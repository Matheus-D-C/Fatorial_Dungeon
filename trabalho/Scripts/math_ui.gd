extends CanvasLayer

# --- CONFIGURAÇÃO MANUAL NO INSPECTOR ---
@export_group("Configurações do Desafio")
@export var pergunta_texto: String = "Sua pergunta personalizada aqui?"
@export var resposta_alvo: String = "Resposta"

# --- REFERÊNCIAS DOS NÓS ---
@onready var control_panel = $ControlPanel
@onready var answer_input = $ControlPanel/AnswerInput
@onready var problem_label = $ControlPanel/ProblemLabel
@onready var feedback_label = $ControlPanel/FeedbackLabel
@onready var portal = $"../Portal"

# A fonte do jogo (Minecraft.ttf) não tem acentos, então os textos novos não usam
const NOMES_FASES := {1: "Tutorial", 2: "Fase 1", 3: "Fase 2", 4: "Fase 3"}
const DICA_PERGUNTA := "[R] Abrir desafio     [ESC] Menu"
const DICA_PORTAL := "Portal aberto! Encontre-o no mapa     [ESC] Menu"

var _dica: Label
var _resolvido := false
var _tween_tremor: Tween
var _pos_painel := Vector2.ZERO
var _pos_capturada := false
var _placeholder_original := ""

func _ready():
	# Configuração inicial de visibilidade e estado
	control_panel.hide()
	feedback_label.hide()
	_placeholder_original = answer_input.placeholder_text
	
	if portal:
		portal.hide()
		portal.set_deferred("monitoring", false)
	
	# Define o texto da pergunta que você configurou no Inspector
	problem_label.text = pergunta_texto
	
	_criar_dica()
	_mostrar_titulo_fase()

func _input(event):
	# Tecla ESC: se o painel da pergunta estiver aberto, fecha o painel;
	# se estiver fechado, volta para o menu principal
	if event.is_action_pressed("ui_cancel"):
		# Marca o evento como tratado ANTES de trocar de cena, porque depois
		# da troca este nó sai da árvore e get_viewport() vira null
		get_viewport().set_input_as_handled()
		if control_panel.visible:
			Sfx.tocar("painel_fechar")
			fechar_painel()
		else:
			voltar_ao_menu()
		return
	
	# Tecla R abre e fecha a interface
	if event.is_action_pressed("abrir_problema"):
		if control_panel.visible:
			Sfx.tocar("painel_fechar")
			fechar_painel()
		else:
			abrir_painel()

func abrir_painel():
	# Reseta a UI para o modo de pergunta
	feedback_label.hide()
	problem_label.show()
	answer_input.show()
	answer_input.clear()
	answer_input.placeholder_text = _placeholder_original
	answer_input.modulate = Color.WHITE
	
	# Guarda a posição original do painel (usada no tremor de resposta errada)
	if not _pos_capturada:
		_pos_painel = control_panel.position
		_pos_capturada = true
	if _tween_tremor and _tween_tremor.is_valid():
		_tween_tremor.kill()
	control_panel.position = _pos_painel
	
	control_panel.show()
	if _dica:
		_dica.hide()
	Sfx.tocar("painel_abrir")
	
	# FOCO: Isso garante que você consiga digitar imediatamente
	answer_input.grab_focus() 
	
	# Pausa o jogo (Certifique-se que o MathUI tenha Process Mode = Always)
	get_tree().paused = true
	
	# Impede que a tecla 'R' que abriu o painel seja escrita na caixa
	get_viewport().set_input_as_handled()

func fechar_painel():
	control_panel.hide()
	get_tree().paused = false
	_atualizar_dica()

# CONECTE O SINAL 'text_submitted' DO LINEEDIT AQUI
func _on_answer_input_text_submitted(new_text):
	if _resolvido:
		return
	
	var fase_raiz = get_parent()
	var num_fase = fase_raiz.numero_da_fase
	
	var resposta_certa = ConfigGlobais.respostas_personalizadas.get(num_fase, "")
	
	if resposta_certa == "":
		resposta_certa = resposta_alvo
	
	if new_text.strip_edges().to_lower() == resposta_certa.strip_edges().to_lower():
		exibir_vitoria()
	else:
		resposta_errada()

