class_name Skeleton

# Class properties
var data: SkeletonData
var bones: Array = []
var slots: Array = []
var draw_order: Array = []
var ik_constraints: Array = []
var ik_constraints_sorted: Array = []
var transform_constraints: Array = []
var path_constraints: Array = []
var update_cache_array: Array = []
var skin: SpineSkin
var color: Color = Color(1.0, 1.0, 1.0, 1.0)
var time: float = 0.0
var flip_x: bool = false
var flip_y: bool = false
var x: float = 0.0
var y: float = 0.0

# Constructor
func _init(arg1) -> void:
	assert(arg1 is SkeletonData or arg1 is Skeleton,
		"Skeleton constructor was called with invalid type for arg1 "+arg1.to_string())
	if(arg1 is SkeletonData):
		var _data:SkeletonData = arg1
		if _data == null:
			push_error("data cannot be null.")
		else:
			data = _data
			#Original java implementation uses custom arrays where resize allocates memory in advance
			# but keeps the array's "size" at 0. 
			# We must resize(0) here or append calls will not work as expected.
			# TODO: implement SpineArray so we can avoid slow append calls.
			bones.resize(0)

			for bone_data in _data.bones:
				var bone: Bone
				if bone_data.parent == null:
					bone = Bone.new(bone_data, self, null)
				else:
					var parent = bones[bone_data.parent.index]
					bone = Bone.new(bone_data, self, parent)
					parent.children.append(bone)
				bones.append(bone)

			slots.resize(0)
			draw_order.resize(0)

			for slot_data in _data.slots:
				var bone = bones[slot_data.bone_data.index]
				var slot = Slot.new(slot_data, bone)
				slots.append(slot)
				draw_order.append(slot)

			#ik_constraints.resize(_data.ik_constraints.size())			
			#ik_constraints_sorted.resize(ik_constraints.size())
			#use clear instead of append here -- original java had different storage type
			ik_constraints.clear()
			ik_constraints_sorted.clear()

			for ik_constraint_data in _data.ik_constraints:
				ik_constraints.append(IkConstraint.new(ik_constraint_data, self))

			transform_constraints.resize(0)

			for transform_constraint_data in _data.transform_constraints:
				transform_constraints.append(TransformConstraint.new(transform_constraint_data, self))

			path_constraints.resize(0)

			for path_constraint_data in _data.path_constraints:
				path_constraints.append(PathConstraint.new(path_constraint_data, self))

			color = Color(1.0,1.0,1.0,1.0)
			update_cache()
	elif(arg1 is Skeleton):
		var _skeleton:Skeleton = arg1
		if _skeleton == null:
			push_error("skeleton cannot be null.")
		else:
			data = _skeleton.data
			bones.resize(_skeleton.bones.size())

			for bone in _skeleton.bones:
				var copy: Bone
				if bone.parent == null:
					copy = Bone.new(bone, self, null)
				else:
					var parent = bones[bone.parent.data.index]
					copy = Bone.new(bone, self, parent)
					parent.children.append(copy)

				bones.append(copy)

			slots.resize(_skeleton.slots.size())

			for slot in _skeleton.slots:
				var bone = bones[slot.bone.data.index]
				slots.append(Slot.new(slot, bone))

			draw_order.resize(slots.size())

			for slot in _skeleton.draw_order:
				draw_order.append(slots[slot.data.index])

			#ik_constraints.resize(_skeleton.ik_constraints.size())
			#ik_constraints_sorted.resize(ik_constraints.size())
			#use clear instead of append here -- original java had different storage type
			ik_constraints.clear()
			ik_constraints_sorted.clear()

			for ik_constraint in _skeleton.ik_constraints:
				ik_constraints.append(IkConstraint.new(ik_constraint, self))

			transform_constraints.resize(_skeleton.transform_constraints.size())

			for transform_constraint in _skeleton.transform_constraints:
				transform_constraints.append(TransformConstraint.new(transform_constraint, self))

			path_constraints.resize(_skeleton.path_constraints.size())

			for path_constraint in _skeleton.path_constraints:
				path_constraints.append(PathConstraint.new(path_constraint, self))

			skin = _skeleton.skin
			color = _skeleton.color
			time = _skeleton.time
			flip_x = _skeleton.flip_x
			flip_y = _skeleton.flip_y
			update_cache()

