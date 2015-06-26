#!/usr/bin/env ruby
# ruby irc bot
# author: Alice Duchess (lolth)
# usage:
# NOTE: bluckbot is tested in ruby 2.1, if your default ruby is not 2.1 then run ruby-1.1 or higher instead
# also gems will need to be installed to your ruby of 2.1 or higher so that they will be loaded
# check modules for specific gems
# ruby ircboats.rb server port channel [logging <true> | <false>] [optional: PASS $PASS]
# example for non ssl ruby ircboats.rb irc.rizon.net 6697 channelname false
# example for ssl     ruby ircboats.rb irc.rizon.net 6697 channelname false
# example for network with a PASS ruby ircboats.rb somenet 6697 channelname false PASS passphrase
####################################################################################################################
# commands
# `plsgo : tells the bot to quit
# `ignore $NICK : tells the bot to ignore a nick
# `save | `load chans : saves and loads channels from currently active and previously saved
# /msg bluckbot `list channels : lists channels, must be a pm from the owner
# `msg $NICK message : sends a message to $NICK
# `part : parts the active channel
# `join $#CHANNEL : joins a channel
# `k $NICK reason: only accessible to the owner and kicks a user from the channel
# `help : prints help
# `load $MODULE : loads a module
# `unload $MODULE : unloads a module
# `ls : lists modules
# `list : lists loaded modules
# `help $MODULE : gives help on a certain module
# `help modules : gives help for all loaded modules
# `mass load : loads a preset set of modules in ./res/.modlist
####################################################################################################################

require 'socket'
require 'openssl'

$plugins_s = Array.new

