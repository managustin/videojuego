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

## Posición X de destino (se toma automáticamente de la posición en el editor).
var _walk_target_x: float

## Estado del disparo: true si ya se hizo clic en esta ronda.
var _shot_fired: bool = false
## true si el clic cayó sobre la hitbox del enemigo.
var _hit_enemy: bool = false


func _ready() -> void:
	# Guardar la posición original del sprite como destino de la caminata.
	_walk_target_x = player_sprite.position.x

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
		# Acierto: a los 1.22s el enemigo recibe el impacto y muere.
		await get_tree().create_timer(1.22).timeout
		enemy_sprite.play("enemigo_muere")
		# Esperar a que termine la animación de disparo del jugador.
		await player_sprite.animation_finished
		qte_prompt._resolve_success()
	else:
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
	await get_tree().create_timer(1.5).timeout
	GameManager.game_result = "victory"
	GameManager.go_to_result()


func _on_qte_failure() -> void:
	# Si no se disparó, significa que el tiempo se agotó pasivamente.
	if not _shot_fired:
		enemy_sprite.play("enemigo_dispara")
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
