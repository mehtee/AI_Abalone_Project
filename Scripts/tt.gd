extends Reference

class_name tt

var state;
var depth;
var eval;

func _init(state, depth, eval):
	self.state = state;
	self.depth = depth;
	self.eval = eval;
