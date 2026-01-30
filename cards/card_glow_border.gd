class_name CardGlowBorder

var color:Color
var duration=1.2
var scale=0
var is_done=false
const OFFSET = Vector2(0,-1)
const SCALE_MODIFIER = 0.75

func _init(gColor=Color("30c8dcff")):
	self.color=Color(gColor)

func pow2_ease_out(start, end, a):
	var pow_ = 2	
	var ease_ = pow(a-1.0,pow_) * -1 + 1.0
	return start + (end-start) * ease_

func update(delta):
	#TODO NEXT: effect seems to be thinner than vanilla StS
	#TODO NEXT: edge of card is jagged -- probably transparency issue
	
	scale = 1 + pow2_ease_out(.03,.11,1-duration)
	scale *= SCALE_MODIFIER
	color.a = duration / 2.0
	#TODO: accessibility setting to use brightness instead of alpha (fixes some distracting visual issues)	
	duration -= delta
	if(duration<0):
		is_done=true
