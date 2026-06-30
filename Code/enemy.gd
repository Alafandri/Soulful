extends CharacterBody2D

@onready var player_node: CharacterBody2D = get_tree().get_first_node_in_group("Player")

@onready var floor_ray_right: RayCast2D = $rightray
@onready var floor_ray_left: RayCast2D = $leftray
@onready var wall_ray_right: RayCast2D = $rightwallray
@onready var wall_ray_left: RayCast2D = $leftwallray

@export var speed: float = 100.0
@export var gravity: float = 980.0
@export_range(-1, 1) var dir: int = 1

var is_turning: bool = false
var health: int = 10
var is_frozen: bool = false

func _ready() -> void:
	if dir == 0:
		dir = 1
	_update_sprite_direction()

func _physics_process(delta: float) -> void:
	if is_frozen:
		move_and_slide()
		return

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 20.0

	if not is_turning:
		_check_for_turn()

	velocity.x = lerp(velocity.x, dir * speed, 10.0 * delta)
	move_and_slide()

func _check_for_turn() -> void:
	if not floor_ray_right or not floor_ray_left or not wall_ray_right or not wall_ray_left:
		return
		
	var should_turn_left = dir == 1 and (not floor_ray_right.is_colliding() or wall_ray_right.is_colliding())
	var should_turn_right = dir == -1 and (not floor_ray_left.is_colliding() or wall_ray_left.is_colliding())

	if should_turn_left:
		_change_direction(-1)
	elif should_turn_right:
		_change_direction(1)

func _change_direction(next_dir: int) -> void:
	is_turning = true
	dir = 0
	
	await get_tree().create_timer(0.2).timeout 
	
	dir = next_dir
	_update_sprite_direction()
	is_turning = false

func _update_sprite_direction() -> void:
	$Sprite2D.flip_h = (dir == -1)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.take_damage(1, global_position.x)

func take_damage(amount: int, knockback_dir: float = 0.0) -> void:
	health -= amount
	flash_white()
	
	if health <= 0:
		queue_free()
	else:
		if knockback_dir != 0.0:
			apply_knockback(knockback_dir)

func apply_knockback(knockback_dir: float) -> void:
	is_frozen = true
	velocity = Vector2(knockback_dir * 400.0, -200.0)
	
	await get_tree().create_timer(0.15).timeout
	
	velocity = Vector2.ZERO
	is_frozen = false

func flash_white() -> void:
	$Sprite2D.modulate = Color(10, 10, 10, 1)
	await get_tree().create_timer(0.1).timeout
	$Sprite2D.modulate = Color(1, 1, 1, 1)
