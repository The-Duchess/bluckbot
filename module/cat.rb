#!/bin/env ruby
#
# module as defined by plugin.rb
# module to print cat

$LOAD_PATH << './module'
require '.pluginf.rb'

class Katzen < Pluginf
	#any functions you may need

	#your definition for script
	def script(message, nick, chan)
		@r = ""
		@r = "~( ^^)"
		return @r
	end
end

reg_p = /^`cat/
na = "cat"
de = "`cat prints a cat"

#plugin = Class_name.new(regex, name, help)
#passed back to the plugins_s array
plugin = Katzen.new(reg_p, na, de)
$plugins_s.push(plugin)