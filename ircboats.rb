#!/usr/bin/env ruby
# ruby irc bot
# author apels Alice Duchess
# usage:
# ruby-2.1 ircboats.rb server port channel [logging <true> | <false>] [optional: PASS $PASS]
# example for non ssl ruby-2.1 ircboats.rb irc.rizon.net 6697 channelname false
# example for ssl     ruby-2.1 ircboats.rb irc.rizon.net 6697 channelname false
# example for network with a PASS ruby-2.1 ircboats.rb somenet 6697 channelname false PASS passphrase
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

load 'command.rb'

class Ircbot
	def initialize(server, port, channel, logging)
		@serv_name = server.to_s
		@channel = channel.to_s
		@port = port.to_i
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
	    	say "NICK bluckbot"
	    	say "USER k 0 * test"
	    	say "JOIN ##{@channel}"
	    	$logs = Array.new
	    	if logging.to_s == "true"
	    		@logging = true
	    	else
	    		@logging = false
	    	end

	    	@channel_s = []
	    	@channel_s.push("##{channel}")
	    	@ignore_s = []
	    	
	    	$admin_s = []

	    	File.open("./res/.admins", 'r') do |fr|
	    		while line = fr.gets
	    			line.chomp!
	    			$admin_s.push(line.to_s)
	    		end
	    	end

    end

	def say(msg)
    	#puts msg
    	@socket.puts msg
	end

	def say_to_chan(msg, chan_name)
		say "PRIVMSG #{chan_name} :#{msg}"
		p "PRIVMSG #{chan_name} :#{msg}"
	end

	def run
		until @socket.eof? do
			msg = @socket.gets
			#puts msg

			if msg.match(/^PING :(.*)$/)
				say "PONG #{$~[1]}"
				next
			end

			message_reg = msg.match(/^(:(?<prefix>\S+) )?(?<command>\S+)( (?!:)(?<params>.+?))?( :(?<trail>.+))?$/)
			nick = message_reg[:prefix].to_s.split("!")[0]
			command = message_reg[:command].to_s
			chan = message_reg[:params].to_s
			message = message_reg[:trail].to_s
			p "nick: #{nick}"
			p "command: #{command}"
			p "channel #{chan}"
			p "message: #{message}"
			p "#{message[0..-2].to_s.length}"

			if $logs.length == 100 then
				$logs.delete_at(99)
				$logs.insert(0, msg)
				if @logging == true and chan != "#trivia"
					#system("echo \"#{msg}\" >> ./res/log")
					#File.open("./res/log", 'a') { |fw| fw.puts "#{msg}"}
					File.write("./res/log", "#{msg}", File.size("./res/log"), mode: 'a')

				end
			else
				$logs.insert(0, msg)
				if @logging == true and chan != "#trivia"
					#system("echo \"#{msg}\" >> ./res/log")
					#File.open("./res/log", 'a') { |fw| fw.puts "#{msg}"}
					File.write("./res/log", "#{msg}", File.size("./res/log"), mode: 'a')
				end
			end

			if chan == "bluckbot"
				#system("echo \"#{@serv_name} #{msg}\" >> ./res/log_p")
				#File.open("./res/log_p", 'a') { |fw| fw.puts "#{@serv_name} #{msg}"}
				File.write("./res/log_p", "#{@serv_name} #{msg}", File.size("./res/log_p"), mode: 'a')
				chan = nick
			end

			if nick == "bluckbot"
				next
			end

			if @ignore_s.include? nick
				next
			end

			if message[0..-2].include? "ACTION pets bluckbot"
				say_to_chan("#{nick} ( \x0304◕\x03‿\x0304◕\x03)",chan)
			end

			if message[0..-2].match(/^`load chans/)
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

			if message[0..-2].match(/^`list channels$/) and chan == nick
				#list = ""
				@channel_s.each do |a|
					p a
					say "NOTICE #{nick} :#{a.split(' ')[0].to_s}"
				end

				next
				#say_to_chan(list, chan)
			end

			if message[0..-2].match(/^`msg /) and nick == chan
    			if $admin_s.include? nick.to_s
					arg = message[0..-2].split(' ')
					message_t = ""
					2.upto(arg.length.to_i - 1) { |a| message_t.concat("#{arg[a].to_s} ")}
					say_to_chan(message_t[0..-2], arg[1].to_s)
					next
				else
					say "NOTICE #{nick} :you are not in the admin file"
					say "NOTICE #{nick} :please contact the bot owner for questions"
    				end
			end

			if message[0..-2].match(/^`k /)
    			if $admin_s.include? nick.to_s
					reason = ""
					tokens = message[0..-2].split(' ')
					user = tokens[1].to_s
					2.upto(tokens.length - 1) { |a| reason.concat("#{tokens[a].to_s}")}

					say "KICK #{chan} #{user} \"#{reason}\""
				else
					say "NOTICE #{nick} :you are not in the admin file"
					say "NOTICE #{nick} :please contact the bot owner for questions"
    			end	
			end

			if message[0..-2].match(/^`ignore /)
				nick_b = message[8..-2].split(' ')
				nick_b.each do |a|
					@ignore_s.push(a.to_s)
				end
			end

			if message.match(/^`join ##?/)
				say "JOIN #{message[6..-2]}"
				if message[6..-2].include? ' '
					if @channel_s.include? message[6..-2].to_s
						next
					end

					@channel_s.push(message[6..-2].to_s)
					next
				else
					if @channel_s.include? message[6..-2].to_s
						next
					end

					@channel_s.push(message[6..-2].to_s)
				end

				next
			end

			if message[0..-2].match(/^`save chans/)
				File.open("./res/.chanlist", 'w') do |fw|
					@channel_s.each do |a|
						fw.puts a
					end
				end
			end

			if message[0..-2].match(/^`part/)
				say "PART #{chan}"
				next
			end

			if message[0..- 2].match(/^`plsgo$/)
    				if $admin_s.include? nick.to_s
    					$plugins_s.each do |a|
    						p parse(nick, chan, "`unload #{a.name} ")
    					end
						say_to_chan("sorry for the disturbance sempai", chan)
						quit
						break
					else
						say "NOTICE #{nick} :you are not in the admin file"
						say "NOTICE #{nick} :please contact the bot owner for questions"
    				end
			end

			if message[0..-2].match(/^`help/)
				if message[0..-2].match(/^`help$/)
					p parse(nick, chan, "`load use.rb ")
					p parse(nick, chan, "`load info.rb ")
					response = "`info for info. `usage for usage. `help $MODULENAME for help on the module"
					say "NOTICE #{nick} :#{response}"
					next
				end
			end

			if message[0..-2].match(/^`reload /)
    			if $admin_s.include? nick.to_s
    					@respond = parse(nick, chan, "`unload #{message[8..-1]}")
					say_to_chan(@respond, chan)
					@respond = parse(nick, chan, "`load #{message[8..-2]}.rb ")
					say_to_chan(@respond, chan)
    			else
					say "NOTICE #{nick} :you are not in the admin file"
					say "NOTICE #{nick} :please contact the bot owner for questions"
    			end

			end

			response = parse(nick, chan, message)

			#if the reponse is actually worth running the send and it is also a string
			if response.length > 0 and response.class.to_s.downcase == "string"
				#this grants a form of access to sockets and allows 
				#the bot to run special commands through modules
				#say "PRIVMSG #{chan_name} :#{msg}"
				#format the message to return as PRIVMSG #channel | nick :message text you want to send to a channel or someone
				prefix = [
							/^PRIVMSG /,
							/^NOTICE /
				]

				reg_s = Regexp.union(prefix)

				if response.match(reg_s) # or any other i feel like adding
					if response.include? "\n"
						@res_new = response.split("\n")
						tokens = @res_new[0].split(' ')
						1.upto(@res_new.length - 1) { |a| @res_new[a].prepend("#{tokens[0]} #{tokens[1]} :")}
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

	def quit
		say "PART ##{@channel} :pls no more testing!"
		say 'QUIT'

		@socket.sysclose
	end
end

ARGV.each { |a| p a.to_s}

bot1 = Ircbot.new("#{ARGV[0].to_s}", "#{ARGV[1].to_i}", "#{ARGV[2].to_s}", "#{ARGV[3].to_s}") #, "#{ARGV[4].to_s}")

bot1.run

#Thread.new { bot1.run }
