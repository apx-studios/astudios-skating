if Config.Framework == "qb" then
	local Skate = {}
	local player = nil
	local QBCore = exports["qb-core"]:GetCoreObject()

	Attached = false

	RegisterNetEvent("astudios-skating:client:puton")
	AddEventHandler("astudios-skating:client:puton", function() 
		Skate.Start()
	end)

	AddEventHandler('longboard:clear', function()
		Skate.Clear()
	end)

	AddEventHandler('longboard:start', function()
		Skate.Start()
	end)

	AddEventHandler('baseevents:onPlayerDied', function()
		Skate.AttachPlayer(false)
	end)

	Skate.Start = function()
		if DoesEntityExist(Skate.Entity) then return end
		Skate.Spawn()
		while DoesEntityExist(Skate.Entity) and DoesEntityExist(Skate.Driver) do
			Citizen.Wait(5)
			local distanceCheck = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()),  GetEntityCoords(Skate.Entity), true)
			Skate.HandleKeys(distanceCheck)
			if distanceCheck <= Config.LoseConnectionDistance then
				if not NetworkHasControlOfEntity(Skate.Driver) then
					NetworkRequestControlOfEntity(Skate.Driver)
				elseif not NetworkHasControlOfEntity(Skate.Entity) then
					NetworkRequestControlOfEntity(Skate.Entity)
				end
			else
				TaskVehicleTempAction(Skate.Driver, Skate.Entity, 6, 2500)
			end
		end
	end

	Skate.MustRagdoll = function()
		local x = GetEntityRotation(Skate.Entity).x
		local y = GetEntityRotation(Skate.Entity).y
		if ((-60.0 < x and x > 60.0)) and IsEntityInAir(Skate.Entity) and Skate.Speed < 5.0 then
			return true
		end	
		if (HasEntityCollidedWithAnything(GetPlayerPed(-1)) and Skate.Speed > 5.0) then return true end
		if IsPedDeadOrDying(player, false) then return true end
			return false
	end

	Skate.HandleKeys = function(distanceCheck)
		if distanceCheck <= 1.5 then
			if IsControlJustPressed(0, 38) then
				Skate.Attach("pick")
			end
			if IsControlJustReleased(0, 113) then
				if Attached then
					Skate.AttachPlayer(false)
				elseif not IsPedRagdoll(player) then
					Citizen.Wait(200)
					Skate.AttachPlayer(true)
				end
			end
		end
		if distanceCheck < Config.LoseConnectionDistance then
			local overSpeed = (GetEntitySpeed(Skate.Entity)*3.6) > Config.MaxSpeedKmh
			-- prevents ped from driving away
			TaskVehicleTempAction(Skate.Driver, Skate.Entity, 1, 1)
			ForceVehicleEngineAudio(Skate.Entity, 0)
			Citizen.CreateThread(function()
				player = GetPlayerPed(-1)
				Citizen.Wait(1)
				SetEntityInvincible(Skate.Entity, true)
				StopCurrentPlayingAmbientSpeech(Skate.Driver)	
				if Attached then
					-- Ragdoll system
					Skate.Speed = GetEntitySpeed(Skate.Entity) * 3.6
					if Skate.MustRagdoll() then
						Skate.AttachPlayer(false)
						SetPedToRagdoll(player, 5000, 4000, 0, true, true, false)
						Attached = false
					end
				end
				
			end)
			-- Input Control longboard 
			if IsControlPressed(0, 32) and not IsControlPressed(0, 33) and not overSpeed then
				TaskVehicleTempAction(Skate.Driver, Skate.Entity, 9, 1)
			end

			if IsControlPressed(0, 22) and Attached then
				-- Jump system
				if not IsEntityInAir(Skate.Entity) then	
					local vel = GetEntityVelocity(Skate.Entity)
					TaskPlayAnim(PlayerPedId(), "move_crouch_proto", "idle_intro", 5.0, 8.0, -1, 0, 0, false, false, false)
					local duration = 0
					local boost = 0
					while IsControlPressed(0, 22) do
						Citizen.Wait(10)
						duration = duration + 10.0
					end
					boost = Config.maxJumpHeigh * duration / 250.0
					if boost > Config.maxJumpHeigh then boost = Config.maxJumpHeigh end
					StopAnimTask(PlayerPedId(), "move_crouch_proto", "idle_intro", 1.0)
					if(Attached) then
						SetEntityVelocity(Skate.Entity, vel.x, vel.y, vel.z + boost)
						TaskPlayAnim(player, "move_strafe@stealth", "idle", 8.0, 2.0, -1, 1, 1.0, false, false, false)
					end
				end
			end
			if IsControlJustReleased(0, 32) or IsControlJustReleased(0, 33) and not overSpeed then
				TaskVehicleTempAction(Skate.Driver, Skate.Entity, 6, 2500)
			end
			if IsControlPressed(0, 33) and not IsControlPressed(0, 32) and not overSpeed then
				TaskVehicleTempAction(Skate.Driver, Skate.Entity, 22, 1)
			end
			if IsControlPressed(0, 34) and IsControlPressed(0, 33) and not overSpeed then
				TaskVehicleTempAction(Skate.Driver, Skate.Entity, 13, 1)
			end
			if IsControlPressed(0, 35) and IsControlPressed(0, 33) and not overSpeed then
				TaskVehicleTempAction(Skate.Driver, Skate.Entity, 14, 1)
			end
			if IsControlPressed(0, 32) and IsControlPressed(0, 33) and not overSpeed then
				TaskVehicleTempAction(Skate.Driver, Skate.Entity, 30, 100)
			end
			if IsControlPressed(0, 34) and IsControlPressed(0, 32) and not overSpeed then
				TaskVehicleTempAction(Skate.Driver, Skate.Entity, 7, 1)
			end
			if IsControlPressed(0, 35) and IsControlPressed(0, 32) and not overSpeed then
				TaskVehicleTempAction(Skate.Driver, Skate.Entity, 8, 1)
			end
			if IsControlPressed(0, 34) and not IsControlPressed(0, 32) and not IsControlPressed(0, 33) and not overSpeed then
				TaskVehicleTempAction(Skate.Driver, Skate.Entity, 4, 1)
			end
			if IsControlPressed(0, 35) and not IsControlPressed(0, 32) and not IsControlPressed(0, 33) and not overSpeed then
				TaskVehicleTempAction(Skate.Driver, Skate.Entity, 5, 1)
			end
		end
	end

	Skate.Spawn = function()
		-- models to load
		Skate.LoadModels({ GetHashKey("bmx"), 68070371, GetHashKey("p_defilied_ragdoll_01_s"), "pickup_object", "move_strafe@stealth", "move_crouch_proto"})
		local spawnCoords, spawnHeading = GetEntityCoords(PlayerPedId()) + GetEntityForwardVector(PlayerPedId()) * 2.0, GetEntityHeading(PlayerPedId())
		Skate.Entity = CreateVehicle(GetHashKey("bmx"), spawnCoords, spawnHeading, true)
		Skate.Skate = CreateObject(GetHashKey("p_defilied_ragdoll_01_s"), 0.0, 0.0, 0.0, true, true, true)
		-- load models
		while not DoesEntityExist(Skate.Entity) do
			Citizen.Wait(5)
		end
		while not DoesEntityExist(Skate.Skate) do
			Citizen.Wait(5)
		end
		SetEntityNoCollisionEntity(Skate.Entity, player, false) -- disable collision between the player and the rc
		SetEntityCollision(Skate.Entity, false, true)
		SetEntityVisible(Skate.Entity, false)
		AttachEntityToEntity(Skate.Skate, Skate.Entity, GetPedBoneIndex(PlayerPedId(), 28422), 0.0, 0.0, -0.40, 0.0, 0.0, 90.0, false, true, true, true, 1, true)
		Skate.Driver = CreatePed(12	, 68070371, spawnCoords, spawnHeading, true, true)
		-- Driver properties
		SetEnableHandcuffs(Skate.Driver, true)
		SetEntityInvincible(Skate.Driver, true)
		SetEntityVisible(Skate.Driver, false)
		FreezeEntityPosition(Skate.Driver, true)
		TaskWarpPedIntoVehicle(Skate.Driver, Skate.Entity, -1)
		while not IsPedInVehicle(Skate.Driver, Skate.Entity) do
			Citizen.Wait(0)
		end
		Skate.Attach("place")
	end

	Skate.Attach = function(param)
		if not DoesEntityExist(Skate.Entity) then
			return
		end
		if param == "place" then
			-- Place longboard
			AttachEntityToEntity(Skate.Entity, PlayerPedId(), GetPedBoneIndex(PlayerPedId(),  28422), -0.1, 0.0, -0.2, 70.0, 0.0, 270.0, 1, 1, 0, 0, 2, 1)
			TaskPlayAnim(PlayerPedId(), "pickup_object", "pickup_low", 8.0, -8.0, -1, 0, 0, false, false, false)
			Citizen.Wait(800)
			DetachEntity(Skate.Entity, false, true)
			PlaceObjectOnGroundProperly(Skate.Entity)
			if Config.NotificationType.client == "qbcore" then
				QBCore.Functions.Notify(Config.Language.Info['controls'], "info")
			elseif Config.NotificationType.client == "okok" then
				exports['okokNotify']:Alert("", Config.Language.Info['controls'], 8000, 'info')
			end
		elseif param == "pick" then
			-- Pick longboard
			Citizen.Wait(100)
			TaskPlayAnim(PlayerPedId(), "pickup_object", "pickup_low", 8.0, -8.0, -1, 0, 0, false, false, false)
			Citizen.Wait(600)
			AttachEntityToEntity(Skate.Entity, PlayerPedId(), GetPedBoneIndex(PlayerPedId(),  28422), -0.1, 0.0, -0.2, 70.0, 0.0, 270.0, 1, 1, 0, 0, 2, 1)
			Citizen.Wait(900)
			-- Clear 
			Skate.Clear()
		end
	end

	Skate.Clear = function(models)
		DetachEntity(Skate.Entity)
		DeleteEntity(Skate.Skate)
		DeleteVehicle(Skate.Entity)
		DeleteEntity(Skate.Driver)
		Skate.UnloadModels()
		Attach = false
		Attached  = false
		SetPedRagdollOnCollision(player, false)
	end

	Skate.LoadModels = function(models)
		for modelIndex = 1, #models do
			local model = models[modelIndex]
			if not Skate.CachedModels then
				Skate.CachedModels = {}
			end
			table.insert(Skate.CachedModels, model)
			if IsModelValid(model) then
				while not HasModelLoaded(model) do
					RequestModel(model)	
					Citizen.Wait(10)
				end
			else
				while not HasAnimDictLoaded(model) do
					RequestAnimDict(model)
					Citizen.Wait(10)
				end    
			end
		end
	end

	Skate.UnloadModels = function()
		for modelIndex = 1, #Skate.CachedModels do
			local model = Skate.CachedModels[modelIndex]
			if IsModelValid(model) then
				SetModelAsNoLongerNeeded(model)
			else
				RemoveAnimDict(model)   
			end
		end
	end

	Skate.AttachPlayer = function(toggle)
		if toggle then
			TaskPlayAnim(player, "move_strafe@stealth", "idle", 8.0, 8.0, -1, 1, 1.0, false, false, false)
			AttachEntityToEntity(player, Skate.Entity, 20, 0.0, 0, 0.7, 0.0, 0.0, -15.0, true, true, false, true, 1, true)
			SetEntityCollision(player, true, true)
			-- SetPedRagdollOnCollision(player, true)
			TriggerServerEvent("astudios-skating:server:onSkate")
		elseif not toggle then
			DetachEntity(player, false, false)
			-- SetPedRagdollOnCollision(player, false)
			--SetEntityCollision(Skate.Entity, false, true)
			StopAnimTask(player, "move_strafe@stealth", "idle", 1.0)
			StopAnimTask(PlayerPedId(), "move_crouch_proto", "idle_intro", 1.0)
			TaskVehicleTempAction(Skate.Driver, Skate.Entity, 3, 1)	
		end	
		Attached = toggle
	end

	RegisterNetEvent("astudios-skating:client:heSkate")
	AddEventHandler("astudios-skating:client:heSkate", function(id)
		local player = GetPlayerFromServerId(id)
		local vehicle = GetEntityAttachedTo(GetPlayerPed(player))
	end)
