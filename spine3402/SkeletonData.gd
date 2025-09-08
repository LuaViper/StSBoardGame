class_name SkeletonData

var name: String
var bones: Array = []
var slots: Array = []
var skins: Array = []
var default_skin: SpineSkin
var events: Array = []
var animations: Array = []
var ik_constraints: Array = []
var transform_constraints: Array = []
var path_constraints: Array = []
var width: float
var height: float
var version: String
var hash: String
var images_path: String

func _init():
	pass

func get_bones() -> Array:
	return bones

func find_bone(bone_name: String) -> BoneData:
	if bone_name == null:
		push_error("boneName cannot be null.")
		return null
	for bone in bones:
		if bone.name == bone_name:
			return bone
	return null

func find_bone_index(bone_name: String) -> int:
	if bone_name == null:
		push_error("boneName cannot be null.")
		return -1
	for i in range(len(bones)):
		if bones[i].name == bone_name:
			return i
	return -1

func get_slots() -> Array:
	return slots

func find_slot(slot_name: String) -> SlotData:
	if slot_name == null:
		push_error("slotName cannot be null.")
		return null
	for slot in slots:
		if slot.name == slot_name:
			return slot
	return null

func find_slot_index(slot_name: String) -> int:
	if slot_name == null:
		push_error("slotName cannot be null.")
		return -1
	for i in range(len(slots)):
		if slots[i].name == slot_name:
			return i
	return -1

func get_default_skin() -> SpineSkin:
	return default_skin

func set_default_skin(skin: SpineSkin):
	default_skin = skin

func find_skin(skin_name: String) -> SpineSkin:
	if skin_name == null:
		push_error("skinName cannot be null.")
		return null
	for skin in skins:
		if skin.name == skin_name:
			return skin
	return null

func get_skins() -> Array:
	return skins

func find_event(event_data_name: String) -> EventData:
	if event_data_name == null:
		push_error("eventDataName cannot be null.")
		return null
	for event_data in events:
		if event_data.name == event_data_name:
			return event_data
	return null

func get_events() -> Array:
	return events

func get_animations() -> Array:
	return animations

func find_animation(animation_name: String) -> Animation_:
	if animation_name == null:
		push_error("animationName cannot be null.")
		return null
	for animation in animations:
		if animation.name == animation_name:
			return animation
	return null

func get_ik_constraints() -> Array:
	return ik_constraints

func find_ik_constraint(constraint_name: String) -> IkConstraintData:
	if constraint_name == null:
		push_error("constraintName cannot be null.")
		return null
	for constraint in ik_constraints:
		if constraint.name == constraint_name:
			return constraint
	return null

func get_transform_constraints() -> Array:
	return transform_constraints

func find_transform_constraint(constraint_name: String) -> TransformConstraintData:
	if constraint_name == null:
		push_error("constraintName cannot be null.")
		return null
	for constraint in transform_constraints:
		if constraint.name == constraint_name:
			return constraint
	return null

func get_path_constraints() -> Array:
	return path_constraints

func find_path_constraint(constraint_name: String) -> PathConstraintData:
	if constraint_name == null:
		push_error("constraintName cannot be null.")
		return null
	for constraint in path_constraints:
		if constraint.name == constraint_name:
			return constraint
	return null

func find_path_constraint_index(path_constraint_name: String) -> int:
	if path_constraint_name == null:
		push_error("pathConstraintName cannot be null.")
		return -1
	for i in range(len(path_constraints)):
		if path_constraints[i].name == path_constraint_name:
			return i
	return -1

func get_name() -> String:
	return name

func set_name(new_name: String):
	name = new_name

func get_width() -> float:
	return width

func set_width(new_width: float):
	width = new_width

func get_height() -> float:
	return height

func set_height(new_height: float):
	height = new_height

func get_version() -> String:
	return version

func set_version(new_version: String):
	version = new_version

func get_hash() -> String:
	return hash

func set_hash(new_hash: String):
	hash = new_hash

func get_images_path() -> String:
	return images_path

func set_images_path(new_images_path: String):
	images_path = new_images_path

func _to_string() :
	#original java returned "super.toString()" where super pointed directly to Object
	return name if name != null else self.to_string()
