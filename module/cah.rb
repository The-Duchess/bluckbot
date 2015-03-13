#!/bin/env ruby
# template as defined by the required file
# author: apels <Alice Duchess>
# module as defined by .plugin.rb
#
#################################################################################################################
# cah.rb is a Cards Against Humanity plugin for bluckbot 
# cah commands:
# 	user commands:
# 		`join : joins an active game
# 		`leave : leaves an active game
# 		`play <card number> : plays a card if you are not the card czar
# 		`select <option number> : chooses a card if you are the card czar
# 		`list : have the bot list your hand in a notice
# 	owner commands:
# 		`start : starts a game
# 		`stop : stops a game
# 		`game : gives information on the current game
#
# cah config:
# cah.rb has a config file in the resource "./res" folder of the irc bot that tells it the name of the channel
# it will be limited to.
#
#################################################################################################################

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
    						/^`game/
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
		# add key for nick to hash
		# add cards.each -> hash[:nick]
	end

	# current nick picks winner
	def pick_winner(winner, nick)
		# increment points to nick in players
		winner_i = winner - 1
		winner_n = @players[winner_i].get_nick
		#increment winner
		@players[winner_i].increment_score
		return "#{winner_n} won the round"
	end

	# joins the current nick
	def join(nick)
		temp_player = Player.new(nick)
		@players.push(temp_player)
		10.times { draw_white(nick) }
		return "#{nick} has joined"
	end

	# leaves the current nick
	# not sure if this should be managed by a function since it is highly dependend on game state
	# on what it should do
	def leave(nick)

	end

	# hands a white card from the deck to current nick
	def draw_white(nick)
		i_t = 0
		@players.each { |a| if a.get_nick == nick then break end; i_t = i_t + 1 }
		@players[i_t].draw_card(@whitedeck.draw)
	end

	# cleans up the table from the current round
	def clean_up_round
		# discard all white cards
		# @played_cards_c[:@played_cards_p.each] -> white discard
		# discard black card
		@played_cards_p.each do |b|
			i_t = @played_cards_w[:b].length - 1
			0.upto(i_t) do |c|
				@whitedeck.discard(@played_cards_w[:b][c])
			end
		end

		@played_cards_w = {}

		@blackdeck.discard(@played_card_b)
		@played_card_b = nil
	end

	# draws a black card
	def draw_black
		# draw a black card
		@played_card_b = @blackdeck.draw
	end

	# sets game state
	def set_state(state)
		@game_state = state
	end

	# gets a list of active players and their score delimited by a ;
	def list_players
		@temp_r = ""
		@players.each { |a| @temp_r.concat("#{a.get_nick} has: #{a.get_score} points;")}
	end

	# returns game state information # game state is not private so why the fuck is this here
	# well bob because HURR DURR muh infrastructure, also because autism
	def game_state
		return @game_state
	end

	# returns list of cards for current nick
	def list(nick)
		temp_p = nil
		i_t = 1
		r_t = "you cards:\n"
		@players.each { |a| if a.get_nick == nick then temp_p = a.get_hand; break end }
		temp_p.each { |a| r_t.concat("#{i_t}: #{a.get_text}\n"); i_t = i_t + 1 }
		return r_t
	end

	# starts the game
	# sets game state and initializes the game
	def start
		set_state("in_round")
		draw_black
		return "game started"
	end

	# stops the game
	# sets the game state to not_started and cleans up in play cards and player's hands
	def stop
		# set the game state
		set_state("not_started")
		# clean up the round
		clean_up_round
		# clean up players
		@players.each do |a|
			i_t = a.get_hand.length.to_i
			1.upto(i_t) do |b|
				@whitedeck.discard(a.play_card(b))
			end
		end

		i_t = @players.length - 1
		0.upto(i_t) { |b| @players.delete_at(b) }
		@players = []
	end

	##########################################################################################################
	# play
	# steps:
	# 	1 - build player list from players who joined
	# 	2 - players draw hands in order
	# 	3 - determine card czar and rotate through the list until end and then back to beginning
	# 	4 - card czar reads card (card is sent as notice to channel)
	# 	5 - players play cards if they are not the card czar
	# 	6 - if num_players have played then card czar may pick
	# 	7 - player score is incremented
	# 	8 - rotate card czar and repeat from step 4
	##########################################################################################################

	#########################################################################################################
	# in_round | choose_card | not_started | waiting
	# players that join in_round will be dealt a hand and assigned to the player list after
	# state changes to choose_card
	##########################################################################################################
	#@game_state = "not_started"

	##########################################################################################################
	# Game State Variables
	# @game_state = "not_started" #game state
	# @num_players = 0 #number of current players
    # @num_cards = 0 #number of current played cards
    # @players = [] #list of players
    # @current_czar = nil #current card czar
    # @played_cards_w = {} #hash of players -> array of white cards
    # @played_cards_p = [] #list of players who played a card that matches by index to the card played
    # @played_card_b = nil #current black card
    # @displayed = false
    ##########################################################################################################

    # handles admin commands
    def admin_parse(message, nick, chan)

   		if message =~ @prefixes_admin[0] and @game_state == "not_started" # `start : starts a game
   			# set game state
   			set_state("waiting")
   			return notice_chan(chan, "game started")
   		elsif message =~ @prefixes_admin[1] and @game_state != "not_started" # `stop : stops a game
   			# stop
   			# set game state
   			stop
   			set_state("not_started")
   			return notice_chan(chan, "game stopped")
   		elsif message =~ @prefixes_admin[2] # `game : gets game state information
   			# notice channel the game information
   			# this should be moved to users and made to notice the user; however for now it will remain an admin ability for testing
   			# get player list
   			# get scores
   			# get game state
   			# notice channel
   			player_list = list_players.split(";")
   			@r = "GAME\nPLAYERS"
   			player_list.each { |a| @r.concat("#{a}\n") }
   			@r.concat("STATE\n#{game_state}")
   			return notice_chan(chan, @r)
   		else # invalid command
   			return notice_chan(nick, "you cannot send this command right now")
   		end

   	end

   	# handles user commands
   	def user_parse(message, nick, chan)

   		if message =~ @prefixes_user[4] and @game_state != "not_started" # `list
   			@r = list(nick)
   			notice_chan(nick, "your card list:\n#{@r}")
   		elsif message =~ @prefixes_user[0] and @game_state != "not_started" # `join : joins an active game
   			join(nick) # only does work for that player
   			@num_players = @num_players + 1

   			if @num_players > 2
   				# draw initial black card # this prevents from having to have game state change outside of comman
   				@played_card_b = @blackdeck.draw
   				set_state("in_round")
   			end
   		elsif message =~ @prefixes_user[1] and @game_state != "not_started" # `leave : leaves an active game
   			if not @played_cards_p.include? nick
   				leave(nick) # only does work for that player
   				@num_players = @num_players - 1
   				if @num_players < 3
   					stop
   					@num_players = 0
   				end
   			else
   				return notice_chan(nick, "you have played this round; you can leave next round")
   			end
   		elsif message =~ @prefixes_user[2] and @game_state == "in_round" # `play <card number> : plays a card if you are not the card czar
   			# check player is the card czar and if not then
   			# if they are tell them they cannot play
   			# check card rule
   			# make sure there are enough cards played by player nick and no card index is larger than the number of cards they have - 1
   			# if so play cards
   			# else tell the player the cards were not accepted
   			# if number of played cards == num players then set state to choose_card
   		elsif message =~ @prefixes_user[3] and @game_state == "choose_card" # `select <option number> : chooses a card if you are the card czar
   			# make sure the player is the card czar
   			# if not tell the user they cannot select
   			# select card
   			# increment winner
   			# clean up round
   			# set state
   			# deal new black card # this prevents from having to have game state change outside of commands
   		else # invalid command
   			return notice_chan(nick, "you cannot send this command right now")
   		end
   	end

	# determines what to do
	def parse(message, nick, chan)

		if $admins.include? nick and message.match(@reg_admin)
			# handle admin commands
			return admin_parse(message, nick, chan)
		elsif message.match(@reg_user)
			# handle non-admin commands
			return user_parse(message, nick, chan)
		else
			return "NOTICE #{chan} :command error"
		end
	end

	#your definition for script
	def script(message, nick, chan)
		@r = ""
		@r.concat(parse(message, nick, chan))
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
    			/^`game/
    			]

reg_p = Regexp.union(prefixes_both) #regex to call the module
na = "cah" #name for plugin #same as file name without .rb
de = "irc plugin to play cah" #description

#plugin = Class_name.new(regex, name, help)
#passed back to the plugins_s array
plugin = Cards.new(reg_p, na, de)
$plugins_s.push(plugin)
