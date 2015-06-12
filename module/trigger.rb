#!/bin/env ruby
#############################################################################################
# author: apels <Alice Duchess>
# module as defined by .plugin.rb
#############################################################################################
# GLOBALS:
# - $logs are stored like [most recent - least recent], they are also unparsed
# - $admins is the list of admins
# - $plugins_s is the array of active plugins
#############################################################################################


$LOAD_PATH << './module'
require '.pluginf.rb'

class Triggered < Pluginf
	
	def initialize(regex, name, help)
		@regexp = Regexp.new(regex.to_s)
		@name = name.to_s
		@help = help
		@chan_list = []
		@chan_list.push("any")

		@prefix = [
					/^`trigger /,
					/^`trigger list$/,
					/^trigger remove /
				 ]

		@prefix_print = [
							nil, # so that the primary trigger won't cause any issues with indeces
							nil, # so that the list trigger won't cause any issues with indeces
							nil, # so that the remove trigger won't cause any issues with indeces
						 ]

		if not File.exist?("./res/.triggered") then
			`touch ./res/.triggered`
		end

		load
	end

	def cleanup

		save
	end

	def load
		# the format for storing regexs and the corrosponding print message is
		# regex _:_ message

		File.open("./res/.triggered", "r") do |fr|
			while line = fr.gets
				line = line.chomp!
				tokens = line.split(" _:_ ")
				add(tokens[0], tokens[1])
			end
		end

	end

	def save
		File.open("./res/.triggered", "w") do |fw|
			3.upto(@prefix.length.to_i - 1) do |i|
				fw.puts "#{@prefix[i].to_s} _:_ #{@prefix_print[i]}"
			end
		end
	end

	def add(regex, print_msg)
		@prefix.push(Regexp.new(regex))
		@prefix_print.push(print_msg.to_s)

		@regexp = Regexp.union(@prefix)
	end

	def list(nick)

		r = "NOTICE #{nick} :"
		ii = 1

		3.upto(@prefix.length - 1) do |i|
			r.concat("[#{ii}]: regex: [#{@prefix[i]}] shows: [#{@prefix_print[i]}]\n")
			ii = ii + 1
		end

		return r
	end

	def remove(index)
		if index < 1 then return "cannot remove" end

		ii = index + 2
		@prefix.delete_at(ii)
		@prefix_print.delete_at(ii)

		@regexp = Regexp.union(@prefix)

		return "removed"
	end

	#your definition for script
	def script(message, nick, chan)

		tokens = message.split(" ")
		passed_add = false
		passed_shows = false

		message_index_end = tokens.length - 1
		regex_str = ""
		message_str = ""

		if message.match(/^`trigger /) and tokens.include? "add:" and tokens.include? "shows:"
			# add
			add_i = tokens.index("add:")
			shows_i = tokens.index("shows:")
			(add_i + 1).upto(shows_i - 1) do |i|
				regex_str.concat("#{tokens[i]} ")
			end
			regex_str = regex_str[0..-2].to_s
			(shows_i + 1).upto(tokens.length - 1) do |i|
				message_str.concat("#{tokens[i]} ")
			end
			message_str = message_str[0..-2].to_s

			add(regex_str, message_str)

			return "added"
		elsif message.match(/^`trigger list$/)
			return list(nick)
		elsif message.match(/^`trigger remove /)
			return remove(tokens[2].to_i)
		else
			if message.match(@regexp) and !message.match(/^`trigger/)
				# find a trigger
				1.upto(@prefix.length - 1) do |i|
					if message.match(@prefix[i])
						return "#{@prefix_print[i]}"
					end
				end
			end
		end

		return ""
	end
end

# allows you to support multiple regexes
# prefix = [
#		//,
#		//
#	   ]
#
# reg_p = Regexp.union(prefix)

reg_p = /^`trigger / #regex to call the module
na = "trigger" #name for plugin #same as file name without .rb
de = "`trigger (add: <regex> shows: <message> | list | remove <index given by list> )" #description

#plugin = Class_name.new(regex, name, help)
#pushed onto to the end of plugins array array
plugin = Triggered.new(reg_p, na, de)
$plugins_s.push(plugin)
