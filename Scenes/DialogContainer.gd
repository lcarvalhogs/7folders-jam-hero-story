extends Node2D
class_name DialogContainer

var _text_blocks: Array[String]
var _current_block: int

var _previous_character_index: int
var _is_playing_text: bool
var _has_completed: bool
var _character_interval: float
var _play_elapsed_time: float
var _current_selection = 1
var _selected_value = -1

var _has_options: bool = false
var _id: int = 0

func _init():
	visible = false
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	_character_interval = .05
	_reset()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _is_playing_text:
		process_play_text(delta)
	pass

func set_text(text: Array[String], options: bool, id: int):
	_id = id
	_text_blocks = text
	set_options(options)
	_reset()
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
		if !_has_options:
			_has_completed = true
			visible = false
		return

	if next_character >= len(_text_blocks[_current_block]):
		_is_playing_text = false
		if _has_options:
			_display_options()
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

func process_input():
	if _is_playing_text:
		return

	if Input.is_action_just_pressed("move_left"):
		_current_selection = 0
		$Selection_No/Selection.visible = false
		$Selection_Yes/Selection.visible = true
	elif Input.is_action_just_pressed("move_right"):
		_current_selection = 1
		$Selection_No/Selection.visible = true
		$Selection_Yes/Selection.visible = false
	elif Input.is_action_just_pressed("action"):
		_selected_value = _current_selection

func _display_options():
	$Selection_No.visible = true
	$Selection_Yes.visible = true

func _hide_options():
	$Selection_No.visible = false
	$Selection_Yes.visible = false

func _reset():
	_previous_character_index = -1
	_current_block = -1
	_has_completed = false
	_selected_value = -1
	_current_selection = 1

func set_options(value: bool):
	_has_options = value
	if not _has_options:
		_hide_options()

func get_selection():
	return _selected_value

func has_selection():
	return _selected_value >= 0

func get_id():
	return _id
