class_name CardTagH extends CardTag

func _init():
	print("CardTagH._init")
	
func autotext()->String:
	return CardIconHelper.get_bbcode_tags("H")
