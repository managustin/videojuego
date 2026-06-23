# game_scene_02.gd
# Segunda escena de la taberna.
# Muestra al jugador ingresando a la taberna, tirando un diálogo,
# cambiando el fondo al enemigo sentado, mostrando su diálogo y transicionando.

extends Control

@onready var background: TextureRect = $Background
@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var lives_container: HBoxContainer = $LivesContainer
@onready var narrative_label: Label = $NarrativeLabel

# ---------- Configuración de Fondos y Animaciones ----------
## Textura de fondo del bar visto desde adentro (puerta).
@export var bg_taberna_adentro: Texture2D
## Textura de fondo del bar con el enemigo sentado.
@export var bg_enemigo_sentado: Texture2D
## Nombre de la animación de entrada del jugador.
@export var entry_animation_name: String = "entra_taberna"

# ---------- Configuración de Diálogos ----------
## Diálogo que dirá el jugador al llegar a la barra.
@export var player_dialogue: String = "Está todo muy vacío acá..."
## Diálogo que dirá el enemigo sentado.
@export var enemy_dialogue: String = "Este pueblito es muy chico para los dos..."
## Tiempo en segundos que durará cada globo de diálogo en pantalla.
@export var dialogue_duration: float = 2.5
## Coordenadas de pantalla locales donde aparecerá el globo de diálogo del enemigo.
@export var enemy_bubble_position: Vector2 = Vector2(1200, 450)
## Distancia vertical hacia arriba desde la posición del jugador para el globo de diálogo.
@export var player_dialogue_offset_y: float = 170.0

# ---------- Variables de Control ----------
var _fade_overlay: ColorRect


func _ready() -> void:
	# Asegurar que el personaje no comience a animarse durante la pantalla negra de inicio
	player_sprite.stop()
	player_sprite.frame = 0

	# 1. Configurar vidas
	_update_lives_display()
	GameManager.lives_changed.connect(_on_lives_changed)

	# 2. Configurar la textura inicial si está asignada
	if bg_taberna_adentro:
		background.texture = bg_taberna_adentro
	else:
		push_warning("game_scene_02: bg_taberna_adentro no está asignada en el Inspector.")

	# 3. Crear overlay de fundido de forma dinámica
	_fade_overlay = ColorRect.new()
	_fade_overlay.color = Color(0, 0, 0, 1) # Inicia en negro para el fade-in
	_fade_overlay.size = Vector2(1920, 1080)
	_fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$CanvasLayer.add_child(_fade_overlay)

	# 4. Limpiar etiquetas iniciales
	narrative_label.text = ""

	# 5. Iniciar secuencia
	_iniciar_secuencia()


## Secuencia principal de la escena.
func _iniciar_secuencia() -> void:
	# A. Reproducir la animación de entrada justo cuando empieza el fade-in
	var anim_started = false
	if player_sprite.sprite_frames and player_sprite.sprite_frames.has_animation(entry_animation_name):
		# Asegurar que no tenga loop
		player_sprite.sprite_frames.set_animation_loop(entry_animation_name, false)
		player_sprite.play(entry_animation_name)
		anim_started = true
	else:
		# Fallback por si la animación no se ha cargado en el editor todavía
		push_warning("game_scene_02: Animación '" + entry_animation_name + "' no encontrada en PlayerSprite.")

	# B. Fade-in (desvanecer negro a transparente)
	var fade_in = create_tween()
	fade_in.tween_property(_fade_overlay, "color:a", 0.0, 1.0)
	await fade_in.finished

	# C. Esperar a que termine la caminata
	if anim_started:
		await player_sprite.animation_finished
	else:
		# Esperar tiempo simulado si la animación no está cargada
		await get_tree().create_timer(3.0).timeout

	# D. Diálogo del personaje principal
	await _mostrar_globo_dialogo(
		player_dialogue,
		_obtener_posicion_cabeza_pj()
	)

	# D. Cambio de plano (cambiar fondo al enemigo sentado)
	# Desvanecer a negro rápido (0.3s) para simular el pestañeo/cambio de plano
	var cut_out = create_tween()
	cut_out.tween_property(_fade_overlay, "color:a", 1.0, 0.3)
	await cut_out.finished

	# Cambiar la textura del fondo
	if bg_enemigo_sentado:
		background.texture = bg_enemigo_sentado
	else:
		push_warning("game_scene_02: bg_enemigo_sentado no asignado.")
	
	# Ocultar sprite del jugador para enfocar el plano del enemigo
	player_sprite.visible = false

	# Fundir de vuelta a visible rápido (0.3s)
	var cut_in = create_tween()
	cut_in.tween_property(_fade_overlay, "color:a", 0.0, 0.3)
	await cut_in.finished

	# E. Diálogo del enemigo sentado
	await _mostrar_globo_dialogo(
		enemy_dialogue,
		enemy_bubble_position
	)

	# F. Fundido a negro final (fade-out)
	var fade_out = create_tween()
	fade_out.tween_property(_fade_overlay, "color:a", 1.0, 1.0)
	await fade_out.finished

	# G. Avanzar en GameManager
	GameManager.game_result = "victory"
	GameManager.go_to_next_scene()


## Muestra un globo de diálogo estilizado en las coordenadas dadas.
func _mostrar_globo_dialogo(texto: String, posicion: Vector2) -> void:
	var bubble = PanelContainer.new()
	add_child(bubble)
	
	# Estilo western oscuro/oro
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.18, 0.12, 0.08, 0.95)
	style.border_color = Color(0.8, 0.65, 0.45)
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	bubble.add_theme_stylebox_override("panel", style)
	
	var label = Label.new()
	label.text = texto
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color(0.95, 0.92, 0.85))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bubble.add_child(label)
	
	# Esperar un frame de layout de Godot para conocer el tamaño real
	await get_tree().process_frame
	
	var target_x = posicion.x - (bubble.size.x / 2.0)
	var target_y = posicion.y - bubble.size.y
	
	bubble.position = Vector2(target_x, target_y + 15)
	bubble.modulate.a = 0.0
	
	# Animación pop-up de entrada
	var pop_tween = create_tween().set_parallel(true)
	pop_tween.tween_property(bubble, "position:y", target_y, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pop_tween.tween_property(bubble, "modulate:a", 1.0, 0.2)
	
	# Esperar a que se lea
	await get_tree().create_timer(dialogue_duration).timeout
	
	# Desvanecer de salida
	var fade_tween = create_tween().set_parallel(true)
	fade_tween.tween_property(bubble, "position:y", target_y - 10, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	fade_tween.tween_property(bubble, "modulate:a", 0.0, 0.2)
	await fade_tween.finished
	bubble.queue_free()
	
	
## Calcula una posición aproximada sobre la cabeza del personaje.
func _obtener_posicion_cabeza_pj() -> Vector2:
	# Si el sprite se reubica, calculamos dinámicamente en base a su posición local
	var pj_x = player_sprite.position.x
	# Ajuste del offset del frame si tiene
	pj_x += player_sprite.offset.x * player_sprite.scale.x
	
	var pj_y = player_sprite.position.y - player_dialogue_offset_y # arriba del pivote
	return Vector2(pj_x, pj_y)


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
