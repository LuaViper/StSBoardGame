extends SubViewport
class_name SpineRenderingViewport
#
var src:SpineRenderingControls
var target:Node2D

func _init():
	src = SpineRenderingControls.new()
	src.viewport=self
	#src.sr = SkeletonMeshRenderer.new();
	#src.sr.PremultipliedAlpha = true;
	#
#
func _process(delta):
	if(%SpineRenderingNode):
		%SpineRenderingNode.src=self.src
		

	
	
