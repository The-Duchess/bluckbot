#!/bin/env ruby
# template as defined by the required file
# author: apels <Alice Duchess>
# module as defined by plugin.rb



$LOAD_PATH << './module'
require '.pluginf.rb'

class Git_pull < Pluginf
	#any functions you may need

	#your definition for script
	def script(message, nick, chan)
		nick_l = ["apels","merdach","iruel"]
		if nick_l.include? nick
			p "nick [x]"
			r = `git pull`
			if r = "Already up-to-date." then 
				return r
			else 
				return "git pull run"
			end
		end
		p "this user is not permitted"
		return "#{nick} cannot access this tool"
	end
end

reg_p = /^`git pull/ #regex to call the module
na = "gitup" #name for plugin #same as file name without .rb
de = "`git pull updates the modules from the current repo" #description

#plugin = Class_name.new(regex, name, help)
#passed back to the plugins_s array
plugin = Git_pull.new(reg_p, na, de)
$plugins_s.push(plugin)