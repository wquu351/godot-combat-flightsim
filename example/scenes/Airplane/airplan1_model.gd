@tool
extends Node3D

## 歼-20 "威龙" 隐身战斗机模型 V2
## 基于真实歼-20照片参考重新设计
## 核心：升力体翼身融合 + 菱形机头 + DSI进气道 + 上反鸭翼 + 外倾全动垂尾

func _ready():
	build_airplan1()

# ==================== 材质 ====================
func _mat_stealth() -> StandardMaterial3D:
	var m = StandardMaterial3D.new()
	m.albedo_color = Color(0.20, 0.22, 0.25, 1.0)
	m.metallic = 0.45
	m.roughness = 0.50
	return m

func _mat_dark() -> StandardMaterial3D:
	var m = StandardMaterial3D.new()
	m.albedo_color = Color(0.10, 0.11, 0.13, 1.0)
	m.metallic = 0.55
	m.roughness = 0.40
	return m

func _mat_glass() -> StandardMaterial3D:
	var m = StandardMaterial3D.new()
	m.albedo_color = Color(0.30, 0.50, 0.65, 0.55)
	m.metallic = 0.92
	m.roughness = 0.03
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return m

func _mat_intake() -> StandardMaterial3D:
	var m = StandardMaterial3D.new()
	m.albedo_color = Color(0.08, 0.09, 0.11, 1.0)
	m.metallic = 0.65
	m.roughness = 0.30
	return m

func _mat_red() -> StandardMaterial3D:
	var m = StandardMaterial3D.new()
	m.albedo_color = Color(0.85, 0.02, 0.02, 1.0)
	m.metallic = 0.25
	m.roughness = 0.5
	return m

func _mat_green() -> StandardMaterial3D:
	var m = StandardMaterial3D.new()
	m.albedo_color = Color(0.02, 0.70, 0.12, 1.0)
	m.metallic = 0.25
	m.roughness = 0.5
	return m

# ==================== 主构建 ====================
func build_airplan1():
	var s = _mat_stealth()
	var d = _mat_dark()
	var g = _mat_glass()
	var i = _mat_intake()
	var r = _mat_red()
	var gr = _mat_green()

	# 按从前往后、从上到下的顺序构建
	_build_nose(s)                    # 菱形机头
	_build_fuselage(s, d)             # 升力体机身（翼身融合）
	_build_canopy(g)                  # 整体式气泡座舱盖
	_build_dsi_intakes(i, d)          # DSI蚌式进气道 ★
	_build_canards(s)                 # 上反鸭翼+尖拱边条 ★
	_build_main_wings(s)              # 大三角主翼（翼身融合）
	_build_vstabs(s)                  # 外倾全动双垂尾 ★
	_build_htails(s)                  # 全动平尾+腹鳍
	_build_exhaust(s, d)              # 双发喷口+尾椎
	_build_details(d, r, gr)          # 细节部件

# ================================================================
#  菱形机头 — 歼-20最标志性的"钻石切面"造型
#  非常扁平、尖锐、多面体感强
# ================================================================
func _build_nose(m: StandardMaterial3D):
	# 机头主锥体（扁平菱形截面）
	var nose1 = CSGBox3D.new()
	nose1.name = "NoseCone"
	nose1.size = Vector3(0.75, 0.28, 2.8)
	nose1.material = m
	nose1.position = Vector3(0, 0.12, -4.2)
	add_child(nose1)

	# 机头前段（更细更扁）
	var nose2 = CSGBox3D.new()
	nose2.name = "NoseTip"
	nose2.size = Vector3(0.40, 0.18, 2.0)
	nose2.material = m
	nose2.position = Vector3(0, 0.08, -5.6)
	add_child(nose2)

	# 机头最尖端（锥形收尾）
	var nose3 = CSGCylinder3D.new()
	nose3.name = "NosePoint"
	nose3.radius = 0.12
	nose3.height = 1.4
	nose3.sides = 6
	nose3.cone = true
	nose3.material = m
	nose3.rotation_degrees = Vector3(-90, 0, 0)
	nose3.position = Vector3(0, 0.06, -6.6)
	add_child(nose3)

	# 机头侧面棱线（菱形特征线）
	var ridge_l = CSGBox3D.new()
	ridge_l.name = "NoseRidgeLeft"
	ridge_l.size = Vector3(0.04, 0.22, 3.5)
	ridge_l.material = m
	ridge_l.position = Vector3(-0.36, 0.14, -4.2)
	add_child(ridge_l)

	var ridge_r = CSGBox3D.new()
	ridge_r.name = "NoseRidgeRight"
	ridge_r.size = Vector3(0.04, 0.22, 3.5)
	ridge_r.material = m
	ridge_r.position = Vector3(0.36, 0.14, -4.2)
	add_child(ridge_r)

