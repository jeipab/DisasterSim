extends Node

enum Choice { LEFT, RIGHT }

var inputs: Array[Choice] = [Choice.LEFT, Choice.RIGHT]
var states: Array[int]
var start_state: int = 1
var final_states: Array[int]

var cards: Dictionary = {
	# Initial Phase (Preparation)
	1:
	{
		"id": "1",
		"image": "res://Art/directed_square-05.png",
		"phase": "initial",
		"type": "regular",
		"name": "Typhoon incoming",
		"text": "You are home and hear the news: a typhoon is approaching your area.",
		"choices":
		{
			"left":
			{
				"text": "Gather supplies like food, water, and other essentials.",
				"next_card": 2,
				"resources": {"supplies": 15, "stamina": -5}
			},
			"right":
			{
				"text": "Check on neighbors to see if they need help.",
				"next_card": 3,
				"resources": {"morale": 10, "supplies": -10, "stamina": -5}
			}
		}
	},
	2:
	{
		"id": "2",
		"image": "res://Art/test-squares-01.png",
		"phase": "initial",
		"type": "regular",
		"name": "Gather supplies",
		"text":
		"You gathered your supplies but realized that you need to secure and protect your home.",
		"choices":
		{
			"left":
			{
				"text": "Secure your home with available resources.",
				"next_card": 5,
				"resources": {"property": 15, "stamina": -10, "supplies": -5}
			},
			"right":
			{
				"text": "Ignore securing your home and pack your supplies.",
				"next_card": 4,
				"resources": {"supplies": 10, "property": -5}
			}
		}
	},
	3:
	{
		"id": "3",
		"image": "res://Art/test-squares-02.png",
		"phase": "initial",
		"type": "regular",
		"name": "Help neighbor",
		"text":
		"You helped your neighbor and they are grateful for your help. Now, the typhoon is getting closer.",
		"choices":
		{
			"left":
			{
				"text": "Return home and gather your supplies.",
				"next_card": 2,
				"resources": {"supplies": 10, "stamina": -5}
			},
			"right":
			{
				"text": "Ask your neighbor to stay in each of your own houses.",
				"next_card": 6,
				"resources": {"morale": 10, "property": -5}
			}
		}
	},
	4:
	{
		"id": "4",
		"image": "res://Art/test-squares-03.png",
		"phase": "initial",
		"type": "regular",
		"name": "Secure home",
		"text":
		"Your home is now secured, but you need to decide if you will stay at your home or prepare to evacuate.",
		"choices":
		{
			"left":
			{
				"text": "Stay at home and ride out the typhoon.",
				"next_card": 7,
				"resources": {"property": 10, "supplies": -5}
			},
			"right":
			{
				"text": "Prepare to evacuate with your packed supplies.",
				"next_card": 8,
				"resources": {"supplies": 10, "stamina": -5}
			}
		}
	},
	5:
	{
		"id": "5",
		"image": "res://Art/test-squares-04.png",
		"phase": "initial",
		"type": "regular",
		"name": "Pack supplies",
		"text":
		"Your supplies are now packed in a bag, but you didn’t secure your home. The typhoon is almost here.",
		"choices":
		{
			"left":
			{
				"text": "Stay at home and ride out the typhoon.",
				"next_card": 7,
				"resources": {"property": 10, "supplies": -5}
			},
			"right":
			{
				"text": "Evacuate to a safer location with your packed supplies.",
				"next_card": 8,
				"resources": {"stamina": -5, "supplies": 5}
			}
		}
	},
	6:
	{
		"id": "6",
		"image": "res://Art/test-squares-01.png",
		"phase": "initial",
		"type": "regular",
		"name": "Stay at home",
		"text":
		"You all agreed to stay at home, but you realized that you need to secure and protect your houses.",
		"choices":
		{
			"left":
			{
				"text": "Stay at home and secure each of your own houses.",
				"next_card": 7,
				"resources": {"morale": 10, "stamina": -10, "property": 10}
			},
			"right":
			{
				"text": "Convince the group to evacuate to an evacuation area.",
				"next_card": 8,
				"resources": {"supplies": 10, "morale": -10}
			}
		}
	},
	# Crisis Phase (During Typhoon)
	7:
	{
		"id": "7a",
		"image": "res://Art/test-squares-02.png",
		"phase": "crisis",
		"type": "regular",
		"name": "Flood rising",
		"text": "You stayed at home, but there’s a flood rising...",
		"choices":
		{
			"left":
			{
				"text": "Call for help and wait from the higher ground of your house.",
				"next_card": 9,
				"resources": {"stamina": -5, "supplies": -10, "morale": 10}
			},
			"right":
			{
				"text": "Evacuate quickly despite the risks.",
				"next_card": 10,
				"resources": {"stamina": -10, "supplies": 5, "property": -5}
			}
		}
	},
	8:
	{
		"id": "8a",
		"image": "res://Art/test-squares-03.png",
		"phase": "crisis",
		"type": "regular",
		"name": "Evacuation center with sufficient supplies",
		"text": "You’ve reached an organized evacuation center with sufficient resources.",
		"choices":
		{
			"left":
			{
				"text": "Follow instructions and participate in activities.",
				"next_card": 11,
				"resources": {"morale": 10, "stamina": 5}
			},
			"right":
			{
				"text": "Focus on personal needs and preparedness.",
				"next_card": 12,
				"resources": {"supplies": 10, "morale": -5}
			}
		}
	},
	# Crisis Phase (Continued)
	9:
	{
		"id": "9",
		"image": "res://Art/test-squares-04.png",
		"phase": "crisis",
		"type": "regular",
		"name": "Flood rising and supplies running out",
		"text":
		"You’re at home and there is still floodwater but it has become stagnant, and going on your own can be risky.",
		"choices":
		{
			"left":
			{
				"text": "Attempt to signal rescuers for help.",
				"next_card": 8,
				"resources": {"stamina": -10, "morale": 10}
			},
			"right":
			{
				"text": "Stay home with remaining supplies since the typhoon has calmed down.",
				"next_card": 14,
				"resources": {"stamina": -15, "supplies": 15}
			}
		}
	},
	10:
	{
		"id": "10a",
		"image": "res://Art/test-squares-01.png",
		"phase": "crisis",
		"type": "regular",
		"name": "Evacuating but forgot supplies",
		"text": "You’re on your way to evacuate but forgot key supplies in your rush.",
		"choices":
		{
			"left":
			{
				"text": "Return briefly to retrieve the forgotten items.",
				"next_card": 9,
				"resources": {"stamina": -10, "supplies": 10}
			},
			"right":
			{
				"text": "Accept the loss and focus on finding safety.",
				"next_card": 8,
				"resources": {"stamina": 5, "supplies": -10}
			}
		}
	},
	11:
	{
		"id": "11",
		"image": "res://Art/test-squares-02.png",
		"phase": "crisis",
		"type": "regular",
		"name": "Participate in activities in the evacuation center",
		"text": "You participate in activities at the evacuation center and follow instructions.",
		"choices":
		{
			"left":
			{
				"text": "Continue cooperating for a positive environment.",
				"next_card": 13,
				"resources": {"morale": 10, "stamina": 5}
			},
			"right":
			{
				"text": "Focus on yourself and minimize interactions.",
				"next_card": 13,
				"resources": {"supplies": 5, "morale": -5}
			}
		}
	},
	12:
	{
		"id": "12",
		"image": "res://Art/test-squares-03.png",
		"phase": "crisis",
		"type": "regular",
		"name": "Focus on your own needs",
		"text": "You decide to focus on your own needs and preparations.",
		"choices":
		{
			"left":
			{
				"text": "Conserve your supplies for future needs.",
				"next_card": 13,
				"resources": {"supplies": 10, "morale": -5}
			},
			"right":
			{
				"text": "Share your extra supplies.",
				"next_card": 13,
				"resources": {"supplies": -5, "stamina": 10}
			}
		}
	},
	# Recovery Phase
	13:
	{
		"id": "13",
		"image": "res://Art/test-squares-04.png",
		"phase": "recovery",
		"type": "regular",
		"name": "At the evacuation center, the typhoon has passed",
		"text":
		"The typhoon has passed, and you feel the need to return home to assess the damage and begin repairs.",
		"choices":
		{
			"left":
			{
				"text": "Return to your house and start repairing your property.",
				"next_card": 15,
				"resources": {"stamina": -10, "property": 10}
			},
			"right":
			{
				"text": "Stay at the evacuation center and wait for further aid.",
				"next_card": 16,
				"resources": {"stamina": 10, "morale": -5}
			}
		}
	},
	14:
	{
		"id": "14",
		"image": "res://Art/test-squares-01.png",
		"phase": "recovery",
		"type": "regular",
		"name": "At home with no electricity",
		"text":
		"Days after the typhoon, you realize that the lack of electricity and clean water is affecting your well-being. You need to decide your next steps.",
		"choices":
		{
			"left":
			{
				"text": "Attempt to go to an evacuation center with better resources.",
				"next_card": 17,
				"resources": {"stamina": -10, "morale": 5}
			},
			"right":
			{
				"text": "Stay at home and ration your remaining supplies.",
				"next_card": 18,
				"resources": {"supplies": -15, "stamina": -5}
			}
		}
	},
	15:
	{
		"id": "15",
		"image": "res://Art/test-squares-02.png",
		"phase": "recovery",
		"type": "regular",
		"name": "Unstable structures in your home",
		"text":
		"As you approach your home, you find it partially damaged. Unstable walls and debris pose a risk of injury.",
		"choices":
		{
			"left":
			{
				"text": "Proceed cautiously and clear debris to stabilize your home.",
				"next_card": 19,
				"resources": {"stamina": -10, "property": 10}
			},
			"right":
			{
				"text": "Wait for help to assess the safety of your home before entering.",
				"next_card": 19,
				"resources": {"stamina": 5, "property": -5}
			}
		}
	},
	16:
	{
		"id": "16",
		"image": "res://Art/test-squares-03.png",
		"phase": "recovery",
		"type": "regular",
		"name": "Incoming supplies in the evacuation center",
		"text":
		"While staying at the evacuation center, you hear rumors of incoming aid and relief supplies.",
		"choices":
		{
			"left":
			{
				"text":
				"Volunteer to assist in distributing aid, gaining morale and a sense of purpose.",
				"next_card": 20,
				"resources": {"stamina": -5, "morale": 10}
			},
			"right":
			{
				"text": "Conserve energy and focus on resting while waiting for aid.",
				"next_card": 20,
				"resources": {"stamina": 10, "supplies": -5}
			}
		}
	},
	17:
	{
		"id": "17",
		"image": "res://Art/test-squares-04.png",
		"phase": "recovery",
		"type": "regular",
		"name": "Bacteria exposure",
		"text":
		"On your way to the evacuation center, you pass through stagnant floodwaters. You start feeling unwell, likely due to exposure to disease-causing bacteria.",
		"choices":
		{
			"left":
			{
				"text": "Push through to the evacuation center and seek medical aid upon arrival.",
				"next_card": 16,
				"resources": {"stamina": -15, "supplies": 10, "morale": -10}
			},
			"right":
			{
				"text": "Avoid the floodwaters and take a longer, safer route to the center.",
				"next_card": 16,
				"resources": {"stamina": -15, "supplies": -5}
			}
		}
	},
	18:
	{
		"id": "18",
		"image": "res://Art/test-squares-01.png",
		"phase": "recovery",
		"type": "regular",
		"name": "Staying at home and rationing supplies",
		"text":
		"You decide to stay home and ration your supplies. Days pass, but the conditions remain difficult.",
		"choices":
		{
			"left":
			{
				"text": "Attempt to repair minor damages to make your home more livable.",
				"next_card": 19,
				"resources": {"stamina": -10, "property": 10}
			},
			"right":
			{
				"text": "Signal for help and hope for rescue.",
				"next_card": 20,
				"resources": {"morale": -10, "stamina": 5}
			}
		}
	},
	19:
	{
		"id": "19",
		"image": "res://Art/test-squares-02.png",
		"phase": "recovery",
		"type": "regular",
		"name": "Stabilizing your home",
		"text": "With limited resources, you work on stabilizing your home as best as you can.",
		"choices":
		{
			"left":
			{
				"text": "Focus on repairing essential areas first.",
				"next_card": -1,
				"resources": {"stamina": -10, "property": 10}
			},
			"right":
			{
				"text": "Conserve energy and plan for long-term repairs.",
				"next_card": -1,
				"resources": {"stamina": 5, "property": 5}
			}
		}
	},
	20:
	{
		"id": "20",
		"image": "res://Art/test-squares-03.png",
		"phase": "recovery",
		"type": "regular",
		"name": "Recovering at the evacuation center",
		"text":
		"You’ve settled into the evacuation center, but you need to decide how to spend your time.",
		"choices":
		{
			"left":
			{
				"text": "Volunteer to help organize supplies and assist others.",
				"next_card": -1,
				"resources": {"stamina": -5, "morale": 10}
			},
			"right":
			{
				"text": "Focus on regaining your strength and conserving your resources.",
				"next_card": -1,
				"resources": {"stamina": 10, "morale": -5}
			}
		}
	},
	# Concluding Phase
	21:
	{
		"id": "21",
		"image": "res://Art/directed_square-05.png",
		"phase": "concluding",
		"type": "win",
		"name": "Triumph Against All Odds",
		"text":
		"You emerge from the disaster stronger than ever. Your meticulous planning and balanced decisions have left you with plentiful supplies, high morale, and abundant stamina. The community looks to you as a leader and a symbol of resilience.",
		"choices":
		{
			"left": {"text": "The storm is over, and now I’m stronger for it."},
			"right": {"text": "I’ve survived, but the journey continues."}
		}
	},
	22:
	{
		"id": "22",
		"image": "res://Art/test-squares-02.png",
		"phase": "concluding",
		"type": "win",
		"name": "Steady and Resilient",
		"text":
		"Though the journey was tough, you managed to keep your supplies and morale in good standing while conserving stamina. Others admire your resourcefulness and determination, and you are ready to face the challenges of rebuilding.",
		"choices":
		{
			"left": {"text": "The storm is over, and now I’m stronger for it."},
			"right": {"text": "I’ve survived, but the journey continues."}
		}
	},
	23:
	{
		"id": "23",
		"image": "res://Art/test-squares-03.png",
		"phase": "concluding",
		"type": "win",
		"name": "Survived, but Scarred",
		"text":
		"You made it through the storm, but just barely. Your resources were stretched thin, morale was tested, and stamina was drained. Yet, despite the hardships, you survived. The experience has left you wiser, though the scars will remain.",
		"choices":
		{
			"left": {"text": "The storm is over, and now I’m stronger for it."},
			"right": {"text": "I’ve survived, but the journey continues."}
		}
	},
	24:
	{
		"id": "24",
		"image": "res://Art/test-squares-04.png",
		"phase": "concluding",
		"type": "lose",
		"name": "Exhaustion and Collapse",
		"text":
		"After a series of poor decisions, you ran out of stamina while navigating floodwaters. Without the energy to press on, you were swept away by the current, unable to make it to safety. The storm claimed more than just your home; it took your life as well.",
		"choices":
		{
			"left": {"text": "The storm took more than I could handle."},
			"right": {"text": "I couldn’t make it this time…"}
		}
	},
	25:
	{
		"id": "25",
		"image": "res://Art/test-squares-02.png",
		"phase": "concluding",
		"type": "lose",
		"name": "Despair and Isolation",
		"text":
		"Morale dwindled due to repeated failures, betrayals, and losses. You lost the will to continue and decided to stay in a damaged shelter, hoping for aid that never arrived. With dwindling supplies and no rescue in sight, your story ends in isolation, a tragic reminder of the psychological toll of disasters.",
		"choices":
		{
			"left": {"text": "The storm took more than I could handle."},
			"right": {"text": "I couldn’t make it this time…"}
		}
	},
	26:
	{
		"id": "26",
		"image": "res://Art/test-squares-03.png",
		"phase": "concluding",
		"type": "lose",
		"name": "Property Over People",
		"text":
		"You focused all your efforts on saving your property, neglecting your personal well-being and the opportunity to evacuate. A subsequent flood destroyed both your property and your chance of survival. The storm claimed everything you held dear.",
		"choices":
		{
			"left": {"text": "The storm took more than I could handle."},
			"right": {"text": "I couldn’t make it this time…"}
		}
	},
	27:
	{
		"id": "27",
		"image": "res://Art/test-squares-01.png",
		"phase": "concluding",
		"type": "lose",
		"name": "Starvation and Dehydration",
		"text":
		"Running out of essential supplies such as food and water left you too weak to continue. The lack of resources made survival impossible, and you succumbed to the harsh conditions of the post-typhoon environment.",
		"choices":
		{
			"left": {"text": "The storm took more than I could handle."},
			"right": {"text": "I couldn’t make it this time…"}
		}
	}
}

