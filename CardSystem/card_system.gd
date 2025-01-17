extends Node

signal card_spawned(card)  # Add this at the top with other signals

# Reference to the Base, Card, and Mask scenes
@onready var base_node = $Base
@onready var card_scene = preload("res://CardSystem/card.tscn")
@onready var mask_scene = preload("res://CardSystem/mask.tscn")
@onready var shadow_scene = preload("res://CardSystem/shadow.tscn")
@onready var initial_mask_position = Vector2(960, 540)
@onready var choice_text_scene = preload("res://CardSystem/choice_text.tscn")

# Variable to track the animated sprite
var animated_sprite = null
var mask_count = 0  # Add counter for debugging
var current_card_id: int = 1  # Track current card ID
var fsm = null  # FSM reference

func initialize(fsm_node) -> void:
	fsm = fsm_node
	if fsm:
		print("[CardSystem] Initialized with FSM")
		current_card_id = fsm.start_state
	else:
		push_error("[CardSystem] Failed to initialize - no FSM provided")

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	# Connect the signal emitted by the base to the method that will spawn a new card
	base_node.connect("new_card_needed", Callable(self, "_on_new_card_needed"))
	
	# If FSM wasn't provided via initialize, try to find it
	if not fsm:
		fsm = get_tree().get_root().find_child("Fsm", true, false)
		if fsm:
			print("[CardSystem] Found FSM node")
			current_card_id = fsm.start_state
		else:
			push_error("[CardSystem] FSM node not found!")
		
	# Spawn the first card
	spawn_first_card()

# This method will be called when the signal is emitted
func _on_new_card_needed(texture: Texture) -> void:
	spawn_new_card(texture)
	
# Get texture from FSM card data
func get_card_texture(card_id: int) -> Texture:
	if not fsm:
		push_error("[CardSystem] Cannot get texture - FSM not initialized")
		return null
		
	var card_data = fsm.cards.get(card_id)
	if not card_data:
		push_error("[CardSystem] Card ID %d not found in FSM" % card_id)
		return null
		
	var image_path = card_data["image"]
	print("[CardSystem] Loading texture from path:", image_path)
	return load(image_path)

# Spawn a new card when the current one falls
func spawn_new_card(texture: Texture) -> void:
	if not fsm:
		push_error("[CardSystem] Cannot spawn card - FSM not initialized")
		return
	
	# Get texture from current card data
	var card_texture = get_card_texture(current_card_id)
	if not card_texture:
		push_error("[CardSystem] Failed to load texture for card %d" % current_card_id)
		return
	
	var new_card = card_scene.instantiate()
	add_child(new_card)
	# Position the new card where the old one was
	new_card.position = initial_mask_position  # Use the same position as mask
	
	# Get the AnimatedSprite2D node (adjust path as needed)
	var animated_sprite = new_card.get_node("AnimatedSprite2D")  # Path inside Card

	# Check if the AnimatedSprite2D exists
	if animated_sprite:
		var sprite_frames = SpriteFrames.new()
		sprite_frames.add_animation("default")
		sprite_frames.add_frame("default", card_texture)
		animated_sprite.sprite_frames = sprite_frames
		animated_sprite.play("default")
		animated_sprite.stop()
		print("[CardSystem] Set card texture for card ID:", current_card_id)
	else:
		push_error("[CardSystem] Error: AnimatedSprite2D not found in new card")
		
	# Connect the card's signal to Base's animate() function
	new_card.connect("card_fell_off", Callable(self, "_on_card_fell_off"))
	
	# Emit signal that new card was spawned
	emit_signal("card_spawned", new_card)
	
	# Spawn new mask with shadow whenever a new card is spawned
	mask_count += 1
	print("[CardSystem] Spawning new mask with card (Count: ", mask_count, ")")
	
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
	choice_text.initialize(fsm)  # Initialize with FSM
	choice_text.sync_with_scenario(current_card_id)  # Sync with current card
	choice_text.connect("choice_made", _on_choice_made)  # Connect choice signal
	
	print("[CardSystem] Mask and shadow created successfully with card ID:", current_card_id)
	
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
			
# Handle choices and update current card ID
func _on_choice_made(is_right: bool) -> void:
	if not fsm:
		push_error("[CardSystem] Cannot handle choice - FSM not initialized")
		return
		
	print("[CardSystem] Choice made:", "right" if is_right else "left")
	var card_data = fsm.cards.get(current_card_id)
	if card_data and card_data["type"] == "regular":
		var choice = "right" if is_right else "left"
		if card_data["choices"].has(choice):
			current_card_id = card_data["choices"][choice]["next_card"]
			print("[CardSystem] Moving to card ID:", current_card_id)
