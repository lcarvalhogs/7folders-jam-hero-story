extends BaseScene
class_name BaseSceneForge

enum STAGE_STATE {INTRO, SPAWN_PLAYER, MOVE_PLAYER, DIALOG_CHOICE_SELECT, DIALOG_CHOICE_SELECTED}

var stage_state: STAGE_STATE
var _selection_state: int = 0
var _selected_option: int = -1

const PLAYER_RESOURCE: String = "res://Scenes/Hero/Hero.tscn"

var _player: Hero

var _timer_blink: Timer
var _timer: Timer

@export var sword_sfx: AudioStream
@export var barrier_sfx: AudioStream
@export var fire_sfx: AudioStream

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Base scene ready")
	dialog_container = $DialogContainer
	dialog_container.set_text(["You enconter a", "Stone Golem."], false, 1)
	dialog_container.play_next()

	
	$Managers/StoneGolem/AnimationPlayer.play("idle")
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
			$Managers.add_child(_player)
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
					process_dialog_choice_selected_crystal(delta)
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
		_selected_option = dialog_container.get_selection()
		if _selected_option == 1:
			stage_state = STAGE_STATE.MOVE_PLAYER
		else:
			stage_state = STAGE_STATE.DIALOG_CHOICE_SELECTED
	else:
		dialog_container.process_input()
		pass

func _bind_interactable_elements():
	$Managers/StoneGolem/Interactable.set_dialog_container(dialog_container)
	$Managers/StoneGolem/Interactable.connect("body_entered", on_Fight_entered, CONNECT_DEFERRED)
	$Managers/StoneGolem/Interactable.connect("body_exited", on_Fight_exited, CONNECT_DEFERRED)
	
	$Managers/Environment.set_dialog_container(dialog_container)
	$Managers/Environment.connect("body_entered", on_Environment_entered, CONNECT_DEFERRED)
	$Managers/Environment.connect("body_exited", on_Environment_entered, CONNECT_DEFERRED)
	
	$Managers/Sneak.set_dialog_container(dialog_container)
	$Managers/Sneak.connect("body_entered", on_Sneak_entered, CONNECT_DEFERRED)
	$Managers/Sneak.connect("body_exited", on_Sneak_entered, CONNECT_DEFERRED)
	
	$Managers/Exit.connect("body_entered", on_Exit_entered, CONNECT_DEFERRED)

func _blink_toogle_monster():
	var sprite: Sprite2D = $Managers/StoneGolem/Sprite2D
	var modulate: Color = sprite.modulate
	if modulate.a > 0:
		modulate.a = 0
	else:
		modulate.a = 1
	sprite.modulate = modulate

func _blink_toogle_crystal():
	var sprite: Sprite2D = $Managers/Environment/Sprite2D
	var modulate: Color = sprite.modulate
	if modulate.a > 0:
		modulate.a = 0
	else:
		modulate.a = 1
	sprite.modulate = modulate

func _blink_toogle_player():
	var sprite: Sprite2D = $Managers/Hero/Sprite2D
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
	_selection_state = 2
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
	_selection_state = 20
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
	_selection_state = 22
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

func _set_crystal_fail_path():
	_selection_state = 20
	_timer_blink = Timer.new()
	_timer_blink.connect("timeout", _blink_toogle_crystal)
	_timer_blink.wait_time = .125
	add_child(_timer_blink)
	_timer_blink.start()

	_timer = Timer.new()
	_timer.connect("timeout", _timer_timeout)
	_timer.wait_time = 2
	add_child(_timer)
	_timer.start()

