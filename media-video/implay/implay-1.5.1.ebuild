# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CMAKE_MAKEFILE_GENERATOR="emake"
inherit cmake desktop xdg-utils

DESCRIPTION="A Cross-Platform Desktop Media Player"
HOMEPAGE="https://tsl0922.github.io/ImPlay/"
SRC_URI="https://github.com/tsl0922/ImPlay/archive/refs/tags/${PV}.tar.gz ->  ImPlay-continuous.tar.gz"
S="${WORKDIR}/ImPlay-${PV}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	media-libs/freetype:2
	media-libs/glfw
	media-video/mpv
	x11-libs/gtk+
"
src_configure() {
	CMAKE_BUILD_TYPE="Release"
	cmake_src_configure
}

src_install() {
	insinto "/usr/lib64"
	doins "${BUILD_DIR}"/third_party/nativefiledialog/src/libnfd.so.1.1.0
	dosym ../../../../../../../../usr/lib64/libnfd.so.1.1.0 /usr/lib64/libnfd.so.1
	cmake_src_install
	dosym ../../../../../../../../usr/bin/ImPlay /usr/bin/implay
	make_desktop_entry ${PN} "A Cross-Platform Desktop Media Player"
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}
