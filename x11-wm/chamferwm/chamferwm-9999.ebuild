# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="A tiling X11 window manager with Vulkan compositor"
HOMEPAGE="https://github.com/jaelpark/chamferwm"

EGIT_REPO_URI="https://github.com/jaelpark/chamferwm.git git://github.com/jaelpark/chamferwm.git"

inherit desktop git-r3 meson xdg

LICENSE="BSD"
SLOT="0"

DEPEND="
	dev-libs/boost[python]
	media-libs/shaderc
	dev-util/vulkan-headers
	media-libs/vulkan-loader
"

RDEPEND="
	media-libs/vulkan-loader
	dev-libs/boost[python]
"

src_prepare(){
	sed -i "s/python3')/python-3.7')/g" meson.build
}

src_install(){
	into /usr
	dobin "${BUILD_DIR}/chamfer"

	insinto /usr/share/chamfer/shaders

	doins "${BUILD_DIR}/default_fragment.spv"
	doins "${BUILD_DIR}/default_geometry.spv"
	doins "${BUILD_DIR}/default_vertex.spv"
	doins "${BUILD_DIR}/frame_fragment.spv"
	doins "${BUILD_DIR}/frame_geometry.spv"
	doins "${BUILD_DIR}/frame_vertex.spv"

	domenu "${S}/share/chamfer.desktop"
}
