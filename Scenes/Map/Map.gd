extends BaseScene
class_name BaseSceneMap

var _map: Node2D
var _scroll: bool = false

enum STAGE_STATE {INTRO, STARTING, HERE_LOCATION}
var stage_state: STAGE_STATE = STAGE_STATE.INTRO
var _timer: Timer = Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	_map = $Managers/Map
	_scroll = true
	
	dialog_container = $DialogContainer
	_timer.connect("timeout", _timer_timeout)
	_timer.wait_time = 3
	add_child(_timer)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _scroll:
		print(_map.position.y)
		_map.position.y -= 5*16*delta
		if _map.position.y <= 0:
			_scroll = false
			_map.position.y = 0
	else:
		process_input(delta)

func process_input(delta):
	match stage_state:
		STAGE_STATE.INTRO:
			dialog_container.set_text(["Press Enter to start"], false, 0)
			dialog_container.play_next()
			stage_state = STAGE_STATE.STARTING
		STAGE_STATE.STARTING:
			process_text_dialog(delta)
			if dialog_container.has_completed():
				dialog_container.visible = false
				$Managers/Map/HereArrow.set_arrow_reference_position(Vector2(43,30))
				stage_state = STAGE_STATE.HERE_LOCATION
				_timer.start()
		STAGE_STATE.HERE_LOCATION:
			# Do nothing: this in handled by the timer
			pass
	pass

func process_text_dialog(delta: float):
	if !dialog_container.is_playing():
		if Input.is_key_pressed(KEY_ENTER):
			dialog_container.play_next()

func _timer_timeout():
	_timer.stop()
	get_tree().call_group("game", "on_next_level")
	
