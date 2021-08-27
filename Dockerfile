FROM tensorflow/tensorflow:latest-gpu-py3-jupyter

RUN apt-get update
RUN apt-get upgrade -y

#install apps
RUN apt-get update && apt-get install -y \
    openssh-server \
    nano \
    cron \
    sudo \
    rsync \
    curl \
    #install <project> specific
    && rm -rf /var/lib/apt/lists/*

# Setup root env
COPY deltas/etc/ /etc/
#COPY deltas/misc/crontab.root /var/spool/cron/crontabs/root

#create needed directory for ssh-server
RUN mkdir -p /var/run/sshd

# Requirement for graphics
RUN sed -i 's/#X11UseLocalhost yes/X11UseLocalhost no/g' /etc/ssh/sshd_config

# Create User env
COPY deltas/arc_user/ /home/arc_user/
RUN chown -R arc_user:arc_user /home/arc_user

# Create additional user
#RUN mkdir /home/someuser
#RUN mkdir /home/someuser/bin
#COPY deltas/someuser/ /home/someuser/
#RUN chown -R someuser:someuser /home/someuser
#RUN mkdir -p /data/logs
#RUN mkdir -p /data/backup


RUN pip3 install --upgrade pip
COPY src/requirements.txt /home/arc_user/scripts
COPY deltas/misc/lab /usr/local/bin
COPY deltas/misc/notebook /usr/local/bin
RUN pip3 install -r /home/arc_user/scripts/requirements.txt


#get that good good dark mode
RUN curl -sL https://deb.nodesource.com/setup_13.x | bash -
RUN apt-get install -y nodejs
RUN jupyter labextension install @telamonian/theme-darcula


#Run <project> specific commands
###


# Expose the SSH ports
EXPOSE 22

#for jupyter:
EXPOSE 8888

COPY deltas/init /root/init
CMD ["/root/init"]

