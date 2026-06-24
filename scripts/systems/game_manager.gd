extends Node

# Singleton - autoload as "GameManager"

signal player_died
signal enemy_died(enemy)
signal item_collected(item_data)
signal coins_changed(amount)
signal game_paused(is_paused)

var coins: int = 0
var is_paused: bool = false
var player: CharacterBody3D = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func register_player(p: CharacterBody3D) -> void:
	player = p

func add_coins(amount: int) -> void:
	coins += amount
	coins_changed.emit(coins)

func on_player_died() -> void:
	player_died.emit()
	# TODO: trigger death screen / respawn logic

func toggle_pause() -> void:
	is_paused = !is_paused
	get_tree().paused = is_paused
	game_paused.emit(is_paused)
