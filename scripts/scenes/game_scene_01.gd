# game_scene_01.gd
# Escena del duelo. El personaje entra caminando, se activa el QTE,
# y el jugador debe disparar haciendo clic sobre el enemigo.

extends Control

@onready var narrative_label: Label = $NarrativeLabel
@onready var lives_container: HBoxContainer = $LivesContainer
@onready var qte_prompt: Control = $QTEPrompt
@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var enemy_sprite: AnimatedSprite2D = $EnemyHitbox/EnemySprite

## Duración en segundos de la caminata de entrada.
@export var walk_duration: float = 2.5

## Posición en pantalla global (1920x1080) a la que se dirigirá el zoom al ganar.
@export var victory_zoom_target_global: Vector2 = Vector2(1450, 550)
## Nivel de escala/zoom que tomará la cámara al ganar.
@export var victory_zoom_level: float = 2.0
## Duración en segundos de la animación de zoom.
@export var victory_zoom_duration: float = 1.0

## Diálogo que dirá el jugador al ganar el duelo.
@export var player_victory_dialogue: String = "¡Casi la quedo!"
## Duración en segundos de la visualización del globo de diálogo.
@export var dialogue_display_duration: float = 2.0

## Nombre de la animación de caminata hacia la taberna.
@export var walk_to_tavern_animation: String = "camina_taberna"
## Posición inicial de la caminata final hacia la taberna (coordenadas locales).
## Ajusta esta coordenada para que coincida con el plano del zoom a la derecha de la escena.
@export var walk_to_tavern_start: Vector2 = Vector2(800, 797)

## Duración en segundos de la transición de fundido a negro (fade-out) al final.
@export var fade_out_duration: float = 1.0

# ---------- Configuración de Audio y Sincronización ----------
## Sonido de disparo del jugador.
@export var player_shoot_sound: AudioStream
## Sonido de disparo del enemigo.
@export var enemy_shoot_sound: AudioStream

## [Caso Éxito] Retraso para el sonido del disparo del jugador (segundos).
@export var success_player_shoot_sound_delay: float = 0.0

## [Caso Fallo por Error] Retraso para el sonido del disparo del jugador (segundos).
@export var failure_miss_player_shoot_sound_delay: float = 0.0
## [Caso Fallo por Error] Retraso para el sonido del disparo del enemigo (segundos).
@export var failure_miss_enemy_shoot_sound_delay: float = 0.0

## [Caso Fallo por Tiempo] Retraso para el sonido del disparo del enemigo (segundos).
@export var failure_timeout_enemy_shoot_sound_delay: float = 0.0

## Posición X de destino (se toma automáticamente de la posición en el editor).
var _walk_target_x: float
var _camera: Camera2D
var _fade_overlay: ColorRect

## Estado del disparo: true si ya se hizo clic en esta ronda.
var _shot_fired: bool = false
## true si el clic cayó sobre la hitbox del enemigo.
var _hit_enemy: bool = false


func _ready() -> void:
	# Guardar la posición original del sprite como destino de la caminata.
	_walk_target_x = player_sprite.position.x

	# Crear e instanciar la cámara dinámicamente
	_camera = Camera2D.new()
	# Centrar en Viewport (1920x1080) restando el offset (97, 88) de la escena raíz
	_camera.position = Vector2(1920.0 / 2.0 - 97.0, 1080.0 / 2.0 - 88.0)
	_camera.enabled = true
	add_child(_camera)

	# Crear el overlay de fade-out de forma dinámica dentro del CanvasLayer existente
	_fade_overlay = ColorRect.new()
	_fade_overlay.color = Color(0, 0, 0, 0) # Empieza totalmente transparente
	_fade_overlay.size = Vector2(1920, 1080) # Cubrir el viewport
	_fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$CanvasLayer.add_child(_fade_overlay)

	_update_lives_display()
	GameManager.lives_changed.connect(_on_lives_changed)
	qte_prompt.qte_success.connect(_on_qte_success)
	qte_prompt.qte_failure.connect(_on_qte_failure)

	# Desactivar mouse_filter en todos los Control para no bloquear al Area2D.
	_set_mouse_filter_ignore(self)

	# Eliminar texto "Press F" del componente QTE.
	qte_prompt.prompt_text = ""

	# Iniciar la secuencia del duelo.
	_iniciar_duelo()


# -------------------- Entrada del personaje --------------------

