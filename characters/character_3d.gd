class_name Monster3D extends Node3D

func load(atlas_file:String,skeleton_file:String,anim:String,timescale:float):
	#SkeletonReader.test_load(get_node(".."));	
	var atlas:SpineTextureAtlas	
	#atlas = SpineTextureAtlas.new("images/monsters/theBottom/cultist/skeleton.atlas")
	#atlas = SpineTextureAtlas.new("images/monsters/theCity/stabBook/skeleton.atlas")	
	#atlas = SpineTextureAtlas.new("images/characters/ironclad/idle/skeleton.atlas")	
	atlas = SpineTextureAtlas.new(atlas_file)
	
	
	var json:SkeletonJson
	json = SkeletonJson.new(atlas)
	#var skeleton_data:SkeletonData = json.read_skeleton_data("images/monsters/theBottom/cultist/skeleton.json")
	#var skeleton_data:SkeletonData = json.read_skeleton_data("images/monsters/theCity/stabBook/skeleton.json")
	#var skeleton_data:SkeletonData = json.read_skeleton_data("images/characters/ironclad/idle/skeleton.json")
	json.set_scale(2/3.0) #use this to compare calculations vs windowed-mode StS
	var skeleton_data:SkeletonData = json.read_skeleton_data(skeleton_file)
	
	#json.set_scale(Settings.renderScale / scale);

	var skeleton = Skeleton.new(skeleton_data)
	%SpineRenderingViewport.src.skeleton = skeleton
	%SpineRenderingViewport.src.skeleton.set_color(Color.WHITE)
	%SpineRenderingViewport.src.state_data = AnimationStateData.new(skeleton_data)
	%SpineRenderingViewport.src.state = AnimationState.new(%SpineRenderingViewport.src.state_data)
	#var e:AnimationState.TrackEntry = %SpineRenderingViewer.src.state.set_animation(0, "Idle", true)
	#var e:AnimationState.TrackEntry = %SpineRenderingViewer.src.state.set_animation(0, "waving", true)
	var e:AnimationState.TrackEntry = %SpineRenderingViewport.src.state.set_animation(0, anim, true)
	e.set_time_scale(timescale)
	%SpineRenderingViewport.src.skeleton.set_flip(false,true) #TODO:

	#var sprite:Sprite3D = %Sprite3D
	%SpineRenderingViewport.src.target_sprite = %Sprite3D
#



#TODO: set_time function
	