func process_dialog_choice_selected_fight(delta: float):
	match _selection_state:
		0:
			dialog_container.disable_sound(true)
			dialog_container.set_text(["You try to slice the", "giant monster in half."], false, 1)
			dialog_container.play_next()
			_selection_state = 1
		1:
			if dialog_container.has_completed():
				if game_data.strength > 1:
					play_sound(sword_sfx)
					_set_fight_success_path()
				else:
					play_sound(barrier_sfx)
					_set_fight_fail_path()
			else:
				process_text_dialog(delta)
		2:
			pass
		3:
			dialog_container.set_text(["You defeated the", "giant monster!", "As the boulders rolls", "you fell the earth shake."], false, 1)
			dialog_container.play_next()
			_selection_state = 4
		4:
			if dialog_container.has_completed():
				_player.set_interactable(null)
				$Managers/StoneGolem.queue_free()
				stage_state = STAGE_STATE.MOVE_PLAYER
				get_tree().call_group("game", "modify_status", 2, 1, 0)
			else:
				process_text_dialog(delta)

		20:
			pass
		21:
			dialog_container.set_text(["The monster uses", "your weapon as a", "toothpick and throws a ", "boulder at you."], false, 1)
			dialog_container.play_next()
			_selection_state = 22
		22:
			if dialog_container.has_completed():
				_set_fight_player_hit()
				_selection_state = 23
			else:
				process_text_dialog(delta)
			pass
		23:
			pass
		24:
			dialog_container.set_text(["The boulder smashes ", "you like a pancake"], false, 1)
			dialog_container.play_next()
			_selection_state = 25
		25:
			if dialog_container.has_completed():
				_selection_state = 26
			else:
				process_text_dialog(delta)
			pass
		26:
			dialog_container.set_text(["Game Over"], false, 1)
			dialog_container.play_next()
			_selection_state = 27
		27:
			if dialog_container.has_completed():
				_selection_state = 28
			else:
				process_text_dialog(delta)
			pass
		28:
			get_tree().call_group("game", "reset_game")

func process_dialog_choice_selected_sneak(delta: float):
	match _selection_state:
		0:
			dialog_container.disable_sound(true)
			dialog_container.set_text(["You try to do a", "sneak attack on", "the enemy"], false, 2)
			dialog_container.play_next()
			_selection_state = 1
		1:
			if dialog_container.has_completed():
				if game_data.dexterity > 1:
					play_sound(sword_sfx)
					_set_fight_success_path()
				else:
					play_sound(barrier_sfx)
					_set_fight_fail_path()
			else:
				process_text_dialog(delta)
		2:
			pass
		3:
			dialog_container.set_text(["You hit the monster's", "weak spot!", "One by one, the monster's", "rocks start to became dust"], false, 2)
			dialog_container.play_next()
			_selection_state = 4
		4:
			if dialog_container.has_completed():
				_player.set_interactable(null)
				$Managers/StoneGolem.queue_free()
				stage_state = STAGE_STATE.MOVE_PLAYER
				get_tree().call_group("game", "modify_status", 0, 2, 1)
			else:
				process_text_dialog(delta)

		20:
			pass
		21:
			dialog_container.set_text(["The monster notices a", "sound and suddenly slap", "his hands", "a bug"], false, 2)
			dialog_container.play_next()
			_selection_state = 22
		22:
			if dialog_container.has_completed():
				play_sound(fire_sfx)
				_set_fight_player_hit()
				_selection_state = 23
			else:
				process_text_dialog(delta)
			pass
		23:
			pass
		24:
			dialog_container.set_text(["The giant hands squashes", "you like a bug!"], false, 2)
			dialog_container.play_next()
			_selection_state = 25
		25:
			if dialog_container.has_completed():
				_selection_state = 26
			else:
				process_text_dialog(delta)
			pass
		26:
			dialog_container.set_text(["Game Over"], false, 1)
			dialog_container.play_next()
			_selection_state = 27
		27:
			if dialog_container.has_completed():
				_selection_state = 28
			else:
				process_text_dialog(delta)
			pass
		28:
			get_tree().call_group("game", "reset_game")

