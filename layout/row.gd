extends Node3D

var monster_card_positions=[]

func _ready():
	monster_card_positions.append(%MonsterCardPosition1)
	monster_card_positions.append(%MonsterCardPosition2)
	monster_card_positions.append(%MonsterCardPosition3)
	monster_card_positions.append(%MonsterCardPosition4)
	monster_card_positions.append(%MonsterCardPosition5)

	%Character3D_1.character2d.load_character("images/characters/watcher/idle/skeleton.atlas", "images/characters/watcher/idle/skeleton.json",
					"Idle",
					0.7)
	%Character3D_2.character2d.load_character("images/monsters/theBottom/cultist/skeleton.atlas", 
					"images/monsters/theBottom/cultist/skeleton.json",
					"waving",
					1.0)
	%Character3D_3.character2d.load_character("images/monsters/theCity/byrd/flying.atlas", 
					"images/monsters/theCity/byrd/flying.json",
					"idle_flap",
					1.0)
	%Character3D_4.character2d.load_character("images/monsters/theForest/spaghetti/skeleton.atlas", 
					"images/monsters/theForest/spaghetti/skeleton.json",
					"Idle",
					1.0)
	%Character3D_5.character2d.load_character("images/monsters/theBottom/nobGremlin/skeleton.atlas", "images/monsters/theBottom/nobGremlin/skeleton.json",
					"animation",
					1.0)
	%Character3D_6.character2d.load_character("images/monsters/theForest/donu/skeleton.atlas", "images/monsters/theForest/donu/skeleton.json",
					"Idle",
					1.0)
