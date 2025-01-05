extends Node2D

# Shadow properties
var shadow_offset: float = 100.0  # Maximum vertical offset when farthest from the center
var fixed_opacity: float = 0.50  # Fixed opacity for the shadow

# Reference to the Sprite2D node
@onready var shadow_sprite: Sprite2D = $Sprite2D

# Called every frame
func _process(delta: float) -> void:
	# Get mouse position relative to the viewport
	var mouse_position = get_viewport().get_mouse_position()
	update_shadow(mouse_position)

# Function to update shadow properties
func update_shadow(mouse_position: Vector2) -> void:
	var screen_size = get_viewport().get_visible_rect().size
	var screen_center = screen_size / 2

	# Calculate horizontal distance from the center (normalized between 0 and 1)
	var horizontal_distance = abs(mouse_position.x - screen_center.x)
	var max_horizontal_distance = screen_size.x / 2
	var normalized_distance = clamp(horizontal_distance / max_horizontal_distance, 0, 1)

	# Calculate vertical offset based on normalized distance
	var vertical_offset = normalized_distance * shadow_offset

	# Update shadow position and opacity
	shadow_sprite.position = Vector2(screen_center.x, screen_center.y + vertical_offset)
	shadow_sprite.modulate = Color(0, 0, 0, fixed_opacity)
