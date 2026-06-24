extends Area3D
class_name Collectible

enum Type { COIN, HEALTH_PICKUP, ITEM }

@export var type: Type = Type.COIN
@export var value: int = 1        # coins or heal amount
@export var item_id: String = ""  # for Type.ITEM
@export var item_data: Dictionary = {}

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if anim.has_animation("float"):
		anim.play("float")

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	match type:
		Type.COIN:
			GameManager.add_coins(value)
		Type.HEALTH_PICKUP:
			if body.has_method("heal"):
				body.heal(float(value))
		Type.ITEM:
			Inventory.add_item(item_data)
	_collect()

func _collect() -> void:
	# TODO: play pickup sound + particle burst
	queue_free()
