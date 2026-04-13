# qte_prompt.gd
# Reusable Quick Time Event component.
# Shows a key prompt with a countdown timer.
# Emits qte_success or qte_failure signals.
#
# Usage: Instance qte_prompt.tscn in a scene, connect to its signals,
# and call start_qte() when ready to trigger.

extends Control

## Emitted when the player presses the correct key in time.
signal qte_success
## Emitted when the timer runs out without correct input.
signal qte_failure

## The key the player must press (set in editor inspector).
@export var target_key: Key = KEY_F
## Seconds before the QTE times out.
@export var time_limit: float = 2.0
## Text displayed to the player (e.g., "Press F!").
@export var prompt_text: String = "Press F!"

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


func _unhandled_input(event: InputEvent) -> void:
	if not is_active or is_resolved:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == target_key:
			_resolve_success()


func _resolve_success() -> void:
	is_active = false
	is_resolved = true
	result_label.text = "Success!"
	result_label.add_theme_color_override("font_color", Color.GREEN)
	qte_success.emit()


func _resolve_failure() -> void:
	is_active = false
	is_resolved = true
	result_label.text = "Failed!"
	result_label.add_theme_color_override("font_color", Color.RED)
	qte_failure.emit()
