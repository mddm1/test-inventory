
extends Control
class_name InventoryHandler

@export var PlayerBody:CharacterBody3D
@export_flags_3d_physics var CollisionMask: int

@export var ItemSlotsCount: int = 20
@export var InventoryGrid: GridContainer
@export var InventorySlotPrefab: PackedScene = preload("res://INVEN_system/Inventory/inventory_slot.tscn")

var InventorySlots: Array[InventorySlot] = []
var EquippedSlot: int = -1

func _ready() -> void:
	for i in ItemSlotsCount:
		var slot = InventorySlotPrefab.instantiate() as InventorySlot
		InventoryGrid.add_child(slot)
		slot.InventorySlotID = i
		#inventory slot emits signal
		slot.OnItemDropped.connect(ItemDroppedOnSlot.bind()) #AICI SE CONECTEAZA
		#what is this?
		slot.OnItemEquipped.connect(ItemEquipped.bind()) #AICI SE CONECTEAZA
		InventorySlots.append(slot)
		



func PickupItem(item: ItemData):
	var foundSlot:bool = false
	for slot in InventorySlots:
		print(item," >>>>item")
		if !slot.SlotFilled:
			slot.FillSlot(item, false)
			foundSlot = true# here was the problem this was not here
			break
	#AICI E PROBLEMA - DACA NU GASESTE SLOT SE INSTACIAZA AUTOMAT
	if !foundSlot:
		var newItem = item.ItemModelPrefab.instantiate() as Node3D
		PlayerBody.get_parent().add_child(newItem)
		newItem.global_position = PlayerBody.global_position + Vector3(0,0,1) #PlayerBody.global_transform.basis.x * 2.0
	




func ItemEquipped(slotID:int):
	if EquippedSlot != -1:
		InventorySlots[EquippedSlot].FillSlot(InventorySlots[EquippedSlot].SlotData, false)
	if slotID != EquippedSlot and InventorySlots[slotID].SlotData != null:
		InventorySlots[slotID].FillSlot(InventorySlots[EquippedSlot].SlotData, true)
		EquippedSlot = slotID
	else:
		EquippedSlot = -1


func ItemDroppedOnSlot(fromSlotID:int, toSlotID:int):
	if EquippedSlot != -1:
		if EquippedSlot == fromSlotID:
			EquippedSlot = toSlotID
		elif EquippedSlot == toSlotID:
			EquippedSlot = fromSlotID
	var toSlotItem = InventorySlots[toSlotID].SlotData
	var fromSlotItem = InventorySlots[fromSlotID].SlotData
	InventorySlots[toSlotID].FillSlot(fromSlotItem, EquippedSlot==toSlotID)#this exchange the item in
	InventorySlots[fromSlotID].FillSlot(toSlotItem, EquippedSlot==fromSlotID)#slot inventory grid



func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data["Type"] == "Item"



func _drop_data(at_position: Vector2, data: Variant) -> void:
	if EquippedSlot == data["ID"]:
		EquippedSlot = -1
	var newItem = InventorySlots[data["ID"]].SlotData.ItemModelPrefab.instantiate() as Node3D
	InventorySlots[data["ID"]].FillSlot(null, false)
	PlayerBody.get_parent().add_child(newItem)
	newItem.global_position = GetWorldMousePosition()
	
	
func GetWorldMousePosition(): #drop the item where the mouse is
	var mousePos = get_viewport().get_mouse_position()
	var cam = get_viewport().get_camera_3d()
	#POSITION IN 3D SPACE WHERE OUT MOUSE IS ON THE SCREEN OMG YESSSS
	var ray_start = cam.project_ray_origin(mousePos) #there is a function that raycasts wow
	var ray_end = ray_start + cam.project_ray_normal(mousePos) * cam.global_position.distance_to(PlayerBody.global_position * 2.0) # times 2?
	var world3d:World3D = PlayerBody.get_world_3d() # wtf is this?
	var space_state = world3d.direct_space_state
	
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end, CollisionMask) #WTF IS THIS
	var results = space_state.intersect_ray(query)
	if results:
		return results["position"] as Vector3 + Vector3(0.0, 0.5, 0.0)
	else:
		return ray_start.lerp(ray_end, 0.5) + Vector3(0.0, 0.5, 0.0)

#it fucking works and id have never done by muself damn
#part 4 FIRAR SA FIE IT IS A MESS!
	
	

	
