printl("Script started mrjarate")

PrecacheModel("models/player/mrjarate/sniper.mdl")

::mrjarate <- {
    function OnGameEvent_post_inventory_application(params)
    {
        local spawnedplayer = GetPlayerFromUserID(params.userid)

        if(!spawnedplayer)return        
        
        if (spawnedplayer.GetPlayerClass() != 2){return}

        for (local wearable = spawnedplayer.FirstMoveChild(); wearable != null; wearable = wearable.NextMovePeer())
            {
                if (wearable.GetClassname() != "tf_wearable")
                    continue
                if (wearable.GetAttribute("mrjarate", 33.33) != 1)
                    continue
                spawnedplayer.SetCustomModelWithClassAnimations("models/player/mrjarate/sniper.mdl")
                return
            }
        spawnedplayer.SetCustomModel("")
        return
    }

    function OnGameEvent_player_hurt(params)
    {
        local victim = GetPlayerFromUserID(params.userid)
        local attacker = GetPlayerFromUserID(params.attacker)

        if (!victim || !attacker)
            return

        if (victim.GetPlayerClass() != 2){return}

        local is_mrjarate = false

        for (local wearable = victim.FirstMoveChild(); wearable != null; wearable = wearable.NextMovePeer())
            {
                if (wearable.GetClassname() != "tf_wearable")
                    continue
                if (wearable.GetAttribute("mrjarate", 33.33) != 1)
                    continue
                is_mrjarate = true
                break
            }

        if (!attacker.InCond(24) && is_mrjarate){
            attacker.AddCondEx(24, 4, null)
        }
    }
}

__CollectGameEventCallbacks(mrjarate)

