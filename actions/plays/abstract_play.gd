#TODO: come up with a better name for this concept than "physical play"
#		maybe AbstractPlayAction?

class_name AbstractPlay extends AbstractGameAction

#TODO: bit of ambiguity whether "player" represents a player character
#	or a human player (who can control multiple player characters).
#	consider renaming variables which reference human players to "human" or "client"
var human_id
var character:AbstractPlayer

# guid is currently used for multiplayer comms
# 	it will be set when received from another client (or self)
var guid

# Plays are "not obligatory" when directly initated by the player,
# and "obligatory" when caused by a different game mechanic.
var obligatory


static func create_play_from_args(human_id,guid,player_id,type,args):	
	var playclass = null
	match type:
		PlayManager.CARD_PLAY:
			playclass = CardPlay
	if(playclass):
		var play = playclass.create_copy(player_id,args)
		play.human_id = human_id
		play.guid = guid
		return play
	assert(false,"Couldn't create_play_from_args with given type "+type)
	return null

static func create_copy(player_id,args):
	#abstract function
	return

func send_to_host():
	#Override and call send_to_host_serialized
	pass


func do():
	#TODO LATER: this space reserved in case we want to
	# handle something in the UI history panel from here
	pass

func on_unplayable():
	# If the play is not obligatory:
	#	remove the play from queue
	#	also remove all plays from the same player from the queue
	#TODO: to avoid race conditions, we need to place a block on the player
	#	and wait for the player to send a special acknowledge/unblock play

	# If the play IS obligatory:
	#	depends on the type of play--
	#	cards go to discard pile unless something specific exhausts them
	pass

func are_decisions_missing():
	return false

func on_decisions_missing():
	# If the play is not obligatory:
	#	remove the play from queue
	#	also remove all plays from the same player from the queue
	# If the play IS obligatory:
	#	player_owner's queue is stuck until player_owner makes a decision
	#	(when playing Regulation mode, ALL player queues are stuck)
	pass
