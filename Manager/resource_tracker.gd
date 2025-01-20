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
		var old_value = resource_values[resource]
		resource_values[resource] = maxf(0.0, resource_values[resource] + amount)
		print("%s: %0.1f -> %0.1f (Δ%0.1f)" % [resource, old_value, resource_values[resource], amount])
		check_resources()

func check_resources() -> int:
	for resource in priority_order:
		if resource_values[resource] <= 0:
			print("Resource depleted: %s" % resource)
			emit_signal("resource_depleted", loss_cards[resource])
			break
	return -1

func get_resource_value(resource_type: String) -> float:
	return resource_values.get(resource_type.to_lower(), 0.0)
