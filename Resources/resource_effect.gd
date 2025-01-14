extends Node2D

# Scale settings for different effect sizes based on change magnitudes
# Small effect: <= 15 (base 10 + variance 5)
# Medium effect: <= 30 (base change max)
# Large effect: > 30 (base 30 + variance 15)
@export var small_effect_scale: float = 0.15
@export var medium_effect_scale: float = 0.45
@export var large_effect_scale: float = 0.75

# Movement properties
var initial_position: Vector2
var target_position: Vector2
var move_amount: float = 650.0
var down_animation_speed: float = 5.0
var up_animation_speed: float = 8.0
var current_animation_speed: float = 5.0
var is_moving: bool = false
var is_down: bool = false

@onready var texture_rect = $CircleTexture

func _ready() -> void:
	set_process_input(true)
	
	initial_position = position
	target_position = initial_position
	
	texture_rect.pivot_offset = texture_rect.size / 2
	texture_rect.set_anchors_preset(Control.PRESET_CENTER)
	
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
	var parent = get_parent()
	# Only move if parent resource indicator is selected
	if parent and parent.has_method("get") and parent.requires_update:
		print("[ResourceEffect] Moving down for: ", parent.resource_type)
		move_down()

func _on_card_tilted_right() -> void:
	var parent = get_parent()
	# Only move if parent resource indicator is selected
	if parent and parent.has_method("get") and parent.requires_update:
		print("[ResourceEffect] Moving down for: ", parent.resource_type)
		move_down()

func _on_card_untilted() -> void:
	# Move up regardless, to ensure we return to starting position
	if is_down:
		var parent = get_parent()
		print("[ResourceEffect] Moving up for: ", parent.resource_type if parent else "unknown")
		move_up()

func move_down() -> void:
	if !is_down:
		target_position = initial_position + Vector2(0, move_amount)
		current_animation_speed = down_animation_speed
		is_moving = true
		is_down = true

func move_up() -> void:
	if is_down:
		target_position = initial_position
		current_animation_speed = up_animation_speed
		is_moving = true
		is_down = false

func _process(delta: float) -> void:
	if is_moving:
		position = position.lerp(target_position, current_animation_speed * delta)
		if position.distance_to(target_position) < 1.0:
			position = target_position
			is_moving = false
