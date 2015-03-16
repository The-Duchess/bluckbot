#!/bin/env ruby
# template as defined by the required file
# author: apels <Alice Duchess>
# module as defined by plugin.rb

require 'net/http'
require 'optparse'
require 'open-uri'
require 'json'

$LOAD_PATH << './module'
require '.pluginf.rb'

class Weather < Pluginf

	def initialize(regex, name, help)
		@regexp = Regexp.new(regex.to_s)
		@name = name.to_s
		@help = help
		@chan_list = []
		@chan_list.push("any")

		# Weather user hash and array
		@users = Hash.new
		@users_s = Array.new

		if not File.exist?("./res/.weather") then
			`touch ./res/.weather` #if the user list file does not exist then create it
		end

		p load_users
	end
	
	def add_user(nick, ac_t)
		#@dict.store("#{object}", ["#{description}"])
		@users_s.push(nick.to_s)
		@users.store(nick.to_s, ac_t.to_s)

		return "added"
	end

	def update_user(nick, ac_t)
		@users[:nick] = ac_t.to_s
		return "updated"
	end

	def check_user(nick)
		if @users_s.include? nick then return true end

		return false
	end

	def cleanup
		# perform cleanup if module is going to be removed
		save_users
	end

	def save_users
		# Write out users to file
		File.open("./res/.weather", 'w') do |fw|
			@users_s.each do |a|
				fw.puts("#{a}:#{@users.fetch(a)}\n")
			end
		end

		return "saved"
	end

	def load_users
		# Read users from file
		File.open("./res/.weather", 'r') do |fr|
			while line = fr.gets
				line.chomp!
				# file format
				# nick:area code
				tokens = line.split(':')
				nick_t = tokens[0]
				area_c = tokens[1] # area code will always have any spaces removed before being saved
				@users_s.push(nick_t.to_s)
				@users.store(nick_t.to_s, area_c.to_s)
			end
		end

		return "loaded"
	end

	def weatherc(c)
		wc = Hash.new

		wc = {200 => "thunderstorm with light rain", 201 => "thunderstorm with rain", 202 => "thunderstorm with heavy rain", 210 => "light thunderstorm", 211 => "thunderstorm", 212 => "heavy thunderstorm", 221 => "ragged thunderstorm", 230 => "thunderstorm with light drizzle", 231 => "thunderstorm with drizzle", 231 => "thunderstorm with heavy drizzle", 300 => "light intensity drizzle", 301 => "drizzle", 302 => "heavy intensity drizzle", 310 => "light intensity drizzle rain", 311 => "drizzle rain", 312 => "heavy intensity drizzle rain", 313 => "shower rain and drizzle", 314 => "heavy shower rain and drizzle", 321 => "shower drizzle", 500 => "light rain", 501 => "moderate rain", 502 => "heavy intensity rain", 503 => "very heavy rain", 504 => "extreme rain", 511 => "freezing rain", 520 => "light intensity shower rain", 521 => "shower rain", 522 => "heavy intensity shower rain", 531 => "ragged shower rain", 600 => "light snow", 601 => "snow", 602 => "heavy snow", 611 => "sleet", 612 => "shower sleet", 615 => "light rain and snow", 616 => "rain and snow", 620 => "light shower snow", 621 => "shower snow", 622 => "heavy shower snow",701 => "mist", 711 => "smoke", 721 => "haze", 731 => "sand, dust. whirls", 741 => "fog", 751 => "sand", 761 => "dust", 762 => "volcanic ash", 771 => "squalls", 781 => "tornado", 800 => "clear sky", 801 => "few clouds", 802 => "scattered clouds", 803 => "broken clouds", 804 => "overcast clouds", 900 => "tornado", 901 => "tropical storm", 902 => "hurricane", 903 => "cold", 904 => "hot", 905 => "windy", 906 => "hail", 951 => "calm", 952 => "light breeze", 953 => "gentle breeze", 954 => "moderate breeze", 955 => "fresh breeze", 956 => "strong breeze", 957 => "high wind, near gale", 958 => "gale", 959 => "severe gale", 960 => "storm", 961 => "violent storm", 962 => "hurricane"}

		return wc.fetch(c.to_i).to_s
	end

	def get_weather(area_code)

		@r_w = ""
		@ac = area_code

		url = "http://api.openweathermap.org/data/2.5/weather?q=#{@ac}&mode=json&units=imperial"
		url_m = "http://api.openweathermap.org/data/2.5/weather?q=#{@ac}&mode=json&units=metric"

		begin
			@contents = open(url).read
		rescue => a
			return "is this place actually real?"
		end

		begin
			@contents_m = open(url_m).read
		rescue => a
			return "is this place actually real?"
		end

		contents = open(url).read
		contents_m = open(url_m).read
		parsed_json = JSON.parse(contents)
		parsed_json_m = JSON.parse(contents_m)
		if parsed_json['main'].nil?
			@r_w = "is this place actually real?"
		elsif weather_in_f = (parsed_json['main']['temp']).to_i
			begin
				weather_in_c = (parsed_json_m['main']['temp']).to_i
			rescue NoMethodError => e
				return "is this place actually real?"
			end
			humidity = parsed_json['main']['humidity']
			weathercode = weatherc("#{parsed_json['weather'][0]['id']}")
			@r_w.concat("Weather of \x0304#{message[3..-1].to_s}:\x03 #{weathercode} at \x0302#{weather_in_f}°F\x03 or \x0302#{weather_in_c}°C\x03 and winds at \x0311#{parsed_json['wind']['speed']} mph\x03")
		end

		return @r_w	
	end

	def get_ac(nick)
		begin
			return @users.fetch(nick)
		rescue => e
			return "nick not found"
		end
	end

	def parse(message, nick, chan)
		tokens = message.split(' ')
		cmd = tokens[0] # the command the user is calling [ `w <area code | nick> | `ws <area code> ]
		@r = "#{nick}: "

		if cmd == "`w" # getting weather for nick or an area code if tokens[1] != nick
			if tokens[1] == nick and tokens.length == 2
				if check_user(nick)
					ac_t = get_ac(nick)
					@r.concat(get_weather(ac_t).to_s)
					return @r
				else
					return "entry for #{tokens[1]} not found"
				end
			elsif tokens[1] != nick and tokens.length == 3
				ac_t = ""
				if tokens.length > 2
					1.upto(tokens.length - 1) do |i|
						ac_t.concat("#{i}")
					end
				else
					ac_t = tokens[1]
				end
				@r.concat(get_weather(ac_t).to_s)
			else
				return "invalid arguments"
			end
		elsif cmd == "`ws" # sets the weather information for nick
			if not tokens.length > 1
				return "invalid arguments"
			end

			if not check_user(tokens[0])
				ac_t = ""
				if tokens.length > 2
					1.upto(tokens.length - 1) do |i|
						ac_t.concat("#{i}")
					end
				else
					ac_t = tokens[1]
				end

				return add_user(tokens[0], ac_t)
			else
				ac_t = ""
				if tokens.length > 2
					1.upto(tokens.length - 1) do |i|
						ac_t.concat("#{i}")
					end
				else
					ac_t = tokens[1]
				end

				return update_user(tokens[0], ac_t)
			end
		else
			# we have a major problem
			return "gottverdammt"
		end
		
		return @r
	end

	#your definition for script
	def script(message, nick, chan)
		return parse(message, nick, chan)
	end
end

prefix_s = [
		/^`ws /,
		/^`w /
	     ]

reg_p = Regexp.union(prefix_s) #regex to call the module
na = "weather" #name for plugin #same as file name without .rb
de = "usage: `w areacode or City, State | `ws <nick> <areacode>" #description

#plugin = Class_name.new(regex, name, help)
#passed back to the plugins_s array
plugin = Weather.new(reg_p, na, de)
$plugins_s.push(plugin)