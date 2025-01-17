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

func _ready() -> void:
	# Find the FSM node
	fsm = get_tree().get_root().find_child("FSM", true, false)
	if not fsm:
		push_error("FSM node not found!")
		return
		
	# Connect to the card system's signals
	var card_system = get_tree().get_root().find_child("CardSystem", true, false)
	if card_system:
		card_system.connect("card_spawned", _on_card_spawned)
		print("[ScenarioText] Connected to CardSystem")
	else:
		print("[ScenarioText] Failed to find CardSystem")
	
	# Set initial scenario
	set_new_scenario()

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
		push_error("FSM not found when setting new scenario")
		return
		
	# Get current card data
	var card_data = fsm.cards.get(current_card_id)
	if not card_data:
		push_error("Card ID %d not found in FSM" % current_card_id)
		return
	
	# Set text based on card title
	var new_text = card_data["title"]
	
	# Set up typing animation for new text
	current_text = new_text
	target_text = new_text
	display_text = ""
	char_index = 0
	is_typing = true
	type_timer = 0.0

func _on_card_spawned(card) -> void:
	if !card.is_connected("card_chosen", _on_card_chosen):
		card.connect("card_chosen", _on_card_chosen)
		print("[ScenarioText] Connected to new card")

func _on_card_chosen(is_right: bool) -> void:
	if not fsm:
		push_error("FSM not found when handling choice")
		return
		
	var card_data = fsm.cards.get(current_card_id)
	if not card_data:
		push_error("Current card ID %d not found in FSM" % current_card_id)
		return
	
	# Get the next card ID based on choice
	var choice = "right" if is_right else "left"
	if card_data["type"] == "regular" and card_data["choices"].has(choice):
		current_card_id = card_data["choices"][choice]["next_card"]
	elif card_data["type"] in ["win", "lose"]:
		# Handle end states - you might want to trigger a game over screen here
		print("Game Over - ", "Victory!" if card_data["type"] == "win" else "Defeat!")
		return
		
	print("[ScenarioText] Moving to card ", current_card_id)
	set_new_scenario()
