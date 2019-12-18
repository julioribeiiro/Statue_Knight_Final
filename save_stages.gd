extends Node2D

var stage = 1


var save_path = "res://save-file.cfg"
var config = ConfigFile.new()
var load_response = config.load(save_path)

func saveStage(section, key):
	config.set_value(section, key, stage)
	config.save(save_path)

func loadStage(section, key):
	stage = config.get_value(section, key, stage)


