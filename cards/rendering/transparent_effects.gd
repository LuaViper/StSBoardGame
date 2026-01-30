class_name TransparentEffects
extends Area2D

var card:AbstractCard
var glow_path = "512/bg_skill_silhouette"

const BLUE_BORDER_GLOW_COLOR:Color = Color(0.2, 0.9, 1.0, 0.25)
const GREEN_BORDER_GLOW_COLOR:Color = Color(0.0, 1.0, 0.0, 0.25)
const GOLD_BORDER_GLOW_COLOR:Color = Color(Color.GOLD)

func _draw():
	#print("(draw)")
	#TODO: glow shouldn't cast shadows. create a 3rd material on card for glows?
	#TODO: skip if card.face_is_hidden()
	if(card && glow_path):
		for glow in card.glow_list:
			AtlasHelper.CARDUI.draw_to_canvas_centered(glow_path,self,glow.OFFSET,glow.scale,glow.color)
	
