# Unity Spack

### Configuration ###

`etc/spack/*.yaml`

### Install scripts ###

`unity-installers/`

### Package Repo ###

`unity-repo/`

### Source code changes ###

* ["gcc/9.4.0" rather than "Core" for the module hierarchy](https://github.com/UMass-RC/spack/commit/8368bdae39be5f628b267cfdd9aa8ca485815a1b)

<<<<<<< HEAD
For a cheat sheet on Spack syntax, run `spack help --spec`.

Tutorial
----------------

We maintain a
[**hands-on tutorial**](https://spack.readthedocs.io/en/latest/tutorial.html).
It covers basic to advanced usage, packaging, developer features, and large HPC
deployments.  You can do all of the exercises on your own laptop using a
Docker container.

Feel free to use these materials to teach users at your organization
about Spack.

Community
------------------------

Spack is an open source project.  Questions, discussion, and
contributions are welcome. Contributions can be anything from new
packages to bugfixes, documentation, or even new core features.

Resources:

* **Slack workspace**: [spackpm.slack.com](https://spackpm.slack.com).
  To get an invitation, visit [slack.spack.io](https://slack.spack.io).
* [**Github Discussions**](https://github.com/spack/spack/discussions): not just for discussions, also Q&A.
* **Mailing list**: [groups.google.com/d/forum/spack](https://groups.google.com/d/forum/spack)
* **Twitter**: [@spackpm](https://twitter.com/spackpm). Be sure to
  `@mention` us!

Contributing
------------------------
Contributing to Spack is relatively easy.  Just send us a
[pull request](https://help.github.com/articles/using-pull-requests/).
When you send your request, make ``develop`` the destination branch on the
[Spack repository](https://github.com/spack/spack).

Your PR must pass Spack's unit tests and documentation tests, and must be
[PEP 8](https://www.python.org/dev/peps/pep-0008/) compliant.  We enforce
these guidelines with our CI process. To run these tests locally, and for
helpful tips on git, see our
[Contribution Guide](https://spack.readthedocs.io/en/latest/contribution_guide.html).

Spack's `develop` branch has the latest contributions. Pull requests
should target `develop`, and users who want the latest package versions,
features, etc. can use `develop`.

Releases
--------

For multi-user site deployments or other use cases that need very stable
software installations, we recommend using Spack's
[stable releases](https://github.com/spack/spack/releases).

Each Spack release series also has a corresponding branch, e.g.
`releases/v0.14` has `0.14.x` versions of Spack, and `releases/v0.13` has
`0.13.x` versions. We backport important bug fixes to these branches but
we do not advance the package versions or make other changes that would
change the way Spack concretizes dependencies within a release branch.
So, you can base your Spack deployment on a release branch and `git pull`
to get fixes, without the package churn that comes with `develop`.

The latest release is always available with the `releases/latest` tag.

See the [docs on releases](https://spack.readthedocs.io/en/latest/developer_guide.html#releases)
for more details.

Code of Conduct
------------------------

Please note that Spack has a
[**Code of Conduct**](.github/CODE_OF_CONDUCT.md). By participating in
the Spack community, you agree to abide by its rules.

Authors
----------------
Many thanks go to Spack's [contributors](https://github.com/spack/spack/graphs/contributors).

Spack was created by Todd Gamblin, tgamblin@llnl.gov.

### Citing Spack

If you are referencing Spack in a publication, please cite the following paper:

 * Todd Gamblin, Matthew P. LeGendre, Michael R. Collette, Gregory L. Lee,
   Adam Moody, Bronis R. de Supinski, and W. Scott Futral.
   [**The Spack Package Manager: Bringing Order to HPC Software Chaos**](https://www.computer.org/csdl/proceedings/sc/2015/3723/00/2807623.pdf).
   In *Supercomputing 2015 (SC’15)*, Austin, Texas, November 15-20 2015. LLNL-CONF-669890.

On GitHub, you can copy this citation in APA or BibTeX format via the "Cite this repository"
button. Or, see the comments in `CITATION.cff` for the raw BibTeX.

License
----------------

Spack is distributed under the terms of both the MIT license and the
Apache License (Version 2.0). Users may choose either license, at their
option.

All new contributions must be made under both the MIT and Apache-2.0
licenses.

See [LICENSE-MIT](https://github.com/spack/spack/blob/develop/LICENSE-MIT),
[LICENSE-APACHE](https://github.com/spack/spack/blob/develop/LICENSE-APACHE),
[COPYRIGHT](https://github.com/spack/spack/blob/develop/COPYRIGHT), and
[NOTICE](https://github.com/spack/spack/blob/develop/NOTICE) for details.

SPDX-License-Identifier: (Apache-2.0 OR MIT)

LLNL-CODE-811652
=======
* [modules placed in cpu-family specific directories](https://github.com/UMass-RC/spack/commit/5857e44663a1d3a182026b3b5b2a0a9b936faaf6)
>>>>>>> Update README.md
