#!/bin/bash

# Colors
cl_red='\e[31m'
cl_nc='\e[39m'
cl_cy='\e[36m'
cl_wh='\e[97m'
cl_lm='\e[95m'
cl_lg='\e[92m'

if [ "$WSL" == "yes" ]; then
    container_name=${container_name-$1}
    shift 1
fi
source /root/.cna_env
if [ ! -z "$container_name" ]; then
    [[ "$debug" == "yes" ]] && echo -e "\t${cl_wh}Container name detected: ${cl_cy}$container_name${cl_nc}"
    if [ -d "/proc2/" ]; then
        [[ "$debug" == "yes" ]] && echo -e "\t${cl_wh}Second Proc area found.${cl_nc}"
        if [ -S "/var/run/docker.sock" ]; then
            [[ "$debug" == "yes" ]] && echo -e "\t${cl_wh}Docker socket found.${cl_nc}"
            container_stat=$(curl --unix-socket /var/run/docker.sock http/containers/$container_name/json -s -o /dev/null -w '%{http_code}\n')
            case $container_stat in
            "000")
                echo -e "\t${cl_red}Err while connecting docker socket."
                echo -e "\tAre you mount right docker socket ?${cl_nc}"
                err_on_exit="yes"
                ;;

            "404")
                echo -e "\t${cl_red}Container ${cl_cy}$container_name${cl_nc} is not found.${cl_nc}"
                err_on_exit="yes"
                ;;

            "200")
                [[ "$debug" == "yes" ]] && echo -e "\t${cl_wh}Container ${cl_cy}$container_name${cl_nc}${cl_wh} is found and running.${cl_nc}"
                if [ $(curl --unix-socket /var/run/docker.sock http/containers/$container_name/json -s | awk -v RS=',' -F: '{ if ( $1 == "\"Running\"") {print $2}}') == "true" ]; then
                    container_pid=$(curl --unix-socket /var/run/docker.sock http/containers/$container_name/json -s | awk -v RS=',' -F: '{ if ( $1 == "\"Pid\"") {print $2}}')
                    container_hostname=$(curl --unix-socket /var/run/docker.sock http/containers/cnat/json -s | awk -v RS=',' -F: '{ if ( $2 == "{\"Hostname\"") {print $3}}')
                    container_hostname="${container_hostname//\"/}"
                    if [ "$container_name" == "$container_hostname" ]; then
                        container_name_hostname=$container_hostname
                    else
                        container_name_hostname="$container_name ($container_hostname)"
                    fi
                    echo -e "\t${cl_wh}Container ${cl_cy}$container_name_hostname${cl_nc}${cl_wh} is found and running.${cl_nc}"
                    rm /var/run/netns/container 2>/dev/null
                    mkdir -p /var/run/netns/
                    ln -s /proc2/$container_pid/ns/net /var/run/netns/container
                    if [ "$?" == "0" ]; then
                        [[ "$debug" == "yes" ]] && echo -e "\t${cl_wh}Link is created for ${cl_cy}$container_hostname${cl_nc}"
                    else
                        echo -e "${cl_red}Link is not created. Did you run this container with privileged ?${cl_nc}"
                        err_on_exit="yes"
                    fi
                    hostname $container_hostname
                else
                    echo -e "${cl_red}Your container is not running."
                    echo -e "Exiting in 10 seconds.${cl_nc}"
                    sleep 10
                    exit 0
                fi
                ;;

            *)
                echo -e "\t${cl_red}Unknow response: ${cl_cy}$container_stat${cl_nc}"
                err_on_exit="yes"
                ;;
            esac
        else
            echo -e "${cl_red}You are mounted Proc folder but you are not mount docker sock."
            echo -e "You can make a mount with ${cl_lm}-v /var/run/docker.sock:/var/run/docker.sock${cl_nc}"
            err_on_exit="yes"
        fi
    else
        echo -e "${cl_red}Second proc folder is not found."
        echo -e "Please mount second proc with docker with ${cl_lm}-v /proc/:/proc2${cl_nc}"
        err_on_exit="yes"
    fi
fi

if [ "$err_on_exit" == "yes" ];
then
    exit 1
fi

if [ -f "/var/run/netns/container" ]; then
    exec_command="ip netns exec container"
else
    exec_command="exec"
fi

if [ -z "$1" ]; then
    $exec_command bash
else
    command=$1
    shift
    $exec_command $command $@
fi
