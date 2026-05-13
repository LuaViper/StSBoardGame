class_name Action2DBlock extends AbstractGameAction2D

const NORMAL_COLOR = Color(0.8,0.0,0.0)
const HIGHLIGHT_COLOR = NORMAL_COLOR + Color(0.2,0.2,0.2)

#TODO: automatically calculate margins from panelcontainer's margins during setup
const MARGINS = 8

#TODO: consider dynamic fold/unfold speed based on container size
#TODO: consider acceleration for fold/unfold animation
var UNFOLD_SPEED = 320
var FOLD_SPEED = 320

var controlled_scroll_size = 40

var saved_owner

static func create_node(action):
	assert(action,"Action2DBlock's action is null")
	var node = preload("res://actions/ui/action_2d_block.tscn").instantiate()
	node.action=action
	return node

func set_panel_color(color:Color)->void:	
	%NinePatchRect.modulate=color	

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
	controlled_scroll_size = %MarginContainer.size.y
	if(%ClipControl.size.y<controlled_scroll_size):
		%ClipControl.size.y+=delta*UNFOLD_SPEED
		if(%ClipControl.size.y>controlled_scroll_size):
			%ClipControl.size.y=controlled_scroll_size
	elif(%ClipControl.size.y>controlled_scroll_size):
		%ClipControl.size.y-=delta*FOLD_SPEED
		if(%ClipControl.size.y<controlled_scroll_size):
			%ClipControl.size.y=controlled_scroll_size

	if(!folded):
		%AccordionArrow.rotation=min(PI,%AccordionArrow.rotation+delta*10)			
	else:
		%AccordionArrow.rotation=max(0,%AccordionArrow.rotation-delta*10)		
	if(action.children.is_empty() && %AccordionArrow.visible):
		%AccordionArrow.hide()
	elif(!action.children.is_empty() && !%AccordionArrow.visible):
		%AccordionArrow.show()
		


func fold():
	#don't call super.fold() -- blocks always remain visible
	for child in %ChildrenContainer.get_children():
		child.on_parent_fold()
	
func unfold():
	super.unfold()
	for child in %ChildrenContainer.get_children():
		child.on_parent_unfold()
		
func on_parent_fold():
	# (action blocks don't hide when parent is folded)
	pass

func on_parent_unfold():
	# (override parent function)
	pass	
	
			
func _on_clip_control_resized() -> void:
	if(saved_owner):
		saved_owner.custom_minimum_size.y=%ClipControl.size.y
		saved_owner.size.y=%ClipControl.size.y
	pass


func _on_clip_control_mouse_entered() -> void:
	set_panel_color(HIGHLIGHT_COLOR)


func _on_clip_control_mouse_exited() -> void:
	set_panel_color(NORMAL_COLOR)
	

func _on_clip_control_gui_input(event: InputEvent) -> void:
	if(event.is_action_pressed("left_mouse_button")):
		toggle_folded_status()
		#TODO: still not correct --
		# panelcontainer needs to resize smoothly, not just clipcontrol
		# we may very well have to start over and do it manually
		if(folded):
			%ChildrenContainer.hide()
		else:
			%ChildrenContainer.show()	
