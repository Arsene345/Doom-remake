extends RigidBody3D

@export var damage: int = 10
@export var range: float = 100.0
@export var spread_degrees: float = 0.5
@export var ammo_max: int = 10
var is_held: bool = false  # Devient true quand l'arme est ramassée
var ammo: int = ammo_max

@onready var muzzle = $scene/Marker3D
@onready var audio = $scene/AudioStreamPlayer3D
@onready var cooldown = $scene/cooldown  # Assure-toi que ce chemin est correct
@onready var animation_player = $scene/AnimationPlayer  # Corrigé ici, ajouté espace après =
@onready var smoke_particles =$scene/Marker3D/GPUParticles3D

func _ready():
	cooldown.connect("timeout", Callable(self, "_on_cooldown_timeout"))

func _on_cooldown_timeout():
	cooldown.stop()
	print("Cooldown terminé, prêt à tirer.")

func _input(event):
	if(is_held):
		if event.is_action_pressed("shoot"):
			if cooldown.is_stopped() and ammo > 0:
				shoot()
				animation_player.play("fir")
			elif ammo <= 0:
				print("Plus de munitions !")
		if event.is_action_pressed("reload"):
			ammo=ammo_max

func shoot():
	smoke_particles.restart()  # relance la fumée (One Shot activé)
	cooldown.start()
	ammo -= 1
	audio.play()
	print("Tir ! Munitions restantes :", ammo)

	# reste du code pour tirer…


	var spread_x = deg_to_rad(randf_range(-spread_degrees, spread_degrees))
	var spread_y = deg_to_rad(randf_range(-spread_degrees, spread_degrees))

	var direction = -muzzle.global_transform.basis.z
	direction = direction.rotated(Vector3.UP, spread_x)
	direction = direction.rotated(Vector3.RIGHT, spread_y)

	var from = muzzle.global_transform.origin
	var to = from + direction * range

	var query = PhysicsRayQueryParameters3D.new()
	query.from = from
	query.to = to
	query.exclude = [self]  # Exclure ce corps rigide

	var result = get_world_3d().direct_space_state.intersect_ray(query)

	if result and result.has("collider"):
		var hit = result.collider
		# Ignorer si c'est le player
		if hit.is_in_group("player"):
			print("Raycast a touché le player, ignoré.")
			return
		print("Touché :", hit.name)
		if hit.has_method("take_damage"):
			hit.take_damage(damage)
