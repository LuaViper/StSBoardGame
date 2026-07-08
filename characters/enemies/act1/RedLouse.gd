class_name RedLouse extends AbstractCharacter

func load_character(node):
	node.load_character("images/monsters/theBottom/louseRed/skeleton.atlas", 
						"images/monsters/theBottom/louseRed/skeleton.json", 
						-3)
	node.load_animation("idle")
