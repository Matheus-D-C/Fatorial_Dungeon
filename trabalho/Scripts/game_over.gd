extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Sfx.tocar("game_over")
	Sfx.decorar_botoes(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_texture_button_pressed() -> void:
	Transicao.mudar_cena("res://cenas/MainMenu.tscn")
