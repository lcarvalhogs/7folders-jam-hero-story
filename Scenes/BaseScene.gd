extends Node
class_name BaseScene

@export var text_blocks: Array[String]

var dialog_container: DialogContainer
var game_data: GameData

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Base scene ready")
	dialog_container = $DialogContainer
	dialog_container.set_text(text_blocks, false, 1)
	dialog_container.play_next()

	$Managers/StoneGolem/Interactable.set_dialog_container(dialog_container)
	$Managers/StoneGolem/Interactable2.set_dialog_container(dialog_container)

	$Managers/Crystal/Interactable.set_dialog_container(dialog_container)
	pass # Replace with function body.

func set_game_data(data: GameData):
	game_data = data

# We only disable the message box complete sound
func play_sound(sfx: AudioStream):
	$AudioStreamPlayer2D.stream = sfx
	$AudioStreamPlayer2D.play()
