--] Settings [--

local moveDelay = 4
local topSpeed = 30

local rotationalTopSpeed = 3

local hideDestinationBlocks = true

--] Variables [--

local mainFolder = script.Parent
local platform = mainFolder.Platform
local alignPosition = platform.AlignPosition
local alignOrientation = platform.AlignOrientation

--] Helper Functions [--

-- Function to get and sort destinations based on their numbering
local function getSortedDestinations()
	local destinations = {}

	while true do
		local lowest = {nil, math.huge} -- Lowest destination found and its number

		for _, value in pairs(mainFolder:GetChildren()) do
			if value:IsA("BasePart") then
				local nameSplit = string.split(value.Name, " ")

				if #nameSplit == 2 and string.lower(nameSplit[1]) == "destination" then
					local destinationNumber = tonumber(nameSplit[2])

					if destinationNumber and destinationNumber < lowest[2] then
						lowest = {value, destinationNumber}
					end
				end
			end
		end

		if not lowest[1] then
			break
		else
			table.insert(destinations, lowest[1].CFrame)

			if hideDestinationBlocks then
				lowest[1]:Destroy() -- Optionally hide the destination block
			else
				lowest[1].Name = "Destination" -- Reset name to "Destination" if not hiding
			end
		end
	end

	return destinations
end

-- Function to move platform to a target CFrame
local function moveToDestination(cframe)
	alignPosition.Position = cframe.Position
	alignOrientation.CFrame = cframe.Rotation
end

--] Main Logic [--

local cframeList = getSortedDestinations()

if #cframeList == 0 then
	warn("No destinations found. Ensure destination blocks are named correctly.")
	return
end

-- Set platform properties
alignPosition.MaxVelocity = topSpeed
alignOrientation.MaxAngularVelocity = rotationalTopSpeed
platform.Anchored = false

-- Initial position and orientation
moveToDestination(cframeList[1])

-- Move platform through each destination in an endless loop
while true do
	for _, cframe in ipairs(cframeList) do
		moveToDestination(cframe)
		task.wait(moveDelay)
	end
end
