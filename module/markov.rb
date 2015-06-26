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
# in ./res/ along with a db
# you also may want to have a text file lg in ./res to make it run properly

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

		if !File.exists?("./res/markovchain.db")
			`touch markovchain.db`
			@m = MarkovChat.new("./res/markovchain.db")
			@m.add_sentence("r u a big guy")
			@m.add_sentence("benis")
			@m.add_sentence("sayaka is a slut")
			@m.add_sentence("HURR DURR MUH SOMETHING RETARDED")
			@m.add_sentence("piss")
			@m.save
			#@markov_object.load
		else
			@m = MarkovChat.new("./res/markovchain.db")
			@m.save
			#@markov_object.load
	    end

	    @m.load

	    if !File.exists?("./res/lg")
	    	return
	    end

		# read in file into markov bot
		File.open("./res/lg", "r") do |fr|
			while line = fr.gets
				line = line.chomp
				# pass line to markov chain obj
				@m.add_sentence("#{line}")
			end
		end
	end


	def cleanup
		@m.save
	end

	#your definition for script
	def script(message, nick, chan)

		if message.match(/^[?]/)
			p "triggering message generate"
			message = message[1..-1].to_s
			word = message.split(" ")[0].to_s
			@r = @m.chat("#{word}")
			return @r
		else
			Process.detach( fork { @m.add_sentence("#{message}") } )
			return ""
		end
	end
end

prefix = [
		//,
		/^[?]/
	   ]

reg_p = Regexp.union(prefix)

#reg_p = // #regex to call the module
na = "markov" #name for plugin #same as file name without .rb
de = "?<word> generates a message based on what people have said and the <word>" #description

#plugin = Class_name.new(regex, name, help)
#pushed onto to the end of plugins array array
plugin = Template.new(reg_p, na, de)
$plugins_s.push(plugin)
