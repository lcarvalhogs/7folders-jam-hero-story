extends Node2D

var base_scene: BaseScene

enum STAGE_STATE {INTRO, SPAWN_PLAYER, MOVE_PLAYER, DIALOG_CHOICE}

var stage_state: STAGE_STATE

const PLAYER_RESOURCE: String = "res://Scenes/Hero/Hero.tscn"

var _player: Hero

func _ready():
	base_scene = get_parent()
	stage_state = STAGE_STATE.INTRO
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_input(delta)
	pass

func process_input(delta):
	match stage_state:
		STAGE_STATE.INTRO:
			process_input_intro(delta)
		STAGE_STATE.SPAWN_PLAYER:
			_player = load(PLAYER_RESOURCE).instantiate()
			_player.position = Vector2(80, 128)
			add_child(_player)
			stage_state = STAGE_STATE.MOVE_PLAYER
		STAGE_STATE.MOVE_PLAYER:
			process_input_player(delta)
		STAGE_STATE.DIALOG_CHOICE:
			process_input_dialog_selection(delta)
	pass

func process_input_intro(delta: float):
	if !base_scene.dialog_container.is_playing():
		if Input.is_key_pressed(KEY_ENTER):
			base_scene.dialog_container.play_next()
	if base_scene.dialog_container.has_completed():
		stage_state = STAGE_STATE.SPAWN_PLAYER

func process_input_player(delta: float):
	if _player != null:
		_player.process_input(delta)
		if _player.is_interacting():
			stage_state = STAGE_STATE.DIALOG_CHOICE

func process_input_dialog_selection(delta: float):
	if base_scene.dialog_container.has_selection():
		base_scene.dialog_container.visible = false
		stage_state = STAGE_STATE.MOVE_PLAYER
	else:
		base_scene.dialog_container.process_input()
		pass

