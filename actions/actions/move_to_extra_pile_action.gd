class_name MoveToExtraPileAction extends AbstractGameAction

# Not for standard use!
# This won't trigger any effects that would normally result from discard/exhaust.

var cards
var destination

func _init(cards,destination):
	self.cards=cards
	self.destination=destination
	if(cards.size()>1):
		description = "Cards move to "+destination.to_string()+"."
	else:
		description = cards[0]._to_string()+" moves to "+destination.to_string()+"."
	pass

func do():
	for card in cards:
		card._set_location(destination)
	_is_done=true
