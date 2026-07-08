class_name CharacterTargetDecision extends AbstractDecision

#TODO: enums are apparently difficult to mod; consider changing these to classes
enum target_types { ENEMY, ENEMY_ROW, PLAYER }

var target_type
var target
