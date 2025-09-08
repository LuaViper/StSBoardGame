class_name SkeletonJson

var attachment_loader: AttachmentLoader
var scale: float = 1.0
var linked_meshes: Array = []

func _init(atlas: SpineTextureAtlas = null, attachment_loader: AttachmentLoader = null):
	if atlas:
		attachment_loader = AtlasAttachmentLoader.new(atlas)
	if attachment_loader == null:
		push_error("attachmentLoader cannot be null.")
		return
	self.attachment_loader = attachment_loader

func get_scale() -> float:
	return scale

func set_scale(new_scale: float):
	scale = new_scale

func read_skeleton_data(filename: String) -> SkeletonData:
	if filename == null:
		push_error("file cannot be null.")
		return null
	
	#var file:FileAccess = FileAccess.open(filename,FileAccess.READ)
	var file:FileAccess = ZipFunctions.extract_file_to_temp(filename)
	
	var scale = self.scale
	var skeleton_data = SkeletonData.new()
	skeleton_data.name = filename.replace(".json", "")
	
	var json_text = file.get_as_text()
	var json = JSON.parse_string(json_text)
	if json == null:
		push_error("Failed to parse JSON.")
		return null
	
	var skeleton_map = json.get("skeleton", {})
	if skeleton_map:
		skeleton_data.hash = skeleton_map.get("hash", null)
		skeleton_data.version = skeleton_map.get("spine", null)
		skeleton_data.width = float(skeleton_map.get("width", 0.0)) * scale
		skeleton_data.height = float(skeleton_map.get("height", 0.0)) * scale
		skeleton_data.images_path = skeleton_map.get("images", null)
	
	for bone_map in json.get("bones", []):
		var parent = null
		var parent_name = bone_map.get("parent", null)
		if parent_name:
			parent = skeleton_data.find_bone(parent_name)
			if parent == null:
				push_error("Parent bone not found: " + parent_name)
		
		var data = BoneData.new(skeleton_data.bones.size(), bone_map.get("name"), parent)
		data.length = float(bone_map.get("length", 0.0)) * scale
		data.x = float(bone_map.get("x", 0.0)) * scale
		data.y = float(bone_map.get("y", 0.0)) * scale
		data.rotation = float(bone_map.get("rotation", 0.0))
		data.scale_x = float(bone_map.get("scaleX", 1.0))
		data.scale_y = float(bone_map.get("scaleY", 1.0))
		data.shear_x = float(bone_map.get("shearX", 0.0))
		data.shear_y = float(bone_map.get("shearY", 0.0))
		data.inherit_rotation = bool(bone_map.get("inheritRotation", true))
		data.inherit_scale = bool(bone_map.get("inheritScale", true))
		
		var color = bone_map.get("color", null)
		if color:
			data.color = Color(color)
		
		skeleton_data.bones.append(data)
	
	for slot_map in json.get("slots", []):
		var slot_name = slot_map.get("name")
		var bone_name = slot_map.get("bone")
		var bone_data = skeleton_data.find_bone(bone_name)
		
		if bone_data == null:
			push_error("Slot bone not found: " + bone_name)
			continue
		
		var data = SlotData.new(skeleton_data.slots.size(), slot_name, bone_data)
		var color = slot_map.get("color", null)
		if color:
			data.color = Color(color)
		
		data.attachment_name = slot_map.get("attachment", null)
		data.blend_mode = slot_map.get("blend", "normal")
		skeleton_data.slots.append(data)

	# IK Constraints
	for constraint_map in json.get("ik", []):
		var data = IkConstraintData.new(constraint_map.get("name"))
		for bone_map in constraint_map.get("bones", []):
			var bone_name = bone_map
			var bone = skeleton_data.find_bone(bone_name)
			if bone == null:
				push_error("IK bone not found: " + bone_name)
			data.bones.append(bone)
		
		var target_name = constraint_map.get("target")
		data.target = skeleton_data.find_bone(target_name)
		if data.target == null:
			push_error("IK target bone not found: " + target_name)
		
		data.bend_direction = 1 if constraint_map.get("bendPositive", true) else -1
		data.mix = float(constraint_map.get("mix", 1.0))
		skeleton_data.ik_constraints.append(data)
	

	for constraint_map in json.get("transform", []):
		var data = TransformConstraintData.new(constraint_map.get("name"))
		
		for bone_name in constraint_map.get("bones", []):
			var bone = skeleton_data.find_bone(bone_name)
			if bone == null:
				push_error("Transform constraint bone not found: " + bone_name)
			data.bones.append(bone)
		
		var target_name = constraint_map.get("target")
		data.target = skeleton_data.find_bone(target_name)
		if data.target == null:
			push_error("Transform constraint target bone not found: " + target_name)

		data.offset_rotation = float(constraint_map.get("rotation", 0.0))
		data.offset_x = float(constraint_map.get("x", 0.0)) * scale
		data.offset_y = float(constraint_map.get("y", 0.0)) * scale
		data.offset_scale_x = float(constraint_map.get("scaleX", 0.0))
		data.offset_scale_y = float(constraint_map.get("scaleY", 0.0))
		data.offset_shear_y = float(constraint_map.get("shearY", 0.0))
		data.rotate_mix = float(constraint_map.get("rotateMix", 1.0))
		data.translate_mix = float(constraint_map.get("translateMix", 1.0))
		data.scale_mix = float(constraint_map.get("scaleMix", 1.0))
		data.shear_mix = float(constraint_map.get("shearMix", 1.0))

		skeleton_data.transform_constraints.append(data)


	for constraint_map in json.get("path", []):
		var data = PathConstraintData.new(constraint_map.get("name"))

		for bone_name in constraint_map.get("bones", []):
			var bone = skeleton_data.find_bone(bone_name)
			if bone == null:
				push_error("Path constraint bone not found: " + bone_name)
			data.bones.append(bone)
		
		var target_name = constraint_map.get("target")
		data.target = skeleton_data.find_slot(target_name)
		if data.target == null:
			push_error("Path constraint target slot not found: " + target_name)

		#TODO: these should all be enums
		data.position_mode = constraint_map.get("positionMode", "percent")
		data.spacing_mode = constraint_map.get("spacingMode", "length")
		data.rotate_mode = constraint_map.get("rotateMode", "tangent")
		data.offset_rotation = float(constraint_map.get("rotation", 0.0))
		data.position = float(constraint_map.get("position", 0.0))
		
		if data.position_mode == PathConstraintData.PositionMode.fixed:
			data.position *= scale		
		
		data.spacing = float(constraint_map.get("spacing", 0.0))
		if data.spacing_mode in ["length", "fixed"]:
			data.spacing *= scale
		
		data.rotate_mix = float(constraint_map.get("rotateMix", 1.0))
		data.translate_mix = float(constraint_map.get("translateMix", 1.0))

		skeleton_data.path_constraints.append(data)

	for skin_map in [ json.get("skins", []) ]:
		var skin = SpineSkin.new(skin_map.keys()[0])

		for key in skin_map:
			var slot_entry = skin_map[key]
			for key2 in slot_entry:
				var slot_index = skeleton_data.find_slot_index(key2)
				if slot_index == -1:
					push_error("Slot not found: " + slot_entry)
					continue			
				var subentry = slot_entry[key2]
				for key3 in subentry:
					var entry_name=key3
					var entry_data = subentry[key3]
					var attachment = read_attachment(entry_data, skin, slot_index, entry_name)
					
					if attachment:
						skin.add_attachment(slot_index, entry_name, attachment)

		skeleton_data.skins.append(skin)
		if skin.name == "default":
			skeleton_data.set_default_skin(skin)

	for linked_mesh in linked_meshes:
		var skin = skeleton_data.get_default_skin() if linked_mesh.skin == null else skeleton_data.find_skin(linked_mesh.skin)
		if skin == null:
			push_error("Skin not found: " + str(linked_mesh.skin))
			continue

		var parent = skin.get_attachment(linked_mesh.slot_index, linked_mesh.parent)
		if parent == null:
			push_error("Parent mesh not found: " + str(linked_mesh.parent))
			continue

		linked_mesh.mesh.set_parent_mesh(parent)
		linked_mesh.mesh.update_uvs()

	linked_meshes.clear()

	for event_map in json.get("events", []):
		var data = EventData.new(event_map.get("name"))
		data.int_value = event_map.get("int", 0)
		data.float_value = event_map.get("float", 0.0)
		data.string_value = event_map.get("string", null)
		skeleton_data.events.append(data)

	var animation_maps = json.get("animations", [])
	for key in animation_maps:
		var animation_name = key
		var animation_map = animation_maps[key]
		if animation_name:
			var result = read_animation(animation_map, animation_name, skeleton_data)
			#if result == null:
			#	push_error("Error reading animation: " + animation_name)

	skeleton_data.bones.resize(len(skeleton_data.bones))
	skeleton_data.slots.resize(len(skeleton_data.slots))
	skeleton_data.skins.resize(len(skeleton_data.skins))
	skeleton_data.events.resize(len(skeleton_data.events))
	skeleton_data.animations.resize(len(skeleton_data.animations))
	skeleton_data.ik_constraints.resize(len(skeleton_data.ik_constraints))

	file.close()

	return skeleton_data
	
