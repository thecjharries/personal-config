# `personal-config`

This is my attempt at setting up a full environment from a repo, à la [dotfiles](https://dotfiles.github.io/). I recently spun up a new server and I plan on upgrading my desktop at some point in the near future. Because I am very, very lazy, I hate doing the same thing over and over.

## Overview

### `zsh`

Initially I tried to set everything up as `zsh` scripts, which was a huge mistake. `zsh`'s documentation is scattered across a ton of different websites, listservs, and repos. There's no central place to find anything useful, and Google/Stack Overflow tend to mix `zsh` results with all the other shells. I also really wanted to avoid wasting time learning yet another testing framework. After spending a full day watching a simple "move these files" script explode with feature creep (albeit necessary creep; I'd like to use this across current systems which means I have to be able perform dry runs), I decided to abandon `zsh` as the runner.

### `ts-node`

Node does all of the things I want. I wrote it in TypeScript instead of vanilla JS for the experience. [ShellJS](https://github.com/shelljs/shelljs) even removes the annoyance of interfacing with the OS (sure, a native `sed` might be faster, but this is a limited use app, not a `* * * * *` `cron`).



