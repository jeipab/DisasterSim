extends Area2D

# Signal to notify when a new card should be introduced
signal new_card_needed

var grow_speed := 5.0 # Speed of the grow/shrink animation
var original_scale := Vector2(1, 1) # Original scale
var grow_scale := Vector2(1.2, 1.2) # Scale during growth
var animating := false # Prevents repeated clicks during animation
var current_scenario := 0 # Tracks the current scenario index
var scenario_images := [] # Array to store scenario textures
var first_texture: Texture  # Store the first texture

@onready var card_sprite := $CardSprite # Sprite2D node for the card

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	# Initialize the random number generator
	randomize()
	
	# Set initial scale
	original_scale = self.scale
	self.connect("input_event", Callable(self, "_on_area2d_input_event"))
	
	# Load scenario textures from the Art folder
	scenario_images = load_scenario_textures()
	if scenario_images.size() > 0:
		first_texture = scenario_images[0]  # Store the first texture
		card_sprite.texture = first_texture  # Start with the first texture

# When the base is clicked, start the animation
func _on_area2d_input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not animating:
		animating = true
		animate()

# Flip the base and introduce a new card
func animate() -> void:
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
	
	# Change texture during the "flip"
	var random_texture = update_card_texture()
	
	# Expand the card's X-axis back to original scale to complete the flip
	tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(original_scale.x, original_scale.y), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	
	# Restore the card's scale to original if needed
	tween = get_tree().create_tween()
	tween.tween_property(self, "scale", original_scale, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	
	# After animation completes, emit the signal with the random texture
	emit_signal("new_card_needed", random_texture)
	
	# Reset base texture to first texture
	card_sprite.texture = first_texture
	
	# Mark the animation as finished
	animating = false

# Load the scenario textures
func load_scenario_textures() -> Array:
	# Load images from the Art folder
	return [
		preload("res://Art/test-squares-01.png"),
		preload("res://Art/test-squares-02.png"),
		preload("res://Art/test-squares-03.png"),
		preload("res://Art/test-squares-04.png")
	]

# Change the card texture after each flip
func update_card_texture() -> Texture:
	# Ensure there are textures loaded
	if scenario_images.size() > 1: # Only randomize if there are multiple textures
		var random_index = randi() % scenario_images.size()
		
		# Ensure the new texture is not the current texture
		while scenario_images[random_index] == card_sprite.texture:
			random_index = randi() % scenario_images.size()
		
		# Update the card's texture
		card_sprite.texture = scenario_images[random_index]
		return scenario_images[random_index]
	
	return card_sprite.texture
