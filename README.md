# Network Tools for Containers

This container is contains some regular network tools on ubuntu.

Using for Container HOST network

## Linux

```bash
docker run -it --rm --network=host ahmetozer/cna
```

Using for inside the Container Network

```bash
container_name="teredo-container"   # This is your container to which is do you want to make a network inspect

docker run -it --rm --privileged --net container:teredo-container ahmetozer/cna
```

You can add bash function for more easy execution

```bash
# You can add to .bashrc
function cna {
container_name="$1"   # This is your container to which is do you want to make a network inspect
shift 1
if [ -z "$container_name" ] || [ "$container_name" == "host" ]
then
    docker run -it --rm --privileged --pid host --network host ahmetozer/cna $@
else
    docker run -it --rm --privileged --pid container:$container_name --net container:$container_name ahmetozer/cna $@
fi
}

_cna_completions() {
    nettools=("ping" "traceroute" "tcpdump" "route" "bwm-ng" "iptraf-ng" "iftop" "nethogs"
    "iperf3" "nmap" "nc" "curl" "wget" "ethtool" "socat" "ifconfig" "ip"
    "nslookup" "whois" "mtr" "arping" "brctl" "iptables" "ip6tables" "bash")
    if [ ${#COMP_WORDS[@]} -lt 3 ]; then
        local containers=($(docker ps -aq --no-trunc))
        local names=($(docker inspect --format '{{.Name}}' "${containers[@]}"))
        names=("${names[@]#/}")
        names+=('host')
        COMPREPLY=($(compgen -W "${names[*]}" "${COMP_WORDS[1]}"))
    elif [ ${#COMP_WORDS[@]} -eq 3 ]; then
        COMPREPLY=($(compgen -W "${nettools[*]}" "${COMP_WORDS[2]}"))
    fi
}

complete -F _cna_completions cna

```

```bash
#for run inside container
cna mycontainer
# run on host
cna

# run with command
cna mycontainer ifconfig
# run with command on host
cna host iptraf-ng
```

## Windows

You can use CNA in WSL2 backend docker
Add cna as DOSKEY on cmd.

```cmd
DOSKEY cna=docker run -it --rm --privileged -e WSL=yes --network host -v /proc/:/proc2/ -v /var/run/docker.sock:/var/run/docker.sock ahmetozer/cna /usr/bin/ENTRYPOINT.sh $*
```
