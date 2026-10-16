extends CanvasLayer
## Transição com fade preto entre cenas (autoload "Transicao").
## Uso:  Transicao.mudar_cena("res://cenas/MainMenu.tscn")

var _cortina: ColorRect
var _ocupado := false


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_cortina = ColorRect.new()
	_cortina.color = Color(0, 0, 0, 1)
	_cortina.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_cortina)
	_cortina.set_anchors_preset(Control.PRESET_FULL_RECT)
	# Fade de entrada da primeira cena do jogo
	var t := create_tween()
	t.tween_property(_cortina, "color:a", 0.0, 0.6)


func mudar_cena(caminho: String) -> void:
	if _ocupado:
		return
	_ocupado = true
	_cortina.mouse_filter = Control.MOUSE_FILTER_STOP  # bloqueia cliques durante o fade
	var escurecer := create_tween()
	escurecer.tween_property(_cortina, "color:a", 1.0, 0.25)
	await escurecer.finished

	get_tree().paused = false
	var erro := get_tree().change_scene_to_file(caminho)
	if erro != OK:
		push_warning("Não foi possível carregar a cena: " + caminho)
	# Espera a cena nova entrar na árvore antes de clarear
	await get_tree().process_frame
	await get_tree().process_frame

	var clarear := create_tween()
	clarear.tween_property(_cortina, "color:a", 0.0, 0.3)
	await clarear.finished
	_cortina.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ocupado = false
