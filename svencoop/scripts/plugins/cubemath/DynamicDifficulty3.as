// Horray! Dynamic Difficulty System
// Win Level = More Difficulty
// Lose Level = Less Difficulty
// By CubeMath

final class Diffy {

	float m_flMessageTime;

	private string s_message = "DIFFICULTY: 50.0 Percent (Medium)\n";
	private string s_oldmessage = "DIFFICULTY: 50.0 Percent (Medium)\n";

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
			{ 0.1, 0.5, 0.75, 1.0, 2.0, 10.0, 500.0 }, //trigger_hurt
			{ 0.01, 0.1, 0.5, 1.0, 1.5, 5.0, 100.0 }, //trigger_hurt nerf alot
			{ 1.0, 1.0, 1.0, 1.0, 2.0, 10.0, 500.0 }, //trigger_hurt in unescapable areas
			{ 0.5, 0.75, 0.9, 1.0, 1.1, 1.5, 2.5 }, //slower speed
			{ 1.0, 1.0, 1.0, 1.0, 1.25, 2.0, 5.0 }, //faster speed
			{ 0.5, 0.75, 0.9, 1.0, 1.25, 2.0, 5.0 }, //mixed speed
			{ 1.0, 1.0, 1.0, 1.0, 0.9, 0.5, 0.0 }, //Tank targetwait
			{ 0.5, 0.75, 0.9, 1.0, 1.25, 2.0, 5.0 }, //Tank Firerate (Sniper/Bullets/Laser)
			{ 0.25, 0.5, 0.75, 1.0, 1.5, 3.0, 10.0 }, //Tank Firerate (Rocket/Mortal)
			{ 0.1, 0.5, 0.9, 1.0, 2.0, 5.0, 100.0 }, //Tank Bullet Damage
			{ 0.5, 0.75, 0.9, 1.0, 1.1, 1.5, 2.0 }, //iMagnitude Multiplier
			{ 600.0, 700.0, 750.0, 800.0, 800.0, 800.0, 800.0 }, //sv_gravity
			{ 0.0, 0.0, 0.0, 0.0, 0.2, 0.6, 1.0 }, //hard-multiply
			{ 0.25, 0.35, 0.45, 0.5, 0.75, 1.0, 1.0 }, //silofan_changefriction
			{ 0.01, 0.1, 0.5, 1.0, 1.0, 1.0, 0.0, 0.0 } //trigger_hurt ignore hardcore
	};
	
	/**
	*	Skill-Data
	*/
	private array<array<double>> skillMatrix = {
			{ 6.0, 30.0, 60.0, 100.0, 150.0, 225.0, 300.0 }, // sk_agrunt_health
			{ 1.0, 5.0, 10.0, 20.0, 20.0, 100.0, 2000.0 }, // sk_agrunt_dmg_punch
			{ 128.0, 192.0, 224.0, 256.0, 256.0, 256.0, 256.0 }, // sk_agrunt_melee_engage_distance
			{ 2.0, 10.0, 20.0, 30.0, 40.0, 200.0, 4000.0 }, // sk_agrunt_berserker_dmg_punch
			{ 15.0, 75.0, 150.0, 300.0, 500.0, 750.0, 1000.0 }, // sk_apache_health
			{ 2.0, 15.0, 30.0, 40.0, 50.0, 75.0, 100.0 }, // sk_barnacle_health
			{ 8.0, 8.0, 8.0, 8.0, 10.0, 50.0, 1000.0 }, // sk_barnacle_bite
			{ 65.0, 65.0, 65.0, 65.0, 65.0, 65.0, 65.0 }, // sk_barney_health
			{ 4.0, 20.0, 40.0, 80.0, 120.0, 180.0, 240.0 }, // sk_bullsquid_health
			{ 1.5, 7.5, 15.0, 25.0, 25.0, 125.0, 2500.0 }, // sk_bullsquid_dmg_bite
			{ 2.5, 12.5, 25.0, 35.0, 45.0, 225.0, 4500.0 }, // sk_bullsquid_dmg_whip
			{ 1.0, 5.0, 10.0, 10.0, 15.0, 75.0, 1500.0 }, // sk_bullsquid_dmg_spit
			{ 0.1, 0.3, 0.5, 0.75, 1.0, 1.0, 1.0 }, // sk_bigmomma_health_factor
			{ 5.0, 25.0, 50.0, 60.0, 70.0, 350.0, 7000.0 }, // sk_bigmomma_dmg_slash
			{ 10.0, 50.0, 100.0, 120.0, 160.0, 240.0, 16000.0 }, // sk_bigmomma_dmg_blast
			{ 100.0, 200.0, 250.0, 250.0, 275.0, 300.0, 500.0 }, // sk_bigmomma_radius_blast
			{ 80.0, 400.0, 800.0, 800.0, 1000.0, 1500.0, 2000.0 }, // sk_gargantua_health
			{ 1.0, 5.0, 10.0, 30.0, 50.0, 250.0, 5000.0 }, // sk_gargantua_dmg_slash
			{ 0.3, 1.5, 3.0, 4.0, 5.0, 25.0, 500.0 }, // sk_gargantua_dmg_fire
			{ 5.0, 25.0, 50.0, 100.0, 100.0, 500.0, 10000.0 }, // sk_gargantua_dmg_stomp
			{ 3.0, 15.0, 30.0, 50.0, 50.0, 75.0, 100.0 }, // sk_hassassin_health
			{ 1.0, 5.0, 10.0, 10.0, 20.0, 30.0, 40.0 }, // sk_headcrab_health
			{ 0.5, 2.5, 5.0, 10.0, 10.0, 50.0, 1000.0 }, // sk_headcrab_dmg_bite
			{ 5.0, 25.0, 50.0, 50.0, 100.0, 150.0, 200.0 }, // sk_hgrunt_health
			{ 0.5, 2.5, 5.0, 10.0, 12.0, 60.0, 1200.0 }, // sk_hgrunt_kick
			{ 1.0, 2.0, 3.0, 5.0, 7.0, 35.0, 700.0 }, // sk_hgrunt_pellets
			{ 100.0, 200.0, 400.0, 600.0, 800.0, 1200.0, 1600.0 }, // sk_hgrunt_gspeed
			{ 2.0, 10.0, 20.0, 30.0, 60.0, 90.0, 120.0 }, // sk_houndeye_health
			{ 1.0, 5.0, 10.0, 13.0, 15.0, 75.0, 1500.0 }, // sk_houndeye_dmg_blast
			{ 3.0, 15.0, 30.0, 60.0, 80.0, 120.0, 160.0 }, // sk_islave_health
			{ 0.8, 4.0, 8.0, 9.0, 10.0, 50.0, 1000.0 }, // sk_islave_dmg_claw
			{ 2.4, 12.0, 24.0, 25.0, 25.0, 125.0, 2500.0 }, // sk_islave_dmg_clawrake
			{ 1.0, 5.0, 10.0, 12.0, 15.0, 75.0, 1500.0 }, // sk_islave_dmg_zap
			{ 20.0, 100.0, 200.0, 300.0, 400.0, 600.0, 800.0 }, // sk_ichthyosaur_health
			{ 2.0, 10.0, 20.0, 35.0, 50.0, 250.0, 5000.0 }, // sk_ichthyosaur_shake
			{ 1.0, 1.0, 2.0, 2.0, 3.0, 4.0, 5.0 }, // sk_leech_health
			{ 0.2, 1.0, 2.0, 3.0, 5.0, 25.0, 500.0 }, // sk_leech_dmg_bite
			{ 6.0, 30.0, 60.0, 80.0, 100.0, 150.0, 200.0 }, // sk_controller_health
			{ 1.5, 7.5, 15.0, 25.0, 35.0, 175.0, 3500.0 }, // sk_controller_dmgzap
			{ 150.0, 450.0, 650.0, 800.0, 1000.0, 1000.0, 1000.0 }, // sk_controller_speedball
			{ 0.3, 1.5, 3.0, 4.0, 5.0, 25.0, 500.0 }, // sk_controller_dmgball
			{ 800.0, 800.0, 800.0, 900.0, 1000.0, 1000.0, 1000.0 }, // sk_nihilanth_health
			{ 3.0, 15.0, 30.0, 40.0, 50.0, 250.0, 5000.0 }, // sk_nihilanth_zap
			{ 50.0, 50.0, 50.0, 50.0, 50.0, 50.0, 50.0 }, // sk_scientist_health
			{ 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0 }, // sk_snark_health
			{ 0.5, 2.5, 5.0, 10.0, 10.0, 50.0, 1000.0 }, // sk_snark_dmg_bite
			{ 0.5, 2.5, 5.0, 5.0, 5.0, 10.0, 50.0 }, // sk_snark_dmg_pop
			{ 5.0, 25.0, 50.0, 60.0, 100.0, 150.0, 200.0 }, // sk_zombie_health
			{ 1.0, 5.0, 10.0, 20.0, 25.0, 125.0, 2500.0 }, // sk_zombie_dmg_one_slash
			{ 2.5, 12.5, 25.0, 40.0, 40.0, 200.0, 4000.0 }, // sk_zombie_dmg_both_slash
			{ 5.0, 25.0, 50.0, 100.0, 200.0, 300.0, 400.0 }, // sk_turret_health
			{ 4.0, 20.0, 40.0, 50.0, 80.0, 120.0, 160.0 }, // sk_miniturret_health
			{ 4.0, 20.0, 40.0, 50.0, 80.0, 120.0, 160.0 }, // sk_sentry_health
			{ 150.0, 30.0, 15.0, 15.0, 15.0, 15.0, 15.0 }, // sk_plr_crowbar
			{ 120.0, 24.0, 12.0, 12.0, 12.0, 12.0, 12.0 }, // sk_plr_9mm_bullet
			{ 660.0, 132.0, 66.0, 66.0, 66.0, 66.0, 66.0 }, // sk_plr_357_bullet
			{ 80.0, 16.0, 8.0, 8.0, 8.0, 8.0, 8.0 }, // sk_plr_9mmAR_bullet
			{ 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0 }, // sk_plr_9mmAR_grenade
			{ 90.0, 18.0, 9.0, 9.0, 9.0, 9.0, 9.0 }, // sk_plr_buckshot
			{ 600.0, 120.0, 60.0, 60.0, 60.0, 60.0, 60.0 }, // sk_plr_xbow_bolt_monster
			{ 150.0, 150.0, 150.0, 150.0, 150.0, 150.0, 150.0 }, // sk_plr_rpg
			{ 190.0, 38.0, 19.0, 19.0, 19.0, 19.0, 19.0 }, // sk_plr_gauss
			{ 10.0, 7.5, 5.0, 5.0, 5.0, 5.0, 5.0 }, // sk_plr_egon_narrow
			{ 24.0, 18.0, 12.0, 12.0, 12.0, 12.0, 12.0 }, // sk_plr_egon_wide
			{ 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0 }, // sk_plr_hand_grenade
			{ 160.0, 160.0, 160.0, 160.0, 160.0, 160.0, 160.0 }, // sk_plr_satchel
			{ 150.0, 150.0, 150.0, 150.0, 150.0, 150.0, 150.0 }, // sk_plr_tripmine
			{ 1.0, 5.0, 10.0, 12.0, 15.0, 75.0, 1500.0 }, // sk_12mm_bullet
			{ 0.3, 1.5, 3.0, 4.0, 6.0, 30.0, 600.0 }, // sk_9mmAR_bullet
			{ 0.5, 2.5, 5.0, 6.0, 9.0, 45.0, 900.0 }, // sk_9mm_bullet
			{ 0.5, 2.5, 4.0, 7.0, 10.0, 50.0, 1000.0 }, // sk_hornet_dmg
			{ 10000.0, 10000.0, 10000.0, 1000.0, 100.0, 10.0, 1.0 }, // sk_suitcharger
			{ 100.0, 100.0, 50.0, 25.0, 15.0, 10.0, 1.0 }, // sk_battery
			{ 10000.0, 10000.0, 10000.0, 10000.0, 1000.0, 100.0, 1.0 }, // sk_healthcharger
			{ 100.0, 100.0, 100.0, 25.0, 15.0, 10.0, 1.0 }, // sk_healthkit
			{ 100.0, 100.0, 100.0, 100.0, 50.0, 10.0, 1.0 }, // sk_scientist_heal
			{ 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0 }, // sk_monster_head
			{ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 }, // sk_monster_chest
			{ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 }, // sk_monster_stomach
			{ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 }, // sk_monster_arm
			{ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 }, // sk_monster_leg
			{ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 }, // sk_player_head
			{ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 }, // sk_player_chest
			{ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 }, // sk_player_stomach
			{ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 }, // sk_player_arm
			{ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 }, // sk_player_leg
			{ 0.5, 2.5, 5.0, 6.0, 8.0, 40.0, 800.0 }, // sk_grunt_buckshot
			{ 40.0, 200.0, 400.0, 600.0, 800.0, 1200.0, 1600.0 }, // sk_babygargantua_health
			{ 1.5, 7.5, 15.0, 25.0, 35.0, 175.0, 3500.0 }, // sk_babygargantua_dmg_slash
			{ 0.15, 0.75, 1.5, 2.0, 3.0, 15.0, 300.0 }, // sk_babygargantua_dmg_fire
			{ 2.5, 12.5, 25.0, 50.0, 60.0, 300.0, 6000.0 }, // sk_babygargantua_dmg_stomp
			{ 15.0, 75.0, 150.0, 200.0, 250.0, 375.0, 500.0 }, // sk_hwgrunt_health
			{ 0.08, 0.4, 0.8, 1.0, 1.2, 6.0, 120.0 }, // sk_hwgrunt_minipellets
			{ 8.0, 40.0, 80.0, 100.0, 125.0, 625.0, 12500.0 }, // sk_rgrunt_explode
			{ 2.5, 12.5, 25.0, 40.0, 50.0, 250.0, 5000.0 }, // sk_massassin_sniper
			{ 65.0, 65.0, 65.0, 65.0, 65.0, 65.0, 65.0 }, // sk_otis_health
			{ 340.0, 68.0, 34.0, 34.0, 34.0, 34.0, 34.0 }, // sk_otis_bullet
			{ 5.0, 25.0, 50.0, 60.0, 110.0, 165.0, 220.0 }, // sk_zombie_barney_health
			{ 1.0, 5.0, 10.0, 20.0, 25.0, 125.0, 2500.0 }, // sk_zombie_barney_dmg_one_slash
			{ 2.5, 12.5, 25.0, 35.0, 40.0, 200.0, 4000.0 }, // sk_zombie_barney_dmg_both_slash
			{ 6.0, 30.0, 60.0, 90.0, 150.0, 225.0, 300.0 }, // sk_zombie_soldier_health
			{ 1.0, 5.0, 10.0, 20.0, 40.0, 200.0, 4000.0 }, // sk_zombie_soldier_dmg_one_slash
			{ 2.5, 12.5, 25.0, 40.0, 55.0, 275.0, 5500.0 }, // sk_zombie_soldier_dmg_both_slash
			{ 8.5, 42.5, 85.0, 125.0, 200.0, 300.0, 400.0 }, // sk_gonome_health
			{ 1.0, 5.0, 10.0, 20.0, 30.0, 150.0, 3000.0 }, // sk_gonome_dmg_one_slash
			{ 1.0, 5.0, 10.0, 10.0, 15.0, 75.0, 1500.0 }, // sk_gonome_dmg_guts
			{ 0.7, 3.5, 7.0, 14.0, 15.0, 75.0, 1500.0 }, // sk_gonome_dmg_one_bite
			{ 4.0, 20.0, 40.0, 60.0, 110.0, 165.0, 220.0 }, // sk_pitdrone_health
			{ 1.5, 7.5, 15.0, 20.0, 25.0, 125.0, 2500.0 }, // sk_pitdrone_dmg_bite
			{ 2.5, 12.5, 25.0, 30.0, 35.0, 175.0, 3500.0 }, // sk_pitdrone_dmg_whip
			{ 1.0, 5.0, 10.0, 12.5, 15.0, 75.0, 1000.0 }, // sk_pitdrone_dmg_spit
			{ 5.0, 25.0, 50.0, 80.0, 200.0, 300.0, 400.0 }, // sk_shocktrooper_health
			{ 0.5, 2.5, 5.0, 10.0, 12.0, 60.0, 1200.0 }, // sk_shocktrooper_kick
			{ 0.8, 4.0, 8.0, 8.0, 10.0, 50.0, 1000.0 }, // sk_shocktrooper_maxcharge
			{ 60.0, 300.0, 600.0, 800.0, 1000.0, 1500.0, 2000.0 }, // sk_tor_health
			{ 4.0, 20.0, 40.0, 55.0, 75.0, 315.0, 7500.0 }, // sk_tor_punch
			{ 0.2, 1.0, 2.0, 3.0, 5.0, 25.0, 500.0 }, // sk_tor_energybeam
			{ 1.0, 5.0, 10.0, 15.0, 25.0, 125.0, 2500.0 }, // sk_tor_sonicblast
			{ 16.0, 160.0, 320.0, 350.0, 450.0, 675.0, 900.0 }, // sk_voltigore_health
			{ 3.0, 15.0, 30.0, 40.0, 50.0, 250.0, 5000.0 }, // sk_voltigore_dmg_punch
			{ 4.0, 20.0, 40.0, 50.0, 60.0, 300.0, 6000.0 }, // sk_voltigore_dmg_beam
			{ 15.0, 75.0, 150.0, 200.0, 250.0, 1250.0, 25000.0 }, // sk_voltigore_dmg_explode
			{ 50.0, 250.0, 500.0, 750.0, 900.0, 1350.0, 1800.0 }, // sk_tentacle
			{ 45.0, 225.0, 450.0, 600.0, 750.0, 1125.0, 1500.0 }, // sk_blkopsosprey
			{ 45.0, 225.0, 450.0, 600.0, 750.0, 1125.0, 1500.0 }, // sk_osprey
			{ 10.0, 50.0, 100.0, 123.0, 150.0, 225.0, 300.0 }, // sk_stukabat
			{ 3.0, 15.0, 30.0, 50.0, 100.0, 150.0, 200.0 }, // sk_sqknest_health
			{ 30.0, 150.0, 300.0, 450.0, 600.0, 900.0, 1200.0 }, // sk_kingpin_health
			{ 2.0, 10.0, 20.0, 25.0, 40.0, 200.0, 4000.0 }, // sk_kingpin_lightning
			{ 1.0, 5.0, 10.0, 15.0, 25.0, 125.0, 2500.0 }, // sk_kingpin_tele_blast
			{ 6.0, 30.0, 60.0, 80.0, 100.0, 500.0, 10000.0 }, // sk_kingpin_plasma_blast
			{ 3.0, 15.0, 30.0, 40.0, 50.0, 250.0, 5000.0 }, // sk_kingpin_melee
			{ 30.0, 150.0, 300.0, 500.0, 1000.0, 5000.0, 100000.0 }, // sk_kingpin_telefrag
			{ 10.0, 10.0, 10.0, 10.0, 10.0, 10.0, 10.0 }, // sk_plr_HpMedic
			{ 220.0, 44.0, 22.0, 22.0, 22.0, 22.0, 22.0 }, // sk_plr_wrench
			{ 400.0, 80.0, 40.0, 40.0, 40.0, 40.0, 40.0 }, // sk_plr_grapple
			{ 100.0, 20.0, 10.0, 10.0, 10.0, 10.0, 10.0 }, // sk_plr_uzi
			{ 15.0, 15.0, 15.0, 15.0, 15.0, 15.0, 15.0 }, // sk_556_bullet PROBLEM: Applies on PLAYER as well as on ENEMY
			{ 1900.0, 380.0, 190.0, 190.0, 190.0, 190.0, 190.0 }, // sk_plr_secondarygauss
			{ 120.0, 24.0, 12.0, 12.0, 12.0, 12.0, 12.0 }, // sk_hornet_pdmg
			{ 1100.0, 220.0, 110.0, 110.0, 110.0, 110.0, 110.0 }, // sk_plr_762_bullet
			{ 1000.0, 200.0, 100.0, 100.0, 100.0, 100.0, 100.0 }, // sk_plr_spore
			{ 150.0, 30.0, 15.0, 15.0, 15.0, 15.0, 15.0 }, // sk_plr_shockrifle
			{ 20.0, 4.0, 2.0, 2.0, 2.0, 2.0, 2.0 }, // sk_plr_shockrifle_beam2
			{ 25.0, 125.0, 250.0, 350.0, 500.0, 2500.0, 50000.0 }, // sk_shockroach_dmg_xpl_touch
			{ 10.0, 50.0, 100.0, 150.0, 250.0, 1250.0, 25000.0 }, // sk_shockroach_dmg_xpl_splash
			{ 2500.0, 500.0, 250.0, 250.0, 250.0, 250.0, 250.0 }, // sk_plr_displacer_other
			{ 300.0, 300.0, 300.0, 300.0, 300.0, 300.0, 300.0 } // sk_plr_displacer_radius
	};
	
	/**
	*	Apperantly MapInit calls funcions twice
	*/
	private bool m_bOnMapInit = false;
	
	/**
	*	Playernumber
	*/
	private int m_iPNum = 0;
	
	/**
	*	Difficulty (0.0 - 1.0)
	*/
	private double m_flDifficulty = 0.5;
	
	/**
	*	OLD Difficulty (0.0 - 1.0)
	*/
	private double m_floldDifficulty = 0.5;
	
	/**
	*	Actual Difficulty that everybody plays on it (0.0 - 1.0)
	*	Only changes at mapspawn
	*/
	private double m_flActualDifficulty = 0.5;
	
	/**
	*	Last Map to check progress
	*/
	private string m_strLastMap = "";
	
	/**
	*	Flag to check iff Scheduler is running
	*/
	private bool m_bIsSchedulerRunning = false;
	
	Diffy(){
		m_flDifficulty = 0.5;
		m_flActualDifficulty = 0.5;
		m_floldDifficulty = 0.5;
		m_strLastMap = "";
		m_bOnMapInit = false;
		s_message = "DIFFICULTY: 50.0 Percent (Medium)\n";
		s_oldmessage = "DIFFICULTY: 50.0 Percent (Medium)\n";
		m_bIsSchedulerRunning = false;
		ResetData();
	}
	
	void ResetData(){
		m_flMessageTime = g_Engine.time;
	}

	bool getMapinit(){
		return m_bOnMapInit;
	}
	
	void addDiffy( double diffy ){
		setDiffy( m_flDifficulty + diffy );
	}
	
	double getDiffy(){
		return m_flDifficulty;
	}
	
	void setDiffy( double diffy ){
		m_flDifficulty = diffy;
		
		if(m_flDifficulty > 1.0) m_flDifficulty = 1.0;
		if(m_flDifficulty < 0.0) m_flDifficulty = 0.0;
	}
	
	void updateADiffy(){
		m_floldDifficulty = m_flActualDifficulty;
		m_flActualDifficulty = m_flDifficulty;
	}
	
	double getADiffy(){
		return m_flActualDifficulty;
	}
	
	string getOldMessage(){
		return s_oldmessage;
	}
	
	void updateMapStatus(bool negative){
		double multiply = 1.0;
		if(negative) multiply = -1.0;

		m_strLastMap = g_Engine.mapname;
		
		addDiffy( 0.001*m_iPNum*multiply );
		
		if (m_strLastMap == "hl_c00") {
			if(m_iPNum == 0)
				setDiffy( 0.5 );
		}
		if (m_strLastMap == "hl_c02_a1") addDiffy( 0.022*multiply );
		if (m_strLastMap == "hl_c02_a2") addDiffy( 0.017*multiply );
		if (m_strLastMap == "hl_c03") addDiffy( 0.014*multiply );
		if (m_strLastMap == "hl_c04") addDiffy( 0.027*multiply );
		if (m_strLastMap == "hl_c05_a1") addDiffy( 0.014*multiply );
		if (m_strLastMap == "hl_c05_a2") addDiffy( 0.028*multiply );
		if (m_strLastMap == "hl_c05_a3") addDiffy( 0.007*multiply );
		if (m_strLastMap == "hl_c06") addDiffy( 0.017*multiply );
		if (m_strLastMap == "hl_c07_a1") addDiffy( 0.018*multiply );
		if (m_strLastMap == "hl_c07_a2") addDiffy( 0.024*multiply );
		if (m_strLastMap == "hl_c08_a1") addDiffy( 0.021*multiply );
		if (m_strLastMap == "hl_c08_a2") addDiffy( 0.030*multiply );
		if (m_strLastMap == "hl_c09") addDiffy( 0.017*multiply );
		if (m_strLastMap == "hl_c10") addDiffy( 0.018*multiply );
		if (m_strLastMap == "hl_c11_a1") addDiffy( 0.030*multiply );
		if (m_strLastMap == "hl_c11_a2") addDiffy( 0.015*multiply );
		if (m_strLastMap == "hl_c11_a3") addDiffy( 0.013*multiply );
		if (m_strLastMap == "hl_c11_a4") addDiffy( 0.016*multiply );
		if (m_strLastMap == "hl_c11_a5") addDiffy( 0.025*multiply );
		if (m_strLastMap == "hl_c12") addDiffy( 0.028*multiply );
		if (m_strLastMap == "hl_c13_a1") addDiffy( 0.020*multiply );
		if (m_strLastMap == "hl_c13_a2") addDiffy( 0.022*multiply );
		if (m_strLastMap == "hl_c13_a3") addDiffy( 0.011*multiply );
		if (m_strLastMap == "hl_c13_a4") addDiffy( 0.045*multiply );
		if (m_strLastMap == "hl_c14") addDiffy( 0.045*multiply );
		if (m_strLastMap == "hl_c15") addDiffy( 0.012*multiply );
		if (m_strLastMap == "hl_c16_a1") addDiffy( 0.019*multiply );
		if (m_strLastMap == "hl_c16_a2") addDiffy( 0.012*multiply );
		if (m_strLastMap == "hl_c16_a3") addDiffy( 0.015*multiply );
		if (m_strLastMap == "hl_c16_a4") addDiffy( 0.065*multiply );
		if (m_strLastMap == "hl_c17") addDiffy( 0.019*multiply );
		
		if (m_strLastMap.Find("hl_c") == 4294967295) addDiffy( 0.015*multiply );
	}
	
	double getSkValue(int index){
		uint iMax = diffBorders.length;
		
		for(uint i = 0; i < iMax;i++){
		
			if(diffBorders[i]==m_flActualDifficulty){
				return skillMatrix[index][i];
			}else if(diffBorders.length>i && diffBorders[i+1]>m_flActualDifficulty){
				double min = diffBorders[i];
				double max = diffBorders[i+1];
				double difference = (m_flActualDifficulty-min)/(max-min);
				
				return skillMatrix[index][i]*(1-difference) + skillMatrix[index][i+1]*difference;
			}
			
		}
		return -1.0;
	}
	
	double getEntchangeValue(int index){
		uint iMax = diffBorders.length;
		
		for(uint i = 0; i < iMax;i++){
		
			if(diffBorders[i]==m_floldDifficulty){
				return entities_multiplyer[index][i];
			}else if(diffBorders.length>i && diffBorders[i+1]>m_floldDifficulty){
				double min = diffBorders[i];
				double max = diffBorders[i+1];
				double difference = (m_floldDifficulty-min)/(max-min);
				
				return entities_multiplyer[index][i]*(1-difference) + entities_multiplyer[index][i+1]*difference;
			}
			
		}
		return -1.0;
	}
	
	void updateSkilldata(){
		int iMax = skillMatrix.size();
	
		File@ pFile = g_FileSystem.OpenFile( "scripts/plugins/store/skill.cfg", OpenFile::WRITE );

		if( pFile !is null && pFile.IsOpen() ) {
		
			CBaseEntity@ pWorld = g_EntityFuncs.Instance( 0 );
			CBaseEntity@ pEntity = g_EntityFuncs.CreateEntity( "trigger_setcvar" );

			if( pEntity !is null ) {
			
				
				g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "m_iszCVarToChange", "skill" );
				
				if(getADiffy() < 0.4){
					g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "message", 1 );
				}else if(getADiffy() > 0.6){
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
			
			if(blackmesaMap) {
				CBaseEntity@ pEntity2 = g_EntityFuncs.CreateEntity( "trigger_setcvar" );

				if( pEntity2 !is null ) {
				
					g_EntityFuncs.DispatchKeyValue( pEntity2.edict(), "m_iszCVarToChange", "sv_gravity" );
					
					g_EntityFuncs.DispatchKeyValue( pEntity2.edict(), "message", getEntchangeValue(11) );

					pEntity2.Use( pWorld, pWorld, USE_ON, 0 );
					g_EntityFuncs.Remove( pEntity2 );
				}
			}
			
			for( int i = 0; i < iMax; ++i ){
			
				pFile.Write( "\""+sk_names[i]+"\" \""+getSkValue(i)+"\"\n" );
				
				//sk_names[i]
				//getSkValue(i)
				
			}
		
			pFile.Close();
		}
	}
	
	void printSkilldata2(){
		g_Game.AlertMessage( at_logged, g_diffy.getOldMessage() );
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, g_diffy.getOldMessage() );
	}
	
	void printSkilldata(){
		s_oldmessage = s_message;
		
		generateMessage();
		
		m_bOnMapInit = false;
		countPeople();
	}
	
	void startCheckEnd(){
		if(!m_bIsSchedulerRunning){
			m_bIsSchedulerRunning = true;
			CScheduledFunction@ m_cfCheck = g_Scheduler.SetInterval( @this, "checkEnd", 3.0 );
		}
	}
	
	void updateOnMapinit(){
		if(!m_bOnMapInit){
			m_bOnMapInit = true;
			
			updateMapStatus(false);
			updateADiffy();
			changeEntities();
			updateSkilldata();
			printSkilldata();
			m_flMessageTime = g_Engine.time + 45.0f;
			g_Scheduler.SetTimeout( @this, "printSkilldata2", 15.0 );
			g_Scheduler.SetTimeout( @this, "startCheckEnd", 30.0 );
		}
	}
	
	void countPeople(){
		m_iPNum = 0;
		
		CBasePlayer@ pPlayer;
		
		for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer ){
			@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
		   
			if( pPlayer is null || !pPlayer.IsConnected() )
				continue;
			
			++m_iPNum;
		}
	}
	
	void generateMessage(){
		int difficultInt = int(m_flActualDifficulty*1000.0+0.5);
		string aStr = "DIFFICULTY: "+(difficultInt/10)+"."+(difficultInt%10)+" percent ";
		string bStr = "\n";
		if(m_flActualDifficulty<0.001)
			bStr = "(Lowest Difficulty)\n";
		else if(m_flActualDifficulty<0.1)
			bStr = "(Beginners)\n";
		else if(m_flActualDifficulty<0.2)
			bStr = "(Very Easy)\n";
		else if(m_flActualDifficulty<0.4)
			bStr = "(Easy)\n";
		else if(m_flActualDifficulty<0.6)
			bStr = "(Medium)\n";
		else if(m_flActualDifficulty<0.75)
			bStr = "(Hard)\n";
		else if(m_flActualDifficulty<0.85)
			bStr = "(Very Hard!)\n";
		else if(m_flActualDifficulty<0.9)
			bStr = "(WARNING: Extreme!)\n";
		else if(m_flActualDifficulty<0.95)
			bStr = "(WARNING: Near Impossible!)\n";
		else if(m_flActualDifficulty<1.0)
			bStr = "(WARNING: Impossible!)\n";
		else
			bStr = "(WARNING: MAXIMUM DIFFICULTY!)\n";
		
		s_message = aStr+bStr;
	}
	
	void checkEnd() {
		if(m_bOnMapInit){
			g_Scheduler.RemoveTimer(g_Scheduler.GetCurrentFunction());
			m_bIsSchedulerRunning = false;
		}else{
			string m_sMap = g_Engine.mapname;
			
			bool b_skip = m_sMap == "hl_c00";
			b_skip = b_skip || m_sMap == "hl_c01_a1";
			b_skip = b_skip || m_sMap == "hl_c01_a2";
			b_skip = b_skip || m_sMap == "hl_c18";
			b_skip = b_skip || m_sMap == "server_crash";
			
			if(b_skip) {
				g_Scheduler.RemoveTimer(g_Scheduler.GetCurrentFunction());
				m_bIsSchedulerRunning = false;
			}else{
				int iLivingPlayers = 0;
				
				for( int iIndex = 1; iIndex <= g_Engine.maxClients; ++iIndex )
				{
					CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iIndex );
					
					if( pPlayer !is null && pPlayer.IsAlive() ) {
						++iLivingPlayers;
					}
				}
				
				if(m_iPNum > 0 && iLivingPlayers == 0){
					updateMapStatus(true);
					addDiffy( -0.15 );
					
					g_Scheduler.RemoveTimer(g_Scheduler.GetCurrentFunction());
					m_bIsSchedulerRunning = false;
					
					updateADiffy();
					generateMessage();
					updateSkilldata();	
				}
			}
		}
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
						multiplyMethod = 14;
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
						multiplyMethod = 4;
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
							multiplyMethod = 5;
						}else{
							multiplyMethod = 4;
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
						multiplyMethod = 4;
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
	
	void sendMes(string message){
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, message );
	}
}

