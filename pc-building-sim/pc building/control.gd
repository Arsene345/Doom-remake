extends Control

func _ready():
	visible = false  # Caché au début

	# Vérifier si les boutons existent
	print($"Panel/VBoxContainer/Processeur")  # Doit afficher [NodePath:...]
	print($"Panel/VBoxContainer/Carte_Mère")
	print($"Panel/VBoxContainer/RAM")
	print($"Panel/VBoxContainer/Fermer")

	# Connecte les boutons aux fonctions 
	if $Panel/VBoxContainer/Processeur:
		$Panel/VBoxContainer/Processeur.connect("pressed", _on_processeur_selected)
	if $Panel/VBoxContainer/Carte_Mère:
		$Panel/VBoxContainer/Carte_Mère.connect("pressed", _on_carte_mere_selected)
	if $Panel/VBoxContainer/RAM:
		$Panel/VBoxContainer/RAM.connect("pressed", _on_ram_selected)
	if $Panel/VBoxContainer/Fermer:
		$Panel/VBoxContainer/Fermer.connect("pressed", _on_close_pressed)

# Fonctions appelées quand un bouton est cliqué
func _on_processeur_selected():
	print("Processeur sélectionné")

func _on_carte_mere_selected():
	print("Carte Mère sélectionnée")

func _on_ram_selected():
	print("RAM sélectionnée")

func _on_close_pressed():
	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  # Rebloque la souris
