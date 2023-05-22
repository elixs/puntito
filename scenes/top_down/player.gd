extends CharacterBody2D

@export var speed = 300
@export var acceleration = 1000

@onready var animation_tree = $AnimationTree

func _ready():
	animation_tree.active = true


func _physics_process(delta):
	
	var move_input = Input.get_vector("move_left", "move_right","move_up", "move_down")
	velocity = velocity.move_toward(move_input * speed, acceleration * delta)
	move_and_slide()
	
	#animation
	if move_input != Vector2.ZERO:
		animation_tree.set("parameters/move/blend_position", move_input)
