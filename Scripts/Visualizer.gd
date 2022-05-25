extends Node

export var pieces_path : NodePath
onready var pieces = get_node(pieces_path)
var white_piece = preload("res://Scenes/White Piece.tscn")
var black_piece = preload("res://Scenes/Black Piece.tscn")
var all_states = [];
var index;

func _ready():
	var board = BoardManager.current_board;
	print(BoardManager.kthrings.size())
	var state = State.new(board, 0, 0)
	draw_complete_board(state.board)
	# minimax
	var time_now = OS.get_unix_time();
	
	
	var maxi = true;
	var new_state = state;
	all_states.append(new_state);
	var count = 0;
	var black = 14;
	var white = 14;
	
	var mm = MiniMax.new()
	while not BoardManager.terminal(new_state.board):
		new_state = MiniMax.forward_pruning_alpha_beta(new_state, 3, maxi, -INF, INF)[0];
		print(new_state)
		count += 1;
		print("count: ", count)
		black = BoardManager.get_number_of_marbles(new_state.board, BoardManager.BLACK);
		print("black: ", black)
		white = BoardManager.get_number_of_marbles(new_state.board, BoardManager.WHITE);
		print("white: ", white)
		print("------")
		maxi = not maxi;
		all_states.append(new_state);
		
	index = all_states.size() - 1
	var time_after = OS.get_unix_time();
	var time_elapsed = time_after - time_now;
	print("time: ", time_elapsed)
	update_board(new_state.board)
	


func _input(event):
	if event is InputEventKey and event.pressed:
		var m = event.as_text().replace("Kp ", "")
		
		if m == "Right":
			print("History, Towards forward:", index)
			if index < all_states.size() - 1:
				index = index + 1
				update_board(all_states[index].board)
			elif index == all_states.size() - 1:
				index = 0
				update_board(all_states[index].board)
				
		elif m == "Left":
			print("History, Towards backward:")
			if index - 1 >= 0:
				index = index - 1
				update_board(all_states[index].board)
			elif index == 0:
				index = all_states.size() - 1
				update_board(all_states[index].board)
				
		elif m == "S":
			print("History, Start of the game:")
			index = 0;
			update_board(all_states[index].board)
		elif m == "E":
			print("History: End of the game")
			index = all_states.size() - 1;
			update_board(all_states[index].board)
		
		print("index: ", index)

func update_board(new_board):
	for child in pieces.get_children():
		child.queue_free()
	
	draw_complete_board(new_board)

func draw_complete_board(board):
	var coordinates = Vector3(0, 0, 0)
	for cell_number in range(len(board)):
		if board[cell_number] == BoardManager.WHITE:
			coordinates = get_3d_coordinates(cell_number)
			var piece = white_piece.instance()
			pieces.add_child(piece)
			piece.translation = coordinates
		elif board[cell_number] == BoardManager.BLACK:
			coordinates = get_3d_coordinates(cell_number)
			var piece = black_piece.instance()
			pieces.add_child(piece)
			piece.translation = coordinates

func get_3d_coordinates(cell_number):
	if cell_number >= 0 and cell_number <= 4:
		return Vector3(-0.6 + cell_number * 0.3, 0.01, -1.04)
	elif cell_number >= 5 and cell_number <= 10:
		return Vector3(-0.75 + (cell_number - 5) * 0.3, 0.01, -0.78)
	elif cell_number >= 11 and cell_number <= 17:
		return Vector3(-0.9 + (cell_number - 11) * 0.3, 0.01, -0.52)
	elif cell_number >= 18 and cell_number <= 25:
		return Vector3(-1.05 + (cell_number - 18) * 0.3, 0.001, -0.26)
	elif cell_number >= 26 and cell_number <= 34:
		return Vector3(-1.2 + (cell_number - 26) * 0.3, 0.01, 0)
	elif cell_number >= 35 and cell_number <= 42:
		return Vector3(-1.05 + (cell_number - 35) * 0.3, 0.01, 0.26)
	elif cell_number >= 43 and cell_number <= 49:
		return Vector3(-0.9 + (cell_number - 43) * 0.3, 0.01, 0.52)
	elif cell_number >= 50 and cell_number <= 55:
		return Vector3(-0.75 + (cell_number - 50) * 0.3, 0.01, 0.78)
	else:
		return Vector3(-0.6 + (cell_number - 56) * 0.3, 0.01, 1.04)
	
