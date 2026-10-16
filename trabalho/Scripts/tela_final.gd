extends Control

func _ready() -> void:
	$BtnSair.pressed.connect(_on_btn_sair_pressed)
	Sfx.decorar_botoes(self)
	Sfx.tocar("vitoria")
	_criar_confete()

func _on_btn_sair_pressed() -> void:
	# Fecha o jogo
	get_tree().quit()

# Chuva de confete colorido caindo do topo da tela
func _criar_confete() -> void:
	var largura := get_viewport_rect().size.x
	var c := CPUParticles2D.new()
	c.position = Vector2(largura / 2.0, -10.0)
	c.amount = 90
	c.lifetime = 5.0
	c.preprocess = 3.0  # já começa com confete caindo
	c.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	c.emission_rect_extents = Vector2(largura / 2.0, 1.0)
	c.direction = Vector2(0, 1)
	c.spread = 20.0
	c.gravity = Vector2(0, 40)
	c.initial_velocity_min = 40.0
	c.initial_velocity_max = 90.0
	c.angular_velocity_min = -240.0
	c.angular_velocity_max = 240.0
	c.scale_amount_min = 3.0
	c.scale_amount_max = 6.0
	var cores := Gradient.new()
	cores.offsets = PackedFloat32Array([0.0, 0.25, 0.5, 0.75, 1.0])
	cores.colors = PackedColorArray([
		Color(1.0, 0.35, 0.35), Color(1.0, 0.85, 0.3), Color(0.4, 0.9, 0.5),
		Color(0.4, 0.7, 1.0), Color(0.85, 0.5, 1.0)])
	c.color_initial_ramp = cores
	c.z_index = 10
	add_child(c)
