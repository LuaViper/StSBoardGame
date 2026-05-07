extends NinePatchRect

const NORMAL_COLOR = Color(0.8,0.0,0.0)
const HIGHLIGHT_COLOR = NORMAL_COLOR + Color(0.2,0.2,0.2)

var open:bool = false

func _ready()->void:
	self_modulate = NORMAL_COLOR

func _process(delta: float) -> void:
	if(!open):
		%AccordionTextureRect.rotation=max(0,%AccordionTextureRect.rotation-delta*10)
	else:
		%AccordionTextureRect.rotation=min(PI,%AccordionTextureRect.rotation+delta*10)
	

func _on_mouse_entered() -> void:
	self_modulate = HIGHLIGHT_COLOR
	pass # Replace with function body.


func _on_mouse_exited() -> void:
	self_modulate = NORMAL_COLOR
	pass # Replace with function body.


func _on_gui_input(event: InputEvent) -> void:
	if(event.is_action_pressed("left_mouse_button")):
		open = !open
	pass # Replace with function body.
