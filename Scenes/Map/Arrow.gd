extends Sprite2D

var timer: Timer = Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	modulate.a = 0
	timer.connect("timeout", timer_timeout)
	add_child(timer)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_arrow_reference_position(pos: Vector2):
	position = pos
	timer.wait_time = .125
	timer.start()

func _blink_reset(sprite: Sprite2D, alpha: float):
	var modulate: Color = sprite.modulate
	modulate.a = alpha
	sprite.modulate = modulate

func timer_timeout():
	if modulate.a > 0:
		modulate.a = 0
	else:
		modulate.a = 1
