extends Node

@onready var game_manager = get_parent()
@onready var status_label = $StatusLabel  # New label for game status
@onready var resources_label = $ResourcesLabel  # New label for resources
@onready var card_label = $CardLabel  # New label for current card text and choices
@onready var game_over_label = $GameOverLabel  # New label for game over message
@onready var left_button = $LeftButton
@onready var right_button = $RightButton

const HEADER_SEPARATOR = "----------------------------------------"
const SECTION_SEPARATOR = "----------------"

# Helper function to format resources for display
func format_resources(resources: Dictionary) -> String:
	var result = ""
	for resource in resources:
		var value = resources[resource]
		result += "%s: %d\n" % [resource.capitalize(), value]
	return result.strip_edges()  # Remove trailing newline

func _on_resources_updated(new_resources: Dictionary):
	update_display(game_manager.currentCard)

func _on_card_completed(_outcome: Dictionary):
	update_display(game_manager.currentCard)

func _on_game_over(reason: String):
	var display_text = "[Game Over!]\n"
	display_text += HEADER_SEPARATOR + "\n"
	display_text += reason + "\n"
	display_text += HEADER_SEPARATOR + "\n\n"
	
	# Show final resource values
	display_text += "[Final Resources]\n"
	display_text += SECTION_SEPARATOR + "\n"
	for resource in game_manager.resources:
		display_text += "%s: %d\n" % [resource.capitalize(), game_manager.resources[resource]]
	
	game_over_label.text = display_text
	left_button.disabled = true
	right_button.disabled = true

func update_display(card: Dictionary):
	if card.is_empty():
		card_label.text = "No cards available"
		left_button.text = "-"
		right_button.text = "-"
		return
	
	# Update button texts with choices
	var left_choice = card.get("choices", {}).get("left", {})
	var right_choice = card.get("choices", {}).get("right", {})
	
	# Build resource strings
	var left_resources_text = format_resources(left_choice.get("resources", {}))
	var right_resources_text = format_resources(right_choice.get("resources", {}))
	
	# Set button text
	left_button.text = "%s\n%s" % [left_choice.get("text", "Left"), left_resources_text]
	right_button.text = "%s\n%s" % [right_choice.get("text", "Right"), right_resources_text]
	
	# Build the display text with clear sections
	var display_text = ""
	
	# Game Status Section
	display_text += "[Game Status]\n"
	display_text += SECTION_SEPARATOR + "\n"
	display_text += "Turn: %d\n" % game_manager.turn_count
	status_label = display_text
	
	# Resources Section
	display_text = "[Resources]\n"
	display_text += SECTION_SEPARATOR + "\n"
	for resource in game_manager.resources:
		display_text += "%s: %d\n" % [resource.capitalize(), game_manager.resources[resource]]
	resources_label.text = display_text	
	
	# Current Card Section
	display_text = "[Current Situation]\n"
	display_text += SECTION_SEPARATOR + "\n"
	display_text += "%s\n" % card.get("text", "")
	card_label.text = display_text

func _on_left_button_pressed():
	game_manager.process_choice("left")

func _on_right_button_pressed():
	game_manager.process_choice("right")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect signals from game manager
	game_manager.connect("resources_updated", _on_resources_updated)
	game_manager.connect("card_completed", _on_card_completed)
	game_manager.connect("game_over", _on_game_over)
	
	# Connect button signals
	left_button.pressed.connect(_on_left_button_pressed)
	right_button.pressed.connect(_on_right_button_pressed)
	
	# Initialize display with first card
	update_display(game_manager.currentCard)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
