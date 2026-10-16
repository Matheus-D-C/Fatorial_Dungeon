extends Area2D

# O 'portal_id' que você já tem
@export var portal_id : int = 0

# Para qual cena este portal envia o jogador (arraste a cena pelo Inspetor)
@export_file("*.tscn") var cena_de_destino: String

var portal_is_locked : bool = false
var _particulas: CPUParticles2D

func _ready() -> void:
	add_to_group("portal")
	# Conecta o sinal de quando algo entra na área do portal
	body_entered.connect(_on_body_entered)
	_criar_particulas()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not portal_is_locked:
		ir_para_outra_cena()

func ir_para_outra_cena() -> void:
	if cena_de_destino == "":
		push_warning("Nenhuma cena de destino foi configurada para este portal!")
		return
	# Bloqueia o portal para evitar múltiplos disparos durante a transição
	lock_portal()
	Sfx.tocar("entrar_portal")
	Transicao.mudar_cena(cena_de_destino)

func lock_portal() -> void:
	# A cena é trocada logo em seguida, então o portal fica bloqueado até lá
	portal_is_locked = true

# Chamado pelo MathUi quando o jogador acerta a resposta
func abrir_com_efeito() -> void:
	var escala_final := scale
	show()
	scale = escala_final * 0.2
	modulate.a = 0.0
	Sfx.tocar("portal")
	_particulas.emitting = true
	
	var t := create_tween().set_parallel(true)
	t.tween_property(self, "scale", escala_final, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "modulate:a", 1.0, 0.4)
	t.chain().tween_callback(_pulsar.bind(escala_final))

# Depois de abrir, o portal "respira" devagar
func _pulsar(base: Vector2) -> void:
	var p := create_tween().set_loops()
	p.tween_property(self, "scale", base * 1.06, 0.9).set_trans(Tween.TRANS_SINE)
	p.tween_property(self, "scale", base, 0.9).set_trans(Tween.TRANS_SINE)

# Faíscas azuis que sobem do portal enquanto ele está aberto
func _criar_particulas() -> void:
	_particulas = CPUParticles2D.new()
	_particulas.emitting = false
	_particulas.amount = 20
	_particulas.lifetime = 1.4
	_particulas.local_coords = false
	_particulas.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	_particulas.emission_sphere_radius = 10.0
	_particulas.direction = Vector2(0, -1)
	_particulas.spread = 60.0
	_particulas.gravity = Vector2(0, -12)
	_particulas.initial_velocity_min = 6.0
	_particulas.initial_velocity_max = 16.0
	_particulas.scale_amount_min = 1.5
	_particulas.scale_amount_max = 3.0
	var grad := Gradient.new()
	grad.set_color(0, Color(0.75, 1.0, 1.0, 1.0))
	grad.set_color(1, Color(0.35, 0.55, 1.0, 0.0))
	_particulas.color_ramp = grad
	_particulas.z_index = 2
	add_child(_particulas)
