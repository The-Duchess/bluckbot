#!/bin/env ruby
# youtube mod
# author: apels <Alice Duchess>
# module as defined by plugin.rb
# module to get youtube information

require 'socket'
require 'google/api_client'
require 'json'
require 'uri'
require 'net/http'
require 'multi_json'
require 'date'

$LOAD_PATH << './module'
require '.pluginf.rb'

class YouTube < Pluginf
	#any functions you may need

	#your definition for script
	def script(message, nick, chan)
		@r = ""
		video_n = message.split("=")[1].to_s
		response = "\x031,0You\x030,4Tube\x03 "
		result = Hash.new

		client = Google::APIClient.new
		youtube = client.discovered_api('youtube', 'v3')
		client.authorization = nil
		result = client.execute :key => "AIzaSyAg8UUsu7u4mf7UzKqIAMmBSoW2Ms50YZM", :api_method => youtube.videos.list, :parameters => {:id => "#{video_n}", :part => 'contentDetails,statistics,snippet'}
		result = JSON.parse(result.data.to_json)

		begin
			video_i = result.fetch('items')[0].fetch('snippet')
		rescue NoMethodError => e
			return "video could not be queried"
		end
		
		video_c = result.fetch('items')[0].fetch('contentDetails')
		video_s = result.fetch('items')[0].fetch('statistics')

		duration = video_c.fetch('duration').match(/^PT((?<hours>[0-9]+)H)?((?<minutes>[0-9]+)M)?((?<seconds>[0-9]+)S)?$/)
		duration = duration[:hours].to_i * 3600 + duration[:minutes].to_i * 60 + duration[:seconds].to_i
		durat = Time.at(duration).utc.strftime("%H:%M:%S")

		viewc = video_s.fetch('viewCount').to_s
		likes = video_s.fetch('likeCount').to_s
		dislikes = video_s.fetch('dislikeCount').to_s

		response.concat("\[\x032title:\x03 #{video_i.fetch('title').to_s}\] ")
		response.concat("\[\x032uploaded by:\x03 #{video_i.fetch('channelTitle').to_s}\] ")
		response.concat("\[\x032duration:\x03 #{durat}\] ")
		response.concat("\[\x032views:\x03 #{viewc}\] \[\x032likes:\x03 #{likes}\] \[\x032dislikes:\x03 #{dislikes}\]")

		description = video_i.fetch('description')[0..500].to_s.split("\n")
		des = ""
		description.each {|a| des.concat("#{a}\. ")}

		#response.concat(" \[description: #{des[0..69]}\.\.\.\]")


		#@r = response
		#return @r
		return response
	end
end

reg_p = /^(?:https?:\/\/)?(?:www\.)?youtu(?:\.be|be\.com)\/(?:watch\?v=)?([\w-]{10,})$/
na = "YouTube"
de = "catches youtube links"

#plugin = Class_name.new(regex, name, help)
#passed back to the plugins_s array
plugin = YouTube.new(reg_p, na, de)
$plugins_s.push(plugin)