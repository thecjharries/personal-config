#!/bin/bash
# This should be all the things you need to do on a new server running CentOS 7
# TODO: maybe add other distros?

# Install the necessaries
# As root
yum makecache fast
yum install -y epel-release
yum update
# Add additional repos

# Node 7
curl --silent --location https://rpm.nodesource.com/setup_7.x | bash -

# Install all packages
yum install -y \
    gcc gcc-c++ mak openssl openssl-devel \
    nginx certbot \
    postfix mailx cyrus-sasl cyrus-sasl-plain \
    curl curl-devel \
    git \
    nano \
    nodejs \
    unzip \
    zsh

# firewalld
# https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-using-firewalld-on-centos-7
# TODO: pull into script

# NGINX Setup
# https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-centos-7
# TODO: pull into script

# Let's Encrypt setup
# https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-centos-7
# TODO: pull into script

# Postfix w/Google
# https://www.howtoforge.com/tutorial/configure-postfix-to-use-gmail-as-a-mail-relay/
# TODO: pull into script
