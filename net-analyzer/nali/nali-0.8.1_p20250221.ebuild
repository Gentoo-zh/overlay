# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit go-module

DESCRIPTION="An offline tool for querying IP geographic information and CDN provider"
HOMEPAGE="https://github.com/zu1k/nali"
EGIT_COMMIT="a41f45b7d9f0ad69631a19a21bd60ae00a777126"
SRC_URI="
	https://github.com/zu1k/nali/archive/${EGIT_COMMIT}.tar.gz -> ${P}.gh.tar.gz
	https://github.com/gentoo-zh/gentoo-deps/releases/download/${P}/${P}-vendor.tar.xz
"

S="${WORKDIR}/${PN}-${EGIT_COMMIT}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

src_compile() {
	local ldflags="
		-X github.com/zu1k/nali/internal/constant.Version=${PV}
		"
	ego build -ldflags "${ldflags}"
}

src_install() {
	dobin ${PN}
}
