extends BaseScene
class_name BaseSceneMapRoute


var _timer: Timer = Timer.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	_timer.wait_time = 3
	_timer.connect("timeout", _timer_timeout)
	add_child(_timer)
	_timer.start()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _timer_timeout():
	_timer.stop()
	get_tree().call_group("game", "on_next_level")

func set_arrow_reference_position(val: int):
	match val:
		0:# this does not match any real game case, but is used for debugging!
			$Managers/Map/HereArrow.set_arrow_reference_position(Vector2(116,32))
		2:
			$Managers/Map/HereArrow.set_arrow_reference_position(Vector2(96,80))
		4:
			$Managers/Map/HereArrow.set_arrow_reference_position(Vector2(136,70))
		6:
			$Managers/Map/HereArrow.set_arrow_reference_position(Vector2(116,32))
		6:
			$Managers/Map/HereArrow.set_arrow_reference_position(Vector2(43,30))
		
