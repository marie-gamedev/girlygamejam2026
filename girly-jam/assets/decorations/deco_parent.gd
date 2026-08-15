class_name DecoParent
extends Node2D
	
func detach_from_carriage() -> void:
	reparent(get_tree().current_scene, true)
	for i in get_child_count():
		var deco : Decoration = get_child(i) as Decoration
		if deco:
			deco.input_pickable = true
	pass

func attach_to_carriage(carriage : Carriage) -> void:
	reparent(carriage, true)
	for i in get_child_count():
		var deco : Decoration = get_child(i) as Decoration
		if deco:
			deco.input_pickable = false
	pass

func remove_all_children() -> void:
	for i in get_child_count():
		get_child(i).queue_free()
