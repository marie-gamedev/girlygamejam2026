extends Node2D

@export var hover_sound : AudioStreamPlayer2D
@export var click_sound : AudioStreamPlayer2D

func on_button_hovered() -> void:
	hover_sound.play()

func on_button_pressed() -> void:
	click_sound.play()
