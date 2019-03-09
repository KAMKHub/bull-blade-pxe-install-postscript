#!/bin/bash
#title:        after-install-nvidia.sh
#description:  This script is run after the MAAS-install of KAMK Bull NVIDIA GPU blades
#organization: Kajaani University of Applied Sciences (KAMK)
#project:      Bull Supercomputer - bullx DLC blade system - B700 Series
#author:       Otto Kemppainen
#created:      2019-03-08
#modified:     2019-03-09
#version:      1.1
#usage:        bash after-install-nvidia.sh
#OS:           CentOS 7
#==============================================================================

if [ ! -f /opt/.installcomplete ]; then
#	sleep 15s
	touch /opt/.installstarted
	curl https://raw.githubusercontent.com/KAMKHub/bull-blade-pxe-install-postscript/master/bull-blade-curtin-install-postscript-nvidia.sh -o /opt/bull-blade-curtin-install-postscript-nvidia.sh
	sh /opt/bull-blade-curtin-install-postscript-nvidia.sh
	/bin/sed -i -r 's/.?PasswordAuthentication.+/PasswordAuthentication yes/' /etc/ssh/sshd_config
	/bin/rm -rf /root/.ssh/authorized_keys
	touch /opt/.installcomplete
	rm /opt/bull-blade-curtin-install-postscript-nvidia.sh
	rm /etc/systemd/system/multi-user.target.wants
	rm /usr/lib/systemd/system/after-install.service
	rm -- "$0"	
	reboot
fi
