#!/bin/bash

# this is a script that starts batch jobs and --wait's for them, and then cleans up after them.

# USAGE
# ./install-package [-a architecture] [-f|g] <spack package spec>
# -a install for a specific architecture rather than read from state/archlist.txt
# -f spack install --fresh
# -g get a GPU for the job

# you can also export EXTRA_SPACK_ARGS and they will be inserted
# you can also export EXTRA_SBATCH_ARGS and they will be inserted

prompt_yes_or_no() {
echo $@
read input
yes_or_no $input
result=$?
if [ $result -eq 2 ]; then
    prompt_yes_or_no $@ # try again
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
YES="NO"
PROMPT_USER="true"
while getopts "a:fg" option; do
    case $option in
        a) USER_ARCH=$OPTARG;;
        f) FRESH_OR_REUSE="--fresh";; # todo no duplicates
        g) GPU="-G 1";; # todo no duplicates
	y) PROMPT_USER="false"
    esac
done
shift $(($OPTIND - 1)) # remove processed args from $@
EXTRA_SPACK_ARGS="$EXTRA_SPACK_ARGS $FRESH_OR_REUSE"
EXTRA_SBATCH_ARGS="$EXTRA_SBATCH_ARGS $GPU"

NUM_CORES=2
TIME="1-0"
PARTITION="building"

SPACK_INSTALL_ARGS="$@"

JOB_NAME="${SPACK_INSTALL_ARGS//-}" # remove dashes
JOB_NAME="${JOB_NAME// /_}" # find and replace spaces with underscores

# if EXTRA_SPACK_ARGS is defined, prepend it to SPACK_INSTALL_ARGS
if [ ! -z ${EXTRA_SPACK_ARGS+x} ]; then
    SPACK_INSTALL_ARGS="$EXTRA_SPACK_ARGS $SPACK_INSTALL_ARGS"
fi

arches=$(<state/archlist.txt)
# if $USER_ARCH is defined, then overwrite the arch list
if [ ! -z ${USER_ARCH+x} ]; then
    arches=($USER_ARCH)
fi

for arch in ${arches[@]}; do
    LOG_FILE="logs/$(date +%s)-${JOB_NAME}_${arch}.out" # random so that logs don't overwrite
    log_files+=("$LOG_FILE")
    this_job="\
sbatch --job-name="$JOB_NAME" --constraint=$arch --output=$LOG_FILE \
${EXTRA_SBATCH_ARGS} --partition=$PARTITION --cpus-per-task=$NUM_CORES --time=$TIME \
--export=SPACK_INSTALL_ARGS='$SPACK_INSTALL_ARGS arch=linux-ubuntu20.04-$arch' \
slurm-install-batch.sh"
    echo "$this_job"
    echo
    JOBS+=("$this_job")
done

if [[ $PROMPT_USER == "false" ]]; then
    do_submit="true"
else
    if prompt_yes_or_no "do you want to submit these jobs?"; then
        do_submit="true"
    else
        do_submit="false"
    fi
fi
if [[ $do_submit == "true" ]]; then
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
