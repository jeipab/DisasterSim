extends Node2D

# Shadow properties
var shadow_offset: float = 200.0  # Maximum vertical offset when farthest from the center
var fixed_opacity: float = 0.5  # Fixed opacity for the shadow
var sensitivity: float = 0.3  # Adjust this to make the shadow react faster (lower = faster)
var shadow_y_offset: float = -470.0  # Adjust this to move the shadow higher or lower
var fixed_x_position: float = 0.0  # Fixed x-axis position for the shadow

# Reference to the shadow sprite and mask
@onready var shadow_sprite: Sprite2D = $Sprite2D
@onready var mask_node: Sprite2D = get_parent()  # Assumes parent is the Mask (Sprite2D)

func _ready() -> void:
	# Store the initial fixed x-axis position
	fixed_x_position = shadow_sprite.position.x

func _process(_delta: float) -> void:
	# Get mouse position relative to the viewport
	var mouse_position = get_viewport().get_mouse_position()
	update_shadow(mouse_position)

# Function to update shadow properties
func update_shadow(mouse_position: Vector2) -> void:
	var screen_size = get_viewport().get_visible_rect().size
	var screen_center = screen_size / 2

	# Calculate horizontal distance from the center
	var horizontal_distance = abs(mouse_position.x - screen_center.x)
	var max_horizontal_distance = screen_size.x * sensitivity  # Sensitivity affects max range
	var normalized_distance = clamp(horizontal_distance / max_horizontal_distance, 0, 1)

	# Calculate vertical offset based on normalized distance
	var vertical_offset = normalized_distance * shadow_offset

	# Negate the Mask's rotation (counter the tilt effect)
	var negated_rotation = -mask_node.rotation  # Inverse the mask's rotation (radians)

	# Update shadow position: Fixed x-axis, animated y-axis
	shadow_sprite.position = Vector2(fixed_x_position, screen_center.y + shadow_y_offset + vertical_offset)

	# Apply the negated rotation to counteract the Mask's tilt
	shadow_sprite.rotation = negated_rotation

	# Maintain fixed opacity
	shadow_sprite.modulate = Color(0, 0, 0, fixed_opacity)
