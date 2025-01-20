class_name BaseResourceIndicator
extends Control

@export var starting_value: float = 50.0
@export var animation_speed: float = 5.0
@export var color_fade_speed: float = 2.0

var min_value: float = 0.0
var max_value: float = 100.0
var current_value: float = 0.0
var target_value: float = 0.0
var requires_update: bool = false

# Store changes from FSM data
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
	if !card.is_connected("card_tilted_left", _on_card_tilted_left):
		card.connect("card_tilted_left", _on_card_tilted_left)
		card.connect("card_tilted_right", _on_card_tilted_right)
		card.connect("card_untilted", _on_card_untilted)
		card.connect("card_chosen", _on_card_chosen)
		
	# Connect signals to resource effect
	if resource_effect:
		if !card.is_connected("card_tilted_left", resource_effect._on_card_tilted_left):
			card.connect("card_tilted_left", resource_effect._on_card_tilted_left)
			card.connect("card_tilted_right", resource_effect._on_card_tilted_right)
			card.connect("card_untilted", resource_effect._on_card_untilted)
	
	update_resource_changes()

func update_resource_changes() -> void:
	var card_system = get_tree().get_root().find_child("CardSystem", true, false)
	if not card_system or not card_system.fsm:
		return
		
	var card_data = card_system.fsm.cards.get(card_system.current_card_id)
	if not card_data or card_data["type"] != "regular":
		requires_update = false
		return

	var left_resources = card_data["choices"]["left"]["resources"]
	var right_resources = card_data["choices"]["right"]["resources"]
	
	# Get changes if this resource is affected
	var resource_key = resource_type.to_lower()
	left_change = left_resources.get(resource_key, 0.0)
	right_change = right_resources.get(resource_key, 0.0)
	
	# Resource requires update if it has any non-zero changes
	requires_update = (left_change != 0.0 or right_change != 0.0)

func _on_card_tilted_left() -> void:
	if requires_update and left_change != 0.0:
		update_effect_scale(abs(left_change))

func _on_card_tilted_right() -> void:
	if requires_update and right_change != 0.0:
		update_effect_scale(abs(right_change))

func _on_card_untilted() -> void:
	if requires_update:
		clear_preview()

func _on_card_chosen(is_right: bool) -> void:
	if requires_update:
		var change = right_change if is_right else left_change
		if change != 0.0:
			modify_value(change)
			update_effect_scale(abs(change))
			flash_color(increase_color if change > 0 else decrease_color)

func update_effect_scale(change_magnitude: float) -> void:
	if resource_effect:
		var scale_value: float
		if change_magnitude <= 5:
			scale_value = resource_effect.small_effect_scale
		elif change_magnitude <= 10:
			scale_value = resource_effect.medium_effect_scale
		else:
			scale_value = resource_effect.large_effect_scale
		resource_effect.scale = Vector2(scale_value, scale_value)

func clear_preview() -> void:
	if resource_effect:
		resource_effect.scale = Vector2(0.5, 0.5)  # Reset to default scale

func flash_color(new_color: Color) -> void:
	current_color = new_color
	target_color = default_color
	is_color_transitioning = true
	color_fill.color = current_color

func initialize(value: float) -> void:
	current_value = value
	target_value = value
	current_color = default_color
	color_fill.color = current_color
	update_visualization()

func modify_value(amount: float) -> void:
	var card_system = get_tree().get_root().find_child("CardSystem", true, false)
	if card_system and card_system.resource_tracker:
		card_system.resource_tracker.modify_resource(resource_type, amount)
	set_value(target_value + amount)

func set_value(new_value: float) -> void:
	target_value = clamp(new_value, min_value, max_value)

func get_value() -> float:
	return current_value

func update_visualization() -> void:
	if color_fill:
		var value_ratio = current_value / max_value
		var max_height = 460.0
		var new_height = max_height * value_ratio
		
		color_fill.size.y = new_height
		color_fill.position.y = max_height - new_height

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
