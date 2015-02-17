#!/bin/env ruby
# template as defined by the required file
# author: apels <Alice Duchess>
# module as defined by plugin.rb



$LOAD_PATH << './module'
require '.pluginf.rb'

class PLUGIN < Pluginf
	#any functions you may need
	def send_p
=begin
			require 'socket'
			begin
				addr = ['<broadcast>', 9]
				UDPSock = UDPSocket.new
				UDPSock.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
				data = "\xFF\xFF\xFF\xFF\xFF\xFF"
				arr = ARGV[0].split(':')
				16.times do |i|
					data<< arr[0].hex.chr+arr[1].hex.chr+arr[2].hex.chr+arr[3].hex.chr+arr[4].hex.chr+arr[5].hex.chr
				end
				puts("Wake-On-Lan packet sent to MAC address "+ARGV[0])
				UDPSock.send(data, 0, addr[0], addr[1])
			rescue
				puts("usage: sample_wol.rb <mac-address>")
				puts(" sample_wol.rb 01:02:03:04:05:06")
			end 	
=end
	end

	#your definition for script
	def script(message, nick, chan)
		@r = ""

		return @r
	end
end

reg_p = // #regex to call the module
na = "" #name for plugin #same as file name without .rb
de = "" #description

#plugin = Class_name.new(regex, name, help)
#passed back to the plugins_s array
plugin = PLUGIN.new(reg_p, na, de)
$plugins_s.push(plugin)