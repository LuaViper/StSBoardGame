class_name LargeSlime extends Character

func load_character(node):
	node.load_character("images/monsters/theBottom/slimeL/skeleton.atlas", 
						"images/monsters/theBottom/slimeL/skeleton.json", 
						-5)
	node.load_animation("Idle")
	#TODO: slimes play sound effects at animation events
