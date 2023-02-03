#!/bin/bash
PREFIX="/modules/spack-0.19/unity-installers"
latest_log_file="logs/$(ls $PREFIX/logs | grep -v failed-builds | tail -n 1)"
if [ ! -z $EDITOR ]; then
    $EDITOR $latest_log_file
else
    less $latest_log_file
fi
