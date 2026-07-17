# game_scene_04.gd
# Coordina las tres tomas de la cinemática. Los recursos visuales se asignan
# manualmente desde el Inspector.

extends Control

@export_group("Personaje")
@export_range(0.0, 10.0, 0.1, "or_greater") var demora_inicial: float = 1.0
@export var animacion_personaje: StringName = &"pj_que_quilombo"
@export_multiline var texto_personaje: String = "Qué quilombo..."
@export_range(0.0, 10.0, 0.1, "or_greater") var duracion_dialogo_personaje: float = 2.5

@export_group("Llamado y zoom")
@export_range(0.0, 10.0, 0.1, "or_greater") var demora_grito_exterior: float = 0.5
@export var texto_llamado: String = "¡HEY!"
@export_range(0.0, 10.0, 0.1, "or_greater") var duracion_llamado_antes_del_zoom: float = 1.0
@export var objetivo_zoom: Vector2 = Vector2(350.0, 325.0)
@export_range(1.0, 4.0, 0.1, "or_greater") var nivel_zoom: float = 1.6
@export_range(0.0, 10.0, 0.1, "or_greater") var duracion_zoom: float = 1.0

@export_group("Segunda toma: enemigo")
@export var animacion_enemigo: StringName = &"enemigo_gritando"
@export_range(0.0, 10.0, 0.1, "or_greater") var demora_dialogo_enemigo: float = 0.1
@export_multiline var texto_grito_exterior: String = "¡Salí de ahí! ¡Te metiste con quien no debías!"
@export_range(0.0, 10.0, 0.1, "or_greater") var duracion_grito_exterior: float = 3.0

@export_group("Tercera toma: personaje")
@export_range(0.0, 10.0, 0.1, "or_greater") var demora_dialogo_tercera_toma: float = 1.0
@export_multiline var texto_dialogo_tercera_toma: String = "¡No me dejaban dormir!"
@export_range(0.0, 10.0, 0.1, "or_greater") var duracion_dialogo_tercera_toma: float = 3.0
@export_range(0.0, 10.0, 0.1, "or_greater") var demora_entre_dialogos: float = 0.3
@export_multiline var texto_dialogo_final: String = "... ahora tengo que ver cómo soluciono esto."
@export_range(0.0, 10.0, 0.1, "or_greater") var duracion_dialogo_final: float = 3.0
@export_range(0.0, 10.0, 0.1, "or_greater") var demora_antes_del_fade: float = 0.3
@export_range(0.0, 10.0, 0.1, "or_greater") var duracion_fade_out: float = 1.2

@onready var background: TextureRect = $Background
@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var player_dialogue_bubble: PanelContainer = $DialogueBubble
@onready var player_dialogue_label: Label = $DialogueBubble/DialogueLabel
@onready var outside_dialogue_bubble: PanelContainer = $OutsideDialogueBubble
@onready var outside_dialogue_label: Label = $OutsideDialogueBubble/DialogueLabel
@onready var enemy_background: TextureRect = $EnemyBackground
@onready var enemy_sprite: AnimatedSprite2D = $EnemySprite
@onready var enemy_companion_left: Sprite2D = $EnemyCompanionLeft
@onready var enemy_companion_right: Sprite2D = $EnemyCompanionRight
@onready var enemy_dialogue_bubble: PanelContainer = $EnemyDialogueBubble
@onready var enemy_dialogue_label: Label = $EnemyDialogueBubble/DialogueLabel
@onready var third_background: TextureRect = $ThirdBackground
@onready var third_dialogue_bubble: PanelContainer = $ThirdDialogueBubble
@onready var third_dialogue_label: Label = $ThirdDialogueBubble/DialogueLabel
@onready var fade_overlay: ColorRect = $FadeOverlay

var _initial_scale: Vector2
var _initial_pivot_offset: Vector2


func _ready() -> void:
	_initial_scale = scale
	_initial_pivot_offset = pivot_offset
	player_dialogue_bubble.visible = false
	outside_dialogue_bubble.visible = false
	enemy_background.visible = false
	enemy_sprite.visible = false
	enemy_companion_left.visible = false
	enemy_companion_right.visible = false
	enemy_dialogue_bubble.visible = false
	third_background.visible = false
	third_dialogue_bubble.visible = false
	fade_overlay.visible = false
	fade_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	player_sprite.stop()
	player_sprite.frame = 0
	enemy_sprite.stop()
	_play_dialogue_sequence()


