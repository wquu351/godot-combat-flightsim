extends CharacterBody3D
class_name AirEnemy

## 空中敌人 — 歼-20 AI
## 核心原则：攻击后沿当前方向直线飞走，绝不跟随玩家转弯

# === 可调参数 ===
@export var fly_speed: float = 18.0               # 巡航速度
@export var max_speed: float = 32.0                # 最大速度
@export var turn_rate: float = 0.5                 # 转弯速率
@export var gun_range: float = 220.0               # 机枪射程
@export var gun_angle: float = 12.0                # 攻击角度(度)
@export var gun_damage: float = 1.2                # 每发伤害
@export var gun_fire_interval: float = 0.25        # 射击间隔
@export var max_health: float = 200.0              # 血量
@export var fly_away_distance: float = 500.0       # 攻击后必须飞走的距离

# === 状态机 ===
enum State { IDLE, APPROACH, ATTACK, STRAIGHT_FLY, TURN_AROUND }
var current_state: State = State.IDLE

# === 内部变量 ===
var current_health: float
var player: Node3D = null
var gun_timer: float = 0.0
var spawn_protection: float = 4.0
var state_timer: float = 0.0
var approach_side: float = 1.0
var straight_fly_dir: Vector3        # 直线飞行的方向（固定！）
var straight_fly_start_pos: Vector3  # 直线飞行的起点
var has_attacked_in_pass: bool = false  # 本轮冲刺是否已开火

# 预加载
var explosion_template = preload("res://example/scenes/Explosion/Explosion.tscn")
var bullet_template = preload("res://example/scenes/AirEnemy/bullet.tscn")

func _ready():
	add_to_group("enemy")
	add_to_group("enemy_air")
	current_health = max_health
	_find_player()
	approach_side = randf_range(-1.0, 1.0)
	state_timer = randf_range(0.0, 2.0)

func _find_player():
	var aircrafts = get_tree().get_nodes_in_group("aircraft")
	if aircrafts.size() > 0:
		player = aircrafts[0]
		return
	var root = get_tree().current_scene
	if root and root.has_node("Aircraft"):
		player = root.get_node("Aircraft")

func _physics_process(delta):
	if not is_instance_valid(player):
		_find_player()
		if not player:
			return
	
	if spawn_protection > 0:
		spawn_protection -= delta
	
	_state_machine(delta)
	move_and_slide()

func _state_machine(delta):
	state_timer += delta
	
	match current_state:
		State.IDLE:
			_state_idle()
		
		State.APPROACH:
			_state_approach()
		
		State.ATTACK:
			_state_attack(delta)
		
		State.STRAIGHT_FLY:
			_state_straight_fly()
		
		State.TURN_AROUND:
			_state_turn_around()

## 空闲：等待开始
func _state_idle():
	var dist = global_position.distance_to(player.global_position) if player else 9999
	if dist < 300.0 or state_timer > 2.0:
		_change_state(State.APPROACH)
	velocity = -global_transform.basis.z * fly_speed * 0.5

## 接近：从侧面靠近玩家
func _state_approach():
	if not is_instance_valid(player):
		return
	
	var to_player = player.global_position - global_position
	var dist = to_player.length()
	var dir_to_player = to_player.normalized()
	
	# 检测是否在玩家后方 → 直接去转弯状态
	var player_fwd = -player.global_transform.basis.z
	var my_fwd = -global_transform.basis.z
	if my_fwd.dot(player_fwd) < -0.15 and dist < 300.0:
		_start_straight_fly()
		return
	
	# 从侧前方接近
	var perpendicular = dir_to_player.cross(Vector3.UP).normalized()
	var target = (dir_to_player + perpendicular * approach_side * 0.6).normalized()
	_smooth_turn(target)
	velocity = -global_transform.basis.z * fly_speed
	
	# 足够近且在前方 → 冲刺攻击
	if dist < 170.0 and my_fwd.dot(dir_to_player) > 0.5:
		has_attacked_in_pass = false
		_change_state(State.ATTACK)

## 攻击：直线冲刺穿过玩家
func _state_attack(delta):
	if not is_instance_valid(player):
		_start_straight_fly()
		return
	
	var to_player = player.global_position - global_position
	var dist = to_player.length()
	var dir_to_player = to_player.normalized()
	
	# 保持冲向玩家
	_smooth_turn(dir_to_player)
	velocity = -global_transform.basis.z * max_speed
	
	# 开火
	_check_gun_attack(delta, dir_to_player, dist)
	has_attacked_in_pass = true
	
	# 冲过或太近 → 进入直线飞离
	if dist < 20.0:
		_start_straight_fly()

## 直线飞离：关键！沿当前方向直飞，不转向，不管玩家在哪
func _state_straight_fly():
	# 完全不转向！保持straight_fly_dir方向
	look_at(global_position + straight_fly_dir, Vector3.UP)
	velocity = straight_fly_dir * max_speed * 1.15
	
	# 飞够距离了没？
	var flown = global_position.distance_to(straight_fly_start_pos)
	if flown >= fly_away_distance or state_timer > 7.0:
		_change_state(State.TURN_AROUND)

## 大转弯调头
func _state_turn_around():
	if not is_instance_valid(player):
		_change_state(State.APPROACH)
		return
	
	var to_player = player.global_position - global_position
	var target = to_player.normalized()
	_smooth_turn(target)
	velocity = -global_transform.basis.z * fly_speed * 0.7
	
	# 基本对准了 → 回到接近
	var dot = (-global_transform.basis.z).dot(target)
	if dot > 0.8 or state_timer > 4.0:
		approach_side *= -1  # 换边
		_change_state(State.APPROACH)

## 开始直线飞离：锁定当前前进方向
func _start_straight_fly():
	straight_fly_dir = -global_transform.basis.z  # 锁定当前方向！
	straight_fly_start_pos = global_position       # 记录起点
	_change_state(State.STRAIGHT_FLY)

## 平滑转向
func _smooth_turn(target_dir: Vector3):
	var fwd = -global_transform.basis.z
	var new_fwd = fwd.lerp(target_dir, turn_rate * get_physics_process_delta_time()).normalized()
	look_at(global_position + new_fwd, Vector3.UP)

func _change_state(s: State):
	current_state = s
	state_timer = 0.0

## 机枪
func _check_gun_attack(delta, dir_to_player: Vector3, dist: float):
	gun_timer -= delta
	if spawn_protection > 0 or dist > gun_range:
		return
	var angle = rad_to_deg((-global_transform.basis.z).angle_to(dir_to_player))
	if angle > gun_angle:
		return
	if gun_timer <= 0:
		gun_timer = gun_fire_interval
		_fire_gun()

func _fire_gun():
	if bullet_template:
		var b = bullet_template.instantiate()
		get_tree().current_scene.add_child(b)
		b.global_position = global_position - global_transform.basis.z * 3.0
		b.setup(-global_transform.basis.z, 170.0, gun_damage)

func take_damage(damage: float):
	current_health -= damage
	if current_health <= 0:
		die()

func die():
	var ex = explosion_template.instantiate()
	get_tree().current_scene.add_child(ex)
	ex.global_position = global_position
	if ex.has_method("explode"):
		ex.explode()
	queue_free()
