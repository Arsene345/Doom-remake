extends RayCast3D

# Positionner le raycast à la position de la caméra
raycast.global_position = camera.global_position
# Définir la direction du raycast pour qu'il pointe vers l'avant de la caméra
raycast.cast_to = camera.global_transform.basis.z * -10  # -10 pour ajuster la longueur du rayon
