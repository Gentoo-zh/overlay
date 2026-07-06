# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop udev xdg

ZIP_NAME="DaVinci_Resolve_${PV}_Linux"
RUN_NAME="${ZIP_NAME}.run"

DESCRIPTION="Professional video editing, color, effects and audio post-processing"
HOMEPAGE="https://www.blackmagicdesign.com/support/family/davinci-resolve-and-fusion"
SRC_URI="${ZIP_NAME}.zip"
S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"

IUSE="video_cards_nvidia video_cards_amdgpu video_cards_intel"
RESTRICT="fetch strip mirror"

BDEPEND="
	app-arch/unzip
	sys-fs/fuse:0
	dev-util/patchelf
"

RDEPEND="
	dev-cpp/tbb
	dev-lang/luajit
	dev-libs/apr-util
	dev-libs/glib:2
	dev-libs/xmlsec
	dev-python/numpy
	media-libs/glu
	media-libs/gst-plugins-bad:1.0
	llvm-runtimes/libcxx
	llvm-runtimes/libcxxabi
	llvm-runtimes/openmp
	sys-libs/libxcrypt
	virtual/jre:*
	virtual/opencl
	video_cards_nvidia? ( x11-drivers/nvidia-drivers )
	video_cards_amdgpu? ( dev-libs/rocm-opencl-runtime )
	video_cards_intel? ( dev-libs/intel-compute-runtime )
	x11-libs/gdk-pixbuf:2
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXinerama
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXt
	x11-libs/libXtst
	x11-libs/libXxf86vm
	x11-libs/xcb-util
	x11-libs/xcb-util-image
	x11-libs/xcb-util-keysyms
	x11-libs/xcb-util-renderutil
	x11-libs/xcb-util-wm
"
DEPEND="${RDEPEND}"

pkg_nofetch() {
	einfo
	einfo "  DaVinci Resolve cannot be downloaded automatically."
	einfo "  Please download ${ZIP_NAME}.zip manually from:"
	einfo
	einfo "    https://www.blackmagicdesign.com/support/family/davinci-resolve-and-fusion"
	einfo
	einfo "  Then place it in your DISTDIR directory:"
	einfo
	einfo "  After that, re-run the emerge command."
	einfo
}

src_unpack() {
	unpack "${ZIP_NAME}.zip" || die

	chmod u+x "${RUN_NAME}" || die
	"${S}/${RUN_NAME}" --appimage-extract || die
}

