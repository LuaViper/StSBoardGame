class_name CardGlowBorder

var color:Color
var duration=1.2
var scale=0
var is_done=false
const OFFSET = Vector2(0,-1)
const SCALE_MODIFIER = 0.71

func _init(gColor=Color("30c8dcff")):
	self.color=Color(gColor)
	#TODO: if room is not set to combat phase, color is instead set to GREEN

func pow2_ease_out(start, end, a):
	var pow_ = 2	
	var ease_ = pow(a-1.0,pow_) * -1 + 1.0
	return start + (end-start) * ease_

func update(delta):
	#TO DO LATER: effect seems to be thinner than vanilla StS -- could be an indication of missized texture
	#TO DO LATER: edge of card is jagged -- probably transparency issue
		# user setting to either keep jagged edges or remove transparency from glow
		#  maybe use brightness instead of alpha
	
	scale = 1 + pow2_ease_out(.03,.11,1-duration)
	scale *= SCALE_MODIFIER
	color.a = duration / 2.0
	
	duration -= delta
	if(duration<0):
		is_done=true
		
#TO DO LATER: we are currently rendering in transparent_effects.gd -- should we move that here?
