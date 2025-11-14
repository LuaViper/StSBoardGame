class_name AcidSlime extends Character

func load_character(node):
	node.load_character("images/monsters/theBottom/slimeM/skeleton.atlas", 
						"images/monsters/theBottom/slimeM/skeleton.json",
						 -10)
	node.load_animation("idle")
	#TODO: slime SFX listener
