class_name Slot

var data
var bone
var color
var attachment
var attachment_time : float
var attachment_vertices = []

func _init(var1, _bone):
	assert(var1 is SlotData || var1 is Slot,"First arg to Slot._init must be SlotData or Slot "+var1.to_string())
	if(var1 is SlotData):
		var _data=var1
		if _data == null:
			push_error("data cannot be null.")
			return
		if _bone == null:
			push_error("bone cannot be null.")
			return
		data = _data
		bone = _bone
		color = Color()
		set_to_setup_pose()
	elif(var1 is Slot):
		var slot=var1
		if slot == null:
			push_error("slot cannot be null.")
			return
		if _bone == null:
			push_error("bone cannot be null.")
			return
		data = slot.data
		bone = _bone
		color = slot.color
		attachment = slot.attachment
		attachment_time = slot.attachment_time


func get_data():
	return data

func get_bone():
	return bone

func get_skeleton():
	return bone.skeleton

func get_color():
	return color

func get_attachment():
	return attachment

func set_attachment(_attachment):
	if attachment != _attachment:
		attachment = _attachment
		attachment_time = bone.skeleton.time
		attachment_vertices.clear()

func set_attachment_time(time):
	attachment_time = bone.skeleton.time - time

func get_attachment_time():
	return bone.skeleton.time - attachment_time

func set_attachment_vertices(_attachment_vertices):
	if _attachment_vertices == null:
		push_error("attachmentVertices cannot be null.")
		return
	attachment_vertices = _attachment_vertices

func get_attachment_vertices():
	return attachment_vertices

func set_to_setup_pose():
	color = data.color
	if data.attachment_name == null:
		set_attachment(null)
	else:
		attachment = null
		set_attachment(bone.skeleton.get_attachment(data.index, data.attachment_name))

func _to_string():
	return data.name
