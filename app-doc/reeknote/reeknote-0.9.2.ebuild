# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.87.0"

inherit cargo optfeature

DESCRIPTION="Command-line Evernote client, with ability to play audio and see images"
HOMEPAGE="https://github.com/vitaly-zdanevich/reeknote"
SRC_URI="
	https://github.com/vitaly-zdanevich/reeknote/archive/refs/tags/${PV}.tar.gz
		-> ${P}.tar.gz
	https://github.com/vitaly-zdanevich/reeknote/releases/download/${PV}/vendor.tar.gz
		-> ${P}-vendor.tar.gz
"

LICENSE="GPL-3"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 BSD CDLA-Permissive-2.0 ISC MIT Unicode-3.0
"
SLOT="0"
KEYWORDS="~amd64"

DOCS=( README.md )

# rust does not use *FLAGS from make.conf, silence portage warning
QA_FLAGS_IGNORED="usr/bin/reeknote usr/bin/rnsync"

ECARGO_VENDOR="${WORKDIR}/vendor"

src_prepare() {
	rm -r "${WORKDIR}/.cargo" || die
	default
}

src_install() {
	cargo_src_install
	einstalldocs
}

pkg_postinst() {
	optfeature "audio attachment playback" media-video/mpv
	optfeature "inline image display in Kitty-compatible terminals" x11-terms/kitty
}
