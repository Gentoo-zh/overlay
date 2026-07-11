# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Manage all your runtime versions with one tool"
HOMEPAGE="https://github.com/asdf-vm/asdf"
SRC_URI="
	https://github.com/asdf-vm/asdf/archive/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/gentoo-zh-drafts/asdf/releases/download/v${PV}/asdf-${PV}-vendor.tar.xz
"
S="${WORKDIR}/asdf-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="test"

BDEPEND=">=dev-lang/go-1.26.3"

DOCS=( CHANGELOG.md README.md )

src_compile() {
	local ldflags="-X 'main.Version=${PV}'"
	ego build -o ${P} -ldflags "${ldflags}" ./cmd/asdf
}

src_install() {
	einstalldocs
	newbin ${P} asdf
}
