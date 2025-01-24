extends Node2D

# Shadow properties
var shadow_offset: float = 200.0
var fixed_opacity: float = 0.5
var sensitivity: float = 0.3
var shadow_y_offset: float = -470.0
var fixed_x_position: float = 0.0

# Animation properties
var is_animating: bool = false
var rise_speed: float = 2000.0
var fade_speed: float = 2.0
var initial_opacity: float = 0.5

# Smoothing properties
var current_vertical_offset: float = 0.0
var target_vertical_offset: float = 0.0
var moving_away_speed: float = 50.0  # Smooth speed when moving away from center
var returning_speed: float = 30.0   # Snappy speed when returning to center
var was_away_from_center: bool = false  # Track if we were away from center

# Cursor movement detection
var cursor_moved: bool = false
var initial_mouse_pos: Vector2
var movement_threshold: float = 10.0
var center_threshold: float = 20.0  # Threshold to consider cursor "at center"

# Reference to the shadow sprite and mask
@onready var shadow_sprite: Sprite2D = $Sprite2D
@onready var mask_node: Sprite2D = get_parent()

signal shadow_disappeared

func _ready() -> void:
	fixed_x_position = shadow_sprite.position.x
	initial_mouse_pos = get_viewport().get_mouse_position()
	# Set initial shadow position without offset
	var screen_center = get_viewport().get_visible_rect().size / 2
	shadow_sprite.position = Vector2(fixed_x_position, screen_center.y + shadow_y_offset)
	shadow_sprite.modulate = Color(0, 0, 0, fixed_opacity)

func _process(delta: float) -> void:
	if is_animating:
		handle_rise_animation(delta)
	else:
		var mouse_position = get_viewport().get_mouse_position()
		
		# Check if cursor has moved beyond threshold
		if not cursor_moved:
			if mouse_position.distance_to(initial_mouse_pos) > movement_threshold:
				cursor_moved = true
		
		# Only update shadow position if cursor has moved
		if cursor_moved:
			update_shadow(mouse_position, delta)

func update_shadow(mouse_position: Vector2, delta: float) -> void:
	var screen_size = get_viewport().get_visible_rect().size
	var screen_center = screen_size / 2
	
	var horizontal_distance = abs(mouse_position.x - screen_center.x)
	var max_horizontal_distance = screen_size.x * sensitivity
	var normalized_distance = clamp(horizontal_distance / max_horizontal_distance, 0, 1)
	
	# Set target vertical offset
	target_vertical_offset = normalized_distance * shadow_offset
	
	# Determine if we're near the center
	var is_near_center = horizontal_distance < center_threshold
	
	# Choose animation speed based on movement direction
	var current_speed
	if is_near_center and was_away_from_center:
		# Snappy return to center
		current_speed = returning_speed
	else:
		# Smooth movement away from center
		current_speed = moving_away_speed
	
	# Update the away-from-center state
	was_away_from_center = !is_near_center
	
	# Apply movement with the selected speed
	current_vertical_offset = lerp(current_vertical_offset, target_vertical_offset, delta * current_speed)
	
	# If we're returning to center and very close to it, snap to initial position
	if is_near_center and abs(current_vertical_offset) < 5.0:
		current_vertical_offset = 0.0
	
	# Smoothly interpolate rotation (keep this smooth regardless of direction)
	var target_rotation = -mask_node.rotation
	var current_rotation = lerp(shadow_sprite.rotation, target_rotation, delta * moving_away_speed)
	
	# Update shadow position and rotation
	shadow_sprite.position = Vector2(fixed_x_position, screen_center.y + shadow_y_offset + current_vertical_offset)
	shadow_sprite.rotation = current_rotation
	shadow_sprite.modulate = Color(0, 0, 0, fixed_opacity)

func start_rise_animation() -> void:
	is_animating = true
	shadow_sprite.modulate.a = initial_opacity

func handle_rise_animation(delta: float) -> void:
	shadow_sprite.position.y -= rise_speed * delta
	shadow_sprite.modulate.a = max(0, shadow_sprite.modulate.a - fade_speed * delta)
	
	if shadow_sprite.modulate.a <= 0:
		emit_signal("shadow_disappeared")
		queue_free()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		# Check if click was on UI buttons
		var ui_layer = get_tree().get_root().find_child("UILayer", true, false)
		if ui_layer:
			var exit_button = ui_layer.get_node("ExitButton")
			var sound_toggle = ui_layer.get_node("SoundToggle")
			var retry_button = ui_layer.get_node("RetryButton")
			
			if exit_button and sound_toggle and retry_button:
				var mouse_pos = get_viewport().get_mouse_position()
				var exit_rect = Rect2(exit_button.global_position, exit_button.size * exit_button.scale)
				var sound_rect = Rect2(sound_toggle.global_position, sound_toggle.size * sound_toggle.scale)
				var retry_rect = Rect2(retry_button.global_position, retry_button.size * retry_button.scale)
				
				# Skip card handling if click was on buttons
				if exit_rect.has_point(mouse_pos) or sound_rect.has_point(mouse_pos) or retry_rect.has_point(mouse_pos):
					return

		var mouse_pos = get_viewport().get_mouse_position()
		var screen_center = get_viewport().get_visible_rect().size.x / 2
		var threshold = 150
		
		if abs(mouse_pos.x - screen_center) > threshold:
			start_rise_animation()
