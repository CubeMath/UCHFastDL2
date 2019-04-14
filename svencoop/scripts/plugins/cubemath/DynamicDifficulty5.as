// Horray! Dynamic Difficulty System
// Uses Votingsystem
// By CubeMath

final class PlayerDiffData {

	/**
	*	Players vote value
	*/
	float m_flDiffVote = -1.0;
	
	/**
	*	Players vote value
	*/
	float m_flLastVoted = 0.0;
	
	/**
	*	Players was Player Alive?
	*/
	bool m_flLastIsAlive = true;
	
	PlayerDiffData(){
		m_flDiffVote = -1.0;
		m_flLastVoted = g_Engine.time;
	}
	
	PlayerDiffData( float pDiffVote ){
		m_flDiffVote = pDiffVote;
		m_flLastVoted = g_Engine.time;
	}
}

final class Diffy {

	/**
	*	Skill-Names
	*/
	private array<string> sk_names = {
			"sk_agrunt_health",
			"sk_agrunt_dmg_punch",
			"sk_agrunt_melee_engage_distance",
			"sk_agrunt_berserker_dmg_punch",
			"sk_apache_health",
			"sk_barnacle_health",
			"sk_barnacle_bite",
			"sk_barney_health",
			"sk_bullsquid_health",
			"sk_bullsquid_dmg_bite",
			"sk_bullsquid_dmg_whip",
			"sk_bullsquid_dmg_spit",
			"sk_bigmomma_health_factor",
			"sk_bigmomma_dmg_slash",
			"sk_bigmomma_dmg_blast",
			"sk_bigmomma_radius_blast",
			"sk_gargantua_health",
			"sk_gargantua_dmg_slash",
			"sk_gargantua_dmg_fire",
			"sk_gargantua_dmg_stomp",
			"sk_hassassin_health",
			"sk_headcrab_health",
			"sk_headcrab_dmg_bite",
			"sk_hgrunt_health",
			"sk_hgrunt_kick",
			"sk_hgrunt_pellets",
			"sk_hgrunt_gspeed",
			"sk_houndeye_health",
			"sk_houndeye_dmg_blast",
			"sk_islave_health",
			"sk_islave_dmg_claw",
			"sk_islave_dmg_clawrake",
			"sk_islave_dmg_zap",
			"sk_ichthyosaur_health",
			"sk_ichthyosaur_shake",
			"sk_leech_health",
			"sk_leech_dmg_bite",
			"sk_controller_health",
			"sk_controller_dmgzap",
			"sk_controller_speedball",
			"sk_controller_dmgball",
			"sk_nihilanth_health",
			"sk_nihilanth_zap",
			"sk_scientist_health",
			"sk_snark_health",
			"sk_snark_dmg_bite",
			"sk_snark_dmg_pop",
			"sk_zombie_health",
			"sk_zombie_dmg_one_slash",
			"sk_zombie_dmg_both_slash",
			"sk_turret_health",
			"sk_miniturret_health",
			"sk_sentry_health",
			"sk_plr_crowbar",
			"sk_plr_9mm_bullet",
			"sk_plr_357_bullet",
			"sk_plr_9mmAR_bullet",
			"sk_plr_9mmAR_grenade",
			"sk_plr_buckshot",
			"sk_plr_xbow_bolt_monster",
			"sk_plr_rpg",
			"sk_plr_gauss",
			"sk_plr_egon_narrow",
			"sk_plr_egon_wide",
			"sk_plr_hand_grenade",
			"sk_plr_satchel",
			"sk_plr_tripmine",
			"sk_12mm_bullet",
			"sk_9mmAR_bullet",
			"sk_9mm_bullet",
			"sk_hornet_dmg",
			"sk_suitcharger",
			"sk_battery",
			"sk_healthcharger",
			"sk_healthkit",
			"sk_scientist_heal",
			"sk_monster_head",
			"sk_monster_chest",
			"sk_monster_stomach",
			"sk_monster_arm",
			"sk_monster_leg",
			"sk_player_head",
			"sk_player_chest",
			"sk_player_stomach",
			"sk_player_arm",
			"sk_player_leg",
			"sk_grunt_buckshot",
			"sk_babygargantua_health",
			"sk_babygargantua_dmg_slash",
			"sk_babygargantua_dmg_fire",
			"sk_babygargantua_dmg_stomp",
			"sk_hwgrunt_health",
			"sk_hwgrunt_minipellets",
			"sk_rgrunt_explode",
			"sk_massassin_sniper",
			"sk_otis_health",
			"sk_otis_bullet",
			"sk_zombie_barney_health",
			"sk_zombie_barney_dmg_one_slash",
			"sk_zombie_barney_dmg_both_slash",
			"sk_zombie_soldier_health",
			"sk_zombie_soldier_dmg_one_slash",
			"sk_zombie_soldier_dmg_both_slash",
			"sk_gonome_health",
			"sk_gonome_dmg_one_slash",
			"sk_gonome_dmg_guts",
			"sk_gonome_dmg_one_bite",
			"sk_pitdrone_health",
			"sk_pitdrone_dmg_bite",
			"sk_pitdrone_dmg_whip",
			"sk_pitdrone_dmg_spit",
			"sk_shocktrooper_health",
			"sk_shocktrooper_kick",
			"sk_shocktrooper_maxcharge",
			"sk_tor_health",
			"sk_tor_punch",
			"sk_tor_energybeam",
			"sk_tor_sonicblast",
			"sk_voltigore_health",
			"sk_voltigore_dmg_punch",
			"sk_voltigore_dmg_beam",
			"sk_voltigore_dmg_explode",
			"sk_tentacle",
			"sk_blkopsosprey",
			"sk_osprey",
			"sk_stukabat",
			"sk_sqknest_health",
			"sk_kingpin_health",
			"sk_kingpin_lightning",
			"sk_kingpin_tele_blast",
			"sk_kingpin_plasma_blast",
			"sk_kingpin_melee",
			"sk_kingpin_telefrag",
			"sk_plr_HpMedic",
			"sk_plr_wrench",
			"sk_plr_grapple",
			"sk_plr_uzi",
			"sk_556_bullet",
			"sk_plr_secondarygauss",
			"sk_hornet_pdmg",
			"sk_plr_762_bullet",
			"sk_plr_spore",
			"sk_plr_shockrifle",
			"sk_plr_shockrifle_beam",
			"sk_shockroach_dmg_xpl_touch",
			"sk_shockroach_dmg_xpl_splash",
			"sk_plr_displacer_other",
			"sk_plr_displacer_radius"
	};

	/**
	*	Skill-Borders
	*/
	private array<double> diffBorders = {
			0.0, 0.1, 0.3, 0.5, 0.7, 0.9, 1.0
	};

	/**
	*	Entities Multiplyers
	*/
	private array<array<double>> entities_multiplyer = {
			{ 0.1, 0.5, 0.75, 1.0, 2.0, 10.0, 500.0, 500.0 }, //trigger_hurt
			{ 0.01, 0.1, 0.5, 1.0, 1.5, 5.0, 100.0, 100.0 }, //trigger_hurt nerf alot
			{ 1.0, 1.0, 1.0, 1.0, 2.0, 10.0, 500.0, 500.0 }, //trigger_hurt in unescapable areas
			{ 0.5, 0.75, 0.9, 1.0, 1.1, 1.5, 2.5, 2.5 }, //slower speed
			{ 1.0, 1.0, 1.0, 1.0, 1.25, 2.0, 5.0, 10.0 }, //faster speed
			{ 0.5, 0.75, 0.9, 1.0, 1.25, 2.0, 5.0, 10.0 }, //mixed speed
			{ 1.0, 1.0, 1.0, 1.0, 0.9, 0.5, 0.0, 0.0 }, //Tank targetwait
			{ 0.5, 0.75, 0.9, 1.0, 1.25, 2.0, 5.0, 10.0 }, //Tank Firerate (Sniper/Bullets/Laser)
			{ 0.25, 0.5, 0.75, 1.0, 1.5, 3.0, 10.0, 10.0 }, //Tank Firerate (Rocket/Mortal)
			{ 0.1, 0.5, 0.9, 1.0, 2.0, 5.0, 100.0, 1000.0 }, //Tank Bullet Damage
			{ 0.5, 0.75, 0.9, 1.0, 1.1, 1.5, 2.0, 3.0 }, //iMagnitude Multiplier
			{ 600.0, 700.0, 750.0, 800.0, 800.0, 800.0, 800.0, 810.0 }, //sv_gravity
			{ 0.0, 0.0, 0.0, 0.0, 0.2, 0.6, 1.0, 1.0 }, //hard-multiply
			{ 0.25, 0.35, 0.45, 0.5, 0.75, 1.0, 1.0, 1.0 }, //silofan_changefriction
			{ 1.0, 1.0, 1.0, 1.0, 1.25, 2.0, 5.0, 6.0 }, //faster speed (psychobot) (hl_c13_a3 platforms)
			{ 0.5, 0.75, 0.9, 1.0, 1.25, 2.0, 5.0, 6.0 }, //mixed speed (hl_c13_a3 platforms)
			{ 0.01, 0.1, 0.5, 1.0, 1.0, 1.0, 0.0, 0.0 } //trigger_hurt ignore hardcore
	};
	
