extends Node
## Global game manager (autoload). Manages state, scoring, and ball spawning.

enum GameState { READY, PLAYING, GAME_OVER }

var state: int = GameState.READY
var score: int = 0
var consecutive_saves: int = 0

signal state_changed(new_state)
signal score_updated(new_score)

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS

func start_game() -> void:
	score = 0
	consecutive_saves = 0
	state = GameState.PLAYING
	state_changed.emit(state)
	score_updated.emit(score)
	_spawn_ball()

func _spawn_ball() -> void:
	var main = get_tree().current_scene
	if not main or not main.has_node("Ball"):
		return
	var ball = main.get_node("Ball")
	var viewport_size = main.get_viewport().get_visible_rect().size

	var center_x = viewport_size.x * 0.5
	var start_pos = Vector2(center_x, viewport_size.y * 0.92)
	var goal_l = viewport_size.x * 0.16
	var goal_r = viewport_size.x * 0.84
	var goal_top = viewport_size.y * 0.08
	var goal_bot = viewport_size.y * 0.72
	var mid_x = viewport_size.x * 0.5

	# Pick left or right side, randomize target within that third
	var side = "left" if randi() % 2 == 0 else "right"
	var target_x: float
	if side == "left":
		target_x = randf_range(goal_l + 12, mid_x - 20)
	else:
		target_x = randf_range(mid_x + 20, goal_r - 12)
	var target_y = randf_range(goal_top + 20, goal_bot - 20)
	var target_pos = Vector2(target_x, target_y)

	# Difficulty scales with score
	var base_speed = 280.0 + min(score * 15, 280.0)
	var reaction_window = 1.4 - min(score * 0.05, 0.6)

	ball.launch(start_pos, target_pos, base_speed, reaction_window)

func on_ball_saved() -> void:
	score += 1
	consecutive_saves += 1
	score_updated.emit(score)

	# Brief pause then next ball
	await get_tree().create_timer(0.4).timeout
	if state == GameState.PLAYING:
		_spawn_ball()

func on_ball_missed() -> void:
	state = GameState.GAME_OVER
	state_changed.emit(state)
