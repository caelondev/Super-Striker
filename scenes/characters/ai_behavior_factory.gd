class_name AIBehaviorFactory

var roles : Dictionary

func _init() -> void:
	roles = {
		Player.Role.GOALIE: AIBehaviorGoalie,
		Player.Role.MIDFIELD: AIBehaviorField,
		Player.Role.OFFENSE: AIBehaviorField, #temp behavior
		Player.Role.DEFENSE: AIBehaviorField, #temp behavior
	}

func get_ai_behavior(role: Player.Role) -> AIBehavior:
	assert(roles.has(role))
	return roles.get(role).new()
