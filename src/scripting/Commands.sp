/**
 * MicroTF2 - Commands.inc
 * 
 * Implements functionality for commands and convars.
 */

ConVar g_hConVarServerCheats;
ConVar g_hConVarHostTimescale;
ConVar g_hConVarPhysTimescale;
ConVar g_hConVarServerGravity;
ConVar g_hConVarTFCheapObjects;
ConVar g_hConVarTFFastBuild;
ConVar g_hConVarTFWeaponSpreads;
ConVar g_hConVarFriendlyFire;

Handle ConVar_MTF2IntermissionEnabled = INVALID_HANDLE;
Handle ConVar_MTF2BonusPoints = INVALID_HANDLE;
Handle ConVar_MTF2AllowCosmetics = INVALID_HANDLE;
Handle ConVar_MTF2ForceMinigame = INVALID_HANDLE;
Handle ConVar_MTF2ForceBossgame = INVALID_HANDLE;
Handle ConVar_MTF2ForceBossgameThreshold = INVALID_HANDLE;
Handle ConVar_MTF2UseServerMapTimelimit = INVALID_HANDLE;

stock void InitializeCommands()
{
	AddToForward(GlobalForward_OnConfigsExecuted, INVALID_HANDLE, Commands_OnConfigsExecuted);

	// Command Listeners
	AddCommandListener(CmdOnPlayerTaunt, "taunt");
	AddCommandListener(CmdOnPlayerTaunt, "+taunt");
	AddCommandListener(CmdOnPlayerTaunt, "use_action_slot_item_server");
	AddCommandListener(CmdOnPlayerTaunt, "+use_action_slot_item_server");

	AddCommandListener(CmdOnPlayerKill, "kill");
	AddCommandListener(CmdOnPlayerKill, "explode");

	g_hConVarServerCheats = FindConVar("sv_cheats");
	g_hConVarHostTimescale = FindConVar("host_timescale");
	g_hConVarPhysTimescale = FindConVar("phys_timescale");

	g_hConVarServerGravity = FindConVar("sv_gravity");
	g_hConVarTFCheapObjects = FindConVar("tf_cheapobjects");
	g_hConVarTFFastBuild = FindConVar("tf_fastbuild");
	g_hConVarTFWeaponSpreads = FindConVar("tf_use_fixed_weaponspreads");
	g_hConVarFriendlyFire = FindConVar("mp_friendlyfire");

	RegAdminCmd("sm_changegamemode", Command_SetGamemode, ADMFLAG_VOTE, "Changes the current gamemode.");
	RegAdminCmd("sm_triggerboss", Command_TriggerBoss, ADMFLAG_VOTE, "Triggers a bossgame to be played next.");

	ConVar_MTF2MaxRounds = CreateConVar("mtf2_maxrounds", "4", "Sets the maximum rounds to be played. 0 = no limit (not recommended).", 0, true, 0.0);
	ConVar_MTF2IntermissionEnabled = CreateConVar("mtf2_intermission_enabled", "1", "Controls whether or not intermission is to be held half way through the maximum round count. Having Intermission enabled assumes you have a intermission integration enabled - for example the SourceMod Mapchooser integration.", 0, true, 0.0, true, 1.0);
	ConVar_MTF2BonusPoints = CreateConVar("mtf2_bonuspoints", "0", "Controls whether or not minigames should have a bonus point.", 0, true, 0.0, true, 1.0);
	ConVar_MTF2AllowCosmetics = CreateConVar("mtf2_cosmetics_enabled", "0", "Allows cosmetics to be worn by players. NOTE: This mode is explicitly not supported and may cause visual bugs and possible server lag spikes.", 0, true, 0.0, true, 1.0);
	ConVar_MTF2UseServerMapTimelimit = CreateConVar("mtf2_use_server_map_timelimit", "0", "Sets whether or not the gamemode should instead run an infinite number of rounds and let mp_timelimit dictate when the map ends. If set to 1, the gamemode will also not run intermission, and your mapchooser plugin will need to handle this instead.", 0, true, 0.0, true, 1.0);

	if (ConVar_MTF2MaxRounds != INVALID_HANDLE)
	{
		HookConVarChange(ConVar_MTF2MaxRounds, OnMaxRoundsChanged);
	}

	if (ConVar_MTF2AllowCosmetics != INVALID_HANDLE)
	{
		HookConVarChange(ConVar_MTF2AllowCosmetics, OnAllowCosmeticsChanged);
	}

	// Debug cvars/cmds
	ConVar_MTF2ForceMinigame = CreateConVar("mtf2_debug_forceminigame", "0", "Forces a minigame to always be played. If 0, no minigame will be forced. This cvar is used only when debugging.", 0, true, 0.0);
	ConVar_MTF2ForceBossgame = CreateConVar("mtf2_debug_forcebossgame", "0", "Forces a bossgame to always be played. If 0, no bossgame will be forced. This cvar is used only when debugging.", 0, true, 0.0);
	ConVar_MTF2ForceBossgameThreshold = CreateConVar("mtf2_debug_forcebossgamethreshold", "0", "Forces a threshold to always be played. If 0, no bossgame will be forced. This cvar is used only when debugging.", 0, true, 0.0);
}

