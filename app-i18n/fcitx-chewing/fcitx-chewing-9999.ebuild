# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="fcitx5-chewing"

inherit cmake git-r3 xdg

DESCRIPTION="Chewing Wrapper for Fcitx"
HOMEPAGE="https://github.com/fcitx/fcitx5-chewing"
EGIT_REPO_URI="https://github.com/fcitx/fcitx5-chewing.git"

LICENSE="LGPL-2.1+"
SLOT="5"
KEYWORDS=""
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="
	!app-i18n/fcitx-chewing:4
	>=app-i18n/fcitx-5.1.13:5
	>=app-i18n/libchewing-0.5.0
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_configure() {
	local mycmakeargs=(
		-DENABLE_TEST=$(usex test)
	)

	cmake_src_configure
}
