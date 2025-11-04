class_name CardTagVuln extends CardTag

func setup(name,card,value,format):
	self.surrounding_nls=false
	super.setup(name,card,value,format)
	return self

func get_autotext()->String:
	return "<VULN_ICON>".repeat(int(displayed_value))