const card_7_variations: Array[Dictionary] = [
	{
		"id": "7a",
		"image": "res://Art/test-squares-01.png",
		"phase": "crisis",
		"type": "regular",
		"name": "Flood rising",
		"text": "You stayed at home, but there’s a flood rising...",
		"choices":
		{
			"left":
			{
				"text": "Call for help and wait from the higher ground of your house.",
				"next_card": 9,
				"resources": {"stamina": -5, "supplies": -10, "morale": 10}
			},
			"right":
			{
				"text": "Evacuate quickly despite the risks.",
				"next_card": 10,
				"resources": {"stamina": -10, "supplies": 5, "property": -5}
			}
		}
	},
	{
		"id": "7b",
		"image": "res://Art/test-squares-01.png",
		"phase": "crisis",
		"type": "regular",
		"name": "Power cut off",
		"text": "You stayed at home, but the power has been cut off.",
		"choices":
		{
			"left":
			{
				"text": "Stay at home while trying to use your limited resources efficiently.",
				"next_card": 9,
				"resources": {"supplies": -10, "morale": 5}
			},
			"right":
			{
				"text": "Evacuate quickly despite the risks.",
				"next_card": 10,
				"resources": {"stamina": -5, "supplies": 10}
			}
		}
	}
]

const card_8_variations: Array[Dictionary] = [
	{
		"id": "8a",
		"image": "res://Art/test-squares-01.png",
		"phase": "crisis",
		"type": "regular",
		"name": "Evacuation center with sufficient supplies",
		"text": "You’ve reached an organized evacuation center with sufficient resources.",
		"choices":
		{
			"left":
			{
				"text": "Follow instructions and participate in activities.",
				"next_card": 11,
				"resources": {"morale": 10, "stamina": 5}
			},
			"right":
			{
				"text": "Focus on personal needs and preparedness.",
				"next_card": 12,
				"resources": {"supplies": 10, "morale": -5}
			}
		}
	},
	{
		"id": "8b",
		"image": "res://Art/test-squares-01.png",
		"phase": "crisis",
		"type": "regular",
		"name": "Evacuation center with limited supplies",
		"text": "You’ve reached an evacuation center, but resources are limited.",
		"choices":
		{
			"left":
			{
				"text": "Focus on personal needs and preparedness.",
				"next_card": 12,
				"resources": {"supplies": 10, "morale": -10}
			},
			"right":
			{
				"text": "Help and share your supplies with others.",
				"next_card": 13,
				"resources": {"supplies": -10, "morale": 10}
			}
		}
	},
]

