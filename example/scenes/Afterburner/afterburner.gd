extends Node3D

## 加力模式系统 — 按住Shift加速3倍 + FOV效果

# === 参数 ===
@export var afterburner_multiplier: float = 3.0   # 加力推力倍率
@export var fov_normal: float = 70.0               # 正常FOV
@export var fov_afterburner: float = 85.0           # 加力FOV
@export var fov_lerp_speed: float = 4.0             # FOV过渡速度
@export var power_return_speed: float = 0.5         # 松开Shift后功率恢复速度

# === 内部变量 ===
var aircraft: RigidBody3D = null
var engine_module = null
var camera: Camera3D = null
var is_afterburner: bool = false
var saved_normal_power: float = 1.0

func _ready():
	# 延迟一帧等待父节点就绪
	await get_tree().process_frame
	aircraft = get_parent().get_parent()  # Aircraft节点
	_find_engine()
	_find_camera()

func _find_engine():
	if aircraft:
		for child in aircraft.get_children():
			if child is AircraftModule_Engine:
				engine_module = child
				break

func _find_camera():
	# 从CameraTripod找相机
	var tripod = get_node_or_null("/root/WorldOrientationReference")
	# 从场景根找
	var root = get_tree().current_scene
	if root:
		_recursive_find_camera(root)

func _recursive_find_camera(node: Node):
	if node is Camera3D:
		camera = node
		return
	for child in node.get_children():
		_recursive_find_camera(child)
		if camera:
			return

func _physics_process(delta):
	if not engine_module:
		return
	
	# 检测Shift键
	is_afterburner = Input.is_key_pressed(KEY_SHIFT)
	
	if is_afterburner:
		# 加力模式：将引擎功率推到最大
		if engine_module.is_engine_working:
			saved_normal_power = engine_module.current_power
			engine_module.engine_set_power(1.0)
	else:
		# 松开后逐渐恢复
		pass
	
	# FOV效果
	if camera:
		var target_fov = fov_afterburner if is_afterburner else fov_normal
		camera.fov = lerp(camera.fov, target_fov, fov_lerp_speed * delta)

func is_afterburner_active() -> bool:
	return is_afterburner
