extends Node2D
#
var src:SpineRenderingControls
#var target:Node2D

func _ready():
	print("SpineRenderingNode.ready")
	src = SpineRenderingControls.new()

func _process(delta):	
	#if(%target):
		#target=%target
	if(!src.state || !src.skeleton): 
		return
	src.state.Update(delta)
	src.state.Apply(src.skeleton)
	src.skeleton.UpdateWorldTransform()
	#src.skeleton.SetPosition(512/2,512-100)
	src.skeleton.SetPosition(512/2,512-90)
	src.skeleton.SetColor(Color.WHITE) #TODO:		
	queue_redraw()
	
func _draw():		
	if(!src.state || !src.skeleton):
		return
	src.sr.DrawSkeletonToCanvas(self,src.skeleton)
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
		
	


func draw_mesh_item(mesh_item, name):
	if(name.to_lower().ends_with("shadow")):
		return
	var vert2s:PackedVector2Array = []
	var colors:PackedColorArray = []
	var uvs:PackedVector2Array = []
	var vertices = mesh_item.vertices
	var triangles = mesh_item.triangles
	var texture = mesh_item.texture
	for v in range(0,len(vertices)):
		var vertex=vertices[v]
		var v2:Vector2 = Vector2(vertex.position.x,vertex.position.y)
		#var color:Color = NumberUtils.float_to_color(vertices.color)
		var color:Color = vertex.color
		#var color:Color = Color.CYAN
		#var color:Color = Color(.4,.4,.4,.4)
		var uv:Vector2 = vertex.textureCoordinate
		#TODO: use resize instead of appendloop
		vert2s.append(v2)
		colors.append(color)
		uvs.append(uv)
	for t in range(0,len(triangles),3):
		var i0:int = triangles[t]
		var i1:int = triangles[t+1]
		var i2:int = triangles[t+2]
		
		var polygon_vert2s:PackedVector2Array = [vert2s[i0],vert2s[i1],vert2s[i2]]
		var polygon_colors:PackedColorArray = [colors[i0],colors[i1],colors[i2]]
		var polygon_uvs:PackedVector2Array = [uvs[i0],uvs[i1],uvs[i2]]
	
		draw_polygon(polygon_vert2s,polygon_colors,polygon_uvs,texture)
	pass
