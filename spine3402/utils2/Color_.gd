class_name Color_

static func value_of(hex:String)->Color:
	hex = hex.substr(1) if hex[0] == "#" else hex
	#note: Copilot suggested int(string, radix) but Godot says no
	var r = convert_hex(hex.substr(0, 2))
	var g = convert_hex(hex.substr(2, 4))
	var b = convert_hex(hex.substr(4, 6))
	var a = 255 if hex.length() != 8 else convert_hex(hex.substr(6, 8))
	return Color(r / 255.0, g / 255.0, b / 255.0, a / 255.0)

static func convert_hex(hex: String) -> int:
	var result = 0
	var hex_chars = "0123456789ABCDEF"
	hex = hex.to_upper() # Ensure consistency
	for i in range(hex.length()):
		var digit = hex_chars.find(hex[i]) # Get the numerical value
		if digit == -1:
			push_error("Invalid hex character: " + hex[i])
			return 0
		result = result * 16 + digit	
	return result
