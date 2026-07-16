# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Read Exif metadata from tiff and jpeg files"
HOMEPAGE="https://github.com/ianare/exif-py"
SRC_URI="https://github.com/ianare/exif-py/archive/${PV}.tar.gz -> ${P}.gh.tar.gz"
S="${WORKDIR}/exif-py-${PV}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~mips ~x86"

RDEPEND="${PYTHON_DEPS}"
