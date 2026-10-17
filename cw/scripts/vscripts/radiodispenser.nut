printl("Script started tf2c radio dispenser")

PrecacheSound("weapons/speedcolatheme.mp3")
PrecacheSound("weapons/doubletaptheme.mp3")
PrecacheModel("models/buildables/jukebox/dispenser_light.mdl")
PrecacheModel("models/buildables/jukebox/dispenser_lvl2_light.mdl")
PrecacheModel("models/buildables/jukebox/dispenser_lvl3_light.mdl")

::radiodispenser <- {

    function is_player_using_correct_pda(player){
        for (local wearable = player.FirstMoveChild(); wearable != null; wearable = wearable.NextMovePeer())
            {
                if (wearable.GetClassname() != "tf_weapon_pda_engineer_build"){continue}
                return (wearable.GetAttribute("radio dispenser",33.33) == 1)
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
        dispenserent.SetModel("models/buildables/jukebox/dispenser_light.mdl")

        dispenserent.ValidateScriptScope()
        local scope = dispenserent.GetScriptScope()
        local currentmodel = 1 // 1: lvl1 building, 2: lvl1 ready, 3: lvl2 building, 4: lvl2 ready, 5: lvl3 building, 6: lvl3 ready
        local counter = 0

        scope.thinkradiodispenserbuff2 <- function()
        {
            local currentlvl = NetProps.GetPropInt(self, "m_iUpgradeLevel")
            local maxPlayers = MaxClients().tointeger()
            local dispenserpos = dispenserent.GetOrigin()
            local radius = 200.0 * currentlvl;
            local radiusSqr = radius * radius;

            for (local i = 1; i <= maxPlayers; i++)
            {
                local player = PlayerInstanceFromIndex(i)
                if (player == null)
                    continue
                local delta = dispenserpos - player.GetOrigin();
                //printl("Playerdist: " + delta.LengthSqr())
                if (delta.LengthSqr() <= radiusSqr)
                {
                    player.AddCondEx(137,2.5,null)
                }
            }

            counter++
            if(counter >= 30){
                StopSoundOn("SpeedCola.Theme", dispenserent);
                EmitSoundOn("SpeedCola.Theme", dispenserent);
                counter = 0
            }
            return 2
        }

        scope.thinkradiodispenserbuild <- function()
        {
            local bulidingstate = NetProps.GetPropFloat(self, "m_flPercentageConstructed")
            local isupgrading = NetProps.GetPropInt(self, "m_iState")
            local currentlvl = NetProps.GetPropInt(self, "m_iUpgradeLevel")

            if(bulidingstate >= 0.99 && currentlvl == 1 && isupgrading == 0){
                self.SetModel("models/buildables/jukebox/dispenser_light.mdl")
                counter++
            }else if(bulidingstate >= 0.99 && currentlvl == 2 && isupgrading == 1){
                self.SetModel("models/buildables/jukebox/dispenser_lvl2_light.mdl")
                counter = 0
            }else if(bulidingstate >= 0.99 && currentlvl == 2 && isupgrading == 0){
                self.SetModel("models/buildables/jukebox/dispenser_lvl2_light.mdl")
                counter++
            }else if(bulidingstate >= 0.99 && currentlvl == 3 && isupgrading == 1){
                self.SetModel("models/buildables/jukebox/dispenser_lvl3_light.mdl")
                counter = 0
            }else if(bulidingstate >= 0.99 && currentlvl == 3 && isupgrading == 0){
                self.SetModel("models/buildables/jukebox/dispenser_lvl3_light.mdl")
                counter++
            }

            if(counter > 50){ // this is delayed to make sure we stay with the right model
                NetProps.SetPropString(self, "m_iszScriptThinkFunction", "thinkradiodispenserbuff2")
                EmitSoundOn("SpeedCola.Theme", dispenserent);
                counter = 0
            }

            return 0.01
        }

        AddThinkToEnt(dispenserent, "thinkradiodispenserbuild")
    }

    function OnGameEvent_player_upgradedobject(params)
    {
        local dispenserent = EntIndexToHScript(params.index)
        local builder = GetPlayerFromUserID(params.userid)
        local objecttype = params.object
        if(dispenserent == null){return}
        if(builder == null){return}
        if (objecttype != 0){return}

        if(dispenserent.GetModelName().find("jukebox") == null){return}
        NetProps.SetPropString(dispenserent, "m_iszScriptThinkFunction", "")
        dispenserent.SetModel("models/buildables/jukebox/dispenser_lvl2_light.mdl")
        dispenserent.ValidateScriptScope()
        local scope = dispenserent.GetScriptScope()
        local counter = 0

        scope.thinkradiodispenserbuff <- function()
        {
            local currentlvl = NetProps.GetPropInt(self, "m_iUpgradeLevel")
            local maxPlayers = MaxClients().tointeger()
            local dispenserpos = dispenserent.GetOrigin()
            local radius = 200.0 * currentlvl;
            local radiusSqr = radius * radius;

            for (local i = 1; i <= maxPlayers; i++)
            {
                local player = PlayerInstanceFromIndex(i)
                if (player == null)
                    continue
                local delta = dispenserpos - player.GetOrigin();
                //printl("Playerdist: " + delta.LengthSqr())
                if (delta.LengthSqr() <= radiusSqr)
                {
                    player.AddCondEx(137,2.5,null)
                }
            }
            counter++

            if(counter >= 30){
                StopSoundOn("SpeedCola.Theme", dispenserent);
                EmitSoundOn("SpeedCola.Theme", dispenserent);
                counter = 0
            }
            return 2
        }

        scope.radiodispenserupgrade <- function()
        {
            local isupgrading = NetProps.GetPropInt(self, "m_iState")
            local currentlvl = NetProps.GetPropInt(self, "m_iUpgradeLevel")

            if(isupgrading == 1){
                if(currentlvl == 2){
                    self.SetModel("models/buildables/jukebox/dispenser_lvl2_light.mdl")
                }else if(currentlvl == 3){
                    self.SetModel("models/buildables/jukebox/dispenser_lvl3_light.mdl")
                }
                counter = 0
            }else{
                if(currentlvl == 2){
                    self.SetModel("models/buildables/jukebox/dispenser_lvl2_light.mdl")
                }else if(currentlvl == 3){
                    self.SetModel("models/buildables/jukebox/dispenser_lvl3_light.mdl")
                }
                counter++
            }

            if(counter > 50){ // this is delayed to make sure we stay with the right model
                NetProps.SetPropString(self, "m_iszScriptThinkFunction", "thinkradiodispenserbuff")
                counter = 0
            }

            return 0.01
        }

        AddThinkToEnt(dispenserent, "radiodispenserupgrade")

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
            if(b.GetModelName().find("jukebox") == null && isgoodpda){ // if the current model of the sentry is NOT the tfcsentry and im using the tfcsentry wrench, destroy that sentry
                DoEntFire("!self", "RemoveHealth","999", -1, b, b)
            }

            if(b.GetModelName().find("jukebox") != null && !isgoodpda){ // if the current model of the sentry IS the tfcsentry and im NOT using the tfcsentry wrench, destroy that sentry
                DoEntFire("!self", "RemoveHealth","999", -1, b, b)
            }
        }
    }

    function OnGameEvent_player_carryobject(params)
    {
        local builder = GetPlayerFromUserID(params.userid)
        local objecttype = params.object
        local dispenserent = EntIndexToHScript(params.index)

        local isgoodpda = is_player_using_correct_pda(builder)
        if(isgoodpda && objecttype == 0){
            NetProps.SetPropString(dispenserent, "m_iszScriptThinkFunction", "")
            StopSoundOn("SpeedCola.Theme", dispenserent);
        }
    }
}
__CollectGameEventCallbacks(radiodispenser)
