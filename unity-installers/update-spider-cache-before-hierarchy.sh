#!/bin/bash

export MODULEPATH="/modules/spack/share/spack/modules/linux-ubuntu20.04-cascadelake:/modules/spack/share/spack/modules/linux-ubuntu20.04-haswell:/modules/spack/share/spack/modules/linux-ubuntu20.04-icelake:/modules/spack/share/spack/modules/linux-ubuntu20.04-skylake_avx512:/modules/spack/share/spack/modules/linux-ubuntu20.04-x86_64:/modules/spack/share/spack/modules/linux-ubuntu20.04-zen:/modules/spack/share/spack/modules/linux-ubuntu20.04-zen2"

source /modules/lmod/lmod/lmod/libexec/update_lmod_system_cache_files -d /modules/lmod/cache $MODULEPATH
