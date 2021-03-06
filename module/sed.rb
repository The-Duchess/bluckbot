#!/bin/env ruby
# sed.rb
# author: apels <Alice Duchess>
# module to handle sed style search replace
# only accepts / as the delimiter for sed even though any character is normally accepted
# the code to allow any character is commented out

$LOAD_PATH << './module'
require '.pluginf.rb'

class PLUGIN < Pluginf
#any functions you may need
#your definition for script
	def script(message, nick, chan)

		if nick == $nick_name then return "" end

		command_s = message
		#temp_c = message[1]
		#command_set = command_s.split("#{temp_c}")
		#command_set = command_s.split("/")
		#split will not handle \/ properly
		msg_l = message.length.to_i - 1
		temp_sa = ""
		temp_sb = ""
		i = 0
		2.upto(msg_l) do |a|
			if message[a] == "/" and message[a - 1] != "\\"
				#we're done
				break
				i = i + 1
			else
				temp_sa.concat(message[a])
				i = i + 1
			end
		end
		
		i = i - 1
		
		i.upto(msg_l) do |b|
			if message[b] == "/" and message[b - 1] != "\\"
				#we're done
				break
			else
				temp_sb.concat(message[b])
			end
		end
		
		#this can likely be done with a regex to split on "/" and not if "/" comes after "\"
		
		#sed_a =  Regexp.new(command_set[1])
		#sed_b = command_set[2].to_s
		begin
			sed_a = Regexp.new(temp_sa.to_s)
		rescue => e
			return "an error occured. perhaps the regex is invalid."
		end
		sed_b = temp_sb.to_s
		p "regex search: #{sed_a.to_s}"
		p "replace: #{sed_b}"
		
		included = false
		string_a = ""
		nick_a = ""

		length_l = $logs.length.to_i
		length_l = length_l - 1
		#$logs.each do |a|

		1.upto(length_l) do |a|

			message_reg_s = $logs[a].match(/^(:(?<prefix>\S+) )?(?<command>\S+)( (?!:)(?<params>.+?))?( :(?<trail>.+))?$/)
			nick_s = message_reg_s[:prefix].to_s.split("!")[0]
			commands = message_reg_s[:command].to_s
			chan_s = message_reg_s[:params].to_s
			message_s = message_reg_s[:trail].to_s[0..-2]
			
			if message_s.match(/^ACTION /)
				@r = "» #{nick_s} "
				message_set = message_s.split(" ")
				message_set.delete_at(0)
				message_s = ""
				message_set.each { |a| message_s.concat("#{a} ") }
				message_s = message_s[0..-2]
			else
				@r = "「#{nick_s}」 "
			end
			
			if message_s.match(sed_a) and chan == chan_s and nick_s != $nick_name then 
				included = true
				string_a = message_s.to_s
				nick_a = nick_s.to_s
				break
			else
				next
			end
		end

		if included then
		#perform sed search replace on a
			#system("echo \"#{string_a}\" > temp")
			File.open("./temp", 'w') { |fw| fw.puts "#{string_a}" }
			File.open("./temp_s", 'w') { |fw| fw.puts "#{command_s}" }
			@r_s = `sed -r -f ./temp_s < ./temp`
			if @r_s.length > 0 then
				@r.concat(@r_s.to_s)
			else
				@r = ""
			end
			#@r.concat(string_a.sub(sed_a, sed_b)) #this works as well but does not offer some options
			system("rm -f temp")
			system("rm -f temp_s")
		else
			@r = ""
		end

		return @r
	end
end

reg_p = /(^s\/(.*)\/(.*)\/(\w)?)/
#reg_p = /(^s(.)(.*)\2(.*)\2(\w)?)/ #allows for any character for the delimiter in sed search replace
na = "sed"
de = "sed style search replace s/<input text and rules>/<output text and rules>/ note: multiple commands using ; to seperate is not supported and weird errors may occur"
#plugin = Class_name.new(regex, name, help)
#passed back to the plugins_s array
plugin = PLUGIN.new(reg_p, na, de)
$plugins_s.push(plugin)
