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
	var vs = main.get_viewport().get_visible_rect().size

	var center_x = vs.x * 0.5

	# Ball spawns at SCREEN CENTER (small, far away, field side)
	var start_pos = Vector2(center_x, vs.y * 0.5)

	# Goal bounds (must match main.gd layout: lower portion of screen)
	var goal_l = vs.x * 0.12
	var goal_r = vs.x * 0.88
	var goal_top = vs.y * 0.58
	var goal_bot = vs.y * 0.92
	var mid_x = vs.x * 0.5

	# Pick left or right side, randomize target within that half of the goal
	var side = "left" if randi() % 2 == 0 else "right"
	var target_x: float
	if side == "left":
		target_x = randf_range(goal_l + 20, mid_x - 20)
	else:
		target_x = randf_range(mid_x + 20, goal_r - 20)
	var target_y = randf_range(goal_top + 30, goal_bot - 30)
	var target_pos = Vector2(target_x, target_y)

	# Ball travel: speed adjusts so travel time decreases with score
	var dist = start_pos.distance_to(target_pos)
	var travel_time = max(1.0 - score * 0.04, 0.5)   # 1.0s → 0.5s
	var speed = dist / travel_time
	speed = clamp(speed, 120.0, 550.0)

	ball.launch(start_pos, target_pos, speed)

func on_ball_saved() -> void:
	score += 1
	consecutive_saves += 1
	score_updated.emit(score)

	await get_tree().create_timer(0.4).timeout
	if state == GameState.PLAYING:
		_spawn_ball()

func on_ball_missed() -> void:
	state = GameState.GAME_OVER
	state_changed.emit(state)
