# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="1"
K_SECURITY_UNSUPPORTED="1"
K_NOSETEXTRAVERSION="1"
ETYPE="sources"
RDEPEND="
	!sys-kernel/xanmod-sources
	!sys-kernel/xanmod-kernel
"
inherit kernel-2
detect_version

DESCRIPTION="XanMod RT sources and CJKTTY options"
HOMEPAGE="https://xanmod.org
		https://github.com/zhmars/cjktty-patches"
XANMOD_VERSION="1"
RT_VERSION="14"
XANMOD_RT_URI="https://github.com/xanmod/linux/releases/download/"
OKV="${OKV}-rt${RT_VERSION}-xanmod${XANMOD_VERSION}"
CJKTTY_URI="https://raw.githubusercontent.com/zhmars/cjktty-patches/master/v6.x/"
SRC_URI="
	${KERNEL_BASE_URI}/linux-${KV_MAJOR}.${KV_MINOR}.tar.xz
	${GENPATCHES_URI}
	${XANMOD_RT_URI}/${OKV}/patch-${OKV}.xz
	${CJKTTY_URI}/cjktty-${KV_MAJOR}.${KV_MINOR}.patch
"
LICENSE+=" CDDL"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+cjk"

src_unpack() {
	UNIPATCH_LIST_DEFAULT="${DISTDIR}/patch-${OKV}.xz"
	UNIPATCH_LIST=""

	if use cjk; then
		UNIPATCH_LIST+=" ${DISTDIR}/cjktty-${KV_MAJOR}.${KV_MINOR}.patch"
	fi

	kernel-2_src_unpack
}

pkg_setup() {
	ewarn ""
	ewarn "${PN} is *not* supported by the Gentoo Kernel Project in any way."
	ewarn "If you need support, please contact the ${HOMEPAGE} directly."
	ewarn "Do *not* open bugs in Gentoo's bugzilla unless you have issues with"
	ewarn "the ebuilds. Thank you."
	ewarn ""

	kernel-2_pkg_setup
}

pkg_postinst() {
	elog "MICROCODES"
	elog "Use xanmod-sources with microcodes"
	elog "Read https://wiki.gentoo.org/wiki/Intel_microcode"

	postinst_sources
}
