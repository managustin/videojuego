# game_scene_03.gd
# Tercera escena: El Duelo de la Taberna (QTE en 2 fases).
# Fase 1: El enemigo dispara, el jugador debe cubrirse detrás de la columna.
# Fase 2: El jugador debe disparar de vuelta haciendo clic en la hitbox del enemigo.

extends Control

@onready var background: TextureRect = $Background
@onready var lives_container: HBoxContainer = $LivesContainer
@onready var narrative_label: Label = $NarrativeLabel
@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var enemy_hitbox: Area2D = $EnemyHitbox
@onready var enemy_sprite: AnimatedSprite2D = $EnemyHitbox/EnemySprite
@onready var cover_hitbox: Area2D = $CoverHitbox
@onready var qte_prompt: Control = $QTEPrompt

# ---------- Configuración de Fondos y Animaciones ----------
## Textura de fondo para el duelo en la taberna.
@export var bg_taberna_duelo: Texture2D
## Nombre de la animación para cubrirse.
@export var cover_animation_name: String = "pj_cubrirse"
## Nombre de la animación de muerte del jugador (Fase 1: no se cubre a tiempo).
@export var death_animation_name: String = "pj_muere2"
## Nombre de la animación de disparo del enemigo.
@export var enemy_animation_name: String = "enemigo2_sentado_dispara"

# ---------- Configuración Fase 2: Contraataque ----------
## Nombre de la animación de disparo del jugador en el contraataque (Fase 2 éxito).
@export var player_shoot_animation_name: String = "pj_dispara_duelo"
## Nombre de la animación del jugador disparando pero muriendo (Fase 2 fallo).
@export var player_shoot_and_die_animation_name: String = "pj_dispara_pero_muere"
## Nombre de la animación del enemigo disparando parado.
@export var enemy_parado_dispara_animation_name: String = "enemigo_parado_dispara"
## Nombre de la animación de muerte del enemigo parado.
@export var enemy_parado_muere_animation_name: String = "enemigo_muere"
## Tiempo límite para disparar en la Fase 2 (segundos).
@export var shoot_qte_time_limit: float = 1.5
## Texto de la barra de tiempo en la Fase 2.
@export var shoot_qte_prompt_text: String = "¡DISPARÁ!"
## Tiempo de espera (segundos) tras iniciar QTE de Fase 2 para que el enemigo empiece a disparar parado.
@export var enemy_shoot_qte_delay: float = 0.5
## Tiempo de espera (segundos) para retrasar la animación del jugador 'pj_dispara_pero_muere' tras el fallo del QTE.
@export var failure_player_shoot_delay: float = 0.0
## Tiempo de espera (segundos) para retrasar o reiniciar la animación del enemigo 'enemigo_parado_dispara' tras el fallo del QTE.
@export var failure_enemy_shoot_delay: float = 0.0
## Tiempo de espera (segundos) para retrasar la animación de muerte del enemigo al acertar el disparo.
@export var enemy_death_delay: float = 0.2

# ---------- Configuración de Tiempos y Diálogos (Fase 1) ----------
## Tiempo límite para cubrirse en el QTE.
@export var qte_time_limit: float = 2.0
## Tiempo de espera desde que inicia la animación del enemigo hasta que aparece el QTE.
@export var qte_delay_after_enemy_animation: float = 3.5
## Texto instructivo al inicio de la escena.
@export var narrative_text: String = "Prepárate..."
## Texto sobre la barra de tiempo durante el QTE.
@export var qte_prompt_text: String = "TOMA COBERTURA"

# ---------- Variables de Control ----------
var _fade_overlay: ColorRect
var _qte_resolved: bool = false
var _enemy_animation_done: bool = false
var _active_bubble: PanelContainer = null

## Fase actual del QTE: 1 = Cobertura, 2 = Disparo.
var _current_qte_phase: int = 1
## true si el jugador ya hizo clic durante la Fase 2 (solo vale un clic).
var _shot_fired: bool = false
## true si el clic de la Fase 2 cayó sobre la hitbox del enemigo.
var _hit_enemy: bool = false


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

	# 4. Configurar el QTE
	qte_prompt.qte_success.connect(_on_qte_success)
	qte_prompt.qte_failure.connect(_on_qte_failure)
	qte_prompt.prompt_text = qte_prompt_text
	qte_prompt.time_limit = qte_time_limit

	# 5. Conectar señales de la hitbox de la columna
	cover_hitbox.input_event.connect(_on_cover_hitbox_input_event)

	# Conectar señal de fin de animación del enemigo
	enemy_sprite.animation_finished.connect(_on_enemy_animation_finished)

	# 6. Desactivar mouse_filter en todos los Control para no bloquear las colisiones
	_set_mouse_filter_ignore(self)

	# 7. Iniciar secuencia
	_iniciar_duelo()


