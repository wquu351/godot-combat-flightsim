extends Control
class_name LockUI

## 战争雷霆风格锁定界面 — 支持武器模式切换

# === 可调参数 ===
@export var lock_distance: float = 500.0
@export var lock_angle: float = 30.0         # 机头前方锁定角度(度) — 只有在这个锥形范围内才能锁定
@export var box_size: float = 40.0
@export var corner_length: float = 12.0
@export var center_dot_radius: float = 4.0
@export var edge_arrow_size: float = 20.0

# === 颜色 ===
var color_locked: Color = Color.YELLOW
var color_unlocked: Color = Color.RED

# === 内部变量 ===
var camera: Camera3D = null
var current_target: Node3D = null
var is_locked: bool = false
var enemies_in_range: Array = []
var current_enemy_index: int = 0
var missile_spawn_points: Array = []  # 左右挂载点
var next_spawn_index: int = 0         # 交替发射

# 导弹场景
var missile_agm_template = preload("res://example/scenes/Missile/MissileAGM.tscn")
var missile_aam_template = preload("res://example/scenes/Missile/MissileAAM.tscn")

# 音效
var sound_generator: SoundGenerator = null
var was_locked: bool = false

# 武器模式引用
var combat_hud = null

func _ready():
	z_index = 100
	anchor_right = 1.0
	anchor_bottom = 1.0
	offset_right = 0
	offset_bottom = 0
	
	sound_generator = SoundGenerator.new()
	add_child(sound_generator)

