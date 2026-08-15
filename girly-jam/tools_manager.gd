extends Node2D

var _tools: Dictionary = {} # ToolType -> Tool

var mode : Enums.tools_mode
var bucket_mode : Enums.bucket_mode
var can_interact_with_tools : bool

var follow_tool : Tool

func set_can_interact_with_tools(value : bool):
	can_interact_with_tools = value
	if !value:
		deselect_old_follow_tool()
	print("can interact with tools: ", value)

func _process(_delta):
	if follow_tool:
		follow_tool.position = get_global_mouse_position()

func set_mode(_mode: Enums.tools_mode):
	if mode == Enums.tools_mode.SPONGE && _mode == Enums.tools_mode.NONE:
		set_bucket_mode(Enums.bucket_mode.NONE)
	mode = _mode
	print("mode is now %s" % GlobalEnums.tools_mode.keys()[_mode])

func set_bucket_mode(_mode : Enums.bucket_mode, color : Color = Color.WHITE):
	if _mode == Enums.bucket_mode.NONE:
		assert(color == Color.WHITE, "ummm tool should not get tinted when bucket mode is set to none")
	bucket_mode = _mode
	print("bucket_mode = %s" % GlobalEnums.bucket_mode.keys()[ToolsManager.bucket_mode])
	_tools[GlobalEnums.tools_mode.SPONGE].tint_tool(color)

func deselect_old_follow_tool():
	if follow_tool:
		print("deselect old follow tool, mode", mode)
		follow_tool.deselect()

func register_tool(tool: Tool) -> void:
	assert(!_tools.has(tool.type), "uh oh tool " + Enums.tools_mode.keys()[tool.type] + "already exists in tool manager")
	_tools[tool.type] = tool

func get_tool(type: GlobalEnums.tools_mode) -> Tool:
	return _tools.get(type, null)

# called from clean controller
func emit_particles(value : bool) -> void:
	if follow_tool:
		value = value && follow_tool.check_particle_requirements()
		follow_tool.toggle_particle_system(value)

func reset() -> void:
	deselect_old_follow_tool()
	set_mode(Enums.tools_mode.NONE)
	set_bucket_mode(Enums.bucket_mode.NONE)
	_tools.clear()
