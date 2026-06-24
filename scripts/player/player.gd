extends CharacterBody3D

# ── signals ──────────────────────────────────────────────────────────────────
signal health_changed(current: float, maximum: float)
signal stamina_changed(current: float, maximum: float)
signal state_changed(new_state: State)
signal died

# ── state machine ─────────────────────────────────────────────────────────────
enum State {
	IDLE,
	WALK,
	RUN,
	JUMP,
	FALL,
	CROUCH,
	ROLL,
	ATTACK_LIGHT,
	ATTACK_HEAVY,
	BLOCK,
	HURT,
	DEAD
}

# ── exports ───────────────────────────────────────────────────────────────────
@export var stats: PlayerStats

# ── node refs ────────────────────────────────────────────────────────────────
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var mesh: Node3D              = $Mesh
@onready var camera_arm: SpringArm3D   = $CameraArm
@onready var camera: Camera3D          = $CameraArm/Camera3D
@onready var attack_hitbox: Area3D     = $Mesh/AttackHitbox
@onready var interact_area: Area3D     = $InteractArea
@onready var coyote_timer: Timer       = $CoyoteTimer
@onready var roll_timer: Timer         = $RollTimer
@onready var attack_timer: Timer       = $AttackTimer
@onready var stamina_regen_timer: Timer = $StaminaRegenTimer

# ── runtime vars ─────────────────────────────────────────────────────────────
var current_state: State = State.IDLE
var health: float
var stamina: float

var _move_dir: Vector3 = Vector3.ZERO
var _vertical_vel: float = 0.0
var _cam_yaw: float = 0.0
var _cam_pitch: float = 0.0

var _is_rolling: bool = false
var _roll_dir: Vector3 = Vector3.ZERO
var _is_attacking: bool = false
var _is_blocking: bool = false
var _can_jump: bool = false   # coyote time

var _lock_on_target: Node3D = null
var _stamina_regen_paused: bool = false

const CAM_PITCH_MIN := -40.0
const CAM_PITCH_MAX :=  70.0

func _ready() -> void:
	if not stats:
		stats = PlayerStats.new()
	add_to_group("player")
	health  = stats.max_health
	stamina = stats.max_stamina
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	GameManager.register_player(self)

# ── input ─────────────────────────────────────────────────────────────────────
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not _lock_on_target:
		_cam_yaw   -= event.relative.x * 0.2
		_cam_pitch  = clamp(_cam_pitch - event.relative.y * 0.2, CAM_PITCH_MIN, CAM_PITCH_MAX)

	if event.is_action_pressed("lock_on"):
		_toggle_lock_on()

	if event.is_action_pressed("inventory"):
		# TODO: open inventory UI
		pass

	if event.is_action_pressed("interact"):
		_try_interact()

# ── per-frame ─────────────────────────────────────────────────────────────────
func _physics_process(delta: float) -> void:
	if current_state == State.DEAD:
		return

	_handle_stamina_regen(delta)
	_update_camera()
	_handle_state(delta)
	move_and_slide()

# ── camera ────────────────────────────────────────────────────────────────────
func _update_camera() -> void:
	if _lock_on_target:
		var dir = (_lock_on_target.global_position - global_position).normalized()
		_cam_yaw = rad_to_deg(atan2(-dir.x, -dir.z))
		_cam_pitch = rad_to_deg(asin(dir.y))

	camera_arm.rotation_degrees.y = _cam_yaw
	camera_arm.rotation_degrees.x = _cam_pitch

	# Joystick camera
	var jx = Input.get_action_strength("cam_right") - Input.get_action_strength("cam_left")
	var jy = Input.get_action_strength("cam_down")  - Input.get_action_strength("cam_up")
	if not _lock_on_target:
		_cam_yaw   -= jx * 120.0 * get_physics_process_delta_time()
		_cam_pitch  = clamp(_cam_pitch - jy * 80.0 * get_physics_process_delta_time(), CAM_PITCH_MIN, CAM_PITCH_MAX)

