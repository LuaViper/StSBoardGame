class_name CardTagDazed extends CardTag

func get_autotext()->String:
	return "<DAZED_ICON>".repeat(int(displayed_value))
