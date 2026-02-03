class_name TransparentEffectsRenderingViewport
extends SubViewport

var card:AbstractCard

#TODO: consider setting Render Target > Update Mode to Always
#TODO: do we actually need this set_card function?
func set_card(card_:AbstractCard):	
	await ready
	self.card=card_
	pass
