if Config.Framework == "qb" then
	local Skating = {}
	local player = nil
	local QBCore = exports["qb-core"]:GetCoreObject()
	Connected = false
	RegisterNetEvent("astudios-skating:client:start", function() Skating.Start() end)
	Skating.Start = function()
		if DoesEntityExist(Skating.Entities) then return end Skating.Spawn()
		while DoesEntityExist(Skating.Entities) and DoesEntityExist(Skating.Player) do Wait(5)
			local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()),  GetEntityCoords(Skating.Entities), true) Skating.HandleKeys(distance)
			if distance <= Config.LoseConnectionDistance then
				if not NetworkHasControlOfEntity(Skating.Player) then
					NetworkRequestControlOfEntity(Skating.Player)
				elseif not NetworkHasControlOfEntity(Skating.Entities) then
					NetworkRequestControlOfEntity(Skating.Entities)
				end
			else TaskVehicleTempAction(Skating.Player, Skating.Entities, 6, 2500) end
		end
	end
	Skating.MustRagdoll = function()
		local x = GetEntityRotation(Skating.Entities).x
		local y = GetEntityRotation(Skating.Entities).y
		if ((-60.0 < x and x > 60.0)) and IsEntityInAir(Skating.Entities) and Skating.Speed < 5.0 then return true end	
		if (HasEntityCollidedWithAnything(GetPlayerPed(-1)) and Skating.Speed > 5.0) then return true end
		if IsPedDeadOrDying(player, false) then return true end return false
	end
	Skating.HandleKeys = function(distance)
		local forward = IsControlPressed(0, 32)
		local backward = IsControlPressed(0, 33)
		local left = IsControlPressed(0, 34)
		local right = IsControlPressed(0, 35)
		if distance <= 1.5 and IsControlJustPressed(0, 38) then
			Skating.Connect("pickupskateboard")
		elseif distance <= 1.5 and IsControlJustReleased(0, 113) then
			if Connected then Skating.ConnectPlayer(false)
			elseif not IsPedRagdoll(player) then Wait(200) Skating.ConnectPlayer(true) end
		end
		if distance < Config.LoseConnectionDistance then
			local overSpeed = (GetEntitySpeed(Skating.Entities)*3.6) > Config.MaxSpeedKmh
			TaskVehicleTempAction(Skating.Player, Skating.Entities, 1, 1)
			ForceVehicleEngineAudio(Skating.Entities, 0)
			CreateThread(function()
				player = GetPlayerPed(-1) Wait(1)
				SetEntityInvincible(Skating.Entities, true)
				StopCurrentPlayingAmbientSpeech(Skating.Player)	
				if Connected then
					Skating.Speed = GetEntitySpeed(Skating.Entities) * 3.6
					if Skating.MustRagdoll() then Skating.ConnectPlayer(false) SetPedToRagdoll(player, 5000, 4000, 0, true, true, false) Connected = false end
				end
			end)
			if forward and not backward and not overSpeed then
				TaskVehicleTempAction(Skating.Player, Skating.Entities, 9, 1)
			end
			if IsControlPressed(0, 22) and Connected then
				if not IsEntityInAir(Skating.Entities) then	
					local vel = GetEntityVelocity(Skating.Entities)
					TaskPlayAnim(PlayerPedId(), "move_crouch_proto", "idle_intro", 5.0, 8.0, -1, 0, 0, false, false, false)
					local duration = 0 local boosting = 0
					while IsControlPressed(0, 22) do Wait(10) duration = duration + 10.0 end
					boosting = Config.maxJumpHeigh * duration / 250.0
					if boosting > Config.maxJumpHeigh then boosting = Config.maxJumpHeigh end
					StopAnimTask(PlayerPedId(), "move_crouch_proto", "idle_intro", 1.0)
					if(Connected) then SetEntityVelocity(Skating.Entities, vel.x, vel.y, vel.z + boosting)
						TaskPlayAnim(player, "move_strafe@stealth", "idle", 8.0, 2.0, -1, 1, 1.0, false, false, false)
					end
				end
			end
			if IsControlJustReleased(0, 32) or IsControlJustReleased(0, 33) and not overSpeed then
				TaskVehicleTempAction(Skating.Player, Skating.Entities, 6, 2500)
			end
			if backward and not forward and not overSpeed then
				TaskVehicleTempAction(Skating.Player, Skating.Entities, 22, 1)
			end
			if left and backward and not overSpeed then
				TaskVehicleTempAction(Skating.Player, Skating.Entities, 13, 1)
			end
			if right and backward and not overSpeed then
				TaskVehicleTempAction(Skating.Player, Skating.Entities, 14, 1)
			end
			if forward and backward and not overSpeed then
				TaskVehicleTempAction(Skating.Player, Skating.Entities, 30, 100)
			end
			if left and forward and not overSpeed then
				TaskVehicleTempAction(Skating.Player, Skating.Entities, 7, 1)
			end
			if right and forward and not overSpeed then
				TaskVehicleTempAction(Skating.Player, Skating.Entities, 8, 1)
			end
			if left and not forward and not backward and not overSpeed then
				TaskVehicleTempAction(Skating.Player, Skating.Entities, 4, 1)
			end
			if right and not forward and not backward and not overSpeed then
				TaskVehicleTempAction(Skating.Player, Skating.Entities, 5, 1)
			end
		end
	end
	Skating.Spawn = function()
		Skating.LoadModels({ GetHashKey("bmx"), 68070371, GetHashKey("p_defilied_ragdoll_01_s"), "pickup_object", "move_strafe@stealth", "move_crouch_proto"})
		local spawnCoords, spawnHeading = GetEntityCoords(PlayerPedId()) + GetEntityForwardVector(PlayerPedId()) * 2.0, GetEntityHeading(PlayerPedId())
		Skating.Entities = CreateVehicle(GetHashKey("bmx"), spawnCoords, spawnHeading, true)
		Skating.Board = CreateObject(GetHashKey("p_defilied_ragdoll_01_s"), 0.0, 0.0, 0.0, true, true, true)
		while not DoesEntityExist(Skating.Entities) do Wait(5) end
		while not DoesEntityExist(Skating.Board) do Wait(5) end
		SetEntityNoCollisionEntity(Skating.Entities, player, false)
		SetEntityCollision(Skating.Entities, false, true)
		SetEntityVisible(Skating.Entities, false)
		AttachEntityToEntity(Skating.Board, Skating.Entities, GetPedBoneIndex(PlayerPedId(), 28422), 0.0, 0.0, -0.40, 0.0, 0.0, 90.0, false, true, true, true, 1, true)
		Skating.Player = CreatePed(12	, 68070371, spawnCoords, spawnHeading, true, true)
		SetEnableHandcuffs(Skating.Player, true)
		SetEntityInvincible(Skating.Player, true)
		SetEntityVisible(Skating.Player, false)
		FreezeEntityPosition(Skating.Player, true)
		TaskWarpPedIntoVehicle(Skating.Player, Skating.Entities, -1)
		while not IsPedInVehicle(Skating.Player, Skating.Entities) do Wait(0) end Skating.Connect("placeskateboard")
	end
	Skating.Connect = function(param)
		if not DoesEntityExist(Skating.Entities) then return end
		if param == "placeskateboard" then
			AttachEntityToEntity(Skating.Entities, PlayerPedId(), GetPedBoneIndex(PlayerPedId(),  28422), -0.1, 0.0, -0.2, 70.0, 0.0, 270.0, 1, 1, 0, 0, 2, 1)
			TaskPlayAnim(PlayerPedId(), "pickup_object", "pickup_low", 8.0, -8.0, -1, 0, 0, false, false, false) Wait(800)
			DetachEntity(Skating.Entities, false, true)
			PlaceObjectOnGroundProperly(Skating.Entities)
			QBCore.Functions.Notify(Config.Language.Info['controls'], "primary") -- Comment if you don't wanna use this
			-- exports['astudios-notify']:notify("", Config.Language.Info['controls'], 8000, 'info') -- Uncomment if you wanna use this
			-- exports['okokNotify']:Alert("", Config.Language.Info['controls'], 8000, 'info') -- Uncomment if you wanna use this
		elseif param == "pickupskateboard" then
			TaskPlayAnim(PlayerPedId(), "pickup_object", "pickup_low", 8.0, -8.0, -1, 0, 0, false, false, false) Wait(600)
			AttachEntityToEntity(Skating.Entities, PlayerPedId(), GetPedBoneIndex(PlayerPedId(),  28422), -0.1, 0.0, -0.2, 70.0, 0.0, 270.0, 1, 1, 0, 0, 2, 1)
			Wait(900) Skating.Clear()
		end
	end
	Skating.Clear = function(models)
		DetachEntity(Skating.Entities)
		DeleteEntity(Skating.Board)
		DeleteVehicle(Skating.Entities)
		DeleteEntity(Skating.Player)
		Skating.UnloadModels()
		Attach = false
		Connected  = false
		SetPedRagdollOnCollision(player, false)
	end
	Skating.LoadModels = function(models)
		for modelIndex = 1, #models do
			local model = models[modelIndex]
			if not Skating.Models then Skating.Models = {} end
			table.insert(Skating.Models, model)
			if IsModelValid(model) then
				while not HasModelLoaded(model) do RequestModel(model)	Wait(10) end
			else
				while not HasAnimDictLoaded(model) do RequestAnimDict(model) Wait(10) end    
			end
		end
	end
	Skating.UnloadModels = function()
		for modelIndex = 1, #Skating.Models do
			local model = Skating.Models[modelIndex]
			if IsModelValid(model) then
				SetModelAsNoLongerNeeded(model)
			else
				RemoveAnimDict(model)   
			end
		end
	end
	Skating.ConnectPlayer = function(toggle)
		if toggle then
			TaskPlayAnim(player, "move_strafe@stealth", "idle", 8.0, 8.0, -1, 1, 1.0, false, false, false)
			AttachEntityToEntity(player, Skating.Entities, 20, 0.0, 0, 0.7, 0.0, 0.0, -15.0, true, true, false, true, 1, true)
			SetEntityCollision(player, true, true)
			TriggerServerEvent("astudios-skating:server:skate")
		elseif not toggle then
			DetachEntity(player, false, false)
			StopAnimTask(player, "move_strafe@stealth", "idle", 1.0)
			StopAnimTask(PlayerPedId(), "move_crouch_proto", "idle_intro", 1.0)
			TaskVehicleTempAction(Skating.Player, Skating.Entities, 3, 1)	
		end	
		Connected = toggle
	end
	RegisterNetEvent("astudios-skating:client:skate", function(id)
		local player = GetPlayerFromServerId(id)
		local vehicle = GetEntityAttachedTo(GetPlayerPed(player))
	end)
