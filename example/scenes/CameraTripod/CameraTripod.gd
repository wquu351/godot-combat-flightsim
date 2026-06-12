extends Node3D

## 相机三脚架 — 支持跟随模式和后视模式
## X键按住时往后看

@export var TargetNode: NodePath
@onready var target_node = get_node_or_null(TargetNode)

@export var RotationSpeed: float = 1.0

# 后视状态
var is_looking_back: bool = false

func _ready():
	# 不在这里锁定鼠标，等菜单关闭后再锁定
	pass

func _input(event):
	# X键按住往后看
	if event is InputEventKey and event.keycode == KEY_X:
		if event.pressed and not is_looking_back:
			is_looking_back = true
		elif not event.pressed and is_looking_back:
			is_looking_back = false

func _process(delta):
	if is_looking_back:
		# 后视：位置跟随飞机，旋转朝后方
		if target_node and is_instance_valid(target_node):
			global_transform.origin = target_node.global_transform.origin
			rotation.x = lerp_angle(rotation.x, -target_node.rotation.x, delta * RotationSpeed * 2.0)
			rotation.y = lerp_angle(rotation.y, target_node.rotation.y + PI, delta * RotationSpeed * 2.0)
			rotation.z = lerp_angle(rotation.z, -target_node.rotation.z, delta * RotationSpeed * 2.0)
	else:
		# 跟随模式：完全跟随飞机
		if target_node and is_instance_valid(target_node):
			global_transform.origin = target_node.global_transform.origin
			rotation.x = lerp_angle(rotation.x, target_node.rotation.x, delta * RotationSpeed)
			rotation.y = lerp_angle(rotation.y, target_node.rotation.y, delta * RotationSpeed)
			rotation.z = lerp_angle(rotation.z, target_node.rotation.z, delta * RotationSpeed)
