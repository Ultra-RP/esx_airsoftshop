local shopItems = {}

MySQL.ready(function()

	MySQL.Async.fetchAll('SELECT * FROM airsoftshops', {}, function(result)
		for i=1, #result, 1 do
			if shopItems[result[i].zone] == nil then
				shopItems[result[i].zone] = {}
			end

			table.insert(shopItems[result[i].zone], {
				item  = result[i].item,
				price = result[i].price,
				label = ESX.GetWeaponLabel(result[i].item)
			})
		end

		TriggerClientEvent('esx_aircraftshop:sendShop', -1, shopItems)
	end)

end)

ESX.RegisterServerCallback('esx_aircraftshop:getShop', function(source, cb)
	cb(shopItems)
end)

ESX.RegisterServerCallback('esx_aircraftshop:buyWeapon', function(source, cb, weaponName, zone)
	local xPlayer = ESX.GetPlayerFromId(source)
	local price = GetPrice(weaponName, zone)

	if price == 0 then
		print(('esx_aircraftshop: %s attempted to buy a unknown weapon!'):format(xPlayer.identifier))
		cb(false)
	else
		if xPlayer.hasWeapon(weaponName) then
			xPlayer.showNotification(_U('already_owned'))
			cb(false)
		else
			if zone == 'BlackWeashop' then
				if xPlayer.getAccount('black_money').money >= price then
					xPlayer.removeAccountMoney('black_money', price)
					xPlayer.addWeapon(weaponName, 42)
	
					cb(true)
				else
					xPlayer.showNotification(_U('not_enough_black'))
					cb(false)
				end
			else
				if xPlayer.getMoney() >= price then
					xPlayer.removeMoney(price)
					xPlayer.addWeapon(weaponName, 42)
	
					cb(true)
				else
					xPlayer.showNotification(_U('not_enough'))
					cb(false)
				end
			end
		end
	end
end)

ESX.RegisterServerCallback('esx_aircraftshop:buyShotgunAmmo', function(source, cb, zone)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local getbankmoney = xPlayer.getAccount('bank').money
    local getmoney = xPlayer.getMoney()
    local price = Config.ShotgunAmmoPrice

    if getbankmoney >= price then
        xPlayer.removeAccountMoney('bank', price)
        TriggerClientEvent('esx:showNotification', _source, _U('you_paid', price))
        canPay = true
    else
        canPay = false
        TriggerClientEvent('esx:showNotification', _source, _U('not_enough_money'))
    end
end)

ESX.RegisterServerCallback('esx_aircraftshop:buyArAmmo', function(source, cb, zone)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local getbankmoney = xPlayer.getAccount('bank').money
    local getmoney = xPlayer.getMoney()
    local price = Config.ArAmmoPrice

    if getbankmoney >= price then
        xPlayer.removeAccountMoney('bank', price)
        TriggerClientEvent('esx:showNotification', _source, _U('you_paid', price))
        canPay = true
    else
        canPay = false
        TriggerClientEvent('esx:showNotification', _source, _U('not_enough_money'))
    end
end)

ESX.RegisterServerCallback('esx_aircraftshop:buySmgAmmo', function(source, cb, zone)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local getbankmoney = xPlayer.getAccount('bank').money
    local getmoney = xPlayer.getMoney()
    local price = Config.SmgAmmoPrice

    if getbankmoney >= price then
        xPlayer.removeAccountMoney('bank', price)
        TriggerClientEvent('esx:showNotification', _source, _U('you_paid', price))
        canPay = true
    else
        canPay = false
        TriggerClientEvent('esx:showNotification', _source, _U('not_enough_money'))
    end
end)

ESX.RegisterServerCallback('esx_aircraftshop:buyPistolAmmo', function(source, cb, zone)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local getbankmoney = xPlayer.getAccount('bank').money
    local getmoney = xPlayer.getMoney()
    local price = Config.PistolAmmoPrice

    if getbankmoney >= price then
        xPlayer.removeAccountMoney('bank', price)
        TriggerClientEvent('esx:showNotification', _source, _U('you_paid', price))
        canPay = true
    else
        canPay = false
        TriggerClientEvent('esx:showNotification', _source, _U('not_enough_money'))
    end
end)

function GetPrice(weaponName, zone)
	local price = MySQL.Sync.fetchScalar('SELECT price FROM weashops WHERE zone = @zone AND item = @item', {
		['@zone'] = zone,
		['@item'] = weaponName
	})

	if price then
		return price
	else
		return 0
	end
end