# ================================================================
#  升力体机身 — 翼身融合设计，从前到后平滑过渡
#  歼-20的机身本身就是升力面，线条极其顺滑
# ================================================================
func _build_fuselage(m: StandardMaterial3D, d: StandardMaterial3D):
	# ====== 前机身（座舱段）======
	# 上表面 — 扁平宽大
	var f_front_top = CSGBox3D.new()
	f_front_top.name = "FFrontTop"
	f_front_top.size = Vector3(1.7, 0.22, 4.5)
	f_front_top.material = m
	f_front_top.position = Vector3(0, 0.26, -1.5)
	add_child(f_front_top)

	# 下表面 — 较窄（菱形截面效果）
	var f_front_bot = CSGBox3D.new()
	f_front_bot.name = "FFrontBot"
	f_front_bot.size = Vector3(1.3, 0.18, 4.0)
	f_front_bot.material = d
	f_front_bot.position = Vector3(0, -0.01, -1.2)
	add_child(f_front_bot)

	# ====== 中机身（翼根段 — 最宽处）======
	# 上表面 — 宽大平滑
	var f_mid_top = CSGBox3D.new()
	f_mid_top.name = "FMidTop"
	f_mid_top.size = Vector3(2.8, 0.28, 4.5)
	f_mid_top.material = m
	f_mid_top.position = Vector3(0, 0.30, 1.5)
	add_child(f_mid_top)

	# 下表面
	var f_mid_bot = CSGBox3D.new()
	f_mid_bot.name = "FMidBot"
	f_mid_bot.size = Vector3(2.2, 0.24, 4.2)
	f_mid_bot.material = d
	f_mid_bot.position = Vector3(0, -0.03, 1.5)
	add_child(f_mid_bot)

	# 中机身侧边斜面（翼身融合过渡 — 关键！让机身向机翼自然延伸）
	var f_slope_l = CSGBox3D.new()
	f_slope_l.name = "FSlopeLeft"
	f_slope_l.size = Vector3(1.8, 0.22, 5.0)
	f_slope_l.material = m
	f_slope_l.rotation_degrees = Vector3(0, 0, 10)
	f_slope_l.position = Vector3(-1.35, 0.16, 1.0)
	add_child(f_slope_l)

	var f_slope_r = CSGBox3D.new()
	f_slope_r.name = "FSlopeRight"
	f_slope_r.size = Vector3(1.8, 0.22, 5.0)
	f_slope_r.material = m
	f_slope_r.rotation_degrees = Vector3(0, 0, -10)
	f_slope_r.position = Vector3(1.35, 0.16, 1.0)
	add_child(f_slope_r)

	# ====== 后机身（收敛到发动机舱）======
	var f_rear_top = CSGBox3D.new()
	f_rear_top.name = "FRearTop"
	f_rear_top.size = Vector3(2.0, 0.25, 3.5)
	f_rear_top.material = m
	f_rear_top.position = Vector3(0, 0.24, 4.2)
	add_child(f_rear_top)

	var f_rear_bot = CSGBox3D.new()
	f_rear_bot.name = "FRearBot"
	f_rear_bot.size = Vector3(1.6, 0.22, 3.2)
	f_rear_bot.material = d
	f_rear_bot.position = Vector3(0, -0.03, 4.1)
	add_child(f_rear_bot)

	# ====== 机背脊线（从座舱后部一直延伸到垂尾根部）======
	var spine = CSGBox3D.new()
	spine.name = "Spine"
	spine.size = Vector3(0.40, 0.10, 7.0)
	spine.material = m
	spine.position = Vector3(0, 0.48, 1.8)
	add_child(spine)

	# 脊线后段加高（垂尾整流区）
	var spine_rear = CSGBox3D.new()
	spine_rear.name = "SpineRear"
	spine_rear.size = Vector3(1.6, 0.15, 2.5)
	spine_rear.material = m
	spine_rear.position = Vector3(0, 0.52, 4.3)
	add_child(spine_rear)

	# ====== 机身腹部（平坦化）======
	var belly = CSGBox3D.new()
	belly.name = "Belly"
	belly.size = Vector3(2.0, 0.06, 9.0)
	belly.material = d
	belly.position = Vector3(0, -0.16, 1.0)
	add_child(belly)