func _process(delta):
	update_enemies_in_range()
	
	if is_locked and not was_locked:
		sound_generator.play_lock_sound()
	elif not is_locked and was_locked:
		sound_generator.play_unlock_sound()
	was_locked = is_locked
	
	queue_redraw()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			switch_target(-1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			switch_target(1)

## 获取当前目标分组
func _get_target_group() -> String:
	if combat_hud and combat_hud.has_method("get_target_group"):
		return combat_hud.get_target_group()
	return "enemy"

## 更新范围内的敌人列表
func update_enemies_in_range():
	if camera == null:
		enemies_in_range.clear()
		current_target = null
		is_locked = false
		return
	
	# 获取玩家飞机的前方向
	var aircraft_forward = _get_aircraft_forward()
	
	var target_group = _get_target_group()
	var all_enemies = get_tree().get_nodes_in_group(target_group)
	
	enemies_in_range.clear()
	for enemy in all_enemies:
		if not is_instance_valid(enemy):
			continue
		var distance = camera.global_position.distance_to(enemy.global_position)
		if distance > lock_distance:
			continue
		# 检查是否在机头前方锁定角度内
		if aircraft_forward != Vector3.ZERO:
			var to_enemy = (enemy.global_position - camera.global_position).normalized()
			var angle = rad_to_deg(aircraft_forward.angle_to(to_enemy))
			if angle > lock_angle:
				continue
		enemies_in_range.append(enemy)
	
	enemies_in_range.sort_custom(func(a, b):
		var dist_a = camera.global_position.distance_to(a.global_position)
		var dist_b = camera.global_position.distance_to(b.global_position)
		return dist_a < dist_b
	)
	
	if enemies_in_range.size() > 0:
		if current_enemy_index >= enemies_in_range.size():
			current_enemy_index = 0
		elif current_enemy_index < 0:
			current_enemy_index = enemies_in_range.size() - 1
		current_target = enemies_in_range[current_enemy_index]
		is_locked = true
	else:
		current_target = null
		is_locked = false
		current_enemy_index = 0

## 获取玩家飞机前方向
func _get_aircraft_forward() -> Vector3:
	var main_scene = get_tree().current_scene
	if main_scene and main_scene.has_node("Aircraft"):
		var aircraft = main_scene.get_node("Aircraft")
		if is_instance_valid(aircraft):
			return -aircraft.global_transform.basis.z
	return Vector3.ZERO

## 滚轮切换目标
func switch_target(direction: int):
	if enemies_in_range.size() <= 1:
		return
	current_enemy_index += direction
	if current_enemy_index >= enemies_in_range.size():
		current_enemy_index = 0
	elif current_enemy_index < 0:
		current_enemy_index = enemies_in_range.size() - 1
	current_target = enemies_in_range[current_enemy_index]
	sound_generator.play_switch_sound()

## ==================== 绘制 ====================
func _draw():
	# 始终绘制机头锁定范围指示
	_draw_lock_cone_indicator()
	
	if not is_locked or current_target == null or camera == null or not is_instance_valid(current_target):
		return
	
	var screen_pos = camera.unproject_position(current_target.global_position)
	var screen_size = get_viewport().get_visible_rect().size
	var margin = edge_arrow_size + 10
	var is_on_screen = screen_pos.x > margin and screen_pos.x < screen_size.x - margin \
		and screen_pos.y > margin and screen_pos.y < screen_size.y - margin
	
	var draw_color = color_locked if is_locked else color_unlocked
	
	if is_on_screen:
		draw_lock_box(screen_pos, draw_color)
		draw_center_dot(screen_pos, draw_color)
		draw_target_info(screen_pos, draw_color)
	else:
		draw_edge_arrow(screen_pos, draw_color)

## 绘制棱角方框
func draw_lock_box(pos: Vector2, color: Color):
	var half_size = box_size / 2
	var corners = [
		Vector2(pos.x - half_size, pos.y - half_size),
		Vector2(pos.x + half_size, pos.y - half_size),
		Vector2(pos.x + half_size, pos.y + half_size),
		Vector2(pos.x - half_size, pos.y + half_size)
	]
	# 发光
	var glow_color = Color(color.r, color.g, color.b, 0.3)
	for i in range(4):
		var corner = corners[i]
		var next_corner = corners[(i + 1) % 4]
		draw_line(corner, next_corner, glow_color, 4.0)
	# 棱角
	for i in range(4):
		var corner = corners[i]
		var next_corner = corners[(i + 1) % 4]
		var prev_corner = corners[(i - 1 + 4) % 4]
		var dir_to_next = (next_corner - corner).normalized()
		var dir_to_prev = (prev_corner - corner).normalized()
		draw_line(corner, corner + dir_to_next * corner_length, color, 2.0)
		draw_line(corner, corner + dir_to_prev * corner_length, color, 2.0)

## 绘制中心圆点
func draw_center_dot(pos: Vector2, color: Color):
	var glow_color = Color(color.r, color.g, color.b, 0.5)
	draw_circle(pos, center_dot_radius + 2, glow_color)
	draw_circle(pos, center_dot_radius, color)

## 绘制目标信息
func draw_target_info(pos: Vector2, color: Color):
	var font = get_theme_default_font()
	var font_size = 14
	var text = str(current_enemy_index + 1) + "/" + str(enemies_in_range.size())
	var text_pos = Vector2(pos.x - 20, pos.y - box_size / 2 - 20)
	var bg_rect = Rect2(text_pos - Vector2(5, 2), Vector2(40, 18) + Vector2(10, 4))
	draw_rect(bg_rect, Color(0, 0, 0, 0.5))
	draw_string(font, text_pos, text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, color)
	
	# 距离显示
	if camera and current_target:
		var dist = camera.global_position.distance_to(current_target.global_position)
		var dist_text = "%dm" % int(dist)
		var dist_pos = Vector2(pos.x - 20, pos.y + box_size / 2 + 18)
		draw_string(font, dist_pos, dist_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, color)

## 绘制边缘箭头
func draw_edge_arrow(pos: Vector2, color: Color):
	var screen_size = get_viewport().get_visible_rect().size
	var screen_center = screen_size / 2
	var direction = (pos - screen_center).normalized()
	var edge_pos = _calculate_edge_position(direction)
	
	var arrow_length = edge_arrow_size
	var arrow_width = edge_arrow_size / 2
	var tip = edge_pos + direction * arrow_length / 2
	var base = edge_pos - direction * arrow_length / 2
	var perpendicular = Vector2(-direction.y, direction.x)
	var left = base + perpendicular * arrow_width / 2
	var right = base - perpendicular * arrow_width / 2
	var points = PackedVector2Array([tip, left, right])
	draw_colored_polygon(points, color)
	
	var font = get_theme_default_font()
	var font_size = 14
	var text = str(current_enemy_index + 1) + "/" + str(enemies_in_range.size())
	draw_string(font, edge_pos + Vector2(0, 25), text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, color)

func _calculate_edge_position(direction: Vector2) -> Vector2:
	var screen_size = get_viewport().get_visible_rect().size
	var margin = edge_arrow_size + 10
	var half_width = screen_size.x / 2 - margin
	var half_height = screen_size.y / 2 - margin
	var screen_center = screen_size / 2
	if abs(direction.x) > abs(direction.y):
		var x = half_width if direction.x > 0 else -half_width
		var y = direction.y / direction.x * x
		return screen_center + Vector2(x, y)
	else:
		var y = half_height if direction.y > 0 else -half_height
		var x = direction.x / direction.y * y
		return screen_center + Vector2(x, y)

## 绘制机头前方锁定范围指示（屏幕中心的圆圈）
func _draw_lock_cone_indicator():
	if camera == null or not is_instance_valid(camera):
		return
	var screen_size = get_viewport().get_visible_rect().size
	var center = screen_size / 2
	
	# 根据lock_angle计算屏幕上的圆圈半径
	# lock_angle对应屏幕上FOV的比例
	if camera == null:
		return
	var fov_h = camera.fov  # 水平FOV
	var cone_ratio = lock_angle / (fov_h / 2.0)
	var radius = center.x * cone_ratio
	
	# 绘制虚线圆圈
	var segments = 36
	var gap_ratio = 0.4  # 虚线间隔比例
	var indicator_color = Color(0.5, 0.5, 0.5, 0.4) if not is_locked else Color(0.8, 0.8, 0.2, 0.5)
	
	for i in range(segments):
		if i % 2 == 1:
			continue  # 跳过间隔段
		var angle_start = (float(i) / segments) * TAU
		var angle_end = (float(i) + gap_ratio * 2.0) / segments * TAU
		var p1 = center + Vector2(cos(angle_start), sin(angle_start)) * radius
		var p2 = center + Vector2(cos(angle_end), sin(angle_end)) * radius
		draw_line(p1, p2, indicator_color, 1.5)
	
	# 中心十字线
	var cross_size = 8.0
	draw_line(center - Vector2(cross_size, 0), center + Vector2(cross_size, 0), indicator_color, 1.0)
	draw_line(center - Vector2(0, cross_size), center + Vector2(0, cross_size), indicator_color, 1.0)

## ==================== 导弹发射 ====================
func fire_missile():
	if not is_locked or current_target == null or not is_instance_valid(current_target):
		print("未锁定目标，无法发射")
		return
	
	if missile_spawn_points.size() == 0:
		print("无导弹挂载点")
		return
	
	# 检查挂载点是否有效
	var spawn_point = missile_spawn_points[next_spawn_index % missile_spawn_points.size()]
	next_spawn_index += 1
	if not is_instance_valid(spawn_point):
		print("挂载点无效")
		return
	
	sound_generator.play_missile_launch_sound()
	
	# 选择导弹类型
	var is_agm = false
	if combat_hud and combat_hud.has_method("get_weapon_mode"):
		is_agm = combat_hud.get_weapon_mode() == 0  # 0 = AGM
	
	var template = missile_agm_template if is_agm else missile_aam_template
	var missile = template.instantiate()
	get_tree().current_scene.add_child(missile)
	
	missile.global_position = spawn_point.global_position
	missile.global_transform.basis = spawn_point.global_transform.basis
	missile.set_target(current_target)
	
	# 碰撞例外
	var aircraft_node = spawn_point.get_parent()
	if is_instance_valid(aircraft_node):
		missile.add_collision_exception_with(aircraft_node)
	
	print("发射%s -> %s" % ["AGM" if is_agm else "AAM", current_target.name])

## ==================== 设置接口 ====================
func set_camera(cam: Camera3D):
	camera = cam

func set_missile_spawn_point(point: Marker3D):
	missile_spawn_points.append(point)

func set_combat_hud(hud):
	combat_hud = hud

func get_locked_target() -> Node3D:
	return current_target if is_locked else null

func is_target_locked() -> bool:
	return is_locked
