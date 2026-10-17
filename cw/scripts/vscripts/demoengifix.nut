printl("Script started shield fix")

PrecacheModel("models/player/demoshieldfix/demo.mdl")
PrecacheModel("models/player/gunslingerfix/engineer.mdl")

::shieldfix <- {
    function OnGameEvent_player_spawn(params)
    {
        local spawnedplayer = GetPlayerFromUserID(params.userid)
        if (spawnedplayer.GetPlayerClass() != 4){return}
        for (local wearable = spawnedplayer.FirstMoveChild(); wearable != null; wearable = wearable.NextMovePeer())
            {
                if (wearable.GetClassname() != "tf_wearable_demoshield")
                    continue
                printl(wearable)
                spawnedplayer.SetCustomModelWithClassAnimations("models/player/demoshieldfix/demo.mdl")
            }
    }
}

::armfix <- {
    function OnGameEvent_player_spawn(params)
    {
        local spawnedplayer = GetPlayerFromUserID(params.userid)
        if (spawnedplayer.GetPlayerClass() != 9){return}
        for (local wearable = spawnedplayer.FirstMoveChild(); wearable != null; wearable = wearable.NextMovePeer())
            {
                if (wearable.GetClassname() != "tf_weapon_robot_arm")
                    continue
                printl(wearable)
                spawnedplayer.SetCustomModelWithClassAnimations("models/player/gunslingerfix/engineer.mdl")
            }
    }
	function OnGameEvent_player_death(params)
    {
        local player = GetPlayerFromUserID(params.userid)

        if (!player || !player.IsValid())
            return

        // Restore default model before ragdoll creation
        player.SetCustomModel("")
    }
}

__CollectGameEventCallbacks(shieldfix)
__CollectGameEventCallbacks(armfix)