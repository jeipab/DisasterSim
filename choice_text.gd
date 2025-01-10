extends Node2D

var choice_pairs = [
	{"left": "Decline", "right": "Accept"},
	{"left": "Reject", "right": "Approve"},
	{"left": "No", "right": "Yes"}
]

# Animation properties
var text_opacity := 0.0
var target_opacity := 0.0
var opacity_smooth_speed := 10.0
var movement_threshold := 100.0  # Threshold before the opacity changes
var threshold_distance := 200.0  # Distance needed for opacity to start increasing
var is_animating := false
var rise_speed := 2000.0
var fade_speed := 2.0

var previous_left: String = ""
var previous_right: String = ""

# Positioning properties
var text_scale := Vector2(3.0, 3.0)

# Vertical movement properties
var max_vertical_offset: float = 50.0  # Maximum vertical offset based on cursor
var vertical_smooth_speed: float = 5.0  # Speed for smooth vertical movement
var current_vertical_offset: float = 0.0  # Current vertical offset for labels

# Node references
@onready var left_label := $LeftChoice
@onready var right_label := $RightChoice
@onready var shadow_node = get_parent()
@onready var delay_timer := $DelayTimer

# State to track cursor movement
var cursor_moved := false
var last_mouse_pos := Vector2()
var delay_completed := false

func _ready() -> void:
	randomize()
	update_choices()
	
	left_label.modulate.a = 0
	right_label.modulate.a = 0
	
	left_label.position = Vector2(-1000, -550)
	right_label.position = Vector2(200, -550)
	
	left_label.scale = text_scale
	right_label.scale = text_scale
	
	var mask_node = shadow_node.get_parent()
	if mask_node:
		mask_node.connect("mask_disappeared", Callable(self, "_on_mask_disappeared"))
	
	# Initialize mouse position
	last_mouse_pos = get_viewport().get_mouse_position()

func _process(delta: float) -> void:
	var current_mouse_pos = get_viewport().get_mouse_position()
	if current_mouse_pos != last_mouse_pos:
		cursor_moved = true
		last_mouse_pos = current_mouse_pos

	if cursor_moved:
		if is_animating:
			handle_rise_animation(delta)
		else:
			handle_text_visibility(delta)
			update_vertical_position(delta)
			counter_rotate()

func handle_text_visibility(delta: float) -> void:
	var viewport_size = get_viewport_rect().size
	var screen_center = viewport_size.x / 2
	var mouse_pos = get_viewport().get_mouse_position()
	var distance_from_center = mouse_pos.x - screen_center
	
	# Only start adjusting opacity after the cursor exceeds the threshold distance
	if abs(distance_from_center) > threshold_distance:
		var opacity_change = (abs(distance_from_center) - threshold_distance) / movement_threshold
		target_opacity = clamp(opacity_change, 0.0, 1.0)
		
		if distance_from_center > 0:
			left_label.modulate.a = 0
			text_opacity = lerp(text_opacity, target_opacity, delta * opacity_smooth_speed)
			right_label.modulate.a = text_opacity
		else:
			right_label.modulate.a = 0
			text_opacity = lerp(text_opacity, target_opacity, delta * opacity_smooth_speed)
			left_label.modulate.a = text_opacity
	else:
		target_opacity = 0.0
		text_opacity = 0.0
		left_label.modulate.a = 0
		right_label.modulate.a = 0

func counter_rotate() -> void:
	var mask_node = get_parent().get_parent()
	if mask_node:
		rotation = -mask_node.rotation
		left_label.rotation = 0
		right_label.rotation = 0

func set_choices(left: String, right: String) -> void:
	left_label.text = "[center]" + left + "[/center]"
	right_label.text = "[center]" + right + "[/center]"

func start_rise_animation() -> void:
	is_animating = true
	text_opacity = max(left_label.modulate.a, right_label.modulate.a)

func handle_rise_animation(delta: float) -> void:
	position.y -= rise_speed * delta
	
	text_opacity = max(0, text_opacity - fade_speed * delta)
	left_label.modulate.a = text_opacity
	right_label.modulate.a = text_opacity
	
	if text_opacity <= 0:
		queue_free()

func update_choices() -> void:
	var new_pair
	while true:
		new_pair = choice_pairs[randi() % choice_pairs.size()]
		if new_pair["left"] != previous_left and new_pair["right"] != previous_right:
			break
	set_choices(new_pair["left"], new_pair["right"])
	previous_left = new_pair["left"]
	previous_right = new_pair["right"]

# Signal handler for mask disappearance
func _on_mask_disappeared() -> void:
	print("Mask disappeared. Updating choices...")
	update_choices()
	is_animating = false
	left_label.modulate.a = 0
	right_label.modulate.a = 0

# New function to handle vertical movement
func update_vertical_position(delta: float) -> void:
	var viewport_size = get_viewport_rect().size
	var screen_center_y = viewport_size.y / 2
	var mouse_pos_y = get_viewport().get_mouse_position().y

	# Calculate target vertical offset
	var vertical_distance = mouse_pos_y - screen_center_y
	var target_vertical_offset = clamp(vertical_distance / screen_center_y * max_vertical_offset, -max_vertical_offset, max_vertical_offset)

	# Smoothly interpolate the current vertical offset
	current_vertical_offset = lerp(current_vertical_offset, target_vertical_offset, delta * vertical_smooth_speed)

	# Apply the vertical offset to the labels
	left_label.position.y = -550 + current_vertical_offset
	right_label.position.y = -550 + current_vertical_offset
