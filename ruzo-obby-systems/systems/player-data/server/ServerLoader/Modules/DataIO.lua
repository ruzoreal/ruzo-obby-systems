local DATASTORE=game:GetService("DataStoreService"):GetDataStore(game:GetService("ReplicatedStorage").GameSettings.Configs.DataName.Value)
local module={}
local function setDataToTable(player: Player,data: {any})
	if not player or not data then
		return
	end
	for _,value in pairs(player:GetDescendants())do
		if value:IsA("ValueBase")and data[value.Name] == nil then
			data[value.Name]= value.Value
		end
	end
end
local function setDataToValue(player: Player,data: {any})
	if not player or not data then
		return
	end
	for _,value in pairs(player:GetDescendants())do
		if value:IsA("ValueBase") and data[value.Name] ~= nil then
			value.Value = data[value.Name]
		end
	end
end

function module.loadData(player: Player)
	local key=`player_{player.UserId}`
	local data
	local success,errormessage
	for attempt=1,3 do
		success,errormessage=pcall(function()
			data=DATASTORE:GetAsync(key)
		end)
		if success then break end
		warn(`Load attempt {attempt} failed for {player.Name}: {errormessage}`)
		task.wait(2*attempt)
	end
	if not success then
		warn(`Data failed to load for {player.Name} after 3 attempts — kicking to prevent overwriting their save.`)
		player:Kick("Failed to load your data. Please rejoin — your progress is safe.")
		return false
	end
	if data then
		setDataToValue(player,data)
	end
	player:SetAttribute("DataLoaded", true)
	return true
end

function module.saveData(player: Player)
	if not player:GetAttribute("DataLoaded") then
		warn(`Skipped saving for {player.Name} — their data never finished loading.`)
		return
	end

	local key=`player_{player.UserId}`
	local data={}
	setDataToTable(player,data)
	local success,errormessage=pcall(function()
		DATASTORE:UpdateAsync(key, function()
			return data
		end)
	end)
	if success then
	else
		warn(errormessage)
	end
end
return module
