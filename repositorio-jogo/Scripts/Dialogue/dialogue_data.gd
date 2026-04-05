extends Reference
class_name DialogueData

static func get_dialogue(dialogue_id):
	var dialogues = {
		"survivor_mara": {
			"start": {
				"speaker": "Mara",
				"text": "Psiu... ainda bem. Achei que você fosse mais um deles. Você é o Ash, não é?",
				"options": [
					{"text": "O que aconteceu nesta rua?", "next": "street_info"},
					{"text": "Você tem suprimentos?", "next": "supplies"},
					{"text": "Não posso ficar. Preciso seguir.", "next": "END"}
				]
			},
			"street_info": {
				"speaker": "Mara",
				"text": "A cidade não caiu de uma vez. Foi sumindo por partes. Primeiro a energia, depois os sinais de rádio, depois as pessoas.",
				"options": [
					{"text": "Eles reagem a barulho?", "next": "noise_info"},
					{"text": "Entendi. Tem suprimentos?", "next": "supplies"},
					{"text": "Já ouvi o suficiente.", "next": "END"}
				]
			},
			"noise_info": {
				"speaker": "Mara",
				"text": "Reagem a presença e movimento. Economiza munição. Plasma é forte, mas não infinito.",
				"options": [
					{"text": "Boa dica.", "next": "supplies"},
					{"text": "Vou continuar sozinho.", "next": "END"}
				]
			},
			"supplies": {
				"speaker": "Mara",
				"text": "Toma algumas cargas de plasma e um pouco de cura.",
				"reward": {
					"ammo": 8,
					"heal": 15
				},
				"reward_once": true,
				"options": [
					{"text": "Obrigado.", "next": "after_reward"}
				]
			},
			"after_reward": {
				"speaker": "Mara",
				"text": "Se encontrar mais alguém vivo, não confie rápido demais.",
				"options": [
					{"text": "Vou lembrar disso.", "next": "END"}
				]
			}
		}
	}

	return dialogues.get(dialogue_id, {})
