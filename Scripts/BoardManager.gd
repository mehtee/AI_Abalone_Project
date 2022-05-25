extends Node

var current_board = []
var neighbors = {}
var kthrings = {}
enum {EMPTY, BLACK, WHITE} # used to represent the board
enum {L, UL, UR, R, DR, DL} # used to represent the directions of neighbors
var hashes = {}
var arr_hashes = []
var rng = RandomNumberGenerator.new()

	
func _ready():
	init_board()
	# test_board()

func init_board():
	var file = File.new()
	file.open("res://adjacency_lists.json", File.READ)
	var raw_data = file.get_as_text()
	var adjacency_lists = parse_json(raw_data)
	file.close() # reading the file that specifies the adjacency lists and converting it to a dictionary
	
	for cell_number in range(61):
		var cell_value = EMPTY
		if (cell_number >= 0 and cell_number <= 10) or (cell_number >= 13 and cell_number <= 15):
			cell_value = BLACK
		elif (cell_number >= 45 and cell_number <= 47) or (cell_number >= 50 and cell_number <= 60):
			cell_value = WHITE
		else:
			cell_value = EMPTY # determining the value of the current board cell
		
		current_board.append(cell_value)
		neighbors[cell_number] = []
		for neighbor in adjacency_lists[str(cell_number)]:
			neighbors[cell_number].append(int(neighbor))
	
	### 4th ring
	var forth_ring = []
	# top
	for cell_number in range(0, 5):
		forth_ring.append(cell_number)
	# bottom
	for cell_number in range(56, 61):
		forth_ring.append(cell_number)
	# right top
	forth_ring += [10, 17, 25, 34]
	# right bottom
	forth_ring += [42, 49, 55]
	# left top
	forth_ring += [5, 11, 18, 26]
	# left bottom
	forth_ring += [35, 43, 50]
	
	for cell in forth_ring:
		kthrings[cell] = 4;
	
	### 3nd ring
	var third_ring = []
	# top
	for cell_number in range(6, 10):
		third_ring.append(cell_number)
	# bottom
	for cell_number in range(51, 55):
		third_ring.append(cell_number)
	# right top
	third_ring += [16, 24, 33]
	# right bottom
	third_ring += [41, 48]
	# left top
	third_ring += [12, 19, 27]
	# left bottom
	third_ring += [36, 44]
	
	for cell in third_ring:
		kthrings[cell] = 3;
	
	### 2nd ring
	var second_ring = []
	# top
	for cell_number in range(13, 16):
		second_ring.append(cell_number)
	# bottom
	for cell_number in range(45, 48):
		second_ring.append(cell_number)
	# right top
	second_ring += [23, 32]
	# right bottom
	second_ring += [40]
	# left top
	second_ring += [20, 28]
	# left bottom
	second_ring += [37]
	
	for cell in second_ring:
		kthrings[cell] = 2;
	
	### 1st ring
	var first_ring = [21, 22, 31, 39, 38, 29]
	for cell in first_ring:
		kthrings[cell] = 1;
	
	kthrings[30] = 0;
	
	

	# Generating each cell's hash of each player in arr_hashes:
	# For Player 1 and 2:
	
	
	for cell_number in range(61):
		var player1 = int(str(rng.randi_range(100,999)) + str(cell_number) + str(1))
		var player2 = int(str(rng.randi_range(100,999)) + str(cell_number) + str(2))


		hashes[cell_number] = [player1, player2]
		
	print(hashes)
	
func check_cluster(board, cell_number, piece, cluster_length, cluster_direction):
	if board[cell_number] != piece:
		return false
	
	var neighbor = cell_number
	for i in range(1, cluster_length):
		neighbor = neighbors[neighbor][cluster_direction]
		if neighbor == -1:
			return false
		elif board[neighbor] != piece:
			return false
	return true
	
func get_stats(board, cell_number, piece, cluster_length, cluster_direction):
	var num_side_pieces = 0
	var num_opponent_pieces = 0
	var piece_has_space = false
	var opponent_has_space = false
	var is_sandwich = false
	
	var current_point = cell_number
	for i in range(cluster_length + cluster_length):
		if board[current_point] == piece:
			if num_opponent_pieces > 0:
				is_sandwich = true
				break
			else:	
				num_side_pieces += 1
				if neighbors[current_point][cluster_direction] != -1:
					if board[neighbors[current_point][cluster_direction]] == EMPTY and i == cluster_length - 1:
						piece_has_space = true
						break
					
		elif board[current_point] == EMPTY:
			continue
			
		else: # opponent
			if num_side_pieces == cluster_length:
				num_opponent_pieces += 1
			if neighbors[current_point][cluster_direction] != -1:
				if board[neighbors[current_point][cluster_direction]] == EMPTY and piece_has_space == false and num_side_pieces == cluster_length and i != cluster_length + cluster_length - 1:
					opponent_has_space = true
					break
		
		current_point = neighbors[current_point][cluster_direction]
		if current_point == -1:
			break
	return {"number of side pieces" : num_side_pieces, "number of opponent pieces" : num_opponent_pieces, \
			"piece has space" : piece_has_space, "opponent has space" : opponent_has_space, 
			"is sandwich" : is_sandwich}
	

func get_number_of_marbles(board, piece):
	# Finding the number of marbles of the given piece type in the board
	var count = 0;
	for cell_number in range(len(board)):
		if board[cell_number] == piece:	
			count += 1;
	return count;


func terminal(board):
	# Return the winner if game is over
	if get_number_of_marbles(board, BoardManager.BLACK) <= 8:
		return true;
	elif get_number_of_marbles(board, BoardManager.WHITE) <= 8:
		return true;
	else:
		return false;
	

func is_game_over(board):
	# Return the winner if game is over
	if get_number_of_marbles(board, BoardManager.BLACK) <= 8:
		return BoardManager.WHITE
	elif get_number_of_marbles(board, BoardManager.WHITE) <= 8:
		return BoardManager.BLACK
	return null;
	
	
func test_board():
	for i in range(61):
		if neighbors[i][L] != -1: # check the correctness of left neighbors
			if neighbors[neighbors[i][L]][R] != i:
				print("Incorrect Left Neighbor: ", i, ", ", neighbors[neighbors[i][L]][R])
				
		if neighbors[i][UL] != -1: # check the correctness of up left neighbors
			if neighbors[neighbors[i][UL]][DR] != i:
				print("Incorrect Up Left Neighbor: ", i, ", ", neighbors[neighbors[i][UL]][DR])
		
		if neighbors[i][UR] != -1: # check the correctness of up right neighbors
			if neighbors[neighbors[i][UR]][DL] != i:
				print("Incorrect Up Right Neighbor: ", i, ", ", neighbors[neighbors[i][UR]][DL])
				
		if neighbors[i][R] != -1: # check the correctness of right neighbors
			if neighbors[neighbors[i][R]][L] != i:
				print("Incorrect Right Neighbor: ", i, ", ", neighbors[neighbors[i][R]][L])
				
		if neighbors[i][DR] != -1: # check the correctness of down right neighbors
			if neighbors[neighbors[i][DR]][UL] != i:
				print("Incorrect Down Right Neighbor: ", i, ", ", neighbors[neighbors[i][DR]][UL])
				
		if neighbors[i][DL] != -1:
			if neighbors[neighbors[i][DL]][UR] != i:
				print("Incorrect Down Left Neighbor: ", i, ", ", neighbors[neighbors[i][DL]][UR])