func update_cache() -> void:
	update_cache_array.clear()

	for bone in bones:
		bone.sorted = false

	var ik_constraints = ik_constraints_sorted
	ik_constraints_sorted.clear()
	ik_constraints.append_array(self.ik_constraints)

	for ik in ik_constraints:
		var bone = ik.bones[0].parent
		var level = 0

		while bone != null:
			level += 1
			bone = bone.parent

		ik.level = level

	for i in range(1, ik_constraints.size()):
		var ik = ik_constraints[i]
		var level = ik.level
		var ii = i - 1

		while ii >= 0:
			var other = ik_constraints[ii]
			if other.level < level:
				break

			ik_constraints[ii + 1] = other
			ii -= 1

		ik_constraints[ii + 1] = ik

	for ik in ik_constraints:
		var constraint = ik
		var target = constraint.target
		sort_bone(target)
		var constrained = constraint.bones
		var parent = constrained[0]
		sort_bone(parent)
		update_cache_array.append(constraint)
		sort_reset(parent.children)
		constrained[constrained.size()-1].sorted = true

	for path_constraint in path_constraints:
		var slot = path_constraint.target
		var slot_index = slot.get_data().index
		var slot_bone = slot.bone

		if skin != null:
			sort_path_constraint_attachment_skin(skin, slot_index, slot_bone)

		if data.default_skin != null and data.default_skin != skin:
			sort_path_constraint_attachment_skin(data.default_skin, slot_index, slot_bone)

		for skin_data in data.skins:
			sort_path_constraint_attachment_skin(skin_data, slot_index, slot_bone)

		var attachment = slot.attachment
		if attachment is PathAttachment:
			sort_path_constraint_attachment(attachment, slot_bone)

		var constrained = path_constraint.bones
		for bone in constrained:
			sort_bone(bone)

		update_cache_array.append(path_constraint)

		for bone in constrained:
			sort_reset(bone.children)

		for bone in constrained:
			bone.sorted = true

	for transform_constraint in transform_constraints:
		sort_bone(transform_constraint.target)
		
		var constrained = transform_constraint.bones
		for bone in constrained:
			sort_bone(bone)

		update_cache_array.append(transform_constraint)

		for bone in constrained:
			sort_reset(bone.children)

		for bone in constrained:
			bone.sorted = true

	for bone in bones:
		sort_bone(bone)

# Sort path constraint attachment by skin and slotBone
func sort_path_constraint_attachment_skin(skin: SpineSkin, slot_index: int, slot_bone: Bone) -> void:
	for key in skin.attachments.keys():
		var entry=skin.attachments.get(key)
		if entry.key.slot_index == slot_index:
			sort_path_constraint_attachment(entry, slot_bone)

# Sort path constraint attachment by attachment and slotBone
func sort_path_constraint_attachment(attachment: Attachment, slot_bone: Bone) -> void:
	if attachment is PathAttachment:
		var path_bones = attachment.get_bones()
		if path_bones == null:
			sort_bone(slot_bone)
		else:
			for bone_index in path_bones:
				sort_bone(bones[bone_index])

# Sort a single bone
func sort_bone(bone: Bone) -> void:
	if not bone.sorted:
		if bone.parent != null:
			sort_bone(bone.parent)
		bone.sorted = true
		update_cache_array.append(bone)

# Reset the sorted state for a list of bones
func sort_reset(bone_list: Array) -> void:
	for bone in bone_list:
		if bone.sorted:
			sort_reset(bone.children)
		bone.sorted = false

# Update the world transform for all updatable elements
func update_world_transform() -> void:
	for updatable in update_cache_array:
		updatable.update()

