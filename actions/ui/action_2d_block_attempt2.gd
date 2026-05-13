
# PanelContainer's StyleBoxTexture's Content Margins must be 0 (instead of -1) so Texture Margins don't control content
# a Control (named %ClipControl) is necessary to hide content as panel expands (ScrollContainer doesn't work intuitively (or at all))

#TODO: AccordionArrow's anchor is a bit awkward. can we move it into HeaderContainer?
#		(this will require a HBoxContainer inside HeaderContainer which contains HeaderPlaceholder followed by a non-filling AccordionArrow)

class_name Action2DBlockAttempt2 extends ColorRect

const NORMAL_COLOR = Color(0.8,0.0,0.0)
const HIGHLIGHT_COLOR = NORMAL_COLOR + Color(0.2,0.2,0.2)

var UNFOLD_SPEED = 256
var FOLD_SPEED = 256

var controlled_scroll_size = 40

var action = null
var open:bool = false

var saved_owner

const OWN_CLASS = preload("res://actions/ui/action_2d_block.tscn")
static func create_node(action):
	assert(action,"Action2DBlock's action is null")
	var node = OWN_CLASS.instantiate()
	node.action=action
	return node

func set_panel_color(color:Color)->void:
	var new_style = %PanelContainer.get_theme_stylebox("panel").duplicate()	
	new_style.modulate_color=color
	%PanelContainer.add_theme_stylebox_override("panel",new_style)


func _ready()->void:
	saved_owner=self	
	set_panel_color(NORMAL_COLOR)
	var single = Action2DSingle.create_node(action)
	# Programmer rant: i thought "add_child_below_node" was much easier to follow than "add_sibling"
	%HeaderPlaceholder.add_sibling(single)
	if(action.children):		
		for child_action in action.children:
			var node = AbstractGameAction2D.create_node(child_action)
			%ChildrenContainer.add_child(node)		


func _process(delta: float) -> void:
	controlled_scroll_size = %PanelContainer.size.y
	if(%ClipControl.size.y<controlled_scroll_size):
		%ClipControl.size.y+=delta*UNFOLD_SPEED
		if(%ClipControl.size.y>controlled_scroll_size):
			%ClipControl.size.y=controlled_scroll_size
	elif(%ClipControl.size.y>controlled_scroll_size):
		%ClipControl.size.y-=delta*FOLD_SPEED
		if(%ClipControl.size.y<controlled_scroll_size):
			%ClipControl.size.y=controlled_scroll_size
	#%ScrollContainer.size.y=controlled_scroll_size

	if(!open):
		%AccordionArrow.rotation=max(0,%AccordionArrow.rotation-delta*10)
	else:
		%AccordionArrow.rotation=min(PI,%AccordionArrow.rotation+delta*10)
	







func _on_clip_control_resized() -> void:
	if(saved_owner):
		#print("Saved owner: ",saved_owner," size: ",%ClipControl.size.y)		
		saved_owner.custom_minimum_size.y=%ClipControl.size.y
		saved_owner.size.y=%ClipControl.size.y
	pass


func _on_mouse_entered() -> void:
	set_panel_color(HIGHLIGHT_COLOR)



func _on_mouse_exited() -> void:
	set_panel_color(NORMAL_COLOR)


func _on_gui_input(event: InputEvent) -> void:
	if(event.is_action_pressed("left_mouse_button")):
		open = !open
		#TODO: still not correct --
		# panelcontainer needs to resize smoothly, not just clipcontrol
		# we may very well have to start over and do it manually
		if(open):
			%ChildrenContainer.hide()
		else:
			%ChildrenContainer.show()
