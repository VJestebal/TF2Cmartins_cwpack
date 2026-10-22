printl("Script started mrjarate")

::mrjarate <- {

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
            attacker.AddCondEx(24, 5, null)
        }
    }
}

__CollectGameEventCallbacks(mrjarate)

