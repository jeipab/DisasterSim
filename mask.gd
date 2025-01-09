extends Sprite2D

# Mask properties
var center_position: Vector2
var left_position: Vector2
var right_position: Vector2
var max_tilt_angle: float = 15  # Maximum tilt angle in degrees
var transition_speed: float = 0.3  # Duration for transition animations

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	center_position = position
	left_position = center_position - Vector2(200, 0)
	right_position = center_position + Vector2(200, 0)

# Called every frame
func _process(_delta: float) -> void:
	follow_cursor()

# Follow the mouse cursor
func follow_cursor() -> void:
	var global_mouse_pos = get_global_mouse_position()
	position.x = clamp(global_mouse_pos.x, left_position.x, right_position.x)

	# Tilt the mask based on horizontal position
	var tilt_ratio = (position.x - center_position.x) / (right_position.x - center_position.x)
	rotation_degrees = tilt_ratio * max_tilt_angle

	# Keep the mask at the original vertical position
	position.y = center_position.y

# Reset mask to center position with animation
func reset_mask() -> void:
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
