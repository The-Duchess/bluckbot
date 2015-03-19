#!/bin/sh
TRUE_T="TRUE"
FALSE_T="FALSE"
. ./res/.config.sh
if [ $PASS_YN == $TRUE_T ]; then
	ruby ./ircboats.rb "$NETWORK_N" "$PORT_V" "$CHANNEL_N" "$LOGGING_YN" "PASS" "$PASSPHRASE"
else
	if [ $PASS_YN == $FALSE_T ]; then
		ruby ./ircboats.rb "$NETWORK_N" "$PORT_V" "$CHANNEL_N" "$LOGGING_YN"
	fi
fi
