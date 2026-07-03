# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

DESCRIPTION="Wemeet - Tencent Video Conferencing"
HOMEPAGE="https://meeting.tencent.com/"

SRC_URI="
	amd64? ( https://updatecdn.meeting.qq.com/cos/\
72e0e0023e1d1e6d4123fba28821aea1/TencentMeeting_0300000000_${PV}_x86_64_default.publish.officialwebsite.deb
		-> ${P}_amd64.deb )
	arm64? ( https://updatecdn.meeting.qq.com/cos/\
c06d6bc4a3370dbfb2f43bbc6ff8969e/TencentMeeting_0300000000_${PV}_arm64_default.publish.officialwebsite.deb
		-> ${P}_arm64.deb )
	loong? ( https://updatecdn.meeting.qq.com/cos/\
399aded330e344aa1327064170be86e8/TencentMeeting_0300000000_${PV}_loongarch64_default.publish.officialwebsite.deb
		-> ${P}_loongarch64.deb )
"

S="${WORKDIR}"
LICENSE="wemeet_license"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="bindist test mirror"

# ~loong TODO:
#
# * qtwebengine sandbox crashes on statx (may have to somehow port qtwebengine:5)
# * provide libcurl-gnutls.so.4 compat symlink

RDEPEND="
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	dev-libs/wayland
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype
	media-libs/harfbuzz
	media-libs/libglvnd
	media-libs/libpulse
	sys-apps/dbus
	virtual/zlib
	virtual/udev
	x11-libs/libdrm
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXinerama
	x11-libs/libxkbcommon
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXtst
	x11-libs/xcb-util-image
	x11-libs/xcb-util-keysyms
	x11-libs/xcb-util-renderutil
	x11-libs/xcb-util-wm
	loong? (
		net-misc/curl[gnutls]
		virtual/loong-ow-compat
	)
"
BDEPEND="dev-util/patchelf"

QA_PREBUILT="opt/${PN}/*"

src_prepare() {
	local f

	einfo "Unbundling libraries"
	pushd opt/${PN}/lib > /dev/null
	for f in lib*; do
		case "${f#lib}" in
		desktop*|crash_guard*|ImSDK*|nxui*|qt*|service_manager*|tms*|ui*|wemeet*|xcast*|xnn*|yuv*|TencentSM*)
			# keep components of $PN itself
			continue
			;;
		icu*|jpeg.so.8*)
			# * the bundled icu ABI is too old (soname is 60) for us to source
			#   from system
			# * jpeg-compat is not packaged in ::gentoo (it is in ::steam-overlay
			#   but we shouldn't force users to pull in other overlays anyway)
			continue
			;;
		Qt5*)
			# we have to keep the entirety of Qt, because of an alarming error
			# seen with libQt5Widgets.so.5 unbundled:
			#
			# /opt/wemeet/bin/wemeetapp: symbol lookup error:
			# /opt/wemeet/lib/libwemeet_framework.so: undefined symbol:
			# _ZN7QWidget11eventFilterEP7QObjectP6QEvent, version Qt_5
			#
			# which means the Qt ABI is different in the Tencent build env than
			# ours, and that it is unsafe for us to swap the libraries.
			continue
			;;
		esac
		einfo "  $f"
		rm "$f" || die
	done
	popd > /dev/null

	einfo "Unbundling plugins to fix libqxcb-glx-integration SIGSEGV"
	rm -r opt/wemeet/plugins/xcbglintegrations || die

	default
}

src_install() {
	# Fix RPATHs to ensure the libraries can be found
	for f in $(find "opt/${PN}/bin" "opt/${PN}/plugins") ; do
		[[ -f ${f} && $(od -t x1 -N 4 "${f}") == *"7f 45 4c 46"* ]] || continue
		patchelf --set-rpath "/opt/${PN}/lib" ${f} || die "patchelf failed on ${f}"
	done
	for f in $(find "opt/${PN}/lib") ; do
		[[ -f ${f} && $(od -t x1 -N 4 "${f}") == *"7f 45 4c 46"* ]] || continue
		patchelf --set-rpath '$ORIGIN' ${f} || die "patchelf failed on ${f}"
	done

	insinto "/opt/${PN}"
	exeinto "/opt/${PN}"
	doins -r opt/"${PN}"/*

	newexe "${FILESDIR}/wemeetapp-xwayland.sh" wemeetapp.sh

	fperms +x "/opt/${PN}/bin/wemeetapp"
	fperms +x "/opt/${PN}/bin/QtWebEngineProcess"

	# put launcher into PATH
	dosym "../../opt/${PN}/wemeetapp.sh" /usr/bin/wemeetapp

	sed -i "s/^Icon=.*/Icon=wemeetapp/g" "usr/share/applications/wemeetapp.desktop" || die
	sed -i "s/^Exec=.*/Exec=wemeetapp %u/g" "usr/share/applications/wemeetapp.desktop" || die
	sed -i -e '$a Comment=Tencent Meeting Linux Client\n\' \
		-e 'Comment[zh_CN]=腾讯会议Linux客户端\n\' \
		-e 'Keywords=wemeet;tencent;meeting;\n' \
		"usr/share/applications/wemeetapp.desktop" || die
	domenu "usr/share/applications/wemeetapp.desktop"
	newicon -s scalable "opt/${PN}/wemeet.svg" "wemeetapp.svg"
	for i in 16 32 64 128 256; do
		png_file="opt/${PN}/icons/hicolor/${i}x${i}/mimetypes/wemeetapp.png"
		if [ -e "${png_file}" ]; then
			newicon -s "${i}" -c mimetypes "${png_file}" "wemeetapp.png"
		fi
	done
}
