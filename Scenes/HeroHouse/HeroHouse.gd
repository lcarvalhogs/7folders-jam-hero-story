extends BaseScene
class_name BaseSceneHeroHouse

# TODO (lac): move this to a base class
enum STAGE_STATE {INTRO, SPAWN_PLAYER, MOVE_PLAYER, WEAPON_CHOICE_SELECT}

var _stage_state: STAGE_STATE

const PLAYER_RESOURCE: String = "res://Scenes/Hero/Hero.tscn"
# end of TODO
var _player: Hero

# Called when the node enters the scene tree for the first time.
func _ready():
	dialog_container = $DialogContainer
	dialog_container.set_text(["Hero's House"], false, 1)
	dialog_container.play_next()

	_bind_interactable_elements()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_input(delta)
	pass

func process_input(delta):
	match _stage_state:
		STAGE_STATE.INTRO:
			process_input_intro(delta)
		STAGE_STATE.SPAWN_PLAYER:
			_player = load(PLAYER_RESOURCE).instantiate()
			_player.position = Vector2(80, 128)
			$Managers.add_child(_player)
			_stage_state = STAGE_STATE.MOVE_PLAYER
		STAGE_STATE.MOVE_PLAYER:
			process_input_player(delta)
		STAGE_STATE.WEAPON_CHOICE_SELECT:
			process_input_dialog_selection(delta)
	pass

func process_text_dialog(delta: float):
	if !dialog_container.is_playing():
		if Input.is_key_pressed(KEY_ENTER):
			dialog_container.play_next()

func process_input_intro(delta: float):
	process_text_dialog(delta)
	if dialog_container.has_completed():
		_stage_state = STAGE_STATE.SPAWN_PLAYER

func process_input_player(delta: float):
	if _player != null:
		_player.process_input(delta)
		if _player.is_interacting():
			_stage_state = STAGE_STATE.WEAPON_CHOICE_SELECT

func process_input_dialog_selection(delta: float):
	if dialog_container.has_selection():
		dialog_container.visible = false
		var _selected_option = dialog_container.get_selection()
		if _selected_option >= 0:
			var strength = 0
			var dex = 0
			var mag = 0
			match _selected_option:
				0:
					dex += 2
				1:
					strength += 2
				2:
					mag += 2
			get_tree().call_group("game", "modify_status", strength, dex, mag)
			# TODO (lac): Refactor this
			$Managers/Interactable/Sprite2D.frame = 1
			_stage_state = STAGE_STATE.MOVE_PLAYER
	else:
		dialog_container.process_input()
		pass

func _bind_interactable_elements():
	$Managers/Interactable.set_dialog_container(dialog_container)
	$Managers/Interactable.connect("body_entered", on_Interactable_entered, CONNECT_DEFERRED)
	$Managers/Interactable.connect("body_exited", on_Interactable_exited, CONNECT_DEFERRED)
	
	$Managers/Exit.connect("body_entered", on_Exit_entered, CONNECT_DEFERRED)

func on_Interactable_entered(area):
	print("on_Interactable_entered:")
	print(area)
	if area is Hero and !dialog_container.has_selection():
		area.set_interactable($Managers/Interactable)

func on_Interactable_exited(area):
	print("on_Interactable_exited area:")
	if area is Hero:
		area.set_interactable(null)
	print(area)
