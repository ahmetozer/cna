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
