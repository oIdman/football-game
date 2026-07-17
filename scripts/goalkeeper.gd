extends Area2D
## Goalkeeper controlled by keyboard (arrows/WASD) and mouse.
## Moves within goal bounds. On contact with ball → save.

var move_speed: float = 320.0

# Goal bounds (set by Main at ready)
var bound_left: float = 40.0
var bound_right: float = 440.0
var bound_top: float = 40.0
var bound_bottom: float = 520.0

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("goalkeeper")
	_generate_texture()

func _generate_texture() -> void:
	var w = 48
	var h = 64
	var img = Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	# Body (jersey - bright color)
	for x in w:
		for y in h:
			# Head (circle at top)
			var hx = x - w / 2
			var hy = y - 12
			if sqrt(hx * hx + hy * hy) <= 14:
				img.set_pixel(x, y, Color(1.0, 0.85, 0.6, 1)) # skin
			# Body rectangle
			elif x > 8 and x < w - 8 and y > 22 and y < h - 4:
				img.set_pixel(x, y, Color(0.2, 0.6, 0.2, 1)) # green jersey
			# Arms (extended to sides)
			elif (x < 10 or x > w - 10) and y > 20 and y < 46:
				img.set_pixel(x, y, Color(0.2, 0.6, 0.2, 1))
			# Gloves (hands)
			elif (x < 6 or x > w - 6) and y > 18 and y < 30:
				img.set_pixel(x, y, Color(1.0, 0.9, 0.1, 1)) # yellow gloves
			# Shorts
			elif x > 12 and x < w - 12 and y > h - 8 and y < h - 2:
				img.set_pixel(x, y, Color(0.1, 0.1, 0.1, 1))
			# Legs
			elif (x > 16 and x < 22 or x > w - 22 and x < w - 16) and y > h - 6 and y < h:
				img.set_pixel(x, y, Color(0.15, 0.15, 0.15, 1))

	sprite.texture = ImageTexture.create_from_image(img)
	sprite.centered = true

func set_bounds(l: float, r: float, t: float, b: float) -> void:
	bound_left = l
	bound_right = r
	bound_top = t
	bound_bottom = b
	# Start position: center of goal
	global_position = Vector2((l + r) * 0.5, (t + b) * 0.5)

func _process(delta: float) -> void:
	if GameManager.state != GameManager.GameState.PLAYING:
		return

	# Keyboard input
	var dir = Vector2.ZERO
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		dir.x -= 1
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		dir.x += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		dir.y -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		dir.y += 1

	# Mouse input — track within bounds
	var mouse_pos = get_global_mouse_position()
	var using_mouse = false
	if mouse_pos.x >= bound_left and mouse_pos.x <= bound_right \
		and mouse_pos.y >= bound_top and mouse_pos.y <= bound_bottom:
		# Only use mouse if not pressing keys
		if dir == Vector2.ZERO:
			global_position = mouse_pos
			using_mouse = true

	if not using_mouse and dir != Vector2.ZERO:
		global_position += dir.normalized() * move_speed * delta

	# Clamp to bounds
	global_position.x = clamp(global_position.x, bound_left, bound_right)
	global_position.y = clamp(global_position.y, bound_top, bound_bottom)
