extends CharacterBody2D
class_name Hero

var _speed = 60
var _interactable: Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process_input(delta: float):
	if Input.is_action_just_pressed("action"):
		if _interactable != null:
			_interactable.interact()
		return

	if Input.is_action_pressed("move_right"):
		velocity.x = _speed * delta
		velocity.y = 0
		$Sprite2D.flip_h = true
		$AnimationPlayer.play("left")
	elif Input.is_action_pressed("move_left"):
		velocity.x = -_speed * delta
		velocity.y = 0
		$Sprite2D.flip_h = false
		$AnimationPlayer.play("left")
	elif Input.is_action_pressed("move_up"):
		velocity.y = -_speed * delta
		velocity.x = 0
		$AnimationPlayer.play("up")
	elif Input.is_action_pressed("move_down"):
		velocity.y = _speed * delta
		velocity.x = 0
		$AnimationPlayer.play("down")
	else:
		velocity.y = 0
		velocity.x = 0
		$AnimationPlayer.pause()
	pass

func _physics_process(delta):
	move_and_collide(velocity)

func move(x: float, y: float):
	velocity.x = x * _speed
	velocity.y = y * _speed

	if x > 0:
		velocity.x = _speed
		$Sprite2D.flip_h = true
		$AnimationPlayer.play("left")
	elif x < 0:
		velocity.x = -_speed
		$Sprite2D.flip_h = false
		$AnimationPlayer.play("left")
	elif y > 0:
		velocity.y = -_speed
		$AnimationPlayer.play("up")
	elif y < 0:
		velocity.y = _speed
		$AnimationPlayer.play("down")

func set_interactable(interactable: Node2D):
	_interactable = interactable
