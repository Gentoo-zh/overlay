# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN=${PN/-bin}
MY_PATH=/opt/${MY_PN}

DESCRIPTION="An interactive Git learning game!"
HOMEPAGE="https://ohmygit.org/
	https://github.com/git-learning-game/oh-my-git"
PKG_URI="https://blinry.itch.io/oh-my-git"
SRC_URI="${MY_PN}-linux.zip"
S="${WORKDIR}"

LICENSE="BlueOak-1.0.0"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="fetch"

DEPEND="
	media-libs/alsa-lib
	media-libs/libglvnd
	media-libs/libpulse
	x11-libs/libX11
	x11-libs/libXcursor
	x11-libs/libXi
	x11-libs/libXinerama
	x11-libs/libXrandr
	x11-libs/libXrender
"
RDEPEND="${DEPEND}"
BDEPEND="app-arch/unzip"

pkg_nofetch() {
	elog "Please download ${A} from"
	elog "${PKG_URI}"
	elog "and place it in your DISTDIR directory."
}

src_install() {
	insinto ${MY_PATH}
	doins ${MY_PN}
	doins ${MY_PN}.pck
	dosym ../..${MY_PATH}/${MY_PN} /usr/bin/${MY_PN}
	fperms +x ${MY_PATH}/${MY_PN}
}
