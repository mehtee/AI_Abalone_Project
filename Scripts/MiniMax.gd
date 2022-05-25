extends Node

class_name MiniMax

var ttable = {}

func _init():
	ttable = {}

static func generate_zobrist_hash(state):
	var h = 0;
	var sboard = state.board;
	for cell_number in range(len(sboard)):
		if state.board[cell_number] == BoardManager.WHITE:
			var hash_w = BoardManager.hashes[cell_number][0]
			h = h ^ hash_w
		elif state.board[cell_number] == BoardManager.BLACK:
			var hash_b = BoardManager.hashes[cell_number][1]
			h = h ^ hash_b
			
	return h;
			

static func center_proximity_heuristic(state, piece):
	var sum = 0;
	var count_marbles = 0;
	for cell_number in range(len(state.board)):
		if state.board[cell_number] == piece:
			var dis = BoardManager.kthrings[cell_number];
			sum = sum + dis;
			count_marbles += 1;
			
	if count_marbles != 0:
		return float(float(sum)/float(count_marbles));
	return 0;

static func coherence_proximity_heuristic(state, piece):
	var all_marbles_count = 0;
	for cell_number in range(len(state.board)):
		if state.board[cell_number] == piece:
			var neighbors = BoardManager.neighbors[cell_number];
			var count = 0;
			for neighbor in neighbors:
				if state.board[neighbor] == piece:
					count += 1
			all_marbles_count += count;
	
	return all_marbles_count;
	
static func number_of_marbles_heuristic(state, piece):
	return BoardManager.get_number_of_marbles(state.board, piece);

static func heuristic(state, piece):
	var opponent = BoardManager.BLACK;
		
	piece = BoardManager.WHITE;
		
	# center proximity calc heuristic (1)
	var center_prox = center_proximity_heuristic(state, opponent) -  center_proximity_heuristic(state, piece)
	
	# coherence proximity calc heuristic (2)
	var coherence_prox = 0;
	if abs(center_prox) > 2:
		coherence_prox = coherence_proximity_heuristic(state, opponent) - coherence_proximity_heuristic(state, piece);
		
	
	# number of marbles calc heuristic (3)
	var num_of_marbles_prox = 0;
	if abs(center_prox) <= 1.8:
		num_of_marbles_prox = 100*number_of_marbles_heuristic(state, piece) - 100*number_of_marbles_heuristic(state, opponent)

	
	return num_of_marbles_prox + center_prox + coherence_prox
	
static func rep(new_score, prev_score, isMax):
	if isMax:
		return new_score > prev_score
	else:
		return new_score < prev_score

static func minimax(state, depth, isMax):
	var res = BoardManager.is_game_over(state.board)
	
	if res == BoardManager.WHITE:
		return [state, INF]
	elif res == BoardManager.BLACK:
		return [state, -INF]
			
	if depth == 0:
		var this_piece;
		var h;
		if isMax:
			this_piece = BoardManager.WHITE
			h = heuristic(state, this_piece)
		else:
			this_piece = BoardManager.BLACK
			h = heuristic(state, this_piece)
		return [state, h]
		
		
	var piece;
	var move_state;
	var bestScore;
	if isMax:
		bestScore = -INF;
		piece = BoardManager.WHITE
	else:
		bestScore = INF;
		piece = BoardManager.BLACK
	
	for successor in Successor.calculate_successor(state, piece):
		var eval = minimax(successor, depth - 1, not isMax)
		if rep(eval[1], bestScore, isMax):
			move_state = successor;
			bestScore = eval[1]
	
	return [move_state, bestScore]


static func alpha_beta(state, depth, isMax, alpha, beta):
	var res = BoardManager.is_game_over(state.board)
	
	if res == BoardManager.WHITE:
		return [state, INF]
	elif res == BoardManager.BLACK:
		return [state, -INF]
			
	if depth == 0:
		var this_piece;
		var h;
		if isMax:
			this_piece = BoardManager.WHITE
			h = heuristic(state, this_piece)
		else:
			this_piece = BoardManager.BLACK
			h = -1*heuristic(state, this_piece)
		return [state, h]
		
		
	var piece;
	var bestScore;
	if isMax:
		bestScore = -INF;
		piece = BoardManager.WHITE
	else:
		bestScore = INF;
		piece = BoardManager.BLACK
	
	var successors = Successor.calculate_successor(state, piece);
	var move_state = successors[0];
	for successor in successors:
		if successor != null:
			var eval = alpha_beta(successor, depth - 1, not isMax, alpha, beta)
			if rep(eval[1], bestScore, isMax):
				move_state = successor;
				bestScore = eval[1]
			
			if isMax:
				alpha = max(alpha, eval[1])
			else:
				beta = min(beta, eval[1])
			
			if alpha >= beta:
				break
	
	return [move_state, bestScore]