class Ircbot
	def initialize(server, port, channel, logging)
		$nick_name = ""
		File.open("./res/.nick_name", 'r') do |fr|
			while line = fr.gets
				line = line.chomp!
				$nick_name = line
				break
			end
			break
		end
		@serv_name = server.to_s
		@channel = channel.to_s
		@port = port.to_i
		puts "Connecting to #{@serv_name} on port #{@port}"
		#STDOUT.flush
		@socket = TCPSocket.open(@serv_name, @port)
		if port.to_i != 6667
			ssl_context = OpenSSL::SSL::SSLContext.new
			ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
			@socket = OpenSSL::SSL::SSLSocket.new(@socket, ssl_context)
			@socket.sync = true
			@socket.connect
			if ARGV.length > 3
				if ARGV[4].to_s == "PASS"
					@socket.puts "PASS #{ARGV[5].to_s}"
				end
			end
		end
		puts "	|"
		puts "	|_Authenticating"
		puts "	|	|"
		puts "	|	|_Nick: #{$nick_name}"
		puts "	|	|"
		puts "	|	|_Name: test"
		puts "	|	|"
		puts "	|	|_User: k"
		#STDOUT.flush
		say "NICK #{$nick_name}"
		say "USER k 0 * test"
		puts "	|"
		puts "	|_Joining ##{@channel}"
		#STDOUT.flush
		say "JOIN ##{@channel}"
		$logs = Array.new
		if logging.to_s == "true"
			puts "	|"
			puts "	|_Logging enabled"
			@logging = true
		else
			puts "	|"
			puts "	|_Logging disabled"
			@logging = false
		end

		STDOUT.flush

		@channel_s = []
		@channel_s.push("##{channel}")
		@ignore_s = []

		$admin_s = []

		puts "	|"
		puts "	|_Loading admin file"
		File.open("./res/.admins", 'r') do |fr|
			while line = fr.gets
				line.chomp!
				if line != "\n" and line != "" and line != "\r\n"
					$admin_s.push(line.to_s)
				end
				puts "		|"
				puts "		|_#{line}"
			end
		end

		puts "done!"
	end

	def say(msg)
		#puts msg
		@socket.puts msg
	end

	def say_to_chan(msg, chan_name)
		say "PRIVMSG #{chan_name} :#{msg}"
		#p "PRIVMSG #{chan_name} :#{msg}"
	end

	def check_admin(nick)
		if $admin_s.include? nick
			return true
		else
			return false
		end
	end

	def load(message, nick, chan)
		if not check_admin(nick)
			say "NOTICE #{nick} :please do not disturb the irc bots."
			return
		end

		if message.match(/^`load /) and message.length > 5 then
			$LOAD_PATH << './module'
			ls = message.to_s[6..-1]
			if !ls.match(/.rb$/)
				ls = "#{ls}.rb"
			end
			#checks if the module is already loaded
			@ra = ""
			$plugins_s.each { |a| @ra.concat("#{a.name.downcase}.rb ") }
			@rb = @ra[0..-1].split(" ")
			@rb.each do |a|
				if a == ls
					say_to_chan("#{ls} is already loaded", channel)
					return
				end
			end
			#checks if the module is is there
			@ra = `ls ./module/`.split("\n").each { |a| a.to_s[0..-2] }
			if not @ra.include? ls
				say_to_chan("#{ls} does not exist", chan)
				return
			end
			#load ls
			load "#{ls}"
			$LOAD_PATH << './'
			say_to_chan("#{ls} loaded", chan)
			return
		end

		return
	end

	def unload(message, nick, chan)
		if message.match(/^`unload /)

			if not check_admin(nick)
				say "NOTICE #{nick} :please do not disturb the irc bots."
				return
			end

			@ii = 0
			@r = ""
			$plugins_s.each do |a|
				#p message.to_s[8..-1]
				#p a.name.to_s
				if a.name.to_s.downcase == message.to_s.downcase[8..-1]
					@r = "plugin #{a.name.to_s} removed"
					p "class"
					p a.class.to_s
					$plugins_s[@ii].cleanup
					$plugins_s.delete_at(@ii)
					say_to_chan(@r, chan)
					return
				else
					@ii += 1
				end

				next
			end

			return
		end
	end

	def run
		until @socket.eof? do

				msg = @socket.gets

				if msg.match(/^PING :(.*)$/)
					say "PONG #{$~[1]}"
					next
				end

				message_reg = msg.match(/^(:(?<prefix>\S+) )?(?<command>\S+)( (?!:)(?<params>.+?))?( :(?<trail>.+))?$/)
				nick = message_reg[:prefix].to_s.split("!")[0]
				command = message_reg[:command].to_s
				chan = message_reg[:params].to_s
				message = message_reg[:trail].to_s
				#p "nick: #{nick}"
				#p "command: #{command}"
				#p "channel #{chan}"
				#p "message: #{message}"
				#p "#{message[0..-1].to_s.length}"

				message = message.chomp

				if $logs.length == 1000 then

					if nick != $nick_name
						$logs.delete_at(999)
						$logs.insert(0, msg)
					end

					if @logging == true and nick != $nick_name
						#system("echo \"#{msg}\" >> ./res/log")
						#File.open("./res/log", 'a') { |fw| fw.puts "#{msg}"}
						temp_line = "[SERVER: #{@serv_name}] [NICK: #{nick}] #{command} #{chan} :#{message.chomp!}\n"
						File.write("./res/log", "#{temp_line}", File.size("./res/log"), mode: 'a')

					end
				else
					if nick != $nick_name
						$logs.insert(0, msg)

					end

					if @logging == true and nick != $nick_name
						#system("echo \"#{msg}\" >> ./res/log")
						#File.open("./res/log", 'a') { |fw| fw.puts "#{msg}"}
						temp_line = "[SERVER: #{@serv_name}] [NICK: #{nick}] #{command} #{chan} :#{message.chomp!}\n"
						File.write("./res/log", "#{temp_line}", File.size("./res/log"), mode: 'a')
					end
				end

				if chan == "#{$nick_name}"
					#system("echo \"#{@serv_name} #{msg}\" >> ./res/log_p")
					#File.open("./res/log_p", 'a') { |fw| fw.puts "#{@serv_name} #{msg}"}
					temp_line = "PM LOG FILE ENTRY INFO: NETWORK: #{@serv_name} MESSAGE INFO: NICK: #{nick} MESSAGE_PARAM: #{message.chomp}\n"
					File.write("./res/log_p", "#{temp_line}", File.size("./res/log_p"), mode: 'a')
					chan = nick
				end

				if nick == $nick_name
					message = "NIL"
					next
				end

				if @ignore_s.include? nick

					next
				end

				if message[0..-1].include? "ACTION pets #{$nick_name}"

					say_to_chan("#{nick} ( \x0304◕\x03‿\x0304◕\x03)",chan)
				end


				#if $plugins_s.class != nil
				if $plugins_s.length > 0 then
					$plugins_s.each do |a|
						if message.match(a.regex) and (a.chans.include? chan or a.chans.include? "any") then
							response = a.script(message, nick, chan)

							if response.length > 0 and response.class.to_s.downcase == "string"
								#this grants a form of access to sockets and allows
								#the bot to run special commands through modules
								#say "PRIVMSG #{chan_name} :#{msg}"
								#format the message to return as PRIVMSG #channel | nick :message text you want to send to a channel or someone
								prefix = [
									/^PRIVMSG /,
									/^NOTICE /,
									/^KICK/,
									/^MODE/
								]

								reg_s = Regexp.union(prefix)

								if response.match(reg_s) # or any other i feel like adding
									if response.include? "\n"
										@res_new = response.split("\n")
										tokens = @res_new[0].split(' ')
										1.upto(@res_new.length - 1) { |a| @res_new[a].prepend("#{tokens[0]} #{tokens[1]} :") }
										@res_new.each do |a|
											say "#{a}"
										end
									else
										say "#{response}"
									end
								else
									if response.include? "\n"
										@res_new = response.split("\n")
										@res_new.each do |a|
											say_to_chan("#{a}", chan)
										end
									else
										say_to_chan("#{response}", chan)
									end

									next
								end
							end
						end
					end
				end
			end
		end

		def quit
			say "PART ##{@channel} :"
			say 'QUIT'

			@socket.sysclose
		end
	end


	#bot1 = Ircbot.new("#{ARGV[0].to_s}", "#{ARGV[1].to_i}", "#{ARGV[2].to_s}", "#{ARGV[3].to_s}") #, "#{ARGV[4].to_s}")

	#bot1.run
