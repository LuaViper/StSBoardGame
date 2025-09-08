class_name SkeletonBinary

# Constants
const BONE_ROTATE = 0
const BONE_TRANSLATE = 1
const BONE_SCALE = 2
const BONE_SHEAR = 3
const SLOT_ATTACHMENT = 0
const SLOT_COLOR = 1
const PATH_POSITION = 0
const PATH_SPACING = 1
const PATH_MIX = 2
const CURVE_LINEAR = 0
const CURVE_STEPPED = 1
const CURVE_BEZIER = 2

# Properties
var temp_color: Color = Color()  # Equivalent to static final tempColor
var attachment_loader: AttachmentLoader
var scale: float = 1.0
var linked_meshes: Array = []

# Constructor for TextureAtlas
func _init(atlas: TextureAtlas) -> void:
	attachment_loader = AtlasAttachmentLoader.new(atlas)

# Constructor for AttachmentLoader
func _init_with_loader(loader: AttachmentLoader) -> void:
	if loader == null:
		push_error("attachmentLoader cannot be null.")
	else:
		attachment_loader = loader

# Getter for scale
func get_scale() -> float:
	return scale

# Setter for scale
func set_scale(_scale: float) -> void:
	scale = _scale

func read_skeleton_data(file) -> SkeletonData:
	if file == null:
		push_error("file cannot be null.")
		return null
	else:
		var scale = self.scale
		var skeleton_data = SkeletonData.new()
		skeleton_data.name = file.get_basename().split(".")[0]  # Equivalent of nameWithoutExtension

		var input = {
			"chars": []
		}

		input.read_string = func() -> String:
			#try:
			var byte_count = input.read_int(true)
			match byte_count:
				0:
					return ""
				1:
					return ""
				_:
					byte_count -= 1
					if len(input["chars"]) < byte_count:
						input["chars"] = []
						for i in range(byte_count):
							input["chars"].append("")
					
					var chars = input["chars"]
					var char_count = 0
					var i = 0

					while i < byte_count:
						var b = input.read()
						match b >> 4:
							-1:
								push_error("EOFException")
								return ""
							12, 13:
								chars[char_count] = char(((b & 31) << 6) | (input.read() & 63))
								char_count += 1
								i += 2
							14:
								chars[char_count] = char(((b & 15) << 12) | ((input.read() & 63) << 6) | (input.read() & 63))
								char_count += 1
								i += 3
							_:
								chars[char_count] = char(b)
								char_count += 1
								i += 1

					return "".join(chars)

		#try:
		# Read hash
		skeleton_data.hash = input.read_string()
		if skeleton_data.hash.empty():
			skeleton_data.hash = null

		# Read version
		skeleton_data.version = input.read_string()
		if skeleton_data.version.empty():
			skeleton_data.version = null

		# Read dimensions
		skeleton_data.width = input.read_float()
		skeleton_data.height = input.read_float()

		# Read nonessential flag
		var nonessential = input.read_bool() > 0
		if nonessential:
			skeleton_data.images_path = input.read_string()
			if skeleton_data.images_path.empty():
				skeleton_data.images_path = null

		# Read bones
		var bone_count = input.read_int()
		for i in range(bone_count):
			var name = input.read_string()
			var parent = null if i == 0 else skeleton_data.bones[input.read_int()]
			var bone_data = BoneData.new(i, name, parent)			
			bone_data.rotation = input.read_float()
			bone_data.x = input.read_float() * scale
			bone_data.y = input.read_float() * scale
			bone_data.scale_x = input.read_float()
			bone_data.scale_y = input.read_float()
			bone_data.shear_x = input.read_float()
			bone_data.shear_y = input.read_float()
			bone_data.length = input.read_float() * scale
			bone_data.inherit_rotation = input.read_bool() > 0
			bone_data.inherit_scale = input.read_bool() > 0

			if nonessential:
				bone_data.color = rgba_8888_to_color(bone_data.color, input.read_int())

			skeleton_data.bones.append(bone_data)

		# Read slots
		var slot_count = input.read_int()
		for i in range(slot_count):
			var slot_name = input.read_string()
			var bone_data = skeleton_data.bones[input.read_int()]
			var slot_data:SlotData = SlotData.new(i, slot_name, bone_data)
			slot_data.color = rgba_8888_to_color(slot_data.color, input.read_int())
			slot_data.attachment_name = input.read_string()
			slot_data.blend_mode = BlendMode[input.read_int()]
			skeleton_data.slots.append(slot_data)


		# IK Constraints
		var ik_constraint_count = input.read_int()
		for i in range(ik_constraint_count):
			var ik_data = IkConstraintData.new(input.get_line())
			var nn = input.read_int()
			for ii in range(nn):
				ik_data.bones.append(skeleton_data.bones[input.read_int()])
			ik_data.target = skeleton_data.bones[input.read_int()]
			ik_data.mix = input.read_float()
			ik_data.bend_direction = input.read_byte()
			skeleton_data.ik_constraints.append(ik_data)

		# Transform Constraints
		var transform_constraint_count = input.read_int()
		for i in range(transform_constraint_count):
			var transform_data = TransformConstraintData.new(input.read_string())
			var nn = input.read_int()
			for ii in range(nn):
				transform_data.bones.append(skeleton_data.bones[input.read_int()])
			transform_data.target = skeleton_data.bones[input.read_int()]
			transform_data.offset_rotation = input.read_float()
			transform_data.offset_x = input.read_float() * scale
			transform_data.offset_y = input.read_float() * scale
			transform_data.offset_scale_x = input.read_float()
			transform_data.offset_scale_y = input.read_float()
			transform_data.offset_shear_y = input.read_float()
			transform_data.rotate_mix = input.read_float()
			transform_data.translate_mix = input.read_float()
			transform_data.scale_mix = input.read_float()
			transform_data.shear_mix = input.read_float()
			skeleton_data.transform_constraints.append(transform_data)

		# Path Constraints
		var path_constraint_count = input.read_int()
		for i in range(path_constraint_count):
			var path_data = PathConstraintData.new(input.read_string())
			var nn = input.read_int()
			for ii in range(nn):
				path_data.bones.append(skeleton_data.bones[input.read_int()])
			path_data.target = skeleton_data.slots[input.read_int()]
			path_data.position_mode = PositionMode[input.read_int()]
			path_data.spacing_mode = SpacingMode[input.read_int()]
			path_data.rotate_mode = RotateMode[input.read_int()]
			path_data.offset_rotation = input.read_int()
			path_data.position = input.read_float()
			if path_data.position_mode == PositionMode.fixed:
				path_data.position *= scale
			path_data.spacing = input.read_float()
			if path_data.spacing_mode in [SpacingMode.length, SpacingMode.fixed]:
				path_data.spacing *= scale
			path_data.rotate_mix = input.read_float()
			path_data.translate_mix = input.read_float()
			skeleton_data.path_constraints.append(path_data)

		# Default Skin
		var default_skin = read_skin(input, "default", nonessential)
		if default_skin != null:
			skeleton_data.default_skin = default_skin
			skeleton_data.skins.append(default_skin)

		# Additional Skins
		var skin_count = input.read_int()
		for i in range(skin_count):
			skeleton_data.skins.append(read_skin(input, input.read_string(), nonessential))

		# Linked Meshes
		for linked_mesh in linked_meshes:
			var skin = linked_mesh.skin if linked_mesh.skin != null else skeleton_data.default_skin
			if skin == null:
				push_error("Skin not found: " + linked_mesh.skin)
				return null
			var parent = skin.get_attachment(linked_mesh.slot_index, linked_mesh.parent)
			if parent == null:
				push_error("Parent mesh not found: " + linked_mesh.parent)
				return null
			linked_mesh.mesh.set_parent_mesh(parent)
			linked_mesh.mesh.update_uvs()
		linked_meshes.clear()

		# Events
		var event_count = input.read_int()
		for i in range(event_count):
			var event_data = EventData.new(input.read_string())
			event_data.int_value = input.read_int()
			event_data.float_value = input.read_float()
			event_data.string_value = input.read_string()
			skeleton_data.events.append(event_data)

		# Animations
		var animation_count = input.read_int()
		for i in range(animation_count):
			read_animation(input.read_string(), input, skeleton_data)

		input.close()

		##original Java: Shrink arrays -- does things with badlogicarray class
		#skeleton_data.bones = skeleton_data.bones.deduplicated()
		#skeleton_data.slots = skeleton_data.slots.deduplicated()
		#skeleton_data.skins = skeleton_data.skins.deduplicated()
		#skeleton_data.events = skeleton_data.events.deduplicated()
		#skeleton_data.animations = skeleton_data.animations.deduplic

