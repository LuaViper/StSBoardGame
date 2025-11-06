class_name GodotSkeletonMeshRenderer



#class_name GodotSkeletonMeshRenderer
#
#var quad_triangles = [0, 1, 2, 2, 3, 0]
#var premultiplied_alpha:bool
#
##var RegionAttachment = load("res://spine-3402-csharp/src/Attachments/RegionAttachment.cs")
##var MeshAttachment = load("res://spine-3402-csharp/src/Attachments/MeshAttachment.cs")
##var SkeletonAttachment = load("res://spine-3402-csharp/src/Attachments/SkeletonAttachment.cs")
## RegionAttachment, MeshAttachment, <s>and SkeletonAttachment</s> are registered as [GlobalClass]
#
#func _init():
	#pass
##
#func draw_skeleton(batch:CanvasItem, skeleton):	
	#var vertices = null
	#var triangles = null
	#var draw_order = skeleton.GetDrawOrderArray()
#
	#for slot in draw_order:
		#var attachment = slot.attachment
		#var texture = null
#
		#if attachment is RegionAttachment:
			#vertices = attachment.ComputeWorldVertices(slot, premultiplied_alpha)
			#triangles = quad_triangles
			#texture = attachment.GetRegionTexture();
#
		#elif attachment is MeshAttachment:
			#vertices = attachment.ComputeWorldVertices(slot, premultiplied_alpha)
			#triangles = attachment.Triangles
			#texture = attachment.GetRegionTexture();
#
		##SkeletonAttachment doesn't exist in the offical runtimes!
#
		#if texture:
			#var blend_mode = slot.Data.BlendMode
			##TODO: PolygonSpriteBatch.class
			##batch.set_blend_mode(blend_mode.get_source(premultiplied_alpha), blend_mode.get_dest())			
			##batch.draw(texture, vertices, 0, len(vertices), triangles, 0, len(triangles))
			#
			##HOMEBREW: do not draw nodes named "shadow"
			##TODO: consider drawing shadow nodes exactly once in a second rendering pass
			#if(slot.data.name!="shadow"):
				#batch.draw_implementation(texture, vertices, triangles)
#
#func set_premultiplied_alpha(premultiplied_alpha:bool):
	#self.premultiplied_alpha = premultiplied_alpha
