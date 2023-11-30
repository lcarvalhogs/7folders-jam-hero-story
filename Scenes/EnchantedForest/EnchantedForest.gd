extends BaseScene
class_name BaseSceneForest

# TODO (lac): move this to a base class
enum STAGE_STATE {INTRO, SPAWN_PLAYER, MOVE_PLAYER, DIALOG_CHOICE_SELECT, DIALOG_CHOICE_SELECTED}

var stage_state: STAGE_STATE
var _seletion_state: int

const PLAYER_RESOURCE: String = "res://Scenes/Hero/Hero.tscn"
# end of TODO
var _player: Hero

var _timer_blink: Timer
var _timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Base scene ready")
	dialog_container = $DialogContainer
	dialog_container.set_text(["You enconter a ", "Mystical Moth."], false, 1)
	dialog_container.play_next()

	
	$Moth/AnimationPlayer.play("idle")
	_bind_interactable_elements()
	pass

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
			match dialog_container.get_id():
				1:
					process_dialog_choice_selected_fight(delta)
				2:
					process_dialog_choice_selected_sneak(delta)
				3:
					process_dialog_choice_selected_environment(delta)
	pass

func process_text_dialog(delta: float):
	if !dialog_container.is_playing():
		if Input.is_key_pressed(KEY_ENTER):
			dialog_container.play_next()

func process_input_intro(delta: float):
	process_text_dialog(delta)
	if dialog_container.has_completed():
		stage_state = STAGE_STATE.SPAWN_PLAYER

func process_input_player(delta: float):
	if _player != null:
		_player.process_input(delta)
		if _player.is_interacting():
			stage_state = STAGE_STATE.DIALOG_CHOICE_SELECT

func process_input_dialog_selection(delta: float):
	if dialog_container.has_selection():
		dialog_container.visible = false
		var _selected_option = dialog_container.get_selection()
		if _selected_option == 1:
			stage_state = STAGE_STATE.MOVE_PLAYER
		else:
			stage_state = STAGE_STATE.DIALOG_CHOICE_SELECTED
	else:
		dialog_container.process_input()
		pass

func _bind_interactable_elements():
	$Moth/Interactable.set_dialog_container(dialog_container)
	$Moth/Interactable.connect("body_entered", on_Fight_entered, CONNECT_DEFERRED)
	$Moth/Interactable.connect("body_exited", on_Fight_exited, CONNECT_DEFERRED)
	
	$Environment.set_dialog_container(dialog_container)
	$Environment.connect("body_entered", on_Environment_entered, CONNECT_DEFERRED)
	$Environment.connect("body_exited", on_Environment_entered, CONNECT_DEFERRED)

func on_Fight_entered(area):
	print("on_Fight_entered:")
	print(area)
	if area is Hero:
		area.set_interactable($Moth/Interactable)

func on_Fight_exited(area):
	print("on_Fight_exited area:")
	if area is Hero:
		area.set_interactable(null)
	print(area)

func on_Environment_entered(area):
	print("on_Environment_entered:")
	print(area)
	if area is Hero:
		area.set_interactable($Environment)

func on_Environment_exited(area):
	print("on_Environment_exited area:")
	if area is Hero:
		area.set_interactable(null)
	print(area)
	
func _blink_toogle_monster():
	var sprite: Sprite2D = $Moth/Sprite2D
	var modulate: Color = sprite.modulate
	if modulate.a > 0:
		modulate.a = 0
	else:
		modulate.a = 1
	sprite.modulate = modulate

func _blink_toogle_environment():
	var sprite: Sprite2D = $Crystal/Sprite2D
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
			dialog_container.set_text(["You charge towards", "the Mystical Moth,", "weapon in hand, aiming", "for a powerful strike"], false, 1)
			dialog_container.play_next()
			_seletion_state = 1
		1:
			if dialog_container.has_completed():
				#_set_fight_success_path()
				_set_fight_fail_path()
			else:
				process_text_dialog(delta)
		2:
			pass
		3:
			dialog_container.set_text(["Your powerful strike", "connects, breaking through", "its defenses. The Moth", "recoils, its luminescence", "momentarily dimming", "as it struggles to recover", "from the forceful blow."], false, 1)
			dialog_container.play_next()
			_seletion_state = 4
		4:
			if dialog_container.has_completed():
				_player.set_interactable(null)
				$Moth.queue_free()
				stage_state = STAGE_STATE.MOVE_PLAYER
				get_tree().call_group("game", "modify_status", 2, 1, 0)
			else:
				process_text_dialog(delta)

		20:
			pass
		21:
			dialog_container.set_text(["The Moth retaliates", "with a burst of light", "testing your ability","to endure its magical", "defenses."], false, 1)
			dialog_container.play_next()
			_seletion_state = 22
		22:
			if dialog_container.has_completed():
				_set_fight_player_hit()
				_seletion_state = 23
			else:
				process_text_dialog(delta)
			pass
		23:
			pass
		24:
			dialog_container.set_text(["Unable to see, you", "are easily wrapped up", "in by Mystical Moth", "magic, and starts"," to fall asleep,", "never waking up."], false, 1)
			dialog_container.play_next()
			_seletion_state = 25
		25:
			if dialog_container.has_completed():
				_seletion_state = 26
			else:
				process_text_dialog(delta)
			pass
		26:
			dialog_container.set_text(["Game Over"], false, 1)
			dialog_container.play_next()
			_seletion_state = 27
		27:
			if dialog_container.has_completed():
				_seletion_state = 28
			else:
				process_text_dialog(delta)
			pass
		28:
			get_tree().call_group("game", "reset_game")

func process_dialog_choice_selected_sneak(delta):
	pass
func process_dialog_choice_selected_environment(delta):
	pass

func _timer_timeout():
	_timer_blink.stop()
	_timer.stop()
	if _seletion_state == 2:
		if dialog_container.get_id() == 3:
			_blink_reset($Environment/Sprite2D, 1)
		_blink_reset($Moth/Sprite2D, 0)
		_seletion_state = 3
	elif _seletion_state == 20:
		if dialog_container.get_id() == 3:
			_blink_reset($Environment/Sprite2D, 1)
		else:
			_blink_reset($Moth/Sprite2D, 1)
		_seletion_state = 21
	elif _seletion_state == 23:
		_blink_reset($Hero/Sprite2D, 0)
		_seletion_state = 24
	remove_child(_timer)
	remove_child(_timer_blink)
