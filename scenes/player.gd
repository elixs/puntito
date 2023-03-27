class_name Player
extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -300.0
const GRAVITY = 500
const ACCELERATION = 4000


func init(id):
	set_multiplayer_authority(id)
	name = str(id)


func _physics_process(delta) -> void:
	if is_multiplayer_authority():
		if not is_on_floor():
			velocity.y += GRAVITY * delta

		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		var move_input = Input.get_axis("move_left", "move_right")
		
		velocity.x = move_toward(velocity.x, move_input * SPEED, ACCELERATION * delta)

		move_and_slide()
		
		rpc("send_position", global_position)
		

@rpc("unreliable_ordered")
func send_position(pos: Vector2) -> void:
	global_position = pos
