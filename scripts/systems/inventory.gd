extends Node

# Singleton - autoload as "Inventory"

signal item_added(item)
signal item_removed(item)
signal item_used(item)

const MAX_SLOTS := 20

var items: Array[Dictionary] = []

# item format: { id, name, icon, quantity, type, data }
# types: "consumable", "weapon", "key_item"

func add_item(item: Dictionary) -> bool:
	if items.size() >= MAX_SLOTS:
		return false
	var existing = _find_item(item.id)
	if existing and item.get("stackable", false):
		existing.quantity += item.get("quantity", 1)
	else:
		items.append(item.duplicate())
	item_added.emit(item)
	return true

func remove_item(item_id: String, quantity: int = 1) -> bool:
	var item = _find_item(item_id)
	if not item:
		return false
	item.quantity -= quantity
	if item.quantity <= 0:
		items.erase(item)
	item_removed.emit(item)
	return true

func use_item(item_id: String) -> void:
	var item = _find_item(item_id)
	if not item:
		return
	item_used.emit(item)
	# TODO: apply item effect based on item.type and item.data
	if item.get("consumable", false):
		remove_item(item_id)

func has_item(item_id: String) -> bool:
	return _find_item(item_id) != null

func _find_item(item_id: String) -> Dictionary:
	for item in items:
		if item.id == item_id:
			return item
	return {}
