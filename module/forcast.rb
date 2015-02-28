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
	
	#gets weather code
	def weatherc(c)
		wc = Hash.new

		wc = {200 => "thunderstorm with light rain", 201 => "thunderstorm with rain", 202 => "thunderstorm with heavy rain", 210 => "light thunderstorm", 211 => "thunderstorm", 212 => "heavy thunderstorm", 221 => "ragged thunderstorm", 230 => "thunderstorm with light drizzle", 231 => "thunderstorm with drizzle", 231 => "thunderstorm with heavy drizzle", 300 => "light intensity drizzle", 301 => "drizzle", 302 => "heavy intensity drizzle", 310 => "light intensity drizzle rain", 311 => "drizzle rain", 312 => "heavy intensity drizzle rain", 313 => "shower rain and drizzle", 314 => "heavy shower rain and drizzle", 321 => "shower drizzle", 500 => "light rain", 501 => "moderate rain", 502 => "heavy intensity rain", 503 => "very heavy rain", 504 => "extreme rain", 511 => "freezing rain", 520 => "light intensity shower rain", 521 => "shower rain", 522 => "heavy intensity shower rain", 531 => "ragged shower rain", 600 => "light snow", 601 => "snow", 602 => "heavy snow", 611 => "sleet", 612 => "shower sleet", 615 => "light rain and snow", 616 => "rain and snow", 620 => "light shower snow", 621 => "shower snow", 622 => "heavy shower snow",701 => "mist", 711 => "smoke", 721 => "haze", 731 => "sand, dust. whirls", 741 => "fog", 751 => "sand", 761 => "dust", 762 => "volcanic ash", 771 => "squalls", 781 => "tornado", 800 => "clear sky", 801 => "few clouds", 802 => "scattered clouds", 803 => "broken clouds", 804 => "overcast clouds", 900 => "tornado", 901 => "tropical storm", 902 => "hurricane", 903 => "cold", 904 => "hot", 905 => "windy", 906 => "hail", 951 => "calm", 952 => "light breeze", 953 => "gentle breeze", 954 => "moderate breeze", 955 => "fresh breeze", 956 => "strong breeze", 957 => "high wind, near gale", 958 => "gale", 959 => "severe gale", 960 => "storm", 961 => "violent storm", 962 => "hurricane"}

		return wc.fetch(c.to_i).to_s

	end

	def hourly(url, url_m)

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

		#show forcast from morning of day to evening in 4 blocks
		@hours = [800, 1200, 1800, 2200]
		@hours_s = ["8AM", "12PM", "6PM", "10PM"]

		if parsed_json['main'].nil?
			return "is this place actually real?"
		elsif 

		end
			

	end

	def weekly(url, url_m) #return days seperated by "\n"

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
			return "is this place actually real?"
		elsif 

		end

	end

	#your definition for script
	def script(message, nick, chan)

		tokens = message.split(' ')
		
		@r = ""

		@ac = ""
		@url = ""
		@url_m = ""

		#hourly forcast for today
		if tokens[1] == "h"
			#@url = tokens[2]
			@ac.concat("#{tokens[2]}")
			@ac.concat("#{tokens[3]}")
			@url = "http://api.openweathermap.org/data/2.5/forcast?q=#{@ac}&mode=json&units=imperial"
			@url_m = "http://api.openweathermap.org/data/2.5/forcast?q=#{@ac}&mode=json&units=metric"
			@r  = hourly(@url, @url_m)
		#forcast for the next four days
		#this is pmed to the person who makes the query
		elsif tokens[1] == "w"
			#@url = tokens[2]
			@ac.concat("#{tokens[2]}")
			@ac.concat("#{tokens[3]}")
			@url = "http://api.openweathermap.org/data/2.5/forcast/daily?q=#{@ac}&mode=json&units=imperial&cnt=5"
			@url_m = "http://api.openweathermap.org/data/2.5/forcast/daily?q=#{@ac}&mode=json&units=metric&cnt=5"
			@r = "RIVMSG #{nick} :"
			@temp = weekly(@url, @url_m)
			@r.concat(@temp.to_s)
		#default to hourly
		else
			#@url = tokens[1]
			@ac.concat("#{tokens[1]}")
			@ac.concat("#{tokens[2]}")
			@url = "http://api.openweathermap.org/data/2.5/forcast?q=#{@ac}&mode=json&units=imperial"
			@url_m = "http://api.openweathermap.org/data/2.5/forcast?q=#{@ac}&mode=json&units=metric"
			@r = hourly(@url, @url_m)
		end

=begin
		if parsed_json['main'].nil?
			@r = "#{@ac.to_s} does not appear to be a valid city name, or maybe you misspelled the country, try again"
		elsif weather_in_f = (parsed_json['main']['temp']).to_i
			begin
				weather_in_c = (parsed_json_m['main']['temp']).to_i
			rescue NoMethodError => e
				return "is this place actually real?"
			end
			humidity = parsed_json['main']['humidity']
			weathercode = weatherc("#{parsed_json['weather'][0]['id']}")
			@r.concat("Weather of \x0304#{message[3..-1].to_s}:\x03 #{weathercode} at \x0302#{weather_in_f}°F\x03 or \x0302#{weather_in_c}°C\x03 and winds at \x0311#{parsed_json['wind']['speed']} mph\x03")
		end
=end

		return @r
	end
end

reg_p = /^`fc/ #regex to call the module
na = "weather" #name for plugin #same as file name without .rb
de = "usage: `w areacode or City, State description: grabs weather information for an area code or City, State" #description

#plugin = Class_name.new(regex, name, help)
#passed back to the plugins_s array
plugin = Weather.new(reg_p, na, de)
$plugins_s.push(plugin)