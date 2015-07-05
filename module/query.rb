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

class Query_s < Pluginf
	#any functions you may need
	def search(query_text, chan)
		results = Array.new

		length_l = $logs.length - 1

		1.upto(length_l) do |a|

			message_reg_s = $logs[a].match(/^(:(?<prefix>\S+) )?(?<command>\S+)( (?!:)(?<params>.+?))?( :(?<trail>.+))?$/)
			nick_s = message_reg_s[:prefix].to_s.split("!")[0]
			commands = message_reg_s[:command].to_s
			chan_s = message_reg_s[:params].to_s
			message_s = message_reg_s[:trail].to_s[0..-2]
			
			if message_s.match(/^ACTION /) or message_s.match(/^`query /) or chan_s != chan
				#skip
				next
			end
			
			if message_s.to_s.include? query_text or nick_s.to_s.include? query_text
				results.push("<#{nick_s}>: #{message_s}")
			end
		end

		return results
	end

	def select(results, query_text)
		choice = "results for : #{query_text}: #{results.length} Results:\n"
		range = results.length

		r = rand(range)

		choice.concat("#{results[r]}")

		return choice
	end

	#your definition for script
	def script(message, nick, chan)

		query_text  = message[7..-1]

		return select(search(query_text, chan), query_text)
	end
end

reg_p = /^`query / #regex to call the module
na = "query" #name for plugin #same as file name without .rb
de = "queries past messages for something someone said. NOTE: does not search actions" #description

#plugin = Class_name.new(regex, name, help)
#pushed onto to the end of plugins array array
plugin = Query_s.new(reg_p, na, de)
$plugins_s.push(plugin)
