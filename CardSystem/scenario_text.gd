extends Node2D

# Track current card and FSM state
var current_card_id: int = 1  # Start with first card
var fsm  # Reference to FSM node

# Typing animation properties
var current_text := ""
var target_text := ""
var display_text := ""
var char_index := 0
var type_speed := 0.03  # Seconds between each character
var type_timer := 0.0
var is_typing := false

@onready var text_label := $TextLabel
@onready var audio_player = $AudioStreamPlayer
@onready var speech_sfx = preload("res://Sounds/text_speech_2.mp3")

# Initialize with FSM reference
func initialize(fsm_node) -> void:
	fsm = fsm_node
	if fsm:
		set_new_scenario()  # Set initial text
	else:
		push_error("[ScenarioText] Failed to initialize - no FSM provided")

func _ready() -> void:
	# Find the FSM node if not already initialized
	if not fsm:
		fsm = get_tree().get_root().find_child("Fsm", true, false)
		if fsm:
			set_new_scenario()
		else:
			push_error("[ScenarioText] FSM node not found!")
			return
	
	# Connect to the card system's signals
	var card_system = get_tree().get_root().find_child("CardSystem", true, false)
	if card_system:
		card_system.connect("card_spawned", _on_card_spawned)
	else:
		push_error("[ScenarioText] Failed to find CardSystem")

func _process(delta: float) -> void:
	if is_typing:
		type_timer += delta
		if type_timer >= type_speed:
			type_timer = 0.0
			if char_index < target_text.length():
				char_index += 1
				display_text = target_text.substr(0, char_index)
				text_label.text = display_text
				
				# Play sound for each character
				play_typing_sound(display_text[char_index - 1])
			else:
				is_typing = false

func play_typing_sound(character: String) -> void:
	# Duplicate audio player and apply sound
	var new_audio_player = audio_player.duplicate()
	new_audio_player.stream = speech_sfx
	new_audio_player.pitch_scale += randf_range(-0.5, 0.5)  # Slight variation in pitch  
	
	# Apply extra pitch change if the character is a vowel
	if character in ["a", "e", "i", "o", "u"]:
		new_audio_player.pitch_scale += 1.0
		
	# Play the sound and clean up after it's done
	get_tree().root.add_child(new_audio_player)
	new_audio_player.play()
	await new_audio_player.finished
	new_audio_player.queue_free()	

func set_new_scenario() -> void:
	if not fsm:
		push_error("[ScenarioText] FSM not found when setting new scenario")
		return
	
	# Get current card data
	var card_data = fsm.cards.get(current_card_id)
	if not card_data:
		push_error("[ScenarioText] Card ID %d not found in FSM" % current_card_id)
		return
	
	# Set up typing animation for new text
	current_text = card_data["text"]
	target_text = card_data["text"]
	display_text = ""
	char_index = 0
	is_typing = true
	type_timer = 0.0

func _on_card_spawned(card) -> void:
	if !card.is_connected("card_chosen", _on_card_chosen):
		card.connect("card_chosen", _on_card_chosen)

func _on_card_chosen(is_right: bool) -> void:
	if not fsm:
		push_error("[ScenarioText] FSM not found when handling choice")
		return
	
	var card_data = fsm.cards.get(current_card_id)
	if not card_data:
		push_error("[ScenarioText] Current card ID %d not found in FSM" % current_card_id)
		return
	
	# Get the latest card ID from card system
	var card_system = get_tree().get_root().find_child("CardSystem", true, false)
	if card_system:
		current_card_id = card_system.current_card_id  # This will now include any loss card override
		set_new_scenario()
	elif card_data["type"] == "regular":
		var choice = "right" if is_right else "left"
		if card_data["choices"].has(choice):
			var next_card = card_data["choices"][choice]["next_card"]
			if next_card == -1:
				card_system = get_tree().get_root().find_child("CardSystem", true, false)
				if card_system:
					next_card = card_system.determine_ending_card()
			current_card_id = next_card
			set_new_scenario()
