#!/bin/env ruby
# template as defined by the required file
# author: apels <Alice Duchess>
# module as defined by plugin.rb



$LOAD_PATH << './module'
require '.pluginf.rb'

class Wget < Pluginf
	#any functions you may need

	#your definition for script
	def script(message, nick, chan)
		@r = "running wget"
		#p `wget #{message[6..-1]}`
		return @r
	end
end

reg_p = /^`wget / #regex to call the module
na = "wget" #name for plugin #same as file name without .rb
de = "an aministrator tool to add plugins" #description

#plugin = Class_name.new(regex, name, help)
#passed back to the plugins_s array
plugin = Wget.new(reg_p, na, de)
$plugins_s.push(plugin)