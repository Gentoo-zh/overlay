EAPI=8
inherit desktop

DESCRIPTION="A violent, sexy, multiplayer first person shooter based on the ioquake3 engine"
HOMEPAGE="https://openarena.ws https://en.wikipedia.org/wiki/OpenArena"

SRC_URI="
	https://downloads.sourceforge.net/oarena/openarena-${PV}.zip
	https://upload.wikimedia.org/wikipedia/commons/2/2c/Openarena.png
	https://upload.wikimedia.org/wikipedia/commons/7/7b/Openarena-server.png
"

S="${WORKDIR}/openarena-${PV}"

LICENSE="GPL-3"

SLOT="0"

KEYWORDS="~amd64 ~x86"

BDEPEND="app-arch/unzip"

DEPEND="
	${COMMON_DEPENDS}
	media-libs/libvorbis
	net-misc/curl
	media-libs/openal
	media-libs/libxmp
	media-libs/libsdl
"

QA_FLAGS_IGNORED="
	/opt/openarena/oa_ded.i386
	/opt/openarena/oa_ded.x86_64
	/opt/openarena/openarena.i386
	/opt/openarena/openarena.x86_64
"

RESTRICT="strip"

src_prepare() {
	eapply_user

	rm *.dll *.exe
	rm -rf __MACOSX *.app
}

src_install() {
	insinto /opt/openarena/
	doins -r "${S}"/*

	fperms +x /opt/openarena/openarena.x86_64 /opt/openarena/openarena.i386

	doins "${FILESDIR}/openarena-runner.sh"
	fperms +x /opt/openarena/openarena-runner.sh

	insinto /usr/share/pixmaps/
	domenu "${FILESDIR}/openarena.desktop"
	domenu "${FILESDIR}/openarena-server.desktop"
	doicon "${DISTDIR}/Openarena.png"
	doicon "${DISTDIR}/Openarena-server.png"

	dosym ../../opt/openarena/openarena-runner.sh /usr/bin/openarena
	dosym ../../opt/openarena/openarena-runner.sh /usr/bin/openarena-server
}
