class_name GremlinAngry extends Character

func load_character(node):
	node.load_character("images/monsters/theBottom/angryGremlin/skeleton.atlas", 
						"images/monsters/theBottom/angryGremlin/skeleton.json", 
						-10)
	node.load_animation("idle")
