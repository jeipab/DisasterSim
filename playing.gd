extends Node

# Reference to the Base, Card, and Mask scenes
@onready var base_node = $Base
@onready var card_scene = preload("res://card.tscn")
@onready var mask_node = $Mask

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	# Connect the signal emitted by the base to the method that will spawn a new card
	base_node.connect("new_card_needed", Callable(self, "_on_new_card_needed"))
	
	# Spawn the first card
	spawn_first_card()

# This method will be called when the signal is emitted
func _on_new_card_needed(texture: Texture) -> void:
	spawn_new_card(texture)

# Spawn a new card when the current one falls
func spawn_new_card(texture: Texture) -> void:
	print("Texture being passed: ", texture)
	var new_card = card_scene.instantiate()
	add_child(new_card)
	# Position the new card where the old one was
	new_card.position = Vector2(960, 540)  # Adjust this position as necessary
	
	# Get the AnimatedSprite2D node (adjust path as needed)
	var animated_sprite = new_card.get_node("AnimatedSprite2D")  # Path inside Card

	# Check if the AnimatedSprite2D exists
	if animated_sprite:
		# Get the current frames (SpriteFrames resource)
		var sprite_frames = SpriteFrames.new()
		
		if texture:
			# Add the texture as the first frame in the "default" animation
			sprite_frames.add_animation("default")
			sprite_frames.add_frame("default", texture)
	
		# Assign the new SpriteFrames to the AnimatedSprite2D
		animated_sprite.sprite_frames = sprite_frames

		# Play the "default" animation
		animated_sprite.play("default")
	else:
		print("Error: AnimatedSprite2D or texture node not found in the new card.")
		
	# Connect the card's signal to Base's animate() function
	new_card.connect("card_fell_off", Callable(self, "_on_card_fell_off"))

	# Ensure Mask is always at the top layer
	mask_node.z_index = 999  # Set a high value to ensure it stays on top of other elements
	
func _on_card_fell_off() -> void:
	base_node.animate()  # Programmatically trigger the base animation
	
# Spawn the first card and connect it to the chain
func spawn_first_card() -> void:
	spawn_new_card(null)  # The texture can be `null` or an initial texture, if needed.
