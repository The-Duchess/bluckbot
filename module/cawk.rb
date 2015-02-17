#!/bin/env ruby
#
# module as defined by plugin.rb

$LOAD_PATH << './module'
require '.pluginf.rb'

class Cawk < Pluginf
	#any functions you may need

	#your definition for script
	def script(message, nick, chan)
		@r = ""
		@r = "OH GOD YES HORSECAWK!!!!!"
		return @r
	end
end

reg_p = /^cawk$/
na = "cawk"
de = "prints a string when someone says cawk"

#plugin = Class_name.new(regex, name, help)
#passed back to the plugins_s array
plugin = Cawk.new(reg_p, na, de)
$plugins_s.push(plugin)