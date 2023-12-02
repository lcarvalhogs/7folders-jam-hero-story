extends Node

@export var initial_scene: String

var game_data: GameData

@export var scene_lost_library_music: AudioStream
@export var scene_enchanted_forest_music: AudioStream

const LOST_LIBRARY_PATH: String = "res://Scenes/LostLibrary/LostLibrary.tscn"
const ENCHANTED_FOREST_PATH: String = "res://Scenes/EnchantedForest/EnchantedForest.tscn"
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("game")
	call_deferred("init")


func init():
	game_data = GameData.new()
	game_data.dexterity = 10
	game_data.magic = 10
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
		var level_instance: BaseScene = level.instantiate()
		level_instance.set_game_data(game_data)
		root.add_child(level_instance)
		result = true
		if path == LOST_LIBRARY_PATH:
			$AudioStreamPlayer2D.stream = scene_lost_library_music
			$AudioStreamPlayer2D.stream
			$AudioStreamPlayer2D.play()
		elif path == ENCHANTED_FOREST_PATH:
			$AudioStreamPlayer2D.stream = scene_enchanted_forest_music
			$AudioStreamPlayer2D.stream
			$AudioStreamPlayer2D.play()

	return result

# API functions
func modify_status(str: int, dex: int, mag: int):
	game_data.strength += str
	game_data.dexterity += dex
	game_data.magic += mag

func reset_game():
	init()
