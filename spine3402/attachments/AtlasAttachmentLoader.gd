class_name AtlasAttachmentLoader extends AttachmentLoader

var atlas:SpineTextureAtlas

func _init(atlas):
	assert(atlas != null, "atlas cannot be null.")
	self.atlas = atlas

func new_region_attachment(skin:SpineSkin, name: String, path: String):
	var region = atlas.find_region(path)
	assert(region != null, "Region not found in atlas: " + path + " (region attachment: " + name + ")")
	var attachment = RegionAttachment.new(name)
	attachment.set_region(region)
	return attachment

func new_mesh_attachment(skin:SpineSkin, name: String, path: String):	
	var region = atlas.find_region(path)
	assert(region != null, "Region not found in atlas: " + path + " (mesh attachment: " + name + ")")
	var attachment = MeshAttachment.new(name)
	attachment.set_region(region)
	return attachment

func new_bounding_box_attachment(skin:SpineSkin, name: String):
	return BoundingBoxAttachment.new(name)

func new_path_attachment(skin:SpineSkin, name: String):
	return PathAttachment.new(name)
