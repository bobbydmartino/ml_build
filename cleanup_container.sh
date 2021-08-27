#!/bin/bash



CONTAINER=$(echo ${PWD##*/})

PORT="2201"

#set port if specified (different from default)
if [[ "$1" != "" ]]; then 
        PORT=$1 
fi

/usr/bin/docker stop $CONTAINER
/usr/bin/docker rm $CONTAINER
/usr/bin/docker rmi $CONTAINER:latest
ssh-keygen -R [localhost]:$PORT
