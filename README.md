# Unity Spack

Complete Unity Spack ready to be cloned anywhere and produce modulefiles in central directory `/modules/spack/share/spack/lmod`. This allows us stay flexible with future Spack updates.

### Configuration ###

`etc/spack/*.yaml`

### Install scripts ###

`unity-installers/`

### Package Repo ###

`unity-repo/`

### Source code changes ###

* ["gcc/9.4.0" rather than "Core" for the module hierarchy](https://github.com/UMass-RC/spack/commit/8368bdae39be5f628b267cfdd9aa8ca485815a1b)

* [modules placed in cpu-family specific directories](https://github.com/UMass-RC/spack/commit/5857e44663a1d3a182026b3b5b2a0a9b936faaf6)
