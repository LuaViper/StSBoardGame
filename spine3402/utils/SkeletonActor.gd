extends Actor
class_name SkeletonActor

var renderer: SkeletonRenderer
var skeleton: Skeleton
var state: AnimationState

func _init(renderer: SkeletonRenderer = null, skeleton: Skeleton = null, state: AnimationState = null):
	self.renderer = renderer
	self.skeleton = skeleton
	self.state = state

func act(delta: float) -> void:
	state.update(delta)
	state.apply(skeleton)
	skeleton.update_world_transform()
	#####super.act(delta)

func draw(batch: Batch, parent_alpha: float) -> void:
	var color: Color = skeleton.get_color()
	var old_alpha: float = color.a
	skeleton.get_color().a *= parent_alpha
	#####skeleton.set_position(get_x(), get_y())
	renderer.draw(batch, skeleton)
	color.a = old_alpha

func get_renderer() -> SkeletonRenderer:
	return renderer

func set_renderer(renderer: SkeletonRenderer) -> void:
	self.renderer = renderer

func get_skeleton() -> Skeleton:
	return skeleton

func set_skeleton(skeleton: Skeleton) -> void:
	self.skeleton = skeleton

func get_animation_state() -> AnimationState:
	return state

func set_animation_state(state: AnimationState) -> void:
	self.state = state