# Set the skeleton to its setup pose
func set_to_setup_pose() -> void:
	set_bones_to_setup_pose()
	set_slots_to_setup_pose()

# Set all bones to their setup pose
func set_bones_to_setup_pose() -> void:
	for bone in bones:
		bone.set_to_setup_pose()

	for ik_constraint in ik_constraints:
		ik_constraint.bend_direction = ik_constraint.data.bend_direction
		ik_constraint.mix = ik_constraint.data.mix

	for transform_constraint in transform_constraints:
		transform_constraint.rotate_mix = transform_constraint.data.rotate_mix
		transform_constraint.translate_mix = transform_constraint.data.translate_mix
		transform_constraint.scale_mix = transform_constraint.data.scale_mix
		transform_constraint.shear_mix = transform_constraint.data.shear_mix

	for path_constraint in path_constraints:
		path_constraint.position = path_constraint.data.position
		path_constraint.spacing = path_constraint.data.spacing
		path_constraint.rotate_mix = path_constraint.data.rotate_mix
		path_constraint.translate_mix = path_constraint.data.translate_mix

# Set all slots to their setup pose
func set_slots_to_setup_pose() -> void:
	draw_order = slots.duplicate()  # Clone the draw order from slots
	for slot in slots:
		slot.set_to_setup_pose()

# Getters
func get_data() -> SkeletonData:
	return data

func get_bones() -> Array:
	return bones

func get_update_cache() -> Array:
	return update_cache_array

func get_root_bone() -> Bone:
	return bones[0] if bones.size() > 0 else null

func find_bone(bone_name: String) -> Bone:
	if bone_name == null:
		push_error("boneName cannot be null")
		return null
	for bone in bones:
		if bone.data.name == bone_name:
			return bone
	return null

func find_bone_index(bone_name: String) -> int:
	if bone_name == null:
		push_error("boneName cannot be null")
		return -1
	for i in range(bones.size()):
		if bones[i].data.name == bone_name:
			return i
	return -1

func get_slots() -> Array:
	return slots

func find_slot(slot_name: String) -> Slot:
	if slot_name == null:
		push_error("slotName cannot be null")
		return null
	for slot in slots:
		if slot.data.name == slot_name:
			return slot
	return null

func find_slot_index(slot_name: String) -> int:
	if slot_name == null:
		push_error("slotName cannot be null")
		return -1
	for i in range(slots.size()):
		if slots[i].data.name == slot_name:
			return i
	return -1

func get_draw_order() -> Array:
	return draw_order

func set_draw_order(new_draw_order: Array) -> void:
	if new_draw_order == null:
		push_error("drawOrder cannot be null")
	else:
		draw_order = new_draw_order

func get_skin() -> SpineSkin:
	return skin

# Set skin by name
func set_skin_by_name(skin_name: String) -> void:
	var skin = data.find_skin(skin_name)
	if skin == null:
		push_error("Skin not found: " + skin_name)
	else:
		set_skin(skin)

# Set skin
func set_skin(new_skin: SpineSkin) -> void:
	if new_skin != null:
		if skin != null:
			new_skin.attach_all(self, skin)
		else:
			for i in range(slots.size()):
				var slot = slots[i]
				var name = slot.data.attachment_name
				if name != null:
					var attachment = new_skin.get_attachment(i, name)
					if attachment != null:
						slot.set_attachment(attachment)
	skin = new_skin

# Get attachment by slot name and attachment name
func get_attachment_by_name(slot_name: String, attachment_name: String) -> Attachment:
	return get_attachment(data.find_slot_index(slot_name), attachment_name)

# Get attachment by slot index and attachment name
func get_attachment(slot_index: int, attachment_name: String) -> Attachment:
	if attachment_name == null:
		push_error("attachmentName cannot be null")
		return null
	if skin != null:
		var attachment = skin.get_attachment(slot_index, attachment_name)
		if attachment != null:
			return attachment
	return data.default_skin.get_attachment(slot_index, attachment_name) if data.default_skin != null else null

