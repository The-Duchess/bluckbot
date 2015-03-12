#!/bin/env ruby
#
# module definition file
# all classes use the plugin class

class Pluginf

	def initialize(regex, name, help)
		@regexp = Regexp.new(regex.to_s)
		@name = name.to_s
		@help = help
		@chan_list = []
		@chan_list.push("any")
	end

	def

=begin
	def initialize(regex, name, help, chan)
		@regexp = Regexp.new(regex.to_s)
		@name = name.to_s
		@help = help
		@chan_list = []
		@chan_list.push("any")
		@chan_list.push(chan.to_s)
	end
=end

	def cleanup
		#used if you wish to save some information on exit
	end

	def script(message, nick, chan)
		
	end

	def regex
		return @regexp
	end

	def chans
		return @chan_list
	end

	def name
		return @name
	end

	def help
		return @help
	end

end