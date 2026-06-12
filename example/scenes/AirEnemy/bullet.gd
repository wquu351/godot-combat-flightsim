extends CharacterBody3D

## 空中敌人子弹 — 简单的高速弹丸

var direction: Vector3 = Vector3.FORWARD
var speed: float = 200.0
var damage: float = 5.0
var lifetime: float = 3.0

func _ready():
	collision_layer = 0
	collision_mask = 0

func setup(dir: Vector3, spd: float, dmg: float):
	direction = dir
	speed = spd
	damage = dmg
	look_at(global_position + direction, Vector3.UP)

func _physics_process(delta):
	velocity = direction * speed
	move_and_slide()
	
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
		return
	
	# 检查是否命中玩家 — 对主场景调take_damage
	var main_scene = get_tree().current_scene
	if main_scene and main_scene.has_method("take_damage"):
		# 检查与玩家飞机的距离
		var player_aircraft = null
		if main_scene.has_node("Aircraft"):
			player_aircraft = main_scene.get_node("Aircraft")
		if player_aircraft and is_instance_valid(player_aircraft):
			var dist = global_position.distance_to(player_aircraft.global_position)
			if dist < 8.0:
				main_scene.take_damage(damage)
				queue_free()
