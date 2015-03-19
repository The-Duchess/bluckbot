#!/bin/env ruby
# template as defined by the required file
# author: apels <Alice Duchess>
# module as defined by .plugin.rb
# modules have access to $plugins to be loaded as well as $logs
# $logs stores unparsed message lines in an array of length 100


$LOAD_PATH << './module'
require '.pluginf.rb'

class Wikipedia < Pluginf

	def initialize(regex, name, help)
		@regexp = Regexp.new(regex.to_s)
		@name = name.to_s
		@help = help
		@chan_list = []
		@chan_list.push("any")

		#@previous_link = ""
		#@previous_search = []

		# these variables hold state (it is not saved) so that multiple users can
		# perform searches like they are were simultaneous

		# current active nicks
		@nick_list = []

		# {nick_1 => "link", ... , nick_n => "link"}
		# hash of nicks => links
		@previous_link = {}

		# {nick_1 => ["link_0",...,"link_n"], ..., nick_n => ["link_0",...,"link_n"]}
		# hash of nicks => array of links
		@previous_search = {}
	end

	def check_nick(nick)
		if @nick_list.include? nick
			return true
		end

		return false
	end

	def add_nick(nick)
		# push the nick to the list
		# this should be called along with set_prev_link NOTE: if no link then set to ""
		# this should be called along with set_prev_Search NOTE: if no search then set to []
		@nick_list.push(nick.to_s)
	end

	def set_prev_link(nick, link)
		#@previous_link = link
		p "link updated"
	end

	def set_prev_search(nick, arr)
		#@previous_search = []
		#@previous_search = arr
		p "search results updated"
	end
	
	def parse(message, nick, chan)

		# return message
		@r = ""

		# tokenize the message
		tokens = message.split(' ')
		cmd = tokens[0].to_s

		#########################################################################################################################################
		# NOTE: it may be more practical to PRIVMSG the user some of these bits of information
		#########################################################################################################################################

		if cmd =~ /^`wiki$/ # `wiki <link>
			# gets information if a valid wikipedia link
			# returns first message line length of characters and then the length
			# also sets previous link
			# also gives the user a link for the full page
		elsif cmd =~ /^`ws$/ # `ws show <search terms> | <search terms> | list | choose <number>
			# shows and stores search term options
			# allows the user to pick from search terms from previous search
			# if show is not specified it will choose the first of the search results and set the previous link
			# if previous search is not empty and choose is specified with a number then set previous link
			# the information for that link is then displayed like for `wiki and previous link is set
		elsif cmd =~ /^`wl$/ # `wl  show <location> | list
			# if show is specified along with a location a link will be handed to the user
			# with information for the page like `wiki
			# if list is specified the user will be given a list of sections
			# NOTE: it may be more practical to PRIVMSG the user some of these bits of information
			# NOTE: there is no concurency and any user can fuck up another user's previous_<link | search>
		else
			# we have a seriously problem
			return "we have a serious problem"
		end

	end

	# gets the information from a wikipedia link
	# returns an array of strings
	# ARR[0] = one line of content
	# ARR[1] = URL
	def wiki_link(link)

	end

	# gets search results and returns as an array of strings
	# strings are the links
	def wiki_search(terms_arr)

	end

	# gets wiki list options and returns as an array of strings
	# format is "[NAME]:[LINK]"
	def wiki_list(link)

	end

	#your definition for script
	def script(message, nick, chan)
		@r = parse(message, nick, chan)
		return @r
	end
end

prefix_s = [
			/^`wiki /,
			/^`ws /,
			/^`wl /
		   ]

reg_p = Regexp.union(prefix_s) #regex to call the module
na = "wikipedia" #name for plugin #same as file name without .rb
de = "`wiki <link> | `ws [show <search terms> | <search terms> | list | choose <number>] | `wl  [show <location in previous link> | list ]" #description

#plugin = Class_name.new(regex, name, help)
#passed back to the plugins_s array
plugin = Wikipedia.new(reg_p, na, de)
$plugins_s.push(plugin)