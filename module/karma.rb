#!/bin/env ruby
# template as defined by the required file
# author: apels <Alice Duchess>
# module as defined by .plugin.rb
# modules have access to $plugins to be loaded as well as $logs
# $logs stores unparsed message lines in an array of length 100


$LOAD_PATH << './module'
require '.pluginf.rb'

class Karm < Pluginf
	
	def initialize(regex, name, help)
		@regexp = Regexp.new(regex)
		@name = name.to_s
		@help = help
		# set of nouns that are keys to an integer value
		@nouns = Hash.new
		# list of the current nouns
		@nouns_s = Array.new

		if not File.exist?("./res/.karmaf") then
			`touch ./res/.karmaf` #if the karma file does not exist create it
		end

		load
	end

	def cleanup
		update
	end

	#checks if the noun is in the hash
	def check_hash(noun)
		noun_a = noun
		if @nouns_s.include? noun_a then
			return true
		else
			return false
		end
	end

	#adds a noun to the hash with the value value
	def add(noun, value)
		noun_a = noun
		if @nouns_s.include? noun_a then return false end
		
		@nouns_s.push(noun_a.to_s)

		@nouns.store("#{noun_a}", value.to_i)

		return true
	end

	#increments the value for the key noun
	def increment(noun)
		noun_a = noun
		if @nouns_s.include? noun_a then
			temp_nv = @nouns["#{noun_a}"].to_i
			@nouns["#{noun_a}"] = temp_nv + 1

			return true
		else
			return false
		end

		return true
	end

	#decrements the value for the key noun
	def decrement(noun)
		noun_a = noun
		if @nouns_s.include? noun_a then
			temp_nv = @nouns["#{noun_a}"].to_i
			@nouns["#{noun_a}"] = temp_nv - 1

			return true
		else
			return false
		end

		return true
	end

	#gets the value for the key noun
	def get(noun)
		if @nouns_s.include? noun then
			return @nouns.fetch("#{noun}").to_i
		else
			return nil
		end

		return nil
	end

	# writes karma keys and value to update the file
	def update
		File.open("./res/.karmaf", 'w') do |fw|
			@nouns_s.each do |a|
				fw.write "#{a}\{#{@nouns.fetch(a)}\}"
			end
		end
	end

	#run on initialization to load the karma file
	def load
		File.open("./res/.karmaf", 'r') do |fr|
			while line = fr.gets
				line.chomp!
				line_toks = line.split("\{")
				add(line_toks[0].to_s, line_toks[1].to_s[0..-2].to_i)
			end
		end
	end

	#your definition for script
	def script(message, nick, chan)
		@r = ""

		if message.match(/^`karma /)

			#@r_s = get(message[7..-1])
			@tokens = message.split(' ')
			@r_s = get(tokens[1].to_s)

			if @r_s == nil
				@r = "object not found"
			else
				@r = "#{tokens[0]} has a karma of #{@r_s}"
			end

		elsif message.match(/[^\s]+(\+\++|--+)/)
			@temp_ns = message.match(/[^\s]+(\+\++|--+)/)
			@temp_n = @temp_ns.to_s[0..-3]
			@incdec = @temp_ns.to_s[-2..-1]

			if @temp_n == nick
				return "you cannot change your karma"
			end

			if @incdec == "++"
				if check_hash(@temp_n)
					increment(@temp_n)
				else
					add(@temp_n, 1)
				end

			elsif @incdec == "--"
				if check_hash(@temp_n)
					decrement(@temp_n)
				else
					add(@temp_n, -1)
				end

			else
				return @r
			end
		end
			
		return @r
	end
end

prefixes = [
/[^\s]+(\+\++|--+)/,
/^`karma /
]

reg_p = Regexp.union(prefixes) #regex to call the module
na = "karma" #name for plugin #same as file name without .rb
de = "recognizes noun++ and noun-- and `karma noun will give the karma for that noun" #description

#plugin = Class_name.new(regex, name, help)
#passed back to the plugins_s array
plugin = Karm.new(reg_p, na, de)
$plugins_s.push(plugin)