	/**
	*	Skill-Data
	*/
	private array<array<double>> skillMatrix = {
			{ 6.0, 30.0, 60.0, 100.0, 150.0, 225.0, 300.0, 300.0 }, // sk_agrunt_health
			{ 1.0, 5.0, 10.0, 20.0, 20.0, 100.0, 2000.0, 2000.0 }, // sk_agrunt_dmg_punch
			{ 128.0, 192.0, 224.0, 256.0, 256.0, 256.0, 256.0, 256.0 }, // sk_agrunt_melee_engage_distance
			{ 2.0, 10.0, 20.0, 30.0, 40.0, 200.0, 4000.0, 4000.0 }, // sk_agrunt_berserker_dmg_punch
			{ 15.0, 75.0, 150.0, 300.0, 500.0, 750.0, 1000.0, 1000.0 }, // sk_apache_health
			{ 2.0, 15.0, 30.0, 40.0, 50.0, 75.0, 100.0, 100.0 }, // sk_barnacle_health
			{ 8.0, 8.0, 8.0, 8.0, 10.0, 50.0, 1000.0, 1000.0 }, // sk_barnacle_bite
			{ 65.0, 65.0, 65.0, 65.0, 65.0, 65.0, 65.0, 1.0 }, // sk_barney_health
			{ 4.0, 20.0, 40.0, 80.0, 120.0, 180.0, 240.0, 240.0 }, // sk_bullsquid_health
			{ 1.5, 7.5, 15.0, 25.0, 25.0, 125.0, 2500.0, 2500.0 }, // sk_bullsquid_dmg_bite
			{ 2.5, 12.5, 25.0, 35.0, 45.0, 225.0, 4500.0, 4500.0 }, // sk_bullsquid_dmg_whip
			{ 1.0, 5.0, 10.0, 10.0, 15.0, 75.0, 1500.0, 1500.0 }, // sk_bullsquid_dmg_spit
			{ 0.1, 0.3, 0.5, 0.75, 1.0, 1.0, 1.0, 1.0 }, // sk_bigmomma_health_factor
			{ 5.0, 25.0, 50.0, 60.0, 70.0, 350.0, 7000.0, 7000.0 }, // sk_bigmomma_dmg_slash
			{ 10.0, 50.0, 100.0, 120.0, 160.0, 240.0, 16000.0, 16000.0 }, // sk_bigmomma_dmg_blast
			{ 100.0, 200.0, 250.0, 250.0, 275.0, 300.0, 500.0, 5000.0 }, // sk_bigmomma_radius_blast
			{ 80.0, 400.0, 800.0, 800.0, 1000.0, 1500.0, 2000.0, 2500.0 }, // sk_gargantua_health
			{ 1.0, 5.0, 10.0, 30.0, 50.0, 250.0, 5000.0, 5000.0 }, // sk_gargantua_dmg_slash
			{ 0.3, 1.5, 3.0, 4.0, 5.0, 25.0, 500.0, 5000.0 }, // sk_gargantua_dmg_fire
			{ 5.0, 25.0, 50.0, 100.0, 100.0, 500.0, 10000.0, 10000.0 }, // sk_gargantua_dmg_stomp
			{ 3.0, 15.0, 30.0, 50.0, 50.0, 75.0, 100.0, 100.0 }, // sk_hassassin_health
			{ 1.0, 5.0, 10.0, 10.0, 20.0, 30.0, 40.0, 50.0 }, // sk_headcrab_health
			{ 0.5, 2.5, 5.0, 10.0, 10.0, 50.0, 2500.0, 2500.0 }, // sk_headcrab_dmg_bite
			{ 5.0, 25.0, 50.0, 50.0, 100.0, 150.0, 200.0, 200.0 }, // sk_hgrunt_health
			{ 0.5, 2.5, 5.0, 10.0, 12.0, 60.0, 1200.0, 1200.0 }, // sk_hgrunt_kick
			{ 1.0, 2.0, 3.0, 5.0, 7.0, 15.0, 50.0, 50.0 }, // sk_hgrunt_pellets
			{ 100.0, 200.0, 400.0, 600.0, 800.0, 1200.0, 1600.0, 2000.0 }, // sk_hgrunt_gspeed
			{ 2.0, 10.0, 20.0, 30.0, 60.0, 90.0, 120.0 , 120.0 }, // sk_houndeye_health
			{ 1.0, 5.0, 10.0, 13.0, 15.0, 75.0, 1500.0, 10000.0 }, // sk_houndeye_dmg_blast
			{ 3.0, 15.0, 30.0, 60.0, 80.0, 120.0, 160.0, 160.0 }, // sk_islave_health
			{ 0.8, 4.0, 8.0, 9.0, 10.0, 50.0, 1000.0, 1000.0 }, // sk_islave_dmg_claw
			{ 2.4, 12.0, 24.0, 25.0, 25.0, 125.0, 2500.0, 2500.0 }, // sk_islave_dmg_clawrake
			{ 1.0, 5.0, 10.0, 12.0, 15.0, 75.0, 1500.0, 1500.0 }, // sk_islave_dmg_zap
			{ 20.0, 100.0, 200.0, 300.0, 400.0, 600.0, 800.0, 1000.0 }, // sk_ichthyosaur_health
			{ 2.0, 10.0, 20.0, 35.0, 50.0, 250.0, 5000.0, 5000.0 }, // sk_ichthyosaur_shake
			{ 1.0, 1.0, 2.0, 2.0, 3.0, 4.0, 5.0, 10.0 }, // sk_leech_health
			{ 0.2, 1.0, 2.0, 3.0, 5.0, 25.0, 500.0, 5000.0 }, // sk_leech_dmg_bite
			{ 6.0, 30.0, 60.0, 80.0, 100.0, 150.0, 200.0, 200.0 }, // sk_controller_health
			{ 1.5, 7.5, 15.0, 25.0, 35.0, 175.0, 3500.0, 3500.0 }, // sk_controller_dmgzap
			{ 150.0, 450.0, 650.0, 800.0, 1000.0, 1000.0, 1000.0, 2000.0 }, // sk_controller_speedball
			{ 0.3, 1.5, 3.0, 4.0, 5.0, 25.0, 500.0, 5000.0 }, // sk_controller_dmgball
			{ 800.0, 800.0, 800.0, 900.0, 1000.0, 1000.0, 1000.0, 1000.0 }, // sk_nihilanth_health
			{ 3.0, 15.0, 30.0, 40.0, 50.0, 250.0, 5000.0, 5000.0 }, // sk_nihilanth_zap
			{ 50.0, 50.0, 50.0, 50.0, 50.0, 50.0, 50.0, 1.0 }, // sk_scientist_health
			{ 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0 }, // sk_snark_health
			{ 0.5, 2.5, 5.0, 10.0, 10.0, 50.0, 1000.0, 10.0 }, // sk_snark_dmg_bite
			{ 0.5, 2.5, 5.0, 5.0, 5.0, 10.0, 50.0, 10.0 }, // sk_snark_dmg_pop
			{ 5.0, 25.0, 50.0, 60.0, 100.0, 150.0, 200.0, 250.0 }, // sk_zombie_health
			{ 1.0, 5.0, 10.0, 20.0, 25.0, 125.0, 2500.0, 2500.0 }, // sk_zombie_dmg_one_slash
			{ 2.5, 12.5, 25.0, 40.0, 40.0, 200.0, 4000.0, 4000.0 }, // sk_zombie_dmg_both_slash
			{ 5.0, 25.0, 50.0, 100.0, 200.0, 300.0, 400.0, 400.0 }, // sk_turret_health
			{ 4.0, 20.0, 40.0, 50.0, 80.0, 120.0, 160.0, 160.0 }, // sk_miniturret_health
			{ 4.0, 20.0, 40.0, 50.0, 80.0, 120.0, 160.0, 160.0 }, // sk_sentry_health
			{ 150.0, 30.0, 15.0, 15.0, 15.0, 15.0, 15.0, 15.0 }, // sk_plr_crowbar
			{ 120.0, 24.0, 12.0, 12.0, 12.0, 12.0, 12.0, 12.0 }, // sk_plr_9mm_bullet
			{ 660.0, 132.0, 66.0, 66.0, 66.0, 66.0, 66.0, 66.0 }, // sk_plr_357_bullet
			{ 80.0, 16.0, 8.0, 8.0, 8.0, 8.0, 8.0, 8.0 }, // sk_plr_9mmAR_bullet
			{ 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0 }, // sk_plr_9mmAR_grenade
			{ 90.0, 18.0, 9.0, 9.0, 9.0, 9.0, 9.0, 9.0 }, // sk_plr_buckshot
			{ 600.0, 120.0, 60.0, 60.0, 60.0, 60.0, 60.0, 60.0 }, // sk_plr_xbow_bolt_monster
			{ 150.0, 150.0, 150.0, 150.0, 150.0, 150.0, 150.0, 150.0 }, // sk_plr_rpg
			{ 190.0, 38.0, 19.0, 19.0, 19.0, 19.0, 19.0, 19.0 }, // sk_plr_gauss
			{ 10.0, 7.5, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0 }, // sk_plr_egon_narrow
			{ 24.0, 18.0, 12.0, 12.0, 12.0, 12.0, 12.0, 12.0 }, // sk_plr_egon_wide
			{ 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0 }, // sk_plr_hand_grenade
			{ 160.0, 160.0, 160.0, 160.0, 160.0, 160.0, 160.0, 160.0 }, // sk_plr_satchel
			{ 150.0, 150.0, 150.0, 150.0, 150.0, 150.0, 150.0, 150.0 }, // sk_plr_tripmine
			{ 1.0, 5.0, 10.0, 12.0, 15.0, 75.0, 1500.0, 12.0 }, // sk_12mm_bullet
			{ 0.3, 1.5, 3.0, 4.0, 6.0, 30.0, 600.0, 4.0 }, // sk_9mmAR_bullet
			{ 0.5, 2.5, 5.0, 6.0, 9.0, 45.0, 900.0, 6.0 }, // sk_9mm_bullet
			{ 0.5, 2.5, 4.0, 7.0, 10.0, 50.0, 1000.0, 7.0 }, // sk_hornet_dmg
			{ 10000.0, 10000.0, 10000.0, 1000.0, 100.0, 10.0, 1.0, 0.0 }, // sk_suitcharger
			{ 100.0, 100.0, 50.0, 25.0, 15.0, 10.0, 1.0, 0.0 }, // sk_battery
			{ 10000.0, 10000.0, 10000.0, 10000.0, 1000.0, 100.0, 1.0, 0.0 }, // sk_healthcharger
			{ 100.0, 100.0, 100.0, 25.0, 15.0, 10.0, 1.0, 0.0 }, // sk_healthkit
			{ 100.0, 100.0, 100.0, 100.0, 50.0, 10.0, 1.0, -1000.0 }, // sk_scientist_heal
			{ 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0 }, // sk_monster_head
			{ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 }, // sk_monster_chest
			{ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 }, // sk_monster_stomach
			{ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 }, // sk_monster_arm
			{ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 }, // sk_monster_leg
			{ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 }, // sk_player_head
			{ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 }, // sk_player_chest
			{ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 }, // sk_player_stomach
			{ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 }, // sk_player_arm
			{ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 }, // sk_player_leg
			{ 0.5, 2.5, 5.0, 6.0, 8.0, 40.0, 800.0, 50000.0 }, // sk_grunt_buckshot
			{ 40.0, 200.0, 400.0, 600.0, 800.0, 1200.0, 1600.0, 2000.0 }, // sk_babygargantua_health
			{ 1.5, 7.5, 15.0, 25.0, 35.0, 175.0, 3500.0, 10000.0 }, // sk_babygargantua_dmg_slash
			{ 0.15, 0.75, 1.5, 2.0, 3.0, 15.0, 300.0, 3000.0 }, // sk_babygargantua_dmg_fire
			{ 2.5, 12.5, 25.0, 50.0, 60.0, 300.0, 6000.0, 10000.0 }, // sk_babygargantua_dmg_stomp
			{ 15.0, 75.0, 150.0, 200.0, 250.0, 375.0, 500.0, 500.0 }, // sk_hwgrunt_health
			{ 1.0, 1.0, 1.0, 1.0, 2.0, 5.0, 50.0, 50.0 }, // sk_hwgrunt_minipellets
			{ 8.0, 40.0, 80.0, 100.0, 125.0, 150.0, 200.0 , 12500.0 }, // sk_rgrunt_explode
			{ 2.5, 12.5, 25.0, 40.0, 50.0, 250.0, 5000.0, 50000.0 }, // sk_massassin_sniper
			{ 65.0, 65.0, 65.0, 65.0, 65.0, 65.0, 65.0, 1.0 }, // sk_otis_health
			{ 340.0, 68.0, 34.0, 34.0, 34.0, 34.0, 34.0, 1.0 }, // sk_otis_bullet
			{ 5.0, 25.0, 50.0, 60.0, 110.0, 165.0, 220.0, 250.0 }, // sk_zombie_barney_health
			{ 1.0, 5.0, 10.0, 20.0, 25.0, 125.0, 2500.0, 2500.0 }, // sk_zombie_barney_dmg_one_slash
			{ 2.5, 12.5, 25.0, 35.0, 40.0, 200.0, 4000.0, 4000.0 }, // sk_zombie_barney_dmg_both_slash
			{ 6.0, 30.0, 60.0, 90.0, 150.0, 225.0, 300.0, 300.0 }, // sk_zombie_soldier_health
			{ 1.0, 5.0, 10.0, 20.0, 40.0, 200.0, 4000.0, 4000.0 }, // sk_zombie_soldier_dmg_one_slash
			{ 2.5, 12.5, 25.0, 40.0, 55.0, 275.0, 5500.0, 5500.0 }, // sk_zombie_soldier_dmg_both_slash
			{ 8.5, 42.5, 85.0, 125.0, 200.0, 300.0, 400.0, 400.0 }, // sk_gonome_health
			{ 1.0, 5.0, 10.0, 20.0, 30.0, 150.0, 3000.0, 3000.0 }, // sk_gonome_dmg_one_slash
			{ 1.0, 5.0, 10.0, 10.0, 15.0, 75.0, 1500.0, 1500.0 }, // sk_gonome_dmg_guts
			{ 0.7, 3.5, 7.0, 14.0, 15.0, 75.0, 1500.0, 1500.0 }, // sk_gonome_dmg_one_bite
			{ 4.0, 20.0, 40.0, 60.0, 110.0, 165.0, 220.0, 220.0 }, // sk_pitdrone_health
			{ 1.5, 7.5, 15.0, 20.0, 25.0, 125.0, 2500.0, 2500.0 }, // sk_pitdrone_dmg_bite
			{ 2.5, 12.5, 25.0, 30.0, 35.0, 175.0, 3500.0, 3500.0 }, // sk_pitdrone_dmg_whip
			{ 1.0, 5.0, 10.0, 12.5, 15.0, 75.0, 1000.0, 1000.0 }, // sk_pitdrone_dmg_spit
			{ 5.0, 25.0, 50.0, 80.0, 200.0, 300.0, 400.0, 400.0 }, // sk_shocktrooper_health
			{ 0.5, 2.5, 5.0, 10.0, 12.0, 60.0, 1200.0, 1200.0 }, // sk_shocktrooper_kick
			{ 0.8, 4.0, 8.0, 8.0, 10.0, 50.0, 1000.0, 1000.0 }, // sk_shocktrooper_maxcharge
			{ 60.0, 300.0, 600.0, 800.0, 1000.0, 1500.0, 2000.0, 2000.0 }, // sk_tor_health
			{ 4.0, 20.0, 40.0, 55.0, 75.0, 315.0, 7500.0, 7500.0 }, // sk_tor_punch
			{ 0.2, 1.0, 2.0, 3.0, 5.0, 25.0, 500.0, 5000.0 }, // sk_tor_energybeam
			{ 1.0, 5.0, 10.0, 15.0, 25.0, 125.0, 2500.0, 2500.0 }, // sk_tor_sonicblast
			{ 16.0, 160.0, 320.0, 350.0, 450.0, 675.0, 900.0, 900.0 }, // sk_voltigore_health
			{ 3.0, 15.0, 30.0, 40.0, 50.0, 250.0, 5000.0, 5000.0 }, // sk_voltigore_dmg_punch
			{ 4.0, 20.0, 40.0, 50.0, 60.0, 300.0, 6000.0, 6000.0 }, // sk_voltigore_dmg_beam
			{ 15.0, 75.0, 150.0, 200.0, 250.0, 1250.0, 25000.0, 25000.0 }, // sk_voltigore_dmg_explode
			{ 50.0, 250.0, 500.0, 750.0, 900.0, 1350.0, 1800.0, 100000.0 }, // sk_tentacle
			{ 45.0, 225.0, 450.0, 600.0, 750.0, 1125.0, 1500.0, 1500.0 }, // sk_blkopsosprey
			{ 45.0, 225.0, 450.0, 600.0, 750.0, 1125.0, 1500.0, 2000.0 }, // sk_osprey
			{ 10.0, 50.0, 100.0, 123.0, 150.0, 225.0, 300.0, 300.0 }, // sk_stukabat
			{ 3.0, 15.0, 30.0, 50.0, 100.0, 150.0, 200.0, 300.0 }, // sk_sqknest_health
			{ 30.0, 150.0, 300.0, 450.0, 600.0, 900.0, 1200.0, 1200.0 }, // sk_kingpin_health
			{ 2.0, 10.0, 20.0, 25.0, 40.0, 200.0, 4000.0, 4000.0 }, // sk_kingpin_lightning
			{ 1.0, 5.0, 10.0, 15.0, 25.0, 125.0, 2500.0, 2500.0 }, // sk_kingpin_tele_blast
			{ 6.0, 30.0, 60.0, 80.0, 100.0, 500.0, 10000.0, 10000.0 }, // sk_kingpin_plasma_blast
			{ 3.0, 15.0, 30.0, 40.0, 50.0, 250.0, 5000.0, 5000.0 }, // sk_kingpin_melee
			{ 30.0, 150.0, 300.0, 500.0, 1000.0, 5000.0, 100000.0, 100000.0 }, // sk_kingpin_telefrag
			{ 10.0, 10.0, 10.0, 10.0, 10.0, 10.0, 10.0, 10.0 }, // sk_plr_HpMedic
			{ 220.0, 44.0, 22.0, 22.0, 22.0, 22.0, 22.0, 22.0 }, // sk_plr_wrench
			{ 400.0, 80.0, 40.0, 40.0, 40.0, 40.0, 40.0, 40.0 }, // sk_plr_grapple
			{ 100.0, 20.0, 10.0, 10.0, 10.0, 10.0, 10.0, 10.0 }, // sk_plr_uzi
			{ 15.0, 15.0, 15.0, 15.0, 15.0, 15.0, 15.0, 15.0 }, // sk_556_bullet PROBLEM: Applies on PLAYER as well as on ENEMY
			{ 1900.0, 380.0, 190.0, 190.0, 190.0, 190.0, 190.0, 190.0 }, // sk_plr_secondarygauss
			{ 120.0, 24.0, 12.0, 12.0, 12.0, 12.0, 12.0, 12.0 }, // sk_hornet_pdmg
			{ 1100.0, 220.0, 110.0, 110.0, 110.0, 110.0, 110.0, 110.0 }, // sk_plr_762_bullet
			{ 1000.0, 200.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0 }, // sk_plr_spore
			{ 150.0, 30.0, 15.0, 15.0, 15.0, 15.0, 15.0, 15.0 }, // sk_plr_shockrifle
			{ 20.0, 4.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0 }, // sk_plr_shockrifle_beam2
			{ 25.0, 125.0, 250.0, 350.0, 500.0, 2500.0, 50000.0, 50000.0 }, // sk_shockroach_dmg_xpl_touch
			{ 10.0, 50.0, 100.0, 150.0, 250.0, 1250.0, 25000.0, 25000.0 }, // sk_shockroach_dmg_xpl_splash
			{ 2500.0, 500.0, 250.0, 250.0, 250.0, 250.0, 250.0, 250.0 }, // sk_plr_displacer_other
			{ 300.0, 300.0, 300.0, 300.0, 300.0, 300.0, 300.0, 300.0 } // sk_plr_displacer_radius
	};
	