# ================================================================
#  整体式气泡座舱盖 — 与机背无缝衔接
#  歼-20采用无隔框整体式座舱盖
# ================================================================
func _build_canopy(m: StandardMaterial3D):
	# 座舱主体（大水滴形气泡）
	var cap_main = CSGSphere3D.new()
	cap_main.name = "CanopyMain"
	cap_main.radius = 0.60
	cap_main.material = m
	cap_main.position = Vector3(0, 0.68, -1.6)
	add_child(cap_main)

	# 座舱前部（低矮扁平，与菱形机头融合）
	var cap_front = CSGBox3D.new()
	cap_front.name = "CanopyFront"
	cap_front.size = Vector3(1.05, 0.25, 1.8)
	cap_front.material = m
	cap_front.position = Vector3(0, 0.50, -2.9)
	add_child(cap_front)

	# 座舱中段（最高点）
	var cap_mid = CSGBox3D.new()
	cap_mid.name = "CanopyMid"
	cap_mid.size = Vector3(0.95, 0.32, 1.4)
	cap_mid.material = m
	cap_mid.position = Vector3(0, 0.58, -1.6)
	add_child(cap_mid)

	# 座舱后部（向下倾斜与机背融合）
	var cap_rear = CSGBox3D.new()
	cap_rear.name = "CanopyRear"
	cap_rear.size = Vector3(0.80, 0.25, 1.2)
	cap_rear.material = m
	cap_rear.rotation_degrees = Vector3(12, 0, 0)
	cap_rear.position = Vector3(0, 0.52, -0.5)
	add_child(cap_rear)

	# 座舱边框（极窄黑色边框 — 歼-20特征）
	var frame_l = CSGBox3D.new()
	frame_l.name = "CanopyFrameL"
	frame_l.size = Vector3(0.05, 0.48, 3.2)
	frame_l.material = _mat_dark()
	frame_l.position = Vector3(-0.50, 0.54, -1.7)
	add_child(frame_l)

	var frame_r = CSGBox3D.new()
	frame_r.name = "CanopyFrameR"
	frame_r.size = Vector3(0.05, 0.48, 3.2)
	frame_r.material = _mat_dark()
	frame_r.position = Vector3(0.50, 0.54, -1.7)
	add_child(frame_r)

	# 座舱中间分隔（隐约可见的风挡横梁）
	var frame_cross = CSGBox3D.new()
	frame_cross.name = "CanopyCrossbar"
	frame_cross.size = Vector3(0.90, 0.03, 0.05)
	frame_cross.material = _mat_dark()
	frame_cross.position = Vector3(0, 0.58, -1.5)
	add_child(frame_cross)

