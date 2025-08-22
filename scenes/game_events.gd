extends Node

signal ball_carried(carrier_name: String)
signal ball_freeform()
signal game_over(country_winner: String)
signal impact_received(impact_position: Vector2, is_high_impact: bool)
signal player_ready()
signal ready_for_kickoff()
signal start_kickoff()
signal score_changed()
signal team_reset()
signal team_scored(team: String)
