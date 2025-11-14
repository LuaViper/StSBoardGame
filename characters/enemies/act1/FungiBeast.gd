class_name FungiBeast extends Character

func load_character(node):
	#TODO: review y-offset. fur is clipping, but "leg" roots would float otherwise
	node.load_character("images/monsters/theBottom/fungi/skeleton.atlas", 
						"images/monsters/theBottom/fungi/skeleton.json", 
						2)
	node.load_animation("Idle",true,randf_range(0.7,1.0))
