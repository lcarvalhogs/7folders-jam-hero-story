extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("idle")
	$Interactable.connect("body_entered", on_DirectInteract_entered, CONNECT_DEFERRED)
	$Interactable.connect("body_exited", on_DirectInteract_exited, CONNECT_DEFERRED)

	$Interactable2.connect("body_entered", on_BackInteract_entered, CONNECT_DEFERRED)
	$Interactable2.connect("body_exited", on_BackInteract_exited, CONNECT_DEFERRED)
	pass # Replace with function body.

func on_DirectInteract_entered(area):
	print("on_DirectInteract_entered:")
	print(area)
	if area is Hero:
		area.set_interactable($Interactable)

func on_DirectInteract_exited(area):
	print("on_DirectInteract_exited area:")
	if area is Hero:
		area.set_interactable(null)
	print(area)

func on_BackInteract_entered(area):
	print("on_BackInteract_entered:")
	print(area)
	if area is Hero:
		area.set_interactable($Interactable2)

func on_BackInteract_exited(area):
	print("on_BackInteract_exited area:")
	if area is Hero:
		area.set_interactable(null)
	print(area)

func interact():
	print("interacting!")
