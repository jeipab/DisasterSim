extends Sprite2D

# Mask properties
var center_position: Vector2
var left_position: Vector2
var right_position: Vector2
var max_tilt_angle: float = 15  # Maximum tilt angle in degrees
var transition_speed: float = 0.3  # Duration for transition animations
var cursor_moved: bool = false  # Whether the cursor has moved
var initial_animation: bool = true  # Whether the mask is transitioning from no movement
var initial_mouse_pos: Vector2  # Initial cursor position for movement detection

# Falling animation properties
var is_animating: bool = false
var fall_speed: float = 1600
var horizontal_fall_speed: float = 600
var rotation_speed: float = 90.0
var fall_velocity: Vector2 = Vector2.ZERO
var swiped_left: bool = false
var swiped_right: bool = false
var threshold: float = 150

signal mask_disappeared  # New signal for when mask is removed

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	center_position = position
	left_position = center_position - Vector2(200, 0)
	right_position = center_position + Vector2(200, 0)
	initial_mouse_pos = get_global_mouse_position()

# Called every frame
func _process(delta: float) -> void:
	if is_animating:
		handle_fall_animation(delta)
	else:
		if not cursor_moved:
			check_cursor_movement(delta)
		if cursor_moved:
			follow_cursor(delta)

# Check if the cursor has moved from the initial position
func check_cursor_movement(delta: float) -> void:
	var global_mouse_pos = get_global_mouse_position()
	if global_mouse_pos.distance_to(initial_mouse_pos) > 10:
		cursor_moved = true

# Follow the mouse cursor smoothly
func follow_cursor(delta: float) -> void:
	var global_mouse_pos = get_global_mouse_position()

	if initial_animation:
		position.x = lerp(position.x, clamp(global_mouse_pos.x, left_position.x, right_position.x), delta * 5)
		if abs(position.x - global_mouse_pos.x) < 2:
			initial_animation = false
	else:
		position.x = clamp(global_mouse_pos.x, left_position.x, right_position.x)

	var tilt_ratio = (position.x - center_position.x) / (right_position.x - center_position.x)
	rotation_degrees = tilt_ratio * max_tilt_angle
	position.y = center_position.y

# Input event handler
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed and not is_animating:
		if position.x >= center_position.x + threshold:
			swiped_right = true
			start_fall_animation()
		elif position.x <= center_position.x - threshold:
			swiped_left = true
			start_fall_animation()
		else:
			reset_mask()

# Start the fall animation
func start_fall_animation() -> void:
	is_animating = true
	if swiped_right:
		fall_velocity = Vector2(horizontal_fall_speed, fall_speed)
	elif swiped_left:
		fall_velocity = Vector2(-horizontal_fall_speed, fall_speed)

# Handle falling animation
func handle_fall_animation(delta: float) -> void:
	position += fall_velocity * delta

	if swiped_right:
		rotation_degrees += rotation_speed * delta
	elif swiped_left:
		rotation_degrees -= rotation_speed * delta

	var viewport_height = get_viewport_rect().size.y
	if position.y > viewport_height + 100:
		emit_signal("mask_disappeared")  # Emit signal before being freed
		queue_free()

# Reset mask to center position with animation
func reset_mask() -> void:
	var position_tween = create_tween()
	position_tween.set_trans(Tween.TRANS_QUAD)
	position_tween.set_ease(Tween.EASE_OUT)
	position_tween.tween_property(self, "position", center_position, transition_speed)

	var rotation_tween = create_tween()
	rotation_tween.set_trans(Tween.TRANS_QUAD)
	rotation_tween.set_ease(Tween.EASE_OUT)
	rotation_tween.tween_property(self, "rotation_degrees", 0, transition_speed)

	cursor_moved = false
	initial_animation = true
	initial_mouse_pos = get_global_mouse_position()
