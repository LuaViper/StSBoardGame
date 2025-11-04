class_name CardTagDiscard extends CardTag

func get_autotext()->String:
	var card=" card." if(int(displayed_value)==1) else " cards."
	return "Discard "+self.get_color_prefix()+displayed_value+card
