printl("Script started shield fix")

PrecacheModel("models/buildables/tfcsentry1.mdl")
PrecacheModel("models/buildables/tfcsentry2.mdl")
PrecacheModel("models/buildables/tfcsentry3.mdl")
PrecacheModel("models/buildables/tfcsentry1_heavy.mdl")
PrecacheModel("models/buildables/tfcsentry2_heavy.mdl")
PrecacheModel("models/buildables/tfcsentry3_heavy.mdl")

::tfcsentry <- {

    function is_player_using_correct_wrench(player){
        for (local wearable = player.FirstMoveChild(); wearable != null; wearable = wearable.NextMovePeer())
            {
                if (wearable.GetClassname() != "tf_weapon_wrench"){continue}
                return (wearable.GetAttribute("tfcsentry",33.33) == 1)
            }
        return false
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

        sentryent.SetModel("models/buildables/tfcsentry1_heavy.mdl")

    }

    function OnGameEvent_sentry_on_go_active(params)
    {
        local sentryent = EntIndexToHScript(params.index)
        local builder = NetProps.GetPropEntity(sentryent, "m_hBuilder")
        if(sentryent == null){return}
        if(builder == null){return}
        if(!is_player_using_correct_wrench(builder)){return}
        //sentryent.SetModel("models/buildables/tfcsentry1.mdl")
        EntFireByHandle(sentryent,"RunScriptCode","self.SetModel(\"models/buildables/tfcsentry1.mdl\")",0.01,null,null)
    }

    function OnGameEvent_player_upgradedobject(params)
    {
        local sentryent = EntIndexToHScript(params.index)
        local builder = GetPlayerFromUserID(params.userid)
        local objecttype = params.object
        if(sentryent == null){return}
        if(builder == null){return}
        if (objecttype != 2){return}

        if(!is_player_using_correct_wrench(builder)){return}

        local is_tfcsentry1 = sentryent.GetModelName().find("tfcsentry1.mdl")
        if (is_tfcsentry1 != null){
            EntFireByHandle(sentryent,"RunScriptCode","self.SetModel(\"models/buildables/tfcsentry2_heavy.mdl\")",0.01,null,null) //set sentry lvl 2 building
            sentryent.ValidateScriptScope()
            local scope = sentryent.GetScriptScope()
            scope.thinktfcsentry <- function()
            {
                //printl("Upgrading...")
                if (NetProps.GetPropInt(sentryent, "m_iState") != 3){ // once it finishes upgrading set sentry lvl 2 
                    sentryent.SetModel("models/buildables/tfcsentry2.mdl")
                    NetProps.SetPropString(sentryent, "m_iszScriptThinkFunction", "")
                }
                return 0.01
            }

            AddThinkToEnt(sentryent, "thinktfcsentry")
        }

        local is_tfcsentry2 = sentryent.GetModelName().find("tfcsentry2.mdl")
        if (is_tfcsentry2 != null){
            EntFireByHandle(sentryent,"RunScriptCode","self.SetModel(\"models/buildables/tfcsentry3_heavy.mdl\")",0.01,null,null) //set sentry lvl 3 building
            sentryent.ValidateScriptScope()
            local scope = sentryent.GetScriptScope()
            scope.thinktfcsentry2 <- function()
            {
                //printl("Upgrading...")
                if (NetProps.GetPropInt(sentryent, "m_iState") != 3){ // once it finishes upgrading set sentry lvl 3
                    sentryent.SetModel("models/buildables/tfcsentry3.mdl")
                    NetProps.SetPropString(sentryent, "m_iszScriptThinkFunction", "")
                }
                return 0.01
            }

            AddThinkToEnt(sentryent, "thinktfcsentry2")
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
            sentryent.SetModel("models/buildables/tfcsentry1_heavy.mdl")
            sentryent.ValidateScriptScope()
            local scope = sentryent.GetScriptScope()
            local states1counter = 0
            local currentmodel = 1 // 1: lvl1 building, 2: lvl1 ready, 3: lvl2 building, 4: lvl2 ready, 5: lvl3 building, 6: lvl3 ready
            scope.thinktfcsentry3 <- function()
            {   
                //printl("Rebuilding...")
                local state = NetProps.GetPropInt(sentryent, "m_iState") // 0 = building... 1 = ready 3 = upgrading...
                local currentlvl = NetProps.GetPropInt(sentryent, "m_iUpgradeLevel")

                if (state == 0 && currentlvl == 1){
                    if(currentmodel != 1){
                        sentryent.SetModel("models/buildables/tfcsentry1_heavy.mdl")
                        currentmodel = 1
                        printl("tfcsentry1_heavy")
                        }
                }else if (state == 3 && currentlvl == 2){
                    if(currentmodel != 3){
                        sentryent.SetModel("models/buildables/tfcsentry2_heavy.mdl")
                        currentmodel = 3
                        printl("tfcsentry2_heavy")
                        }
                }else if (state == 3 && currentlvl == 3){
                    if(currentmodel != 5){
                        sentryent.SetModel("models/buildables/tfcsentry3_heavy.mdl")
                        currentmodel = 5
                        printl("tfcsentry3_heavy")
                        }
                }


                if (state == 1 && currentlvl == 1){
                    if(currentmodel != 2){
                        sentryent.SetModel("models/buildables/tfcsentry1.mdl")
                        currentmodel = 2
                        printl("tfcsentry1")
                        }
                }else if(state == 1 && currentlvl == 2){
                    if(currentmodel != 4){
                        sentryent.SetModel("models/buildables/tfcsentry2.mdl")
                        currentmodel = 4
                        printl("tfcsentry2")
                        }
                }else if(state == 1 && currentlvl == 3){
                    if(currentmodel != 6){
                        sentryent.SetModel("models/buildables/tfcsentry3.mdl")
                        currentmodel = 6
                        printl("tfcsentry3")
                        }
                }

                if (state == 1){states1counter++}else{states1counter = 0}
                if(states1counter > 40){ // if we receive consecutive states 1, the sentry has finished building, we can stop the think
                    NetProps.SetPropString(sentryent, "m_iszScriptThinkFunction", "")

                    // make sure we end with the good model
                    if (currentlvl == 1){sentryent.SetModel("models/buildables/tfcsentry1.mdl")}
                    if (currentlvl == 2){sentryent.SetModel("models/buildables/tfcsentry2.mdl")}
                    if (currentlvl == 3){sentryent.SetModel("models/buildables/tfcsentry3.mdl")}
                }
                return 0.01
            }

            AddThinkToEnt(sentryent, "thinktfcsentry3")
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
            if(b.GetModelName().find("tfcsentry") == null && isgoodwrench){ // if the current model of the sentry is NOT the tfcsentry and im using the tfcsentry wrench, destroy that sentry
                DoEntFire("!self", "RemoveHealth","999", -1, b, b)
            }

            if(b.GetModelName().find("tfcsentry") != null && !isgoodwrench){ // if the current model of the sentry IS the tfcsentry and im NOT using the tfcsentry wrench, destroy that sentry
                DoEntFire("!self", "RemoveHealth","999", -1, b, b)
            }
        }
    }

}

__CollectGameEventCallbacks(tfcsentry)
