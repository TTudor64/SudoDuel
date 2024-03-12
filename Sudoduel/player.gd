extends Node2D

var selected_cell: Button = null
var current_array = [[],[],[],[],[],[],[],[],[]]
var edit_array = [[],[],[],[],[],[],[],[],[]]
var player_solved_array = []
var cells = [[],[],[],[],[],[],[],[],[]]
# Called when the node enters the scene tree for the first time.
func _ready():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	for i in range($GridContainer.get_child_count()):
		var cell = $GridContainer.get_child(i)
		cell.connect("cell_selected", Callable(self, "_on_cell_selected"))
		cell.toggle_blur()
		cell.set_index(i)
		cells[i / 9].append(cell)
	
	init_array()
	player_solved_array = MainGame.completed_array.duplicate(true)


func _on_cell_selected(cell: Button):
	selected_cell = cell
	

func init_array():
	for i in range(9):
		for j in range(9):
			current_array[j].append(0)
			
	print(current_array)

func update_cells():
	for i in range($GridContainer.get_child_count()):
		var cell = $GridContainer.get_child(i)
		if current_array[i/9][i % 9] == 0:
			cell.text = ""
		else:
			cell.text = str(current_array[i/9][i % 9])
		if edit_array[i/9][i % 9] == 1:
			cell.disabled = true
		else:
			cell.disabled = false

func generate_edit_array():
	for i in range(9):
		for j in range(9):
			edit_array[j].append(0)
	for i in range($GridContainer.get_child_count()):
		var cell = $GridContainer.get_child(i)
		if cell.is_editable:
			edit_array[i/9][i%9] = 1
		else:
			edit_array[i/9][i%9] = 0
			

func _process(delta):
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		if selected_cell:
			if Input.is_action_pressed("select_right"):
				var index = selected_cell.index
				selected_cell = cells[index / 9][(index+1) % 9]
			if Input.is_action_pressed("select_left"):
				var index = selected_cell.index
				selected_cell = cells[index / 9][(index-1) % 9]
			if Input.is_action_pressed("select_down"):
				var index = selected_cell.index
				selected_cell = cells[(index+1 / 9) % 9][index % 9]
			if Input.is_action_pressed("select_up"):
				var index = selected_cell.index
				selected_cell = cells[(index-1 / 9) % 9][index % 9]
