extends Node

@onready var canvas = CanvasLayer.new()
@onready var container = VBoxContainer.new()

func _ready() -> void:
	add_child(canvas)
	canvas.add_child(container)

func print(message: Variant) -> void:
	if not multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		var type = "Server" if multiplayer.is_server() else "Client"
		print_rich("[b]%s:[/b]" % type, message)
		message = "%s: %s" % [type, str(message)]
	else:
		print(message)
	var label = Label.new()
	label.text = str(message)
	container.add_child(label)
	container.move_child(label, 0)
	await get_tree().create_timer(2).timeout
	container.remove_child(label)
	label.queue_free()
