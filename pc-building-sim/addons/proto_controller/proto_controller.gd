# ProtoController v1.0 by Brackeys
# CC0 License
# Intended for rapid prototyping of first-person games.
# Happy prototyping!

extends CharacterBody3D

@onready var raycast = $Head/Camera3D/RayCast3D
@onready var marker = $Head/Camera3D/Marker3D
## Can we move around?
@export var can_move : bool = true
## Are we affected by gravity?
@export var has_gravity : bool = true
## Can we press to jump?
@export var can_jump : bool = true
## Can we hold to run?
@export var can_sprint : bool = false
## Can we press to enter freefly mode (noclip)?
@export var can_freefly : bool = false

@export_group("Speeds")
## Look around rotation speed.
@export var look_speed : float = 0.002
## Normal speed.
@export var base_speed : float = 7.0
## Speed of jump.
@export var jump_velocity : float = 4.5
## How fast do we run?
@export var sprint_speed : float = 10.0
## How fast do we freefly?
@export var freefly_speed : float = 25.0

@export_group("Input Actions")
## Name of Input Action to move Left.
@export var input_left : String = "ui_left"
## Name of Input Action to move Right.
@export var input_right : String = "ui_right"
## Name of Input Action to move Forward.
@export var input_forward : String = "ui_up"
## Name of Input Action to move Backward.
@export var input_back : String = "ui_down"
## Name of Input Action to Jump.
@export var input_jump : String = "ui_accept"
## Name of Input Action to Sprint.
@export var input_sprint : String = "sprint"
## Name of Input Action to toggle freefly mode.
@export var input_freefly : String = "freefly"
@export var input_interact : String = "interact"




var mouse_captured : bool = false
var look_rotation : Vector2
var move_speed : float = 0.0
var freeflying : bool = false
var picked_obj
var pull_power
@export var popup_3D: Node3D  # Assigne ici ton menu 3D dans l'inspecteur
var menu_active = false  # Indique si le menu est actif
var currMarker

## IMPORTANT REFERENCES
@onready var head: Node3D = $Head
@onready var collider: CollisionShape3D = $Collider



func pick_object(colision, paramMarker):
	print("Objet détecté :", colision)
	

	if colision is RigidBody3D:
		picked_obj = colision
		currMarker = paramMarker
		print("Objet ramassé :", picked_obj)
		picked_obj.linear_velocity = Vector3.ZERO  # Désactive la vitesse linéaire de l'objet
		picked_obj.gravity_scale = 0  # Désactive la gravité
		picked_obj.set_collision_layer_value(1, false)
		if picked_obj is RigidBody3D and picked_obj.has_method("shoot"):
			picked_obj.is_held = true
		

		# ✅ Réinitialise l’échelle à 1 pour éviter les tailles bizarres
		picked_obj.scale = Vector3.ONE

		
func remove_object():
	if picked_obj != null:
		if picked_obj.has_method("shoot"):
			picked_obj.is_held = false
		picked_obj.gravity_scale = 1
		picked_obj.set_collision_layer_value(1, true)
		picked_obj = null
		currMarker = null



func _ready() -> void:
	check_input_mappings()
	look_rotation.y = rotation.y
	look_rotation.x = head.rotation.x
	if not InputMap.has_action("interact"):
		var new_action = InputEventKey.new()
		new_action.keycode = KEY_E  # Touche E
		InputMap.add_action("interact")
		InputMap.action_add_event("interact", new_action)

func _unhandled_input(event: InputEvent) -> void:
	# Mouse capturing
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		capture_mouse()
	if Input.is_key_pressed(KEY_ESCAPE):
		release_mouse()
	
	# Look around
	if mouse_captured and event is InputEventMouseMotion:
		rotate_look(event.relative)
	
	# Toggle freefly mode
	if can_freefly and Input.is_action_just_pressed(input_freefly):
		if not freeflying:
			enable_freefly()
		else:
			disable_freefly()