## Se ejecuta cuando termina cualquier animación del enemigo.
func _on_enemy_animation_finished() -> void:
	if enemy_sprite.animation == enemy_animation_name:
		_enemy_animation_done = true


# ==================== FASE 1: COBERTURA ====================

## Configura e inicia el duelo desde la Fase 1 (cobertura).
func _iniciar_duelo() -> void:
	_qte_resolved = false
	_enemy_animation_done = false
	_current_qte_phase = 1
	_shot_fired = false
	_hit_enemy = false
	if _active_bubble and is_instance_valid(_active_bubble):
		_active_bubble.queue_free()
		_active_bubble = null
	narrative_label.text = narrative_text
	narrative_label.visible = true
	
	# Mantener al personaje estático en su frame inicial
	player_sprite.animation = cover_animation_name
	player_sprite.stop()
	player_sprite.frame = 0
	player_sprite.visible = true

	# Mantener al enemigo estático en su frame inicial al inicio
	enemy_sprite.stop()
	enemy_sprite.frame = 0
	enemy_sprite.visible = true

	# Asegurar que el QTE esté oculto al iniciar
	qte_prompt.visible = false

	# Iniciar animación del enemigo de inmediato (apenas se hace el cambio a este fondo)
	if enemy_sprite.sprite_frames and enemy_sprite.sprite_frames.has_animation(enemy_animation_name):
		enemy_sprite.sprite_frames.set_animation_loop(enemy_animation_name, false)
		enemy_sprite.play(enemy_animation_name)
	else:
		push_warning("game_scene_03: Animación del enemigo '" + enemy_animation_name + "' no encontrada.")
		_enemy_animation_done = true

	# Crear un temporizador en paralelo para que el QTE empiece exactamente después del delay configurado
	var qte_start_timer = get_tree().create_timer(qte_delay_after_enemy_animation)

	# Fade-in (desvanecer negro a transparente)
	var fade_in = create_tween()
	fade_in.tween_property(_fade_overlay, "color:a", 0.0, 1.0)
	await fade_in.finished

	# Mostrar burbuja de diálogo del enemigo "fuiste"
	var enemy_head_pos = enemy_hitbox.position + Vector2(-133, -160)
	_mostrar_globo_dialogo("fuiste", enemy_head_pos, 2.0)

	# Esperar el resto del retraso para iniciar el QTE si no se completó durante el fade-in
	await qte_start_timer.timeout

	# Si ya se resolvió en la espera, no hacer nada
	if _qte_resolved:
		return

	# Iniciar el QTE de Fase 1 (cobertura)
	qte_prompt.prompt_text = qte_prompt_text
	qte_prompt.time_limit = qte_time_limit
	qte_prompt.start_qte()


## Se ejecuta al hacer clic en la hitbox de la columna (Fase 1).
func _on_cover_hitbox_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not (event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed):
		return

	# Solo responder en Fase 1
	if _current_qte_phase != 1:
		return

	if not qte_prompt.is_active or qte_prompt.is_resolved or _qte_resolved:
		return

	_qte_resolved = true
	# Detener el cronómetro del QTE
	qte_prompt.is_active = false
	
	if _active_bubble and is_instance_valid(_active_bubble):
		_active_bubble.queue_free()
		_active_bubble = null
	
	# Éxito: reproducir animación de cubrirse
	if player_sprite.sprite_frames and player_sprite.sprite_frames.has_animation(cover_animation_name):
		player_sprite.sprite_frames.set_animation_loop(cover_animation_name, false)
		player_sprite.play(cover_animation_name)
		await player_sprite.animation_finished
	else:
		push_warning("game_scene_03: Animación '" + cover_animation_name + "' no encontrada. Simulando...")
		await get_tree().create_timer(1.5).timeout

	# Resolver el QTE en el componente
	qte_prompt._resolve_success()


# ==================== FASE 2: CONTRAATAQUE (DISPARO) ====================

## Detecta cualquier clic izquierdo durante la Fase 2.
## Solo el primer clic cuenta; los siguientes se ignoran.
func _input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed):
		return

	# Solo responder en Fase 2
	if _current_qte_phase != 2:
		return

	if not qte_prompt.is_active or qte_prompt.is_resolved or _shot_fired:
		return

	_shot_fired = true
	# Chequeo sincrónico de colisiones (misma técnica que Scene 1)
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	query.collide_with_areas = true
	var result = space_state.intersect_point(query)
	for hit in result:
		if hit["collider"] == enemy_hitbox:
			_hit_enemy = true
			break

	if _hit_enemy:
		# Acierto: detener el QTE inmediatamente y resolver como éxito
		qte_prompt.is_active = false
		qte_prompt._resolve_success()
	else:
		# Fallo por clic errado: no hacemos nada aquí para dejar que el tiempo corra
		# hasta el final del QTE, cumpliendo con la regla de que la animación de
		# pj_dispara_duelo se activa "al final del tiempo del qte".
		pass


