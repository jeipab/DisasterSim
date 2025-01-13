extends Node2D

# Array of sample scenarios for testing
var scenarios = [
	"A Category 4 typhoon is approaching the coast. Evacuation orders need to be issued within 12 hours.",
	"The typhoon has damaged our emergency communications tower. A temporary fix might last a week.",
	"Flooding has cut off access to the hospital district. We have rescue boats, but limited fuel.",
	"Our typhoon shelters are at 120% capacity. The nearby school could be converted for temporary use.",
	"Power lines are down in residential areas. Repair teams warn of electrocution risks from flood waters.",
	"Food supplies are running low at evacuation centers. Military rations are available but expensive.",
	"Three fishing villages are refusing evacuation orders. They want to protect their boats.",
	"The weather station predicts a second typhoon forming. Current shelters won't withstand another hit.",
	"Floodwaters are approaching a chemical plant. Emergency containment will require most of our workforce.",
	"Foreign aid is arriving at the airport, but roads are flooded. Helicopter fuel is limited."
]

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
	# Pick a random scenario
	var new_text = scenarios[randi() % scenarios.size()]
	while new_text == current_text:  # Avoid repeating the same scenario
		new_text = scenarios[randi() % scenarios.size()]
	
	# Set up typing animation
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

func _on_card_chosen(_is_right: bool) -> void:
	print("[ScenarioText] Card chosen, setting new scenario")
	set_new_scenario()
