extends Node2D

# 1. CRIAR AS VARIÁVEIS EXPORTADAS
@export_file("*.tscn") var proxima_fase: String
@export var numero_da_fase: int

# Esta variável vai permitir que você digite a pergunta direto no Inspector de cada fase!
@export_multiline var texto_da_pergunta: String = "Qual é a pergunta desta fase?"

# Referências aos nós da sua fase
@onready var timer_fase: Timer = $TimerFase
# Caminho exato baseado na estrutura do seu MathUi
@onready var problem_label: Label = $MathUi/ControlPanel/ProblemLabel 

func _ready() -> void:
	
	var pergunta_padrao = $MathUi.pergunta_texto
	var resposta_padrao = $MathUi.resposta_alvo
	
	var perg_custom = ConfigGlobais.perguntas_personalizadas.get(numero_da_fase, "")
	var resp_custom = ConfigGlobais.respostas_personalizadas.get(numero_da_fase, "")
	
	if perg_custom.strip_edges() != "":
		$MathUi/ControlPanel/ProblemLabel.text = perg_custom
	else:
		$MathUi/ControlPanel/ProblemLabel.text = pergunta_padrao
	
	if resp_custom.strip_edges() != "":
		$MathUi.resposta_alvo = resp_custom
	else:
		$MathUi.resposta_alvo = resposta_padrao
	
	if ConfigGlobais.timer_ativo:
		if has_node("CanvasLayer/LabelTimer"):
			get_node("CanvasLayer/LabelTimer").visible = true
		if not timer_fase.timeout.is_connected(_on_timer_fase_timeout):
			timer_fase.timeout.connect(_on_timer_fase_timeout)
		timer_fase.start()
	else:
		if has_node("CanvasLayer/LabelTimer"):
			get_node("CanvasLayer/LabelTimer").visible = false
	
	

func _process(_delta: float) -> void:
	# Atualização visual do relógio (opcional, se usar o Label do tempo)
	if ConfigGlobais.timer_ativo and not timer_fase.is_stopped() and has_node("CanvasLayer/LabelTimer"):
		var tempo_restante = timer_fase.time_left
		var minutos = int(tempo_restante) / 60
		var segundos = int(tempo_restante) % 60
		get_node("CanvasLayer/LabelTimer").text = "%02d:%02d" % [minutos, segundos]

func _on_timer_fase_timeout() -> void:
	Transicao.mudar_cena(ConfigGlobais.cena_game_over)
