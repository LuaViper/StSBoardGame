class_name Card2D
extends Node2D

var bg_path = "512/bg_attack_red";
var img_path = "red/attack/whirlwind";
var frame_path = "512/frame_attack_uncommon";
var banner_path = "512/banner_uncommon";
var orb_path = "512/card_red_orb";
var card_title = "Whirlwind"
var card_type_name = "Attack"
var card_cost_text = "X"
var card_description = "Deal 5 damage to ALL enemies X times."
var frame_offset_x = 18
var frame_offset_y = 59
var orb_offset_x = -22
var orb_offset_y = -16

var textures={}

func _draw():
	if(img_path):
		#%Card2D.draw_circle(Vector2(0,0),50,Color.ORANGE_RED)
		#%Card2D.draw_circle(Vector2(200,200),50,Color.ORANGE_RED)
		#draw_circle(Vector2(100,100),50,Color.ORANGE_RED)
		#var path:String = "C:\\Program Files (x86)\\Steam\\steamapps\\common\\SlayTheSpire\\desktop-1.0.jar"	
		AtlasHelper.CARDUI.draw_to_canvas(bg_path,self,Vector2i(-304/2,-419/2))
		if(img_path!="SPECIAL"):		
			AtlasHelper.CARDS.draw_to_canvas(img_path,self,Vector2i(-304/2+26,-419/2+45))				
		else:
			#TODO: handle SPECIAL (golden ticket)
			pass
		AtlasHelper.CARDUI.draw_to_canvas(frame_path,self,Vector2i(-304/2+frame_offset_x,-419/2+frame_offset_y))
		AtlasHelper.CARDUI.draw_to_canvas(banner_path,self,Vector2i(-304/2-13,-419/2+16))
		if(orb_path):
			AtlasHelper.CARDUI.draw_to_canvas(orb_path,self,Vector2i(-304/2+orb_offset_x,-419/2+orb_offset_y))
		##%Card2D.queue_redraw()
		#draw_texture_rect_region(src,Rect2(dest_xy.x,dest_xy.y,wid,hgt),Rect2(x,y,wid,hgt))		
	%NameLabel.clear()
	%NameLabel.push_font(FontHelper.KREON_REGULAR_CARDNAME,23)	
	%NameLabel.add_text(card_title)
	%NameLabel.pop_all()
	%CostLabel.clear()	
	%CostLabel.push_font(FontHelper.KREON_BOLD,36)	
	%CostLabel.add_text(card_cost_text)
	%CostLabel.pop_all()		
	%DescriptionLabel.clear()
	%DescriptionLabel.push_font(FontHelper.KREON_REGULAR_CARDDESCRIPTION,24)	
	#card_description = CardAutotextHelper.parse(card_description)
	%DescriptionLabel.append_text(card_description)
	%DescriptionLabel.pop_all()
	%TypeLabel.clear()
	%TypeLabel.push_font(FontHelper.KREON_REGULAR,17)	
	%TypeLabel.add_text(card_type_name)
	%TypeLabel.pop_all()	
