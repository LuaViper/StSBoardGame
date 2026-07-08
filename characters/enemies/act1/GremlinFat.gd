class_name GremlinFat extends AbstractCharacter

func load_character(node):
	node.load_character("images/monsters/theBottom/fatGremlin/skeleton.atlas", 
						"images/monsters/theBottom/fatGremlin/skeleton.json", 
						-5)
	node.load_animation("animation")
