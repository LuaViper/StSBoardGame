class_name SkeletonRenderer

var premultiplied_alpha: bool = false

func _init():
	pass

func draw(batch, skeleton):
	var premultiplied_alpha = self.premultiplied_alpha
	var draw_order = skeleton.draw_order

	for slot in draw_order:
		var attachment = slot.attachment
		if attachment is RegionAttachment:
			var region_attachment = attachment
			var vertices = region_attachment.update_world_vertices(slot, premultiplied_alpha)
			var blend_mode = slot.data.get_blend_mode()
			batch.set_blend_function(blend_mode.get_source(premultiplied_alpha), blend_mode.get_dest())
			batch.draw(region_attachment.get_region().get_texture(), vertices, 0, 20)
		elif attachment is MeshAttachment:
			push_error("SkeletonMeshRenderer is required to render meshes.")
		elif attachment is SkeletonAttachment:
			var attachment_skeleton = attachment.get_skeleton()
			if attachment_skeleton:
				var bone = slot.get_bone()
				var root_bone = attachment_skeleton.get_root_bone()
				var old_scale_x = root_bone.get_scale_x()
				var old_scale_y = root_bone.get_scale_y()
				var old_rotation = root_bone.get_rotation()

				attachment_skeleton.set_position(skeleton.get_x() + bone.get_world_x(), skeleton.get_y() + bone.get_world_y())
				root_bone.set_rotation(old_rotation + bone.get_world_rotation_x())
				attachment_skeleton.update_world_transform()

				draw(batch, attachment_skeleton)

				attachment_skeleton.set_x(0)
				attachment_skeleton.set_y(0)
				root_bone.set_scale_x(old_scale_x)
				root_bone.set_scale_y(old_scale_y)
				root_bone.set_rotation(old_rotation)

func set_premultiplied_alpha(premultiplied_alpha: bool):
	self.premultiplied_alpha = premultiplied_alpha
