class_name CardPlay extends AbstractPlay

var player:AbstractPlayer
var card:AbstractCard

func _init(player:AbstractPlayer,card:AbstractCard):
	self.player=player
	self.card=card

func is_play_blocked():
	# Check card.cannot_be_played
	# Check card is in hand
	#	(cards that aren't in hand must be played via means other than CardPlay)
	return false

func on_unplayable():
	return

func send_to_host():
	Globals.multiplayer_manager.send_serialized(PlayManager.CARD_PLAY,[card.guid,card.internal_name])

static func create_copy(player,args):	
	var card
	for c in player.hand.get_cards():
		if(c.guid==args[0] && c.internal_name==args[1]):
			card = c
	var play = preload("res://actions/plays/card_play.gd").new(player,card)
	return play

func do():
	# Header: make pre-play decisions
	# (play can still be cancelled at this point IF not obligatory)
	# Header: player pays energy
	# Action: deduct energy
	# Action: card moves to play limbo
	# Header: resolve
	# (run card.play())
	# Header: triggered abilities
	# (action queue continues)
	# Header: cleanup
	# Action: card to discard / exhaust / active powers etc)

	pass
