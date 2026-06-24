extends CanvasLayer

@onready var health_bar: ProgressBar  = $MarginContainer/VBox/HealthBar
@onready var stamina_bar: ProgressBar = $MarginContainer/VBox/StaminaBar
@onready var health_label: Label      = $MarginContainer/VBox/HealthBar/Label
@onready var coin_label: Label        = $CoinCounter/Label
@onready var lock_on_marker: Control  = $LockOnMarker
@onready var interact_hint: Label     = $InteractHint
@onready var state_debug: Label       = $StateDebug   # remove in production

var _player: CharacterBody3D = null

func _ready() -> void:
	interact_hint.hide()
	lock_on_marker.hide()
	await get_tree().process_frame
	_connect_player()
	GameManager.coins_changed.connect(_on_coins_changed)

func _connect_player() -> void:
	_player = GameManager.player
	if not _player:
		return
	_player.health_changed.connect(_on_health_changed)
	_player.stamina_changed.connect(_on_stamina_changed)
	_player.state_changed.connect(_on_state_changed)
	_on_health_changed(_player.health, _player.stats.max_health)
	_on_stamina_changed(_player.stamina, _player.stats.max_stamina)

func _on_health_changed(current: float, maximum: float) -> void:
	health_bar.max_value = maximum
	health_bar.value     = current
	health_label.text    = "%d / %d" % [int(current), int(maximum)]

func _on_stamina_changed(current: float, maximum: float) -> void:
	stamina_bar.max_value = maximum
	stamina_bar.value     = current

func _on_coins_changed(amount: int) -> void:
	coin_label.text = "Coins: %d" % amount

func _on_state_changed(state) -> void:
	state_debug.text = "State: %s" % str(state)

func show_interact_hint(text: String = "Press E to interact") -> void:
	interact_hint.text = text
	interact_hint.show()

func hide_interact_hint() -> void:
	interact_hint.hide()

func show_lock_on(screen_pos: Vector2) -> void:
	lock_on_marker.position = screen_pos - lock_on_marker.size / 2.0
	lock_on_marker.show()

func hide_lock_on() -> void:
	lock_on_marker.hide()
