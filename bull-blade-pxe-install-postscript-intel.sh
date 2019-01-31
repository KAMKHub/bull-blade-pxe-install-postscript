#!/bin/bash -       
#title:        bull-blade-pxe-install-postscript-intel.sh
#description:  This script is run after the PXE-install of KAMK Bull
#              Intel GPU blades
#ogranization: Kajaani University of Applied Sciences (KAMK)
#project:      Bull Supercomputer - bullx DLC blade system - B700 Series
#author:       Jukka Jurvansuu <jukka.jurv@nsuu.fi>
#created:      2019-01-31
#modified:     2019-01-31
#version:      1.0
#usage:        bash bull-blade-pxe-install-postscript-intel.sh
#OS:           CentOS 7
#==============================================================================

#==============================================================================
# Install tools, useful utilities and settings
#==============================================================================

# Clear the yum Caches
yum clean all

# Set time zone and NTP
## Check settings: timedatectl
yum -y install ntp
chkconfig ntpd on
service ntpd start
timedatectl set-timezone Europe/Helsinki
sed -i 's/SYNC_HWCLOCK=no/SYNC_HWCLOCK=yes/g' /etc/sysconfig/ntpdate /etc/sysconfig/ntpdate

yum install -y epel-release
yum install -y nano
yum install -y telnet

# Disable SELinux
sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config

# Disable Firewall
systemctl stop firewalld
systemctl disable firewalld

# Enable root-login
sed -i -r 's/.?PermitRootLogin.+/PermitRootLogin yes/' /etc/ssh/sshd_config

#==============================================================================
# Install Python
#==============================================================================

yum install -y python
yum install -y python-pip
pip install --upgrade pip
pip install ipython

#==============================================================================
# Docker installation
#==============================================================================

# Install required packages for Docker
yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2

# Set up the stable repository
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

# Install the latest version of Docker CE
yum install docker-ce  -y

# Enable Docker
systemctl enable docker

# Start Docker
systemctl start docker

# Install Docker Compose
pip install docker-compose
