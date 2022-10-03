#!/bin/bash

while getopts "a:" option; do
    case $option in
        a) USER_ARCH=$OPTARG;;
    esac
done

IFS=$'\n'
packages=$(<state/packagelist.txt)
for package in $packages; do
# bash seems to remove empty lines on its own
#    if [[ "$package" == '' ]]; then
#        echo "disregarding '$package'..."
#        continue
#    fi
    if [[ $package =~ ^[[:space:]]+$ ]]; then
        echo "disregarding '$package'..."
        continue
    fi
    if [[ $package =~ ^[[:space:]]*\#.*$ ]]; then
        echo "disregarding '$package'..."
        continue
    fi
    # if $USER_ARCH is defined
    if [ ! -z ${USER_ARCH+x} ]; then
        ./install-package.sh -y -a $USER_ARCH $package
    else
        ./install-package.sh -y $package
    sleep .3
    fi
done
unset IFS
