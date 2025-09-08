class_name SpineRenderingControls

var state:AnimationState
var state_data:AnimationStateData
var skeleton:Skeleton
var sr:SkeletonMeshRenderer
var viewport:SpineRenderingViewport
var render_target:Node2D
var target_sprite:Sprite3D

func init():
	sr = SkeletonMeshRenderer.new();
	sr.set_premultiplied_alpha(true);
