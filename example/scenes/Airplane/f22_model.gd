@tool
extends Node3D

## 紧凑型战斗机模型 — 适合第三人称视角
## 小巧、不挡视野、轮廓干净

func _ready():
	build()

# ==================== 材质 ====================
func _mat_body() -> StandardMaterial3D:
	var m = StandardMaterial3D.new()
	m.albedo_color = Color(0.22, 0.23, 0.26, 1.0)
	m.metallic = 0.35
	m.roughness = 0.65
	return m

func _mat_dark() -> StandardMaterial3D:
	var m = StandardMaterial3D.new()
	m.albedo_color = Color(0.06, 0.06, 0.08, 1.0)
	m.metallic = 0.55
	m.roughness = 0.40
	return m

func _mat_glass() -> StandardMaterial3D:
	var m = StandardMaterial3D.new()
	m.albedo_color = Color(0.45, 0.60, 0.75, 0.50)
	m.metallic = 0.85
	m.roughness = 0.08
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return m

func _mat_engine() -> StandardMaterial3D:
	var m = StandardMaterial3D.new()
	m.albedo_color = Color(0.10, 0.09, 0.08, 1.0)
	m.metallic = 0.90
	m.roughness = 0.15
	return m

func _mat_red() -> StandardMaterial3D:
	var m = StandardMaterial3D.new()
	m.albedo_color = Color(0.75, 0.10, 0.10, 1.0)
	m.metallic = 0.20
	m.roughness = 0.50
	return m

func _mat_green() -> StandardMaterial3D:
	var m = StandardMaterial3D.new()
	m.albedo_color = Color(0.10, 0.60, 0.18, 1.0)
	m.metallic = 0.20
	m.roughness = 0.50
	return m

func _mat_white() -> StandardMaterial3D:
	var m = StandardMaterial3D.new()
	m.albedo_color = Color(0.60, 0.62, 0.65, 1.0)
	m.metallic = 0.15
	m.roughness = 0.50
	return m

# ==================== 主构建 ====================
func build():
	var bd = _mat_body()
	var dk = _mat_dark()
	var gl = _mat_glass()
	var en = _mat_engine()

	# 机身
	_fuselage(bd, dk)
	# 座舱
	_cockpit(gl, dk)
	# 机翼
	_wings(bd, dk)
	# 尾翼
	_tail(bd, dk)
	# 发动机
	_engine(en, dk)
	# 起落架舱门
	_doors(dk)

# ================================================================
#  机身 — 流线型，前细后粗，整体紧凑
# ================================================================
func _fuselage(m: StandardMaterial3D, d: StandardMaterial3D):
	# 机头锥
	var nose = CSGCylinder3D.new()
	nose.name = "Nose"
	nose.radius = 0.28
	nose.height = 1.8
	nose.sides = 8
	nose.cone = true
	nose.material = m
	nose.rotation_degrees = Vector3(-90, 0, 0)
	nose.position = Vector3(0, 0.08, -3.2)
	add_child(nose)

	# 前机身
	var front = CSGCylinder3D.new()
	front.name = "FrontBody"
	front.radius = 0.28
	front.height = 2.0
	front.sides = 8
	front.material = m
	front.rotation_degrees = Vector3(-90, 0, 0)
	front.position = Vector3(0, 0.08, -2.0)
	add_child(front)

	# 中机身（最宽处）
	var mid = CSGBox3D.new()
	mid.name = "MidBody"
	mid.size = Vector3(0.70, 0.35, 2.5)
	mid.material = m
	mid.position = Vector3(0, 0.10, -0.2)
	add_child(mid)

	# 后机身（发动机段）
	var rear = CSGBox3D.new()
	rear.name = "RearBody"
	rear.size = Vector3(0.60, 0.32, 2.5)
	rear.material = m
	rear.position = Vector3(0, 0.10, 1.8)
	add_child(rear)

	# 机背脊线
	var spine = CSGBox3D.new()
	spine.name = "Spine"
	spine.size = Vector3(0.15, 0.06, 5.5)
	spine.material = m
	spine.position = Vector3(0, 0.30, 0.0)
	add_child(spine)

	# 机身腹部
	var belly = CSGBox3D.new()
	belly.name = "Belly"
	belly.size = Vector3(0.50, 0.04, 4.0)
	belly.material = d
	belly.position = Vector3(0, -0.10, 0.3)
	add_child(belly)

