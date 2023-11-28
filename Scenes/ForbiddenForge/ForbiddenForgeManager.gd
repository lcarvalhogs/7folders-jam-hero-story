extends Node2D

var base_scene: BaseScene

enum STAGE_STATE {INTRO, SPAWN_PLAYER, MOVE_PLAYER, DIALOG_CHOICE_SELECT, DIALOG_CHOICE_SELECTED}

var stage_state: STAGE_STATE
var _seletion_state: int

const PLAYER_RESOURCE: String = "res://Scenes/Hero/Hero.tscn"

var _player: Hero

var _timer_blink: Timer
var _timer: Timer

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
		STAGE_STATE.DIALOG_CHOICE_SELECT:
			process_input_dialog_selection(delta)
		STAGE_STATE.DIALOG_CHOICE_SELECTED:
			process_dialog_choice_selected_fight(delta)
	pass

func process_text_dialog(delta: float):
	if !base_scene.dialog_container.is_playing():
		if Input.is_key_pressed(KEY_ENTER):
			base_scene.dialog_container.play_next()

func process_input_intro(delta: float):
	process_text_dialog(delta)
	if base_scene.dialog_container.has_completed():
		stage_state = STAGE_STATE.SPAWN_PLAYER

func process_input_player(delta: float):
	if _player != null:
		_player.process_input(delta)
		if _player.is_interacting():
			stage_state = STAGE_STATE.DIALOG_CHOICE_SELECT

func process_input_dialog_selection(delta: float):
	if base_scene.dialog_container.has_selection():
		base_scene.dialog_container.visible = false
		var _selected_option = base_scene.dialog_container.get_selection()
		if _selected_option == 1:
			stage_state = STAGE_STATE.MOVE_PLAYER
		else:
			stage_state = STAGE_STATE.DIALOG_CHOICE_SELECTED
	else:
		base_scene.dialog_container.process_input()
		pass

func _blink_toogle_monster():
	var sprite: Sprite2D = $StoneGolem/Sprite2D
	var modulate: Color = sprite.modulate
	if modulate.a > 0:
		modulate.a = 0
	else:
		modulate.a = 1
	sprite.modulate = modulate

func _blink_toogle_player():
	var sprite: Sprite2D = $Hero/Sprite2D
	var modulate: Color = sprite.modulate
	if modulate.a > 0:
		modulate.a = 0
	else:
		modulate.a = 1
	sprite.modulate = modulate

func _blink_reset(sprite: Sprite2D, alpha: float):
	var modulate: Color = sprite.modulate
	modulate.a = alpha
	sprite.modulate = modulate

func _set_fight_success_path():
	_seletion_state = 2
	_timer_blink = Timer.new()
	_timer_blink.connect("timeout", _blink_toogle_monster)
	_timer_blink.wait_time = .125
	add_child(_timer_blink)
	_timer_blink.start()

	_timer = Timer.new()
	_timer.connect("timeout", _timer_timeout)
	_timer.wait_time = 2
	add_child(_timer)
	_timer.start()

func _set_fight_fail_path():
	_seletion_state = 20
	_timer_blink = Timer.new()
	_timer_blink.connect("timeout", _blink_toogle_monster)
	_timer_blink.wait_time = .125
	add_child(_timer_blink)
	_timer_blink.start()

	_timer = Timer.new()
	_timer.connect("timeout", _timer_timeout)
	_timer.wait_time = 1
	add_child(_timer)
	_timer.start()

func _set_fight_player_hit():
	_seletion_state = 22
	_timer_blink = Timer.new()
	_timer_blink.connect("timeout", _blink_toogle_player)
	_timer_blink.wait_time = .125
	add_child(_timer_blink)
	_timer_blink.start()

	_timer = Timer.new()
	_timer.connect("timeout", _timer_timeout)
	_timer.wait_time = 1
	add_child(_timer)
	_timer.start()

func process_dialog_choice_selected_fight(delta: float):
	match _seletion_state:
		0:
			base_scene.dialog_container.set_text(["You try to slice the", "giant monster in half"], false)
			base_scene.dialog_container.play_next()
			_seletion_state = 1
		1:
			if base_scene.dialog_container.has_completed():
				#_set_fight_success_path()
				_set_fight_fail_path()
			else:
				process_text_dialog(delta)
		2:
			pass
		3:
			base_scene.dialog_container.set_text(["You defeated the", "giant monster!", "As the boulders rolls", "you fell the earth shake"], false)
			base_scene.dialog_container.play_next()
			_seletion_state = 4
		4:
			if base_scene.dialog_container.has_completed():
				_player.set_interactable(null)
				$StoneGolem.queue_free()
				stage_state = STAGE_STATE.MOVE_PLAYER
			else:
				process_text_dialog(delta)

		20:
			pass
		21:
			base_scene.dialog_container.set_text(["The monster uses", "your sword as a toothpick", "and throws a boulder", "at you"], false)
			base_scene.dialog_container.play_next()
			_seletion_state = 22
		22:
			if base_scene.dialog_container.has_completed():
				_set_fight_player_hit()
				_seletion_state = 23
			else:
				process_text_dialog(delta)
			pass
		23:
			pass
		24:
			base_scene.dialog_container.set_text(["The boulder smashes you ", "like a pancake"], false)
			base_scene.dialog_container.play_next()
			_seletion_state = 25
		25:
			if base_scene.dialog_container.has_completed():
				_seletion_state = 26
			else:
				process_text_dialog(delta)
			pass
		26:
			base_scene.dialog_container.set_text(["Game Over"], false)
			base_scene.dialog_container.play_next()
			_seletion_state = 27
		27:
			pass

func _timer_timeout():
	_timer_blink.stop()
	_timer.stop()
	if _seletion_state == 2:
		_blink_reset($StoneGolem/Sprite2D, 0)
		_seletion_state = 3
	elif _seletion_state == 20:
		_blink_reset($StoneGolem/Sprite2D, 1)
		_seletion_state = 21
	elif _seletion_state == 23:
		_blink_reset($Hero/Sprite2D, 1)
		_seletion_state = 24
	remove_child(_timer)
	remove_child(_timer_blink)
