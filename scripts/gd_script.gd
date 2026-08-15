extends CSGBox3D

# @export var hp : int  = 100
# var damage : float = 2.5
# var text : String = "zero"
# var is_text : bool = true
# var player # тоже самое что var player : Variant

# var test : bool = true

# var ver2 = Vector2(10, 5)
# var ver3 = Vector3(10, 5, 15)


# var obj : Dictionary = {
# 	"name": "Denis",
# 	"age": 25
# }

# enum State {
# 	IDLE, # 0
# 	RUN, # 1
# 	RUNING, # 2
# 	JUMP # 3
# } 

# var list1 : Array = ["hello world", 15, null]
# var list2 : Array[int] = [10, 15, 4]
# var list3 : Array [int] = list2

# const SPEED : float = 5

# func _ready() -> void:
# 	print(hp)

# 	print("condition()")
# 	condition()

# 	print("cycles()")
# 	cycles()

# 	print("END")

# func _process(delta: float) -> void:
# 	pass

# func condition() -> void:
# 	if hp >= 75:
# 		print("FULL HP " + str(hp))
# 	elif hp >= 25:
# 		print("HALF HP " + str(hp))
# 	else:
# 		print("LOW HP " + str(hp))

# 	print(text)
# 	var text = "hi" if is_text else "bay"
# 	print(text)

# 	var state : String = "idle"
	
# 	match state:
# 		"idle":
# 			print("Idle")
# 		"run", "runing":
# 			print("Run")
# 		"jump":
# 			print("Jump")
# 		_:
# 			print("Null")

# func cycles() -> void:
# 	var try = 0

# 	while try < 5:
# 		print(try)
# 		try += 1

# 	for i in range(5):
# 		print(1)

# 	for key in obj:
# 		print(key + " " + str(obj[key]))

var is_player : bool = true 


func _ready() -> void:
	is_player = 0
	print(is_player, typeof(is_player), type_string(typeof(is_player)))