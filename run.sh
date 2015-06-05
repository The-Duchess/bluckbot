#!/bin/sh
. ./res/.config.sh
if [[ "$PASS_YN" == "TRUE" ]]; then
	ruby ./ircboats.rb "$NETWORK_N" "$PORT_V" "$CHANNEL_N" "$LOGGING_YN" "PASS" "$PASSPHRASE"
else
	if [[ "$PASS_YN" == "FALSE" ]]; then
		ruby ./ircboats.rb "$NETWORK_N" "$PORT_V" "$CHANNEL_N" "$LOGGING_YN"
	fi
fi
