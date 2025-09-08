class_name Card2DRenderingViewport
extends SubViewport

@onready var card_2d: Card2D = $Card2D

#var img_path

func set_card(library_card):
	#self.img_path=img_path
	await ready	
	var color_str:String
	match(library_card.get("color")):
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
	var type_str:String = library_card.get("type").to_lower()
	var frame_str:String = type_str
	match frame_str:
		"curse":
			frame_str="skill"
		"ticket":
			frame_str="power"
	var rarity_str:String = library_card.get("rarity").to_lower()
	match rarity_str:
		"starter","curse":
			rarity_str="common"
		"ticket":
			rarity_str="rare"
	card_2d.bg_path = "512/bg_"+type_str+"_"+color_str	
	card_2d.img_path = library_card.get("imagepath")
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
	card_2d.orb_path = "512/card_"+color_str+"_orb"
	#TODO: vgname isn't card_title -- vgname should be a link to an entry in localization/eng/cards.json
	card_2d.card_title = LocalizationHelper.CARDS.eng[library_card.get("vgname")].NAME
	
	card_2d.card_type_name = library_card.get("type").capitalize()
	card_2d.card_cost_text = library_card.get("cost")
	if(not card_2d.card_cost_text is String):
		card_2d.card_cost_text = String.num(card_2d.card_cost_text,0)
	card_2d.card_description = library_card.get("text")
	
	card_2d.queue_redraw()
	
	
	
	
	
