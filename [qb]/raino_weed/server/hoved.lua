local raino = exports['raino_core']:GetCoreObject()

raino.Functions.CreateCallback('raino_weed:server:getBuildingPlants', function(_, cb, building)
    local buildingPlants = {}

    MySQL.query('SELECT * FROM house_plants WHERE building = ?', {building}, function(plants)
        for i = 1, #plants, 1 do
            buildingPlants[#buildingPlants+1] = plants[i]
        end

        if buildingPlants ~= nil then
            cb(buildingPlants)
        else
            cb(nil)
        end
    end)
end)

RegisterNetEvent('raino_weed:server:placePlant', function(coords, sort, currentHouse)
    local random = math.random(1, 2)
    local gender
    if random == 1 then
        gender = "man"
    else
        gender = "woman"
    end
    MySQL.insert('INSERT INTO house_plants (building, coords, gender, sort, plantid) VALUES (?, ?, ?, ?, ?)',
        {currentHouse, coords, gender, sort, math.random(111111, 999999)})
    TriggerClientEvent('raino_weed:client:refreshHousePlants', -1, currentHouse)
end)

RegisterNetEvent('raino_weed:server:removeDeathPlant', function(building, plantId)
    MySQL.query('DELETE FROM house_plants WHERE plantid = ? AND building = ?', {plantId, building})
    TriggerClientEvent('raino_weed:client:refreshHousePlants', -1, building)
end)

CreateThread(function()
    while true do
        local housePlants = MySQL.query.await('SELECT * FROM house_plants', {})
        for k, _ in pairs(housePlants) do
            if housePlants[k].food >= 50 then
                MySQL.update('UPDATE house_plants SET food = ? WHERE plantid = ?',
                    {(housePlants[k].food - 1), housePlants[k].plantid})
                if housePlants[k].health + 1 < 100 then
                    MySQL.update('UPDATE house_plants SET health = ? WHERE plantid = ?',
                        {(housePlants[k].health + 1), housePlants[k].plantid})
                end
            end

            if housePlants[k].food < 50 then
                if housePlants[k].food - 1 >= 0 then
                    MySQL.update('UPDATE house_plants SET food = ? WHERE plantid = ?',
                        {(housePlants[k].food - 1), housePlants[k].plantid})
                end
                if housePlants[k].health - 1 >= 0 then
                    MySQL.update('UPDATE house_plants SET health = ? WHERE plantid = ?',
                        {(housePlants[k].health - 1), housePlants[k].plantid})
                end
            end
        end
        TriggerClientEvent('raino_weed:client:refreshPlantStats', -1)
        Wait((60 * 1000) * 19.2)
    end
end)

CreateThread(function()
    while true do
        local housePlants = MySQL.query.await('SELECT * FROM house_plants', {})
        for k, _ in pairs(housePlants) do
            if housePlants[k].health > 50 then
                local Grow = math.random(1, 3)
                if housePlants[k].progress + Grow < 100 then
                    MySQL.update('UPDATE house_plants SET progress = ? WHERE plantid = ?',
                        {(housePlants[k].progress + Grow), housePlants[k].plantid})
                elseif housePlants[k].progress + Grow >= 100 then
                    if housePlants[k].stage ~= QBWeed.Plants[housePlants[k].sort]["highestStage"] then
                        if housePlants[k].stage == "stage-a" then
                            MySQL.update('UPDATE house_plants SET stage = ? WHERE plantid = ?',
                                {'stage-b', housePlants[k].plantid})
                        elseif housePlants[k].stage == "stage-b" then
                            MySQL.update('UPDATE house_plants SET stage = ? WHERE plantid = ?',
                                {'stage-c', housePlants[k].plantid})
                        elseif housePlants[k].stage == "stage-c" then
                            MySQL.update('UPDATE house_plants SET stage = ? WHERE plantid = ?',
                                {'stage-d', housePlants[k].plantid})
                        elseif housePlants[k].stage == "stage-d" then
                            MySQL.update('UPDATE house_plants SET stage = ? WHERE plantid = ?',
                                {'stage-e', housePlants[k].plantid})
                        elseif housePlants[k].stage == "stage-e" then
                            MySQL.update('UPDATE house_plants SET stage = ? WHERE plantid = ?',
                                {'stage-f', housePlants[k].plantid})
                        elseif housePlants[k].stage == "stage-f" then
                            MySQL.update('UPDATE house_plants SET stage = ? WHERE plantid = ?',
                                {'stage-g', housePlants[k].plantid})
                        end
                        MySQL.update('UPDATE house_plants SET progress = ? WHERE plantid = ?',
                            {0, housePlants[k].plantid})
                    end
                end
            end
        end
        TriggerClientEvent('raino_weed:client:refreshPlantStats', -1)
        Wait((60 * 1000) * 9.6)
    end
end)

raino.Functions.CreateUseableItem("weed_white-widow_seed", function(source, item)
    TriggerClientEvent('raino_weed:client:placePlant', source, 'white-widow', item)
end)

raino.Functions.CreateUseableItem("weed_skunk_seed", function(source, item)
    TriggerClientEvent('raino_weed:client:placePlant', source, 'skunk', item)
end)

raino.Functions.CreateUseableItem("weed_purple-haze_seed", function(source, item)
    TriggerClientEvent('raino_weed:client:placePlant', source, 'purple-haze', item)
end)

raino.Functions.CreateUseableItem("weed_og-kush_seed", function(source, item)
    TriggerClientEvent('raino_weed:client:placePlant', source, 'og-kush', item)
end)

raino.Functions.CreateUseableItem("weed_amnesia_seed", function(source, item)
    TriggerClientEvent('raino_weed:client:placePlant', source, 'amnesia', item)
end)

raino.Functions.CreateUseableItem("weed_ak47_seed", function(source, item)
    TriggerClientEvent('raino_weed:client:placePlant', source, 'ak47', item)
end)

raino.Functions.CreateUseableItem("weed_nutrition", function(source, item)
    TriggerClientEvent('raino_weed:client:foodPlant', source, item)
end)

RegisterServerEvent('raino_weed:server:removeSeed', function(itemslot, seed)
    local src = source
    local Player = raino.Functions.GetPlayer(src)
    Player.Functions.RemoveItem(seed, 1, itemslot)
end)

RegisterNetEvent('raino_weed:server:harvestPlant', function(house, amount, plantName, plantId)
    local src = source
    local Player = raino.Functions.GetPlayer(src)
    local weedBag = Player.Functions.GetItemByName('empty_weed_bag')
    local sndAmount = math.random(12, 16)

    if weedBag ~= nil then
        if weedBag.amount >= sndAmount then
            if house ~= nil then
                local result = MySQL.query.await(
                    'SELECT * FROM house_plants WHERE plantid = ? AND building = ?', {plantId, house})
                if result[1] ~= nil then
                    Player.Functions.AddItem('weed_' .. plantName .. '_seed', amount)
                    Player.Functions.AddItem('weed_' .. plantName, sndAmount)
                    Player.Functions.RemoveItem('empty_weed_bag', sndAmount)
                    MySQL.query('DELETE FROM house_plants WHERE plantid = ? AND building = ?',
                        {plantId, house})
                    TriggerClientEvent('raino:Notify', src,  Lang:t('text.the_plant_has_been_harvested'), 'success', 3500)
                    TriggerClientEvent('raino_weed:client:refreshHousePlants', -1, house)
                else
                    TriggerClientEvent('raino:Notify', src, Lang:t('error.this_plant_no_longer_exists'), 'error', 3500)
                end
            else
                TriggerClientEvent('raino:Notify', src, Lang:t('error.house_not_found'), 'error', 3500)
            end
        else
            TriggerClientEvent('raino:Notify', src, Lang:t('error.you_dont_have_enough_resealable_bags'), 'error', 3500)
        end
    else
        TriggerClientEvent('raino:Notify', src, Lang:t('error.you_Dont_have_enough_resealable_bags'), 'error', 3500)
    end
end)

RegisterNetEvent('raino_weed:server:foodPlant', function(house, amount, plantName, plantId)
    local src = source
    local Player = raino.Functions.GetPlayer(src)
    local plantStats = MySQL.query.await(
        'SELECT * FROM house_plants WHERE building = ? AND sort = ? AND plantid = ?',
        {house, plantName, tostring(plantId)})
    TriggerClientEvent('raino:Notify', src,
        QBWeed.Plants[plantName]["label"] .. ' | Ernæring: ' .. plantStats[1].food .. '% + ' .. amount .. '% (' ..
            (plantStats[1].food + amount) .. '%)', 'success', 3500)
    if plantStats[1].food + amount > 100 then
        MySQL.update('UPDATE house_plants SET food = ? WHERE building = ? AND plantid = ?',
            {100, house, plantId})
    else
        MySQL.update('UPDATE house_plants SET food = ? WHERE building = ? AND plantid = ?',
            {(plantStats[1].food + amount), house, plantId})
    end
    Player.Functions.RemoveItem('weed_nutrition', 1)
    TriggerClientEvent('raino_weed:client:refreshHousePlants', -1, house)
end)
