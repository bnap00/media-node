FROM ubuntu:14.04

MAINTAINER Harshad Yeola harshadyeola92@gmail.com

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update

RUN apt-get install -y wget curl git-core \
 && git clone git://github.com/bnap00/media-node.git /root/media-node 

COPY ./ubuntu.sh /ubuntu.sh
RUN apt-get update && apt-get install sudo \
 && /bin/bash /ubuntu.sh

WORKDIR /root/media-node

RUN sed -i "s/listen_ip = transcoder_ip/listen_ip = '0.0.0.0'/g" /root/media-node/ffmpeg_server.js

RUN apt-get install -y wget curl sudo gcc g++ \
 && curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash - \
 && sudo apt-get -y install nodejs build-essential \
 && npm install -g npm@latest \
 && npm install -g node-gyp \
 && npm install
 
VOLUME /root/media-node/queued /root/media-node/temp /root/media-node/completed /root/media-node/log

RUN touch /root/media-node/log/ffmpeg_server.log

EXPOSE 1203

ENTRYPOINT ["/usr/bin/node", "ffmpeg_server.js"]
