printl("Script started launch")

::shootingstarlaunch <- {

    function OnGameEvent_player_hurt(params)
    {
        local victim = GetPlayerFromUserID(params.userid)
        local attacker = GetPlayerFromUserID(params.attacker)

        if (!victim || !attacker)
            return
        
        local weapon = attacker.GetActiveWeapon()

        if (!weapon)
            return

        if (weapon.GetAttribute("launch to stratosphere", 33.33) != 1)
            return
        
        local damage_dealt = params.damageamount

        
        local vel = victim.GetAbsVelocity()
        vel.z = damage_dealt * 15
        victim.SetAbsVelocity(vel)
    }
}

__CollectGameEventCallbacks(shootingstarlaunch)