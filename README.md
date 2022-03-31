# Network Tools for Containers

Distroless and rootless network tools in a container.

## Linux

Using for container host network

```bash
docker run -it --rm --network=host --cap-add=CAP_NET_BIND_SERVICE --cap-add=CAP_NET_RAW --cap-add=CAP_NET_ADMIN ghcr.io/ahmetozer/cna:latest
```

Using for inside the Container Network

```bash
docker run -it --rm --privileged --net container:teredo-container ghcr.io/ahmetozer/cna:latest
```

You can add bash function for more easy execution

```bash
# You can add to .bashrc
function cna {
    container_name="$1"   # This is your container to which is do you want to make a network inspect
    shift 1
    if [ -z "$container_name" ] || [ "$container_name" == "host" ]
    then
        docker run -it --rm --cap-add=CAP_NET_BIND_SERVICE --cap-add=CAP_NET_RAW --cap-add=CAP_NET_ADMIN --pid host --network host ghcr.io/ahmetozer/cna:latest $@
    else
        docker run -it --rm --cap-add=CAP_NET_BIND_SERVICE --cap-add=CAP_NET_RAW --cap-add=CAP_NET_ADMIN --pid container:$container_name --net container:$container_name ghcr.io/ahmetozer/cna:latest $@
    fi
}

_cna_completions() {
    nettools=("ping" "traceroute" "tcpdump"
    "iperf3" "nmap" "netcat" "curl" "ethtool" "socat" "ip"
    "nslookup" "whois" "bash")
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
cna mycontainer ip a
# run with command on host
cna host tcpdump -n
```

## Windows

You can use CNA in WSL2 backend docker
Add cna as DOSKEY on cmd.

```cmd
DOSKEY cna=docker run -it --rm --privileged -e WSL=yes --network host -v /proc/:/proc2/ -v /var/run/docker.sock:/var/run/docker.sock ghcr.io/ahmetozer/cna:latest /usr/bin/ENTRYPOINT.sh $*
```
