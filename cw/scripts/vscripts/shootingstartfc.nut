printl("Script started launch")

::shootingstarlaunch <- {
    function OnScriptHook_OnTakeDamage(params)
    {
        local victim = params.const_entity
        local attacker = params.attacker

        if (!victim || !attacker)
            return

        if (params.damage_custom != 1)
            return

        local weapon = attacker.GetActiveWeapon()
        if (!weapon)
            return

        if (weapon.GetAttribute("launch to stratosphere", 33.33) != 1)
            return

        local vel = victim.GetAbsVelocity()
        vel.z = 3000.0
        victim.SetAbsVelocity(vel)
    }
}

__CollectGameEventCallbacks(shootingstarlaunch)