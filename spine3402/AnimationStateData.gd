class_name AnimationStateData

# Member variables.
var skeleton_data	# The associated SkeletonData instance.
var animation_to_mix_time = {}  # Dictionary to simulate ObjectFloatMap<Key>.
var temp_key = {}	# Temporary dictionary for mix lookups.
var default_mix = 0.0  # Default mix time.

# Constructor.
func _init(skeleton_data):
	if skeleton_data == null:
		push_error("skeleton_data cannot be null.")
		return
	self.skeleton_data = skeleton_data

# Gets the associated SkeletonData.
func get_skeleton_data():
	return skeleton_data

# Sets the mix time for animations specified by names.
func set_mix_by_name(from_name, to_name, duration):
	var from_anim = skeleton_data.find_animation(from_name)
	if from_anim == null:
		push_error("Animation not found: %s" % from_name)
		return
	var to_anim = skeleton_data.find_animation(to_name)
	if to_anim == null:
		push_error("Animation not found: %s" % to_name)
		return
	set_mix(from_anim, to_anim, duration)

# Sets the mix time for animations.
func set_mix(from_anim, to_anim, duration):
	if from_anim == null:
		push_error("from_anim cannot be null.")
		return
	if to_anim == null:
		push_error("to_anim cannot be null.")
		return
	var key=Key.new(from_anim,to_anim)
	animation_to_mix_time[key] = duration

# Retrieves the mix time for the given animations.
func get_mix(from_anim, to_anim):
	temp_key["a1"] = from_anim
	temp_key["a2"] = to_anim
	if temp_key in animation_to_mix_time:
		return animation_to_mix_time[temp_key]
	return default_mix

# Gets the default mix time.
func get_default_mix():
	return default_mix

# Sets the default mix time.
func set_default_mix(value):
	default_mix = value

# =============================================================================
# Inner class: Key (simulated as dictionary in GDScript)
# =============================================================================
class Key:
	var a1 = null  # First animation.
	var a2 = null  # Second animation.

	func _init(a1 = null, a2 = null):
		self.a1 = a1
		self.a2 = a2

	func hash_code():
		return 31 * (31 + (a1.hash() if a1 != null else 0)) + (a2.hash() if a2 != null else 0)

	func equals(other):
		if other == null or !(other is Key):
			return false
		if a1 == null:
			if other.a1 != null:
				return false
		elif not a1.equals(other.a1):
			return false
		if a2 == null:
			if other.a2 != null:
				return false
		elif not a2.equals(other.a2):
			return false
		return true
