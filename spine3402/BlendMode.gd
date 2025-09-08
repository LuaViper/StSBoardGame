class_name BlendMode

# Constants representing blend modes.
const NORMAL = { "source": 770, "source_pma": 1, "dest": 771 }
const ADDITIVE = { "source": 770, "source_pma": 1, "dest": 1 }
const MULTIPLY = { "source": 774, "source_pma": 774, "dest": 771 }
const SCREEN = { "source": 1, "source_pma": 1, "dest": 769 }

# List of blend modes.
var values = [NORMAL, ADDITIVE, MULTIPLY, SCREEN]

# Gets the source blend factor based on whether premultiplied alpha is used.
func get_source(blend_mode, premultiplied_alpha):
	return blend_mode["source_pma"] if premultiplied_alpha else blend_mode["source"]

# Gets the destination blend factor.
func get_dest(blend_mode):
	return blend_mode["dest"]