func read_skin(input, skin_name: String, nonessential: bool) -> Skin:
	var slot_count = input.read_int()
	if slot_count == 0:
		return null
	else:
		var skin = Skin.new(skin_name)
		for i in range(slot_count):
			var slot_index = input.read_int()
			var attachment_count = input.read_int()
			for ii in range(attachment_count):
				var name = input.read_string()
				var attachment = read_attachment(input, skin, slot_index, name, nonessential)
				skin.add_attachment(slot_index, name, attachment)
		return skin

func read_attachment(input, skin: Skin, slot_index: int, attachment_name: String, nonessential: bool) -> Attachment:
	var scale = self.scale
	var name = input.read_string()
	if name.empty():
		name = attachment_name

	var type = AttachmentType[input.read_byte()]
	match type:
		AttachmentType.region:
			var path = input.read_string()
			var rotation = input.read_float()
			var x = input.read_float()
			var y = input.read_float()
			var scale_x = input.read_float()
			var scale_y = input.read_float()
			var width = input.read_float()
			var height = input.read_float()
			var color = input.read_int()
			if path.empty():
				path = name

			var region = attachment_loader.new_region_attachment(skin, name, path)
			if region == null:
				return null
			region.set_path(path)
			region.set_x(x * scale)
			region.set_y(y * scale)
			region.set_scale_x(scale_x)
			region.set_scale_y(scale_y)
			region.set_rotation(rotation)
			region.set_width(width * scale)
			region.set_height(height * scale)
			rgba8888_to_color(region.get_color(),color)
			region.update_offset()
			return region

		AttachmentType.boundingbox:
			var vertex_count = input.read_int()
			var vertices = read_vertices(input, vertex_count)
			var color = input.read_int() if nonessential else 0
			var box = attachment_loader.new_bounding_box_attachment(skin, name)
			if box == null:
				return null
			box.set_world_vertices_length(vertex_count * 2)
			box.set_vertices(vertices.vertices)
			box.set_bones(vertices.bones)
			if nonessential:
				rgba8888_to_color(box.get_color(),color)
			return box

		AttachmentType.mesh:
			var path = input.read_string()
			var color = input.read_int()
			var vertex_count = input.read_int()
			var uvs = read_float_array(input, vertex_count * 2, 1.0)
			var triangles = read_short_array(input)
			var vertices = read_vertices(input, vertex_count)
			var hull_length = input.read_int()
			var edges = null
			var width = 0.0
			var height = 0.0
			if nonessential:
				edges = read_short_array(input)
				width = input.read_float()
				height = input.read_float()

			if path.empty():
				path = name

			var mesh = attachment_loader.new_mesh_attachment(skin, name, path)
			if mesh == null:
				return null
			mesh.set_path(path)
			rgba8888_to_color(mesh.get_color(),color)
			mesh.set_bones(vertices.bones)
			mesh.set_vertices(vertices.vertices)
			mesh.set_world_vertices_length(vertex_count * 2)
			mesh.set_triangles(triangles)
			mesh.set_region_uvs(uvs)
			mesh.update_uvs()
			mesh.set_hull_length(hull_length * 2)
			if nonessential:
				mesh.set_edges(edges)
				mesh.set_width(width * scale)
				mesh.set_height(height * scale)
			return mesh

		AttachmentType.linkedmesh:
			var path = input.read_string()
			var color = input.read_int()
			var skin_name = input.read_string()
			var parent = input.read_string()
			var inherit_deform = input.read_bool() > 0
			var width = 0.0
			var height = 0.0
			if nonessential:
				width = input.read_float()
				height = input.read_float()

			if path.empty():
				path = name

			var mesh = attachment_loader.new_mesh_attachment(skin, name, path)
			if mesh == null:
				return null
			mesh.set_path(path)
			rgba8888_to_color(mesh.get_color(),color)
			mesh.set_inherit_deform(inherit_deform)
			if nonessential:
				mesh.set_width(width * scale)
				mesh.set_height(height * scale)

			linked_meshes.append(SkeletonJson.LinkedMesh.new(mesh, skin_name, slot_index, parent))
			return mesh

		AttachmentType.path:
			var closed = input.get_8() > 0
			var constant_speed = input.get_8() > 0
			var vertex_count = input.get_32()
			var vertices = read_vertices(input, vertex_count)
			var lengths = []
			for i in range(vertex_count / 3):
				lengths.append(input.get_float() * scale)

			var color = input.get_32() if nonessential else 0
			var path = attachment_loader.new_path_attachment(skin, name)
			if path == null:
				return null
			path.set_closed(closed)
			path.set_constant_speed(constant_speed)
			path.set_world_vertices_length(vertex_count * 2)
			path.set_vertices(vertices.vertices)
			path.set_bones(vertices.bones)
			path.set_lengths(lengths)
			if nonessential:
				rgba8888_to_color(path.get_color(), color)
			return path

		_:
			return null
			
			
