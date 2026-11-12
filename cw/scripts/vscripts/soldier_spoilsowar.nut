printl("Script started soldier_spoilsowar")

::soldier_spoilsowar <- {

    function is_player_using_correct_banner(player){
        for (local wearable = player.FirstMoveChild(); wearable != null; wearable = wearable.NextMovePeer())
            {
                if (wearable.GetClassname() != "tf_weapon_buff_item"){continue}
                return (wearable.GetAttribute("spoils o war",33.33) == 1)
            }
        return false
    }

    function OnGameEvent_player_death(params)
    {
        local victim = GetPlayerFromUserID(params.userid)
        local attacker = GetPlayerFromUserID(params.attacker)

        if (!victim)
            return

        if(!victim.InCond(77))return
        if(victim.GetCondDuration(77) < 0){
            EntFireByHandle(victim,"RunScriptCode","self.RemoveCond(77)",5,null,null);
            return
        }

        EntFireByHandle(victim,"RunScriptCode","soldier_spoilsowar.deghostify_function(self)",0.1,null,null);

    }

    function deghostify_function(victim){

        if(!victim.InCond(77))return
        if(victim.GetCondDuration(77) < 0){
            EntFireByHandle(victim,"RunScriptCode","self.RemoveCond(77)",5,null,null);
        }

    }
    
}

__CollectGameEventCallbacks(soldier_spoilsowar)