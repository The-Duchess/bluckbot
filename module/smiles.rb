#!/bin/env ruby
#
# module as defined by plugin.rb
# module to generate smiles

$LOAD_PATH << './module'
require '.pluginf.rb'

class Emote < Pluginf
	#any functions you may need

	#your definition for script
	def script(message, nick, chan)
		@r = ""

		@sides = ["()", "()", ""]
		@sides.shuffle!

		@eyes = ["◕◕", "^^", "ﾟﾟ", "''", "´`", "`'", "一一", "¬¬", "♥♥"]
		@eyes.shuffle!

		@arms = ["ﾉﾉ","づづ","ヽﾉ", "┐┌", ""]
		@arms.shuffle!

		@mouth = ["～", "‿", "‿‿", "‿", "_", "ω", "▽", "ヮ"]
		@mouth.shuffle!

		@cheeks = ["｡｡", "； ", " ；","","",""]
		@cheeks.shuffle!

		@item = ["*:･ﾟ✧", "", "", "", "", ""]
		@item.shuffle!

		if @arms[0].length !=0
			@r.concat(@arms[0].to_s[0])
		end

		if @sides[0].length !=0
			@r.concat(@sides[0].to_s[0])
		end

		if @cheeks[0].length !=0
			if @cheeks[0].to_s[0] != ' '
				@r.concat(@cheeks[0].to_s[0])
			end
		end

		@r.concat(@eyes[0][0])
		@r.concat(@mouth[0])
		@r.concat(@eyes[0][1])

		if @cheeks[0].length !=0
			if @cheeks[0].to_s[1] != ' '
				@r.concat(@cheeks[0].to_s[1])
			end
		end

		if @sides[0].length !=0
			@r.concat(@sides[0].to_s[1])
		end

		if @arms[0].length !=0
			@r.concat(@arms[0].to_s[1])
		end

		@r.concat(@item[0])

		return @r
	end
end

reg_p = /^`smile/
na = "smiles"
de = "`smile prints a smiley"

#plugin = Class_name.new(regex, name, help)
#passed back to the plugins_s array
plugin = Emote.new(reg_p, na, de)
$plugins_s.push(plugin)