func _play_dialogue_sequence() -> void:
	await _wait(demora_inicial)

	player_dialogue_label.text = texto_personaje
	player_dialogue_bubble.visible = true
	_play_player_animation()

	await _wait(duracion_dialogo_personaje)
	player_dialogue_bubble.visible = false

	await _wait(demora_grito_exterior)
	outside_dialogue_label.text = texto_llamado
	outside_dialogue_bubble.visible = true

	await _wait(duracion_llamado_antes_del_zoom)
	await _zoom_to_window()
	_change_to_enemy_shot()
	await _wait(demora_dialogo_enemigo)

	enemy_dialogue_label.text = texto_grito_exterior
	enemy_dialogue_bubble.visible = true
	await _wait(duracion_grito_exterior)
	enemy_dialogue_bubble.visible = false

	_change_to_third_shot()
	await _wait(demora_dialogo_tercera_toma)
	third_dialogue_label.text = texto_dialogo_tercera_toma
	third_dialogue_bubble.visible = true
	await _wait(duracion_dialogo_tercera_toma)
	third_dialogue_bubble.visible = false

	await _wait(demora_entre_dialogos)
	third_dialogue_label.text = texto_dialogo_final
	third_dialogue_bubble.visible = true
	await _wait(duracion_dialogo_final)
	third_dialogue_bubble.visible = false

	await _wait(demora_antes_del_fade)
	await _fade_out()
	GameManager.game_result = "victory"
	GameManager.go_to_result()


func _play_player_animation() -> void:
	if player_sprite.sprite_frames == null:
		push_warning("game_scene_04: Asigná los SpriteFrames de PlayerSprite desde el Inspector.")
		return

	if not player_sprite.sprite_frames.has_animation(animacion_personaje):
		push_warning("game_scene_04: No existe la animación '" + String(animacion_personaje) + "'.")
		return

	player_sprite.play(animacion_personaje)


func _change_to_enemy_shot() -> void:
	outside_dialogue_bubble.visible = false
	background.visible = false
	player_sprite.visible = false

	# Esta toma ya es un primer plano, por eso no hereda el zoom anterior.
	scale = _initial_scale
	pivot_offset = _initial_pivot_offset
	enemy_background.visible = true
	enemy_sprite.visible = true
	enemy_companion_left.visible = true
	enemy_companion_right.visible = true
	_play_enemy_animation()


func _play_enemy_animation() -> void:
	if enemy_sprite.sprite_frames == null:
		push_warning("game_scene_04: Asigná los SpriteFrames de EnemySprite desde el Inspector.")
		return

	if not enemy_sprite.sprite_frames.has_animation(animacion_enemigo):
		push_warning("game_scene_04: No existe la animación del enemigo '" + String(animacion_enemigo) + "'.")
		return

	enemy_sprite.play(animacion_enemigo)


func _change_to_third_shot() -> void:
	enemy_background.visible = false
	enemy_sprite.visible = false
	enemy_companion_left.visible = false
	enemy_companion_right.visible = false
	enemy_dialogue_bubble.visible = false
	third_background.visible = true


func _fade_out() -> void:
	fade_overlay.visible = true
	fade_overlay.color = Color(0.0, 0.0, 0.0, 0.0)

	if duracion_fade_out <= 0.0:
		fade_overlay.color = Color.BLACK
		return

	var fade_tween := create_tween()
	fade_tween.tween_property(fade_overlay, "color:a", 1.0, duracion_fade_out)
	await fade_tween.finished


func _zoom_to_window() -> void:
	pivot_offset = objetivo_zoom

	if duracion_zoom <= 0.0:
		scale *= nivel_zoom
		return

	var zoom_tween := create_tween()
	zoom_tween.set_trans(Tween.TRANS_QUAD)
	zoom_tween.set_ease(Tween.EASE_IN_OUT)
	zoom_tween.tween_property(self, "scale", scale * nivel_zoom, duracion_zoom)
	await zoom_tween.finished


func _wait(seconds: float) -> void:
	if seconds > 0.0:
		await get_tree().create_timer(seconds).timeout
