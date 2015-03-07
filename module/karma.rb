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
	end


	#your definition for script
	def script(message, nick, chan)
		@r = ""

		if message.match(/^`karma /)
			#print karms
			@r = "checking karma"
		elsif message.match(/^[^\s]+(\+\++|--+)/)
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
na = "" #name for plugin #same as file name without .rb
de = "recognizes noun++ and noun-- and `karma noun will give the karma for that noun" #description

#plugin = Class_name.new(regex, name, help)
#passed back to the plugins_s array
plugin = Karm.new(reg_p, na, de)
$plugins_s.push(plugin)