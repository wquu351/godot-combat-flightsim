extends CharacterBody3D
class_name GroundEnemy

## 地面小兵 - 在地面上随机走动的靶子敌人

# === 可调参数 ===
@export var max_health: float = 100.0        # 最大血量
@export var move_speed: float = 2.0          # 移动速度
@export var wander_radius: float = 30.0      # 游走范围半径（从出生点）
@export var direction_change_min: float = 2.0  # 方向改变最小间隔
@export var direction_change_max: float = 4.0  # 方向改变最大间隔

# === 内部变量 ===
var current_health: float
var spawn_position: Vector3                   # 出生位置
var target_direction: Vector3                 # 目标移动方向
var direction_change_timer: float = 0.0       # 方向改变计时器
var next_direction_change_time: float         # 下次改变方向的时间

# 爆炸效果预加载
var explosion_template = preload("res://example/scenes/Explosion/Explosion.tscn")

# 重力
const GRAVITY = 9.8

func _ready():
	# 加入敌人分组
	add_to_group("enemy")
	add_to_group("enemy_ground")
	
	# 设置碰撞层（敌人在第2层）
	collision_layer = 2
	collision_mask = 1  # 只检测世界
	
	# 初始化血量
	current_health = max_health
	
	# 记录出生位置
	spawn_position = global_position
	
	# 初始化方向
	choose_new_direction()
	
	# 设置下次改变方向的时间
	next_direction_change_time = randf_range(direction_change_min, direction_change_max)

func _physics_process(delta):
	# 应用重力
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0
	
	# 方向改变计时
	direction_change_timer += delta
	if direction_change_timer >= next_direction_change_time:
		choose_new_direction()
		direction_change_timer = 0.0
		next_direction_change_time = randf_range(direction_change_min, direction_change_max)
	
	# 检查是否超出范围
	var distance_from_spawn = global_position.distance_to(spawn_position)
	if distance_from_spawn > wander_radius:
		# 超出范围，转向回出生点
		target_direction = (spawn_position - global_position).normalized()
		target_direction.y = 0
		target_direction = target_direction.normalized()
	
	# 移动
	velocity.x = target_direction.x * move_speed
	velocity.z = target_direction.z * move_speed
	
	# 碰撞检测 - 碰到障碍物转向
	var collision = move_and_slide()
	if collision:
		# 碰到障碍物，随机转向
		choose_new_direction()
	
	# 朝向移动方向（仅水平旋转）
	if target_direction.length() > 0.1:
		var look_target = global_position + target_direction
		look_at(look_target, Vector3.UP)

## 选择新的移动方向
func choose_new_direction():
	# 随机选择一个水平方向
	var angle = randf_range(0, TAU)
	target_direction = Vector3(cos(angle), 0, sin(angle))

## 受到伤害
func take_damage(damage: float):
	current_health -= damage
	
	# 血量为0时死亡
	if current_health <= 0:
		die()

## 死亡 - 播放爆炸效果并消失
func die():
	# 创建爆炸效果
	var explosion = explosion_template.instantiate()
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = global_position
	if explosion.has_method("explode"):
		explosion.explode()
	
	# 移除自己
	queue_free()