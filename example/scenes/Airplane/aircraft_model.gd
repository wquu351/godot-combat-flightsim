@tool
extends Node3D

## 战斗机模型 - 用 CSG 组合搭建

func _ready():
	build_aircraft()

func build_aircraft():
	# === 材质 ===
	var body_mat = StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.3, 0.3, 0.35, 1)
	body_mat.metallic = 0.6
	body_mat.roughness = 0.3
	
	var wing_mat = StandardMaterial3D.new()
	wing_mat.albedo_color = Color(0.25, 0.25, 0.3, 1)
	wing_mat.metallic = 0.5
	wing_mat.roughness = 0.4
	
	var cockpit_mat = StandardMaterial3D.new()
	cockpit_mat.albedo_color = Color(0.4, 0.7, 1.0, 0.7)
	cockpit_mat.metallic = 0.8
	cockpit_mat.roughness = 0.1
	cockpit_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	var exhaust_mat = StandardMaterial3D.new()
	exhaust_mat.albedo_color = Color(0.15, 0.15, 0.15, 1)
	exhaust_mat.metallic = 0.9
	exhaust_mat.roughness = 0.2
	
	var red_mat = StandardMaterial3D.new()
	red_mat.albedo_color = Color(0.8, 0.1, 0.1, 1)
	red_mat.metallic = 0.3
	red_mat.roughness = 0.5
	
	# === 机身（前细后粗的流线型）===
	var fuselage = CSGCylinder3D.new()
	fuselage.name = "Fuselage"
	fuselage.radius = 0.6
	fuselage.height = 6.0
	fuselage.sides = 16
	fuselage.material = body_mat
	fuselage.rotation_degrees = Vector3(90, 0, 0)
	fuselage.position = Vector3(0, 0, 0)
	add_child(fuselage)
	
	# 机头（锥形）
	var nose = CSGCylinder3D.new()
	nose.name = "Nose"
	nose.radius = 0.6
	nose.height = 2.0
	nose.sides = 16
	nose.cone = true
	nose.material = body_mat
	nose.rotation_degrees = Vector3(-90, 0, 0)
	nose.position = Vector3(0, 0, -4.0)
	add_child(nose)
	
	# 机尾（锥形，较细）
	var tail = CSGCylinder3D.new()
	tail.name = "Tail"
	tail.radius = 0.6
	tail.height = 1.5
	tail.sides = 16
	tail.cone = true
	tail.material = body_mat
	tail.rotation_degrees = Vector3(90, 0, 0)
	tail.position = Vector3(0, 0.2, 3.5)
	add_child(tail)
	
	# === 座舱 ===
	var cockpit = CSGSphere3D.new()
	cockpit.name = "Cockpit"
	cockpit.radius = 0.5
	cockpit.material = cockpit_mat
	cockpit.position = Vector3(0, 0.5, -1.5)
	add_child(cockpit)
	
	# 座舱后部
	var cockpit_back = CSGCylinder3D.new()
	cockpit_back.name = "CockpitBack"
	cockpit_back.radius = 0.45
	cockpit_back.height = 1.2
	cockpit_back.sides = 12
	cockpit_back.material = cockpit_mat
	cockpit_back.rotation_degrees = Vector3(90, 0, 0)
	cockpit_back.position = Vector3(0, 0.45, -0.8)
	add_child(cockpit_back)
	
	# === 主翼（三角翼） ===
	# 左翼
	var left_wing = CSGBox3D.new()
	left_wing.name = "LeftWing"
	left_wing.size = Vector3(5.0, 0.08, 2.0)
	left_wing.material = wing_mat
	left_wing.position = Vector3(-3.0, -0.05, 0.3)
	add_child(left_wing)
	
	# 左翼尖（斜切）
	var left_wing_tip = CSGBox3D.new()
	left_wing_tip.name = "LeftWingTip"
	left_wing_tip.size = Vector3(1.5, 0.08, 1.2)
	left_wing_tip.material = wing_mat
	left_wing_tip.position = Vector3(-5.8, -0.05, 0.8)
	# 稍微倾斜
	left_wing_tip.rotation_degrees = Vector3(0, -15, 0)
	add_child(left_wing_tip)
	
	# 右翼
	var right_wing = CSGBox3D.new()
	right_wing.name = "RightWing"
	right_wing.size = Vector3(5.0, 0.08, 2.0)
	right_wing.material = wing_mat
	right_wing.position = Vector3(3.0, -0.05, 0.3)
	add_child(right_wing)
	
	# 右翼尖
	var right_wing_tip = CSGBox3D.new()
	right_wing_tip.name = "RightWingTip"
	right_wing_tip.size = Vector3(1.5, 0.08, 1.2)
	right_wing_tip.material = wing_mat
	right_wing_tip.position = Vector3(5.8, -0.05, 0.8)
	right_wing_tip.rotation_degrees = Vector3(0, 15, 0)
	add_child(right_wing_tip)
	
	# === 垂直尾翼 ===
	var vertical_stabilizer = CSGBox3D.new()
	vertical_stabilizer.name = "VerticalStabilizer"
	vertical_stabilizer.size = Vector3(0.08, 1.8, 1.5)
	vertical_stabilizer.material = wing_mat
	vertical_stabilizer.position = Vector3(0, 1.0, 3.0)
	add_child(vertical_stabilizer)
	
	# 垂直尾翼顶部（斜切）
	var vertical_stab_top = CSGBox3D.new()
	vertical_stab_top.name = "VerticalStabTop"
	vertical_stab_top.size = Vector3(0.08, 0.6, 0.8)
	vertical_stab_top.material = wing_mat
	vertical_stab_top.position = Vector3(0, 1.9, 2.7)
	vertical_stab_top.rotation_degrees = Vector3(0, 0, 0)
	add_child(vertical_stab_top)
	
	# === 水平尾翼 ===
	# 左水平尾翼
	var left_h_stab = CSGBox3D.new()
	left_h_stab.name = "LeftHorizontalStabilizer"
	left_h_stab.size = Vector3(2.0, 0.06, 1.0)
	left_h_stab.material = wing_mat
	left_h_stab.position = Vector3(-1.3, 0.15, 3.0)
	add_child(left_h_stab)
	
	# 右水平尾翼
	var right_h_stab = CSGBox3D.new()
	right_h_stab.name = "RightHorizontalStabilizer"
	right_h_stab.size = Vector3(2.0, 0.06, 1.0)
	right_h_stab.material = wing_mat
	right_h_stab.position = Vector3(1.3, 0.15, 3.0)
	add_child(right_h_stab)
	
	# === 引擎喷口 ===
	var exhaust = CSGCylinder3D.new()
	exhaust.name = "Exhaust"
	exhaust.radius = 0.4
	exhaust.height = 0.5
	exhaust.sides = 12
	exhaust.material = exhaust_mat
	exhaust.rotation_degrees = Vector3(90, 0, 0)
	exhaust.position = Vector3(0, 0.1, 3.8)
	add_child(exhaust)
	
	# === 翼尖导弹挂架 ===
	# 左翼挂架
	var left_pylon = CSGCylinder3D.new()
	left_pylon.name = "LeftPylon"
	left_pylon.radius = 0.08
	left_pylon.height = 0.4
	left_pylon.sides = 8
	left_pylon.material = body_mat
	left_pylon.position = Vector3(-4.5, -0.25, 0.3)
	add_child(left_pylon)
	
	# 右翼挂架
	var right_pylon = CSGCylinder3D.new()
	right_pylon.name = "RightPylon"
	right_pylon.radius = 0.08
	right_pylon.height = 0.4
	right_pylon.sides = 8
	right_pylon.material = body_mat
	right_pylon.position = Vector3(4.5, -0.25, 0.3)
	add_child(right_pylon)
	
	# === 翼尖灯 ===
	var left_light = CSGSphere3D.new()
	left_light.name = "LeftLight"
	left_light.radius = 0.06
	left_light.material = red_mat
	left_light.position = Vector3(-5.5, -0.05, 0.3)
	add_child(left_light)
	
	var right_light = CSGSphere3D.new()
	right_light.name = "RightLight"
	right_light.radius = 0.06
	right_light.material = StandardMaterial3D.new()
	right_light.material.albedo_color = Color(0.1, 0.8, 0.1, 1)
	right_light.position = Vector3(5.5, -0.05, 0.3)
	add_child(right_light)
	
	# === 进气道 ===
	var left_intake = CSGBox3D.new()
	left_intake.name = "LeftIntake"
	left_intake.size = Vector3(0.4, 0.4, 1.5)
	left_intake.material = exhaust_mat
	left_intake.position = Vector3(-0.8, -0.2, -0.5)
	add_child(left_intake)
	
	var right_intake = CSGBox3D.new()
	right_intake.name = "RightIntake"
	right_intake.size = Vector3(0.4, 0.4, 1.5)
	right_intake.material = exhaust_mat
	right_intake.position = Vector3(0.8, -0.2, -0.5)
	add_child(right_intake)
