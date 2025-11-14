class_name SpikeSlime extends Character

func load_character(node):
	node.load_character("images/monsters/theBottom/slimeAltM/skeleton.atlas", 
						"images/monsters/theBottom/slimeAltM/skeleton.json",
						 20)
	node.load_animation("idle")
	#TODO: slime SFX listener
