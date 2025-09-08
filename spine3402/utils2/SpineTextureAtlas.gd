class_name SpineTextureAtlas

# Equivalent to static final String[] tuple = new String[4];
var tuple = ["", "", "", ""]

# Using arrays instead of ObjectSet and ArrayList
var textures = []
var regions = []

# Equivalent to the Java comparator (sorting function in GDScript)
static func index_comparator(region1, region2):
	var i1 = region1.index if region1.index != -1 else int(INF)
	var i2 = region2.index if region2.index != -1 else int(INF)
	return i1 - i2
	
	

func _init(var1=null, var2=false):
	textures = []
	textures.resize(4)
	regions = []
	if(var1 is String):
		var parent = var1.get_base_dir()
		var tda:TextureAtlasData = TextureAtlasData.new(var1, parent, var2)
		self.load(tda)
		
		
	

func load(data):
	var page_to_texture = {}

	for page in data.pages:
		var texture = null
		if page.get("texture") == null:
			#TODO: equivalent texture settings in GDScript would be needed
			#texture = Texture2D.new()
			texture = ZipFunctions.read_texture2d(page.texture_file)			#, page.format, page.useMipMaps);
			#texture.setFilter...
			#texture.setWrap...
		else:
			texture = ZipFunctions.read_texture2d(page.get("texture"))			#, page.format, page.useMipMaps);
			#texture.setFilter...
			#texture.setWrap...
			
		textures.append(texture)
		page_to_texture[page] = texture

	for region:Region in data.regions:
	#for region in data.regions:
		var width = region.width
		var height = region.height
		var atlas_region:SpineTextureAtlas.AtlasRegion = SpineTextureAtlas.AtlasRegion.new(page_to_texture.get(region.page),region.left,region.top,height if(region.rotate) else width,width if(region.rotate) else height)
		atlas_region.index = region.index
		atlas_region.name = region.name
		atlas_region.offset_x = region.offset_x
		atlas_region.offset_y = region.offset_y
		atlas_region.original_height = region.original_height
		atlas_region.original_width = region.original_width
		atlas_region.rotate = region.rotate
		atlas_region.splits = region.splits
		atlas_region.pads = region.pads
		if(region.flip):
			atlas_region.flip(false,true)
		
		regions.append(atlas_region)

func add_region(name, texture, x, y, width, height):
	textures.append(texture)
	var region:SpineTextureAtlas.AtlasRegion = SpineTextureAtlas.AtlasRegion.new(texture, x, y, width, height)
	region.name = name
	region.original_width = width
	region.original_height = height
	region.index = -1
	regions.append(region)
	return region



func get_regions():
	return regions

func find_region(name):
	for region in regions:
		if region.name == name:
			return region
	return null

func find_region_by_index(name, index):
	for region in regions:
		if region.name == name and region.index == index:
			return region
	return null

func find_regions(name):
	var matched = []
	for region in regions:
		if region.name == name:
			matched.append(region)
	return matched

func create_sprites():
	var sprites = []
	for region in regions:
		sprites.append(new_sprite(region))
	return sprites

func create_sprite(name):
	for region in regions:
		if region.name == name:
			return new_sprite(region)
	return null

func create_sprite_by_index(name, index):
	for region in regions:
		if region.name == name and region.index == index:
			return new_sprite(region)
	return null

func create_sprites_by_name(name):
	var matched = []
	for region in regions:
		if region.name == name:
			matched.append(new_sprite(region))
	return matched

func new_sprite(region):
	return null
	#if region.packed_width == region.original_width and region.packed_height == region.original_height:
		#if region.rotate:
			#var sprite = Sprite.new()
			#sprite.set_region_rect(Rect2(0, 0, region.get_region_height(), region.get_region_width()))
			#sprite.flip_h = true
			#return sprite
		#else:
			#return Sprite.new()
	#else:
		#return AtlasSprite.new()

func create_patch(name):
	return null
	#for region in regions:
		#if region.name == name:
			#if region.splits == null:
				#push_error("Region does not have ninepatch splits: " + name)
				#return null
			#var patch = NinePatch.new()
			#patch.set_region_rect(Rect2(0, 0, region.width, region.height))
			#if region.pads != null:
				#patch.set_padding(region.pads[0], region.pads[1], region.pads[2], region.pads[3])
			#return patch
	#return null



func get_textures():
	return textures

func dispose():
	for texture in textures:
		texture.queue_free()
	textures.clear()

