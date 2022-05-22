extends Node

class_name MiniMax

static func rep(x, score, isMax):
	if isMax:
		return x > score
	else:
		return x < score

static func minimax(state, depth, isMax):
	var res = BoardManager.is_game_over(state.board)
	if depth == 3 or res != null:
		if res == BoardManager.WHITE:
			return [state, state.white_score]
		elif res == BoardManager.BLACK:
			return [state, state.black_score]
		else:
			return [state, state.black_score]
			
	var move_state;
	var bestScore
	var piece
	if isMax:
		bestScore = -INF;
		piece = BoardManager.WHITE;
	else:
		bestScore = INF;
		piece = BoardManager.BLACK;
	
	for successor in Successor.calculate_successor(state, piece):
		var eval = minimax(successor, depth + 1, not isMax)
		if rep(eval[1], bestScore, isMax):
			move_state = successor;
			bestScore = eval[1]
	
	return [move_state, bestScore]
