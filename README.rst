==========
 Cool App
==========

.. more badges cannot be enabled yet (see document footer) without
   policy and license answers plus backend integration (and some
   code cleanup)

|ci| |codeql| |cpplint| |coverage|

|pre| |cov|

|tag| |std|

The cool app fulfills the following requirements:

:REQ00010: The cool app Shall_00010 serve as a minimal but buildable example application.
:REQ00020: The cool app Shall_00020 demonstrate simple (slighly cheesy) tests.
:REQ00030: The cool app Shall_00030 display a version number.

.. BEGIN-usage-cut-marker-comment

Start a repo using this template, then run find/grep on the repository contents
for ``app_name/app-name`` and *change* each instance to the real app name::

  $ find . -name \*app_name\*
  $ grep app_name -R

Then replace the requirements above some functional requirements appropriate
to the planned application, ie, *what should it do?*

Next, *replace* the text in this section with a nice description of the real
application. Then remove and/or copy over the stub code (ie, replace it with
your own source code) and then update the ``CMakeLists.txt`` file in the app
directory with the new source file names.

Finally, install and update pre-commit in your new repo, then run it to cleanup
any annoying nits ``;)``  After running the install and autoupdate commands in
the following section, run the following to start the cleanup::

  $ pre-commit run --all-files


.. important:: For the coverage workflow/badge/PR comments, you must first create and push
  an orphan ``badges`` branch, exactly like you would `create a gh-pages branch`_.

Once all the above is done and committed, create a ``v0.0.0`` tag on the tip of
your develop branch and push it to your shiny new repository::

  $ git tag v0.0.0
  $ git push --tags

Note this can be any tag, even a "lightweight" tag.  This will allow the cmake
files to use ``git describe`` to generate the SCM_VERSION_INFO used in the build.

.. _create a gh-pages branch: https://jiafulow.github.io/blog/2020/07/09/create-gh-pages-branch-in-existing-repo/

Finally, when these adjustments are done, delete this block of text between
the BEGIN- and END- marker comments.

.. END-usage-cut-marker-comment


Making Changes & Contributing
=============================

This repo is now pre-commit_ enabled for various linting and format checks
(and in many cases, automatic fixes).  The checks run on commit/push and will
fail the commit (if not clean) with some checks performing simple file corrections.
Simply review the changes and adjust (if needed) then ``git add`` the files and continue.

If other checks fail on commit, the failure display should explain the error
types and line numbers. Note you must fix any fatal errors for the commit to
succeed; some errors should be fixed automatically (use ``git status`` and
`` git diff`` to review any changes).

Note cpplint_ is the primary check that requires your own input, as well
as a decision as to the appropriate fix action.  You must fix any cpplint_
warnings (relative to the baseline config file) for the commit to succeed.

See the pre-commit docs under ``docs/dev/`` for more information:

* pre-commit-config_
* pre-commit-usage_

You will need to install pre-commit before contributing any changes;
installing it using your system's package manager is recommended,
otherwise install with pip into your local user's virtual environment
using something like::

  $ sudo emerge pre-commit  --or--
  $ pip install pre-commit

then install it into the repo you just cloned::

  $ git clone https://github.com/goletastar/gs-app-name
  $ cd gs-app-name/
  $ pre-commit install
  $ pre-commit install-hooks

It's usually a good idea to update the hooks to the latest version::

    pre-commit autoupdate


.. _pre-commit: http://pre-commit.com/
.. _cpplint: https://github.com/cpplint/cpplint
.. _pre-commit-config: docs/dev/pre-commit-config.rst
.. _pre-commit-usage: docs/dev/pre-commit-usage.rst


Prerequisites
-------------

Updated packages are available for Ubuntu_, and the latest can be installed
on Gentoo using the ebuilds in `this portage overlay`_.  For more details
on the exact tool/library versions, see the `Build Dependencies`_ section
below.

.. _Ubuntu: https://launchpad.net/~nerdboy/+archive/ubuntu/embedded
.. _this portage overlay: https://github.com/VCTLabs/embedded-overlay/


A supported linux distribution, mainly something that uses either ``.ebuilds``
(eg, Gentoo or funtoo) or ``.deb`` packages, starting with at least Ubuntu
bionic or Debian stretch (see the above PPA package repo on Launchpad).

Make sure you have the ``add-apt-repository`` command installed and then add
the PPA:

::

  $ sudo apt-get install software-properties-common
  $ sudo add-apt-repository -y -s ppa:nerdboy/embedded
  $ sudo apt-get install cmake libspdlog-dev libfmt-dev libredis-ipc-dev
  $ sudo apt-get install libgtest-dev libgmock-dev gcovr lcov


