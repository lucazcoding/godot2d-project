extends Control

onready var sprite = $Sprite
onready var amount = $amount
onready var item_name = $item_name
onready var highlight = $highlight

func _ready():	
	highlight.visible = false
	connect("focus_entered", self, "_on_focus_entered")
	connect("focus_exited", self, "_on_focus_exited")

func _on_focus_entered():
	highlight.visible = true

func _on_focus_exited():
	highlight.visible = false


func _gui_input(event):
	if event.is_action_pressed("drop_item") and sprite.texture != null:
		Inventory.remove_item(item_name.text)
		sprite.texture = null
		amount.text = ""
		item_name.text = ""
		
		
		highlight.visible = false
		focus_mode = Control.FOCUS_NONE
		
		for irmao in get_parent().get_children():
			if irmao.focus_mode == Control.FOCUS_ALL:
				irmao.grab_focus()
				break

func get_drag_data(_position):
	if sprite.texture == null:
		return null
		
	var preview = TextureRect.new()
	preview.texture = sprite.texture
	preview.expand = true
	preview.rect_size = Vector2(60, 60)
	preview.rect_position = -Vector2(30, 30)
	
	var preview_control = Control.new()
	preview_control.add_child(preview)
	set_drag_preview(preview_control)
	
	return {
		"textura": sprite.texture,
		"quantidade": amount.text,
		"nome": item_name.text,
		"slot_origem": self
	}

func can_drop_data(_position, data):
	return typeof(data) == TYPE_DICTIONARY and data.has("textura")

func drop_data(_position, data):
	if sprite.texture == data["textura"]:
		var soma = int(amount.text) + int(data["quantidade"])
		amount.text = str(soma)
		
		data["slot_origem"].sprite.texture = null
		data["slot_origem"].amount.text = ""
		data["slot_origem"].item_name.text = ""
	else:
		var temp_textura = sprite.texture
		var temp_quantidade = amount.text
		var temp_nome = item_name.text
		
		sprite.texture = data["textura"]
		amount.text = str(data["quantidade"])
		item_name.text = data["nome"]
		
		data["slot_origem"].sprite.texture = temp_textura
		data["slot_origem"].amount.text = temp_quantidade
		data["slot_origem"].item_name.text = temp_nome
		data["slot_origem"].item_name.text = temp_nome
		
	# Adicione estas linhas EXATAMENTE no final da função drop_data, fora do bloco if/else
		self.focus_mode = Control.FOCUS_ALL if self.sprite.texture != null else Control.FOCUS_NONE
		data["slot_origem"].focus_mode = Control.FOCUS_ALL if data["slot_origem"].sprite.texture != null else Control.FOCUS_NONE
