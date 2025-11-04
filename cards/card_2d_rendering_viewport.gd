class_name Card2DRenderingViewport
extends SubViewport

@onready var card_2d: Card2D = $Card2D

#var img_path

func set_card(card:AbstractCard):
	#TODO: some of this should probably be moved to either abstract_card or card_2d
	#self.img_path=img_path
	await ready	
	var color_str:String
	match(card.data.color):
		"BGRed":
			color_str="red"
			card_2d.orb_offset_x=-22
			card_2d.orb_offset_y=-16
		"BGGreen":
			color_str="green"
		"BGBlue":
			color_str="blue"
			card_2d.orb_offset_x=-19
			card_2d.orb_offset_y=-13			
		"BGPurple":
			color_str="purple"
		"BGColorless","BGStatus":
			#TODO: 1024 files use "colorless" instead of "gray"
			color_str="gray"
			card_2d.orb_offset_x=-19
			card_2d.orb_offset_y=-13
		"BGCurse":
			color_str="black"
			card_2d.orb_offset_x=-19
			card_2d.orb_offset_y=-13		
	var orb_str
	match(color_str):
		"gray","black","status":
			orb_str="colorless"
			#curse orb appears to be the exact same color as colorless, no blending needed
		_:
			orb_str=color_str
	var type_str:String = card.data.type.to_lower()
	var frame_str:String = type_str
	match frame_str:
		"curse","status":
			frame_str="skill"
		"ticket":
			frame_str="power"
	var rarity_str:String = card.data.rarity.to_lower()
	match rarity_str:
		"starter","curse","status":
			rarity_str="common"
		"ticket":
			rarity_str="rare"
	card_2d.bg_path = "512/bg_"+frame_str+"_"+color_str	
	card_2d.img_path = card.data.imagepath
	card_2d.frame_path = "512/frame_"+frame_str+"_"+rarity_str
	match frame_str:
		"attack":
			card_2d.frame_offset_x = 18
			card_2d.frame_offset_y = 59
		"skill":
			card_2d.frame_offset_x = 18
			card_2d.frame_offset_y = 58
		"power":
			card_2d.frame_offset_x = 15
			card_2d.frame_offset_y = 3
			
	card_2d.banner_path = "512/banner_"+rarity_str
	card_2d.orb_path = "512/card_"+orb_str+"_orb" if(card.data.cost!="NONE") else ""
	#TODO: vgname isn't card_title -- vgname should be a link to an entry in localization/eng/cards.json
	if(card.data.vgname!="SPECIAL"):
		card_2d.card_title = LocalizationHelper.CARDS.eng[card.data.vgname].NAME
	else:
		#TODO: handle SPECIAL vgname (golden ticket)
		pass
	
	card_2d.card_type_name = card.data.type.capitalize()
	card_2d.card_cost_text = card.data.cost if(card.data.cost!="NONE") else ""
	#if(not card_2d.card_cost_text is String):
	#	card_2d.card_cost_text = String.num(card_2d.card_cost_text,0)
	#card_2d.card_description = card.data.text
	card_2d.card_description = card.get_text()
	
	card_2d.queue_redraw()
	
	
	
	
	
