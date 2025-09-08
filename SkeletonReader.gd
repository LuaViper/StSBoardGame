class_name SkeletonReader extends Node

static func test_load(scene):
	var install_location = "C:/Program Files (x86)/Steam/steamapps/common/SlayTheSpire/desktop-1.0.jar"
	var reader = ZIPReader.new()
	var err = reader.open(install_location)
	if err != OK:
		print("err")
		return null
		
	var skeletondata = reader.read_file("images/monsters/theBottom/cultist/skeleton.json").get_string_from_utf8()	
	var json=JSON.new()
	var error=json.parse(skeletondata)
	if error == OK:
		print("Bones count: ",json.data.bones.size())
		for bone:Dictionary in json.data.bones:
			validate_dictionary_keys(bone,["name","parent","x","y","rotation","length"])
			zero_null_dictionary_keys(bone,["x","y","rotation","length"])
			#print(bone.name," ",bone.parent," ",bone.x," ",bone.y," ",bone.rotation)
		for slot:Dictionary in json.data.slots:		
			validate_dictionary_keys(slot,["name","bone","attachment"])			
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in file at line ", json.get_error_line())		
	reader.close()	
	
	#TODO: return early if parse error

	#print("Scene: ",scene)
	#print(scene.get_node("Sprite2D"))
	
	var skeleton = Skeleton2D.new()
	scene.add_child(skeleton)
	skeleton.position.x=500
	skeleton.position.y=300
	var testsprite = preload("res://TestSprite.tscn")
	for bone:Dictionary in json.data.bones:
		var node=Bone2D.new()
		if(bone.name=="root"):
			skeleton.add_child(node)		
		bone.set("node",node)
		bone.set("parentnode",null)
		link_parent_bone(bone,json.data.bones)
		#node.position.x=bone.x
		#node.position.y=bone.y
		#reminder - this is not a typo, bone.rotation is in degrees
		#node.rotation_degrees=bone.rotation				
		#node.set_transform(Transform2D().rotated_local((bone.rotation)/180*PI).translated_local(Vector2(bone.x,-bone.y)))
		#node.set_transform(Transform2D().rotated((bone.rotation)/180*PI).translated(Vector2(bone.x,-bone.y)))
		node.set_length(bone.length)
		node.set_transform(Transform2D().rotated_local(bone.rotation/180*PI).translated_local(Vector2(bone.x,-bone.y)))
		#node.set_bone_angle(bone.rotation/180*PI)
		
		var spr=testsprite.instantiate()
		node.add_child(spr)
		bone.set("contents",spr)
		
		#assign texture to bone from json.data.slots
	for slot:Dictionary in json.data.slots:				
	#for bone in json.data.bones:
		var bone=find_bone(slot.bone,json.data.bones)
		var contents:Sprite2D=bone.contents.get_node("%Contents")
		#if(true):
		if(slot.attachment!=null):
			var rect2:Rect2 = AtlasHelper.CULTIST_SKELETON.get_rect2(slot.attachment)
			contents.region_enabled=true
			contents.region_filter_clip_enabled=true
			contents.region_rect=rect2
			var image:Image=AtlasHelper.CULTIST_SKELETON.get_image(slot.attachment)
			var texture:Texture2D=ImageTexture.create_from_image(image)			
			contents.texture=texture
			var rotate:bool = AtlasHelper.CULTIST_SKELETON.get_rotate(slot.attachment)
			print("Contents sprite: ",contents.position.x," ",contents.position.y)
			#contents.z_index=-bone.node.get_index_in_skeleton()
			if(rotate):
				#contents.texture=Texture2D.new()
				#TODO: this is supposed to be 90 degrees clockwise. verify
				contents.rotation_degrees-=90;
				#print(slot.attachment," is rotated in the atlas!")				
		#else:
			#contents.visible=false;

	#for bone in json.data.bones:
		#if(bone.name!="root"):
			#bone.node.hide()
	


static func validate_dictionary_keys(dict:Dictionary,keys:Array)->void:
	for key:String in keys:
		dict.set(key,dict.get(key))
		
static func zero_null_dictionary_keys(dict:Dictionary,keys:Array)->void:
	for key:String in keys:
		dict.set(key,dict.get(key)if dict.get(key) else 0)

static func find_bone(name:String,bones:Array):
	for b:Dictionary in bones:
		if(b.name==name):
			return b
	return null

static func link_parent_bone(bone:Dictionary,bones:Array)->void:
	if(!bone.parent):return
	var b=find_bone(bone.parent,bones)
	if(b):
		bone.set("parentnode",b)
		b.node.add_child(bone.node)		
