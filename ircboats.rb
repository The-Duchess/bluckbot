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

	def load_mod(message, nick, chan)
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

	def unload_mod(message, nick, chan)
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
				if message[0..-1].match(/^`load chans/)
					File.open("./res/.chanlist", 'r') do |fr|
						while line = fr.gets
							#say_to_chan(line, "apels_")
							if line.include? ' '
								if @channel_s.include? line.to_s
									next
								end

								say "JOIN #{line}"
								@channel_s.push(line.to_s)
								next
							end
						end
					end

					next
				end

				if message[0..-1].match(/^`list channels$/)
					if !$admin_s.include? nick.to_s
						say "NOTICE #{nick} :please do not disturb the irc bots."
						next
					end

					@channel_s.each do |a|
						p a
						say "NOTICE #{nick} :#{a.split(' ')[0].to_s}"
						next
					end

					next
					#say_to_chan(list, chan)
				end

				if message[0..-1].match(/^`msg /) and nick == chan
					if $admin_s.include? nick.to_s
						arg = message[0..-1].split(' ')
						message_t = ""
						2.upto(arg.length.to_i - 1) { |a| message_t.concat("#{arg[a].to_s} ") }
						say_to_chan(message_t[0..-1], arg[1].to_s)
						next
					else
						"NOTICE #{nick} :please do not disturb the irc bots."
					end

					next
				end

				if message[0..-1].match(/^`act /) and nick == chan
					if $admin_s.include? nick.to_s
						arg = message[0..-1].split(' ')
						message_t = ""
						2.upto(arg.length.to_i - 1) { |a| message_t.concat("#{arg[a].to_s} ") }
						say_to_chan("\001ACTION #{message_t[0..-1]}\001", arg[1].to_s)
						next
					else
						"NOTICE #{nick} :please do not disturb the irc bots."
					end

					next
				end

				if message[0..-1].match(/^`k /)
					if $admin_s.include? nick.to_s
						reason = ""
						tokens = message[0..-1].split(' ')
						user = tokens[1].to_s
						2.upto(tokens.length - 1) { |a| reason.concat("#{tokens[a].to_s}") }

						say "KICK #{chan} #{user} \"#{reason}\""
						next
					else
						say "NOTICE #{nick} :you are not in the admin file"
						say "NOTICE #{nick} :please contact the bot owner for questions"
					end

					next
				end

				if message[0..-1].match(/^`ignore /)
					if $admin_s.include? nick
						nick_b = message[8..-1].split(' ')
						nick_b.each do |a|
							@ignore_s.push(a.to_s)
							say "NOTICE #{a} :You had been informed not to disturb the irc bots but apparently you couldn't help yourself."
						end
						next
					else
						say "NOTICE #{nick} :please do not disturb the irc bots."
					end

					next
				end

				if message[0..-1].match(/^`unignore /)
					if $admin_s.include? nick
						nick_b = message[8..-1].split(' ')
						nick_b.each do |a|
							@ignore_s.delete_if { |b| b == a }
						end
						next
					else
						say "NOTICE #{nick} :please do not disturb the irc bots."
					end

					next
				end

				if message[0..-1].match(/`lsign/) #list ignored nicks
					if $admin_s.include? nick
						say "NOTICE #{nick} :Ignored Nicks ===================="
						@ignore_s.each do |a|
							say "NOTICE #{nick} :#{a}"
						end
						say "NOTICE #{nick} :=================================="
						next
					else
						say "NOTICE #{nick} :please do not disturb the irc bots."
					end

					next
				end

				if message.match(/^`join ##?/)
					say "JOIN #{message[6..-1]}"

					if not $admin_s.include? nick
						say_to_chan("You must gather your party before venturing forth.", chan)
						say "NOTICE #{nick} :please do not disturb the irc bots."
						next
					else

						if message[6..-1].include? ' '
							if @channel_s.include? message[6..-1].to_s
								next
							end

							@channel_s.push(message[6..-1].to_s)
							next
						else
							if @channel_s.include? message[6..-1].to_s
								next
							end

							@channel_s.push(message[6..-1].to_s)
						end

					end

					next
				end

				if message[0..-1].match(/^`save chans/)
					File.open("./res/.chanlist", 'w') do |fw|
						@channel_s.each do |a|
							fw.puts a
						end
					end
					next
				end

				if message[0..-1].match(/^`part/)
					if $admin_s.include? nick
						say "PART #{chan}"
						next
					else
						say "NOTICE #{nick} :please do not disturb the irc bots."
					end

					next
				end

				if message[0..- 1].match(/^`plsgo$/)
					if $admin_s.include? nick.to_s
						$plugins_s.each do |i|
							i.cleanup
						end
						say_to_chan("This exchange is over.", chan)
						quit
						break
					else
						say "NOTICE #{nick} :you are not in the admin file"
						say "NOTICE #{nick} :please contact the bot owner for questions"
					end
				end

				if message[0..-1].match(/^`help$/)
					if message[0..-1].match(/^`help$/)
						response = "`info for info. `usage for usage. `help $TOPIC for help on a module"
						say "NOTICE #{nick} :#{response}"
						next
					end

					next
				end

				if message[0..-1].match(/^`reload /) and message.length > 8
					if $admin_s.include? nick.to_s
						unload_mod("`unload #{message[8..-1]}", nick, chan)
						load_mod("`load #{message[8..-1]}.rb", nick, chan)
						next
					else
						say "NOTICE #{nick} :please do not disturb the irc bots."
					end
					next
				end

				if message.match(/^`load /) and message.length > 5
					load_mod("`load #{message[6..-1]}", nick, chan)
					next
				end

				if message.match(/^`ls$/)

					if not check_admin(nick)
						say "NOTICE #{nick} :you are not in the admin file\nplease contact the bot owner for questions"
					end

					@r = "NOTICE #{nick} :"
					@ra = `ls ./module/`.split("\n").each { |a| a.to_s[0..-1] }
					@ra.each { |a| @r.concat("#{a} ") }
					say @r[0..-1].to_s

				end

				if message.match(/^`list$/)

					@r = "NOTICE #{nick} :"

					$plugins_s.each do |a|
						#p a.class.to_s
						#p a.regex.to_s
						#p a.name.to_s
						#p a.help.to_s
						@r.concat("#{a.name} ")
					end

					say @r[0..-2].to_s
				end

				if message.match(/^`help /)
					@ii = 0
					@r = ""
					$plugins_s.each do |a|
						#p message.to_s[6..-1]
						#p a.name.to_s
						if a.name.to_s.downcase == message.to_s.downcase[6..-1]
							@r = "NOTICE #{nick} :#{a.name} description: #{a.help}"
							say @r.to_s
						end

						next
					end

					say_to_chan("no plugin: #{message[6..-1]} was found", chan)
				end

				if message.match(/^`unload /) and message.length > 8
					unload_mod("`unload #{message[8..-1]}", nick, chan)
					next
				end

				if message.match(/^`mass load$/)

					if not check_admin(nick)
						return "NOTICE #{nick} :please do not disturb the irc bots."
					end

					temp_r = []
					File.open("./res/.modlist", 'r') do |fr|
						while line = fr.gets
							line.chomp!
							temp_r.push(line.to_s)
						end
					end
					temp_p = []
					$plugins_s.each { |a| temp_p.push("#{a.name.downcase}.rb") }
					temp_r.each do |a|
						if temp_p.include? a
							p "#{a} is already loaded"
							next
						end

						$LOAD_PATH << './module'
						begin
							load "#{a}"
						rescue => e
							p "failed to load #{a}"
						end

						$LOAD_PATH << './'
					end
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

def main
	bot1 = Ircbot.new("#{ARGV[0].to_s}", "#{ARGV[1].to_i}", "#{ARGV[2].to_s}", "#{ARGV[3].to_s}") #, "#{ARGV[4].to_s}")

	bot1.run
end

main