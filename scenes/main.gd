extends Node2D

@export var player_scene: PackedScene
@onready var players = $Players
@onready var markers = $Markers


func _ready():
	Game.players.sort()
	for i in Game.players.size():
		var id = Game.players[i]
		var player: Player = player_scene.instantiate()
		players.add_child(player)
		var marker = markers.get_child(i)
		player.global_position = marker.global_position
		player.init(id)
		
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