func resposta_errada():
	Sfx.tocar("erro")
	answer_input.clear()
	answer_input.placeholder_text = "Resposta incorreta, tente de novo!"
	answer_input.modulate = Color(1.0, 0.45, 0.45)
	
	# Painel "balança" e o campo volta à cor normal
	if _tween_tremor and _tween_tremor.is_valid():
		_tween_tremor.kill()
	control_panel.position = _pos_painel
	_tween_tremor = create_tween()
	for desl in [10.0, -10.0, 7.0, -7.0, 3.0, 0.0]:
		_tween_tremor.tween_property(control_panel, "position:x", _pos_painel.x + desl, 0.05)
	_tween_tremor.tween_property(answer_input, "modulate", Color.WHITE, 0.4)

func exibir_vitoria():
	_resolvido = true
	Sfx.tocar("acerto")
	
	# Esconde a pergunta e a entrada de texto para destacar o parabéns
	problem_label.hide()
	answer_input.hide()
	feedback_label.show()
	
	# A mensagem "pula" na tela e, depois de 2 segundos, o portal é liberado
	feedback_label.pivot_offset = feedback_label.size / 2.0
	feedback_label.scale = Vector2(0.6, 0.6)
	var t := create_tween()
	t.tween_property(feedback_label, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_interval(1.65)
	t.tween_callback(liberar_portal)

func liberar_portal():
	fechar_painel()
	if portal:
		portal.set_deferred("monitoring", true)
		if portal.has_method("abrir_com_efeito"):
			portal.abrir_com_efeito()
		else:
			portal.show()
		print("Portal aberto e colisão ativada!")

func voltar_ao_menu():
	# A transição cuida de despausar e trocar a cena com fade
	Transicao.mudar_cena("res://cenas/MainMenu.tscn")

# --- EXTRAS VISUAIS ---

func _novo_label(texto: String, tamanho: int) -> Label:
	var l := Label.new()
	l.text = texto
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var fonte := load("res://fonte/Minecraft.ttf") as Font
	if fonte:
		l.add_theme_font_override("font", fonte)
	l.add_theme_font_size_override("font_size", tamanho)
	l.add_theme_color_override("font_color", Color(1, 1, 1))
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	l.add_theme_constant_override("outline_size", 6)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

func _criar_dica():
	_dica = _novo_label(DICA_PERGUNTA, 16)
	add_child(_dica)
	_dica.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE, 24)
	_dica.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_dica.grow_vertical = Control.GROW_DIRECTION_BEGIN
	# Pisca de leve para chamar atenção sem atrapalhar
	var t := create_tween().set_loops()
	t.tween_property(_dica, "modulate:a", 0.45, 0.9).set_trans(Tween.TRANS_SINE)
	t.tween_property(_dica, "modulate:a", 1.0, 0.9).set_trans(Tween.TRANS_SINE)

func _atualizar_dica():
	if _dica == null:
		return
	_dica.text = DICA_PORTAL if _resolvido else DICA_PERGUNTA
	_dica.show()

func _mostrar_titulo_fase():
	var fase = get_parent()
	if fase == null or not ("numero_da_fase" in fase):
		return
	var nome: String = NOMES_FASES.get(fase.numero_da_fase, "")
	if nome == "":
		return
	var titulo := _novo_label(nome, 36)
	add_child(titulo)
	titulo.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE, 48)
	titulo.grow_horizontal = Control.GROW_DIRECTION_BOTH
	titulo.modulate.a = 0.0
	var t := create_tween()
	t.tween_interval(0.5)  # espera o fade de entrada da cena
	t.tween_property(titulo, "modulate:a", 1.0, 0.4)
	t.tween_interval(1.4)
	t.tween_property(titulo, "modulate:a", 0.0, 0.7)
	t.tween_callback(titulo.queue_free)