	float m_flMessageTime;

	private string s_message = "DIFFICULTY: 50.0 Percent (Medium)";
	private string s_oldmessage = "DIFFICULTY: 50.0 Percent (Medium)";
	private string s_votemessage = "DIFFICULTY: \"diff status\" then open console for voteinfo. Current Difficulty is 50.0 Percent (Medium)";
	private string s_oldvotemessage = "DIFFICULTY: \"diff status\" then open console for voteinfo. Current Difficulty is 50.0 Percent (Medium)";

	/**
	*	Apperantly MapInit calls funcions twice
	*/
	private bool m_bOnMapInit = false;
	
	/**
	*	Is the HardcoreCheck Scheduler running?
	*/
	private bool m_bHardcoreCheckRunning = false;
	
	/**
	*	Average vote Difficulty (0.0 - 1.0)
	*/
	private double m_flAverageVoteDifficulty = 0.5;
	
	/**
	*	Average vote Difficulty (0.0 - 1.0)
	*/
	private double m_flMapDifficulty = 0.5;
	
	/**
	*	Flag to check iff Scheduler is running
	*/
	private bool m_bIsSchedulerRunning = false;
	
	Diffy(){
		m_flAverageVoteDifficulty = 0.5;
		m_flMapDifficulty = 0.5;
		m_bOnMapInit = false;
		s_message = "DIFFICULTY: 50.0 Percent (Medium)";
		s_oldmessage = "DIFFICULTY: 50.0 Percent (Medium)";
		s_votemessage = "DIFFICULTY: \"diff status\" then open console for voteinfo. Current Difficulty is 50.0 Percent (Medium)";
		s_oldvotemessage = "DIFFICULTY: \"diff status\" then open console for voteinfo. Current Difficulty is 50.0 Percent (Medium)";
		m_bIsSchedulerRunning = false;
		ResetData();
	}
	
