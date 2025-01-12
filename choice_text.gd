extends Node2D

var choice_pairs = [
	{"left": "No", "right": "Yes"},  # Very short
	{"left": "Reject Proposal", "right": "Accept Offer"},  # Medium
	{"left": "Absolutely Definitely Not Ever", "right": "Without Any Doubt Yes Indeed"},  # Long
	{"left": "Nope", "right": "Sure"},  # Short
	{"left": "This is completely unacceptable", "right": "I wholeheartedly agree with this"},  # Extra long
	{"left": "Never mind", "right": "Go ahead"}  # Short-medium
]

# Animation properties
var is_animating := false
var rise_speed := 10000.0  # Match shadow's rise speed
var fade_speed := 2.0     # Match shadow's fade speed
var initial_opacity := 1.0  # Start fully visible

var previous_pair := {"left": "", "right": ""}
var current_pair := {"left": "", "right": ""}

# Positioning properties
var text_scale := Vector2(3.0, 3.0)
var base_y_position := -2200.0
var base_visible_y_position := -500.0
var visible_y_position := -450.0
var movement_smooth_speed := 8.0
var horizontal_smooth_speed := 10.0
var base_x_position := -650
var max_x_offset_right := 125
var max_x_offset_left := 350
var line_height_offset := 250.0

# Text properties
var text_width := 500
var text_base_x := -400
var text_margin := 100
var text_y_offset := -100
var max_chars_per_line := 20

# Movement thresholds
var activation_threshold := 400
var full_visibility_threshold := 400
var return_threshold := 250.0

# Node references
@onready var choice_label := $ChoiceLabel
@onready var shadow_node = get_parent()
@onready var delay_timer := $DelayTimer

# State tracking
var cursor_moved := false
var last_mouse_pos := Vector2()
var current_side := "center"

func count_lines(text: String) -> int:
	if text.is_empty():
		return 1
	var words = text.split(" ")
	var current_line_length := 0
	var line_count := 1
	
	for word in words:
		if current_line_length + word.length() + 1 > max_chars_per_line:
			line_count += 1
			current_line_length = word.length()
		else:
			current_line_length += word.length() + 1
	
	return line_count

func adjust_visible_position(text: String) -> void:
	var lines = count_lines(text)
	visible_y_position = base_visible_y_position - ((lines - 1) * line_height_offset)

func _ready() -> void:
	randomize()
	update_choices()
	
	# Configure the RichTextLabel
	choice_label.position = Vector2(text_base_x, base_y_position)
	choice_label.scale = text_scale
	choice_label.size = Vector2(text_width, 0)
	choice_label.custom_minimum_size = Vector2(text_width, 0)
	choice_label.fit_content = true
	choice_label.clip_contents = false
	choice_label.auto_translate = false
	
	var mask_node = shadow_node.get_parent()
	if mask_node:
		mask_node.connect("mask_disappeared", Callable(self, "_on_mask_disappeared"))
	
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
			update_choice_position_and_text(delta)
			counter_rotate()

func update_choice_position_and_text(delta: float) -> void:
	var viewport_size = get_viewport_rect().size
	var screen_center = viewport_size.x / 2
	var mouse_pos = get_viewport().get_mouse_position()
	var distance_from_center = abs(mouse_pos.x - screen_center)
	
	# Calculate vertical movement
	var target_y = base_y_position
	var vertical_ratio = 0.0
	
	if distance_from_center > activation_threshold:
		if distance_from_center <= full_visibility_threshold:
			vertical_ratio = (distance_from_center - activation_threshold) / (full_visibility_threshold - activation_threshold)
		else:
			vertical_ratio = 1.0
	else:
		vertical_ratio = max(0.0, (distance_from_center - activation_threshold / 2) / activation_threshold)
	
	# Adjust visible_y_position based on current text
	if mouse_pos.x < screen_center:
		adjust_visible_position(current_pair.left)
	else:
		adjust_visible_position(current_pair.right)
	
	target_y = lerp(base_y_position, visible_y_position, vertical_ratio)
	
	# Calculate horizontal movement with asymmetric offsets
	var direction = sign(mouse_pos.x - screen_center)
	var horizontal_ratio = clamp(distance_from_center / full_visibility_threshold, 0.0, 1.0)
	var max_offset = max_x_offset_right if direction > 0 else max_x_offset_left
	var target_x = base_x_position + (direction * max_offset * horizontal_ratio)
	
	# Update positions with smooth interpolation
	choice_label.position.y = lerp(choice_label.position.y, target_y, delta * movement_smooth_speed)
	choice_label.position.x = lerp(choice_label.position.x, target_x, delta * horizontal_smooth_speed)
	
	# Update text visibility and alignment
	if distance_from_center < activation_threshold / 2:
		choice_label.text = ""
		current_side = "center"
	elif mouse_pos.x < screen_center:
		if current_side != "left":
			current_side = "left"
			choice_label.position = Vector2(text_base_x - text_margin, choice_label.position.y)
		choice_label.text = "[left]" + current_pair.left + "[/left]"
	else:
		if current_side != "right":
			current_side = "right"
			choice_label.position = Vector2(text_base_x + text_margin, choice_label.position.y)
		choice_label.text = "[right]" + current_pair.right + "[/right]"

	# Update modulation for fade effect
	if is_animating:
		choice_label.modulate.a = max(0, choice_label.modulate.a - fade_speed * delta)

func counter_rotate() -> void:
	var mask_node = get_parent().get_parent()
	if mask_node:
		rotation = -mask_node.rotation
		choice_label.rotation = 0

func start_rise_animation() -> void:
	is_animating = true
	choice_label.modulate.a = initial_opacity

func handle_rise_animation(delta: float) -> void:
	choice_label.position.y -= rise_speed * delta
	choice_label.modulate.a = max(0, choice_label.modulate.a - fade_speed * delta)
	if choice_label.modulate.a <= 0:
		queue_free()

func update_choices() -> void:
	var new_pair
	while true:
		new_pair = choice_pairs[randi() % choice_pairs.size()]
		if new_pair.left != previous_pair.left and new_pair.right != previous_pair.right:
			break
	current_pair = new_pair
	previous_pair = new_pair

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		var mouse_pos = get_viewport().get_mouse_position()
		var screen_center = get_viewport().get_visible_rect().size.x / 2
		var threshold = 150
		
		if abs(mouse_pos.x - screen_center) > threshold:
			start_rise_animation()

func _on_mask_disappeared() -> void:
	print("Mask disappeared. Updating choices...")
	update_choices()
	is_animating = false