# Set attachment for a slot by name
func set_attachment(slot_name: String, attachment_name: String) -> void:
	if slot_name == null:
		push_error("slotName cannot be null")
		return
	for i in range(slots.size()):
		var slot = slots[i]
		if slot.data.name == slot_name:
			var attachment = null
			if attachment_name != null:
				attachment = get_attachment(i, attachment_name)
				if attachment == null:
					push_error("Attachment not found: " + attachment_name + ", for slot: " + slot_name)
					return
			slot.set_attachment(attachment)
			return
	push_error("Slot not found: " + slot_name)

# Get IK constraints
func get_ik_constraints() -> Array:
	return ik_constraints

# Find IK constraint by name
func find_ik_constraint(constraint_name: String) -> IkConstraint:
	if constraint_name == null:
		push_error("constraintName cannot be null")
		return null
	for ik_constraint in ik_constraints:
		if ik_constraint.data.name == constraint_name:
			return ik_constraint
	return null

# Get transform constraints
func get_transform_constraints() -> Array:
	return transform_constraints

# Find transform constraint by name
func find_transform_constraint(constraint_name: String) -> TransformConstraint:
	if constraint_name == null:
		push_error("constraintName cannot be null")
		return null
	for transform_constraint in transform_constraints:
		if transform_constraint.data.name == constraint_name:
			return transform_constraint
	return null

# Get path constraints
func get_path_constraints() -> Array:
	return path_constraints

# Find path constraint by name
func find_path_constraint(constraint_name: String) -> PathConstraint:
	if constraint_name == null:
		push_error("constraintName cannot be null")
		return null
	for path_constraint in path_constraints:
		if path_constraint.data.name == constraint_name:
			return path_constraint
	return null

# Get bounds of the skeleton
func get_bounds(offset: Vector2, size: Vector2) -> void:
	if offset == null:
		push_error("offset cannot be null")
		return
	if size == null:
		push_error("size cannot be null")
		return

	var min_x = INF
	var min_y = INF
	var max_x = -INF
	var max_y = -INF

	for slot in draw_order:
		var vertices = null
		var attachment = slot.attachment
		if attachment is RegionAttachment:
			vertices = attachment.update_world_vertices(slot, false)
		elif attachment is MeshAttachment:
			vertices = attachment.update_world_vertices(slot, true)

		if vertices != null:
			for j in range(0, vertices.size(), 5):
				var x = vertices[j]
				var y = vertices[j + 1]
				min_x = min(min_x, x)
				min_y = min(min_y, y)
				max_x = max(max_x, x)
				max_y = max(max_y, y)

	offset.x=min_x
	offset.y=min_y
	size.x=max_x-min_x
	size.y=max_y-min_y

# Get color
func get_color() -> Color:
	return color

# Set color
func set_color(new_color: Color) -> void:
	if new_color == null:
		push_error("color cannot be null")
	else:
		color = new_color

# Get and set flip X
func get_flip_x() -> bool:
	return flip_x

func set_flip_x(value: bool) -> void:
	flip_x = value

# Get and set flip Y
func get_flip_y() -> bool:
	return flip_y

func set_flip_y(value: bool) -> void:
	flip_y = value

# Set both flip X and Y
func set_flip(x: bool, y: bool) -> void:
	flip_x = x
	flip_y = y

# Get and set position
func get_x() -> float:
	return x

func set_x(value: float) -> void:
	x = value

func get_y() -> float:
	return y

func set_y(value: float) -> void:
	y = value

func set_position(new_x: float, new_y: float) -> void:
	x = new_x
	y = new_y

# Get and set time
func get_time() -> float:
	return time

func set_time(value: float) -> void:
	time = value

# Update time with delta
func update(delta: float) -> void:
	time += delta

# To string method
func _to_string() :
	return data.name if data.name != null else super.to_string()
