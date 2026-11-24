local module={}

function module.getOneData(dataName: string): ModuleScript?
    if not dataName then
        return
    end

    local dataModule=script:FindFirstChild(dataName)
    if not dataModule then
        return
    else
        return require(dataModule)
    end
end

function module.getAllData(): {ModuleScript?}
	local dataModulesList={}
	for _,value in pairs(script:GetChildren())do
		if value:IsA("ModuleScript") then
			if value:GetAttribute("data")==true then
				dataModulesList[value]=require(value)
			else
				warn(`PlayerData: "{value.Name}" is a ModuleScript but is missing the "data" attribute (or it's not set to true) — it will NOT be created for players. Set its "data" attribute to true if this is meant to be a real data category.`)
			end
		end
	end
	return dataModulesList
end

return module