## Inicia la caminata de entrada y conecta el fin de animación al QTE.
func _iniciar_duelo() -> void:
	_shot_fired = false
	_hit_enemy = false

	# Asegurar el reseteo de la cámara
	if _camera:
		_camera.position = Vector2(1920.0 / 2.0 - 97.0, 1080.0 / 2.0 - 88.0)
		_camera.zoom = Vector2.ONE

	narrative_label.text = "Uno que está re loco sale de la nada..."
	qte_prompt.visible = false

	# Posicionar fuera de pantalla (izquierda) y caminar hasta su marca.
	player_sprite.position.x = -300
	player_sprite.play("entra_en_escena")
	enemy_sprite.stop()

	var tween = create_tween()
	tween.tween_property(player_sprite, "position:x", _walk_target_x, walk_duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	# Al terminar la animación, activar el QTE.
	player_sprite.animation_finished.connect(_al_terminar_entrada, CONNECT_ONE_SHOT)


## Se ejecuta al finalizar "entra_en_escena". Activa el QTE.
func _al_terminar_entrada() -> void:
	if player_sprite.animation == "entra_en_escena":
		narrative_label.text = "¡DISPARÁ!"
		qte_prompt.start_qte()


# -------------------- Disparo --------------------

## Detecta cualquier clic izquierdo durante el QTE.
## Solo el primer clic cuenta; los siguientes se ignoran.
func _input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed):
		return
	if not qte_prompt.is_active or qte_prompt.is_resolved or _shot_fired:
		return

	_shot_fired = true
	# Chequeo sincrónico de colisiones para evitar dependencias de framerate o race conditions
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	query.collide_with_areas = true
	var result = space_state.intersect_point(query)
	for hit in result:
		if hit["collider"] == $EnemyHitbox:
			_hit_enemy = true
			break

	# Detener el temporizador del QTE.
	qte_prompt.is_active = false

	# Reproducir animación de disparo de ambos.
	player_sprite.play("shoot")
	enemy_sprite.play("enemigo_dispara")

	if _hit_enemy:
		# --- Caso Éxito (Jugador acierta) ---
		# Sonido de disparo del jugador
		if success_player_shoot_sound_delay > 0:
			get_tree().create_timer(success_player_shoot_sound_delay).timeout.connect(func():
				AudioManager.play_sfx(player_shoot_sound)
			)
		else:
			AudioManager.play_sfx(player_shoot_sound)

		# Acierto: a los 1.22s el enemigo recibe el impacto y muere.
		await get_tree().create_timer(1.22).timeout
		enemy_sprite.play("enemigo_muere")
		# Esperar a que termine la animación de disparo del jugador.
		await player_sprite.animation_finished
		qte_prompt._resolve_success()
	else:
		# --- Caso Fallo por Clic Errado (Jugador le erra) ---
		# Sonido de disparo del jugador
		if failure_miss_player_shoot_sound_delay > 0:
			get_tree().create_timer(failure_miss_player_shoot_sound_delay).timeout.connect(func():
				AudioManager.play_sfx(player_shoot_sound)
			)
		else:
			AudioManager.play_sfx(player_shoot_sound)

		# Sonido de disparo del enemigo
		if failure_miss_enemy_shoot_sound_delay > 0:
			get_tree().create_timer(failure_miss_enemy_shoot_sound_delay).timeout.connect(func():
				AudioManager.play_sfx(enemy_shoot_sound)
			)
		else:
			AudioManager.play_sfx(enemy_shoot_sound)

		# Fallo: esperar tiempo preciso para interrumpir con muerte.
		await get_tree().create_timer(1.8).timeout
		# Interrumpir el disparo con la animación de muerte.
		player_sprite.play("pj_muere1")
		await player_sprite.animation_finished
		qte_prompt._resolve_failure()



## Señal del Area2D EnemyHitbox (obsoleta porque chequeamos asíncronamente en _input)
func _on_enemy_hitbox_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	pass


# -------------------- Vidas --------------------

## Reconstruye el display de corazones.
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


# -------------------- Resultado del QTE --------------------

