extends Camera2D

@export var follow_speed: float = 5.0
@export var camera_offset: Vector2 = Vector2(0, 0)

@onready var player: CharacterBody2D = get_parent()
@onready var dead_zone_collision: CollisionShape2D = $"../DeadZone/CollisionShape2D"

func _ready() -> void:
	top_level = true
	global_position = player.global_position + camera_offset

func _process(delta: float) -> void:
	var rect: RectangleShape2D = dead_zone_collision.shape as RectangleShape2D
	if not rect:
		return

	var center_of_deadzone = player.global_position + camera_offset
	var half_extents = rect.size / 2.0
	
	var left_bound = center_of_deadzone.x - half_extents.x
	var right_bound = center_of_deadzone.x + half_extents.x
	var top_bound = center_of_deadzone.y - half_extents.y
	var bottom_bound = center_of_deadzone.y + half_extents.y
	
	var target_position = global_position

	if global_position.x < left_bound:
		target_position.x = left_bound
	elif global_position.x > right_bound:
		target_position.x = right_bound

	if player.is_on_floor():
		target_position.y = player.global_position.y + camera_offset.y
	else:
		if global_position.y < top_bound:
			target_position.y = top_bound
		elif global_position.y > bottom_bound:
			target_position.y = bottom_bound

	global_position = global_position.lerp(target_position, follow_speed * delta)
