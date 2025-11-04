class_name CardTagFrost extends CardTag

func get_autotext()->String:
	return "#yChannel "+self.get_color_prefix()+displayed_value+" #yFrost."
