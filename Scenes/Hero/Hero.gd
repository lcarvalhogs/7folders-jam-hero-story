extends CharacterBody2D

var _fps = 30
var _speed = 60 * 30

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
	move_and_slide()
