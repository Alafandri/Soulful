extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -800.0
const JUMP_BUFFER_TIME = 0.1
const FALL_GRAVITY := 2500.0

var jump_buffer_timer = 0.0
var health: int = 6
var is_invincible: bool = false

@onready var sprite = $Sprite2D

func get_custom_gravity(current_velocity: Vector2) -> float:
	if current_velocity.y < 0:
		return get_gravity().y
	return FALL_GRAVITY

func _ready() -> void:
	add_to_group("Player")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Slash/Area2D.body_entered.connect(_on_slash_hit)
	$Slash/Area2D/CollisionShape2D.disabled = true

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("Left", "Right")

	if direction != 0:
		sprite.flip_h = direction < 0

	$Slash.flip_h = sprite.flip_h

	if sprite.flip_h:
		$Slash.position.x = -abs($Slash.position.x)
	else:
		$Slash.position.x = abs($Slash.position.x)

	if Input.is_action_just_pressed("slash") and not $Slash.visible:
		$Slash.visible = true
		$Slash.frame = 0
		$Slash.play("slash")
		$Slash/Area2D/CollisionShape2D.disabled = false

		await get_tree().create_timer(0.35).timeout

		$Slash.stop()
		$Slash.visible = false
		$Slash/Area2D/CollisionShape2D.disabled = true

	if not is_on_floor():
		velocity.y += get_custom_gravity(velocity) * delta

	if Input.is_action_just_released("Jump") and velocity.y < 0:
		velocity.y = JUMP_VELOCITY / 4

	if Input.is_action_just_pressed("Jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		jump_buffer_timer -= delta

	if is_on_floor() and jump_buffer_timer > 0:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0.0

	if not is_invincible:
		if direction != 0:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	handle_animations(direction)
	move_and_slide()

func handle_animations(direction: float) -> void:
	if is_on_floor():
		if direction != 0:
			sprite.play("Move")
		else:
			sprite.play("Idle")

func _on_slash_hit(body: Node2D) -> void:
	if body != self and body.has_method("take_damage"):
		var knockback_dir = -1.0 if sprite.flip_h else 1.0
		body.take_damage(1, knockback_dir)

func take_damage(amount: int, enemy_x: float = 0.0) -> void:
	if is_invincible:
		return

	health -= amount
	is_invincible = true

	velocity.y = -250

	if global_position.x < enemy_x:
		velocity.x = -400
	else:
		velocity.x = 400

	hit_freeze(0.02)
	flash_white()

	if health <= 0:
		Engine.time_scale = 1.0
		await get_tree().process_frame
		get_tree().reload_current_scene()
		return

	await get_tree().create_timer(0.2).timeout
	velocity.x = 0

	await get_tree().create_timer(0.3).timeout
	is_invincible = false

func flash_white() -> void:
	sprite.modulate = Color(10, 10, 10, 1)
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(0.502, 0.502, 0.502)

func hit_freeze(duration: float) -> void:
	Engine.time_scale = 0.05
	await get_tree().create_timer(duration).timeout
	Engine.time_scale = 1.0
