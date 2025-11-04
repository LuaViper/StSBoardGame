class_name CardTagLightning extends CardTag

func get_autotext()->String:
	return "#yChannel "+self.get_color_prefix()+displayed_value+" #yLightning."
