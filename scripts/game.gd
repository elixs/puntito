extends Node

# [ id ]
var players: Array = []


# Emitted when UPnP port mapping setup is completed (regardless of success or failure).
signal upnp_completed(error)

# Replace this with your own server port number between 1024 and 65535.
const SERVER_PORT = 5409
var thread = null

func _upnp_setup(server_port):
	# UPNP queries take some time.
	var upnp = UPNP.new()
	var err = upnp.discover()
	
	print("discover")
	

	if err != OK:
		push_error(str(err))
		emit_signal("upnp_completed", err)
		return

	var gateway = upnp.get_gateway()
	if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
		upnp.add_port_mapping(server_port, server_port, ProjectSettings.get_setting("application/config/name"), "UDP")
		upnp.add_port_mapping(server_port, server_port, ProjectSettings.get_setting("application/config/name"), "TCP")
		print("signal2")
		
		emit_signal("upnp_completed", OK)

func _ready():
	thread = Thread.new()
	thread.start(_upnp_setup.bind(SERVER_PORT))
	print("start")

func _exit_tree():
	# Wait for thread finish here to handle game exit while the thread is running.
	thread.wait_to_finish()
