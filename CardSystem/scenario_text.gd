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

# Initialize with FSM reference
func initialize(fsm_node) -> void:
	fsm = fsm_node
	if fsm:
		print("[ScenarioText] Initialized with FSM")
		print("[ScenarioText] Available cards: ", fsm.cards.keys())
		set_new_scenario()  # Set initial text
	else:
		push_error("[ScenarioText] Failed to initialize - no FSM provided")

func _ready() -> void:
	# Find the FSM node if not already initialized
	if not fsm:
		fsm = get_tree().get_root().find_child("Fsm", true, false)
		if fsm:
			print("[ScenarioText] Found FSM node")
			set_new_scenario()
		else:
			push_error("[ScenarioText] FSM node not found!")
			return
	
	# Connect to the card system's signals
	var card_system = get_tree().get_root().find_child("CardSystem", true, false)
	if card_system:
		card_system.connect("card_spawned", _on_card_spawned)
		print("[ScenarioText] Connected to CardSystem")
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
			else:
				is_typing = false

func set_new_scenario() -> void:
	if not fsm:
		push_error("[ScenarioText] FSM not found when setting new scenario")
		return
	
	# Get current card data
	print("[ScenarioText] Attempting to get card data for ID:", current_card_id)
	var card_data = fsm.cards.get(current_card_id)
	if not card_data:
		push_error("[ScenarioText] Card ID %d not found in FSM" % current_card_id)
		return
	
	print("[ScenarioText] Setting text for card %d: %s" % [current_card_id, card_data["text"]])
	
	# Set text based on card text
	var new_text = card_data["text"]
	
	# Set up typing animation for new text
	current_text = new_text
	target_text = new_text
	display_text = ""
	char_index = 0
	is_typing = true
	type_timer = 0.0

func _on_card_spawned(card) -> void:
	print("[ScenarioText] New card spawned, connecting signals")
	if !card.is_connected("card_chosen", _on_card_chosen):
		card.connect("card_chosen", _on_card_chosen)
		print("[ScenarioText] Connected to new card's chosen signal")

func _on_card_chosen(is_right: bool) -> void:
	print("[ScenarioText] Card choice made:", "right" if is_right else "left")
	
	if not fsm:
		push_error("[ScenarioText] FSM not found when handling choice")
		return
	
	var card_data = fsm.cards.get(current_card_id)
	if not card_data:
		push_error("[ScenarioText] Current card ID %d not found in FSM" % current_card_id)
		return
	
	# Get the next card ID based on choice
	var choice = "right" if is_right else "left"
	if card_data["type"] == "regular" and card_data["choices"].has(choice):
		var next_card = card_data["choices"][choice]["next_card"]
		print("[ScenarioText] Moving from card %d to card %d" % [current_card_id, next_card])
		current_card_id = next_card
	elif card_data["type"] in ["win", "lose"]:
		print("[ScenarioText] Game Over - ", "Victory!" if card_data["type"] == "win" else "Defeat!")
		return
	
	set_new_scenario()
