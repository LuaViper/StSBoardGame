class_name CardTagScry extends CardTag

func get_autotext()->String:
	return "#yScry "+self.get_color_prefix()+displayed_value+"."
