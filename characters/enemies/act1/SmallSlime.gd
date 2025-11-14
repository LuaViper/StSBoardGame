class_name SmallSlime extends Character

func load_character(node):
	node.load_character("images/monsters/theBottom/slimeAltS/skeleton.atlas", 
						"images/monsters/theBottom/slimeAltS/skeleton.json",
						 5)
	node.load_animation("idle")
	#TODO: slime SFX listener
