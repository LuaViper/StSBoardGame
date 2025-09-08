class_name SkeletonMeshRenderer

var quad_triangles = [0, 1, 2, 2, 3, 0]
var premultiplied_alpha:bool

func _init():
	pass

func draw_skeleton(batch:CanvasItem, skeleton):	
	var vertices = null
	var triangles = null
	var draw_order = skeleton.draw_order

	for slot in draw_order:
		var attachment = slot.attachment
		var texture = null

		if attachment is RegionAttachment:
			vertices = attachment.update_world_vertices(slot, premultiplied_alpha)
			triangles = quad_triangles
			texture = attachment.get_region().texture

		elif attachment is MeshAttachment:
			vertices = attachment.update_world_vertices(slot, premultiplied_alpha)
			triangles = attachment.get_triangles()
			texture = attachment.get_region().texture

		elif attachment is SkeletonAttachment:
			var attachment_skeleton = attachment.get_skeleton()
			if not attachment_skeleton:
				continue

			var bone = slot.get_bone()
			var root_bone = attachment_skeleton.get_root_bone()
			var old_scale_x = root_bone.get_scale_x()
			var old_scale_y = root_bone.get_scale_y()
			var old_rotation = root_bone.get_rotation()

			attachment_skeleton.set_position(Vector2(skeleton.position.x + bone.get_world_x(), skeleton.position.y + bone.get_world_y()))
			root_bone.set_rotation(old_rotation + bone.get_world_rotation_x())
			attachment_skeleton.update_world_transform()
			draw_skeleton(batch, attachment_skeleton)

			attachment_skeleton.set_position(Vector2(0, 0))
			root_bone.set_scale_x(old_scale_x)
			root_bone.set_scale_y(old_scale_y)
			root_bone.set_rotation(old_rotation)

		if texture:
			var blend_mode = slot.data.get_blend_mode()
			#TODO: PolygonSpriteBatch.class
			#batch.set_blend_mode(blend_mode.get_source(premultiplied_alpha), blend_mode.get_dest())			
			#batch.draw(texture, vertices, 0, len(vertices), triangles, 0, len(triangles))
			batch.draw_implementation(texture, vertices, triangles)

func set_premultiplied_alpha(premultiplied_alpha:bool):
	self.premultiplied_alpha = premultiplied_alpha
