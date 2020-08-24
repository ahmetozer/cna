# Network Tools for Containers

This container is contains some regular network tools on ubuntu.

Using for Container HOST network

```bash
docker run -it --rm --network=host ahmetozer/cna
```

Using for inside the Container Network

```bash
container_name="teredo-container"   # This is your container to which is do you want to make a network inspect

docker run -it --rm --privileged -v /proc/$(docker inspect -f '{{.State.Pid}}' $container_name)/ns/net:/var/run/netns/container ahmetozer/cna
```
