extends Control

@onready var restart_button : Button = $Restart
@onready var continue_button : Button = $Continue
@onready var quit_button : Button = $Quit

@onready var win_text : Label = $Win
@onready var lose_text : Label = $Lose

func _ready() -> void:
	visible = false
	win_text.visible = false
	lose_text.visible = false
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	#get_tree().paused = true

func _process(delta: float) -> void:
	if Input.is_action_just_pressed('menu'):
		visible = !visible
		
		if visible:
			#continue_button.visible = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else: 
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
		get_tree().paused = bool(visible)

func show_win():
	visible = true
	win_text.visible = true
	lose_text.visible = false
	continue_button.visible = false

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true

func show_lose():
	visible = true
	win_text.visible = false
	lose_text.visible = true
	continue_button.visible = false

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
	
func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_continue_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false
	visible = false

func _on_quit_pressed() -> void:
	get_tree().quit()
