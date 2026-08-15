extends Control

@export var prefab : PackedScene
@onready var deco_manager : DecorationsSpawner = $"../../.."

func pressed() -> void:
	deco_manager.on_spawn_deco_pressed(prefab)
