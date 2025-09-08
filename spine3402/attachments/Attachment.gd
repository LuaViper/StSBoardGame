class_name Attachment

var name: String
var key:SpineSkin.Key

func _init(name: String):
	# Ensure the passed name is not null
	assert(name != null, "name cannot be null.")
	self.name = name

func get_name() -> String:
	return name

func _to_string() :
	return get_name()
