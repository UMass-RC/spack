#!/bin/bash
# the microarch modules allow Lmod to crawl through the spack modules for each microarch
# when we make the hierarchy change, we just have to change the microarch modules
export MODULEPATH="/modules/modulefiles"

source /modules/lmod/lmod/lmod/libexec/update_lmod_system_cache_files -d /modules/lmod/cache $MODULEPATH

echo "this does not update spider cache for power9 nodes, their cache is somewhere else"
