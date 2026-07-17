# dev_start.gd
# Entrada temporal para trabajar desde el duelo dentro de la taberna.
# Conserva intacto el flujo normal y posiciona correctamente GameManager
# para que, al ganar, se avance a la siguiente escena en desarrollo.

extends Node

const START_SCENE: String = "res://scenes/game_scene_03.tscn"


func _ready() -> void:
	GameManager.reset_game()
	var start_index := GameManager.scene_order.find(START_SCENE)
	if start_index == -1:
		push_error("dev_start: La escena inicial no está incluida en GameManager.scene_order")
		return

	GameManager.current_scene_index = start_index
	GameManager.call_deferred("go_to_scene", START_SCENE)
