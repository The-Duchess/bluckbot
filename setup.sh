#!/bin/sh

echo "performing setup"
echo "creating resources dir"
mkdir -v res
echo "creating config file"
touch ./res/.config.sh
echo "#!/bin/bash" >> ./res/.config.sh
echo "#network name" >> ./res/.config.sh
echo "NETWORK_N =" >> ./res/.config.sh
echo "#Port Number" >> ./res/.config.sh
echo "PORT_V =" >> ./res/.config.sh
echo "#channel name without the #" >> ./res/.config.sh
echo "CHANNEL_N =" >> ./res/.config.sh
echo "#LOGGING TRUE | FALSE" >> ./res/.config.sh
echo "LOGGING_YN =" >> ./res/.config.sh
echo "#WHETHER TO USE PASS TRUE | FALSE" >> ./res/.config.sh
echo "PASS_YN =" >> ./res/.config.sh
echo "#Passphrase" >> ./res/.config.sh
echo "PASSPHRASE =" >> ./res/.config.sh
echo "creating log files"
touch ./res/log
touch ./res/log_p
echo "creating channel list"
touch ./res/.chanlist
echo "setup complete"