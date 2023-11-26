extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("idle")
	$Area2D.connect("body_entered", on_Area2D_entered, CONNECT_DEFERRED)
	$Area2D.connect("body_exited", on_Area2D_exited, CONNECT_DEFERRED)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_Area2D_entered(area):
	print("entered area:")
	print(area)
	if area is Hero:
		area.set_interactable(self)

func on_Area2D_exited(area):
	print("exited area:")
	if area is Hero:
		area.set_interactable(null)
	print(area)

func interact():
	print("interacting!")