const card_10_variations: Array[Dictionary] = [
	{
		"id": "10a",
		"image": "res://Art/test-squares-01.png",
		"phase": "crisis",
		"type": "regular",
		"name": "Evacuating but forgot supplies",
		"text": "You’re on your way to evacuate but forgot key supplies in your rush.",
		"choices":
		{
			"left":
			{
				"text": "Return briefly to retrieve the forgotten items.",
				"next_card": 9,
				"resources": {"stamina": -10, "supplies": 10}
			},
			"right":
			{
				"text": "Accept the loss and focus on finding safety.",
				"next_card": 8,
				"resources": {"stamina": 5, "supplies": -10}
			}
		}
	},
	{
		"id": "10b",
		"image": "res://Art/test-squares-01.png",
		"phase": "crisis",
		"type": "regular",
		"name": "Evacuating but a fallen tree is blocking the way",
		"text": "You’re on your way to evacuate, but a fallen tree is blocking the way.",
		"choices":
		{
			"left":
			{
				"text": "Come back to your house.",
				"next_card": 9,
				"resources": {"stamina": -10, "supplies": 10}
			},
			"right":
			{
				"text": "Use strength to climb over the fallen tree.",
				"next_card": 8,
				"resources": {"stamina": 5, "supplies": -10}
			}
		}
	},
]


func randomize_card(card_number: int, card_variations: Array[Dictionary]) -> void:
	var random_card = card_variations[randi() % card_variations.size()]
	cards[card_number] = random_card


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()

	randomize_card(7, card_7_variations)
	randomize_card(8, card_8_variations)
	randomize_card(10, card_10_variations)

	# Populate the states and the final states
	for id in cards.keys():
		var card = cards[id]
		states.append(card)
		if card["phase"] == "concluding":
			final_states.append(id)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
