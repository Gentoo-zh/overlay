# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit linux-info desktop

NAME="${PN}_dwarfs.sh"
DESCRIPTION="DwarFS image of Arch Linux with: Lutris, Steam, Bottles, Wine..."
HOMEPAGE="https://github.com/Kron4ek/Conty"
SRC_URI="https://github.com/Kron4ek/Conty/releases/download/${PV}/${NAME} -> $P"
S="${WORKDIR}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="strip"

RDEPEND="
	|| (
		sys-fs/fuse:3
		sys-fs/fuse:0
	)
"

QA_PREBUILT="*"

CONFIG_CHECK="
	~IA32_EMULATION
	~USER_NS
	~PROC_SYSCTL
"
WARNING_IA32_EMULATION="CONFIG_IA32_EMULATION is needed to run 32-bit x86 binaries on amd64 - for Wine"
WARNING_USER_NS="CONFIG_USER_NS is needed for unprivileged user namespaces, which Conty uses for its sandbox."
WARNING_PROC_SYSCTL="CONFIG_PROC_SYSCTL is needed for /proc/sys support inside the container."

src_install() {
	newbin "${DISTDIR}/${P}" $PN

	domenu "${FILESDIR}/${PN}-lutris.desktop"
	domenu "${FILESDIR}/${PN}-steam.desktop"
	domenu "${FILESDIR}/${PN}-bottles.desktop"
	domenu "${FILESDIR}/${PN}-genymotion.desktop"
	domenu "${FILESDIR}/${PN}-nautilus.desktop"
}
pkg_postinst() {
	einfo "How to use: $ ${NAME} [command] [command_arguments]"
	einfo "For example: ${NAME} steam"
	einfo "or"
	einfo "WINEPREFIX=$HOME/wine-conty ${NAME} gamescope -f -- wine ./game.exe"
	einfo "but for simplicity use lutris here - you will get GUI for Wine options"
	einfo "also --help is available"
}
