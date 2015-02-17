#!/bin/sh

echo "performing setup"
echo "creating resources dir"
mkdir -v res
echo "creating log files"
touch ./res/log
touch ./res/log_p
echo "creating channel list"
touch ./res/.chanlist
echo "setup complete"