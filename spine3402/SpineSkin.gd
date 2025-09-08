class_name SpineSkin

var lookup:SpineSkin.Key = Key.new()
var name : String
var attachments = {}
var key_pool = []

func _init(_name: String):
	if _name == null:
		push_error("name cannot be null.")
		return
	name = _name
	for i in range(64):
		key_pool.append(SpineSkin.Key.new())

func add_attachment(slot_index: int, _name: String, attachment):
	if attachment == null:
		push_error("attachment cannot be null.")
		return
	if slot_index < 0:
		push_error("slotIndex must be >= 0.")
		return
	var key:SpineSkin.Key = key_pool.pop_back()
	attachment.key=key
	key.set_(slot_index, _name)
	attachments[key.hash()] = attachment
	#print("Attachment: ",slot_index," ",_name," ",key.hash())

func get_attachment(slot_index: int, _name: String):
	if slot_index < 0:
		push_error("slotIndex must be >= 0.")
		return null
	lookup.set_(slot_index, _name)
	return attachments.get(lookup.hash())

func find_names_for_slot(slot_index: int, names: Array):
	if names == null:
		push_error("names cannot be null.")
		return
	if slot_index < 0:
		push_error("slotIndex must be >= 0.")
		return
	for key:SpineSkin.Key in attachments.keys():
		if key.slot_index == slot_index:
			names.append(key.name)

func find_attachments_for_slot(slot_index: int, attachments_array: Array):
	if attachments_array == null:
		push_error("attachments cannot be null.")
		return
	if slot_index < 0:
		push_error("slotIndex must be >= 0.")
		return
	for entry in attachments.keys():
		if entry.slot_index == slot_index:
			attachments_array.append(attachments[entry.hash()])

func clear():
	key_pool.clear()
	for i in range(64):
		key_pool.append(SpineSkin.Key.new())
	attachments.clear()

func get_name():
	return name

func attachments_iterator():
	return attachments.values()

func _to_string():
	return name

func attach_all(skeleton, old_skin):
	for entry:SpineSkin.Key in old_skin.attachments.keys():
		var slot_index = entry.slot_index
		var slot = skeleton.slots[slot_index]
		if slot.attachment == old_skin.attachments[entry]:
			var attachment = get_attachment(slot_index, entry.name)
			if attachment != null:
				slot.set_attachment(attachment)


class Key:
	var slot_index: int
	var name: String
	var hash_code: int

	func _init():
		pass

	func set_(slot_index: int, name: String):
		if name == null:
			push_error("name cannot be null.")
		else:
			self.slot_index = slot_index
			self.name = name
			self.hash_code = 31 * (31 + name.hash()) + slot_index

	func hash():
		return self.hash_code

	func equals(other):
		if other == null:
			return false
		return self.slot_index == other.slot_index and self.name == other.name

	func _to_string():
		return str(self.slot_index) + ":" + self.name
