#!/bin/bash

. ./res/.config.sh
if [ "$PASS_YN" = "TRUE"]; then
	ruby-2.1 ./ircboats.rb $NETWORK_N $PORT_V $CHANNEL_N $LOGGING_YN PASS $PASSPHRASE
else
	if [ "$PASS_YN" = "FALSE"]
		ruby-2.1 ./ircboats.rb $NET $PORT $CHANNEL $LOGGING
	fi
fi