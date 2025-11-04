class_name CardTagWarcry extends CardTag

func get_autotext()->String:
	return "Draw "+get_color_prefix()+displayed_value+" cards.<NL>Then put a card from your hand onto the top of your draw pile."
