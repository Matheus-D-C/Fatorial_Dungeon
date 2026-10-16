extends Node
## Efeitos sonoros e pequenos efeitos de interface (autoload "Sfx").
## Uso em qualquer script:  Sfx.tocar("acerto")  /  Sfx.decorar_botoes(self)

const NOMES := ["acerto", "erro", "portal", "entrar_portal", "clique", "hover",
		"painel_abrir", "painel_fechar", "passo", "vitoria", "game_over"]

# Volume de cada som em dB (os que não estão aqui usam o padrão abaixo)
const VOLUMES_DB := {"passo": -14.0, "hover": -12.0, "clique": -6.0, "vitoria": -3.0}
const VOLUME_PADRAO_DB := -8.0

var _sons: Dictionary = {}
var _players: Array[AudioStreamPlayer] = []


func _ready() -> void:
	# Continua funcionando mesmo com o jogo pausado (painel da pergunta aberto)
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in 8:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)
	for nome in NOMES:
		var caminho := "res://sfx/%s.wav" % nome
		if ResourceLoader.exists(caminho):
			_sons[nome] = load(caminho)


func tocar(nome: String) -> void:
	if not _sons.has(nome):
		return
	for p in _players:
		if not p.playing:
			p.stream = _sons[nome]
			p.volume_db = VOLUMES_DB.get(nome, VOLUME_PADRAO_DB)
			p.play()
			return


## Dá som de clique/hover e um leve "crescer" ao passar o mouse em todos os
## botões que estiverem dentro de 'raiz'. O efeito parte da escala que o botão
## já tem na cena e mantém o centro do botão parado (ele só cresce no lugar).
func decorar_botoes(raiz: Node) -> void:
	for no in raiz.find_children("*", "BaseButton", true, false):
		var botao := no as BaseButton
		if botao == null or botao.has_meta("fx_ligado"):
			continue
		botao.set_meta("fx_ligado", true)
		botao.set_meta("fx_escala", botao.scale)
		botao.mouse_entered.connect(_ao_entrar.bind(botao))
		botao.mouse_exited.connect(_ao_sair.bind(botao))
		botao.pressed.connect(tocar.bind("clique"))


func _ao_entrar(botao: BaseButton) -> void:
	if botao.disabled:
		return
	tocar("hover")
	var base: Vector2 = botao.get_meta("fx_escala", Vector2.ONE)
	# Guarda o centro visual do botão enquanto ele está no tamanho normal
	if botao.scale.is_equal_approx(base):
		botao.set_meta("fx_centro", _centro_visual(botao))
	_animar(botao, base * 1.06)


func _ao_sair(botao: BaseButton) -> void:
	var base: Vector2 = botao.get_meta("fx_escala", Vector2.ONE)
	_animar(botao, base)


# Ponto central do botão na tela (considera escala e pivô)
func _centro_visual(b: Control) -> Vector2:
	return b.position + b.pivot_offset + (b.size / 2.0 - b.pivot_offset) * b.scale


# Posição que o botão precisa ter para o centro continuar no mesmo lugar
func _posicao_para(b: Control, centro: Vector2, escala: Vector2) -> Vector2:
	return centro - b.pivot_offset - (b.size / 2.0 - b.pivot_offset) * escala


func _animar(botao: BaseButton, escala_alvo: Vector2) -> void:
	var centro = botao.get_meta("fx_centro", null)
	if centro == null:
		return
	var antigo = botao.get_meta("fx_tween", null)
	if antigo is Tween and antigo.is_valid():
		antigo.kill()
	var t := botao.create_tween().set_parallel(true)
	t.tween_property(botao, "scale", escala_alvo, 0.1)
	t.tween_property(botao, "position", _posicao_para(botao, centro, escala_alvo), 0.1)
	botao.set_meta("fx_tween", t)
