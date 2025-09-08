extends VertexAttachment
class_name MeshAttachment

# MeshAttachment represents a textured mesh with UV mapping, triangle data,
# deformation support, and optional inheritance of vertices from a parent mesh.

# Member variables
var region = null                   
var path: String = ""               
var region_uvs: Array
var world_vertices: Array
var triangles: Array
var color: Color = Color(1.0, 1.0, 1.0, 1.0)
var hull_length: int = 0
var parent_mesh: MeshAttachment
var inherit_deform: bool
var edges: Array
var width: float
var height: float

func _init(name: String):
	super._init(name)

func set_region(region):
	assert(region != null, "region cannot be null.")
	self.region = region

func get_region():
	if self.region == null:
		assert(false, "Region has not been set: " + str(self))
	return self.region


func update_uvs():
	var r_uvs:Array = self.region_uvs
	var vertices_length = r_uvs.size()
	var world_vertices_length = (vertices_length >> 1) * 5
	
	if self.world_vertices == null or self.world_vertices.size() != world_vertices_length:
		self.world_vertices = []
		self.world_vertices.resize(world_vertices_length)
		self.world_vertices.fill(0.0)
			
	var u: float
	var v: float
	var region_width: float
	var region_height: float
	
	if self.region == null:
		u = 0.0
		v = 0.0
		region_width = 1.0
		region_height = 1.0
	else:
		u = self.region.u
		v = self.region.v
		region_width = self.region.u2 - u
		region_height = self.region.v2 - v
		
	if self.region is SpineTextureAtlas.AtlasRegion and self.region.rotate:
		var i = 0
		var w = 3
		while(i < vertices_length):
			self.world_vertices[w] = u + r_uvs[i + 1] * region_width
			self.world_vertices[w + 1] = v + region_height - r_uvs[i] * region_height
			i += 2
			w += 5
	else:
		var i = 0
		var w = 3
		while(i < vertices_length):
			self.world_vertices[w] = u + r_uvs[i] * region_width
			self.world_vertices[w + 1] = v + r_uvs[i + 1] * region_height
			i += 2
			w += 5
	var foo=0
	foo+=1
	return	


