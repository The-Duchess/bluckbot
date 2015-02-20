#!/bin/env ruby
# template as defined by the required file
# author: apels <Alice Duchess>
# module as defined by .plugin.rb
# modules have access to $plugins to be loaded as well as $logs
# $logs stores unparsed message lines in an array of length 100


$LOAD_PATH << './module'
require '.pluginf.rb'

class Uptiamu < Pluginf
	#any functions you may need

	#your definition for script
	def script(message, nick, chan)
		@r = `uptime`
		return @r.to_s
	end
end

reg_p = /^`u$/ #regex to call the module
na = "uptime" #name for plugin #same as file name without .rb
de = "`u gives uptime" #description

#plugin = Class_name.new(regex, name, help)
#passed back to the plugins_s array
plugin = Uptaimu.new(reg_p, na, de)
$plugins_s.push(plugin)