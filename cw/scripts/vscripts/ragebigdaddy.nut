printl("Script started rage big daddy")

PrecacheSound("entities/big_daddy_hurt_1.mp3")
PrecacheSound("entities/big_daddy_hurt_2.mp3")
PrecacheSound("entities/big_daddy_hurt_3.mp3")

::bigdaddyrage <- {
    function OnGameEvent_player_hurt(params)
    {
        local victim = GetPlayerFromUserID(params.userid)
        local attacker = GetPlayerFromUserID(params.attacker)

        if (!victim || !attacker)
            return

        local weapon = victim.GetActiveWeapon()
        if (!weapon)
            return

        if (weapon.GetAttribute("speed boost on take dmg", 33.33) != 1)
            return

        if (!victim.InCond(32)){
            victim.AddCondEx(32, 6, null)
            StopSoundOn("bigdaddy.hurt", victim);
            EmitSoundOn("bigdaddy.hurt", victim);
        }
    }
}

__CollectGameEventCallbacks(bigdaddyrage)