#!/bin/bash

# add the install to the packagelist
#grep -qxF "$SPACK_INSTALL_ARGS" state/packagelist.txt || echo $SPACK_INSTALL_ARGS >> state/packagelist.txt

echo
echo "removing implicit modules from Lmod..."
./hide-implicit-mods-thorough.py

echo
echo "updating Lmod spider cache..."
./update-spider-cache-before-hierarchy.sh
echo "reminder: after the module hierarchy change, the other spider cache updating script should be used!
