class_name AbstractPlayer extends AbstractCharacter







var hand:CardGroup = CardGroup.new()
var draw_pile:CardGroup = CardGroup.new()
var discard_pile:CardGroup = CardGroup.new()
var exhaust_pile:CardGroup = CardGroup.new()
var powers:CardGroup = CardGroup.new()

########### NOT CURRENTLY USED: ######################
## The stack of cards created when you quickly drag multiple cards past the drop line.
#var queue_stack = []
## The stack of cards actually being played. Should only contain one card at a time plus copies and triggered cards (e.g. Havoc)
#var playing_stack = []
######################################################

var reward_pile = []
var rare_reward_pile = []
var removed_pile = []

var energy
var base_energy_per_turn = 3
var displayed_energy_per_turn = base_energy_per_turn

# A collection of references to physical tokens.
var shivs = []
var miracles = []
# References to physical orb slots. Orb slots in turn contain references to physical cubes.
var orb_slots = []





func attempt_play_card(card:AbstractCard):
	var result=card.can_be_played(self)
	if(result==true):
		pass
	else:
		#TODO: result is either false or contains an error message;
		#	communicate error message to player
		pass
	pass