.. note:: If building/installing on Ubuntu bionic, you will *need* to install
          several dependencies from the PPA (this is also true for focal, but
          to a much lesser extent).


If you get a key error you will also need to manually import the PPA
signing key like so:

::

  $ sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys <PPA_KEY>

where <PPA_KEY> is the key shown in the launchpad PPA page under "Adding
this PPA to your system", eg, ``41113ed57774ed19`` for `Embedded device ppa`_.


.. _Embedded device ppa: https://launchpad.net/~nerdboy/+archive/ubuntu/embedded


Build and test with Tox
-----------------------

As long as you have git and at least Python 3.6, then the "easy" dev
install is to clone this repository and install `tox`_.

After cloning the repository, you can run the current tests using cmake (and
optional build generator) with the ``tox`` command.  It will build a virtual
python environment with most of the build dependencies (except the shared
libraries above and toolchain) and then run the tests. For cmake
plus test coverage, you would first install your toolchain, the required
libraries, and tox, then run the following commands:

::

  $ git clone https://github.com/goletastar/gs-app-name  # this name is fictional
  $ cd gs-app-name
  $ tox -e ctest

The above will build and run the tests with coverage display.  You can view
each of the ``tox`` test commands in the console, prefixed with the environment
name and ``run-test: commands[N]`` (where ``N`` is incremented for each sub-cmd
run in that environment).  Note you can always examine the ``tox.ini`` file for
more commands.

There are several ``tox -e`` environment commands available:

* ``ctest`` - build/run tests using single ctest cmd (runs from the top-level directory)
* ``tests`` - build/run tests using individual cmake cmds (run from build directory)
* ``clang`` - build/run tests with clang toolchain file (no coverage)
* ``lint`` - run the cpplint style checks
* ``clean`` - clean the cmake build/ directory/files
* ``bionic`` - build/run tests with old bionic gtest pkgs (should not be needed with PPA pkgs)

See the `Github workflow files`_ for more details on the packages installed
for each runner OS environment.

.. _tox: https://github.com/tox-dev/tox
.. _Github workflow files: https://github.com/goletastar/gs-app-template/tree/develop/.github/workflows


Linting configuration
---------------------

The ``cpplint`` configuration file has no support for recursive excludes so we *may* use
``pre-commit`` regex in the ``.pre-commit-config.yaml`` file to limit the sources
passed to ``cpplint`` when running pre-commit hooks during a commit. This means
running ``cpplint`` by hand or via the tox ``lint`` command *will not use these excludes*
so the following manual lint command should be used (when needed) instead::

  $ pre-commit run cpplint -a  # manually run cpplint on all source files


Displaying package version
--------------------------

Project (and package) metadata is generated directly from git during the build
and populated using the ``config.h.in`` template file.  Things to note about
command-line tools and version display:

* the 4-digit package version contains an extra refcount digit to indicate the distance
  in commits from the closest tag
* an (optional) alternate version string using the full output of ``git describe`` is
  available by setting ``-DVERSION_FORMAT_DEV=TRUE`` for a given cmake build configuration

Default version display::

  $ ./build/app_name/app_name -v
  0.0.0.50

Alternate (dev) version display::

  $ ./build/app_name/app_name -v
  0.0.0-50-ged5a10d


Build Dependencies
==================

The current build supports using the "latest" distro packages to satisfy the
primary project dependencies, albeit with some help from the PPA or overlay;
in general, you will need the following:

* cmake >= 3.18
* redis_ipc >= 0.0.2 https://github.com/VCTLabs/redis-ipc/
* spdlog 1.9.2+ (v1.x branch) https://github.com/gabime/spdlog/
* fmtlib 8.0.1+ https://github.com/fmtlib/fmt/
* googletest 1.10.0+ https://github.com/google/googletest

Take careful note of the versions below for each Linux environment.

* Ubuntu bionic (``=>`` PPA upgrade version)

  - cmake 3.10.2-1 ``=>`` 3.18.4-2ubuntu1.bpo2
  - libgtest-dev 1.10.0-2 ``=>`` 1.10.0-2ubuntu1
  - libgmock-dev ``=>`` 1.10.0-2ubuntu1
  - libspdlog-dev 0.16.3-1 ``=>`` 1.9.2-1ubuntu2
  - libfmt-dev 4.0.0+ds-2 ``=>`` 8.0.1-1build1.bpo2
  - libredis-ipc-dev 0.0.3-1ubuntu3

* Ubuntu focal (``=>`` PPA upgrade version)

  - cmake 3.16.3-1 ``=>`` 3.18.4-2ubuntu1.bpo1
  - libgtest-dev 1.10.0-2
  - libgmock-dev 1.10.0-2
  - libspdlog-dev_1.5.0-1 ``=>`` 1.9.2-1ubuntu1
  - libfmt-dev 6.1.2+ds-2 ``=>`` 8.0.1-1build1.bpo1
  - libredis-ipc-dev 0.0.3-1ubuntu4

