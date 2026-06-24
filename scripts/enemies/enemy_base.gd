extends CharacterBody3D
class_name EnemyBase

# ── signals ───────────────────────────────────────────────────────────────────
signal died(enemy)
signal health_changed(current: float, maximum: float)

# ── state ─────────────────────────────────────────────────────────────────────
enum State { IDLE, PATROL, CHASE, ATTACK, HURT, DEAD }

# ── exports ───────────────────────────────────────────────────────────────────
@export var max_health: float = 60.0
@export var move_speed: float = 2.5
@export var chase_speed: float = 4.5
@export var attack_damage: float = 15.0
@export var attack_range: float = 1.5
@export var detection_range: float = 10.0
@export var attack_cooldown: float = 1.5
@export var patrol_points: Array[NodePath] = []
@export var drops_coins: int = 5   # coins dropped on death

# ── runtime ───────────────────────────────────────────────────────────────────
var current_state: State = State.IDLE
var health: float
var _player: CharacterBody3D = null
var _attack_ready: bool = true
var _patrol_index: int = 0
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var attack_timer: Timer          = $AttackCooldownTimer
@onready var anim: AnimationPlayer        = $AnimationPlayer
@onready var detection_area: Area3D       = $DetectionArea
@onready var health_bar_3d: Node3D        = $HealthBar3D   # world-space billboard

func _ready() -> void:
	health = max_health
	add_to_group("enemies")
	# detection_area signals are connected in enemy_base.tscn

func _physics_process(delta: float) -> void:
	if current_state == State.DEAD:
		return

	_apply_gravity(delta)
	_update_state()
	_execute_state(delta)
	move_and_slide()

func _update_state() -> void:
	if not _player:
		if current_state != State.PATROL:
			_set_state(State.PATROL if patrol_points.size() > 0 else State.IDLE)
		return

	var dist = global_position.distance_to(_player.global_position)
	match current_state:
		State.IDLE, State.PATROL:
			if dist < detection_range:
				_set_state(State.CHASE)
		State.CHASE:
			if dist <= attack_range and _attack_ready:
				_set_state(State.ATTACK)
			elif dist > detection_range * 1.5:
				_player = null
				_set_state(State.PATROL if patrol_points.size() > 0 else State.IDLE)

func _execute_state(_delta: float) -> void:
	match current_state:
		State.IDLE:
			velocity.x = 0
			velocity.z = 0
		State.PATROL:
			_do_patrol()
		State.CHASE:
			_move_toward(_player.global_position, chase_speed)
		State.ATTACK:
			_do_attack()
		State.HURT:
			velocity.x = lerp(velocity.x, 0.0, 0.3)
			velocity.z = lerp(velocity.z, 0.0, 0.3)

func _do_patrol() -> void:
	if patrol_points.is_empty():
		return
	var target = get_node(patrol_points[_patrol_index]).global_position
	if global_position.distance_to(target) < 0.5:
		_patrol_index = (_patrol_index + 1) % patrol_points.size()
	_move_toward(target, move_speed)

func _move_toward(target: Vector3, speed: float) -> void:
	nav_agent.target_position = target
	var next = nav_agent.get_next_path_position()
	var dir = (next - global_position).normalized()
	dir.y = 0
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed
	if dir.length() > 0.01:
		rotation.y = lerp_angle(rotation.y, atan2(-dir.x, -dir.z), 0.15)

func _do_attack() -> void:
	if not _attack_ready:
		return
	_attack_ready = false
	attack_timer.start(attack_cooldown)
	# anim.play("attack")
	if _player and global_position.distance_to(_player.global_position) <= attack_range + 0.3:
		_player.take_damage(attack_damage, global_position)
	_set_state(State.CHASE)

# ── damage ────────────────────────────────────────────────────────────────────
func take_damage(amount: float, from_position: Vector3 = Vector3.ZERO) -> void:
	if current_state == State.DEAD:
		return
	health = max(0.0, health - amount)
	health_changed.emit(health, max_health)
	_update_health_bar()

	if health <= 0.0:
		_die()
	else:
		_set_state(State.HURT)
		# anim.play("hurt")
		# brief knockback
		var kb_dir = (global_position - from_position).normalized()
		velocity += kb_dir * 3.0

func _die() -> void:
	_set_state(State.DEAD)
	died.emit(self)
	GameManager.add_coins(drops_coins)
	# anim.play("death")
	await get_tree().create_timer(2.0).timeout
	queue_free()

func _update_health_bar() -> void:
	if health_bar_3d and health_bar_3d.has_method("set_value"):
		health_bar_3d.set_value(health / max_health)

# ── helpers ───────────────────────────────────────────────────────────────────
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta
	else:
		if velocity.y < 0:
			velocity.y = 0

func _set_state(new_state: State) -> void:
	if current_state == new_state:
		return
	current_state = new_state

# ── signals ───────────────────────────────────────────────────────────────────
func _on_body_entered_detection(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player = body

func _on_body_exited_detection(body: Node3D) -> void:
	if body == _player:
		_player = null

func _on_attack_cooldown_timer_timeout() -> void:
	_attack_ready = true
