class_name CardTagXPlus1 extends CardTag

func setup(name,card,value,format):
	self.surrounding_nls=false
	super.setup(name,card,value,format)
	return self

func get_autotext()->String:
	return "X+1"
