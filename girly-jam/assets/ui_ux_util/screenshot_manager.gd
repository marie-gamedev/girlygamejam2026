extends Node

@export var _open_folder_button : Control # disable this when running web build

func _ready() -> void:
	_open_folder_button.visible = !OS.has_feature("web")

func _on_take_screenshot_button_pressed():
	take_screenshot()
	
func _on_open_screenshot_folder_button_pressed():
	_open_screenshot_folder()

func take_screenshot() -> void:
	# Wait one frame so the viewport is fully rendered before we grab it
	await RenderingServer.frame_post_draw

	var img := get_viewport().get_texture().get_image()
	var png_bytes := img.save_png_to_buffer()

	if png_bytes.is_empty():
		push_error("Screenshot: failed to encode PNG")
		return

	if OS.has_feature("web"):
		_save_web(png_bytes)
	else:
		_save_native(png_bytes)

func _make_filename() -> String:
	var dt := Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
	return "screenshot_%s.png" % dt

# --- Web export: trigger a browser download via JS ---
func _save_web(png_bytes: PackedByteArray) -> void:
	var base64_png := Marshalls.raw_to_base64(png_bytes)
	var filename := _make_filename()

	var js := """
	(function() {
		const b64 = '%s';
		const byteChars = atob(b64);
		const byteNums = new Array(byteChars.length);
		for (let i = 0; i < byteChars.length; i++) {
			byteNums[i] = byteChars.charCodeAt(i);
		}
		const byteArray = new Uint8Array(byteNums);
		const blob = new Blob([byteArray], { type: 'image/png' });
		const link = document.createElement('a');
		link.href = URL.createObjectURL(blob);
		link.download = '%s';
		document.body.appendChild(link);
		link.click();
		document.body.removeChild(link);
		URL.revokeObjectURL(link.href);
	})();
	""" % [base64_png, filename]

	JavaScriptBridge.eval(js, true)

# --- Native (desktop) export: write straight to disk ---
func _save_native(png_bytes: PackedByteArray) -> void:
	var dir_path := "user://screenshots"
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_absolute(dir_path)

	var path := dir_path.path_join(_make_filename())
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Screenshot: could not open file for writing: %s" % FileAccess.get_open_error())
		return

	file.store_buffer(png_bytes)
	file.close()

	print("Screenshot saved to: ", ProjectSettings.globalize_path(path))

func _open_screenshot_folder() -> void:
	print ("opnening screenshot location")
	var dir_path := "user://screenshots"
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_absolute(dir_path)

	OS.shell_open(ProjectSettings.globalize_path(dir_path))
