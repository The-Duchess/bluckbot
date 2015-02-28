#!/bin/env ruby
# template as defined by the required file
# author: apels <Alice Duchess>
# module as defined by .plugin.rb
# modules have access to $plugins to be loaded as well as $logs
# $logs stores unparsed message lines in an array of length 100


$LOAD_PATH << './module'
require '.pluginf.rb'

class Eightball < Pluginf
	#any functions you may need

	#your definition for script
	def script(message, nick, chan)
		responses = [ "It is certain", 
"It is decidedly so", 
"Without a doubt", 
"es definitely", 
"You may rely on it", 
"As I see it, yes", 
"Most likely", 
"Outlook good", 
"Yes", 
"Signs point to yes", 
"Reply hazy try again", 
"Ask again later", 
"Better not tell you now", 
"Cannot predict now", 
"Concentrate and ask again", 
"Don\'t count on it", 
"My reply is no", 
"My sources say no", 
"Outlook not so good", 
"Very doubtful" ]

		responses.shuffle!
		return "#{nick}: #{responses[0].to_s}"
	end
end

reg_p = /^bluckbot[:,]?\s?(.+)\?/ #regex to call the module
na = "eightball" #name for plugin #same as file name without .rb
de = "bluckbot: yes no question? will get an eightball style answer" #description

#plugin = Class_name.new(regex, name, help)
#passed back to the plugins_s array
plugin = Eightball.new(reg_p, na, de)
$plugins_s.push(plugin)
