#! /bin/env ruby
#
# Configuration Tool
# this script will setup and run the IRC bot and prevent you from having to manually edit
# the config files.
#
# Config files to setup:
# 	<> .admins
# 	<> .chanlist
# 	<> .config.sh
# 	<> .modlist
# 	<> .nick_name
#
# this script will end by calling run.sh if the user wants to
# this script will also overwrite existing config files
# there is no existing default outside of .modlist and .nick_name

def setup_admin_file
	input = ""
	`echo \"\" > ./res/.admins`

	puts "you must enter at least one admin nick for the bot"

	while input != "N" and input != "n" and input != "exit"
		print "> "
		STDOUT.flush
		input = STDIN.gets
		input = input.chomp

		if input != "N" and input != "n" and input != "exit" and !input.include? " "
			`echo \"#{input}\" >> ./res/.admins`
		else
			puts "invalid input"
			input = "y"
			next
		end

		print "add another nick to the admin file [Y/n]? "
		STDOUT.flush
		input = STDIN.gets
		input = input.chomp

	end
end

def setup_channels_file
	input = ""
	`echo \"\" > ./res/.chanlist`

	puts "enter a channel for the ircbot to join with `load chans; entering n, N and exit will allow you to skip"

	while input != "N" and input != "n" and input != "exit"
		print "> "
		STDOUT.flush
		input = STDIN.gets
		input = input.chomp

		if input != "N" and input != "n" input != "exit" and !input.match(/^\#/)
			`echo "#{input}" >> ./res/.chanlist`
		else
			puts "invalid input"
			input = "y"
		end

		print "add another channel to the channels file [Y/n]? "
		STDOUT.flush
		input = STDIN.gets
		input = input.chomp

	end
end

def setup_config_script
	# required entries
	# network name
	network_id = ""
	# port
	port = 6667
	# channel name
	channel = ""
	# logging
	logging = ""
	# pass confirm
	pass_y_n = ""
	# pass
	pass = ""

	print "enter an irc network server address: "
	STDOUT.flush
	input = STDIN.gets
	input = input.chomp
	network_id = input

	print "enter a port: "
	STDOUT.flush
	input = STDIN.gets
	input = input.chomp
	port = input.to_i

	print "enter a channel without the #: "
	STDOUT.flush
	input = STDIN.gets
	input = input.chomp
	channel = input

	print "enter whether you want the bot to log [TRUE | FALSE]: "
	STDOUT.flush
	input = STDIN.gets
	input = input.chomp
	logging = input

	print "enter whther the network uses a password to connect [TRUE | FALSE]: "
	STDOUT.flush
	input = STDIN.gets
	input = input.chomp
	pass_y_n = input

	if pass_y_n == "TRUE"
		print "enter network password: "
		STDOUT.flush
		input = STDIN.gets
		input = input.chomp
		pass = intput
	end

	echo "#!/bin/sh" > ./res/.config.sh
	echo "#network name" >> ./res/.config.sh
	echo "export NETWORK_N=#{network_id}" >> ./res/.config.sh
	echo "#Port Number" >> ./res/.config.sh
	echo "export PORT_V=#{port}" >> ./res/.config.sh
	echo "#channel name without the #" >> ./res/.config.sh
	echo "export CHANNEL_N=#{channel}" >> ./res/.config.sh
	echo "#LOGGING TRUE | FALSE" >> ./res/.config.sh
	echo "export LOGGING_YN=#{logging}" >> ./res/.config.sh
	echo "#WHETHER TO USE PASS TRUE | FALSE" >> ./res/.config.sh
	echo "export PASS_YN=#{pass_y_n}" >> ./res/.config.sh
	echo "#Passphrase" >> ./res/.config.sh
	echo "export PASSPHRASE=#{pass}" >> ./res/.config.sh

end

def setup_modules_file
	input = ""
	`echo "usage.rb" > ./res/.modlist`
	`echo "info.rb" >> ./res/.modlist`

	puts "enter a module for the ircbot to load with `mass load\nentering n, N and exit will allow you to skip\nentering list will list available modules"

	while input != "N" and input != "n" and input != "exit"
		print "> "
		STDOUT.flush
		input = STDIN.gets
		input = input.chomp

		if input != "N" and input != "n" input != "exit" and input.match(/.rb$/) and !input.include? "" and input != "list"
			`echo "#{input}" >> ./res/.modlist`
		elsif input == "list"
			ra = `ls ./module/`.split("\n").each { |a| a.to_s[0..-1]}
			print "available modules: "
			STDOUT.flush
			ra.each do { |a| print "#{a} "; STDOUT.flush}
			puts ""
		else
			puts "invalid input"
			input = "y"
		end

		print "add another module to the modules file [Y/n]? "
		STDOUT.flush
		input = STDIN.gets
		input = input.chomp

	end
end

def setup_nick_name
	input = ""
	`echo "bluckbot" > ./res/.nick_name`

	print "use a custome nick [y/N]? "
	STDOUT.flush
	input = STDIN.gets
	input = input.chomp

	if input == "y" or input  == "Y"
		print "enter a nick to use: "
		STDOUT.flush
		input = STDIN.gets
		input = input.chomp
		`echo \"#{input}\" > ./res/.nick_name`
	end
end

def start_bot
	`./run.sh`
end

def main
	setup_admin_file
	setup_channels_file
	setup_modules_file
	setup_nick_name
	setup_config_script

	print "do you want to start the irc bot now [Y/n]? "
	STDOUT.flush
	input = STDIN.gets
	input = input.chomp
	if input != 'n' and input != 'N'
		start_bot
	end
end

main