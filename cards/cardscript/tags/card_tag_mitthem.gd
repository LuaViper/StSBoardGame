class_name CardTagMItThem extends CardTag

func setup(name,card,value,format):
	self.surrounding_nls=false
	super.setup(name,card,value,format)
	return self

func get_autotext()->String:
	var mtag=self.card.tags["m"]
	var result="it" if(int(mtag.displayed_value)==1) else "them"
	
	return result
