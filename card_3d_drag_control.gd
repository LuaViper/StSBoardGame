class_name Card3DDragControl
extends Node3D

var dragged=false
var hovered=false

func _ready():
	get_node("%Card3D").set_drag_control(self)

func _process(delta):
	#TODO: if associated card is no longer in hand, remove self from card tray 
	pass