static func read_value(reader):
	var line = reader.get_line()
	var colon = line.find(":")
	if colon == -1:
		push_error("Invalid line: " + line)
		return null
	return line.substr(colon + 1).strip_edges()

static func read_tuple(reader):
	var line = reader.get_line()
	var colon = line.find(":")
	if colon == -1:
		push_error("Invalid line: " + line)
		return null
	var values = line.substr(colon + 1).strip_edges().split(",")
	return values

class TextureAtlasData:
	var pages = []
	var regions = []

	func _init(pack_file, images_dir, flip):	
		var reader = ZipFunctions.extract_file_to_temp(pack_file)
		var page_image = null

		while not reader.eof_reached():
			var line = reader.get_line()
			if line.strip_edges().length() == 0:
				page_image = null
			elif page_image == null:
				var file = images_dir + "/" + line.strip_edges()
				var width = 0
				var height = 0
				var tuple = SpineTextureAtlas.read_tuple(reader)
				if len(tuple) == 2:
					width = int(tuple[0])
					height = int(tuple[1])
					tuple = SpineTextureAtlas.read_tuple(reader)

				var format = tuple[0]
				tuple = SpineTextureAtlas.read_tuple(reader)
				var min_filter = tuple[0]
				var max_filter = tuple[1]

				var direction = SpineTextureAtlas.read_value(reader)
				var repeat_x = "ClampToEdge"
				var repeat_y = "ClampToEdge"

				if direction == "x":
					repeat_x = "Repeat"
				elif direction == "y":
					repeat_y = "Repeat"
				elif direction == "xy":
					repeat_x = "Repeat"
					repeat_y = "Repeat"

				#page_image = {"file": file, "width": width, "height": height, "format": format, "min_filter": min_filter, "max_filter": max_filter, "repeat_x": repeat_x, "repeat_y": repeat_y}
				#TODO: mipmaps not supported yet because min_filter is a String instead of TextureFilter
				# check java Texture.TextureFilter.isMipMap implementation
				page_image = Page.new(file,width,height,false,format,min_filter,max_filter,repeat_x,repeat_y)
				pages.append(page_image)
			else:
				var rotate = (SpineTextureAtlas.read_value(reader)=="true")
				var tuple = SpineTextureAtlas.read_tuple(reader)
				var left = int(tuple[0])
				var top = int(tuple[1])

				tuple = SpineTextureAtlas.read_tuple(reader)
				var width = int(tuple[0])
				var height = int(tuple[1])

				var region = SpineTextureAtlas.Region.new()
				region.page = page_image
				region.left = left
				region.top = top
				region.width = width
				region.height = height
				region.name = line
				region.rotate = rotate				
				tuple = SpineTextureAtlas.read_tuple(reader)
				if len(tuple) == 4:
					region.splits = [int(tuple[0]), int(tuple[1]), int(tuple[2]), int(tuple[3])]
					tuple = SpineTextureAtlas.read_tuple(reader)
					if len(tuple) == 4:
						region.pads = [int(tuple[0]), int(tuple[1]), int(tuple[2]), int(tuple[3])]
						tuple = SpineTextureAtlas.read_tuple(reader)

				region.original_width = int(tuple[0])
				region.original_height = int(tuple[1])
				tuple = SpineTextureAtlas.read_tuple(reader)
				region.offset_x = int(tuple[0])
				region.offset_y = int(tuple[1])
				region.index = int(SpineTextureAtlas.read_value(reader))
				if flip:
					region.flip = true

				regions.append(region)
		
		reader.close()



class Page:
	var texture_file
	var texture
	var width
	var height
	var use_mip_maps
	var format
	var min_filter
	var mag_filter
	var u_wrap
	var v_wrap

	func _init(handle, width, height, use_mip_maps, format, min_filter, mag_filter, u_wrap, v_wrap):
		self.texture_file = handle
		self.width = width
		self.height = height
		self.use_mip_maps = use_mip_maps
		self.format = format
		self.min_filter = min_filter
		self.mag_filter = mag_filter
		self.u_wrap = u_wrap
		self.v_wrap = v_wrap

class Region:
	var page
	var index
	var name
	var offset_x
	var offset_y
	var original_width
	var original_height
	var rotate:bool
	var left
	var top
	var width
	var height
	var flip
	var splits
	var pads

	func _init():
		pass

