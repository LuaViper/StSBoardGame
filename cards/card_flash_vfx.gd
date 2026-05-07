class_name CardFlashVfx

var color:Color
var duration=0.5
var scale=0
var y_scale=0
var is_done=false
var is_super=false
const OFFSET = Vector2(0,-1)
const SCALE_MODIFIER = 1.333

func _init(gColor=Color(1.0,0.8,0.2,1.2),is_super_=false):
	self.color=Color(gColor)
	self.is_super=is_super_
	
func bounce_in_4(start, end, a):
	const _BOUNCES = 4
	var ease_ = 1.0 - bounce_out_4(1.0-a)
	return start + (end-start) * ease_

func bounce_out_4(a):
	if(a==1.0): return 1.0
	const _BOUNCES=4
	const WIDTHS = [0.34*2,0.34,0.2,0.15]
	const HEIGHTS = [1.0,0.26,0.11,0.03]
	a+=WIDTHS[0]/2.0
	var width=0.0
	var height=0.0
	for i in range(WIDTHS.size()):
		width=WIDTHS[i]
		if(a<=width):
			height=HEIGHTS[i]
			break
		a-=width
	a/=width
	var z = 4.0/width*height*a
	return 1.0 - (z - z*a) * width
	
	

func update(delta):
	#TO DO LATER: edge of card is jagged -- probably transparency issue
		# user setting to either keep jagged edges or remove transparency from glow
		#  maybe use brightness instead of alpha
	scale = bounce_in_4(1.2,1.1,duration*2.0)
	scale *= SCALE_MODIFIER
	color.a = duration
	
	duration -= delta
	#print("!: ",duration)
	if(duration<0):
		is_done=true

#TO DO LATER: we are currently rendering in transparent_effects.gd -- should we move that here?
