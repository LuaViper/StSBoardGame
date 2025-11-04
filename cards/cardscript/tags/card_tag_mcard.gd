class_name CardTagMCard extends CardTag

func setup(name,card,value,format):
	self.surrounding_nls=false
	super.setup(name,card,value,format)
	return self

func get_autotext()->String:
	var mtag=self.card.tags["m"]
	var card="card" if(int(mtag.displayed_value)==1) else "cards"
	
	var displayed=self.get_color_prefix()+mtag.displayed_value
	
	if(format.has("a") && card=="card"):
		displayed="a"
	var result=displayed+" "+card
	
	return result
