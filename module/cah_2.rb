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

	end

	def draw
		if @black_deck.length > 0
			temp_c = @black_deck[0]
			@black_deck.delete_at(0)
			return temp_c
		else
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
		@played = false
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

	def get_played
		return @played
	end

	def set_played played
		@played = played
	end

end

class CAH_II < Pluginf
	
	def initialize(regex, name, help, chan)
		@regexp = Regexp.new(regex.to_s)
		@name = name.to_s
		@help = help
		@chan_list = []
		#@chan_list.push("any")
		#@chan_list.push(chan.to_s)

		@prefixes_user = [
    						/^\$join$/,
    						/^\$leave$/,
    						/^\$play \d\d?$/,
    						/^\$select \d\d?$/,
    						/^\$list$/
    				     ]

    	@prefixes_admin = [
    						/^\$start$/, 
    						/^\$stop$/,
    						/^\$game/
    				      ]

    	@reg_user = Regexp.union(@prefixes_user)
    	@reg_admin = Regexp.union(@prefixes_admin)

    	reg_t = [@reg_user, @reg_admin]
    	@regexp = Regexp.union(reg_t)

    	@whitedeck = White_deck.new
    	@blackdeck = Black_deck.new

    	@game_state = "not_started" #game state
    	@num_players = 0 #number of current players
    	@num_cards = 0 #number of current played cards
    	@players = [] #list of players
    	@current_czar = nil #current card czar
    	@played_cards_white = {} #hash of players -> array of white cards
    	@played_cards_players = [] #list of players who played a card that matches by index to the card played
    	@played_card_black = nil #current black card
    	@displayed = false #to prevent re displaying the black card if a user enters a bad command

    	if !(File.exist? "./res/.cah_conf") then `touch "./res/.cah_conf"`

    	File.open("./res/.cah_conf", 'r') do |fr|
    		while line = fr.gets
    			line.chomp!
    			@chan_list.push(line)
    		end
    	end

	end

	# returns NOTICE #{nick_n} :#{message_n}
	# this function allows noticing a player their relevant information
	# i.e. their score, hand, currently played white card
	def notice_player nick_n, message_n

		return "NOTICE #{nick_n} :#{message_n}"
	end

	# return NOTICE #{channel_n} :#{message_n}
	# this function allows noticing the channel relevant information
	# i.e. the current black card, chosen cards, score
	def notice_channel channel_n, message_n

		return "NOTICE #{channel_n} :#{message_n}"
	end

	# adds nick_n to the game and handles game state
	# returns true if the player could be added
	# returns false if the player could not be added
	def add_player nick_n
		# players can be added at any time during the game
		# but they will be forced into the current round
		temp_player = Player.new(nick_n)
		@players.push(temp_player)
		10.times { draw_white(nick_n) }
		return "#{nick_n} has joined"
	end

	# removes nick_n to the game and handles game state
	# returns true if the player could be removed
	# returns false if the playewr could not be removed
	def remove_player nick_n, nick_called_by
		# players can only leave before they play a card and they are not the card czar

		# however the admin can forcibly remove a player (this can be chekced with nick_called_by)
		# this feature is to be implemented later

		# check if the player has played a card or is the card czar
		# if they have or are the card czar then return false
		# if they haven't and are not the card czar then
		# 	[1] decrement num_players
		# 	[2] cleanup player's hand
		# 	[3] remove player from list of players

		# NOTE: before a round begins the player count is checked, this technically
		# 		would permit removing players leaving during the round
		temp_p = nil
		i = 0
		@players.each do |a|
			if a.get_nick == nick_n then
				temp_p = a.get_hand; break
			else
				i = i + 1
			end
		end


		if nick_n == @current_czar or temp_p.get_played == true
			return false
		else
			# [1] decrement num_players
			if @num_players >= 1
				@num_players = @num_players - 1
			end

			# [2] cleanup player's hand
			temp_player.get_hand.each { |a| @whitedeck.discard(a); }

			# [3] remove player from list of players
			@players.delete_at(i)
			return true
		end

		return false
	end

	# adds a white card to player, nick_n's, hand list
	def draw_white nick_n
		i_t = 0
		@players.each { |a| if a.get_nick == nick then break end; i_t = i_t + 1 }
		@players[i_t].draw_card(@whitedeck.draw)
	end

	# called by the game loop to get a black card from the black card deck
	def draw_black

	end

	# is called by the game loop to discard the current black card
	def discard_black

	end

	# called by the game loop at the request to tell a user
	# their cards along with an index that is 0 for the first element
	# this function returns the list of cards formatted using notice_player
	def list_hand nick_n
		temp_p = nil
		i_t = 0
		r_t = "your cards:\n"
		@players.each { |a| if a.get_nick == nick_n then temp_p = a.get_hand; break end }
		temp_p.each { |a| r_t.concat("[ #{i_t} ] #{a.get_text}\n"); i_t = i_t + 1 }
		return notice_player(nick_n, r_t)
	end

	#your definition for script
	def script(message, nick, chan)

		return "string"
	end
end

reg_p = // #regex to call the module
na = "CAH_2" #name for plugin #same as file name without .rb
de = "NOTES ^| HELP" #description

#plugin = Class_name.new(regex, name, help)
#pushed onto to the end of plugins array array
plugin = CAH_II.new(reg_p, na, de)
$plugins_s.push(plugin)
