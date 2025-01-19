extends Node

@onready var game_manager = get_parent()
@onready var status_label = $StatusLabel  
@onready var resources_label = $ResourcesLabel  
@onready var card_label = $CardLabel  
@onready var game_over_label = $GameOverLabel  
@onready var phase_label = $PhaseLabel
@onready var left_button = $LeftButton
@onready var right_button = $RightButton

const HEADER_SEPARATOR = "----------------------------------------"
const SECTION_SEPARATOR = "----------------"

# Helper functions
func format_resources(resources: Dictionary) -> String:
	var result = ""
	for resource in resources:
		var value = resources[resource]
		result += "%s: %d\n" % [resource.capitalize(), value]
	return result.strip_edges()  # Remove trailing newline

func update_all_UI(card: Dictionary) -> void:
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
	left_button.text = "%s\n%s\n%s" % [left_choice.get("text", "Left"), left_resources_text, left_choice.get("next_card")] 
	right_button.text = "%s\n%s\n%s" % [right_choice.get("text", "Right"), right_resources_text, right_choice.get("next_card")]
	
	# Build the display text with clear sections
	
	# Game Status Section
	var status_text = ""
	status_text += "[Game Status]\n"
	status_text += SECTION_SEPARATOR + "\n"
	status_text += "Turn: %d\n" % game_manager.turn_count
	status_label = status_text
	
	# Resources Section
	var resources_text = ""
	resources_text = "[Resources]\n"
	resources_text += SECTION_SEPARATOR + "\n"
	for resource in game_manager.resources:
		resources_text += "%s: %d\n" % [resource.capitalize(), game_manager.resources[resource]]
	resources_label.text = resources_text	
	
	# Current Card Section
	var card_text =  ""
	card_text = "[Current Situation]\n"
	card_text += SECTION_SEPARATOR + "\n"
	card_text += "%s\n" % card.get("title", "")
	card_label.text = card_text
	
	# Phase Section
	var phase_text = ""
	phase_text = "[Current Phase]: "
	phase_text += game_manager.current_card.phase
	phase_label.text = phase_text
	
	if !game_manager.game_active:
		var game_over_text = "[Game Over!]\n"
		game_over_text += HEADER_SEPARATOR + "\n"
		game_over_text += HEADER_SEPARATOR + "\n\n"
	
		# Show final resource values
		game_over_text += "[Final Resources]\n"
		game_over_text += SECTION_SEPARATOR + "\n"
		for resource in game_manager.resources:
			game_over_text += "%s: %d\n" % [resource.capitalize(), game_manager.resources[resource]]
		
		game_over_label.text = game_over_text
		left_button.disabled = true
		right_button.disabled = true	
	
	
func _on_card_changed(new_card) -> void:
	update_all_UI(new_card)

func _on_left_button_pressed():
	game_manager.process_choice("left")

func _on_right_button_pressed():
	game_manager.process_choice("right")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_manager.connect("card_changed", _on_card_changed)
	left_button.pressed.connect(_on_left_button_pressed)
	right_button.pressed.connect(_on_right_button_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
