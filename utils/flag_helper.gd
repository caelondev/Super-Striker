class_name FlagHelper

static var flag_texture : Dictionary[String, Texture] = {}

static func get_texture(country: String) -> Texture2D:
	if not flag_texture.has(country):
		flag_texture.set(country, load("res://assets/art/ui/flags/flag-%s.png" % [country.to_lower()]))
	return flag_texture[country]
