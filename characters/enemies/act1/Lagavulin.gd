class_name Lagavulin extends Character

func load_character(node):
	node.load_character("images/monsters/theBottom/lagavulin/skeleton.atlas", 
						"images/monsters/theBottom/lagavulin/skeleton.json", 
						2)
	node.load_animation("Idle_1")	
	#node.load_animation("Idle_2")
	
	node.set_mix("Attack", "Idle_2", 0.25);
	node.set_mix("Hit", "Idle_2", 0.25);
	node.set_mix("Idle_1", "Idle_2", 0.5);
