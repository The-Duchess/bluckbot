#!/bin/env ruby
# template as defined by the required file
# author: apels <Alice Duchess>
# module as defined by plugin.rb



$LOAD_PATH << './module'
require '.pluginf.rb'

class Info < Pluginf
	#any functions you may need

	#your definition for script
	def script(message, nick, chan)
		@r = "NOTICE #{nick} :Bluckbot, current nick #{$nick_name} v1.5.5:\ndescription: bluckbot is a modular/plugable irc bot coded in ruby.\nhttps://github.com/The-Duchess/bluckbot\ncreated by lolth <Alice \"Duchess\" Archer>"
		return @r
	end
end

reg_p = /^`info$/ #regex to call the module
na = "info" #name for plugin #same as file name without .rb
de = "usage: `info gives information about bluckbot" #description

#plugin = Class_name.new(regex, name, help)
#passed back to the plugins_s array
plugin = Info.new(reg_p, na, de)
$plugins_s.push(plugin)
