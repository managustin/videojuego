# game_scene_01.gd
# First gameplay scene. Shows narrative text, then triggers a QTE.
# On success: advance to victory. On failure: lose a life and retry or game over.

extends Control

@onready var narrative_label: Label = $NarrativeLabel
@onready var lives_container: HBoxContainer = $LivesContainer
@onready var qte_prompt: Control = $QTEPrompt

## Seconds to wait before triggering the QTE.
var qte_delay: float = 2.0


func _ready() -> void:
	_update_lives_display()
	GameManager.lives_changed.connect(_on_lives_changed)
	qte_prompt.qte_success.connect(_on_qte_success)
	qte_prompt.qte_failure.connect(_on_qte_failure)

	# Start QTE after a short narrative delay
	narrative_label.text = "A shadowy figure steps out of the saloon...\nHe reaches for his gun!"
	await get_tree().create_timer(qte_delay).timeout
	qte_prompt.start_qte()


## Rebuilds the hearts display based on current lives.
func _update_lives_display() -> void:
	# Remove old hearts
	for child in lives_container.get_children():
		child.queue_free()
	# Add one heart per life
	for i in GameManager.lives:
		var heart := Label.new()
		heart.text = "♥"
		heart.add_theme_font_size_override("font_size", 32)
		heart.add_theme_color_override("font_color", Color.RED)
		lives_container.add_child(heart)


func _on_lives_changed(_new_lives: int) -> void:
	_update_lives_display()


func _on_qte_success() -> void:
	narrative_label.text = "You drew first! The outlaw falls."
	await get_tree().create_timer(1.5).timeout
	GameManager.game_result = "victory"
	GameManager.go_to_result()


func _on_qte_failure() -> void:
	GameManager.lose_life()
	if GameManager.is_game_over():
		narrative_label.text = "The outlaw was faster... darkness takes you."
		await get_tree().create_timer(1.5).timeout
		GameManager.go_to_result()
	else:
		narrative_label.text = "You were too slow! Brace yourself..."
		await get_tree().create_timer(1.5).timeout
		narrative_label.text = "He draws again!"
		await get_tree().create_timer(1.0).timeout
		qte_prompt.start_qte()
