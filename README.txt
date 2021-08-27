# README #
#here is a quick outline to try and give a rundown of how I set things up.

- <project>_build (parent dir of container build)
	- cleanup_container.sh
		- stops container processes
		- removes active container
		- removes container image
		- removes entry from known_hosts (for ease of re-deployment if using ssh)
		- must pass it an ssh port if not using default
	- deltas/
		- etc/ (premade in some container and copied them out to reuse)
			- passwd
			- shadow
			- group
			- (default user is arc_user, to change edit in group/passwd/dockerfile/ and rename the arc_user dir)
		- misc/
			- random crap I don't know where else to put (just reference in the Dockerfile)
		- arc_user/
			- user home directory for container env
			- keep scripts for cronjobs, etc.
		- init
			- this is the script that all of my containers call at initialization of the container
			- any services or processes you will want to run at bootup of the container every time is starts, put in here
			- this script is always PID 1**
	- Dockerfile
		- script to set up environment 
		- grab base image, first time updates/upgrades, setup home dirs, cronjobs, install apps, expose ports from continer to host, etc.
		- the CMD command in the Dockerfile is the process that you will call on init of the container (in my case, /root/init)
	- generate_container.sh
		- builds and runs container the first time
		- if you change your restart policy (always, unless-stopped, etc.) once the container is running it should be autonomous (default is always, dont change unless you know what you're doing)
		- modify the container name and include any ports you want the container to expose to the host (default is project name)
		- this is where you will mount volumes (i.e. share host directories with the container, be careful with this) (default is ./src for project code mounted to /opt in container)
		- in the build line, you'll see a --cache option. I find that this option is nice (albeit takes longer to deploy container) 
		  but I have ran into issues where something got fucked up and on each redeployement, the fucked-uppedness continued because 
		  whatever was screwey was maintained in cache.
		

** In containers, when PID 1 terminates, the entire container terminates. That is how the computer knows when to end the container session. You will see I end the script with /bin/bash and that is to keep it alive until I choose to kill it with the container daemon controls (e.g. Docker stop <container_name>)
