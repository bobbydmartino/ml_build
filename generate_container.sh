#!/bin/bash

CONTAINER=$( echo ${PWD##*/} )


#defaults
RUN_FLAG=false

NOCACHE_FLAG=true
POLICY_FLAG=true
SSHPORT_FLAG=true
VOLUME_FLAG=true

GLX_FLAG=false
NET_FLAG=false
NAME_FLAG=false

#default values
policy="always"
sshport="2201"
volume="$PWD/src"


#params passed in
arg_i=0
args=( "$@" )
for arg in "${args[@]}"; do
	case "$arg" in
		"--run")
			RUN_FLAG=true
			;;
		"--cache")
			NOCACHE_FLAG=false
			;;
		"--restart-policy")
			POLICY_FLAG=true
			policy=${args[`expr $arg_i + 1`]}
			;;
		"--ssh-port")
			SSHPORT_FLAG=true
			sshport=${args[`expr $arg_i + 1`]}
			;;
		 "--glx")
                        GLX_FLAG=true
                        ;;
		"--hostnet")
			NET_FLAG=true
			;;
		"--name")
			NAME_FLAG=true
			CONTAINER=${args[`expr $arg_i + 1`]}
			;;
		"--volume")
			VOLUME_FLAG=true
			volume=${args[`expr $arg_i + 1`]}
			;;
			*)
			;;
	esac
	arg_i=`expr $arg_i + 1`
done

build_options=""
run_options=""

if [[ $NOCACHE_FLAG == true ]]; then
	build_options="$build_options --no-cache"
fi

if [[ $POLICY_FLAG == true ]]; then
	run_options="$run_options --restart=$policy"
fi

if [[ $SSHPORT_FLAG == true ]]; then
	run_options="$run_options -p $sshport:22"
	run_options="$run_options -p 8888:8888"
fi

if [[ $VOLUME_FLAG == true ]]; then
	run_options="$run_options -v $volume:/opt"
fi

if [[ $GLX_FLAG == true ]]; then
        run_options="$run_options -v /tmp/.X11-unix:/tmp/.X11-unix"
        run_options="$run_options -e DISPLAY=unix$DISPLAY"
fi

if [[ $NET_FLAG == true ]]; then
	run_options="$run_options --privileged"
        run_options="$run_options --net=host"
fi

if [[ $RUN_FLAG == true ]]; then
	/usr/bin/docker build $build_options -t $CONTAINER .
	sleep 1
	/usr/bin/docker run -itd $run_options \
		--name=$CONTAINER \
		--hostname=$CONTAINER \
		$CONTAINER

else
	echo "USAGE: ./$(basename $0) [--run] [--no-cache] [--restart-policy <always | unless-stopped | never>] [--ssh-port <port>] [--volume <local_dir>] [--graphics] [--hostnet] [--name <name>]"
	echo ""
	echo "--run: generates container, else help screen. you can set it to true in the script to avoid having to type --run, but then you'll miss out on my insightful help text"
	echo ""
	echo "--cache: I find that having no-cache enabled is nice (albeit takes longer to deploy container) but I have ran into issues where something got fucked up and on each redeployement, the fucked-uppedness continued because whatever was screwey was maintained in cache."
	echo ""
	echo "--restart policy: if you change your restart policy (always, unless-stopped, etc.) once the container is running it should be autonomous (default is always, dont change unless you know what you're doing)"
	echo ""
	echo "--ssh-port: set the port, currently set to 2201 as a default, however only one container can have a single port, so change it when deploying multiple containers. Also if you select --hostnet this wont matter as I have not figured out how to ssh into containers that share the home network"
	echo ""
	echo "--volume: set the volume on the host machine to mount into /opt in the container, I guess you could manually go in and choose a different place to mount it, different strokes for different folks"
	echo ""
	echo "--glx: this mounts x11 stuff and transfers display, necessary in conjunction with hostnet and installing nvidia drivers to work glx"
	echo ""
	echo "--hostnet: this allows for glx and other graphical elements to use the host resources and properly display, you must first however type 'xhost local:root' into your host machine to open it up to docker containers"
	echo ""
	echo "--name: default is name of parent directory (project_build) however to deploy multiple of the same use this to differentiate them"
fi

