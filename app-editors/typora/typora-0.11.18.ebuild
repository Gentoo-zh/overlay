# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

DESCRIPTION="Typora will give you a seamless experience as both a reader and a writer"
HOMEPAGE="https://typora.io"
SRC_URI="https://web.archive.org/web/20211127121316if_/https://typora.io/linux/typora_${PV}_amd64.deb"

#TODO : update license
S="${WORKDIR}/usr"
LICENSE="typora"
SLOT="0"
KEYWORDS="-* ~amd64"

RESTRICT="mirror"

RDEPEND="x11-libs/libXScrnSaver"

QA_PREBUILT="*"

src_prepare() {
	rm -rf share/lintian || die
	sed -i '/Change Log/d' share/applications/typora.desktop || die
	default
}

src_install() {
	local dir="/opt/${PN}"

	insinto "${dir}"
	doins -r bin share

	fperms 0755 "${dir}/bin/typora"
	fperms 4755 "${dir}/share/typora/chrome-sandbox"
	dosym -r /opt/typora/bin/typora /usr/bin/typora

	domenu share/applications/typora.desktop
}