# ================================================================
#  DSI蚌式进气道 ★★★ 歼-20三大核心特征之一
#  无附面层隔道，进气口上方有特征性鼓包/压缩曲面
#  进气道呈"S"形弯曲，遮挡发动机叶片
# ================================================================
func _build_dsi_intakes(i: StandardMaterial3D, d: StandardMaterial3D):
	# ========== 左侧DSI进气道 ==========
	# 进气口外唇（上唇 — 斜切设计）
	var li_lip_upper = CSGBox3D.new()
	li_lip_upper.name = "LI_LipUpper"
	li_lip_upper.size = Vector3(0.72, 0.12, 1.6)
	li_lip_upper.material = i
	li_lip_upper.rotation_degrees = Vector3(5, 0, 0)
	li_lip_upper.position = Vector3(-1.08, 0.12, 0.5)
	add_child(li_lip_upper)

	# 进气口主体（深色内部）
	var li_body = CSGBox3D.new()
	li_body.name = "LI_Body"
	li_body.size = Vector3(0.60, 0.62, 2.0)
	li_body.material = d
	li_body.position = Vector3(-1.08, -0.16, 0.3)
	add_child(li_body)

	# ★ DSI鼓包（压缩曲面 — 最关键的识别特征！）
	var li_bump = CSGSphere3D.new()
	li_bump.name = "LI_DSIBump"
	li_bump.radius = 0.38
	li_bump.material = i
	li_bump.position = Vector3(-0.90, 0.20, 0.2)
	add_child(li_bump)

	# 鼓包前方过渡斜面（让鼓包与机头侧面自然连接）
	var li_bump_ramp = CSGBox3D.new()
	li_bump_ramp.name = "LI_BumpRamp"
	li_bump_ramp.size = Vector3(0.45, 0.18, 1.2)
	li_bump_ramp.material = i
	li_bump_ramp.rotation_degrees = Vector3(-15, 0, 5)
	li_bump_ramp.position = Vector3(-1.05, 0.16, -0.4)
	add_child(li_bump_ramp)

	# 进气口下唇
	var li_lip_lower = CSGBox3D.new()
	li_lip_lower.name = "LI_LipLower"
	li_lip_lower.size = Vector3(0.68, 0.07, 0.25)
	li_lip_lower.material = i
	li_lip_lower.position = Vector3(-1.08, -0.49, 1.2)
	add_child(li_lip_lower)

	# 进气道外侧边界/隔板
	var li_outer = CSGBox3D.new()
	li_outer.name = "LI_Outer"
	li_outer.size = Vector3(0.06, 0.58, 1.8)
	li_outer.material = i
	li_outer.position = Vector3(-1.42, -0.14, 0.4)
	add_child(li_outer)

	# ========== 右侧DSI进气道（镜像）==========
	# 进气口外唇
	var ri_lip_upper = CSGBox3D.new()
	ri_lip_upper.name = "RI_LipUpper"
	ri_lip_upper.size = Vector3(0.72, 0.12, 1.6)
	ri_lip_upper.material = i
	ri_lip_upper.rotation_degrees = Vector3(5, 0, 0)
	ri_lip_upper.position = Vector3(1.08, 0.12, 0.5)
	add_child(ri_lip_upper)

	# 进气口主体
	var ri_body = CSGBox3D.new()
	ri_body.name = "RI_Body"
	ri_body.size = Vector3(0.60, 0.62, 2.0)
	ri_body.material = d
	ri_body.position = Vector3(1.08, -0.16, 0.3)
	add_child(ri_body)

	# ★ DSI鼓包
	var ri_bump = CSGSphere3D.new()
	ri_bump.name = "RI_DSIBump"
	ri_bump.radius = 0.38
	ri_bump.material = i
	ri_bump.position = Vector3(0.90, 0.20, 0.2)
	add_child(ri_bump)

	# 鼓包前方过渡斜面
	var ri_bump_ramp = CSGBox3D.new()
	ri_bump_ramp.name = "RI_BumpRamp"
	ri_bump_ramp.size = Vector3(0.45, 0.18, 1.2)
	ri_bump_ramp.material = i
	ri_bump_ramp.rotation_degrees = Vector3(-15, 0, -5)
	ri_bump_ramp.position = Vector3(1.05, 0.16, -0.4)
	add_child(ri_bump_ramp)

	# 下唇
	var ri_lip_lower = CSGBox3D.new()
	ri_lip_lower.name = "RI_LipLower"
	ri_lip_lower.size = Vector3(0.68, 0.07, 0.25)
	ri_lip_lower.material = i
	ri_lip_lower.position = Vector3(1.08, -0.49, 1.2)
	add_child(ri_lip_lower)

	# 外侧边界
	var ri_outer = CSGBox3D.new()
	ri_outer.name = "RI_Outer"
	ri_outer.size = Vector3(0.06, 0.58, 1.8)
	ri_outer.material = i
	ri_outer.position = Vector3(1.42, -0.14, 0.4)
	add_child(ri_outer)

