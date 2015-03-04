#!/bin/ash

# nrpe_address_wan.sh - cronjob (and on startup in rc.local) to make NRPE listen to the currently used WAN address

WAN_INTERFACE="eth0.2"
NRPE_CONFIG_FILE=/etc/nrpe.cfg
CURRENT_NRPE_ADDRESS=$(grep "server_address" $NRPE_CONFIG_FILE | cut -d= -f2)
CURRENT_WAN_ADDRESS=$(ifconfig $WAN_INTERFACE | grep "inet addr" | cut -d: -f2 | cut -d" " -f1);

# only replace NRPE server_address if neccessary
if [[ "$CURRENT_NRPE_ADDRESS" != "$CURRENT_WAN_ADDRESS" ]]; then
	sed -i "s/server_address=.*/server_address=$CURRENT_WAN_ADDRESS/" $NRPE_CONFIG_FILE
	if [[ "$?" -eq "0" ]]; then
		kill -HUP $(pgrep nrpe);
		if [[ "$?" -ne "0" ]]; then
			echo "Warning, HUP'ing nrpe was not successful, execution of NRPE checks may be disrupted. Please investigate!"
		fi
	fi
fi
