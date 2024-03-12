extends Control

@export var address = "127.0.0.1"
@export var port = 9981
var peer
# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#Func called on Server & Clients
func peer_connected(id):
	print("Player Connected " + str(id))

#Server & Clients
func peer_disconnected(id):
	print("Player Disconnected " + str(id))

#Clients Only
func connected_to_server():
	print("Connected to Server")
	SendPlayerInformation.rpc_id(1, $Username.text, multiplayer.get_unique_id())

#Clients Only
func connection_failed():
	print("Failed to connect")

@rpc("any_peer")
func SendPlayerInformation(name, id):
	if !GameController.players.has(id):
		GameController.players[id] = {
			"name": name,
			"id": id,
			"points": 0,
			"abilities" : [0,1,2]
		}
	if multiplayer.is_server():
		for i in GameController.players:
			SendPlayerInformation.rpc(GameController.players[i].name, i)

@rpc("any_peer", "call_local")
func StartGame():
	var scene = load("res://sudoku_grid.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide

func _on_host_button_down():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 2)
	if error != OK:
		print("Cannot Host: " + error)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for Players")
	SendPlayerInformation($Username.text, multiplayer.get_unique_id())


func _on_join_button_down():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)

func _on_start_game_button_down():
	StartGame().rpc()
	pass # Replace with function body.