## Inicia la Fase 2 del QTE (disparar al enemigo).
func _iniciar_fase_disparo() -> void:
	_current_qte_phase = 2
	_shot_fired = false
	_hit_enemy = false

	narrative_label.text = shoot_qte_prompt_text

	# Iniciar el QTE de Fase 2
	qte_prompt.prompt_text = shoot_qte_prompt_text
	qte_prompt.time_limit = shoot_qte_time_limit
	qte_prompt.start_qte()

	# Iniciar animación del enemigo disparando parado a cierto tiempo del QTE
	if enemy_shoot_qte_delay >= 0:
		var enemy_shoot_timer = get_tree().create_timer(enemy_shoot_qte_delay)
		enemy_shoot_timer.timeout.connect(func():
			if _current_qte_phase == 2 and qte_prompt.is_active and not qte_prompt.is_resolved:
				if enemy_sprite.sprite_frames and enemy_sprite.sprite_frames.has_animation(enemy_parado_dispara_animation_name):
					enemy_sprite.sprite_frames.set_animation_loop(enemy_parado_dispara_animation_name, false)
					enemy_sprite.play(enemy_parado_dispara_animation_name)
				else:
					push_warning("game_scene_03: Animación del enemigo '" + enemy_parado_dispara_animation_name + "' no encontrada.")
		)


# ==================== RESOLUCIÓN DEL QTE ====================

## Éxito del QTE (se llama para ambas fases).
func _on_qte_success() -> void:
	if _current_qte_phase == 1:
		# Fase 1 completada: el jugador se cubrió.
		# Esperar a que el enemigo termine su animación de disparo.
		if not _enemy_animation_done:
			await enemy_sprite.animation_finished

		# Pasar a la Fase 2: contraataque
		_iniciar_fase_disparo()

	elif _current_qte_phase == 2:
		# Fase 2 completada: el jugador disparó y acertó.
		
		var player_done = [false]
		var enemy_done = [false]

		var play_player = func():
			if player_sprite.sprite_frames and player_sprite.sprite_frames.has_animation(player_shoot_animation_name):
				player_sprite.sprite_frames.set_animation_loop(player_shoot_animation_name, false)
				player_sprite.stop()
				player_sprite.frame = 0
				player_sprite.play(player_shoot_animation_name)
				await player_sprite.animation_finished
			else:
				push_warning("game_scene_03: Animación '" + player_shoot_animation_name + "' no encontrada.")
			player_done[0] = true

		var play_enemy = func():
			if enemy_death_delay > 0:
				await get_tree().create_timer(enemy_death_delay).timeout
			
			if enemy_sprite.sprite_frames and enemy_sprite.sprite_frames.has_animation(enemy_parado_muere_animation_name):
				enemy_sprite.sprite_frames.set_animation_loop(enemy_parado_muere_animation_name, false)
				enemy_sprite.stop()
				enemy_sprite.frame = 0
				enemy_sprite.play(enemy_parado_muere_animation_name)
				await enemy_sprite.animation_finished
			else:
				push_warning("game_scene_03: Animación del enemigo '" + enemy_parado_muere_animation_name + "' no encontrada.")
			enemy_done[0] = true

		play_player.call()
		play_enemy.call()

		# Esperar a que terminen ambas animaciones y sus respectivos retrasos
		while not (player_done[0] and enemy_done[0]):
			await get_tree().process_frame

		# Transicionar a la pantalla de victoria/resultados
		var fade_out = create_tween()
		fade_out.tween_property(_fade_overlay, "color:a", 1.0, 1.0)
		await fade_out.finished
		
		GameManager.game_result = "victory"
		GameManager.go_to_next_scene()


