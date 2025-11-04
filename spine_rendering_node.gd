extends Node2D

var src:SpineRenderingControls
#var target:Node2D

func _init():
	src = SpineRenderingControls.new()

func _process(delta):	
	#if(%target):
		#target=%target
	if(!src.state || !src.skeleton): 
		return
	src.state.update(delta)
	src.state.apply(src.skeleton)
	src.skeleton.update_world_transform()
	src.skeleton.set_position(512/2,512-100)
	#skeleton.set_color(Color.WHITE) #TODO:		
	queue_redraw()
	
func _draw():		
	if(!src.state || !src.skeleton):
		return
	src.sr.draw_skeleton(self,src.skeleton)
	if(src.target_sprite):
		#var src_texture = src.viewport.get_texture()		
		#
		#if(!(src.target_sprite.get_texture() is ImageTexture)):			
			#src.target_sprite.set_texture(ImageTexture.new())
		#var dest_texture = src.target_sprite.get_texture()
		##dest_texture.viewport_path = ".."
		##print($"..")

		# Retrieve the captured Image using get_image().
		var img = src.viewport.get_texture().get_image()
		# Convert Image to ImageTexture.
		var tex = ImageTexture.create_from_image(img)
		# Set sprite texture.
		src.target_sprite.texture = tex
	
		
		
		#src.target_sprite.set_texture(Texture2D.new())
		
		#destimage.blend_rect(viewimage,Rect2i(0,0,1024,1024),Vector2i(pos.x-512,pos.y-512))
		##destimage.save_png("user://test2.png")
		#var texture = ImageTexture.new()
		#texture.set_image(destimage)		
		#var material = StandardMaterial3D.new()
		#material.set_transparency(2) #TRANSPARENCY_ALPHA_SCISSOR
		#material.albedo_texture = texture		
		#mesh_instance_node.set_surface_override_material(1,material)
		
	
func draw_implementation(texture,vertices,polygons):
	#if(!target):
		#return;
	#TODO: learn to use canvas_item_add_triangle_array instead
	var vert2s:PackedVector2Array = []
	var colors:PackedColorArray = []
	var uvs:PackedVector2Array = []
	for v in range(0,len(vertices),5):
		var v2:Vector2 = Vector2(vertices[v],vertices[v+1])
		var color:Color = NumberUtils.float_to_color(vertices[v+2])
		#var color:Color = Color.CYAN
		#var color:Color = Color(.4,.4,.4,.4)
		var uv:Vector2 = Vector2(vertices[v+3],vertices[v+4])
		#TODO: use resize instead of appendloop
		vert2s.append(v2)
		colors.append(color)
		uvs.append(uv)
	for p in range(0,len(polygons),3):
		var i0:int = polygons[p]
		var i1:int = polygons[p+1]
		var i2:int = polygons[p+2]
		
		var polygon_vert2s:PackedVector2Array = [vert2s[i0],vert2s[i1],vert2s[i2]]
		var polygon_colors:PackedColorArray = [colors[i0],colors[i1],colors[i2]]
		var polygon_uvs:PackedVector2Array = [uvs[i0],uvs[i1],uvs[i2]]
	
		draw_polygon(polygon_vert2s,polygon_colors,polygon_uvs,texture)
	
