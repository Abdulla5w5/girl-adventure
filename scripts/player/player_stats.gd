extends Resource
class_name PlayerStats

@export var max_health: float = 100.0
@export var max_stamina: float = 100.0
@export var stamina_regen_rate: float = 20.0   # per second
@export var stamina_regen_delay: float = 1.5   # seconds after last use

@export var walk_speed: float = 3.5
@export var run_speed: float = 6.5
@export var crouch_speed: float = 2.0
@export var jump_force: float = 5.5
@export var gravity: float = 9.8

@export var roll_speed: float = 8.0
@export var roll_duration: float = 0.5
@export var roll_stamina_cost: float = 20.0

@export var light_attack_damage: float = 25.0
@export var heavy_attack_damage: float = 50.0
@export var light_attack_stamina_cost: float = 10.0
@export var heavy_attack_stamina_cost: float = 25.0
@export var block_stamina_cost: float = 15.0   # per hit blocked

@export var attack_reach: float = 1.8
@export var lock_on_range: float = 15.0
