class_name AbstractGameAction

var description:String
var children
var show_while_folded:bool = false

func _init(description:String):
	self.description = description

func _to_string()->String:
	return description
	