# Function to read vertices
func read_vertices(input, vertex_count: int) -> Dictionary:
	var vertices_length = vertex_count * 2  # vertexCount << 1
	var vertices = {"vertices": [], "bones": []}

	if not input.get_8():  # Boolean check
		vertices["vertices"] = read_float_array(input, vertices_length, scale)
	else:
		var weights = []
		var bones_array = []
		for i in range(vertex_count):
			var bone_count = input.read_int()  # True flag read
			bones_array.append(bone_count)
			for ii in range(bone_count):
				bones_array.append(input.read_int())  # Read bone index
				weights.append(input.read_float() * scale)  # x coordinate
				weights.append(input.read_float() * scale)  # y coordinate
				weights.append(input.read_float())  # weight

		vertices["vertices"] = weights
		vertices["bones"] = bones_array

	return vertices

# Function to read a float array
func read_float_array(input, n: int, scale: float) -> Array:
	var array = Array()
	if scale == 1.0:
		for i in range(n):
			array.append(input.read_float())
	else:
		for i in range(n):
			array.append(input.read_float() * scale)
	return array

# Function to read a short array
func read_short_array(input) -> Array:
	var n = input.read_int()  # True flag read
	var array = []
	for i in range(n):
		array.append(input.read_short())  # Read short
	return array
	
