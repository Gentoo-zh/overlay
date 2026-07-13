# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..14} python3_13t )
inherit python-any-r1

EGIT_COMMIT=59456757ca1f0736dcf03b507f661a3693f5b51d

DESCRIPTION="Fcitx5 theme to match KDE's Breeze style"
HOMEPAGE="https://gitlab.com/scratch-er/fcitx5-breeze"
SRC_URI="https://gitlab.com/scratch-er/fcitx5-breeze/-/archive/v${PV}/fcitx5-breeze-${PV}.tar.bz2"

S="${WORKDIR}/fcitx5-breeze-v${PV}-${EGIT_COMMIT}"

LICENSE="GPL-3"
SLOT="5"
KEYWORDS="~amd64 ~x86"

BDEPEND="${PYTHON_DEPS}
	media-gfx/inkscape"
RDEPEND="
	app-i18n/fcitx:5"

src_compile() {
	./build.py
}

src_install() {
	insinto /usr/share/fcitx5/themes
	doins -r build/*
}
