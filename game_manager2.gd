# GameManager.gd
# This script manages the game logic, including resources, cards, and game state.
#
# Signals:
# - resources_changed(resources: Dictionary) - Emitted when the resources are updated.
#		"stamina": int,
#		"supplies": int,
#		"morale": int,
#		"property": int
#
# -  card_drawn(new_card: Dictionary) - Emitted when a card is completed.

extends Node

signal state_changed(new_state: GameState)
signal card_drawn(new_card: Dictionary)

enum GameState { INITIAL, CRISIS, RECOVERY, WIN, LOSE }

var current_state: GameState = GameState.INITIAL

func transition_to_state(new_state: GameState) -> void:
	if current_state != new_state:
		current_state = new_state
		emit_signal("state_changed", new_state)
		print("Transitioned to state: ", current_state_to_string())

# Constants
const MIN_RESOURCE: int = 0
const MAX_RESOURCE: int = 100
const STARTING_RESOURCE: int = 50

var resources: Dictionary = {
	"stamina": STARTING_RESOURCE,
	"supplies": STARTING_RESOURCE,
	"morale": STARTING_RESOURCE,
	"property": STARTING_RESOURCE
}

# Game state
var cards: Dictionary
var used_cards_index: Dictionary = {
	initial_cards = [],
	crisis_cards = [],
	recovery_cards = []
}
var current_card: Dictionary
var turn_count: int = 0
var game_active: bool = true;

func update_resource(resource: String, amount: int) -> void:
	if resources.has(resource):
		var new_value = resources[resource] + amount;
		
		# Check for game over condition before clamping
		if new_value <= MIN_RESOURCE:
			resources[resource] = MIN_RESOURCE;
			transition_to_state(GameState.LOSE);
			game_active = false;
		else:
			resources[resource] = clamp(new_value, MIN_RESOURCE, MAX_RESOURCE);
	
func draw_card() -> void:
	var cards_type: Array
	var used_cards_type: Array
	
	match current_state:
		GameState.INITIAL:
			if cards["initial_cards"].size() == used_cards_index["initial_cards"].size():
				transition_to_state(GameState.CRISIS)
		GameState.CRISIS:
			if cards["crisis_cards"].size() == used_cards_index["crisis_cards"].size():
				transition_to_state(GameState.RECOVERY)
		GameState.RECOVERY:
			if cards["recovery_cards"].size() == used_cards_index["recovery_cards"].size():
				transition_to_state(GameState.WIN)
				game_active = false
				return
	
	match current_state:
		GameState.INITIAL:
			cards_type = cards["initial_cards"]
			used_cards_type = used_cards_index["initial_cards"]
		GameState.CRISIS:
			cards_type = cards["crisis_cards"]
			used_cards_type = used_cards_index["crisis_cards"]
		GameState.RECOVERY:
			cards_type = cards["recovery_cards"]
			used_cards_type = used_cards_index["recovery_cards"]
			
	var card_index: int
	while true:
		card_index = randi() % cards_type.size()
		if not used_cards_type.has(card_index): break;
		
	used_cards_type.append(card_index)
	current_card = cards_type[card_index]
	print(current_card)
	emit_signal("card_drawn", current_card)
	
func process_choice(choice: String) -> void:
	var outcome = current_card["choices"][choice]

	# Process resource changes
	for resource in outcome.get("resources", {}).keys():
		var amount = outcome["resources"][resource]
		update_resource(resource, amount)
		
	print("Outcome: ", outcome)
	print("Updated Resource: ", resources)
	
	turn_count += 1
	emit_signal("choice_completed")
	
	if game_active:
		draw_card()	

# Helper functions
func load_json_file(path: String) -> Dictionary:
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var json = JSON.parse_string(file.get_as_text())
		return json
	else: return {}

func current_state_to_string() -> String:
	for name in GameState.keys():
		if GameState[name] == current_state:
			return name
	return "Unknown"

func start_game() -> void:
	resources["stamina"] = STARTING_RESOURCE
	resources["supplies"] = STARTING_RESOURCE
	resources["morale"] = STARTING_RESOURCE
	resources["property"] = STARTING_RESOURCE
	cards = load_json_file("res://data/cards2.json")
	used_cards_index = { initial_cards = [], crisis_cards = [], recovery_cards = [] }
	current_card = {}
	
	turn_count = 0
	game_active = true
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_game()
	draw_card()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
