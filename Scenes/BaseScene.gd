extends Node
class_name BaseScene

@export var text_blocks: Array[String]

var dialog_container: DialogContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Base scene ready")
	dialog_container = $DialogContainer
	dialog_container.set_text(text_blocks)
	dialog_container.play_next()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
