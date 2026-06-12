extends Control

## 战斗HUD — 武器模式显示 + 玩家血量

# === 武器模式 ===
enum WeaponMode { AGM, AAM }
var current_mode: WeaponMode = WeaponMode.AAM

# === 玩家血量 ===
var player_health: float = 100.0
var player_max_health: float = 100.0
var player_min_health: float = 1.0  # 最低1血

# === 引用 ===
var aircraft: Node3D = null

func _ready():
	anchor_right = 1.0
	anchor_bottom = 1.0
	offset_right = 0
	offset_bottom = 0
	
	# 查找玩家飞机
	await get_tree().process_frame
	var root = get_tree().current_scene
	if root and root.has_node("Aircraft"):
		aircraft = root.get_node("Aircraft")

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_Z:
			# Z键切换武器模式
			if current_mode == WeaponMode.AGM:
				current_mode = WeaponMode.AAM
			else:
				current_mode = WeaponMode.AGM

func _process(delta):
	# 更新玩家血量（从主场景获取）
	var main_scene = get_tree().current_scene
	if main_scene and main_scene.has_method("get_health"):
		player_health = main_scene.get_health()
	queue_redraw()

func _draw():
	var screen_size = get_viewport().get_visible_rect().size
	
	# === 武器模式显示（左下角）===
	var mode_text = "AGM" if current_mode == WeaponMode.AGM else "AAM"
	var mode_color = Color(1, 0.6, 0.2) if current_mode == WeaponMode.AGM else Color(0.3, 0.8, 1.0)
	var font = get_theme_default_font()
	var font_size = 28
	
	# 背景框
	var text_len = font.get_string_size(mode_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var bg_rect = Rect2(20, screen_size.y - 60, text_len + 30, 45)
	draw_rect(bg_rect, Color(0, 0, 0, 0.6))
	draw_rect(bg_rect, mode_color, false, 2.0)
	draw_string(font, Vector2(35, screen_size.y - 28), mode_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, mode_color)
	
	# === 玩家血量条（底部居中）===
	var bar_width = 250.0
	var bar_height = 12.0
	var bar_x = (screen_size.x - bar_width) / 2.0
	var bar_y = screen_size.y - 35.0
	
	# 背景
	draw_rect(Rect2(bar_x, bar_y, bar_width, bar_height), Color(0.1, 0.1, 0.1, 0.7))
	
	# 血量
	var health_ratio = clamp(player_health / player_max_health, 0.0, 1.0)
	var health_color = Color.GREEN
	if health_ratio < 0.3:
		health_color = Color.RED
	elif health_ratio < 0.6:
		health_color = Color.YELLOW
	draw_rect(Rect2(bar_x, bar_y, bar_width * health_ratio, bar_height), health_color)
	
	# 边框
	draw_rect(Rect2(bar_x, bar_y, bar_width, bar_height), Color.WHITE, false, 1.0)
	
	# 血量数字
	var hp_text = "HP: %d" % int(player_health)
	var hp_font_size = 16
	var hp_text_size = font.get_string_size(hp_text, HORIZONTAL_ALIGNMENT_LEFT, -1, hp_font_size)
	draw_string(font, Vector2(bar_x + bar_width / 2.0 - hp_text_size.x / 2.0, bar_y - 4), hp_text, HORIZONTAL_ALIGNMENT_LEFT, -1, hp_font_size, Color.WHITE)

## 获取当前武器模式
func get_weapon_mode() -> WeaponMode:
	return current_mode

## 获取目标分组名
func get_target_group() -> String:
	if current_mode == WeaponMode.AGM:
		return "enemy_ground"
	else:
		return "enemy_air"

## 玩家受到伤害
func take_damage(amount: float):
	player_health = max(player_min_health, player_health - amount)

## 获取血量
func get_health() -> float:
	return player_health
