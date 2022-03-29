FROM ubuntu as base

WORKDIR /root
RUN apt update &&\
DEBIAN_FRONTEND=noninteractive; apt upgrade -y ; apt install --no-install-recommends -y \
net-tools tcpdump iproute2 iptraf-ng iperf3 nmap \
netcat curl iputils-ping  socat netbase libcap2-bin \
dnsutils whois traceroute ethtool bridge-utils iptables ca-certificates  && \
find /var/lib/apt/lists/ -maxdepth 1 -type f -print0 | xargs -0 rm

COPY --from=ghcr.io/ahmetozer/distroless-helper /bin/distroless-helper /bin/distroless-helper

RUN distroless-helper $(which ping) /opt
RUN distroless-helper $(which traceroute) /opt
RUN distroless-helper $(which tcpdump) /opt
RUN distroless-helper $(which ip) /opt

RUN distroless-helper $(which iperf3) /opt
RUN distroless-helper $(which nmap) /opt
RUN distroless-helper $(which netcat) /opt

RUN distroless-helper $(which curl) /opt
RUN distroless-helper $(which ethtool) /opt
RUN distroless-helper $(which socat) /opt
RUN distroless-helper $(which brctl) /opt

RUN distroless-helper $(which iptables) /opt
RUN distroless-helper $(which ip6tables) /opt

RUN distroless-helper $(which bash) /opt
RUN distroless-helper $(which nslookup) /opt
RUN distroless-helper $(which dig) /opt
RUN distroless-helper $(which whois) /opt
RUN distroless-helper $(whereis libnss_dns.so.2 | cut -d' ' -f2) /opt


COPY ENTRYPOINT.sh /opt/usr/bin/ENTRYPOINT.sh

RUN set +x && cp -a --parents /usr/share/nmap /opt && \
cp -a --parents /etc/resolv.conf /opt && \
cp -a --parents /var/run/ /opt && \
cp -a --parents /var/lock/ /opt && \
mkdir -p /opt/var/lib/ && chmod -R 755 /opt/var/lib/ && \
cp -a --parents /usr/share/iptables /opt && \
ln -s $(which bash) /opt/bin/sh && \
cp -a --parents  /etc/ca-certificates /opt && \
cp -a --parents /etc/ssl/ /opt && \
cp -a --parents /etc/services /opt/ && \
chmod +x /opt/usr/bin/ENTRYPOINT.sh

RUN printf set cap && \
setcap CAP_NET_BIND_SERVICE,CAP_NET_RAW,CAP_NET_ADMIN+eip /opt$(which ping) && \
setcap CAP_NET_BIND_SERVICE,CAP_NET_RAW,CAP_NET_ADMIN+eip /opt$(which traceroute) && \
setcap CAP_NET_BIND_SERVICE,CAP_NET_RAW,CAP_NET_ADMIN+eip /opt$(which tcpdump) && \
setcap CAP_NET_BIND_SERVICE,CAP_NET_RAW,CAP_NET_ADMIN+eip /opt$(which ip) && \
setcap CAP_NET_BIND_SERVICE,CAP_NET_RAW,CAP_NET_ADMIN+eip /opt$(which iperf3) && \
setcap CAP_NET_BIND_SERVICE,CAP_NET_RAW,CAP_NET_ADMIN+eip /opt$(which nmap) && \
setcap CAP_NET_BIND_SERVICE,CAP_NET_RAW,CAP_NET_ADMIN+eip /opt$(which netcat) && \
setcap CAP_NET_BIND_SERVICE,CAP_NET_RAW,CAP_NET_ADMIN+eip /opt$(which curl) && \
setcap CAP_NET_BIND_SERVICE,CAP_NET_RAW,CAP_NET_ADMIN+eip /opt$(which ethtool) && \
setcap CAP_NET_BIND_SERVICE,CAP_NET_RAW,CAP_NET_ADMIN+eip /opt$(which socat) && \
setcap CAP_NET_BIND_SERVICE,CAP_NET_RAW,CAP_NET_ADMIN+eip /opt$(which brctl) && \
setcap CAP_NET_BIND_SERVICE,CAP_NET_RAW,CAP_NET_ADMIN+eip /opt$(which iptables) && \
setcap CAP_NET_BIND_SERVICE,CAP_NET_RAW,CAP_NET_ADMIN+eip /opt$(which ip6tables) && \
echo ok


FROM scratch
COPY --from=base /opt /
LABEL org.opencontainers.image.source="https://github.com/ahmetozer/cna"
USER 65534
CMD [ "/usr/bin/ENTRYPOINT.sh" ]