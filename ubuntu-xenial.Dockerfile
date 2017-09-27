# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This is a Dockerfile for creating a ubuntu image with init, systemd and a masterless salt-minion

# Make sure to specify the Ubuntu base image here and to set the version for the
# UBUNTU_VERSION variable below
FROM ubuntu:xenial
MAINTAINER alejdg

# Miscellaneous Settings
ENV UBUNTU_VERSION "xenial"
#ENV SALT_VERSION "2016.11.3"
ENV SALT_VERSION "2017.7.1"
ENV TERM="vt100" XDG_RUNTIME_DIR="/run/user/$(id -u)"

LABEL ubuntu_version=$UBUNTU_VERSION
LABEL salt_version=$SALT_VERSION
LABEL masterless="true"

ENV DEBIAN_FRONTEND noninteractive 

ADD files/resolv.conf /etc/resolv.conf

# Update package lists
RUN apt-get clean 
# RUN apt-get update
RUN apt-get update 

# Install a few packages to get started, but leave package installation up to salt in general
RUN apt-get install -y apt-utils vim bind9-host curl iputils-ping 

RUN mkdir -p /etc/salt/minion.d && \
    chmod -R 755 /etc/salt

ADD files/10-minion-overrides.conf /etc/salt/minion.d/

# No agetty
RUN rm -f /etc/init/tty*
RUN rm -f /etc/systemd/system/getty.target.wants/*
RUN rm -f /sbin/agetty

# Update the .bashrc so once attached, the salt-minion will start if it is not the case.
ADD files/bashrc_update.sh /root/
RUN chmod +x /root/bashrc_update.sh
RUN /root/bashrc_update.sh && rm -f /root/bashrc_update.sh

# Install salt from official repository
RUN apt-get install -y wget && wget -O - https://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest/SALTSTACK-GPG-KEY.pub | apt-key add -
RUN echo "deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest xenial main" >> /etc/apt/sources.list.d/saltstack.list
RUN apt-get update
RUN apt-get install -y salt-minion

CMD [ "/sbin/init" ]
