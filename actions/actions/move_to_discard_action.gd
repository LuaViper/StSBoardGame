class_name MoveToDiscardAction extends AbstractGameAction

var cards
var sly

func _init(cards,sly:bool=false):
	self.cards=cards
	self.sly=sly
	if(cards.size()>1):
		description = "Cards move to discard pile."
	else:
		description = cards[0]._to_string()+" moves to discard pile."
	pass

func do():
	for card:AbstractCard in cards:
		card.move_to_discard(sly)
	_is_done=true
