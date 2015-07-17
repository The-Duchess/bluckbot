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

class Topic
	def initialize(name)
		@topic_name = name.to_s
		@topic_choices = []
		@topic_values = {}
		@voter_names = []
		@locked = false
	end

	def lock
		@locked = true
	end

	def unlock
		@locked = false
	end

	def add_choice(choice)

		if @locked then return end

		@topic_values.store(choice.to_s, 0)
		@topic_choices.push(choice.to_s)
	end

	def vote(choice, name)

		if @locked then return false end

		if @voter_names.include? name.to_s then return false end

		@topic_values["#{choice}"] += 1
		@voter_names.push(name.to_s)

		return true
	end

	def get_choices
		return @topic_choices
	end

	def get_value(choice)
		if !@topic_choices.include? choice then return nil

		return @topic_values["#{choice}"]
	end

	def get_all_values
		arr = []
		@topic_choices.each { |a| arr.push(@topic_values["#{a}"]) }

		return arr
	end

	def get_voters
		return @voter_names
	end
end

class Vote < Pluginf

	def initialize(regex, name, help)
		@regexp = Regexp.new(regex.to_s)
		@name = name.to_s
		@help = help
		@chan_list = []
		@chan_list.push("any")

		@topics = []
	end

	def vote(nick, topic, choice)

	end

	def add_topic(name, choices)

	end

	def remove_topic(name)

	end

	def lock_vote(name)

	end

	def unlock_vote(name)

	end

	# admin functions
	# `vote add topic choices
	# 	- add topic: <topic> choices: <choices delimited by a space>
	# `vote lock topic
	# `vote unlock topic
	# general user functions
	# `vote topic choice
	# `vote list topics
	# `vote list choices topic
	# `vote list voters topic
	def script(message, nick, chan)
		response = ""

	end
end

reg_p = /^`vote / #regex to call the module
na = "vote" #name for plugin #same as file name without .rb
de = "admin functions\n  `vote add topic: <topic> choices: <choices delimited by a space>\n  `vote lock topic\n  `vote unlock topic\ngeneral user functions\n  `vote topic choice\n  `vote list topics\n  `vote list choices topic  \n`vote list voters topic"

plugin = Vote.new(reg_p, na, de)
$plugins_s.push(plugin)
