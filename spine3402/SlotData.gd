class_name SlotData

var index: int
var name: String
var bone_data
var color: Color = Color(1.0, 1.0, 1.0, 1.0)
var attachment_name
var blend_mode

func _init(_index: int, _name: String, _bone_data):
	if _index < 0:
		push_error("index must be >= 0.")
		return
	if _name == null:
		push_error("name cannot be null.")
		return
	if _bone_data == null:
		push_error("boneData cannot be null.")
		return
	index = _index
	name = _name
	bone_data = _bone_data

func get_index() -> int:
	return index

func get_name() -> String:
	return name

func get_bone_data():
	return bone_data

func get_color() -> Color:
	return color

func set_attachment_name(_attachment_name: String):
	attachment_name = _attachment_name

func get_attachment_name() -> String:
	return attachment_name

func get_blend_mode():
	return blend_mode

func set_blend_mode(_blend_mode):
	blend_mode = _blend_mode

func _to_string() :
	return name
