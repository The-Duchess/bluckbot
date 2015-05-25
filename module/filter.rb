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

class Wrdfltr < Pluginf
	#any functions you may need
	def initialize(regex, name, help)
		@regexp = Regexp.new(regex.to_s)
		@name = name.to_s
		@help = help
		@chan_list = []
		@chan_list.push("any")

		# prefix to be detected
		@prefix = [
					/^`fl /,
				  ]

		# prefix for replacement word
		@prefix_r = [
						//,
					]

		# id
		@prefix_id = [
						"default",
					 ]

		# purpose
		@prefix_pr = [
						"default",
					 ]
	end

	# adds a word filter
	# generates the id as the word to be replaced
	# words to be replaced cannot have multiple entries
	def append_regexp(new_filter)

		# new_filter should look like
		# $word with $other_word
		# $word -> id
		# $word -> @prefix
		# $other_word -> @prefix_r

		# length of 3 since phrases are not supported
		tokens = new_filter.split(" ")

		@prefix.push(Regexp.new(tokens[0]))
		@prefix_r.push(tokens[2])
		@prefix_id.push(tokens[0])
		@prefix_pr.push("replace #{new_filter}")

		# regenerate @regexp
		@regexp = Regexp.union(@prefix)

		return "#{new_filter}: appended"

	end

	# removes a word filter by id
	# if the id is not in the @prefix_id array it will not be removed
	# default cannot be removed
	def remove_regexp(id)
		if not @prefix_id.include? id or id == "default"
			return "invalid option"
		end

		index = 0

		@prefix_id.each do |a|
			if id == a
				break
			end

			index = index + 1
		end

		@prefix.delete_at(index)
		@prefix_r.delete_at(index)
		@prefix_id.delete_at(index)
		@prefix_pr.delete_at(index)

		return "#{id}: removed"

	end

	# saves current filters on exit
	def save
		puts "save feature not implemented"
		return ""
	end

	# loads current filters on load
	def load
		puts "load feature not implemented"
		return ""
	end

	# saves current filters on exit
	def cleanup
		save
		return ""
	end

	# returns all existing filters
	def get_filters
		return "this feature will be included when you pay EA an inordinant ammount of money"
	end

	# do the search replace on the message
	def sed(message, nick)

		ii = 0

		# duplicate for preservation of the original
		# ruby does not pass by value
		new_message = message

		@prefix.each do |a|

			if new_message.match(a)
				# then do a replace
				new_message.gsub! @prefix_id[ii].to_s, @prefix_r[ii].to_s
			end

			ii = ii + 1
		end

		return new_message

	end

	#your definition for script
	def script(message, nick, chan)
		
		if nick == $nick_name or message.length.to_i == 4
			return ""
		end

		@r = ""

		tokens = message.split(" ")

		if tokens[0].match(/^`fl$/)
			# replace, list, remove
			if tokens[1] == "replace"

				new_filter = ""
				2.upto(@tokens.length - 1) do { |a| new_filter.concat("#{a} ") }
				new_filter = new_filter[0..-1].to_s
				@r = append_regexp(new_filter)

			elsif tokens[1] == "list" and tokens.length == 2
				return "work in progress"
			elsif tokens[1] == "remove" and tokens.length == 3
				return "work in progress"
			else
				return "You have failed"
			end

		else
			# do a sed
			sed(message, nick)
		end

		return ""
	end
end

reg_p = /^`fl / #regex to call the module
na = "template" #name for plugin #same as file name without .rb
de = "`fl [replace $word with $other_word] | [list] | [remove $id]" #description

#plugin = Class_name.new(regex, name, help)
#pushed onto to the end of plugins array array
plugin = Wrdfltr.new(reg_p, na, de)
$plugins_s.push(plugin)
