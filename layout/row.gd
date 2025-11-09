extends Node3D

var monster_card_positions=[]

var Character2D = preload("res://characters/Character2D.tscn")

var Bone = load("res://spine-3402-csharp/src/Bone.cs")

var eye
var eye_bone

func _ready():
	monster_card_positions.append(%MonsterCardPosition1)
	monster_card_positions.append(%MonsterCardPosition2)
	monster_card_positions.append(%MonsterCardPosition3)
	monster_card_positions.append(%MonsterCardPosition4)
	monster_card_positions.append(%MonsterCardPosition5)
#
	#%Character3D_1.character2d.load_character("images/characters/watcher/idle/skeleton.atlas", "images/characters/watcher/idle/skeleton.json", 105)
	#%Character3D_1.character2d.load_animation("Idle",0.7)	
	##%Character3D_1.character2d.skeleton.SetColor(Color.AQUAMARINE)
	#eye_bone = %Character3D_1.character2d.skeleton.FindBone("eye_anchor")					
	#eye = Character2D.instantiate()
	#add_child(eye)
	#eye.load_character("images/characters/watcher/eye_anim/skeleton.atlas","images/characters/watcher/eye_anim/skeleton.json", 0)
	#eye.load_animation("None",1.0)
	#eye.render_target = %Character3D_1.character2d
	#%Character3D_1.character2d.skeleton.IgnoreShadows = true;
	#
	#
	#%Character3D_2.character2d.load_character("images/monsters/theBottom/cultist/skeleton.atlas", 
					#"images/monsters/theBottom/cultist/skeleton.json", 90)
	#%Character3D_2.character2d.load_animation("waving",1.0,true)
	#%Character3D_3.character2d.load_character("images/monsters/theCity/byrd/flying.atlas", 
					#"images/monsters/theCity/byrd/flying.json", 90)
	#%Character3D_3.character2d.load_animation("idle_flap",1.0)
	#%Character3D_4.character2d.load_character("images/monsters/theForest/spaghetti/skeleton.atlas", 
					#"images/monsters/theForest/spaghetti/skeleton.json", 90)
	#%Character3D_4.character2d.load_animation("Idle",1.0)
	#%Character3D_5.character2d.load_character("images/monsters/theBottom/nobGremlin/skeleton.atlas", "images/monsters/theBottom/nobGremlin/skeleton.json", 90)
	#%Character3D_5.character2d.load_animation("animation",1.0)
	#%Character3D_6.character2d.load_character("images/monsters/theForest/donu/skeleton.atlas", "images/monsters/theForest/donu/skeleton.json", 90)
	#%Character3D_6.character2d.load_animation("Idle",1.0)
##
#func _process(_delta):
	#var watcher = %Character3D_1.character2d
	#eye.skeleton.SetPosition(watcher.skeleton.X + eye_bone.WorldX, watcher.skeleton.Y + eye_bone.WorldY)
	#eye.skeleton.SetColor(watcher.skeleton.GetColor())
	#eye.skeleton.MatchFlip(watcher.skeleton)
#
#func _notification(what):
	#if what == NOTIFICATION_PREDELETE:
		#eye.queue_free()

var CharacterCard3D = preload("res://characters/character_card_3d.tscn")

func temp_spawncardatposition(pos):
	var card = CharacterCard3D.instantiate()
	add_child(card)
	card.position=Vector3(monster_card_positions[pos].position.x,monster_card_positions[pos].position.y,monster_card_positions[pos].position.z)
	#card.rotation.x=PI
	card.test()
	pass
