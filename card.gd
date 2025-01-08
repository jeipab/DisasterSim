extends Area2D

# Card properties
var swiped_right: bool = false
var swiped_left: bool = false
var threshold: float = 150  # Distance to trigger left or right swipe
var transition_speed: float = 0.3  # Duration for transition animations
var max_tilt_angle: float = 15  # Maximum tilt angle in degrees
var is_animating: bool = false  # Whether the card is currently animating
var fall_speed: float = 1600  # Base speed for the vertical fall animation
var horizontal_fall_speed: float = 600  # Base speed for horizontal trajectory
var rotation_speed: float = 90.0  # Speed of rotation during the fall

# Signals
signal card_fell_off

# Positions
var left_position: Vector2
var right_position: Vector2
var center_position: Vector2

# Velocity for the fall
var fall_velocity: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	center_position = position
	left_position = center_position - Vector2(200, 0)
	right_position = center_position + Vector2(200, 0)

# Called every frame
func _process(delta: float) -> void:
	if is_animating:
		handle_fall_animation(delta)
	else:
		follow_cursor()

# Follow the mouse cursor
func follow_cursor() -> void:
	var global_mouse_pos = get_global_mouse_position()
	position.x = clamp(global_mouse_pos.x, left_position.x, right_position.x)

	# Tilt the card based on horizontal position
	var tilt_ratio = (position.x - center_position.x) / (right_position.x - center_position.x)
	rotation_degrees = tilt_ratio * max_tilt_angle

	# Keep the card at the original vertical position
	position.y = center_position.y

# Input event handler
func _input(event: InputEvent) -> void:
	# Check for left mouse button release to make a choice
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed and not is_animating:
		if position.x >= center_position.x + threshold:
			swiped_right = true
			start_fall_animation()
		elif position.x <= center_position.x - threshold:
			swiped_left = true
			start_fall_animation()
		else:
			# Reset position and rotation if not swiped enough
			reset_card()

# Start the fall animation with an initial velocity
func start_fall_animation() -> void:
	is_animating = true
	# Set horizontal velocity based on swipe direction
	if swiped_right:
		fall_velocity = Vector2(horizontal_fall_speed, fall_speed)  # Diagonal right
	elif swiped_left:
		fall_velocity = Vector2(-horizontal_fall_speed, fall_speed)  # Diagonal left

# Handle card falling offscreen along a diagonal trajectory
func handle_fall_animation(delta: float) -> void:
	# Update the card's position based on the velocity
	position += fall_velocity * delta

	# Add more rotation during the fall
	if swiped_right:
		rotation_degrees += rotation_speed * delta  # Rotate clockwise
	elif swiped_left:
		rotation_degrees -= rotation_speed * delta  # Rotate counterclockwise

	# Check if the card is fully offscreen
	var viewport_height = get_viewport_rect().size.y
	if position.y > viewport_height + 100:  # Ensure card fully exits the screen with a buffer
		emit_signal("card_fell_off")  # Emit signal when card is offscreen
		queue_free()  # Remove the card from the scene

# Reset card to center position with animation
func reset_card() -> void:
	# Tween for position
	var position_tween = create_tween()
	position_tween.set_trans(Tween.TRANS_QUAD)
	position_tween.set_ease(Tween.EASE_OUT)
	position_tween.tween_property(self, "position", center_position, transition_speed)

	# Tween for rotation
	var rotation_tween = create_tween()
	rotation_tween.set_trans(Tween.TRANS_QUAD)
	rotation_tween.set_ease(Tween.EASE_OUT)
	rotation_tween.tween_property(self, "rotation_degrees", 0, transition_speed)