	void ResetData(){
		m_flMessageTime = g_Engine.time;
	}

	bool getMapinit(){
		return m_bOnMapInit;
	}
	
	string getOldMessage(){
		return s_oldmessage;
	}
	
	string getOldVoteMessage(){
		return s_oldvotemessage;
	}
	
	double getSkValue(int index){
		uint iMax = diffBorders.length;
		
		if(m_flAverageVoteDifficulty==1.0){
			//g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, ""+skillMatrix[index][7]+"\n" );
			return skillMatrix[index][7];
		}else{
			
			for(uint i = 0; i < iMax;i++){
			
				if(diffBorders[i]==m_flAverageVoteDifficulty){
					return skillMatrix[index][i];
				}else if(diffBorders.length>i && diffBorders[i+1]>m_flAverageVoteDifficulty){
					double min = diffBorders[i];
					double max = diffBorders[i+1];
					double difference = (m_flAverageVoteDifficulty-min)/(max-min);
					
					return skillMatrix[index][i]*(1-difference) + skillMatrix[index][i+1]*difference;
				}
				
			}
			
		}
		return -1.0;
	}
	
	double getEntchangeValue(int index){
		uint iMax = diffBorders.length;
		
		if(m_flAverageVoteDifficulty==1.0){
			return entities_multiplyer[index][7];
		}else{
		
			for(uint i = 0; i < iMax;i++){
			
				if(diffBorders[i]==m_flAverageVoteDifficulty){
					return entities_multiplyer[index][i];
				}else if(diffBorders.length>i && diffBorders[i+1]>m_flAverageVoteDifficulty){
					double min = diffBorders[i];
					double max = diffBorders[i+1];
					double difference = (m_flAverageVoteDifficulty-min)/(max-min);
					
					return entities_multiplyer[index][i]*(1-difference) + entities_multiplyer[index][i+1]*difference;
				}
				
			}
		}
		
		return -1.0;
	}
	
	void updateSkillfile(){
		int iMax = skillMatrix.size();
	
		File@ pFile = g_FileSystem.OpenFile( "scripts/plugins/store/skill.cfg", OpenFile::WRITE );

		if( pFile !is null && pFile.IsOpen() ) {
		
			for( int i = 0; i < iMax; ++i ){
			
				pFile.Write( "\""+sk_names[i]+"\" \""+getSkValue(i)+"\"\n" );
				
			}
		
			pFile.Close();
		}
	}
	
