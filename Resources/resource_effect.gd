extends Node2D

# Scale limits
@export var min_scale: float = 0.8
@export var max_scale: float = 1.2

# Movement properties
var initial_position: Vector2
var target_position: Vector2
var move_amount: float = 600.0  # Amount to move down when tilted
var down_animation_speed: float = 5.0  # Speed of downward movement
var up_animation_speed: float = 8.0   # Faster speed for returning to center
var current_animation_speed: float = 5.0  # Current animation speed
var is_moving: bool = false

@onready var texture_rect = $CircleTexture

func _ready() -> void:
	# Make sure the node can process input
	set_process_input(true)
	
	# Store initial position
	initial_position = position
	target_position = initial_position
	
	# Set up the texture rect
	texture_rect.pivot_offset = texture_rect.size / 2
	texture_rect.set_anchors_preset(Control.PRESET_CENTER)
	
	# Connect to card signals
	var card_system = get_tree().get_root().find_child("CardSystem", true, false)
	if card_system:
		print("[ResourceEffect] Found CardSystem, waiting for card")
		card_system.connect("card_spawned", _on_card_spawned)

func _on_card_spawned(card) -> void:
	if !card.is_connected("card_tilted_left", _on_card_tilted_left):
		card.connect("card_tilted_left", _on_card_tilted_left)
		card.connect("card_tilted_right", _on_card_tilted_right)
		card.connect("card_untilted", _on_card_untilted)
		print("[ResourceEffect] Connected to card signals")

func _on_card_tilted_left() -> void:
	print("[ResourceEffect] Received left tilt")
	move_down()

func _on_card_tilted_right() -> void:
	print("[ResourceEffect] Received right tilt")
	move_down()

func _on_card_untilted() -> void:
	print("[ResourceEffect] Received untilt")
	move_up()

func move_down() -> void:
	target_position = initial_position + Vector2(0, move_amount)
	current_animation_speed = down_animation_speed
	is_moving = true

func move_up() -> void:
	target_position = initial_position
	current_animation_speed = up_animation_speed
	is_moving = true

func _process(delta: float) -> void:
	if is_moving:
		# Smoothly interpolate to target position
		position = position.lerp(target_position, current_animation_speed * delta)
		
		# Check if we're close enough to stop moving
		if position.distance_to(target_position) < 1.0:
			position = target_position
			is_moving = false

func _input(event: InputEvent) -> void:
	# Handle mouse click events for scale changes
	if event is InputEventMouseButton and event.pressed:
		var click_pos = event.position
		if texture_rect.get_rect().has_point(click_pos):
			randomize_scale()

func randomize_scale() -> void:
	var new_scale = randf_range(min_scale, max_scale)
	scale = Vector2(new_scale, new_scale)
