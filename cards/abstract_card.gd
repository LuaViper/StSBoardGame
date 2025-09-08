class_name AbstractCard

func hit_color_tags(str:String):
	#TODO: surround with color tags depending on hit amt
	return str

func block_color_tags(str:String):
	#TODO:
	return str

func magic_color_tags(str:String):
	#TODO:
	return str


var block_amt:int : set = set_block_amt, get = get_block_amt
func get_block_amt():
	return block_amt
func set_block_amt(value):
	block_amt=value
	
var dazed_amt:int
