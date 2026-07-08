class_name BlueSlaver extends AbstractCharacter

func load_character(node):
	node.load_character("images/monsters/theBottom/blueSlaver/skeleton.atlas", 
						"images/monsters/theBottom/blueSlaver/skeleton.json", 
						0)
	node.load_animation("idle")
