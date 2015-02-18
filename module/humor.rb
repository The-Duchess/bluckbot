#!/bin/env ruby
# template as defined by the required file
# author: apels <Alice Duchess>
# module as defined by .plugin.rb
# modules have access to $plugins to be loaded as well as $logs
# $logs stores unparsed message lines in an array of length 100


$LOAD_PATH << './module'
require '.pluginf.rb'

class Joke < Pluginf
	#any functions you may need
	def initialize(regex, name, help)
		@regexp = Regexp.new(regex.to_s)
		@name = name.to_s
		@help = help
		@jokes = Array.new
		load_j
	end

	def load_j
		File.open("./res/.jokes") do |fr|
			while line = fr.gets
				line.chomp!
				if @jokes.include? line
					next
				else
					@jokes.push(line.to_s)
				end
			end
		end

		p @jokes
	end

	def add(joke)
		@jokes.push(joke.to_s)
		system("echo \"#{joke}\" >> ./res/.jokes")
	end

	#your definition for script
	def script(message, nick, chan)
		if message != "`h"
			tokens = message.split(' ')
		else
			tokens = ["NULL", "NULL"]
		end

		if tokens[1] == "load" then
			load_j
			return "loaded"
		elsif tokens[1] == "add"
			temp = ""
			2.upto(tokens.length - 1) { |a| temp.concat("#{tokens[a]} ")}
			add(temp[0..-2])
			return "added"
		else
			@jokes.shuffle!
			begin
				return @jokes[0].to_s
			rescue => e
				return "no jokes loaded"
			end
		end

		return "failed"
	end
end

reg_p = /^`h/ #regex to call the module
na = "humor" #name for plugin #same as file name without .rb
de = "`h says a joke | `h load reloads the joke file | `h add adds" #description

#plugin = Class_name.new(regex, name, help)
#passed back to the plugins_s array
plugin = Joke.new(reg_p, na, de)
$plugins_s.push(plugin)