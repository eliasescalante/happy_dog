extends Node2D

const PIXEL : int = 60
var tween : Tween
var moving : bool = false
var attacking : bool = false
var current_idle = "idle"
@onready var valid_position = position
@onready var animation : AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_derecha : RayCast2D = $RayCasts/derecha
@onready var ray_izquierda : RayCast2D = $RayCasts/izquierda

var energia: float = 100.0
var last_direction: Vector2 = Vector2.ZERO

signal perro_se_movio(energia)
signal perro_inactivo()
signal wuau()

func _ready():
	pass

func _process(delta):
	var direction = Input.get_vector("move_left", "move_right", "", "")
	var action = Input.is_action_pressed("water")

	if action and not attacking:
		attacking = true
		if direction.x < 0:
			animation.play("attack_izquierda")
		elif direction.x > 0:
			animation.play("attack_derecha")
		else:
			animation.play("attack_derecha")
		emit_signal("wuau")

	if attacking:
		if not animation.is_playing():
			attacking = false
			print("Attack animation finished")

	if direction != Vector2.ZERO and not moving and not attacking:
		
		move_me(direction)
		energia -= 150.0 * delta
		emit_signal("perro_se_movio", energia)
	elif direction == Vector2.ZERO and not moving and not attacking:
		animation.play(current_idle)
		emit_signal("perro_inactivo")
		energia += 0.5 * delta
		energia = max(0, energia)

func move_me(direction):
	var next_position : Vector2

	if direction.x < 0 && !ray_izquierda.is_colliding():
		next_position = position + Vector2(-PIXEL, 0)
		animation.play("walk_left")
		current_idle = "idle"
		move_by_tween(next_position)
		
	elif direction.x > 0 && !ray_derecha.is_colliding():
		next_position = position + Vector2(PIXEL, 0)
		animation.play("walk_right")
		current_idle = "idle"
		move_by_tween(next_position)

	

func move_by_tween(next_position: Vector2):
	moving = true
	valid_position = next_position
	tween = create_tween()
	tween.tween_property(self, "position", next_position, 0.2)
	tween.tween_callback(Callable(self, "end_of_tween"))

func end_of_tween():
	moving = false
	animation.play("idle_down")
