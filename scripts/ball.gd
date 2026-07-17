extends Area2D
## Ball that flies from the bottom center toward the goal.
## Grows in size, leaves a trail, and triggers save/miss events.

var _target: Vector2
var _speed: float = 300.0
var _reaction_window: float = 1.0
var _active: bool = false
var _progress: float = 0.0
var _start_pos: Vector2
var _travel_distance: float

@onready var sprite: Sprite2D = $Sprite2D
@onready var trail: Line2D = $Trail
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	hide()
	set_process(false)
	collision_shape.disabled = true
	area_entered.connect(_on_area_entered)
	# Generate ball texture at runtime
	_generate_texture()

func _generate_texture() -> void:
	var radius = 16
	var size = radius * 2
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	# Draw white circle
	for x in size:
		for y in size:
			var dx = x - radius + 0.5
			var dy = y - radius + 0.5
			var d = sqrt(dx * dx + dy * dy)
			if d <= radius:
				img.set_pixel(x, y, Color.WHITE)
			if d <= 4:
				img.set_pixel(x, y, Color(0.4, 0.4, 0.4, 1))
	# Draw pentagon pattern (simplified soccer ball)
	var cx = radius
	var cy = radius
	var inner_r = radius * 0.45
	for i in 5:
		var angle = i * PI * 2 / 5 - PI / 2
		var px = cx + inner_r * cos(angle)
		var py = cy + inner_r * sin(angle)
		for dy2 in range(-2, 3):
			for dx2 in range(-2, 3):
				var sx = int(px) + dx2
				var sy = int(py) + dy2
				if sx >= 0 and sx < size and sy >= 0 and sy < size:
					if sqrt(dx2*dx2 + dy2*dy2) <= 2.2:
						var existing = img.get_pixel(sx, sy)
						if existing.a > 0:
							img.set_pixel(sx, sy, Color(0.15, 0.15, 0.15, 1))

	sprite.texture = ImageTexture.create_from_image(img)
	sprite.centered = true

func launch(start_pos: Vector2, target_pos: Vector2, speed: float, reaction_window: float) -> void:
	global_position = start_pos
	_start_pos = start_pos
	_target = target_pos
	_speed = speed
	_reaction_window = reaction_window
	scale = Vector2(0.25, 0.25)
	_progress = 0.0
	_travel_distance = start_pos.distance_to(target_pos)
	_active = true
	show()
	set_process(true)
	collision_shape.disabled = false

	# Trail setup
	trail.clear_points()
	trail.add_point(Vector2.ZERO)  # local coords
	trail.width = 4

func _process(delta: float) -> void:
	if not _active:
		return

	var direction = (_target - global_position).normalized()
	var step = _speed * delta
	var dist_remaining = global_position.distance_to(_target)

	if dist_remaining > step:
		global_position += direction * step
		_progress = 1.0 - (dist_remaining / _travel_distance)
		# Scale from 0.25 to 1.0
		var s = lerp(0.25, 1.0, _progress)
		scale = Vector2(s, s)
		# Trail — keep ~40 points, fade alpha
		if trail.get_point_count() == 0 or global_position.distance_to(trail.get_points()[-1] + Vector2(0, 0)) > 6:
			# Convert to local coords
			var local_pos = to_local(global_position)
			trail.add_point(local_pos)
			while trail.get_point_count() > 40:
				trail.remove_point(0)
	else:
		# Reached the goal area — missed!
		_miss()

func _miss() -> void:
	_active = false
	set_process(false)
	collision_shape.disabled = true
	trail.clear_points()
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
		hide()
		if GameManager.state == GameManager.GameState.PLAYING:
			GameManager.on_ball_saved()
