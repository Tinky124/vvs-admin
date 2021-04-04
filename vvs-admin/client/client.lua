local duty = false

ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function cleanPlayer(playerPed)
	SetPedArmour(playerPed, 0)
	ClearPedBloodDamage(playerPed)
	ResetPedVisibleDamage(playerPed)
	ClearPedLastWeaponDamage(playerPed)
	ResetPedMovementClipset(playerPed, 0)
end

function setUniform(playerPed)
  local playerPed = PlayerPedId()

	TriggerEvent('skinchanger:getSkin', function(skin)
      ESX.TriggerServerCallback("Admin:getRankFromPlayer", function(group)
        if skin.sex == 0 then
          if group == "superadmin" then
            TriggerEvent("skinchanger:loadClothes", skin, Config.Admin.superadmin.male)
          elseif group == "admin" then
            TriggerEvent("skinchanger:loadClothes", skin, Config.Admin.admin.male)
          end
        else
          if group == "superadmin" then
            TriggerEvent("skinchanger:loadClothes", skin, Config.Admin.superadmin.female)
          elseif group == "admin" then
            TriggerEvent("skinchanger:loadClothes", skin, Config.Admin.admin.female)
          end
          

        end
      end)
	end)
end

local playerPed = PlayerPedId()
function resetUniform(playerPed)
ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
	TriggerEvent('skinchanger:loadSkin', skin)
	end)
end

RegisterNetEvent("toggleOnDuty")
AddEventHandler("toggleOnDuty", function(source)
  TriggerEvent("skinchanger:getSkin", function(skin)   
      duty = true
      TriggerEvent("chatMessage", "^8 ^8VVS ^0| Sada ste na duznosti, kada zavrsite sa poslom kucajte /offduty.")
      --resetUniform(playerPed) -- If you want on duty get admin skin delete "--"
    end)   
end)

RegisterNetEvent("toggleOffDuty")
AddEventHandler("toggleOffDuty", function(source)
  TriggerEvent("skinchanger:getSkin", function(skin)   
      duty = false
      TriggerEvent("chatMessage", "^8 ^8VVS ^0| Vise niste na duznosti, da se vratite na duznost kucajte /onduty.")
     
      --resetUniform(playerPed) If you want on duty get admin skin delete "--"

  end)   
end)