extends BaseScene
class_name BaseSceneSummary


# Called when the node enters the scene tree for the first time.
func _ready():
	if game_data != null:
		$Dialog/Status/Bow/Label.text = str(game_data.dexterity)
		$Dialog/Status/Sword/Label.text = str(game_data.strength)
		$Dialog/Status/Staff/Label.text = str(game_data.magic)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_released("action"):
		get_tree().call_group("game", "reset_game")
	pass
