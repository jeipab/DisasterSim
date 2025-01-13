extends Node2D

# Scale limits
@export var min_scale: float = 0.8
@export var max_scale: float = 1.2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Make sure the node can process input
	set_process_input(true)
	
	# Get the texture rect and set its pivot
	var texture_rect = $CircleTexture
	# Set the pivot to the center
	texture_rect.pivot_offset = texture_rect.size / 2
	# Center the anchor
	texture_rect.set_anchors_preset(Control.PRESET_CENTER)

# Handle input events
func _input(event: InputEvent) -> void:
	# Check for mouse click events
	if event is InputEventMouseButton and event.pressed:
		# Check if click is within the texture area
		var texture_rect = $CircleTexture
		var click_pos = event.position
		if texture_rect.get_rect().has_point(click_pos):
			randomize_scale()

# Function to randomize the scale
func randomize_scale() -> void:
	# Generate random scale between min and max
	var new_scale = randf_range(min_scale, max_scale)
	# Apply the same scale to both x and y to maintain aspect ratio
	scale = Vector2(new_scale, new_scale)