# ================================================================
#  上反鸭翼 + 尖拱边条 ★★ 歼-20最标志性的气动特征
#  鸭翼位于座舱两侧偏前方，带明显上反角
#  尖拱边条(LEX)从鸭翼根部向后延伸融入主翼
# ================================================================
func _build_canards(m: StandardMaterial3D):
	# --- 左鸭翼 ---
	var lc = CSGBox3D.new()
	lc.name = "LeftCanard"
	lc.size = Vector3(2.4, 0.055, 0.80)
	lc.material = m
	# 后掠~52° + 上反角(~5°) + 安装角
	lc.rotation_degrees = Vector3(-4, -50, 5)
	lc.position = Vector3(-1.75, 0.44, -0.6)
	add_child(lc)

	# 左鸭翼翼根整流罩（与机身融合）
	var lc_root = CSGBox3D.new()
	lc_root.name = "LeftCanardRoot"
	lc_root.size = Vector3(0.70, 0.14, 0.75)
	lc_root.material = m
	lc_root.position = Vector3(-0.82, 0.34, -0.55)
	add_child(lc_root)

	# --- 右鸭翼 ---
	var rc = CSGBox3D.new()
	rc.name = "RightCanard"
	rc.size = Vector3(2.4, 0.055, 0.80)
	rc.material = m
	rc.rotation_degrees = Vector3(-4, 50, -5)
	rc.position = Vector3(1.75, 0.44, -0.6)
	add_child(rc)

	# 右鸭翼翼根整流罩
	var rc_root = CSGBox3D.new()
	rc_root.name = "RightCanardRoot"
	rc_root.size = Vector3(0.70, 0.14, 0.75)
	rc_root.material = m
	rc_root.position = Vector3(0.82, 0.34, -0.55)
	add_child(rc_root)

	# --- 左尖拱边条（从鸭翼根部向后延伸）---
	var llex = CSGBox3D.new()
	llex.name = "LeftLEX"
	llex.size = Vector3(2.2, 0.045, 1.8)
	llex.material = m
	# 大后掠角 ~60°
	llex.rotation_degrees = Vector3(0, -60, 8)
	llex.position = Vector3(-1.35, 0.42, 0.2)
	add_child(llex)

	# 边条内侧填充
	var llex_inner = CSGBox3D.new()
	llex_inner.name = "LeftLEXInner"
	llex_inner.size = Vector3(1.2, 0.04, 1.2)
	llex_inner.material = m
	llex_inner.rotation_degrees = Vector3(0, -50, 4)
	llex_inner.position = Vector3(-0.95, 0.39, -0.1)
	add_child(llex_inner)

	# --- 右尖拱边条 ---
	var rlex = CSGBox3D.new()
	rlex.name = "RightLEX"
	rlex.size = Vector3(2.2, 0.045, 1.8)
	rlex.material = m
	rlex.rotation_degrees = Vector3(0, 60, -8)
	rlex.position = Vector3(1.35, 0.42, 0.2)
	add_child(rlex)

	# 边条内侧填充
	var rlex_inner = CSGBox3D.new()
	rlex_inner.name = "RightLEXInner"
	rlex_inner.size = Vector3(1.2, 0.04, 1.2)
	rlex_inner.material = m
	rlex_inner.rotation_degrees = Vector3(0, 50, -4)
	rlex_inner.position = Vector3(0.95, 0.39, -0.1)
	add_child(rlex_inner)

# ================================================================
#  大三角主翼 — 翼身融合设计
#  后掠角约42°，大展弦比，翼尖削薄
# ================================================================
func _build_main_wings(m: StandardMaterial3D):
	# --- 左主翼 ---
	var lw = CSGBox3D.new()
	lw.name = "LeftWing"
	lw.size = Vector3(6.2, 0.06, 3.2)
	lw.material = m
	# 后掠42° + 微小上反角
	lw.rotation_degrees = Vector3(-1.5, -43, 2.5)
	lw.position = Vector3(-3.8, 0.06, 1.4)
	add_child(lw)

	# 左翼根过渡（与机身融合 — 加厚段）
	var lw_root = CSGBox3D.new()
	lw_root.name = "LeftWingRoot"
	lw_root.size = Vector3(2.0, 0.10, 1.8)
	lw_root.material = m
	lw_root.rotation_degrees = Vector3(-1, -38, 3)
	lw_root.position = Vector3(-1.8, 0.08, 0.8)
	add_child(lw_root)

	# 左翼尖（削尖处理）
	var lw_tip = CSGBox3D.new()
	lw_tip.name = "LeftWingTip"
	lw_tip.size = Vector3(1.4, 0.04, 0.7)
	lw_tip.material = m
	lw_tip.rotation_degrees = Vector3(0, -50, 0)
	lw_tip.position = Vector3(-6.6, 0.02, 2.4)
	add_child(lw_tip)

	# 左翼后缘襟副翼暗示
	var lw_te = CSGBox3D.new()
	lw_te.name = "LeftWingTE"
	lw_te.size = Vector3(3.0, 0.045, 0.5)
	lw_te.material = _mat_dark()
	lw_te.rotation_degrees = Vector3(0, -43, 0)
	lw_te.position = Vector3(-4.8, 0.00, 2.6)
	add_child(lw_te)

	# --- 右主翼（镜像）---
	var rw = CSGBox3D.new()
	rw.name = "RightWing"
	rw.size = Vector3(6.2, 0.06, 3.2)
	rw.material = m
	rw.rotation_degrees = Vector3(-1.5, 43, -2.5)
	rw.position = Vector3(3.8, 0.06, 1.4)
	add_child(rw)

	# 右翼根过渡
	var rw_root = CSGBox3D.new()
	rw_root.name = "RightWingRoot"
	rw_root.size = Vector3(2.0, 0.10, 1.8)
	rw_root.material = m
	rw_root.rotation_degrees = Vector3(-1, 38, -3)
	rw_root.position = Vector3(1.8, 0.08, 0.8)
	add_child(rw_root)

	# 右翼尖
	var rw_tip = CSGBox3D.new()
	rw_tip.name = "RightWingTip"
	rw_tip.size = Vector3(1.4, 0.04, 0.7)
	rw_tip.material = m
	rw_tip.rotation_degrees = Vector3(0, 50, 0)
	rw_tip.position = Vector3(6.6, 0.02, 2.4)
	add_child(rw_tip)

	# 右翼后缘襟副翼暗示
	var rw_te = CSGBox3D.new()
	rw_te.name = "RightWingTE"
	rw_te.size = Vector3(3.0, 0.045, 0.5)
	rw_te.material = _mat_dark()
	rw_te.rotation_degrees = Vector3(0, 43, 0)
	rw_te.position = Vector3(4.8, 0.00, 2.6)
	add_child(rw_te)

