extends Node

# Signals
signal resources_updated(resources: Dictionary)
signal card_completed(outcome: Dictionary)
signal game_over(reason: String)

# Constants
const MIN_RESOURCE: int = 0
const MAX_RESOURCE: int = 100
const STARTING_RESOURCE: int = 50

# Resource configuration
var resources: Dictionary = {
	"stamina": STARTING_RESOURCE,
	"supplies": STARTING_RESOURCE,
	"morale": STARTING_RESOURCE,
	"property": STARTING_RESOURCE
}

# Game state
var currentCard: Dictionary
var card_history: Array = []
var used_cards_index: Array = []
var turn_count: int = 0
var game_active: bool = false;

# Content Management
var card_pool: Array = []

func load_content() -> void:
	var card_data = load_json_file("res://data/cards.json")
	
	# Initialize card pools from loaded data
	card_pool = card_data.get("regular_cards", [])
	emit_signal("resources_updated", resources)
	
func reset_resources() -> void:
	resources["stamina"] = STARTING_RESOURCE
	resources["supplies"] = STARTING_RESOURCE
	resources["morale"] = STARTING_RESOURCE
	resources["property"] = STARTING_RESOURCE
	emit_signal("resources_updated", resources)
	
func update_resource(resource: String, amount: int) -> void:
	if resources.has(resource):
		resources[resource] = clamp(resources[resource] + amount, MIN_RESOURCE, MAX_RESOURCE)
	
	# Check for game over conditions
	if resources[resource] <= MIN_RESOURCE:
		emit_signal("game_over", "Resource %s reached critical level" % resource)
		game_active = false
		
func draw_next_card() -> void:
	if card_pool.size() == used_cards_index.size():
		emit_signal("game_over", "No more cards available")
		game_active = false
		return
		
	# Randomly select a card from the pool	
	var card_index: int
	while true:
		card_index = randi() % card_pool.size()
		if not used_cards_index.has(card_index):
			break;
	
	used_cards_index.append(card_index)		
	currentCard = card_pool[card_index]
	print(currentCard)

func process_choice(choice: String) -> void:
	var outcome = currentCard["choices"][choice]
	
	# Process resource changes
	for resource in outcome.get("resources", {}).keys():
		update_resource(resource, outcome["resources"][resource])
	
	# Add to history
	card_history.append({
		"card": currentCard,
		"choice": choice,
		"outcome": outcome,
		"turn": turn_count
	})
	
	print("Outcome: ", outcome)
	print("Updated Resource: ", resources)
	
	turn_count += 1
	if game_active:
		draw_next_card()
		
	emit_signal("card_completed", outcome)
	
func load_json_file(path: String) -> Dictionary:
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var json = JSON.parse_string(file.get_as_text())
		return json if json is Dictionary else {}
	return {}
	
func start_game() -> void:
	reset_resources()
	turn_count = 0
	game_active = true
	draw_next_card()
	emit_signal("resources_updated", resources)		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Game Initialized!")
	load_content()
	start_game()
	# pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
