# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop pax-utils xdg

DESCRIPTION="A complete, free Microsoft Office-compatible alternative office suite"
HOMEPAGE="https://www.freeoffice.com"
BASE_URI="https://www.softmaker.net/down/softmaker-freeoffice-2021-${PV}"
SRC_URI="${BASE_URI}-amd64.tgz"

S="${WORKDIR}"

LICENSE="SoftMaker"
SLOT="0"
KEYWORDS="~amd64"
LANGUAGES="ar bg da de el en-GB en-US es et fi fr hu id it ja kk ko lt lv nl pl pt pt-BR ro ru sl sv tr uk zh"
for lang in ${LANGUAGES}; do
	IUSE+="l10n_${lang%:*} "
done

RESTRICT="mirror strip"

DEPEND="
	app-admin/chrpath
	app-arch/xz-utils"
RDEPEND="
	${DEPEND}
	media-libs/mesa
	net-misc/curl
	x11-libs/libXrandr
	dev-util/desktop-file-utils
	dev-util/gtk-update-icon-cache
	media-libs/libglvnd
	x11-misc/xdg-utils"

QA_PRESTRIPPED="*"
QA_PREBUILT="*"
QA_FLAGS_IGNORED="*"

font_clean(){
	for lang in ${LANGUAGES}; do
		use l10n_${lang%:*} && continue
		declare suf
		case ${lang%:*} in
			zh-CN)
				suf="sc";;
			ko)
				suf="kr";;
			ja)
				suf="jp";;
		esac
		rm fonts/NotoSansCJK${suf}-Regular.otf
	done
}

free_clean(){
	for lang in ${LANGUAGES}; do
		use l10n_${lang%:*} && continue
		declare fix
		case ${lang%:*} in
			de)
				fix="de";;
		esac
		rm *free_${fix}.pdf
	done
}

lang_clean(){
for lang in ${LANGUAGES}; do
		use l10n_${lang%:*} && continue
		declare suffix
		case ${lang%:*} in
			da)
				suffix="dk";;
			el)
				suffix="gr";;
			en-US)
				suffix="us";;
			en-GB)
				suffix="uk";;
			et)
				suffix="ee";;
			ja)
				suffix="jp";;
			kk)
				suffix="kz";;
			ko)
				suffix="kr";;
			pt-BR)
				suffix="pb";;
			sl)
				suffix="si";;
			sv)
				suffix="se";;
			uk)
				suffix="ua";;
			*)
				suffix="${lang%:*}";;
		esac
		rm *_${suffix}.dwr
	done

}

doc_clean(){
for lang in ${LANGUAGES}; do
		use l10n_${lang%:*} && continue
		declare doc
		case ${lang%:*} in
			da)
				doc="dk";;
			el)
				doc="gr";;
			en-US)
				doc="us";;
			en-GB)
				doc="uk";;
			et)
				doc="ee";;
			ja)
				doc="jp";;
			kk)
				doc="kz";;
			ko)
				doc="kr";;
			pt-BR)
				doc="pb";;
			sl)
				doc="si";;
			sv)
				doc="se";;
			uk)
				doc="ua";;
			*)
				doc="${lang%:*}";;
		esac
		rm inst/*_${doc}.zip
	done

}

src_unpack() {
	:
}

src_install(){
	mkdir -p "${ED}/usr/lib64/${PN}"
	cd "${ED}/usr/lib64/${PN}"

	unpack ${A}
	xz -d "freeoffice2021.tar.lzma" || die
	tar x -f "freeoffice2021.tar" \
		&& rm "freeoffice2021.tar" || die
	rm "installfreeoffice"

	chrpath --delete "textmaker"
	chrpath --delete "planmaker"
	chrpath --delete "presentations"

	font_clean
	lang_clean
	free_clean
	doc_clean

	for m in "${FILESDIR}"/*.desktop; do
		domenu "${m}"
	done

	for size in 16 24 32 48 64 128 256 512; do
		newicon -s ${size} icons/pml_${size}.png ${PN}-planmaker.png
		newicon -s ${size} icons/prl_${size}.png ${PN}-presentations.png
		newicon -s ${size} icons/tml_${size}.png ${PN}-textmaker.png
	done

	insinto /usr/share/mime/packages
	doins mime/softmaker-freeoffice21.xml

	pax-mark -m "${ED}"/usr/lib64/${PN}/planmaker
	pax-mark -m "${ED}"/usr/lib64/${PN}/presentations
	pax-mark -m "${ED}"/usr/lib64/${PN}/textmaker
}

pkg_postinst(){
	einfo
	elog "In order to use Softmaker Freeoffice, you need a serial number."
	elog "To obtain a valid free serial number, please visit"
	elog "https://www.freeoffice.com/en/download"
	einfo
	xdg_pkg_postinst
}
