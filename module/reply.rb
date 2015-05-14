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

class Trigger < Pluginf

	def initialize(regex, name, help, phrase)
		@regexp = Regexp.new(regex.to_s)
		@name = name.to_s
		@help = help
		@chan_list = []
		@chan_list.push("any")
		@phrase = phrase
	end

	def script(message, nick, chan)
		return @phrase
	end

end

class Plsrespond < Pluginf
	#any functions you may need

	#your definition for script
	def script(message, nick, chan)

		tokens = message.split(" ")

		if tokens.length.to_i == 1 or nick == "bluckbot"
			return ""
		end

		tokens.each do |a|
			print "#{a} "
			STDOUT.flush
		end

		puts "test"

		phrase = ""

		if tokens[2] == "triggers"

			p "===================triggers==================="

			3.upto(tokens.length.to_i - 1) do |a|
				phrase.concat("#{tokens[a]} ")
			end

			phrase = phrase[0..-2].to_s

			$plugins_s.push(Trigger.new(tokens[1], "", "", phrase))

		elsif tokens[2] == "say"

			p "===================say==================="

			3.upto(tokens.length.to_i - 1) do |a|
				phrase.concat("#{tokens[a]} ")
			end

			phrase = phrase[0..-2].to_s

			$plugins_s.push(Trigger.new(tokens[1], "", "", phrase))

		else
			return "invalid syntax"
		end

		return "#{phrase} triggered by #{tokens[1]}"
	end
end

reg_p = /^`reply/ #regex to call the module
na = "reply" #name for plugin #same as file name without .rb
de = "reply with programmed text `reply $word triggers $phrase or `reply forget $word or `reply $nick say $phrase" #description

#plugin = Class_name.new(regex, name, help)
#pushed onto to the end of plugins array array
plugin = Plsrespond.new(reg_p, na, de)
$plugins_s.push(plugin)
