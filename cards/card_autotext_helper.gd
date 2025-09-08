#global CardAutotextHelper
extends Node

var all_tags=[""]

func parse(text:String)->String:
	print("Initial text: ",text)
	var result=""
	var regex = RegEx.new()
	regex.compile("\\[(.*?)\\]")
	var previous_end = 0
	for m in regex.search_all(text):
		var start = m.get_start()
		var end = m.get_end()
		var tag = m.get_string(1)
		result += text.substr(previous_end, start - previous_end)
		if(tag=="H"):
			result += CardTagH.new().autotext()			
		print("Start/end: ",start," ",end)
		print("Result: ",result)
		previous_end=end

		
	result += text.substr(previous_end)
	
	return result
