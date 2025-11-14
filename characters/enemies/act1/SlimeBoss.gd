class_name SlimeBoss extends Character


func load_character(node):
	node.load_character("images/monsters/theBottom/boss/slime/skeleton.atlas", 
						"images/monsters/theBottom/boss/slime/skeleton.json", 
						10)
	node.load_animation("idle")
	
