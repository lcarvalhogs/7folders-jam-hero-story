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
var _sfx_disabled: bool = false

var _has_options: bool = false
var _id: int = 0
var _is_treasure_chest: bool = false

@export var message_char_sfx: AudioStream
@export var message_finish_sfx: AudioStream
@export var menu_selection_sfx: AudioStream
@export var menu_confirm_sfx: AudioStream


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
			play_sound(message_finish_sfx)
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
		play_sound(message_char_sfx)

	_previous_character_index = next_character
	_play_elapsed_time += delta

func is_playing():
	return _is_playing_text

func has_completed():
	return _has_completed

func process_input():
	if _is_playing_text:
		return

	if !_is_treasure_chest:
		if Input.is_action_just_pressed("move_left") and _current_selection != 0:
			_current_selection = 0
			$Selection_No/Selection.visible = false
			$Selection_Yes/Selection.visible = true
			play_sound(menu_selection_sfx)
		elif Input.is_action_just_pressed("move_right")  and _current_selection != 1:
			_current_selection = 1
			$Selection_No/Selection.visible = true
			$Selection_Yes/Selection.visible = false
			play_sound(menu_selection_sfx)
		elif Input.is_action_just_pressed("action"):
			_selected_value = _current_selection
			play_sound(menu_confirm_sfx)
	else:
		if Input.is_action_just_pressed("move_up") and _current_selection > 0:
			# initial selection
			if _current_selection == -1:
				_current_selection = 0
			_current_selection -=1
			$WeaponsSelection/Selection_Bow/Selection.visible = false
			$WeaponsSelection/Selection_Sword/Selection.visible = false
			$WeaponsSelection/Selection_Staff/Selection.visible = false
			_display_selection(_current_selection)
			play_sound(menu_selection_sfx)
		elif Input.is_action_just_pressed("move_down")  and _current_selection < 2:
			_current_selection += 1
			$WeaponsSelection/Selection_Bow/Selection.visible = false
			$WeaponsSelection/Selection_Sword/Selection.visible = false
			$WeaponsSelection/Selection_Staff/Selection.visible = false
			_display_selection(_current_selection)
			play_sound(menu_selection_sfx)
		elif Input.is_action_just_pressed("action"):
			_selected_value = _current_selection
			play_sound(menu_confirm_sfx)

func _display_selection(val: int):
	if _current_selection == 0:
		$WeaponsSelection/Selection_Bow/Selection.visible = true
	elif _current_selection == 1:
		$WeaponsSelection/Selection_Sword/Selection.visible = true
	elif _current_selection == 2:
		$WeaponsSelection/Selection_Staff/Selection.visible = true

func _display_options():
	if _is_treasure_chest:
		$WeaponsSelection.visible = true
	else:
		$Selection_No.visible = true
		$Selection_Yes.visible = true

func _hide_options():
	$Selection_No.visible = false
	$Selection_Yes.visible = false
	$WeaponsSelection.visible = false

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

func disable_sound(status: bool):
	_sfx_disabled = status

# We only disable the message box complete sound
func play_sound(sfx: AudioStream):
	if !_sfx_disabled or sfx != message_finish_sfx:
		$AudioStreamPlayer2D.stream = sfx
		$AudioStreamPlayer2D.play()

func set_is_treasure_chest(val: bool):
	_is_treasure_chest = val
