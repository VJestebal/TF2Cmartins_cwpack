printl("Script started tfc minidispenser")

PrecacheModel("models/buildables/mini_dispenser.mdl")
PrecacheModel("models/buildables/mini_dispenser_light.mdl")
PrecacheModel("models/buildables/mini_dispenser_blueprint.mdl")
PrecacheModel("models/buildables/gibs/mini_dispenser_gib1.mdl")
PrecacheModel("models/buildables/gibs/mini_dispenser_gib2.mdl")
PrecacheModel("models/buildables/gibs/mini_dispenser_gib3.mdl")
PrecacheModel("models/buildables/gibs/mini_dispenser_gib4.mdl")
PrecacheModel("models/buildables/gibs/mini_dispenser_gib5.mdl")


::minidispensertfc <- {

    function is_player_using_correct_pda(player){
        for (local wearable = player.FirstMoveChild(); wearable != null; wearable = wearable.NextMovePeer())
            {
                if (wearable.GetClassname() != "tf_weapon_pda_engineer_build"){continue}
                return (wearable.GetAttribute("mini dispenser",33.33) == 1)
            }
        return false
    }

    function OnGameEvent_player_builtobject(params)
    {
        local dispenserent = EntIndexToHScript(params.index)
        local builder = GetPlayerFromUserID(params.userid)
        local objecttype = params.object
        if(dispenserent == null){return}
        if(builder == null){return}
        if (objecttype != 0){return}

        if(!is_player_using_correct_pda(builder)){return}
        NetProps.SetPropString(dispenserent, "m_iszScriptThinkFunction", "")
        dispenserent.SetModel("models/buildables/mini_dispenser.mdl")
        NetProps.SetPropInt(dispenserent, "m_bMiniBuilding", 1)
        DoEntFire("!self", "SetHealth", "51", 0, null, dispenserent)
	    DoEntFire("!self", "AddOutput", "max_health 100", 0, null, dispenserent)

        dispenserent.ValidateScriptScope()
        local scope = dispenserent.GetScriptScope()
        local counter = 0
        scope.thinkminid <- function()
        {
            local state = NetProps.GetPropFloat(self, "m_flPercentageConstructed")
            if (state >=  0.99){
                counter++
                self.SetModel("models/buildables/mini_dispenser_light.mdl")
                if(counter > 50){ // this is delayed to make sure we stay with the right model
                    NetProps.SetPropString(self, "m_iszScriptThinkFunction", "")
                    counter = 0
                }
                local AmmoDisplayPanel = null
				while ( AmmoDisplayPanel = Entities.FindByClassname(AmmoDisplayPanel, "vgui_screen") )
					{
						if (builder == NetProps.GetPropEntity(AmmoDisplayPanel, "m_hPlayerOwner") )
						{
							AmmoDisplayPanel.Destroy()
							return 0.01
						}
					}
            }
            //printl(state)
            return 0.01
        }
        AddThinkToEnt(dispenserent, "thinkminid")

    }

        function OnGameEvent_post_inventory_application(params)
    {
        local builder = GetPlayerFromUserID(params.userid)
        if(builder == null){return}

        local buildings = []
        local ent = null

        while ((ent = Entities.FindByClassname(ent, "obj_dispenser")) != null)
        {
            if (NetProps.GetPropEntity(ent, "m_hBuilder") == builder)
            {
                buildings.append(ent)
            }
        }
        if (buildings.len() == 0){return}

        local isgoodpda = is_player_using_correct_pda(builder)

        foreach(b in buildings)
        {
            if(b.GetModelName().find("mini_dispenser") == null && isgoodpda){ // if the current model of the sentry is NOT the tfcsentry and im using the tfcsentry wrench, destroy that sentry
                DoEntFire("!self", "RemoveHealth","999", -1, b, b)
            }

            if(b.GetModelName().find("mini_dispenser") != null && !isgoodpda){ // if the current model of the sentry IS the tfcsentry and im NOT using the tfcsentry wrench, destroy that sentry
                DoEntFire("!self", "RemoveHealth","999", -1, b, b)
            }
        }
    }

    function OnGameEvent_player_carryobject(params)
    {
        local builder = GetPlayerFromUserID(params.userid)
        local objecttype = params.object
        local dispenserent = EntIndexToHScript(params.index)
        
        
        if ( objecttype == 0 && NetProps.GetPropInt(dispenserent, "m_bMiniBuilding") == 1 )
        {
            NetProps.SetPropString(dispenserent, "m_iszScriptThinkFunction", "")
            //This is kinda jank
            //vscript thinks too fast, so we use DoEntFire to make a delay to actually get the model to display
            //DoEntFire("!self", "AddOutput", "modelindex "+GetModelIndex(OBJ_MODEL.OBJ_MINIDISPENSER_BLUEPRINT), -1, buildingindex, buildingindex)
            EntFireByHandle(dispenserent,"RunScriptCode","self.SetModel(\"models/buildables/mini_dispenser_blueprint.mdl\")",0.05,null,null)
            EntFireByHandle(dispenserent,"RunScriptCode","self.SetModel(\"models/buildables/mini_dispenser_blueprint.mdl\")",0.1,null,null)
        }
    }
}

__CollectGameEventCallbacks(minidispensertfc)