	void updateSkilldata(){
	
		CBaseEntity@ pWorld = g_EntityFuncs.Instance( 0 );
		CBaseEntity@ pEntity = g_EntityFuncs.CreateEntity( "trigger_setcvar" );

		if( pEntity !is null ) {
		
			
			g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "m_iszCVarToChange", "skill" );
			
			if(m_flAverageVoteDifficulty < 0.4){
				g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "message", 1 );
			}else if(m_flAverageVoteDifficulty > 0.6){
				g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "message", 3 );
			}else{
				g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "message", 2 );
			}
			
			pEntity.Use( pWorld, pWorld, USE_ON, 0 );
			g_EntityFuncs.Remove( pEntity );
		}
		
		string mapname = g_Engine.mapname;
		bool blackmesaMap = mapname == "hl_c00";
		blackmesaMap = blackmesaMap || mapname == "hl_c01_a1";
		blackmesaMap = blackmesaMap || mapname == "hl_c01_a2";
		blackmesaMap = blackmesaMap || mapname == "hl_c02_a1";
		blackmesaMap = blackmesaMap || mapname == "hl_c02_a2";
		blackmesaMap = blackmesaMap || mapname == "hl_c03";
		blackmesaMap = blackmesaMap || mapname == "hl_c04";
		blackmesaMap = blackmesaMap || mapname == "hl_c05_a1";
		blackmesaMap = blackmesaMap || mapname == "hl_c05_a2";
		blackmesaMap = blackmesaMap || mapname == "hl_c05_a3";
		blackmesaMap = blackmesaMap || mapname == "hl_c06";
		blackmesaMap = blackmesaMap || mapname == "hl_c07_a1";
		blackmesaMap = blackmesaMap || mapname == "hl_c07_a2";
		blackmesaMap = blackmesaMap || mapname == "hl_c08_a1";
		blackmesaMap = blackmesaMap || mapname == "hl_c08_a2";
		blackmesaMap = blackmesaMap || mapname == "hl_c09";
		blackmesaMap = blackmesaMap || mapname == "hl_c10";
		blackmesaMap = blackmesaMap || mapname == "hl_c11_a1";
		blackmesaMap = blackmesaMap || mapname == "hl_c11_a2";
		blackmesaMap = blackmesaMap || mapname == "hl_c11_a3";
		blackmesaMap = blackmesaMap || mapname == "hl_c11_a4";
		blackmesaMap = blackmesaMap || mapname == "hl_c11_a5";
		blackmesaMap = blackmesaMap || mapname == "hl_c12";
		blackmesaMap = blackmesaMap || mapname == "hl_c13_a1";
		blackmesaMap = blackmesaMap || mapname == "hl_c13_a2";
		blackmesaMap = blackmesaMap || mapname == "hl_c13_a3";
		blackmesaMap = blackmesaMap || mapname == "hl_c13_a4";
		blackmesaMap = blackmesaMap || mapname == "ba_tram1";
		blackmesaMap = blackmesaMap || mapname == "ba_tram2";
		blackmesaMap = blackmesaMap || mapname == "ba_tram3";
		blackmesaMap = blackmesaMap || mapname == "ba_security1";
		blackmesaMap = blackmesaMap || mapname == "ba_security2";
		blackmesaMap = blackmesaMap || mapname == "ba_maint";
		blackmesaMap = blackmesaMap || mapname == "ba_elevator";
		blackmesaMap = blackmesaMap || mapname == "ba_canal1";
		blackmesaMap = blackmesaMap || mapname == "ba_canal1b";
		blackmesaMap = blackmesaMap || mapname == "ba_canal2";
		blackmesaMap = blackmesaMap || mapname == "ba_canal3";
		blackmesaMap = blackmesaMap || mapname == "ba_yard1";
		blackmesaMap = blackmesaMap || mapname == "ba_yard2";
		blackmesaMap = blackmesaMap || mapname == "ba_yard3a";
		blackmesaMap = blackmesaMap || mapname == "ba_yard3b";
		blackmesaMap = blackmesaMap || mapname == "ba_yard3";
		blackmesaMap = blackmesaMap || mapname == "ba_yard4";
		blackmesaMap = blackmesaMap || mapname == "ba_yard4a";
		blackmesaMap = blackmesaMap || mapname == "ba_yard5";
		blackmesaMap = blackmesaMap || mapname == "ba_yard5a";
		blackmesaMap = blackmesaMap || mapname == "ba_power1";
		blackmesaMap = blackmesaMap || mapname == "ba_power2";
		blackmesaMap = blackmesaMap || mapname == "ba_teleport1";
		blackmesaMap = blackmesaMap || mapname == "ba_teleport2";
		
		if(blackmesaMap) {
			CBaseEntity@ pEntity2 = g_EntityFuncs.CreateEntity( "trigger_setcvar" );

			if( pEntity2 !is null ) {
			
				g_EntityFuncs.DispatchKeyValue( pEntity2.edict(), "m_iszCVarToChange", "sv_gravity" );
				
				g_EntityFuncs.DispatchKeyValue( pEntity2.edict(), "message", getEntchangeValue(11) );

				pEntity2.Use( pWorld, pWorld, USE_ON, 0 );
				g_EntityFuncs.Remove( pEntity2 );
			}
		}
	}
	
	void printSkilldata(){
		g_Game.AlertMessage( at_logged, getOldMessage()+"\n" );
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, getOldMessage()+"\n" );
	}
	
	void printVoteInfo(){
		g_Game.AlertMessage( at_logged, getOldVoteMessage()+"\n" );
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, getOldVoteMessage()+"\n" );
	}
	
	void playerCheck(){
		CBasePlayer@ pPlayer = null;
		
		for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer ){
			@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
			
			if( pPlayer is null || !pPlayer.IsConnected() ){
				PlayerDiffData@ pData = g_PlayerDiffData[ iPlayer - 1 ];
				pData.m_flDiffVote = -1.0;
			}
		}
		
		m_bOnMapInit = false;
	}
	
	void updateOldMessage(){
		s_oldmessage = s_message;
		s_oldvotemessage = s_votemessage;
	}
	
	void updateOnMapinit(){
		if(!m_bOnMapInit){
			m_bOnMapInit = true;
			
			changeEntities();
			updateSkilldata();
			updateOldMessage();
			m_flMessageTime = g_Engine.time + 20.0f;
			
			m_flMapDifficulty = m_flAverageVoteDifficulty;
			
			if(!m_bHardcoreCheckRunning && m_flMapDifficulty==1.0){
				m_bHardcoreCheckRunning = true;
				g_Scheduler.SetTimeout( @this, "HardcoreCheck", 0.1 );
			}
			
			g_Scheduler.SetTimeout( @this, "printVoteInfo", 20.0 );
			g_Scheduler.SetTimeout( @this, "playerCheck", 30.0 );
		}
	}
	
	void generateMessage(){
		int difficultInt = int(m_flAverageVoteDifficulty*1000.0+0.5);
		string aStr = "DIFFICULTY: Current: "+(difficultInt/10)+"."+(difficultInt%10)+" percent ";
		string bStr = "";
		if(m_flAverageVoteDifficulty<0.0005)
			bStr = "(Lowest Difficulty)";
		else if(m_flAverageVoteDifficulty<0.1)
			bStr = "(Beginners)";
		else if(m_flAverageVoteDifficulty<0.2)
			bStr = "(Very Easy)";
		else if(m_flAverageVoteDifficulty<0.4)
			bStr = "(Easy)";
		else if(m_flAverageVoteDifficulty<0.6)
			bStr = "(Medium)";
		else if(m_flAverageVoteDifficulty<0.75)
			bStr = "(Hard)";
		else if(m_flAverageVoteDifficulty<0.85)
			bStr = "(Very Hard!)";
		else if(m_flAverageVoteDifficulty<0.9)
			bStr = "(WARNING: Extreme!)";
		else if(m_flAverageVoteDifficulty<0.95)
			bStr = "(WARNING: Near Impossible!)";
		else if(m_flAverageVoteDifficulty<0.9995)
			bStr = "(WARNING: Impossible!)";
		else
			bStr = "(WARNING: MAXIMUM DIFFICULTY!)";
		
		s_message = aStr+bStr;
	}
	
	void generateVoteMessage(){
		int difficultInt = int(m_flAverageVoteDifficulty*1000.0+0.5);
		string aStr = "DIFFICULTY: \"diff status\" then open console for voteinfo. Current Difficulty is "+(difficultInt/10)+"."+(difficultInt%10)+" percent ";
		string bStr = "";
		if(m_flAverageVoteDifficulty<0.0005)
			bStr = "(Lowest Difficulty)";
		else if(m_flAverageVoteDifficulty<0.1)
			bStr = "(Beginners)";
		else if(m_flAverageVoteDifficulty<0.2)
			bStr = "(Very Easy)";
		else if(m_flAverageVoteDifficulty<0.4)
			bStr = "(Easy)";
		else if(m_flAverageVoteDifficulty<0.6)
			bStr = "(Medium)";
		else if(m_flAverageVoteDifficulty<0.75)
			bStr = "(Hard)";
		else if(m_flAverageVoteDifficulty<0.85)
			bStr = "(Very Hard!)";
		else if(m_flAverageVoteDifficulty<0.9)
			bStr = "(WARNING: Extreme!)";
		else if(m_flAverageVoteDifficulty<0.95)
			bStr = "(WARNING: Near Impossible!)";
		else if(m_flAverageVoteDifficulty<0.9995)
			bStr = "(WARNING: Impossible!)";
		else
			bStr = "(WARNING: MAXIMUM DIFFICULTY!)";
		
		s_votemessage = aStr+bStr;
	}
	
	void changeEntities(){
		string m_sMap = g_Engine.mapname;
		CBaseEntity@ pWorld = g_EntityFuncs.Instance( 0 );
		
		for( int i = 0; i < g_Engine.maxEntities; ++i ) {
			CBaseEntity@ pEntity = g_EntityFuncs.Instance( i );
			
			if( pEntity !is null ) {
				
				string pClassname = pEntity.GetClassname();
				int multiplyMethod = 0;
				
				bool canHurt = (pClassname == "trigger_hurt");
				canHurt = canHurt || (pClassname == "env_laser");
				canHurt = canHurt || (pClassname == "env_beam");
				canHurt = canHurt || (pClassname == "func_door");
				canHurt = canHurt || (pClassname == "func_door_rotating");
				canHurt = canHurt || (pClassname == "func_train");
				canHurt = canHurt || (pClassname == "func_tracktrain");
				canHurt = canHurt || (pClassname == "trigger_hurt_remote");
				canHurt = canHurt || (pClassname == "func_pendulum");
				canHurt = canHurt || (pClassname == "func_plat");
				canHurt = canHurt || (pClassname == "func_platrot");
				canHurt = canHurt || (pClassname == "func_rotating");
				canHurt = canHurt || (pClassname == "func_trackautochange");
				canHurt = canHurt || (pClassname == "func_trackchange");
				canHurt = canHurt || (pClassname == "momentary_door");
				
				bool hurtExeptions = false;
				bool hurtAlwaysIn = false;
				
				if(m_sMap == "hl_c03"){
					if(pEntity.pev.modelindex == 469){
						hurtAlwaysIn = true;
					}
				}
				if(m_sMap == "hl_c04"){
					if(pEntity.pev.modelindex == 15){
						hurtAlwaysIn = true;
					}
				}
				if(m_sMap == "hl_c05_a2"){
					if(pEntity.pev.modelindex == 67 || pEntity.pev.modelindex == 97){
						multiplyMethod = 2;
					}
				}
				if(m_sMap == "hl_c08_a2"){
					if(pEntity.pev.modelindex == 215){
						hurtAlwaysIn = true;
					}
					if(pEntity.pev.modelindex == 45 || pEntity.pev.modelindex == 46){
						hurtExeptions = true;
					}
				}
				if(m_sMap == "hl_c13_a3"){
					if(pEntity.pev.modelindex == 19 || pEntity.pev.modelindex == 11){
						multiplyMethod = 2;
					}
				}
				if(m_sMap == "th_ep2_04"){
                    if(pEntity.pev.modelindex == 226 || pEntity.pev.modelindex == 259 || pEntity.pev.modelindex == 640){
						multiplyMethod = 16;
                    }
                }
				
				if(canHurt){
					if( hurtAlwaysIn || (pEntity.pev.dmg > 0.5 && pEntity.pev.dmg < 150.0 && !hurtExeptions) ){
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "dmg", (pEntity.pev.dmg*getEntchangeValue(multiplyMethod)) );
					}
					if( pEntity.pev.dmg < 0.0 && m_flAverageVoteDifficulty == 1.0 ){
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "dmg", 0.0 );
					}
				}
				
				if(m_sMap == "hl_c05_a2"){
					if(pEntity.GetTargetname() == "crazybucket"){
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "maxspeed", (pEntity.pev.maxspeed*getEntchangeValue(3)) );
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "speed", (pEntity.pev.speed*getEntchangeValue(3)) );
					}
					if(pEntity.GetTargetname() == "crazymanager1"){
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "crazymanager2", (5.0/getEntchangeValue(3)-0.75*getEntchangeValue(12)) );
					}
					if(pEntity.GetTargetname() == "crazymanager2"){
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "crazymanager1", (5.0/getEntchangeValue(3)-0.75*getEntchangeValue(12)) );
					}
					if(pEntity.GetTargetname() == "silofan_changefriction"){
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "$f_easy", getEntchangeValue(13) );
					}
				}
				if(m_sMap == "hl_c07_a2"){
					string s_Targetname = pEntity.GetTargetname();
					
					bool movingEntities = s_Targetname == "crates";
					movingEntities = movingEntities || s_Targetname.Find("z5crateway") < 4294967295;
					
					if(movingEntities){
						multiplyMethod = 4;
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "maxspeed", (pEntity.pev.maxspeed*getEntchangeValue(multiplyMethod)) );
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "speed", (pEntity.pev.speed*getEntchangeValue(multiplyMethod)) );
					}
				}
				
				if(m_sMap == "hl_c09"){
					string s_Targetname = pEntity.GetTargetname();
					
					bool movingEntities2 = s_Targetname == "sec4_moveables";
					movingEntities2 = movingEntities2 || s_Targetname == "sec4_endcrusher";
					movingEntities2 = movingEntities2 || (s_Targetname.Find("piston") < 4294967295 && s_Targetname.Find("_a") == 4294967295);
					movingEntities2 = movingEntities2 || s_Targetname.Find("chomper") < 4294967295;
					
					bool movingEntities = s_Targetname == "towerwater";
					movingEntities = movingEntities || s_Targetname == "sec2_moveables";
					movingEntities = movingEntities || s_Targetname == "sec3_moveables";
					movingEntities = movingEntities || s_Targetname.Find("piston") < 4294967295;
					movingEntities = movingEntities || s_Targetname.Find("vat") < 4294967295;
					movingEntities = movingEntities || movingEntities2;
					
					if(movingEntities){
						if(movingEntities2){
							multiplyMethod = 3;
						}else{
							multiplyMethod = 4;
						}
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "maxspeed", (pEntity.pev.maxspeed*getEntchangeValue(multiplyMethod)) );
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "speed", (pEntity.pev.speed*getEntchangeValue(multiplyMethod)) );
					}
				}
				
				if(m_sMap == "hl_c10"){
					if(pEntity.GetTargetname() == "psychobot"){
						multiplyMethod = 14;
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "maxspeed", (pEntity.pev.maxspeed*getEntchangeValue(multiplyMethod)) );
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "speed", (pEntity.pev.speed*getEntchangeValue(multiplyMethod)) );
					}
				}
				
				if(m_sMap == "hl_c13_a3"){
					bool movingEntities = pEntity.pev.modelindex == 60;
					bool movingEntities2 = pEntity.pev.modelindex == 2;
					movingEntities = movingEntities || pEntity.pev.modelindex == 59;
					movingEntities = movingEntities || pEntity.pev.modelindex == 58;
					movingEntities2 = movingEntities2 || pEntity.pev.modelindex == 3;
					movingEntities2 = movingEntities2 || pEntity.pev.modelindex == 5;
					movingEntities = movingEntities || movingEntities2;
					
					if(movingEntities){
						if(movingEntities2){
							multiplyMethod = 15;
						}else{
							multiplyMethod = 14;
						}
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "speed", (pEntity.pev.speed*getEntchangeValue(multiplyMethod)) );
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "maxspeed", (pEntity.pev.maxspeed*getEntchangeValue(multiplyMethod)) );
						pEntity.Use( pWorld, pWorld, USE_OFF, 0 );
						pEntity.Use( pWorld, pWorld, USE_ON, 0 );
					}
				}
				
				if(m_sMap == "hl_c14"){
					string s_Targetname = pEntity.GetTargetname();
					
					bool movingEntities = pEntity.pev.modelindex > 1 && pEntity.pev.modelindex < 8;
					movingEntities = movingEntities || pEntity.pev.modelindex == 41;
					movingEntities = movingEntities || pEntity.pev.modelindex == 40;
					movingEntities = movingEntities || s_Targetname == "a";
					movingEntities = movingEntities || s_Targetname == "b";
					movingEntities = movingEntities || s_Targetname == "c";
					movingEntities = movingEntities || s_Targetname == "d";
					movingEntities = movingEntities || s_Targetname == "e";
					movingEntities = movingEntities || s_Targetname == "f";
					movingEntities = movingEntities || s_Targetname == "g";
					movingEntities = movingEntities || s_Targetname == "h";
					movingEntities = movingEntities || s_Targetname == "i";
					movingEntities = movingEntities || s_Targetname == "j";
					movingEntities = movingEntities || s_Targetname == "k";
					movingEntities = movingEntities || s_Targetname == "l";
					movingEntities = movingEntities || s_Targetname == "m";
					movingEntities = movingEntities || s_Targetname == "n";
					movingEntities = movingEntities || s_Targetname == "o";
					movingEntities = movingEntities || s_Targetname == "p";
					
					if(movingEntities){
						multiplyMethod = 14;
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "speed", (pEntity.pev.speed*getEntchangeValue(multiplyMethod)) );
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "maxspeed", (pEntity.pev.maxspeed*getEntchangeValue(multiplyMethod)) );
						pEntity.Use( pWorld, pWorld, USE_OFF, 0 );
						pEntity.Use( pWorld, pWorld, USE_ON, 0 );
					}
				}
				
				if(m_sMap == "hl_c16_a1"){
					bool movingEntities2 = pEntity.pev.modelindex > 17 && pEntity.pev.modelindex < 22;
					bool movingEntities = pEntity.pev.modelindex > 1 && pEntity.pev.modelindex < 5;
					movingEntities = movingEntities || pEntity.pev.modelindex == 64;
					movingEntities = movingEntities || pEntity.pev.modelindex == 142;
					movingEntities = movingEntities || pEntity.pev.modelindex == 141;
					movingEntities = movingEntities || pEntity.pev.modelindex == 8;
					movingEntities = movingEntities || movingEntities2;
					
					if(movingEntities){
						multiplyMethod = 4;
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "speed", (pEntity.pev.speed*getEntchangeValue(multiplyMethod)) );
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "maxspeed", (pEntity.pev.maxspeed*getEntchangeValue(multiplyMethod)) );
						if(movingEntities2) {
							pEntity.Use( pWorld, pWorld, USE_OFF, 0 );
							pEntity.Use( pWorld, pWorld, USE_ON, 0 );
						}
					}
				}
				
				//Func_tank section
				if(m_sMap == "hl_c07_a1"){
					if(pClassname == "func_tank"){
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "bullet_damage", (12.0*getEntchangeValue(9)) );
					}
				}
				if(m_sMap == "hl_c07_a2"){
					string s_Targetname = pEntity.GetTargetname();
					if(s_Targetname == "tinygun" || s_Targetname == "biggun" || s_Targetname == "siloguardgunv2" || s_Targetname == "siloguardgunv3"){
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "bullet_damage", (12.0*getEntchangeValue(9)) );
					}
					if(s_Targetname == "sniper1"){
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "firerate", (2.0*getEntchangeValue(7)) );
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "targetwait", (2.0*getEntchangeValue(6)) );
					}
					if(s_Targetname == "trackguardrocket" || s_Targetname == "trackguardrocketv2"){
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "firerate", (1.0*getEntchangeValue(8)) );
					}
				}
				if(m_sMap == "hl_c11_a2"){
					string s_Targetname = pEntity.GetTargetname();
					if(s_Targetname == "sniper1" || s_Targetname == "sniper2"){
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "firerate", (2.0*getEntchangeValue(7)) );
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "targetwait", (2.0*getEntchangeValue(6)) );
					}
					if(pClassname == "func_tankmortar" && s_Targetname == "tank_turret"){
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "iMagnitude", (60.0*getEntchangeValue(10)) );
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "firerate", (0.8*getEntchangeValue(8)) );
					}
					if(s_Targetname == "brad_turret"){
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "firerate", (0.7*getEntchangeValue(8)) );
					}
				}
				if(m_sMap == "hl_c11_a4"){
					string s_Targetname = pEntity.GetTargetname();
					if(s_Targetname == "sniper1"){
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "firerate", (2.0*getEntchangeValue(7)) );
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "targetwait", (2.0*getEntchangeValue(6)) );
					}
					if(pClassname == "func_tankmortar" && s_Targetname == "brad_turret"){
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "firerate", (1.0*getEntchangeValue(8)) );
					}
				}
				if(m_sMap == "hl_c12"){
					string s_Targetname = pEntity.GetTargetname();
					if(pClassname == "func_tankmortar" && s_Targetname == "tank_turret"){
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "iMagnitude", (100.0*getEntchangeValue(10)) );
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "firerate", (0.4*getEntchangeValue(8)) );
					}
					if(s_Targetname == "biggun"){
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "firerate", (6.0*getEntchangeValue(7)) );
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "bullet_damage", (12.0*getEntchangeValue(9)) );
					}
					if(s_Targetname == "alien_turret_2"){
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "firerate", (2.0*getEntchangeValue(7)) );
					}
				}
				if(m_sMap == "hl_c14"){
					if(pClassname == "func_tanklaser"){
						g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "firerate", (1.0*getEntchangeValue(7)) );
					}
				}
			}
		}
	}
	
	double getAverageDiffy(){
		return m_flAverageVoteDifficulty;
	}
	
	void calcAverageDiffy(){
		int playersTotal = 0;
		int voters = 0;
		float diffiSum = 0.0;
		CBasePlayer@ pPlayer = null;
		
		for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer ){
			@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
		   
			if(!( pPlayer is null || !pPlayer.IsConnected() ))
				++playersTotal;
			
			PlayerDiffData@ pData = g_PlayerDiffData[ iPlayer - 1 ];
			
			if(pData.m_flDiffVote < 0.0)
				continue;
			
			diffiSum = diffiSum + pData.m_flDiffVote;
			++voters;
		}
		
		if(voters > 0){
			diffiSum = diffiSum / float(voters);
		}else{
			if(playersTotal == 0) {
				diffiSum = 0.5;
			} else {
				diffiSum = m_flAverageVoteDifficulty;
			}
		}
		
		if(diffiSum > 0.0 && diffiSum < 0.001) diffiSum = 0.001;
		if(diffiSum < 1.0 && diffiSum > 0.999) diffiSum = 0.999;
		
		if(m_flAverageVoteDifficulty != diffiSum){
			m_flAverageVoteDifficulty = diffiSum;
			updateSkillfile();
			generateMessage();
			generateVoteMessage();
		}
	}
	
	void debugPrintStatus(CBasePlayer@ m_caller){
		CBasePlayer@ pPlayer = null;
		
		for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer ){
			@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
		   
			if( pPlayer is null || !pPlayer.IsConnected() )
				continue;
			
			PlayerDiffData@ pData = g_PlayerDiffData[ iPlayer - 1 ];
			
			string aStr = "";
			if(pData.m_flDiffVote < 0.0){
				aStr = "DIFFICULTY: \""+pPlayer.pev.netname+"\": none\n";
			}else{
				int difficultInt2 = int(pData.m_flDiffVote*1000.0+0.5);
				string bStr = ""+(difficultInt2/10)+"."+(difficultInt2%10)+" percent.\n";
				
				aStr = "DIFFICULTY: \""+pPlayer.pev.netname+"\": "+bStr;
			}
			g_PlayerFuncs.ClientPrint( m_caller, HUD_PRINTCONSOLE, aStr );
		}
		
		int difficultInt = int(g_diffy.getAverageDiffy()*1000.0+0.5);
		string aStr = ""+(difficultInt/10)+"."+(difficultInt%10)+" percent.\n";
		
		g_PlayerFuncs.ClientPrint( m_caller, HUD_PRINTCONSOLE, "DIFFICULTY: - - - - - - - - - - - - - - - - -\n" );
		g_PlayerFuncs.ClientPrint( m_caller, HUD_PRINTCONSOLE, "DIFFICULTY: Average: "+aStr );
		g_PlayerFuncs.ClientPrint( m_caller, HUD_PRINTCONSOLE, getOldMessage()+"\n" );
	}
	
	void HardcoreCheck(){
		if(m_flMapDifficulty==1.0){
			
			CBasePlayer@ pPlayer = null;
			
			for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer ){
				PlayerDiffData@ pData = g_PlayerDiffData[ iPlayer - 1 ];
				@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
				
				if( pPlayer is null || !pPlayer.IsConnected() ){
					pData.m_flLastIsAlive = false;
					continue;
				}
				
				if(pPlayer.IsAlive()){
					if(pPlayer.pev.health > 1.0) pPlayer.pev.health = 1.0;
					if(pPlayer.pev.armorvalue > 0.0) pPlayer.pev.armorvalue = 0.0;
					
					if(!pData.m_flLastIsAlive) {
						pData.m_flLastIsAlive = true;
					}
				}else{
					if(pData.m_flLastIsAlive){
						pPlayer.Killed(pPlayer.pev, GIB_ALWAYS);
						pData.m_flLastIsAlive = false;
					}
				}
			}
			
			//g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "DIFFICULTY: HardcoreCheck\n" );
			g_Scheduler.SetTimeout( @this, "HardcoreCheck", 0.1 );
		}else{
			m_bHardcoreCheckRunning = false;
		}
	}
}

