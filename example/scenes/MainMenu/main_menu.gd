extends Control

## 主菜单 — 开始游戏 / 暂停继续 / 退出游戏
## 支持初始界面和游戏中ESC呼出

var is_game_started: bool = false
var btn_start: Button
var title_label: Label

func _ready():
	# 强制全屏覆盖
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0
	
	# 菜单不受暂停影响
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# 确保鼠标可见可点击
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# 标记游戏未开始并暂停
	get_tree().set_meta("game_started", false)
	get_tree().paused = true
	
	# 创建UI
	_create_ui()

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if not is_game_started:
			return
		# 游戏中按ESC：重新显示菜单
		_show_menu()

func _create_ui():
	# 半透明黑色背景
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.75)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	
	# 居中容器
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	
	# 垂直布局
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 12)
	center.add_child(vbox)
	
	# 标题
	title_label = Label.new()
	title_label.text = "空 战 模 拟"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 52)
	title_label.add_theme_color_override("font_color", Color(0.9, 0.9, 1.0))
	vbox.add_child(title_label)
	
	# 副标题
	var subtitle = Label.new()
	subtitle.text = "AIR COMBAT SIMULATOR"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 18)
	subtitle.add_theme_color_override("font_color", Color(0.5, 0.6, 0.8))
	vbox.add_child(subtitle)
	
	# 间距
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 40)
	vbox.add_child(spacer)
	
	# 开始/继续按钮
	btn_start = _create_button("开 始 游 戏", Color(0.2, 0.6, 1.0))
	btn_start.pressed.connect(_on_start_pressed)
	vbox.add_child(btn_start)
	
	# 退出游戏按钮
	var btn_quit = _create_button("退 出 游 戏", Color(0.8, 0.3, 0.3))
	btn_quit.pressed.connect(_on_quit_pressed)
	vbox.add_child(btn_quit)
	
	# 间距
	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 40)
	vbox.add_child(spacer2)
	
	# 操作说明
	var controls = Label.new()
	controls.text = "WASD-飞行 | Shift-加力 | Z-切换武器 | X-后视 | 右键-发射 | ESC-菜单"
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls.add_theme_font_size_override("font_size", 13)
	controls.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	vbox.add_child(controls)

func _create_button(text: String, accent_color: Color) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(300, 55)
	btn.add_theme_font_size_override("font_size", 24)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_color_override("font_hover_color", accent_color)
	btn.add_theme_color_override("font_pressed_color", accent_color.lightened(0.3))
	btn.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.1, 0.1, 0.15, 0.9)
	normal_style.border_color = Color(0.3, 0.3, 0.4)
	normal_style.set_border_width_all(2)
	normal_style.set_corner_radius_all(8)
	normal_style.set_content_margin_all(12)
	btn.add_theme_stylebox_override("normal", normal_style)
	
	var hover_style = normal_style.duplicate()
	hover_style.bg_color = Color(0.15, 0.15, 0.25, 0.95)
	hover_style.border_color = accent_color
	btn.add_theme_stylebox_override("hover", hover_style)
	
	var pressed_style = normal_style.duplicate()
	pressed_style.bg_color = Color(0.2, 0.2, 0.3)
	pressed_style.border_color = accent_color.lightened(0.3)
	btn.add_theme_stylebox_override("pressed", pressed_style)
	
	return btn

## 显示菜单（游戏中ESC调用）
func _show_menu():
	modulate.a = 1.0
	show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	# 更新按钮文字为"继续游戏"
	if btn_start and is_game_started:
		btn_start.text = "继 续 游 戏"
	if title_label and is_game_started:
		title_label.text = "游 戏 暂 停"

## 隐藏菜单（点击开始后）
func _hide_menu():
	is_game_started = true
	get_tree().set_meta("game_started", true)
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(hide)

func _on_start_pressed():
	if modulate.a < 0.5:
		return
	_hide_menu()

func _on_quit_pressed():
	get_tree().quit()
