extends Node2D

var ZipManager = load("res://spine-3402-csharp/homebrew_utils/ZipManager.cs")
var SkeletonMeshRenderer = load("res://spine-3402-csharp/src/SkeletonMeshRenderer.cs")
var Atlas = load("res://spine-3402-csharp/src/Atlas.cs")
var SkeletonJson = load("res://spine-3402-csharp/src/SkeletonJson.cs")
var SkeletonData = load("res://spine-3402-csharp/src/SkeletonData.cs")
var Skeleton = load("res://spine-3402-csharp/src/Skeleton.cs")
var AnimationStateData = load("res://spine-3402-csharp/src/AnimationStateData.cs")
var AnimationState = load("res://spine-3402-csharp/src/AnimationState.cs")

var renderer
var render_target
var atlas
var skeleton
var animation_state_data
var animation_state

#TODO: looks like skeletons are casting shadows but not receiving them?

func _ready():
	renderer=SkeletonMeshRenderer.new()
	# change render_target if you have two or more skeletons drawing to the same character (e.g. Watcher)
	render_target = self

func load_character(atlas_filepath:String,skeleton_filepath:String,y_offset:float,inverse_scale:float=1.0):
	ZipManager.SetZipPath(Globals.install_location)

	atlas = [Atlas.new(atlas_filepath)]
	
	var json = SkeletonJson.new(atlas)
	json.Scale=1/inverse_scale
	var skeleton_data = json.ReadSkeletonData(skeleton_filepath)	
	
	skeleton = Skeleton.new(skeleton_data)	
	skeleton.SetColor(Color.WHITE)
	animation_state_data = AnimationStateData.new(skeleton_data)
	animation_state = AnimationState.new(animation_state_data)
	@warning_ignore("integer_division")
	skeleton.SetPosition(512/2,512-(100+y_offset))
	#skeleton.SetPosition(512/2,512-90)
	#TODO: color should probably go somewhere else
	skeleton.SetGodotFlip(false,false)
	skeleton.SetColor(Color.WHITE)


func load_animation(anim:String,random_time:bool=true,timescale:float=1.0,loop:bool=true):
	var e = animation_state.SetAnimation(0, anim, loop)
	e.TimeScale = timescale
	if(random_time):
		e.Time = e.EndTime * randf()

func set_mix(anim1:String,anim2:String,duration:float):
	self.animation_state_data.SetMix(anim1,anim2,duration)
	
	

func _process(delta):
	if(!animation_state_data || !skeleton): 
		return
	animation_state.Update(delta)
	animation_state.Apply(skeleton)
	skeleton.UpdateWorldTransform()
	queue_redraw()

func _draw():
	if(!animation_state_data || !skeleton):
		return
	renderer.DrawSkeletonToCanvas(skeleton,render_target)

func debug_draw_callback(array_mesh,primary_texture,colors):
	#breakpoint here so we can check vars
	var x
	x=0
	#draw_mesh(array_mesh,primary_texture);
