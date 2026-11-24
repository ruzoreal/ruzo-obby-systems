local M_PLAYER_DATA=require(game:GetService("ReplicatedStorage").Data.PlayerData)
local module={}

local function loopCreate(player: Player,data: {ModuleScript})
	if not player or not data then
		return
	end

	for index,value in data do
		local folder=Instance.new("Folder")
		folder.Name=string.lower(index.Name)
		for index,value in value do
			local childInstance=Instance.new(value.T)
			childInstance.Name=index
			childInstance.Value=value.V
			childInstance.Parent=folder
		end
		folder.Parent=player
	end
end

function module.createData(player: Player)
    if not player then
        return
    end
    
    local dataList=M_PLAYER_DATA.getAllData()
    if not dataList then
        return
    end
    
    loopCreate(player,dataList)
    
end

return module
