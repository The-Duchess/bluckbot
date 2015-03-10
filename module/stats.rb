#!/bin/env ruby
# template as defined by the required file
# author: apels <Alice Duchess>
# module as defined by .plugin.rb
# modules have access to $plugins to be loaded as well as $logs
# $logs stores unparsed message lines in an array of length 100


$LOAD_PATH << './module'
require '.pluginf.rb'

class System < Pluginf
	
	def status
		#hostname
		host = `hostname`.to_s.chomp!
		#uptime
		uptime = `uptime -p`.to_s.chomp!
		#processes
		processes = `ps -ef | wc -l`.to_s.chomp!
		#memory
		percent_mem = `free | awk 'FNR == 3 {print $3/($3+$4)*100}'`.to_s.chomp!
		tokens = `free -m | grep -i "Mem:"`.split(' ')
		total_mem = tokens[1]
		used_mem = tokens[2]
		#load
		cpu_use = `top -bn1 | grep "Cpu(s)" | \
           sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | \
           awk '{print 100 - $1"%"}'`.to_s

        #Server Aika up 18d 01h 32m 43s, 675 TCP connections, 146 processes, 17.1GB/64GB RAM in use.
        return "Server \x0303#{host}\x03 #{uptime}, \x0303#{processes}\x03 Processes, \x0303#{percent_mem}\x03% | \x0304#{used_mem}\x03 of \x0303#{total_mem}\x03 MB of Memory Used, CPU utilization: \x0303#{cpu_use}\x03"
	end

	def info
		#hostname
		host = `hostname`.to_s.chomp!

		#OS
		#13 - 15
		tokens = `inxi -S`.split(' ')
		os = "#{tokens[12]} #{tokens[13]} #{tokens[14]}"
		#Kernel
		#token[5 and 6]
		kernel = "#{tokens[4]} #{tokens[5]}"
		#processor
		tokens_p = `inxi -C`.split(' ')
		processor = "#{tokens_p[1]} #{tokens_p[2]} #{tokens_p[3]} #{tokens_p[4]} @ #{tokens_p[13]}#{tokens_p[14]} : #{tokens_p[9]}#{tokens_p[10]} cache"
		
		return "\x0303#{host}\x03 : #{os} : #{kernel}\n#{processor}"

	end

	#your definition for script
	def script(message, nick, chan)
		token_i = message.split(' ')

		if token_i[1] == "status"
			return status
		elsif token_i[1] == "info"
			#return info
			return "not finished"
		else
			return "invalid input"
		end
		
	end
end

reg_p = /`sys / #regex to call the module
na = "stats" #name for plugin #same as file name without .rb
de = "`sys [status] | [info]" #description

#plugin = Class_name.new(regex, name, help)
#passed back to the plugins_s array
plugin = System.new(reg_p, na, de)
$plugins_s.push(plugin)