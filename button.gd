extends Button

var trc
var text_rendering_viewport = preload("res://text_rendering_viewport.tscn")

func _on_pressed() -> void:	
	print("Hello, world!")	

#
	#var pba:PackedByteArray=PackedByteArray()
	#pba.resize(32)
	#pba.encode_float(0,7.5)
	#print("_int_to_float_color: ",7.5," became ",pba.decode_s32(0))	
	#
	#
	print("3 & 6 = ",3 & 6)
	
	
	
	var install_location = "C:/Program Files (x86)/Steam/steamapps/common/SlayTheSpire/desktop-1.0.jar"
	var reader = ZIPReader.new()
	var err = reader.open(install_location)
	if err != OK:
		print("err")
		return
	#var stances = reader.read_file("localization/eng/stances.json")
	#print(stances.get_string_from_utf8())
		
	var face = Image.create_empty(808,1038,false,Image.FORMAT_RGBA8)	
		
	AtlasHelper.CARDUI.draw_to_image("1024/bg_attack_red",face,Vector2i(100,100))
	
	if(true):
		#var portrait = reader.read_file("images/1024Portraits/red/attack/cleave.png")
		var portrait = reader.read_file("images/1024Portraits/red/attack/whirlwind.png")
		var src = Image.new()
		src.load_png_from_buffer(portrait)
		face.blend_rect(src,Rect2i(0,0,500,380),Vector2i(100+50,100+66))

	AtlasHelper.CARDUI.draw_to_image("1024/frame_attack_uncommon",face,Vector2i(100+40,100+115))	
	AtlasHelper.CARDUI.draw_to_image("1024/banner_uncommon",face,Vector2i(100-25,100+20))
	AtlasHelper.CARDUI.draw_to_image("1024/card_red_orb",face,Vector2i(100-40,100-40))
	
	#var back = Image.load_from_file("res://card_cardtexture.png")
	#var back = Image.create_empty(808,808,false,Image.FORMAT_RGBA8)	
	var back = Image.load_from_file("res://card_cardtexture.png")
	back.convert(Image.FORMAT_RGBA8)	
	AtlasHelper.CARDUI.draw_to_image("512/card_back",back,Vector2i(0,0),2)	
			
	#const DESCRIPTION="Wow! Rendering text to a card texture is obnoxiously difficult in Godot. I need a break. Time to unwind with some nice, easy Defect A20H Busted Crown swaps."
	#const DESCRIPTION="Deal 8 damage to ALL enemies."
	const DESCRIPTION="Deal 5 damage to ALL enemies X times."
	FontHelper.render_card_description(DESCRIPTION, %Card1, FontHelper.KREON_REGULAR)
	reader.close()

	if(true):
		var texture = ImageTexture.new()
		texture.set_image(face)		
		var material = StandardMaterial3D.new()
		material.set_transparency(2) #TRANSPARENCY_ALPHA_SCISSOR
		material.albedo_texture = texture
		var mesh_instance_node = %Card1.get_node("%Card3D").get_node("Card")
		mesh_instance_node.set_surface_override_material(1,material)
	
	if(true):
		var texture = ImageTexture.new()
		texture.set_image(back)	#can we change this to ImageTexture.create_from_image?
		var material = StandardMaterial3D.new()
		material.set_transparency(2) #TRANSPARENCY_ALPHA_SCISSOR
		material.albedo_texture = texture
		var mesh_instance_node = %Card1.get_node("%Card3D").get_node("Card")
		mesh_instance_node.set_surface_override_material(0,material)	
	
	
	
	err = reader.open(install_location)
	if err != OK:
		print("err")
		return
	

	
	
	print("OK bye.")


func _on_button_2_pressed() -> void:
	pass # Replace with function body.
