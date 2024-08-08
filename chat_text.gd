extends Control
#see https://ai.google.dev/tutorials/rest_quickstart

var api_key = ""
var http_request
var conversations = []
var history = []
var historyBox : TextEdit
var last_user_prompt
var model = "v1beta/models/gemini-1.5-pro-latest"
func _ready():
	var settings = JSON.parse_string(FileAccess.get_file_as_string("res://settings.json"))
	if not settings:
		get_tree().change_scene("res://main.tsn")
	api_key = settings.api_key
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", _on_request_completed)
	historyBox = find_child("HistText")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#func _get_option_selected_text(key):
	#var option = find_child(key+"OptionButton")
	#var text = option.get_item_text(option.get_selected_id())
	#return  text
#
#func read_settings_file():
	#var file_path = "res://settings.json"
	#var file = FileAccess.open(file_path, FileAccess.READ)
#
	#if file == null:
		#print("Erro ao abrir o arquivo: ", file_path)
		#get_tree().change_scene_to_file("res://main.tscn")
		#
	#var content = ""
	#while not file.eof_reached():
		#content += file.get_line()
	#file.close()
	#
	#var settings = {}
	#content = JSON.parse_string(content)
	#print(content)
	#if !content:
		#print("Erro ao analisar JSON")
		#get_tree().change_scene_to_file("res://main.tscn")
	#
	#settings = content
	#return settings
	
func _on_send_button_pressed():
	find_child("SendButton").disabled = true
	var input = find_child("InputEdit").text
	_request_chat(input)

func _request_chat(prompt):
	# var url = "https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=%s"%api_key
	var url = "https://generativelanguage.googleapis.com/%s:generateContent?key=%s"%[model,api_key]
	
	var contents_value = []
	for conversation in conversations:
		contents_value.append({
			"role":"user",
			"parts":[{"text":conversation["user"]}]
		})
		contents_value.append({
			"role":"model",
			"parts":[{"text":conversation["model"]}]
		})
		
	contents_value.append({
			"role":"user",
			"parts":[{"text":prompt}]
		})
	var body = JSON.stringify({
		"contents":contents_value
		,# basically useless,just they say 'I cant talk about that.'
		"safety_settings":[
			{
			"category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
			"threshold": "BLOCK_ONLY_HIGH",
			},
			{
			"category": "HARM_CATEGORY_HATE_SPEECH",
			"threshold": "BLOCK_ONLY_HIGH",
			},
			{
			"category": "HARM_CATEGORY_HARASSMENT",
			"threshold": "BLOCK_ONLY_HIGH",
			},
			{
			"category": "HARM_CATEGORY_DANGEROUS_CONTENT",
			"threshold": "BLOCK_ONLY_HIGH",
			},
			]
	})
	last_user_prompt = prompt
	print("send-content"+str(body))
	var error = http_request.request(url, ["Content-Type: application/json"], HTTPClient.METHOD_POST, body)
	
	if error != OK:
		push_error("requested but error happen code = %s"%error)
		get_tree().change_scene("res://main.tsn")

func _set_label_text(key,text):
	var label = find_child(key)
	if text == "HIGH":
		label.get_label_settings().set_font_color(Color(1,0,0,1))
	else:
		label.get_label_settings().set_font_color(Color(1,1,1,1))
	label.text = text
	
func _on_request_completed(result, responseCode, headers, body):
	find_child("SendButton").disabled = false
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	print("response")
	print(response)
	
	if response == null:
		print("response is null")
		find_child("FinishedLabel").text = "No Response"
		find_child("FinishedLabel").visible = true
		return
	
	
	if response.has("promptFeedback"):
		var ratings = response.promptFeedback.safetyRatings
		for rate in ratings:
			match rate.category:
				"HARM_CATEGORY_SEXUALLY_EXPLICIT":
					_set_label_text("SexuallyExplicitStatus",rate.probability)
					
				"HARM_CATEGORY_HATE_SPEECH":
					_set_label_text("HateSpeechStatus",rate.probability)
					
				"HARM_CATEGORY_HARASSMENT":
					_set_label_text("HarassmentStatus",rate.probability)
					
				"HARM_CATEGORY_DANGEROUS_CONTENT":
					_set_label_text("DangerousContentStatus",rate.probability)
					
	
	if response.has("error"):
		find_child("FinishedLabel").text = "ERROR"
		find_child("FinishedLabel").visible = true
		find_child("ResponseEdit").text = str(response.error)
		#maybe blocked
		return
	
	#No Answer
	if !response.has("candidates"):
		find_child("FinishedLabel").text = "Blocked"
		find_child("FinishedLabel").visible = true
		find_child("ResponseEdit").text = ""
		#maybe blocked
		return
		
	#I can not talk about
	if response.candidates[0].finishReason != "STOP":
		find_child("FinishedLabel").text = "Safety"
		find_child("FinishedLabel").visible = true
		find_child("ResponseEdit").text = ""
	else:
		find_child("FinishedLabel").text = ""
		find_child("FinishedLabel").visible = false
		var newStr = response.candidates[0].content.parts[0].text
		find_child("ResponseEdit").text = newStr
		conversations.append({"user":"%s"%last_user_prompt,"model":"%s"%newStr})
		history = {"user":"%s"%last_user_prompt,"model":"%s"%newStr}
		_add_to_history()
	
func _add_to_history():
	historyBox.text += "User: " + history.user + "\n"
	historyBox.text += "Model: " +history.model + "\n"
	historyBox.text += "\n"
