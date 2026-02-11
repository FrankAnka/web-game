extends Area2D
	
func _on_body_entered(body: Node2D) -> void:
	print("entered")
	if body.is_in_group("player"):
		body.money+=1
		print(body.money)

		queue_free()
