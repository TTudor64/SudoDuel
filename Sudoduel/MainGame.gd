extends Node2D

var selected_cell: Button = null
# Called when the node enters the scene tree for the first time.
@export var sudoku_array = [[],[],[],[],[],[],[],[],[]]
@export var completed_array = [[],[],[],[],[],[],[],[],[]]
@export var edit_array = [[],[],[],[],[],[],[],[],[]]
@export var PlayerScene : PackedScene

var rng = RandomNumberGenerator.new()


func _ready():
	var index = 0
	for i in GameController.players:
		var currentPlayer = PlayerScene.instantiate()
		currentPlayer.name = str(GameController.players[i].id)
		add_child(currentPlayer)
		for spawn in get_tree().get_nodes_in_group("PlayerSpawnPoint"):
			if spawn.name == str(index):
				currentPlayer.global_position = spawn.global_position
				
		index += 1
	
	for i in range($GridContainer.get_child_count()):
		var cell = $GridContainer.get_child(i)
		cell.connect("cell_selected", Callable(self, "_on_cell_selected"))
	$UI_Buttons.connect("solve_board", Callable(self, "_on_board_solve"))
	$UI_Buttons.connect("new_game", Callable(self, "_on_new_game"))
	$UI_Buttons.connect("rotate", Callable(self, "_on_rotate_board"))
	init_sudoku_array()
	generate_sudoku_array()
	completed_array = sudoku_array.duplicate(true)
	remove_clues(43)
	generate_edit_array()
	fill_board()
	update_board()
	
	
func update_board():
	for i in range($GridContainer.get_child_count()):
		var cell = $GridContainer.get_child(i)
		if cell.text == "":
			sudoku_array[i/9][i % 9] = 0
		else:
			sudoku_array[i/9][i % 9] = int(cell.text)
		
	$UI_Buttons/Label.text = check_grid()
		
func update_cells():
	for i in range($GridContainer.get_child_count()):
		var cell = $GridContainer.get_child(i)
		if sudoku_array[i/9][i % 9] == 0:
			cell.text = ""
		else:
			cell.text = str(sudoku_array[i/9][i % 9])
		if edit_array[i/9][i % 9] == 1:
			cell.is_editable = true
		else:
			cell.is_editable = false
			
		
func _on_cell_selected(cell: Button):
	selected_cell = cell

func _on_board_solve():
	solve_board()
	
func _on_rotate_board():
	sudoku_array = rotate_matrix(sudoku_array)
	completed_array = rotate_matrix(completed_array)
	edit_array = rotate_matrix(edit_array)
	update_cells()

func _on_new_game():
	for i in range($GridContainer.get_child_count()):
		var cell = $GridContainer.get_child(i)
		cell.is_editable = false
	sudoku_array = [[],[],[],[],[],[],[],[],[]]
	completed_array = [[],[],[],[],[],[],[],[],[]]
	init_sudoku_array()
	generate_sudoku_array()
	completed_array = sudoku_array.duplicate(true)
	remove_clues(43)
	generate_edit_array()
	fill_board()
	update_board()


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

func rotate_matrix(matrix):
	var size = 9
	var rotated_matrix = []
	
	for i in range(size):
		rotated_matrix.append([])

	# Transpose and reverse each row
	for i in range(size):
		for j in range(size):
			rotated_matrix[j].insert(0, matrix[i][j])
	
	return rotated_matrix
		
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if selected_cell:
			if event.pressed and Input.is_key_pressed(KEY_SHIFT):
				if event.keycode >= KEY_1 and event.keycode <= KEY_9:
					var number = event.keycode - KEY_1 + 1
					if selected_cell.is_editable and selected_cell.text == "":
						selected_cell.toggle_jotting_visibility(number)
			elif event.keycode >= KEY_1 and event.keycode <= KEY_9 and not Input.is_key_pressed(KEY_SHIFT):
				var number = event.keycode - KEY_1 + 1
				if selected_cell.is_editable:
					selected_cell.hide_all_jottings()
					selected_cell.text = str(number)
			elif Input.is_key_pressed(KEY_BACKSPACE) or Input.is_key_pressed(KEY_DELETE):
				if selected_cell.is_editable:
					selected_cell.text = ""
					selected_cell.hide_all_jottings()
			elif Input.is_key_pressed(KEY_ESCAPE):
				selected_cell = null
			update_board()
