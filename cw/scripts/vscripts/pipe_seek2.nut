
printl("Script started pipe seek")

PrecacheSound("entities/beepbeep.wav")

::pipeseek <- {

    function OnGameEvent_player_shoot(params)
    {
        local player = GetPlayerFromUserID(params.userid);

        if (player == null || !player.IsAlive())
            return;

        local weapon = player.GetActiveWeapon();

        if (weapon == null)
            return;

        if (weapon.GetAttribute("pipe seek", 33.33) != 1){return}

        EntFireByHandle(
            player,
            "RunScriptCode",
            "pipeseek.FindPipe(self)",
            0.1,
            null,
            null
        );
    }

    function FindPipe(player)
    {
        if (player == null || !player.IsAlive())
            return;

        local weapon = player.GetActiveWeapon();

        if (weapon == null)
            return;

        if (weapon.GetAttribute("pipe seek", 33.33) != 1){return}

        local pipe = null;
        local bestPipe = null;
        local bestDistSq = 200 * 200;

        // Find the closest pipe thrown by this player.
        local bestPipe = Entities.FindByClassnameNearest(
            "tf_projectile_pipe",
            player.EyePosition(),
            200.0
        );

        if (bestPipe == null)
            return;

        if (bestPipe.GetThrower() != player)
            return;

        bestPipe.ValidateScriptScope();

        local scope = bestPipe.GetScriptScope();

        scope.owner <- player;
        scope.weapon <- weapon;


        scope.PipeSeekThink <- function()
        {
            if (owner == null || !owner.IsAlive())
                return -1;

            if (weapon == null)
                return -1;

            local bestTarget = null;
            local bestDistSq = 999999999.0;
            self.GetFlags()
            for (local i = 1; i <= MaxClients(); i++)
            {
                
                local ply = PlayerInstanceFromIndex(i);

                if (ply == null)
                    continue;

                if (ply.GetTeam() == owner.GetTeam())
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

            if (bestTarget == null)
                return 0.3;

            local current_z_velocity = self.GetPhysVelocity().z

            // Direction from the pipe to the target.
            local pipePos = self.GetOrigin();
            local targetPos = bestTarget.GetCenter();

            local direction = targetPos - pipePos;

            if (direction.LengthSqr() < 0.11)
                return 0.3;

            direction.Norm();

            // Fixed horizontal speed. Tune this value in-game.
            local BASE_SPEED = 400.0;

            local velocity = Vector(
                direction.x * BASE_SPEED,
                direction.y * BASE_SPEED,
                current_z_velocity
            );

            self.SetPhysVelocity(velocity);
            EmitSoundOn("pipe_seek.beep", self);
            return 0.3;
        }

        EntFireByHandle(
            bestPipe,
            "RunScriptCode",
            "AddThinkToEnt(self, \"PipeSeekThink\");",
            2,
            null,
            null
        );
    }
}

__CollectGameEventCallbacks(pipeseek)
