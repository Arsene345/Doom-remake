extends Area3D

@export var popup: Control  # Référence à la popup
@export var panel_3D: Node3D 
var test: bool
@export var object_to_pick: RigidBody3D  # L'objet qu'on veut que le joueur ramasse automatiquement
# Connexion du signal dans _ready()
func _ready():
	# Connecte le signal `body_entered` à la méthode _on_body_entered
	self.connect("body_entered", Callable(self, "_on_body_entered"))
	
	#Vérifie si la popup est assignée
	if panel_3D:
		print("La popup est assignée.")
		var close_button = panel_3D.get_node("SubViewport/GUI/Panel/VBoxContainer/Fermer")
		if close_button:
			close_button.connect("pressed", Callable(self, "_on_close_pressed"))
		else:
			print("Erreur : Le bouton 'Fermer' n'a pas été trouvé.")
	else:
		print("Erreur : 'popup' n'est pas assignée.")


# La méthode qui est appelée lorsque le corps entre dans la zone
func _on_body_entered(body):
	if body.is_in_group("player"):
		if object_to_pick:
			body.pick_object(object_to_pick, body.marker)  # <- on passe bien l'objet à ramasser
		else:
			print("⚠️ Aucun objet à ramasser n’est défini !")
# Fonction pour fermer la popup (cacher la fenêtre)
func _on_close_pressed():
	test=false;
	
	if popup:
		popup.hide()  # Cache la popup
		print("La fenêtre a été fermée.")
		
