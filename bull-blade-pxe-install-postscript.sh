#!/bin/bash -       
#title:        bull-blade-pxe-install-postscript.sh
#description:  This script is run after the PXE-install of KAMK Bull blades
#ogranization: Kajaani University of Applied Sciences (KAMK)
#project:      Bull Supercomputer - bullx DLC blade system - B700 Series
#author:       Jukka Jurvansuu <jukka.jurv@nsuu.fi>
#created:      2019-01-24
#modified:     2019-01-28
#version:      1.3
#usage:        bash bull-blade-pxe-install-postscript.sh
#OS:           CentOS 7
#==============================================================================

#==============================================================================
# Install tools and useful utilities
#==============================================================================

yum install -y epel-release
yum install -y nano
yum install -y telnet
# yum update -y

# Disable SELinux
sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config

# Disable Firewall
systemctl stop firewalld
systemctl disable firewalld
