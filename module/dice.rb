#!/bin/env ruby
# dice roll
# author: apels <Alice Duchess>
# module as defined by plugin.rb
# module to do dice roll


$LOAD_PATH << './module'
require '.pluginf.rb'

class Dice < Pluginf
	#any functions you may need

	#your definition for script
	def script(message, nick, chan)
		@r = ""
		@r = "not completed"
		return @r
	end
end

reg_p = /^`roll \d\dD\d\d\d/
na = "Dice" #name for plugin #same as file name without .rb
de = "rolls dice"#description

#plugin = Class_name.new(regex, name, help)
#passed back to the plugins_s array
plugin = Dice.new(reg_p, na, de)
$plugins_s.push(plugin)