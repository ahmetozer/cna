FROM ubuntu

COPY ENTRYPOINT.sh /usr/bin/ENTRYPOINT.sh
WORKDIR /root
RUN apt update &&\
apt install --no-install-recommends -y \
net-tools tcpdump iproute2 bwm-ng iptraf-ng iftop nethogs iperf3 nmap \
netcat curl wget && \
find /var/lib/apt/lists/ -maxdepth 1 -type f -print0 | xargs -0 rm

CMD [ "/usr/bin/ENTRYPOINT.sh" ]