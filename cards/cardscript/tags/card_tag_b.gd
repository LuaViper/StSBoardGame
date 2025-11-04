class_name CardTagB extends CardTag

func setup(name,card,value,format):
	self.surrounding_nls=false
	if(value.begins_with("ANY")):
		value=value.substr(3)
		misc=true;
	super.setup(name,card,value,format)

func get_autotext()->String:
	var to_any_player = "" if(!misc) else " to any player."
	return self.get_color_prefix()+(displayed_value)+"<BLOCK_ICON>"+to_any_player
