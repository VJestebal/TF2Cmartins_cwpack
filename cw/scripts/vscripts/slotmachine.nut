printl("Script started slotmachine")

PrecacheModel("models/buildables/slot_machine/slot_machine_heavy.mdl")
PrecacheModel("models/buildables/slot_machine/slot_machine.mdl")
PrecacheSound("entities/cash_register.mp3")
PrecacheSound("entities/limbus_company_coin.mp3")
PrecacheSound("entities/slotmachine2.mp3")

::slotmachine <- {

    function is_player_using_correct_wrench(player){
        for (local wearable = player.FirstMoveChild(); wearable != null; wearable = wearable.NextMovePeer())
            {
                if (wearable.GetClassname() != "tf_weapon_wrench"){continue}
                return (wearable.GetAttribute("slotmachine",33.33) == 1)
            }
        return false
    }

    function OnScriptHook_OnTakeDamage(params)
    {
        local victim = params.const_entity
        local attacker = params.attacker
        local weapon = params.weapon
        if(victim == null){return}
        if(attacker == null){return}
        if(weapon == null){return}
        if(!is_player_using_correct_wrench(attacker)){return}
        if(weapon.GetClassname() != "obj_sentrygun"){return}
        params.crit_type = 1
    }

    function OnGameEvent_player_builtobject(params)
    {
        local sentryent = EntIndexToHScript(params.index)
        local builder = GetPlayerFromUserID(params.userid)
        local objecttype = params.object
        if(sentryent == null){return}
        if(builder == null){return}
        if (objecttype != 2){return}

        if(!is_player_using_correct_wrench(builder)){return}
        NetProps.SetPropInt(sentryent, "m_bMiniBuilding", 1)
        DoEntFire("!self", "SetHealth", "75", 0, null, sentryent)
        DoEntFire("!self", "AddOutput", "max_health 150", 0, null, sentryent)
        sentryent.SetModel("models/buildables/slot_machine/slot_machine_heavy.mdl")
        local skin = builder.GetTeam() - 2
        EntFireByHandle(sentryent,"RunScriptCode","self.SetSkin("+ skin +")",0.01,null,null)
    }

    function OnGameEvent_sentry_on_go_active(params2)
    {
        local sentryent = EntIndexToHScript(params2.index)
        local builder = NetProps.GetPropEntity(sentryent, "m_hBuilder")
        if(sentryent == null){return}
        if(builder == null){return}
        if(!is_player_using_correct_wrench(builder)){return}
        //sentryent.SetModel("models/buildables/tfcsentry1.mdl")

        EntFireByHandle(sentryent,"RunScriptCode","self.SetModel(\"models/buildables/slot_machine/slot_machine.mdl\")",0.01,null,null)
        sentryent.ValidateScriptScope();
        sentryent.GetScriptScope().ModifyEmitSoundParams <- function()
        {            
            if(params.GetSoundName() == "Building_Sentrygun.Idle"){
                params.SetSoundName("cash_register")
            }else if(params.GetSoundName() == "Building_MiniSentrygun.Fire"){
                params.SetSoundName("limbus_company_coin")
            }else if(params.GetSoundName() == "Building_Sentrygun.Alert"){
                params.SetSoundName("slotmachine2")
            }
        }
    }

    function OnGameEvent_player_dropobject(params){
            local sentryent = EntIndexToHScript(params.index)
            local builder = GetPlayerFromUserID(params.userid)
            local objecttype = params.object
            if(sentryent == null){return}
            if(builder == null){return}
            if (objecttype != 2){return}

            if(!is_player_using_correct_wrench(builder)){return}
            sentryent.SetModel("models/buildables/slot_machine/slot_machine_heavy.mdl")
            sentryent.ValidateScriptScope()
            local scope = sentryent.GetScriptScope()
            local states1counter = 0
            local currentmodel = 1 // 1: lvl1 building, 2: lvl1 ready, 3: lvl2 building, 4: lvl2 ready, 5: lvl3 building, 6: lvl3 ready
            scope.thinkslotmachine <- function()
            {   
                //printl("Rebuilding...")
                local state = NetProps.GetPropInt(sentryent, "m_iState") // 0 = building... 1 = ready 3 = upgrading...
                local currentlvl = NetProps.GetPropInt(sentryent, "m_iUpgradeLevel")

                if (state == 0 && currentlvl == 1){
                    if(currentmodel != 1){
                        sentryent.SetModel("models/buildables/slot_machine/slot_machine.mdl")
                        currentmodel = 1
                        }
                }


                if (state == 1 && currentlvl == 1){
                    if(currentmodel != 2){
                        sentryent.SetModel("models/buildables/slot_machine/slot_machine.mdl")
                        currentmodel = 2
                        }
                }

                if (state == 1){states1counter++}else{states1counter = 0}
                if(states1counter > 40){ // if we receive consecutive states 1, the sentry has finished building, we can stop the think
                    NetProps.SetPropString(sentryent, "m_iszScriptThinkFunction", "")

                    // make sure we end with the good model
                    if (currentlvl == 1){sentryent.SetModel("models/buildables/slot_machine/slot_machine.mdl")}
                }
                return 0.01
            }

            AddThinkToEnt(sentryent, "thinkslotmachine")
    }

    function OnGameEvent_post_inventory_application(params)
    {
        local builder = GetPlayerFromUserID(params.userid)
        if(builder == null){return}

        local buildings = []
        local ent = null

        while ((ent = Entities.FindByClassname(ent, "obj_sentrygun")) != null)
        {
            if (NetProps.GetPropEntity(ent, "m_hBuilder") == builder)
            {
                buildings.append(ent)
            }
        }
        if (buildings.len() == 0){return}

        local isgoodwrench = is_player_using_correct_wrench(builder)

        foreach(b in buildings)
        {
            if(b.GetModelName().find("slot_machine") == null && isgoodwrench){ // if the current model of the sentry is NOT the tfcsentry and im using the tfcsentry wrench, destroy that sentry
                DoEntFire("!self", "RemoveHealth","999", -1, b, b)
            }

            if(b.GetModelName().find("slot_machine") != null && !isgoodwrench){ // if the current model of the sentry IS the tfcsentry and im NOT using the tfcsentry wrench, destroy that sentry
                DoEntFire("!self", "RemoveHealth","999", -1, b, b)
            }
        }
    }

}

__CollectGameEventCallbacks(slotmachine)
