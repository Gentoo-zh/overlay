# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker

DESCRIPTION="at32 workbench is a GUI tool for AT32 MCU startup code generation"
HOMEPAGE="https://www.arterytek.com/cn/support/tools.jsp"
SRC_URI="https://www.arterytek.com/download/AT32%20Workbench/AT32_Work_Bench_Linux-x86_64_V${PV}.zip"
S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="mirror strip"

BDEPEND="app-arch/unzip"

QA_PREBUILT="
	/opt/AT32_Work_Bench/AT32_Work_Bench
	/opt/AT32_Work_Bench/lib*.so*
	/opt/AT32_Work_Bench/platforms/libqxcb.so
"

src_unpack() {
	unpack "${A}"
	unpack "${WORKDIR}/AT32_Work_Bench_Linux-x86_64_V${PV}.deb"
}

src_install() {
	tar -xf "${WORKDIR}/data.tar.xz" -C "${D}" || die

	dodir /opt
	mv "${D}/usr/local/AT32_Work_Bench" "${D}/opt/" || die
	dodoc "${D}"/usr/local/Documents/*.pdf || die
	rm -r "${D}/usr/local" || die

	sed -i \
		-e "/^Encoding=/d" \
		-e "s|^Name=AT32_Work_Bench[[:space:]]*$|Name=AT32_Work_Bench|" \
		-e "s|/usr/local/AT32_Work_Bench|/opt/AT32_Work_Bench|" \
		-e "s|Categories=Application;Development;|Categories=Development;|" \
		"${D}/usr/share/applications/AT32_Work_Bench.desktop" || die

	find "${D}" ! -type l -perm -0002 -exec chmod go-w {} + || die
}
