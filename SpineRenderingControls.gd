class_name SpineRenderingControls

var state
var state_data
var skeleton
var sr
var viewport:SpineRenderingViewport
var render_target:Node2D
var target_sprite:Sprite3D

var SkeletonMeshRenderer = load("res://spine-3402-csharp/src/SkeletonMeshRenderer.cs")

func _init():
	print("SpineRenderingControls.init")
	sr = SkeletonMeshRenderer.new();
	print("Skeleton Mesh Renderer: ",sr)
	sr.PremultipliedAlpha = true;
