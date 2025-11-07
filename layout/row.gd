extends Node3D

var monster_card_positions=[]

func _ready():
	monster_card_positions.append(%MonsterCardPosition1)
	monster_card_positions.append(%MonsterCardPosition2)
	monster_card_positions.append(%MonsterCardPosition3)
	monster_card_positions.append(%MonsterCardPosition4)
	monster_card_positions.append(%MonsterCardPosition5)

	%Character3D_1.load("images/monsters/theBottom/louseGreen/skeleton.atlas",
					"images/monsters/theBottom/louseGreen/skeleton.json",
					"idle",
					1.0)
	%Character3D_2.load("images/monsters/theBottom/cultist/skeleton.atlas", 
					"images/monsters/theBottom/cultist/skeleton.json",
					"waving",
					1.0)
	%Character3D_3.load("images/monsters/theCity/byrd/flying.atlas", 
					"images/monsters/theCity/byrd/flying.json",
					"idle_flap",
					1.0)
	%Character3D_4.load("images/monsters/theForest/spaghetti/skeleton.atlas", 
					"images/monsters/theForest/spaghetti/skeleton.json",
					"Idle",
					1.0)
	%Character3D_5.load("images/monsters/theBottom/nobGremlin/skeleton.atlas", "images/monsters/theBottom/nobGremlin/skeleton.json",
					"animation",
					1.0)
	%Character3D_6.load("images/monsters/theForest/donu/skeleton.atlas", "images/monsters/theForest/donu/skeleton.json",
					"Idle",
					1.0)
