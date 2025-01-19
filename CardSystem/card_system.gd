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
var final_card_spawned = false

func initialize(fsm_node) -> void:
	fsm = fsm_node
	if fsm:
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
	return load(image_path)

# Spawn a new card when the current one falls
func spawn_new_card(_texture: Texture) -> void:
	if not fsm:
		push_error("[CardSystem] Cannot spawn card - FSM not initialized")
		return
	
	# Get card data to verify it exists and is valid
	var card_data = fsm.cards.get(current_card_id)
	if not card_data:
		push_error("[CardSystem] Card ID %d not found in FSM" % current_card_id)
		return
	
	# Create new card instance
	var new_card = card_scene.instantiate()
	add_child(new_card)
	new_card.position = initial_mask_position 
	
	 # Set up card sprite
	var animated_sprite = new_card.get_node("AnimatedSprite2D")  # Path inside Card
	if animated_sprite:
		var sprite_frames = SpriteFrames.new()
		sprite_frames.add_animation("default")
		
		# Load the texture from the path
		var card_texture = load(card_data["image"])
		sprite_frames.add_frame("default", card_texture)
		animated_sprite.sprite_frames = sprite_frames
		animated_sprite.play("default")
		animated_sprite.stop()
		
	else:
		push_error("[CardSystem] Error: AnimatedSprite2D not found in new card")
		
	# Connect signals and notify systems
	new_card.connect("card_fell_off", Callable(self, "_on_card_fell_off"))
	emit_signal("card_spawned", new_card)
	
	# Create mask and associated elements
	create_mask_with_elements(new_card)

func create_mask_with_elements(card) -> void:
	# Spawn new mask with shadow whenever a new card is spawned
	mask_count += 1
	
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
	
	# Initialize with current card data
	choice_text.initialize(fsm) 
	choice_text.sync_with_scenario(current_card_id) 
	choice_text.connect("choice_made", _on_choice_made)
	
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
	if final_card_spawned:
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://Game/start.tscn")
	
	if not fsm:
		push_error("[CardSystem] Cannot handle choice - FSM not initialized")
		return

	var card_data = fsm.cards.get(current_card_id)
	if not card_data:
		push_error("[CardSystem] Current card ID %d not found in FSM" % current_card_id)
		return
		
	if card_data["type"] == "regular":
		var choice = "right" if is_right else "left"
		if card_data["choices"].has(choice):
			var next_card = card_data["choices"][choice]["next_card"]
			
			# Check if this is a transition to an ending
			if next_card == -1:
				next_card = determine_ending_card()
				print("[Card System] Final card spawned")
				final_card_spawned = true
			
			# Update current card before spawning new one
			current_card_id = next_card
		elif card_data["type"] == "win":
			print("[CardSystem] Reached win state")

func get_total_resources() -> float:
	var resource_container = get_tree().get_root().find_child("ResourceContainer", true, false)
	if not resource_container:
		return 0.0
	
	var total = 0.0
	for resource in resource_container.get_node("Grouped").get_children():
		total += resource.get_value()
	return total/4

func determine_ending_card() -> int:
	var total = get_total_resources()
	
	# Determine which ending based on total resources
	if total >= 75:  
		return 21
	elif total >= 50:  
		return 22
	else:  # Low resources
		return 23
