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

class Bullshit < Pluginf
	
	def initialize(regex, name, help)
		@regexp = Regexp.new(regex.to_s)
		@name = name.to_s
		@help = help
		@chan_list = []
		@chan_list.push("any")

		@dict = [
					"cloud",
					"grid",
					"base",
					"engine",
					"metadata",
					"replication",
					"factory",
					"strategy",
					"configuration |",
					"information |",
					"interface",
					"singleton",
					"framework",
					"NoSQL |",
					"cache",
					"persistence |",
					"self-signing |",
					"scripting |",
					"template",
					"realtime |",
					"realtime-java |",
					"just-in-time |",
					"full-stack |",
					"API",
					"service",
					"event",
					"rails",
					"polling |",
					"injection |",
					"pipelining |",
					"firewall",
					"standard",
					"GPU |",
					"shader",
					"agile ^",
					"advanced ^",
					"leveraged ^",
					"extended ^",
					"basic ^",
					"core |",
					"hardware",
					"software",
					"database",
					"rich-client |",
					"DOM |",
					"CSS |",
					"CMS |",
					"STM |",
					"map/reduce |",
					"reduce/map |",
					"descriptor",
					"hypervisor",
					"callback |",
					"method",
					"table",
					"package",
					"plugin",
					"browser",
					"extension",
					"open-source ^",
					"module",
					"proxy",
					"hosting",
					"wrapper",
					"storage",
					"social ^",
					"private ^",
					"component",
					"markup",
					"lifecycle |",
					"flexible ^",
					"patented ^",
					"abstract ^",
					"stateless ^",
					"optimized ^",
					"virtualized ^",
					"extensible ^",
					"compliant ^",
					"scale-out ^",
					"session |",
					"content-driven |",
					"high-performance |",
					"general-purpose |",
					"out-scaling |",
					"generic ^",
					"mobile ^",
					"property |",
					"secure ^",
					"overflow-preventing ^",
					"non-blocking ^",
					"self-healing ^",
					"ISO-certified ^",
					"encrypted ^",
					"proven ^",
					"open ^",
					"RESTful ^",
					"content-addressed ^",
					"asynchronous ^",
					"object-oriented ^",
					"immutable ^",
					"anonymous ^",
					"transactional ^",
					"distributed ^",
					"structured ^",
					"managed ^",
					"webscale ^",
					"lossless ^",
					"virtual ^",
					"shared ^",
					"stable ^",
					"SQL *",
					"JSON *",
					"XML *",
					"YAML *",
					"XMPP *",
					"SOAP *",
					"HTML *",
					"AJAX *",
					"ORM *",
					"SVG *",
					"ACPI *",
					"WEB2.0 *",
					"SSL *",
					"HTTP *",
					"TOR *",
					"layer $",
					"element |",
					"manager $",
					"frontend $",
					"backend $",
					"control $",
					"controller $",
					"framework $",
					"database $",
					"generator $",
					"optimizer $",
					"interface $",
					"solution $",
					"dependency |",
					"locator $",
					"-oriented %",
					"-based %",
					"-aware %",
					"-scale %"
				]
	end

	def cleanup
		return ""
	end

	def min(a, b)
		if a > b then return b end

		return a
	end

	def asm

		types = 0
		r = ""

		@dict.each do |a| # select one of each type

			if types == 5
				break
			end

			token = a

			if token.include? " "
				tokens = token.split(" ")

				if tokens[1] == "*"

				elsif tokens[1] == "$"

				elsif tokens[1] == "%" # immdiately follows an intro

				elsif tokens[1] == "^"

				elsif tokens[1] == "|"

				else
					# the string is
				end
			else
				r.concat("#{token}")
			end
		end
	end

	def bs

	end

	#your definition for script
	def script(message, nick, chan)

		return "string"
	end
end

# allows you to support multiple regexes
# prefix = [
#		//,
#		//
#	   ]
#
# reg_p = Regexp.union(prefix)

reg_p = /^`bs$/ #regex to call the module
na = "bullshit" #name for plugin #same as file name without .rb
de = "`bs generates a bullshit tech sentence" #description

#plugin = Class_name.new(regex, name, help)
#pushed onto to the end of plugins array array
plugin = Bullshit.new(reg_p, na, de)
$plugins_s.push(plugin)
