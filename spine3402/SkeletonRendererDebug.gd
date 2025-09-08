#class_name SkeletonRendererDebug
#
#var bone_line_color = Color.RED
#var bone_origin_color = Color.GREEN
#var attachment_line_color = Color(0, 0, 1, 0.5)
#var triangle_line_color = Color(1, 0.64, 0, 0.5)
#var aabb_color = Color(0, 1, 0, 0.5)
#
#var shapes = ShapeRenderer.new()
#var draw_bones = true
#var draw_region_attachments = true
#var draw_bounding_boxes = true
#var draw_mesh_hull = true
#var draw_mesh_triangles = true
#var draw_paths = true
#var bounds = SkeletonBounds.new()
#var temp = []
#var scale = 1.0
#var bone_width = 2.0
#var premultiplied_alpha = false
#
#func _init():
	#pass
#
#func draw(skeleton):
	#var skeleton_x = skeleton.get_x()
	#var skeleton_y = skeleton.get_y()
#
	#var src_func = 1 if premultiplied_alpha else 770
	#shapes.set_blend_function(src_func, 771)
#
	#var bones = skeleton.get_bones()
	#if draw_bones:
		#shapes.set_color(bone_line_color)
		#shapes.begin(ShapeRenderer.FILL)
		#for bone in bones:
			#if bone.parent:
				#var x = skeleton_x + bone.data.length * bone.a + bone.world_x
				#var y = skeleton_y + bone.data.length * bone.c + bone.world_y
				#shapes.rect_line(skeleton_x + bone.world_x, skeleton_y + bone.world_y, x, y, bone_width * scale)
		#shapes.end()
		#shapes.begin(ShapeRenderer.LINE)
		#shapes.draw_point(skeleton_x, skeleton_y, 4.0 * scale)
	#else:
		#shapes.begin(ShapeRenderer.LINE)
#
	#if draw_region_attachments:
		#shapes.set_color(attachment_line_color)
		#for slot in skeleton.get_slots():
			#var attachment = slot.attachment
			#if attachment is RegionAttachment:
				#var region_attachment = attachment
				#var vertices = region_attachment.update_world_vertices(slot, false)
				#shapes.line(vertices[0], vertices[1], vertices[5], vertices[6])
				#shapes.line(vertices[5], vertices[6], vertices[10], vertices[11])
				#shapes.line(vertices[10], vertices[11], vertices[15], vertices[16])
				#shapes.line(vertices[15], vertices[16], vertices[0], vertices[1])
#
	## Convert MeshAttachment logic
	#if draw_mesh_hull or draw_mesh_triangles:
		#for slot in skeleton.get_slots():
			#var attachment = slot.attachment
			#if attachment is MeshAttachment:
				#var mesh = attachment
				#mesh.update_world_vertices(slot, false)
				#var vertices = mesh.get_world_vertices()
				#var triangles = mesh.get_triangles()
				#var hull_length = mesh.get_hull_length()
#
				#if draw_mesh_triangles:
					#shapes.set_color(triangle_line_color)
					#for ii in range(0, triangles.size(), 3):
						#shapes.triangle(vertices[triangles[ii] * 5], vertices[triangles[ii] * 5 + 1],
										#vertices[triangles[ii + 1] * 5], vertices[triangles[ii + 1] * 5 + 1],
										#vertices[triangles[ii + 2] * 5], vertices[triangles[ii + 2] * 5 + 1])
#
				#if draw_mesh_hull and hull_length > 0:
					#shapes.set_color(attachment_line_color)
					#hull_length = (hull_length >> 1) * 5
					#var last_x = vertices[hull_length - 5]
					#var last_y = vertices[hull_length - 4]
					#for ii in range(0, hull_length, 5):
						#var x = vertices[ii]
						#var y = vertices[ii + 1]
						#shapes.line(x, y, last_x, last_y)
						#last_x = x
						#last_y = y
#
	## Bounding boxes
	#if draw_bounding_boxes:
		#bounds.update(skeleton, true)
		#shapes.set_color(aabb_color)
		#shapes.rect(bounds.get_min_x(), bounds.get_min_y(), bounds.get_width(), bounds.get_height())
		#for i in range(bounds.get_polygons().size()):
			#var polygon = bounds.get_polygons()[i]
			#shapes.set_color(bounds.get_bounding_boxes()[i].get_color())
			#shapes.polygon(polygon, 0, polygon.size())
#
	#shapes.end()
#
#func set_bones(value: bool):
	#draw_bones = value
#
#func set_scale(value: float):
	#scale = value
#
#func set_region_attachments(value: bool):
	#draw_region_attachments = value
#
#func set_bounding_boxes(value: bool):
	#draw_bounding_boxes = value
#
#func set_mesh_hull(value: bool):
	#draw_mesh_hull = value
#
#func set_mesh_triangles(value: bool):
	#draw_mesh_triangles = value
#
#func set_paths(value: bool):
	#draw_paths = value
#
#func set_premultiplied_alpha(value: bool):
	#premultiplied_alpha = value
