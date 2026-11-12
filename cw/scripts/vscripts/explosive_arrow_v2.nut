
printl("Script started explosive arrow")

PrecacheSound("weapons/grenade_explode2.wav")
PrecacheSound("entities/beep2.wav")

::explosive_arrow <- {

    function OnGameEvent_player_shoot(params)
    {
        local player = GetPlayerFromUserID(params.userid);
        if (player == null || !player.IsAlive())
            return;

        local weapon = player.GetActiveWeapon();

        if (weapon == null)
            return;

        if (weapon.GetAttribute("explosive arrow", 33.33) != 1){return}

        EntFireByHandle(
            player,
            "RunScriptCode",
            "explosive_arrow.FindArrow(self)",
            0,
            null,
            null
        );
        
    }

    function FindArrow(player)
    {

        local arrow = Entities.FindByClassnameNearest(
            "tf2c_projectile_dart",
            player.EyePosition(),
            200.0
        );

        if (arrow == null)
            return;

        if (arrow.GetOwner() != player)
            return;

        arrow.ValidateScriptScope();

        local scope = arrow.GetScriptScope();
        local shoot_time = Time();

        scope.EArrow_attacker <- player;
        scope.EArrow_shoot_time <- shoot_time;
        scope.EArrow_team <- player.GetTeam();
        scope.EArrow_explosion_scheduled <- 0;
        local angles = QAngle(0, 0, 0);
        scope.EArrow_ExplosiveArrowThink <- function()
        {
            local arrow_velocity = self.GetAbsVelocity().Length()
            local arrow_position = self.GetOrigin();
            if(arrow_velocity < 5){
                EArrow_explosion_scheduled++;
            }
            if(EArrow_explosion_scheduled > 9){
                explosive_arrow.Explode_arrow(self,arrow_position,null);
                NetProps.SetPropString(self, "m_iszScriptThinkFunction", "") //stop think function
                return -1
            }
            EmitSoundOn("explosive_arrow.beep", self);
            if(EArrow_team == 2){
                DispatchParticleEffect("repair_claw_heal_red3", arrow_position, angles);
            }else if(EArrow_team == 3){
                DispatchParticleEffect("repair_claw_heal_blue3", arrow_position, angles);
            }
            return 0.2
        }

        AddThinkToEnt(arrow, "EArrow_ExplosiveArrowThink");
    }
   
    function OnGameEvent_arrow_impact(params)
    {
        local victim = EntIndexToHScript(params.attachedEntity)
        local attacker = EntIndexToHScript(params.shooter)
        local boneid = params.boneIndexAttached
        local angles = QAngle(0, 0, 0);

        if (!victim || !attacker)
            return

        if(victim.GetClassname() != "player")return

        local arrow = null
        local best_arrow = null
        local arrow_scope = null
        local best_arrow_scope = null
        while ( arrow = Entities.FindByClassname(arrow, "tf2c_projectile_dart*") )
        {
            arrow_scope = arrow.GetScriptScope();
            if(arrow_scope == null || !arrow_scope.rawin("EArrow_explosion_scheduled"))continue
            if(arrow_scope.EArrow_attacker != attacker)continue
            if(arrow_scope.rawin("EArrow_boneid"))continue
            if(best_arrow == null){
                best_arrow = arrow
            }else{
                best_arrow_scope = best_arrow.GetScriptScope();
                if(arrow_scope.EArrow_shoot_time > best_arrow_scope.EArrow_shoot_time){
                    best_arrow = arrow
                }
            }
        }

        if(!best_arrow)return

        best_arrow_scope = best_arrow.GetScriptScope();
        best_arrow_scope.EArrow_boneid <- boneid;
        best_arrow_scope.EArrow_explosion_scheduled <- 0;
        best_arrow_scope.EArrow_victim <- victim;

        best_arrow_scope.EArrow_ExplosiveArrowHitThink <- function()
        {
            if (EArrow_victim == null || !EArrow_victim.IsValid()){
                NetProps.SetPropString(self, "m_iszScriptThinkFunction", "") //stop think function
                return -1 
            }
            local bone_position = EArrow_victim.GetBoneOrigin(EArrow_boneid);
            if(EArrow_explosion_scheduled > 9){
                explosive_arrow.Explode_arrow(self,bone_position,EArrow_victim);
                NetProps.SetPropString(self, "m_iszScriptThinkFunction", "") //stop think function
                return -1
            }
            EmitSoundOn("explosive_arrow.beep", EArrow_victim);
            if(EArrow_team == 2){
                DispatchParticleEffect("repair_claw_heal_red3", bone_position, angles);
            }else if(EArrow_team == 3){
                DispatchParticleEffect("repair_claw_heal_blue3", bone_position, angles);
            }
            if(!EArrow_victim.IsAlive()){
                explosive_arrow.Explode_arrow(self,bone_position,EArrow_victim);
                NetProps.SetPropString(self, "m_iszScriptThinkFunction", "") //stop think function
                return -1
            }
            EArrow_explosion_scheduled++
            return 0.2
        }

        AddThinkToEnt(best_arrow, "EArrow_ExplosiveArrowHitThink");
    }

    function Explode_arrow(attached_ent,position,victim){
        NetProps.SetPropString(attached_ent, "m_iszScriptThinkFunction", "") //stop think function

        local scope = attached_ent.GetScriptScope();
        if (scope == null)return

        local angles = QAngle(0, 0, 0);
        local attacker = scope.EArrow_attacker
        local team = scope.EArrow_team

        DispatchParticleEffect("ExplosionCore_MidAir", position, angles);
        if(victim != null){
        EmitSoundOn("grenade_explode2.sound", victim);
        }else{
        EmitSoundOn("grenade_explode2.sound", attached_ent);
        }

        // Explosion settings
        local radius = 168.0;
        local maxDamage = 75.0;
        // Find nearby players
        local player = null;

        while ((player = Entities.FindByClassname(player, "player")) != null)
        {
            // Ignore teammates
            if (player.GetTeam() == team)
                continue;

            // Ignore dead players
            if (player.GetHealth() <= 0)
                continue;

            if(victim != null && player == victim){
                player.TakeDamage(75,64,attacker);
                continue
            }

            // Calculate distance
            local distance = (player.GetCenter() - position).Length();

            if (distance > radius)
                continue;

            // Calculate damage
            local damage = 20 + maxDamage * (1.0 - distance / radius);

            if (damage <= 0)
                continue;

            // Apply damage
            player.TakeDamage(
                damage,
                64,
                attacker
            );
        }

        // Find nearby buildings
        local buildingClasses = [
            "obj_sentrygun",
            "obj_dispenser",
            "obj_teleporter"
        ];

        foreach (classname in buildingClasses)
        {
            local building = null;

            while ((building = Entities.FindByClassname(building, classname)) != null)
            {
                // Ignore friendly buildings
                if (building.GetTeam() == team)
                    continue;

                // Calculate distance
                local distance = (building.GetCenter() - position).Length();

                if (distance > radius)
                    continue;

                // Calculate damage
                local damage = maxDamage * (1.0 - distance / radius);

                if (damage <= 0)
                    continue;

                // Apply damage
                building.TakeDamage(
                    damage,
                    64,
                    attacker
                );
            }
        }
    }
}

__CollectGameEventCallbacks(explosive_arrow)
