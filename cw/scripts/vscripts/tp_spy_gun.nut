printl("Script started tp spy gun")

::tpspygun <- {
    function OnGameEvent_projectile_direct_hit(params)
    {
        local attacker = EntIndexToHScript(params.attacker);
        local victim = EntIndexToHScript(params.victim);
        local weaponindex = params.weapon_def_index;

        if (!victim || !attacker)
            return;

        if (weaponindex != 20232)
            return;


        // Guardar posiciones
        local victimPos = victim.GetLocalOrigin(); 
        local attackerPos = attacker.GetLocalOrigin();

        // Intercambiar posiciones
        attacker.SetLocalOrigin(victimPos);
        victim.SetLocalOrigin(attackerPos);

        EmitSoundOn("Building_Teleporter.Receive", attacker);
        EmitSoundOn("Building_Teleporter.Receive", victim);


    }
}

__CollectGameEventCallbacks(tpspygun);