src_prepare() {
	default

	local squashfs="squashfs-root"

	chmod -R u+rwX,go+rX,go-w "${squashfs}" || die

	pushd "${squashfs}/share/panels" > /dev/null || die
	tar -zxf dvpanel-framework-linux-x86_64.tgz || die
	chmod -R u+rwX,go+rX,go-w "lib" || die
	mv -t "${S}/${squashfs}/libs/" *.so || die
	cp -a lib/* "${S}/${squashfs}/libs/" || die
	popd > /dev/null || die

	rm -rf "${squashfs}"/{installer*,AppRun*,CentOSUpdate} || die
	rm -rf "${squashfs}/Onboarding" || die
	rm -f "${squashfs}"/LUT/Gen{Lut,OutputLut} || die
	rm -f "${squashfs}/bin/sqlite3" || die

	while IFS= read -r -d '' _dir; do
		chmod 0755 "${_dir}" || die
	done < <(find "${squashfs}" -type d -print0)

	while IFS= read -r -d '' _f; do
		[[ -f "${_f}" && "$(od -t x1 -N 4 "${_f}")" == *"7f 45 4c 46"* ]] || continue
		chmod 0755 "${_f}" || die
	done < <(find "${squashfs}" -type f -print0)

	local _install_dir="/opt/${PN}"

	local _patchelf_paths=(
		"libs"
		"libs/plugins/sqldrivers"
		"libs/plugins/xcbglintegrations"
		"libs/plugins/imageformats"
		"libs/plugins/platforms"
		"libs/Fusion"
		"plugins"
		"bin"
		"BlackmagicRAWSpeedTest/BlackmagicRawAPI"
		"BlackmagicRAWSpeedTest/plugins/platforms"
		"BlackmagicRAWSpeedTest/plugins/imageformats"
		"BlackmagicRAWSpeedTest/plugins/mediaservice"
		"BlackmagicRAWSpeedTest/plugins/audio"
		"BlackmagicRAWSpeedTest/plugins/xcbglintegrations"
		"BlackmagicRAWSpeedTest/plugins/bearer"
		"BlackmagicRAWPlayer/BlackmagicRawAPI"
		"BlackmagicRAWPlayer/plugins/mediaservice"
		"BlackmagicRAWPlayer/plugins/imageformats"
		"BlackmagicRAWPlayer/plugins/audio"
		"BlackmagicRAWPlayer/plugins/platforms"
		"BlackmagicRAWPlayer/plugins/xcbglintegrations"
		"BlackmagicRAWPlayer/plugins/bearer"
		"DaVinci Control Panels Setup/plugins/platforms"
		"DaVinci Control Panels Setup/plugins/imageformats"
		"DaVinci Control Panels Setup/plugins/bearer"
		"DaVinci Control Panels Setup/AdminUtility/PlugIns/DaVinciKeyboards"
		"DaVinci Control Panels Setup/AdminUtility/PlugIns/DaVinciPanels"
	)

	local _i
	for _i in "${!_patchelf_paths[@]}"; do
		_patchelf_paths[_i]="${_install_dir}/${_patchelf_paths[_i]}"
	done

	local _new_rpath
	printf -v _new_rpath '%s:' "${_patchelf_paths[@]}"
	_new_rpath+="\$ORIGIN"

	while IFS= read -r -d '' _f; do
		[[ -f "${_f}" && "$(od -t x1 -N 4 "${_f}")" == *"7f 45 4c 46"* ]] || continue
		patchelf --set-rpath "${_new_rpath}" "${_f}" || die "patchelf failed on ${_f}"
	done < <(find "${squashfs}" -type f -size -32M -print0)

	local _syslib="${EPREFIX}/usr/$(get_libdir)"

	rm -f "${squashfs}/libs"/libglib-2.0.so.0{,.6800.4} || die
	rm -f "${squashfs}/libs"/libgio-2.0.so.0{,.6800.4} || die
	rm -f "${squashfs}/libs"/libgmodule-2.0.so.0{,.6800.4} || die
	rm -f "${squashfs}/libs"/libgobject-2.0.so.0{,.6800.4} || die

	rm -f "${squashfs}/libs"/libc++.so{,.1,.1.0} || die
	rm -f "${squashfs}/libs"/libc++abi.so{,.1,.1.0} || die

	ln -s "${_syslib}/libglib-2.0.so.0" "${squashfs}/libs/libglib-2.0.so.0" || die
	ln -s "${_syslib}/libgio-2.0.so.0" "${squashfs}/libs/libgio-2.0.so.0" || die
	ln -s "${_syslib}/libgmodule-2.0.so.0" "${squashfs}/libs/libgmodule-2.0.so.0" || die
	ln -s "${_syslib}/libgobject-2.0.so.0" "${squashfs}/libs/libgobject-2.0.so.0" || die
	ln -s "${_syslib}/libgdk_pixbuf-2.0.so.0" "${squashfs}/libs/libgdk_pixbuf-2.0.so.0" || die
	ln -s "${_syslib}/libc++.so.1" "${squashfs}/libs/libc++.so.1" || die
	ln -s "${_syslib}/libc++abi.so.1" "${squashfs}/libs/libc++abi.so.1" || die
	ln -s "${_syslib}/libomp.so" "${squashfs}/libs/libiomp5.so.5" || die

	ln -s "../BlackmagicRAWPlayer/BlackmagicRawAPI" "${squashfs}/bin/BlackmagicRawAPI" || die

	while IFS= read -r -d '' _f; do
		sed -i "s|RESOLVE_INSTALL_LOCATION|/opt/${PN}|g" "${_f}" || die
	done < <(find . -type f \( -name "*.desktop" -o -name "*.directory" -o -name "*.menu" \) -print0)

	echo "StartupWMClass=resolve" >> "${squashfs}/share/DaVinciResolve.desktop" || die

	mkdir -p "${squashfs}/share/etc/udev/rules.d" || die

	sed -i 's#Categories=Video#Categories=AudioVideo#' \
		"${squashfs}/share/blackmagicraw-player.desktop" "${squashfs}/share/blackmagicraw-speedtest.desktop" || die

	sed -i 's#Exec=.*#Exec=davinci-control-panels-setup#' \
		"${squashfs}/share/DaVinciControlPanelsSetup.desktop" || die
	sed -i 's#Icon=.*#Icon=davinci-resolve#' \
		"${squashfs}/share/DaVinciResolve.desktop" || die
	sed -i 's#Icon=.*#Icon=davinci-resolve-panels-setup#' \
		"${squashfs}/share/DaVinciControlPanelsSetup.desktop" || die
	sed -i 's#Icon=.*#Icon=blackmagicraw-player#' \
		"${squashfs}/share/blackmagicraw-player.desktop" || die
	sed -i 's#Icon=.*#Icon=blackmagicraw-speedtest#' \
		"${squashfs}/share/blackmagicraw-speedtest.desktop" || die
}

src_install() {
	local install_dir="/opt/${PN}"
	local app_dir="${ED}/${install_dir}"

	dodir "${install_dir}"
	cp -a squashfs-root/. "${app_dir}/" || die

	local _runtime_dirs=(
		"Apple Immersive/Calibration"
		.crashreport
		.license
		.LUT
		configs
		DolbyVision
		GPUCache
		logs
	)
	local _d
	for _d in "${_runtime_dirs[@]}"; do
		keepdir "${install_dir}/${_d}"
	done

	cp "${app_dir}/share/"{default-config.dat,log-conf.xml} "${app_dir}/configs/" || die
	cp "${app_dir}/share/default_cm_config.bin" "${app_dir}/DolbyVision/" || die

	dosym "${install_dir}/bin/resolve" "/usr/bin/${PN}"

	domenu "${app_dir}/share/"*.desktop

	insinto /usr/share/desktop-directories
	doins "${app_dir}/share/DaVinciResolve.directory"

	insinto /etc/xdg/menus
	doins "${app_dir}/share/DaVinciResolve.menu"

	local _iconsrc="${app_dir}/graphics"

	insinto /usr/share/icons/hicolor/64x64/apps
	newins "${_iconsrc}/DV_Resolve.png" davinci-resolve.png
	newins "${_iconsrc}/DV_ResolveProj.png" davinci-resolve-project.png

	insinto /usr/share/icons/hicolor/128x128/apps
	newins "${_iconsrc}/DV_Resolve.png" davinci-resolve.png
	newins "${_iconsrc}/DV_Panels.png" davinci-resolve-panels-setup.png

	insinto /usr/share/icons/hicolor/256x256/apps
	newins "${_iconsrc}/blackmagicraw-player_256x256_apps.png" blackmagicraw-player.png
	newins "${_iconsrc}/blackmagicraw-speedtest_256x256_apps.png" blackmagicraw-speedtest.png

	insinto /usr/share/mime/packages
	doins "${app_dir}/share/resolve.xml"

	insinto /lib/udev/rules.d
	doins "${app_dir}/share/etc/udev/rules.d/"*.rules

	dodir "/usr/share/licenses/${PN}"
	dosym "${install_dir}/docs/License.html" "/usr/share/licenses/${PN}/License.html"
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update
	xdg_mimeinfo_database_update
	udev_reload
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
	xdg_mimeinfo_database_update
	udev_reload
}
