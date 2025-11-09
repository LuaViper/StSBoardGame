class_name JawWorm extends Character

func load_character(node):
	node.load_character("images/monsters/theBottom/jawWorm/skeleton.atlas", 
						"images/monsters/theBottom/jawWorm/skeleton.json",
						 20)
	node.load_animation("idle")
	#node.load_character("images/monsters/theCity/stabBook/skeleton.atlas", 
						#"images/monsters/theCity/stabBook/skeleton.json",
						 #20)						
	#node.load_animation("Idle",true,0.8)
	#node.set_mix("Hit", "Idle", 0.2);
