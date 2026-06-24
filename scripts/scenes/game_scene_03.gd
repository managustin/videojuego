# game_scene_03.gd
# Tercera escena: El Duelo de la Taberna.
# Muestra el fondo de duelo, realiza fundidos y prepara la transición final.

extends Control

@onready var background: TextureRect = $Background
@onready var lives_container: HBoxContainer = $LivesContainer
@onready var narrative_label: Label = $NarrativeLabel
@onready var enemy_hitbox: Area2D = $EnemyHitbox
@onready var enemy_sprite: AnimatedSprite2D = $EnemyHitbox/EnemySprite

# ---------- Configuración de Fondos ----------
## Textura de fondo para el duelo en la taberna.
@export var bg_taberna_duelo: Texture2D

# ---------- Variables de Control ----------
var _fade_overlay: ColorRect


func _ready() -> void:
	# 1. Configurar vidas
	_update_lives_display()
	GameManager.lives_changed.connect(_on_lives_changed)

	# 2. Configurar la textura inicial si está asignada
	if bg_taberna_duelo:
		background.texture = bg_taberna_duelo
	else:
		push_warning("game_scene_03: bg_taberna_duelo no está asignada en el Inspector.")

	# 3. Crear overlay de fundido de forma dinámica
	_fade_overlay = ColorRect.new()
	_fade_overlay.color = Color(0, 0, 0, 1) # Inicia en negro para el fade-in
	_fade_overlay.size = Vector2(1920, 1080)
	_fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$CanvasLayer.add_child(_fade_overlay)

	# 4. Texto informativo temporal del duelo
	narrative_label.text = "Prepárate..."
	narrative_label.add_theme_font_size_override("font_size", 36)
	narrative_label.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2)) # Rojo

	# 5. Iniciar secuencia
	_iniciar_secuencia()


## Secuencia principal de la escena.
func _iniciar_secuencia() -> void:
	# A. Fade-in (desvanecer negro a transparente)
	var fade_in = create_tween()
	fade_in.tween_property(_fade_overlay, "color:a", 0.0, 1.0)
	await fade_in.finished

	# B. Esperar un tiempo para simular la tensión del duelo por ahora
	await get_tree().create_timer(3.0).timeout

	# C. Fundido a negro final (fade-out)
	var fade_out = create_tween()
	fade_out.tween_property(_fade_overlay, "color:a", 1.0, 1.0)
	await fade_out.finished

	# D. Avanzar en GameManager (que cargará la pantalla de resultados)
	GameManager.game_result = "victory"
	GameManager.go_to_next_scene()


# ---------- Sistema de Vidas ----------

func _update_lives_display() -> void:
	for child in lives_container.get_children():
		child.queue_free()
	for i in GameManager.lives:
		var heart := Label.new()
		heart.text = "♥"
		heart.add_theme_font_size_override("font_size", 32)
		heart.add_theme_color_override("font_color", Color.RED)
		heart.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lives_container.add_child(heart)


func _on_lives_changed(_new_lives: int) -> void:
	_update_lives_display()
