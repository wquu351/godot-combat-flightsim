extends Node3D

## 主场景 — 完整空战系统
## 包含：加力模式、武器切换、空中敌人AI、锁定系统、导弹系统、玩家血量

# === 刷怪系统参数 ===
@export var spawn_interval: float = 5.0
@export var max_ground_enemies: int = 8
@export var spawn_radius: float = 50.0

# === 空中敌人参数 ===
@export var air_enemy_count: int = 3                 # 同时存在的敌机数量
@export var air_enemy_respawn_delay: float = 8.0
@export var air_enemy_spawn_height: float = 150.0
@export var air_enemy_spawn_distance: float = 400.0  # 生成距离（远一点避免出生即被攻击）

# === 预加载场景 ===
var template_explosion = preload("res://example/scenes/Explosion/Explosion.tscn")
var template_ground_enemy = preload("res://example/scenes/GroundEnemy/ground_enemy.tscn")
var template_air_enemy = preload("res://example/scenes/AirEnemy/air_enemy.tscn")
var template_lock_ui = preload("res://example/scenes/LockUI/lock_ui.tscn")
var template_combat_hud = preload("res://example/scenes/CombatHUD/CombatHUD.tscn")
var template_aircraft_model = preload("res://example/scenes/Airplane/Airplan2Model.tscn")
var template_main_menu = preload("res://example/scenes/MainMenu/main_menu.gd")

# === 内部变量 ===
@onready var aircraft = get_node("Aircraft")
var is_reloading_fuel: bool = false
var spawn_timer: float = 0.0

# 系统引用
var lock_ui: Control = null
var combat_hud: Control = null
var main_camera: Camera3D = null

# 导弹挂载点（左右各一个）
var missile_spawn_left: Marker3D = null
var missile_spawn_right: Marker3D = null

# 空中敌人管理
var air_respawn_timer: float = 0.0

# 玩家血量
var player_health: float = 100.0
var player_max_health: float = 100.0
var player_min_health: float = 1.0  # 最低1血，空中敌人打不死

# 加力模式
var is_afterburner: bool = false
var normal_engine_power: float = 1.0
var normal_power_factor: float = 20.0  # 保存原始PowerFactor
var afterburner_power_factor: float = 60.0  # 3倍推力

func _ready():
	# 连接飞机事件
	aircraft.connect("crashed", Callable(self, "_on_Aircraft_crashed"))
	aircraft.connect("parked", Callable(self, "_on_Aircraft_parked"))
	aircraft.connect("moved", Callable(self, "_on_Aircraft_moved"))
	
	$Aircraft/Engine.connect("update_interface", Callable($Aircraft/Model/MovingParts/Engine, "_on_Engine_update_interface"))
	$Aircraft/Steering.connect("update_interface", Callable($Aircraft/Model/MovingParts/Steering, "_on_Steering_update_interface"))
	$Aircraft/Flaps.connect("update_interface", Callable($Aircraft/Model/MovingParts/Flaps, "_on_Flaps_update_interface"))
	$Aircraft/LandingGear.connect("update_interface", Callable($Aircraft/Model/MovingParts/LandingGear, "_on_LandingGear_update_interface"))
	
	# 替换飞机模型
	replace_aircraft_model()
	
	# 创建主菜单（添加到Viewport层级确保全屏覆盖）
	var main_menu = template_main_menu.new()
	get_viewport().add_child.call_deferred(main_menu)
	
	# 创建导弹挂载点
	create_missile_spawn_points()
	
	# 获取主相机
	main_camera = get_main_camera()
	
	# 创建战斗HUD（武器模式+血量）
	create_combat_hud()
	
	# 创建锁定UI
	create_lock_ui()
	
	# 将玩家飞机加入分组
	aircraft.add_to_group("aircraft")
	
	# 生成初始空中敌人（3架）
	for i in range(air_enemy_count):
		spawn_air_enemy()
		await get_tree().create_timer(0.5).timeout  # 错开生成时间避免重叠
	
	# 保存引擎原始PowerFactor
	_save_engine_power_factor()

