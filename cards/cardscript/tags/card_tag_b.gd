class_name CardTagB extends CardTag

func autotext()->String:
	return self.card.block_color_tags(str(self.card.block_amt))+"[BLOCK_ICON]"
