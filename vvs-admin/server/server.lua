local ESX = nil
AdminPlayers = {}

TriggerEvent('esx:getSharedObject', function(obj) 
    ESX = obj 
end)

ESX.RegisterServerCallback("Admin:getRankFromPlayer", function(source, cb)
    local player = ESX.GetPlayerFromId(source)

    if player ~= nil then
        local playerGroup = player.getGroup()

        if playerGroup ~= nil then 
            cb(playerGroup)
        else
            cb("user")
        end
    else
        cb("user")
    end
end)


RegisterCommand('onduty',  function(source, args)
  local xPlayer = ESX.GetPlayerFromId(source)

  MySQL.Async.fetchAll('SELECT group2 FROM `users` WHERE `identifier` = @identifier',
        {
            ['@identifier'] = xPlayer.identifier
        },
        function(result)
          --print(result[1].group2)
        if xPlayer then
          xPlayer.setGroup(result[1].group2)
        end

    if AdminPlayers[source] == nil then    
    	if Config.TagByPermission then
    		    AdminPlayers[source] = {source = source, permission = xPlayer.getPermissions()}
                      else
                          AdminPlayers[source] = {source = source, group = xPlayer.getGroup()}
                      end
			        if result[1].group2 == "admin" or result[1].group2 == "superadmin" then
			            TriggerClientEvent("toggleOnDuty", source)
			            TriggerClientEvent('chat:addMessage', -1, {
			                args = {"^8VVS ^8»  Developer ^0" ..  GetPlayerName(source) .. "^0 je sada na duznosti ! "} 
			              })
			        TriggerClientEvent('relisoft_tag:set_admins',-1,AdminPlayers)    
			        else
					  TriggerClientEvent("chatMessage", source, "❗ ^8VVS ^8» Nemate permisije za ovu komandu!^0.")
					end
        end            
    end)  
end)

RegisterCommand('offduty',  function(source, args)
  local xPlayer = ESX.GetPlayerFromId(source)
  if xPlayer.getGroup() == "admin" or xPlayer.getGroup() == "superadmin" then
    TriggerClientEvent("toggleOffDuty", source)
    TriggerClientEvent('chat:addMessage', -1, {
        args = {"^8VVS ^8»  Admin ^0" ..  GetPlayerName(source) .. "^0 vise nije na duznosti ! "} 
      })
        if xPlayer then
          xPlayer.setGroup('user')
        end

                if AdminPlayers[source] == nil then
                      if Config.TagByPermission then
                          AdminPlayers[source] = {source = source, permission = xPlayer.getPermissions()}
                      else
                          AdminPlayers[source] = {source = source, group = xPlayer.getGroup()}
                      end
                else
                      AdminPlayers[source] = nil
                end
                    TriggerClientEvent('relisoft_tag:set_admins',-1,AdminPlayers)
  else
  TriggerClientEvent("chatMessage", source, "❗ ^8VVS ^8» Nemate permisije za ovu komandu!^0.")
  end
end)


ESX.RegisterServerCallback('relisoft_tag:getAdminsPlayers',function(source,cb)
    cb(AdminPlayers)
end)

AddEventHandler('esx:playerDropped', function(source)
    if AdminPlayers[source] ~= nil then
        AdminPlayers[source] = nil
    end
    TriggerClientEvent('relisoft_tag:set_admins',-1,AdminPlayers)
end)