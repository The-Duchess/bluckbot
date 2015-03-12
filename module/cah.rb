#!/bin/env ruby
# template as defined by the required file
# author: apels <Alice Duchess>
# module as defined by .plugin.rb
# modules have access to $plugins to be loaded as well as $logs
# $logs stores unparsed message lines in an array of length 100


$LOAD_PATH << './module'
require '.pluginf.rb'

class White_card
	def initialize(text, id)
		@text = text
		@id = id
	end

	def get_text
		return @text
	end

	def get_id
		return @id
	end
end

class Black_card
	def initialize(text, id, rule)
		@text = text
		@id = id
		@rule = rule #rule types are stored as a strings (example: pick_two_play_three)
	end

	def get_text
		return @text
	end

	def get_id
		return @id
	end

	def get_rule
		return @rule
	end
end

class White_deck # load a deck from the white card file
	def initialize
		@white_deck = []
		@white_discard = []
		File.open("./res/.white_cards", 'r') do |fr|
			while line = fr.gets
				line.chomp!
				#evaluate line
				tokens = line.split(':') # card_id:string
				temp_c = White_card.new(tokens[1].to_s, tokens[0].to_i)
				@white_deck.push(temp_c)
			end
		end

		@white_deck.shuffle!
		@white_deck.shuffle!

	end

	def draw
		if @white_deck.length > 0
			temp_c = @white_deck[0]
			@white_deck.delete_at(0)
			return temp_c
		else
			@white_discard.shuffle!
			@white_discard.shuffle!

			@white_discard.each { |w| @white_deck.push(w) }

			temp_c = @white_deck[0]
			@white_deck.delete_at(0)
			return temp_c
		end
	end

	#recieve a card to discard
	def discard(card)
		@white_discard.push(card)
	end

end

class Black_deck # load a deck from the black card file
	def initialize
		@black_deck = []
		@black_discard = []
		File.open("./res/.black_cards", 'r') do |fr|
			while line = fr.gets
				line.chomp!
				#evaluate line
				tokens = line.split(':') # card_id:string:rule
				temp_c = Black_card.new(tokens[1].to_s, tokens[0].to_i, tokens[2].to_s)
				@black_deck.push(temp_c)
			end
		end

		@black_deck.shuffle!
		@black_deck.shuffle!

	end

	def draw
		if @black_deck.length > 0
			temp_c = @black_deck[0]
			@black_deck.delete_at(0)
			return temp_c
		else
			@black_discard.shuffle!
			@black_discard.shuffle!

			@black_discard.each { |b| @black_deck.push(b) }

			temp_c = @black_deck[0]
			@black_deck.delete_at(0)
			return temp_c
		end
	end

	def discard(card)
		@black_discard.push(card)
	end

end

class Player

	def initialize(nick)
		@hand = [] #array of white cards
		@nick = nick
		@score = 0
	end

	#if the player wind a round
	def increment_score
		@score = @score + 1
	end

	#get score
	def get_score
		return @score
	end

	#get nick
	def get_nick
		return @nick
	end

	#play a card
	def play_card(num)
		temp_c = @hand[num - 1]
		@hand.delete_at(num - 1)
		return temp_c
	end

	#recieve a card
	def draw_card(card)
		temp_c = card
		@hand.push(temp_c)
	end

	def get_hand
		return @hand
	end

end

class Cards < Pluginf
	
	def initialize(regex, name, help, chan)
		@regexp = Regexp.new(regex.to_s)
		@name = name.to_s
		@help = help
		@chan_list = []
		#@chan_list.push("any")
		#@chan_list.push(chan.to_s)

		@prefixes_user = [
    						/^`join$/,
    						/^`leave$/,
    						/^`play \d\d?$/,
    						/^`select \d\d?$/,
    						/^`list$/
    	]

    	@prefixes_admin = [
    						/^`start$/,
    						/^`stop$/,
    	]

    	@reg_user = Regexp.union(@prefixes_user)
    	@reg_admin = Regexp.union(@prefixes_admin)

    	@whitedeck = White_deck.new
    	@blackdeck = Black_deck.new

    	@game_state = "not_started" #game state
    	@num_players = 0 #number of current players
    	@num_cards = 0 #number of current played cards
    	@players = [] #list of players
    	@current_czar = nil #current card czar
    	@played_cards_w = {} #hash of players -> array of white cards
    	@played_cards_p = [] #list of players who played a card that matches by index to the card played
    	@played_card_b = nil #current black card
    	@displayed = false #to prevent re displaying the black card if a user enters a bad command

    	if !(File.exist? "./res/.cah_conf") then `touch "./res/.cah_conf"`

    	File.open("./res/.cah_conf", 'r') do |fr|
    		while line = fr.gets
    			line.chomp!
    			@chan_list.push(line)
    		end
    	end

	end

	def notice_chan msg_t
		return "NOTICE #{chan} : #{msg_t}"
	end

	def notice_player msg_t
		return "NOTICE #{nick} : #{msg_t}"
	end

	# plays cards for current nick
	def play_cards(cards, nick)

	end

	# current nick picks winner
	def pick_winner(winner, nick)

	end

	# joins the current nick
	def join(nick)

	end

	# leaves the current nick
	def leave(nick)

	end

	# returns list of cards for current nick
	def list(nick)

	end

	# starts the game
	def start

	end

	# stops the game
	def stop

	end

	# determines what to do
	def parse

	end

	#your definition for script
	def script(message, nick, chan)
		@r = ""

		return @r
	end
end

prefixes_both = [
    			/^`join$/,
    			/^`leave$/,
    			/^`play \d\d?$/,
    			/^`select \d\d?$/,
    			/^`list$/,
    			/^`start$/,
    			/^`stop$/,
    			]

reg_p = Regexp.union(prefixes_both) #regex to call the module
na = "cah" #name for plugin #same as file name without .rb
de = "irc plugin to play cah" #description

#plugin = Class_name.new(regex, name, help)
#passed back to the plugins_s array
plugin = Cards.new(reg_p, na, de)
$plugins_s.push(plugin)