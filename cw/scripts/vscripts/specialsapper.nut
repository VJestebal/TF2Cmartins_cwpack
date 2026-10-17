//My first tf2 vscript yeah boiiii
printl("Script started")

PrecacheModel("models/buildables/sapper_sentry/sapper_placed.mdl")

::Sentrysapper <- {
    function OnGameEvent_object_destroyed(params)
    { 

        local attacker = GetPlayerFromUserID(params.attacker)
        local weaponstr = params.weapon

        if (weaponstr != null){
            printl("Weapon used: " + weaponstr)
            if (weaponstr == "weapon_sentry_sapper"){
                printl("special sapper detected")
            }else{return}
        }else{return}

        if (attacker != null){
            printl("Destroyed by: " + attacker.GetPlayerName())
        }else{return}

        local objectName = "Unknown"
        if (params.objecttype != 0 && params.objecttype != 2){return}
        switch (params.objecttype)
        {
            case 0: objectName = "Dispenser"; break
            case 1: objectName = "Teleporter Entrance"; break
            case 2: objectName = "Teleporter Exit"; break
            case 3: objectName = "Sentry"; break
        }

        printl(objectName + " destroyed")

        local ent = EntIndexToHScript(params.index)

        if (ent != null)
        {
            local pos = ent.GetOrigin()
            printl("Building destroyed at: " + pos)
            local sentry = SpawnEntityFromTable("obj_sentrygun", {origin = pos})
            if (sentry != null){
                sentry.SetTeam(attacker.GetTeam())
                sentry.SetSkin(attacker.GetTeam()-2)
                sentry.SetModelScale(0.7,0)
                sentry.SetMaxHealth(25)
                sentry.SetHealth(25)
                DoEntFire("!self", "RemoveHealth","125", -1, sentry, sentry)
                DoEntFire("!self", "SetBuilder","", -1, attacker, sentry)


            }
        }
    }

    function OnGameEvent_player_sapped_object(params)
    {
        local sapper = EntIndexToHScript(params.sapperid)
        local player = GetPlayerFromUserID(params.userid)

        if (player != null){
            local weapon = player.GetActiveWeapon()
            if (weapon != null){
                local is_sentrysapper = weapon.GetAttribute("spawn sentry on kill",33.33)
                if (is_sentrysapper != 1){return}
            }else{return}
        }else{return}

        if (sapper != null)
        {
            sapper.SetModel("models/buildables/sapper_sentry/sapper_placed.mdl")
        }
    }

}

__CollectGameEventCallbacks(Sentrysapper)