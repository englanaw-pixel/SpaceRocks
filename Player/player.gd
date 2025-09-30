extends RigidBody2D

enum {INIT, ALIVE, INVULERABLE, DEAD}

var state = INIT 


@export var engine_power = 500
@export var spin_power = 8000
@export var bullet_scene : PackedScene
@export var fire_rate = 0.25
var can_shoot = true 
var thrust = Vector2.ZERO
var rotation_dir = 0 
var screensize = Vector2.ZERO

func _ready():
	change_state(ALIVE)
	screensize = get_viewport_rect().size
	$GunCoolDown.wait_time = fire_rate

func change_state(new_state):
	
	match new_state:
		INIT:
			$CollisionShape2D.set_deferred("dusabled", "true")
		ALIVE:
			$CollisionShape2D.set_deferred("dusabled", "true")
		INVULERABLE:
			$CollisionShape2D.set_deferred("dusabled", "true")
		DEAD:
			$CollisionShape2D.set_deferred("dusabled", "true")
	state = new_state

func get_input():
	thrust = Vector2.ZERO
	if state in [DEAD, INIT]:
		return
		
	if Input.is_action_pressed("thrust"):
		thrust = transform.x * engine_power
		
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()
	rotation_dir = Input.get_axis("rotate_left", "rotate_right")
func _process(_delta):
	get_input()

func _physics_process(_delta):
	
	constant_force = thrust
	constant_torque = rotation_dir * spin_power
	
func _integrate_forces(physics_state):
	var xform = physics_state.transform
	xform.origin.x = wrapf(xform.origin.x, 0, screensize.x)
	xform.origin.y = wrapf(xform.origin.y, 0, screensize.y)
	physics_state.transform = xform
	
	
func shoot():
	if state == INVULERABLE:
		return 
	can_shoot = false 
	$GunCoolDown.start()
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	b.start($Muzzle.global_transform)
	
func _on_gun_cool_down_timeout():
	can_shoot = true 
