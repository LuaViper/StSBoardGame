class_name GremlinAngry extends AbstractCharacter

func load_character(node):
	node.load_character("images/monsters/theBottom/angryGremlin/skeleton.atlas", 
						"images/monsters/theBottom/angryGremlin/skeleton.json", 
						-10)
	node.load_animation("idle")
