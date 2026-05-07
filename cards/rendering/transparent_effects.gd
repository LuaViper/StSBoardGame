class_name TransparentEffects
extends Area2D

var card:AbstractCard
var glow_path = "512/bg_skill_silhouette"
var superflash_path = "512/card_flash_vfx"

const BLUE_BORDER_GLOW_COLOR:Color = Color(0.2, 0.9, 1.0, 0.25)
const GREEN_BORDER_GLOW_COLOR:Color = Color(0.0, 1.0, 0.0, 0.25)
const GOLD_BORDER_GLOW_COLOR:Color = Color(Color.GOLD)

#TO DO LATER: the fact that we want to stretch the glow suggests that the card model is the wrong size
const GLOW_STRETCH_MODIFIER = 1.05

#Reminder: TransparentEffects uses a modified CanvasItemMaterial with Premultiplied Alpha blend mode

func _draw():
	#TODO: skip if card.face_is_hidden()
	if(card && glow_path):

		#this appears to be functionally identical to vanilla flash but it renders a bit differently
		for flash in card.flash_list:
			if(flash.is_super):
				#reminder: is_super flash uses different taller yscale
				AtlasHelper.CARDUI.draw_to_canvas_centered(superflash_path,self,flash.OFFSET,0.53*Vector2(flash.scale*GLOW_STRETCH_MODIFIER,flash.scale),flash.color)
				AtlasHelper.CARDUI.draw_to_canvas_centered(superflash_path,self,flash.OFFSET,0.57*Vector2(flash.scale*GLOW_STRETCH_MODIFIER,flash.scale),flash.color)
				AtlasHelper.CARDUI.draw_to_canvas_centered(superflash_path,self,flash.OFFSET,0.6*Vector2(flash.scale*GLOW_STRETCH_MODIFIER,flash.scale),flash.color)
			else:
				AtlasHelper.CARDUI.draw_to_canvas_centered(glow_path,self,flash.OFFSET,0.52*Vector2(flash.scale*GLOW_STRETCH_MODIFIER,flash.scale),flash.color)
				AtlasHelper.CARDUI.draw_to_canvas_centered(glow_path,self,flash.OFFSET,0.55*Vector2(flash.scale*GLOW_STRETCH_MODIFIER,flash.scale),flash.color)
				AtlasHelper.CARDUI.draw_to_canvas_centered(glow_path,self,flash.OFFSET,0.58*Vector2(flash.scale*GLOW_STRETCH_MODIFIER,flash.scale),flash.color)
			
		for glow in card.glow_list:
			AtlasHelper.CARDUI.draw_to_canvas_centered(glow_path,self,glow.OFFSET,Vector2(glow.scale*GLOW_STRETCH_MODIFIER,glow.scale),glow.color)
