# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3

DESCRIPTION="Enables USB charging for Apple devices"
HOMEPAGE="https://github.com/mkorenkov/ipad_charge"
EGIT_REPO_URI="https://github.com/mkorenkov/ipad_charge.git"

LICENSE="GPL-2"
SLOT="0"

DEPEND="virtual/libusb:1"
RDEPEND="${DEPEND}"

# TODO: fixed prestripped
QA_PRESTRIPPED="/usr/bin/ipad_charge"

src_prepare(){
	default
	eapply -p0 "${FILESDIR}/${PN}-9999-makefile.patch"
}