Diffy@ g_diffy;
array<PlayerDiffData@> g_PlayerDiffData;

void PluginInit() {
	g_Module.ScriptInfo.SetAuthor( "CubeMath" );
	g_Module.ScriptInfo.SetContactInfo( "steamcommunity.com/id/CubeMath" );
	
	g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
	g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, @ClientDisconnect );
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay2 );
	
	g_PlayerDiffData.resize( g_Engine.maxClients );
	
	//In case the plugin is being reloaded, fill in the list manually to account for it. Saves a lot of console output.
	for( int iPlayer = 0; iPlayer < g_Engine.maxClients; ++iPlayer ){
		PlayerDiffData data();
		@g_PlayerDiffData[ iPlayer ] = @data;
	}
	
	Diffy dif();
	@g_diffy = @dif;
}

void MapInit() {

	//maxplayers normally can't be changed at runtime, but if that ever changes, we are fucked.
	g_PlayerDiffData.resize( g_Engine.maxClients );

	for( uint uiIndex = 0; uiIndex < g_PlayerDiffData.length(); ++uiIndex ){
	
		PlayerDiffData@ pData = g_PlayerDiffData[ uiIndex ];
		
		if(pData is null){
			PlayerDiffData data();
			@g_PlayerDiffData[ uiIndex ] = @data;
		}else{
			pData.m_flLastVoted = g_Engine.time;
		}
	}
	
	g_diffy.ResetData();
}

