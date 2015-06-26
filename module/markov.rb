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

# this plugin requires files from https://github.com/epitron/markovchat to be placed
# in ./res/

$LOAD_PATH << './module'
require '.pluginf.rb'
$LOAD_PATH << './res'
require 'markovchat.rb'

class Template < Pluginf
	
	def initialize(regex, name, help)
		@regexp = Regexp.new(regex.to_s)
		@name = name.to_s
		@help = help
		@chan_list = []
		@chan_list.push("any")

		@m = nil

		if !File.exists?("markovchain.db")
			`touch markovchain.db`
			@m = MarkovChat.new("markovchain.db")
			#@markov_object.load
		else
			@m = MarkovChat.new("markovchain.db")
			#@markov_object.load
	    end
	end


	def cleanup
		m.save
	end

	#your definition for script
	def script(message, nick, chan)

		if message.match(/^?/)
			message = message[1..-1].to_s
			@r = @m.chat(message.to_s)
			return @r
		else
			Process.detach( fork { @m.add_sentence("#{message}") } )
		end

		return "string"
	end
end

prefix = [
		//,
		/^\?/
	   ]

 reg_p = Regexp.union(prefix)

#reg_p = // #regex to call the module
na = "template" #name for plugin #same as file name without .rb
de = "NOTES ^| HELP" #description

#plugin = Class_name.new(regex, name, help)
#pushed onto to the end of plugins array array
plugin = Template.new(reg_p, na, de)
$plugins_s.push(plugin)
