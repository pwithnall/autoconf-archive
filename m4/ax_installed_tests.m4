# ===========================================================================
#
# SYNOPSIS
#
#   AX_INSTALLED_TESTS()
#
# DESCRIPTION
#
#   Automates configuration of building and installing unit tests following the
#   installed-tests standard:
#
#     https://wiki.gnome.org/Initiatives/GnomeGoals/InstalledTests
#
#   Defines INSTALLED_TESTS_RULES which should be substituted in your Makefile;
#   and $enable_modular_tests and $enable_installed_tests which can be used in
#   subsequent configure output.  ENABLE_BUILD_TESTS is defined and
#   substituted, and specifies whether unit tests should be built.
#   ENABLE_INSTALL_TESTS is defined and substituted, and specifies whether unit
#   tests should be installed to the system.
#
#   The INSTALLED_TESTS_RULES should be substituted in a Makefile.am and the
#   all_test_programs variable set to a space-separated list of all possible
#   unit test programs to be compiled.  They will be compiled, added to TESTS
#   and installed as specified by the configure options.  all_test_scripts and
#   all_test_data may also be defined and act as analogues for *_SCRIPTS and
#   *_DATA.  .test files will be automatically generated for all tests in
#   all_test_programs and all_test_scripts, using the 'session' test type. If
#   a test requires a custom .test file, it must be created manually.
#
#   Due to automake limitations, you must define TESTS in Makefile.am.
#
#   Usage example:
#
#   configure.ac:
#
#     AX_INSTALLED_TESTS
#
#   Makefile.am:
#
#     @INSTALLED_TESTS_RULES@
#     TESTS = $(NULL)
#     all_test_programs = test1 test3
#     all_test_scripts = test2.py
#     all_test_data = test-data.conf
#
# LICENSE
#
#   Copyright (c) 2015 Philip Withnall <philip.withnall@collabora.co.uk>
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved.  This file is offered as-is, without any
#   warranty.

#serial 1

AC_DEFUN([AX_INSTALLED_TESTS],[
	dnl Installed tests
	AC_ARG_ENABLE([modular_tests],
	              AS_HELP_STRING([--disable-modular-tests],
	                             [Disable build of test programs (default: no)]),,
	              [enable_modular_tests=yes])
	AC_ARG_ENABLE([installed_tests],
	              AS_HELP_STRING([--enable-installed-tests],
	                             [Install test programs (default: no)]),,
	              [enable_installed_tests=no])

	AS_IF([test "$enable_modular_tests" = "yes" ||
	       test "$enable_installed_tests" = "yes"],
	      [enable_build_tests=yes],[enable_build_tests=no])
	AM_CONDITIONAL([ENABLE_BUILD_TESTS],
	               [test "$enable_build_tests" = "yes"])
	AC_SUBST([ENABLE_BUILD_TESTS],[$enable_build_tests])

	AM_CONDITIONAL([ENABLE_INSTALL_TESTS],
	               [test "$enable_installed_tests" = "yes"])
	AC_SUBST([ENABLE_INSTALL_TESTS],[$enable_installed_tests])

INSTALLED_TESTS_RULES='
# Installed tests rules
#
# https://wiki.gnome.org/Initiatives/GnomeGoals/InstalledTests
#
# Optional:
#  - all_test_programs: Space-separated list of test programs to build, install
#    and run. (Default: empty)
#  - all_test_scripts: Space-separated list of test scripts to install and run.
#    (Default: empty)
#  - all_test_data: Space-separated list of test data files to install.
#    (Default: empty)
#  - installed_tests_dir: Directory to install test programs to. This should
#    rarely need to be overridden.
#    (Default: $(libexecdir)/installed-tests/$(PACKAGE))
#  - installed_tests_meta_dir: Directory to install .test files to. This should
#    rarely need to be overridden.
#    (Default: $(datadir)/installed-tests/$(PACKAGE))

# Configuration variables
all_test_programs ?=
all_test_scripts ?=
all_test_data ?=
installed_tests_dir ?= $(libexecdir)/installed-tests/$(PACKAGE)
installed_tests_meta_dir ?= $(datadir)/installed-tests/$(PACKAGE)

noinst_PROGRAMS ?=
noinst_SCRIPTS ?=
noinst_DATA ?=

# Build rules
ifeq ($(ENABLE_BUILD_TESTS),yes)
TESTS += $(all_test_programs) $(all_test_scripts)
noinst_PROGRAMS += $(all_test_programs)
noinst_SCRIPTS += $(all_test_scripts)
noinst_DATA += $(all_test_data)
endif

ifeq ($(ENABLE_INSTALL_TESTS),yes)
insttestdir = $(installed_tests_dir)
insttest_PROGRAMS = $(all_test_programs)
insttest_SCRIPTS = $(all_test_scripts)
insttest_DATA = $(all_test_data)

testmetadir = $(installed_tests_meta_dir)
testmeta_DATA = $(all_test_programs:=.test) $(all_test_scripts:=.test)
endif

%.test: % Makefile
	$(AM_V_GEN) (echo "[Test]" > $[@].tmp; \
	echo "Type=session" >> $[@].tmp; \
	echo "Exec=$(insttestdir)/$<" >> $[@].tmp; \
	mv $[@].tmp $[@])
'

	AC_SUBST([INSTALLED_TESTS_RULES])
	m4_ifdef([_AM_SUBST_NOTMAKE],[_AM_SUBST_NOTMAKE([INSTALLED_TESTS_RULES])])
])