func read_attachment(map: Dictionary, skin: SpineSkin, slot_index: int, name: String) -> Attachment:
	var scale = self.scale
	name = map.get("name", name)
	var type = map.get("type", "region")
	
	match type:
		"region":
			var path = map.get("path", name)
			var region:RegionAttachment = attachment_loader.new_region_attachment(skin, name, path)
			if region == null:
				return null
			
			region.set_path(path)
			region.set_x(map.get("x", 0.0) * scale)
			region.set_y(map.get("y", 0.0) * scale)
			region.set_scale_x(map.get("scaleX", 1.0))
			region.set_scale_y(map.get("scaleY", 1.0))
			region.set_rotation(map.get("rotation", 0.0))
			region.set_width(map.get("width", 0.0) * scale)
			region.set_height(map.get("height", 0.0) * scale)
			
			var color = map.get("color", null)
			if color:
				#TODO: we're not 100% sure this sets the new color. original Java was phrased differently
				region.set_color(Color_.value_of(color))
			
			region.update_offset()
			return region
		
		"boundingbox":
			var box = attachment_loader.new_bounding_box_attachment(skin, name)
			if box == null:
				return null
			
			read_vertices(map, box, map.get("vertexCount", 0) * 2)
			
			var color = map.get("color", null)
			if color:
				box.get_color().set(Color(color))
			
			return box
		
		"mesh", "linkedmesh":
			var path = map.get("path", name)
			var mesh = attachment_loader.new_mesh_attachment(skin, name, path)
			if mesh == null:
				return null
			
			mesh.set_path(path)
			
			var color = map.get("color", null)
			if color:
				mesh.get_color().set(Color(color))
			
			mesh.set_width(map.get("width", 0.0) * scale)
			mesh.set_height(map.get("height", 0.0) * scale)
			
			var parent = map.get("parent", null)
			if parent:
				mesh.set_inherit_deform(map.get("deform", true))
				linked_meshes.append(LinkedMesh.new(mesh, map.get("skin", null), slot_index, parent))
				return mesh
			
			##convert uvs from Array to Array[float]
			#var uvs:Array[float] = []
			#uvs.assign(map.get("uvs", []))
			var uvs:Array=map.get("uvs", [])
			read_vertices(map, mesh, len(uvs))
			#convert triangles from Array to Array[int]
			#var triangles:Array[int]=[]
			#triangles.assign(map.get("triangles", []))
			var triangles:Array=map.get("triangles",[])
			mesh.set_triangles(triangles)
			mesh.set_region_uvs(uvs)
			mesh.update_uvs()
			
			if map.has("hull"):
				mesh.set_hull_length(map.get("hull") * 2)
			
			if map.has("edges"):
				mesh.set_edges(map.get("edges", []))
			
			return mesh
		
		"path":
			var path = attachment_loader.new_path_attachment(skin, name)
			if path == null:
				return null
			
			path.set_closed(map.get("closed", false))
			path.set_constant_speed(map.get("constantSpeed", true))
			
			var vertex_count = map.get("vertexCount", 0)
			read_vertices(map, path, vertex_count * 2)
			
			var lengths = []
			for curve in map.get("lengths", []):
				lengths.append(curve * scale)
			
			path.set_lengths(lengths)
			
			var color = map.get("color", null)
			if color:
				path.get_color().set(Color(color))
			
			return path
		
		_:
			return null

