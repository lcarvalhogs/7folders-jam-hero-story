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

	$Managers/StoneGolem/Interactable.set_dialog_container(dialog_container)
	$Managers/StoneGolem/Interactable2.set_dialog_container(dialog_container)
	pass # Replace with function body.

