# qte_prompt.gd
# Componente reutilizable de Quick Time Event (QTE).
# Muestra una barra de cuenta regresiva.
# Emite señales qte_success o qte_failure.
#
# Uso: Instanciar qte_prompt.tscn en una escena, conectar señales,
# y llamar a start_qte() cuando sea necesario.

extends Control

## Se emite cuando el jugador completa el QTE exitosamente.
signal qte_success
## Se emite cuando se agota el tiempo sin acción correcta.
signal qte_failure

## Segundos antes de que se agote el tiempo.
@export var time_limit: float = 1.0
## Texto mostrado al jugador (vacío = la escena padre maneja el texto).
@export var prompt_text: String = ""

@onready var prompt_label: Label = $VBoxContainer/PromptLabel
@onready var timer_bar: ProgressBar = $VBoxContainer/TimerBar
@onready var result_label: Label = $VBoxContainer/ResultLabel

var time_remaining: float = 0.0
var is_active: bool = false
var is_resolved: bool = false


func _ready() -> void:
	visible = false
	result_label.text = ""


## Activates the QTE prompt and starts the countdown.
func start_qte() -> void:
	prompt_label.text = prompt_text
	time_remaining = time_limit
	timer_bar.max_value = time_limit
	timer_bar.value = time_limit
	result_label.text = ""
	is_active = true
	is_resolved = false
	visible = true


func _process(delta: float) -> void:
	if not is_active:
		return

	time_remaining -= delta
	timer_bar.value = time_remaining

	if time_remaining <= 0.0:
		_resolve_failure()



func _resolve_success() -> void:
	is_active = false
	is_resolved = true
	result_label.text = "¡Éxito!"
	result_label.add_theme_color_override("font_color", Color.GREEN)
	qte_success.emit()


func _resolve_failure() -> void:
	is_active = false
	is_resolved = true
	result_label.text = "¡Fallaste!"
	result_label.add_theme_color_override("font_color", Color.RED)
	qte_failure.emit()
