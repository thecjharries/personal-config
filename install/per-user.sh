#!/usr/bin/env zsh
zmodload zsh/pcre

PARENT_PID=$$

unsetopt EVAL_LINENO
[[ "$argv" -pcre-match "-v{4}\b" ]] && setopt xtrace && argv= && echo "Tracing everything"

TRAPZERR() {
    echo ${#pipestatus}

    unset pipestatus
    # kill -KILL $PARENT_PID
}

function help_and_die() {
    cat <<EOS
Usage: ./per-user.sh [-h|--help] [-f|--force] [-d|--destination path] [-s|--source path] [-v|--verbose] [-t|--test] [-l|--log [path]]

    -h, --help           Prints this help and exits
    -f, --force          Annihilates everything.
    -d, --destination    Specifies the destination root. Defaults to \$HOME ($HOME)
    -s, --source         Specifies the source root. Defaults to <location of repo> ($(dirname $(dirname $(readlink -f $0))))
    -v, --verbose        Prints logs of everything it's doing
    -t, --test           Prints a verbose dry without actually moving anything
    -l, --log            Saves a verbose log to the specified path or dies trying. Defaults to <location of repo> ($(dirname $(dirname $(readlink -f $0)))/personal-config.log)

    -vvvv                Starts the script with "setopt xtrace" for debugging. Might be useful if -l/-v aren't working
EOS
    exit 0
}

unset MATCH match
pcre_compile -i "\-(?:\-?\?|h|-help)"

pcre_match -- "$argv"
[[ -n "$MATCH" ]] && help_and_die

test=("")
force=("")
destination_root=("$HOME")
source_dir=("$(dirname $(dirname $(readlink -f $0)))")
verbose=("")
zparseopts -D -K -M -E -- t=test -test=t f=force -force=f d:=directoryopt -dest:=d s:=source -source:=s h=help -help=h \?=h v=verbose -verbose=v
unset MATCH match
pcre_compile -i "\-(?:l|\-log)\s*([^\-\"\'](?:\\ |\S)*|[\"\'][^\"\']+[\"\'])?"
pcre_match -- "$argv"
if [[ -n "$MATCH" ]]; then
    log=true
    log_path=$(readlink -m ${match:-"$(dirname $(dirname $(readlink -f $0)))/personal-config.log"})
    touch "$log_path" || (echo "Unable to access log $log_path" && exit 1)
else
    log=false
    log_path=/dev/null
fi
unset MATCH match

[[ -n "${verbose//\-/}" || -n "$test" ]] && verbose=true

function logger() {
    zparseopts -D -K -E -- e:-=error_message
    input=("$argv")
    chained_retval=0
    for explodeands (${(s:&&:)input}); do
        for subcommand (${(s:||:)explodeands}); do
            if [[ "$subcommand" -pcre-match "^\s*\[\[(?!:\]{2})([\s\S]*?)\]\]\s*$" ]]; then
                output="$subcommand is $(eval "$subcommand" && echo true || echo false)"
            elif [[ -n "$test" && ! "$subcommand" =~ "^safe_find" ]]; then
                output="$subcommand"
            else
                output="$(eval $subcommand)"
                retval="$?"
                ((chained_retval+=$retval))
                case $retval in
                    1)
                        output=$([[ "$subcommand" -pcre-match "^\s*exit" ]] && echo "$subcommand" || echo "Error code 1 in '$subcommand', that isn't helpful")
                        ;;
                    127)
                        output="$subcommand"
                        ;;
                    [0-9]*[1-9])
                        output="MASSIVE ERRORS IN '$subcommand' (code $retval)"
                        ;;
                    0)
                        # do nothing
                        ;;
                    *)
                        echo "Nonstandard exit code detected; that's kinda scary"
                        exit $retval
                        ;;
                esac
            fi
            [[ true = "$verbose" ]] && (echo "$output" >> $log_path && echo "$output")
        done
    done
    [[ "$chained_retval" -gt 0 ]] && return 1
    return 0
}

find_mode=$([[ -n "$test" ]] && echo "-print" || echo "-print") #TODO: swap out "-delete")

function safe_find() {
    maxdepth=(0)
    zparseopts -D -K -M -E -- name:=name maxdepth:-=maxdepth
    find "${1:-.}"$([[ 0 -lt "$maxdepth" ]] && echo " -maxdepth $maxdepth") "$find_mode"$([[ -n $name ]] && echo " -name $name")
}

# Validate destinate or create
logger "[[ -d $destination_root ]] || mkdir -p $destination_root"
logger "[[ ! -d $source_dir ]] || exit 1"
exit 0

# Validate source directory
if [[ ! -d "$source_dir" ]]; then
    echo "Cannot find source $source_dir"
    exit 1
fi

# Set up flags
[[ -n "$force" ]] && force=true

echo "cd $source_dir"
cd $location
echo "Updating submodules"


if [[ -d "$source_dir" ]]; then

    # TODO: error handling
    git submodule init
    git submodule update --recursive


    echo "Linking files"
    if [[ true = "$force" ]]; then
        rm -rvf "$HOME/.zprezto" "$HOME/.nano"
    fi
    ln -s "$location/.zprezto" "$HOME/.zprezto"
    ln -s "$location/.nano" "$HOME/.nano"

    echo "Linking configuration files"
    # Nano's symlinked
    ln -s ~/.nano/nanorc ~/.nanorc

    # link any Prezto files that aren't present
    setopt EXTENDED_GLOB
    for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
        [[ true = "$force" ]] && rm -vf "${ZDOTDIR:-$HOME}/.${rcfile:t}"
        ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
    done

else
    echo "Could not find $source_dir"
fi