func process_dialog_choice_selected_crystal(delta: float):
	match _selection_state:
		0:
			dialog_container.disable_sound(true)
			dialog_container.set_text(["You absorb the crystal's", "power and infuse your", "weapon with it."], false, 3)
			dialog_container.play_next()
			_selection_state = 1
		1:
			if dialog_container.has_completed():
				
				if game_data.magic > 1:
					play_sound(sword_sfx)
					_set_fight_success_path()
				else:
					play_sound(barrier_sfx)
					_set_crystal_fail_path()
				
			else:
				process_text_dialog(delta)
		2:
			pass
		3:
			dialog_container.set_text(["Without the crystal's", "power, the Golem starts to", "sleep, in a shutdown state"], false, 3)
			dialog_container.play_next()
			_selection_state = 4
		4:
			if dialog_container.has_completed():
				_player.set_interactable(null)
				$Managers/StoneGolem.queue_free()
				stage_state = STAGE_STATE.MOVE_PLAYER
				get_tree().call_group("game", "modify_status", 1, 2, 0)
			else:
				process_text_dialog(delta)

		20:
			pass
		21:
			dialog_container.set_text(["You have trouble", "trying to control", "the crystal's power."], false, 3)
			dialog_container.play_next()
			_selection_state = 22
		22:
			if dialog_container.has_completed():
				_set_fight_player_hit()
				_selection_state = 23
			else:
				process_text_dialog(delta)
			pass
		23:
			pass
		24:
			dialog_container.set_text(["The crystal explodes", "and it's shards hit", "your vital spots"], false, 3)
			dialog_container.play_next()
			_selection_state = 25
		25:
			if dialog_container.has_completed():
				_selection_state = 26
			else:
				process_text_dialog(delta)
			pass
		26:
			dialog_container.set_text(["Game Over"], false, 1)
			dialog_container.play_next()
			_selection_state = 27
		27:
			if dialog_container.has_completed():
				_selection_state = 28
			else:
				process_text_dialog(delta)
			pass
		28:
			get_tree().call_group("game", "reset_game")

func _timer_timeout():
	_timer_blink.stop()
	_timer.stop()
	if _selection_state == 2:
		if dialog_container.get_id() == 3:
			_blink_reset($Managers/Environment/Sprite2D, 1)
		_blink_reset($Managers/StoneGolem/Sprite2D, 0)
		_selection_state = 3
	elif _selection_state == 20:
		if dialog_container.get_id() == 3:
			_blink_reset($Managers/Environment/Sprite2D, 1)
		else:
			_blink_reset($Managers/StoneGolem/Sprite2D, 1)
		_selection_state = 21
	elif _selection_state == 23:
		_blink_reset($Managers/Hero/Sprite2D, 0)
		_selection_state = 24
	remove_child(_timer)
	remove_child(_timer_blink)


func on_Fight_entered(area):
	print("on_Fight_entered:")
	print(area)
	if area is Hero and !has_valid_selection():
		area.set_interactable($Managers/StoneGolem/Interactable)

func on_Fight_exited(area):
	print("on_Fight_exited area:")
	if area is Hero:
		area.set_interactable(null)
	print(area)

func on_Environment_entered(area):
	print("on_Environment_entered:")
	print(area)
	if area is Hero and !has_valid_selection():
		area.set_interactable($Managers/Environment)

func on_Environment_exited(area):
	print("on_Environment_exited area:")
	if area is Hero:
		area.set_interactable(null)
	print(area)

func on_Sneak_entered(area):
	print("on_Sneak_entered:")
	print(area)
	if area is Hero and !has_valid_selection():
		area.set_interactable($Managers/Sneak)

func on_Sneak_exited(area):
	print("on_Sneak_exited area:")
	if area is Hero:
		area.set_interactable(null)
	print(area)

func interact():
	print("interacting!")

# NB (lac):this returns multiple values on multiple ocasions: we only want to make sure to
# avoid re-selecting after the battle already finished
func has_valid_selection():
	# -1: default value; 1: "no" selection
	if _selected_option == -1 or _selected_option == 1:
		return false
	return true

func on_Exit_entered(area):
	if has_valid_selection():
		get_tree().call_group("game", "on_next_level")
