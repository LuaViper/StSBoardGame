extends Attachment
class_name SkeletonAttachment

var skeleton:Skeleton

func _init(name: String) -> void:
	super._init(name)

func get_skeleton() -> Skeleton:
	return skeleton

func set_skeleton(new_skeleton: Skeleton) -> void:
	skeleton = new_skeleton