void MapActivate() {
	g_diffy.updateOnMapinit();
}

HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer ){

	PlayerDiffData@ pData = g_PlayerDiffData[ pPlayer.entindex() - 1 ];

	pData.m_flLastVoted = g_Engine.time;
	
	if(!g_diffy.getMapinit()){
		g_diffy.playerCheck();
	}
	
	g_diffy.calcAverageDiffy();
	
	return HOOK_CONTINUE;
}

HookReturnCode ClientDisconnect( CBasePlayer@ pPlayer ){

	PlayerDiffData@ pData = g_PlayerDiffData[ pPlayer.entindex() - 1 ];
	
	bool doMessage = true;
	
	if(pData.m_flDiffVote == -1.0){
		doMessage = false;
	}else{
		pData.m_flDiffVote = -1.0;
	}
	
	if(!g_diffy.getMapinit()){
		g_diffy.playerCheck();
	}
	
	g_diffy.calcAverageDiffy();
	
	if(doMessage){
		int difficultInt = int(g_diffy.getAverageDiffy()*1000.0+0.5);
		string aStr = ""+(difficultInt/10)+"."+(difficultInt%10)+" percent";
		g_Game.AlertMessage( at_logged, "DIFFICULTY: Client disconnected: Average next map would be "+aStr+"\n" );
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "DIFFICULTY: Client disconnected: Average next map would be "+aStr+"\n" );
	}
	
	return HOOK_CONTINUE;
}

