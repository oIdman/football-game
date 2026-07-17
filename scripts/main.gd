extends Node2D
## Main game scene. Draws pitch, goal frame, net. Positions goalkeeper.

var vs: Vector2
var goal_l: float
var goal_r: float
var goal_t: float
var goal_b: float
var post_w: float = 8.0
var crossbar_h: float = 8.0

@onready var goalkeeper: Area2D = $Goalkeeper
@onready var ball: Area2D = $Ball
@onready var ui_layer: CanvasLayer = $UI

func _ready() -> void:
	vs = get_viewport().get_visible_rect().size

	goal_l = vs.x * 0.16
	goal_r = vs.x * 0.84
	goal_t = vs.y * 0.06
	goal_b = vs.y * 0.72

	var padding = post_w + 4
	goalkeeper.set_bounds(goal_l + padding, goal_r - padding,
		goal_t + crossbar_h + 4, goal_b - 4)

	GameManager.state_changed.connect(_on_state_changed)
	GameManager.state = GameManager.GameState.READY
	queue_redraw()

func _draw() -> void:
	if vs == Vector2.ZERO:
		return
	# Pitch background
	draw_rect(Rect2(0, 0, vs.x, vs.y), Color(0.12, 0.42, 0.12, 1))
	# Sky strip at top
	draw_rect(Rect2(0, 0, vs.x, vs.y * 0.04), Color(0.2, 0.5, 0.7, 1))

	var net_l = goal_l + post_w
	var net_r = goal_r - post_w
	var net_t = goal_t + crossbar_h
	var net_b = goal_b
	var net_w = net_r - net_l
	var net_h = net_b - net_t

	# Net background
	draw_rect(Rect2(net_l, net_t, net_w, net_h), Color(0.9, 0.9, 0.9, 0.15))
	# Horizontal net lines
	var lc = Color(0.9, 0.9, 0.9, 0.12)
	var gap = 24.0
	var y = net_t + gap
	while y < net_b:
		draw_line(Vector2(net_l, y), Vector2(net_r, y), lc, 1.0)
		y += gap
	# Vertical net lines
	var x = net_l + gap
	while x < net_r:
		draw_line(Vector2(x, net_t), Vector2(x, net_b), lc, 1.0)
		x += gap

	# Goal frame (white)
	draw_rect(Rect2(goal_l, goal_t, goal_r - goal_l, crossbar_h), Color.WHITE)
	draw_rect(Rect2(goal_l, goal_t, post_w, goal_b - goal_t), Color.WHITE)
	draw_rect(Rect2(goal_r - post_w, goal_t, post_w, goal_b - goal_t), Color.WHITE)
	draw_rect(Rect2(goal_l, goal_b, goal_r - goal_l, 3), Color(0.9, 0.9, 0.9, 0.8))

	# Post shadows
	var sh = Color(0, 0, 0, 0.08)
	draw_rect(Rect2(goal_l + 4, goal_t + crossbar_h + 4, 6, goal_b - goal_t - crossbar_h), sh)
	draw_rect(Rect2(goal_r - post_w - 10, goal_t + crossbar_h + 4, 6, goal_b - goal_t - crossbar_h), sh)

func _on_state_changed(new_state: int) -> void:
	match new_state:
		GameManager.GameState.READY:
			goalkeeper.hide()
			ball.hide()
		GameManager.GameState.PLAYING:
			goalkeeper.show()
		GameManager.GameState.GAME_OVER:
			goalkeeper.hide()
			ball.hide()
