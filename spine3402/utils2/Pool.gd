class_name Pool

var items = []

func _init():
	items = []

func free_(obj):
	items.clear()	
	obj.reset()