# ================================================================
#  座舱 — 小巧气泡座舱盖
# ================================================================
func _cockpit(m: StandardMaterial3D, d: StandardMaterial3D):
	var bubble = CSGSphere3D.new()
	bubble.name = "Canopy"
	bubble.radius = 0.22
	bubble.material = m
	bubble.position = Vector3(0, 0.30, -1.5)
	add_child(bubble)

	# 座舱后部与机背融合
	var cap_r = CSGBox3D.new()
	cap_r.name = "CanopyRear"
	cap_r.size = Vector3(0.30, 0.10, 0.8)
	cap_r.material = m
	cap_r.rotation_degrees = Vector3(18, 0, 0)
	cap_r.position = Vector3(0, 0.26, -0.8)
	add_child(cap_r)

	# 座舱框线
	var line_l = CSGBox3D.new()
	line_l.name = "CanopyLineL"
	line_l.size = Vector3(0.004, 0.18, 1.2)
	line_l.material = d
	line_l.position = Vector3(-0.20, 0.28, -1.4)
	add_child(line_l)

	var line_r = CSGBox3D.new()
	line_r.name = "CanopyLineR"
	line_r.size = Vector3(0.004, 0.18, 1.2)
	line_r.material = d
	line_r.position = Vector3(0.20, 0.28, -1.4)
	add_child(line_r)

# ================================================================
#  机翼 — 后掠翼，紧凑
# ================================================================
func _wings(m: StandardMaterial3D, d: StandardMaterial3D):
	# 左主翼
	var lw = CSGBox3D.new()
	lw.name = "LeftWing"
	lw.size = Vector3(3.5, 0.03, 1.4)
	lw.material = m
	lw.rotation_degrees = Vector3(0, -35, 0)
	lw.position = Vector3(-2.2, 0.04, 0.2)
	add_child(lw)

	# 左翼根加厚
	var lw_root = CSGBox3D.new()
	lw_root.name = "LeftWingRoot"
	lw_root.size = Vector3(1.5, 0.06, 1.2)
	lw_root.material = m
	lw_root.rotation_degrees = Vector3(0, -30, 0)
	lw_root.position = Vector3(-1.0, 0.06, 0.0)
	add_child(lw_root)

	# 右主翼
	var rw = CSGBox3D.new()
	rw.name = "RightWing"
	rw.size = Vector3(3.5, 0.03, 1.4)
	rw.material = m
	rw.rotation_degrees = Vector3(0, 35, 0)
	rw.position = Vector3(2.2, 0.04, 0.2)
	add_child(rw)

	var rw_root = CSGBox3D.new()
	rw_root.name = "RightWingRoot"
	rw_root.size = Vector3(1.5, 0.06, 1.2)
	rw_root.material = m
	rw_root.rotation_degrees = Vector3(0, 30, 0)
	rw_root.position = Vector3(1.0, 0.06, 0.0)
	add_child(rw_root)

	# 副翼缝线
	var ail_l = CSGBox3D.new()
	ail_l.name = "LeftAileron"
	ail_l.size = Vector3(2.5, 0.004, 0.02)
	ail_l.material = d
	ail_l.rotation_degrees = Vector3(0, -35, 0)
	ail_l.position = Vector3(-2.5, 0.02, 0.8)
	add_child(ail_l)

	var ail_r = CSGBox3D.new()
	ail_r.name = "RightAileron"
	ail_r.size = Vector3(2.5, 0.004, 0.02)
	ail_r.material = d
	ail_r.rotation_degrees = Vector3(0, 35, 0)
	ail_r.position = Vector3(2.5, 0.02, 0.8)
	add_child(ail_r)

	# 翼尖灯
	var ll = CSGSphere3D.new()
	ll.name = "LeftLight"
	ll.radius = 0.025
	ll.material = _mat_red()
	ll.position = Vector3(-3.8, 0.04, 0.8)
	add_child(ll)

	var rl = CSGSphere3D.new()
	rl.name = "RightLight"
	rl.radius = 0.025
	rl.material = _mat_green()
	rl.position = Vector3(3.8, 0.04, 0.8)
	add_child(rl)

