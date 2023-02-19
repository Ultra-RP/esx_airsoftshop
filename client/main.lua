local HasAlreadyEnteredMarker = false
local LastZone = nil
local CurrentAction = nil
local CurrentActionMsg = ''
local CurrentActionData = {}
local ShopOpen = false

ESX.TriggerServerCallback('esx_aircraftshop:getShop', function(shopItems)
	for k,v in pairs(shopItems) do
		Config.Zones[k].Items = v
	end
end)

RegisterNetEvent('esx_aircraftshop:sendShop')
AddEventHandler('esx_aircraftshop:sendShop', function(shopItems)
	for k,v in pairs(shopItems) do
		Config.Zones[k].Items = v
	end
end)

function OpenBuyLicenseMenu(zone)
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_license', {
		title = _U('buy_license'),
		align = 'top-left',
		elements = {
			{label = _U('no'), value = 'no'},
			{label = _U('yes', ('<span style="color: green;">%s</span>'):format((_U('shop_menu_item', ESX.Math.GroupDigits(Config.LicensePrice))))), value = 'yes'},
		}
	}, function(data, menu)
		if data.current.value == 'yes' then
			ESX.TriggerServerCallback('esx_aircraftshop:buyLicense', function(bought)
				if bought then
					menu.close()
					OpenMainMenu(zone)
				end
			end)
		end
	end, function(data, menu)
		menu.close()
	end)
end

function OpenMainMenu(zone)
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'main', {
		title    = _U('shop_menu_title'),
		align    = 'top-left',
		elements = { 
			{label = _U('open_weapon'), value = 'open_weapon'},         
			{label = _U('open_ammo'), value = 'open_ammo'}
	}}, function(data, menu)

		if data.current.value == 'open_weapon' then
			OpenShopMenu(CurrentActionData.zone) 
		elseif data.current.value == 'open_ammo' then
			OpenAmmoMenu()
		end

	end, function(data, menu)
		PlaySoundFrontend(-1, 'BACK', 'HUD_AMMO_SHOP_SOUNDSET', false)
		ShopOpen = false
		menu.close()

	end, function(data, menu)
		PlaySoundFrontend(-1, 'NAV', 'HUD_AMMO_SHOP_SOUNDSET', false)
	end)
end

function OpenAmmoMenu()
	ESX.UI.Menu.CloseAll()
	local elements = {}
	ShopOpen = true

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'main', {
		title    = _U('shop_menu_title'),
		align    = 'top-left',
		elements = { 
			{label = _U('add_ammo_shot'),     value = 'add_ammo_shot'},
			{label = _U('add_ammo_ar'),     value = 'add_ammo_ar'},
			{label = _U('add_ammo_smg'),     value = 'add_ammo_smg'},
			{label = _U('add_ammo_pistol'),     value = 'add_ammo_pistol'}
	}}, function(data, menu)

		if data.current.value == 'add_ammo_shot' then
			TriggerEvent('esx_aircraftshop:add_ammo_shot')
			ESX.TriggerServerCallback('esx_aircraftshop:buyShotgunAmmo')
		elseif data.current.value == 'add_ammo_ar' then
			TriggerEvent('esx_aircraftshop:add_ammo_ar')
			ESX.TriggerServerCallback('esx_aircraftshop:buyArAmmo')
		elseif data.current.value == 'add_ammo_smg' then
			TriggerEvent('esx_aircraftshop:add_ammo_smg')
			ESX.TriggerServerCallback('esx_aircraftshop:buySmgAmmo')
		elseif data.current.value == 'add_ammo_pistol' then
			TriggerEvent('esx_aircraftshop:add_ammo_pistol')
			ESX.TriggerServerCallback('esx_aircraftshop:buyPistolAmmo')
		end

	end, function(data, menu)
		PlaySoundFrontend(-1, 'BACK', 'HUD_AMMO_SHOP_SOUNDSET', false)
		ShopOpen = false
		menu.close()

	end, function(data, menu)
		PlaySoundFrontend(-1, 'NAV', 'HUD_AMMO_SHOP_SOUNDSET', false)
	end)
end

function OpenShopMenu(zone)
	local elements = {}
	ShopOpen = true

	for i=1, #Config.Zones[zone].Items, 1 do
		local item = Config.Zones[zone].Items[i]

		table.insert(elements, {
			label = ('%s - <span style="color: green;">%s</span>'):format(item.label, _U('shop_menu_item', ESX.Math.GroupDigits(item.price))),
			price = item.price,
			weaponName = item.item
		})
	end

	PlaySoundFrontend(-1, 'BACK', 'HUD_AMMO_SHOP_SOUNDSET', false)

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop', {
		title = _U('shop_menu_title'),
		align = 'top-left',
		elements = elements
	}, function(data, menu)
		ESX.TriggerServerCallback('esx_aircraftshop:buyWeapon', function(bought)
			if bought then
				DisplayBoughtScaleform(data.current.weaponName, data.current.price)
			else
				PlaySoundFrontend(-1, 'ERROR', 'HUD_AMMO_SHOP_SOUNDSET', false)
			end
		end, data.current.weaponName, zone)
	end, function(data, menu)
		PlaySoundFrontend(-1, 'BACK', 'HUD_AMMO_SHOP_SOUNDSET', false)
		ShopOpen = false
		menu.close()

	end, function(data, menu)
		PlaySoundFrontend(-1, 'NAV', 'HUD_AMMO_SHOP_SOUNDSET', false)
	end)
end