# ================================================================
#  外倾全动双垂尾 ★★★
#  向外倾斜约27°，整体可偏转（非仅舵面）
#  面积较大，顶部斜切
# ================================================================
func _build_vstabs(m: StandardMaterial3D):
	# --- 左垂尾 ---
	var lv = CSGBox3D.new()
	lv.name = "LeftVStab"
	lv.size = Vector3(0.06, 2.6, 1.8)
	lv.material = m
	# 外倾27°
	lv.rotation_degrees = Vector3(0, 0, 27)
	lv.position = Vector3(-1.02, 1.32, 4.0)
	add_child(lv)

	# 左垂尾顶部斜切
	var lv_top = CSGBox3D.new()
	lv_top.name = "LeftVStabTop"
	lv_top.size = Vector3(0.06, 0.75, 0.75)
	lv_top.material = m
	lv_top.rotation_degrees = Vector3(0, 0, 27)
	lv_top.position = Vector3(-1.36, 2.38, 3.55)
	add_child(lv_top)

	# 左垂尾根部整流（与机背融合）
	var lv_root = CSGBox3D.new()
	lv_root.name = "LeftVStabRoot"
	lv_root.size = Vector3(0.60, 0.35, 1.2)
	lv_root.material = m
	lv_root.rotation_degrees = Vector3(0, 0, 15)
	lv_root.position = Vector3(-0.68, 0.46, 4.0)
	add_child(lv_root)

	# --- 右垂尾 ---
	var rv = CSGBox3D.new()
	rv.name = "RightVStab"
	rv.size = Vector3(0.06, 2.6, 1.8)
	rv.material = m
	rv.rotation_degrees = Vector3(0, 0, -27)
	rv.position = Vector3(1.02, 1.32, 4.0)
	add_child(rv)

	# 右垂尾顶部斜切
	var rv_top = CSGBox3D.new()
	rv_top.name = "RightVStabTop"
	rv_top.size = Vector3(0.06, 0.75, 0.75)
	rv_top.material = m
	rv_top.rotation_degrees = Vector3(0, 0, -27)
	rv_top.position = Vector3(1.36, 2.38, 3.55)
	add_child(rv_top)

	# 右垂尾根部整流
	var rv_root = CSGBox3D.new()
	rv_root.name = "RightVStabRoot"
	rv_root.size = Vector3(0.60, 0.35, 1.2)
	rv_root.material = m
	rv_root.rotation_degrees = Vector3(0, 0, -15)
	rv_root.position = Vector3(0.68, 0.46, 4.0)
	add_child(rv_root)

	# 垂尾间机背整流罩（宽大平整）
	var tail_deck = CSGBox3D.new()
	tail_deck.name = "TailDeck"
	tail_deck.size = Vector3(2.4, 0.14, 2.2)
	tail_deck.material = m
	tail_deck.position = Vector3(0, 0.52, 4.2)
	add_child(tail_deck)

