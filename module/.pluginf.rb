#!/bin/env ruby
#
# module definition file
# all classes use the plugin class

class Pluginf

	def initialize(regex, name, help)
		@regexp = Regexp.new(regex.to_s)
		@name = name.to_s
		@help = help
	end

	def cleanup
		#used if you wish to save some information on exit
	end

	def script(message, nick, chan)
		
	end

	def regex
		return @regexp
	end

	def name
		return @name
	end

	def help
		return @help
	end

end