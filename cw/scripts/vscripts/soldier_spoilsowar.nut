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

    function OnGameEvent_player_hurt(params)
    {
        local victim = GetPlayerFromUserID(params.userid)

        if (!victim)
            return

        if(!victim.InCond(76))return
        if(params.health > 0)return
        EntFireByHandle(victim,"RunScriptCode","soldier_spoilsowar.deghostify_function(self)",0.5,null,null);

    }

    function deghostify_function(victim){

        if(!victim.InCond(77))return
        if(victim.GetCondDuration(77) < 0){
            EntFireByHandle(victim,"RunScriptCode","self.RemoveCond(77)",3,null,null);
        }

    }
    
}

__CollectGameEventCallbacks(soldier_spoilsowar)