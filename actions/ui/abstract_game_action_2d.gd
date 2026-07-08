class_name AbstractGameAction2D extends Control

var action:AbstractGameAction
var folded:bool = false
#var TEMP_BLOCK=false
#var saved_owner
#var action_node

const OWN_CLASS = preload("res://actions/ui/abstract_game_action_2d.tscn")
static func create_node(action):
	assert(action,"AbstractAction2D's action is null")	
	if(!action):
		action=AbstractGameAction.new("placeholder")
	var node
	if(action.children==null):	#this evaluates differently from if(action.children)
		node = Action2DSingle.create_node(action)
	else:
		node = Action2DBlock.create_node(action)
	return node


func fold():
	pass
func unfold():
	pass
func on_parent_fold():
	if(!action.show_while_folded):
		hide()
func on_parent_unfold():
	show()

func toggle_folded_status():	
	folded = !folded
	if(folded):	fold()
	else: unfold()
	return folded


#const ASBTRACTGAMEACTION_CLASS = preload("res://actions/abstract_game_action.gd")

#func _ready():
	#saved_owner = self
	#if(!action):
		#action=AbstractGameAction.new("placeholder")
	#if(action.children==null):	#this evaluates differently from if(action.children)
		#action_node = Action2DSingle.create_node(action)
	#else:
		#action_node = Action2DBlock.create_node(action)
	#%PanelContainer.add_child(action_node)
	
#func _on_panel_container_resized() -> void:
	#if(saved_owner):
		##print("Saved owner: ",saved_owner," size: ",%PanelContainer.size.y)
		#saved_owner.custom_minimum_size.y=%PanelContainer.size.y
		#saved_owner.size.y=%PanelContainer.size.y	
