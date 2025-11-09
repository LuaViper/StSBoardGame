extends Node3D

var rows = []

var Character2D = preload("res://characters/Character2D.tscn")

var Bone = load("res://spine-3402-csharp/src/Bone.cs")

var TestEnemy = load("res://characters/enemies/act1/JawWorm.gd")

var eye_bone
var eye

func _ready():
	rows.append(%Row1)
	rows.append(%Row2)
	rows.append(%Row3)
	rows.append(%Row4)

	var character
	#character=%Row1.get_node("%Character3D_1").character2d
	#character.load_character("images/characters/ironclad/idle/skeleton.atlas", "images/characters/ironclad/idle/skeleton.json", 10)
	#character.load_animation("Idle",false,0.6)
	#character.set_mix("Hit", "Idle", 0.1);
	#character.skeleton.IgnoreShadows = true;
#
	#character=%Row2.get_node("%Character3D_1").character2d
	#character.load_character("images/characters/theSilent/idle/skeleton.atlas", "images/characters/theSilent/idle/skeleton.json", 15)
	#character.load_animation("Idle",false,0.9)
	#character.set_mix("Hit", "Idle", 0.1);
	#character.skeleton.IgnoreShadows = true;
	#
	#character=%Row3.get_node("%Character3D_1").character2d
	#character.load_character("images/characters/defect/idle/skeleton.atlas", "images/characters/defect/idle/skeleton.json", 5)
	#character.load_animation("Idle",false,0.9)
	#character.set_mix("Hit", "Idle", 0.1);
	#character.skeleton.IgnoreShadows = true;
	#
	#character=%Row4.get_node("%Character3D_1").character2d
	#character.load_character("images/characters/watcher/idle/skeleton.atlas", "images/characters/watcher/idle/skeleton.json", 5)
	#character.load_animation("Idle",false,0.7)
	#character.set_mix("Hit", "Idle", 0.1);
	#character.skeleton.IgnoreShadows = true;
	#eye_bone = character.skeleton.FindBone("eye_anchor")
	#eye = Character2D.instantiate()
	#add_child(eye)
	#eye.load_character("images/characters/watcher/eye_anim/skeleton.atlas","images/characters/watcher/eye_anim/skeleton.json", 0)
	#eye.load_animation("None",false,1.0)
	#eye.render_target = character
#
	character=%Row1.get_node("%Character3D_2").character2d
	var test_enemy = TestEnemy.new()
	test_enemy.load_character(character)
	character.skeleton.IgnoreShadows = true;
	%Row1.temp_spawncardatposition(0)
	
	return #!!!

	for i in range(3,7):
		character=%Row1.get_node("%Character3D_"+str(i)).character2d
		character.load_character("images/monsters/theBottom/slimeM/skeleton.atlas", "images/monsters/theBottom/slimeM/skeleton.json", -10)
		character.load_animation("idle")
		#TODO: slimes play sound effects at animation events
		character.skeleton.IgnoreShadows = true;
		%Row1.temp_spawncardatposition(i-2)	

	
	character=%Row2.get_node("%Character3D_2").character2d
	character.load_character("images/monsters/theBottom/angryGremlin/skeleton.atlas", "images/monsters/theBottom/angryGremlin/skeleton.json",-10)
	character.load_animation("idle")
	character.skeleton.IgnoreShadows = true;
	%Row2.temp_spawncardatposition(0)
	
	character=%Row2.get_node("%Character3D_3").character2d
	character.load_character("images/monsters/theBottom/fatGremlin/skeleton.atlas", "images/monsters/theBottom/fatGremlin/skeleton.json", -5)
	character.load_animation("animation")
	character.skeleton.IgnoreShadows = true;
	%Row2.temp_spawncardatposition(1)	
	
	character=%Row2.get_node("%Character3D_4").character2d
	character.load_character("images/monsters/theBottom/thiefGremlin/skeleton.atlas", "images/monsters/theBottom/thiefGremlin/skeleton.json", -19)
	character.load_animation("animation")
	character.skeleton.IgnoreShadows = true;
	%Row2.temp_spawncardatposition(2)

	character=%Row2.get_node("%Character3D_5").character2d
	character.load_character("images/monsters/theBottom/wizardGremlin/skeleton.atlas", "images/monsters/theBottom/wizardGremlin/skeleton.json", -14)
	character.load_animation("animation")
	character.skeleton.IgnoreShadows = true;
	%Row2.temp_spawncardatposition(3)


	character=%Row3.get_node("%Character3D_2").character2d
	character.load_character("images/monsters/theBottom/thiefGremlin/skeleton.atlas", "images/monsters/theBottom/thiefGremlin/skeleton.json", -19)	
	character.load_animation("animation")
	character.skeleton.IgnoreShadows = true;
	%Row3.temp_spawncardatposition(0)
	
	character=%Row3.get_node("%Character3D_3").character2d
	character.load_character("images/monsters/theBottom/angryGremlin/skeleton.atlas", "images/monsters/theBottom/angryGremlin/skeleton.json", -10)		
	character.load_animation("idle")
	character.skeleton.IgnoreShadows = true;
	%Row3.temp_spawncardatposition(1)	
	
	character=%Row3.get_node("%Character3D_4").character2d
	character.load_character("images/monsters/theBottom/wizardGremlin/skeleton.atlas", "images/monsters/theBottom/wizardGremlin/skeleton.json", -14)	
	character.load_animation("animation")
	character.skeleton.IgnoreShadows = true;
	%Row3.temp_spawncardatposition(2)

	character=%Row3.get_node("%Character3D_5").character2d
	character.load_character("images/monsters/theBottom/fatGremlin/skeleton.atlas", "images/monsters/theBottom/fatGremlin/skeleton.json", -5)	
	character.load_animation("animation")
	character.skeleton.IgnoreShadows = true;
	%Row3.temp_spawncardatposition(3)

	character=%Row4.get_node("%Character3D_2").character2d
	character.load_character("images/monsters/theBottom/louseRed/skeleton.atlas", "images/monsters/theBottom/louseRed/skeleton.json", -3)
	character.load_animation("idle")
	character.skeleton.IgnoreShadows = true;
	%Row4.temp_spawncardatposition(0)
	
	character=%Row4.get_node("%Character3D_3").character2d
	character.load_character("images/monsters/theBottom/louseGreen/skeleton.atlas", "images/monsters/theBottom/louseGreen/skeleton.json", -3)
	character.load_animation("idle")
	character.skeleton.IgnoreShadows = true;
	%Row4.temp_spawncardatposition(1)

	character=%Row4.get_node("%Character3D_4").character2d
	character.load_character("images/monsters/theBottom/louseRed/skeleton.atlas", "images/monsters/theBottom/louseRed/skeleton.json", -3)
	character.load_animation("idle")
	character.skeleton.IgnoreShadows = true;
	%Row4.temp_spawncardatposition(2)
	


#func _process(_delta):
	#var watcher = %Row4.get_node("%Character3D_1").character2d
	#eye.skeleton.SetPosition(watcher.skeleton.X + eye_bone.WorldX, watcher.skeleton.Y + eye_bone.WorldY)
	#eye.skeleton.SetColor(watcher.skeleton.GetColor())
	#eye.skeleton.MatchFlip(watcher.skeleton)

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		eye.queue_free()
