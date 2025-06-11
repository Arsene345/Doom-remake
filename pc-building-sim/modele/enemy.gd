extends CharacterBody3D

@export var speed := 3.0
@export var player_path := NodePath()
@export var health := 20
@export var has_gravity := true

@onready var anim_player = $characterMedium/AnimationPlayer
@onready var player = get_node(player_path)
@onready var nav_agent = $NavigationAgent3D as NavigationAgent3D

func _ready():
	call_deferred("_init_nav_agent")

func _init_nav_agent():
	# Attend 1 frame pour que la navigation soit prête
	await get_tree().physics_frame
	if player:
		nav_agent.target_position = player.global_transform.origin

func _physics_process(delta):
	if not player:
		return

	# Appliquer la gravité
	if has_gravity:
		velocity += get_gravity() * delta

	# Mettre à jour la cible
	nav_agent.target_position = player.global_transform.origin

	# Récupérer la prochaine position à suivre
	var next_point = nav_agent.get_next_path_position()

	# Déplacer horizontalement vers le joueur
	var dir = (Vector3(next_point.x, global_transform.origin.y, next_point.z) - global_transform.origin).normalized()
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed

	# Jouer l’animation run si actif
	if anim_player and not anim_player.is_playing():
		anim_player.play("run")

	# Appliquer le mouvement (inclut gravité)
	move_and_slide()
func take_damage(amount):
	health -= amount
	if health <= 0:
		die()

func die():
	queue_free()
