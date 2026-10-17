printl("Script started civ_stunstick")

::civ_stunstick <- {
    function OnGameEvent_player_hurt(params)
    {
        local victim = GetPlayerFromUserID(params.userid)
        local attacker = GetPlayerFromUserID(params.attacker)

        if (!victim || !attacker)
            return
        
        local weapon = attacker.GetActiveWeapon()

        if (!weapon)
            return

        if(weapon.GetAttribute("stun on full charge",33.33) != 1){return}
         
        if(params.damageamount  < 35){return}

        victim.StunPlayer(1,1,2,attacker)
    }
}

__CollectGameEventCallbacks(civ_stunstick)