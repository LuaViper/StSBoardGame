class_name NumberUtils

static func _int_to_float_color(value: int) -> float:
	#value = value & -16777217
	var pba:PackedByteArray=PackedByteArray()
	pba.resize(32)
	#TODO: verify this & operation is working correctly
	#-16777217 = 11111110111111111111111111111111
	var value2=value & -16777217
	pba.encode_s32(0,value2)		
	#print("_int_to_float_color: ",value & -16777217," became ",pba.decode_float(0))	
	return pba.decode_float(0)

static func float_to_color(value: float) -> Color:
	var ints = float_to_int_bits(value)
	#TODO: colors might actually be stored as ABGR
	var a = (ints >> 24) & 0xFF
	var b = (ints >> 16) & 0xFF
	var g = (ints >> 8) & 0xFF
	var r = ints & 0xFF
	return Color(r/255.0,g/255.0,b/255.0,a/255.0)

	
static func float_to_int_bits(value: float) -> int:
	var byte_array = PackedByteArray()
	byte_array.resize(4)
	byte_array.encode_float(0,value)
	return byte_array.decode_s32(0)
