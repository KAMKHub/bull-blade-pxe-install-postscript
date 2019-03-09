#!/bin/sh

#########################################################
## Purkkaviritelmä joka asentaa NVIDIAn vehkeet kuntoon #
#########################################################

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
