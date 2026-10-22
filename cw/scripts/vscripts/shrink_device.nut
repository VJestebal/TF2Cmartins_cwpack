printl("Script started shrink device")

PrecacheSound("entities/mini_mushroom.mp3")

::shrinkdevice <- {

    function OnGameEvent_player_shoot(params)
    { 

        local player = GetPlayerFromUserID(params.userid)

        if(player == null){return}
        local weapon = player.GetActiveWeapon()
        if (!weapon){return}
        if (weapon.GetAttribute("shrink device desc", 33.33) != 1){return}
        player.SetModelScale(0.35,0.5)
        player.AddCustomAttribute("voice pitch scale",1.5,25)
		player.AddCondEx(41,25,player)
		for (local wearable = player.FirstMoveChild(); wearable != null; wearable = wearable.NextMovePeer())
            {

                if (wearable.GetClassname() != "tf_weapon_knife"){continue}
				player.Weapon_Switch(wearable)
                break

            }
        weapon.AddAttribute("maxammo primary reduced",0,30)
        EntFireByHandle(weapon,"RunScriptCode","self.RemoveAttribute(\"maxammo primary reduced\")",30,null,null)
        EntFireByHandle(player,"RunScriptCode","shrinkdevice.reset_device_ammo(self)",31,null,null)
        EntFireByHandle(player,"RunScriptCode","shrinkdevice.unshrink_player(self)",23,null,null)

    }

    function unshrink_player(player){

        local is_shrinkdevice_present = false

        for (local wearable = player.FirstMoveChild(); wearable != null; wearable = wearable.NextMovePeer())
            {

                if (wearable.GetClassname() != "tf_weapon_shotgun_primary"){continue}
                if (wearable.GetAttribute("shrink device desc",33.33) != 1){continue}
                is_shrinkdevice_present = true
                break

            }

        if(is_shrinkdevice_present){
            player.SetModelScale(1,0.5)
            player.SetAbsOrigin(player.GetOrigin() + Vector(0, 0, 50))
        }

    }

    function reset_device_ammo(player){

        local is_shrinkdevice_present = false

        for (local wearable = player.FirstMoveChild(); wearable != null; wearable = wearable.NextMovePeer())
            {

                if (wearable.GetClassname() != "tf_weapon_shotgun_primary"){continue}
                if (wearable.GetAttribute("shrink device desc",33.33) != 1){continue}
                is_shrinkdevice_present = true
                break
            }

        if(is_shrinkdevice_present){
            NetProps.SetPropIntArray(player, "m_iAmmo", 1, 1)
        }

    }

}

__CollectGameEventCallbacks(shrinkdevice)
