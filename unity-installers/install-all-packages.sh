#!/bin/bash

while getopts "a:" option; do
    case $option in
        a) USER_ARCH=$OPTARG;;
    esac
done

IFS=$'\n'

if [ ! -z $USER_ARCH ]; then
    arches=($USER_ARCH)
else
    arches=($(ls packagelist))
fi

echo arches:
for arch in ${arches[@]}; do
    echo $arch
done

for arch in ${arches[@]}; do
    for package in $(cat packagelist/$arch); do
        # if empty/whitespace line or first character is a hash
        if [[ $package =~ ^[[:space:]]*$ ]] || [[ $package =~ ^[[:space:]]*\#.*$ ]]; then
            echo "disregarding '$package'..."
            continue
        fi
        echo $package arch=$arch
        ./install-package.sh -y -a $arch $package > /dev/null
        #sleep 0.25
    done
done
unset IFS