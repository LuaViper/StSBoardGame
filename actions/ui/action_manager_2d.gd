
# SAVE A BACKUP BEFORE EDITING ANYTHING; PROCEDURALLY-INSTANCED GODOT CONTROLS ARE OBNOXIOUS



extends Panel

const ABSTRACTGAMEACTION_CLASS=preload("res://actions/abstract_game_action.gd")

func _ready()->void:
	var node
	var groupaction
	for i in 3:
		node = AbstractGameAction2D.create_node(ABSTRACTGAMEACTION_CLASS.new("PLACEHOLDER"))
		%VBoxContainer.add_child(node)
		
	var nestedgroup
	nestedgroup = ABSTRACTGAMEACTION_CLASS.new("NESTED PLACEHOLDER")
	nestedgroup.children = [ABSTRACTGAMEACTION_CLASS.new("NESTED CHILD 1"),ABSTRACTGAMEACTION_CLASS.new("NESTED CHILD 2")]
		
	groupaction = ABSTRACTGAMEACTION_CLASS.new("GROUP PLACEHOLDER")
	groupaction.children = [ABSTRACTGAMEACTION_CLASS.new("CHILD 1"),ABSTRACTGAMEACTION_CLASS.new("CHILD 2")]
	node = AbstractGameAction2D.create_node(groupaction)		
	%VBoxContainer.add_child(node)

	for i in 2:
		node = AbstractGameAction2D.create_node(ABSTRACTGAMEACTION_CLASS.new("PLACEHOLDER"))
		%VBoxContainer.add_child(node)

	groupaction = ABSTRACTGAMEACTION_CLASS.new("GROUP PLACEHOLDER")
	groupaction.children = [ABSTRACTGAMEACTION_CLASS.new("CHILD 1"),nestedgroup,ABSTRACTGAMEACTION_CLASS.new("CHILD 3")]
	node = AbstractGameAction2D.create_node(groupaction)		
	%VBoxContainer.add_child(node)

	for i in 2:
		node = AbstractGameAction2D.create_node(ABSTRACTGAMEACTION_CLASS.new("PLACEHOLDER"))
		%VBoxContainer.add_child(node)


		
	#groupaction = ABSTRACTGAMEACTION_CLASS.new("GROUP PLACEHOLDER")
	#groupaction.children = []
	#node = AbstractGameAction2D.create_node(groupaction)		
	#%VBoxContainer.add_child(node)
	#for i in 3:
		#node = AbstractGameAction2D.create_node(ABSTRACTGAMEACTION_CLASS.new("PLACEHOLDER"))
		#%VBoxContainer.add_child(node)		
	
	return
	#var action = AbstractAction2D.create_node(AbstractGameAction.new("AbstractGameAction placeholder"))
	#%VBoxContainer.add_child(action)
