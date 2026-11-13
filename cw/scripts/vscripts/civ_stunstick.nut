printl("Script started civ_stunstick")

::civ_stunstick <- {
    function OnGameEvent_player_hurt(params)
    {
        local victim = GetPlayerFromUserID(params.userid)
        local attacker = GetPlayerFromUserID(params.attacker)
        if (!victim || !attacker)
            return
        
        local weapon = attacker.GetActiveWeapon()

        if (!weapon)
            return

        if(weapon.GetAttribute("stun on 3rd hit",33.33) != 1){return}
         
        weapon.ValidateScriptScope();
        local scope = weapon.GetScriptScope();
        if(scope.rawin("last_player_hit") && scope.rawin("last_last_player_hit")){
            if(scope.last_player_hit != victim){
                scope.last_player_hit = victim
                return
            }else if(scope.last_last_player_hit != victim){
                scope.last_last_player_hit = victim
            }else{
                victim.StunPlayer(1,1,2,attacker)
                scope.last_player_hit = null
                scope.last_last_player_hit = null
            }
        }else{
            scope.last_player_hit <- victim
            scope.last_last_player_hit <- null
        }

        
    }
}

__CollectGameEventCallbacks(civ_stunstick)