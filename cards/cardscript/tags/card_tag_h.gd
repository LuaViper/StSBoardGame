class_name CardTagH extends CardTag

func setup(name,card,value,format):
	self.surrounding_nls=false
	if(value.begins_with("AOE")):
		value=value.substr(3)
		misc=true;
	super.setup(name,card,value,format)
	return self

func get_autotext()->String:
	var aoe = "" if(!misc) else "<AOE_ICON>"
	return aoe+self.get_color_prefix()+displayed_value+"<HIT_ICON>"
