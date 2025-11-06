### Commented out for now while we test the C# library.

extends Button
#
#
#func _on_pressed() -> void:
	##SkeletonReader.test_load(get_node(".."));	
	#var atlas:SpineTextureAtlas	
	##atlas = SpineTextureAtlas.new("images/monsters/theBottom/cultist/skeleton.atlas")
	#atlas = SpineTextureAtlas.new("images/monsters/theCity/stabBook/skeleton.atlas")	
	##atlas = SpineTextureAtlas.new("images/characters/ironclad/idle/skeleton.atlas")	
	#
	#
	#var json:SkeletonJson
	#json = SkeletonJson.new(atlas)
	##var skeleton_data:SkeletonData = json.read_skeleton_data("images/monsters/theBottom/cultist/skeleton.json")
	#var skeleton_data:SkeletonData = json.read_skeleton_data("images/monsters/theCity/stabBook/skeleton.json")
	##var skeleton_data:SkeletonData = json.read_skeleton_data("images/characters/ironclad/idle/skeleton.json")
	##json.set_scale(Settings.renderScale / scale);
#
	#%SRV.src.skeleton = Skeleton.new(skeleton_data)
	#%SRV.src.skeleton.set_color(Color.WHITE)
	#%SRV.src.state_data = AnimationStateData.new(skeleton_data)
	#%SRV.src.state = AnimationState.new(%SRV.src.state_data)
	#var e:AnimationState.TrackEntry = %SRV.src.state.set_animation(0, "Idle", true)
	##var e:AnimationState.TrackEntry = %SRV.src.state.set_animation(0, "waving", true)
	#e.set_time_scale(0.8)
	#%SRV.src.skeleton.set_flip(false,true) #TODO:
#
#
	#var sprite:Sprite3D = get_node("/root/Main/%SPR3D")
	#%SRV.src.target_sprite = sprite
##
	#var atlas2:SpineTextureAtlas
	#atlas2 = SpineTextureAtlas.new("images/characters/ironclad/idle/skeleton.atlas")
	#var json2:SkeletonJson
	#json2 = SkeletonJson.new(atlas2)
	#var skeleton_data2:SkeletonData = json2.read_skeleton_data("images/characters/ironclad/idle/skeleton.json")	
	#%SRV2.src.skeleton = Skeleton.new(skeleton_data2)
	#%SRV2.src.skeleton.set_color(Color.WHITE)
	#%SRV2.src.state_data = AnimationStateData.new(skeleton_data2)
	#%SRV2.src.state = AnimationState.new(%SRV2.src.state_data)
	#var e2:AnimationState.TrackEntry = %SRV2.src.state.set_animation(0, "Idle", true)
	#e2.set_time_scale(0.6)
	#%SRV2.src.skeleton.set_flip(false,true) #TODO:
#
	#var sprite2:Sprite3D = get_node("/root/Main/%SPR3D2")
	#%SRV2.src.target_sprite = sprite2