# ================================================================
#  全动差动平尾 + 腹鳍
# ================================================================
func _build_htails(m: StandardMaterial3D):
	# --- 左全动平尾 ---
	var lh = CSGBox3D.new()
	lh.name = "LeftHTail"
	lh.size = Vector3(2.6, 0.045, 1.2)
	lh.material = m
	lh.rotation_degrees = Vector3(0, -22, 0)
	lh.position = Vector3(-1.75, 0.10, 4.8)
	add_child(lh)

	# --- 右全动平尾 ---
	var rh = CSGBox3D.new()
	rh.name = "RightHTail"
	rh.size = Vector3(2.6, 0.045, 1.2)
	rh.material = m
	rh.rotation_degrees = Vector3(0, 22, 0)
	rh.position = Vector3(1.75, 0.10, 4.8)
	add_child(rh)

	# --- 左腹鳍 ---
	var lf = CSGBox3D.new()
	lf.name = "LeftVentralFin"
	lf.size = Vector3(0.045, 1.0, 1.4)
	lf.material = m
	lf.rotation_degrees = Vector3(-18, 0, 8)
	lf.position = Vector3(-0.60, -0.56, 4.9)
	add_child(lf)

	# --- 右腹鳍 ---
	var rf = CSGBox3D.new()
	rf.name = "RightVentralFin"
	rf.size = Vector3(0.045, 1.0, 1.4)
	rf.material = m
	rf.rotation_degrees = Vector3(-18, 0, -8)
	rf.position = Vector3(0.60, -0.56, 4.9)
	add_child(rf)

# ================================================================
#  双发喷口区域 + 尾椎
# ================================================================
func _build_exhaust(m: StandardMaterial3D, d: StandardMaterial3D):
	# --- 左喷口外壳 ---
	var ln_out = CSGBox3D.new()
	ln_out.name = "LeftNozzleOuter"
	ln_out.size = Vector3(0.72, 0.58, 0.9)
	ln_out.material = m
	ln_out.position = Vector3(-0.50, 0.02, 5.7)
	add_child(ln_out)

	# 左喷口内管（深色高温区）
	var ln_in = CSGCylinder3D.new()
	ln_in.name = "LeftNozzleInner"
	ln_in.radius = 0.30
	ln_in.height = 0.7
	ln_in.sides = 12
	ln_in.material = d
	ln_in.rotation_degrees = Vector3(90, 0, 0)
	ln_in.position = Vector3(-0.50, 0.02, 6.15)
	add_child(ln_in)

	# --- 右喷口外壳 ---
	var rn_out = CSGBox3D.new()
	rn_out.name = "RightNozzleOuter"
	rn_out.size = Vector3(0.72, 0.58, 0.9)
	rn_out.material = m
	rn_out.position = Vector3(0.50, 0.02, 5.7)
	add_child(rn_out)

	# 右喷口内管
	var rn_in = CSGCylinder3D.new()
	rn_in.name = "RightNozzleInner"
	rn_in.radius = 0.30
	rn_in.height = 0.7
	rn_in.sides = 12
	rn_in.material = d
	rn_in.rotation_degrees = Vector3(90, 0, 0)
	rn_in.position = Vector3(0.50, 0.02, 6.15)
	add_child(rn_in)

	# 双喷口之间整流罩
	var nz_center = CSGBox3D.new()
	nz_center.name = "NozzleCenterFairing"
	nz_center.size = Vector3(0.35, 0.48, 1.2)
	nz_center.material = m
	nz_center.position = Vector3(0, 0.02, 5.55)
	add_child(nz_center)

	# 发动机舱上部整流
	var eng_top = CSGBox3D.new()
	eng_top.name = "EngineDeckTop"
	eng_top.size = Vector3(1.8, 0.18, 2.5)
	eng_top.material = m
	eng_top.position = Vector3(0, 0.28, 5.0)
	add_child(eng_top)

	# 尾椎（收敛锥）
	var tail_cone = CSGCylinder3D.new()
	tail_cone.name = "TailCone"
	tail_cone.radius = 0.38
	tail_cone.height = 1.2
	tail_cone.sides = 12
	tail_cone.cone = true
	tail_cone.material = m
	tail_cone.rotation_degrees = Vector3(90, 0, 0)
	tail_cone.position = Vector3(0, 0.02, 6.7)
	add_child(tail_cone)

