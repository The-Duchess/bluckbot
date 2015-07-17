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

	def name
		return @topic_name
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

	def get_topic(name)
		temp_topic = nil

		@topics.length < 1 then return nil end

		@topics.each { |a| if a.name == name.to_s then return a end }

		return nil
	end

	def vote(nick, topic, choice)

		@topics.each do |a|
			if a.name == topic.to_s
				return a.vote(choice, nick)
			end
		end

		return false
	end

	def add_topic(name, choices)
		new_topic = Topic.new(name)

		choices.each { |a| new_topic.add_choice(a) }
	end

	def remove_topic(name)
		@topics.delete_if { |a| a.name == name.to_s }
	end

	def lock_vote(name)
		@topics.each do |a|
			if a.name == name.to_s
				a.lock_vote
				return
			end
		end
	end

	def unlock_vote(name)
		@topics.each do |a|
			if a.name == name.to_s
				a.unlock_vote
				return
			end
		end
	end

	# admin functions
	# `vote add topic: <topic> choices: <choices delimited by a space>
	# `vote lock topic
	# `vote unlock topic
	# general user functions
	# `vote topic choice
	# `vote list topics
	# `vote list choices topic
	# `vote list voters topic
	def script(message, nick, chan)

		response = ""
		tokens = message.split(" ")

		if tokens[1] == "add"
			# fuck this noise
		elsif tokens[1] == "lock"
			topic = ""
			1.upto(tokens.length - 1) { |a| topic.concat("#{a} ") }
			topic = topic[0..-2].to_s

			lock_vote(topic)
		elsif tokens[1] == "unlock"
			topic = ""
			1.upto(tokens.length - 1) { |a| topic.concat("#{a} ") }
			topic = topic[0..-2].to_s

			unlock_vote(topic)
		elsif tokens[1] == "list"
			# fuck this noise
		elsif tokens.length >= 3
			choice = tokens[tokens.length - 1].to_s
			topic = ""
			1.upto(tokens.length - 2) { |a| topic.concat("#{a} ") }
			topic = topic[0..-2].to_s

			if vote(nick, topic, choice) then response.concat("NOTICE #{nick} :your vote has been added") end

			response = "NOTICE #{nick} :unable to make vote"
		else
			response = "bad arguments"
		end

	end
end

reg_p = /^`vote / #regex to call the module
na = "vote" #name for plugin #same as file name without .rb
de = "admin functions\n  `vote add topic: <topic> choices: <choices delimited by a space>\n  `vote lock topic\n  `vote unlock topic\ngeneral user functions\n  `vote topic choice\n  `vote list topics\n  `vote list choices topic  \n`vote list voters topic"

plugin = Vote.new(reg_p, na, de)
$plugins_s.push(plugin)
