extends Area2D
## Ball that appears at screen center and flies toward the goal (downward).
## Grows larger as it approaches. Leaves a COMET/METEOR trail.
## Trail tail points opposite to flight direction.

var _target: Vector2
var _speed: float = 200.0
var _active: bool = false
var _progress: float = 0.0
var _travel_distance: float
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
	# Pentagon pattern
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

func _setup_comet_trail() -> void:
	# --- Width curve: fat near ball, tapered at tail ---
	var wc = Curve.new()
	wc.add_point(Vector2(0.0, 0.0))   # tail tip:   0px wide
	wc.add_point(Vector2(0.3, 0.25))  # lower third: narrow
	wc.add_point(Vector2(0.7, 0.7))   # mid:     thickening
	wc.add_point(Vector2(1.0, 1.0))   # ball end:   full width
	trail.width_curve = wc
	trail.width = 14.0

	# --- Gradient: bright near ball, fading out ---
	var g = Gradient.new()
	g.set_color(0.0, Color(1.0, 0.4, 0.15, 0.0))    # tail tip:  red, transparent
	g.set_color(0.3, Color(1.0, 0.6, 0.2, 0.25))    # lower:     orange glow
	g.set_color(0.6, Color(1.0, 0.85, 0.5, 0.55))   # mid:       gold
	g.set_color(0.85, Color(1.0, 0.95, 0.8, 0.85))  # near ball: warm white
	g.set_color(1.0, Color(1.0, 1.0, 1.0, 1.0))     # ball end:  pure white
	trail.gradient = g

	# Rounded caps for smooth look
	trail.begin_cap_mode = Line2D.LINE_CAP_ROUND
	trail.end_cap_mode = Line2D.LINE_CAP_ROUND

func launch(start_pos: Vector2, target_pos: Vector2, speed: float) -> void:
	global_position = start_pos
	_target = target_pos
	_speed = speed
	scale = Vector2(0.15, 0.15)     # tiny at distance
	_progress = 0.0
	_travel_distance = start_pos.distance_to(target_pos)
	_active = true
	_trail_world.clear()
	show()
	set_process(true)
	collision_shape.disabled = false
	trail.clear_points()

func _process(delta: float) -> void:
	if not _active:
		return
	var direction = (_target - global_position).normalized()
	var step = _speed * delta
	var remaining = global_position.distance_to(_target)

	if remaining > step:
		global_position += direction * step
		_progress = 1.0 - (remaining / _travel_distance)

		# Ball grows from 0.15x → 1.0x as it approaches
		var s = lerp(0.15, 1.0, _progress * _progress)  # quadratic ease-in
		scale = Vector2.ONE * s

		# Record trail positions (world coords, sample every 6px)
		if _trail_world.is_empty() or \
			_trail_world[-1].distance_squared_to(global_position) > 36.0:
			_trail_world.append(global_position)
			if _trail_world.size() > 20:
				_trail_world.remove_at(0)

		# Rebuild Line2D from world → local coords
		trail.clear_points()
		for wp in _trail_world:
			trail.add_point(to_local(wp))
	else:
		_miss()

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
