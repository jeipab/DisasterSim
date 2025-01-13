class_name BaseResourceIndicator
extends Control

@export var starting_value: float = 50.0
@export var animation_speed: float = 5.0
@export var color_fade_speed: float = 2.0  # Speed of color transition

var min_value: float = 0.0
var max_value: float = 100.0
var current_value: float = 0.0
var target_value: float = 0.0

# Color states
var default_color = Color("42aec9")
var increase_color = Color.GREEN
var decrease_color = Color.RED
var current_color = Color("42aec9")
var target_color = Color("42aec9")
var is_color_transitioning = false

# Resource identification
@export var resource_type: String = "Base"
@onready var color_fill = $FillMask/ColorFill

func _ready() -> void:
	set_process(true)
	initialize(starting_value)
	
	# Find the card system and connect to its signals
	var card_system = get_tree().get_root().find_child("CardSystem", true, false)
	if card_system:
		card_system.connect("card_spawned", _on_card_spawned)
		print("[ResourceIndicator] %s connected to CardSystem" % resource_type)
	else:
		print("[ResourceIndicator] %s failed to find CardSystem" % resource_type)

func _on_card_spawned(card) -> void:
	if !card.is_connected("card_chosen", _on_card_chosen):
		card.connect("card_chosen", _on_card_chosen)
		print("[ResourceIndicator] %s connected to new card" % resource_type)

func _on_card_chosen(is_right: bool) -> void:
	# Random change but influenced by choice direction
	var change = 10.0 if randf() < 0.5 else -10.0
	if !is_right:  # If it's a left swipe
		change *= -1
		
	print("[ResourceIndicator] %s responding to card choice, change: %s" % [resource_type, change])
	
	# Apply the change
	modify_value(change)
	if change > 0:
		flash_color(increase_color)
	else:
		flash_color(decrease_color)

func initialize(value: float) -> void:
	current_value = value
	target_value = value
	current_color = default_color
	color_fill.color = current_color
	update_visualization()

func _process(delta: float) -> void:
	# Handle value animation
	if not is_equal_approx(current_value, target_value):
		current_value = lerp(current_value, target_value, delta * animation_speed)
		update_visualization()
	
	# Handle color transition
	if is_color_transitioning:
		current_color = current_color.lerp(target_color, delta * color_fade_speed)
		color_fill.color = current_color
		
		# Check if we're close enough to target color to stop transitioning
		if current_color.is_equal_approx(target_color):
			is_color_transitioning = false
			current_color = default_color  # Force reset to default
			color_fill.color = current_color

func set_value(new_value: float) -> void:
	target_value = clamp(new_value, min_value, max_value)

func modify_value(amount: float) -> void:
	set_value(target_value + amount)

func get_value() -> float:
	return current_value

func flash_color(new_color: Color) -> void:
	current_color = new_color
	target_color = Color(default_color.r, default_color.g, default_color.b, default_color.a)  # Create a new Color instance
	is_color_transitioning = true
	color_fill.color = current_color

func update_visualization() -> void:
	if color_fill:
		var value_ratio = current_value / max_value
		var max_height = 401.0  # Matching your scene's ColorRect height
		var new_height = max_height * value_ratio
		
		# Update the ColorRect's height and position from bottom
		color_fill.size.y = new_height
		color_fill.position.y = max_height - new_height
