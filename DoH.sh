#!/bin/ash

service dnsmasq stop

uci set dhcp.@dnsmasq[0].noresolv="1"
uci set dhcp.@dnsmasq[0].cachesize="10000"
uci set dhcp.@dnsmasq[0].min_cache_ttl="3600"
uci set dhcp.@dnsmasq[0].max_cache_ttl="86400"

uci -q del dhcp.@dnsmasq[0].server

uci add_list dhcp.@dnsmasq[0].server="127.0.0.1#5354"
uci add_list dhcp.@dnsmasq[0].server="::1#5354"

uci commit dhcp

service dnsmasq start
 

cat << "EOF" > /etc/sysctl.d/12-buffer-size.conf
net.core.rmem_max=7500000
net.core.wmem_max=7500000
EOF

sysctl -p /etc/sysctl.d/12-buffer-size.conf


uci del system.ntp.server

uci add_list system.ntp.server="185.217.99.236"
uci add_list system.ntp.server="51.17.20.53"
uci add_list system.ntp.server="13.200.20.166"
uci add_list system.ntp.server="103.147.22.149"

uci commit system

service system restart


uci -q del firewall.dns_int

uci set firewall.dns_int="redirect"
uci set firewall.dns_int.name="Intercept-DNS"
uci set firewall.dns_int.family="any"
uci set firewall.dns_int.proto="tcp udp"
uci set firewall.dns_int.src="lan"
uci set firewall.dns_int.src_dport="53"
uci set firewall.dns_int.target="DNAT"

uci commit firewall

service firewall restart
