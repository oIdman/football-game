extends Area2D
## Ball with 3 shot types: straight / curve (bezier) / knuckle (wobble+dip).
## Appears at screen center, flies toward goal, leaves comet trail.

enum ShotType { STRAIGHT, CURVE, KNUCKLE }

var _target: Vector2
var _start_pos: Vector2
var _control: Vector2            # bezier control point for curve shot
var _speed: float = 200.0
var _active: bool = false
var _progress: float = 0.0
var _travel_distance: float
var _shot_type: int = ShotType.STRAIGHT
var _knuckle_seed: float = 0.0   # random seed for knuckleball wobble
var _trail_world: Array[Vector2] = []

@onready var sprite: Sprite2D = $Sprite2D
@onready var trail: Line2D = $Trail
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	hide()
	set_process(false)
	collision_shape.disabled = true
	area_entered.connect(_on_area_entered)
	_generate_texture()
	_setup_comet_trail()

# ---------------------------------------------------------------------------
# Texture generation
# ---------------------------------------------------------------------------
func _generate_texture() -> void:
	var r = 16
	var img = Image.create(r * 2, r * 2, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	for x in r * 2:
		for y in r * 2:
			var dx = x - r + 0.5
			var dy = y - r + 0.5
			if sqrt(dx * dx + dy * dy) <= r - 0.5:
				img.set_pixel(x, y, Color.WHITE)
	var cx = r
	var cy = r
	var ir = r * 0.45
	for i in 5:
		var a = i * PI * 2 / 5 - PI / 2
		var px = cx + ir * cos(a)
		var py = cy + ir * sin(a)
		for dy2 in range(-2, 3):
			for dx2 in range(-2, 3):
				var sx = int(px) + dx2
				var sy = int(py) + dy2
				if sx >= 0 and sx < r * 2 and sy >= 0 and sy < r * 2:
					if sqrt(float(dx2 * dx2 + dy2 * dy2)) <= 2.2 and img.get_pixel(sx, sy).a > 0:
						img.set_pixel(sx, sy, Color(0.15, 0.15, 0.15, 1))
	sprite.texture = ImageTexture.create_from_image(img)
	sprite.centered = true

# ---------------------------------------------------------------------------
# Comet trail setup
# ---------------------------------------------------------------------------
func _setup_comet_trail() -> void:
	var wc = Curve.new()
	wc.add_point(Vector2(0.0, 0.0))
	wc.add_point(Vector2(0.3, 0.25))
	wc.add_point(Vector2(0.7, 0.7))
	wc.add_point(Vector2(1.0, 1.0))
	trail.width_curve = wc
	trail.width = 14.0

	var g = Gradient.new()
	g.set_color(0.0, Color(1.0, 0.4, 0.15, 0.0))
	g.set_color(0.3, Color(1.0, 0.6, 0.2, 0.25))
	g.set_color(0.6, Color(1.0, 0.85, 0.5, 0.55))
	g.set_color(0.85, Color(1.0, 0.95, 0.8, 0.85))
	g.set_color(1.0, Color(1.0, 1.0, 1.0, 1.0))
	trail.gradient = g
	trail.begin_cap_mode = Line2D.LINE_CAP_ROUND
	trail.end_cap_mode = Line2D.LINE_CAP_ROUND

# ---------------------------------------------------------------------------
# Launch — random shot type if none specified
# ---------------------------------------------------------------------------
func launch(start_pos: Vector2, target_pos: Vector2, speed: float, shot_type: int = -1) -> void:
	_start_pos = start_pos
	_target = target_pos
	_speed = speed
	_travel_distance = start_pos.distance_to(target_pos)
	_progress = 0.0
	_trail_world.clear()

	# Random shot type selection
	if shot_type < 0:
		var roll = randf()
		if roll < 0.40:
			_shot_type = ShotType.STRAIGHT
		elif roll < 0.70:
			_shot_type = ShotType.CURVE
		else:
			_shot_type = ShotType.KNUCKLE
	else:
		_shot_type = shot_type

	# Per-type initialisation
	match _shot_type:
		ShotType.CURVE:
			_setup_curve()
		ShotType.KNUCKLE:
			_knuckle_seed = randf() * 100.0

	global_position = start_pos
	scale = Vector2(0.15, 0.15)
	_active = true
	show()
	set_process(true)
	collision_shape.disabled = false
	trail.clear_points()

func _setup_curve() -> void:
	"""Quadratic bezier control point offset perpendicular to direction."""
	var dir = (_target - _start_pos).normalized()
	var perp = Vector2(-dir.y, dir.x)
	var dist = _start_pos.distance_to(_target)
	var strength = dist * randf_range(0.30, 0.65)
	var side = 1 if randi() % 2 == 0 else -1
	var mid = (_start_pos + _target) * 0.5
	_control = mid + perp * strength * side

# ---------------------------------------------------------------------------
# Position on path
# ---------------------------------------------------------------------------
func _compute_position(progress: float) -> Vector2:
	match _shot_type:
		ShotType.STRAIGHT:
			return _start_pos.lerp(_target, progress)

		ShotType.CURVE:    # Quadratic Bézier: B(t) = (1-t)²P0 + 2(1-t)tP1 + t²P2
			var t = progress
			var omt = 1.0 - t
			return omt * omt * _start_pos \
				 + 2.0 * omt * t * _control \
				 + t * t * _target

		ShotType.KNUCKLE:
			var base = _start_pos.lerp(_target, progress)
			var wob_x = sin(progress * 16.0 + _knuckle_seed) * 5.0
			var wob_y = sin(progress * 13.0 + _knuckle_seed * 1.37) * 4.0
			var dip = 0.0
			if progress > 0.65:
				var f = (progress - 0.65) / 0.35
				dip = f * f * 40.0
			return base + Vector2(wob_x, wob_y + dip)

	return _start_pos.lerp(_target, progress)

# ---------------------------------------------------------------------------
# Per-frame update
# ---------------------------------------------------------------------------
func _process(delta: float) -> void:
	if not _active:
		return

	_progress += (_speed * delta) / _travel_distance

	if _progress >= 1.0:
		_miss()
		return

	global_position = _compute_position(_progress)

	# Ball grows from 0.15x to 1.0x with quadratic ease-in
	var s = lerp(0.15, 1.0, _progress * _progress)
	scale = Vector2.ONE * s

	# Trail recording (world coords, ~6px sample interval)
	if _trail_world.is_empty() or \
		_trail_world[-1].distance_squared_to(global_position) > 36.0:
		_trail_world.append(global_position)
		if _trail_world.size() > 20:
			_trail_world.remove_at(0)

	trail.clear_points()
	for wp in _trail_world:
		trail.add_point(to_local(wp))

# ---------------------------------------------------------------------------
# End conditions
# ---------------------------------------------------------------------------
func _miss() -> void:
	_active = false
	set_process(false)
	collision_shape.disabled = true
	trail.clear_points()
	_trail_world.clear()
	hide()
	if GameManager.state == GameManager.GameState.PLAYING:
		GameManager.on_ball_missed()

func _on_area_entered(area: Area2D) -> void:
	if not _active:
		return
	if area.is_in_group("goalkeeper"):
		_active = false
		set_process(false)
		collision_shape.disabled = true
		trail.clear_points()
		_trail_world.clear()
		hide()
		if GameManager.state == GameManager.GameState.PLAYING:
			GameManager.on_ball_saved()
