extends Control
const NumberLabelScene = preload("res://misc/NumberLabel.tscn")

var colors = {
	solutions = Color(0.065918, 0.84375, 0),
	mid = Color(0.921875, 1, 0),
	ends = Color(0.097229, 0.380701, 0.921875),
	
	search_ends = Color(1, 0.609375, 0),
	temp_elimiated = Color(1, 0.570313, 0.640808),
	elimiated = Color(0.707031, 0.085617, 0.085617),
	unsearched = Color(0.925781, 0.925781, 0.925781),
	
}
var numbers: Array = []

onready var GridContainerNode = $HBoxContainer/VBoxContainer2/CenterContainer/GridContainer
onready var PartOneButton = $HBoxContainer/VBoxContainer/PartOneButton
onready var PartTwoButton = $HBoxContainer/VBoxContainer/PartTwoButton
onready var LabelNode = $HBoxContainer/VBoxContainer2/Label
onready var file = File.new()
onready var PartOne = PartOneClass.new()
onready var PartTwo = PartTwoClass.new()

func _ready():
	file.open("res://input.txt", File.READ)
	
	for line in file.get_as_text().split("\n"):
		numbers.append(int(line))
	numbers.sort()
	
	for n in numbers:
		var label = NumberLabelScene.instance()
		label.modulate = colors.unsearched
		label.text = "%d" % n
		GridContainerNode.add_child(label)
	
	
	part_one(numbers)
	part_one_map(numbers)
	part_two(numbers)
	PartOneButton.connect("pressed", self, "_on_part_one_button_pressed")
	PartTwoButton.connect("pressed", self, "_on_part_two_button_pressed")

func _on_part_one_button_pressed():
	var coroutine = PartOne.run(numbers)
	while coroutine is GDScriptFunctionState and coroutine.is_valid():
		var children = GridContainerNode.get_children()
		for i in range(len(children)):
			if i == PartOne.a_i:
				children[i].modulate = colors.solutions
				
			elif i < PartOne.a_i:
				children[i].modulate = colors.elimiated
			
			elif i < PartOne.start:
				children[i].modulate = colors.temp_elimiated
				
			elif i == PartOne.start:
				children[i].modulate = colors.search_ends
				
			elif i == PartOne.mid:
				children[i].modulate = colors.mid
				
			elif i == PartOne.end:
				children[i].modulate = colors.search_ends
				
			elif i > PartOne.end:
				children[i].modulate = colors.temp_elimiated
			
			else:
				children[i].modulate = colors.unsearched
		
		LabelNode.text = "A + B = %d + %d = %d" % [PartOne.a, PartOne.b, PartOne.sum]
		yield(get_tree().create_timer(0.25), "timeout")
		coroutine = coroutine.resume()
	
	LabelNode.text = "A + B = %d + %d = %d" % [PartOne.a, PartOne.b, PartOne.sum]
	GridContainerNode.get_child(PartOne.solution).modulate = colors.solutions

func _on_part_two_button_pressed():
	var coroutine = PartTwo.run(numbers)
	while coroutine is GDScriptFunctionState and coroutine.is_valid():
		coroutine = coroutine.resume()
		var children = GridContainerNode.get_children()
		for i in range(len(children)):
			if i == PartTwo.start:
				children[i].modulate = colors.solutions
			
			elif i == PartTwo.end:
				children[i].modulate = colors.solutions
				
			elif i == PartTwo.b_start:
				children[i].modulate = colors.search_ends
				
			elif i == PartTwo.b_end:
				children[i].modulate = colors.search_ends
				
			elif i == PartTwo.mid:
				children[i].modulate = colors.mid
			
			elif i < PartTwo.start:
				children[i].modulate = colors.elimiated
			
			elif i > PartTwo.end:
				children[i].modulate = colors.elimiated
			
			elif i < PartTwo.b_start:
				children[i].modulate = colors.temp_elimiated
				
			elif i > PartTwo.b_end:
				children[i].modulate = colors.temp_elimiated
			
			else:
				children[i].modulate = colors.unsearched
		
		LabelNode.text = "A + B + C = %d + %d + %d = %d" % [PartTwo.a, PartTwo.b, PartTwo.c, PartTwo.sum]
		yield(get_tree().create_timer(0.25), "timeout")
		coroutine = coroutine.resume()
		
	GridContainerNode.get_child(PartTwo.solution).modulate = colors.solutions
	
func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_ESCAPE and !event.is_pressed():
			get_tree().quit()

class PartOneClass extends Resource:
	var a_i
	var a
	var b
	
	var start
	var end
	var mid
	var solution
	var sum
	
	func run(list):
		
		for i in range(len(list)):
			a_i = i
			start = i
			end = len(list) - 1
			mid = (start + end) / 2
			a = list[start]
			b = list[mid]
			sum = a + b
			yield()
			
			while start <= end:
				mid = (start + end) / 2
				b = list[mid]
				sum = a + b
				yield()
				if sum == 2020:
					solution = mid
					print("%d %d %d" % [a, b, (a * b)])
					return
				elif sum < 2020:
					start = mid + 1
				else:
					end = mid - 1

class PartTwoClass extends Resource:
	var start
	var end
	var b_start
	var b_end
	var mid
	var solution
	var a
	var b
	var c
	var sum
	
	func run(list):
		start = 0
		end = len(list) - 1
		
		while start <= end:
			a = list[start]
			c = list[end]
			b_start = start
			b_end = end
			mid = (b_start + b_end) / 2
			b = list[mid]
			yield()
			var state = 0
			
			while b_start <= b_end:
				mid = (b_start + b_end) / 2
				b = list[mid]
				sum = a + b + c
				yield()
				
				if sum == 2020:
					solution = mid
					print("%d %d %d %d" % [a, b, c, a * b * c])
					return
				elif sum < 2020:
					b_start = mid + 1
					state = -1
				else:
					b_end = mid - 1
					state = 1
			
			match state:
				-1:
					start += 1
				1:
					end -= 1
			
func part_one_map(list):
	var lookup_table = {}
	for n in list:
		lookup_table[n] = 2020 - n
		
	for n in list:
		var val = lookup_table[n]
		if lookup_table.has(val):
			print("%d + %d = %d (hash: %d)" % [n, val, val + n, val * n])
		
func part_one(list):
	for i in range(len(list)):
		print(i)
		var start = i
		var end = len(list) - 1
		var a = list[start]
		
		# Binary search for the value.
		while start <= end:
			var mid = (start + end) / 2
			var b = list[mid]
			var sum = a + b
			if sum == 2020:
				print("%d %d %d" % [a, b, (a * b)])
				return
			elif sum < 2020:
				start = mid + 1
			else:
				end = mid - 1

func part_two(list):
	var start = 0
	var end = len(list) - 1
	
	while start <= end:
		var a = list[start]
		var c = list[end]
		var b_start = start
		var b_end = end
		var state = 0
		
		# Use a modified binary search, this search uses `state` to tell the 
		# outer loop whether it ended high or low. if it ends low, the start
		# is incermented. If it ends high, move the `end` is decermented.
		# Binary search should let this run in n * log(n) time.
		while b_start <= b_end:
			var mid = (b_start + b_end) / 2
			var b = list[mid]
			var sum = a + b + c
			if sum == 2020:
				print("%d %d %d %d" % [a, b, c, a * b * c])
				return
			elif sum < 2020:
				b_start = mid + 1
				state = -1
			else:
				b_end = mid - 1
				state = 1
		
		match state:
			-1:
				start += 1
			1:
				end -= 1




