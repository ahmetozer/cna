FROM ubuntu


WORKDIR /root
RUN apt update &&\
DEBIAN_FRONTEND=noninteractive; apt upgrade -y ; apt install --no-install-recommends -y \
net-tools tcpdump iproute2 bwm-ng iptraf-ng iftop nethogs iperf3 nmap \
netcat curl wget iputils-ping ethtool socat \
dnsutils whois mtr-tiny traceroute arping ethtool pppoe bridge-utils iptables ca-certificates nano && \
find /var/lib/apt/lists/ -maxdepth 1 -type f -print0 | xargs -0 rm

COPY ENTRYPOINT.sh /usr/bin/ENTRYPOINT.sh
LABEL org.opencontainers.image.source="https://github.com/ahmetozer/cna"
RUN chmod +x /usr/bin/ENTRYPOINT.sh && echo "build_date=\"$(date +"%d/%m/%Y %X")"\" > /root/.cna_env

CMD [ "/usr/bin/ENTRYPOINT.sh" ]