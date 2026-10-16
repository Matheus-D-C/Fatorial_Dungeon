extends Control

# Certifique-se de que os caminhos das suas cenas estão corretos!
# Se suas cenas estiverem em outras pastas, ajuste os caminhos abaixo.
@export_file("*.tscn") var cena_fase_1: String = "res://cenas/level_1.tscn"
@export_file("*.tscn") var cena_tutorial: String = "res://cenas/Tutorial.tscn"
@export_file("*.tscn") var cena_inserir: String = "uid://i5y825fhaovl"
@export_file("*.tscn") var cena_opcoes: String = "res://cenas/Opcoes.tscn"

func _ready() -> void:
	
	# Força o celular a deitar a tela no modo Paisagem (Landscape)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # Garante que o toque funcione
	
	# Conecta os sinais de clique dos botões às suas respectivas funções
	$BtnJogar.pressed.connect(_on_btn_jogar_pressed)
	$BtnTutorial.pressed.connect(_on_btn_tutorial_pressed)
	$BtnSair.pressed.connect(_on_btn_sair_pressed)
	$Button.pressed.connect(_on_button_pressed)
	
	$BtnOpcoes.pressed.connect(_on_btn_opcoes_pressed)
	
	# Sons e animação nos botões
	Sfx.decorar_botoes(self)
	_animar_entrada_dos_botoes()

func _on_btn_jogar_pressed() -> void:
	if cena_fase_1 != "":
		Transicao.mudar_cena(cena_fase_1)
	else:
		print("Erro: Caminho da Fase 1 não configurado!")

func _on_btn_tutorial_pressed() -> void:
	if cena_tutorial != "":
		Transicao.mudar_cena(cena_tutorial)
	else:
		print("Erro: Caminho do Tutorial não configurado!")

func _on_btn_sair_pressed() -> void:
	# Fecha o jogo
	get_tree().quit()

func _on_button_pressed() -> void:
	if cena_inserir != "":
		Transicao.mudar_cena(cena_inserir)
	else:
		print("Erro: Caminho da cena Inserir não configurado")

func _on_btn_opcoes_pressed() -> void:
	if cena_inserir != "":
		Transicao.mudar_cena(cena_opcoes)
	else:
		print("Erro: Caminho da cena Inserir não configurado")

# Os botões aparecem um depois do outro quando o menu abre
func _animar_entrada_dos_botoes() -> void:
	var i := 0
	for b in [$BtnJogar, $BtnTutorial, $BtnOpcoes, $Button, $BtnSair]:
		b.modulate.a = 0.0
		var t := create_tween()
		t.tween_interval(0.35 + 0.1 * i)
		t.tween_property(b, "modulate:a", 1.0, 0.35)
		i += 1
