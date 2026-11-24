local S_PLAYERS = game:GetService("Players")
local M_DATA_IO = require(script.Modules.DataIO)
local M_CREATE_DATA = require(script.Modules.CreateData)
local savingPlayers = {}

local function addedHandler(player: Player)
	if not player then 
		return 
	end

	M_CREATE_DATA.createData(player)
	M_DATA_IO.loadData(player)
end

local function removingHandler(player: Player)
	if not player or savingPlayers[player] then
		return 
	end

	savingPlayers[player] = true
	M_DATA_IO.saveData(player)
	savingPlayers[player] = nil
end

game:BindToClose(function()
	local players = S_PLAYERS:GetPlayers()
	local remaining = #players

	for _, player in ipairs(players) do
		task.spawn(function()
			removingHandler(player)
			remaining -= 1
		end)
	end

	local deadline = os.clock() + 25

	while remaining > 0 and os.clock() < deadline do
		task.wait()
	end
end)

S_PLAYERS.PlayerAdded:Connect(addedHandler)
S_PLAYERS.PlayerRemoving:Connect(removingHandler)
