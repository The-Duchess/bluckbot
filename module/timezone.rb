#!/bin/env ruby
# template as defined by the required file
# author: apels <Alice Duchess>
# module as defined by .plugin.rb
#
# this plugin allows people to get timezone information from a City in a state or country


$LOAD_PATH << './module'
require '.pluginf.rb'

class TimeZone < Pluginf
	
	#parses the input and calls the appropriate functions and returns the info to script
	def parse message nick chan
		tokens = message.split(' ')
	end

	#returns an array of the timezone and the local time stored as strings
	def get_timezone city state_country

	end

	#your definition for script
	def script message nick chan

	end
end

reg_p = /`tz / #regex to call the module
na = "timezone" #name for plugin #same as file name without .rb
de = "`tz CITY, STATE | COUNTRY gives the timezone of the CITY and the local time in that city" #description

#plugin = Class_name.new(regex, name, help)
#passed back to the plugins_s array
plugin = PLUGIN.new(reg_p, na, de)
$plugins_s.push(plugin)