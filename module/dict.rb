#!/bin/env ruby
# template as defined by the required file
# author: apels <Alice Duchess>
# module as defined by plugin.rb
# dict allows people to add descriptions to a given object
# dict stores and array of keys and a hash table of keys to an array of descriptions
# `dict add <object> is <description> will add an entry for the key <object>
# `dict show <object> will print all entries for the key <object>


$LOAD_PATH << './module'
require '.pluginf.rb'

class Dict < Pluginf

	def finalize
		p save
	end
	
	#adds a description to the key object
	#if the key does not exist then add it to the hash and the array
	def add(object, description)
		#p "object: #{object}"
		#p "description: #{description}"
		#@keys.each { |a| p a }
		if @keys.include? object
			@dict["#{object}"].push(description) #broken
		else
			@dict.store("#{object}", ["#{description}"])
			@keys.push(object)
		end

		#this is an example of why we hate file IO, over time this will progressively get worse until adding is next to impossible
		#p save
		#p "echo '#{object}:#{description}' >> /run/media/alice/HORSECAWK/.dict"
		#system("echo '#{object}:#{description}' >> ./res/.dict")
		File.open("./res/.quotes", mode: 'a') { |fw| fw.puts "#{object}:#{description}" }

		return "added"
	end

	#returns a string with the descriptions for object
	#returns and empty string if the key does not exist
	def show(object)
		if @keys.include? object
			@temp = "#{object}: "
			@temp_a = Array.new
			@temp_a = @dict.fetch("#{object}")
			#p @temp_a.class.to_s
			#p @dict.to_s
			if @temp_a.class.to_s.downcase != "array"
				return "#{object} not found"
			end
			if @temp_a.length == 0
				return "no entries"
			end
			@temp_a.each { |a| @temp.concat("#{a}, ")}
			return @temp[0..-3]
		else
			return ""
		end
	end

	#parses message and returns an appropriate string
	def parse(message)
		symbols = message.split(' ')

		if symbols[0] == "add" then
			object = symbols[1]
			description = ""

			if symbols[2] != "is"
				return "invalid use"
			end

			3.upto(symbols.length - 1) do |a|
				description.concat("#{symbols[a]} ")
			end

			return add(object, description[0..-2])

		elsif symbols[0] == "show"
			if symbols.length == 1
				return "invalid use"
			end

			return show(symbols[1])

		elsif symbols[0] == "save"
			return save

		elsif symbols[0] == "load"
			#return load
			return "called when module is loaded, users do not need to use"
		else
			return "#{symbols[0]} is an invalid command for dict"
		end
	end

	#saves the current entries to a file
	def save
		File.open("./res/.dict", 'w') do |fw|
			temp = ""
			@keys.each do |a|
				p a
				@dict.fetch("#{a}").each { |b| p "THIS IS b: #{b}"; temp.concat("#{b.chomp}"); temp.concat(", ")}
				temp = temp[0..-3]
				p temp
				if temp.length != 0
					fw.puts "#{a}:#{temp}"
				end
				temp = ""
			end
		end
		return "saved"
	end

	#loads the current entries from a file
	def load

		File.open("./res/.dict", 'r') do |fr|
			while line = fr.gets
				line = line.chomp
				#apels: making bluckbot break in new and bizzare ways
				object_t = line.split(":")[0].to_s
				description_st = line.split(":")[1].to_s
				description_s = []
				if description_st.include? ","
					description_s = description_st.split(", ")
				else
					p "BEFORE ADD"
					#add(object_t, description_st)
					if @keys.include? object_t
						@dict["#{object_t}"].push(description_st) #broken
					else
						@dict.store("#{object_t}", ["#{description_st}"])
						@keys.push(object_t)
					end
					next
				end
				p description_s
				description_s.each do |a|
					a = a.chomp
					p "BEFORE ADD"
					#add(object_t, a)
					if @keys.include? object_t
						@dict["#{object_t}"].push(a.to_s) #broken
					else
						@dict.store("#{object_t}", ["#{a.to_s}"])
						@keys.push(object_t)
					end
				end
			end
		end

		return "loaded"
	end

	#your definition for script
	def script(message, nick, chan)
		message = message[6..-1] #remove `dict from the string
		message.delete! ':`,'
		@r = parse(message)

		return @r
	end

	def initialize(regex, name, help)
		@regexp = Regexp.new(regex.to_s)
		@name = name.to_s
		@help = help
		@keys = Array.new
		@dict = Hash.new(0)
		load
		#ObjectSpace.define_finalizer(self, Dict.method(:save))
	end
end

reg_p = /^`dict / #regex to call the module
na = "dict" #name for plugin #same as file name without .rb
de = "`dict [add <object> is <description>] | [show <object>] | [save] | [load]" #description

#plugin = Class_name.new(regex, name, help)
#passed back to the plugins_s array
plugin = Dict.new(reg_p, na, de)
$plugins_s.push(plugin)
