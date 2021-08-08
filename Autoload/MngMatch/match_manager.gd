extends Node
"""
autoload Game
"""

signal scores_updated
signal match_begun

export var _default_match_time := 60

onready var _match_countdown: MatchCountdown = $UI/MatchCountdown
onready var _match_timer: Timer = $MatchTimer

var paddles_scenes := []
var ball_scene: PackedScene

var stage: Stage
var ball: Ball

"""
An array containing dictionaries of player information
{
	id: The player id and input id
	paddle: The player paddle
	spawn: the paddle spawn
	goal_area: the player's goal area
}
"""
var players := {}

var scores := {}

func get_match_time_left() -> float:
	return _match_timer.time_left

func setup_match(stage: Stage, paddles: Array, ball: Ball) -> void:
	players.clear()
	scores.clear()
	
	self.stage = stage
	self.ball = ball
	
	var smaller := min(paddles.size(), stage.paddle_spawns.size())
	
	for i in range(smaller):
		var paddle := paddles[i] as Paddle
		var spawn := stage.paddle_spawns[i] as PaddleSpawn
		
		var id := i + 1
		paddle.input.set_input_index(id)
		paddle.input.set_process(false)
		paddle.position = spawn.global_position
		paddle.set_shooting_direction(spawn.shooting_direction)
		
		players[id] = {
			id = id, paddle = paddle, spawn = spawn, goal_area = spawn.goal_area
		}
		scores[spawn.goal_area] = { id = id, score = 0 }
		
	
	paddles[0].hold_ball(ball)
	
	_match_countdown.play()
	
	for ga in stage.goal_areas:
		ga.connect("goal_scored", self, "_on_goal_scored")
	
	_match_timer.start(_default_match_time)
	emit_signal("match_begun")

func _on_goal_scored(goal_scorer: GoalScorer, goal_area: GoalArea) -> void:
	for player in players.values():
		if player.goal_area != goal_area:
			continue
		
		print("%s points scored on Id %s" % [goal_scorer.points, player.id])
		scores[goal_area].score += goal_scorer.points
		emit_signal("scores_updated")
		# Add scores
		_reset_players()
		player.paddle.hold_ball(ball)

func _reset_players() -> void:
	for player in players.values():
		player.paddle.position = player.spawn.global_position
		


func _on_MatchTimer_timeout():
	print("Match over")
	pass # Replace with function body.


func _on_match_countdown_over():
	for player in players.values():
		player.paddle.input.set_process(true)
