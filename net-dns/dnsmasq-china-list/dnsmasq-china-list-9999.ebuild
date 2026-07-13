# Copyright 2022-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="Chinese-specific configuration to improve your favorite DNS server"
HOMEPAGE="https://github.com/felixonmars/dnsmasq-china-list"

EGIT_REPO_URI="https://github.com/felixonmars/dnsmasq-china-list.git"
EGIT_MIN_CLONE_TYPE=shallow

LICENSE="WTFPL-2"
SLOT="0"
IUSE="+dnsmasq smartdns dnscrypt-proxy"

RDEPEND="
	${DEPEND}
	dnsmasq? ( net-dns/dnsmasq )
	smartdns? ( net-dns/smartdns )
	dnscrypt-proxy? ( net-dns/dnscrypt-proxy )
"

src_compile() {
	if use smartdns; then
		make smartdns SERVER=china
		rm bogus-nxdomain.china.smartdns.conf
	fi
	if use dnscrypt-proxy; then
		# dnscrypt-proxy won't cache the forwarded domain
		# recommend to use systemd-resolved extra stub listener
		# for caching china domains
		make SERVER="127.0.0.1:5335" dnscrypt-proxy
	fi
}

src_install() {
	if use dnsmasq; then
		insinto /etc/dnsmasq.d/
		dobin dnsmasq-update-china-list
		doins *.china.conf
	fi
	if use smartdns; then
		insinto /etc/smartdns/
		doins *.china.smartdns.conf
	fi
	if use dnscrypt-proxy; then
		insinto /etc/dnscrypt-proxy/
		newins dnscrypt-proxy-forwarding-rules.txt forwarding-rules.txt
	fi
}

pkg_postinst() {
	ewarn "If you want systemd-resolved to act as a cache for dnscrypt-proxy domestic domains"
	ewarn "edit /etc/systemd/resolved.conf.d/dnscrypt-proxy.conf:"
	ewarn "[Resolve]"
	ewarn "DNS="
	ewarn "DNSStubListener=no"
	ewarn "DNSStubListenerExtra=udp:127.0.0.1:5335"
}
