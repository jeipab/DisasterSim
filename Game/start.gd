extends Node2D

@onready var start_button = $StartButton
@onready var mask = $Mask
@onready var icon = $Mask/Icon
@onready var animation_player = $AnimationPlayer

# Tilt properties
var max_tilt_angle: float = 8.0  # Reduced max tilt for subtler effect
var tilt_sensitivity: float = 0.3  # How responsive the tilt is to mouse movement
var center_screen: float

func _ready():
	# Connect button signal
	start_button.pressed.connect(_on_start_button_pressed)
	
	# Get center of screen for tilt calculations
	center_screen = get_viewport_rect().size.x / 2
	
	# Start idle floating animation
	if animation_player:
		animation_player.play("idle_float")

func _process(_delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	update_tilt(mouse_pos)

func update_tilt(mouse_pos: Vector2) -> void:
	# Calculate how far mouse is from center
	var distance_from_center = (mouse_pos.x - center_screen)
	var max_distance = get_viewport_rect().size.x * tilt_sensitivity
	
	# Calculate tilt angle based on mouse position
	var tilt = (distance_from_center / max_distance) * max_tilt_angle
	
	# Apply tilt while preserving the vertical position from the float animation
	var current_pos = mask.position
	mask.rotation_degrees = clamp(tilt, -max_tilt_angle, max_tilt_angle)

func _on_start_button_pressed():
	# Stop the floating animation
	animation_player.stop()
	
	# Create a parallel tween for synchronized animations
	var tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# Initial scale down of both mask and icon
	tween.tween_property(mask, "scale", Vector2(1.8, 1.8), 0.2)
	tween.tween_property(icon, "scale", Vector2(0.12, 0.12), 0.2)
	
	await tween.finished
	
	# Flip animation
	var tween_flip = create_tween().set_parallel(true)
	tween_flip.set_trans(Tween.TRANS_QUAD)
	
	# Scale and rotate both elements together
	tween_flip.tween_property(mask, "scale", Vector2(0, 2), 0.4)
	tween_flip.tween_property(icon, "scale:x", 0, 0.4)
	tween_flip.tween_property(mask, "rotation_degrees", 180, 0.4)
	tween_flip.tween_property(icon, "rotation_degrees", 180, 0.4)
	
	await tween_flip.finished
	
	# Final shrink of both elements
	var tween_final = create_tween().set_parallel(true)
	tween_final.set_trans(Tween.TRANS_BACK)
	tween_final.set_ease(Tween.EASE_IN)
	
	tween_final.tween_property(mask, "scale", Vector2.ZERO, 0.3)
	tween_final.tween_property(icon, "scale", Vector2.ZERO, 0.3)
	
	await tween_final.finished
	
	# Change to game scene
	get_tree().change_scene_to_file("res://Game/game.tscn")
