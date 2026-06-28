extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -800.0

const JUMP_BUFFER_TIME = 0.1
var jump_buffer_timer = 0.0

@onready var sprite = $Sprite2D

const FALL_GRAVITY := 2500.0

func get_custom_gravity(current_velocity: Vector2) -> float:
	if current_velocity.y < 0:
		return get_gravity().y
	return FALL_GRAVITY

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

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
		
		await get_tree().create_timer(0.5).timeout
		$Slash.stop()
		$Slash.visible = false
	
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
