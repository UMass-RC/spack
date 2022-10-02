this is a copy of the builtin package with 2 small changes:

https://github.com/spack/spack/blob/d9c008085800c0fb5fbc309a2d847354387d8a52/var/spack/repos/builtin/packages/openmpi/package.py#L920
It says that if we're doing slurm and pmi, then specify pmi path to the slurm prefix.
We're using the system slurm, which doesn't have libpmi2.h there, so I hard code it's location

installing openmpi with our system libpmix, it has a version requirement and the newest it can install is 3.1.6, which is too old, so I changed the version requirement. This may cause problems later on but we'll switch to ubuntu 22 someday.
https://github.com/spack/spack/pull/29449

diff:
```
13a14,15
> PMI_DEV_DIR="/usr/include/slurm"
> PMI_LIB_DIR="/usr/lib/x86_64-linux-gnu"
327c329
<     depends_on('pmix@3.2:', when='@4.0:4')
---
>     depends_on('pmix@3.1:', when='@4.0:4')
684c686,690
<             config_args.append('--with-pmi={0}'.format(spec['slurm'].prefix))
---
>             #config_args.append('--with-pmi={0}'.format(spec['slurm'].prefix))
>             # system slurm pmi2.h parent directory
>             #config_args.append('--with-pmi=/usr/lib/x86_64-linux-gnu')
>             config_args.append(f'--with-pmi={PMI_DEV_DIR}')
>             config_args.append(f'--with-pmi-libdir={PMI_LIB_DIR}')
1051a1058,1064
>     def flag_handler(self, name, flags):
>         wrapper_flags = None
> 
>         if name == 'cflags':
>             wrapper_flags = [f'-I{PMI_DEV_DIR}']
> 
>         return (wrapper_flags, None, flags)
```
