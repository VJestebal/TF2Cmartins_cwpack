printl("Script started hydraulic hammers")

PrecacheSound("weapons/deflect_smak.mp3")

::deflect_smak <- {
    function OnGameEvent_object_deflected(params)
    {
        local attacker = GetPlayerFromUserID(params.userid )

        if (!attacker)
            return
        
        local weapon = attacker.GetActiveWeapon()

        if (!weapon)
            return

        if(weapon.GetAttribute("deflect on swing2",33.33) != 1){return}
         
        attacker.EmitSound("deflect_on_swing.sound")
    }
}

__CollectGameEventCallbacks(deflect_smak)