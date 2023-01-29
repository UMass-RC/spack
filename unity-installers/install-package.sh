#!/bin/bash

# this is a script that starts batch jobs and --wait's for them, and then cleans up after them.

# USAGE
# ./install-package [-a architecture] [-f|g|y] <optional spack arguments> <spack package spec>
# -a install for a specific architecture rather than read from state/archlist.txt
# -d debug mode
# -f spack install --fresh
# -g get a GPU for the job
# -y don't ask "yes or no"

# you can also export EXTRA_SBATCH_ARGS and they will be inserted

PREFIX="/modules/spack-0.19/unity-installers"
NUM_CORES="4"
TIME="1-0"
PARTITION="building"

set -e # exit if any command fails

prompt_yes_or_no() {
    echo $@
    read input
    yes_or_no $input
    result=$?
    if [ $result -eq 2 ]; then
        prompt_yes_or_no $@ # try again
        return $?
    else
        return $result
    fi
}

yes_or_no() {
    case $1 in
        [Yy]) return 0 ;;
        [Yy]es) return 0 ;;
        [Tt]rue) return 0;;
        [Nn]) return  1;;
        [Nn]o) return  1;;
        [Ff]alse) return  1;;
	    *) return 2;;
    esac
}

FRESH_OR_REUSE="--reuse"
GPU=""
while getopts "a:dfgy" option; do
    case $option in
        a) USER_ARCH=$OPTARG;;
        d) export SPACK_DEBUG="-d";;
        f) FRESH_OR_REUSE="--fresh";; # todo no duplicates
        g) GPU="-G 1";; # todo no duplicates
	    y) DO_SKIP_PROMPT="true"
    esac
done
shift $(($OPTIND - 1)) # remove processed args from $@

export SPACK_INSTALL_ARGS="$@ $FRESH_OR_REUSE arch=linux-ubuntu20.04-$arch"
ARGS="$@" # for some reason I can't use $@ directly in the {find/replace}
JOB_NAME="${ARGS// /_}" # find and replace spaces with underscores

arches=$(<$PREFIX/state/family-arch-list.txt)
# if $USER_ARCH is defined, then overwrite the arch list
if [ ! -z ${USER_ARCH+x} ]; then
    arches=($USER_ARCH)
fi

for arch in ${arches[@]}; do
    # include time so that `ls` sorts chronologically
    LOG_FILE="$PREFIX/logs/$(date +%s)-${JOB_NAME}_${arch}.out"
    log_files+=("$LOG_FILE")
    this_job="\
sbatch --job-name="$JOB_NAME" --output="$LOG_FILE" --partition="$PARTITION" \
--cpus-per-task="$NUM_CORES" --time="$TIME" --export=ALL $GPU \
$EXTRA_SBATCH_ARGS $PREFIX/slurm-install-batch.sh"
    echo "$this_job"
    echo
    JOBS+=("$this_job")
done

if [[ $DO_SKIP_PROMPT == "true" ]] || prompt_yes_or_no "do you want to submit these jobs?"; then
    echo
    IFS=$'\n'
    for i in ${!JOBS[@]}; do
	job=${JOBS[$i]}
	logfile=${log_files[$i]}
        eval "$job"
	echo $logfile
	echo
    done
    unset IFS
fi
