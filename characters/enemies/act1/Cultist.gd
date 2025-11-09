class_name Cultist extends Character

func load_character(node):
	node.load_character("images/monsters/theBottom/cultist/skeleton.atlas", 
						"images/monsters/theBottom/cultist/skeleton.json",
						 -15)
	node.load_animation("waving")
