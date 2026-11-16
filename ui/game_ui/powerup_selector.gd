extends HBoxContainer
class_name PowerUpSelector


@export var button1: Button
@export var button2: Button


var player: Player

var power1: int
var power2: int


const POWER_UPS: Dictionary[int, String] = {
	0: "Attack Speed Up",
	1: "Weight Up",
	2: "Movement Speed Up",
	3: "Knockback Up",
	4: "Jump Force Up",
	5: "Additional Dashes",
	6: "Decrease Dash Cooldown",
	7: "Increase Dash Distance",
}


@rpc("any_peer", "call_local", "reliable")
func offer_power_up() -> void:
	player = get_node("../../Players/" + str(MultiplayerHandler.tube_client.peer_id))

	visible = true

	var idx1 = randi() % POWER_UPS.keys().size()
	var idx2 = randi() % POWER_UPS.keys().size()

	while idx2 == idx1 and POWER_UPS.keys().size() > 1:
		idx2 = randi() % POWER_UPS.keys().size()
	
	button1.text = POWER_UPS[idx1]
	power1 = idx1
	button2.text = POWER_UPS[idx2]
	power2 = idx2

func _select_power_1() -> void:
	set_power(power1)

func _select_power_2() -> void:
	set_power(power2)

func set_power(power_id: int) -> void:
	visible = false
	match power_id:
		0:
			player.attack_cooldown *= .9
			return
		1:
			player.mass *= 1.5
			return
		2:
			player.target_speed *= 1.25
			player.pid._p *= 1.25
			return
		3:
			player.knockback_impulse *= 1.25
			return
		4:
			player.jump_force *= 1.25
			return
		5:
			player.max_dashes += 1
			player.num_dashes = player.max_dashes
			return
		6:
			player.dash_cooldown *= .9
			return
		7:
			player.dash_impulse *= 1.1
			return
		_:
			print("error")
