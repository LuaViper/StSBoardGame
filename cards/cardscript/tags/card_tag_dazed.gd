class_name CardTagDazed extends CardTag

func autotext()->String:
	return "[DAZED_ICON]".repeat(card.dazed_amt)
