class_name Looter extends Character

func load_character(node):
	node.load_character("images/monsters/theBottom/looter/skeleton.atlas", 
						"images/monsters/theBottom/looter/skeleton.json", 
						-3)
	node.load_animation("idle")
