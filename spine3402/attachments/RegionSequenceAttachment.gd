extends RegionAttachment
class_name RegionSequenceAttachment

enum Mode {
	forward,
	backward,
	forwardLoop,
	backwardLoop,
	pingPong,
	random
}

var mode: Mode
var frame_time: float
var regions: Array[TextureRegion]

func _init(name):
	super._init(name)

# Computes and returns the updated world vertices.
func update_world_vertices(slot, premultiplied_alpha: bool) -> Array[float]:
	assert(regions != null, "Regions have not been set: " + str(self))
	
	# Compute the frame index based on the attachment time and frame time.
	var frame_index: int = int(slot.get_attachment_time() / frame_time)
	
	# Adjust the frame index according to the mode.
	match mode:
		Mode.forward:
			frame_index = min(regions.size() - 1, frame_index)
		Mode.forwardLoop:
			frame_index %= regions.size()
		Mode.pingPong:
			frame_index %= (regions.size() << 1)
			if frame_index >= regions.size():
				frame_index = regions.size() - 1 - (frame_index - regions.size())
		Mode.random:
			#TODO: we *think* the range is correct here but maybe double-check
			frame_index = randi_range(0, regions.size()-1)
		Mode.backward:
			frame_index = max(regions.size() - frame_index - 1, 0)
		Mode.backwardLoop:
			frame_index %= regions.size()
			frame_index = regions.size() - frame_index - 1
	
	# Set the current region based on the computed frame index.
	set_region(regions[frame_index])
	
	# Return the updated world vertices computed by the parent method.
	return super.update_world_vertices(slot, premultiplied_alpha)

# Getter for regions.
func get_regions() -> Array[TextureRegion]:
	assert(regions != null, "Regions have not been set: " + str(self))
	return regions

# Setter for regions.
func set_regions(new_regions: Array[TextureRegion]) -> void:
	regions = new_regions

# Setter for the frame time.
func set_frame_time(new_frame_time: float) -> void:
	frame_time = new_frame_time

# Setter for the mode.
func set_mode(new_mode: Mode) -> void:
	mode = new_mode