# ── state handler ─────────────────────────────────────────────────────────────
func _handle_state(delta: float) -> void:
	match current_state:
		State.IDLE, State.WALK, State.RUN, State.CROUCH:
			_handle_locomotion(delta)
		State.JUMP, State.FALL:
			_handle_airborne(delta)
		State.ROLL:
			_handle_roll(delta)
		State.ATTACK_LIGHT, State.ATTACK_HEAVY:
			_handle_attack_movement(delta)
		State.BLOCK:
			_handle_block(delta)
		State.HURT:
			_apply_gravity(delta)

func _handle_locomotion(delta: float) -> void:
	_apply_gravity(delta)
	_read_movement_input()

	var speed: float
	var is_crouching = Input.is_action_pressed("crouch")
	var is_running    = Input.is_action_pressed("run") and not is_crouching

	if is_crouching:
		speed = stats.crouch_speed
		_set_state(State.CROUCH)
	elif _move_dir != Vector3.ZERO:
		speed = stats.run_speed if is_running else stats.walk_speed
		_set_state(State.RUN if is_running else State.WALK)
	else:
		speed = 0.0
		_set_state(State.IDLE)

	velocity.x = _move_dir.x * speed
	velocity.z = _move_dir.z * speed

	if _move_dir != Vector3.ZERO:
		var face_dir = _move_dir if not _lock_on_target else (_lock_on_target.global_position - global_position).normalized()
		face_dir.y = 0
		if face_dir.length() > 0.01:
			mesh.rotation.y = lerp_angle(mesh.rotation.y, atan2(-face_dir.x, -face_dir.z), 0.2)

	if Input.is_action_just_pressed("jump") and (is_on_floor() or _can_jump):
		_jump()

	if Input.is_action_just_pressed("roll") and _move_dir != Vector3.ZERO:
		_start_roll()

	if Input.is_action_just_pressed("attack_light"):
		_start_attack(false)

	if Input.is_action_just_pressed("attack_heavy"):
		_start_attack(true)

	if Input.is_action_pressed("block"):
		_set_state(State.BLOCK)

func _handle_airborne(delta: float) -> void:
	_apply_gravity(delta)
	_read_movement_input()
	velocity.x = lerp(velocity.x, _move_dir.x * stats.walk_speed, 0.1)
	velocity.z = lerp(velocity.z, _move_dir.z * stats.walk_speed, 0.1)

	if is_on_floor():
		_set_state(State.IDLE)
	elif velocity.y < 0:
		_set_state(State.FALL)

func _handle_roll(delta: float) -> void:
	_apply_gravity(delta)
	velocity.x = _roll_dir.x * stats.roll_speed
	velocity.z = _roll_dir.z * stats.roll_speed

func _handle_attack_movement(delta: float) -> void:
	_apply_gravity(delta)
	velocity.x = lerp(velocity.x, 0.0, 0.3)
	velocity.z = lerp(velocity.z, 0.0, 0.3)
	if is_on_floor() and Input.is_action_just_pressed("roll"):
		_start_roll()

func _handle_block(delta: float) -> void:
	_apply_gravity(delta)
	var slow_dir = _move_dir * stats.walk_speed * 0.5
	velocity.x = slow_dir.x
	velocity.z = slow_dir.z
	_read_movement_input()
	if not Input.is_action_pressed("block"):
		_set_state(State.IDLE)

# ── actions ───────────────────────────────────────────────────────────────────
func _jump() -> void:
	_vertical_vel = stats.jump_force
	velocity.y    = _vertical_vel
	_can_jump     = false
	_set_state(State.JUMP)
	# animation_player.play("jump")

func _start_roll() -> void:
	if stamina < stats.roll_stamina_cost:
		return
	_spend_stamina(stats.roll_stamina_cost)
	_roll_dir = _move_dir if _move_dir != Vector3.ZERO else -mesh.global_transform.basis.z
	_set_state(State.ROLL)
	roll_timer.start(stats.roll_duration)
	# animation_player.play("roll")

