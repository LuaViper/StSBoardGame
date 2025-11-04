class_name CardTagShiv extends CardTag

func setup(name,card,value,format):
	self.surrounding_nls=false
	super.setup(name,card,value,format)
	return self

func get_autotext()->String:
	return "<SHIV_ICON>".repeat(int(displayed_value))