func read_animation(name: String, input, skeleton_data: SkeletonData) -> void:
	var timelines = []
	var scale = self.scale
	var duration = 0.0

	# Slot Timelines
	var slot_count1 = input.read_int()
	for i in range(slot_count1):
		var slot_index = input.read_int()
		var timeline_count = input.read_int()
		for ii in range(timeline_count):
			var timeline_type = input.read_byte()
			var frame_count = input.read_int()
			match timeline_type:
				0:  # AttachmentTimeline
					var timeline = Animation_.AttachmentTimeline.new(frame_count)
					timeline.slot_index = slot_index
					for frame_index in range(frame_count):
						timeline.set_frame(frame_index, input.read_float(), input.read_string())
					timelines.append(timeline)
					duration = max(duration, timeline.get_frames()[frame_count - 1])
				1:  # ColorTimeline
					var timeline = Animation_.ColorTimeline.new(frame_count)
					timeline.slot_index = slot_index
					for frame_index in range(frame_count):
						var time = input.get_float()
						var color = input.get_32()  # Assuming proper RGBA conversion is done
						timeline.set_frame(frame_index, time, color.r, color.g, color.b, color.a)
						if frame_index < frame_count - 1:
							read_curve(input, frame_index, timeline)
					timelines.append(timeline)
					duration = max(duration, timeline.get_frames()[(frame_count - 1) * 5])

	# Bone Timelines
	var bone_count = input.read_int()
	for i in range(bone_count):
		var bone_index = input.read_int()
		var timeline_count = input.read_int()
		for ii in range(timeline_count):
			var timeline_type = input.read_byte()
			var frame_count = input.read_int()
			match timeline_type:
				0:  # RotateTimeline
					var timeline = Animation_.RotateTimeline.new(frame_count)
					timeline.bone_index = bone_index
					for frame_index in range(frame_count):
						timeline.set_frame(frame_index, input.read_float(), input.read_float())
						if frame_index < frame_count - 1:
							read_curve(input, frame_index, timeline)
					timelines.append(timeline)
					duration = max(duration, timeline.get_frames()[(frame_count - 1) * 2])
				1, 2, 3:  # Translate, Scale, ShearTimeline
					var timeline_scale = 1.0
					var timeline
					if timeline_type == 2:  # ScaleTimeline
						timeline = Animation_.ScaleTimeline.new(frame_count)
					elif timeline_type == 3:  # ShearTimeline
						timeline = Animation_.ShearTimeline.new(frame_count)
					else:  # TranslateTimeline
						timeline = Animation_.TranslateTimeline.new(frame_count)
						timeline_scale = scale

					timeline.bone_index = bone_index
					for frame_index in range(frame_count):
						timeline.set_frame(frame_index, input.read_float(), input.get_float() * timeline_scale, input.read_float() * timeline_scale)
						if frame_index < frame_count - 1:
							read_curve(input, frame_index, timeline)
					timelines.append(timeline)
					duration = max(duration, timeline.get_frames()[(frame_count - 1) * 3])

	# IK Constraint Timelines
	var ik_count = input.read_int()
	for i in range(ik_count):
		var index = input.read_int()
		var frame_count = input.read_int()
		var timeline = Animation_.IkConstraintTimeline.new(frame_count)
		timeline.ik_constraint_index = index
		for frame_index in range(frame_count):
			timeline.set_frame(frame_index, input.read_float(), input.read_float(), input.read_byte())
			if frame_index < frame_count - 1:
				read_curve(input, frame_index, timeline)
		timelines.append(timeline)
		duration = max(duration, timeline.get_frames()[(frame_count - 1) * 3])

	# Transform Constraint Timelines
	var transform_count = input.read_int()
	for i in range(transform_count):
		var index = input.read_int()
		var frame_count = input.read_int()
		var timeline = Animation_.TransformConstraintTimeline.new(frame_count)
		timeline.transform_constraint_index = index
		for frame_index in range(frame_count):
			timeline.set_frame(frame_index, input.read_float(), input.read_float(), input.read_float(), input.get_float(), input.read_float())
			if frame_index < frame_count - 1:
				read_curve(input, frame_index, timeline)
		timelines.append(timeline)
		duration = max(duration, timeline.get_frames()[(frame_count - 1) * 5])

	# Path Constraint Timelines
	for i in range(input.read_int()):
		var index = input.read_int()
		var data = skeleton_data.get_path_constraints()[index]

		for ii in range(input.read_int()):
			var timeline_type = input.read_byte()
			var frame_count = input.read_int()

			match timeline_type:
				0, 1:
					var timeline_scale = 1.0
					var timeline

					if timeline_type == 1:  # PathConstraintSpacingTimeline
						timeline = Animation_.PathConstraintSpacingTimeline.new(frame_count)
						if data.spacing_mode in [SpacingMode.length, SpacingMode.fixed]:
							timeline_scale = scale
					else:  # PathConstraintPositionTimeline
						timeline = Animation_.PathConstraintPositionTimeline.new(frame_count)
						if data.position_mode == PositionMode.fixed:
							timeline_scale = scale

					timeline.path_constraint_index = index

					for frame_index in range(frame_count):
						timeline.set_frame(frame_index, input.read_float(), input.read_float() * timeline_scale)
						if frame_index < frame_count - 1:
							read_curve(input, frame_index, timeline)

					timelines.append(timeline)
					duration = max(duration, timeline.get_frames()[(frame_count - 1) * 2])

				2:  # PathConstraintMixTimeline
					var timeline = Animation.PathConstraintMixTimeline.new(frame_count)
					timeline.path_constraint_index = index

					for frame_index in range(frame_count):
						timeline.set_frame(frame_index, input.read_float(), input.get_float(), input.read_float())
						if frame_index < frame_count - 1:
							read_curve(input, frame_index, timeline)

					timelines.append(timeline)
					duration = max(duration, timeline.get_frames()[(frame_count - 1) * 3])

	# Deform Timelines
	for i in range(input.read_int()):
		var skin = skeleton_data.skins[input.read_int()]

		for ii in range(input.read_int()):
			var slot_index = input.read_int()

			for iii in range(input.read_int()):
				var attachment = skin.get_attachment(slot_index, input.get_line())
				var weighted = attachment.get_bones() != null
				var vertices = attachment.get_vertices()
				var deform_length = len(vertices) / 3 * 2 if weighted else len(vertices)
				var frame_count = input.read_int()

				var timeline = Animation_.DeformTimeline.new(frame_count)
				timeline.slot_index = slot_index
				timeline.attachment = attachment

				for frame_index in range(frame_count):
					var time = input.read_float()
					var end = input.read_int()
					var deform

					if end == 0:
						if weighted:
							deform=[]
							deform.resize(deform_length)
						else:
							deform = vertices
					else:
						deform = []
						deform.resize(deform_length)
						var start = input.read_int()
						end += start

						if scale == 1.0:
							for v in range(start, end):
								deform[v] = input.read_float()
						else:
							for v in range(start, end):
								deform[v] = input.read_float() * scale

						if not weighted:
							for v in range(len(deform)):
								deform[v] += vertices[v]

					timeline.set_frame(frame_index, time, deform)
					if frame_index < frame_count - 1:
						read_curve(input, frame_index, timeline)

				timelines.append(timeline)
				duration = max(duration, timeline.get_frames()[frame_count - 1])

	# Draw Order Timelines
	var draw_order_count = input.read_int()
	if draw_order_count > 0:
		var timeline = Animation_.DrawOrderTimeline.new(draw_order_count)
		var slot_count = len(skeleton_data.slots)
		#TODO: decomp uses "i<i" as conditional so entire block gets skipped
		for i in range(draw_order_count):
			var time = input.read_float()
			var offset_count = input.read_int()
			var draw_order = []
			draw_order.resize(slot_count)
			draw_order.fill(-1)
			var unchanged = []
			unchanged.resize(slot_count - offset_count)
			var original_index = 0
			var unchanged_index = 0

			for ii in range(offset_count):
				var slot_index = input.read_int()
				while original_index != slot_index:
					unchanged.append(original_index)
					original_index += 1

				draw_order[original_index + input.read_int()] = original_index
				original_index += 1

			while original_index < slot_count:
				unchanged.append(original_index)
				original_index += 1

			for ii in range(slot_count - 1, -1, -1):
				if draw_order[ii] == -1:
					unchanged_index -= 1
					draw_order[ii] = unchanged[unchanged_index]

			timeline.set_frame(i, time, draw_order)

		timelines.append(timeline)
		duration = max(duration, timeline.get_frames()[draw_order_count - 1])

	# Event Timelines
	var event_count = input.read_int()
	if event_count > 0:
		var timeline = Animation_.EventTimeline.new(event_count)

		for i in range(event_count):
			var time = input.read_float()
			var event_data = skeleton_data.events[input.read_int()]
			var event = Event.new(time, event_data)
			event.int_value = input.read_int()
			event.float_value = input.read_float()
			event.string_value = input.read_string() if input.read_bool() else event_data.string_value
			timeline.set_frame(i, event)

		timelines.append(timeline)
		duration = max(duration, timeline.get_frames()[event_count - 1])

	# Add animation to skeleton data
	skeleton_data.animations.append(Animation_.new(name, timelines, duration))


func read_curve(input, frame_index: int, timeline: Animation_.CurveTimeline) -> void:
	match input.get_8():
		1:
			timeline.set_stepped(frame_index)
		2:
			set_curve(timeline, frame_index, input.get_float(), input.get_float(), input.get_float(), input.get_float())


func set_curve(timeline: Animation_.CurveTimeline, frame_index: int, cx1: float, cy1: float, cx2: float, cy2: float) -> void:
	timeline.set_curve(frame_index, cx1, cy1, cx2, cy2)
	
class Vertices:
	var bones:Array=[]
	var vertices:Array=[]
