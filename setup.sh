#!/bin/sh

echo "performing setup"
echo "creating resources dir"
mkdir -v res
echo "creating config file"
touch ./res/.config.sh
echo "#!/bin/sh" >> ./res/.config.sh
echo "#network name" >> ./res/.config.sh
echo "export NETWORK_N=" >> ./res/.config.sh
echo "#Port Number" >> ./res/.config.sh
echo "export PORT_V=" >> ./res/.config.sh
echo "#channel name without the #" >> ./res/.config.sh
echo "export CHANNEL_N=" >> ./res/.config.sh
echo "#LOGGING TRUE | FALSE" >> ./res/.config.sh
echo "export LOGGING_YN=" >> ./res/.config.sh
echo "#WHETHER TO USE PASS TRUE | FALSE" >> ./res/.config.sh
echo "export PASS_YN=" >> ./res/.config.sh
echo "#Passphrase" >> ./res/.config.sh
echo "export PASSPHRASE=" >> ./res/.config.sh
echo "creating log files"
touch ./res/log
touch ./res/log_p
echo "creating channel list"
touch ./res/.chanlist
echo "creating module list"
touch ./res/.modlist
echo "usage.rb" > ./res/.modlist
echo "info.rb" >> ./res/.modlist
echo "admins.rb" >> ./res/.modlist
echo "creating admin list"
touch ./res/.admins
echo "creating nick file"
touch ./res/.nick_name
echo "bluckbot" > ./res/.nick_name
echo "setup complete"
