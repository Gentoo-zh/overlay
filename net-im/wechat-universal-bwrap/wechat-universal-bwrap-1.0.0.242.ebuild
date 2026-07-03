# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RPM_COMPRESS_TYPE="none"

inherit desktop toolchain-funcs rpm xdg

DESCRIPTION="WeChat (Universal) from UOS, inside bwrap sandbox"
HOMEPAGE="https://weixin.qq.com https://github.com/7Ji-PKGBUILDs/wechat-universal-bwrap"

RPM_URI="https://mirrors.opencloudos.tech/opencloudos/9.2/extras"
AUR_REPO_REF="5e8ad25218b82b9bbacb0bd43dce2feb85998889"
SRC_URI="
	amd64? ( ${RPM_URI}/x86_64/os/Packages/wechat-beta_${PV}_amd64.rpm )
	arm64? ( ${RPM_URI}/aarch64/os/Packages/wechat-beta_${PV}_arm64.rpm )
	https://github.com/7Ji-PKGBUILDs/wechat-universal-bwrap/archive/${AUR_REPO_REF}.tar.gz
		-> wechat-universal-bwrap-${AUR_REPO_REF}.tar.gz
"

S="${WORKDIR}"
LICENSE="all-rights-reserved GPL-2"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="bindist strip mirror"

# the sonames are gathered with the following trick
#
# objdump -p /path/weixin | grep NEEDED | awk '{print $2}' | xargs equery b | sort | uniq
BLOB_RDEPEND="
	app-accessibility/at-spi2-core:2
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	dev-libs/openssl-compat:1.1.1
	dev-libs/wayland
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype
	media-libs/libglvnd
	media-libs/libpulse
	media-libs/mesa
	media-libs/tiff-compat:4
	sys-apps/dbus
	virtual/jack
	virtual/zlib
	x11-libs/cairo
	x11-libs/libdrm
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/pango
	x11-libs/xcb-util-image
	x11-libs/xcb-util-keysyms
	x11-libs/xcb-util-renderutil
	x11-libs/xcb-util-wm
"

RDEPEND="
	${BLOB_RDEPEND}
	sys-apps/bubblewrap
	sys-apps/lsb-release
	x11-misc/flatpak-xdg-utils
	x11-misc/xdg-user-dirs
	loong? ( virtual/loong-ow-compat )
"
BDEPEND="
	${BDEPEND}
	dev-util/patchelf
"

QA_PREBUILT="*"

src_prepare() {
	pushd "${S}/wechat-universal-bwrap-${AUR_REPO_REF}" > /dev/null
	eapply "${FILESDIR}/adjust-launcher-fs-layout-1.patch"
	popd > /dev/null

	default
}

call_cc() {
	local cc="$(tc-getCC)"
	echo "$cc" "$@"
	"$cc" "$@" || die
}

call_patchelf() {
	echo patchelf "$@"
	patchelf "$@" || die
}

src_compile() {
	einfo "Fixing blob RUNPATHs"
	pushd "${S}/opt/wechat-beta" > /dev/null
	# originally $ORIGIN:$ORIGIN
	call_patchelf --set-rpath '$ORIGIN' RadiumWMPF/runtime/WeChatAppEx
	# originally $ORIGIN:/home/ubuntu/.wconan2/ilink/5ae3ed15_1692179323/libs/Release/
	# clang-llvm-12.0.0/libs:
	call_patchelf --remove-rpath RadiumWMPF/runtime/libilink2.so
	# originally /home/ubuntu/.wconan2/ilink_network/cfed668b_1692178974/ilink-network/libs/Release/
	# clang-llvm-12.0.0/libs:
	call_patchelf --remove-rpath RadiumWMPF/runtime/libilink_network.so
	# originally ./ (!!!)
	call_patchelf --remove-rpath libvoipChannel.so
	call_patchelf --remove-rpath libvoipCodec.so
	call_patchelf --remove-needed libbz2.so.1.0 wechat
	call_patchelf --add-needed libbz2.so.1 wechat
	popd > /dev/null

	einfo "Building stub libuosdevicea.so"
	pushd "${S}/wechat-universal-bwrap-${AUR_REPO_REF}" > /dev/null
	call_cc -fPIC -shared ${CFLAGS} ${LDFLAGS} -o libuosdevicea.so libuosdevicea.c || die
	popd > /dev/null
}

src_install() {
	LIB_DIR=/usr/lib/wechat-universal
	pushd "${S}/wechat-universal-bwrap-${AUR_REPO_REF}" > /dev/null
	domenu wechat-universal.desktop
	exeinto /usr/lib/wechat-universal
	newexe wechat-universal.sh start.sh
	newexe wechat-universal.sh stop.sh

	exeinto ${LIB_DIR}/usr/bin
	newexe fake_dde-file-manager dde-file-manager

	insinto /opt/wechat-universal
	doins libuosdevicea.so
	insinto ${LIB_DIR}/usr/lib/license
	doins libuosdevicea.so
	popd > /dev/null

	# needed on the host side for bwrap to be able to do the bind-mount
	keepdir /usr/lib/license

	insinto ${LIB_DIR}/etc
	newins "${FILESDIR}/stub-uos-release" lsb-release

	insinto /opt/wechat-universal
	doins -r "${S}/opt/wechat-beta/"*
	fperms 0755 /opt/wechat-universal/{crashpad_handler,wechat}
	fperms 0755 /opt/wechat-universal/RadiumWMPF/runtime/WeChatAppEx{,_crashpad_handler}

	newicon "${S}/opt/wechat-beta/icons/wechat.png" wechat-universal.png
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "This WeChat will run in a sys-apps/bubblewrap sandbox, and will only"
	elog "be able to access \$XDG_DOCUMENTS_DIR/WeChat_Data by default."
	elog
	elog "You can bind additional directories into the sandbox by creating a"
	elog "~/.config/wechat-universal/binds.list file, with every line an"
	elog "absolute or relative-to-HOME path."
}

pkg_postrm() {
	xdg_pkg_postrm
}
