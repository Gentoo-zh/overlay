# Copyright 2023-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg

DESCRIPTION="Trae IDE (binary package)"
HOMEPAGE="https://www.trae.cn/"

SRC_URI="
	amd64? (
		https://lf-cdn.trae.com.cn/obj/trae-com-cn/pkg/app/releases/stable/${PV}/linux/Trae_CN-linux-x64.deb
			-> ${P}.deb
	)
"

S="${WORKDIR}"

LICENSE="LCEDA-EULA"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
DEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-crypt/libsecret
	dev-libs/expat
	dev-libs/glib
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa
	net-print/cups
	sys-apps/dbus
	sys-apps/util-linux
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3[X]
	x11-libs/libdrm
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libxkbcommon
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXScrnSaver
	x11-libs/libxshmfence
	x11-libs/libXtst
	x11-libs/pango
	"
RDEPEND="${DEPEND}"
BDEPEND="app-arch/unzip"

RESTRICT="mirror"

QA_PREBUILT="
	/usr/share/trae-cn/chrome-sandbox
	/usr/share/trae-cn/chrome_crashpad_handler
	/usr/share/trae-cn/libEGL.so
	/usr/share/trae-cn/libffmpeg.so
	/usr/share/trae-cn/trae-cn
	/usr/share/trae-cn/libvk_swiftshader.so
	/usr/share/trae-cn/libGLESv2.so
	/usr/share/trae-cn/libvulkan.so.1
	/usr/share/trae-cn/resources/app/extensions/byted-icube.integrations-extended/dist/skia.linux-x64-musl.node
	/usr/share/trae-cn/resources/app/extensions/microsoft-authentication/dist/libmsalruntime.so
	/usr/share/trae-cn/resources/app/node_modules/@aha-kit/ipc-linux-x64/dist/zeromq/prebuild/linux/x64/node/musl-127-Release/addon.node
"

src_unpack(){
	export LANG=C.UTF-8
	unpack ${A}
}

src_install(){
	tar -xvf data.tar.xz -C "${D}"
	fperms 0755 /usr/share/trae-cn/trae-cn
	fperms 0755 /usr/share/trae-cn/chrome_crashpad_handler
}
