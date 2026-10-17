printl("Script started heat seek")

::heatseek <- {

    function OnGameEvent_player_shoot(params)
    { 

        local player = GetPlayerFromUserID(params.userid)

        if(player == null){return}
        local weapon = player.GetActiveWeapon()
        if (!weapon){return}
        if (weapon.GetAttribute("heat seek", 33.33) != 1){return}
        local rocket = null;

        EntFireByHandle(player,
            "RunScriptCode",
            "heatseek.FindRocket(self)",
            0.1,
            null,
            null);

    }

    function FindRocket(player)
    {
        local rocket = Entities.FindByClassnameNearest(
            "tf_projectile_rocket",
            player.EyePosition(),
            200.0
        );

        

        if (rocket && rocket.GetOwner() == player)
        {
            rocket.ValidateScriptScope();

            local scope = rocket.GetScriptScope();
            scope.owner <- player;

            scope.HeatSeekThink <- function()
            {
                local bestTarget = null;
                local bestDistSq = 999999999.0;

                if(!owner.IsAlive()){return 0.1}

                if(owner.GetActiveWeapon().GetAttribute("heat seek", 33.33) != 1){return 0.1}

                for (local i = 1; i <= MaxClients(); i++)
                {
                    local ply = PlayerInstanceFromIndex(i);
                    if (!ply) continue;

                    if (ply.GetTeam() == owner.GetTeam())
                        continue;

                    if (!ply.InCond(22))
                        continue;

                    if (!ply.IsAlive())
                        continue;

                    if (!self.IsEntVisible(ply))
                        continue;

                    local delta = ply.GetCenter() - self.GetOrigin();
                    local distSq = delta.LengthSqr();

                    if (distSq < bestDistSq)
                    {
                        bestDistSq = distSq;
                        bestTarget = ply;
                    }
                }

                if(bestTarget == null){return 0.1}

                local velocity = self.GetAbsVelocity();
                local speed = velocity.Length();

                local currentDir = velocity;
                currentDir.Norm();

                local desiredDir = bestTarget.GetCenter() - self.GetOrigin();
                desiredDir.Norm();

                // Turn rate (0 = never turn, 1 = instant turn)
                local turnRate = 0.4;

                local newDir = currentDir * (1.0 - turnRate) + desiredDir * turnRate;
                newDir.Norm();

                self.SetAbsVelocity(newDir * speed);

                return 0.1; // Ejecutar de nuevo dentro de 0.05 segundos
            }

            AddThinkToEnt(rocket, "HeatSeekThink");
        }
    }

    function OnGameEvent_player_hurt(params)
    {
        local victim = GetPlayerFromUserID(params.userid)
        local attacker = GetPlayerFromUserID(params.attacker)

        if (!victim || !attacker)
            return

        local weapon = attacker.GetActiveWeapon()
        if (!weapon)
            return

        if (weapon.GetAttribute("extinguish on hit", 33.33) != 1)
            return
        if (victim == null){return}
        if (params.minicrit == 1 && victim.InCond(22)){        
            EntFireByHandle(victim,
            "RunScriptCode",
            "heatseek.extinguish_player(self)",
            0.1,
            null,
            null);}
    }

    function extinguish_player(player){
        if(!player.IsAlive()){return}
        player.ExtinguishPlayerBurning()
    }

}

__CollectGameEventCallbacks(heatseek)
