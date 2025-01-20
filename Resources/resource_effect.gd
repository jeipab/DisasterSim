extends Node2D

# Scale settings for different effect sizes
@export var small_effect_scale: float = 0.15  # <= 5
@export var medium_effect_scale: float = 0.30  # <= 10
@export var large_effect_scale: float = 0.60   # > 10

# Movement properties
var initial_position: Vector2
var target_position: Vector2
var move_amount: float = 625.0
var down_animation_speed: float = 5.0
var up_animation_speed: float = 5.0
var current_animation_speed: float = 5.0
var is_moving: bool = false
var is_down: bool = false
var just_reached_top: bool = false

@onready var texture_rect = $CircleTexture

func _ready() -> void:
	initial_position = position
	target_position = initial_position
	
	texture_rect.pivot_offset = texture_rect.size / 2
	texture_rect.set_anchors_preset(Control.PRESET_CENTER)

func _on_card_tilted_left() -> void:
	var parent = get_parent()
	if parent and parent.has_method("get_value") and parent.requires_update and parent.left_change != 0:
		scale_effect(abs(parent.left_change))
		move_down()

func _on_card_tilted_right() -> void:
	var parent = get_parent()
	if parent and parent.has_method("get_value") and parent.requires_update and parent.right_change != 0:
		scale_effect(abs(parent.right_change))
		move_down()

func _on_card_untilted() -> void:
	if is_down:
		move_up()

func scale_effect(change_magnitude: float) -> void:
	var new_scale: float
	if change_magnitude <= 5:
		new_scale = small_effect_scale
	elif change_magnitude <= 10:
		new_scale = medium_effect_scale
	else:
		new_scale = large_effect_scale
	
	scale = Vector2(new_scale, new_scale)

func reset_scale() -> void:
	await get_tree().create_timer(1.0).timeout
	scale = Vector2(0.5, 0.5)  # Default scale

func move_down() -> void:
	if !is_down:
		target_position = initial_position + Vector2(0, move_amount)
		current_animation_speed = down_animation_speed
		is_moving = true
		is_down = true
		just_reached_top = false

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
			
			# If we just finished moving up (reached top position)
			if !is_down and !just_reached_top:
				just_reached_top = true  # Mark that we've just reached the top
				reset_scale()  # Reset scale only after reaching the top
