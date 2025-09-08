extends Pool
class_name SkeletonPool

var skeleton_data

func _init(skeleton_data, initial_capacity = null, max_val = null):
	if initial_capacity != null and max_val != null:
		super._init(initial_capacity, max_val)
	elif initial_capacity != null:
		super._init(initial_capacity)
	else:
		super._init()
	self.skeleton_data = skeleton_data

func new_object():
	return Skeleton.new(skeleton_data)
