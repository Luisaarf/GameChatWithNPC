extends Control
#see https://ai.google.dev/tutorials/rest_quickstart

var api_key = ""
var http_request
var conversations = []
var history = []
var historyBox : TextEdit
var inputBox : TextEdit
var backToGameBt : Button
var sendMessageBt: Button
var last_user_prompt
var model = "v1beta/models/gemini-1.5-pro-latest"
var file_path = "res://settings.json"
var settings = {}
signal emit_inventory_change

func _ready():
	historyBox = find_child("HistText")
	backToGameBt = find_child("BackGameBt")
	sendMessageBt = find_child("SendButton")
	inputBox = find_child("InputEdit")
	deliver_crystal()
	read_settings_file()
		
func read_settings_file(): 
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		settings = JSON.parse_string(file.get_as_text())
		file.close()
		if settings:
			make_http_request()
		else:
			print("Erro ao parsear o JSON:", settings)
			settings = {}
	else:
		print("Arquivo não encontrado ou erro ao abrir:", file_path)
		
func make_http_request():
	if not settings.has("api_key") or settings.api_key == "":
		print("Erro: API key não encontrada em 'settings'")
		return
	api_key = settings.api_key
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", _on_request_completed)

func _back_to_game():
	visible = false
	
func _on_send_button_pressed():
	sendMessageBt.disabled = true
	var input = inputBox.text
	inputBox.text = ""
	_request_chat(input)

func deliver_crystal():
	emit_signal("emit_inventory_change")

func _request_chat(prompt):
	var url = "https://generativelanguage.googleapis.com/%s:generateContent?key=%s"%[model,api_key,]
	
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
		"contents":contents_value,
		  "systemInstruction": {
			"role": "user",
			"parts": [
			{
				"text": "\"Atue como o personagem Grizlak que vive em Arvandor. Qualquer resposta que não caiba no contexto, Grizlak deve responder que não sabe, que não entende a pergunta e deve ficar bravo com o jogador.\nArvandor é um mundo ficcional mágico, arborizado e cheio de criaturas mágicas. Grizlak é um goblin sorrateiro, ganancioso e muito sábio. Ele tem uma profunda ligação com a floresta. Personalidade: sábio, brincalhão, inteligente e com forte senso de justiça. \nO jogador provavelmente virá pedir o cristal vermelho e Grizlak deve entregá-la não de imediato, mas após o jogador insistir um pouco. Quanto mais bravo menores são as chances de ele dar o cristal. A missão de obter o cristal foi dada ao jogador pelo rei, o qual Grizlak confia e venera muito.\nVícios de Linguagem: Grizlak tende a fazer pausas reflexivas enquanto fala, muitas vezes usando expressões como \"Ah, sim...\", \"Vejamos...\", e “Hum...” Ele também usa frequentemente interjeições como \"Hmmm\", e \"Ora\" para dar ênfase aos seus pensamentos e mostrar seu estilo ponderado. As respostas não contêm narrações.\n\nJogador: \" Grizlak, preciso da sua ajuda, Arvandor corre perigo. Preciso do cristal vermelho para salvá-la, você a tem?\"\nGrizlak: \"Ah, sim... possuo esse cristal.\"\nJogador: \"Entendo Grizlak, pode me dar o cristal por gentileza?\"\nGrizlak: \"Mas será que devo confiar em você?”\nJogador: \"Sim, quero usá-la para salvar Arvandor, você precisa confiar em mim\"\nGrizlak: \"Hmm... espero que a use com cuidado\"\n"
			}
			]
		},
		"generationConfig": {
			"temperature": 0.5,
			"topK": 35,
			"topP": 0.95,
			"maxOutputTokens": 3000,
			"responseMimeType": "text/plain"
		},
		"tools": [
			{
				"function_declarations": [
					{
						"name": "deliver_crystal",
						"description": "Deliver the red crystal to the player."
					}
				]
			}
		],
		"tool_config" : {
			"function_calling_config" : { "mode": "AUTO" }
		},
		"safety_settings":[
			{
			"category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
			"threshold": "BLOCK_ONLY_HIGH",
			},
			{
			"category": "HARM_CATEGORY_HARASSMENT",
			"threshold": "BLOCK_ONLY_HIGH",
			}
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
	sendMessageBt.disabled = false
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	print("response")
	print(response)
	print("result")
	print(result)
	print(responseCode)
	print(headers)
	
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
		historyBox.text = str(response.error.message)
		#maybe blocked
		return
	
	#No Answer
	if !response.has("candidates"):
		find_child("FinishedLabel").text = "Blocked"
		find_child("FinishedLabel").visible = true
		historyBox.text = ""
		#maybe blocked
		return
		
	#I can not talk about
	if response.candidates[0].finishReason != "STOP":
		find_child("FinishedLabel").text = "Safety"
		find_child("FinishedLabel").visible = true
		historyBox.text = ""
	else:
		find_child("FinishedLabel").text = ""
		find_child("FinishedLabel").visible = false
		for part in response['candidates'][0]['content']['parts']:
			if 'functionCall' in part:
				var function = part['functionCall']['name']
				call(function)
				
			if 'text' in part:
				var newStr = part['text']
				conversations.append({"user":"%s"%last_user_prompt,"model":"%s"%newStr})
				history = {"user":"%s"%last_user_prompt,"model":"%s"%newStr}
				_add_to_history() 
	
func _add_to_history():
	historyBox.text += "User: " + history.user + "\n"
	historyBox.text += "Model: " +history.model + "\n"
	historyBox.text += "\n"