# ================================================================
#  细节部件：航行灯、空速管、传感器、舱门缝线等
# ================================================================
func _build_details(d: StandardMaterial3D, r: StandardMaterial3D, g: StandardMaterial3D):
	# ---- 翼尖航行灯 ----
	var ll = CSGSphere3D.new()
	ll.name = "LeftNavLight"
	ll.radius = 0.05
	ll.material = r
	ll.position = Vector3(-6.75, 0.05, 2.4)
	add_child(ll)

	var rl = CSGSphere3D.new()
	rl.name = "RightNavLight"
	rl.radius = 0.05
	rl.material = g
	rl.position = Vector3(6.75, 0.05, 2.4)
	add_child(rl)

	# 尾部白灯
	var tl = CSGSphere3D.new()
	tl.name = "TailNavLight"
	tl.radius = 0.04
	tl.material = _create_white_mat()
	tl.position = Vector3(0, 0.52, 7.1)
	add_child(tl)

	# ---- 空速管/Pitot tube（机头最前端）----
	var pitot = CSGCylinder3D.new()
	pitot.name = "PitotTube"
	pitot.radius = 0.012
	pitot.height = 1.0
	pitot.sides = 6
	pitot.material = d
	pitot.rotation_degrees = Vector3(-90, 0, 0)
	pitot.position = Vector3(0, 0.28, -7.1)
	add_child(pitot)

	# ---- EOTS光电瞄准窗口（机头下方）----
	var eots = CSGBox3D.new()
	eots.name = "EOTSWindow"
	eots.size = Vector3(0.28, 0.06, 0.18)
	eots.material = _mat_glass()
	eots.position = Vector3(0, -0.12, -5.4)
	add_child(eots)

	# ---- 机背天线/DAS传感器整流罩 ----
	var dorsal = CSGBox3D.new()
	dorsal.name = "DorsalFin"
	dorsal.size = Vector3(0.28, 0.18, 0.9)
	dorsal.material = d
	dorsal.position = Vector3(0, 0.68, 2.8)
	add_child(dorsal)

	# ---- 座舱两侧天线/传感器凸起 ----
	var ant_l = CSGBox3D.new()
	ant_l.name = "LeftSensorHump"
	ant_l.size = Vector3(0.15, 0.10, 0.30)
	ant_l.material = d
	ant_l.position = Vector3(-0.92, 0.32, -0.6)
	add_child(ant_l)

	var ant_r = CSGBox3D.new()
	ant_r.name = "RightSensorHump"
	ant_r.size = Vector3(0.15, 0.10, 0.30)
	ant_r.material = d
	ant_r.position = Vector3(0.92, 0.32, -0.6)
	add_child(ant_r)

	# ---- 起落架舱门缝线暗示（深色细线）----
	var ng_door = CSGBox3D.new()
	ng_door.name = "NoseGearDoorLine"
	ng_door.size = Vector3(0.55, 0.015, 1.4)
	ng_door.material = d
	ng_door.position = Vector3(0, -0.19, -3.6)
	add_child(ng_door)

	var lg_door_l = CSGBox3D.new()
	lg_door_l.name = "LeftGearDoorLine"
	lg_door_l.size = Vector3(0.90, 0.015, 2.0)
	lg_door_l.material = d
	lg_door_l.position = Vector3(-1.05, -0.21, 1.5)
	add_child(lg_door_l)

	var lg_door_r = CSGBox3D.new()
	lg_door_r.name = "RightGearDoorLine"
	lg_door_r.size = Vector3(0.90, 0.015, 2.0)
	lg_door_r.material = d
	lg_door_r.position = Vector3(1.05, -0.21, 1.5)
	add_child(lg_door_r)

	# ---- 主弹舱门缝线暗示（机腹中线）----
	var bay_line = CSGBox3D.new()
	bay_line.name = "WeaponsBayLine"
	bay_line.size = Vector3(0.025, 0.015, 3.0)
	bay_line.material = d
	bay_line.position = Vector3(0, -0.20, 2.2)
	add_child(bay_line)

	# ---- 侧弹舱门缝线 ----
	var sbay_l = CSGBox3D.new()
	sbay_l.name = "SideBayLineLeft"
	sbay_l.size = Vector3(0.025, 0.015, 1.5)
	sbay_l.material = d
	sbay_l.position = Vector3(-0.55, -0.20, 1.8)
	add_child(sbay_l)

	var sbay_r = CSGBox3D.new()
	sbay_r.name = "SideBayLineRight"
	sbay_r.size = Vector3(0.025, 0.015, 1.5)
	sbay_r.material = d
	sbay_r.position = Vector3(0.55, -0.20, 1.8)
	add_child(sbay_r)

func _create_white_mat() -> StandardMaterial3D:
	var m = StandardMaterial3D.new()
	m.albedo_color = Color(0.88, 0.88, 0.93, 1.0)
	m.metallic = 0.18
	m.roughness = 0.35
	return m
