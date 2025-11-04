class_name CardTagE extends CardTag

func setup(name,card,value,format):
	if(format.has("IconOnly")):
		self.surrounding_nls=false
	super.setup(name,card,value,format)
	return self
	
func get_autotext()->String:
	if(not format.has("IconOnly")):
		return "Gain "+"<ENERGY_ICON>".repeat(int(displayed_value))+"."
	else:
		return "<ENERGY_ICON>".repeat(int(displayed_value))
