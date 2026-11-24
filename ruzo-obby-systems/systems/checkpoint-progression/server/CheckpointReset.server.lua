local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientFolder = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Client")
local ResetRemote = ClientFolder:WaitForChild("ResetFunction")
local ChangeBackRemote = ClientFolder:WaitForChild("ChangeBack")
local ResetWorld = ClientFolder:WaitForChild("ResetWorld")
local MaxStage = ReplicatedStorage.GameSettings.Configs.MaxCheckpoints

local function resetWorld(player)
	ResetWorld:FireClient(player)
end

local resetDebounce = {}

local function OnServerFunction(Player: Player)
	if not Player then return false end

	if resetDebounce[Player.UserId] then
		return false
	end
	resetDebounce[Player.UserId] = true
	task.delay(1, function()
		resetDebounce[Player.UserId] = nil
	end)

	local CurrentStage = Player:FindFirstChild("leaderstats") and Player.leaderstats:FindFirstChild("Stage")
	if not CurrentStage then return false end

	if CurrentStage.Value >= MaxStage.Value then
		local Wins = Player:FindFirstChild("playerstats") and Player.playerstats:FindFirstChild("Wins")
		CurrentStage.Value = 0
		if Wins then
			Wins.Value += 1
		end

		local character = Player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.Health = 0
		end

		resetWorld(Player)
		return true
	end

	return false
end

ResetRemote.OnServerInvoke = OnServerFunction
