extends BaseScene
class_name BaseSceneForest

# TODO (lac): move this to a base class
enum STAGE_STATE {INTRO, SPAWN_PLAYER, MOVE_PLAYER, DIALOG_CHOICE_SELECT, DIALOG_CHOICE_SELECTED}

var stage_state: STAGE_STATE
var _seletion_state: int
var _selected_option: int = -1

const PLAYER_RESOURCE: String = "res://Scenes/Hero/Hero.tscn"
# end of TODO
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
		_selected_option = dialog_container.get_selection()
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
	
	$Sneak.set_dialog_container(dialog_container)
	$Sneak.connect("body_entered", on_Sneak_entered, CONNECT_DEFERRED)
	$Sneak.connect("body_exited", on_Sneak_entered, CONNECT_DEFERRED)
	
	$Managers/Exit.connect("body_entered", on_Exit_entered, CONNECT_DEFERRED)

func on_Fight_entered(area):
	print("on_Fight_entered:")
	print(area)
	if area is Hero and !has_valid_selection():
		area.set_interactable($Moth/Interactable)

func on_Fight_exited(area):
	print("on_Fight_exited area:")
	if area is Hero:
		area.set_interactable(null)
	print(area)

func on_Environment_entered(area):
	print("on_Environment_entered:")
	print(area)
	if area is Hero and !has_valid_selection():
		area.set_interactable($Environment)

func on_Environment_exited(area):
	print("on_Environment_exited area:")
	if area is Hero:
		area.set_interactable(null)
	print(area)

func on_Sneak_entered(area):
	print("on_Sneak_entered:")
	print(area)
	if area is Hero and !has_valid_selection():
		area.set_interactable($Sneak)

func on_Sneak_exited(area):
	print("on_Sneak_exited area:")
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
			dialog_container.disable_sound(true)
			dialog_container.set_text(["You charge towards", "the Mystical Moth,", "weapon in hand, aiming", "for a powerful strike"], false, 1)
			dialog_container.play_next()
			_seletion_state = 1
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
				play_sound(fire_sfx)
				_set_fight_player_hit()
				_seletion_state = 23
			else:
				process_text_dialog(delta)
			pass
		23:
			pass
		24:
			dialog_container.set_text(["Blinded by the strong", "light, you became an ", "easy target to the", "Mystical Moth's spells.", "You start to became", "uncouncious and falls,", "asleep, never waking."], false, 1)
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

func _set_sneak_fail_path():
	_seletion_state = 20
	_timer_blink = Timer.new()
	add_child(_timer_blink)

	_timer = Timer.new()
	_timer.connect("timeout", _timer_timeout)
	_timer.wait_time = 1
	add_child(_timer)
	_timer.start()

