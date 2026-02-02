extends CanvasLayer

@onready var health_label: Label = $VBoxContainer/HealthLabel
@onready var stamina_label: Label = $VBoxContainer/StaminaLabel
@onready var mana_label: Label = $VBoxContainer/ManaLabel

func update_health(current: int, max_val: int) -> void:
	health_label.text = "Health: %d / %d" % [current, max_val]

func update_stamina(current: float, max_val: float) -> void:
	stamina_label.text = "Stamina: %.1f / %.1f" % [current, max_val]

func update_mana(current: float, max_val: float) -> void:
	mana_label.text = "Mana: %d / %d" % [int(current), int(max_val)]
