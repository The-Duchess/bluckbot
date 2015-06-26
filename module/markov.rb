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

require 'marky_markov'

$LOAD_PATH << './module'
require '.pluginf.rb'

class Template < Pluginf
	
	def initialize(regex, name, help)
		@regexp = Regexp.new(regex.to_s)
		@name = name.to_s
		@help = help
		@chan_list = []
		@chan_list.push("any")

		if !File.exist? ("./res/.dictionary.mmd")
			@m = MarkyMarkov::Dictionary.new("./res/dictionary", 5)
			@m.parse_string "this is a test"
			if File.exist? ("./res/lg")
				@m.parse_file "./res/lg"
			end

			@m.save_dictionary!
		else
			@m = MarkyMarkov::Dictionary.new("./res/dictionary", 5)
		end
	end


	def cleanup
		@m.save_dictionary!
	end

	#your definition for script
	def script(message, nick, chan)

		if message.match(/^`post/)
			p "triggering message generate"
			message = message[1..-1].to_s
			word = message.split(" ")[0].to_s
			@r = @m.generate_n_sentences 2
			return @r[rand(2)]
		else
			Process.detach( fork { @m.parse_string("#{message}") } )
			return ""
		end
	end
end

prefix = [
		//,
		/^`post/
	   ]

reg_p = Regexp.union(prefix)

#reg_p = // #regex to call the module
na = "markov" #name for plugin #same as file name without .rb
de = "?<word> generates a message based on what people have said and the <word>" #description

#plugin = Class_name.new(regex, name, help)
#pushed onto to the end of plugins array array
plugin = Template.new(reg_p, na, de)
$plugins_s.push(plugin)
