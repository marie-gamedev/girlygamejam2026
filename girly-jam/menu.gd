extends Node2D

func play_btn_pressed():
	get_tree().change_scene_to_file("res://main.tscn")

func _on_button_pressed():
	play_btn_pressed()

func _on_button_quit_pressed():
	get_tree().quit()
