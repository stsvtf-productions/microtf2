/**
 * MicroTF2 - Minigame 27
 *
 * Hit someone! 
 */

public void Minigame27_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame27_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame27_OnMinigameSelected);
	AddToForward(GlobalForward_OnPlayerTakeDamage, INVALID_HANDLE, Minigame27_OnPlayerTakeDamage);
}

public void Minigame27_OnMinigameSelectedPre()
{
	if (MinigameID == 27)
	{
		IsBlockingDamage = false;
	}
}

public void Minigame27_OnMinigameSelected(int client)
{
	if (MinigameID != 27)
	{
		return;
	}

	if (!IsMinigameActive)
	{
		return;
	}

	Player player = new Player(client);

	if (player.IsValid)
	{
		player.Class = TFClass_Scout;
		player.RemoveAllWeapons();
		player.SetGodMode(false);
		player.SetHealth(30);
		player.GiveWeapon(325);
	}
}

public void Minigame27_OnPlayerTakeDamage(int victimId, int attackerId, float damage)
{
	if (IsMinigameActive && MinigameID == 27)
	{
		Player victim = new Player(victimId);
		Player attacker = new Player(attackerId);

		if (attacker.IsValid && attacker.IsParticipating && victim.IsValid && victim.IsParticipating && victim.ClientId != attacker.ClientId)
		{
			attacker.TriggerSuccess();
		}
	}
}