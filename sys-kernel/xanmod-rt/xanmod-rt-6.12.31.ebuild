# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

KERNEL_IUSE_GENERIC_UKI=1
KERNEL_IUSE_MODULES_SIGN=1

inherit kernel-build toolchain-funcs

DESCRIPTION="XanMod RT sources w/ genpatches and CJKTTY options"
HOMEPAGE="https://xanmod.org
		https://github.com/zhmars/cjktty-patches
		https://github.com/bigshans/cjktty-patches"

MY_P=linux-${PV%.*}
#Note: to bump xanmod, check GENPATCHES_P in sys-kernel/gentoo-kernel
# e.g. gentoo-kernel-6.12.32.ebuild is + 5
GENPATCHES_P=genpatches-${PV%.*}-$(( ${PV##*.} + 6 ))
XANMOD_VERSION="1"
RT_PATCHSET=""
XANMOD_RT_URI="https://downloads.sourceforge.net/project/xanmod/releases/rt"
XANMOD_OKV="${PV}-rt${RT_PATCHSET}-xanmod${XANMOD_VERSION}"
CJKTTY_URI="https://raw.githubusercontent.com/bigshans/cjktty-patches/master/v6.x/"
# https://koji.fedoraproject.org/koji/packageinfo?packageID=8
# forked to https://github.com/projg2/fedora-kernel-config-for-gentoo
GENTOO_CONFIG_VER=g16
CONFIG_VER=6.12.12-200.fc41
SRC_URI="
	https://cdn.kernel.org/pub/linux/kernel/v$(ver_cut 1).x/${MY_P}.tar.xz
	https://dev.gentoo.org/~mpagano/dist/genpatches/${GENPATCHES_P}.base.tar.xz
	https://dev.gentoo.org/~mpagano/dist/genpatches/${GENPATCHES_P}.extras.tar.xz
	${XANMOD_RT_URI}/${XANMOD_OKV}/patch-${XANMOD_OKV}.xz
	${CJKTTY_URI}/cjktty-6.9.patch
	experimental? (
		https://dev.gentoo.org/~mpagano/dist/genpatches/${GENPATCHES_P}.experimental.tar.xz
	)
	amd64? (
		https://github.com/projg2/gentoo-kernel-config/archive/${GENTOO_CONFIG_VER}.tar.gz
			-> gentoo-kernel-config-${GENTOO_CONFIG_VER}.tar.gz
	)
	https://raw.githubusercontent.com/projg2/fedora-kernel-config-for-gentoo/${CONFIG_VER}/kernel-x86_64-fedora.config
		-> kernel-x86_64-fedora.config.${CONFIG_VER}
"

S=${WORKDIR}/${MY_P}
LICENSE+=" CDDL"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+cjk debug experimental hardened"

BDEPEND="
	debug? ( dev-util/pahole )
"
PDEPEND="
	>=virtual/dist-kernel-${PV}"

QA_FLAGS_IGNORED="
	usr/src/linux-.*/scripts/gcc-plugins/.*.so
	usr/src/linux-.*/vmlinux
"

src_prepare() {
	# Remove linux-stable patches (see 0000_README)
	find "${WORKDIR}" -maxdepth 1 -name "1[0-4][0-9][0-9]*.patch" -exec rm {} + || die

	local PATCHES=(
	    # xanmod patches
	    "${WORKDIR}"/patch-${PV}-rt-xanmod${XANMOD_VERSION}
	    # genpatches
	    "${WORKDIR}"/*.patch
	)
	default

	# prepare the default config
	case ${ARCH} in
	amd64)
		cp "${DISTDIR}/kernel-x86_64-fedora.config.${CONFIG_VER}" .config || die
	    #XANMOD_VERSION="${XANMOD_VERSION}-x64v3"
	    ;;
	*)
	    die "Unsupported arch ${ARCH}"
	    ;;
	esac

	rm "${S}"/localversion* || die
	local myversion="-rt${RT_PATCHSET}-xanmod${XANMOD_VERSION}-dist"
	use hardened && myversion+="-hardened"
	echo "CONFIG_LOCALVERSION=\"${myversion}\"" > "${T}"/version.config || die
	local dist_conf_path="${WORKDIR}/gentoo-kernel-config-${GENTOO_CONFIG_VER}"

	echo "CONFIG_MODPROBE_PATH=\"/sbin/modprobe\"" >"${T}"/modprobe.config || die

	local merge_configs=(
		"${T}"/version.config
		"${T}"/modprobe.config
		"${dist_conf_path}"/base.config
		"${dist_conf_path}"/6.12+.config
	)
	use debug || merge_configs+=(
		"${dist_conf_path}"/no-debug.config
	)
	if use hardened; then
		merge_configs+=( "${dist_conf_path}"/hardened-base.config )

		tc-is-gcc && merge_configs+=( "${dist_conf_path}"/hardened-gcc-plugins.config )

		if [[ -f "${dist_conf_path}/hardened-${ARCH}.config" ]]; then
			merge_configs+=( "${dist_conf_path}/hardened-${ARCH}.config" )
		fi
	fi

	use secureboot && merge_configs+=( "${dist_conf_path}/secureboot.config" )

	kernel-build_merge_configs "${merge_configs[@]}"
}