func _start_attack(is_heavy: bool) -> void:
	var cost = stats.heavy_attack_stamina_cost if is_heavy else stats.light_attack_stamina_cost
	if stamina < cost:
		return
	_spend_stamina(cost)
	_is_attacking = true
	_set_state(State.ATTACK_HEAVY if is_heavy else State.ATTACK_LIGHT)
	attack_timer.start(0.6 if is_heavy else 0.4)
	_do_attack(is_heavy)
	# animation_player.play("attack_heavy" if is_heavy else "attack_light")

func _do_attack(is_heavy: bool) -> void:
	attack_hitbox.monitoring = true
	var damage = stats.heavy_attack_damage if is_heavy else stats.light_attack_damage
	for body in attack_hitbox.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(damage, global_position)

func _try_interact() -> void:
	for body in interact_area.get_overlapping_bodies():
		if body.has_method("interact"):
			body.interact(self)
			break

func _toggle_lock_on() -> void:
	if _lock_on_target:
		_lock_on_target = null
		return
	_lock_on_target = _find_nearest_enemy()

func _find_nearest_enemy() -> Node3D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var nearest: Node3D = null
	var nearest_dist := stats.lock_on_range
	for e in enemies:
		var d = global_position.distance_to(e.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = e
	return nearest

# ── health / damage ───────────────────────────────────────────────────────────
func take_damage(amount: float, from_position: Vector3 = Vector3.ZERO) -> void:
	if current_state == State.DEAD:
		return

	if _is_blocking:
		_spend_stamina(stats.block_stamina_cost)
		amount *= 0.2  # 80% reduction while blocking

	health = max(0.0, health - amount)
	health_changed.emit(health, stats.max_health)

	if health <= 0.0:
		_die()
	else:
		_set_state(State.HURT)
		# animation_player.play("hurt")

func _die() -> void:
	_set_state(State.DEAD)
	died.emit()
	GameManager.on_player_died()
	# animation_player.play("death")

func heal(amount: float) -> void:
	health = min(stats.max_health, health + amount)
	health_changed.emit(health, stats.max_health)

# ── stamina ───────────────────────────────────────────────────────────────────
func _spend_stamina(amount: float) -> void:
	stamina = max(0.0, stamina - amount)
	stamina_changed.emit(stamina, stats.max_stamina)
	_stamina_regen_paused = true
	stamina_regen_timer.start(stats.stamina_regen_delay)

func _handle_stamina_regen(delta: float) -> void:
	if _stamina_regen_paused or stamina >= stats.max_stamina:
		return
	stamina = min(stats.max_stamina, stamina + stats.stamina_regen_rate * delta)
	stamina_changed.emit(stamina, stats.max_stamina)

# ── helpers ───────────────────────────────────────────────────────────────────
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= stats.gravity * delta
	else:
		if velocity.y < 0:
			velocity.y = 0
		if current_state == State.JUMP or current_state == State.FALL:
			_set_state(State.IDLE)

func _read_movement_input() -> void:
	var raw_x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var raw_z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	var raw = Vector2(raw_x, raw_z)
	if raw.length() > 1.0:
		raw = raw.normalized()
	var cam_basis = camera_arm.global_transform.basis
	_move_dir = (cam_basis.x * raw.x + cam_basis.z * raw.y)
	_move_dir.y = 0
	if _move_dir.length() > 0.01:
		_move_dir = _move_dir.normalized()
	else:
		_move_dir = Vector3.ZERO

func _set_state(new_state: State) -> void:
	if current_state == new_state:
		return
	current_state = new_state
	state_changed.emit(new_state)

# ── timer callbacks ───────────────────────────────────────────────────────────
func _on_roll_timer_timeout() -> void:
	_is_rolling = false
	_set_state(State.IDLE)

func _on_attack_timer_timeout() -> void:
	_is_attacking = false
	attack_hitbox.monitoring = false
	_set_state(State.IDLE)

func _on_coyote_timer_timeout() -> void:
	_can_jump = false

func _on_stamina_regen_timer_timeout() -> void:
	_stamina_regen_paused = false

func _on_body_left_floor() -> void:
	if current_state not in [State.JUMP, State.ROLL]:
		coyote_timer.start(0.15)
		_can_jump = true
