extends Node2D

# Shadow properties
var shadow_offset: float = 200.0  # Maximum vertical offset when farthest from the center
var fixed_opacity: float = 0.5  # Fixed opacity for the shadow
var sensitivity: float = 0.3  # Adjust this to make the shadow react faster (lower = faster)
var shadow_y_offset: float = -470.0  # Adjust this to move the shadow higher or lower

# Reference to the Sprite2D node
@onready var shadow_sprite: Sprite2D = $Sprite2D

# Called every frame
func _process(_delta: float) -> void:
	# Get mouse position relative to the viewport
	var mouse_position = get_viewport().get_mouse_position()

	# Ensure the Card node exists and pass its position
	if has_node("../Card"):  # Adjust the path to your Card node
		var card_position = get_node("../Card").position
		update_shadow(mouse_position, card_position)

# Function to update shadow properties
func update_shadow(mouse_position: Vector2, card_position: Vector2) -> void:
	var screen_size = get_viewport().get_visible_rect().size
	var screen_center = screen_size / 2

	# Calculate horizontal distance from the center
	var horizontal_distance = abs(mouse_position.x - screen_center.x)
	var max_horizontal_distance = screen_size.x * sensitivity  # Sensitivity affects max range
	var normalized_distance = clamp(horizontal_distance / max_horizontal_distance, 0, 1)

	# Calculate vertical offset based on normalized distance
	var vertical_offset = normalized_distance * shadow_offset

	# Update shadow position: Follow the Card's x position, and adjust y for vertical offset + custom y offset
	shadow_sprite.position = Vector2(card_position.x, screen_center.y + shadow_y_offset + vertical_offset)

	# Update shadow opacity
	shadow_sprite.modulate = Color(0, 0, 0, fixed_opacity)
