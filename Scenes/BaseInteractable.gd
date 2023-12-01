extends Area2D

@export var type: String

var dialog_container: DialogContainer

func interact():
	match type:
		"ForbiddenForge_battle":
			dialog_container.set_text(["Challenge the Stone Golem?"], true, 1)
			dialog_container.play_next()
			return true
		"ForbiddenForge_back":
			dialog_container.set_text(["Sneak attack?"], true, 2)
			dialog_container.play_next()
			return true
		"ForbiddenForge_environment":
			dialog_container.set_text(["Touch the cristal?"], true, 3)
			dialog_container.play_next()
			return true
		"EnchantedForest_battle":
			dialog_container.set_text(["Fight the Mystical Moth?"], true, 1)
			dialog_container.play_next()
			return true
		"EnchantedForest_back":
			dialog_container.set_text(["Hide in the trees?"], true, 2)
			dialog_container.play_next()
			return true
		"EnchantedForest_environment":
			dialog_container.set_text(["Talk to the trees?"], true, 3)
			dialog_container.play_next()
			return true
		"LostLibrary_battle":
			dialog_container.set_text(["Fight the Dark Mage?"], true, 1)
			dialog_container.play_next()
			return true
		"LostLibrary_back":
			dialog_container.set_text(["Hide behind the shelves?"], true, 2)
			dialog_container.play_next()
			return true
		"LostLibrary_environment":
			dialog_container.set_text(["Read the arcane book?"], true, 3)
			dialog_container.play_next()
			return true
		_:
			print("no type detected:" + type)
			return false

func set_dialog_container(node: DialogContainer):
	dialog_container = node
