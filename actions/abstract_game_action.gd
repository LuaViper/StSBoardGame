class_name AbstractGameAction

#TODO: children is deprecated but action2D still relies on it.
#	rewrite to children() function
var children

var description:String
var show_while_folded:bool = false

var parent_action
var sub_actions
var triggered_actions
var cleanup_actions

var decisions

var _is_done:bool=false

func _init(description:String=""):
	self.description = description

func _to_string()->String:
	return description
	
func is_done()->bool:
	return _is_done

func is_all_done()->bool:
	return is_done() && are_subactions_done(sub_actions) && are_subactions_done(triggered_actions) && are_subactions_done(cleanup_actions)
	
func are_subactions_done(list)->bool:
	if(!list): return true
	for action in list:
		if(!action.is_done()):
			return false
	return true

func do():
	pass
