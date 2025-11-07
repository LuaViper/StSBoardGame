class_name Monster3D extends Node3D

var GodotSpineTextureLoader = load("res://spine-3402-csharp/homebrew_utils/GodotSpineTextureLoader.cs")
var ZipManager = load("res://spine-3402-csharp/homebrew_utils/ZipManager.cs")
var Atlas = load("res://spine-3402-csharp/src/Atlas.cs")
var SkeletonJson = load("res://spine-3402-csharp/src/SkeletonJson.cs")

var Skeleton = load("res://spine-3402-csharp/src/Skeleton.cs")
var SkeletonData = load("res://spine-3402-csharp/src/SkeletonData.cs")
var AnimationStateData = load("res://spine-3402-csharp/src/AnimationStateData.cs")
var AnimationState = load("res://spine-3402-csharp/src/AnimationState.cs")

static var texture_loader
var atlas
var character2d

#TODO: Writhing Mass requires viewport wider than 512px to fit entire shadow

func _ready():
	character2d=%SpineRenderingViewport.get_node("Character2D")
	self.texture=%SpineRenderingViewport.get_texture()
