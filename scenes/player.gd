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
@onready var ray_cast_2d = $RayCast2D


@export var ImpactParticles: PackedScene

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
	Debug.print(global_position)
	if is_multiplayer_authority():
		if not is_on_floor():
			velocity.y += GRAVITY * delta

		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		move_input = Input.get_axis("move_left", "move_right")
		
		velocity.x = move_toward(velocity.x, move_input * SPEED, ACCELERATION * delta)
		
		if Input.is_action_just_pressed("melee"):
			melee.rpc()
		
		rpc("send_data", global_position, velocity, move_input)
		
	move_and_slide()
	
	# Animation
	if move_input != 0:
		pivot.scale.x = sign(move_input)
	
	if abs(velocity.x) >= 10 or move_input != 0:
		playback.travel("walk")
	else:
		playback.travel("idle")
	
	if ray_cast_2d.is_colliding():
		modulate = Color.BURLYWOOD
	else:
		modulate = Color.DEEP_SKY_BLUE
	
@rpc("unreliable_ordered")
func send_data(pos: Vector2, vel: Vector2, mi: float) -> void:
	var weight = (pos.distance_squared_to(global_position) - 1000) / 3000
	weight = min(max(0.5, weight), 1.0)
	global_position = lerp(global_position, pos, weight)
	velocity = lerp(velocity, vel, 0.5)
	move_input = mi


@rpc("call_local", "reliable", "any_peer")
func hit(hit_position: Vector2) -> void:
	velocity = (global_position - hit_position).normalized() * HIT_SPEED + Vector2.UP * 300


@rpc("reliable", "any_peer")
func launch(laucher_position: Vector2) -> void:
	velocity = (global_position - laucher_position).normalized() * HIT_SPEED + Vector2.UP * 300


func _on_body_entered(body: Node) -> void:
	if body is Player and body != self:
		var player = body as Player
		player.launch.rpc(global_position)
		_spawn_impact_particles.rpc(body.global_position)


@rpc("call_local", "reliable")
func melee() -> void:
	playback.call_deferred("travel", "melee")

func _exit_tree():
	Debug.print("oh no")

@rpc("call_local", "reliable")
func _spawn_impact_particles(pos: Vector2) -> void:
	if not ImpactParticles:
		return
	var impact_particles = ImpactParticles.instantiate()
	add_sibling(impact_particles)
	impact_particles.global_position = pos
