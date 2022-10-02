#!/bin/bash

while getopts "a:" option; do
    case $option in
        a) USER_ARCH=$OPTARG;;
    esac
done

IFS=$'\n'
packages=$(<state/packagelist.txt)

for package in $packages; do
    # if $USER_ARCH is defined
    if [ ! -z ${USER_ARCH+x} ]; then
        ./install-package.sh -a $USER_ARCH $package
    else
        ./install-package.sh $package
    sleep .3
    fi
done
unset IFS
