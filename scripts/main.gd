extends Node2D
## Main game scene. Draws pitch, goal frame (lower screen), net.
## Position: camera is BEHIND the goal, looking at the field.

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

	# Goal occupies lower-center portion (we're behind it, ball comes from field above)
	goal_l = vs.x * 0.12     # x=58
	goal_r = vs.x * 0.88     # x=422
	goal_t = vs.y * 0.58     # y=418 (crossbar)
	goal_b = vs.y * 0.92     # y=662 (ground line)

	var padding = post_w + 4
	goalkeeper.set_bounds(goal_l + padding, goal_r - padding,
		goal_t + crossbar_h + 4, goal_b - 4)

	GameManager.state_changed.connect(_on_state_changed)
	GameManager.state = GameManager.GameState.READY
	queue_redraw()

func _draw() -> void:
	if vs == Vector2.ZERO:
		return

	# Field / pitch background
	draw_rect(Rect2(0, 0, vs.x, vs.y), Color(0.12, 0.42, 0.12, 1))
	# Sky band at very top (field far end)
	draw_rect(Rect2(0, 0, vs.x, vs.y * 0.05), Color(0.25, 0.55, 0.75, 1))

	var net_l = goal_l + post_w
	var net_r = goal_r - post_w
	var net_t = goal_t + crossbar_h
	var net_b = goal_b
	var net_w = net_r - net_l
	var net_h = net_b - net_t

	# Net area (semi-transparent white)
	draw_rect(Rect2(net_l, net_t, net_w, net_h), Color(0.95, 0.95, 0.95, 0.10))
	# Horizontal net lines
	var lc = Color(0.95, 0.95, 0.95, 0.08)
	var gap = 20.0
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
	# Crossbar
	draw_rect(Rect2(goal_l, goal_t, goal_r - goal_l, crossbar_h), Color.WHITE)
	# Left post
	draw_rect(Rect2(goal_l, goal_t, post_w, goal_b - goal_t), Color.WHITE)
	# Right post
	draw_rect(Rect2(goal_r - post_w, goal_t, post_w, goal_b - goal_t), Color.WHITE)
	# Ground line
	draw_rect(Rect2(goal_l, goal_b, goal_r - goal_l, 3), Color(0.9, 0.9, 0.9, 0.7))

	# Inner post shadow (depth)
	var sh = Color(0, 0, 0, 0.06)
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
