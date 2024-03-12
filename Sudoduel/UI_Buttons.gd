extends VBoxContainer

signal solve_board()
signal new_game()
signal rotate()
# Called when the node enters the scene tree for the first time.
func _ready():
	
	$Solve.connect("pressed", Callable(self, "_on_solve_pressed"))
	$New_Game.connect("pressed", Callable(self, "_on_new_game_pressed"))
	$Rotate.connect("pressed", Callable(self, "_on_rotate_pressed"))
	
func _on_solve_pressed():
	solve_board.emit()

func _on_new_game_pressed():
	new_game.emit()

func _on_rotate_pressed():
	rotate.emit()
