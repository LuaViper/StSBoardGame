class_name CardGroup

var _cards = []
var node

func get_cards():
	return _cards

func is_empty():
	return _cards.is_empty()

func append(card:AbstractCard)->void:
	_cards.append(card)

func back()->AbstractCard:
	return _cards.back()

func has(card:AbstractCard):
	return _cards.has(card)

func erase(card:AbstractCard)->void:
	_cards.erase(card)