elseif Config.Framework == "esx" then
	local Skate = {}
	local player = nil
	ESX = nil

	Attached = false

	CreateThread(function()
		while ESX == nil do
		  TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		  Wait(0)
		end
	  end)

	RegisterNetEvent("astudios-skating:client:puton")
	AddEventHandler("astudios-skating:client:puton", function() 
		Skate.Start()
	end)

	AddEventHandler('longboard:clear', function()
		Skate.Clear()
	end)

	AddEventHandler('longboard:start', function()
		Skate.Start()
	end)

	AddEventHandler('baseevents:onPlayerDied', function()
		Skate.AttachPlayer(false)
	end)

	Skate.Start = function()
		if DoesEntityExist(Skate.Entity) then return end
		Skate.Spawn()
		while DoesEntityExist(Skate.Entity) and DoesEntityExist(Skate.Driver) do
			Citizen.Wait(5)
			local distanceCheck = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()),  GetEntityCoords(Skate.Entity), true)
			Skate.HandleKeys(distanceCheck)
			if distanceCheck <= Config.LoseConnectionDistance then
				if not NetworkHasControlOfEntity(Skate.Driver) then
					NetworkRequestControlOfEntity(Skate.Driver)
				elseif not NetworkHasControlOfEntity(Skate.Entity) then
					NetworkRequestControlOfEntity(Skate.Entity)
				end
			else
				TaskVehicleTempAction(Skate.Driver, Skate.Entity, 6, 2500)
			end
		end
	end

	Skate.MustRagdoll = function()
		local x = GetEntityRotation(Skate.Entity).x
		local y = GetEntityRotation(Skate.Entity).y
		if ((-60.0 < x and x > 60.0)) and IsEntityInAir(Skate.Entity) and Skate.Speed < 5.0 then
			return true
		end	
		if (HasEntityCollidedWithAnything(GetPlayerPed(-1)) and Skate.Speed > 5.0) then return true end
		if IsPedDeadOrDying(player, false) then return true end
			return false
	end

	Skate.HandleKeys = function(distanceCheck)
		if distanceCheck <= 1.5 then
			if IsControlJustPressed(0, 38) then
				Skate.Attach("pick")
			end
			if IsControlJustReleased(0, 113) then
				if Attached then
					Skate.AttachPlayer(false)
				elseif not IsPedRagdoll(player) then
					Citizen.Wait(200)
					Skate.AttachPlayer(true)
				end
			end
		end
		if distanceCheck < Config.LoseConnectionDistance then
			local overSpeed = (GetEntitySpeed(Skate.Entity)*3.6) > Config.MaxSpeedKmh
			-- prevents ped from driving away
			TaskVehicleTempAction(Skate.Driver, Skate.Entity, 1, 1)
			ForceVehicleEngineAudio(Skate.Entity, 0)
			Citizen.CreateThread(function()
				player = GetPlayerPed(-1)
				Citizen.Wait(1)
				SetEntityInvincible(Skate.Entity, true)
				StopCurrentPlayingAmbientSpeech(Skate.Driver)	
				if Attached then
					-- Ragdoll system
					Skate.Speed = GetEntitySpeed(Skate.Entity) * 3.6
					if Skate.MustRagdoll() then
						Skate.AttachPlayer(false)
						SetPedToRagdoll(player, 5000, 4000, 0, true, true, false)
						Attached = false
					end
				end
				
			end)
			-- Input Control longboard 
			if IsControlPressed(0, 32) and not IsControlPressed(0, 33) and not overSpeed then
				TaskVehicleTempAction(Skate.Driver, Skate.Entity, 9, 1)
			end

			if IsControlPressed(0, 22) and Attached then
				-- Jump system
				if not IsEntityInAir(Skate.Entity) then	
					local vel = GetEntityVelocity(Skate.Entity)
					TaskPlayAnim(PlayerPedId(), "move_crouch_proto", "idle_intro", 5.0, 8.0, -1, 0, 0, false, false, false)
					local duration = 0
					local boost = 0
					while IsControlPressed(0, 22) do
						Citizen.Wait(10)
						duration = duration + 10.0
					end
					boost = Config.maxJumpHeigh * duration / 250.0
					if boost > Config.maxJumpHeigh then boost = Config.maxJumpHeigh end
					StopAnimTask(PlayerPedId(), "move_crouch_proto", "idle_intro", 1.0)
					if(Attached) then
						SetEntityVelocity(Skate.Entity, vel.x, vel.y, vel.z + boost)
						TaskPlayAnim(player, "move_strafe@stealth", "idle", 8.0, 2.0, -1, 1, 1.0, false, false, false)
					end
				end
			end
			if IsControlJustReleased(0, 32) or IsControlJustReleased(0, 33) and not overSpeed then
				TaskVehicleTempAction(Skate.Driver, Skate.Entity, 6, 2500)
			end
			if IsControlPressed(0, 33) and not IsControlPressed(0, 32) and not overSpeed then
				TaskVehicleTempAction(Skate.Driver, Skate.Entity, 22, 1)
			end
			if IsControlPressed(0, 34) and IsControlPressed(0, 33) and not overSpeed then
				TaskVehicleTempAction(Skate.Driver, Skate.Entity, 13, 1)
			end
			if IsControlPressed(0, 35) and IsControlPressed(0, 33) and not overSpeed then
				TaskVehicleTempAction(Skate.Driver, Skate.Entity, 14, 1)
			end
			if IsControlPressed(0, 32) and IsControlPressed(0, 33) and not overSpeed then
				TaskVehicleTempAction(Skate.Driver, Skate.Entity, 30, 100)
			end
			if IsControlPressed(0, 34) and IsControlPressed(0, 32) and not overSpeed then
				TaskVehicleTempAction(Skate.Driver, Skate.Entity, 7, 1)
			end
			if IsControlPressed(0, 35) and IsControlPressed(0, 32) and not overSpeed then
				TaskVehicleTempAction(Skate.Driver, Skate.Entity, 8, 1)
			end
			if IsControlPressed(0, 34) and not IsControlPressed(0, 32) and not IsControlPressed(0, 33) and not overSpeed then
				TaskVehicleTempAction(Skate.Driver, Skate.Entity, 4, 1)
			end
			if IsControlPressed(0, 35) and not IsControlPressed(0, 32) and not IsControlPressed(0, 33) and not overSpeed then
				TaskVehicleTempAction(Skate.Driver, Skate.Entity, 5, 1)
			end
		end
	end

	Skate.Spawn = function()
		-- models to load
		Skate.LoadModels({ GetHashKey("bmx"), 68070371, GetHashKey("p_defilied_ragdoll_01_s"), "pickup_object", "move_strafe@stealth", "move_crouch_proto"})
		local spawnCoords, spawnHeading = GetEntityCoords(PlayerPedId()) + GetEntityForwardVector(PlayerPedId()) * 2.0, GetEntityHeading(PlayerPedId())
		Skate.Entity = CreateVehicle(GetHashKey("bmx"), spawnCoords, spawnHeading, true)
		Skate.Skate = CreateObject(GetHashKey("p_defilied_ragdoll_01_s"), 0.0, 0.0, 0.0, true, true, true)
		-- load models
		while not DoesEntityExist(Skate.Entity) do
			Citizen.Wait(5)
		end
		while not DoesEntityExist(Skate.Skate) do
			Citizen.Wait(5)
		end
		SetEntityNoCollisionEntity(Skate.Entity, player, false) -- disable collision between the player and the rc
		SetEntityCollision(Skate.Entity, false, true)
		SetEntityVisible(Skate.Entity, false)
		AttachEntityToEntity(Skate.Skate, Skate.Entity, GetPedBoneIndex(PlayerPedId(), 28422), 0.0, 0.0, -0.40, 0.0, 0.0, 90.0, false, true, true, true, 1, true)
		Skate.Driver = CreatePed(12	, 68070371, spawnCoords, spawnHeading, true, true)
		-- Driver properties
		SetEnableHandcuffs(Skate.Driver, true)
		SetEntityInvincible(Skate.Driver, true)
		SetEntityVisible(Skate.Driver, false)
		FreezeEntityPosition(Skate.Driver, true)
		TaskWarpPedIntoVehicle(Skate.Driver, Skate.Entity, -1)
		while not IsPedInVehicle(Skate.Driver, Skate.Entity) do
			Citizen.Wait(0)
		end
		Skate.Attach("place")
	end

	Skate.Attach = function(param)
		if not DoesEntityExist(Skate.Entity) then
			return
		end
		if param == "place" then
			-- Place longboard
			AttachEntityToEntity(Skate.Entity, PlayerPedId(), GetPedBoneIndex(PlayerPedId(),  28422), -0.1, 0.0, -0.2, 70.0, 0.0, 270.0, 1, 1, 0, 0, 2, 1)
			TaskPlayAnim(PlayerPedId(), "pickup_object", "pickup_low", 8.0, -8.0, -1, 0, 0, false, false, false)
			Citizen.Wait(800)
			DetachEntity(Skate.Entity, false, true)
			PlaceObjectOnGroundProperly(Skate.Entity)
			if Config.NotificationType.client == "esx" then
				ESX.ShowNotification(Config.Language.Info['controls'])
			elseif Config.NotificationType.client == "okok" then
				exports['okokNotify']:Alert("", Config.Language.Info['controls'], 8000, 'info')
			end
		elseif param == "pick" then
			-- Pick longboard
			Citizen.Wait(100)
			TaskPlayAnim(PlayerPedId(), "pickup_object", "pickup_low", 8.0, -8.0, -1, 0, 0, false, false, false)
			Citizen.Wait(600)
			AttachEntityToEntity(Skate.Entity, PlayerPedId(), GetPedBoneIndex(PlayerPedId(),  28422), -0.1, 0.0, -0.2, 70.0, 0.0, 270.0, 1, 1, 0, 0, 2, 1)
			Citizen.Wait(900)
			-- Clear 
			Skate.Clear()
		end
	end

	Skate.Clear = function(models)
		DetachEntity(Skate.Entity)
		DeleteEntity(Skate.Skate)
		DeleteVehicle(Skate.Entity)
		DeleteEntity(Skate.Driver)
		Skate.UnloadModels()
		Attach = false
		Attached  = false
		SetPedRagdollOnCollision(player, false)
	end

	Skate.LoadModels = function(models)
		for modelIndex = 1, #models do
			local model = models[modelIndex]
			if not Skate.CachedModels then
				Skate.CachedModels = {}
			end
			table.insert(Skate.CachedModels, model)
			if IsModelValid(model) then
				while not HasModelLoaded(model) do
					RequestModel(model)	
					Citizen.Wait(10)
				end
			else
				while not HasAnimDictLoaded(model) do
					RequestAnimDict(model)
					Citizen.Wait(10)
				end    
			end
		end
	end

	Skate.UnloadModels = function()
		for modelIndex = 1, #Skate.CachedModels do
			local model = Skate.CachedModels[modelIndex]
			if IsModelValid(model) then
				SetModelAsNoLongerNeeded(model)
			else
				RemoveAnimDict(model)   
			end
		end
	end

	Skate.AttachPlayer = function(toggle)
		if toggle then
			TaskPlayAnim(player, "move_strafe@stealth", "idle", 8.0, 8.0, -1, 1, 1.0, false, false, false)
			AttachEntityToEntity(player, Skate.Entity, 20, 0.0, 0, 0.7, 0.0, 0.0, -15.0, true, true, false, true, 1, true)
			SetEntityCollision(player, true, true)
			-- SetPedRagdollOnCollision(player, true)
			TriggerServerEvent("astudios-skating:server:onSkate")
		elseif not toggle then
			DetachEntity(player, false, false)
			-- SetPedRagdollOnCollision(player, false)
			--SetEntityCollision(Skate.Entity, false, true)
			StopAnimTask(player, "move_strafe@stealth", "idle", 1.0)
			StopAnimTask(PlayerPedId(), "move_crouch_proto", "idle_intro", 1.0)
			TaskVehicleTempAction(Skate.Driver, Skate.Entity, 3, 1)	
		end	
		Attached = toggle
	end

	RegisterNetEvent("astudios-skating:client:heSkate")
	AddEventHandler("astudios-skating:client:heSkate", function(id)
		local player = GetPlayerFromServerId(id)
		local vehicle = GetEntityAttachedTo(GetPlayerPed(player))
	end)
end