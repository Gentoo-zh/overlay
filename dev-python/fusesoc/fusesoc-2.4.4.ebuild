# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="
Award-winnning package manager and build abstraction tool for HDL code
"
HOMEPAGE="
	https://github.com/olofk/fusesoc/
	https://pypi.org/project/fusesoc/
"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/edalize-0.4.1
	>=dev-python/pyparsing-2.3.1
	>=dev-python/pyyaml-6.0
	>=dev-python/simplesat-0.9.1
	dev-python/fastjsonschema
	dev-python/argcomplete
"

# prohibit network environment
RESTRICT="test"