func init_sudoku_array():
	for i in range(9):
		for j in range(9):
			sudoku_array[j].append(0)
			
	print(sudoku_array)

func generate_sudoku_array():
	var tmp = [1,2,3,4,5,6,7,8,9]
	tmp.shuffle()
	for i in range(3):
		for j in range(3):
			sudoku_array[i][j] = tmp.pop_back()
	tmp = [1,2,3,4,5,6,7,8,9]
	tmp.shuffle()
	for i in range(3):
		for j in range(3):
			sudoku_array[i+3][j+3] = tmp.pop_back()
	tmp = [1,2,3,4,5,6,7,8,9]
	tmp.shuffle()
	for i in range(3):
		for j in range(3):
			sudoku_array[i+6][j+6] = tmp.pop_back()
	
	return recursive_fill()

func fill_board():
	for i in range($GridContainer.get_child_count()):
		var cell = $GridContainer.get_child(i)
		var row = i / 9
		var col = i % 9
		if sudoku_array[row][col] == 0:
			cell.text = ""
		else:
			cell.text = str(sudoku_array[row][col])
	
func recursive_fill():
	for row in range(9):
		for col in range(9):
			if sudoku_array[row][col] == 0:
				var random_num = rng.randi_range(1,9)
				
				if check_space(random_num,[row,col]):
					sudoku_array[row][col] = random_num
				
					if solve():
						recursive_fill()
						return sudoku_array
					
					sudoku_array[row][col] = 0
				
					
			
			
			
	return false

func check_space(num: int,space: Array):
	if not sudoku_array[space[0]][space[1]] == 0:
		return false
	
	for col in sudoku_array[space[0]]:
		if col == num:
			return false
	
	for row in range(9):
		if sudoku_array[row][space[1]] == num:
			return false
			
	var cube_row = space[0] / 3
	var cube_col = space[1] / 3
	
	for i in range(3):
		for j in range(3):
			if sudoku_array[i + (cube_row * 3)][j + (cube_col * 3)] == num:
				return false
	
	return true

func solve():
	var emptySpace = findSpaces()
	
	if not emptySpace:
		return true
	else:
		var row = emptySpace[0]
		var col = emptySpace[1]
	
		for i in range(1,10):
			if check_space(i, [row,col]):
				sudoku_array[row][col] = i
				
				if solve():
					return sudoku_array
				
				sudoku_array[row][col] = 0

	return false


func findSpaces():
	for row in range(9):
		for col in range(9):
			if sudoku_array[row][col] == 0:
				return [row,col]
	return false
	
func remove_clues(num_clues: int):
	var nums = range(81)
	nums.shuffle()
	
	for i in range(num_clues+1):
		var num = nums.pop_back()
		var cell = $GridContainer.get_child(num)
		sudoku_array[num/9][num % 9] = 0
		
		cell.is_editable = true
		
func check_grid():
	var text = "Results: \n Empty: %d \n Wrong: %d "
	var empty = 0
	var wrong = 0
	for i in range($GridContainer.get_child_count()):
		var cell = $GridContainer.get_child(i)
		if cell.text == "":
			empty += 1
		elif cell.text != str(completed_array[i/9][i%9]):
			wrong +=1
	
	var result = text % [empty,wrong]
	
	if empty == 0 and wrong == 0:
		result = "Results: \n All Correct. Well Done"
	return result
	
func solve_board():
	for i in range($GridContainer.get_child_count()):
		var cell = $GridContainer.get_child(i)
		cell.text = str(completed_array[i/9][i%9])
	update_board()
