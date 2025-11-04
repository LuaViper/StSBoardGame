class_name CardTagMustExhaust extends CardTag

func get_color_prefix():
	#TODO:
	return "" 

func get_autotext()->String:
	var text = "#yExhaust a card in your hand."
	if(displayed_value=="(1,2)"):
		text = "#yExhaust 1 or 2 cards in your hand."
	elif(displayed_value.begins_with("(0,")):
		var val = displayed_value[3]
		text = "#yExhaust up to "+self.get_color_prefix()+val+" cards in your hand."
	return text
