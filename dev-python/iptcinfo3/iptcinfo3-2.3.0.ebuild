# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="To read/write image metadata"
HOMEPAGE="
	https://github.com/james-see/iptcinfo3
	https://pypi.org/project/IPTCInfo3/
"

SRC_URI="https://github.com/james-see/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="|| ( Artistic GPL-1+ )"

SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
	test? (
		dev-python/pytest[${PYTHON_USEDEP}]
		dev-python/pytest-cov[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest
