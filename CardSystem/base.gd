extends Area2D

# Signal to notify when a new card should be introduced
signal new_card_needed

var grow_speed := 5.0 # Speed of the grow/shrink animation
var original_scale := Vector2(1, 1) # Original scale
var grow_scale := Vector2(1.2, 1.2) # Scale during growth
var animating := false # Prevents repeated clicks during animation
var initial_texture: Texture  # Store the initial card back texture
var fsm = null  # Reference to FSM node
var card_system = null  # Reference to CardSystem

@onready var card_sprite := $CardSprite # Sprite2D node for the card
@onready var sfx_flip: AudioStreamPlayer = $sfx_flip

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	# Set initial scale
	original_scale = self.scale
	self.connect("input_event", Callable(self, "_on_area2d_input_event"))
	
	# Load and set the initial card back texture
	initial_texture = load("res://Art/Card_Back_Card (Back).png")
	card_sprite.texture = initial_texture
	
	# Get FSM and CardSystem references
	fsm = get_tree().get_root().find_child("Fsm", true, false)
	card_system = get_parent()
	
	if !fsm or !card_system:
		push_error("[Base] Failed to find required nodes!")

# When the base is clicked, start the animation
func _on_area2d_input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not animating:
		animating = true
		animate()

# Get texture for next card from FSM using card_system's current_card_id
func get_next_card_texture() -> Texture:
	if !fsm or !card_system:
		push_error("[Base] Cannot get texture - required nodes not initialized")
		return initial_texture
		
	var card_data = fsm.cards.get(card_system.current_card_id)
	if not card_data:
		push_error("[Base] Card ID %d not found in FSM" % card_system.current_card_id)
		return initial_texture
		
	var image_path = card_data["image"]
	return load(image_path)

# Flip the base and introduce a new card
func animate() -> void:
	# Get next card's texture before starting animation
	var next_texture = get_next_card_texture()
	sfx_flip.play()
	
	# Grow the card
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", grow_scale, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished
	
	# Pause after grow animation
	await get_tree().create_timer(0.1).timeout
	
	# Shrink the card's X-axis to create a flip effect
	tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(0, original_scale.y), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	
	# Change to next card's texture during the "flip"
	card_sprite.texture = next_texture
	
	# Expand the card's X-axis back to original scale to complete the flip
	tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(original_scale.x, original_scale.y), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	
	# Restore the card's scale to original if needed
	tween = get_tree().create_tween()
	tween.tween_property(self, "scale", original_scale, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	
	# After animation completes, emit the signal Wwith the next texture
	emit_signal("new_card_needed", next_texture)
	
	# Reset base texture to initial card back
	card_sprite.texture = initial_texture
	
	# Mark the animation as finished
	animating = false
