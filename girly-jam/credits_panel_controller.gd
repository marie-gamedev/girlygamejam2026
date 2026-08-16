extends Panel

func show_panel() -> void:
	self.visible = true
	
func hide_panel() -> void:
	self.visible = false

func _ready() -> void:
	hide_panel()
