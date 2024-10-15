extends Area3D

signal OnItemPickedUp(item)

@export var ItemTypes: Array[ItemData] = []

var NearbyBodies: Array[InteractableItem] #de ce avem nevoie de asta?




func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		pickup_nearest_item()



func pickup_nearest_item():
	var nearest_item: InteractableItem = null
	var nearest_item_distance:float = INF #wow exista infinit bai 99999
	for item in NearbyBodies:
		if item.global_position.distance_to(global_position) < nearest_item_distance:
			nearest_item_distance = item.global_position.distance_to(global_position)
			nearest_item = item
		if nearest_item != null:
			nearest_item.queue_free()
			NearbyBodies.remove_at(NearbyBodies.find(nearest_item))
			
			var item_prefab = nearest_item.scene_file_path
			for i in ItemTypes.size():
				if ItemTypes[i].ItemModelPrefab != null and ItemTypes[i].ItemModelPrefab.resource_path == item_prefab:
					print("item id: " + str(i) + "item name: " + ItemTypes[i].ItemName)
					OnItemPickedUp.emit(ItemTypes[i])
					return
			printerr("item not found wow")










#body enters area, daca e interactive focus + bagat in array
func OnObjectEnteredArea(body: Node3D):
	if body is InteractableItem:
		body.gain_focus()
		NearbyBodies.append(body)


#body iasa din area - fara focus + scos din array
func OnObjectExitedArea(body: Node3D):
	if body is InteractableItem and NearbyBodies.has(body):
		body.lose_focus()
		NearbyBodies.remove_at(NearbyBodies.find(body))










#4.44 part 1 done
#0:40 part 2 done
#0.02 part 3
#part 4 done but BUGGY FUCK SHIT
