extends MarginContainer


const MAX_PLAYERS = 4
const PORT = 5409

@onready var user = %User
@onready var ip = %IP
@onready var host = %Host
@onready var join = %Join


func _ready():
	host.pressed.connect(_on_host_pressed)
	join.pressed.connect(_on_join_pressed)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func _on_host_pressed():
	var peer = ENetMultiplayerPeer.new()
	print("host")


func _on_join_pressed():
	print("join")


func _on_connected_to_server():
	print("connected_to_server")


func _on_connection_failed():
	print("connection_failed")


func _on_peer_connected(id: int):
	prints("peer_connected", id)


func _on_peer_disconnected(id: int):
	prints("peer_disconnected", id)


func _on_server_disconnected():
	print("server_disconnected")