elseif Config.Framework == "esx" then
	ESX = exports["es_extended"]:getSharedObject()
	local Skating = {}
	local player = nil
	Connected = false

	RegisterNetEvent("astudios-skating:client:start", function() Skating.Start() end)

	Skating.Start = function()
		if DoesEntityExist(Skating.Entities) then return end Skating.Spawn()
		while DoesEntityExist(Skating.Entities) and DoesEntityExist(Skating.Player) do Wait(5)
			local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()),  GetEntityCoords(Skating.Entities), true) Skating.HandleKeys(distance)
			if distance <= Config.LoseConnectionDistance then
				if not NetworkHasControlOfEntity(Skating.Player) then
					NetworkRequestControlOfEntity(Skating.Player)
				elseif not NetworkHasControlOfEntity(Skating.Entities) then
					NetworkRequestControlOfEntity(Skating.Entities)
				end
			else TaskVehicleTempAction(Skating.Player, Skating.Entities, 6, 2500) end
		end
	end
	Skating.MustRagdoll = function()
		local x = GetEntityRotation(Skating.Entities).x
		local y = GetEntityRotation(Skating.Entities).y
		if ((-60.0 < x and x > 60.0)) and IsEntityInAir(Skating.Entities) and Skating.Speed < 5.0 then return true end	
		if (HasEntityCollidedWithAnything(GetPlayerPed(-1)) and Skating.Speed > 5.0) then return true end
		if IsPedDeadOrDying(player, false) then return true end return false
	end
	Skating.HandleKeys = function(distance)
		local forward = IsControlPressed(0, 32)
		local backward = IsControlPressed(0, 33)
		local left = IsControlPressed(0, 34)
		local right = IsControlPressed(0, 35)
		if distance <= 1.5 and IsControlJustPressed(0, 38) then
			Skating.Connect("pickupskateboard")
		elseif distance <= 1.5 and IsControlJustReleased(0, 113) then
			if Connected then Skating.ConnectPlayer(false)
			elseif not IsPedRagdoll(player) then Wait(200) Skating.ConnectPlayer(true) end
		end
		if distance < Config.LoseConnectionDistance then
			local overSpeed = (GetEntitySpeed(Skating.Entities)*3.6) > Config.MaxSpeedKmh
			TaskVehicleTempAction(Skating.Player, Skating.Entities, 1, 1)
			ForceVehicleEngineAudio(Skating.Entities, 0)
			CreateThread(function()
				player = GetPlayerPed(-1) Wait(1)
				SetEntityInvincible(Skating.Entities, true)
				StopCurrentPlayingAmbientSpeech(Skating.Player)	
				if Connected then
					Skating.Speed = GetEntitySpeed(Skating.Entities) * 3.6
					if Skating.MustRagdoll() then Skating.ConnectPlayer(false) SetPedToRagdoll(player, 5000, 4000, 0, true, true, false) Connected = false end
				end
			end)
			if forward and not backward and not overSpeed then
				TaskVehicleTempAction(Skating.Player, Skating.Entities, 9, 1)
			end
			if IsControlPressed(0, 22) and Connected then
				if not IsEntityInAir(Skating.Entities) then	
					local vel = GetEntityVelocity(Skating.Entities)
					TaskPlayAnim(PlayerPedId(), "move_crouch_proto", "idle_intro", 5.0, 8.0, -1, 0, 0, false, false, false)
					local duration = 0 local boosting = 0
					while IsControlPressed(0, 22) do Wait(10) duration = duration + 10.0 end
					boosting = Config.maxJumpHeigh * duration / 250.0
					if boosting > Config.maxJumpHeigh then boosting = Config.maxJumpHeigh end
					StopAnimTask(PlayerPedId(), "move_crouch_proto", "idle_intro", 1.0)
					if(Connected) then SetEntityVelocity(Skating.Entities, vel.x, vel.y, vel.z + boosting)
						TaskPlayAnim(player, "move_strafe@stealth", "idle", 8.0, 2.0, -1, 1, 1.0, false, false, false)
					end
				end
			end
			if IsControlJustReleased(0, 32) or IsControlJustReleased(0, 33) and not overSpeed then
				TaskVehicleTempAction(Skating.Player, Skating.Entities, 6, 2500)
			end
			if backward and not forward and not overSpeed then
				TaskVehicleTempAction(Skating.Player, Skating.Entities, 22, 1)
			end
			if left and backward and not overSpeed then
				TaskVehicleTempAction(Skating.Player, Skating.Entities, 13, 1)
			end
			if right and backward and not overSpeed then
				TaskVehicleTempAction(Skating.Player, Skating.Entities, 14, 1)
			end
			if forward and backward and not overSpeed then
				TaskVehicleTempAction(Skating.Player, Skating.Entities, 30, 100)
			end
			if left and forward and not overSpeed then
				TaskVehicleTempAction(Skating.Player, Skating.Entities, 7, 1)
			end
			if right and forward and not overSpeed then
				TaskVehicleTempAction(Skating.Player, Skating.Entities, 8, 1)
			end
			if left and not forward and not backward and not overSpeed then
				TaskVehicleTempAction(Skating.Player, Skating.Entities, 4, 1)
			end
			if right and not forward and not backward and not overSpeed then
				TaskVehicleTempAction(Skating.Player, Skating.Entities, 5, 1)
			end
		end
	end
	Skating.Spawn = function()
		Skating.LoadModels({ GetHashKey("bmx"), 68070371, GetHashKey("p_defilied_ragdoll_01_s"), "pickup_object", "move_strafe@stealth", "move_crouch_proto"})
		local spawnCoords, spawnHeading = GetEntityCoords(PlayerPedId()) + GetEntityForwardVector(PlayerPedId()) * 2.0, GetEntityHeading(PlayerPedId())
		Skating.Entities = CreateVehicle(GetHashKey("bmx"), spawnCoords, spawnHeading, true)
		Skating.Board = CreateObject(GetHashKey("p_defilied_ragdoll_01_s"), 0.0, 0.0, 0.0, true, true, true)
		while not DoesEntityExist(Skating.Entities) do Wait(5) end
		while not DoesEntityExist(Skating.Board) do Wait(5) end
		SetEntityNoCollisionEntity(Skating.Entities, player, false)
		SetEntityCollision(Skating.Entities, false, true)
		SetEntityVisible(Skating.Entities, false)
		AttachEntityToEntity(Skating.Board, Skating.Entities, GetPedBoneIndex(PlayerPedId(), 28422), 0.0, 0.0, -0.40, 0.0, 0.0, 90.0, false, true, true, true, 1, true)
		Skating.Player = CreatePed(12	, 68070371, spawnCoords, spawnHeading, true, true)
		SetEnableHandcuffs(Skating.Player, true)
		SetEntityInvincible(Skating.Player, true)
		SetEntityVisible(Skating.Player, false)
		FreezeEntityPosition(Skating.Player, true)
		TaskWarpPedIntoVehicle(Skating.Player, Skating.Entities, -1)
		while not IsPedInVehicle(Skating.Player, Skating.Entities) do Wait(0) end Skating.Connect("placeskateboard")
	end
	Skating.Connect = function(param)
		if not DoesEntityExist(Skating.Entities) then return end
		if param == "placeskateboard" then
			AttachEntityToEntity(Skating.Entities, PlayerPedId(), GetPedBoneIndex(PlayerPedId(),  28422), -0.1, 0.0, -0.2, 70.0, 0.0, 270.0, 1, 1, 0, 0, 2, 1)
			TaskPlayAnim(PlayerPedId(), "pickup_object", "pickup_low", 8.0, -8.0, -1, 0, 0, false, false, false) Wait(800)
			DetachEntity(Skating.Entities, false, true)
			PlaceObjectOnGroundProperly(Skating.Entities)
			ESX.ShowNotification(Config.Language.Info['controls']) -- Comment if you don't wanna use this
			-- exports['astudios-notify']:notify("", Config.Language.Info['controls'], 8000, 'info') -- Uncomment if you wanna use this
			-- exports['okokNotify']:Alert("", Config.Language.Info['controls'], 8000, 'info') -- Uncomment if you wanna use this
		elseif param == "pickupskateboard" then
			TaskPlayAnim(PlayerPedId(), "pickup_object", "pickup_low", 8.0, -8.0, -1, 0, 0, false, false, false) Wait(600)
			AttachEntityToEntity(Skating.Entities, PlayerPedId(), GetPedBoneIndex(PlayerPedId(),  28422), -0.1, 0.0, -0.2, 70.0, 0.0, 270.0, 1, 1, 0, 0, 2, 1)
			Wait(900) Skating.Clear()
		end
	end
	Skating.Clear = function(models)
		DetachEntity(Skating.Entities)
		DeleteEntity(Skating.Board)
		DeleteVehicle(Skating.Entities)
		DeleteEntity(Skating.Player)
		Skating.UnloadModels()
		Attach = false
		Connected  = false
		SetPedRagdollOnCollision(player, false)
	end
	Skating.LoadModels = function(models)
		for modelIndex = 1, #models do
			local model = models[modelIndex]
			if not Skating.Models then Skating.Models = {} end
			table.insert(Skating.Models, model)
			if IsModelValid(model) then
				while not HasModelLoaded(model) do RequestModel(model)	Wait(10) end
			else
				while not HasAnimDictLoaded(model) do RequestAnimDict(model) Wait(10) end    
			end
		end
	end
	Skating.UnloadModels = function()
		for modelIndex = 1, #Skating.Models do
			local model = Skating.Models[modelIndex]
			if IsModelValid(model) then
				SetModelAsNoLongerNeeded(model)
			else
				RemoveAnimDict(model)   
			end
		end
	end
	Skating.ConnectPlayer = function(toggle)
		if toggle then
			TaskPlayAnim(player, "move_strafe@stealth", "idle", 8.0, 8.0, -1, 1, 1.0, false, false, false)
			AttachEntityToEntity(player, Skating.Entities, 20, 0.0, 0, 0.7, 0.0, 0.0, -15.0, true, true, false, true, 1, true)
			SetEntityCollision(player, true, true)
			TriggerServerEvent("astudios-skating:server:skate")
		elseif not toggle then
			DetachEntity(player, false, false)
			StopAnimTask(player, "move_strafe@stealth", "idle", 1.0)
			StopAnimTask(PlayerPedId(), "move_crouch_proto", "idle_intro", 1.0)
			TaskVehicleTempAction(Skating.Player, Skating.Entities, 3, 1)	
		end	
		Connected = toggle
	end
	RegisterNetEvent("astudios-skating:client:skate", function(id)
		local player = GetPlayerFromServerId(id)
		local vehicle = GetEntityAttachedTo(GetPlayerPed(player))
	end)
end
