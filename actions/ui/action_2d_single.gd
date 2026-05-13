
# margin between Icon and ScrollContainer is determined by HBoxContainer's Separation property,
	# currently 6

#TODO: hook up Icon to mouse signals so user can click to view rulings

class_name Action2DSingle extends AbstractGameAction2D

static func create_node(action):
	assert(action,"Action2DSingle's action is null")
	var node = preload("res://actions/ui/action_2d_single.tscn").instantiate()
	node.action=action
	return node

func _ready()->void:
	%Description.set_text(action.to_string())#action._to_string()
	#print("...: ",self.to_string())
	pass