function DisplayBoughtScaleform(weaponName, price)
	local scaleform = ESX.Scaleform.Utils.RequestScaleformMovie('MP_BIG_MESSAGE_FREEMODE')
	local sec = 4

	BeginScaleformMovieMethod(scaleform, 'SHOW_WEAPON_PURCHASED')

	PushScaleformMovieMethodParameterString(_U('weapon_bought', ESX.Math.GroupDigits(price)))
	PushScaleformMovieMethodParameterString(ESX.GetWeaponLabel(weaponName))
	PushScaleformMovieMethodParameterInt(GetHashKey(weaponName))
	PushScaleformMovieMethodParameterString('')
	PushScaleformMovieMethodParameterInt(100)

	EndScaleformMovieMethod()

	PlaySoundFrontend(-1, 'WEAPON_PURCHASE', 'HUD_AMMO_SHOP_SOUNDSET', false)

	Citizen.CreateThread(function()
		while sec > 0 do
			Citizen.Wait(0)
			sec = sec - 0.01
	
			DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
		end
	end)
end

RegisterNetEvent('esx_aircraftshop:add_ammo_shot')
AddEventHandler('esx_aircraftshop:add_ammo_shot', function()
	local playerPed = GetPlayerPed()
	local weapon = GetHashKey("weapon_pumpshotgun")

	AddAmmoToPed(GetPlayerPed(-1), weapon1, 600)

end)

RegisterNetEvent('esx_aircraftshop:add_ammo_ar')
AddEventHandler('esx_aircraftshop:add_ammo_ar', function()
	local playerPed = GetPlayerPed()
	local weapon = GetHashKey("weapon_specialcarbine")

	AddAmmoToPed(GetPlayerPed(-1), weapon, 600)

end)

RegisterNetEvent('esx_aircraftshop:add_ammo_smg')
AddEventHandler('esx_aircraftshop:add_ammo_smg', function()
	local playerPed = GetPlayerPed()
	local weapon = GetHashKey("weapon_smg")

	AddAmmoToPed(GetPlayerPed(-1), weapon, 600)

end)

RegisterNetEvent('esx_aircraftshop:add_ammo_pistol')
AddEventHandler('esx_aircraftshop:add_ammo_pistol', function()
	local playerPed = GetPlayerPed()
	local weapon = GetHashKey("weapon_combatpistol")

	AddAmmoToPed(GetPlayerPed(-1), weapon, 600)

end)

AddEventHandler('esx_aircraftshop:hasEnteredMarker', function(zone)
	if zone == 'AirSoftShop' or zone == 'BlackWeashop' then
		CurrentAction     = 'shop_menu'
		CurrentActionMsg  = _U('shop_menu_prompt')
		CurrentActionData = { zone = zone }
	end
end)

AddEventHandler('esx_aircraftshop:hasExitedMarker', function(zone)
	CurrentAction = nil
	ESX.UI.Menu.CloseAll()
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		if ShopOpen then
			ESX.UI.Menu.CloseAll()
		end
	end
end)

-- Create Blips
Citizen.CreateThread(function()
	for k,v in pairs(Config.Zones) do
		if v.Legal then
			for i = 1, #v.Locations, 1 do
				local blip = AddBlipForCoord(v.Locations[i])

				SetBlipSprite (blip, 110)
				SetBlipDisplay(blip, 4)
				SetBlipScale  (blip, 1.0)
				SetBlipColour (blip, 81)
				SetBlipAsShortRange(blip, true)

				BeginTextCommandSetBlipName("STRING")
				AddTextComponentSubstringPlayerName(_U('map_blip'))
				EndTextCommandSetBlipName(blip)
			end
		end
	end
end)

-- Display markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		local coords = GetEntityCoords(PlayerPedId())

		for k,v in pairs(Config.Zones) do
			for i = 1, #v.Locations, 1 do
				if (Config.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Locations[i], true) < Config.DrawDistance) then
					DrawMarker(Config.Type, v.Locations[i], 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.Size.x, Config.Size.y, Config.Size.z, Config.Color.r, Config.Color.g, Config.Color.b, 100, false, true, 2, false, false, false, false)
				end
			end
		end
	end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local coords = GetEntityCoords(PlayerPedId())
		local isInMarker, currentZone = false, nil

		for k,v in pairs(Config.Zones) do
			for i=1, #v.Locations, 1 do
				if GetDistanceBetweenCoords(coords, v.Locations[i], true) < Config.Size.x then
					isInMarker, ShopItems, currentZone, LastZone = true, v.Items, k, k
				end
			end
		end
		if isInMarker and not HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = true
			TriggerEvent('esx_aircraftshop:hasEnteredMarker', currentZone)
		end
		
		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('esx_aircraftshop:hasExitedMarker', LastZone)
		end
	end
end)

-- Key Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if CurrentAction ~= nil then
			ESX.ShowHelpNotification(CurrentActionMsg)

			if IsControlJustReleased(0, 38) then

				if CurrentAction == 'shop_menu' then
					if Config.LicenseEnable and Config.Zones[CurrentActionData.zone] then
						ESX.TriggerServerCallback('esx_license:checkLicense', function(hasWeaponLicense)
							if hasWeaponLicense then
								OpenMainMenu(CurrentActionData.zone)
							else
								OpenBuyLicenseMenu(CurrentActionData.zone)
							end
						end, GetPlayerServerId(PlayerId()), 'weapon')
					else
						OpenMainMenu(CurrentActionData.zone)
					end
				end

				CurrentAction = nil
			end
		end
	end
end)