public void Commands_OnConfigsExecuted()
{
	PrepareConVars();
}

stock void ResetConVars()
{
	g_hConVarHostTimescale.RestoreDefault();
	g_hConVarPhysTimescale.RestoreDefault();
	g_hConVarServerGravity.RestoreDefault();	
	g_hConVarTFCheapObjects.RestoreDefault();
	g_hConVarTFFastBuild.RestoreDefault();
	g_hConVarTFWeaponSpreads.RestoreDefault();
	g_hConVarFriendlyFire.RestoreDefault();

	ResetConVar(ConVar_MTF2ForceMinigame);
	ResetConVar(ConVar_MTF2ForceBossgame);
	
	// Non-Exclusive ConVars
	// Server ConVars
	SetConVarInt(FindConVar("sv_use_steam_voice"), 0);

	// Multiplayer ConVars
	ResetConVar(FindConVar("mp_stalemate_enable"));
	ResetConVar(FindConVar("mp_waitingforplayers_time"));
	ResetConVar(FindConVar("mp_disable_respawn_times"));
	ResetConVar(FindConVar("mp_respawnwavetime"));
	ResetConVar(FindConVar("mp_forcecamera"));
	ResetConVar(FindConVar("mp_idlemaxtime"));
	
	if (!GetConVarBool(ConVar_MTF2UseServerMapTimelimit))
	{
		ResetConVar(FindConVar("mp_timelimit"));
	}

	// TeamFortress ConVars
	ResetConVar(FindConVar("tf_avoidteammates_pushaway"));
	ResetConVar(FindConVar("tf_max_health_boost"));
	ResetConVar(FindConVar("tf_airblast_cray_ground_minz"));
	ResetConVar(FindConVar("tf_player_movement_restart_freeze"));

	ConVar conVar = FindConVar("sm_mapvote_extend");
	if (conVar != INVALID_HANDLE)
	{
		ResetConVar(conVar);
	}

	conVar = FindConVar("sm_umc_vc_extend");
	if (conVar != INVALID_HANDLE)
	{
		ResetConVar(conVar);
	}
}

