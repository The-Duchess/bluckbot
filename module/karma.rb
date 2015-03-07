#!/bin/env ruby
# template as defined by the required file
# author: apels <Alice Duchess>
# module as defined by .plugin.rb
# modules have access to $plugins to be loaded as well as $logs
# $logs stores unparsed message lines in an array of length 100


$LOAD_PATH << './module'
require '.pluginf.rb'

class Karm < Pluginf
	
	def initialize(regex, name, help)
		@regexp = Regexp.new(regex)
		@name = name.to_s
		@help = help
		# set of nouns that are keys to an integer value
		@nouns = Hash.new

		if not File.exist?("./res/.karmaf") then
			`touch ./res/.karmaf` #if the karma file does not exist create it
		end
		
		load
	end


	#checks if the noun is in the hash
	def check_hash noun

	end

	#adds a noun to the hash with the value 0
	def add noun

	end

	#increments the value for the key noun
	def increment noun

	end

	#decrements the value for the key noun
	def decrement noun

	end

	#gets the value for the key noun
	def get noun

	end

	#run on any command besides `karma to update the file
	def update

	end

	#run on initialization to load the karma file
	def load

	end

	#your definition for script
	def script(message, nick, chan)
		@r = ""

		if message.match(/^`karma /)
			@r = "checking karma"
		elsif message.match(/^[^\s]+(\+\++|--+)/)
			@temp_n = message[0..-3]
			@incdec = message[-3..-1]

			if @incdec == "++"

			elsif @incdec == "--"

			else

			end
				
			@r = "changing karma for #{message[0..-3]}"
		end
			
		return @r
	end
end

prefixes = [
/^[^\s]+(\+\++|--+)/,
/^`karma /
]

reg_p = Regexp.union(prefixes) #regex to call the module
na = "karma" #name for plugin #same as file name without .rb
de = "recognizes noun++ and noun-- and `karma noun will give the karma for that noun" #description

#plugin = Class_name.new(regex, name, help)
#passed back to the plugins_s array
plugin = Karm.new(reg_p, na, de)
$plugins_s.push(plugin)