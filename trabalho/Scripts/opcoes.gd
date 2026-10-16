extends Node2D

@onready var check_button: CheckButton = $TimerLigar
@onready var master_audio = AudioServer.get_bus_index("Master")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Sfx.decorar_botoes(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_h_slider_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(master_audio, linear_to_db(value))
	
	if value == 0:
		AudioServer.set_bus_mute(master_audio, true)
	else:
		AudioServer.set_bus_mute(master_audio, false)


func _on_timer_ligar_toggled(toggled_on: bool) -> void:
	ConfigGlobais.timer_ativo = toggled_on


func _on_button_pressed() -> void:
	Transicao.mudar_cena("res://cenas/MainMenu.tscn")