# ================================================================
#  尾翼 — 小型后掠垂尾+平尾
# ================================================================
func _tail(m: StandardMaterial3D, d: StandardMaterial3D):
	# 垂尾
	var vt = CSGBox3D.new()
	vt.name = "VStab"
	vt.size = Vector3(0.03, 0.90, 0.70)
	vt.material = m
	vt.position = Vector3(0, 0.60, 2.2)
	add_child(vt)

	# 垂尾顶
	var vt_top = CSGBox3D.new()
	vt_top.name = "VStabTop"
	vt_top.size = Vector3(0.03, 0.25, 0.30)
	vt_top.material = m
	vt_top.position = Vector3(0, 1.00, 2.0)
	add_child(vt_top)

	# 左平尾
	var lh = CSGBox3D.new()
	lh.name = "LeftHTail"
	lh.size = Vector3(1.8, 0.025, 0.60)
	lh.material = m
	lh.rotation_degrees = Vector3(0, -30, 0)
	lh.position = Vector3(-1.0, 0.06, 2.4)
	add_child(lh)

	# 右平尾
	var rh = CSGBox3D.new()
	rh.name = "RightHTail"
	rh.size = Vector3(1.8, 0.025, 0.60)
	rh.material = m
	rh.rotation_degrees = Vector3(0, 30, 0)
	rh.position = Vector3(1.0, 0.06, 2.4)
	add_child(rh)

	# 尾灯
	var tl = CSGSphere3D.new()
	tl.name = "TailLight"
	tl.radius = 0.018
	tl.material = _mat_white()
	tl.position = Vector3(0, 1.05, 2.0)
	add_child(tl)

# ================================================================
#  发动机喷口
# ================================================================
func _engine(m: StandardMaterial3D, d: StandardMaterial3D):
	# 喷口外壳
	var nozzle = CSGCylinder3D.new()
	nozzle.name = "Nozzle"
	nozzle.radius = 0.18
	nozzle.height = 0.6
	nozzle.sides = 12
	nozzle.material = m
	nozzle.rotation_degrees = Vector3(90, 0, 0)
	nozzle.position = Vector3(0, 0.10, 3.2)
	add_child(nozzle)

	# 喷口内部（深色）
	var inner = CSGCylinder3D.new()
	inner.name = "NozzleInner"
	inner.radius = 0.12
	inner.height = 0.5
	inner.sides = 12
	inner.material = d
	inner.rotation_degrees = Vector3(90, 0, 0)
	inner.position = Vector3(0, 0.10, 3.3)
	add_child(inner)

	# 尾椎
	var tail_cone = CSGCylinder3D.new()
	tail_cone.name = "TailCone"
	tail_cone.radius = 0.20
	tail_cone.height = 0.8
	tail_cone.sides = 8
	tail_cone.cone = true
	tail_cone.material = _mat_body()
	tail_cone.rotation_degrees = Vector3(90, 0, 0)
	tail_cone.position = Vector3(0, 0.10, 2.8)
	add_child(tail_cone)

# ================================================================
#  舱门缝线
# ================================================================
func _doors(d: StandardMaterial3D):
	# 前起落架舱门
	var ng = CSGBox3D.new()
	ng.name = "NoseGearDoor"
	ng.size = Vector3(0.15, 0.004, 0.50)
	ng.material = d
	ng.position = Vector3(0, -0.10, -2.0)
	add_child(ng)

	# 主起落架舱门
	var lg = CSGBox3D.new()
	lg.name = "LeftGearDoor"
	lg.size = Vector3(0.40, 0.004, 0.80)
	lg.material = d
	lg.position = Vector3(-0.60, -0.10, 0.0)
	add_child(lg)

	var rg = CSGBox3D.new()
	rg.name = "RightGearDoor"
	rg.size = Vector3(0.40, 0.004, 0.80)
	rg.material = d
	rg.position = Vector3(0.60, -0.10, 0.0)
	add_child(rg)
