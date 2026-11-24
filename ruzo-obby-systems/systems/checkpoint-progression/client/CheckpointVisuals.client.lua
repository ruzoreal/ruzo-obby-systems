local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local remote = ReplicatedStorage:WaitForChild("Remotes")
	:WaitForChild("Client")
	:WaitForChild("CheckPointChange")

local ResetWorld = ReplicatedStorage:WaitForChild("Remotes")
	:WaitForChild("Client")
	:WaitForChild("ResetWorld")

local MaxStage = ReplicatedStorage:WaitForChild("GameSettings")
	:WaitForChild("Configs")
	:WaitForChild("MaxCheckpoints").Value
local RemoteSyncStage = ReplicatedStorage:WaitForChild("Remotes")
	:WaitForChild("Client"):WaitForChild("SyncStage")

local GameSettings = ReplicatedStorage:WaitForChild("GameSettings")
local SoundSuccess = GameSettings.Sounds:WaitForChild("Sucess")
local SoundFinal = GameSettings.Sounds:WaitForChild("Final")
local activeTweens = {}

local resetting = false

local function resetCheckpoint(Checkpoint)
	local Flag = Checkpoint:FindFirstChild("Flag")
	if not Flag then return end

	local FlagObject = Flag:FindFirstChild("Flag")
	local Circle = Checkpoint:FindFirstChild("Circle")
	local HasCompleted = Checkpoint:FindFirstChild("Has")

	if HasCompleted then
		HasCompleted.Value = false
	end

	if FlagObject and FlagObject:GetAttribute("StartCFrame") then
		FlagObject.CFrame = FlagObject:GetAttribute("StartCFrame")
	end

	if Circle then
		Circle.Color = Color3.fromRGB(230, 19, 86)
	end
	
	if FlagObject then
		FlagObject.Color = Color3.fromRGB(230, 19, 86)
	end
end

ResetWorld.OnClientEvent:Connect(function()
	resetting = true

	for _, cp in pairs(workspace.Checkpoints:GetChildren()) do
		resetCheckpoint(cp)
	end

	task.wait(0.3)
	resetting = false
end)

local function onRemote(Checkpoint, Join)
	if resetting then return end
	if not Checkpoint then return end

	local Flag = Checkpoint:FindFirstChild("Flag")
	local Circle = Checkpoint:FindFirstChild("Circle")
	local HasCompleted = Checkpoint:FindFirstChild("Has")

	if not Flag or not Circle or not HasCompleted then return end

	local FlagObject = Flag:FindFirstChild("Flag")
	local Particles = Flag:FindFirstChild("Particles")

	if not FlagObject then
		return
	end

	if not FlagObject:GetAttribute("StartCFrame") then
		FlagObject:SetAttribute("StartCFrame", FlagObject.CFrame)
	end

	local p1 = Particles and Particles:FindFirstChild("p1")
	local p2 = Particles and Particles:FindFirstChild("p2")
	local p3 = Particles and Particles:FindFirstChild("p3")
	local p4 = Particles and Particles:FindFirstChild("p4")

	local function playSound(sound)
		if sound and not sound.IsPlaying then
			sound:Play()
		end
	end

	if Checkpoint.Name == "0" then return end

	if Join and HasCompleted.Value then
		Circle.Color = Color3.fromRGB(130, 222, 10)
		FlagObject.Color = Color3.fromRGB(130, 222, 10)
		FlagObject.CFrame = FlagObject:GetAttribute("StartCFrame") * CFrame.new(0, 3.310, 0)
		return
	end

	if not Join and HasCompleted.Value then
		return
	end

	if not Join and activeTweens[Checkpoint] then
		return
	end

	HasCompleted.Value = true

	Circle.Color = Color3.fromRGB(130, 222, 10)
	FlagObject.Color = Color3.fromRGB(130, 222, 10)

	if Checkpoint.Name == tostring(MaxStage) then
		playSound(SoundFinal)
	else
		playSound(SoundSuccess)
	end

	if p1 then p1.Enabled = true end
	if p2 then p2.Enabled = true end
	if p3 then p3.Enabled = true end
	if p4 then p4.Enabled = true end

	task.wait(0.1)
	
	if resetting then return end
	if p1 then p1.Enabled = false end
	if p2 then p2.Enabled = false end
	if p3 then p3.Enabled = false end
	if p4 then p4.Enabled = false end

	local tweenInfo = TweenInfo.new(
		1,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out,
		0,
		false,
		0.1
	)

	local startCFrame = FlagObject.CFrame
	local targetCFrame = startCFrame * CFrame.new(0, 3.310, 0)

	local cf = Instance.new("CFrameValue")
	cf.Value = startCFrame

	local record = { cf = cf }
	record.conn = cf:GetPropertyChangedSignal("Value"):Connect(function()
		if resetting then
			record.conn:Disconnect()
			if record.tween then
				record.tween:Cancel()
			end
			record.cf:Destroy()
			activeTweens[Checkpoint] = nil
			return
		end
		FlagObject.CFrame = cf.Value
	end)

	record.tween = TweenService:Create(cf, tweenInfo, { Value = targetCFrame })
	record.tween.Completed:Connect(function()
		record.conn:Disconnect()
		record.cf:Destroy()
		if activeTweens[Checkpoint] == record then
			activeTweens[Checkpoint] = nil
		end
	end)

	activeTweens[Checkpoint] = record
	record.tween:Play()
end

remote.OnClientEvent:Connect(onRemote)

RemoteSyncStage.OnClientEvent:Connect(function(myStage)
	for _, cp in pairs(workspace.Checkpoints:GetChildren()) do
		local n = tonumber(cp.Name)
		local has = cp:FindFirstChild("Has")
		if n and has and n <= myStage then
			has.Value = true
			onRemote(cp, true)
		end
	end
end)
