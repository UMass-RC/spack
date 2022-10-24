#!/bin/bash

# set the flat view modulepath
export LMOD_ENABLE_LIMITED_VIEW=false 
source /modules/admin-resources/new-spack-demo/profile.d/modulepath.sh
echo source /modules/lmod/lmod/lmod/libexec/update_lmod_system_cache_files -d /modules/lmod/cache $MODULEPATH

echo this script does nothing right now, it should not be fixed/run until the hierarchy module change
