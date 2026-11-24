local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local ClientEvents = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Client")
local RemoteCheckPointChange = ClientEvents:WaitForChild("CheckPointChange")
local CheckPointEvent = ClientEvents:WaitForChild("CheckPointEvent")
local RemoteSyncStage = ClientEvents:WaitForChild("SyncStage")

local CheckpointsFolder = Workspace:WaitForChild("Checkpoints")

local debounce = {}

local function getCheckpoint(stageNumber)
	return CheckpointsFolder:FindFirstChild(tostring(stageNumber))
end

local function onCheckpointTouched(checkpoint, hit)
	local character = hit.Parent
	if not character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end

local debouncekey = player.UserId .. "_" .. checkpoint.Name
	if debounce[debouncekey] then
		return
	end
	debounce[debouncekey] = true
	task.delay(1, function()
		debounce[debouncekey] = nil
	end)


	local leaderstats = player:WaitForChild("leaderstats", 5)
	if not leaderstats then
		return
	end

	local stage = leaderstats:WaitForChild("Stage", 5)
	if not stage then
		return
	end

	local checkpointNumber = tonumber(checkpoint.Name)
	if not checkpointNumber then
		return
	end

	if checkpointNumber == stage.Value + 1 then
		stage.Value = checkpointNumber
		RemoteCheckPointChange:FireClient(player, checkpoint)
		CheckPointEvent:FireClient(player)
	end
end

for _, checkpoint in ipairs(CheckpointsFolder:GetChildren()) do
	if checkpoint:IsA("BasePart") then
		local checkpointNumber = tonumber(checkpoint.Name)
		if checkpointNumber then
			checkpoint.Touched:Connect(function(hit)
				onCheckpointTouched(checkpoint, hit)
			end)
		end
	end
end

local function syncCheckpointsToStage(player)
	local leaderstats = player:WaitForChild("leaderstats")
	local stage = leaderstats:WaitForChild("Stage")

	RemoteSyncStage:FireClient(player, stage.Value)

	return stage
end

local function onCharacterAdded(player, character)
	if not player:GetAttribute("DataLoaded") then
		player:GetAttributeChangedSignal("DataLoaded"):Wait()
	end

	local leaderstats = player:WaitForChild("leaderstats")
	local stage = leaderstats:WaitForChild("Stage")

	RemoteSyncStage:FireClient(player, stage.Value)

	local spawnCheckpoint = getCheckpoint(stage.Value)

	if not spawnCheckpoint then
		warn(`Could not find spawn checkpoint for {player.Name}, Stage {stage.Value}`)
		return
	end

	if not spawnCheckpoint:IsA("BasePart") then
		spawnCheckpoint =
			spawnCheckpoint:FindFirstChild("Circle")
			or spawnCheckpoint:FindFirstChildWhichIsA("BasePart", true)
	end

	if not spawnCheckpoint then
		warn(`Checkpoint {stage.Value} has no usable BasePart`)
		return
	end

	local hrp = character:WaitForChild("HumanoidRootPart")

	task.wait()

	character:PivotTo(
		spawnCheckpoint.CFrame
			* CFrame.new(0, 3, 0)
			* CFrame.Angles(0, math.rad(180), 0)
	)
end

local function onPlayerAdded(player)
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)
end

Players.PlayerAdded:Connect(onPlayerAdded)

for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
	if player.Character then
		task.spawn(onCharacterAdded, player, player.Character)
	end
end
