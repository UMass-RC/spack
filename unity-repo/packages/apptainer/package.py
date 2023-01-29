# Copyright 2013-2022 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)


from spack.package import *
from spack.pkg.builtin.singularityce import SingularityBase


# Apptainer is the new name of Singularity, piggy-back on the original package
class Apptainer(SingularityBase):
    """Apptainer is an open source container platform designed to be simple, fast, and
    secure. Many container platforms are available, but Apptainer is designed for
    ease-of-use on shared systems and in high performance computing (HPC)
    environments.

    Needs post-install chmod/chown steps to enable full functionality.
    See package definition or `spack-build-out.txt` build log for details,
    e.g.::

        tail -15 $(spack location -i apptainer)/.spack/spack-build-out.txt
    """

    homepage = "https://apptainer.org"
    url = "https://github.com/apptainer/apptainer/releases/download/v1.0.2/apptainer-1.0.2.tar.gz"
    git = "https://github.com/apptainer/apptainer.git"

    version("main", branch="main")
    version("1.0.2", sha256="2d7a9d0a76d5574459d249c3415e21423980d9154ce85e8c34b0600782a7dfd3")
    version("1.1.5", sha256="f6ed14a02a5bb31cc75371d99309abca1d6aa6c5b04295e73a0701a26d0a31af")

    singularity_org = "apptainer"
    singularity_name = "apptainer"
    singularity_security_urls = (
        "https://apptainer.org/docs/admin/main/security.html",
        "https://apptainer.org/docs/admin/main/admin_quickstart.html#apptainer-security",
    )
