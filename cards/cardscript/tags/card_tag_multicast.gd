class_name CardTagMultiCast extends CardTag

func get_autotext()->String:
	var text = "#yEvoke 1 Orb twice."
	if(displayed_value=="X"):
		text = "#yEvoke 1 Orb X times."
	elif(displayed_value=="X+1"):
		text = "#yEvoke 1 Orb X+1 times."
	return text
