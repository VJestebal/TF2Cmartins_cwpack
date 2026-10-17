printl("Script started jumpy scatter")

::jumpyscatter <- {
    function OnGameEvent_player_death(params)
    { 

        local attacker = GetPlayerFromUserID(params.attacker)
        local weaponstr = params.weapon

        if (weaponstr != null){
            if (weaponstr == "jumpy_scatter"){
            }else{return}
        }else{return}

        if (attacker != null){
        }else{return}

        local weapon = attacker.GetActiveWeapon()
        if(weapon.GetAttribute("air dash count", 33.3) != 7){
            weapon.AddAttribute("air dash count", 7, 10)
            EntFireByHandle(weapon,"RunScriptCode","self.RemoveAttribute(\"air dash count\")",10,null,null)
        }

    }

}

__CollectGameEventCallbacks(jumpyscatter)