func _on_qte_success() -> void:
	narrative_label.text = "¡Lo lograste! El forajido cae."
	
	# Crear el globo de diálogo dinámico sobre la cabeza del personaje
	var bubble = PanelContainer.new()
	add_child(bubble)
	
	# Estilo personalizado para el globo de diálogo (marrón oscuro con bordes beige/dorado)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.18, 0.12, 0.08, 0.95) # Marrón oscuro semi-transparente
	style.border_color = Color(0.8, 0.65, 0.45) # Oro/Arena
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	bubble.add_theme_stylebox_override("panel", style)
	
	var label = Label.new()
	label.text = player_victory_dialogue
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color(0.95, 0.92, 0.85)) # Crema
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bubble.add_child(label)
	
	# Esperar un frame para que Godot calcule el tamaño (size) real del PanelContainer
	await get_tree().process_frame
	
	# Centrar el globo sobre la cabeza del personaje
	var player_center_x = player_sprite.position.x + (player_sprite.offset.x * player_sprite.scale.x)
	var target_x = player_center_x - (bubble.size.x / 2.0)
	var target_y = player_sprite.position.y - 280
	
	bubble.position = Vector2(target_x, target_y + 15)
	bubble.modulate.a = 0.0
	
	# Animación pop-up de entrada del globo de texto
	var pop_tween = create_tween().set_parallel(true)
	pop_tween.tween_property(bubble, "position:y", target_y, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pop_tween.tween_property(bubble, "modulate:a", 1.0, 0.2)
	
	# Mantener el globo en pantalla durante el tiempo configurado
	await get_tree().create_timer(dialogue_display_duration).timeout
	
	# Desvanecer y eliminar el globo de diálogo
	var fade_tween = create_tween().set_parallel(true)
	fade_tween.tween_property(bubble, "position:y", target_y - 10, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	fade_tween.tween_property(bubble, "modulate:a", 0.0, 0.2)
	await fade_tween.finished
	bubble.queue_free()
	
	# Ocultar todos los elementos de UI antes de iniciar el zoom cinematográfico
	lives_container.visible = false
	narrative_label.visible = false
	qte_prompt.visible = false
	
	# Iniciar el zoom suave de la cámara hacia la puerta de la taberna
	_play_victory_zoom()
	
	# Esperar a la mitad del zoom para iniciar la caminata
	await get_tree().create_timer(victory_zoom_duration / 2.0).timeout
	_iniciar_caminata_taberna()


func _on_qte_failure() -> void:
	# Si no se disparó, significa que el tiempo se agotó pasivamente.
	if not _shot_fired:
		enemy_sprite.play("enemigo_dispara")
		
		# Sonido de disparo del enemigo (Fallo por Tiempo)
		if failure_timeout_enemy_shoot_sound_delay > 0:
			get_tree().create_timer(failure_timeout_enemy_shoot_sound_delay).timeout.connect(func():
				AudioManager.play_sfx(enemy_shoot_sound)
			)
		else:
			AudioManager.play_sfx(enemy_shoot_sound)

		await get_tree().create_timer(1.8).timeout
		player_sprite.play("pj_muere1")
		await player_sprite.animation_finished

	GameManager.lose_life()
	if GameManager.is_game_over():
		narrative_label.text = "Fue más rápido... la oscuridad te envuelve."
		await get_tree().create_timer(1.5).timeout
		GameManager.go_to_result()
	else:
		if _shot_fired:
			narrative_label.text = "¡Le erraste!"
		else:
			narrative_label.text = "Lamentable..."
		await get_tree().create_timer(2.0).timeout
		_iniciar_duelo()


# -------------------- Utilidades --------------------

## Setea MOUSE_FILTER_IGNORE en todos los nodos Control del subárbol.
func _set_mouse_filter_ignore(node: Node) -> void:
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		_set_mouse_filter_ignore(child)


## Efecto cinematográfico de zoom hacia la puerta de la taberna al ganar.
func _play_victory_zoom() -> void:
	if not _camera:
		return
	
	# Restamos el offset de la escena raíz Control (97, 88) para calcular la coordenada local
	var local_target = victory_zoom_target_global - Vector2(97.0, 88.0)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(_camera, "position", local_target, victory_zoom_duration)
	tween.tween_property(_camera, "zoom", Vector2(victory_zoom_level, victory_zoom_level), victory_zoom_duration)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)


## Inicia el desplazamiento y la animación final del personaje entrando a la taberna.
func _iniciar_caminata_taberna() -> void:
	# Colocar al personaje en su posición de inicio para la caminata en el plano de zoom
	player_sprite.position = walk_to_tavern_start
	
	# Asegurar que la animación de caminata no esté configurada en bucle (loop)
	var sf = player_sprite.sprite_frames
	if sf and sf.has_animation(walk_to_tavern_animation):
		sf.set_animation_loop(walk_to_tavern_animation, false)
	
	# Reproducir la animación de caminata hacia la taberna
	player_sprite.play(walk_to_tavern_animation)
	
	# Esperar a que la animación de la caminata termine (la traslación está pre-renderizada en los frames)
	await player_sprite.animation_finished
	
	# Ejecutar el fade-out de transición
	await _play_fade_out()
	
	# Transicionar a la siguiente escena del juego
	GameManager.game_result = "victory"
	GameManager.go_to_next_scene()


## Realiza el fundido a negro (fade-out) suave al terminar la escena.
func _play_fade_out() -> void:
	if not _fade_overlay:
		return
	
	var tween = create_tween()
	tween.tween_property(_fade_overlay, "color:a", 1.0, fade_out_duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)
	await tween.finished
