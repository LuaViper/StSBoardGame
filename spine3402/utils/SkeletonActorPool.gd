extends Pool
class_name SkeletonActorPool

var renderer: SkeletonRenderer
var skeleton_data: SkeletonData
var state_data: AnimationStateData

var skeleton_pool: Pool
var state_pool: Pool

var obtained: Array

#TODO: make sure 2147483647 really is equivalent to Integer.MAX_VALUE
func _init(renderer: SkeletonRenderer, skeleton_data: SkeletonData, state_data: AnimationStateData, initial_capacity: int = 16, max: int = 2147483647) -> void:
	super._init(initial_capacity,max)
	self.renderer = renderer
	self.skeleton_data = skeleton_data
	self.state_data = state_data
	self.obtained = []
	self.obtained.resize(initial_capacity)
	if(true):
		var lambda1=func new_object()->Skeleton:
			return Skeleton.new(skeleton_data)
		var lambda2=func reset(skeleton:Skeleton):
			skeleton.set_color(Color.WHITE)
			skeleton.set_flip(false,false)
			skeleton.set_skin(null)
			skeleton.set_skin(skeleton_data.get_default_skin())
			skeleton.set_to_setup_pose()
		self.skeletonPool=Pool.new(initial_capacity,max,[lambda1, lambda2])
	if(true):
		var lambda1=func ne2w_object()->AnimationState:
			return AnimationState.new(state_data)
		var lambda2=func r2eset(state:AnimationState):
			state.clear_tracks()
			state.clear_listeners()
		self.state_pool = Pool.new(initial_capacity,max,[lambda1,lambda2])
	
		
# -----------------------------------------------
# free_complete(): Releases any actor whose animation tracks are all null.
# -----------------------------------------------
func free_complete() -> void:
	# Iterate in reverse order.
	for i in range(obtained.size() - 1, -1, -1):
		var actor: SkeletonActor = obtained.get(i)
		# Assume actor.state.get_tracks() returns an Array.
		var tracks: Array = actor.state.get_tracks()
		var can_free: bool = true
		for track in tracks:
			if track != null:
				can_free = false
				break
		if can_free:
			self.free_(actor)

func new_object() -> SkeletonActor:
	var actor: SkeletonActor = SkeletonActor.new()
	actor.set_renderer(renderer)
	return actor


func obtain() -> SkeletonActor:
	var actor: SkeletonActor = super.obtain()
	actor.set_skeleton(skeleton_pool.obtain())
	actor.set_animation_state(state_pool.obtain())
	obtained.append(actor)
	return actor


func reset(actor: SkeletonActor) -> void:
	actor.remove()
	obtained.erase(actor)
	skeleton_pool.free_(actor.get_skeleton())
	state_pool.free_(actor.get_animation_state())


func get_obtained() -> Array:
	return obtained