func replace_aircraft_model():
	var static_parts = aircraft.get_node_or_null("Model/StaticParts")
	if static_parts:
		static_parts.queue_free()
	var new_model = template_aircraft_model.instantiate()
	aircraft.get_node("Model").add_child(new_model)

func _save_engine_power_factor():
	for child in aircraft.get_children():
		if child is AircraftModule_Engine:
			normal_power_factor = child.PowerFactor
			afterburner_power_factor = normal_power_factor * 3.0
			break

func create_missile_spawn_points():
	# 左翼挂载点
	missile_spawn_left = Marker3D.new()
	missile_spawn_left.name = "MissileSpawnLeft"
	missile_spawn_left.position = Vector3(-3, 0, 0)
	aircraft.add_child(missile_spawn_left)
	
	# 右翼挂载点
	missile_spawn_right = Marker3D.new()
	missile_spawn_right.name = "MissileSpawnRight"
	missile_spawn_right.position = Vector3(3, 0, 0)
	aircraft.add_child(missile_spawn_right)

func create_combat_hud():
	combat_hud = template_combat_hud.instantiate()
	add_child(combat_hud)

func create_lock_ui():
	lock_ui = template_lock_ui.instantiate()
	add_child(lock_ui)
	
	if main_camera:
		lock_ui.set_camera(main_camera)
	if missile_spawn_left:
		lock_ui.set_missile_spawn_point(missile_spawn_left)
	if missile_spawn_right:
		lock_ui.set_missile_spawn_point(missile_spawn_right)
	if combat_hud:
		lock_ui.set_combat_hud(combat_hud)

func get_main_camera() -> Camera3D:
	var camera_tripod = get_node_or_null("CameraTripod")
	if camera_tripod and camera_tripod.has_node("Camera3D"):
		return camera_tripod.get_node("Camera3D")
	var cameras = get_tree().get_nodes_in_group("camera")
	if cameras.size() > 0:
		return cameras[0]
	for child in get_children():
		if child is Camera3D:
			return child
		for subchild in child.get_children():
			if subchild is Camera3D:
				return subchild
	return null

func _physics_process(delta):
	# 菜单未关闭时跳过游戏逻辑
	if get_tree().has_meta("game_started") and not get_tree().get_meta("game_started"):
		return
	
	# 飞机已销毁则跳过
	if not is_instance_valid(aircraft):
		return
	
	# === 地面敌人刷怪 ===
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		spawn_ground_enemy()
	
	# === 加油逻辑 ===
	if is_reloading_fuel and is_instance_valid(aircraft):
		var is_full = aircraft.load_energy("fuel", 5.0 * delta)
		if is_full:
			is_reloading_fuel = false
	
	# === 加力模式 ===
	_process_afterburner(delta)
	
	# === 空中敌人管理 ===
	_manage_air_enemy(delta)
	
	# === 导弹发射 ===
	if Input.is_action_just_pressed("fire_missile"):
		fire_missile()

# ================================================================
#  加力模式 — 3倍推力 + FOV效果
# ================================================================
func _process_afterburner(delta):
	is_afterburner = Input.is_key_pressed(KEY_SHIFT)
	
	# 找到引擎模块
	var engine_module = null
	for child in aircraft.get_children():
		if child is AircraftModule_Engine:
			engine_module = child
			break
	
	if engine_module and engine_module.is_engine_working:
		if is_afterburner:
			# 加力：功率拉满 + 3倍推力
			engine_module.engine_set_power(1.0)
			engine_module.PowerFactor = afterburner_power_factor
		else:
			# 恢复正常推力
			engine_module.PowerFactor = normal_power_factor
	
	# FOV效果 — 加力时大幅增加产生速度感
	if main_camera:
		var target_fov = 100.0 if is_afterburner else 70.0
		main_camera.fov = lerp(main_camera.fov, target_fov, 4.0 * delta)

