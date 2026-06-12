extends CharacterBody3D
class_name GuidedMissile

## 导弹 — 追踪目标飞行（AGM/AAM共用）

# === 可调参数 ===
@export var speed: float = 100.0                   # 导弹速度
@export var max_turn_rate: float = 720.0             # 转弯速率（AAM极高，百分百跟踪）
@export var max_flight_time: float = 10.0
@export var explosion_radius: float = 20.0           # 爆炸范围
@export var explosion_damage_agm: float = 200.0      # AGM伤害
@export var explosion_damage_aam: float = 300.0      # AAM伤害（一发秒杀200血敌机）
@export var missile_type: String = "aam"  # "aam" 或 "agm"

# === 内部变量 ===
var target: Node3D = null
var flight_time: float = 0.0
var is_exploding: bool = false
var invincible_time: float = 0.3

# 爆炸效果
var explosion_template = preload("res://example/scenes/Explosion/Explosion.tscn")

# 尾迹粒子
var trail_particles: CPUParticles3D = null

func _ready():
	collision_layer = 4
	collision_mask = 3
	_setup_trail()

func _setup_trail():
	# 创建尾迹粒子
	trail_particles = CPUParticles3D.new()
	trail_particles.name = "Trail"
	trail_particles.emitting = true
	trail_particles.amount = 20
	trail_particles.lifetime = 0.5
	trail_particles.one_shot = false
	trail_particles.explosiveness = 0.0
	trail_particles.randomness = 0.3
	
	# 粒子材质
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.6, 0.1, 0.8)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.4, 0.0)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	var mesh = SphereMesh.new()
	mesh.radius = 0.15
	mesh.height = 0.3
	mesh.material = mat
	
	trail_particles.mesh = mesh
	trail_particles.direction = Vector3(0, 0, 1)  # 向后喷射
	trail_particles.spread = 15.0
	trail_particles.initial_velocity_min = 5.0
	trail_particles.initial_velocity_max = 10.0
	trail_particles.gravity = Vector3.ZERO
	trail_particles.scale_amount_min = 0.5
	trail_particles.scale_amount_max = 1.0
	
	add_child(trail_particles)

func _physics_process(delta):
	if is_exploding:
		return
	
	flight_time += delta
	if flight_time >= max_flight_time:
		explode()
		return
	
	# 追踪目标
	if is_instance_valid(target):
		var to_target = target.global_position - global_position
		var target_direction = to_target.normalized()
		
		# AAM: 极强追踪，几乎不可能逃脱
		# AGM: 稍弱的追踪（对地目标不需要那么强）
		var turn_speed = max_turn_rate
		if missile_type == "agm":
			turn_speed = max_turn_rate * 0.4  # AGM转弯慢一些
		
		# AAM直接锁定方向，不插值，百分百跟踪
		if missile_type == "aam":
			velocity = target_direction * speed
			look_at(global_position + target_direction, Vector3.UP)
		else:
			# AGM平滑转向
			var current_dir = -global_transform.basis.z
			var new_dir = current_dir.lerp(target_direction, turn_speed * delta / 360.0).normalized()
			velocity = new_dir * speed
			look_at(global_position + new_dir, Vector3.UP)
	else:
		# 目标丢失，继续直线飞行
		velocity = -global_transform.basis.z * speed
	
	move_and_slide()
	
	if flight_time < invincible_time:
		return
	
	# 检查命中
	_check_hit()

func _check_hit():
	# 距离检测（AAM判定更宽）
	var target_group = "enemy_ground" if missile_type == "agm" else "enemy_air"
	var hit_distance = 8.0 if missile_type == "aam" else 5.0
	var enemies = get_tree().get_nodes_in_group(target_group)
	for enemy in enemies:
		if is_instance_valid(enemy):
			var distance = global_position.distance_to(enemy.global_position)
			if distance < hit_distance:
				explode()
				return
	
	# 也检查通用enemy组
	var all_enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in all_enemies:
		if is_instance_valid(enemy):
			var distance = global_position.distance_to(enemy.global_position)
			if distance < hit_distance:
				explode()
				return
	
	# 碰撞检测
	if get_slide_collision_count() > 0:
		explode()

## 爆炸
func explode():
	if is_exploding:
		return
	is_exploding = true
	
	# 爆炸效果
	var explosion = explosion_template.instantiate()
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = global_position
	if explosion.has_method("explode"):
		explosion.explode()
	
	# 溅射伤害（按导弹类型）
	var actual_explosion_damage = explosion_damage_aam if missile_type == "aam" else explosion_damage_agm
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if is_instance_valid(enemy):
			var distance = global_position.distance_to(enemy.global_position)
			if distance <= explosion_radius:
				var damage_factor = 1.0 - (distance / explosion_radius)
				var actual_damage = actual_explosion_damage * damage_factor
				if enemy.has_method("take_damage"):
					enemy.take_damage(actual_damage)
	
	# 播放爆炸音效
	_play_explosion_sound()
	
	queue_free()

func _play_explosion_sound():
	var temp_player = AudioStreamPlayer.new()
	temp_player.volume_db = -5
	get_tree().current_scene.add_child(temp_player)
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = 22050
	generator.buffer_length = 0.3
	temp_player.stream = generator
	temp_player.play()
	var playback = temp_player.get_stream_playback()
	var sample_rate = 22050
	var duration = 0.25
	var samples_needed = int(duration * sample_rate)
	for i in range(samples_needed):
		var t = float(i) / sample_rate
		var noise = randf_range(-1.0, 1.0) * 0.4
		var bass = sin(2.0 * PI * 100.0 * t) * 0.3
		var value = noise + bass
		var fade = 1.0
		if i < samples_needed * 0.05:
			fade = float(i) / (samples_needed * 0.05)
		elif i > samples_needed * 0.5:
			fade = (samples_needed - float(i)) / (samples_needed * 0.5)
		value *= fade
		playback.push_frame(Vector2(value, value))
	await get_tree().create_timer(0.5).timeout
	temp_player.queue_free()

## 设置目标
func set_target(new_target: Node3D):
	target = new_target
	if is_instance_valid(target):
		look_at(target.global_position, Vector3.UP)
		var to_target = target.global_position - global_position
		velocity = to_target.normalized() * speed
