ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local onTimer       = {}
local savedCoords   = {}
local warnedPlayers = {}
local deadPlayers   = {}

RegisterCommand("pomoc", function(source, args, rawCommand)	-- /report [MESSAGE]		send report message to all online admins
  	local xPlayer = ESX.GetPlayerFromId(source)
	if onTimer[source] and onTimer[source] > GetGameTimer() then
		local timeLeft = (onTimer[source] - GetGameTimer()) / 1000
		TriggerClientEvent('chatMessage', xPlayer.source, _U('report_cooldown', tostring(ESX.Math.Round(timeLeft))))
		return
	end
	if args[1] then
    	local message = string.sub(rawCommand, 7)
    	local xAll = ESX.GetPlayers()
    	for i=1, #xAll, 1 do
      		local xTarget = ESX.GetPlayerFromId(xAll[i])
      		if havePermission(xTarget) then		-- you can exclude some ranks to NOT reciveing reports
        		if xPlayer.source ~= xTarget.source then
		    		TriggerClientEvent('chatMessage', xTarget.source, _U('report', xPlayer.getName(), xPlayer.source, message))
        		end
      		end
		end
		TriggerClientEvent('chatMessage', xPlayer.source, _U('report', xPlayer.getName(), xPlayer.source, message))
		onTimer[source] = GetGameTimer() + (Config.reportCooldown * 1000)
	else
		TriggerClientEvent('chatMessage', xPlayer.source, _U('invalid_input', 'REPORT'))
	end
end, false)

---------- Bring / Bringback ----------
RegisterCommand("donesi", function(source, args, rawCommand)	-- /bring [ID]
	if source ~= 0 then
	  	local xPlayer = ESX.GetPlayerFromId(source)
	  	if havePermission(xPlayer) then
	    	if args[1] and tonumber(args[1]) then
	      		local targetId = tonumber(args[1])
	      		local xTarget = ESX.GetPlayerFromId(targetId)
	      		if xTarget then
	        		local targetCoords = xTarget.getCoords()
	        		local playerCoords = xPlayer.getCoords()
	        		savedCoords[targetId] = targetCoords
	        		xTarget.setCoords(playerCoords)
	        		TriggerClientEvent("chatMessage", xPlayer.source, _U('bring_adminside', args[1]))
	        		TriggerClientEvent("chatMessage", xTarget.source, _U('bring_playerside'))
	      		else
	        		TriggerClientEvent("chatMessage", xPlayer.source, _U('not_online', 'BRING'))
	      		end
	    	else
	      		TriggerClientEvent("chatMessage", xPlayer.source, _U('invalid_input', 'BRING'))
	    	end
	  	end
	end
end, false)

RegisterCommand("vrati", function(source, args, rawCommand)	-- /bringback [ID] will teleport player back where he was before /bring
	if source ~= 0 then
  		local xPlayer = ESX.GetPlayerFromId(source)
  		if havePermission(xPlayer) then
    		if args[1] and tonumber(args[1]) then
      			local targetId = tonumber(args[1])
      			local xTarget = ESX.GetPlayerFromId(targetId)
      			if xTarget then
        			local playerCoords = savedCoords[targetId]
        			if playerCoords then
          			xTarget.setCoords(playerCoords)
          			TriggerClientEvent("chatMessage", xPlayer.source, _U('bringback_admin', 'BRINGBACK', args[1]))
          			TriggerClientEvent("chatMessage", xTarget.source,  _U('bringback_player', 'BRINGBACK'))
          			savedCoords[targetId] = nil
        		else
          			TriggerClientEvent("chatMessage", xPlayer.source, _U('noplace_bring'))
        			end
      			else
        			TriggerClientEvent("chatMessage", xPlayer.source, _U('not_online', 'BRINGBACK'))
      			end
    		else
      			TriggerClientEvent("chatMessage", xPlayer.source, _U('invalid_input', 'BRINGBACK'))
    		end
  		end
	end
end, false)

---------- goto/goback ----------
RegisterCommand("idi", function(source, args, rawCommand)	-- /goto [ID]
	if source ~= 0 then
  		local xPlayer = ESX.GetPlayerFromId(source)
  		if havePermission(xPlayer) then
    		if args[1] and tonumber(args[1]) then
      			local targetId = tonumber(args[1])
      			local xTarget = ESX.GetPlayerFromId(targetId)
      			if xTarget then
        			local targetCoords = xTarget.getCoords()
        			local playerCoords = xPlayer.getCoords()
        			savedCoords[source] = playerCoords
        			xPlayer.setCoords(targetCoords)
        			TriggerClientEvent("chatMessage", xPlayer.source, _U('goto_admin', args[1]))
					TriggerClientEvent("chatMessage", xTarget.source,  _U('goto_player'))
      			else
        			TriggerClientEvent("chatMessage", xPlayer.source, _U('not_online', 'GOTO'))
      			end
    		else
      			TriggerClientEvent("chatMessage", xPlayer.source, _U('invalid_input', 'GOTO'))
    		end
  		end
	end
end, false)

RegisterCommand("vratise", function(source, args, rawCommand)	-- /goback will teleport you back where you was befor /goto
	if source ~= 0 then
	  	local xPlayer = ESX.GetPlayerFromId(source)
	  	if havePermission(xPlayer) then
	    	local playerCoords = savedCoords[source]
	    	if playerCoords then
	      		xPlayer.setCoords(playerCoords)
				TriggerClientEvent("chatMessage", xPlayer.source, _U('goback'))
	      		savedCoords[source] = nil
	    	else
	      		TriggerClientEvent("chatMessage", xPlayer.source, _U('goback_error'))
	    	end
	  	end
	end
end, false)

RegisterCommand("reviveall", function(source, args, rawCommand)	-- reviveall (can be used from console)
	canRevive = false
	if source == 0 then
		canRevive = true
	else
		local xPlayer = ESX.GetPlayerFromId(source)
		if havePermission(xPlayer) then
			canRevive = true
		end
	end
	if canRevive then
		for i,data in pairs(deadPlayers) do
			TriggerClientEvent('esx_ambulancejob:revive', i)
		end
	end
end, false)

------------ functions and events ------------
RegisterNetEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function(data)
	deadPlayers[source] = data
end)

RegisterNetEvent('esx:onPlayerSpawn')
AddEventHandler('esx:onPlayerSpawn', function()
	if deadPlayers[source] then
		deadPlayers[source] = nil
	end
end)

AddEventHandler('esx:playerDropped', function(playerId, reason)
	-- empty tables when player no longer online
	if onTimer[playerId] then
		onTimer[playerId] = nil
	end
    if savedCoords[playerId] then
    	savedCoords[playerId] = nil
    end
	if warnedPlayers[playerId] then
		warnedPlayers[playerId] = nil
	end
	if deadPlayers[playerId] then
		deadPlayers[playerId] = nil
	end
end)

function havePermission(xPlayer, exclude)	-- you can exclude rank(s) from having permission to specific commands 	[exclude only take tables]
	if exclude and type(exclude) ~= 'table' then exclude = nil;print("^3[esx_admin] ^1ERROR ^0exclude argument is not table..^0") end	-- will prevent from errors if you pass wrong argument

	local playerGroup = xPlayer.getGroup()
	for k,v in pairs(Config.adminRanks) do
		if v == playerGroup then
			if not exclude then
				return true
			else
				for a,b in pairs(exclude) do
					if b == v then
						return false
					end
				end
				return true
			end
		end
	end
	return false
end
