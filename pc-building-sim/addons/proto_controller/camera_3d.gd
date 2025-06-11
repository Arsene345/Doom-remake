
extends Camera3D  # Si tu attache le script à la caméra ou à un nœud contenant la caméra
@export var popup: Node3D  # Ou peut-être un type plus spécifique comme Panel3D si c'est une fenêtre spécifique.
@export var raycast: RayCast3D  # RayCast3D pour détecter les objets en face

@export var button1: MeshInstance3D  # Le premier bouton
@export var button2: MeshInstance3D  # Le deuxième bouton
@export var button3: MeshInstance3D  # Le troisième bouton
@export var close_button: MeshInstance3D  # Le bouton "Fermer"

var button_material : Material  # Matériau des boutons
var highlight_material : Material  # Matériau de survol pour les boutons

func _ready():
	# Vérifier si le raycast et les boutons sont assignés
	if raycast == null or button1 == null or button2 == null or button3 == null or close_button == null:
		print("Erreur : Assurez-vous que tous les éléments sont assignés.")
		return
	
	# Créer les matériaux pour les boutons
	button_material = button1.get_surface_material(0)  # Utilise le matériau du bouton
	

	# Assurez-vous que le raycast est activé
	raycast.enabled = true

	# Positionner la fenêtre dans l'espace 3D
	popup.position = Vector3(0, 1, 5)  # Place la fenêtre à une distance raisonnable

	# Positionner les boutons sur la fenêtre
	button1.position = Vector3(-2, 0, 0)  # Position du premier bouton
	button2.position = Vector3(0, 0, 0)  # Position du deuxième bouton
	button3.position = Vector3(2, 0, 0)  # Position du troisième bouton
	close_button.position = Vector3(0, -1, 0)  # Bouton de fermeture (en dessous)

# Fonction pour détecter les clics
func _process(delta):
	# Si le raycast touche un bouton, vérifier si le joueur clique
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider is MeshInstance3D:
			# Mettre en surbrillance le bouton
			_on_button_hovered(collider)

			# Vérifie si le bouton a été cliqué
			if Input.is_action_just_pressed("ui_select"):  # Le bouton gauche de la souris
				_on_button_clicked(collider)
		else:
			# Si rien n'est touché, réinitialise les boutons
			_on_button_unhovered(button1)
			_on_button_unhovered(button2)
			_on_button_unhovered(button3)
			_on_button_unhovered(close_button)

# Fonction pour gérer le survol des boutons
func _on_button_hovered(button: MeshInstance3D):
	# Change le matériau du bouton pour simuler un survol
	button.material_override = highlight_material

# Fonction pour gérer l'arrêt du survol des boutons
func _on_button_unhovered(button: MeshInstance3D):
	# Réinitialise le matériau du bouton
	button.material_override = button_material

# Fonction qui est appelée lorsque le bouton est cliqué
func _on_button_clicked(button: MeshInstance3D):
	if button == button1:
		print("Bouton 1 cliqué !")
		# Implémenter l'action pour le bouton 1
	elif button == button2:
		print("Bouton 2 cliqué !")
		# Implémenter l'action pour le bouton 2
	elif button == button3:
		print("Bouton 3 cliqué !")
		# Implémenter l'action pour le bouton 3
	elif button == close_button:
		print("Fermeture de la fenêtre.")
		popup.queue_free()  # Ferme la fenêtre (ou tu peux la cacher)