* Gentoo

  - dev-util/cmake-3.20.5
  - dev-cpp/gtest-1.10.0_p20200702
  - dev-libs/spdlog-1.9.2
  - dev-libs/libfmt-8.0.1-r1
  - dev-embedded/redis-ipc-0.0.3


Useful CMake Build Options
==========================

The following manual examples are mainly for illustrative purposes; you
should probably be using the ``tox`` commands instead.

Other than build type, these are set via cmake/configure (not make/build).
To change an existing build, remove the contents from the ``build`` folder
and then run the ``cmake`` configure command again.  Prefix each build option
with ``-D`` as shown in the examples below.

* CMAKE_TOOLCHAIN_FILE - use a non-default toolchain on the build host
* CMAKE_BUILD_TYPE - one of Release, Debug, RelWithDebInfo (default).
  Note this changes both debug *and* optimization flags.
* WITH_COVERAGE - run the build with test coverage enabled

The following should not be necessary if using the PPA:

* GOOGLETEST_SRC_DIR - point the build at googletest sources (only needed on bionic)

Examples
--------

::

  $ cd build
  $ cmake ..
  $ cmake -DCMAKE_TOOLCHAIN_FILE=../clang_toolchain.cmake ..
  $ rm -rf *
  $ cmake -DCMAKE_BUILD_TYPE=Debug ..


GoogleTest on Ubuntu
====================

You can now skip the following extra configure step (using GOOGLETEST_SRC_DIR)
if you installed the PPA packages; otherwise continue reading...

There is a googletest package in the universe repo of both bionic and focal
ubuntu releases, however, *on bionic there is no* libgmock-dev package, so
the workaround below must be used to build the gmock modules from the
googletest source package (already installed as a dependency of libgtest).

On Ubuntu 18.04 (bionic) without the PPA
----------------------------------------

* Enable ``universe`` and install the same dependencies as below (except
  for libgmock-dev)
* Supply path to googletest source to cmake::

  $ mkdir build && cd build
  $ cmake -DWITH_COVERAGE=TRUE -DGOOGLETEST_SRC_DIR=/usr/src/googletest ..
  $ make -j4
  $ make check
  $ gcovr -s -r ../ -e ../app_name/test app_name/


On Ubuntu 20.04 (focal)
-----------------------

Install the build dependencies:

* libgtest-dev libspdlog-dev libfmt-dev
* gcovr lcov libgmock-dev

To build with test coverage enabled::

  $ mkdir build && cd build && cmake -DWITH_COVERAGE=TRUE ..


GoogleTest on Yocto/OpenEmbedded
================================

There is a googletest package in meta-oe repo that does install pre-compiled
binary libraries into the sysroot. Thus, it is sufficient just to add googletest
to the recipe ``DEPENDS``.


.. |ci| image:: https://github.com/goletastar/gs-app-template/actions/workflows/smoke.yml/badge.svg
    :target: https://github.com/goletastar/gs-app-template/actions/workflows/smoke.yml
    :alt: GitHub CI Smoke Test Status

.. |codeql| image:: https://github.com/goletastar/gs-app-template/actions/workflows/codeql.yml/badge.svg
    :target: https://github.com/goletastar/gs-app-template/actions/workflows/codeql.yml
    :alt: GitHub CI CodeQL Status

.. |cpplint| image:: https://github.com/goletastar/gs-app-template/actions/workflows/cpplint.yml/badge.svg
    :target: https://github.com/goletastar/gs-app-template/actions/workflows/cpplint.yml
    :alt: GitHub CI Cpplint Status

.. |coverage| image:: https://github.com/goletastar/gs-app-template/actions/workflows/coverage.yml/badge.svg
    :target: https://github.com/goletastar/gs-app-template/actions/workflows/coverage.yml
    :alt: GitHub CI Coverage Status

.. |pre| image:: https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white
   :target: https://github.com/pre-commit/pre-commit
   :alt: pre-commit

.. |cov| image:: https://raw.githubusercontent.com/goletastar/gs-app-template/badges/develop/test-coverage.svg?token=AACJLLPL6OKCWJ2CZPYLAQTB2ZGR6
    :target: https://github.com/goletastar/gs-app-template/
    :alt: Test coverage (branches)

.. |tag| image:: https://img.shields.io/badge/latest%20%20release-None-00000.svg
    :target: https://github.com/goletastar/gs-app-template/releases
    :alt: Static value (no tags)

.. |std| image:: https://img.shields.io/badge/Standards-C++11%20%20C99-00000.svg
    :target: https://isocpp.org/wiki/faq/cpp11
    :alt: Language standards
