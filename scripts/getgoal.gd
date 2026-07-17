extends CanvasLayer
## UI layer: start screen, score display, game-over overlay, restart.

@onready var score_label: Label = $Control/ScoreLabel
@onready var start_panel: Panel = $Control/StartPanel
@onready var start_title: Label = $Control/StartPanel/Title
@onready var start_button: Button = $Control/StartPanel/StartButton
@onready var game_over_panel: Panel = $Control/GameOverPanel
@onready var final_score_label: Label = $Control/GameOverPanel/FinalScoreLabel
@onready var restart_button: Button = $Control/GameOverPanel/RestartButton
@onready var instruction_label: Label = $Control/InstructionLabel

func _ready() -> void:
	GameManager.state_changed.connect(_on_state_changed)
	GameManager.score_updated.connect(_on_score_updated)
	start_button.pressed.connect(_on_start_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	_show_start()

func _show_start() -> void:
	score_label.hide()
	start_panel.show()
	game_over_panel.hide()
	instruction_label.hide()

func _show_playing() -> void:
	score_label.show()
	start_panel.hide()
	game_over_panel.hide()
	instruction_label.show()

func _show_game_over() -> void:
	score_label.hide()
	start_panel.hide()
	game_over_panel.show()
	final_score_label.text = "Game Over!\nSaves: %d" % GameManager.score
	instruction_label.hide()

func _on_start_pressed() -> void:
	GameManager.start_game()

func _on_restart_pressed() -> void:
	GameManager.start_game()

func _on_state_changed(new_state: int) -> void:
	match new_state:
		GameManager.GameState.READY:
			_show_start()
		GameManager.GameState.PLAYING:
			_show_playing()
		GameManager.GameState.GAME_OVER:
			_show_game_over()

func _on_score_updated(new_score: int) -> void:
	score_label.text = "Saves: %d" % new_score
