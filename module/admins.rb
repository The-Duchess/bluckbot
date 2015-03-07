#!/bin/env ruby
# template as defined by the required file
# author: apels <Alice Duchess>
# module as defined by .plugin.rb
# modules have access to $plugins to be loaded as well as $logs
# $logs stores unparsed message lines in an array of length 100


$LOAD_PATH << './module'
require '.pluginf.rb'

class PLUGIN < Pluginf
	#any functions you may need
	
	#reloads the file
	def load
		$admin_s = []

	   	File.open("./res/.admins", 'r') do |fr|
    		while line = fr.gets
    			line.chomp!
    			$admin_s.push(line.to_s)
    		end
    	end

    	return "admin file loaded"
	end

	#saves the file
	def save
		`echo "" > ./res/.admins`

	   	File.open("./res/.admins", 'w') do |fw|
	   		$admin_s.each do |fw_l|
	   			fw.write(fw_l.to_s)
	   		end
    	end

    	return "admin file saved"
	end

	#add to the list
	def add(nick_a)
		$admin_s.push(nick_a.to_s)
		return "#{nick_a} added to admin list"
	end

	#remove from the list
	def remove(nick_r)
		i = 0
		$admin_s.each do |a|
			if a == nick_r then break end
			i = i + 1
		end

		$admin_s.delete_at(i.to_i)
		return "#{nick_r} removed from admin list"
	end

	#your definition for script
	def script(message, nick, chan)
		#parse
		if !($admin_s.include? nick)
			return "#{nick} does not have access to this tool\nplease talk to an admin to be added to the admin list"
		end

		tokens = message.split(' ')
		@add_s = "add"
		@remove_s = "remove"
		@save_s = "save"
		@reload_s = "reload"

		if tokens[1].to_s == @add_s then
			@r = add(tokens[2].to_s)
		elsif tokens[1].to_s == @remove_s
			@r = remove(tokens[2].to_s)
		elsif tokens[1].to_s == @save_s
			@r = save
		elsif tokens[1].to_s == @reload_s
			@r = load
		else
			@r = "#{nick}: invalid use"
		end

		return @r
	end
end

reg_p = /^`admin / #regex to call the module
na = "admins" #name for plugin #same as file name without .rb
de = "`admin [add <nick> | remove <nick> | save  | reload ] to allow admins to add or remove other admins and update the list" #description

#plugin = Class_name.new(regex, name, help)
#passed back to the plugins_s array
plugin = PLUGIN.new(reg_p, na, de)
$plugins_s.push(plugin)