Diffy@ g_diffy;
CConCommand@ g_DiffSet = null;

void PluginInit() {
	g_Module.ScriptInfo.SetAuthor( "CubeMath" );
	g_Module.ScriptInfo.SetContactInfo( "steamcommunity.com/id/CubeMath" );
	
	g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
	g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, @ClientDisconnect );
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay2 );
	
	Diffy dif();
	@g_diffy = @dif;
	@g_DiffSet = CConCommand( "set_difficulty", "Set Difficulty (0 - 100)", @DifficultySet );
}

void MapInit() {
	g_diffy.ResetData();
}

void MapActivate() {
	g_diffy.updateOnMapinit();
}

HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer ){
	if(!g_diffy.getMapinit()) {
		g_diffy.countPeople();
		g_diffy.addDiffy( 0.005 );
	}
	return HOOK_CONTINUE;
}

HookReturnCode ClientDisconnect( CBasePlayer@ pPlayer ){
	if(!g_diffy.getMapinit()){
		g_diffy.countPeople();
		if(g_diffy.getDiffy()<1.0){
			g_diffy.addDiffy( -0.005 );
		}
	}
	return HOOK_CONTINUE;
}

void DifficultySet( const CCommand@ pArgs ) {
	int diffNum = Math.clamp( 0, 100, atoi( pArgs.Arg( 1 ) ) );
	g_diffy.setDiffy( double(diffNum)/100.0 );
	
	g_diffy.updateADiffy();
	g_diffy.generateMessage();
	g_diffy.updateSkilldata();	
	
	g_Game.AlertMessage( at_logged, "Diff set to: "+diffNum+"\n" );
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
	strTest = strTest || (str.Find("INSTAN") < 4294967295);
	strTest = strTest || (str.Find("DIFF") < 2 && str.Length()<6);
	strTest = strTest || (str == "!D");
	strTest = strTest && (g_diffy.m_flMessageTime < g_Engine.time);
	
	if (strTest) {
		g_diffy.m_flMessageTime = g_Engine.time + 60.0f;
		g_Game.AlertMessage( at_logged, g_diffy.getOldMessage() );
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, g_diffy.getOldMessage() );
	}
}

HookReturnCode ClientSay2( SayParameters@ pParams ) {
	ChatCheck2( pParams );
	
	return HOOK_CONTINUE;
}
