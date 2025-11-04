class_name CardTagDazedDiscardPile extends CardTag

func get_autotext()->String:
	var put:String="Put a " if(int(displayed_value)==1) else "Put "
	return put+"<DAZED_ICON>".repeat(int(displayed_value))+" in your discard pile."
