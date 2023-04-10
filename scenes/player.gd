class_name Player
extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -300.0
const GRAVITY = 500
const ACCELERATION = 4000

const HIT_SPEED = 300.0


@onready var pivot = $Pivot
@onready var animation_tree = $AnimationTree
@onready var playback = animation_tree.get("parameters/playback")
@onready var sword = $Pivot/Sword

var move_input = 0


var meh = 5 :
	set(value):
		meh = lerp(value, meh, 0.5)
		prints("meh", meh)


func init(id):
	set_multiplayer_authority(id)
	name = str(id)


func _ready():
	Debug.print(name)
	set_multiplayer_authority(name.to_int())
	
	meh = 10
	animation_tree.active = true
	
	if is_multiplayer_authority():
		sword.body_entered.connect(_on_body_entered)
	

func _physics_process(delta) -> void:
	
	if is_multiplayer_authority():
		if not is_on_floor():
			velocity.y += GRAVITY * delta

		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		move_input = Input.get_axis("move_left", "move_right")
		
		velocity.x = move_toward(velocity.x, move_input * SPEED, ACCELERATION * delta)

		move_and_slide()
		
		if Input.is_action_just_pressed("melee"):
			melee.rpc()
		
		rpc("send_data", global_position, velocity, move_input)
	
	# Animation
	
	if move_input != 0:
		pivot.scale.x = sign(move_input)
	
	if abs(velocity.x) >= 10 or move_input != 0:
		playback.travel("walk")
	else:
		playback.travel("idle")
	

	
	

@rpc("unreliable_ordered")
func send_data(pos: Vector2, vel: Vector2, mi: float) -> void:
	global_position = lerp(global_position, pos, 0.5)
	velocity = lerp(velocity, vel, 0.5)
	move_input = mi


@rpc("call_local", "reliable", "any_peer")
func hit(hit_position: Vector2) -> void:
	velocity = (global_position - hit_position).normalized() * HIT_SPEED + Vector2.UP * 300


@rpc("call_local", "reliable")
func hit2(enemy: Node2D) -> void:
	enemy.velocity = (global_position - enemy.global_position).normalized() * HIT_SPEED + Vector2.UP * 300



func _on_body_entered(body: Node) -> void:
	if body is Player and body != self:
		var player = body as Player
		Debug.print(is_multiplayer_authority())
#		player.rpc("hit", global_position)
		rpc("hit2", player)
#		player.hit.rpc(global_position)

@rpc("call_local", "reliable")
func melee() -> void:
	playback.call_deferred("travel", "melee")