func _physics_process(delta: float) -> void:
	# If freeflying, handle freefly and nothing else
	if can_freefly and freeflying:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var motion := (head.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		motion *= freefly_speed * delta
		move_and_collide(motion)
		return
	
	# Apply gravity to velocity
	if has_gravity:
		if not is_on_floor():
			velocity += get_gravity() * delta
			

	# Apply jumping
	if can_jump:
		if Input.is_action_just_pressed(input_jump) and is_on_floor():
			velocity.y = jump_velocity

	# Modify speed based on sprinting
	if can_sprint and Input.is_action_pressed(input_sprint):
		move_speed = sprint_speed
	else:
		move_speed = base_speed

	# Apply desired movement to velocity
	if can_move:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if move_dir:
			velocity.x = move_dir.x * move_speed
			velocity.z = move_dir.z * move_speed
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed)
			velocity.z = move_toward(velocity.z, 0, move_speed)
	else:
		velocity.x = 0
		velocity.y = 0
	
	# Use velocity to actually move
	move_and_slide()
	if picked_obj != null:
	# Option simple : l'objet suit juste la position du marker
		picked_obj.global_transform.origin = marker.global_transform.origin

	# Option bonus : il suit aussi la rotation du marker (facultatif)
		picked_obj.global_transform = marker.global_transform

## Rotate us to look around.
## Base of controller rotates around y (left/right). Head rotates around x (up/down).
## Modifies look_rotation based on rot_input, then resets basis and rotates by look_rotation.
func rotate_look(rot_input : Vector2):
	look_rotation.x -= rot_input.y * look_speed
	look_rotation.x = clamp(look_rotation.x, deg_to_rad(-85), deg_to_rad(85))
	look_rotation.y -= rot_input.x * look_speed
	transform.basis = Basis()
	rotate_y(look_rotation.y)
	head.transform.basis = Basis()
	head.rotate_x(look_rotation.x)


func enable_freefly():
	collider.disabled = true
	freeflying = true
	velocity = Vector3.ZERO

func disable_freefly():
	collider.disabled = false
	freeflying = false


func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true


func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false


## Checks if some Input Actions haven't been created.
## Disables functionality accordingly.
func check_input_mappings():
	if can_move and not InputMap.has_action(input_left):
		push_error("Movement disabled. No InputAction found for input_left: " + input_left)
		can_move = false
	if can_move and not InputMap.has_action(input_right):
		push_error("Movement disabled. No InputAction found for input_right: " + input_right)
		can_move = false
	if can_move and not InputMap.has_action(input_forward):
		push_error("Movement disabled. No InputAction found for input_forward: " + input_forward)
		can_move = false
	if can_move and not InputMap.has_action(input_back):
		push_error("Movement disabled. No InputAction found for input_back: " + input_back)
		can_move = false
	if can_jump and not InputMap.has_action(input_jump):
		push_error("Jumping disabled. No InputAction found for input_jump: " + input_jump)
		can_jump = false
	if can_sprint and not InputMap.has_action(input_sprint):
		push_error("Sprinting disabled. No InputAction found for input_sprint: " + input_sprint)
		can_sprint = false
	if can_freefly and not InputMap.has_action(input_freefly):
		push_error("Freefly disabled. No InputAction found for input_freefly: " + input_freefly)
		can_freefly = false
		


func _process(delta):
	if raycast.is_colliding():
		var obj = raycast.get_collider()
		if obj and obj.is_in_group("interactable"):  # Vérifie si c'est bien l'objet interactif
					# Interaction avec la touche "E"
			if Input.is_action_just_pressed("interact"):
				if picked_obj == null:
					pick_object(obj, marker)  # Appelle la fonction pick_object si aucun objet n'est pris
				else:
					remove_object()  # Si un objet est pris, on le lâche


	# L'objet suivi par le markeR
	if picked_obj != null:
		var new_origin = marker.global_transform.origin
		var new_basis = marker.global_transform.basis.orthonormalized()
		# Applique position et rotation, mais préserve le scale
		var current_scale = picked_obj.scale
		picked_obj.global_transform = Transform3D(new_basis, new_origin)
		picked_obj.scale = current_scale
