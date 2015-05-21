#!/bin/env ruby
#############################################################################################
# author: apels <Alice Duchess>
# module as defined by .plugin.rb
#############################################################################################
# GLOBALS:
# - $logs are stored like [most recent - least recent], they are also unparsed
# - $admins is the list of admins
# - $plugins_s is the array of active plugins
#############################################################################################


$LOAD_PATH << './module'
require '.pluginf.rb'

class Reaperh < Pluginf
	#any functions you may need

	#your definition for script
	def script(message, nick, chan)

		# answers about bluckbot
		reaper_r = [
					"Rudamentary creatures of blood and flesh, you touch my mind, fumbling in ignorance, incapable of understanding.",
					"There is a realm of existence so far beyond your own you cannot even imagine it. I am beyond your comprehension.",
					"We are eternal. The pinnacle of evolution and existence. Before us, you are nothing.",
					"We have no beginning. We have no end. We are infinite.",
					"Irc bot, a label given to us by others to give voice to your autism."
				   ]

		qr = [
				/what are you/,
				/#{$nick_name}\?/,
				/#{$nick_name} is/
			 ]

		prefix_r = Regexp.union(qr)

		# general questions
		reaper_a = [
					"We are eternal, the pinnacle of evolution and existence. Before us, you are nothing.",
					"We have no beginning. We have no end. We are infinite."
				   ]

		qa = [
				/who made you/,
				/where are you from/,
				/who created you/,
				/source\?$/
			 ]

		prefix_a = Regexp.union(qa)

		help_a = [
				/help/,
				/Help/,
			     ]

		prefix_s = Regexp.union(help_a)

		# how can i help
		reaper_o = ["What do you require fleshling?", "What is it mortal?"]

		tokens = message.split(" ")

		message_t = ""

		1.upto(tokens.length - 1) do |a|
			message_t.concat("#{tokens[a]} ")
		end

		message_t = message_t[0..-2].to_s

		if tokens.length.to_i != 2 and message_t.match(prefix_r)
			reaper_r.shuffle!
			return "NOTICE #{nick} :#{reaper_r[2]}"
		end

		if tokens.length.to_i != 2 and message_t.match(prefix_a)
			reaper_a.shuffle!
			return "NOTICE #{nick} :#{reaper_a[1]}"

		end

		if tokens.length.to_i == 2 and message_t.match(prefix_s)
			reaper_o.shuffle!
			return "NOTICE #{nick} :#{reaper_o[1]}"
		end

		$plugins_s.each do |a|
			if tokens[1].to_s.downcase == a.name.to_s.downcase
				@r = "NOTICE #{nick} :here mortal\n#{a.help}"
				return @r
			end
		end

		return "NOTICE #{nick} :do not babble at me fleshling, I have little time or patience for your insignificant rambling."
	end
end

# allows you to support multiple regexes
# prefix = [
#		//,
#		//
#	   ]
#
# reg_p = Regexp.union(prefix)

reg_p = /^`h / #regex to call the module
na = "help" #name for plugin #same as file name without .rb
de = "`h [topic] provides help on modules or if one was not given an appropriate Reaper style response ise given" #description

#plugin = Class_name.new(regex, name, help)
#pushed onto to the end of plugins array array
plugin = Reaperh.new(reg_p, na, de)
$plugins_s.push(plugin)
