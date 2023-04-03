extends Node2D

@export var player_scene: PackedScene
@onready var players = $Players
@onready var markers = $Markers


func _ready():
	if is_multiplayer_authority():
		Game.players.sort()
		for i in Game.players.size():
			var id = Game.players[i]
			var player: Player = player_scene.instantiate()
			player.name = str(id)
			var marker = markers.get_child(i)
			player.global_position = marker.global_position
			players.add_child(player)
#			player.init(id)
		

