# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

DESCRIPTION="A cross-platform, complete password management solution"
HOMEPAGE="https://www.enpass.io"
SRC_URI="https://apt.enpass.io/pool/main/e/${PN}/${PN}_${PV}_amd64.deb"

S="${WORKDIR}"

LICENSE="SINEW-EULA"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="bindist mirror strip"

# Dependencies
#
# objdump -p ./Enpass | grep NEEDED | awk '{print $2}' | xargs equery b | sort | uniq

DEPEND="elibc_glibc? ( sys-libs/glibc:2.2 )"
RDEPEND="
	app-arch/xz-utils
	dev-libs/glib:2
	media-libs/fontconfig
	media-libs/freetype:2
	media-libs/libglvnd
	media-libs/libpulse
	net-print/cups
	sys-apps/dbus
	sys-apps/util-linux
	virtual/zlib
	x11-libs/gtk+:3
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXScrnSaver
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/pango
	x11-libs/xcb-util-image
	x11-libs/xcb-util-keysyms
	x11-libs/xcb-util-renderutil
	x11-libs/xcb-util-wm"

QA_PREBUILT="opt/enpass/*"

src_prepare() {
	default
	gzip -d "${S}"/usr/share/doc/enpass/changelog.gz || die
}

src_install() {
	domenu "${S}"/usr/share/applications/enpass.desktop
	dodoc "${S}"/usr/share/doc/enpass/changelog

	insinto /opt/enpass
	doins -r "${S}"/opt/enpass/.
	fperms +x /opt/enpass/{Enpass,importer_enpass,wifisyncserver_bin}

	insinto /usr/share/mime/packages
	doins "${S}"/usr/share/mime/packages/application-enpass.xml

	local size
	for size in 16 22 24 32 48; do
		doicon -c status -s ${size} "${S}"/usr/share/icons/hicolor/${size}x${size}/status/enpass-status.png
		doicon -c status -s ${size} "${S}"/usr/share/icons/hicolor/${size}x${size}/status/enpass-status-dark.png
	done

	for size in 16 24 32 48 64 96 128 256; do
		doicon -s ${size} "${S}"/usr/share/icons/hicolor/${size}x${size}/apps/enpass.png
	done
}
