# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )
DISTUTILS_USE_PEP517=setuptools
PYPI_VERIFY_REPO="https://github.com/elijahr/python-autopxd2"
inherit distutils-r1 pypi

DESCRIPTION="Generate Cython pxd files from C header files"
HOMEPAGE="
	https://github.com/elijahr/python-autopxd2
	https://pypi.org/project/autopxd2/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

RDEPEND="
	dev-python/click[${PYTHON_USEDEP}]
	dev-python/pycparser[${PYTHON_USEDEP}]
"

# PyPI sdist missing test infrastructure (conftest.py, assertions.py, etc.)
RESTRICT="test"

src_prepare() {
	default

	# Fix deprecated project.license table format (PEP 639)
	sed -i 's/^license = { file = "LICENSE" }/license = "MIT"/' pyproject.toml || die
}
