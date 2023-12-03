extends Node

@export var initial_scene: String

var game_data: GameData

@export var scene_lost_library_music: AudioStream
@export var scene_enchanted_forest_music: AudioStream
@export var scene_forbidden_forge_music: AudioStream
@export var scene_map_route_path_music: AudioStream
@export var scene_intro_path_music: AudioStream

const LOST_LIBRARY_PATH: String = "res://Scenes/LostLibrary/LostLibrary.tscn"
const ENCHANTED_FOREST_PATH: String = "res://Scenes/EnchantedForest/EnchantedForest.tscn"
const FORBIDDEN_FORGE_PATH: String = "res://Scenes/ForbiddenForge/ForbiddenForge.tscn"
const INTRO_PATH: String = "res://Scenes/Map/Map.tscn"
const MAP_ROUTE_PATH: String = "res://Scenes/Map/MapRoute.tscn"
const HERO_HOUSE_PATH: String = "res://Scenes/HeroHouse/HeroHouse.tscn"

const LEVELS = [
	INTRO_PATH
	,HERO_HOUSE_PATH
	,MAP_ROUTE_PATH
	,FORBIDDEN_FORGE_PATH
	,MAP_ROUTE_PATH
	,ENCHANTED_FOREST_PATH
	,MAP_ROUTE_PATH
	,LOST_LIBRARY_PATH
	,MAP_ROUTE_PATH
	,HERO_HOUSE_PATH]


var _level_number = 0
@export var fade_time: float = .5

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("game")
	call_deferred("init")


func init():
	$AudioStreamPlayer2D.stop()
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
		elif path == FORBIDDEN_FORGE_PATH:
			$AudioStreamPlayer2D.stream = scene_forbidden_forge_music
			$AudioStreamPlayer2D.stream
			$AudioStreamPlayer2D.play()
		elif path == INTRO_PATH:
			$AudioStreamPlayer2D.stream = scene_intro_path_music
			$AudioStreamPlayer2D.stream
			$AudioStreamPlayer2D.play()
		elif path == MAP_ROUTE_PATH:
			$AudioStreamPlayer2D.stream = scene_map_route_path_music
			$AudioStreamPlayer2D.stream
			$AudioStreamPlayer2D.play()
			level_instance.set_arrow_reference_position(_level_number)

	return result

# API functions
func modify_status(str: int, dex: int, mag: int):
	game_data.strength += str
	game_data.dexterity += dex
	game_data.magic += mag

func reset_game():
	init()

func on_next_level():
	$AudioStreamPlayer2D.stop()
	_level_number += 1
	# NB (lac): Scene transition
	get_tree().paused = true	# NB (lac): Pause the game, which is in "process" mode (levelr are not)
	var tween: Tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)	# NB (lac): set tween to always process
	tween.tween_property($Node2D/Fader, "color:a", 1, fade_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)	
	await(tween.finished)

	load_level(LEVELS[_level_number])

	# NB (lac): Scene transition
	tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property($Node2D/Fader, "color:a", 0, 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await(tween.finished)
	get_tree().paused = false
	# TODO (lac): Do something when there are no more levels
