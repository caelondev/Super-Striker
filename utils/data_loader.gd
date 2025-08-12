extends Node

var squads : Dictionary[String, Array]

func _init() -> void:
	var json_file = FileAccess.open("res://assets/json/squads.json", FileAccess.READ)
	if json_file == null:
		print("Error! Failed to load PlayerData JSON File.")
		return
	var json_txt = json_file.get_as_text()
	var json = JSON.new()
	if json.parse(json_txt) != OK:
		print("Could not parse squads.json")
		return
	for team in json.data:
		var country_name := team["country"] as String
		var players := team["players"] as Array
		if not squads.has(country_name):
			squads.set(country_name, [])
		for player in players:
			var full_name := player["name"] as String
			var skin = player["skin"] as Player.SkinColor
			var role = player["role"] as Player.Role
			var speed := player["speed"] as float
			var power := player["power"] as float
			var player_resources := PlayerResources.new(full_name, skin, role, speed, power)
			squads.get(country_name).append(player_resources)
		assert(players.size() == 6)
	json_file.close()

func get_squad(country: String) -> Array:
	if squads.has(country):
		return squads[country]
	return []
