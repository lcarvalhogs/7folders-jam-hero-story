extends Area2D

@export var type: String

var dialog_container: DialogContainer

func interact():
	match type:
		"ForbiddenForge_battle":
			dialog_container.set_text(["Fight?"], true)
			dialog_container.play_next()
			return true
		"ForbiddenForge_back":
			dialog_container.set_text(["Sneak attack?"], true)
			dialog_container.play_next()
			return true
		"ForbiddenForge_environment":
			dialog_container.set_text(["Pull the lever?"], true)
			dialog_container.play_next()
			return true
		_:
			print("no type detected:" + type)
			return false

func set_dialog_container(node: DialogContainer):
	dialog_container = node
