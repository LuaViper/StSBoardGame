class_name TheGuardian extends Character


func load_character(node):
	node.load_character("images/monsters/theBottom/boss/guardian/skeleton.atlas", 
						"images/monsters/theBottom/boss/guardian/skeleton.json", 
						-95,
						2.0)
	node.load_animation("idle",true,1.0)
	#node.load_animation("defensive",true,2.0)
	
