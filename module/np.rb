#!/bin/env ruby
# template as defined by the required file
# author: apels <Alice Duchess>
# module as defined by plugin.rb



$LOAD_PATH << './module'
require '.pluginf.rb'

class NP < Pluginf
	#any functions you may need

	#your definition for script
	def script(message, nick, chan)
		@r = ""
		@np_a = `banshee --no-present --query-artist`.to_s[0..-2]
		@np_s = `banshee --no-present --query-title`.to_s[0..-2]
		@np_al = `banshee --no-present --query-album`.to_s[0..-2]
		@np_p = `banshee --no-present --query-position`.to_s[0..-2]
		@np_p = Time.at(@np_p.split("\.")[0].split(": ")[1].to_i).utc.strftime("%M:%S")
		@r = "\[#{@np_s}\] \[#{@np_a}\] \[#{@np_al}\] \[position: #{@np_p}\]"

		return @r
	end
end

reg_p = /^`np/
na = "NP" #name for plugin #same as file name without .rb
de = "gets banshee now playing info"#description

#plugin = Class_name.new(regex, name, help)
#passed back to the plugins_s array
plugin = NP.new(reg_p, na, de)
$plugins_s.push(plugin)