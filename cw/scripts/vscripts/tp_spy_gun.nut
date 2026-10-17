printl("Script started tp spy gun")

::tpspygun <- {
    function OnGameEvent_projectile_direct_hit(params)
    {
        local attacker = EntIndexToHScript(params.attacker);
        local victim = EntIndexToHScript(params.victim);
        local weaponindex = params.weapon_def_index;

        printl(attacker);
        printl(attacker.GetLocalOrigin());
                printl(params.attacker);


        if (!victim || !attacker)
            return;

        if (weaponindex != 20232)
            return;

        printl("siuuuu");

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