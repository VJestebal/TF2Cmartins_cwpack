printl("Script started stun airborn")

::stun_airborn <- {
    function OnGameEvent_player_hurt(params)
    {
        local victim = GetPlayerFromUserID(params.userid)
        local attacker = GetPlayerFromUserID(params.attacker)

        if (!victim || !attacker)
            return

        local weapon = attacker.GetActiveWeapon()
        if (!weapon)
            return

        if (weapon.GetAttribute("stun airborn", 33.33) != 1)
            return

        if (!(victim.GetFlags() & Constants.FPlayer.FL_ONGROUND))
        {
	        victim.StunPlayer(1,1,2,attacker)
        }

    }
}

__CollectGameEventCallbacks(stun_airborn)
