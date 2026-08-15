class_name DecorationsSpawner
extends Node

@export var deco_parent : Node2D

func _ready() -> void:
	self.visible = false

func on_spawn_deco_pressed(decoration_prefab : PackedScene) -> void:
	var decoration := decoration_prefab.instantiate()
	deco_parent.add_child(decoration)
	decoration.global_position = get_viewport().get_visible_rect().size / 2
	self.visible = false

func deco_store_button_pressed() -> void:
	self.visible = !self.visible
