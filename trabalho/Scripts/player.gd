extends CharacterBody2D

@export var walk_speed = 15.0
const TILE_SIZE = 16

# Trocado para apontar para o seu AnimatedSprite2D
@onready var sprite = $AnimatedSprite2D
@onready var ray = $RayCast2D 

var initial_position = Vector2(0, 0)
var input_direction = Vector2(0, 0)
var is_moving = false
var percent_moved_to_next_tile = 0.0

func _ready():
	initial_position = position
	
	# AJUSTE DE POSIÇÃO: Coloca o RayCast nos pés do personagem
	ray.position = Vector2(0, 4) # Ajuste esse '4' se precisar alinhar melhor no editor
	
func _physics_process(delta):
	if !is_moving:
		process_player_input()
	else:
		move(delta)
		
func process_player_input():
	var current_input = Vector2.ZERO
	current_input.x = int(Input.is_action_pressed("ir_direita")) - int(Input.is_action_pressed("ir_esquerda"))
	
	if current_input.x == 0:
		current_input.y = int(Input.is_action_pressed("ir_baixo")) - int(Input.is_action_pressed("ir_cima"))
	
	if current_input != Vector2.ZERO:
		input_direction = current_input
		
		# --- CHECAGEM DE COLISÃO ---
		ray.target_position = input_direction * TILE_SIZE
		ray.force_raycast_update()
		
		if ray.is_colliding():
			# Se colidir, apenas vira o personagem na direção do obstáculo, mas fica parado
			atualizar_animacao(input_direction, false)
			return 
		
		# Inicia o movimento e ativa a animação de andar
		atualizar_animacao(input_direction, true)
		
		initial_position = position
		is_moving = true
	else:
		# Se não há comandos, fica parado olhando para a última direção
		atualizar_animacao(input_direction, false)

func move(delta):
	percent_moved_to_next_tile += walk_speed * delta
	
	if percent_moved_to_next_tile >= 1.0:
		position = initial_position + (TILE_SIZE * input_direction)
		percent_moved_to_next_tile = 0.0
		is_moving = false
		Sfx.tocar("passo")
		
		var check_input = Vector2.ZERO
		check_input.x = int(Input.is_action_pressed("ir_direita")) - int(Input.is_action_pressed("ir_esquerda"))
		check_input.y = int(Input.is_action_pressed("ir_baixo")) - int(Input.is_action_pressed("ir_cima"))
		
		if check_input == Vector2.ZERO:
			atualizar_animacao(input_direction, false)
	else:
		position = initial_position + (TILE_SIZE * input_direction * percent_moved_to_next_tile)

# Nova função que gerencia o AnimatedSprite2D diretamente
func atualizar_animacao(direcao: Vector2, movendo: bool):
	if direcao.x > 0:
		sprite.play("AndandoDireita")
	elif direcao.x < 0:
		sprite.play("AndandoEsquerda")
	elif direcao.y > 0:
		sprite.play("AndandoBaixo")
	elif direcao.y < 0:
		sprite.play("AndandoCima")
	
	# Se o personagem não estiver andando, pausa a animação e volta para o frame 0 (pose em pé)
	if not movendo:
		sprite.stop()
		sprite.frame = 0
