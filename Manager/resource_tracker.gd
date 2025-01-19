extends Node

signal resource_depleted(loss_card: int)

var resource_values = {
	"stamina": 50.0,
	"morale": 50.0,
	"property": 50.0,
	"supplies": 50.0
}

var loss_cards = {
	"stamina": 24,
	"morale": 25,
	"property": 26,
	"supplies": 27
}

# Priority order for checking resources
var priority_order = ["stamina", "morale", "property", "supplies"]

func modify_resource(resource_type: String, amount: float) -> void:
	if resource_values.has(resource_type.to_lower()):
		var resource = resource_type.to_lower()
		resource_values[resource] = maxf(0.0, resource_values[resource] + amount)
		check_resources()

func check_resources() -> int:
	for resource in priority_order:
		if resource_values[resource] <= 0:
			emit_signal("resource_depleted", loss_cards[resource])
			break  # Stop checking after first depleted resource
	return -1  # No loss condition

func get_resource_value(resource_type: String) -> float:
	return resource_values.get(resource_type.to_lower(), 0.0)
