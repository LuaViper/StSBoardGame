class_name RedLouse extends Character

func load_character(node):
	node.load_character("images/monsters/theBottom/louseGreen/skeleton.atlas", 
						"images/monsters/theBottom/louseGreen/skeleton.json", 
						-3)
	node.load_animation("idle")
