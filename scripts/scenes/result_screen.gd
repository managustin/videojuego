# result_screen.gd
# Displays victory or defeat based on GameManager.game_result.
# Provides Retry and Main Menu buttons.

extends Control

@onready var result_label: Label = $VBoxContainer/ResultLabel
@onready var message_label: Label = $VBoxContainer/MessageLabel
@onready var retry_button: Button = $VBoxContainer/RetryButton
@onready var menu_button: Button = $VBoxContainer/MenuButton
@onready var background: ColorRect = $Background


func _ready() -> void:
	retry_button.pressed.connect(_on_retry_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	_display_result()


## Configures the screen based on the game outcome.
func _display_result() -> void:
	if GameManager.game_result == "victory":
		result_label.text = "You Survived!"
		message_label.text = "The frontier is safe... for now."
		result_label.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2))
		background.color = Color(0.05, 0.15, 0.05)
	else:
		result_label.text = "You Died."
		message_label.text = "The west is a dangerous place..."
		result_label.add_theme_color_override("font_color", Color(0.8, 0.2, 0.2))
		background.color = Color(0.15, 0.05, 0.05)


func _on_retry_pressed() -> void:
	GameManager.start_game()


func _on_menu_pressed() -> void:
	GameManager.go_to_main_menu()
