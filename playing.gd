extends Node

# Reference to the Base, Card, and Mask scenes
@onready var base_node = $Base
@onready var card_scene = preload("res://card.tscn")
@onready var mask_scene = preload("res://mask.tscn")
@onready var shadow_scene = preload("res://shadow.tscn")
@onready var initial_mask_position = Vector2(960, 540)
@onready var choice_text_scene = preload("res://choice_text.tscn")

# Variable to track the animated sprite
var animated_sprite = null
var mask_count = 0  # Add counter for debugging

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
	var new_card = card_scene.instantiate()
	add_child(new_card)
	# Position the new card where the old one was
	new_card.position = initial_mask_position  # Use the same position as mask
	
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
		animated_sprite.stop()  # Pause the animation at the initial frame
	else:
		print("Error: AnimatedSprite2D or texture node not found in the new card.")
		
	# Connect the card's signal to Base's animate() function
	new_card.connect("card_fell_off", Callable(self, "_on_card_fell_off"))
	
	# Spawn new mask with shadow whenever a new card is spawned
	mask_count += 1
	print("[DEBUG] Spawning new mask with card (Count: ", mask_count, ")")
	
	var new_mask = mask_scene.instantiate()
	add_child(new_mask)
	new_mask.position = initial_mask_position
	new_mask.scale = Vector2(0.25, 0.25)
	new_mask.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
	new_mask.light_mask = 0
	
	# Add shadow to mask
	var shadow = shadow_scene.instantiate()
	new_mask.add_child(shadow)
	shadow.position = Vector2(-3840, -2160)
	shadow.scale = Vector2(4, 4)
	
	# Add choice text
	var choice_text = choice_text_scene.instantiate()
	shadow.add_child(choice_text)
	choice_text.name = "ChoiceText"
	choice_text.position = Vector2(960, 540)
	choice_text.scale = Vector2(0.25, 0.25)
	
	print("[DEBUG] Mask and shadow created successfully")
	
func _on_card_fell_off() -> void:
	base_node.animate()  # Programmatically trigger the base animation
	
# Spawn the first card and connect it to the chain
func spawn_first_card() -> void:
	spawn_new_card(null)  # The texture can be `null` or an initial texture, if needed.

# Detect mouse movement to continue the animation
func _input(event: InputEvent) -> void:
	# Check if the event is a mouse motion
	if event is InputEventMouseMotion:
		# Resume the animation if the AnimatedSprite2D exists
		if animated_sprite and not animated_sprite.is_playing():
			animated_sprite.play()
