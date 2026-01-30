class_name AbstractPlayer

var hand = []
var draw_pile = []
var discard_pile = []
var exhaust_pile = []
var powers = []

# The stack of cards created when you quickly drag multiple cards past the drop line.
var queue_stack = []
# The stack of cards actually being played. Should only contain one card at a time plus copies and triggered cards (e.g. Havoc)
var playing_stack = []

var reward_pile = []
var rare_reward_pile = []
var removed_pile = []
