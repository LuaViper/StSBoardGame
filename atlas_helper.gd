extends Node

var CARDUI = Dictionary()
var CARDS = {}
var POWER_ICONS = {}
var CULTIST_SKELETON = Dictionary()

func _init():
	if(true):
		var instance
		instance = TextureAtlas.new()
		instance.load_file("cardui/cardui.atlas")
		CARDUI=instance
		instance = TextureAtlas.new()
		instance.load_file("cards/cards.atlas")
		CARDS=instance
		instance = TextureAtlas.new()
		instance.load_file("powers/powers.atlas")
		POWER_ICONS=instance
	#if(true):
		#var instance = TextureAtlas.new()
		#instance.load_file("images/monsters/theBottom/cultist/skeleton.atlas")
		#CULTIST_SKELETON=instance