void ChatCheck2( SayParameters@ m_pArgs ) {
	string str = m_pArgs.GetCommand();
	str.ToUppercase();
	bool strTest = false;

	strTest = (str.Find("DIFFICULT") < 4294967295);
	strTest = strTest || (str.Find("BEGINNER") < 4294967295);
	strTest = strTest || (str.Find("EASY") < 4294967295);
	strTest = strTest || (str.Find("MEDIUM") < 4294967295);
	strTest = strTest || (str.Find("HARD") < 4294967295);
	strTest = strTest || (str.Find("EXTREME") < 4294967295);
	strTest = strTest || (str.Find("IMPOSSIBLE") < 4294967295);
	strTest = strTest || (str.Find("TOUGH") < 4294967295);
	strTest = strTest || (str.Find("ONE HIT") < 4294967295);
	strTest = strTest || (str.Find("ONE SHOT") < 4294967295);
	strTest = strTest || (str.Find("1 HIT") < 4294967295);
	strTest = strTest || (str.Find("1 SHOT") < 4294967295);
	strTest = strTest || (str.Find("INSTAN") < 4294967295);
	strTest = strTest || (str.Find("DIFF") < 2 && str.Length()<6);
	strTest = strTest && (g_diffy.m_flMessageTime < g_Engine.time);
	
	if (strTest) {
		g_diffy.m_flMessageTime = g_Engine.time + 30.0f;
		
		int difficultInt = int(g_diffy.getAverageDiffy()*1000.0+0.5);
		string aStr = g_diffy.getOldMessage()+" Average next map would be "+(difficultInt/10)+"."+(difficultInt%10)+" percent.\n";
		
		g_Game.AlertMessage( at_logged, aStr );
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, aStr );
	}
	
	strTest = false;
	int diffVote = -1;
	
	if( str.Find("DIFF ") == 0 && str.Length()<9){
		for( int i = 0; i <= 100; ++i ){
			if(str == ("DIFF "+i)){
				strTest = true;
				diffVote = i;
			}
		}
	}
	
	if(strTest){
		CBasePlayer@ pPlayer = m_pArgs.GetPlayer();
		PlayerDiffData@ pData = g_PlayerDiffData[ pPlayer.entindex() - 1 ];
		
		if(pData.m_flLastVoted < g_Engine.time) {
			pData.m_flLastVoted = g_Engine.time+10.0;
			
			float m_flDiffVoteOld = pData.m_flDiffVote;
			pData.m_flDiffVote = float(diffVote)/100.0;
			
			g_diffy.calcAverageDiffy();
			
			int difficultInt = int(g_diffy.getAverageDiffy()*1000.0+0.5);
			string aStr = ""+(difficultInt/10)+"."+(difficultInt%10)+" percent";
			string bStr = "";
			
			if(m_flDiffVoteOld == pData.m_flDiffVote){
				bStr = "DIFFICULTY: \"" + pPlayer.pev.netname +
						"\" stays at "+diffVote+" percent\n";
			} else {
				bStr = "DIFFICULTY: \"" + pPlayer.pev.netname +
						"\" voted for "+diffVote+" percent (Average next map would be "+aStr+")\n";
			}
			
			g_Game.AlertMessage( at_logged, bStr );
			g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, bStr );
		}else{
			string aStr = "DIFFICULTY: Mind the 10s Cooldown";
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, aStr );
		}
	}
	
	if(str == "DIFF IDC"){
		CBasePlayer@ pPlayer = m_pArgs.GetPlayer();
		PlayerDiffData@ pData = g_PlayerDiffData[ pPlayer.entindex() - 1 ];
		
		if(pData.m_flLastVoted < g_Engine.time) {
			pData.m_flLastVoted = g_Engine.time+10.0;
			
			pData.m_flDiffVote = -1.0;
			
			g_diffy.calcAverageDiffy();
			
			int difficultInt = int(g_diffy.getAverageDiffy()*1000.0+0.5);
			string aStr = ""+(difficultInt/10)+"."+(difficultInt%10)+" percent";

			string bStr = "DIFFICULTY: \"" + pPlayer.pev.netname +
						"\" doesn't care about a difficulty (Average next map would be "+aStr+")\n";
			
			g_Game.AlertMessage( at_logged, bStr );
			g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, bStr );
		}else{
			string aStr = "DIFFICULTY: Mind the 10s Cooldown";
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, aStr );
		}
	}
	
	if(str == "DIFF STATUS"){
		g_diffy.debugPrintStatus(m_pArgs.GetPlayer());
	}
	
	if(str == "DIFF STATUS2"){
		m_pArgs.ShouldHide = true;
		g_diffy.debugPrintStatus(m_pArgs.GetPlayer());
	}
}

HookReturnCode ClientSay2( SayParameters@ pParams ) {
	ChatCheck2( pParams );
	
	return HOOK_CONTINUE;
}
