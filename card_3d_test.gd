extends StaticBody3D

func test(viewport:Card2DRenderingViewport):
	var tex:ViewportTexture = viewport.get_texture()
	var img:Image = tex.get_image()
	#print(img.get_pixel(90,90))
	var mesh_instance_node = get_node("%Card3DModel").get_node("Card")

	var material
	material = StandardMaterial3D.new()
	material.set_transparency(2) #TRANSPARENCY_ALPHA_SCISSOR
	material.albedo_texture = tex		
	mesh_instance_node.set_surface_override_material(1,material)

	material = StandardMaterial3D.new()
	material.set_transparency(2) #TRANSPARENCY_ALPHA_SCISSOR
	material.albedo_texture = load("card_cardtexture.png")
	mesh_instance_node.set_surface_override_material(0,material)


	
