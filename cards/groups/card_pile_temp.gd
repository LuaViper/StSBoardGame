extends Node3D

var ingame_name = "(Unnamed card pile)"
var card3D = preload("res://cards/rendering/card_3d.tscn")
var viewport = preload("res://cards/rendering/card_2d_rendering_viewport.tscn")
var transparents = preload("res://cards/rendering/transparent_effects_rendering_viewport.tscn")

var EFFECTIVE_CARD_WIDTH = 0.03
var face_down = false

func _ready():
	%PLACEHOLDER.queue_free()

func temp_add_card(cardname):
	#TODO: when we do this for real, face-down cards don't render their front side
	
	##Wait until Globals.main reference exists
	#await get_tree().root.ready
	
	var card = Globals.card_library.card_list[cardname].make_copy()
	card.owner = Globals.sandbox_player
	card._set_location(card.owner.draw_pile)
	
	var c2rvp:Card2DRenderingViewport=viewport.instantiate()
	c2rvp.set_card(card);
	Globals.main.add_child(c2rvp)
	
	var cards = get_node("%Cards")
	var cards_contents = cards.get_children()
	var c3=card3D.instantiate()
	c3.position=Vector3(0,0.03*cards_contents.size(),0)
	c3.rotation=Vector3(0,0,int(face_down)*PI)
	c3.scale=Vector3(1,1,1)
	cards.add_child(c3)
	c3.attach_2d_card_viewport(c2rvp)
	
	var terp:TransparentEffectsRenderingViewport=transparents.instantiate()
	terp.set_card(card);
	Globals.main.add_child(terp)
	c3.attach_transparent_effects_viewport(terp)
	
	return c3
	
	#print("!")
	

func temp_setup():
	face_down=true
	temp_add_card("BGStrike_Red")
	temp_add_card("BGStrike_Red")
	temp_add_card("BGBash")
	temp_add_card("BGStrike_Red")
	temp_add_card("BGDefend_Red")
	temp_add_card("BGDefend_Red")	
	temp_add_card("BGStrike_Red")	
	temp_add_card("BGDefend_Red")
	temp_add_card("BGStrike_Red")
	temp_add_card("BGInflame")
	temp_add_card("BGDefend_Red")
	pass

func _to_string()->String:
	return ingame_name
	
func _physics_process_position_card(_delta,card:AbstractCard):
	var lerp_speed=0.03
	var transform = Transform3D(self.global_transform)
	
	transform = transform.interpolate_with(transform,lerp_speed)