func process_dialog_choice_selected_sneak(delta):
	match _seletion_state:
		0:
			dialog_container.disable_sound(true)
			dialog_container.set_text(["Navigating through the", "Enchanted Forest's", "shadows, you search", "for the perfect ", "moment to strike.", "The Mystical Moth seems", "unaware as you position", "yourself for a", "stealthy assault"], false, 2)
			dialog_container.play_next()
			_seletion_state = 1
		1:
			if dialog_container.has_completed():
				if game_data.dexterity > 1:
					play_sound(sword_sfx)
					_set_fight_success_path()
				else:
					play_sound(barrier_sfx)
					_set_sneak_fail_path()
			else:
				process_text_dialog(delta)
		2:
			pass
		3:
			dialog_container.set_text(["With precise timing,", "you unleash a swift", "and unexpected attack,", "catching the Moth", "off guard.", "Your precise attack", "disrupt the creature's", "ethereal flight, leaving", "it bleeding to death", "on the forest ground."], false, 2)
			dialog_container.play_next()
			_seletion_state = 4
		4:
			if dialog_container.has_completed():
				_player.set_interactable(null)
				$Moth.queue_free()
				stage_state = STAGE_STATE.MOVE_PLAYER
				get_tree().call_group("game", "modify_status", 0, 2, 1)
			else:
				process_text_dialog(delta)

		20:
			pass
		21:
			dialog_container.set_text(["As you attempt to", "approach the Mystical", "Moth with stealth,","a sudden rustle in the", "enchanted foliage alerts", "the creature to your presence."], false, 2)
			dialog_container.play_next()
			_seletion_state = 22
		22:
			if dialog_container.has_completed():
				play_sound(fire_sfx)
				_set_fight_player_hit()
				_seletion_state = 23
			else:
				process_text_dialog(delta)
			pass
		23:
			pass
		24:
			dialog_container.set_text(["In a swift countermove,", "the Moth releases a", "blinding burst of", "magical energy, exposing", "your location.", "Caught off guard and", "unable to evade,", "the intense magical", "surge overwhelms you.", "The last thing you see", "is the radiant glow", "of the Moth's wings as", "the magical onslaught", "takes its toll, leading", "to an unfortunate demise."], false, 2)
			dialog_container.play_next()
			_seletion_state = 25
		25:
			if dialog_container.has_completed():
				_seletion_state = 26
			else:
				process_text_dialog(delta)
			pass
		26:
			dialog_container.set_text(["Game Over"], false, 2)
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

func _set_environment_fail_path():
	_seletion_state = 20
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

func process_dialog_choice_selected_environment(delta):
	match _seletion_state:
		0:
			dialog_container.disable_sound(true)
			dialog_container.set_text(["Seeking to harness the", "magic of the forest", "you call upon the aid", "of nature itself."], false, 3)
			dialog_container.play_next()
			_seletion_state = 1
		1:
			if dialog_container.has_completed():
				if game_data.magic > 1:
					play_sound(sword_sfx)
					_set_fight_success_path()
				else:
					play_sound(barrier_sfx)
					_set_environment_fail_path()
			else:
				process_text_dialog(delta)
		2:
			pass
		3:
			dialog_container.set_text(["Whispers of nature guide", "you as mystical creatures", "emerge to aid your cause.", "Together, you create a", "harmonious force that", "weakens the Moth's", "mystical resilience.", "until no trace of", "the Moth is left"], false, 3)
			dialog_container.play_next()
			_seletion_state = 4
		4:
			if dialog_container.has_completed():
				_player.set_interactable(null)
				$Moth.queue_free()
				stage_state = STAGE_STATE.MOVE_PLAYER
				get_tree().call_group("game", "modify_status", 0, 1, 2)
			else:
				process_text_dialog(delta)

		20:
			pass
		21:
			dialog_container.set_text(["As you attempt to call", "upon the aid of the", "mystical creatures and", "the forces of nature,", "a discordant energy", "disrupts your connection.", "The creatures, now confused,", "join forces with", "the Mystical Moth."], false, 3)
			dialog_container.play_next()
			_seletion_state = 22
		22:
			if dialog_container.has_completed():
				play_sound(fire_sfx)
				_set_fight_player_hit()
				_seletion_state = 23
			else:
				process_text_dialog(delta)
			pass
		23:
			pass
		24:
			dialog_container.set_text(["Now outnumbered,", "the fight became a ", "one-sided blood-bath.", "Your lifeless body", "lies on the ground", "while the Moth drinks", "your blood, mocking one", "more hero that", "dared to defy her."], false, 3)
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

func _timer_timeout():
	_timer_blink.stop()
	_timer.stop()
	if _seletion_state == 2:
		_blink_reset($Moth/Sprite2D, 0)
		_seletion_state = 3
	elif _seletion_state == 20:
		_blink_reset($Moth/Sprite2D, 1)
		_seletion_state = 21
	elif _seletion_state == 23:
		_blink_reset($Hero/Sprite2D, 0)
		_seletion_state = 24
	remove_child(_timer)
	remove_child(_timer_blink)

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
