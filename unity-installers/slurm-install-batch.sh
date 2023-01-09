#!/bin/bash

# why is this here?
#source /etc/profile # refresh $MODULEPATH

source ../share/spack/setup-env.sh
echo "which spack? $(which spack)"
echo jobid $SLURM_JOB_ID on host $(hostname) by user $(whoami) on $(date)

spack install --verbose -y $SPACK_INSTALL_ARGS

#--keep-stage will leave the build logs in /scratch, which will get cleaned up automatically
# but it only does so if the installation was a success, and that's exactly when I don't want the logs

#--debug will include tracebacks in spack source code
#--verbose will spit out much (but not all) of the build log in the regular log. Good because the build log gets deleted.

