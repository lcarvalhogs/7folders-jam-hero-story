extends Node2D

var base_scene: BaseScene

enum STAGE_STATE {INTRO, SELECTION}

var stage_state: STAGE_STATE

func _ready():
	base_scene = get_parent()
	stage_state = STAGE_STATE.INTRO
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_input(delta)
	pass

func process_input(delta):
	match stage_state:
		STAGE_STATE.INTRO:
			process_input_intro(delta)
	pass

func process_input_intro(delta: float):
	if !base_scene.dialog_container.is_playing():
		if Input.is_key_pressed(KEY_ENTER):
			base_scene.dialog_container.play_next()
	if base_scene.dialog_container.has_completed():
		stage_state = STAGE_STATE.SELECTION
