extends Node

var thread: Thread

#TODO: apparently GOG has a different patch/checksum than Steam!
var file
var file_is_ok:bool=false

func load(path:String) -> void:
	file=null
	file_is_ok=false
	print("Checking hash...")
	thread = Thread.new()
	# You can bind multiple arguments to a function Callable.
	thread.start(_thread_function.bind(path))



# Run here and exit.
# The argument is the bound data passed from start().
func _thread_function(path):

	const TARGET_SHA256_HASH:String = "cfad868ac8d65a88e71a0bf096fb09f78811e553effe0787c5309a655e081673"
	const CHUNK_SIZE = 1024

	if not FileAccess.file_exists(path):
		print("File does not exist: ",path)
		return
	# Start an SHA-256 context.
	var ctx = HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	# Open the file to hash.
	file = FileAccess.open(path, FileAccess.READ)
	# Update the context after reading each chunk.
	while file.get_position() < file.get_length():
		var remaining = file.get_length() - file.get_position()
		ctx.update(file.get_buffer(min(remaining, CHUNK_SIZE)))
	# Get the computed hash.
	var res = ctx.finish()
	if(res.hex_encode()==TARGET_SHA256_HASH):
		file_is_ok=true
		print("SHA256 hash OK!")


# Thread must be disposed (or "joined"), for portability.
func _exit_tree():
	if(thread):
		thread.wait_to_finish()
