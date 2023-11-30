extends Node

@export var initial_scene: String

var game_data: GameData
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("game")
	call_deferred("init")


func init():
	game_data = GameData.new()
	load_level(initial_scene)
	pass

func get_level_node():
	var root = get_tree().root
	if root.has_node("Level"):
		return root.get_node("Level")
	return null

func load_level(path: String):
	var result: bool = false
	var old_level = get_level_node()
	var root = get_tree().root

	if old_level != null:
		root.remove_child(old_level)
		old_level.queue_free()

	var level = load(path)
	if level != null:
		var level_instance = level.instantiate()
		root.add_child(level_instance)
		result = true

	return result

# API functions
func modify_status(str: int, dex: int, mag: int):
	game_data.strength += str
	game_data.dexterity += dex
	game_data.magic += mag

func reset_game():
	init()
