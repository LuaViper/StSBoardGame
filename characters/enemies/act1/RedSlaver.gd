class_name RedSlaver extends AbstractCharacter

func load_character(node):
	node.load_character("images/monsters/theBottom/redSlaver/skeleton.atlas", 
						"images/monsters/theBottom/redSlaver/skeleton.json", 
						0)
	node.load_animation("idle")
