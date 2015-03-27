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

class Eightball < Pluginf
	#any functions you may need

	#your definition for script
	def script(message, nick, chan)

		return "string"
	end
end

# allows you to support multiple regexes
# prefix = [
#		//,
#		//
#	   ]
#
# reg_p = Regexp.union(prefix)

reg_p = /^bluckbot:*\?$/ #regex to call the module
na = "eightball" #name for plugin #same as file name without .rb
de = "bluckbot: your question? will be answered with an eightball response" #description

#plugin = Class_name.new(regex, name, help)
#pushed onto to the end of plugins array array
plugin = Eightball.new(reg_p, na, de)
$plugins_s.push(plugin)
