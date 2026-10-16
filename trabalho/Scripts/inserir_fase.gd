extends Node2D

# Referências corretas de acordo com a sua cena InserirFase.tscn
@onready var edit_pergunta: LineEdit = $Label/LinePergunta
@onready var edit_resposta: LineEdit = $Label6/LineResposta

var fase_atual_editando: int = 1 
var popup_aviso: AcceptDialog

func _ready() -> void:
	Sfx.decorar_botoes(self)
	
	popup_aviso = AcceptDialog.new()
	popup_aviso.title = "Salvo"
	add_child(popup_aviso)
	
	# Conecta os 4 botões de fase que você possui na cena
	$BtnFase1.pressed.connect(func(): mudar_fase_edicao(1)) # Botão do Tutorial
	$BtnFase2.pressed.connect(func(): mudar_fase_edicao(2)) # Botão da Fase 1
	$BtnFase3.pressed.connect(func(): mudar_fase_edicao(3)) # Botão da Fase 2
	$BtnFase4.pressed.connect(func(): mudar_fase_edicao(4)) # Botão da Fase 3

	
	# Mostra a primeira pergunta (Tutorial) logo ao abrir a tela
	atualizar_campos_na_tela()

func mudar_fase_edicao(nova_fase: int) -> void:
	# Salva o que estava escrito antes de mudar de aba
	ConfigGlobais.perguntas_personalizadas[fase_atual_editando] = edit_pergunta.text
	ConfigGlobais.respostas_personalizadas[fase_atual_editando] = edit_resposta.text
	
	# Atualiza para a fase que foi clicada
	fase_atual_editando = nova_fase
	
	# Mostra os textos salvos dessa nova fase selecionada
	atualizar_campos_na_tela()
	print("Editando agora a fase: ", fase_atual_editando)

func atualizar_campos_na_tela() -> void:
	edit_pergunta.text = ConfigGlobais.perguntas_personalizadas[fase_atual_editando]
	edit_resposta.text = ConfigGlobais.respostas_personalizadas[fase_atual_editando]

func _on_btn_salvar_pressed() -> void:
	# Salva definitivamente o texto atual na fase selecionada
	ConfigGlobais.perguntas_personalizadas[fase_atual_editando] = edit_pergunta.text
	ConfigGlobais.respostas_personalizadas[fase_atual_editando] = edit_resposta.text
	
	popup_aviso.dialog_text = "Fase " + str(fase_atual_editando) + " salva com sucesso!"
	popup_aviso.popup_centered()


func _on_btn_voltar_pressed() -> void:
	Transicao.mudar_cena("res://cenas/MainMenu.tscn")
