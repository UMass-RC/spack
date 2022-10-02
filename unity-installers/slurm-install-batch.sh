#!/bin/bash

source /etc/profile # refresh $MODULEPATH
echo "Loading spack environment..."
source ../share/spack/setup-env.sh

echo "which spack? $(which spack)"

ARCH=$(spack arch)
echo jobid $SLURM_JOB_ID on host $(hostname) with arch $(spack arch) by user $(whoami) on $(date)

echo spack install --verbose -y $SPACK_INSTALL_ARGS
spack install --verbose -y $SPACK_INSTALL_ARGS

#--keep-stage will leave the build logs in /scratch, which will get cleaned up by /scratch anyways
# but it only does so if the installation was a success, and that's exactly when I don't want the logs

#--debug will say a lot of stuff and include tracebacks in spack codebase

#-V will spit out much (but not all) of the build log in the regular log. Good because the build log gets deleted.

