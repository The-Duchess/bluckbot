#!/bin/env ruby
# template as defined by the required file
# author: apels <Alice Duchess>
# module as defined by plugin.rb

$LOAD_PATH << './module'
require '.pluginf.rb'

class Smiles_b < Pluginf
	#any functions you may need

	#your definition for script
	def script(message, nick, chan)
		@r_s = ["( \x0304◕\x03‿\x0304◕\x03)", "｡\x0304◕\x03‿\x0304◕\x03｡", "(づ｡\x0304◕\x03‿‿\x0304◕\x03｡)づ", "ヽ(' ▽' )ノ !", "(っ´ω｀)っ", "（ ￣ヮ￣）～♪", "（ ￣ヮ￣）～♫", "ヽ（＞ヮ＜）ノ", "(ﾉ ﾟ◡◡ﾟ)ﾉ☆", "( ﾟ◡◡ﾟ)", "(ﾉ\x0304◕\x03ヮ\x0304◕\x03)ﾉ*:･ﾟ✧", "\x0313♥\x03‿\x0313♥\x03", "(¬_¬)", "(づ￣ ³￣)づ", "◕‿↼", "(¬‿¬)"]
		@r_s.shuffle!
		return @r_s[0].to_s
	end
end

reg_p = /^`smile/ #regex to call the module
na = "smiles_b" #name for plugin #same as file name without .rb
de = "`smile shows a smile" #description

#plugin = Class_name.new(regex, name, help)
#passed back to the plugins_s array
plugin = Smiles_b.new(reg_p, na, de)
$plugins_s.push(plugin)