# ================================================================
#  空中敌人管理
# ================================================================
func _manage_air_enemy(delta):
	var air_enemies = get_tree().get_nodes_in_group("enemy_air")
	var current_count = air_enemies.size()
	
	if current_count < air_enemy_count:
		air_respawn_timer += delta
		if air_respawn_timer >= air_enemy_respawn_delay:
			air_respawn_timer = 0.0
			spawn_air_enemy()
	else:
		air_respawn_timer = 0.0

func spawn_air_enemy():
	var enemy = template_air_enemy.instantiate()
	add_child(enemy)
	
	# 在玩家前方上方生成，带随机偏移避免重叠
	var spawn_pos = Vector3(0, air_enemy_spawn_height, 0)
	if is_instance_valid(aircraft):
		var forward = -aircraft.global_transform.basis.z
		var right = aircraft.global_transform.basis.x
		var dist_offset = randf_range(-100.0, 100.0)
		var side_offset = randf_range(-150.0, 150.0)
		spawn_pos = aircraft.global_position + forward * (air_enemy_spawn_distance + dist_offset) + right * side_offset + Vector3(0, air_enemy_spawn_height + randf_range(-30, 30), 0)
	else:
		var spawn_point = get_node_or_null("Scenario/EnemySpawnPoint")
		if spawn_point:
			spawn_pos = spawn_point.global_position + Vector3(randf_range(-200, 200), air_enemy_spawn_height, randf_range(-200, 200))
	
	enemy.global_position = spawn_pos
	print("生成空中敌人: ", spawn_pos, " 当前数量: ", get_tree().get_nodes_in_group("enemy_air").size())

# ================================================================
#  地面敌人刷怪
# ================================================================
func spawn_ground_enemy():
	var enemies = get_tree().get_nodes_in_group("enemy_ground")
	if enemies.size() >= max_ground_enemies:
		return
	
	var enemy = template_ground_enemy.instantiate()
	add_child(enemy)
	
	var spawn_center = get_spawn_center()
	var random_offset = Vector3(
		randf_range(-spawn_radius, spawn_radius),
		0,
		randf_range(-spawn_radius, spawn_radius)
	)
	enemy.global_position = spawn_center + random_offset

func get_spawn_center() -> Vector3:
	var spawn_point = get_node_or_null("Scenario/EnemySpawnPoint")
	if spawn_point:
		return spawn_point.global_position
	return Vector3(0, 1, 0)

# ================================================================
#  导弹发射
# ================================================================
func fire_missile():
	if lock_ui and lock_ui.has_method("fire_missile"):
		lock_ui.fire_missile()

# ================================================================
#  玩家受伤（空中敌人调用）
# ================================================================
func take_damage(amount: float):
	player_health = max(player_min_health, player_health - amount)
	# 同步到CombatHUD
	if combat_hud and combat_hud.has_method("take_damage"):
		combat_hud.take_damage(amount)

## 获取玩家血量
func get_health() -> float:
	return player_health

# ================================================================
#  飞机事件
# ================================================================
func _on_Aircraft_crashed(_impact_velocity):
	var crash_pos = aircraft.global_transform.origin
	var new_explosion = template_explosion.instantiate()
	add_child(new_explosion)
	new_explosion.global_transform.origin = crash_pos
	new_explosion.explode()
	aircraft.queue_free()
	aircraft = null  # 立即置空，防止后续访问已释放节点
	await get_tree().create_timer(2.0).timeout
	var __ = get_tree().reload_current_scene()

func _on_Aircraft_parked():
	if is_instance_valid(aircraft) and $FuelArea.overlaps_body(aircraft):
		is_reloading_fuel = true

func _on_Aircraft_moved():
	if is_reloading_fuel:
		is_reloading_fuel = false