func update_world_vertices(slot:Slot, premultiplied_alpha: bool) -> Array:
	var skeleton:Skeleton = slot.get_skeleton()
	var skeleton_color:Color = skeleton.get_color()
	#book of stabbing transparency is handled by changing slot color
	var slot_color:Color = slot.get_color()
	var mesh_color:Color = self.color
	# Compute a composite alpha value.
	var alpha:float = skeleton_color.a * slot_color.a * mesh_color.a * 255.0
	var multiplier:float = alpha if premultiplied_alpha else 255.0
	
	# Pack the color components into a single integer then convert it.
	var packed_int = (int(alpha) << 24) | (int(skeleton_color.b * slot_color.b * mesh_color.b * multiplier) << 16) | (int(skeleton_color.g * slot_color.g * mesh_color.g * multiplier) << 8) | (int(skeleton_color.r * slot_color.r * mesh_color.r * multiplier))
	var computed_color:float = NumberUtils._int_to_float_color(packed_int)
	
	var x:float = skeleton.get_x()
	var y:float = skeleton.get_y()
	
	# Retrieve deformation info and the vertex data.
	#TODO NEXT: Ironclad's feet aren't correctly anchored to ground. Prime suspect is broken deform implementation.
	var deform_array = slot.get_attachment_vertices()  # Assumes an Array of floats.
	var vertices_array:Array = self.vertices            # Array inherited from VertexAttachment.	
	var world_vertices_array:Array = self.world_vertices  # This array was allocated in update_uvs.
	var bones_array = self.bones                  # Bone weights, inherited as well.
	
	if bones_array == null:
		# No bone weighting: transform vertices using a single bone.
		var vertices_length = vertices_array.size()
		if deform_array.size() > 0:
			vertices_array = deform_array
		var bone:Bone = slot.get_bone()
		x += bone.get_world_x()
		y += bone.get_world_y()
		var a:float = bone.get_a()
		var b:float = bone.get_b()
		var c:float = bone.get_c()
		var d:float = bone.get_d()
		var v:int = 0
		var w:int = 0
		while(v < vertices_length):
			var vx:float = vertices_array[v]
			var vy:float = vertices_array[v + 1]
			world_vertices_array[w] = vx * a + vy * b + x
			world_vertices_array[w + 1] = vx * c + vy * d + y
			world_vertices_array[w + 2] = computed_color
			v += 2		
			w += 5
		return world_vertices_array
	else:
		# For weighted vertices: combine transformations from multiple bones.
		var skeleton_bones:Array = skeleton.get_bones()  # Expecting an array of Bone objects.
		if deform_array.size() == 0:
			var w:int = 0
			var v:int = 0
			var b:int = 0
			
			var n:int = bones_array.size()
			while v < n:
				var wx = x
				var wy = y
				
				var nn:int = bones_array[v]
				v += 1
				nn+=v
				while v < nn:
					var bone:Bone = skeleton_bones[bones_array[v]]
					var vx:float = vertices_array[b]
					var vy:float= vertices_array[b + 1]
					var weight:float = vertices_array[b + 2]
					wx += (vx * bone.get_a() + vy * bone.get_b() + bone.get_world_x()) * weight
					wy += (vx * bone.get_c() + vy * bone.get_d() + bone.get_world_y()) * weight
					v += 1
					b += 3
				world_vertices_array[w] = wx
				world_vertices_array[w + 1] = wy
				world_vertices_array[w + 2] = computed_color
				w += 5
		else:
			var deform:Array = deform_array
			var w:int = 0
			var v:int = 0
			var b:int = 0
			var f:int = 0
			
			var n:int=bones_array.size()
			while v < n:
				var wx = x
				var wy = y
				
				var nn:int = bones_array[v]
				v += 1
				nn+=v
				while v < nn:
					var bone:Bone = skeleton_bones[bones_array[v]]
					var vx:float = vertices_array[b] + deform[f]
					var vy:float = vertices_array[b + 1] + deform[f + 1]
					var weight:float = vertices_array[b + 2]
					wx += (vx * bone.get_a() + vy * bone.get_b() + bone.get_world_x()) * weight
					wy += (vx * bone.get_c() + vy * bone.get_d() + bone.get_world_y()) * weight
					v += 1
					b += 3
					f += 2
				world_vertices_array[w] = wx
				world_vertices_array[w + 1] = wy
				world_vertices_array[w + 2] = computed_color
				w += 5
		return world_vertices_array


func apply_deform(source_attachment) -> bool:
	return self == source_attachment or (self.inherit_deform and self.parent_mesh == source_attachment)

func get_world_vertices() -> Array:
	return self.world_vertices

func get_triangles() -> Array:
	return self.triangles

func set_triangles(triangles:Array):
	self.triangles = triangles

func get_region_uvs() -> Array:
	return self.region_uvs

func set_region_uvs(region_uvs:Array):
	self.region_uvs = region_uvs

func get_color() -> Color:
	return self.color

func get_path() -> String:
	return self.path

func set_path(path: String):
	self.path = path

func get_hull_length() -> int:
	return self.hull_length

func set_hull_length(hull_length: int):
	self.hull_length = hull_length

func set_edges(edges:Array):
	self.edges = edges

func get_edges() -> Array:
	return self.edges

func get_width() -> float:
	return self.width

func set_width(width: float):
	self.width = width

func get_height() -> float:
	return self.height

func set_height(height: float):
	self.height = height

func get_parent_mesh() -> MeshAttachment:
	return self.parent_mesh

func set_parent_mesh(parent_mesh:MeshAttachment):
	self.parent_mesh = parent_mesh
	if parent_mesh != null:
		self.bones = parent_mesh.bones
		self.vertices = parent_mesh.vertices
		self.region_uvs = parent_mesh.region_uvs
		self.triangles = parent_mesh.triangles
		self.hull_length = parent_mesh.hull_length
		self.edges = parent_mesh.edges
		self.width = parent_mesh.width
		self.height = parent_mesh.height

func get_inherit_deform() -> bool:
	return self.inherit_deform

func set_inherit_deform(inherit_deform: bool):
	self.inherit_deform = inherit_deform
