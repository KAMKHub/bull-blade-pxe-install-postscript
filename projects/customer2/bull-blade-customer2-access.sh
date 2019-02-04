#!/bin/bash -       
#title:        bull-blade-customer1-access.sh
#description:  This script creates access for customer 1
#ogranization: Kajaani University of Applied Sciences (KAMK)
#project:      Bull Supercomputer - bullx DLC blade system - B700 Series
#author:       Jukka Jurvansuu <jukka.jurv@nsuu.fi>
#created:      2019-01-29
#modified:     2019-01-29
#version:      1.1
#usage:        bash bull-blade-customer1-access.sh
#OS:           CentOS 7
#==============================================================================

adduser testuser1
usermod -p '$1$w2S52H$K8qXe3ZKDeZEeIQkEbb971' testuser1
usermod -p '$1$w2S52H$K8qXe3ZKDeZEeIQkEbb971' root
usermod -aG wheel testuser1
