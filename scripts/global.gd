extends Node

var score := 0.0
signal score_changed(new_score: float)
signal flash_fx

var junk: Array[Node] = []

func add_score(amount: float) -> void:
	score += amount
	score_changed.emit(score)

func reset_score() -> void:
	score = 0
	score_changed.emit(score)

func junk_put(node: Node) -> void:
	junk.push_front(node)

func cleanup() -> void:
	for node in junk:
		node.queue_free()

	junk = []
