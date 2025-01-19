extends Node

# Signals
signal card_changed(resources: Dictionary)

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
var current_card: Dictionary
var turn_count: int = 0
var game_active: bool = false

# FSM reference
@onready var fsm: Node = $FSM

func reset_resources() -> void:
	resources["stamina"] = STARTING_RESOURCE
	resources["supplies"] = STARTING_RESOURCE
	resources["morale"] = STARTING_RESOURCE
	resources["property"] = STARTING_RESOURCE
	turn_count = 0
	game_active = true
	current_card = fsm.cards.get(fsm.start_state)
	emit_signal("card_changed", current_card)
	
func update_resource(resource: String, amount: int) -> void:
	if resources.has(resource):
		var new_value = resources[resource] + amount;
		
		# Check for game over condition before clamping
		if new_value <= MIN_RESOURCE:
			resources[resource] = MIN_RESOURCE;
			print("game_over", "Resource %s reached critical level" % resource)
			game_active = false;
		else:
			resources[resource] = clamp(new_value, MIN_RESOURCE, MAX_RESOURCE);	

func process_choice(choice_str: String) -> void:		
	# Early exit if the game is not active
	if not game_active:
		push_warning("Game is inactive. No further choices can be processed.")
		return
		
	if current_card["phase"] == "concluding":
		print("end Game");
		game_active = false;
		return
		
	if not current_card.has("choices") or not current_card["choices"].has(choice_str):
		return
		
	var fsm_choice
	if (choice_str == "left"):
		fsm_choice = fsm.Choice.LEFT
	elif (choice_str == "right"):
		fsm_choice = fsm.Choice.RIGHT
	else:
		push_error("Invalid Choice: ", choice_str)
		return
	
	var outcome = current_card["choices"][choice_str]
	
	# Transition to the next card
	if outcome.has("next_card"):
		var next_card_id = outcome["next_card"]
		if fsm.cards.has(next_card_id):
			current_card = fsm.cards[next_card_id]
			print("Transitioned to card: ", current_card)
		else:
			push_error("Invalid next card ID: ", next_card_id)
	else:
		push_error("Choice missing 'next_card' field: ", choice_str)	
	
	# Process resource changes
	for resource in outcome.get("resources", {}).keys():
		var amount = outcome["resources"][resource]
		update_resource(resource, amount)
		
	print("Outcome: ", outcome)
	print("Updated Resources: ", resources)
	
	turn_count += 1
	
	emit_signal("card_changed", current_card)
	
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset_resources()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
