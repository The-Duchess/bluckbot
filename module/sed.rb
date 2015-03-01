#!/bin/env ruby
# template as defined by the required file
# author: apels <Alice Duchess>
# module as defined by .plugin.rb
# modules have access to $plugins to be loaded as well as $logs
# $logs stores unparsed message lines in an array of length 100
$LOAD_PATH << './module'
require '.pluginf.rb'

class PLUGIN < Pluginf
#any functions you may need
#your definition for script
	def script(message, nick, chan)
		command_s = message
		temp_c = message[1]
		command_set = command_s.split("#{temp_c}")
		#command_set = command_s.split("/")
		sed_a =  Regexp.new(command_set[1])
		sed_b = command_set[2].to_s
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
			message_s = message_reg_s[:trail].to_s

			if message_s.match(sed_a) and chan == chan_s then 
				included = true
				string_a = message_s.to_s
				nick_a = nick_s.to_s
				break
			else
				next
			end
		end

		@r = "#{nick_a}: "

		if included then
		#perform sed search replace on a
			system("echo \"#{string_a}\" > temp")
			@r.concat(`sed -e \"#{command_s}\" < temp`)
			#@r.concat(string_a.sub(sed_a, sed_b)) #this works as well but does not offer some options
			system("rm -f temp")
		else
			@r = ""
		end

		return @r
	end
end

#reg_p = /(^s\/(.*)\/(.*)\/(\w)?)/
reg_p = /(^s(.)(.*)\2(.*)\2(\w)?)/ #allows for any character for the delimiter in sed search replace
na = "sed"
de = "sed style search replace s/<input text and rules>/<output text and rules>/"
#plugin = Class_name.new(regex, name, help)
#passed back to the plugins_s array
plugin = PLUGIN.new(reg_p, na, de)
$plugins_s.push(plugin)
