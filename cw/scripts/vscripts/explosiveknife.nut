printl("Script started explosiveknife")

::explosiveknife <- {
    function OnScriptHook_OnTakeDamage(params)
    {
        local victim = params.const_entity
        local attacker = params.attacker
        if (!victim || !attacker)
            return

        if(params.damage_custom != 2){return}
        
        local weapon = attacker.GetActiveWeapon()

        if (!weapon)
            return
        if(weapon.GetAttribute("explosive knife",33.33) != 1){return}
        params.damage = 1
        victim.ValidateScriptScope()
        local scope = victim.GetScriptScope()

        local cyclecounter = 0
        scope.thinkeknife <- function()
        {
            cyclecounter++
            
            printl("Explosion countdown: " + cyclecounter)
            if (!victim.IsAlive()){
                NetProps.SetPropString(victim,"m_iszScriptThinkFunction","")
            }
            if (cyclecounter > 5)
            {
                NetProps.SetPropString(victim, "m_iszScriptThinkFunction", "")

                if (!victim.IsAlive())
                    return

                // Explosion entity
                local explosion = SpawnEntityFromTable(
                    "env_explosion",
                    {
                        origin = victim.GetOrigin(),
                        iMagnitude = 160,
                        iRadiusOverride = 280
                    }
                )

                EntFireByHandle(
                    explosion,
                    "Explode",
                    "",
                    0,
                    attacker,
                    attacker
                )

                EntFireByHandle(
                    explosion,
                    "Kill",
                    "",
                    0.1,
                    attacker,
                    attacker
                )

                // Kill victim
                victim.TakeDamage(1000, 64, attacker)
                StopSoundOn("Instructor.LessonStart", victim);
                return 1
            }else{
                EmitSoundOn("Instructor.LessonStart", victim);
            }



            return 1
        }

        AddThinkToEnt(victim, "thinkeknife")
    }
}

__CollectGameEventCallbacks(explosiveknife)