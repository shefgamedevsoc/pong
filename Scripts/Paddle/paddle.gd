extends KinematicBody2D
class_name Paddle

export(NodePath) var _states_parent: NodePath

onready var _ball_reactor: PaddleBallReactor = $BallCollider
onready var _input: InputNode = $Input

var _fields := PaddleFields.new()
var _states := []

func _ready() -> void:
	_states =  get_children() if _states_parent.is_empty() else get_node(_states_parent).get_children()
	for state in _states:
		state.set_fields(_fields)
		state.set_input(_input)

func _process(delta: float) -> void:
	
	for state in _states:
		state.execute(delta)
		if state.escape_stack_execution:
			break
	
	var collision := move_and_collide(_fields.velocity)
	if collision:
		_fields.velocity = Vector2()
		
	_ball_reactor.velocity = _fields.velocity