## Fallo del QTE (se agotó el tiempo, se llama para ambas fases).
func _on_qte_failure() -> void:
	if _active_bubble and is_instance_valid(_active_bubble):
		_active_bubble.queue_free()
		_active_bubble = null

	if _current_qte_phase == 1:
		# Fase 1 fallida: no se cubrió a tiempo → pj_muere2
		if player_sprite.sprite_frames and player_sprite.sprite_frames.has_animation(death_animation_name):
			player_sprite.sprite_frames.set_animation_loop(death_animation_name, false)
			player_sprite.stop()
			player_sprite.frame = 0
			player_sprite.play(death_animation_name)
			await player_sprite.animation_finished
		else:
			push_warning("game_scene_03: Animación '" + death_animation_name + "' no encontrada. Simulando...")
			await get_tree().create_timer(1.5).timeout

	elif _current_qte_phase == 2:
		# Fase 2 fallida: el tiempo se terminó (ya sea por inacción o por haber errado el disparo)
		
		var player_done = [false]
		var enemy_done = [false]

		var play_player = func():
			if failure_player_shoot_delay > 0:
				await get_tree().create_timer(failure_player_shoot_delay).timeout
			
			if is_instance_valid(player_sprite) and player_sprite.sprite_frames and player_sprite.sprite_frames.has_animation(player_shoot_and_die_animation_name):
				player_sprite.sprite_frames.set_animation_loop(player_shoot_and_die_animation_name, false)
				player_sprite.stop()
				player_sprite.frame = 0
				player_sprite.play(player_shoot_and_die_animation_name)
				await player_sprite.animation_finished
			else:
				push_warning("game_scene_03: Animación '" + player_shoot_and_die_animation_name + "' no encontrada.")
			player_done[0] = true

		var play_enemy = func():
			if failure_enemy_shoot_delay > 0:
				await get_tree().create_timer(failure_enemy_shoot_delay).timeout
			
			if is_instance_valid(enemy_sprite) and enemy_sprite.sprite_frames and enemy_sprite.sprite_frames.has_animation(enemy_parado_dispara_animation_name):
				enemy_sprite.sprite_frames.set_animation_loop(enemy_parado_dispara_animation_name, false)
				enemy_sprite.stop()
				enemy_sprite.frame = 0
				enemy_sprite.play(enemy_parado_dispara_animation_name)
				await enemy_sprite.animation_finished
			else:
				push_warning("game_scene_03: Animación del enemigo '" + enemy_parado_dispara_animation_name + "' no encontrada.")
			enemy_done[0] = true

		play_player.call()
		play_enemy.call()

		# Esperar a que terminen ambas animaciones y sus respectivos retrasos
		while not (player_done[0] and enemy_done[0]):
			await get_tree().process_frame

	# Perder vida
	GameManager.lose_life()
	if GameManager.is_game_over():
		if _current_qte_phase == 1:
			narrative_label.text = "No lograste cubrirte a tiempo... la oscuridad te envuelve."
		else:
			narrative_label.text = "Fuiste demasiado lento con el gatillo..."
		await get_tree().create_timer(1.5).timeout
		GameManager.go_to_result()
	else:
		if _current_qte_phase == 1:
			narrative_label.text = "¡Muy lento!"
		else:
			if _shot_fired and not _hit_enemy:
				narrative_label.text = "¡Le erraste!"
			else:
				narrative_label.text = "Lamentable..."
		await get_tree().create_timer(1.5).timeout
		
		# Reiniciar el duelo completo desde Fase 1 (fade out -> reset -> fade in)
		var fade_out = create_tween()
		fade_out.tween_property(_fade_overlay, "color:a", 1.0, 0.5)
		await fade_out.finished
		
		_iniciar_duelo()


# ==================== GLOBO DE DIÁLOGO ====================

## Muestra un globo de diálogo estilizado en las coordenadas dadas con una duración específica.
func _mostrar_globo_dialogo(texto: String, posicion: Vector2, duracion: float = 2.5) -> void:
	if _active_bubble and is_instance_valid(_active_bubble):
		_active_bubble.queue_free()
		_active_bubble = null

	var bubble = PanelContainer.new()
	_active_bubble = bubble
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
	if not is_instance_valid(bubble):
		return
	
	var target_x = posicion.x - (bubble.size.x / 2.0)
	var target_y = posicion.y - bubble.size.y
	
	bubble.position = Vector2(target_x, target_y + 15)
	bubble.modulate.a = 0.0
	
	# Animación pop-up de entrada
	var pop_tween = create_tween().set_parallel(true)
	pop_tween.tween_property(bubble, "position:y", target_y, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pop_tween.tween_property(bubble, "modulate:a", 1.0, 0.2)
	
	# Esperar a que se lea según la duración especificada
	await get_tree().create_timer(duracion).timeout
	if not is_instance_valid(bubble):
		return
	
	# Desvanecer de salida
	var fade_tween = create_tween().set_parallel(true)
	fade_tween.tween_property(bubble, "position:y", target_y - 10, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	fade_tween.tween_property(bubble, "modulate:a", 0.0, 0.2)
	await fade_tween.finished
	if is_instance_valid(bubble):
		bubble.queue_free()
		if _active_bubble == bubble:
			_active_bubble = null


# ==================== UTILIDADES ====================

## Setea MOUSE_FILTER_IGNORE en todos los nodos Control del subárbol.
func _set_mouse_filter_ignore(node: Node) -> void:
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		_set_mouse_filter_ignore(child)


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
