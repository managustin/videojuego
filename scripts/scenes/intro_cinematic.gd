# intro_cinematic.gd
# Cinemática introductoria. Muestra una secuencia de imágenes estáticas
# con tiempos configurables, fade-in/zoom en la primera y fade-out en la última.
# Al terminar pasa automáticamente a la primera escena de juego.

extends Control

# ---------- Configuración de duraciones ----------

## Duración en pantalla de cada imagen (en segundos).
## El índice 0 corresponde a 0.png, el índice 1 a 1.png, etc.
## Modificá estos valores desde el Inspector de Godot para ajustar el ritmo.
@export var slide_durations: Array[float] = [
	4.0,  # 0.png  — primera imagen (incluye fade-in + zoom)
	3.0,  # 1.png
	3.0,  # 2.png
	3.0,  # 3.png
	3.0,  # 4.png
	3.0,  # 5.png
	3.0,  # 6.png
	3.0,  # 7.png
	3.0,  # 8.png
	3.0,  # 9.png
	4.0,  # 10.png — última imagen (incluye fade-out)
]

## Duración del fade-in (de negro a visible) en la primera imagen.
@export var fade_in_duration: float = 1.5
## Duración del fade-out (de visible a negro) en la última imagen.
@export var fade_out_duration: float = 1.5
## Escala inicial del zoom (1.0 = sin zoom, 1.15 = 15% más grande).
@export var zoom_start_scale: float = 1.15
## Duración del efecto de zoom de entrada (en segundos).
@export var zoom_duration: float = 3.0

# ---------- Nodos ----------

@onready var image_display: TextureRect = $ImageDisplay
@onready var fade_overlay: ColorRect = $FadeOverlay

# ---------- Estado ----------

const STATIC_SLIDES: int = 11

const IMAGES_PATH: String = "res://assets/cinematics/intro/"
var _textures: Array[Texture2D] = []
var _current_slide: int = 0


func _ready() -> void:
	# Cargar todas las texturas al inicio.
	_load_textures()

	# Preparar el overlay de fade: empieza totalmente negro (opaco).
	fade_overlay.color = Color(0, 0, 0, 1)
	fade_overlay.visible = true
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Asegurar que ImageDisplay no bloquee input.
	image_display.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Iniciar la secuencia.
	_play_sequence()


# ---------- Carga de texturas ----------

## Carga las 11 texturas desde la carpeta de assets.
func _load_textures() -> void:
	# Cargar las 11 imágenes estáticas de tu compañero
	for i in range(STATIC_SLIDES):
		var path = IMAGES_PATH + str(i) + ".png"
		var tex = load(path) as Texture2D
		if tex:
			_textures.append(tex)
		else:
			push_warning("intro_cinematic: No se pudo cargar " + path)


# ---------- Secuencia principal ----------

## Reproduce la secuencia completa de imágenes con sus efectos.
func _play_sequence() -> void:
	for i in range(_textures.size()):
		_current_slide = i
		_show_slide(i)

		if i == 0:
			# Primera imagen: fade-in + zoom.
			_apply_fade_in()
			_apply_zoom_in()
		elif i == _textures.size() - 1:
			# Última imagen: esperar la mayor parte, luego fade-out.
			pass

		# Esperar la duración configurada para esta imagen.
		var duration = _get_slide_duration(i)
		await get_tree().create_timer(duration).timeout

		if i == _textures.size() - 1:
			# Fade-out al final de la última imagen.
			_apply_fade_out()
			await get_tree().create_timer(fade_out_duration).timeout

	# Terminó la cinemática, pasar a la primera escena de juego.
	_on_cinematic_finished()


## Muestra la imagen del índice dado.
func _show_slide(index: int) -> void:
	if index >= 0 and index < _textures.size() and _textures[index]:
		image_display.texture = _textures[index]


## Devuelve la duración configurada para una imagen, con fallback a 3.0s.
func _get_slide_duration(index: int) -> float:
	# Respeta el tiempo configurado para cada imagen estática
	if index >= 0 and index < slide_durations.size():
		return slide_durations[index]
	return 3.0


# ---------- Efectos ----------

## Fade-in: el overlay negro se vuelve transparente.
func _apply_fade_in() -> void:
	fade_overlay.color = Color(0, 0, 0, 1)
	var tween = create_tween()
	tween.tween_property(fade_overlay, "color:a", 0.0, fade_in_duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)


## Fade-out: el overlay negro se vuelve opaco.
func _apply_fade_out() -> void:
	fade_overlay.color = Color(0, 0, 0, 0)
	var tween = create_tween()
	tween.tween_property(fade_overlay, "color:a", 1.0, fade_out_duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)


## Zoom de entrada: la imagen empieza más grande y se reduce a tamaño normal.
func _apply_zoom_in() -> void:
	# Pivotar desde el centro.
	image_display.pivot_offset = image_display.size / 2.0
	image_display.scale = Vector2(zoom_start_scale, zoom_start_scale)
	var tween = create_tween()
	tween.tween_property(image_display, "scale", Vector2.ONE, zoom_duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)


# ---------- Fin de cinemática ----------

## Llamada al terminar la secuencia. Inicia la primera escena de juego.
func _on_cinematic_finished() -> void:
	GameManager.start_first_scene()
