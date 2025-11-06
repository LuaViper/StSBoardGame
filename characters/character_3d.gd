class_name Monster3D extends Node3D

var GodotSpineTextureLoader = load("res://spine-3402-csharp/homebrew_utils/GodotSpineTextureLoader.cs")
var ZipManager = load("res://spine-3402-csharp/homebrew_utils/ZipManager.cs")
var Atlas = load("res://spine-3402-csharp/src/Atlas.cs")
var SkeletonJson = load("res://spine-3402-csharp/src/SkeletonJson.cs")

var NewScript = load("res://spine-3402-csharp/homebrew_utils/NewScript.cs")

var Skeleton = load("res://spine-3402-csharp/src/Skeleton.cs")
var SkeletonData = load("res://spine-3402-csharp/src/SkeletonData.cs")
var AnimationStateData = load("res://spine-3402-csharp/src/AnimationStateData.cs")
var AnimationState = load("res://spine-3402-csharp/src/AnimationState.cs")

static var texture_loader
var atlas

#func _ready():
#	texture_loader = GodotSpineTextureLoader.new()

func load(atlas_file:String,skeleton_file:String,anim:String,timescale:float):
	#TODO: this atlas might be intended to be a static variable? check StS java implementation
	var install_location = "C:/Program Files (x86)/Steam/steamapps/common/SlayTheSpire/desktop-1.0.jar"
	ZipManager.SetZipPath(install_location)

	self.atlas = Atlas.new(atlas_file)
	var json = SkeletonJson.new([atlas])
	#json.SetScale(2/3.0) #use this to compare calculations vs windowed-mode StS	
	
	#note: when calling a C# function with a return type, the return type must extend GodotObject to avoid function-not-found errors
	var skeleton_data = json.ReadSkeletonData(skeleton_file)

	var skeleton = Skeleton.new(skeleton_data)
	%SpineRenderingViewport.src.skeleton = skeleton
	%SpineRenderingViewport.src.skeleton.SetColor(Color.WHITE)
	%SpineRenderingViewport.src.state_data = AnimationStateData.new(skeleton_data)
	%SpineRenderingViewport.src.state = AnimationState.new(%SpineRenderingViewport.src.state_data)
	var e = %SpineRenderingViewport.src.state.SetAnimation(0, anim, true)
	e.TimeScale = timescale
	%SpineRenderingViewport.src.skeleton.SetFlip(false,true) #TODO:

	%SpineRenderingViewport.src.target_sprite = %Sprite3D
#



#TODO: set_time function
	





#class_name Monster3D extends Node3D
#
#func load(atlas_file:String,skeleton_file:String,anim:String,timescale:float):
	##SkeletonReader.test_load(get_node(".."));	
	#var atlas:SpineTextureAtlas	
	##atlas = SpineTextureAtlas.new("images/monsters/theBottom/cultist/skeleton.atlas")
	##atlas = SpineTextureAtlas.new("images/monsters/theCity/stabBook/skeleton.atlas")	
	##atlas = SpineTextureAtlas.new("images/characters/ironclad/idle/skeleton.atlas")	
	#atlas = SpineTextureAtlas.new(atlas_file)
	#
	#
	#var json:SkeletonJson
	#json = SkeletonJson.new(atlas)
	##var skeleton_data:SkeletonData = json.read_skeleton_data("images/monsters/theBottom/cultist/skeleton.json")
	##var skeleton_data:SkeletonData = json.read_skeleton_data("images/monsters/theCity/stabBook/skeleton.json")
	##var skeleton_data:SkeletonData = json.read_skeleton_data("images/characters/ironclad/idle/skeleton.json")
	#json.set_scale(2/3.0) #use this to compare calculations vs windowed-mode StS
	#var skeleton_data:SkeletonData = json.read_skeleton_data(skeleton_file)
	#
	##json.set_scale(Settings.renderScale / scale);
#
	#var skeleton = Skeleton.new(skeleton_data)
	#%SpineRenderingViewport.src.skeleton = skeleton
	#%SpineRenderingViewport.src.skeleton.set_color(Color.WHITE)
	#%SpineRenderingViewport.src.state_data = AnimationStateData.new(skeleton_data)
	#%SpineRenderingViewport.src.state = AnimationState.new(%SpineRenderingViewport.src.state_data)
	##var e:AnimationState.TrackEntry = %SpineRenderingViewer.src.state.set_animation(0, "Idle", true)
	##var e:AnimationState.TrackEntry = %SpineRenderingViewer.src.state.set_animation(0, "waving", true)
	#var e:AnimationState.TrackEntry = %SpineRenderingViewport.src.state.set_animation(0, anim, true)
	#e.set_time_scale(timescale)
	#%SpineRenderingViewport.src.skeleton.set_flip(false,true) #TODO:
#
	##var sprite:Sprite3D = %Sprite3D
	#%SpineRenderingViewport.src.target_sprite = %Sprite3D
##
#
#
#
##TODO: set_time function
	#
#
#
