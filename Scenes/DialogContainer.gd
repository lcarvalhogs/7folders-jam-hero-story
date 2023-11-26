extends Node2D
class_name DialogContainer

var _text_blocks: Array[String]
var _current_block: int

var _previous_character_index: int
var _is_playing_text: bool
var _has_completed: bool
var _character_interval: float
var _play_elapsed_time: float

func _init():
	visible = false
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	_character_interval = .05
	_previous_character_index = -1
	_current_block = -1
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _is_playing_text:
		process_play_text(delta)
	pass

func set_text(text: Array[String]):
	_text_blocks = text
	_has_completed = false
	pass

func play_next():
	_current_block += 1
	_is_playing_text = true
	_previous_character_index = -1
	_play_elapsed_time = 0
	$Label.text = ""

func process_play_text(delta: float):
	visible = true
	var next_character = int(_play_elapsed_time/_character_interval)
	if _current_block >= len(_text_blocks):
		_is_playing_text = false
		visible = false
		_has_completed = true
		return

	if next_character >= len(_text_blocks[_current_block]):
		_is_playing_text = false
		return

	if _previous_character_index != next_character:
		while(_previous_character_index < next_character):
			$Label.text += _text_blocks[_current_block][_previous_character_index + 1]
			_previous_character_index += 1

	_previous_character_index = next_character
	_play_elapsed_time += delta

func is_playing():
	return _is_playing_text

func has_completed():
	return _has_completed