class AtlasRegion extends TextureRegion_:
	var index
	var name
	var offset_x
	var offset_y
	var packed_width
	var packed_height
	var original_width
	var original_height
	var rotate
	var splits
	var pads

	func _init(texture, x, y, width, height):
		super._init(texture, x, y, width, height)
		self.original_width = width
		self.original_height = height
		self.packed_width = width
		self.packed_height = height

	func flip(x, y):
		if x:
			self.offset_x = self.original_width - self.offset_x - self.get_rotated_packed_width()
		if y:
			self.offset_y = self.original_height - self.offset_y - self.get_rotated_packed_height()

	func get_rotated_packed_width():
		return self.packed_height if self.rotate else self.packed_width

	func get_rotated_packed_height():
		return self.packed_width if self.rotate else self.packed_height

	func _to_string():
		return self.name

class AtlasSprite extends Sprite2D:
	var region
	var original_offset_x
	var original_offset_y

	func _init(region):
		self.region = region
		self.original_offset_x = region.offset_x
		self.original_offset_y = region.offset_y

	func set_position_(x, y):
		self.region.offset_x = x + self.region.offset_x
		self.region.offset_y = y + self.region.offset_y

	func set_bounds(x, y, width, height):
		var width_ratio = width / self.region.original_width
		var height_ratio = height / self.region.original_height
		self.region.offset_x = self.original_offset_x * width_ratio
		self.region.offset_y = self.original_offset_y * height_ratio
		var packed_width = self.region.packed_height if self.region.rotate else self.region.packed_width
		var packed_height = self.region.packed_width if self.region.rotate else self.region.packed_height
		self.region.offset_x = x + self.region.offset_x
		self.region.offset_y = y + self.region.offset_y

	func set_size(width, height):
		self.set_bounds(self.get_x(), self.get_y(), width, height)

	func set_origin(origin_x, origin_y):
		#super.set_origin(origin_x - self.region.offset_x, origin_y - self.region.offset_y)
		#TODO:
		pass

	func set_origin_center():
		#super.set_origin(self.get_width() / 2.0 - self.region.offset_x, self.get_height() / 2.0 - self.region.offset_y)
		#TODO:
		pass

	func flip(x, y):
		if self.region.rotate:
			flip_h=y
			flip_v=x
		else:
			flip_h=x
			flip_v=y

		var old_origin_x = self.get_origin_x()
		var old_origin_y = self.get_origin_y()
		var old_offset_x = self.region.offset_x
		var old_offset_y = self.region.offset_y
		var width_ratio = self.get_width_ratio()
		var height_ratio = self.get_height_ratio()

		self.region.offset_x = self.original_offset_x
		self.region.offset_y = self.original_offset_y
		self.region.flip(x, y)

		self.original_offset_x = self.region.offset_x
		self.original_offset_y = self.region.offset_y

		self.region.offset_x *= width_ratio
		self.region.offset_y *= height_ratio

		self.translate(Vector2(self.region.offset_x - old_offset_x, self.region.offset_y - old_offset_y))
		self.set_origin(old_origin_x, old_origin_y)

	func rotate_90(clockwise):
		var old_origin_x = self.get_origin_x()
		var old_origin_y = self.get_origin_y()
		var old_offset_x = self.region.offset_x
		var old_offset_y = self.region.offset_y
		var width_ratio = self.get_width_ratio()
		var height_ratio = self.get_height_ratio()

		if clockwise:
			self.region.offset_x = old_offset_y
			self.region.offset_y = self.region.original_height * height_ratio - old_offset_x - self.region.packed_width * width_ratio
		else:
			self.region.offset_x = self.region.original_width * width_ratio - old_offset_y - self.region.packed_height * height_ratio
			self.region.offset_y = old_offset_x

		self.translate(Vector2(self.region.offset_x - old_offset_x, self.region.offset_y - old_offset_y))
		self.set_origin(old_origin_x, old_origin_y)

	func get_x():
		return self.position.x - self.region.offset_x

	func get_y():
		return self.position.y - self.region.offset_y

	func get_origin_x():
		return self.get_origin_x() + self.region.offset_x

	func get_origin_y():
		return self.get_origin_y() + self.region.offset_y

	func get_width():
		return self.get_width() / self.region.get_rotated_packed_width() * self.region.original_width

	func get_height():
		return self.get_height() / self.region.get_rotated_packed_height() * self.region.original_height

	func get_width_ratio():
		return self.get_width() / self.region.get_rotated_packed_width()

	func get_height_ratio():
		return self.get_height() / self.region.get_rotated_packed_height()

	func get_atlas_region():
		return self.region

	func _to_string():
		return self.region.to_string()
