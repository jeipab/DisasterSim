extends Node2D

var fsm  # Reference to FSM node
var current_card_id: int = 1  # Start with first card
signal choice_made(is_right: bool)  # Add signal for choice

# Animation properties
var is_animating := false
var rise_speed := 10000.0
var fade_speed := 2.0
var initial_opacity := 1.0

var current_pair := {"left": "", "right": ""}

# Positioning properties
var text_scale := Vector2(3.0, 3.0)
var base_y_position := -2200.0  # Starting position
var base_max_y_offset := 1800.0  # Base maximum distance to move up
var additional_line_offset := -150  # Additional offset per line
var sensitivity := 0.3          # Matches shadow's sensitivity
var horizontal_smooth_speed := 10.0
var base_x_position := -650
var max_x_offset_right := -120
var max_x_offset_left := 350
var line_height_offset := 250.0

# Smooth movement properties
var current_vertical_offset := 0.0
var target_vertical_offset := 0.0
var moving_away_speed := 15.0   # Speed when moving away from base position
var returning_speed := 25.0     # Speed when returning to base position
var was_away_from_center := false
var center_threshold := 20.0

# Text properties
var text_width := 600
var text_base_x := -400
var text_margin := 100
var text_y_offset := -100
var max_chars_per_line := 16

# Node references
@onready var choice_label := $ChoiceLabel
@onready var shadow_node = get_parent()
@onready var sfx_swipe: AudioStreamPlayer = $sfx_swipe
@onready var sfx_swipe_up: AudioStreamPlayer = $sfx_swipe_up

# State tracking
var cursor_moved := false
var last_mouse_pos := Vector2()
var current_side := "center"

func initialize(fsm_node) -> void:
	fsm = fsm_node
	if fsm:
		update_choices()  # Set initial choices
	else:
		push_error("[ChoiceText] Failed to initialize - no FSM provided")

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

func get_adjusted_max_y_offset(text: String) -> float:
	var lines = count_lines(text)
	return base_max_y_offset + ((lines - 1) * additional_line_offset)

func sync_with_scenario(card_id: int) -> void:
	current_card_id = card_id
	update_choices()

func _ready() -> void:
	# Find the FSM node if not already initialized
	if not fsm:
		fsm = get_tree().get_root().find_child("Fsm", true, false)
		if fsm:
			update_choices()
		else:
			push_error("[ChoiceText] FSM node not found!")
			return
	
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
	var screen_size = get_viewport_rect().size
	var screen_center = screen_size.x / 2
	var mouse_pos = get_viewport().get_mouse_position()
	
	# Calculate horizontal distance from center
	var horizontal_distance = abs(mouse_pos.x - screen_center)
	var max_horizontal_distance = screen_size.x * sensitivity
	var normalized_distance = clamp(horizontal_distance / max_horizontal_distance, 0, 1)
	
	# Get the current text based on mouse position
	var current_text = current_pair.left if mouse_pos.x < screen_center else current_pair.right
	
	# Calculate max_y_offset based on text length
	var current_max_y_offset = get_adjusted_max_y_offset(current_text)
	
	# Set target vertical offset based on normalized distance and text length
	target_vertical_offset = normalized_distance * current_max_y_offset
	
	# Determine if we're near the center
	var is_near_center = horizontal_distance < center_threshold
	
	# Choose animation speed based on movement direction
	var current_speed = returning_speed if (is_near_center and was_away_from_center) else moving_away_speed
	
	# Update the away-from-center state
	was_away_from_center = !is_near_center
	
	# Smoothly interpolate vertical position
	current_vertical_offset = lerp(current_vertical_offset, target_vertical_offset, delta * current_speed)
	
	# Calculate horizontal movement
	var direction = sign(mouse_pos.x - screen_center)
	var max_offset = max_x_offset_right if direction > 0 else max_x_offset_left
	var target_x = base_x_position + (direction * max_offset * normalized_distance)
	
	# Update positions
	choice_label.position.y = base_y_position + current_vertical_offset
	choice_label.position.x = lerp(choice_label.position.x, target_x, delta * horizontal_smooth_speed)
	
	var previous_side = current_side
	
	# Update text visibility and content
	if is_near_center:
		choice_label.text = ""
		current_side = "center"
		if not sfx_swipe_up.is_playing() and previous_side != "center":
			sfx_swipe_up.play()
	elif mouse_pos.x < screen_center:
		if current_side != "left":
			current_side = "left"
			choice_label.position = Vector2(text_base_x - text_margin, choice_label.position.y)
			sfx_swipe.play()
		choice_label.text = "[left]" + current_pair.left + "[/left]"
	else:
		if current_side != "right":
			current_side = "right"
			choice_label.position = Vector2(text_base_x + text_margin, choice_label.position.y)
			sfx_swipe.play()
		choice_label.text = "[right]" + current_pair.right + "[/right]"
		
	

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
	if not fsm:
		push_error("[ChoiceText] FSM not found when updating choices")
		return
		
	var card_data = fsm.cards.get(current_card_id)
	if not card_data:
		push_error("[ChoiceText] Card ID %d not found in FSM" % current_card_id)
		return
		
	if card_data["type"] == "win":
		current_pair = {
			"left": card_data["choices"]["left"]["text"],
			"right": card_data["choices"]["right"]["text"]
		}
	elif card_data["type"] == "regular":
		if not card_data["choices"].has("left") or not card_data["choices"].has("right"):
			push_error("[ChoiceText] Card %d missing left or right choice" % current_card_id)
			return
		current_pair = {
			"left": card_data["choices"]["left"]["text"],
			"right": card_data["choices"]["right"]["text"]
		}
		
	if not card_data["choices"].has("left") or not card_data["choices"].has("right"):
		push_error("[ChoiceText] Card %d missing left or right choice" % current_card_id)
		return
		
	# Update choices from card data
	current_pair = {
		"left": card_data["choices"]["left"]["text"],
		"right": card_data["choices"]["right"]["text"]
	}

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		# Check if click was on UI buttons
		var ui_layer = get_tree().get_root().find_child("UILayer", true, false)
		if ui_layer:
			var exit_button = ui_layer.get_node("ExitButton")
			var sound_toggle = ui_layer.get_node("SoundToggle")
			
			if exit_button and sound_toggle:
				var mouse_pos = get_viewport().get_mouse_position()
				var exit_rect = Rect2(exit_button.global_position, exit_button.size * exit_button.scale)
				var sound_rect = Rect2(sound_toggle.global_position, sound_toggle.size * sound_toggle.scale)
				
				# Skip card handling if click was on buttons
				if exit_rect.has_point(mouse_pos) or sound_rect.has_point(mouse_pos):
					return

		var mouse_pos = get_viewport().get_mouse_position()
		var screen_center = get_viewport().get_visible_rect().size.x / 2
		var threshold = 150
		
		if abs(mouse_pos.x - screen_center) > threshold:
			# Emit signal for choice made
			var is_right = mouse_pos.x > screen_center
			emit_signal("choice_made", is_right)
			start_rise_animation()

func _on_mask_disappeared() -> void:
	if fsm:
		var card_data = fsm.cards.get(current_card_id)
		if card_data and card_data["type"] == "regular":
			# Get next card ID based on last choice
			var choice = "right" if current_side == "right" else "left"
			if card_data["choices"].has(choice):
				current_card_id = card_data["choices"][choice]["next_card"]
				update_choices()
	
	is_animating = false
