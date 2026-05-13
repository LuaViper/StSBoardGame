
#NOTE: this is currently an abandoned backup file. unblocked mouse input is NYI
#	(unblocked mouse input may or may not resolve itself after Action2DSingle is revised)

class_name Action2DBlockUnanimated extends ColorRect

const NORMAL_COLOR = Color(0.8,0.0,0.0)
const HIGHLIGHT_COLOR = NORMAL_COLOR + Color(0.2,0.2,0.2)


var action = null
var open:bool = false

var saved_owner

const OWN_CLASS = preload("res://actions/ui/action_2d_block_unanimated.tscn")
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
	if(true): return #!!!
	if(!open):
		%AccordionIcon.rotation=max(0,%AccordionIcon.rotation-delta*10)
	else:
		%AccordionIcon.rotation=min(PI,%AccordionIcon.rotation+delta*10)
	

func _on_mouse_entered() -> void:
	set_panel_color(HIGHLIGHT_COLOR)
	pass # Replace with function body.


func _on_mouse_exited() -> void:
	set_panel_color(NORMAL_COLOR)
	pass # Replace with function body.


func _on_gui_input(event: InputEvent) -> void:
	if(event.is_action_pressed("left_mouse_button")):
		open = !open
	pass # Replace with function body.


func _on_panel_container_resized() -> void:
	if(saved_owner):
		#print("Saved owner: ",saved_owner," size: ",%InvisiblePanelContainer.size.y)
		saved_owner.custom_minimum_size.y=%PanelContainer.size.y
		saved_owner.size.y=%PanelContainer.size.y