func read_vertices(map: Dictionary, attachment: VertexAttachment, vertices_length: int):
	attachment.set_world_vertices_length(vertices_length)

	var vertices = map.get("vertices", [])
	if vertices_length == len(vertices):
		if self.scale != 1.0:
			for i in range(len(vertices)):
				vertices[i] *= self.scale
		
		attachment.set_vertices(vertices)
	else:
		var weights:Array[float] = []
		var bones:Array[int] = []
		var i = 0
		var n = len(vertices)

		while i < n:
			var bone_count = int(vertices[i])
			i += 1
			bones.append(bone_count)

			var nn = i + bone_count * 4
			while i < nn:
				bones.append(int(vertices[i]))
				weights.append(vertices[i + 1] * self.scale)
				weights.append(vertices[i + 2] * self.scale)
				weights.append(vertices[i + 3])
				i += 4
		
		attachment.set_bones(bones)
		attachment.set_vertices(weights)

func read_animation(map: Dictionary, name: String, skeleton_data: SkeletonData):
	var scale = self.scale
	var timelines = []
	var duration = 0.0

	# Process slot animations
	var slots_data=map.get("slots",[])
	for key in slots_data:
		var slot_map=slots_data.get(key)
		var slot_index = skeleton_data.find_slot_index(key)
		if slot_index == -1:
			push_error("Slot not found: " + key)
			continue

		for timeline_map in slot_map.keys():
			var child=slot_map.get(timeline_map,[])			
			var timeline_name = timeline_map
			
			if timeline_name == "color":
				var timeline = Animation_.ColorTimeline.new(len(child))
				timeline.slot_index = slot_index
				var frame_index = 0

				for value_map in child:
					var color = Color(value_map.get("color"))
					timeline.set_frame(frame_index, value_map.get("time"), color.r, color.g, color.b, color.a)
					read_curve(value_map, timeline, frame_index)
					frame_index += 1

				timelines.append(timeline)
				duration = max(duration, timeline.get_frames()[(timeline.get_frame_count() - 1) * 5])

			elif timeline_name == "attachment":
				var timeline = Animation_.AttachmentTimeline.new(len(child))
				timeline.slot_index = slot_index
				var frame_index = 0

				for value_map in child:
					timeline.set_frame(frame_index, value_map.get("time"), value_map.get("name"))
					frame_index += 1

				timelines.append(timeline)
				duration = max(duration, timeline.get_frames()[timeline.get_frame_count() - 1])

			else:
				push_error("Invalid timeline type for a slot: " + timeline_name + " (" + slot_map.get("name") + ")")

	# Process bone animations
	for key in map.get("bones", []):
		var bone_map=map.get("bones",[]).get(key,[])
		var bone_index = skeleton_data.find_bone_index(key)
		if bone_index == -1:
			push_error("Bone not found: " + key)
			continue
		for key2 in bone_map.keys():
			var timeline_map = {"name"=key2,"child"=bone_map[key2]}
			var timeline_name = timeline_map.get("name")
			if timeline_name == "rotate":
				var timeline = Animation_.RotateTimeline.new(len(timeline_map.get("child", [])))
				timeline.bone_index = bone_index
				var frame_index = 0

				for value_map in timeline_map.get("child", []):
					timeline.set_frame(frame_index, value_map.get("time"), value_map.get("angle"))
					read_curve(value_map, timeline, frame_index)
					frame_index += 1

				timelines.append(timeline)
				duration = max(duration, timeline.get_frames()[(timeline.get_frame_count() - 1) * 2])

			elif timeline_name in ["translate", "scale", "shear"]:
				var timeline_scale = 1.0
				var timeline

				if timeline_name == "scale":
					timeline = Animation_.ScaleTimeline.new(len(timeline_map.get("child", [])))
				elif timeline_name == "shear":
					timeline = Animation_.ShearTimeline.new(len(timeline_map.get("child", [])))
				else:
					timeline = Animation_.TranslateTimeline.new(len(timeline_map.get("child", [])))
					timeline_scale = scale

				timeline.bone_index = bone_index
				var frame_index = 0

				for value_map in timeline_map.get("child", []):
					var x = value_map.get("x", 0.0)
					var y = value_map.get("y", 0.0)
					timeline.set_frame(frame_index, value_map.get("time"), x * timeline_scale, y * timeline_scale)
					read_curve(value_map, timeline, frame_index)
					frame_index += 1

				timelines.append(timeline)
				duration = max(duration, timeline.get_frames()[(timeline.get_frame_count() - 1) * 3])

			else:
				push_error("Invalid timeline type for a bone: " + timeline_name + " (" + bone_map.get("name") + ")")


	# IK Constraints
	for constraint_map in map.get("ik", []):
		var constraint = skeleton_data.find_ik_constraint(constraint_map.get("name"))
		var timeline = Animation_.IkConstraintTimeline.new(len(constraint_map.get("child", [])))
		timeline.ik_constraint_index = skeleton_data.ik_constraints.find(constraint)

		var frame_index = 0
		for value_map in constraint_map.get("child", []):
			timeline.set_frame(frame_index, value_map.get("time"), value_map.get("mix", 1.0), 1 if value_map.get("bendPositive", true) else -1)
			read_curve(value_map, timeline, frame_index)
			frame_index += 1

		timelines.append(timeline)
		duration = max(duration, timeline.get_frames()[(timeline.get_frame_count() - 1) * 3])

	# Transform Constraints
	for constraint_map in map.get("transform", []):
		var constraint = skeleton_data.find_transform_constraint(constraint_map.get("name"))
		var timeline = Animation_.TransformConstraintTimeline.new(len(constraint_map.get("child", [])))
		timeline.transform_constraint_index = skeleton_data.transform_constraints.find(constraint)

		var frame_index = 0
		for value_map in constraint_map.get("child", []):
			timeline.set_frame(frame_index, value_map.get("time"),
				value_map.get("rotateMix", 1.0),
				value_map.get("translateMix", 1.0),
				value_map.get("scaleMix", 1.0),
				value_map.get("shearMix", 1.0)
			)
			read_curve(value_map, timeline, frame_index)
			frame_index += 1

		timelines.append(timeline)
		duration = max(duration, timeline.get_frames()[(timeline.get_frame_count() - 1) * 5])

	# Path Constraints
	for constraint_map in map.get("paths", []):
		var index = skeleton_data.find_path_constraint_index(constraint_map.get("name"))
		if index == -1:
			push_error("Path constraint not found: " + constraint_map.get("name"))
			continue

		var data = skeleton_data.path_constraints[index]

		for timeline_map in constraint_map.get("child", []):
			var timeline_name = timeline_map.get("name")
			if timeline_name == "mix":
				var timeline = Animation_.PathConstraintMixTimeline.new(len(timeline_map.get("child", [])))
				timeline.path_constraint_index = index

				var frame_index = 0
				for value_map in timeline_map.get("child", []):
					timeline.set_frame(frame_index, value_map.get("time"),
						value_map.get("rotateMix", 1.0),
						value_map.get("translateMix", 1.0)
					)
					read_curve(value_map, timeline, frame_index)
					frame_index += 1

				timelines.append(timeline)
				duration = max(duration, timeline.get_frames()[(timeline.get_frame_count() - 1) * 3])

			elif timeline_name in ["position", "spacing"]:
				var timeline_scale = 1.0
				var timeline

				if timeline_name == "spacing":
					timeline = Animation_.PathConstraintSpacingTimeline.new(len(timeline_map.get("child", [])))
					if data.spacing_mode in [PathConstraintData.SpacingMode.length, PathConstraintData.SpacingMode.fixed]:
						timeline_scale = scale
				else:
					timeline = Animation_.PathConstraintPositionTimeline.new(len(timeline_map.get("child", [])))
					if data.position_mode == "fixed":
						timeline_scale = scale

				timeline.path_constraint_index = index

				var frame_index = 0
				for value_map in timeline_map.get("child", []):
					timeline.set_frame(frame_index, value_map.get("time"), value_map.get(timeline_name, 0.0) * timeline_scale)
					read_curve(value_map, timeline, frame_index)
					frame_index += 1

				timelines.append(timeline)
				duration = max(duration, timeline.get_frames()[(timeline.get_frame_count() - 1) * 2])

	# Deform Timelines
	var all_deforms=map.get("deform",null)
	if(all_deforms):
		for key in all_deforms.keys():
			var deform_map = map.get("deform").get(key,[])
			var skin_name = key
			var skin = skeleton_data.find_skin(skin_name)
			if skin == null:
				push_error("Skin not found: " + deform_map.get("name"))
				continue

			for slot in deform_map.keys():
				var slot_index = skeleton_data.find_slot_index(slot)
				if slot_index == -1:
					push_error("Slot not found: " + slot)
					continue

				var slot_child=deform_map.get(slot)
				for key2 in slot_child.keys():
					var timeline_map=slot_child.get(key2,[])
					var attachment = skin.get_attachment(slot_index, key2)
					if attachment == null:
						push_error("Deform attachment not found: " + key2)
						continue

					var weighted = attachment.get_bones() != null
					var vertices = attachment.get_vertices()
					var deform_length = len(vertices) / 3 * 2 if weighted else len(vertices)
					var timeline = Animation_.DeformTimeline.new(len(timeline_map))
					timeline.slot_index = slot_index
					timeline.attachment = attachment

					var frame_index = 0
					for value_map in timeline_map:
						var vertices_value = value_map.get("vertices")
						var deform

						if vertices_value == null:
							if weighted:
								deform=[]
								deform.resize(deform_length)
								deform.fill(0)
							else:
								deform=vertices
						else:
							deform = []
							deform.resize(deform_length)
							deform.fill(0)
							var start = value_map.get("offset", 0)
							var vertex_data = vertices_value
							
							#original java uses System.arraycopy(verticesValue.asFloatArray(), 0, deform, start, verticesValue.size);
							var dest=start
							for i in range(vertex_data.size()):
								deform[dest]=vertex_data[i]
								dest+=1

							if scale != 1.0:
								for i in range(start, start + len(vertex_data)):
									deform[i] *= scale

							if not weighted:
								for i in range(deform_length):
									deform[i] += vertices[i]

						timeline.set_frame(frame_index, value_map.get("time"), deform)
						read_curve(value_map, timeline, frame_index)
						frame_index += 1

					timelines.append(timeline)
					duration = max(duration, timeline.get_frames()[timeline.get_frame_count() - 1])



	var draw_orders_map = map.get("drawOrder", null)
	##decomp jank?
	#if draw_orders_map == null:
		#draw_orders_map = map.get("drawOrder")
	if(draw_orders_map!=null):
		var timeline = Animation_.DrawOrderTimeline.new(len(draw_orders_map.get("child", [])))
		var slot_count = len(skeleton_data.slots)
		var frame_index = 0

		for draw_order_map in draw_orders_map.get("child", []):
			var draw_order = null
			var offsets = draw_order_map.get("offsets")

			if offsets:
				draw_order = [-1] * slot_count
				var unchanged = []
				var original_index = 0
				var unchanged_index = 0

				for offset_map in offsets:
					var slot_index = skeleton_data.find_slot_index(offset_map.get("slot"))
					if slot_index == -1:
						push_error("Slot not found: " + offset_map.get("slot"))
						continue

					while original_index != slot_index:
						unchanged.append(original_index)
						original_index += 1

					draw_order[original_index + offset_map.get("offset")] = original_index
					original_index += 1

				while original_index < slot_count:
					unchanged.append(original_index)
					original_index += 1

				for i in range(slot_count):
					if draw_order[i] == -1:
						unchanged_index -= 1
						draw_order[i] = unchanged[unchanged_index]

			timeline.set_frame(frame_index, draw_order_map.get("time"), draw_order)
			frame_index += 1
			
		timelines.append(timeline)
		duration = max(duration, timeline.get_frames()[timeline.getFrameCount() - 1])


	var events_map = map.get("events", null)
	if events_map:
		var timeline = Animation_.EventTimeline.new(len(events_map.get("child", [])))
		var frame_index = 0

		for event_map in events_map.get("child", []):
			var event_data = skeleton_data.find_event(event_map.get("name"))
			if event_data == null:
				push_error("Event not found: " + event_map.get("name"))
				continue

			var event = Event.new(event_map.get("time"), event_data)
			event.int_value = event_map.get("int", event_data.int_value)
			event.float_value = event_map.get("float", event_data.float_value)
			event.string_value = event_map.get("string", event_data.string_value)

			timeline.set_frame(frame_index, event)
			frame_index += 1

		timelines.append(timeline)
		duration = max(duration, timeline.get_frames()[timeline.get_frame_count() - 1])

	timelines.resize(len(timelines))
	skeleton_data.animations.append(Animation_.new(name,timelines,duration))
	
func read_curve(map: Dictionary, timeline: Animation_.CurveTimeline, frame_index: int):
	var curve = map.get("curve", null)
	if curve:
		if typeof(curve) == TYPE_STRING and curve == "stepped":
			timeline.set_stepped(frame_index)
		elif typeof(curve) == TYPE_ARRAY and len(curve) == 4:
			timeline.set_curve(frame_index, curve[0], curve[1], curve[2], curve[3])

class LinkedMesh:
	var parent: String
	var skin: String
	var slot_index: int
	var mesh: MeshAttachment

	func _init(mesh: MeshAttachment, skin: String, slot_index: int, parent: String):
		self.mesh = mesh
		self.skin = skin
		self.slot_index = slot_index
		self.parent = parent
	
