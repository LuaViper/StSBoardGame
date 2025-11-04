class_name CardTagStr extends CardTag

func setup(name,card,value,format):
	self.surrounding_nls=false
	super.setup(name,card,value,format)
	return self

func get_autotext()->String:
	if(not format.has("IconOnly")):
		return "Gain "+"<STR_ICON>".repeat(int(displayed_value))+"."
	else:
		return "<STR_ICON>".repeat(int(displayed_value))
