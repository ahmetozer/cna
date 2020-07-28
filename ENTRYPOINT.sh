#!/bin/bash

if [ -f "/var/run/netns/container" ]
then
    exec_command="ip netns exec container"
else
    exec_command="exec"
fi

$exec_command bash