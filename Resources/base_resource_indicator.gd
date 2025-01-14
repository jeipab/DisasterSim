class_name BaseResourceIndicator
extends Control

@export var starting_value: float = 50.0
@export var animation_speed: float = 5.0
@export var color_fade_speed: float = 2.0

# Change generation limits
var min_base_change: float = 10.0
var max_base_change: float = 30.0
var min_variance: float = 5.0
var max_variance: float = 15.0

var min_value: float = 0.0
var max_value: float = 100.0
var current_value: float = 0.0
var target_value: float = 0.0
var requires_update: bool = false

# Store pre-calculated changes for left/right swipes
var left_change: float = 0.0
var right_change: float = 0.0

# Color states
var default_color = Color("42aec9")
var increase_color = Color.GREEN
var decrease_color = Color.RED
var current_color = Color("42aec9")
var target_color = Color("42aec9")
var is_color_transitioning = false

@export var resource_type: String = "Base"
@onready var color_fill = $FillMask/ColorFill
@onready var resource_effect = $ResourceEffect

func _ready() -> void:
	set_process(true)
	initialize(starting_value)
	
	var card_system = get_tree().get_root().find_child("CardSystem", true, false)
	if card_system:
		card_system.connect("card_spawned", _on_card_spawned)

func _on_card_spawned(card) -> void:
	if !card.is_connected("card_chosen", _on_card_chosen):
		card.connect("card_chosen", _on_card_chosen)
		
	# Generate new random changes when a new card spawns
	if requires_update:
		generate_resource_changes()

func generate_resource_changes() -> void:
	# Generate base random change
	var base_change = randf_range(min_base_change, max_base_change)
	var variance = randf_range(min_variance, max_variance)
	
	# Randomly decide if left or right should be positive
	if randf() > 0.5:
		left_change = -base_change - variance
		right_change = base_change + variance
	else:
		left_change = base_change + variance
		right_change = -base_change - variance
	
	print("[ResourceIndicator] Generated changes for %s - Left: %f, Right: %f" % [resource_type, left_change, right_change])

func _on_card_chosen(is_right: bool) -> void:
	if requires_update:
		print("[ResourceIndicator] Applying %s change for: %s" % ["right" if is_right else "left", resource_type])
		var change = right_change if is_right else left_change
		modify_value(change)
		update_effect_scale(abs(change))
		
		if change > 0:
			flash_color(increase_color)
		else:
			flash_color(decrease_color)

func update_effect_scale(change_magnitude: float) -> void:
	if resource_effect:
		# Match scale thresholds to our possible change ranges
		var scale_value: float
		if change_magnitude <= 15:
			scale_value = resource_effect.small_effect_scale
		elif change_magnitude > 15 and change_magnitude <= 30:
			scale_value = resource_effect.medium_effect_scale
		else:  # > 30
			scale_value = resource_effect.large_effect_scale
		
		# Ensure the effect scale is set properly	
		resource_effect.scale = Vector2(scale_value, scale_value)
		print("[ResourceIndicator] Effect scale set to: ", scale_value, " for change magnitude: ", change_magnitude)

func initialize(value: float) -> void:
	current_value = value
	target_value = value
	current_color = default_color
	color_fill.color = current_color
	update_visualization()

func _process(delta: float) -> void:
	if not is_equal_approx(current_value, target_value):
		current_value = lerp(current_value, target_value, delta * animation_speed)
		update_visualization()
	
	if is_color_transitioning:
		current_color = current_color.lerp(target_color, delta * color_fade_speed)
		color_fill.color = current_color
		
		if current_color.is_equal_approx(target_color):
			is_color_transitioning = false
			current_color = default_color
			color_fill.color = current_color

func set_value(new_value: float) -> void:
	target_value = clamp(new_value, min_value, max_value)

func modify_value(amount: float) -> void:
	set_value(target_value + amount)

func get_value() -> float:
	return current_value

func flash_color(new_color: Color) -> void:
	current_color = new_color
	target_color = default_color
	is_color_transitioning = true
	color_fill.color = current_color

func update_visualization() -> void:
	if color_fill:
		var value_ratio = current_value / max_value
		var max_height = 401.0
		var new_height = max_height * value_ratio
		
		color_fill.size.y = new_height
		color_fill.position.y = max_height - new_height
