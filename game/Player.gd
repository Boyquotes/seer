extends CharacterBody2D

@export var speed : int
@onready var anim = $AnimationTree
@onready var detector = $Detector

@export var active = true
var facing_dir = Vector2(0,1)
var target_node

func _ready():
	detector.body_entered.connect(detect)
	detector.body_exited.connect(left)

func _physics_process(_delta):
	if(active):
		var input_dir = Input.get_vector("left", "right", "up", "down")
		velocity = input_dir * speed
		
		move_and_slide()
		
		if(velocity == Vector2.ZERO): #Animation setting
			if(input_dir != Vector2.ZERO):
				anim.set("parameters/Idle/blend_position", input_dir)
				facing_dir = input_dir
			anim.get("parameters/playback").travel("Idle")
		else:
			facing_dir = input_dir
			anim.set("parameters/Idle/blend_position", input_dir)
			anim.set("parameters/Move/blend_position", input_dir)
			anim.get("parameters/playback").travel("Move")
		
		if(Input.is_action_just_pressed("interact")): #Raycasting
			move_detector()
			if target_node is AnimatableBody2D: #for NPC
				print("Interacting NPC")
				target_node.on_interact()
				anim.get("parameters/playback").travel("Idle")
			if target_node is StaticBody2D: #for environment
				print("Interacting object")
				target_node.on_interact()
				anim.get("parameters/playback").travel("Idle")

func move_detector():
	var target_space = Vector2.ZERO
	if(facing_dir.x > 0):
		target_space = Vector2(24,15)
	if(facing_dir.x < 0):
		target_space = Vector2(-24,15)
	if(facing_dir.y > 0):
		target_space = Vector2(0,40)
	if(facing_dir.y < 0):
		target_space = Vector2(0,-10)
	detector.set(("position"), target_space)

func detect(entered_node):
	target_node = entered_node
	print(target_node)
	return target_node

func left(_node):
	target_node = null

func player_activated(state):
	active = state