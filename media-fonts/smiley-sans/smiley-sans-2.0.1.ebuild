# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit font

MY_PN="SmileySans"
DESCRIPTION="An open-source font for Chinese"
HOMEPAGE="https://github.com/atelier-anchor/smiley-sans"
SRC_URI="https://github.com/atelier-anchor/smiley-sans/releases/download/v${PV}/smiley-sans-v${PV}.zip -> ${P}.zip"
S=${WORKDIR}

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64"
BDEPEND="app-arch/unzip"
FONT_SUFFIX="ttf otf"

src_unpack() {
	default
	# rename the font files
	mv ${MY_PN}-Oblique.otf ${MY_PN}.otf || die "Renaming otf fonts failed"
	mv ${MY_PN}-Oblique.ttf ${MY_PN}.ttf || die "Renaming ttf fonts failed"
}