stock void PrepareConVars()
{
	// Server ConVars	
	SetConVarInt(FindConVar("sv_use_steam_voice"), 1);

	// Multiplayer ConVars
	SetConVarInt(FindConVar("mp_stalemate_enable"), 0);
	SetConVarInt(FindConVar("mp_friendlyfire"), 1);
	SetConVarInt(FindConVar("mp_waitingforplayers_time"), 90);
	SetConVarInt(FindConVar("mp_disable_respawn_times"), 0);
	SetConVarInt(FindConVar("mp_respawnwavetime"), 9999);
	SetConVarInt(FindConVar("mp_forcecamera"), 0);
	SetConVarInt(FindConVar("mp_idlemaxtime"), 8);

	if (!GetConVarBool(ConVar_MTF2UseServerMapTimelimit))
	{
		// If not using mp_timelimit mode, set to 0.
	 	SetConVarInt(FindConVar("mp_timelimit"), 0);
	}

	SetConVarInt(FindConVar("tf_avoidteammates_pushaway"), 0);
	SetConVarFloat(FindConVar("tf_max_health_boost"), 1.0);
	SetConVarFloat(FindConVar("tf_airblast_cray_ground_minz"), 268.3281572999747);
	SetConVarInt(FindConVar("tf_player_movement_restart_freeze"), 0);

	g_hConVarTFFastBuild.BoolValue = false;
	g_hConVarTFWeaponSpreads.BoolValue = true;

	g_hConVarServerGravity.IntValue = 800;
	g_hConVarHostTimescale.FloatValue = 1.0;
	g_hConVarPhysTimescale.FloatValue = 1.0;

	Handle conVar = FindConVar("sm_mapvote_extend");
	if (conVar != INVALID_HANDLE)
	{
		SetConVarInt(conVar, 0);
	}

	conVar = FindConVar("sm_umc_vc_extend");
	if (conVar != INVALID_HANDLE)
	{
		SetConVarInt(conVar, 0);
	}
}

public Action CmdOnPlayerTaunt(int client, const char[] command, int args)
{
	if (!IsPluginEnabled)
	{
		return Plugin_Continue;
	}

	#if defined DEBUG
	PrintToServer("[WWDBG] Client num #%d CmdOnPlayerTaunt. IsBlockingTaunts: %s", client, IsBlockingTaunts ? "True": "False");
	#endif

	return (IsBlockingTaunts ? Plugin_Handled : Plugin_Continue);
}

public Action CmdOnPlayerKill(int client, const char[] command, int args)
{
	if (!IsPluginEnabled)
	{
		return Plugin_Continue;
	}

	#if defined DEBUG
	PrintToServer("[WWDBG] Client num #%d CmdOnPlayerKill. IsBlockingTaunts: %s", client, IsBlockingTaunts ? "True": "False");
	#endif

	return (IsBlockingDeathCommands ? Plugin_Handled : Plugin_Continue);
}


public Action Command_SetGamemode(int client, int args)
{
	if (args != 1)
	{
		ReplyToCommand(client, "[WWR] Usage: sm_changegamemode <gamemodeid>");
		return Plugin_Handled;
	}

	char text[10];
	GetCmdArg(1, text, sizeof(text));

	int id = StringToInt(text);

	if (id < TOTAL_GAMEMODES)
	{
		GamemodeID = id;
		SpecialRoundID = 0;

		ReplyToCommand(client, "[WWR] Gamemode changed to \"%s\".", SystemNames[GamemodeID]);

		PluginForward_SendGamemodeChanged(id);

		return Plugin_Handled;
	}
	
	ReplyToCommand(client, "[WWR] Error: specified gamemode ID is invalid.");
	
	return Plugin_Handled;
}

public Action Command_TriggerBoss(int client, int args)
{
	MinigamesPlayed = BossGameThreshold - 1;

	ReplyToCommand(client, "[WWR] Bossgame will be played shortly.");

	return Plugin_Handled;
}

public void OnMaxRoundsChanged(Handle cvar, const char[] oldVal, const char[] newVal)
{
	int value = StringToInt(newVal);

	MaxRounds = value;
}

public void OnAllowCosmeticsChanged(Handle cvar, const char[] oldVal, const char[] newVal)
{
	int value = StringToInt(newVal);

	AllowCosmetics = value == 1;
}

public bool Config_BonusPointsEnabled()
{
	return GetConVarBool(ConVar_MTF2BonusPoints);
}