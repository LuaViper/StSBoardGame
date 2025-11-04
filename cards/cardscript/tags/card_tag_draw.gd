class_name CardTagDraw extends CardTag

func setup(name,card,value,format):
	if(format.has("NCards")):
		self.surrounding_nls=false
	super.setup(name,card,value,format)
	return self

func get_autotext()->String:
	var card = "card"
	if(displayed_value.is_valid_int()):
		if(int(displayed_value)>1):
			card="cards"
	var displayed=self.get_color_prefix()+displayed_value
	if(format.has("a") && card=="card"):
		displayed="a"
	var result=displayed+" "+card
	if(!format.has("NCards")):
		result="Draw "+result+"."
	return result
