printl("Script started indirect hit")

::indirecthit <- {
    function OnScriptHook_OnTakeDamage(params)
    {
        local victim = params.const_entity
        local attacker = params.attacker

        if(!victim.IsPlayer()){return}
        if(!attacker.IsPlayer()){return}

        local weapon = attacker.GetActiveWeapon()
        if (!weapon)
            return

        if (weapon.GetAttribute("minicrit ground", 33.33) != 1)
            return

        if (victim.GetFlags() & Constants.FPlayer.FL_ONGROUND)
        {
	        //printl("Entity is on the ground!")
            params.crit_type = 1
        }

    }
}

__CollectGameEventCallbacks(indirecthit)
