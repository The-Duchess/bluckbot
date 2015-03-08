#!/bin/env ruby
# template as defined by the required file
# author: apels <Alice Duchess>
# module as defined by plugin.rb



$LOAD_PATH << './module'
require '.pluginf.rb'

class Usage < Pluginf
	#any functions you may need

	#your definition for script
	def script(message, nick, chan)
		@r = "NOTICE #{chan} :commands: `join #\$CHAN joins #\$CHAN. \`list displays a list of loaded modules. `ls lists modules. `load $module.rb loads $module.rb\nnote:`load and `ls are admin only"
		return @r
	end
end

reg_p = /^`usage/ #regex to call the module
na = "use" #name for plugin #same as file name without .rb
de = "usage: `usage gives help" #description

#plugin = Class_name.new(regex, name, help)
#passed back to the plugins_s array
plugin = Usage.new(reg_p, na, de)
$plugins_s.push(plugin)