func alpha_beta_with_table(state, depth, isMax, alpha, beta):
	var res = BoardManager.is_game_over(state.board)
	
	if res == BoardManager.WHITE:
		return [state, INF]
	elif res == BoardManager.BLACK:
		return [state, -INF]
			
	if depth == 0:
		var this_piece;
		var h;
		var hash_of_state = generate_zobrist_hash(state);
		if isMax:
			this_piece = BoardManager.WHITE
			var flag = false;
			if self.ttable.has(hash_of_state):
				if self.ttable[hash_of_state].depth >= depth:
					var t = self.ttable[hash_of_state];
					h = t.eval
					flag = true;
			if flag == false:
				h = heuristic(state, this_piece)
				self.ttable[hash_of_state] = tt.new(state, depth, h);
		else:
			this_piece = BoardManager.BLACK
			var flag = false;
			if self.ttable.has(hash_of_state):
				if self.ttable[hash_of_state].depth >= depth:
					var t = self.ttable[hash_of_state];
					h = -1 * t.eval
			if flag == false:
				h = -1 * heuristic(state, this_piece)
				self.ttable[hash_of_state] = tt.new(state, depth, h);
		return [state, h]
		
		
	var piece;
	var bestScore;
	if isMax:
		bestScore = -INF;
		piece = BoardManager.WHITE
	else:
		bestScore = INF;
		piece = BoardManager.BLACK
	
	var successors = Successor.calculate_successor(state, piece);
	var move_state = successors[0];
	for successor in successors:
		if successor != null:
			var eval = alpha_beta_with_table(successor, depth - 1, not isMax, alpha, beta)
			if rep(eval[1], bestScore, isMax):
				move_state = successor;
				bestScore = eval[1]
			
			if isMax:
				alpha = max(alpha, eval[1])
			else:
				beta = min(beta, eval[1])
			
			if alpha >= beta:
				break
	
	
	var hash_of_state = generate_zobrist_hash(state);
	self.ttable[hash_of_state] = tt.new(state, depth, bestScore);
				
				
	return [move_state, bestScore]



static func forward_pruning(states):
	var pq = PQ.new()
	pq.make()
	for stateq in states:
		var h = heuristic(stateq, BoardManager.WHITE);
		pq.push(PQState.new(stateq, h))
	
	var best_ones = [];
	var best_ones_num = pq.size()/3;
	if pq.size() == 2:
		best_ones_num = 2;
	if pq.size() == 1:
		best_ones_num = 1;
	for i in range(best_ones_num):
		best_ones.append(pq.pop().state)
		
	return states;
	
	
static func forward_pruning_alpha_beta(state, depth, isMax, alpha, beta):
	var res = BoardManager.is_game_over(state.board)
	
	if res == BoardManager.WHITE:
		return [state, INF]
	elif res == BoardManager.BLACK:
		return [state, -INF]
			
	if depth == 0:
		var this_piece;
		var h;
		if isMax:
			this_piece = BoardManager.WHITE
			h = heuristic(state, this_piece)
		else:
			this_piece = BoardManager.BLACK
			h = -1*heuristic(state, this_piece)
		return [state, h]
		
		
	var piece;
	var bestScore;
	if isMax:
		bestScore = -INF;
		piece = BoardManager.WHITE
	else:
		bestScore = INF;
		piece = BoardManager.BLACK
	
	# Forward Pruning before alpha beta minimax of successors.
	var successors = Successor.calculate_successor(state, piece);
	successors = forward_pruning(successors);
	
	var move_state = successors[0];
	for successor in successors:
		if successor != null:
			var eval = alpha_beta(successor, depth - 1, not isMax, alpha, beta)
			if rep(eval[1], bestScore, isMax):
				move_state = successor;
				bestScore = eval[1]
			
			if isMax:
				alpha = max(alpha, eval[1])
			else:
				beta = min(beta, eval[1])
			
			if alpha >= beta:
				break
	
	return [move_state, bestScore]



