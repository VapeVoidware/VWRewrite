repeat task.wait() until game:IsLoaded()
repeat task.wait() until shared.GuiLibrary

local function run(func)
	task.spawn(function()
		local suc, err = pcall(function() func() end)
		if err then warn("[VW687224481.lua Module Error]: "..tostring(debug.traceback(err))) end
	end)
end
local GuiLibrary = shared.GuiLibrary
local store = shared.GlobalStore
local bedwars = shared.GlobalBedwars
local vape = shared.vape
local entitylib = vape.Libraries.entity
local targetinfo = vape.Libraries.targetinfo
local sessioninfo = vape.Libraries.sessioninfo
local uipallet = vape.Libraries.uipallet
local tween = vape.Libraries.tween
local color = vape.Libraries.color
local whitelist = vape.Libraries.whitelist
local prediction = vape.Libraries.prediction
local getfontsize = vape.Libraries.getfontsize
local getcustomasset = vape.Libraries.getcustomasset

local runService = game:GetService("RunService")
local RunService = runService
local runservice = runService

local CustomsAllowed = false

local collectionService = game:GetService("CollectionService")
local CollectionService = collectionService
shared.vapewhitelist = vape.Libraries.whitelist
local playersService = game:GetService("Players")
if (not shared.GlobalBedwars) or (shared.GlobalBedwars and type(shared.GlobalBedwars) ~= "table") or (not shared.GlobalStore) or (shared.GlobalStore and type(shared.GlobalStore) ~= "table") then
	errorNotification("VW-BEDWARS", "Critical! Important connection is missing! Please report this bug to erchodev#0", 10)
	pcall(function()
		function GuiLibrary:Save()
			warningNotification("GuiLibrary.SaveSettings", "Profiles saving is disabled due to error in the code!", 1)
		end
	end)
	local delfile = delfile or function(file) writefile(file, "") end
	if isfile('vape/games/6872274481.lua') then delfile('vape/games/6872274481.lua') end
end
local entityLibrary = entitylib
local VoidwareStore = {
	bedtable = {},
	Tweening = false
}

local networkownerswitch = tick()
-- xylex ._.
local isnetworkowner = function(part)
	local suc, res = pcall(function() return gethiddenproperty(part, "NetworkOwnershipRule") end)
	if suc and res == Enum.NetworkOwnership.Manual then
		sethiddenproperty(part, "NetworkOwnershipRule", Enum.NetworkOwnership.Automatic)
		networkownerswitch = tick() + 8
	end
	return networkownerswitch <= tick()
end

VoidwareFunctions.GlobaliseObject("lplr", game:GetService("Players").LocalPlayer)
VoidwareFunctions.LoadFunctions("Bedwars")

local function BedwarsInfoNotification(mes)
    local bedwars = shared.GlobalBedwars
	local NotificationController = bedwars.NotificationController
	NotificationController:sendInfoNotification({
		message = tostring(mes),
		image = "rbxassetid://18518244636"
	});
end
getgenv().BedwarsInfoNotification = BedwarsInfoNotification
local function BedwarsErrorNotification(mes)
    local bedwars = shared.GlobalBedwars
	local NotificationController = bedwars.NotificationController
	NotificationController:sendErrorNotification({
		message = tostring(mes),
		image = "rbxassetid://18518244636"
	});
end
getgenv().BedwarsErrorNotification = BedwarsErrorNotification

VoidwareFunctions.LoadFunctions("Bedwars")

local gameCamera = game.Workspace.CurrentCamera

local lplr = game:GetService("Players").LocalPlayer

local btext = function(text)
	return text..' '
end
local void = function() end
local runservice = game:GetService("RunService")
local newcolor = function() return {Hue = 0, Sat = 0, Value = 0} end
function safearray()
    local array = {}
    local mt = {}
    function mt:__index(index)
        if type(index) == "number" and (index < 1 or index > #array) then
            return nil
        end
        return array[index]
    end
    function mt:__newindex(index, value)
        if type(index) == "number" and index > 0 then
            array[index] = value
        else
            error("Invalid index for safearray", 2)
        end
    end
    function mt:insert(value)
        table.insert(array, value)
    end
    function mt:remove(index)
        if type(index) == "number" and index > 0 and index <= #array then
            table.remove(array, index)
        else
            error("Invalid index for safearray removal", 2)
        end
    end
    function mt:length()
        return #array
	end
    setmetatable(array, mt)
    return array
end
function getrandomvalue(list)
    local count = #list
    if count == 0 then
        return ''
    end
    local randomIndex = math.random(1, count)
    return list[randomIndex]
end

local vapeConnections
if shared.vapeConnections and type(shared.vapeConnections) == "table" then vapeConnections = shared.vapeConnections else vapeConnections = {} shared.vapeConnections = vapeConnections end

GuiLibrary.SelfDestructEvent.Event:Connect(function()
	for i, v in pairs(vapeConnections) do
		if v.Disconnect then pcall(function() v:Disconnect() end) continue end
		if v.disconnect then pcall(function() v:disconnect() end) continue end
	end
end)
local whitelist = shared.vapewhitelist

task.spawn(function()
    pcall(function()
        local lplr = game:GetService("Players").LocalPlayer
        local char = lplr.Character or lplr.CharacterAdded:wait()
        local displayName = char:WaitForChild("Head"):WaitForChild("Nametag"):WaitForChild("DisplayNameContainer"):WaitForChild("DisplayName")
        repeat task.wait() until shared.vapewhitelist
        repeat task.wait() until shared.vapewhitelist.loaded
        local tag = shared.vapewhitelist:tag(lplr, "", true)
        if displayName.ClassName == "TextLabel" then
            if not displayName.RichText then displayName.RichText = true end
            displayName.Text = tag..lplr.Name
        end
        displayName:GetPropertyChangedSignal("Text"):Connect(function()
            if displayName.Text ~= tag..lplr.Name then
                displayName.Text = tag..lplr.Name
            end
        end)
    end)
end)

local GetEnumItems = function() return {} end
GetEnumItems = function(enum)
	local fonts = {}
	for i,v in next, Enum[enum]:GetEnumItems() do 
		table.insert(fonts, v.Name) 
	end
	return fonts
end

--[[run(function()
    local ClientCrasher
	local collectionService = game:GetService("CollectionService")
	local entitylib = entitylib or entityLibrary
	local signal
    ClientCrasher = vape.Categories.Blatant:CreateModule({
        Name = "Client Crasher",
        Function = function(call)
            if call then
                signal = collectionService:GetInstanceAddedSignal('inventory-entity'):Connect(function(player)
                    local item = player:WaitForChild('HandInvItem')
                    for i,v in getconnections(item.Changed) do
						pcall(function()
                        	v:Disable()
						end)
                    end                
                end)

                repeat
                    if entitylib.isAlive then
                        for _, tool in store.inventory.inventory.items do
							task.spawn(switchItem, tool.tool)
						end
                    end
                    task.wait()
                until not ClientCrasher.Enabled
            else
				if signal then
					pcall(function() signal:Disconnect() end)
					signal = nil
				end
			end
        end
    })
end)--]]

--[[run(function()
	local ChosenPack = {Value = "Realistic Pack"}
	local TexturePacks = {Enabled = false}
	TexturePacks = vape.Categories.Utility:CreateModule({
		Name = "Texture Packs",
		Tooltip = "Replaces the boring sword with a better texture pack.",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					repeat task.wait() until store.matchState ~= 0
					local function killPlayer(player)
						local character = player.Character
						if character then
							local humanoid = character:FindFirstChildOfClass("Humanoid")
							if humanoid then
								humanoid.Health = 0
							end
						end
					end
					local canRespawn = function() end
					canRespawn = function()
						local success, response = pcall(function() 
							return lplr.leaderstats.Bed.Value == '✅' 
						end)
						return success and response 
					end
					warningNotification("Texture packs", "Reset for the pack to work", 3)
					--if canRespawn() then warningNotification("Texture packs", "Resetting for the texture to get applied", 5) killPlayer(lplr) else warningNotification("Texture packs", "Unable to reset your chatacter! Please do it manually", 3) end
					TexturePacks.Enabled = false 
					TexturePacks.Enabled = true 
					if ChosenPack.Value == "Realistic Pack" then
						local Services = {
							Storage = game:GetService("ReplicatedStorage"),
							Workspace = game:GetService("Workspace"),
							Players = game:GetService("Players")
						}
						
						local ASSET_ID = "rbxassetid://14431940695"
						local PRIMARY_ROTATION = CFrame.Angles(0, -math.pi/4, 0)
						
						local ToolMaterials = {
							sword = {"wood", "stone", "iron", "diamond", "emerald"},
							pickaxe = {"wood", "stone", "iron", "diamond"},
							axe = {"wood", "stone", "iron", "diamond"}
						}
						
						local Offsets = {
							sword = CFrame.Angles(0, -math.pi/2, -math.pi/2),
							pickaxe = CFrame.Angles(0, -math.pi, -math.pi/2),
							axe = CFrame.Angles(0, -math.pi/18, -math.pi/2)
						}
						
						local ToolIndex = {}
						
						local function initializeToolIndex(asset)
							for toolType, materials in pairs(ToolMaterials) do
								for _, material in ipairs(materials) do
									local identifier = material .. "_" .. toolType
									local toolModel = asset:FindFirstChild(identifier)
						
									if toolModel then
										--print("Found tool in initializeToolIndex:", identifier)
										table.insert(ToolIndex, {
											Name = identifier,
											Offset = Offsets[toolType],
											Model = toolModel
										})
									else
										--warn("Model for " .. identifier .. " not found in initializeToolIndex!")
									end
								end
							end
						end
						
						local function adjustAppearance(part)
							if part:IsA("BasePart") then
								part.Transparency = 1
							end
						end
						
						local function attachModel(target, data, modifier)
							local clonedModel = data.Model:Clone()
							clonedModel.CFrame = target:FindFirstChild("Handle").CFrame * data.Offset * PRIMARY_ROTATION * (modifier or CFrame.new())
							clonedModel.Parent = target
						
							local weld = Instance.new("WeldConstraint", clonedModel)
							weld.Part0 = clonedModel
							weld.Part1 = target:FindFirstChild("Handle")
						end
						
						local function processTool(tool)
							if not tool:IsA("Accessory") then return end
						
							for _, toolData in ipairs(ToolIndex) do
								if toolData.Name == tool.Name then
									for _, child in pairs(tool:GetDescendants()) do
										adjustAppearance(child)
									end
									attachModel(tool, toolData)
						
									local playerTool = Services.Players.LocalPlayer.Character:FindFirstChild(tool.Name)
									if playerTool then
										for _, child in pairs(playerTool:GetDescendants()) do
											adjustAppearance(child)
										end
										attachModel(playerTool, toolData, CFrame.new(0.4, 0, -0.9))
									end
								end
		end
	end
	
						
						local loadedTools = game:GetObjects(ASSET_ID)
						local mainAsset = loadedTools[1]
						mainAsset.Parent = Services.Storage
						
						wait(1)
						
						
						for _, child in pairs(mainAsset:GetChildren()) do
							--print("Found tool in asset:", child.Name)
						end
						
						initializeToolIndex(mainAsset)
						Services.Workspace:WaitForChild("Camera").Viewmodel.ChildAdded:Connect(processTool)
					elseif ChosenPack.Value == "32x Pack" then 
						local Services = {
							Storage = game:GetService("ReplicatedStorage"),
							Workspace = game:GetService("Workspace"),
							Players = game:GetService("Players")
						}
						
						local ASSET_ID = "rbxassetid://14421314747"
						local PRIMARY_ROTATION = CFrame.Angles(0, -math.pi/4, 0)
						
						local ToolMaterials = {
							sword = {"wood", "stone", "iron", "diamond", "emerald"},
							pickaxe = {"wood", "stone", "iron", "diamond"},
							axe = {"wood", "stone", "iron", "diamond"}
						}
						
						local Offsets = {
							sword = CFrame.Angles(0, -math.pi/2, -math.pi/2),
							pickaxe = CFrame.Angles(0, -math.pi, -math.pi/2),
							axe = CFrame.Angles(0, -math.pi/18, -math.pi/2)
						}
						
						local ToolIndex = {}
						
						local function initializeToolIndex(asset)
							for toolType, materials in pairs(ToolMaterials) do
								for _, material in ipairs(materials) do
									local identifier = material .. "_" .. toolType
									local toolModel = asset:FindFirstChild(identifier)
						
									if toolModel then
										--print("Found tool in initializeToolIndex:", identifier)
										table.insert(ToolIndex, {
											Name = identifier,
											Offset = Offsets[toolType],
											Model = toolModel
										})
									else
										--warn("Model for " .. identifier .. " not found in initializeToolIndex!")
		end
	end
		end
	end
	
						local function adjustAppearance(part)
							if part:IsA("BasePart") then
								part.Transparency = 1
							end
						end
						
						local function attachModel(target, data, modifier)
							local clonedModel = data.Model:Clone()
							clonedModel.CFrame = target:FindFirstChild("Handle").CFrame * data.Offset * PRIMARY_ROTATION * (modifier or CFrame.new())
							clonedModel.Parent = target
						
							local weld = Instance.new("WeldConstraint", clonedModel)
							weld.Part0 = clonedModel
							weld.Part1 = target:FindFirstChild("Handle")
						end
						
						local function processTool(tool)
							if not tool:IsA("Accessory") then return end
						
							for _, toolData in ipairs(ToolIndex) do
								if toolData.Name == tool.Name then
									for _, child in pairs(tool:GetDescendants()) do
										adjustAppearance(child)
									end
									attachModel(tool, toolData)
						
									local playerTool = Services.Players.LocalPlayer.Character:FindFirstChild(tool.Name)
									if playerTool then
										for _, child in pairs(playerTool:GetDescendants()) do
											adjustAppearance(child)
										end
										attachModel(playerTool, toolData, CFrame.new(0.4, 0, -0.9))
									end
								end
							end
						end
						
						
						local loadedTools = game:GetObjects(ASSET_ID)
						local mainAsset = loadedTools[1]
						mainAsset.Parent = Services.Storage
						
						wait(1)
						
						
						for _, child in pairs(mainAsset:GetChildren()) do
							--print("Found tool in asset:", child.Name)
						end
						
						initializeToolIndex(mainAsset)
						Services.Workspace:WaitForChild("Camera").Viewmodel.ChildAdded:Connect(processTool)
					elseif ChosenPack.Value == "16x Pack" then 
						local Services = {
							Storage = game:GetService("ReplicatedStorage"),
							Workspace = game:GetService("Workspace"),
							Players = game:GetService("Players")
						}
						
						local ASSET_ID = "rbxassetid://14474879594"
						local PRIMARY_ROTATION = CFrame.Angles(0, -math.pi/4, 0)
						
						local ToolMaterials = {
							sword = {"wood", "stone", "iron", "diamond", "emerald"},
							pickaxe = {"wood", "stone", "iron", "diamond"},
							axe = {"wood", "stone", "iron", "diamond"}
						}
						
						local Offsets = {
							sword = CFrame.Angles(0, -math.pi/2, -math.pi/2),
							pickaxe = CFrame.Angles(0, -math.pi, -math.pi/2),
							axe = CFrame.Angles(0, -math.pi/18, -math.pi/2)
						}
						
						local ToolIndex = {}
						
						local function initializeToolIndex(asset)
							for toolType, materials in pairs(ToolMaterials) do
								for _, material in ipairs(materials) do
									local identifier = material .. "_" .. toolType
									local toolModel = asset:FindFirstChild(identifier)
						
									if toolModel then
										--print("Found tool in initializeToolIndex:", identifier)
										table.insert(ToolIndex, {
											Name = identifier,
											Offset = Offsets[toolType],
											Model = toolModel
										})
									else
										--warn("Model for " .. identifier .. " not found in initializeToolIndex!")
									end
								end
							end
						end
						
						local function adjustAppearance(part)
							if part:IsA("BasePart") then
								part.Transparency = 1
							end
						end
						
						local function attachModel(target, data, modifier)
							local clonedModel = data.Model:Clone()
							clonedModel.CFrame = target:FindFirstChild("Handle").CFrame * data.Offset * PRIMARY_ROTATION * (modifier or CFrame.new())
							clonedModel.Parent = target
						
							local weld = Instance.new("WeldConstraint", clonedModel)
							weld.Part0 = clonedModel
							weld.Part1 = target:FindFirstChild("Handle")
						end
						
						local function processTool(tool)
							if not tool:IsA("Accessory") then return end
						
							for _, toolData in ipairs(ToolIndex) do
								if toolData.Name == tool.Name then
									for _, child in pairs(tool:GetDescendants()) do
										adjustAppearance(child)
									end
									attachModel(tool, toolData)
						
									local playerTool = Services.Players.LocalPlayer.Character:FindFirstChild(tool.Name)
									if playerTool then
										for _, child in pairs(playerTool:GetDescendants()) do
											adjustAppearance(child)
										end
										attachModel(playerTool, toolData, CFrame.new(0.4, 0, -0.9))
									end
								end
							end
						end
						
						
						local loadedTools = game:GetObjects(ASSET_ID)
						local mainAsset = loadedTools[1]
						mainAsset.Parent = Services.Storage
						
						wait(1)
						
						
						for _, child in pairs(mainAsset:GetChildren()) do
							--print("Found tool in asset:", child.Name)
						end
						
						initializeToolIndex(mainAsset)
						Services.Workspace:WaitForChild("Camera").Viewmodel.ChildAdded:Connect(processTool)
					elseif ChosenPack.Value == "Garbage" then 
						local Services = {
							Storage = game:GetService("ReplicatedStorage"),
							Workspace = game:GetService("Workspace"),
							Players = game:GetService("Players")
						}
						
						local ASSET_ID = "rbxassetid://14336548540"
						local PRIMARY_ROTATION = CFrame.Angles(0, -math.pi/4, 0)
						
						local ToolMaterials = {
							sword = {"wood", "stone", "iron", "diamond", "emerald"},
							pickaxe = {"wood", "stone", "iron", "diamond"},
							axe = {"wood", "stone", "iron", "diamond"}
						}
						
						local Offsets = {
							sword = CFrame.Angles(0, -math.pi/2, -math.pi/2),
							pickaxe = CFrame.Angles(0, -math.pi, -math.pi/2),
							axe = CFrame.Angles(0, -math.pi/18, -math.pi/2)
						}
						
						local ToolIndex = {}
						
						local function initializeToolIndex(asset)
							for toolType, materials in pairs(ToolMaterials) do
								for _, material in ipairs(materials) do
									local identifier = material .. "_" .. toolType
									local toolModel = asset:FindFirstChild(identifier)
						
									if toolModel then
										--print("Found tool in initializeToolIndex:", identifier)
										table.insert(ToolIndex, {
											Name = identifier,
											Offset = Offsets[toolType],
											Model = toolModel
										})
									else
										--warn("Model for " .. identifier .. " not found in initializeToolIndex!")
									end
								end
							end
						end
						
						local function adjustAppearance(part)
							if part:IsA("BasePart") then
								part.Transparency = 1
							end
						end
						
						local function attachModel(target, data, modifier)
							local clonedModel = data.Model:Clone()
							clonedModel.CFrame = target:FindFirstChild("Handle").CFrame * data.Offset * PRIMARY_ROTATION * (modifier or CFrame.new())
							clonedModel.Parent = target
						
							local weld = Instance.new("WeldConstraint", clonedModel)
							weld.Part0 = clonedModel
							weld.Part1 = target:FindFirstChild("Handle")
						end
						
						local function processTool(tool)
							if not tool:IsA("Accessory") then return end
						
							for _, toolData in ipairs(ToolIndex) do
								if toolData.Name == tool.Name then
									for _, child in pairs(tool:GetDescendants()) do
										adjustAppearance(child)
									end
									attachModel(tool, toolData)
						
									local playerTool = Services.Players.LocalPlayer.Character:FindFirstChild(tool.Name)
									if playerTool then
										for _, child in pairs(playerTool:GetDescendants()) do
											adjustAppearance(child)
										end
										attachModel(playerTool, toolData, CFrame.new(0.4, 0, -0.9))
									end
								end
							end
						end
						
						
						local loadedTools = game:GetObjects(ASSET_ID)
						local mainAsset = loadedTools[1]
						mainAsset.Parent = Services.Storage
						
						wait(1)
						
						
						for _, child in pairs(mainAsset:GetChildren()) do
							--print("Found tool in asset:", child.Name)
						end
						
						initializeToolIndex(mainAsset)
						Services.Workspace:WaitForChild("Camera").Viewmodel.ChildAdded:Connect(processTool)
					end
				end)
			end
		end
	})
	ChosenPack = TexturePacks:CreateDropdown({
        Name = "Pack",
        List = {
            "Realistic Pack",
            "32x Pack",
            "16x Pack",
            "Garbage",
        },
        Function = function() end,
    })
end)--]]

run(function()
	local PlayerLevelSet = {Enabled = false}
	local PlayerLevel = {Value = 100}
	PlayerLevelSet = vape.Categories.Misc:CreateModule({
		Name = 'SetPlayerLevel',
		Tooltip = 'Sets your player level to 100 (client sided)',
		Function = function(calling)
			if calling then 
				warningNotification("SetPlayerLevel", "This is client sided (only u will see the new level)", 3)
				game.Players.LocalPlayer:SetAttribute("PlayerLevel", PlayerLevel.Value)
			end
		end
	})
	PlayerLevel = PlayerLevelSet:CreateSlider({
		Name = 'Sets your desired player level',
		Function = function() if PlayerLevelSet.Enabled then game.Players.LocalPlayer:SetAttribute("PlayerLevel", PlayerLevel.Value) end end,
		Min = 1,
		Max = 100,
		Default = 100
	})
end)

run(function()
    local QueueDisplayConfig = {
        ActiveState = false,
        GradientControl = {Enabled = true},
        ColorSettings = {
            Gradient1 = {Hue = 0, Saturation = 0, Brightness = 1},
            Gradient2 = {Hue = 0, Saturation = 0, Brightness = 0.8}
        },
        Animation = {Speed = 0.5, Progress = 0}
    }

    local DisplayUtils = {
        createGradient = function(parent)
            local gradient = parent:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient")
            gradient.Parent = parent
            return gradient
        end,
        updateColor = function(gradient, config)
            local time = tick() * config.Animation.Speed
            local interp = (math.sin(time) + 1) / 2
            local h = config.ColorSettings.Gradient1.Hue + (config.ColorSettings.Gradient2.Hue - config.ColorSettings.Gradient1.Hue) * interp
            local s = config.ColorSettings.Gradient1.Saturation + (config.ColorSettings.Gradient2.Saturation - config.ColorSettings.Gradient1.Saturation) * interp
            local b = config.ColorSettings.Gradient1.Brightness + (config.ColorSettings.Gradient2.Brightness - config.ColorSettings.Gradient1.Brightness) * interp
            gradient.Color = ColorSequence.new(Color3.fromHSV(h, s, b))
        end
    }

	local CoreConnection

    local function enhanceQueueDisplay()
		pcall(function() 
			CoreConnection:Disconnect()
		end)
        local success, err = pcall(function()
            if not lplr.PlayerGui:FindFirstChild('QueueApp') then return end
            
            for attempt = 1, 3 do
                if QueueDisplayConfig.GradientControl.Enabled then
                    local queueFrame = lplr.PlayerGui.QueueApp['1']
                    queueFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    
                    local gradient = DisplayUtils.createGradient(queueFrame)
                    gradient.Rotation = 180
                    
                    local displayInterface = {
                        module = vape.watermark,
                        gradient = gradient,
                        GetEnabled = function()
                            return QueueDisplayConfig.ActiveState
                        end,
                        SetGradientEnabled = function(state)
                            QueueDisplayConfig.GradientControl.Enabled = state
                            gradient.Enabled = state
                        end
                    }
                    --vape.whitelistedlines["enhancedQueueDisplay"] = displayInterface
                    CoreConnection = game:GetService("RunService").RenderStepped:Connect(function()
                        if QueueDisplayConfig.ActiveState and QueueDisplayConfig.GradientControl.Enabled then
                            DisplayUtils.updateColor(gradient, QueueDisplayConfig)
                        end
                    end)
                end
                task.wait(0.1)
            end
        end)
        
        if not success then
            warn("Queue display enhancement failed: " .. tostring(err))
        end
    end

    local QueueDisplayEnhancer
    QueueDisplayEnhancer = vape.Categories.Utility:CreateModule({
        Name = 'QueueCardMods',
        Tooltip = 'Enhances the QueueApp display with dynamic gradients',
        Function = function(enabled)
            QueueDisplayConfig.ActiveState = enabled
            if enabled then
                enhanceQueueDisplay()
                QueueDisplayEnhancer:Clean(lplr.PlayerGui.ChildAdded:Connect(enhanceQueueDisplay))
			else
				pcall(function() 
					CoreConnection:Disconnect()
				end)
			end
        end
    })

   	QueueDisplayEnhancer:CreateSlider({
        Name = "Animation Speed",
        Function = function(speed)
            QueueDisplayConfig.Animation.Speed = math.clamp(speed, 0.1, 5)
        end,
        Min = 1,
        Max = 5,
        Default = 5
    })

    QueueDisplayEnhancer:CreateColorSlider({
        Name = "Color 1",
        Function = function(h, s, v)
            QueueDisplayConfig.ColorSettings.Gradient1 = {Hue = h, Saturation = s, Brightness = v}
        end
    })

    QueueDisplayEnhancer:CreateColorSlider({
        Name = "Color 2",
        Function = function(h, s, v)
            QueueDisplayConfig.ColorSettings.Gradient2 = {Hue = h, Saturation = s, Brightness = v}
        end
    })
end)

--[[run(function()
	task.spawn(function()
		pcall(function()
			GuiLibrary.RemoveObject("SetEmote")
			local SetEmote = {}
			local SetEmoteList = {Value = ''}
			local oldemote
			local emo2 = {}
			local credits
			SetEmote = vape.Categories.Utility:CreateModule({
				Name = 'SetEmote',
				Tooltip = "Sets your emote",
				Function = function(calling)
					if calling then
						oldemote = lplr:GetAttribute('EmoteTypeSlot1')
						lplr:SetAttribute('EmoteTypeSlot1', emo2[SetEmoteList.Value])
					else
						if oldemote then 
							lplr:GetAttribute('EmoteTypeSlot1', oldemote)
							oldemote = nil 
						end
					end
					SetEmote:Clean(lplr.PlayerGui.ChildAdded:Connect(function(v)
						local anim
						if tostring(v) == 'RoactTree' and isAlive(lplr, true) and not emoting then 
							v:WaitForChild('1'):WaitForChild('1')
							if not v['1']:IsA('ImageButton') then 
								return 
							end
							v['1'].Visible = false
							emoting = true
							bedwars.Client:Get('Emote'):CallServer({emoteType = lplr:GetAttribute('EmoteTypeSlot1')})
							local oldpos = lplr.Character:WaitForChild("HumanoidRootPart").Position 
							if tostring(lplr:GetAttribute('EmoteTypeSlot1')):lower():find('nightmare') then 
								anim = Instance.new('Animation')
								anim.AnimationId = 'rbxassetid://9191822700'
								anim = lplr.Character:WaitForChild("Humanoid").Animator:LoadAnimation(anim)
								task.spawn(function()
									repeat 
										anim:Play()
										anim.Completed:Wait()
									until not anim
								end)
							end
							repeat task.wait() until ((lplr.Character:WaitForChild("HumanoidRootPart").Position - oldpos).Magnitude >= 0.3 or not isAlive(lplr, true))
							pcall(function() anim:Stop() end)
							anim = nil
							emoting = false
							bedwars.Client:Get('EmoteCancelled'):CallServer({emoteType = lplr:GetAttribute('EmoteTypeSlot1')})
						end
					end))
				end
			})
			local emo = {}
			for i,v in pairs(bedwars.EmoteMeta) do 
				table.insert(emo, v.name)
				emo2[v.name] = i
			end
			table.sort(emo, function(a, b) return a:lower() < b:lower() end)
			SetEmoteList = SetEmote:CreateDropdown({
				Name = 'Emote',
				List = emo,
				Function = function(emote)
					if SetEmote.Enabled then 
						lplr:SetAttribute('EmoteTypeSlot1', emo2[emote])
					end
				end
			})
		end)
	end)
end)--]]

--[[if shared.TestingMode then
	pcall(function()
		run(function()
			local SessionInfo = {Enabled = false}
			local BackgroundColor = {Hue = 0, Sat = 0, Value = 0}
			local lplr = game:GetService("Players").LocalPlayer
			local plrgui = lplr.PlayerGui
			local deathCount = 0
			local regionDisplayText = plrgui:WaitForChild("ServerRegionDisplay").ServerRegionText.Text
			local playerDead = false 
			local debounce = false
		
			SessionInfo = vape.Categories.Utility:CreateModule({
				Name = "SessionInfo Custom",
				Tooltip = "Customizable session info.",
				Function = function(call)
					if call then 
						local function extractValue(text, pattern)
							return text:match(pattern)
						end

						local components = {
							Gui = Instance.new("ScreenGui"),
							Background = Instance.new("Frame"),
							UICorner = Instance.new("UICorner"),
							SessionInfoLabel = Instance.new("TextLabel"),
							TimePlayed = Instance.new("TextLabel"),
							Kills = Instance.new("TextLabel"),
							Deaths = Instance.new("TextLabel"),
							Region = Instance.new("TextLabel"),
							DropShadowHolder = Instance.new("Frame"),
							DropShadow = Instance.new("ImageLabel")
						}
						
						local function setupLabel(label, text, positionY)
							label.Font = Enum.Font.SourceSans
							label.Text = text
							label.TextColor3 = Color3.fromRGB(255, 255, 255)
							label.TextScaled = true
							label.TextWrapped = true
							label.TextXAlignment = Enum.TextXAlignment.Left
							label.BackgroundTransparency = 1
							label.Position = UDim2.new(0.04, 0, positionY, 0)
							label.Size = UDim2.new(1, 0, 0.17, 0)
							label.Parent = components.Background
						end
		
						components.Gui.Name = "SessionInfo"
						components.Gui.Parent = plrgui
						components.Gui.ResetOnSpawn = false
		
						components.Background.Name = "Background"
						components.Background.Parent = components.Gui
						components.Background.BackgroundColor3 = Color3.fromHSV(0, 0, 0)
						components.Background.BackgroundTransparency = 0.8
						components.Background.Size = UDim2.new(0.13, 0, 0.16, 0)
						components.Background.Position = UDim2.new(0.01, 0, 0.38, 0)
						components.UICorner.Parent = components.Background
		
						setupLabel(components.SessionInfoLabel, "Session Info", 0)
						setupLabel(components.TimePlayed, "Time Played: 00:00", 0.28)
						setupLabel(components.Kills, "Kills: 0", 0.45)
						setupLabel(components.Deaths, "Deaths: 0", 0.62)
						setupLabel(components.Region, "Region: " .. extractValue(regionDisplayText, "REGION:%s*([^<]+)"), 0.79)
		
						components.DropShadowHolder.Parent = components.Background
						components.DropShadowHolder.BackgroundTransparency = 1
						components.DropShadowHolder.Size = UDim2.new(1, 0, 1, 0)
						components.DropShadow.Name = "DropShadow"
						components.DropShadow.Parent = components.DropShadowHolder
						components.DropShadow.Image = "rbxassetid://6014261993"
						components.DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
						components.DropShadow.ImageTransparency = 0.5
						components.DropShadow.ScaleType = Enum.ScaleType.Slice
						components.DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
						components.DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
						components.DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
						components.DropShadow.Size = UDim2.new(1, 47, 1, 47)
		
						local function updateTimer()
							while enabled do
								wait()
								local timerText = plrgui.TopBarAppGui.TopBarApp["2"]["5"].Text
								components.TimePlayed.Text = "Time Played: " .. extractValue(timerText, "<b>(%d+:%d+)</b>")
							end
						end
		
						local function updateKills()
							while enabled do
								wait()
								local killsText = plrgui.TopBarAppGui.TopBarApp["3"]["5"].Text
								components.Kills.Text = "Kills: " .. extractValue(killsText, "<b>(%d+)</b>")
							end
						end
		
						local function trackDeaths()
							lplr.Character:WaitForChild("Humanoid").HealthChanged:Connect(function(health)
								if debounce then return end
								debounce = true
								if health <= 0 and not playerDead then
									deathCount += 1
									components.Deaths.Text = "Deaths: " .. deathCount
									playerDead = true
								elseif health > 0 then
									playerDead = false
								end
								debounce = false
							end)
						end
						
						task.spawn(updateTimer)
						task.spawn(updateKills)
						task.spawn(trackDeaths)
						
					else
						if plrgui:FindFirstChild("SessionInfo") then 
							plrgui.SessionInfo:Destroy()
						else 
							errorNotification("SessionInfo", "Session Info not found, please DM erchodev#0 about this.", 3)
						end
					end
				end
			})
		
			BackgroundColor = SessionInfo:CreateColorSlider({
				Name = "Background Color",
				Function = function(h, s, v) 
					local sessionInfo = game.Players.LocalPlayer.PlayerGui:FindFirstChild("SessionInfo")
					if sessionInfo then 
						sessionInfo.Background.BackgroundColor3 = Color3.fromHSV(h, s, v)
					else
						print("No SessionInfo found.")
					end
				end
			})
		end)		
	end)
else
	run(function()
		local lplr = game.Players.LocalPlayer
		local plrgui = lplr.PlayerGui
		local deathscounter = 0
		local regiondisplay = plrgui:WaitForChild("ServerRegionDisplay").ServerRegionText.Text
		local playerded = false 
		local debouncegaming = false
		local SessionInfo = vape.Categories.Utility:CreateModule({
			Name = "SessionInfo Custom",
			Tooltip = "Customizable session info.",
			Function = function(callback)
				if callback then 
					local function extractnumber(text)
						local number = text:match("<b>(%d+)</b>")
						return tonumber(number)
					end
					local function extracttimer(text)
						local minutes, seconds = text:match("<b>(%d+:%d+)</b>")
						return minutes
					end
					local function extractregion(text)
						local region = text:match("REGION:%s*([^<]+)")
						return region
					end
					
					local Converted = {
						["_SessionInfo"] = Instance.new("ScreenGui");
						["_Background"] = Instance.new("Frame");
						["_UICorner"] = Instance.new("UICorner");
						["_SessionInfoLabel"] = Instance.new("TextLabel");
						["_TimePlayed"] = Instance.new("TextLabel");
						["_Kills"] = Instance.new("TextLabel");
						["_Deaths"] = Instance.new("TextLabel");
						["_Region"] = Instance.new("TextLabel");
						["_DropShadowHolder"] = Instance.new("Frame");
						["_DropShadow"] = Instance.new("ImageLabel");
					}
					
					Converted["_SessionInfo"].ZIndexBehavior = Enum.ZIndexBehavior.Sibling
					Converted["_SessionInfo"].Name = "SessionInfo"
					Converted["_SessionInfo"].Parent = plrgui
					Converted["_SessionInfo"].ResetOnSpawn = false
					
					Converted["_Background"].BackgroundColor3 = Color3.fromHSV(0, 0, 0)
					Converted["_Background"].BackgroundTransparency = 0.800000011920929
					Converted["_Background"].BorderColor3 = Color3.fromRGB(0, 0, 0)
					Converted["_Background"].BorderSizePixel = 0
					Converted["_Background"].Position = UDim2.new(0.0116598075, 0, 0.375, 0)
					Converted["_Background"].Size = UDim2.new(0.128257886, 0, 0.16310975, 0)
					Converted["_Background"].Name = "Background"
					Converted["_Background"].Parent = Converted["_SessionInfo"]
					
					Converted["_UICorner"].Parent = Converted["_Background"]
					
					Converted["_SessionInfoLabel"].Font = Enum.Font.SourceSansBold
					Converted["_SessionInfoLabel"].Text = "Session Info"
					Converted["_SessionInfoLabel"].TextColor3 = Color3.fromRGB(255, 255, 255)
					Converted["_SessionInfoLabel"].TextScaled = true
					Converted["_SessionInfoLabel"].TextSize = 14
					Converted["_SessionInfoLabel"].TextWrapped = true
					Converted["_SessionInfoLabel"].TextXAlignment = Enum.TextXAlignment.Left
					Converted["_SessionInfoLabel"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					Converted["_SessionInfoLabel"].BackgroundTransparency = 1
					Converted["_SessionInfoLabel"].BorderColor3 = Color3.fromRGB(0, 0, 0)
					Converted["_SessionInfoLabel"].BorderSizePixel = 0
					Converted["_SessionInfoLabel"].Position = UDim2.new(0.0374331549, 0, 0, 0)
					Converted["_SessionInfoLabel"].Size = UDim2.new(1, 0, 0.242990658, 0)
					Converted["_SessionInfoLabel"].Name = "SessionInfoLabel"
					Converted["_SessionInfoLabel"].Parent = Converted["_Background"]
					
					Converted["_TimePlayed"].Font = Enum.Font.SourceSans
					Converted["_TimePlayed"].Text = "Time Played: 00:00" 
					Converted["_TimePlayed"].TextColor3 = Color3.fromRGB(255, 255, 255)
					Converted["_TimePlayed"].TextScaled = true
					Converted["_TimePlayed"].TextSize = 14
					Converted["_TimePlayed"].TextWrapped = true
					Converted["_TimePlayed"].TextXAlignment = Enum.TextXAlignment.Left
					Converted["_TimePlayed"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					Converted["_TimePlayed"].BackgroundTransparency = 1
					Converted["_TimePlayed"].BorderColor3 = Color3.fromRGB(0, 0, 0)
					Converted["_TimePlayed"].BorderSizePixel = 0
					Converted["_TimePlayed"].Position = UDim2.new(0.0374331549, 0, 0.275288522, 0)
					Converted["_TimePlayed"].Size = UDim2.new(1, 0, 0.168224305, 0)
					Converted["_TimePlayed"].Name = "TimePlayed"
					Converted["_TimePlayed"].Parent = Converted["_Background"]
					
					Converted["_Kills"].Font = Enum.Font.SourceSans
					Converted["_Kills"].Text = "Kills: 0" 
					Converted["_Kills"].TextColor3 = Color3.fromRGB(255, 255, 255)
					Converted["_Kills"].TextScaled = true
					Converted["_Kills"].TextSize = 14
					Converted["_Kills"].TextWrapped = true
					Converted["_Kills"].TextXAlignment = Enum.TextXAlignment.Left
					Converted["_Kills"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					Converted["_Kills"].BackgroundTransparency = 1
					Converted["_Kills"].BorderColor3 = Color3.fromRGB(0, 0, 0)
					Converted["_Kills"].BorderSizePixel = 0
					Converted["_Kills"].Position = UDim2.new(0.0374331549, 0, 0.445024729, 0)
					Converted["_Kills"].Size = UDim2.new(1, 0, 0.168224305, 0)
					Converted["_Kills"].Name = "Kills"
					Converted["_Kills"].Parent = Converted["_Background"]
					
					Converted["_Deaths"].Font = Enum.Font.SourceSans
					Converted["_Deaths"].Text = "Deaths: 0"
					Converted["_Deaths"].TextColor3 = Color3.fromRGB(255, 255, 255)
					Converted["_Deaths"].TextScaled = true
					Converted["_Deaths"].TextSize = 14
					Converted["_Deaths"].TextWrapped = true
					Converted["_Deaths"].TextXAlignment = Enum.TextXAlignment.Left
					Converted["_Deaths"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					Converted["_Deaths"].BackgroundTransparency = 1
					Converted["_Deaths"].BorderColor3 = Color3.fromRGB(0, 0, 0)
					Converted["_Deaths"].BorderSizePixel = 0
					Converted["_Deaths"].Position = UDim2.new(0.0374331549, 0, 0.614760935, 0)
					Converted["_Deaths"].Size = UDim2.new(1, 0, 0.168224305, 0)
					Converted["_Deaths"].Name = "Deaths"
					Converted["_Deaths"].Parent = Converted["_Background"]
					
					Converted["_Region"].Font = Enum.Font.SourceSans
					Converted["_Region"].Text = "Region: "..extractregion(regiondisplay)
					Converted["_Region"].TextColor3 = Color3.fromRGB(255, 255, 255)
					Converted["_Region"].TextScaled = true
					Converted["_Region"].TextSize = 14
					Converted["_Region"].TextWrapped = true
					Converted["_Region"].TextXAlignment = Enum.TextXAlignment.Left
					Converted["_Region"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					Converted["_Region"].BackgroundTransparency = 1
					Converted["_Region"].BorderColor3 = Color3.fromRGB(0, 0, 0)
					Converted["_Region"].BorderSizePixel = 0
					Converted["_Region"].Position = UDim2.new(0.0374331549, 0, 0.78298521, 0)
					Converted["_Region"].Size = UDim2.new(1, 0, 0.168224305, 0)
					Converted["_Region"].Name = "Region"
					Converted["_Region"].Parent = Converted["_Background"]
					
					Converted["_DropShadowHolder"].BackgroundTransparency = 1
					Converted["_DropShadowHolder"].BorderSizePixel = 0
					Converted["_DropShadowHolder"].Size = UDim2.new(1, 0, 1, 0)
					Converted["_DropShadowHolder"].ZIndex = 0
					Converted["_DropShadowHolder"].Name = "DropShadowHolder"
					Converted["_DropShadowHolder"].Parent = Converted["_Background"]
					
					Converted["_DropShadow"].Image = "rbxassetid://6014261993"
					Converted["_DropShadow"].ImageColor3 = Color3.fromRGB(0, 0, 0)
					Converted["_DropShadow"].ImageTransparency = 0.5
					Converted["_DropShadow"].ScaleType = Enum.ScaleType.Slice
					Converted["_DropShadow"].SliceCenter = Rect.new(49, 49, 450, 450)
					Converted["_DropShadow"].AnchorPoint = Vector2.new(0.5, 0.5)
					Converted["_DropShadow"].BackgroundTransparency = 1
					Converted["_DropShadow"].BorderSizePixel = 0
					Converted["_DropShadow"].Position = UDim2.new(0.5, 0, 0.5, 0)
					Converted["_DropShadow"].Size = UDim2.new(1, 47, 1, 47)
					Converted["_DropShadow"].ZIndex = 0
					Converted["_DropShadow"].Name = "DropShadow"
					Converted["_DropShadow"].Parent = Converted["_DropShadowHolder"]
					
					local function timerupdate()
						while true do
							wait()
							local timercounter = plrgui.TopBarAppGui.TopBarApp["2"]["5"].Text
							local timergaming = extracttimer(timercounter)
							Converted["_TimePlayed"].Text = "Time Played: " .. timergaming
						end
					end
					
					local function killsupdate()
						while true do
							wait()
							local killscounter = plrgui.TopBarAppGui.TopBarApp["3"]["5"].Text
							local kills = extractnumber(killscounter)
							Converted["_Kills"].Text = "Kills: " .. kills
						end
					end
					
					local function deathcounterfunc()
						local humanoid = lplr.Character:WaitForChild("Humanoid")
						humanoid.HealthChanged:Connect(function(health)
							if not debouncegaming then
								debouncegaming = true
								if health <= 0 and not playerded then
									deathscounter = deathscounter + 1
									Converted["_Deaths"].Text = "Deaths: " .. deathscounter
									playerded = true
									debouncegaming = false
									wait(1) 
								elseif health > 0 and playerded then
									playerded = false
								end
							end
						end)
					end
					
					task.spawn(timerupdate)
					task.spawn(killsupdate)
					task.spawn(deathcounterfunc)	
				else 
					local plrgui = game.Players.LocalPlayer.PlayerGui
					if plrgui:FindFirstChild("SessionInfo") then 
						local sessioninfo = plrgui.SessionInfo
						sessioninfo:Destroy()
					else 
						ErrorWarning("SessionInfo", "Session Info not found, please dm salad about this.", 30)
					end
				end
			end
		})
		SessioninfoBgColor = SessionInfo:CreateColorSlider({
			Name = "Background Color",
			Function = function(h, s, v) 
				if game.Players.LocalPlayer.PlayerGui:FindFirstChild("SessionInfo") then 
					game.Players.LocalPlayer.PlayerGui.SessionInfo.Background.BackgroundColor3 = Color3.fromHSV(h, s, v)
				else
					print("no session info found lol")
				end
			end
		})
	end)
end--]]

run(function()
    local tppos2 = nil
    local TweenSpeed = 0.7
    local HeightOffset = 5
    local BedTP = {}

    local function teleportWithTween(char, destination)
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            destination = destination + Vector3.new(0, HeightOffset, 0)
            local currentPosition = root.Position
            if (destination - currentPosition).Magnitude > 0.5 then
                local tweenInfo = TweenInfo.new(TweenSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                local goal = {CFrame = CFrame.new(destination)}
                local tween = TweenService:Create(root, tweenInfo, goal)
                tween:Play()
                tween.Completed:Wait()
				BedTP:Toggle(false)
            end
        end
    end

    local function killPlayer(player)
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Health = 0
            end
        end
    end

    local function getEnemyBed(range)
        range = range or math.huge
        local bed = nil
        local player = lplr

        if not isAlive(player, true) then 
            return nil 
        end

        local localPos = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position or Vector3.zero
        local playerTeam = player:GetAttribute('Team')
        local beds = collectionService:GetTagged('bed')

        for _, v in ipairs(beds) do 
            if v:GetAttribute('PlacedByUserId') == 0 then
                local bedTeam = v:GetAttribute('id'):sub(1, 1)
                if bedTeam ~= playerTeam then 
                    local bedPosition = v.Position
                    local bedDistance = (localPos - bedPosition).Magnitude
                    if bedDistance < range then 
                        bed = v
                        range = bedDistance
                    end
                end
            end
        end

        if not bed then 
            warningNotification("BedTP", 'No enemy beds found. Total beds: '..#beds, 5)
        else
            --warningNotification("BedTP", 'Teleporting to bed at position: '..tostring(bed.Position), 3)
			warningNotification("BedTP", 'Teleporting to bed at position: '..tostring(bed.Position), 3)
        end

        return bed
    end

    BedTP = vape.Categories.Blatant:CreateModule({
        ["Name"] = "BedTP",
        ["Function"] = function(callback)
            if callback then
				task.spawn(function()
					repeat task.wait() until vape.Modules.Invisibility
					repeat task.wait() until vape.Modules.GamingChair
					if vape.Modules.Invisibility.Enabled and vape.Modules.GamingChair.Enabled then
						errorNotification("BedTP", "Please turn off the Invisibility and GamingChair module!", 3)
						BedTP:Toggle()
						return
					end
					if vape.Modules.Invisibility.Enabled then
						errorNotification("BedTP", "Please turn off the Invisibility module!", 3)
						BedTP:Toggle()
						return
					end
					if vape.Modules.GamingChair.Enabled then
						errorNotification("BedTP", "Please turn off the GamingChair module!", 3)
						BedTP:Toggle()
						return
					end
					BedTP:Clean(lplr.CharacterAdded:Connect(function(char)
						if tppos2 then 
							task.spawn(function()
								local root = char:WaitForChild("HumanoidRootPart", 9000000000)
								if root and tppos2 then 
									teleportWithTween(char, tppos2)
									tppos2 = nil
								end
							end)
						end
					end))
					local bed = getEnemyBed()
					if bed then 
						tppos2 = bed.Position
						killPlayer(lplr)
					else
						BedTP:Toggle(false)
					end
				end)
            end
        end
    })
end)

run(function()
	local TweenService = game:GetService("TweenService")
	local playersService = game:GetService("Players")
	local lplr = playersService.LocalPlayer
	
	local tppos2
	local deathtpmod = {["Enabled"] = false}
	local TweenSpeed = 0.7
	local HeightOffset = 5

	local function teleportWithTween(char, destination)
		local root = char:FindFirstChild("HumanoidRootPart")
		if root then
			destination = destination + Vector3.new(0, HeightOffset, 0)
			local currentPosition = root.Position
			if (destination - currentPosition).Magnitude > 0.5 then
				local tweenInfo = TweenInfo.new(TweenSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
				local goal = {CFrame = CFrame.new(destination)}
				local tween = TweenService:Create(root, tweenInfo, goal)
				tween:Play()
				tween.Completed:Wait()
			end
		end
	end

	local function killPlayer(player)
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.Health = 0
			end
		end
	end

	local function onCharacterAdded(char)
		if tppos2 then 
			task.spawn(function()
				local root = char:WaitForChild("HumanoidRootPart", 9000000000)
				if root and tppos2 then 
					teleportWithTween(char, tppos2)
					tppos2 = nil
				end
			end)
		end
	end

	vapeConnections[#vapeConnections + 1] = lplr.CharacterAdded:Connect(onCharacterAdded)

	local function setTeleportPosition()
		local UserInputService = game:GetService("UserInputService")
		local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

		if isMobile then
			warningNotification("DeathTP", "Please tap on the screen to set TP position.", 3)
			local connection
			connection = UserInputService.TouchTapInWorld:Connect(function(inputPosition, processedByUI)
				if not processedByUI then
					local mousepos = lplr:GetMouse().UnitRay
					local rayparams = RaycastParams.new()
					rayparams.FilterDescendantsInstances = {game.Workspace.Map, game.Workspace:FindFirstChild("SpectatorPlatform")}
					rayparams.FilterType = Enum.RaycastFilterType.Whitelist
					local ray = game.Workspace:Raycast(mousepos.Origin, mousepos.Direction * 10000, rayparams)
					if ray then 
						tppos2 = ray.Position 
						warningNotification("DeathTP", "Set TP Position. Resetting to teleport...", 3)
						killPlayer(lplr)
					end
					connection:Disconnect()
					deathtpmod["ToggleButton"](false)
				end
			end)
		else
			local mousepos = lplr:GetMouse().UnitRay
			local rayparams = RaycastParams.new()
			rayparams.FilterDescendantsInstances = {game.Workspace.Map, game.Workspace:FindFirstChild("SpectatorPlatform")}
			rayparams.FilterType = Enum.RaycastFilterType.Whitelist
			local ray = game.Workspace:Raycast(mousepos.Origin, mousepos.Direction * 10000, rayparams)
			if ray then 
				tppos2 = ray.Position 
				warningNotification("DeathTP", "Set TP Position. Resetting to teleport...", 3)
				killPlayer(lplr)
			end
			deathtpmod["ToggleButton"](false)
		end
	end

	deathtpmod = vape.Categories.Blatant:CreateModule({
		["Name"] = "DeathTP",
		["Function"] = function(calling)
			if calling then
				task.spawn(function()
					repeat task.wait() until vape.Modules.Invisibility
					repeat task.wait() until vape.Modules.GamingChair
					if vape.Modules.Invisibility.Enabled and vape.Modules.GamingChair.Enabled then
						errorNotification("DeathTP", "Please turn off the Invisibility and GamingChair module!", 3)
						deathtpmod:Toggle()
						return
					end
					if vape.Modules.Invisibility.Enabled then
						errorNotification("DeathTP", "Please turn off the Invisibility module!", 3)
						deathtpmod:Toggle()
						return
					end
					if vape.Modules.GamingChair.Enabled then
						errorNotification("DeathTP", "Please turn off the GamingChair module!", 3)
						deathtpmod:Toggle()
						return
					end
					local canRespawn = function() end
					canRespawn = function()
						local success, response = pcall(function() 
							return lplr.leaderstats.Bed.Value == '✅' 
						end)
						return success and response 
					end
					if not canRespawn() then 
						warningNotification("DeathTP", "Unable to use DeathTP without bed!", 5)
						deathtpmod:Toggle()
					else
						setTeleportPosition()
					end
				end)
			end
		end
	})
end)

local function GetTarget()
	return entitylib.EntityPosition({
		Part = 'RootPart',
		Range = 1000,
		Players = true,
		NPCs = false,
		Wallcheck = false
	})
end

run(function()
	local PlayerTP = {}
	local PlayerTPTeleport = {Value = 'Respawn'}
	local PlayerTPSort = {Value = 'Distance'}
	local PlayerTPMethod = {Value = 'Linear'}
	local PlayerTPAutoSpeed = {}
	local PlayerTPSpeed = {Value = 200}
	local PlayerTPTarget = {Value = ''}
	local playertween
	local oldmovefunc
	local bypassmethods = {
		Respawn = function() 
			if isEnabled('InfiniteFly') then 
				return 
			end
			if not canRespawn() then 
				return 
			end
			for i = 1, 30 do 
				if isAlive(lplr, true) and lplr.Character:WaitForChild("Humanoid"):GetState() ~= Enum.HumanoidStateType.Dead then
					lplr.Character:WaitForChild("Humanoid"):TakeDamage(lplr.Character:WaitForChild("Humanoid").Health)
					lplr.Character:WaitForChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
				end
			end
			lplr.CharacterAdded:Wait()
			repeat task.wait() until isAlive(lplr, true) 
			task.wait(0.1)
			local target = GetTarget(nil, PlayerTPSort.Value == 'Health', true)
			if target.RootPart == nil or not PlayerTP.Enabled then 
				return
			end
			local localposition = lplr.Character:WaitForChild("HumanoidRootPart").Position
			local tweenspeed = (PlayerTPAutoSpeed.Enabled and ((target.RootPart.Position - localposition).Magnitude / 470) + 0.001 * 2 or (PlayerTPSpeed.Value / 1000) + 0.1)
			local tweenstyle = (PlayerTPAutoSpeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[PlayerTPMethod.Value])
			playertween = tweenService:Create(lplr.Character:WaitForChild("HumanoidRootPart"), TweenInfo.new(tweenspeed, tweenstyle), {CFrame = target.RootPart.CFrame}) 
			playertween:Play() 
			playertween.Completed:Wait()
		end,
		Instant = function() 
			local target = GetTarget(nil, PlayerTPSort.Value == 'Health', true)
			if target.RootPart == nil then 
				return PlayerTP:Toggle()
			end
			lplr.Character:WaitForChild("HumanoidRootPart").CFrame = (target.RootPart.CFrame + Vector3.new(0, 5, 0)) 
			PlayerTP:Toggle()
		end,
		Recall = function()
			if not isAlive(lplr, true) or lplr.Character:WaitForChild("Humanoid").FloorMaterial == Enum.Material.Air then 
				errorNotification('PlayerTP', 'Recall ability not available.', 7)
				return 
			end
			if not bedwars.AbilityController:canUseAbility('recall') then 
				errorNotification('PlayerTP', 'Recall ability not available.', 7)
				return
			end
			pcall(function()
				oldmovefunc = require(lplr.PlayerScripts.PlayerModule).controls.moveFunction 
				require(lplr.PlayerScripts.PlayerModule).controls.moveFunction = function() end
			end)
			bedwars.AbilityController:useAbility('recall')
			local teleported
			PlayerTP:Clean(lplr:GetAttributeChangedSignal('LastTeleported'):Connect(function() teleported = true end))
			repeat task.wait() until teleported or not PlayerTP.Enabled or not isAlive(lplr, true) 
			task.wait()
			local target = GetTarget(nil, PlayerTPSort.Value == 'Health', true)
			if target.RootPart == nil or not isAlive(lplr, true) or not PlayerTP.Enabled then 
				return
			end
			local localposition = lplr.Character:WaitForChild("HumanoidRootPart").Position
			local tweenspeed = (PlayerTPAutoSpeed.Enabled and ((target.RootPart.Position - localposition).Magnitude / 1000) + 0.001 or (PlayerTPSpeed.Value / 1000) + 0.1)
			local tweenstyle = (PlayerTPAutoSpeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[PlayerTPMethod.Value])
			playertween = tweenService:Create(lplr.Character:WaitForChild("HumanoidRootPart"), TweenInfo.new(tweenspeed, tweenstyle), {CFrame = target.RootPart.CFrame}) 
			playertween:Play() 
			playertween.Completed:Wait()
		end
	}
	PlayerTP = vape.Categories.Blatant:CreateModule({
		Name = 'PlayerTP',
		Tooltip = 'Tweens you to a nearby target.',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					repeat task.wait() until vape.Modules.Invisibility
					repeat task.wait() until vape.Modules.GamingChair
					if vape.Modules.Invisibility.Enabled and vape.Modules.GamingChair.Enabled then
						errorNotification("PlayerTP", "Please turn off the Invisibility and GamingChair module!", 3)
						PlayerTP:Toggle()
						return
					end
					if vape.Modules.Invisibility.Enabled then
						errorNotification("PlayerTP", "Please turn off the Invisibility module!", 3)
						PlayerTP:Toggle()
						return
					end
					if vape.Modules.GamingChair.Enabled then
						errorNotification("PlayerTP", "Please turn off the GamingChair module!", 3)
						PlayerTP:Toggle()
						return
					end
					if GetTarget(nil, PlayerTPSort.Value == 'Health', true) and GetTarget(nil, PlayerTPSort.Value == 'Health', true).RootPart and shared.VapeFullyLoaded then 
						bypassmethods[isAlive() and PlayerTPTeleport.Value or 'Respawn']() 
					else
						InfoNotification("PlayerTP", "No player/s found!", 3)
					end
					if PlayerTP.Enabled then 
						PlayerTP:Toggle()
					end
				end)
			else
				pcall(function() playertween:Disconnect() end)
				if oldmovefunc then 
					pcall(function() require(lplr.PlayerScripts.PlayerModule).controls.moveFunction = oldmovefunc end)
				end
				oldmovefunc = nil
			end
		end
	})
	PlayerTPTeleport = PlayerTP:CreateDropdown({
		Name = 'Teleport Method',
		List = {'Respawn', 'Recall'},
		Function = function() end
	})
	PlayerTPAutoSpeed = PlayerTP:CreateToggle({
		Name = 'Auto Speed',
		Tooltip = 'Automatically uses a "good" tween speed.',
		Default = true,
		Function = function(calling) 
			if calling then 
				pcall(function() PlayerTPSpeed.Object.Visible = false end) 
			else 
				pcall(function() PlayerTPSpeed.Object.Visible = true end) 
			end
		end
	})
	PlayerTPSpeed = PlayerTP:CreateSlider({
		Name = 'Tween Speed',
		Min = 20, 
		Max = 350,
		Default = 200,
		Function = function() end
	})
	PlayerTPMethod = PlayerTP:CreateDropdown({
		Name = 'Teleport Method',
		List = GetEnumItems('EasingStyle'),
		Function = function() end
	})
	PlayerTPSpeed.Object.Visible = false
end)

local GodMode = {Enabled = false}
run(function()
    local antiDeath = {}
    local antiDeathConfig = {
        Mode = {},
        BoostMode = {},
        SongId = {},
        Health = {},
        Velocity = {},
        CFrame = {},
        TweenPower = {},
        TweenDuration = {},
        SkyPosition = {},
        AutoDisable = {},
        Sound = {},
        Notify = {}
    }
    local antiDeathState = {}
    local handlers = {}

    function handlers.new()
        local self = {
			godmode = false,
            boost = false,
            inf = false,
            notify = false,
            id = false,
            hrp = entityLibrary.character.HumanoidRootPart,
            hasNotified = false
        }
        setmetatable(self, { __index = handlers })
        return self
    end

    function handlers:enable()
		antiDeath:Clean(runService.Heartbeat:Connect(function()
			if not isAlive(lplr, true) then
                handlers:disable()
                return
            end

            if getHealth() <= antiDeathConfig.Health.Value and getHealth() > 0 then
                if not handlers.boost then
                    handlers:activateMode()
                    if not handlers.hasNotified and antiDeathConfig.Notify.Enabled then
                        handlers:sendNotification()
                    end
                    handlers:playNotificationSound()
                    handlers.boost = true
                end
            else
                handlers:resetMode()
				pcall(function()
					handlers.hrp = entityLibrary.character.HumanoidRootPart
					handlers.hrp.Anchored = false
				end)
                handlers.boost = false

                if handlers.hasNotified then
                    handlers.hasNotified = false
                end
            end
		end))
    end

    function handlers:disable()
        --RunLoops:UnbindFromHeartbeat('antiDeath')
    end

    function handlers:activateMode()
        local modeActions = {
            Infinite = function() self:enableInfiniteMode() end,
            Boost = function() self:applyBoost() end,
            Sky = function() self:moveToSky() end,
			AntiHit = function() self:enableAntiHitMode() end
        }
		if antiDeathConfig.Mode.Value == "Infinite" then return end
        modeActions[antiDeathConfig.Mode.Value]()
    end

	function handlers:enableAntiHitMode()
		if not GodMode.Enabled then
			GodMode:Toggle(false)
			self.godmode = true
		end
	end

    function handlers:enableInfiniteMode()
        if not vape.Modules.InfiniteFly.Enabled then
            vape.Modules.InfiniteFly:Toggle(true)
            self.inf = true
        end
    end

    function handlers:applyBoost()
        local boostActions = {
            Velocity = function() self.hrp.Velocity += Vector3.new(0, antiDeathConfig.Velocity.Value, 0) end,
            CFrame = function() self.hrp.CFrame += Vector3.new(0, antiDeathConfig.CFrame.Value, 0) end,
            Tween = function()
                tweenService:Create(self.hrp, twinfo(antiDeathConfig.TweenDuration.Value / 10), {
                    CFrame = self.hrp.CFrame + Vector3.new(0, antiDeathConfig.TweenPower.Value, 0)
                }):Play()
            end
        }
        boostActions[antiDeathConfig.BoostMode.Value]()
    end

    function handlers:moveToSky()
        self.hrp.CFrame += Vector3.new(0, antiDeathConfig.SkyPosition.Value, 0)
        self.hrp.Anchored = true
    end

    function handlers:sendNotification()
        InfoNotification('AntiDeath', 'Prevented death. Health is lower than ' .. antiDeathConfig.Health.Value ..
            '. (Current health: ' .. math.floor(getHealth() + 0.5) .. ')', 5)
        self.hasNotified = true
    end

    function handlers:playNotificationSound()
        if antiDeathConfig.Sound.Enabled then
            local soundId = antiDeathConfig.SongId.Value ~= '' and antiDeathConfig.SongId.Value or '7396762708'
            playSound(soundId, false)
        end
    end

    function handlers:resetMode()
        if self.inf then
            if antiDeathConfig.AutoDisable.Enabled then
                if vape.Modules.InfiniteFly.Enabled then
                    vape.Modules.InfiniteFly:Toggle(false)
                end
            end
            self.inf = false
            self.hasNotified = false
        elseif self.godmode then
			if antiDeathConfig.AutoDisable.Enabled then
                if GodMode.Enabled then
                    GodMode:Toggle(false)
                end
            end
            self.godmode = false
            self.hasNotified = false
		end
    end

    local antiDeathStatus = handlers.new()

    antiDeath = vape.Categories.Utility:CreateModule({
        Name = 'AntiDeath',
        Function = function(callback)
            if callback then
                coroutine.wrap(function()
                    antiDeathStatus:enable()
                end)()
            else
                pcall(function()
                    antiDeathStatus:disable()
                end)
            end
        end,
        Default = false,
        Tooltip = btext('Prevents you from dying.'),
        ExtraText = function()
            return antiDeathConfig.Mode.Value
        end
    })

    antiDeathConfig.Mode = antiDeath:CreateDropdown({
        Name = 'Mode',
        List = {'Infinite', 'Boost', 'Sky', 'AntiHit'},
        Default = 'AntiHit',
        Tooltip = btext('Mode to prevent death.'),
        Function = function(val)
            antiDeathConfig.BoostMode.Object.Visible = val == 'Boost'
            antiDeathConfig.SkyPosition.Object.Visible = val == 'Sky'
            antiDeathConfig.AutoDisable.Object.Visible = (val == 'Infinite' or val == 'AntiHit')
            antiDeathConfig.Velocity.Object.Visible = false
            antiDeathConfig.CFrame.Object.Visible = false
            antiDeathConfig.TweenPower.Object.Visible = false
            antiDeathConfig.TweenDuration.Object.Visible = false
        end
    })

    antiDeathConfig.BoostMode = antiDeath:CreateDropdown({
        Name = 'Boost',
        List = { 'Velocity', 'CFrame', 'Tween' },
        Default = 'Velocity',
        Tooltip = btext('Mode to boost your character.'),
        Function = function(val)
            antiDeathConfig.Velocity.Object.Visible = val == 'Velocity'
            antiDeathConfig.CFrame.Object.Visible = val == 'CFrame'
            antiDeathConfig.TweenPower.Object.Visible = val == 'Tween'
            antiDeathConfig.TweenDuration.Object.Visible = val == 'Tween'
        end
    })
    antiDeathConfig.BoostMode.Object.Visible = false

    antiDeathConfig.SongId = antiDeath:CreateTextBox({
        Name = 'SongID',
        TempText = 'Song ID',
        Tooltip = 'ID to play the song.',
        FocusLost = function()
            if antiDeath.Enabled then
                antiDeath:Toggle()
                antiDeath:Toggle()
            end
        end
    })
    antiDeathConfig.SongId.Object.Visible = false

    antiDeathConfig.Health = antiDeath:CreateSlider({
        Name = 'Health Trigger',
        Min = 10,
        Max = 90,
        Tooltip = btext('Health at which AntiDeath will perform its actions.'),
        Default = 50,
        Function = function(val) end
    })

    antiDeathConfig.Velocity = antiDeath:CreateSlider({
        Name = 'Velocity Boost',
        Min = 100,
        Max = 600,
        Tooltip = btext('Power to get boosted in the air.'),
        Default = 600,
        Function = function(val) end
    })
    antiDeathConfig.Velocity.Object.Visible = false

    antiDeathConfig.CFrame = antiDeath:CreateSlider({
        Name = 'CFrame Boost',
        Min = 100,
        Max = 1000,
        Tooltip = btext('Power to get boosted in the air.'),
        Default = 1000,
        Function = function(val) end
    })
    antiDeathConfig.CFrame.Object.Visible = false

    antiDeathConfig.TweenPower = antiDeath:CreateSlider({
        Name = 'Tween Boost',
        Min = 100,
        Max = 1300,
        Tooltip = btext('Power to get boosted in the air.'),
        Default = 1000,
        Function = function(val) end
    })
    antiDeathConfig.TweenPower.Object.Visible = false

    antiDeathConfig.TweenDuration = antiDeath:CreateSlider({
        Name = 'Tween Duration',
        Min = 1,
        Max = 10,
        Tooltip = btext('Duration of the tweening process.'),
        Default = 4,
        Function = function(val) end
    })
    antiDeathConfig.TweenDuration.Object.Visible = false

    antiDeathConfig.SkyPosition = antiDeath:CreateSlider({
        Name = 'Sky Position',
        Min = 100,
        Max = 1000,
        Tooltip = btext('Position to TP in the sky.'),
        Default = 1000,
        Function = function(val) end
    })
    antiDeathConfig.SkyPosition.Object.Visible = false

    antiDeathConfig.AutoDisable = antiDeath:CreateToggle({
        Name = 'Auto Disable',
        Tooltip = btext('Automatically disables InfiniteFly after healing.'),
        Function = function(val) end,
        Default = true
    })
    antiDeathConfig.AutoDisable.Object.Visible = false

    antiDeathConfig.Sound = antiDeath:CreateToggle({
        Name = 'Sound',
        Tooltip = btext('Plays a sound after preventing death.'),
        Function = function(callback)
            antiDeathConfig.SongId.Object.Visible = callback
        end,
        Default = true
    })

    antiDeathConfig.Notify = antiDeath:CreateToggle({
        Name = 'Notification',
        Tooltip = btext('Notifies you when AntiDeath actioned.'),
        Default = true,
        Function = function(callback) end
    })
end)

run(function()
	local ExploitUser = {Enabled = false}
	local ExploitConfig = {
		TrainWhistle = false,
		PartyPopper = false,
		SkyScythe = false
	}
	local function getItem(itemName, inv)
		for slot, item in (inv or store.localInventory.inventory.items) do
			if item.itemType == itemName then
				return item, slot
			end
		end
		return nil
	end
	local ExploitTable = {
		TrainWhistle = function()
			bedwars.AbilityController:useAbility('TRAIN_WHISTLE')
		end,
		PartyPopper = function()
			bedwars.AbilityController:useAbility('PARTY_POPPER')
		end,
		SkyScythe = function()
			if getItem("sky_scythe") then
				bedwars.Client:Get('SkyScytheSpin'):SendToServer()
			end
		end
	}
	ExploitUser = vape.Categories.Utility:CreateModule({
		Name = "ExploitUser",
		Function = function(call)
			if call then
				task.spawn(function()
					repeat task.wait();
						for i,v in pairs(ExploitTable) do
							if ExploitConfig[v] then 
								pcall(v) 
							end
						end
					until (not ExploitUser.Enabled)
				end)
			end
		end
	})
	for i,v in pairs(ExploitTable) do
		ExploitUser:CreateToggle({
			Name = tostring(i).."Exploit",
			Function = function(call) ExploitConfig[i] = call end
		})
	end
end)

run(function()
	local TexturePacks = {["Enabled"] = false}
	local packselected = {["Value"] = "OldBedwars"}

	local toolFunction = function() end
	local con

	local packfunctions = {
		SeventhPack = function() 
			task.spawn(function()
				local Players = game:GetService("Players")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local Workspace = game:GetService("Workspace")
				local objs = game:GetObjects("rbxassetid://14033898270")
				local import = objs[1]
				import.Parent = ReplicatedStorage
				local index = {
					{
						name = "wood_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-100), math.rad(-90)),
						model = import:WaitForChild("Wood_Sword"),
					},	
					{
						name = "stone_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-100), math.rad(-90)),
						model = import:WaitForChild("Stone_Sword"),
					},
					{
						name = "iron_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-100), math.rad(-90)),
						model = import:WaitForChild("Iron_Sword"),
					},
					{
						name = "diamond_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-100), math.rad(-90)),
						model = import:WaitForChild("Diamond_Sword"),
					},
					{
						name = "emerald_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-100), math.rad(-90)),
						model = import:WaitForChild("Emerald_Sword"),
					},
					{
						name = "wood_pickaxe",
						offset = CFrame.Angles(math.rad(0), math.rad(-190), math.rad(-95)),
						model = import:WaitForChild("Wood_Pickaxe"),
					},
					{
						name = "stone_pickaxe",
						offset = CFrame.Angles(math.rad(0), math.rad(-190), math.rad(-95)),
						model = import:WaitForChild("Stone_Pickaxe"),
					},
					{
						name = "iron_pickaxe",
						offset = CFrame.Angles(math.rad(0), math.rad(-190), math.rad(-95)),
						model = import:WaitForChild("Iron_Pickaxe"),
					},
					{
						name = "diamond_pickaxe",
						offset = CFrame.Angles(math.rad(0), math.rad(80), math.rad(-95)),
						model = import:WaitForChild("Diamond_Pickaxe"),
					},	
					{
						name = "wood_axe",
						offset = CFrame.Angles(math.rad(0), math.rad(-10), math.rad(-95)),
						model = import:WaitForChild("Wood_Axe"),
					},	
					{
						name = "stone_axe",
						offset = CFrame.Angles(math.rad(0), math.rad(-10), math.rad(-95)),
						model = import:WaitForChild("Stone_Axe"),
					},	
					{
						name = "iron_axe",
						offset = CFrame.Angles(math.rad(0), math.rad(-10), math.rad(-95)),
						model = import:WaitForChild("Iron_Axe"),
					},	
					{
						name = "diamond_axe",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(-95)),
						model = import:WaitForChild("Diamond_Axe"),
					},	
					{
						name = "fireball",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Fireball"),
					},	
					{
						name = "telepearl",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Telepearl"),
					},
				}
				toolFunction = function(tool)	
					if not tool:IsA("Accessory") then return end	
					for _, v in ipairs(index) do	
						if v.name == tool.Name then		
							for _, part in ipairs(tool:GetDescendants()) do
								if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then				
									part.Transparency = 1
								end			
							end		
							local model = v.model:Clone()
							model.CFrame = tool:WaitForChild("Handle").CFrame * v.offset
							model.CFrame *= CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0))
							model.Parent = tool			
							local weld = Instance.new("WeldConstraint", model)
							weld.Part0 = model
							weld.Part1 = tool:WaitForChild("Handle")			
							local tool2 = Players.LocalPlayer.Character:WaitForChild(tool.Name)			
							for _, part in ipairs(tool2:GetDescendants()) do
								if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then				
									part.Transparency = 1				
								end			
							end			
							local model2 = v.model:Clone()
							model2.Anchored = false
							model2.CFrame = tool2:WaitForChild("Handle").CFrame * v.offset
							model2.CFrame *= CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0))
							if v.name:match("sword") or v.name:match("blade") then
								model2.CFrame *= CFrame.new(.5, 0, -1.1) - Vector3.new(0, 0, -.3)
							elseif v.name:match("axe") and not v.name:match("pickaxe") and v.name:match("diamond") then
								model2.CFrame *= CFrame.new(.08, 0, -1.1) - Vector3.new(0, 0, -.9)
							elseif v.name:match("axe") and not v.name:match("pickaxe") and not v.name:match("diamond") then
								model2.CFrame *= CFrame.new(-.2, 0, -2.4) + Vector3.new(0, 0, 2.12)
							else
								model2.CFrame *= CFrame.new(.2, 0, -.09)
							end
							model2.Parent = tool2
							local weld2 = Instance.new("WeldConstraint", model)
							weld2.Part0 = model2
							weld2.Part1 = tool2:WaitForChild("Handle")
						end
					end
				end
			end)
		end,
		EighthPack = function() 
			task.spawn(function()
				local Players = game:GetService("Players")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local Workspace = game:GetService("Workspace")
				local objs = game:GetObjects("rbxassetid://14078540433")
				local import = objs[1]
				import.Parent = game:GetService("ReplicatedStorage")
				index = {
					{
						name = "wood_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
						model = import:WaitForChild("Wood_Sword"),
					},
					{
						name = "stone_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
						model = import:WaitForChild("Stone_Sword"),
					},
					{
						name = "iron_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
						model = import:WaitForChild("Iron_Sword"),
					},
					{
						name = "diamond_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
						model = import:WaitForChild("Diamond_Sword"),
					},
					{
						name = "emerald_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
						model = import:WaitForChild("Emerald_Sword"),
					},
					{
						name = "rageblade",
						offset = CFrame.Angles(math.rad(0),math.rad(-90),math.rad(90)),
						model = import:WaitForChild("Rageblade"),
					}, 
				}
				toolFunction = function(tool)
					if(not tool:IsA("Accessory")) then return end
					for i,v in pairs(index) do
						if(v.name == tool.Name) then
							for i,v in pairs(tool:GetDescendants()) do
								if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
									v.Transparency = 1
								end
							end
							local model = v.model:Clone()
							model.CFrame = tool:WaitForChild("Handle").CFrame * v.offset
							model.CFrame *= CFrame.Angles(math.rad(0),math.rad(-50),math.rad(0))
							model.Parent = tool
							local weld = Instance.new("WeldConstraint",model)
							weld.Part0 = model
							weld.Part1 = tool:WaitForChild("Handle")
							local tool2 = Players.LocalPlayer.Character:WaitForChild(tool.Name)
							for i,v in pairs(tool2:GetDescendants()) do
								if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
									v.Transparency = 1
								end
							end
							local model2 = v.model:Clone()
							model2.Anchored = false
							model2.CFrame = tool2:WaitForChild("Handle").CFrame * v.offset
							model2.CFrame *= CFrame.Angles(math.rad(0),math.rad(-50),math.rad(0))
							model2.CFrame *= CFrame.new(.5,0,-.8)
							model2.Parent = tool2
							local weld2 = Instance.new("WeldConstraint",model)
							weld2.Part0 = model2
							weld2.Part1 = tool2:WaitForChild("Handle")
						end
					end
				end
			end)
		end,
		SixthPack = function() 
			task.spawn(function()
				local Players = game:GetService("Players")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local Workspace = game:GetService("Workspace")

				local objs = game:GetObjects("rbxassetid://13780890894")
				local import = objs[1]
				import.Parent = ReplicatedStorage
				
				local swordIndex = {
					{
						name = "wood_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-100), math.rad(-90)),
						model = import:WaitForChild("Wood_Sword"),
					},
					{
						name = "stone_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-100), math.rad(-90)),
						model = import:WaitForChild("Stone_Sword"),
					},
					{
						name = "iron_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-100), math.rad(-90)),
						model = import:WaitForChild("Iron_Sword"),
					},
					{
						name = "diamond_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-100), math.rad(-90)),
						model = import:WaitForChild("Diamond_Sword"),
					},
					{
						name = "emerald_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-100), math.rad(-90)),
						model = import:WaitForChild("Emerald_Sword"),
					},
				}
				
				local pickaxeIndex = {
					{
						name = "wood_pickaxe",
						offset = CFrame.Angles(math.rad(0), math.rad(-190), math.rad(-95)),
						model = import:WaitForChild("Wood_Pickaxe"),
					},
					{
						name = "stone_pickaxe",
						offset = CFrame.Angles(math.rad(0), math.rad(-190), math.rad(-95)),
						model = import:WaitForChild("Stone_Pickaxe"),
					},
					{
						name = "iron_pickaxe",
						offset = CFrame.Angles(math.rad(0), math.rad(-190), math.rad(-95)),
						model = import:WaitForChild("Iron_Pickaxe"),
					},
					{
						name = "diamond_pickaxe",
						offset = CFrame.Angles(math.rad(0), math.rad(80), math.rad(-95)),
						model = import:WaitForChild("Diamond_Pickaxe"),
					},
				}

				local swordFunction = function(tool)
					if not tool:IsA("Accessory") then
						return
					end
					
					for _, v in pairs(swordIndex) do
						if v.name == tool.Name then
							for _, v in pairs(tool:GetDescendants()) do
								if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
									v.Transparency = 1
								end
							end
							
							local model = v.model:Clone()
							model.CFrame = tool.Handle.CFrame * v.offset
							model.CFrame *= CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0))
							model.Parent = tool
							
							local weld = Instance.new("WeldConstraint", model)
							weld.Part0 = model
							weld.Part1 = tool.Handle
							
							local tool2 = Players.LocalPlayer.Character[tool.Name]
							
							for _, v in pairs(tool2:GetDescendants()) do
								if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
									v.Transparency = 1
								end
							end
							
							local model2 = v.model:Clone()
							model2.Anchored = false
							model2.CFrame = tool2.Handle.CFrame * v.offset
							model2.CFrame *= CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0))
							model2.CFrame *= CFrame.new(0.4, 0, -0.9)
							model2.Parent = tool2
							
							local weld2 = Instance.new("WeldConstraint", model)
							weld2.Part0 = model2
							weld2.Part1 = tool2.Handle
						end
					end
				end

				local pickaxeFunction = function(tool)
					if not tool:IsA("Accessory") then
						return
					end

					for _, v in pairs(pickaxeIndex) do
						if v.name == tool.Name then
							for _, v in pairs(tool:GetDescendants()) do
								if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
									v.Transparency = 1
								end
							end
							local model = v.model:Clone()
							model.CFrame = tool.Handle.CFrame * v.offset
							model.CFrame *= CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0))
							model.Parent = tool
							local weld = Instance.new("WeldConstraint", model)
							weld.Part0 = model
							weld.Part1 = tool.Handle
							local tool2 = Players.LocalPlayer.Character[tool.Name]
							for _, v in pairs(tool2:GetDescendants()) do
								if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
									v.Transparency = 1
								end
							end
							local model2 = v.model:Clone()
							model2.Anchored = false
							model2.CFrame = tool2.Handle.CFrame * v.offset
							model2.CFrame *= CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0))
							model2.CFrame *= CFrame.new(-0.2, 0, -0.08)
							model2.Parent = tool2
							local weld2 = Instance.new("WeldConstraint", model)
							weld2.Part0 = model2
							weld2.Part1 = tool2.Handle
						end
					end
				end

				toolFunction = function(tool)
					task.spawn(function() swordFunction(tool) end)
					task.spawn(function() pickaxeFunction(tool) end)
				end
			end)
		end,
		FifthPack = function() 
			task.spawn(function()
				local Players = game:GetService("Players")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local Workspace = game:GetService("Workspace")
				
				local objs = game:GetObjects("rbxassetid://13802020264")
				local import = objs[1]
				
				import.Parent = game:GetService("ReplicatedStorage")
				
				index = {
					{
						name = "wood_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
						model = import:WaitForChild("Wood_Sword"),
					},
					
					{
						name = "stone_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
						model = import:WaitForChild("Stone_Sword"),
					},
					
					{
						name = "iron_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
						model = import:WaitForChild("Iron_Sword"),
					},
					
					{
						name = "diamond_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
						model = import:WaitForChild("Diamond_Sword"),
					},
					
					{
						name = "emerald_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
						model = import:WaitForChild("Emerald_Sword"),
					},
					
					
				}
				
				toolFunction = function(tool)
					if(not tool:IsA("Accessory")) then return end
					for i,v in pairs(index) do
						if(v.name == tool.Name) then
							for i,v in pairs(tool:GetDescendants()) do
								if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
									v.Transparency = 1
								end
							end
						
							local model = v.model:Clone()
							model.CFrame = tool:WaitForChild("Handle").CFrame * v.offset
							model.CFrame *= CFrame.Angles(math.rad(0),math.rad(-50),math.rad(0))
							model.Parent = tool
							
							local weld = Instance.new("WeldConstraint",model)
							weld.Part0 = model
							weld.Part1 = tool:WaitForChild("Handle")
							
							local tool2 = Players.LocalPlayer.Character:WaitForChild(tool.Name)
							
							for i,v in pairs(tool2:GetDescendants()) do
								if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
									v.Transparency = 1
								end
							end
							
							local model2 = v.model:Clone()
							model2.Anchored = false
							model2.CFrame = tool2:WaitForChild("Handle").CFrame * v.offset
							model2.CFrame *= CFrame.Angles(math.rad(0),math.rad(-50),math.rad(0))
							model2.CFrame *= CFrame.new(0.8,0,-.9)
							model2.Parent = tool2
							
							local weld2 = Instance.new("WeldConstraint",model)
							weld2.Part0 = model2
							weld2.Part1 = tool2:WaitForChild("Handle")			
						end
					end
				end
			end)
		end,
		FourthPack = function() 
			task.spawn(function()
				local Players = game:GetService("Players")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local Workspace = game:GetService("Workspace")
				
				local objs = game:GetObjects("rbxassetid://13801509384")
				local import = objs[1]
				
				import.Parent = game:GetService("ReplicatedStorage")
				
				index = {
				
					{
						name = "wood_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
						model = import:WaitForChild("Wood_Sword"),
					},
					
					{
						name = "stone_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
						model = import:WaitForChild("Stone_Sword"),
					},
					
					{
						name = "iron_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
						model = import:WaitForChild("Iron_Sword"),
					},
					
					{
						name = "diamond_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
						model = import:WaitForChild("Diamond_Sword"),
					},
					
					{
						name = "emerald_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
						model = import:WaitForChild("Emerald_Sword"),
					},
					
					{
						name = "rageblade",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-270)),
						model = import:WaitForChild("Rageblade"),
					},
					
					
				}

				toolFunction = function(tool)
					if(not tool:IsA("Accessory")) then return end
					for i,v in pairs(index) do
						if(v.name == tool.Name) then	
							for i,v in pairs(tool:GetDescendants()) do
								if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then	
									v.Transparency = 1
								end
							end
						
							local model = v.model:Clone()
							model.CFrame = tool:WaitForChild("Handle").CFrame * v.offset
							model.CFrame *= CFrame.Angles(math.rad(0),math.rad(-50),math.rad(0))
							model.Parent = tool
							
							local weld = Instance.new("WeldConstraint",model)
							weld.Part0 = model
							weld.Part1 = tool:WaitForChild("Handle")
							
							local tool2 = Players.LocalPlayer.Character:WaitForChild(tool.Name)
							
							for i,v in pairs(tool2:GetDescendants()) do
								if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then	
									v.Transparency = 1	
								end	
							end

							local model2 = v.model:Clone()
							model2.Anchored = false
							model2.CFrame = tool2:WaitForChild("Handle").CFrame * v.offset
							model2.CFrame *= CFrame.Angles(math.rad(0),math.rad(-50),math.rad(0))
							model2.CFrame *= CFrame.new(0.4,0,-.9)
							model2.Parent = tool2
							
							local weld2 = Instance.new("WeldConstraint",model)
							weld2.Part0 = model2
							weld2.Part1 = tool2:WaitForChild("Handle")					
						end
					end
				end
			end)
		end,
		SecondPack = function() 
			task.spawn(function()
				local Players = game:GetService("Players")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local Workspace = game:GetService("Workspace")
				local objs = game:GetObjects("rbxassetid://13801616054")
				local import = objs[1]
				import.Parent = game:GetService("ReplicatedStorage")
				index = {
					{
						name = "wood_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(100),math.rad(-90)),
						model = import:WaitForChild("Wood_Sword"),
					},
					
					{
						name = "stone_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(100),math.rad(-90)),
						model = import:WaitForChild("Stone_Sword"),
					},
					
					{
						name = "iron_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(100),math.rad(-90)),
						model = import:WaitForChild("Iron_Sword"),
					},
					
					{
						name = "diamond_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(100),math.rad(-90)),
						model = import:WaitForChild("Diamond_Sword"),
					},
					
					{
						name = "emerald_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(100),math.rad(-90)),
						model = import:WaitForChild("Emerald_Sword"),
					},
					
					{
						name = "rageblade",
						offset = CFrame.Angles(math.rad(0),math.rad(100),math.rad(-270)),
						model = import:WaitForChild("Rageblade"),
					},
					
					
				}

				toolFunction = function(tool)
					if(not tool:IsA("Accessory")) then return end
					for i,v in pairs(index) do
						if(v.name == tool.Name) then
							for i,v in pairs(tool:GetDescendants()) do
								if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
									v.Transparency = 1
								end
							end
						
							local model = v.model:Clone()
							model.CFrame = tool:WaitForChild("Handle").CFrame * v.offset
							model.CFrame *= CFrame.Angles(math.rad(0),math.rad(-50),math.rad(0))
							model.Parent = tool
							
							local weld = Instance.new("WeldConstraint",model)
							weld.Part0 = model
							weld.Part1 = tool:WaitForChild("Handle")
							
							local tool2 = Players.LocalPlayer.Character:WaitForChild(tool.Name)
							
							for i,v in pairs(tool2:GetDescendants()) do
								if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
									v.Transparency = 1
								end
							end
							
							local model2 = v.model:Clone()
							model2.Anchored = false
							model2.CFrame = tool2:WaitForChild("Handle").CFrame * v.offset
							model2.CFrame *= CFrame.Angles(math.rad(0),math.rad(-50),math.rad(0))
							model2.CFrame *= CFrame.new(0.8,0,-.9)
							model2.Parent = tool2
							
							local weld2 = Instance.new("WeldConstraint",model)
							weld2.Part0 = model2
							weld2.Part1 = tool2:WaitForChild("Handle")
						end
					end
				end
			end)
		end,
		FirstPack = function() 
			task.spawn(function()
				local Players = game:GetService("Players")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local Workspace = game:GetService("Workspace")
				local objs = game:GetObjects("rbxassetid://13783192680")
				local import = objs[1]
				import.Parent = game:GetService("ReplicatedStorage")
				index = {
					{
						name = "wood_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
						model = import:WaitForChild("Wood_Sword"),
					},
					
					{
						name = "stone_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
						model = import:WaitForChild("Stone_Sword"),
					},
					
					{
						name = "iron_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
						model = import:WaitForChild("Iron_Sword"),
					},
					
					{
						name = "diamond_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
						model = import:WaitForChild("Diamond_Sword"),
					},
					
					{
						name = "emerald_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
						model = import:WaitForChild("Emerald_Sword"),
					},
					
					
				}
				toolFunction = function(tool)
					if(not tool:IsA("Accessory")) then return end
					for i,v in pairs(index) do
						if(v.name == tool.Name) then
							for i,v in pairs(tool:GetDescendants()) do
								if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
									v.Transparency = 1
								end
							end
							local model = v.model:Clone()
							model.CFrame = tool:WaitForChild("Handle").CFrame * v.offset
							model.CFrame *= CFrame.Angles(math.rad(0),math.rad(-50),math.rad(0))
							model.Parent = tool
							
							local weld = Instance.new("WeldConstraint",model)
							weld.Part0 = model
							weld.Part1 = tool:WaitForChild("Handle")
							
							local tool2 = Players.LocalPlayer.Character:WaitForChild(tool.Name)
							
							for i,v in pairs(tool2:GetDescendants()) do
								if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
									v.Transparency = 1
								end
							end
							
							local model2 = v.model:Clone()
							model2.Anchored = false
							model2.CFrame = tool2:WaitForChild("Handle").CFrame * v.offset
							model2.CFrame *= CFrame.Angles(math.rad(0),math.rad(-50),math.rad(0))
							model2.CFrame *= CFrame.new(0.4,0,-.9)
							model2.Parent = tool2
							
							local weld2 = Instance.new("WeldConstraint",model)
							weld2.Part0 = model2
							weld2.Part1 = tool2:WaitForChild("Handle")
						end
					end
				end
			end)
		end,
		CottonCandy = function() 
			task.spawn(function() 
				local Players = game:GetService("Players")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local Workspace = game:GetService("Workspace")
				local objs = game:GetObjects("rbxassetid://14161283331")
				local import = objs[1]
				import.Parent = ReplicatedStorage
				local index = {
					{
						name = "wood_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Wood_Sword"),
					},	
					{
						name = "stone_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Stone_Sword"),
					},
					{
						name = "iron_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Iron_Sword"),
					},
					{
						name = "diamond_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Diamond_Sword"),
					},
					{
						name = "emerald_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Emerald_Sword"),
					},
					{
						name = "rageblade",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(90)),
						model = import:WaitForChild("Rageblade"),
					}, 
					{
						name = "wood_pickaxe",
						offset = CFrame.Angles(math.rad(0), math.rad(-180), math.rad(-95)),
						model = import:WaitForChild("Wood_Pickaxe"),
					},
					{
						name = "stone_pickaxe",
						offset = CFrame.Angles(math.rad(0), math.rad(-180), math.rad(-95)),
						model = import:WaitForChild("Stone_Pickaxe"),
					},
					{
						name = "iron_pickaxe",
						offset = CFrame.Angles(math.rad(0), math.rad(-18033), math.rad(-95)),
						model = import:WaitForChild("Iron_Pickaxe"),
					},
					{
						name = "diamond_pickaxe",
						offset = CFrame.Angles(math.rad(0), math.rad(80), math.rad(-95)),
						model = import:WaitForChild("Diamond_Pickaxe"),
					},	
					{
						name = "wood_axe",
						offset = CFrame.Angles(math.rad(0), math.rad(-10), math.rad(-95)),
						model = import:WaitForChild("Wood_Axe"),
					},	
					{
						name = "stone_axe",
						offset = CFrame.Angles(math.rad(0), math.rad(-10), math.rad(-95)),
						model = import:WaitForChild("Stone_Axe"),
					},	
					{
						name = "iron_axe",
						offset = CFrame.Angles(math.rad(0), math.rad(-10), math.rad(-95)),
						model = import:WaitForChild("Iron_Axe"),
					},	
					{
						name = "diamond_axe",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-95)),
						model = import:WaitForChild("Diamond_Axe"),
					},	
					{
						name = "fireball",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Fireball"),
					},	
					{
						name = "telepearl",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Telepearl"),
					},
					{
						name = "diamond",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Diamond"),
					},
					{
						name = "iron",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Iron"),
					},
					{
						name = "gold",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Gold"),
					},
					{
						name = "emerald",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Emerald"),
					},
					{
						name = "wood_bow",
						offset = CFrame.Angles(math.rad(0), math.rad(0), math.rad(90)),
						model = import:WaitForChild("Bow"),
					},
					{
						name = "wood_crossbow",
						offset = CFrame.Angles(math.rad(0), math.rad(0), math.rad(90)),
						model = import:WaitForChild("Bow"),
					},
					{
						name = "tactical_crossbow",
						offset = CFrame.Angles(math.rad(0), math.rad(180), math.rad(-90)),
						model = import:WaitForChild("Bow"),
					},
				}
				toolFunction = function(tool)	
					if not tool:IsA("Accessory") then return end	
					for _, v in ipairs(index) do	
						if v.name == tool.Name then		
							for _, part in ipairs(tool:GetDescendants()) do
								if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then				
									part.Transparency = 1
								end			
							end		
							local model = v.model:Clone()
							model.CFrame = tool:WaitForChild("Handle").CFrame * v.offset
							model.CFrame *= CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0))
							model.Parent = tool			
							local weld = Instance.new("WeldConstraint", model)
							weld.Part0 = model
							weld.Part1 = tool:WaitForChild("Handle")			
							local tool2 = Players.LocalPlayer.Character:WaitForChild(tool.Name)			
							for _, part in ipairs(tool2:GetDescendants()) do
								if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then				
									part.Transparency = 1				
								end			
							end			
							local model2 = v.model:Clone()
							model2.Anchored = false
							model2.CFrame = tool2:WaitForChild("Handle").CFrame * v.offset
							model2.CFrame *= CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0))
							if v.name:match("rageblade") then
								model2.CFrame *= CFrame.new(0.7, 0, -1)                           
							elseif v.name:match("sword") or v.name:match("blade") then
								model2.CFrame *= CFrame.new(.6, 0, -1.1) - Vector3.new(0, 0, -.3)
							elseif v.name:match("axe") and not v.name:match("pickaxe") and v.name:match("diamond") then
								model2.CFrame *= CFrame.new(.08, 0, -1.1) - Vector3.new(0, 0, -1.1)
							elseif v.name:match("axe") and not v.name:match("pickaxe") and not v.name:match("diamond") then
								model2.CFrame *= CFrame.new(-.2, 0, -2.4) + Vector3.new(0, 0, 2.12)
							elseif v.name:match("iron") then
								model2.CFrame *= CFrame.new(0, -.24, 0)
							elseif v.name:match("gold") then
								model2.CFrame *= CFrame.new(0, .03, 0)
							elseif v.name:match("diamond") then
								model2.CFrame *= CFrame.new(0, .027, 0)
							elseif v.name:match("emerald") then
								model2.CFrame *= CFrame.new(0, .001, 0)
							elseif v.name:match("telepearl") then
								model2.CFrame *= CFrame.new(.1, 0, .1)
							elseif v.name:match("fireball") then
								model2.CFrame *= CFrame.new(.28, .1, 0)
							elseif v.name:match("bow") and not v.name:match("crossbow") then
								model2.CFrame *= CFrame.new(-.29, .1, -.2)
							elseif v.name:match("wood_crossbow") and not v.name:match("tactical_crossbow") then
								model2.CFrame *= CFrame.new(-.6, 0, 0)
							elseif v.name:match("tactical_crossbow") and not v.name:match("wood_crossbow") then
								model2.CFrame *= CFrame.new(-.5, 0, -1.2)
							else
								model2.CFrame *= CFrame.new(.2, 0, -.2)
							end
							model2.Parent = tool2
							local weld2 = Instance.new("WeldConstraint", model)
							weld2.Part0 = model2
							weld2.Part1 = tool2:WaitForChild("Handle")
						end
					end
				end   
			end)
		end,
		EgirlPack = function() 
			task.spawn(function() 	
				local Players = game:GetService("Players")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local Workspace = game:GetService("Workspace")
				local objs = game:GetObjects("rbxassetid://14126814481")
				local import = objs[1]
				import.Parent = game:GetService("ReplicatedStorage")
				index = {
					{
						name = "wood_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
						model = import:WaitForChild("Wood_Sword"),
					},
					{
						name = "stone_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
						model = import:WaitForChild("Stone_Sword"),
					},
					{
						name = "iron_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
						model = import:WaitForChild("Iron_Sword"),
					},
					{
						name = "diamond_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
						model = import:WaitForChild("Diamond_Sword"),
					},
					{
						name = "emerald_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
						model = import:WaitForChild("Emerald_Sword"),
					},
					{
						name = "rageblade",
						offset = CFrame.Angles(math.rad(0),math.rad(-90),math.rad(90)),
						model = import:WaitForChild("Rageblade"),
					}, 
				}
				toolFunction = function(tool)
					if(not tool:IsA("Accessory")) then return end
					for i,v in pairs(index) do
						if(v.name == tool.Name) then
							for i,v in pairs(tool:GetDescendants()) do
								if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
									v.Transparency = 1
								end
							end
							local model = v.model:Clone()
							model.CFrame = tool:WaitForChild("Handle").CFrame * v.offset
							model.CFrame *= CFrame.Angles(math.rad(0),math.rad(-50),math.rad(0))
							model.Parent = tool
							local weld = Instance.new("WeldConstraint",model)
							weld.Part0 = model
							weld.Part1 = tool:WaitForChild("Handle")
							local tool2 = Players.LocalPlayer.Character:WaitForChild(tool.Name)
							for i,v in pairs(tool2:GetDescendants()) do
								if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
									v.Transparency = 1
								end
							end
							local model2 = v.model:Clone()
							model2.Anchored = false
							model2.CFrame = tool2:WaitForChild("Handle").CFrame * v.offset
							model2.CFrame *= CFrame.Angles(math.rad(0),math.rad(-50),math.rad(0))
							model2.CFrame *= CFrame.new(.6,0,-1)
							model2.Parent = tool2
							local weld2 = Instance.new("WeldConstraint",model)
							weld2.Part0 = model2
							weld2.Part1 = tool2:WaitForChild("Handle")
						end
					end
				end             
			end)
		end,
		GlizzyPack = function() 
			task.spawn(function()
				local Players = game:GetService("Players")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local Workspace = game:GetService("Workspace")
				local objs = game:GetObjects("rbxassetid://13804645310")
				local import = objs[1]
				import.Parent = game:GetService("ReplicatedStorage")
				index = {
					{
						name = "wood_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
						model = import:WaitForChild("Wood_Sword"),
					},
					{
						name = "stone_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
						model = import:WaitForChild("Stone_Sword"),
					},
					{
						name = "iron_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
						model = import:WaitForChild("Iron_Sword"),
					},
					{
						name = "diamond_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
						model = import:WaitForChild("Diamond_Sword"),
					},
					{
						name = "emerald_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
						model = import:WaitForChild("Emerald_Sword"),
					},
					{
						name = "rageblade",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-270)),
						model = import:WaitForChild("Rageblade"),
					},
				}
				toolFunction = function(tool)
					if(not tool:IsA("Accessory")) then return end
					for i,v in pairs(index) do
						if(v.name == tool.Name) then
							for i,v in pairs(tool:GetDescendants()) do
								if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
									v.Transparency = 1
								end
							end
							local model = v.model:Clone()
							model.CFrame = tool:WaitForChild("Handle").CFrame * v.offset
							model.CFrame *= CFrame.Angles(math.rad(0),math.rad(100),math.rad(0))
							model.Parent = tool
							local weld = Instance.new("WeldConstraint",model)
							weld.Part0 = model
							weld.Part1 = tool:WaitForChild("Handle")
							local tool2 = Players.LocalPlayer.Character:WaitForChild(tool.Name)
							for i,v in pairs(tool2:GetDescendants()) do
								if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
									v.Transparency = 1
								end
							end
							local model2 = v.model:Clone()
							model2.Anchored = false
							model2.CFrame = tool2:WaitForChild("Handle").CFrame * v.offset
							model2.CFrame *= CFrame.Angles(math.rad(0),math.rad(-105),math.rad(0))
							model2.CFrame *= CFrame.new(-0.4,0,-0.10)
							model2.Parent = tool2
							local weld2 = Instance.new("WeldConstraint",model)
							weld2.Part0 = model2
							weld2.Part1 = tool2:WaitForChild("Handle")
						end
					end
				end
			end)
        end,
		PrivatePack = function() 
			task.spawn(function()
				local Players = game:GetService("Players")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local Workspace = game:GetService("Workspace")
				local objs = game:GetObjects("rbxassetid://14161283331")
				local import = objs[1]
				import.Parent = ReplicatedStorage
				local index = {
					{
						name = "wood_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Wood_Sword"),
					},	
					{
						name = "stone_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Stone_Sword"),
					},
					{
						name = "iron_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Iron_Sword"),
					},
					{
						name = "diamond_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Diamond_Sword"),
					},
					{
						name = "emerald_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Emerald_Sword"),
					},
					{
						name = "rageblade",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(90)),
						model = import:WaitForChild("Rageblade"),
					}, 
					{
						name = "wood_pickaxe",
						offset = CFrame.Angles(math.rad(0), math.rad(-180), math.rad(-95)),
						model = import:WaitForChild("Wood_Pickaxe"),
					},
					{
						name = "stone_pickaxe",
						offset = CFrame.Angles(math.rad(0), math.rad(-180), math.rad(-95)),
						model = import:WaitForChild("Stone_Pickaxe"),
					},
					{
						name = "iron_pickaxe",
						offset = CFrame.Angles(math.rad(0), math.rad(-18033), math.rad(-95)),
						model = import:WaitForChild("Iron_Pickaxe"),
					},
					{
						name = "diamond_pickaxe",
						offset = CFrame.Angles(math.rad(0), math.rad(80), math.rad(-95)),
						model = import:WaitForChild("Diamond_Pickaxe"),
					},	
					{
						name = "wood_axe",
						offset = CFrame.Angles(math.rad(0), math.rad(-10), math.rad(-95)),
						model = import:WaitForChild("Wood_Axe"),
					},	
					{
						name = "stone_axe",
						offset = CFrame.Angles(math.rad(0), math.rad(-10), math.rad(-95)),
						model = import:WaitForChild("Stone_Axe"),
					},	
					{
						name = "iron_axe",
						offset = CFrame.Angles(math.rad(0), math.rad(-10), math.rad(-95)),
						model = import:WaitForChild("Iron_Axe"),
					},	
					{
						name = "diamond_axe",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-95)),
						model = import:WaitForChild("Diamond_Axe"),
					},	
					{
						name = "fireball",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Fireball"),
					},	
					{
						name = "telepearl",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Telepearl"),
					},
					{
						name = "diamond",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Diamond"),
					},
					{
						name = "iron",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Iron"),
					},
					{
						name = "gold",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Gold"),
					},
					{
						name = "emerald",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Emerald"),
					},
					{
						name = "wood_bow",
						offset = CFrame.Angles(math.rad(0), math.rad(0), math.rad(90)),
						model = import:WaitForChild("Bow"),
					},
					{
						name = "wood_crossbow",
						offset = CFrame.Angles(math.rad(0), math.rad(0), math.rad(90)),
						model = import:WaitForChild("Bow"),
					},
					{
						name = "tactical_crossbow",
						offset = CFrame.Angles(math.rad(0), math.rad(180), math.rad(-90)),
						model = import:WaitForChild("Bow"),
					},
				}
				toolFunction = function(tool)	
					if not tool:IsA("Accessory") then return end	
					for _, v in ipairs(index) do	
						if v.name == tool.Name then		
							for _, part in ipairs(tool:GetDescendants()) do
								if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then				
									part.Transparency = 1
								end			
							end		
							local model = v.model:Clone()
							model.CFrame = tool:WaitForChild("Handle").CFrame * v.offset
							model.CFrame *= CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0))
							model.Parent = tool			
							local weld = Instance.new("WeldConstraint", model)
							weld.Part0 = model
							weld.Part1 = tool:WaitForChild("Handle")			
							local tool2 = Players.LocalPlayer.Character:WaitForChild(tool.Name)			
							for _, part in ipairs(tool2:GetDescendants()) do
								if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then				
									part.Transparency = 1				
								end			
							end			
							local model2 = v.model:Clone()
							model2.Anchored = false
							model2.CFrame = tool2:WaitForChild("Handle").CFrame * v.offset
							model2.CFrame *= CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0))
							if v.name:match("rageblade") then
								model2.CFrame *= CFrame.new(0.7, 0, -1)                           
							elseif v.name:match("sword") or v.name:match("blade") then
								model2.CFrame *= CFrame.new(.6, 0, -1.1) - Vector3.new(0, 0, -.3)
							elseif v.name:match("axe") and not v.name:match("pickaxe") and v.name:match("diamond") then
								model2.CFrame *= CFrame.new(.08, 0, -1.1) - Vector3.new(0, 0, -1.1)
							elseif v.name:match("axe") and not v.name:match("pickaxe") and not v.name:match("diamond") then
								model2.CFrame *= CFrame.new(-.2, 0, -2.4) + Vector3.new(0, 0, 2.12)
							elseif v.name:match("iron") then
								model2.CFrame *= CFrame.new(0, -.24, 0)
							elseif v.name:match("gold") then
								model2.CFrame *= CFrame.new(0, .03, 0)
							elseif v.name:match("diamond") then
								model2.CFrame *= CFrame.new(0, .027, 0)
							elseif v.name:match("emerald") then
								model2.CFrame *= CFrame.new(0, .001, 0)
							elseif v.name:match("telepearl") then
								model2.CFrame *= CFrame.new(.1, 0, .1)
							elseif v.name:match("fireball") then
								model2.CFrame *= CFrame.new(.28, .1, 0)
							elseif v.name:match("bow") and not v.name:match("crossbow") then
								model2.CFrame *= CFrame.new(-.29, .1, -.2)
							elseif v.name:match("wood_crossbow") and not v.name:match("tactical_crossbow") then
								model2.CFrame *= CFrame.new(-.6, 0, 0)
							elseif v.name:match("tactical_crossbow") and not v.name:match("wood_crossbow") then
								model2.CFrame *= CFrame.new(-.5, 0, -1.2)
							else
								model2.CFrame *= CFrame.new(.2, 0, -.2)
							end
							model2.Parent = tool2
							local weld2 = Instance.new("WeldConstraint", model)
							weld2.Part0 = model2
							weld2.Part1 = tool2:WaitForChild("Handle")
						end
					end
				end          
			end)
        end,
		DemonSlayerPack = function() 
			task.spawn(function()
				local Players = game:GetService("Players")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local Workspace = game:GetService("Workspace")
				local objs = game:GetObjects("rbxassetid://14241215869")
				local import = objs[1]
				import.Parent = ReplicatedStorage
				local index = {
					{
						name = "wood_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Wood_Sword"),
					},	
					{
						name = "stone_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Stone_Sword"),
					},
					{
						name = "iron_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Iron_Sword"),
					},
					{
						name = "diamond_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Diamond_Sword"),
					},
					{
						name = "emerald_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Emerald_Sword"),
					},
					{
						name = "wood_pickaxe",
						offset = CFrame.Angles(math.rad(0), math.rad(-180), math.rad(-95)),
						model = import:WaitForChild("Wood_Pickaxe"),
					},
					{
						name = "stone_pickaxe",
						offset = CFrame.Angles(math.rad(0), math.rad(-180), math.rad(-95)),
						model = import:WaitForChild("Stone_Pickaxe"),
					},
					{
						name = "iron_pickaxe",
						offset = CFrame.Angles(math.rad(0), math.rad(-180), math.rad(-95)),
						model = import:WaitForChild("Iron_Pickaxe"),
					},
					{
						name = "diamond_pickaxe",
						offset = CFrame.Angles(math.rad(0), math.rad(90), math.rad(-95)),
						model = import:WaitForChild("Diamond_Pickaxe"),
					},	
					{
						name = "fireball",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Fireball"),
					},	
					{
						name = "telepearl",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Telepearl"),
					},
					{
						name = "diamond",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(-90)),
						model = import:WaitForChild("Diamond"),
					},
					{
						name = "iron",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Iron"),
					},
					{
						name = "gold",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Gold"),
					},
					{
						name = "emerald",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(-90)),
						model = import:WaitForChild("Emerald"),
					},
					{
						name = "wood_bow",
						offset = CFrame.Angles(math.rad(0), math.rad(0), math.rad(90)),
						model = import:WaitForChild("Bow"),
					},
					{
						name = "wood_crossbow",
						offset = CFrame.Angles(math.rad(0), math.rad(0), math.rad(90)),
						model = import:WaitForChild("Bow"),
					},
					{
						name = "tactical_crossbow",
						offset = CFrame.Angles(math.rad(0), math.rad(180), math.rad(-90)),
						model = import:WaitForChild("Bow"),
					},
					{
						name = "wood_dao",
						offset = CFrame.Angles(math.rad(0), math.rad(89), math.rad(-90)),
						model = import:WaitForChild("Wood_Sword"),
					},
					{
						name = "stone_dao",
						offset = CFrame.Angles(math.rad(0), math.rad(89), math.rad(-90)),
						model = import:WaitForChild("Stone_Sword"),
					},
					{
						name = "iron_dao",
						offset = CFrame.Angles(math.rad(0), math.rad(89), math.rad(-90)),
						model = import:WaitForChild("Iron_Sword"),
					},
					{
						name = "diamond_dao",
						offset = CFrame.Angles(math.rad(0), math.rad(89), math.rad(-90)),
						model = import:WaitForChild("Diamond_Sword"),
					},
				}
				toolFunction = function(tool)	
					if not tool:IsA("Accessory") then return end	
					for _, v in ipairs(index) do	
						if v.name == tool.Name then		
							for _, part in ipairs(tool:GetDescendants()) do
								if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then				
									part.Transparency = 1
								end			
							end		
							local model = v.model:Clone()
							model.CFrame = tool:WaitForChild("Handle").CFrame * v.offset
							model.CFrame *= CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0))
							model.Parent = tool			
							local weld = Instance.new("WeldConstraint", model)
							weld.Part0 = model
							weld.Part1 = tool:WaitForChild("Handle")			
							local tool2 = Players.LocalPlayer.Character:WaitForChild(tool.Name)			
							for _, part in ipairs(tool2:GetDescendants()) do
								if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then				
									part.Transparency = 1				
								end			
							end			
							local model2 = v.model:Clone()
							model2.Anchored = false
							model2.CFrame = tool2:WaitForChild("Handle").CFrame * v.offset
							model2.CFrame *= CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0))
							if v.name:match("rageblade") then
								model2.CFrame *= CFrame.new(0.7, 0, -.7)                           
							elseif v.name:match("sword") or v.name:match("blade") then
								model2.CFrame *= CFrame.new(.2, 0, -.8)
							elseif v.name:match("dao") then
								model2.CFrame *= CFrame.new(.7, 0, -1.3)
							elseif v.name:match("axe") and not v.name:match("pickaxe") and v.name:match("diamond") then
								model2.CFrame *= CFrame.new(.08, 0, -1.1) - Vector3.new(0, 0, -1.1)
							elseif v.name:match("axe") and not v.name:match("pickaxe") and not v.name:match("diamond") then
								model2.CFrame *= CFrame.new(-.2, 0, -2.4) + Vector3.new(0, 0, 2.12)
							elseif v.name:match("diamond_pickaxe") then
								model2.CFrame *= CFrame.new(.2, 0, -.26)
							elseif v.name:match("iron") and not v.name:match("iron_pickaxe") then
								model2.CFrame *= CFrame.new(0, -.24, 0)
							elseif v.name:match("gold") then
								model2.CFrame *= CFrame.new(0, .03, 0)
							elseif v.name:match("diamond") or v.name:match("emerald") then
								model2.CFrame *= CFrame.new(0, -.03, 0)
							elseif v.name:match("telepearl") then
								model2.CFrame *= CFrame.new(.1, 0, .1)
							elseif v.name:match("fireball") then
								model2.CFrame *= CFrame.new(.28, .1, 0)
							elseif v.name:match("bow") and not v.name:match("crossbow") then
								model2.CFrame *= CFrame.new(-.2, .1, -.05)
							elseif v.name:match("wood_crossbow") and not v.name:match("tactical_crossbow") then
								model2.CFrame *= CFrame.new(-.5, 0, .05)
							elseif v.name:match("tactical_crossbow") and not v.name:match("wood_crossbow") then
								model2.CFrame *= CFrame.new(-.35, 0, -1.2)
							else
								model2.CFrame *= CFrame.new(.0, 0, -.06)
							end
							model2.Parent = tool2
							local weld2 = Instance.new("WeldConstraint", model)
							weld2.Part0 = model2
							weld2.Part1 = tool2:WaitForChild("Handle")
						end
					end
				end
			end)
		end,
        FirstHighResPack = function() 
            task.spawn(function()
				local Players = game:GetService("Players")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local Workspace = game:GetService("Workspace")
				local objs = game:GetObjects("rbxassetid://14224565815")
				local import = objs[1]
				import.Parent = ReplicatedStorage
				local index = {
					{
						name = "wood_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Wood_Sword"),
					},
					{
						name = "stone_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Stone_Sword"),
					},
					{
						name = "iron_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Iron_Sword"),
					},
					{
						name = "diamond_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Diamond_Sword"),
					},
					{
						name = "emerald_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Emerald_Sword"),
					},
          			{
                        name = "rageblade",
                        offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(90)),
                        model = import:WaitForChild("Rageblade"),
          			},
					{
						name = "wood_pickaxe",
						offset = CFrame.Angles(math.rad(0), math.rad(-180), math.rad(-95)),
						model = import:WaitForChild("Wood_Pickaxe"),
					},
					{
						name = "stone_pickaxe",
						offset = CFrame.Angles(math.rad(0), math.rad(-180), math.rad(-95)),
						model = import:WaitForChild("Stone_Pickaxe"),
					},
					{
						name = "iron_pickaxe",
						offset = CFrame.Angles(math.rad(0), math.rad(-180), math.rad(-95)),
						model = import:WaitForChild("Iron_Pickaxe"),
					},
					{
						name = "diamond_pickaxe",
						offset = CFrame.Angles(math.rad(0), math.rad(90), math.rad(-95)),
						model = import:WaitForChild("Diamond_Pickaxe"),
					},
					{
						name = "wood_axe",
						offset = CFrame.Angles(math.rad(0), math.rad(-10), math.rad(-95)),
						model = import:WaitForChild("Wood_Axe"),
					},
					{
						name = "stone_axe",
						offset = CFrame.Angles(math.rad(0), math.rad(-10), math.rad(-95)),
						model = import:WaitForChild("Stone_Axe"),
					},
					{
						name = "iron_axe",
						offset = CFrame.Angles(math.rad(0), math.rad(-10), math.rad(-95)),
						model = import:WaitForChild("Iron_Axe"),
					},
					{
						name = "diamond_axe",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-95)),
						model = import:WaitForChild("Diamond_Axe"),
					},
					{
						name = "fireball",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Fireball"),
					},
					{
						name = "telepearl",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Telepearl"),
					},
					{
						name = "diamond",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(-90)),
						model = import:WaitForChild("Diamond"),
					},
					{
						name = "iron",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Iron"),
					},
					{
						name = "gold",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Gold"),
					},
					{
						name = "emerald",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(-90)),
						model = import:WaitForChild("Emerald"),
					},
					{
						name = "wood_bow",
						offset = CFrame.Angles(math.rad(0), math.rad(0), math.rad(90)),
						model = import:WaitForChild("Bow"),
					},
					{
						name = "wood_crossbow",
						offset = CFrame.Angles(math.rad(0), math.rad(0), math.rad(90)),
						model = import:WaitForChild("Bow"),
					},
					{
						name = "tactical_crossbow",
						offset = CFrame.Angles(math.rad(0), math.rad(180), math.rad(-90)),
						model = import:WaitForChild("Bow"),
					},
				}
				toolFunction = function(tool)
					if not tool:IsA("Accessory") then return end
					for _, v in ipairs(index) do
						if v.name == tool.Name then
							for _, part in ipairs(tool:GetDescendants()) do
								if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then
									part.Transparency = 1
								end
							end
							local model = v.model:Clone()
							model.CFrame = tool:WaitForChild("Handle").CFrame * v.offset
							model.CFrame *= CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0))
							model.Parent = tool
							local weld = Instance.new("WeldConstraint", model)
							weld.Part0 = model
							weld.Part1 = tool:WaitForChild("Handle")
							local tool2 = Players.LocalPlayer.Character:WaitForChild(tool.Name)
							for _, part in ipairs(tool2:GetDescendants()) do
								if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then
									part.Transparency = 1
								end
							end
							local model2 = v.model:Clone()
							model2.Anchored = false
							model2.CFrame = tool2:WaitForChild("Handle").CFrame * v.offset
							model2.CFrame *= CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0))
							if v.name:match("rageblade") then
								model2.CFrame *= CFrame.new(0.7, 0, -1)
							elseif v.name:match("sword") or v.name:match("blade") then
								model2.CFrame *= CFrame.new(.6, 0, -1.1) - Vector3.new(0, 0, -.3)
							elseif v.name:match("axe") and not v.name:match("pickaxe") and v.name:match("diamond") then
								model2.CFrame *= CFrame.new(.08, 0, -1.1) - Vector3.new(0, 0, -1.1)
							elseif v.name:match("axe") and not v.name:match("pickaxe") and not v.name:match("diamond") then
								model2.CFrame *= CFrame.new(-.2, 0, -2.4) + Vector3.new(0, 0, 2.12)
							elseif v.name:match("diamond_pickaxe") then
								model2.CFrame *= CFrame.new(.2, 0, -.26)
							elseif v.name:match("iron") and not v.name:match("iron_pickaxe") then
								model2.CFrame *= CFrame.new(0, -.24, 0)
							elseif v.name:match("gold") then
								model2.CFrame *= CFrame.new(0, .03, 0)
							elseif v.name:match("diamond") or v.name:match("emerald") then
								model2.CFrame *= CFrame.new(0, -.03, 0)
							elseif v.name:match("telepearl") then
								model2.CFrame *= CFrame.new(.1, 0, .1)
							elseif v.name:match("fireball") then
								model2.CFrame *= CFrame.new(.28, .1, 0)
							elseif v.name:match("bow") and not v.name:match("crossbow") then
								model2.CFrame *= CFrame.new(-.2, .1, -.05)
							elseif v.name:match("wood_crossbow") and not v.name:match("tactical_crossbow") then
								model2.CFrame *= CFrame.new(-.5, 0, .05)
							elseif v.name:match("tactical_crossbow") and not v.name:match("wood_crossbow") then
								model2.CFrame *= CFrame.new(-.35, 0, -1.2)
							else
								model2.CFrame *= CFrame.new(.2, 0, -.24)
							end
							model2.Parent = tool2
							local weld2 = Instance.new("WeldConstraint", model)
							weld2.Part0 = model2
							weld2.Part1 = tool2:WaitForChild("Handle")
						end
					end
				end
           end)
		end,
        RandomPack = function() 
            task.spawn(function()  
				local Players = game:GetService("Players")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local Workspace = game:GetService("Workspace")
				local objs = game:GetObjects("rbxassetid://14282106674")
				local import = objs[1]
				import.Parent = game:GetService("ReplicatedStorage")
				index = {
					{
						name = "wood_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-89),math.rad(-90)),
						model = import:WaitForChild("Wood_Sword"),
					},
					{
						name = "stone_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-89),math.rad(-90)),
						model = import:WaitForChild("Stone_Sword"),
					},
					{
						name = "iron_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-89),math.rad(-90)),
						model = import:WaitForChild("Iron_Sword"),
					},
					{
						name = "diamond_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-89),math.rad(-90)),
						model = import:WaitForChild("Diamond_Sword"),
					},
					{
						name = "emerald_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-89),math.rad(-90)),
						model = import:WaitForChild("Emerald_Sword"),
					},
				}
				toolFunction = function(tool)
					if(not tool:IsA("Accessory")) then return end
					for i,v in pairs(index) do
						if(v.name == tool.Name) then
							for i,v in pairs(tool:GetDescendants()) do
								if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
									v.Transparency = 1
								end
							end
							local model = v.model:Clone()
							model.CFrame = tool:WaitForChild("Handle").CFrame * v.offset
							model.CFrame *= CFrame.Angles(math.rad(0),math.rad(-50),math.rad(0))
							model.Parent = tool
							local weld = Instance.new("WeldConstraint",model)
							weld.Part0 = model
							weld.Part1 = tool:WaitForChild("Handle")
							local tool2 = Players.LocalPlayer.Character:WaitForChild(tool.Name)
							for i,v in pairs(tool2:GetDescendants()) do
								if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
									v.Transparency = 1
								end            
							end            
							local model2 = v.model:Clone()
							model2.Anchored = false
							model2.CFrame = tool2:WaitForChild("Handle").CFrame * v.offset
							model2.CFrame *= CFrame.Angles(math.rad(0),math.rad(-50),math.rad(0))
							model2.CFrame *= CFrame.new(0.6,0,-.9)
							model2.Parent = tool2
							local weld2 = Instance.new("WeldConstraint",model)
							weld2.Part0 = model2
							weld2.Part1 = tool2:WaitForChild("Handle")
						end
					end
				end  
           end)
		end,
		SecondHighResPack = function() 
            task.spawn(function()
				local Players = game:GetService("Players")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local Workspace = game:GetService("Workspace")
				local objs = game:GetObjects("rbxassetid://14078540433")
				local import = objs[1]
				import.Parent = game:GetService("ReplicatedStorage")
				index = {
					{
						name = "wood_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
						model = import:WaitForChild("Wood_Sword"),
					},
					{
						name = "stone_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
						model = import:WaitForChild("Stone_Sword"),
					},
					{
						name = "iron_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
						model = import:WaitForChild("Iron_Sword"),
					},
					{
						name = "diamond_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
						model = import:WaitForChild("Diamond_Sword"),
					},
					{
						name = "emerald_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
						model = import:WaitForChild("Emerald_Sword"),
					},
					{
						name = "rageblade",
						offset = CFrame.Angles(math.rad(0),math.rad(-90),math.rad(90)),
						model = import:WaitForChild("Rageblade"),
					}, 
				}
				toolFunction = function(tool)
					if(not tool:IsA("Accessory")) then return end
					for i,v in pairs(index) do
						if(v.name == tool.Name) then
							for i,v in pairs(tool:GetDescendants()) do
								if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
									v.Transparency = 1
								end
							end
							local model = v.model:Clone()
							model.CFrame = tool:WaitForChild("Handle").CFrame * v.offset
							model.CFrame *= CFrame.Angles(math.rad(0),math.rad(-50),math.rad(0))
							model.Parent = tool
							local weld = Instance.new("WeldConstraint",model)
							weld.Part0 = model
							weld.Part1 = tool:WaitForChild("Handle")
							local tool2 = Players.LocalPlayer.Character:WaitForChild(tool.Name)
							for i,v in pairs(tool2:GetDescendants()) do
								if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
									v.Transparency = 1
								end
							end
							local model2 = v.model:Clone()
							model2.Anchored = false
							model2.CFrame = tool2:WaitForChild("Handle").CFrame * v.offset
							model2.CFrame *= CFrame.Angles(math.rad(0),math.rad(-50),math.rad(0))
							model2.CFrame *= CFrame.new(.5,0,-.8)
							model2.Parent = tool2
							local weld2 = Instance.new("WeldConstraint",model)
							weld2.Part0 = model2
							weld2.Part1 = tool2:WaitForChild("Handle")
						end
					end
				end
           end)
		end
	}

	if (not TexturePacks.Enabled) then toolFunction = function() end end

	local function refresh()
		pcall(function() con:Disconnect() end)
		con = game:GetService("Workspace"):WaitForChild("Camera").Viewmodel.ChildAdded:Connect(toolFunction)
		for i,v in pairs(game:GetService("Workspace"):WaitForChild("Camera").Viewmodel:GetChildren()) do toolFunction(v) end
	end

	TexturePacks = vape.Categories.Render:CreateModule({
		["Name"] = "TexturePacksV3",
		["Function"] = function(callback) 
			if callback then 
				packfunctions[packselected["Value"]]()
				refresh()
            else 
				toolFunction = function() end
				refresh()
		end
	end
	})
	local list = {}
	for i,v in pairs(packfunctions) do table.insert(list, tostring(i)) end
	packselected = TexturePacks:CreateDropdown({
		["Name"] = "Pack",
		["Function"] = function() if TexturePacks.Enabled then packfunctions[packselected["Value"]](); refresh() end end,
		["List"] = list
	})
end)

--[[run(function()
	local AutoUpgradeEra = {}

	local function invokePurchaseEra(eras)
		for _, era in ipairs(eras) do
			local args = {
				[1] = {
					["era"] = era
				}
			}
			game:GetService("ReplicatedStorage")
				:WaitForChild("rbxts_include")
				:WaitForChild("node_modules")
				:WaitForChild("@rbxts")
				:WaitForChild("net")
				:WaitForChild("out")
				:WaitForChild("_NetManaged")
				:WaitForChild("RequestPurchaseEra")
				:InvokeServer(unpack(args))
			task.wait(0.1) 
		end
	end
	
	local function invokePurchaseUpgrade(upgrades)
		for _, upgrade in ipairs(upgrades) do
			local args = {
				[1] = {
					["upgrade"] = upgrade
				}
			}
			game:GetService("ReplicatedStorage")
				:WaitForChild("rbxts_include")
				:WaitForChild("node_modules")
				:FindFirstChild("@rbxts")
				:WaitForChild("net")
				:WaitForChild("out")
				:WaitForChild("_NetManaged")
				:WaitForChild("RequestPurchaseTeamUpgrade")
				:InvokeServer(unpack(args))
			task.wait(0.1) 
		end
	end

	AutoUpgradeEra = vape.Categories.Blatant:CreateModule({
		Name = 'AutoUpgradeEra',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					repeat 
						task.wait()
						invokePurchaseEra({"iron_era", "diamond_era", "emerald_era"})
						invokePurchaseUpgrade({"altar_i", "bed_defense_i", "destruction_i", "magic_i", "altar_ii", "destruction_ii", "magic_ii", "altar_iii"})
					until not AutoUpgradeEra.Enabled
				end)
			end
		end
	})
end)--]]

run(function()
    local AdetundeRemote
	local function upgrade(args)
		if not AdetundeRemote then
			AdetundeRemote = game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("UpgradeFrostyHammer")
		end
		return AdetundeRemote:InvokeServer(unpack(args))
	end
    local AdetundeExploit = {}
    local AdetundeExploit_List = { Value = "Shield" }

    local adetunde_remotes = {
        ["Shield"] = function()
            local args = { [1] = "shield" }
            local returning = upgrade(args)
            return returning
        end,

        ["Speed"] = function()
            local args = { [1] = "speed" }
            local returning = upgrade(args)
            return returning
        end,

        ["Strength"] = function()
            local args = { [1] = "strength" }
            local returning = upgrade(args)
            return returning
        end
    }

    local current_upgrador = "Shield"
    local hasnt_upgraded_everything = true
    local testing = 1

	local function getItem(itemName, inv)
		store.localInventory = store.localInventory or store.inventory
		for slot, item in (inv or store.localInventory.inventory.items) do
			if item.itemType == itemName then
				return item, slot
			end
		end
		return nil
	end

    AdetundeExploit = vape.Categories.Blatant:CreateModule({
        Name = 'AdetundeExploit',
        Function = function(calling)
            if calling then 
                --[[task.spawn(function()
					repeat task.wait() until store.equippedKit ~= ""
					if store.equippedKit ~= "adetunde" then
						warningNotification("AdetundeExploit", "Adetunde kit required!", 3)
						if AdetundeExploit.Enabled then
							AdetundeExploit:Toggle()
						end
					end
				end)--]]
                task.spawn(function()
                    repeat
						if not getItem("frosty_hammer") then return end
                        local returning_table = adetunde_remotes[current_upgrador]()
                        
                        if type(returning_table) == "table" then
                            local Speed = returning_table["speed"]
                            local Strength = returning_table["strength"]
                            local Shield = returning_table["shield"]

                            print("Speed: " .. tostring(Speed))
                            print("Strength: " .. tostring(Strength))
                            print("Shield: " .. tostring(Shield))
                            print("Current Upgrador: " .. tostring(current_upgrador))

                            if returning_table[string.lower(current_upgrador)] == 3 then
                                if Strength and Shield and Speed then
                                    if Strength == 3 or Speed == 3 or Shield == 3 then
                                        if (Strength == 3 and Speed == 2 and Shield == 2) or
                                           (Strength == 2 and Speed == 3 and Shield == 2) or
                                           (Strength == 2 and Speed == 2 and Shield == 3) then
                                            warningNotification("AdetundeExploit", "Fully upgraded everything possible!", 7)
                                            hasnt_upgraded_everything = false
                                        else
                                            local things = {}
                                            for i, v in pairs(adetunde_remotes) do
                                                table.insert(things, i)
                                            end
                                            for i, v in pairs(things) do
                                                if things[i] == current_upgrador then
                                                    table.remove(things, i)
                                                end
                                            end
                                            local random = things[math.random(1, #things)]
                                            current_upgrador = random
                                        end
                                    end
                                end
                            end
                        else
                            local things = {}
                            for i, v in pairs(adetunde_remotes) do
                                table.insert(things, i)
                            end
                            for i, v in pairs(things) do
                                if things[i] == current_upgrador then
                                    table.remove(things, i)
                                end
                            end
                            local random = things[math.random(1, #things)]
                            current_upgrador = random
                        end
                        task.wait(0.1)
                    until not AdetundeExploit.Enabled or not hasnt_upgraded_everything
                end)
            end
        end
    })

    local real_list = {}
    for i, v in pairs(adetunde_remotes) do
        table.insert(real_list, i)
    end

    AdetundeExploit_List = AdetundeExploit:CreateDropdown({
        Name = 'Preferred Upgrade',
        List = real_list,
        Function = function() end,
        Default = "Shield"
    })
end)

run(function()
	function IsAlive(plr)
		plr = plr or lplr
		if not plr.Character then return false end
		if not plr.Character:FindFirstChild("Head") then return false end
		if not plr.Character:FindFirstChild("Humanoid") then return false end
		if plr.Character:FindFirstChild("Humanoid").Health < 0.11 then return false end
		return true
	end
	local Slowmode = {Value = 2}
	GodMode = vape.Categories.Blatant:CreateModule({
		Name = "AntiHit/Godmode",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat task.wait()
						local res, msg = pcall(function()
							if (not vape.Modules.Fly.Enabled) and (not vape.Modules.InfiniteFly.Enabled) then
								for i, v in pairs(game:GetService("Players"):GetChildren()) do
									if v.Team ~= lplr.Team and IsAlive(v) and IsAlive(lplr) then
										if v and v ~= lplr then
											local TargetDistance = lplr:DistanceFromCharacter(v.Character:FindFirstChild("HumanoidRootPart").CFrame.p)
											if TargetDistance < 25 then
												if not lplr.Character:WaitForChild("HumanoidRootPart"):FindFirstChildOfClass("BodyVelocity") then
													repeat task.wait() until shared.GlobalStore.matchState ~= 0
													if not (v.Character.HumanoidRootPart.Velocity.Y < -10*5) then
														lplr.Character.Archivable = true
				
														local Clone = lplr.Character:Clone()
														Clone.Parent = game.Workspace
														Clone.Head:ClearAllChildren()
														gameCamera.CameraSubject = Clone:FindFirstChild("Humanoid")
					
														for i,v in pairs(Clone:GetChildren()) do
															if string.lower(v.ClassName):find("part") and v.Name ~= "HumanoidRootPart" then
																v.Transparency = 1
															end
															if v:IsA("Accessory") then
																v:FindFirstChild("Handle").Transparency = 1
															end
														end
					
														lplr.Character:WaitForChild("HumanoidRootPart").CFrame = lplr.Character:WaitForChild("HumanoidRootPart").CFrame + Vector3.new(0,100,0)
					
														GodMode:Clean(game:GetService("RunService").RenderStepped:Connect(function()
															if Clone ~= nil and Clone:FindFirstChild("HumanoidRootPart") then
																Clone.HumanoidRootPart.Position = Vector3.new(lplr.Character:WaitForChild("HumanoidRootPart").Position.X, Clone.HumanoidRootPart.Position.Y, lplr.Character:WaitForChild("HumanoidRootPart").Position.Z)
															end
														end))
					
														task.wait(Slowmode.Value/10)
														lplr.Character:WaitForChild("HumanoidRootPart").Velocity = Vector3.new(lplr.Character:WaitForChild("HumanoidRootPart").Velocity.X, -1, lplr.Character:WaitForChild("HumanoidRootPart").Velocity.Z)
														lplr.Character:WaitForChild("HumanoidRootPart").CFrame = Clone.HumanoidRootPart.CFrame
														gameCamera.CameraSubject = lplr.Character:FindFirstChild("Humanoid")
														Clone:Destroy()
														task.wait(0.15)
													end
												end
											end
										end
									end
								end
							end
						end)
						if not res then warn(msg) end
					until (not GodMode.Enabled)
				end)
			end
		end
	})
	Slowmode = GodMode:CreateSlider({
		Name = "Slowmode",
		Function = function() end,
		Default = 2,
		Min = 1,
		Max = 25
	})
end)

run(function()
	local AntiHit = {}
	local physEngine = game:GetService("RunService")
	local worldSpace = game.Workspace
	local camView = worldSpace.CurrentCamera
	local plyr = lplr
	local entSys = entitylib
	local queryutil = {}
	function queryutil:setQueryIgnored(part, index)
		if index == nil then index = true end
		if part then part:SetAttribute("gamecore_GameQueryIgnore", index) end
	end
	local utilPack = {QueryUtil = queryutil}

	local dupeNode, altHeight, initOk, sysOk = nil, nil, false, true
	shared.anchorBase = nil
	shared.evadeFlag = false

	local trigSet = {p = true, n = false, w = false}
	local shiftMode = "Up"
	local scanRad = 30

	local function genTwin()
		if entSys.isAlive and entSys.character.Humanoid.Health > 0 and entSys.character.HumanoidRootPart then
			altHeight = entSys.character.Humanoid.HipHeight
			shared.anchorBase = entSys.character.HumanoidRootPart
			utilPack.QueryUtil:setQueryIgnored(shared.anchorBase, true)
			if not plyr.Character or not plyr.Character.Parent then return false end

			plyr.Character.Parent = game
			dupeNode = shared.anchorBase:Clone()
			dupeNode.Parent = plyr.Character
			shared.anchorBase.Parent = camView
			dupeNode.CFrame = shared.anchorBase.CFrame

			plyr.Character.PrimaryPart = dupeNode
			entSys.character.HumanoidRootPart = dupeNode
			entSys.character.RootPart = dupeNode
			plyr.Character.Parent = worldSpace

			for _, x in plyr.Character:GetDescendants() do
				if x:IsA('Weld') or x:IsA('Motor6D') then
					if x.Part0 == shared.anchorBase then x.Part0 = dupeNode end
					if x.Part1 == shared.anchorBase then x.Part1 = dupeNode end
				end
			end
			return true
		end
		return false
	end

	local function resetCore()
		if not entSys.isAlive or not shared.anchorBase or not shared.anchorBase:IsDescendantOf(game) then
			shared.anchorBase = nil
			dupeNode = nil
			return false
		end

		if not plyr.Character or not plyr.Character.Parent then return false end

		plyr.Character.Parent = game

		shared.anchorBase.Parent = plyr.Character
		shared.anchorBase.CanCollide = true
		shared.anchorBase.Velocity = Vector3.zero 
		shared.anchorBase.Anchored = false 

		plyr.Character.PrimaryPart = shared.anchorBase
		entSys.character.HumanoidRootPart = shared.anchorBase
		entSys.character.RootPart = shared.anchorBase

		for _, x in plyr.Character:GetDescendants() do
			if x:IsA('Weld') or x:IsA('Motor6D') then
				if x.Part0 == dupeNode then x.Part0 = shared.anchorBase end
				if x.Part1 == dupeNode then x.Part1 = shared.anchorBase end
			end
		end

		local prevLoc = dupeNode and dupeNode.CFrame or shared.anchorBase.CFrame
		if dupeNode then
			dupeNode:Destroy()
			dupeNode = nil
		end

		plyr.Character.Parent = worldSpace
		shared.anchorBase.CFrame = prevLoc

		if entSys.character.Humanoid then
			entSys.character.Humanoid.HipHeight = altHeight or 2
		end

		shared.anchorBase = nil
		shared.evadeFlag = false
		altHeight = nil

		return true
	end

	local function shiftPos()
		if not entSys.isAlive or not shared.anchorBase or not AntiHit.on then return end

		local hits = entSys.AllPosition({
			Range = scanRad,
			Wallcheck = trigSet.w or nil,
			Part = 'RootPart',
			Players = trigSet.p,
			NPCs = trigSet.n,
			Limit = 1
		})

		if #hits > 0 and not shared.evadeFlag then
			local base = entSys.character.RootPart
			if base then
				shared.evadeFlag = true
				local targetY = shiftMode == "Up" and 150 or 0
				shared.anchorBase.CFrame = CFrame.new(base.CFrame.X, targetY, base.CFrame.Z)
				task.wait(0.15)
				shared.anchorBase.CFrame = base.CFrame
				task.wait(0.05)
				shared.evadeFlag = false
			end
		end
	end

	function AntiHit:engage()
		if self.on then return end
		self.on = true

		initOk = genTwin()
		if not initOk then
			self:disengage()
			return
		end

		self.physHook = physEngine.PreSimulation:Connect(function(dt)
			if entSys.isAlive and shared.anchorBase and entSys.character.RootPart then
				local currBase = entSys.character.RootPart
				local currPos = currBase.CFrame

				if not isnetworkowner(shared.anchorBase) then
					currBase.CFrame = shared.anchorBase.CFrame
					currBase.Velocity = shared.anchorBase.Velocity
					return
				end
				if not shared.evadeFlag then
					shared.anchorBase.CFrame = currPos
				end
				shared.anchorBase.Velocity = Vector3.zero
				shared.anchorBase.CanCollide = false
				shiftPos()
			else
				self:disengage() 
			end
		end)

		self.respawnHook = entSys.Events.LocalAdded:Connect(function(_)
			if self.on then
				self:disengage() 
				task.wait(0.1) 
				self:engage() 
			end
		end)
	end

	local Antihit_core = {Enabled = false}

	function AntiHit:disengage()
		self.on = false
		local success, err = pcall(resetCore)
		if not success then
			warn("AntiHit resetCore failed: " .. tostring(err))
		end
		if self.physHook then
			self.physHook:Disconnect()
			self.physHook = nil
		end
		if self.respawnHook then
			self.respawnHook:Disconnect()
			self.respawnHook = nil
		end
	end

	Antihit_core = vape.Categories.Blatant:CreateModule({
		Name = "AntiHit V2",
		Function = function(active)
			if active then
				warningNotification("Antihit V2", "Warning: this is still experimental!", 3)
			end
			task.spawn(function()
				repeat task.wait() until store.matchState > 0 or not Antihit_core.Enabled
				if not Antihit_core.Enabled then return end
				if active then
					AntiHit:engage()
				else
					AntiHit:disengage()
				end
			end)
		end,
		Tooltip = "Dodges attacks."
	})

	Antihit_core:CreateTargets({
		Players = true,
		NPCs = false
	})
	Antihit_core:CreateDropdown({
		Name = "Shift Type",
		List = {"Up", "Down"},
		Value = "Up",
		Function = function(opt) shiftMode = opt end
	})
	Antihit_core:CreateSlider({
		Name = "Scan Perimeter",
		Min = 1,
		Max = 30,
		Default = 30,
		Suffix = function(v) return v == 1 and "span" or "spans" end,
		Function = function(v) scanRad = v end
	})
end)

task.spawn(function()
    local tweenmodules = {"BedTP", "EmeraldTP", "DiamondTP", "MiddleTP", "Autowin", "PlayerTP"}
    local tweening = false
    repeat
    for i,v in pairs(tweenmodules) do
        pcall(function()
        if vape.Modules[v].Enabled then
            tweening = true
        end
        end)
    end
    VoidwareStore.Tweening = tweening
    tweening = false
    task.wait()
  until not vapeInjected
end)
local vapeAssert = function(argument, title, text, duration, hault, moduledisable, module) 
	if not argument then
    local suc, res = pcall(function()
    local notification = GuiLibrary.CreateNotification(title or "Voidware", text or "Failed to call function.", duration or 20, "assets/WarningNotification.png")
    notification.IconLabel.ImageColor3 = Color3.new(220, 0, 0)
    notification.Frame.Frame.ImageColor3 = Color3.new(220, 0, 0)
    if moduledisable and (module and vape.Modules[module].Enabled) then vape.Modules[module]:Toggle(false) end
    end)
    if hault then while true do task.wait() end end end
end
local function GetMagnitudeOf2Objects(part, part2, bypass)
	local magnitude, partcount = 0, 0
	if not bypass then 
		local suc, res = pcall(function() return part.Position end)
		partcount = suc and partcount + 1 or partcount
		suc, res = pcall(function() return part2.Position end)
		partcount = suc and partcount + 1 or partcount
	end
	if partcount > 1 or bypass then 
		magnitude = bypass and (part - part2).magnitude or (part.Position - part2.Position).magnitude
	end
	return magnitude
end
local function GetTopBlock(position, smart, raycast, customvector)
	position = position or isAlive(lplr, true) and lplr.Character:WaitForChild("HumanoidRootPart").Position
	if not position then 
		return nil 
	end
	if raycast and not game.Workspace:Raycast(position, Vector3.new(0, -2000, 0), store.blockRaycast) then
	    return nil
    end
	local lastblock = nil
	for i = 1, 500 do 
		local newray = game.Workspace:Raycast(lastblock and lastblock.Position or position, customvector or Vector3.new(0.55, 999999, 0.55), store.blockRaycast)
		local smartest = newray and smart and game.Workspace:Raycast(lastblock and lastblock.Position or position, Vector3.new(0, 5.5, 0), store.blockRaycast) or not smart
		if newray and smartest then
			lastblock = newray
		else
			break
		end
	end
	return lastblock
end
local function FindEnemyBed(maxdistance, highest)
	local target = nil
	local distance = maxdistance or math.huge
	local whitelistuserteams = {}
	local badbeds = {}
	if not lplr:GetAttribute("Team") then return nil end
	for i,v in pairs(playersService:GetPlayers()) do
		if v ~= lplr then
			local type, attackable = shared.vapewhitelist:get(v)
			if not attackable then
				whitelistuserteams[v:GetAttribute("Team")] = true
			end
		end
	end
	for i,v in pairs(collectionService:GetTagged("bed")) do
			local bedteamstring = string.split(v:GetAttribute("id"), "_")[1]
			if whitelistuserteams[bedteamstring] ~= nil then
			   badbeds[v] = true
		    end
	    end
	for i,v in pairs(collectionService:GetTagged("bed")) do
		if v:GetAttribute("id") and v:GetAttribute("id") ~= lplr:GetAttribute("Team").."_bed" and badbeds[v] == nil and lplr.Character and lplr.Character.PrimaryPart then
			if v:GetAttribute("NoBreak") or v:GetAttribute("PlacedByUserId") and v:GetAttribute("PlacedByUserId") ~= 0 then continue end
			local magdist = GetMagnitudeOf2Objects(lplr.Character.PrimaryPart, v)
			if magdist < distance then
				target = v
				distance = magdist
			end
		end
	end
	local coveredblock = highest and target and GetTopBlock(target.Position, true)
	if coveredblock then
		target = coveredblock.Instance
	end
	return target
end
local function FindTeamBed()
	local bedstate, res = pcall(function()
		return lplr.leaderstats.Bed.Value
	end)
	return bedstate and res and res ~= nil and res == "✅"
end
local function FindItemDrop(item)
	local itemdist = nil
	local dist = math.huge
	local function abletocalculate() return lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") end
    for i,v in pairs(collectionService:GetTagged("ItemDrop")) do
		if v and v.Name == item and abletocalculate() then
			local itemdistance = GetMagnitudeOf2Objects(lplr.Character:WaitForChild("HumanoidRootPart"), v)
			if itemdistance < dist then
			itemdist = v
			dist = itemdistance
		end
		end
	end
	return itemdist
end
local function FindTarget(dist, blockRaycast, includemobs, healthmethod)
	local whitelist = shared.vapewhitelist
	local sort, entity = healthmethod and math.huge or dist or math.huge, {}
	local function abletocalculate() return lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") end
	local sortmethods = {Normal = function(entityroot, entityhealth) return abletocalculate() and GetMagnitudeOf2Objects(lplr.Character:WaitForChild("HumanoidRootPart"), entityroot) < sort end, Health = function(entityroot, entityhealth) return abletocalculate() and entityhealth < sort end}
	local sortmethod = healthmethod and "Health" or "Normal"
	local function raycasted(entityroot) return abletocalculate() and blockRaycast and game.Workspace:Raycast(entityroot.Position, Vector3.new(0, -2000, 0), store.blockRaycast) or not blockRaycast and true or false end
	for i,v in pairs(playersService:GetPlayers()) do
		if v ~= lplr and abletocalculate() and isAlive(v) and v.Team ~= lplr.Team then
			if not ({whitelist:get(v)})[2] then 
				continue
			end
			if sortmethods[sortmethod](v.Character.HumanoidRootPart, v.Character:GetAttribute("Health") or v.Character.Humanoid.Health) and raycasted(v.Character.HumanoidRootPart) then
				sort = healthmethod and v.Character.Humanoid.Health or GetMagnitudeOf2Objects(lplr.Character:WaitForChild("HumanoidRootPart"), v.Character.HumanoidRootPart)
				entity.Player = v
				entity.Human = true 
				entity.RootPart = v.Character.HumanoidRootPart
				entity.Humanoid = v.Character.Humanoid
			end
		end
	end
	if includemobs then
		local maxdistance = dist or math.huge
		for i,v in pairs(store.pots) do
			if abletocalculate() and v.PrimaryPart and GetMagnitudeOf2Objects(lplr.Character:WaitForChild("HumanoidRootPart"), v.PrimaryPart) < maxdistance then
			entity.Player = {Character = v, Name = "PotEntity", DisplayName = "PotEntity", UserId = 1}
			entity.Human = false
			entity.RootPart = v.PrimaryPart
			entity.Humanoid = {Health = 1, MaxHealth = 1}
			end
		end
		for i,v in pairs(collectionService:GetTagged("DiamondGuardian")) do 
			if v.PrimaryPart and v:FindFirstChild("Humanoid") and v.Humanoid.Health and abletocalculate() then
				if sortmethods[sortmethod](v.PrimaryPart, v.Humanoid.Health) and raycasted(v.PrimaryPart) then
				sort = healthmethod and v.Humanoid.Health or GetMagnitudeOf2Objects(lplr.Character:WaitForChild("HumanoidRootPart"), v.PrimaryPart)
				entity.Player = {Character = v, Name = "DiamondGuardian", DisplayName = "DiamondGuardian", UserId = 1}
				entity.Human = false
				entity.RootPart = v.PrimaryPart
				entity.Humanoid = v.Humanoid
				end
			end
		end
		for i,v in pairs(collectionService:GetTagged("GolemBoss")) do
			if v.PrimaryPart and v:FindFirstChild("Humanoid") and v.Humanoid.Health and abletocalculate() then
				if sortmethods[sortmethod](v.PrimaryPart, v.Humanoid.Health) and raycasted(v.PrimaryPart) then
				sort = healthmethod and v.Humanoid.Health or GetMagnitudeOf2Objects(lplr.Character:WaitForChild("HumanoidRootPart"), v.PrimaryPart)
				entity.Player = {Character = v, Name = "Titan", DisplayName = "Titan", UserId = 1}
				entity.Human = false
				entity.RootPart = v.PrimaryPart
				entity.Humanoid = v.Humanoid
				end
			end
		end
		for i,v in pairs(collectionService:GetTagged("Drone")) do
			local plr = playersService:GetPlayerByUserId(v:GetAttribute("PlayerUserId"))
			if plr and plr ~= lplr and plr.Team and lplr.Team and plr.Team ~= lplr.Team and ({VoidwareFunctions:GetPlayerType(plr)})[2] and abletocalculate() and v.PrimaryPart and v:FindFirstChild("Humanoid") and v.Humanoid.Health then
				if sortmethods[sortmethod](v.PrimaryPart, v.Humanoid.Health) and raycasted(v.PrimaryPart) then
					sort = healthmethod and v.Humanoid.Health or GetMagnitudeOf2Objects(lplr.Character:WaitForChild("HumanoidRootPart"), v.PrimaryPart)
					entity.Player = {Character = v, Name = "Drone", DisplayName = "Drone", UserId = 1}
					entity.Human = false
					entity.RootPart = v.PrimaryPart
					entity.Humanoid = v.Humanoid
				end
			end
		end
		for i,v in pairs(collectionService:GetTagged("Monster")) do
			if v:GetAttribute("Team") ~= lplr:GetAttribute("Team") and abletocalculate() and v.PrimaryPart and v:FindFirstChild("Humanoid") and v.Humanoid.Health then
				if sortmethods[sortmethod](v.PrimaryPart, v.Humanoid.Health) and raycasted(v.PrimaryPart) then
				sort = healthmethod and v.Humanoid.Health or GetMagnitudeOf2Objects(lplr.Character:WaitForChild("HumanoidRootPart"), v.PrimaryPart)
				entity.Player = {Character = v, Name = "Monster", DisplayName = "Monster", UserId = 1}
				entity.Human = false
				entity.RootPart = v.PrimaryPart
				entity.Humanoid = v.Humanoid
			end
		end
	end
    end
    return entity
end
local function isVulnerable(plr) return plr.Humanoid.Health > 0 and not plr.Character.FindFirstChildWhichIsA(plr.Character, "ForceField") end
VoidwareFunctions.GlobaliseObject("isVulnarable", isVulnarable)
local function EntityNearPosition(distance, ignore, overridepos)
	local closestEntity, closestMagnitude = nil, distance
	if entityLibrary.isAlive then
		for i, v in pairs(entityLibrary.entityList) do
			if not v.Targetable then continue end
			if isVulnerable(v) then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.RootPart.Position).magnitude
				if overridepos and mag > distance then
					mag = (overridepos - v.RootPart.Position).magnitude
				end
				if mag <= closestMagnitude then
					closestEntity, closestMagnitude = v, mag
				end
			end
		end
		if not ignore then
			for i, v in pairs(game.Workspace:GetChildren()) do
				if v.Name == "Void Enemy Dummy" or v.Name == "Emerald Enemy Dummy" or v.Name == "Diamond Enemy Dummy" or v.Name == "Leather Enemy Dummy" or v.Name == "Regular Enemy Dummy" or v.Name == "Iron Enemy Dummy" then
					if v.PrimaryPart then
						local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
						if overridepos and mag > distance then
							mag = (overridepos - v2.PrimaryPart.Position).magnitude
						end
						if mag <= closestMagnitude then
							closestEntity, closestMagnitude = {Player = {Name = v.Name, UserId = (v.Name == "Duck" and 2020831224 or 1443379645)}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
						end
					end
				end
			end
			for i, v in pairs(collectionService:GetTagged("Monster")) do
				if v.PrimaryPart and v:GetAttribute("Team") ~= lplr:GetAttribute("Team") then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then
						mag = (overridepos - v2.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = v.Name, UserId = (v.Name == "Duck" and 2020831224 or 1443379645)}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in pairs(collectionService:GetTagged("GuardianOfDream")) do
				if v.PrimaryPart and v:GetAttribute("Team") ~= lplr:GetAttribute("Team") then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then
						mag = (overridepos - v2.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = v.Name, UserId = (v.Name == "Duck" and 2020831224 or 1443379645)}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in pairs(collectionService:GetTagged("DiamondGuardian")) do
				if v.PrimaryPart then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then
						mag = (overridepos - v2.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = "DiamondGuardian", UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in pairs(collectionService:GetTagged("GolemBoss")) do
				if v.PrimaryPart then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then
						mag = (overridepos - v2.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = "GolemBoss", UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in pairs(collectionService:GetTagged("Drone")) do
				if v.PrimaryPart and tonumber(v:GetAttribute("PlayerUserId")) ~= lplr.UserId then
					local droneplr = playersService:GetPlayerByUserId(v:GetAttribute("PlayerUserId"))
					if droneplr and droneplr.Team == lplr.Team then continue end
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then
						mag = (overridepos - v.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then -- magcheck
						closestEntity, closestMagnitude = {Player = {Name = "Drone", UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i,v in pairs(game.Workspace:GetChildren()) do
				if v.Name == "InfectedCrateEntity" and v.ClassName == "Model" and v.PrimaryPart then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then
						mag = (overridepos - v.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then -- magcheck
						closestEntity, closestMagnitude = {Player = {Name = "InfectedCrateEntity", UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in pairs(store.pots) do
				if v.PrimaryPart then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then
						mag = (overridepos - v.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then -- magcheck
						closestEntity, closestMagnitude = {Player = {Name = "Pot", UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
		end
	end
	return closestEntity
end
VoidwareFunctions.GlobaliseObject("EntityNearPosition", EntityNearPosition)

local function oldautowin()
run(function()
	local Autowin = {Enabled = false}
	local AutowinNotification = {Enabled = true}
	local bedtween
	local playertween
	Autowin = vape.Categories.Blatant:CreateModule({
		Name = "Autowin",
		ExtraText = function() return store.queueType:find("5v5") and "BedShield" or "Normal" end,
		Function = function(callback)
			if callback then
				task.spawn(function()
					if store.matchState == 0 then repeat task.wait() until store.matchState ~= 0 or not Autowin.Enabled end
					if not shared.VapeFullyLoaded then repeat task.wait() until shared.VapeFullyLoaded or not Autowin.Enabled end
					if not Autowin.Enabled then return end
					vapeAssert(not store.queueType:find("skywars"), "Autowin", "Skywars not supported.", 7, true, true, "Autowin")
					if isAlive(lplr, true) then
						lplr.Character:WaitForChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
						lplr.Character:WaitForChild("Humanoid"):TakeDamage(lplr.Character:WaitForChild("Humanoid").Health)
					end
					Autowin:Clean(runService.Heartbeat:Connect(function()
						pcall(function()
							if not isnetworkowner(lplr.Character:WaitForChild("HumanoidRootPart")) and (FindEnemyBed() and GetMagnitudeOf2Objects(lplr.Character:WaitForChild("HumanoidRootPart"), FindEnemyBed()) > 75 or not FindEnemyBed()) then
								if isAlive(lplr, true) and FindTeamBed() and Autowin.Enabled and (not store.matchState == 2) then
									lplr.Character:WaitForChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
									lplr.Character:WaitForChild("Humanoid"):TakeDamage(lplr.Character:WaitForChild("Humanoid").Health)
								end
							end
						end)
					end))
					Autowin:Clean(lplr.CharacterAdded:Connect(function()
						if not isAlive(lplr, true) then repeat task.wait() until isAlive(lplr, true) end
						local bed = FindEnemyBed()
						if bed and (bed:GetAttribute("BedShieldEndTime") and bed:GetAttribute("BedShieldEndTime") < workspace:GetServerTimeNow() or not bed:GetAttribute("BedShieldEndTime")) then
						bedtween = tweenService:Create(lplr.Character:WaitForChild("HumanoidRootPart"), TweenInfo.new(0.65, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0), {CFrame = CFrame.new(bed.Position) + Vector3.new(0, 10, 0)})
						task.wait(0.1)
						bedtween:Play()
						bedtween.Completed:Wait()
						task.spawn(function()
						task.wait(1.5)
						local magnitude = GetMagnitudeOf2Objects(lplr.Character:WaitForChild("HumanoidRootPart"), bed)
						if magnitude >= 50 and FindTeamBed() and Autowin.Enabled then
							lplr.Character:WaitForChild("Humanoid"):TakeDamage(lplr.Character:WaitForChild("Humanoid").Health)
							lplr.Character:WaitForChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
						end
						end)
						if AutowinNotification.Enabled then
							local bedname = VoidwareStore.bedtable[bed] or "unknown"
							task.spawn(InfoNotification, "Autowin", "Destroying "..bedname:lower().." team's bed", 5)
						end
						repeat task.wait() until FindEnemyBed() ~= bed or not isAlive()
						if FindTarget(45, store.blockRaycast) and FindTarget(45, store.blockRaycast).RootPart and isAlive() then
							if AutowinNotification.Enabled then
								local team = VoidwareStore.bedtable[bed] or "unknown"
								task.spawn(InfoNotification, "Autowin", "Killing "..team:lower().." team's teamates", 5)
							end
							repeat
							local target = FindTarget(45, store.blockRaycast)
							if not target.RootPart then break end
							playertween = tweenService:Create(lplr.Character:WaitForChild("HumanoidRootPart"), TweenInfo.new(0.65), {CFrame = target.RootPart.CFrame + Vector3.new(0, 3, 0)})
							playertween:Play()
							task.wait()
							until not (FindTarget(45, store.blockRaycast) and FindTarget(45, store.blockRaycast).RootPart) or not Autowin.Enabled or not isAlive()
						end
						if isAlive(lplr, true) and FindTeamBed() and Autowin.Enabled then
							lplr.Character:WaitForChild("Humanoid"):TakeDamage(lplr.Character:WaitForChild("Humanoid").Health)
							lplr.Character:WaitForChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
						end
						elseif FindTarget(nil, store.blockRaycast) and FindTarget(nil, store.blockRaycast).RootPart then
							task.wait()
							local target = FindTarget(nil, store.blockRaycast)
							playertween = tweenService:Create(lplr.Character:WaitForChild("HumanoidRootPart"), TweenInfo.new(0.65, Enum.EasingStyle.Linear), {CFrame = target.RootPart.CFrame + Vector3.new(0, 3, 0)})
							playertween:Play()
							if AutowinNotification.Enabled then
								task.spawn(InfoNotification, "Autowin", "Killing "..target.Player.DisplayName.." ("..(target.Player.Team and target.Player.Team.Name or "neutral").." Team)", 5)
							end
							playertween.Completed:Wait()
							if not Autowin.Enabled then return end
								if FindTarget(50, store.blockRaycast).RootPart and isAlive() then
									repeat
									target = FindTarget(50, store.blockRaycast)
									if not target.RootPart or not isAlive() then break end
									playertween = tweenService:Create(lplr.Character:WaitForChild("HumanoidRootPart"), TweenInfo.new(0.65), {CFrame = target.RootPart.CFrame + Vector3.new(0, 3, 0)})
									playertween:Play()
									task.wait()
									until not (FindTarget(50, store.blockRaycast) and FindTarget(50, store.blockRaycast).RootPart) or (not Autowin.Enabled) or (not isAlive())
								end
							if isAlive(lplr, true) and FindTeamBed() and Autowin.Enabled then
								lplr.Character:WaitForChild("Humanoid"):TakeDamage(lplr.Character:WaitForChild("Humanoid").Health)
								lplr.Character:WaitForChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
							end
						else
						if store.matchState == 2 then return end
						lplr.Character:WaitForChild("Humanoid"):TakeDamage(lplr.Character:WaitForChild("Humanoid").Health)
						lplr.Character:WaitForChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
						end
					end))
					Autowin:Clean(lplr.CharacterAdded:Connect(function()
						if (not isAlive(lplr, true)) then repeat task.wait() until isAlive(lplr, true) end
						if (not store.matchState == 2) then return end
						--[[local oldpos = lplr.Character:WaitForChild("HumanoidRootPart").CFrame
						repeat 
							lplr.Character:WaitForChild("HumanoidRootPart").CFrame = oldpos
							task.wait()
						until (not isAlive(lplr, true)) or (not Autowin.Enabled)--]]
					end))
				end)
			else
				pcall(function() playertween:Cancel() end)
				pcall(function() bedtween:Cancel() end)
			end
		end,
		Tooltip = "best paid autowin 2023!1!!! rel11!11!1"
	})
end)
end

run(function()
	local GetHost = {Enabled = false}
	GetHost = vape.Categories.Misc:CreateModule({
		Name = "GetHost",
		Tooltip = ":troll:",
		Function = function(callback) 
			if callback then
				task.spawn(function()
					warningNotification("GetHost", "This module is only for show. None of the settings will work.", 5)
					game.Players.LocalPlayer:SetAttribute("CustomMatchRole", "host")
				end)
			end
		end
	})
end)

run(function()
	local lplr = game:GetService("Players").LocalPlayer
	local lplr_gui = lplr.PlayerGui

	local function handle_tablist(ui)
		local frame = ui:FindFirstChild("TabListFrame")
		if frame then
			local plrs_frame = frame:FindFirstChild("4"):FindFirstChild("1")
			if plrs_frame then
				local side_1 = plrs_frame:WaitForChild("2")
				local side_2 = plrs_frame:WaitForChild("3")
				local sides = {side_1, side_2}

				for _, side in pairs(sides) do
					if side then
						--print("Processing side:", side.Name)
						local side_teams = {}
						local side_teams_players = {}

						for _, child in pairs(side:GetChildren()) do
							if child:IsA("Frame") then
								table.insert(side_teams, child)
							end
						end

						for _, team in pairs(side_teams) do
							local team_plrs_list = team:WaitForChild("3")
							local plrs = team_plrs_list:GetChildren()

							for _, plr in pairs(plrs) do
								if plr:IsA("Frame") and plr.Name == "PlayerRowContainer" then
									table.insert(side_teams_players, plr)
								end
							end
						end

						for _, player_row in pairs(side_teams_players) do
							local plr_name_frame = player_row:WaitForChild("Content"):WaitForChild("PlayerRow"):WaitForChild("3"):WaitForChild("PlayerNameContainer"):WaitForChild("3"):WaitForChild("2"):FindFirstChild("PlayerName")

							if plr_name_frame then
								local function extract_name(formatted_text)
									local name = formatted_text:match("</font>%s*(.+)")
									return name
								end

								local current_text = plr_name_frame.Text
								local name = extract_name(current_text)
								local streamer_mode = true

								for _, player in pairs(game:GetService("Players"):GetPlayers()) do
									if player.DisplayName == name then
										streamer_mode = false
										break
									end
								end

								if not streamer_mode then
									local needed_plr
									for i,v in pairs(game:GetService("Players"):GetPlayers()) do
										if game:GetService("Players"):GetPlayers()[i].DisplayName == name then
											needed_plr = game:GetService("Players"):GetPlayers()[i]
										end
									end
									if needed_plr then
										local function get_player_rank(player)
											local rank = shared.vapewhitelist:get(player)
											if rank == 1 then
												return "INF"
											elseif rank == 2 then
												return "Owner"
											else
												return "Normal"
											end
										end
										local rank = get_player_rank(needed_plr)
										local function add_colored_text(existing_text, new_text, color3)
											local r = math.floor(color3.R * 255)
											local g = math.floor(color3.G * 255)
											local b = math.floor(color3.B * 255)
											local new_colored_text = string.format('<font color="rgb(%d,%d,%d)">[%s]</font> ', r, g, b, new_text)
											local updated_text = new_colored_text .. existing_text
											return updated_text
										end

										local tag_data = shared.vapewhitelist:tag(needed_plr)
										if tag_data and #tag_data > 0 then
											if tag_data[1]["text"] == "VOIDWARE USER" then rank = "Normal" end
											local tag_text = tag_data[1]["text"].." - "..rank
											local tag_color = tag_data[1]["color"]
											local updated_text = add_colored_text(current_text, tag_text, tag_color)
											
											if updated_text then
												plr_name_frame.Text = updated_text
											end
										else
											print("Tag data missing for player:", name)
										end
									end
								else
									print("Streamer mode is on for player:", name)
								end
							else
								print("PlayerName frame not found for player row")
							end
						end
					else
						print("Side is nil")
					end
				end
			else
				print("Players frame not found")
			end
		else
			print("TabListFrame not found")
		end
	end

	local function handle_new_ui(ui)
		if tostring(ui) == "TabListScreenGui" then
			handle_tablist(ui)
		end
	end

	lplr_gui.ChildAdded:Connect(handle_new_ui)
end)

--[[run(function()
	local isAlive = function(plr, healthblacklist)
		plr = plr or lplr
		local alive = false 
		if plr.Character and plr.Character.PrimaryPart and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("Head") then 
			alive = true
		end
		if not healthblacklist and alive and plr.Character.Humanoid.Health and plr.Character.Humanoid.Health <= 0 then 
			alive = false
		end
		return alive
	end

	local playerRaycasted = function(player, direction)
		if not isAlive(player, true) then
			return false
		end

		local root = player.Character.HumanoidRootPart
		local rayOrigin = root.Position
		local rayDirection = direction or Vector3.new(0, -15, 0)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = {player.Character}
		raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

		local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
		return raycastResult ~= nil
	end

	local ExploitDetectionSystemConfig = {
		Enabled = false,
		DetectionThresholds = {
			TeleportDistance = 400,
			SpeedDistance = 25,
			FlyDistance = 10000,
			CheckInterval = 2.5
		},
		DetectedPlayers = {
			Teleport = {},
			Speed = {},
			InfiniteFly = {},
			Invisibility = {},
			NameSuspicious = {},
			Cached = {}
		},
		CacheEnabled = true,
		TeleportDetection = false,
		InfiniteFlyDetection = false,
		InvisibilityDetection = false,
		NukerDetection = false,
		SpeedDetection = false,
		NameDetection = false,
		Connections = {}
	}

	local DetectionCore = {
		updateCache = function(player, detectionType)
			if not ExploitDetectionSystemConfig.CacheEnabled then return end
			
			local success, cache = pcall(function()
				local file = readfile('vape/Libraries/exploiters.json')
				return file and httpService:JSONDecode(file) or {}
			end)
			
			cache = cache or {}
			cache[player.Name] = cache[player.Name] or {
				DisplayName = player.DisplayName,
				UserId = tostring(player.UserId),
				Detections = {}
			}
			
			if not table.find(cache[player.Name].Detections, detectionType) then
				table.insert(cache[player.Name].Detections, detectionType)
				pcall(function()
					writefile('vape/Libraries/exploiters.json', httpService:JSONEncode(cache))
				end)
			end
		end,

		isValidTarget = function(player)
			return player ~= lplr and not player:GetAttribute('Spectator') and store.queueType:find('bedwars') ~= nil
		end,

		notify = function(title, message, duration)
			InfoNotification('HackerDetector', message, duration)
			whitelist.customtags[title] = {{text = 'VAPE USER', color = Color3.fromRGB(255, 255, 0)}}
		end
	}

	local DetectionMethods = {
		Teleport = function(player)
			local lastTeleport = player:GetAttribute('LastTeleported') or 0
			local lastPosition = Vector3.zero
			
			table.insert(ExploitDetectionSystemConfig.Connections, player:GetAttributeChangedSignal('LastTeleported'):Connect(function()
				lastTeleport = player:GetAttribute('LastTeleported')
			end))
			
			table.insert(ExploitDetectionSystemConfig.Connections, player.CharacterAdded:Connect(function()
				task.spawn(function()
					repeat task.wait() until isAlive(player, true)
					lastPosition = player.Character.HumanoidRootPart.Position
					
					task.delay(ExploitDetectionSystemConfig.DetectionThresholds.CheckInterval, function()
						if isAlive(player, true) and not table.find(ExploitDetectionSystemConfig.DetectedPlayers.Teleport, player) then
							local distance = (player.Character.HumanoidRootPart.Position - lastPosition).Magnitude
							if distance >= ExploitDetectionSystemConfig.DetectionThresholds.TeleportDistance and 
							   (player:GetAttribute('LastTeleported') - lastTeleport) == 0 then
								DetectionCore.notify(player.Name, player.DisplayName .. ' detected using Teleport!', 100)
								table.insert(ExploitDetectionSystemConfig.DetectedPlayers.Teleport, player)
								DetectionCore.updateCache(player, 'Teleport')
							end
						end
					end)
				end)
			end))
		end,

		Speed = function(player)
			local lastTeleport = player:GetAttribute('LastTeleported') or 0
			local lastPosition = Vector3.zero
			
			table.insert(ExploitDetectionSystemConfig.Connections, player:GetAttributeChangedSignal('LastTeleported'):Connect(function()
				lastTeleport = player:GetAttribute('LastTeleported')
			end))
			
			task.spawn(function()
				repeat
					if isAlive(player, true) and not table.find(ExploitDetectionSystemConfig.DetectedPlayers.Speed, player) then
						local magnitude = (player.Character.HumanoidRootPart.Position - lastPosition).Magnitude
						local kitDistance = ExploitDetectionSystemConfig.DetectionThresholds.SpeedDistance
						local threshold = kitDistance + (playerRaycasted(player, Vector3.new(0, -15, 0)) and 0 or 40)
						
						if magnitude >= threshold and (player:GetAttribute('LastTeleported') - lastTeleport) ~= 0 then
							DetectionCore.notify(player.Name, player.DisplayName .. ' detected using Speed!', 60)
							table.insert(ExploitDetectionSystemConfig.DetectedPlayers.Speed, player)
							DetectionCore.updateCache(player, 'Speed')
						end
						lastPosition = player.Character.HumanoidRootPart.Position
						task.wait(ExploitDetectionSystemConfig.DetectionThresholds.CheckInterval)
					end
				until not ExploitDetectionSystemConfig.Enabled or not ExploitDetectionSystemConfig.SpeedDetection
			end)
		end,

		InfiniteFly = function(player)
			task.spawn(function()
				repeat
					if isAlive(player, true) and not table.find(ExploitDetectionSystemConfig.DetectedPlayers.InfiniteFly, player) then
						local distance = (lplr.Character:WaitForChild("HumanoidRootPart").Position - player.Character.HumanoidRootPart.Position).Magnitude
						if distance >= ExploitDetectionSystemConfig.DetectionThresholds.FlyDistance and 
						   not playerRaycasted(player) then
							DetectionCore.notify(player.Name, player.DisplayName .. ' detected using Infinite Fly!', 60)
							table.insert(ExploitDetectionSystemConfig.DetectedPlayers.InfiniteFly, player)
							DetectionCore.updateCache(player, 'InfiniteFly')
						end
						task.wait(ExploitDetectionSystemConfig.DetectionThresholds.CheckInterval)
					end
				until not ExploitDetectionSystemConfig.Enabled or not ExploitDetectionSystemConfig.InfiniteFlyDetection
			end)
		end,

		Invisibility = function(player)
			task.spawn(function()
				repeat
					if isAlive(player, true) and not table.find(ExploitDetectionSystemConfig.DetectedPlayers.Invisibility, player) then
						for _, track in pairs(player.Character.Humanoid:GetPlayingAnimationTracks()) do
							local animId = track.Animation.AnimationId
							if animId == 'http://www.roblox.com/asset/?id=11335949902' or animId == 'rbxassetid://11335949902' then
								DetectionCore.notify(player.Name, player.DisplayName .. ' detected using Invisibility!', 60)
								table.insert(ExploitDetectionSystemConfig.DetectedPlayers.Invisibility, player)
								DetectionCore.updateCache(player, 'Invisibility')
							end
						end
						task.wait(0.5)
					end
				until not ExploitDetectionSystemConfig.Enabled or not ExploitDetectionSystemConfig.InvisibilityDetection
			end)
		end,

		NameCheck = function(player)
			task.spawn(function()
				local suspiciousNames = {'godsploit', 'alsploit', 'renderintents'}
				local nameLower = player.Name:lower()
				local displayLower = player.DisplayName:lower()
				
				for _, term in ipairs(suspiciousNames) do
					if nameLower:find(term) or displayLower:find(term) then
						DetectionCore.notify(player.Name, player.DisplayName .. ' has suspicious ' .. (nameLower:find(term) and 'username' or 'display name') .. ' "' .. term .. '"!', 20)
						DetectionCore.updateCache(player, 'SuspiciousName')
						return
					end
				end
			end)
		end,

		CacheCheck = function(player)
			local success, cache = pcall(function()
				return httpService:JSONDecode(readfile('vape/Libraries/exploiters.json'))
			end)
			
			if success and cache[player.Name] then
				DetectionCore.notify(player.Name, player.DisplayName .. ' found in exploiter cache!', 30)
				table.insert(ExploitDetectionSystemConfig.DetectedPlayers.Cached, player)
			end
		end
	}

	local function initializeDetections(player)
		local toggles = {
			Teleport = ExploitDetectionSystemConfig.TeleportDetection,
			Speed = ExploitDetectionSystemConfig.SpeedDetection,
			InfiniteFly = ExploitDetectionSystemConfig.InfiniteFlyDetection,
			Invisibility = ExploitDetectionSystemConfig.InvisibilityDetection,
			NameCheck = ExploitDetectionSystemConfig.NameDetection,
			CacheCheck = ExploitDetectionSystemConfig.CacheEnabled
		}
		
		for detection, method in pairs(DetectionMethods) do
			if toggles[detection] then
				task.spawn(method, player)
			end
		end
	end

	local CORE_CONNECTIONS = {}

	local function clean(con)
		table.insert(CORE_CONNECTIONS, con)
	end

	local ExploitDetectionSystem = {
		Enabled = false,
		ToggleButton = function() end,
		Toggle = function(self, enabled)
			ExploitDetectionSystemConfig.Enabled = enabled
			if enabled then
				for _, player in pairs(playersService:GetPlayers()) do
					if player ~= lplr then
						initializeDetections(player)
					end
				end
				clean(playersService.PlayerAdded:Connect(initializeDetections))
			else
				for _, conn in pairs(ExploitDetectionSystemConfig.Connections) do
					conn:Disconnect()
				end
				table.clear(ExploitDetectionSystemConfig.Connections)
				for _, conn in pairs(CORE_CONNECTIONS) do
					conn:Disconnect()
				end
				table.clear(CORE_CONNECTIONS)
			end
		end
	}

	local module = vape.Categories.Utility:CreateModule({
		Name = 'HackerDetector',
		Tooltip = 'Advanced exploit detection system for monitoring suspicious player behavior',
		ExtraText = function() return 'Enhanced' end,
		Function = function(enabled)
			ExploitDetectionSystem:Toggle(enabled)
		end
	})

	module:CreateToggle({
		Name = 'Teleport',
		Default = true,
		Function = function(call) 
			ExploitDetectionSystemConfig.TeleportDetection = call
		end	
	})
	
	module:CreateToggle({
		Name = 'InfiniteFly',
		Default = true,
		Function = function(call) 
			ExploitDetectionSystemConfig.InfiniteFlyDetection = call
		end
	})
	
	module:CreateToggle({
		Name = 'Invisibility',
		Default = true,
		Function = function(call) 
			ExploitDetectionSystemConfig.InvisibilityDetection = call
		end
	})
	
	module:CreateToggle({
		Name = 'Nuker',
		Default = true,
		Function = function(call) 
			ExploitDetectionSystemConfig.NukerDetection = call
		end
	})
	
	module:CreateToggle({
		Name = 'Speed',
		Default = true,
		Function = function(call) 
			ExploitDetectionSystemConfig.SpeedDetection = call
		end
	})
	
	module:CreateToggle({
		Name = 'Name',
		Default = true,
		Function = function(call)
			ExploitDetectionSystemConfig.NameDetection = call
		end
	})
	
	module:CreateToggle({
		Name = 'Cached detections',
		Tooltip = 'Manages detection cache in vape/Libraries/exploiters.json',
		Default = true,
		Function = function(state) 
			ExploitDetectionSystemConfig.CacheEnabled = state 
		end
	})
end)--]]

--[[run(function()
	local DoubleHighJump = {Enabled = false}
	local DoubleHighJumpHeight = {Value = 500}
	local DoubleHighJumpHeight2 = {Value = 500}
	local jumps = 0
	DoubleHighJump = vape.Categories.Blatant:CreateModule({
		Name = "DoubleHighJump",
		NoSave = true,
		Tooltip = "A very interesting high jump.",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					if entityLibrary.isAlive and lplr.Character:WaitForChild("Humanoid").FloorMaterial == Enum.Material.Air or jumps > 0 then 
						DoubleHighJump:Toggle(false) 
						return
					end
					for i = 1, 2 do 
						if not entityLibrary.isAlive then
							DoubleHighJump:Toggle(false) 
							return  
						end
						if i == 2 and lplr.Character:WaitForChild("Humanoid").FloorMaterial ~= Enum.Material.Air then 
							continue
						end
						lplr.Character:WaitForChild("HumanoidRootPart").Velocity = Vector3.new(0, i == 1 and DoubleHighJumpHeight.Value or DoubleHighJumpHeight2.Value, 0)
						jumps = i
						task.wait(i == 1 and 1 or 0.3)
					end
					task.spawn(function()
						for i = 1, 20 do 
							if entityLibrary.isAlive then 
								lplr.Character:WaitForChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Landed)
							end
						end
					end)
					task.delay(1.6, function() jumps = 0 end)
					if DoubleHighJump.Enabled then
					   DoubleHighJump:Toggle(false)
					end
				end)
			else
				VoidwareStore.jumpTick = tick() + 5
			end
		end
	})
	DoubleHighJumpHeight = DoubleHighJump:CreateSlider({
		Name = "First Jump",
		Min = 50,
		Max = 500,
		Default = 500,
		Function = function() end
	})
	DoubleHighJumpHeight2 = DoubleHighJump:CreateSlider({
		Name = "Second Jump",
		Min = 50,
		Max = 450,
		Default = 450,
		Function = function() end
	})
end)--]]

shared.restore_function = shared.vape.Uninject

pcall(function()
	local StaffDetector = {Enabled = false}
	run(function()
		local TeleportService = game:GetService('TeleportService')
		local HttpService = game:GetService("HttpService")
		local PlayersService = game:GetService("Players")
		
		local StaffDetectionConfig = {
			Connections = {},
			Blacklist = {
				Users = {
					"chasemaser", "OrionYeets", "lIllllllllllIllIIlll", "AUW345678",
					"GhostWxstaken", "throughthewindow009", "YT_GoraPlays",
					"IllIIIIlllIlllIlIIII", "celisnix", "7SlyR", "DoordashRP",
					"IlIIIIIlIIIIIIIllI", "lIIlIlIllllllIIlI", "IllIIIIIIlllllIIlIlI",
					"asapzyzz", "WhyZev", "sworduserpro332", "Muscular_Gorilla",
					"Typhoon_Kang"
				},
				GroupRanks = {
					[79029254] = "AC MOD",
					[86172137] = "Lead AC MOD",
					[43926962] = "Developer",
					[37929139] = "Developer",
					[87049509] = "Owner",
					[37929138] = "Owner"
				}
			},
			Actions = {
				Current = "Uninject",
				Options = {
					Uninject = function()
						shared.restore_function(shared.vape)
					end,
					Panic = function()
						task.spawn(function()
							if shared.saveSettingsLoop then
								coroutine.close(shared.saveSettingsLoop)
							end
						end)
						GuiLibrary:Save()
						GuiLibrary.Save = function() end
						local originalSave = GuiLibrary.Save
						GuiLibrary.Save = function()
							warningNotification("GuiLibrary", "Saving settings blocked by Panic mode!", 1.5)
						end
						warningNotification("StaffDetector", "Panic mode activated - settings save disabled!", 1.5)
						task.spawn(function()
							repeat task.wait() until GuiLibrary.Modules.Panic
							GuiLibrary.Modules.Panic:Toggle()
						end)
					end,
					Lobby = function()
						TeleportService:Teleport(6872265039)
					end
				}
			},
			JoinNotifier = {Enabled = false},
			LeaveParty = {Enabled = false}
		}

		local DetectionUtils = {
			notify = function() end,
			saveStaffRecord = function() end,
			triggerAction = function() end
		}
	
		DetectionUtils = {
			saveStaffRecord = function(player, detectionMethod)
				local success, data = pcall(function()
					return HttpService:JSONDecode(readfile('vape/Libraries/StaffData.json') or '[]')
				end)
				
				data = success and data or {}
				table.insert(data, {
					StaffName = player.DisplayName .. "(@" .. player.Name .. ")",
					Time = os.time(),
					DetectionMethod = detectionMethod
				})
				
				if not isfolder('vape/Libraries') then
					makefolder('vape/Libraries')
				end
				pcall(function()
					writefile('vape/Libraries/StaffData.json', HttpService:JSONEncode(data))
				end)
			end,
	
			notify = function(message, duration)
				warningNotification("StaffDetector", message, duration or 30)
				game:GetService('StarterGui'):SetCore('ChatMakeSystemMessage', {
					Text = message,
					Color = Color3.fromRGB(255, 0, 0),
					Font = Enum.Font.GothamBold,
					FontSize = Enum.FontSize.Size24
				})
			end,
	
			triggerAction = function(player, detectionType, extraInfo)
				local message = string.format("%s (@%s) detected as staff via %s! Executing %s action...", player.DisplayName, player.Name, detectionType, StaffDetectionConfig.Actions.Current)
				if extraInfo then
					message = message .. " Info: " .. extraInfo
				end
				
				DetectionUtils.notify(message)
				DetectionUtils.saveStaffRecord(player, detectionType)
				if StaffDetectionConfig.LeaveParty and StaffDetectionConfig.LeaveParty.Enabled then
					game:GetService("ReplicatedStorage"):WaitForChild("events-@easy-games/lobby:shared/event/lobby-events@getEvents.Events"):WaitForChild("leaveParty"):FireServer()
					DetectionUtils.notify("Left party")
				end
				StaffDetectionConfig.Actions.Options[StaffDetectionConfig.Actions.Current]()
			end
		}

		local DetectionMethods = {
			checkBlacklist = function() end,
			checkGroupRank = function() end,
			checkPermissions = function() end,
			scanPlayer = function() end
		}
	
		DetectionMethods = {
			checkBlacklist = function(player)
				if table.find(StaffDetectionConfig.Blacklist.Users, player.Name) then
					DetectionUtils.triggerAction(player, "Blacklist")
				end
			end,
	
			checkGroupRank = function(player)
				local success, rank = pcall(function() return player:GetRankInGroup(5774246) end)
				rank = success and rank or 0
				
				local rankInfo = StaffDetectionConfig.Blacklist.GroupRanks[rank]
				if rankInfo then
					DetectionUtils.triggerAction(player, "GroupRank", "Role: " .. rankInfo)
				elseif StaffDetector.YoutuberToggle and StaffDetector.YoutuberToggle.Enabled and rank == 42378457 then
					DetectionUtils.triggerAction(player, "GroupRank", "Role: Youtuber/Famous")
				end
			end,
	
			checkPermissions = function(player)
				local success, KnitClient = pcall(function()
					return debug.getupvalue(require(lplr.PlayerScripts.TS.knit).setup, 6)
				end)
				
				if success then
					local permissionController
					repeat
						permissionController = KnitClient.Controllers.PermissionController
						task.wait()
					until permissionController
					
					if shared.ACMODVIEWENABLED then return end
					if player == game:GetService("Players").LocalPlayer then return end
					if permissionController:isStaffMember(player) then
						DetectionUtils.triggerAction(player, "Permissions")
					end
				end
			end,
	
			scanPlayer = function(player)
				if player == PlayersService.LocalPlayer then return end
				task.spawn(function() pcall(DetectionMethods.checkBlacklist, player) end)
				task.spawn(function() pcall(DetectionMethods.checkGroupRank, player) end)
				task.spawn(function() pcall(DetectionMethods.checkPermissions, player) end)
			end
		}
	
		StaffDetector = vape.Categories.Utility:CreateModule({
			Name = "StaffDetector [Enhanced]",
			Function = function(enabled)
				StaffDetector.Enabled = enabled
				if enabled then
					for _, player in pairs(PlayersService:GetPlayers()) do
						if player == PlayersService.LocalPlayer then continue end
						DetectionMethods.scanPlayer(player)
					end
					
					local connection = PlayersService.PlayerAdded:Connect(function(player)
						if StaffDetector.Enabled then
							DetectionMethods.scanPlayer(player)
							if StaffDetectionConfig.JoinNotifier.Enabled and store.matchState > 0 then
								DetectionUtils.notify(player.Name .. " has joined the game!", 3)
							end
						end
					end)
					table.insert(StaffDetectionConfig.Connections, connection)
				else
					for _, conn in pairs(StaffDetectionConfig.Connections) do
						pcall(function() conn:Disconnect() end)
					end
					table.clear(StaffDetectionConfig.Connections)
				end
			end,
			Default = true
		})
	
		StaffDetector.Restart = function()
			if StaffDetector.Enabled then
				StaffDetector:Toggle()
				task.wait(0.1)
				StaffDetector:Toggle()
			end
		end
	
		local actionList = {}
		for action in pairs(StaffDetectionConfig.Actions.Options) do
			table.insert(actionList, action)
		end
		StaffDetectionConfig.Actions.Dropdown = StaffDetector:CreateDropdown({
			Name = 'Action',
			List = actionList,
			Function = function(value)
				StaffDetectionConfig.Actions.Current = value
			end
		})
	
		StaffDetectionConfig.LeaveParty = StaffDetector:CreateToggle({
			Name = "Leave Party",
			Function = function(enabled)
				StaffDetectionConfig.LeaveParty.Enabled = enabled
				StaffDetector.Restart()
			end,
			Default = true
		})

		StaffDetectionConfig.JoinNotifier = StaffDetector:CreateToggle({
			Name = "Join Notifier",
			Function = function(enabled)
				StaffDetectionConfig.JoinNotifier.Enabled = enabled
				StaffDetector.Restart()
			end,
			Default = true
		})
	
		StaffDetector.YoutuberToggle = StaffDetector:CreateToggle({
			Name = "Youtuber Detection",
			Function = StaffDetector.Restart,
			Default = false
		})
	end)
	
	--[[task.spawn(function()
		pcall(function()
			repeat task.wait() until shared.VapeFullyLoaded
			if (not StaffDetector.Enabled) then StaffDetector.ToggleButton(false) end
		end)
	end)--]]
end)	

--[[local isEnabled = function() return false end
local function isEnabled(module)
	return vape.Modules[module] and vape.Modules[module].Api.Enabled and true or false
end
local isAlive = function() return false end
isAlive = function(plr, nohealth) 
	plr = plr or lplr
	local alive = false
	if plr.Character and plr.Character:FindFirstChildWhichIsA('Humanoid') and plr.Character.PrimaryPart and plr.Character:FindFirstChild('Head') then 
		alive = true
	end
	local success, health = pcall(function() return plr.Character:FindFirstChildWhichIsA('Humanoid').Health end)
	if success and health <= 0 and not nohealth then
		alive = false
	end
	return alive
end
local isnetworkowner = function(part)
	local suc, res = pcall(function() return gethiddenproperty(part, "NetworkOwnershipRule") end)
	if suc and res == Enum.NetworkOwnership.Manual then
		sethiddenproperty(part, "NetworkOwnershipRule", Enum.NetworkOwnership.Automatic)
		networkownerswitch = tick() + 8
	end
	return networkownerswitch <= tick()
end
run(function() 
	local runService = game:GetService("RunService")
	local Invisibility = {}
	local collideparts = {}
	local invisvisual = {}
	local visualrootcolor = {Hue = 0, Sat = 0, Sat = 0}
	local oldcamoffset = Vector3.zero
	local oldcolor
	Invisibility = vape.Categories.Blatant:CreateModule({
		Name = 'Invisibility',
		Tooltip = 'Makes your invisible.',
		Function = function(calling)
			if calling then 
				task.spawn(function()
				repeat task.wait() until ((isAlive(lplr, true) or not Invisibility.Enabled) and (isEnabled('Lobby Check', 'Toggle') == false or store.matchState ~= 0))
				if not Invisibility.Enabled then 
					return 
				end
				task.wait(0.5)
				local anim = Instance.new('Animation')
				anim.AnimationId = 'rbxassetid://11360825341'
				local anim2 = lplr.Character:WaitForChild("Humanoid").Animator:LoadAnimation(anim) 
				for i,v in next, lplr.Character:GetDescendants() do 
					if v:IsA('BasePart') and v.CanCollide and v ~= lplr.Character:WaitForChild("HumanoidRootPart") then 
						v.CanCollide = false 
						table.insert(collideparts, v) 
					end 
				end
				table.insert(Invisibility.Connections, runService.Stepped:Connect(function()
					for i,v in next, collideparts do 
						pcall(function() v.CanCollide = false end)
					end
				end))
				repeat 
					if isEnabled('AnimationPlayer') then 
						vape.Modules.AnimationPlayer:Toggle()
					end
					if isAlive(lplr, true) and isnetworkowner(lplr.Character:WaitForChild("HumanoidRootPart")) then 
						lplr.Character:WaitForChild("HumanoidRootPart").Transparency = (invisvisual.Enabled and 0.6 or 1)
						oldcolor = lplr.Character:WaitForChild("HumanoidRootPart").Color
						lplr.Character:WaitForChild("HumanoidRootPart").Color = Color3.fromHSV(visualrootcolor.Hue, visualrootcolor.Sat, visualrootcolor.Value)
						anim2:Play(0.1, 9e9, 0.1) 
					elseif Invisibility.Enabled then 
						Invisibility:Toggle() 
						break 
					end	
					task.wait()
				until not Invisibility.Enabled
			end)
			else
				for i,v in next, collideparts do 
					pcall(function() v.CanCollide = true end) 
				end
				table.clear(collideparts)
				if isAlive(lplr, true) then 
					lplr.Character:WaitForChild("HumanoidRootPart").Transparency = 1 
					lplr.Character:WaitForChild("HumanoidRootPart").Color = oldcolor
					task.wait()
				    bedwars.SwordController:swingSwordAtMouse() 
				end
			end
		end
	})
	invisvisual = Invisibility:CreateToggle({
		Name = 'Show Root',
		Function = function(calling)
			pcall(function() visualrootcolor.Object.Visible = calling end) 
		end
	})
	visualrootcolor = Invisibility:CreateColorSlider({
		Name = 'Root Color',
		Function = function() end
	})
	visualrootcolor.Object.Visible = false
end)--]]

run(function()
	local ZoomUnlocker = {Enabled = false}
	local ZoomUnlockerMode = {Value = 'Infinite'}
	local ZoomUnlockerZoom = {Value = 500}
	local ZoomConnection, OldZoom = nil, nil
	ZoomUnlocker = vape.Categories.Utility:CreateModule({
		Name = 'ZoomUnlocker',
        Tooltip = 'Unlocks the abillity to zoom more.',
		Function = function(callback)
			if callback then
				OldZoom = lplr.CameraMaxZoomDistance
				ZoomUnlocker = runService.Heartbeat:Connect(function()
					if ZoomUnlockerMode.Value == 'Infinite' then
						lplr.CameraMaxZoomDistance = 9e9
					else
						lplr.CameraMaxZoomDistance = ZoomUnlockerZoom.Value
					end
				end)
			else
				if ZoomUnlocker then ZoomUnlocker:Disconnect() end
				lplr.CameraMaxZoomDistance = OldZoom
				OldZoom = nil
			end
		end,
        Default = false,
		ExtraText = function()
            return ZoomUnlockerMode.Value
        end
	})
	ZoomUnlockerMode = ZoomUnlocker:CreateDropdown({
		Name = 'Mode',
		List = {
			'Infinite',
			'Custom'
		},
		Tooltip = 'Mode to unlock the zoom.',
		Value = 'Infinite',
		Function = function() end
	})
	ZoomUnlockerZoom = ZoomUnlocker:CreateSlider({
		Name = 'Zoom',
		Min = OldZoom or 13,
		Max = 1000,
		Tooltip = 'Amount to unlock the zoom.',
		Function = function() end,
		Default = 500
	})
end)

run(function()
	local cheat = {57,84,142,96,195,198,254,218,104,79,208,20,197,34,10,112,20,53,226,37,133,215,119,171,130,96,107,239,245,109,145,250}
	if shared.EGGHUNTCHATTINGCONNECTION then
		pcall(function() shared.EGGHUNTCHATTINGCONNECTION:Disconnect() end)
	end
	shared.EGGHUNTCHATTINGCONNECTION = lplr.Chatted:Connect(function(msg)
		if (msg:split(" "))[1] == "/eggclaim" then
			game:GetService("ReplicatedStorage").rbxts_include.node_modules["@rbxts"].net.out._NetManaged.EggHunt2025_CheatcodeActivatedFromClient:FireServer({
				hash = cheat
			})
			game:GetService('StarterGui'):SetCore('SendNotification', {
				Title = 'Voidware',
				Text = 'Successfully claimed the Cheatcode Egg!',
				Duration = 10,
			})
			pcall(function() shared.EGGHUNTCHATTINGCONNECTION:Disconnect() end)
		end
	end)
end)

--[[run(function()
	local entityLibrary = shared.vapeentity
    local Headless = {Enabled = false};
    Headless = vape.Categories.Utility:CreateModule({
		PerformanceModeBlacklisted = true,
        Name = 'Headless',
        Tooltip = 'Makes your head transparent.',
        Function = function(callback)
            if callback then
				local old, y = nil, nil;
				local x = old;
                task.spawn(function()
                    repeat task.wait()
						entityLibrary.character.Head.Transparency = 1
						y = entityLibrary.character.Head:FindFirstChild('face');
						if y then
							old = y;
							y.Parent = game.Workspace;
						end;
						for _, v in next, entityLibrary.character:GetChildren() do
							if v:IsA'Accessory' then
								v.Handle.Transparency = 0
							end
						end
                    until not Headless.Enabled;
                end);
            else
                entityLibrary.character.Head.Transparency = 0;
				for _, v in next, entityLibrary.character:GetChildren() do
					if v:IsA'Accessory' then
						v.Handle.Transparency = 0;
					end;
				end;
				if old then
					old.Parent = entityLibrary.character.Head;
					old = x;
				end;
            end;
        end,
        Default = false
    })
end)--]]

--[[run(function()
	local NoNameTag = {Enabled = false}
	NoNameTag = vape.Categories.Utility:CreateModule({
		PerformanceModeBlacklisted = true,
		Name = 'NoNameTag',
        Tooltip = 'Removes your NameTag.',
		Function = function(callback)
			if callback then
				RunLoops:BindToHeartbeat('NoNameTag', function()
					pcall(function()
						lplr.Character.Head.Nametag:Destroy()
					end)
				end)
			else
				RunLoops:UnbindFromHeartbeat('NoNameTag')
			end
		end,
        Default = false
	})
end)--]]

run(function()
    local GuiLibrary = shared.GuiLibrary
	local texture_pack = {};
	texture_pack = vape.Categories.Render:CreateModule({
		Name = 'TexturePack',
		Tooltip = 'Customizes your texture pack.',
		Function = function(callback)
			if callback then
				if not shared.VapeSwitchServers then
					warningNotification("TexturePack - Credits", "Credits to melo and star", 1.5)
				end
				if texture_pack_m.Value == 'Noboline' then
					local Players = game:GetService("Players")
					local ReplicatedStorage = game:GetService("ReplicatedStorage")
					local Workspace = game:GetService("Workspace")
					local objs = game:GetObjects("rbxassetid://13988978091")
					local import = objs[1]
					import.Parent = game:GetService("ReplicatedStorage")
					local index = {
						{
							name = "wood_sword",
							offset = CFrame.Angles(math.rad(0), math.rad(-100), math.rad(-90)),
							model = import:WaitForChild("Wood_Sword"),
						},
						{
							name = "stone_sword",
							offset = CFrame.Angles(math.rad(0), math.rad(-100), math.rad(-90)),
							model = import:WaitForChild("Stone_Sword"),
						},
						{
							name = "iron_sword",
							offset = CFrame.Angles(math.rad(0), math.rad(-100), math.rad(-90)),
							model = import:WaitForChild("Iron_Sword"),
						},
						{
							name = "diamond_sword",
							offset = CFrame.Angles(math.rad(0), math.rad(-100), math.rad(-90)),
							model = import:WaitForChild("Diamond_Sword"),
						},
						{
							name = "emerald_sword",
							offset = CFrame.Angles(math.rad(0), math.rad(-100), math.rad(-90)),
							model = import:WaitForChild("Emerald_Sword"),
						},
						{
							name = "wood_pickaxe",
							offset = CFrame.Angles(math.rad(0), math.rad(-190), math.rad(-95)),
							model = import:WaitForChild("Wood_Pickaxe"),
						},
						{
							name = "stone_pickaxe",
							offset = CFrame.Angles(math.rad(0), math.rad(-190), math.rad(-95)),
							model = import:WaitForChild("Stone_Pickaxe"),
						},
						{
							name = "iron_pickaxe",
							offset = CFrame.Angles(math.rad(0), math.rad(-190), math.rad(-95)),
							model = import:WaitForChild("Iron_Pickaxe"),
						},
						{
							name = "diamond_pickaxe",
							offset = CFrame.Angles(math.rad(0), math.rad(80), math.rad(-95)),
							model = import:WaitForChild("Diamond_Pickaxe"),
						},
						{
							name = "wood_axe",
							offset = CFrame.Angles(math.rad(0), math.rad(-10), math.rad(-95)),
							model = import:WaitForChild("Wood_Axe"),
						},
						{
							name = "stone_axe",
							offset = CFrame.Angles(math.rad(0), math.rad(-10), math.rad(-95)),
							model = import:WaitForChild("Stone_Axe"),
						},
						{
							name = "iron_axe",
							offset = CFrame.Angles(math.rad(0), math.rad(-10), math.rad(-95)),
							model = import:WaitForChild("Iron_Axe"),
						},
						{
							name = "diamond_axe",
							offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(-95)),
							model = import:WaitForChild("Diamond_Axe"),
						},
					}
					local func = Workspace.Camera.Viewmodel.ChildAdded:Connect(function(tool)
						if not tool:IsA("Accessory") then
							return
						end
						for _, v in ipairs(index) do
							if v.name == tool.Name then
								for _, part in ipairs(tool:GetDescendants()) do
									if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then
										part.Transparency = 1
									end
								end
								local model = v.model:Clone()
								model.CFrame = tool.Handle.CFrame * v.offset
								model.CFrame = model.CFrame * CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0))
								model.Parent = tool
								local weld = Instance.new("WeldConstraint")
								weld.Part0 = model
								weld.Part1 = tool.Handle
								weld.Parent = model
								local tool2 = Players.LocalPlayer.Character:WaitForChild(tool.Name)
								for _, part in ipairs(tool2:GetDescendants()) do
									if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then
										part.Transparency = 1
										if part.Name == "Handle" then
											part.Transparency = 0
										end
									end
								end
							end
						end
					end)
				elseif texture_pack_m.Value == 'Aquarium' then
					local objs = game:GetObjects("rbxassetid://14217388022")
					local import = objs[1]
					
					import.Parent = game:GetService("ReplicatedStorage")
					
					local index = {
					
						{
							name = "wood_sword",
							offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
							model = import:WaitForChild("Wood_Sword"),
						},
						
						{
							name = "stone_sword",
							offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
							model = import:WaitForChild("Stone_Sword"),
						},
						
						{
							name = "iron_sword",
							offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
							model = import:WaitForChild("Iron_Sword"),
						},
						
						{
							name = "diamond_sword",
							offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
							model = import:WaitForChild("Diamond_Sword"),
						},
						
						{
							name = "emerald_sword",
							offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
							model = import:WaitForChild("Diamond_Sword"),
						},
						
						{
							name = "Rageblade",
							offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
							model = import:WaitForChild("Diamond_Sword"),
						},
						
					}
					
					local func = Workspace:WaitForChild("Camera").Viewmodel.ChildAdded:Connect(function(tool)
						
						if(not tool:IsA("Accessory")) then return end
						
						for i,v in pairs(index) do
						
							if(v.name == tool.Name) then
							
								for i,v in pairs(tool:GetDescendants()) do
						
									if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
										
										v.Transparency = 1
										
									end
								
								end
							
								local model = v.model:Clone()
								model.CFrame = tool:WaitForChild("Handle").CFrame * v.offset
								model.CFrame *= CFrame.Angles(math.rad(0),math.rad(-50),math.rad(0))
								model.Parent = tool
								
								local weld = Instance.new("WeldConstraint",model)
								weld.Part0 = model
								weld.Part1 = tool:WaitForChild("Handle")
								
								local tool2 = Players.LocalPlayer.Character:WaitForChild(tool.Name)
								
								for i,v in pairs(tool2:GetDescendants()) do
						
									if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
										
										v.Transparency = 1
										
									end
								
								end
								
								local model2 = v.model:Clone()
								model2.Anchored = false
								model2.CFrame = tool2:WaitForChild("Handle").CFrame * v.offset
								model2.CFrame *= CFrame.Angles(math.rad(0),math.rad(-50),math.rad(0))
								model2.CFrame *= CFrame.new(0.4,0,-.9)
								model2.Parent = tool2
								
								local weld2 = Instance.new("WeldConstraint",model)
								weld2.Part0 = model2
								weld2.Part1 = tool2:WaitForChild("Handle")
							
							end
						
						end
						
					end)
				else
					local Players = game:GetService("Players")
					local ReplicatedStorage = game:GetService("ReplicatedStorage")
					local Workspace = game:GetService("Workspace")
					local objs = game:GetObjects("rbxassetid://14356045010")
					local import = objs[1]
					import.Parent = game:GetService("ReplicatedStorage")
					index = {
						{
							name = "wood_sword",
							offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
							model = import:WaitForChild("Wood_Sword"),
						},
						{
							name = "stone_sword",
							offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
							model = import:WaitForChild("Stone_Sword"),
						},
						{
							name = "iron_sword",
							offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
							model = import:WaitForChild("Iron_Sword"),
						},
						{
							name = "diamond_sword",
							offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
							model = import:WaitForChild("Diamond_Sword"),
						},
						{
							name = "emerald_sword",
							offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
							model = import:WaitForChild("Emerald_Sword"),
						}, 
						{
							name = "rageblade",
							offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(90)),
							model = import:WaitForChild("Rageblade"),
						}, 
						   {
							name = "fireball",
									offset = CFrame.Angles(math.rad(0), math.rad(0), math.rad(90)),
							model = import:WaitForChild("Fireball"),
						}, 
						{
							name = "telepearl",
									offset = CFrame.Angles(math.rad(0), math.rad(0), math.rad(90)),
							model = import:WaitForChild("Telepearl"),
						}, 
						{
							name = "wood_bow",
							offset = CFrame.Angles(math.rad(0), math.rad(0), math.rad(90)),
							model = import:WaitForChild("Bow"),
						},
						{
							name = "wood_crossbow",
							offset = CFrame.Angles(math.rad(0), math.rad(0), math.rad(90)),
							model = import:WaitForChild("Crossbow"),
						},
						{
							name = "tactical_crossbow",
							offset = CFrame.Angles(math.rad(0), math.rad(180), math.rad(-90)),
							model = import:WaitForChild("Crossbow"),
						},
							{
							name = "wood_pickaxe",
							offset = CFrame.Angles(math.rad(0), math.rad(-180), math.rad(-95)),
							model = import:WaitForChild("Wood_Pickaxe"),
						},
						{
							name = "stone_pickaxe",
							offset = CFrame.Angles(math.rad(0), math.rad(-180), math.rad(-95)),
							model = import:WaitForChild("Stone_Pickaxe"),
						},
						{
							name = "iron_pickaxe",
							offset = CFrame.Angles(math.rad(0), math.rad(-180), math.rad(-95)),
							model = import:WaitForChild("Iron_Pickaxe"),
						},
						{
							name = "diamond_pickaxe",
							offset = CFrame.Angles(math.rad(0), math.rad(80), math.rad(-95)),
							model = import:WaitForChild("Diamond_Pickaxe"),
						},
					   {
								  
							name = "wood_axe",
							offset = CFrame.Angles(math.rad(0), math.rad(-10), math.rad(-95)),
							model = import:WaitForChild("Wood_Axe"),
						},
						{
							name = "stone_axe",
							offset = CFrame.Angles(math.rad(0), math.rad(-10), math.rad(-95)),
							model = import:WaitForChild("Stone_Axe"),
						},
						{
							name = "iron_axe",
							offset = CFrame.Angles(math.rad(0), math.rad(-10), math.rad(-95)),
							model = import:WaitForChild("Iron_Axe"),
						 },
						 {
							name = "diamond_axe",
							offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-95)),
							model = import:WaitForChild("Diamond_Axe"),
						 },
					
					
					
					 }
					local func = Workspace:WaitForChild("Camera").Viewmodel.ChildAdded:Connect(function(tool)
						if(not tool:IsA("Accessory")) then return end
						for i,v in pairs(index) do
							if(v.name == tool.Name) then
								for i,v in pairs(tool:GetDescendants()) do
									if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
										v.Transparency = 1
									end
								end
								local model = v.model:Clone()
								model.CFrame = tool:WaitForChild("Handle").CFrame * v.offset
								model.CFrame *= CFrame.Angles(math.rad(0),math.rad(-50),math.rad(0))
								model.Parent = tool
								local weld = Instance.new("WeldConstraint",model)
								weld.Part0 = model
								weld.Part1 = tool:WaitForChild("Handle")
								local tool2 = Players.LocalPlayer.Character:WaitForChild(tool.Name)
								for i,v in pairs(tool2:GetDescendants()) do
									if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
										v.Transparency = 1
									end
								end
								local model2 = v.model:Clone()
								model2.Anchored = false
								model2.CFrame = tool2:WaitForChild("Handle").CFrame * v.offset
								model2.CFrame *= CFrame.Angles(math.rad(0),math.rad(-50),math.rad(0))
								model2.CFrame *= CFrame.new(.7,0,-.8)
								model2.Parent = tool2
								local weld2 = Instance.new("WeldConstraint",model)
								weld2.Part0 = model2
								weld2.Part1 = tool2:WaitForChild("Handle")
							end
						end
					end)
				end
			end
		end
	})
	texture_pack_m = texture_pack:CreateDropdown({
		Name = 'Mode',
		List = {
			'Noboline',
			'Aquarium',
			'Ocean'
		},
		Default = 'Noboline',
		Tooltip = 'Mode to render the texture pack.',
		Function = function() end;
	});
end)

run(function()
    local TexturePacksV2 = {Enabled = false}
    local TexturePacksV2_Connections = {}
    local TexturePacksV2_GUI_Elements = {
        Material = {Value = "Forcefield"},
        Color = {Hue = 0, Sat = 0, Value = 0},
        GuiSync = {Enabled = false}
    }

    local function refreshChild(child, children)
        if (not child) then return warn("[refreshChild]: invalid child!") end
        if (not table.find(children, child)) then table.insert(children, child) end
        if child.ClassName == "Accessory" then
            for i, v in pairs(child:GetChildren()) do
                if v.ClassName == "MeshPart" then
                    --v.Material = Enum.Material[TexturePacksV2_GUI_Elements.Material.Value]
					v.Material = Enum.Material.ForceField
                    if TexturePacksV2_GUI_Elements.GuiSync.Enabled and TexturePacksV2.Enabled then
                        if shared.RiseMode and GuiLibrary.GUICoreColor and GuiLibrary.GUICoreColorChanged then
                            v.Color = GuiLibrary.GUICoreColor
							TexturePacksV2:Clean(GuiLibrary.GUICoreColorChanged.Event:Connect(function()
                                if TexturePacksV2_GUI_Elements.GuiSync.Enabled then v.Color = GuiLibrary.GUICoreColor end
                            end))
                        else
                            local color = vape.GUIColor
                            v.Color = Color3.fromHSV(color.Hue, color.Sat, color.Value)
							TexturePacksV2:Clean(runService.Heartbeat:Connect(function()
								if TexturePacksV2_GUI_Elements.GuiSync.Enabled and TexturePacksV2.Enabled then
                                    local color = vape.GUIColor
                                    v.Color = Color3.fromHSV(color.Hue, color.Sat, color.Value)
                                    if TexturePacksV2.Enabled then
                                        color = {Hue = h, Sat = s, Value = v}
                                        v.Color = Color3.fromHSV(color.Hue, color.Sat, color.Value)
                                    end
                                end
							end))
                        end
                    else
                        v.Color = Color3.fromHSV(TexturePacksV2_GUI_Elements.Color.Hue, TexturePacksV2_GUI_Elements.Color.Sat, TexturePacksV2_GUI_Elements.Color.Value)
                    end
                end
            end
        end
    end

    local function refreshChildren()
        local children = gameCamera and gameCamera:FindFirstChild("Viewmodel") and gameCamera:FindFirstChild("Viewmodel").ClassName and gameCamera:FindFirstChild("Viewmodel").ClassName == "Model" and gameCamera:FindFirstChild("Viewmodel"):GetChildren() or {}
        for i, v in pairs(children) do refreshChild(v, children) end
    end

    TexturePacksV2 = vape.Categories.Render:CreateModule({
        Name = "TexturePacksV2",
        Function = function(call)
            if call then
                task.spawn(function()
                    repeat
                        refreshChildren()
                        task.wait()
                    until (not TexturePacksV2.Enabled)
                end)
            else
                for i, v in pairs(TexturePacksV2_Connections) do
                    pcall(function() v:Disconnect() end)
                end
            end
        end
    })

    TexturePacksV2.Restart = function()
        if TexturePacksV2.Enabled then
            TexturePacksV2:Toggle(false)
            TexturePacksV2:Toggle(false)
        end
    end

    TexturePacksV2_GUI_Elements.Material = TexturePacksV2:CreateDropdown({
        Name = "Material",
        Function = refreshChildren,
        List = GetEnumItems("Material"),
        Default = "Forcefield"
    })
	TexturePacksV2_GUI_Elements.Material.Object.Visible = false

    TexturePacksV2_GUI_Elements.Color = TexturePacksV2:CreateColorSlider({
        Name = "Color",
        Function = refreshChildren
    })

    TexturePacksV2_GUI_Elements.GuiSync = TexturePacksV2:CreateToggle({
        Name = "GUI Color Sync",
        Function = TexturePacksV2.Restart,
        Default = true
    })
end)

run(function()
	local GuiLibrary = shared.GuiLibrary
	local size_changer = {};
	local size_changer_d = {};
	local size_changer_h = {};
	local size_changer_v = {};
	size_changer = vape.Categories.Misc:CreateModule({
		Name = 'ToolSizeChanger',
		Tooltip = 'Changes the size of the tools.',
		Function = function(callback) 
			if callback then
				pcall(function()
					lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_DEPTH_OFFSET', -(size_changer_d.Value / 10));
					lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_HORIZONTAL_OFFSET', size_changer_h.Value / 10);
					lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_VERTICAL_OFFSET', size_changer_v.Value / 10);
					bedwars.ViewmodelController:playAnimation((10 / 2) + 6);
				end)
			else
				pcall(function()
					lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_DEPTH_OFFSET', 0);
					lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_HORIZONTAL_OFFSET', 0);
					lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_VERTICAL_OFFSET', 0);
					bedwars.ViewmodelController:playAnimation((10 / 2) + 6);
					cam.Viewmodel.RightHand.RightWrist.C1 = cam.Viewmodel.RightHand.RightWrist.C1;
				end)
			end;
		end;
	});
	size_changer_d = size_changer:CreateSlider({
		Name = 'Depth',
		Min = 0,
		Max = 24,
		Function = function(val)
			if size_changer.Enabled then
				pcall(function()
					lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_DEPTH_OFFSET', -(val / 10));
				end)
			end;
		end,
		Default = 10;
	});
	size_changer_h = size_changer:CreateSlider({
		Name = 'Horizontal',
		Min = 0,
		Max = 24,
		Function = function(val)
			if size_changer.Enabled then
				pcall(function()
					lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_HORIZONTAL_OFFSET', (val / 10));
				end)
			end;
		end,
		Default = 10;
	});
	size_changer_v = size_changer:CreateSlider({
		Name = 'Vertical',
		Min = 0,
		Max = 24,
		Function = function(val)
			if size_changer.Enabled then
				pcall(function()
					lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_VERTICAL_OFFSET', (val / 10));
				end)
			end;
		end,
		Default = 0;
	});
end)

run(function()
    local InvisibilitySystem = {
        Enabled = false
    }
	local InvisibilitySystemConnections = {}
	local InvisibilitySystemConfig = {
		ShowRoot = true,
		RootColor = {Hue = 0, Sat = 0, Val = 1}
	}
	local InvisibilitySystemParts = {}
	local InvisibilitySystemAnimation = nil

    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local lplr = Players.LocalPlayer

    local InvisUtils = {
        disableCollisions = function(character)
            InvisibilitySystemParts = {}
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide and part ~= character:FindFirstChild("HumanoidRootPart") then
                    part.CanCollide = false
                    table.insert(InvisibilitySystemParts, part)
                end
            end
        end,

        setupAnimation = function(character)
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://11335949902"
            local humanoid = character:WaitForChild("Humanoid", 5)
            if humanoid then
                local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
                InvisibilitySystemAnimation = animator:LoadAnimation(anim)
                return InvisibilitySystemAnimation
            end
            return nil
        end,

        updateRootAppearance = function(rootPart)
            if rootPart then
                rootPart.Transparency = InvisibilitySystemConfig.ShowRoot and 0.6 or 1
                rootPart.Color = Color3.fromHSV(
                    InvisibilitySystemConfig.RootColor.Hue,
                    InvisibilitySystemConfig.RootColor.Sat,
                    InvisibilitySystemConfig.RootColor.Val
                )
            end
        end,

        toggleSpider = function(enable)
            local spiderButton = vape.Modules.Spider
            if not spiderButton then return end
            
            if enable and spiderButton.Enabled then
                spiderButton:Toggle(false)
                task.spawn(function()
                    repeat task.wait(0.1) until warningNotification
                    warningNotification("Invisibility", "Spider disabled to prevent suffocation.\nRe-enabled when invisibility ends!", 10)
                end)
                return true
            elseif not enable and not spiderButton.Enabled then
                spiderButton:Toggle(false)
                task.spawn(function()
                    repeat task.wait(0.1) until warningNotification
                    warningNotification("Invisibility", "Spider re-enabled!", 10)
                end)
            end
            return false
        end
    }

    local function applyInvisibility()
        local character = lplr.Character
        if not isAlive(lplr, true) or not character then return end

        InvisUtils.disableCollisions(character)
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local anim = InvisibilitySystemAnimation or InvisUtils.setupAnimation(character)

        table.insert(InvisibilitySystemConnections, character.DescendantAdded:Connect(function(part)
            if part:IsA("BasePart") and part.CanCollide and part ~= rootPart then
                part.CanCollide = false
                table.insert(InvisibilitySystemParts, part)
            end
        end))

        local stepConnection = RunService.Stepped:Connect(function()
            for _, part in pairs(InvisibilitySystemParts) do
                part.CanCollide = false
            end
        end)
        table.insert(InvisibilitySystemConnections, stepConnection)

        while InvisibilitySystem.Enabled and isAlive(lplr, true) and anim do
            if vape.Modules.AnimationPlayer.Enabled then
                vape.Modules.AnimationPlayer:Toggle(false)
            end
            
            InvisUtils.updateRootAppearance(rootPart)
            anim:Play(0.1, 9e9, 0.1)
            task.wait(0.1)
        end

        if anim then
            anim:Stop()
            anim:AdjustSpeed(0)
        end
        stepConnection:Disconnect()
    end

    InvisibilitySystem = vape.Categories.Blatant:CreateModule({
        Name = "Invisibility",
        Tooltip = "Renders you less visible via animation and transparency",
		Function = function(enabled)
            InvisibilitySystem.Enabled = enabled
			if enabled then
				if store.queueType == "halloween_2025_event_pve" then 
					warningNotification("Invisibility", "Disabled in halloween event!", 3)
					Invisibility:Toggle()
					return
				end
                local spiderWasDisabled = InvisUtils.toggleSpider(true)
                
                local taskHandle = task.spawn(applyInvisibility)
                table.insert(InvisibilitySystemConnections, lplr.CharacterAdded:Connect(function()
                    task.cancel(taskHandle)
                    taskHandle = task.spawn(applyInvisibility)
                end))

                InvisibilitySystem.Cleanup = function()
                    if spiderWasDisabled then
                        InvisUtils.toggleSpider(false)
                    end
                    if InvisibilitySystemAnimation then
                        InvisibilitySystemAnimation:Stop()
                        InvisibilitySystemAnimation:AdjustSpeed(0)
                    end
                    for _, conn in pairs(InvisibilitySystemConnections) do
                        pcall(conn.Disconnect, conn)
                    end
                    table.clear(InvisibilitySystemConnections)
                    InvisibilitySystemParts = {}
                end
            else
                if InvisibilitySystem.Cleanup then
                    InvisibilitySystem.Cleanup()
                    InvisibilitySystem.Cleanup = nil
                end
            end
        end
    })

    InvisibilitySystem.RootToggle = InvisibilitySystem:CreateToggle({
        Name = "Show Root Part",
        Default = true,
        Function = function(enabled)
			pcall(function()
				InvisibilitySystemConfig.ShowRoot = enabled
				InvisibilitySystem.RootColor.Object.Visible = enabled
			end)
        end,
        Tooltip = "Toggles visibility of the root part"
    })

    InvisibilitySystem.RootColor = InvisibilitySystem:CreateColorSlider({
        Name = "Root Color",
        Function = function(hue, sat, val)
            InvisibilitySystemConfig.RootColor = {Hue = hue, Sat = sat, Val = val}
        end,
        Default = {Hue = 0, Sat = 0, Val = 1},
        Tooltip = "Sets the color of the root part when visible"
    })

    InvisibilitySystem.RootColor.Object.Visible = InvisibilitySystemConfig.ShowRoot
end)

run(function() 
	local TPExploit = {}
	TPExploit = vape.Categories.Blatant:CreateModule({
		Name = "EmptyGameTP",
		Function = function(calling)
			if calling then 
				TPExploit:Toggle()
				local TeleportService = game:GetService("TeleportService")
				local e2 = TeleportService:GetLocalPlayerTeleportData()
				game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer, e2)
			end
		end,
		WhitelistRequired = 1
	}) 
end)

local GuiLibrary = shared.GuiLibrary
shared.slowmode = 0

local ReportDetector_Cooldown = 0
run(function()
    local ReportDetector = {Enabled = false}
    local HttpService = game:GetService("HttpService")
    local ReportDetector_GUIObjects = {}
    local ReportDetector_Connections = {}

    local function fetchReports(username)
        if not username then return {Suc = false, Error = "Username not specified!"} end
        local url = 'https://detections.vapevoidware.xyz/reportdetector?user=' .. tostring(username)
        local res = request({Url = url, Method = "GET"})

        if res and res.StatusCode == 200 then
            return {Suc = true, Data = res.Body}
        else
            return {Suc = false, Error = "HTTP Error: " .. tostring(res.StatusCode) .. " | " .. tostring(res.Body), StatusCode = res.StatusCode, Body = res.Body}
        end
    end

    local function resolveData(data)
        if not data then return {Suc = false, Error = "No data to resolve"} end
        local suc, decodedData = pcall(function() return HttpService:JSONDecode(data) end)
        if not suc then return {Suc = false, Error = "Failed to decode JSON"} end

        local resolvedReports = {}
        for _, guildData in pairs(decodedData) do
            if guildData.guild_id and guildData.Reports then
                for reportID, report in pairs(guildData.Reports) do
                    table.insert(resolvedReports, {
                        Message = report.content or "No message",
                        AuthorData = {
                            UserID = report.author.id or "Unknown",
                            Username = report.author.username or "Unknown",
                            ReporterHashNumber = report.author.discriminator or "Unknown"
                        },
                        ChannelID = report.channel.id or "Unknown",
                        GuildID = guildData.guild_id
                    })
                end
            end
        end
        return {Suc = true, ResolvedReports = resolvedReports}
    end

    local function convertData(data)
        local convertedData = {}
        for i, v in ipairs(data) do
            table.insert(convertedData, {
                ReportNumber = tostring(i),
                TotalReports = tostring(#data),
                Notifications = {
                    {Title = "ReportInfo - Message/Sender", Message = "[Sender:" .. v.AuthorData.Username .. "#" .. v.AuthorData.ReporterHashNumber .. "] - [Message:" .. v.Message .. "]           ", Duration = 7},
                    {Title = "ReportInfo - ServerInfo", Message = "[ServerID:" .. v.GuildID .. "] - [ChannelID:" .. v.ChannelID .. "]           ", Duration = 7}
                }
            })
        end
        return convertedData
    end

    local function handleError(res)
        local ErrorHandling = {
            ["404"] = "Critical error in the API endpoint!",
            ["400"] = "No username specified! Contact erchodev#0 on discord.",
            ["500"] = "Critical server error! Try again later.",
            ["429"] = "You are being rate-limited. Please wait."
        }
        local message = ErrorHandling[tostring(res.StatusCode)] or "Unknown error! StatusCode: " .. tostring(res.StatusCode)
        errorNotification("ReportDetector_ErrorHandler ["..tostring(res.StatusCode).."]", message, 10)
    end

    local function getPlayers()
        local plrs = {}
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            table.insert(plrs, player.Name)
        end
        return plrs
    end

    local function createGUIElement(api, argsTbl)
        local name = argsTbl.GUI_Name
        local creationType = argsTbl.GUI_Args.Type
        local creationArgs = argsTbl.GUI_Args.Creation_Args

        ReportDetector_GUIObjects[name] = api[creationType](api, creationArgs)
    end

	local function getObject(name)
		return ReportDetector_GUIObjects[name] and ReportDetector_GUIObjects[name].Object
	end

    local Methods_Functions = {
        ["Self"] = function() getObject("ServerUsername").Visible = false; getObject("CustomUsername").Visible = false end,
        ["Server"] = function() getObject("ServerUsername").Visible = true; getObject("CustomUsername").Visible = false end,
        ["Global"] = function() getObject("ServerUsername").Visible = false; getObject("CustomUsername").Visible = true end,
    }

	local function getUsername()
		local CorresponderTable = {
			["Self"] = nil,
			["Server"] = "ServerUsername",
			["Global"] = "CustomUsername"
		}
		local val = ReportDetector_GUIObjects["Mode"].Value
		local function verifyVal(value) if value ~= nil and value ~= "" then return true, value else return false, value end end
		if val ~= "Self" then 
			local suc, res = verifyVal(ReportDetector_GUIObjects[CorresponderTable[val]].Value)
			if suc then return res else return nil, {Step = 1, ErrorInfo = "Invalid value!", Debug = {Type = val, Res = tostring(res)}} end
		else
			return game:GetService("Players").LocalPlayer.Name
		end
	end

	ReportDetector = vape.Categories.Utility:CreateModule({
		Name = "ReportDetector",
		Function = function(call)
			if call then
				ReportDetector:Toggle(false)
				local targetUsername, errorInfo = getUsername()
				if (not targetUsername) then return errorNotification("ReportDetector_ErrorHandler_V2", game:GetService("HttpService"):JSONEncode(errorInfo), 10) end
				warningNotification("ReportDetector", "Request sent to VW API for user: "..tostring(targetUsername).."!           ", 3)
				local res = fetchReports(targetUsername)
				if res.Suc then
					local resolvedData = resolveData(res.Data)
					if resolvedData.Suc then
						local convertedData = convertData(resolvedData.ResolvedReports)
                        local saveTable = {}
						for _, report in ipairs(convertedData) do
							for _, notification in ipairs(report.Notifications) do
                                saveTable["[Report #" .. report.ReportNumber .. "/" .. report.TotalReports .. "]"] = saveTable["[Report #" .. report.ReportNumber .. "/" .. report.TotalReports .. "]"] or {}
                                table.insert(saveTable["[Report #" .. report.ReportNumber .. "/" .. report.TotalReports .. "]"], {
                                    Title = notification.Title,
                                    Message = notification.Message
                                })
								warningNotification("[Report #" .. report.ReportNumber .. "/" .. report.TotalReports .. "] " .. notification.Title, notification.Message, notification.Duration)
							end
						end
						if #convertedData < 1 then warningNotification("ReportDetector", "No reports found for " .. targetUsername .. "!", 10) end
                        writefile("ReportDetectorLog.json", game:GetService("HttpService"):JSONEncode(saveTable))
                        warningNotification("ReportDetector_LogSaver", "Successfully saved the report logs to ReportDetectorLog.json in your \n executor's game.Workspace folder!", 10)
					else
						errorNotification("ReportDetector", "Data sorting failed: " .. resolvedData.Error, 10)
					end
				else
					handleError(res)
					errorNotification("ReportDetector", "Failed to fetch reports: " .. res.Error, 10)
				end
			end
		end,
		Tooltip = "Detects if anyone has reported you."
	})
	local GUI_Elements = {
		{GUI_Name = "Mode", GUI_Args = {Type = "CreateDropdown", Arg = {Value = "Self"}, Creation_Args = {Name = "Mode", List = {"Self", "Server", "Global"}, Function = function(val) Methods_Functions[val]() end}}},
		{GUI_Name = "ServerUsername", GUI_Args = {Type = "CreateDropdown", Arg = {Value = game:GetService("Players").LocalPlayer.Name}, Creation_Args = {Name = "Players", List = getPlayers(), Function = function() end}}},
		{GUI_Name = "CustomUsername", GUI_Args = {Type = "CreateTextBox", Arg = {Value = game:GetService("Players").LocalPlayer.Name}, Creation_Args = {Name = "Username", TempText = "Type here a username", Function = function() end}}}
	}

	for _, element in ipairs(GUI_Elements) do
		createGUIElement(ReportDetector, element)
	end
end)

if CustomsAllowed then
	run(function()
		local ItemSpawner = {Enabled = false}
		local spawnedItems = {}
		local chattedConnection
		local function getInv(plr) return plr.Character and plr.Character:FindFirstChild("InventoryFolder") and plr.Character:FindFirstChild("InventoryFolder").Value end
		local ArmorIncluded = {Enabled = false}
		local ProjectilesIncluded = {Enabled = false}
		local ItemsIncluded = {Enabled = false}
		local StrictMatch = {Enabled = false}
		local function getRepItems()
			local tbl = {"Armor", "Projectiles"}
			local a = ItemsIncluded.Enabled and game:GetService("ReplicatedStorage"):FindFirstChild("Items") and game:GetService("ReplicatedStorage"):FindFirstChild("Items"):GetChildren() or {}
			local b = ArmorIncluded.Enabled and game:GetService("ReplicatedStorage"):FindFirstChild("Assets") and game:GetService("ReplicatedStorage"):FindFirstChild("Assets"):FindFirstChild(tbl[1]) and game:GetService("ReplicatedStorage"):FindFirstChild("Assets"):FindFirstChild(tbl[1]):GetChildren() or {}
			local c = ProjectilesIncluded.Enabled and game:GetService("ReplicatedStorage"):FindFirstChild("Assets") and game:GetService("ReplicatedStorage"):FindFirstChild("Assets"):FindFirstChild(tbl[2]) and game:GetService("ReplicatedStorage"):FindFirstChild("Assets"):FindFirstChild(tbl[2]):GetChildren() or {}
			
			local fullTbl = {}
			local d = {a,b,c}
			for i,v in pairs(d) do for i2,v2 in pairs(v) do table.insert(fullTbl, v2) end end
			return fullTbl
		end
		local inv, repItems
		local function getRepItem(name)
			repItems = getRepItems()
			for i,v in pairs(repItems) do if v.Name and ((StrictMatch.Enabled and v.Name == name) or ((not StrictMatch.Enabled) and string.find(v.Name, name))) then return v end end
			return nil
		end
		local function getSpawnedItem(name)
			for i,v in pairs(spawnedItems) do if v.Name and ((StrictMatch.Enabled and v.Name == name) or ((not StrictMatch.Enabled) and string.find(v.Name, name))) then return v end end
			return nil
		end
		ItemSpawner = vape.Categories.Utility:CreateModule({
			Name = "ItemSpawner (CS)",
			Function = function(call)
				if call then
					task.spawn(function() repeat task.wait(0.1); inv = getInv(game:GetService("Players").LocalPlayer) until inv end)
					task.spawn(function() repeat task.wait(0.1); repItems = getRepItems() until repItems end)
					chattedConnection = game:GetService("Players").LocalPlayer.Chatted:Connect(function(msg)
						local parts = string.split(msg, " ")
						if parts[1] == "/e" then
							if parts[2] == "spawn" then
								inv, repItems = getInv(game:GetService("Players").LocalPlayer), getRepItems()
								if parts[3] then
									local item = getRepItem(parts[3])
									if item then
										local amount, newItem = tonumber(parts[4]) or 1, item:Clone()
										newItem.Parent = inv
										pcall(function() newItem:SetAttribute("Amount", amount) end)
										pcall(function() newItem:SetAttribute("CustomSpawned", true) end)
										pcall(function() bedwars.StoreController:updateLocalInventory() end)
										table.insert(spawnedItems, newItem)
									else errorNotification("ItemSpawner", tostring(parts[3]).." is not a valid item name!", 3) end
								end
							elseif parts[2] == "despawn" then
								inv, repItems = getInv(game:GetService("Players").LocalPlayer), getRepItems()
								if parts[3] then
									local item = getSpawnedItem(parts[3])
									if item then 
										table.remove(spawnedItems, table.find(spawnedItems, item))
										pcall(function() item:Destroy() end)
										pcall(function() bedwars.StoreController:updateLocalInventory() end)
									end
								else errorNotification("ItemSpawner", tostring(parts[3]).." is not a valid item name!", 3) end
							end
						end
					end)
				else
					pcall(function() chattedConnection:Disconnect() end)
					pcall(function() chattedConnection:Disconnect() end)
					for i,v in pairs(spawnedItems) do pcall(function() v:Destroy() end) end
				end
			end
		})
		ItemSpawner.Restart = function() if ItemSpawner.Enabled then ItemSpawner:Toggle(false); ItemSpawner:Toggle(false) end end
		StrictMatch = ItemSpawner:CreateToggle({ Name = "StrictMatch", Function = ItemSpawner.Restart, Default = true})
		ItemsIncluded = ItemSpawner:CreateToggle({Name = "ItemsIncluded", Function = ItemSpawner.Restart, Default = true})
		ProjectilesIncluded = ItemSpawner:CreateToggle({Name = "ProjectilesIncluded", Function = ItemSpawner.Restart, Default = true})
		ArmorIncluded = ItemSpawner:CreateToggle({Name = "ArmorIncluded", Function = ItemSpawner.Restart, Default = true})
	end)
end

local isAlive = function(plr, healthblacklist)
	plr = plr or lplr
	local alive = false 
	if plr.Character and plr.Character.PrimaryPart and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("Head") then 
		alive = true
	end
	if not healthblacklist and alive and plr.Character.Humanoid.Health and plr.Character.Humanoid.Health <= 0 then 
		alive = false
	end
	return alive
end
local function fetchTeamMembers()
	local plrs = {}
	for i,v in pairs(game:GetService("Players"):GetPlayers()) do if v.Team == lplr.Team then table.insert(plrs, v) end end
	return plrs
end
local function isEveryoneDead()
	if #fetchTeamMembers() > 0 then
		for i,v in pairs(fetchTeamMembers()) do
			local plr = playersService:FindFirstChild(v.name)
			if plr and isAlive(plr, true) then
				return false
			end
		end
		return true
	else
		return true
	end
end

run(function()
    local anim
	local asset
	local lastPosition
    local NightmareEmote
	NightmareEmote = vape.Categories.World:CreateModule({
		Name = "NightmareEmote",
		Function = function(call)
			if call then
				local l__GameQueryUtil__8
				if (not shared.CheatEngineMode) then 
					l__GameQueryUtil__8 = require(game:GetService("ReplicatedStorage")['rbxts_include']['node_modules']['@easy-games']['game-core'].out).GameQueryUtil 
				else
					local backup = {}; function backup:setQueryIgnored() end; l__GameQueryUtil__8 = backup;
				end
				local l__TweenService__9 = game:GetService("TweenService")
				local player = game:GetService("Players").LocalPlayer
				local p6 = player.Character
				
				if not p6 then NightmareEmote:Toggle() return end
				
				local v10 = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Effects"):WaitForChild("NightmareEmote"):Clone();
				asset = v10
				v10.Parent = game.Workspace
				lastPosition = p6.PrimaryPart and p6.PrimaryPart.Position or Vector3.new()
				
				task.spawn(function()
					while asset ~= nil do
						local currentPosition = p6.PrimaryPart and p6.PrimaryPart.Position
						if currentPosition and (currentPosition - lastPosition).Magnitude > 0.1 then
							asset:Destroy()
							asset = nil
							NightmareEmote:Toggle()
							break
						end
						lastPosition = currentPosition
						v10:SetPrimaryPartCFrame(p6.LowerTorso.CFrame + Vector3.new(0, -2, 0));
						task.wait()
					end
				end)
				
				local v11 = v10:GetDescendants();
				local function v12(p8)
					if p8:IsA("BasePart") then
						l__GameQueryUtil__8:setQueryIgnored(p8, true);
						p8.CanCollide = false;
						p8.Anchored = true;
					end;
				end;
				for v13, v14 in ipairs(v11) do
					v12(v14, v13 - 1, v11);
				end;
				local l__Outer__15 = v10:FindFirstChild("Outer");
				if l__Outer__15 then
					l__TweenService__9:Create(l__Outer__15, TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
						Orientation = l__Outer__15.Orientation + Vector3.new(0, 360, 0)
					}):Play();
				end;
				local l__Middle__16 = v10:FindFirstChild("Middle");
				if l__Middle__16 then
					l__TweenService__9:Create(l__Middle__16, TweenInfo.new(12.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
						Orientation = l__Middle__16.Orientation + Vector3.new(0, -360, 0)
					}):Play();
				end;
                anim = Instance.new("Animation")
				anim.AnimationId = "rbxassetid://9191822700"
				anim = p6.Humanoid:LoadAnimation(anim)
				anim:Play()
			else 
                if anim then 
					anim:Stop()
					anim = nil
				end
				if asset then
					asset:Destroy() 
					asset = nil
				end
			end
		end
	})
end)

--[[if not shared.CheatEngineMode then
	run(function()
		local AntiLagback = {Enabled = false}
		local control_module = require(lplr:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")).controls
		local old = control_module.moveFunction
		local clone
		local connection
		local function clone_lplr_char()
			if not (lplr.Character ~= nil and lplr.Character.PrimaryPart ~= nil) then return nil end
			lplr.Character.Archivable = true
		
			local clone = lplr.Character:Clone()
		
			clone.Parent = game.Workspace
			clone.Name = "Clone"
		
			clone.PrimaryPart.CFrame = lplr.Character.PrimaryPart.CFrame
		
			gameCamera.CameraSubject = clone.Humanoid	
		
			task.spawn(function()
				for i, v in next, clone:FindFirstChild("Head"):GetDescendants() do
					v:Destroy()
				end
				for i, v in next, clone:GetChildren() do
					if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
						v.Transparency = 1
					end
					if v:IsA("Accessory") then
						v:FindFirstChild("Handle").Transparency = 1
					end
				end
			end)
			return clone
		end
		local function bypass()
			clone = clone_lplr_char()
			if not entitylib.isAlive then return AntiLagback:Toggle() end
			if not clone then return AntiLagback:Toggle() end
			control_module.moveFunction = function(self, vec, ...)
				local RaycastParameters = RaycastParams.new()
	
				RaycastParameters.FilterType = Enum.RaycastFilterType.Include
				RaycastParameters.FilterDescendantsInstances = {CollectionService:GetTagged("block")}
	
				local LookVector = Vector3.new(gameCamera.CFrame.LookVector.X, 0, gameCamera.CFrame.LookVector.Z).Unit
	
				if clone.PrimaryPart then
					local Raycast = game.Workspace:Raycast((clone.PrimaryPart.Position + LookVector), Vector3.new(0, -1000, 0), RaycastParameters)
					local Raycast2 = game.Workspace:Raycast(((clone.PrimaryPart.Position - Vector3.new(0, 15, 0)) + (LookVector * 3)), Vector3.new(0, -1000, 0), RaycastParameters)
	
					if Raycast or Raycast2 then
						clone.PrimaryPart.CFrame = CFrame.new(clone.PrimaryPart.Position + (LookVector / (GetSpeed())))
						vec = LookVector
					end
	
					if (not clone) and entitylib.isAlive then
						control_module.moveFunction = OldMoveFunction
						gameCamera.CameraSubject = lplr.Character.Humanoid
					end
				end
	
				return old(self, vec, ...)
			end
		end
		local function safe_revert()
			control_module.moveFunction = old
			if entitylib.isAlive then
				gameCamera.CameraSubject = lplr.Character:WaitForChild("Humanoid")
			end
						pcall(function()
				clone:Destroy()
			end)
		end
		AntiLagback = vape.Categories.Blatant:CreateModule({
			Name = "AntiLagback",
			Function = function(call)
				if call then
					connection = lplr:GetAttributeChangedSignal("LastTeleported"):Connect(function()
						if entitylib.isAlive and store.matchState ~= 0 and not lplr.Character:FindFirstChildWhichIsA("ForceField") and (not vape.Modules.BedTP.Enabled) and (not vape.Modules.PlayerTP.Enabled) then					
							bypass()
							task.wait(4.5)
							safe_revert()
						end 
					end)
				else
					pcall(function() connection:Disconnect() end)
					control_module.moveFunction = old
					if entitylib.isAlive then
						gameCamera.CameraSubject = lplr.Character:WaitForChild("Humanoid")
					end
					pcall(function() clone:Destroy() end)
				end
			end
		})
	end)
end--]]

run(function()
	local Maid = {}
	Maid.__index = Maid
	
	function Maid.new()
		return setmetatable({ Tasks = {} }, Maid)
	end
	
	function Maid:Add(task)
		if typeof(task) == "RBXScriptConnection" or
		   (typeof(task) == "Instance" and task.Destroy) or
		   typeof(task) == "function" or
		   (typeof(task) == "table" and (task.Destroy or task.Disconnect)) then
			table.insert(self.Tasks, task)
		else
			warn("[Maid] Invalid task type: " .. typeof(task))
		end
		return task
	end
	
	function Maid:Clean()
		for _, task in ipairs(self.Tasks) do
			local success, errorMsg = pcall(function()
				if typeof(task) == "RBXScriptConnection" then
					task:Disconnect()
				elseif typeof(task) == "Instance" then
					task:Destroy()
				elseif typeof(task) == "function" then
					task()
				elseif typeof(task) == "table" then
					if task.Destroy then
						task:Destroy()
					elseif task.Disconnect then
						task:Disconnect()
					end
							end
						end)
			if not success then
				warn("[Maid] Error cleaning task: " .. tostring(errorMsg))
			end
		end
		table.clear(self.Tasks)
	end
	
	local Services = setmetatable({}, {
		__index = function(self, key)
			local suc, service = pcall(game.GetService, game, key)
			if suc and service then
				self[key] = service
				return service
			else
				warn(`[Services] Warning: "{key}" is not a valid Roblox service.`)
				return nil
			end
		end
	})
	
    local Players = Services.Players
    local Workspace = Services.Workspace
    local maid = Maid.new()
    local BetterSpectator = { Enabled = false }
    local Choice = { Value = Players.LocalPlayer.Name }
    local playerConnections = {} 
    local connectedPlayerMaid = nil 
    local localCharacter = nil
    local refreshDebounce = false 
    local lastRefreshTime = 0 

    local function getPlayerList()
        local playerList = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and player.Character:IsDescendantOf(Workspace) and player.Character.ClassName == "Model" then
                table.insert(playerList, player.Name)
            end
        end
        return playerList
    end

    local function findLocalCharacter()
        if localCharacter and localCharacter:IsDescendantOf(Workspace) and localCharacter.Name == Players.LocalPlayer.Name then
            return localCharacter
        end
        local char = Workspace:FindFirstChild(Players.LocalPlayer.Name)
        if char and char.ClassName == "Model" then
            localCharacter = char
            return char
        end
        return nil
    end

    local function saveLocalCharacter()
        local char = Players.LocalPlayer.Character
        if char and char:IsDescendantOf(Workspace) and char.ClassName == "Model" and char.Name == Players.LocalPlayer.Name then
            localCharacter = char
        else
            localCharacter = findLocalCharacter()
        end
    end

    local function connectPlayer(player)
        if playerConnections[player] then
            playerConnections[player]:Clean()
        end
        local playerMaid = Maid.new()
        playerMaid:Add(player.CharacterAdded:Connect(function()
            if not refreshDebounce then
                refreshChoices()
            end
					end))
        playerMaid:Add(player.CharacterRemoving:Connect(function()
            if not refreshDebounce then
                refreshChoices()
            end
        end))
        playerConnections[player] = playerMaid
    end

    local function clearConnections()
        for _, connectionMaid in pairs(playerConnections) do
            connectionMaid:Clean()
        end
        table.clear(playerConnections)
    end

    local function initiatePlayers()
        clearConnections()
        for _, player in ipairs(Players:GetPlayers()) do
            connectPlayer(player)
        end
    end

    local function updateChoice(playerName)
        local player = Players:FindFirstChild(playerName)
        if not player or not player.Character or not player.Character:IsDescendantOf(Workspace) then
            warningNotification("BetterSpectator", "Selected player is invalid or has no character.", 2)
            Choice.Value = Players.LocalPlayer.Name
            Players.LocalPlayer.Character = findLocalCharacter()
            if connectedPlayerMaid then
                connectedPlayerMaid:Clean()
                connectedPlayerMaid = nil
            end
            return
        end

        saveLocalCharacter()
        Players.LocalPlayer.Character = player.Character

        if connectedPlayerMaid then
            connectedPlayerMaid:Clean()
        end
        connectedPlayerMaid = Maid.new()
        connectedPlayerMaid:Add(player.CharacterRemoving:Connect(function()
            Players.LocalPlayer.Character = findLocalCharacter()
            warningNotification("BetterSpectator", "Spectated player died. Waiting for respawn...", 2)
        end))
        connectedPlayerMaid:Add(player.CharacterAdded:Connect(function(newChar)
            saveLocalCharacter()
            Players.LocalPlayer.Character = newChar
            InfoNotification("BetterSpectator", "Spectated player respawned.", 2)
        end))

        InfoNotification("BetterSpectator", "Now spectating " .. player.Name .. ".", 2)
    end

    function refreshChoices()
        if refreshDebounce or tick() - lastRefreshTime < 0.5 then
            return
        end
        refreshDebounce = true
        lastRefreshTime = tick()

        local playerList = getPlayerList()
        Choice:Change(playerList)
        initiatePlayers()

        if BetterSpectator.Enabled and Choice.Value ~= Players.LocalPlayer.Name then
            updateChoice(Choice.Value)
        else
            Players.LocalPlayer.Character = findLocalCharacter()
            if connectedPlayerMaid then
                connectedPlayerMaid:Clean()
                connectedPlayerMaid = nil
            end
        end

        refreshDebounce = false
    end

    BetterSpectator = vape.Categories.Utility:CreateModule({
        Name = "BetterSpectator",
        Function = function(enabled)
            if enabled then
                BetterSpectator.Enabled = true
                initiatePlayers()
                maid:Add(Players.PlayerAdded:Connect(function(player)
                    connectPlayer(player)
                    refreshChoices()
                end))
                maid:Add(Players.PlayerRemoving:Connect(function(player)
                    if playerConnections[player] then
                        playerConnections[player]:Clean()
                        playerConnections[player] = nil
                    end
                    if Choice.Value == player.Name then
                        Choice.Value = Players.LocalPlayer.Name
                        updateChoice(Choice.Value)
                    end
                    refreshChoices()
                end))
                maid:Add(clearConnections)
                maid:Add(function()
                    if connectedPlayerMaid then
                        connectedPlayerMaid:Clean()
                        connectedPlayerMaid = nil
                    end
                    Players.LocalPlayer.Character = findLocalCharacter()
                    Choice.Value = Players.LocalPlayer.Name
                end)
                refreshChoices()
            else
                BetterSpectator.Enabled = false
                maid:Clean()
            end
        end,
        Tooltip = "Allows spectating other players by switching your character's perspective."
    })

    Choice = BetterSpectator:CreateDropdown({
        Name = "Player",
        List = getPlayerList(),
        Default = Players.LocalPlayer.Name,
        Function = function(value)
            Choice.Value = value
            if BetterSpectator.Enabled then
                updateChoice(value)
			end
		end
	})
end)

shared.slowmode = 0
run(function()
    local HttpService = game:GetService("HttpService")
    local StaffDetectionSystem = {
        Enabled = false
    }
    local StaffDetectionSystemConfig = {
        GameMode = "Bedwars",
        CustomGroupEnabled = false,
        IgnoreOnline = false,
        AutoCheck = false,
        MemberLimit = 50,
        CustomGroupId = "",
        CustomRoles = {}
    }
    local StaffDetectionSystemStaffData = {
        Games = {
            Bedwars = {groupId = 5774246, roles = {79029254, 86172137, 43926962, 37929139, 87049509, 37929138}},
            PS99 = {groupId = 5060810, roles = {33738740, 33738765}}
        },
        Detected = {}
    }

    local DetectionUtils = {
        resetSlowmode = function() end,
        fetchUsersInRole = function() end,
        fetchUserPresence = function() end,
        fetchGroupRoles = function() end,
        getDetectionConfig = function() end,
        scanStaff = function() end
    }

    DetectionUtils = {
        resetSlowmode = function()
            task.spawn(function()
                while shared.slowmode > 0 do
                    shared.slowmode = shared.slowmode - 1
                    task.wait(1)
                end
                shared.slowmode = 0
            end)
        end,

        fetchUsersInRole = function(groupId, roleId, cursor)
            local url = string.format("https://groups.roblox.com/v1/groups/%d/roles/%d/users?limit=%d%s", groupId, roleId, StaffDetectionSystemConfig.MemberLimit, cursor and "&cursor=" .. cursor or "")
            local success, response = pcall(function()
                return request({Url = url, Method = "GET"})
            end)
            return success and HttpService:JSONDecode(response.Body) or {}
        end,

        fetchUserPresence = function(userIds)
            local success, response = pcall(function()
                return request({
                    Url = "https://presence.roblox.com/v1/presence/users",
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode({userIds = userIds})
                })
            end)
            return success and HttpService:JSONDecode(response.Body) or {userPresences = {}}
        end,

        fetchGroupRoles = function(groupId)
            local success, response = pcall(function()
                return request({
                    Url = "https://groups.roblox.com/v1/groups/" .. groupId .. "/roles",
                    Method = "GET"
                })
            end)
            if success and response.StatusCode == 200 then
                local roles = {}
                for _, role in pairs(HttpService:JSONDecode(response.Body).roles) do
                    table.insert(roles, role.id)
                end
                return true, roles
            end
            return false, nil, "Failed to fetch roles: " .. (success and response.StatusCode or "Network error")
        end,

        getDetectionConfig = function()
            if StaffDetectionSystemConfig.CustomGroupEnabled then
                if not StaffDetectionSystemConfig.CustomGroupId or StaffDetectionSystemConfig.CustomGroupId == "" then
                    return false, nil, "Custom Group ID not specified", false, nil, "Custom"
                end
                if #StaffDetectionSystemConfig.CustomRoles == 0 then
                    return true, tonumber(StaffDetectionSystemConfig.CustomGroupId), nil, false, nil, "Custom roles not specified"
                end
                local success, roles, error = DetectionUtils.fetchGroupRoles(StaffDetectionSystemConfig.CustomGroupId)
                return true, tonumber(StaffDetectionSystemConfig.CustomGroupId), nil, success, roles, error, "Custom"
            else
                local gameData = StaffDetectionSystemStaffData.Games[StaffDetectionSystemConfig.GameMode]
                return true, gameData.groupId, nil, true, gameData.roles, nil, "Normal"
            end
        end,

        scanStaff = function(groupId, roleId)
            local users, userIds = {}, {}
            local cursor = nil
            repeat
                local data = DetectionUtils.fetchUsersInRole(groupId, roleId, cursor)
                for _, user in pairs(data.data or {}) do
                    table.insert(users, user)
                    table.insert(userIds, user.userId)
                end
                cursor = data.nextPageCursor
            until not cursor

            local presenceData = DetectionUtils.fetchUserPresence(userIds)
            for _, user in pairs(users) do
                for _, presence in pairs(presenceData.userPresences) do
                    if user.userId == presence.userId then
                        user.presenceType = presence.userPresenceType
                        user.lastLocation = presence.lastLocation
                        break
                    end
                end
            end
            return users
        end
    }

    local function processStaffCheck()
        if shared.slowmode > 0 and not StaffDetectionSystemConfig.AutoCheck then
            errorNotification("StaffDetector", "Slowmode active! Wait " .. shared.slowmode .. " seconds", shared.slowmode)
            return
        end

        shared.slowmode = 5
        DetectionUtils.resetSlowmode()
        InfoNotification("StaffDetector", "Checking staff presence...", 5)

        local groupSuccess, groupId, groupError, rolesSuccess, roles, rolesError, mode = DetectionUtils.getDetectionConfig()
        if not groupSuccess or not rolesSuccess then
            shared.slowmode = 0
            if groupError then errorNotification("StaffDetector", groupError, 5) end
            if rolesError then errorNotification("StaffDetector", rolesError, 5) end
            return
        end

        local detectedStaff, uniqueIds = {}, {}
        for _, roleId in pairs(roles) do
            for _, user in pairs(DetectionUtils.scanStaff(groupId, roleId)) do
				local resolve = {
					["Offline"] = '<font color="rgb(128,128,128)">Offline</font>',
					["Online"] = '<font color="rgb(0,255,0)">Online</font>',
					["In Game"] = '<font color="rgb(16, 150, 234)">In Game</font>',
					["In Studio"] = '<font color="rgb(255,165,0)">In Studio</font>'
				}
                local status = ({
                    [0] = "Offline",
                    [1] = "Online",
                    [2] = "In Game",
                    [3] = "In Studio"
                })[user.presenceType or 0]

                if (status == "In Game" or (not StaffDetectionSystemConfig.IgnoreOnline and status == "Online")) and
                   not table.find(uniqueIds, user.userId) then
                    table.insert(uniqueIds, user.userId)
                    local userData = {UserID = tostring(user.userId), Username = user.username, Status = status}
                    if not table.find(detectedStaff, userData) then
                        table.insert(detectedStaff, userData)
                        errorNotification("StaffDetector", "@" .. userData.Username .. "(" .. userData.UserID .. ") is " .. resolve[status], 7)
                    end
                end
            end
        end
        InfoNotification("StaffDetector", #detectedStaff .. " staff members detected online/in-game!", 7)
    end

    StaffDetectionSystem = vape.Categories.Utility:CreateModule({
        Name = 'StaffFetcher - Roblox',
        Function = function(enabled)
            StaffDetectionSystem.Enabled = enabled
            if enabled then
                if StaffDetectionSystemConfig.AutoCheck then
                    task.spawn(function()
                        repeat
                            processStaffCheck()
                            task.wait(30)
                        until not StaffDetectionSystem.Enabled or not StaffDetectionSystemConfig.AutoCheck
                        StaffDetectionSystem:Toggle(false)
                    end)
                else
                    processStaffCheck()
                    StaffDetectionSystem:Toggle(false)
                end
            end
        end
    })

    local StaffDetectionSystemUI = {}

    local gameList = {}
    for game in pairs(StaffDetectionSystemStaffData.Games) do table.insert(gameList, game) end
    StaffDetectionSystemUI.GameSelector = StaffDetectionSystem:CreateDropdown({
        Name = "Game Mode",
        Function = function(value) StaffDetectionSystemConfig.GameMode = value end,
        List = gameList
    })

    StaffDetectionSystemUI.RolesList = StaffDetectionSystem:CreateTextList({
        Name = "Custom Roles",
        TempText = "Role ID (number)",
        Function = function(values) StaffDetectionSystemConfig.CustomRoles = values end
    })

    StaffDetectionSystemUI.GroupIdInput = StaffDetectionSystem:CreateTextBox({
        Name = "Custom Group ID",
        TempText = "Group ID (number)",
        Function = function(value) StaffDetectionSystemConfig.CustomGroupId = value end
    })

    StaffDetectionSystem:CreateToggle({
        Name = "Custom Group",
        Function = function(enabled)
            StaffDetectionSystemConfig.CustomGroupEnabled = enabled
            StaffDetectionSystemUI.GroupIdInput.Object.Visible = enabled
            StaffDetectionSystemUI.RolesList.Object.Visible = enabled
            StaffDetectionSystemUI.GameSelector.Object.Visible = not enabled
        end,
        Tooltip = "Use a custom staff group",
        Default = false
    })

    StaffDetectionSystem:CreateToggle({
        Name = "Ignore Online Staff",
        Function = function(enabled) StaffDetectionSystemConfig.IgnoreOnline = enabled end,
        Tooltip = "Only show in-game staff, ignoring online staff",
        Default = false
    })

    StaffDetectionSystem:CreateSlider({
        Name = "Member Limit",
        Min = 1,
        Max = 100,
        Function = function(value) StaffDetectionSystemConfig.MemberLimit = value end,
        Default = 50
    })

    StaffDetectionSystem:CreateToggle({
        Name = "Auto Check",
        Function = function(enabled)
            StaffDetectionSystemConfig.AutoCheck = enabled
            if enabled and shared.slowmode > 0 then
                errorNotification("StaffDetector", "Disable Auto Check to use manually during slowmode!", 5)
            end
        end,
        Tooltip = "Automatically check every 30 seconds",
        Default = false
    })

    StaffDetectionSystemUI.GroupIdInput.Object.Visible = false
    StaffDetectionSystemUI.RolesList.Object.Visible = false
end)

if not shared.CheatEngineMode then
	local inputService = game:GetService('UserInputService')
	local isMobile = inputService.TouchEnabled and not inputService.KeyboardEnabled and not inputService.MouseEnabled
	run(function()
		local controller
		local LegacyLayout = {Enabled = false}
		LegacyLayout = vape.Categories.World:CreateModule({
			Name = "LegacyLayout",
			Function = function(call)
				if not controller then
					controller = require(game:GetService("ReplicatedStorage").rbxts_include.node_modules["@flamework"].core.out).Flamework.resolveDependency("@easy-games/game-core:client/controllers/ability/ability-controller@AbilityController").mobileAbilityUIController.mobileLayoutController
				end
				if call and not isMobile then
					warningNotification("LegacyLayout", "Mobile devices only!", 3)
					--LegacyLayout:Toggle(false)
				end
				controller:setIsLegacyMode(call)
			end
		})
	end)
end

run(function()
	local a = {Enabled = false}
	a = vape.Categories.World:CreateModule({
		Name = "Leave Party",
		Function = function(call)
			if call then
				a:Toggle(false)
				game:GetService("ReplicatedStorage"):WaitForChild("events-@easy-games/lobby:shared/event/lobby-events@getEvents.Events"):WaitForChild("leaveParty"):FireServer()
			end
		end
	})
end)

if not shared.CheatEngineMode then
	run(function()
		local KnitInit, Knit
		repeat
			KnitInit, Knit = pcall(function()
				return debug.getupvalue(require(game:GetService("Players").LocalPlayer.PlayerScripts.TS.knit).setup, 9)
			end)
			if KnitInit then break end
			task.wait()
		until KnitInit

		if not debug.getupvalue(Knit.Start, 1) then
			repeat task.wait() until debug.getupvalue(Knit.Start, 1)
		end

		local Players = game:GetService("Players")

		shared.PERMISSION_CONTROLLER_HASANYPERMISSIONS_REVERT = shared.PERMISSION_CONTROLLER_HASANYPERMISSIONS_REVERT or Knit.Controllers.PermissionController.hasAnyPermissions
		shared.MATCH_CONTROLLER_GETPLAYERPARTY_REVERT = shared.MATCH_CONTROLLER_GETPLAYERPARTY_REVERT or Knit.Controllers.MatchController.getPlayerParty

		local AC_MOD_View = {
			playerConnections = {},
			Enabled = false,
			Friends = {}, 
			parties = {}, 
			teamMap = {}, 
			display = {},
			isRefreshing = false,
			cacheDirty = true,
			disable_disguises = false,
			disguises = {},
			teamData = {}
		}

		AC_MOD_View.controller = Knit.Controllers.PermissionController
		AC_MOD_View.match_controller = Knit.Controllers.MatchController

		function AC_MOD_View:getPartyById(displayId)
			if not displayId then return end
			displayId = tostring(displayId)
			if self.display[displayId] then return self.display[displayId] end
			for _, party in pairs(self.parties) do
				if party.displayId == tostring(displayId) then
					self.display[displayId] = party
					return party
				end
			end
		end

		function AC_MOD_View:refreshDisplayCache()
			for _, plr in pairs(Players:GetPlayers()) do
				local playerId = tostring(plr.UserId)

				local playerPartyId = self.teamMap[playerId]
				if playerPartyId ~= nil then
					self:getPartyById(playerPartyId)
				end
				task.wait()
			end
		end

		function AC_MOD_View:refreshDisplayCacheAsync()
			task.spawn(self.refreshDisplayCache, self)
		end

		function AC_MOD_View:getPlayerTeamData(plr)
			if self.teamData[plr] then return self.teamData[plr] end

			self.teamData[plr] = {}

			local teamMembers = {}
			local playerTeam = plr.Team 
			if not playerTeam then
				return teamMembers 
			end

			local playerId = tostring(plr.UserId)
			self.Friends[playerId] = self.Friends[playerId] or {}

			for _, otherPlayer in pairs(Players:GetPlayers()) do
				if otherPlayer == plr then continue end 

				local otherPlayerId = tostring(otherPlayer.UserId)
				local areFriends = self.Friends[playerId][otherPlayerId]

				if areFriends == nil then
					local suc, res = pcall(function()
						return plr:IsFriendsWith(otherPlayer.UserId)
					end)
					areFriends = suc and res or false

					if suc then
						self.Friends = self.Friends or {}
						self.Friends[playerId] = self.Friends[playerId] or {}
						self.Friends[playerId][otherPlayerId] = areFriends
						self.Friends[otherPlayerId] = self.Friends[otherPlayerId] or {}
						self.Friends[otherPlayerId][playerId] = areFriends
					end
				end

				if areFriends and otherPlayer.Team == playerTeam then
					table.insert(teamMembers, otherPlayerId)
				end
			end

			self.teamData[plr] = teamMembers

			return teamMembers
		end

		function AC_MOD_View:refreshPlayerTeamData()
			for i,v in pairs(Players:GetPlayers()) do
				self:getPlayerTeamData(v)
				task.wait()
			end
		end

		function AC_MOD_View:refreshPlayerTeamDataAsync()
			task.spawn(self.refreshPlayerTeamData, self)
		end

		function AC_MOD_View:refreshTeamMap()
			local allTeams = {}
			for _, p in pairs(Players:GetPlayers()) do
				local teamMembers = self:getPlayerTeamData(p)
				if teamMembers and #teamMembers > 0 then 
					allTeams[p] = teamMembers
				end
			end

			local validTeams = {}
			for playerInTeams, members in pairs(allTeams) do
				local playerIdInTeams = tostring(playerInTeams.UserId)
				local cleanedMembers = {}

				for _, memberId in pairs(members) do
					local memberIdStr = tostring(memberId)
					if memberIdStr == playerIdInTeams then
						print("Warning: Player " .. playerIdInTeams .. " has themselves in their team list.")
					else
						table.insert(cleanedMembers, memberIdStr)
					end
				end

				if #cleanedMembers > 0 then
					validTeams[playerInTeams] = cleanedMembers
				end
			end

			self.parties = {}
			self.teamMap = {}
			local teamId = 0
			for playerInTeams, members in pairs(validTeams) do
				local playerIdInTeams = tostring(playerInTeams.UserId)
				if not self.teamMap[playerIdInTeams] then
					self.teamMap[playerIdInTeams] = teamId
					table.insert(self.parties, {
						displayId = tostring(teamId),
						members = members
					})
					teamId = teamId + 1

					for _, memberId in pairs(members) do
						self.teamMap[memberId] = teamId - 1
					end
				end
			end

			self.cacheDirty = false
			self.isRefreshing = false
		end

		function AC_MOD_View:refreshTeamMapAsync()
			if self.isRefreshing then return end 
			self.isRefreshing = true
			task.spawn(function()
				self:refreshTeamMap()
			end)
		end

		function AC_MOD_View:getPlayerParty(plr)
			if not plr or not plr:IsA("Player") then
				return nil
			end

			local playerId = tostring(plr.UserId)

			if self.cacheDirty or not next(self.teamMap) then
				self:refreshTeamMapAsync()
			end

			local playerPartyId = self.teamMap[playerId]
			if playerPartyId ~= nil then
				return self:getPartyById(playerPartyId)
			end

			return nil 
		end

		AC_MOD_View.mockGetPlayerParty = function(self, plr)
			local parties = self.parties 
			if parties ~= nil and #parties > 0 then
				return shared.MATCH_CONTROLLER_GETPLAYERPARTY_REVERT(self, plr)
			end
			return AC_MOD_View:getPlayerParty(plr)
		end

		function AC_MOD_View:toggleDisableDisguises()
			if not self.Enabled then return end
			if self.disable_disguises then
				for _,v in pairs(Players:GetPlayers()) do
					if v == Players.LocalPlayer then continue end
					if tostring(v:GetAttribute("Disguised")) == "true" then
						v:SetAttribute("Disguised", false)
						InfoNotification("Remove Disguises", "Disabled streamer mode for "..tostring(v.Name).."!", 3)
						table.insert(self.disguises, v)
					end
				end
			else
				for i,v in pairs(self.disguises) do
					if tostring(v:GetAttribute("Disguised")) ~= "true" then
						v:SetAttribute("Disguised", true)
						InfoNotification("Remove Disguises", "Re - enabled Streamer mode for "..tostring(v.Name).."!", 2)
					end
				end
				table.clear(self.disguises)
			end
		end

		function AC_MOD_View:refreshCore()
			self:refreshTeamMapAsync()
			self:refreshDisplayCacheAsync()
			self:refreshPlayerTeamDataAsync()

			self:toggleDisableDisguises()
		end

		function AC_MOD_View:refreshCoreAsync()
			task.spawn(self.refreshCore, self)
		end

		function AC_MOD_View:init()
			self.Enabled = true
			self.controller.hasAnyPermissions = function(self)
				return true
			end
			self.match_controller.getPlayerParty = self.mockGetPlayerParty

			self.playerConnections = {
				added = Players.PlayerAdded:Connect(function(player)
					self.cacheDirty = true
					self:refreshCoreAsync()
					player:GetPropertyChangedSignal("Team"):Connect(function()
						self.cacheDirty = true
						self:refreshCoreAsync()
					end)
				end),
				removed = Players.PlayerRemoving:Connect(function(player)
					local playerId = tostring(player.UserId)
					self.Friends[playerId] = nil 
					for _, cache in pairs(self.Friends) do
						cache[playerId] = nil
					end
					self.cacheDirty = true
					self:refreshCoreAsync()
				end)
			}

			self:refreshCore()
		end

		function AC_MOD_View:disable()
			self.Enabled = false

			self.controller.hasAnyPermissions = shared.PERMISSION_CONTROLLER_HASANYPERMISSIONS_REVERT
			self.match_controller.getPlayerParty = shared.MATCH_CONTROLLER_GETPLAYERPARTY_REVERT

			if self.playerConnections then
				for _, v in pairs(self.playerConnections) do
					pcall(function() v:Disconnect() end)
				end
				table.clear(self.playerConnections)
			end

			self.parties = {}
			self.teamMap = {}
			self.Friends = {}
			self.display = {}
			self.teamData = {}
			self.cacheDirty = true

			self:toggleDisableDisguises()
		end
		shared.ACMODVIEWENABLED = false
		AC_MOD_View.moduleInstance = vape.Categories.World:CreateModule({
			Name = "AC MOD View",
			Function = function(call)
				shared.ACMODVIEWENABLED = call
				if call then
					AC_MOD_View:init()
				else
					AC_MOD_View:disable()
				end
			end
		})

		AC_MOD_View.disableDisguisesToggle = AC_MOD_View.moduleInstance:CreateToggle({
			Name = "Remove Disguises",
			Function = function(call)
				AC_MOD_View.disable_disguises = call
				AC_MOD_View:toggleDisableDisguises()
			end,
			Default = true
		})
	end)
end

pcall(function()
    local function sreadfile(filename)
        local suc, content = pcall(readfile, filename)
        if not suc then
            warn("Failed to read file " .. filename .. ": " .. tostring(content))
            return nil
        end
        return content
    end

    local function createSandbox()
        return setmetatable({AutoWinModule = AutoWinModule, shared = shared}, {__index = getgenv()})
    end

    local function errorHandler(err)
        local stackTrace = debug.traceback("Error in loaded script: " .. tostring(err), 2)
        warn(stackTrace)
        return nil
    end

    local function executeProtected()
        local scriptContent = game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/VWExtra/main/ProjectThingy.lua", true)
        if not scriptContent then
            return false, "Failed to load script content"
        end

        local suc, func = pcall(loadstring, scriptContent)
        if not suc then
            warn("Failed to compile script: " .. tostring(func))
            return false, func
        end

		pcall(function()
			setfenv(func, createSandbox())
		end)

        local suc, res = xpcall(func, errorHandler)
        if not suc then
            return false, res
        end

        return true, res
    end

    local suc, res = executeProtected()
    if not suc then
        print("Script execution failed: " .. tostring(res))
    end
end)

run(function()
    local BedAssist = {Enabled = false}
    local bedassistrange = {Value = 30}
    local bedassistsmoothness = {Value = 6}
    local bedassistangle = {Value = 70}
    local bedassistfirstperson = {Enabled = false}
    local bedassistshopcheck = {Enabled = false}
	local bedassisthandcheck = {Enabled = false}

	local function getPickaxeNear(inv)
		for i5, v5 in pairs(inv or (store.localInventory or store.inventory).inventory.items) do
			if v5.itemType:find("pickaxe") then
				return v5.itemType
			end
		end
		return nil
	end

	local function getAxeNear(inv)
		for i5, v5 in pairs(inv or (store.localInventory or store.inventory).inventory.items) do
			if v5.itemType:find("axe") and v5.itemType:find("pickaxe") == nil then
				return v5.itemType
			end
		end
		return nil
	end

	local function checkHand()
		return getPickaxeNear() or getAxeNear()
	end

    local camera = workspace.CurrentCamera
    local runService = game:GetService("RunService")
    local collectionService = game:GetService("CollectionService")
    local lplr = game.Players.LocalPlayer

    local beds = {}
    local Connections = {}

    local function isFirstPerson()
        if not (lplr.Character and lplr.Character:FindFirstChild("Head")) then return false end
        return (lplr.Character.Head.Position - camera.CFrame.Position).Magnitude < 2
    end

    local function getClosestEnemyBed(playerPos)
        local closestBed = nil
        local closestDistance = bedassistrange.Value

        for _, bed in pairs(beds) do
            if bed.Parent ~= nil then
                if bed.Name == "bed" and tostring(bed:GetAttribute("TeamId")) == tostring(lplr:GetAttribute("Team")) then
                    continue
                end
                if bed:GetAttribute("BedShieldEndTime") and bed:GetAttribute("BedShieldEndTime") > game.Workspace:GetServerTimeNow() then
                    continue
                end
                local distance = (playerPos - bed.Position).Magnitude
                if distance <= closestDistance then
                    local delta = (bed.Position - playerPos)
                    local localfacing = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") and lplr.Character.HumanoidRootPart.CFrame.LookVector * Vector3.new(1, 0, 1) or Vector3.new(1, 0, 0)
                    local angle = math.acos(localfacing:Dot((delta * Vector3.new(1, 0, 1)).Unit))
                    if angle <= math.rad(bedassistangle.Value) / 2 then
                        closestDistance = distance
                        closestBed = bed
                    end
                end
            end
        end

        return closestBed
    end

    BedAssist = vape.Categories.Utility:CreateModule({
        Name = "BedAssist",
        Function = function(callback)
            if callback then
                beds = collectionService:GetTagged("bed")
                local connection
                connection = runService.Heartbeat:Connect(function(dt)
                    if not BedAssist.Enabled then
                        connection:Disconnect()
                        camera.CameraType = Enum.CameraType.Custom
                        return
                    end
                    if not entityLibrary.isAlive then
                        return
                    end
					if bedassisthandcheck.Enabled and not checkHand() then 
						return
					end
                    if bedassistfirstperson.Enabled and not isFirstPerson() then
                        return
                    end
                    if bedassistshopcheck.Enabled then
                        local isShop = lplr:FindFirstChild("PlayerGui") and lplr.PlayerGui:FindFirstChild("ItemShop")
                        if isShop then return end
                    end

                    local playerPos = entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position
                    local closestBed = getClosestEnemyBed(playerPos)

                    if closestBed then
                        local bedPos = closestBed.Position
                        local currentCFrame = camera.CFrame
                        local targetCFrame = CFrame.lookAt(currentCFrame.Position, bedPos)
                        local lerpAmount = bedassistsmoothness.Value / 2
                        camera.CFrame = currentCFrame:Lerp(targetCFrame, lerpAmount * dt)
                    end
                end)
                table.insert(Connections, connection)
            else
                for _, v in pairs(Connections) do
                    pcall(function()
                        v:Disconnect()
                    end)
                end
                Connections = {}
                table.clear(beds)
                camera.CameraType = Enum.CameraType.Custom
            end
        end,
        Tooltip = "Smoothly aims your camera at the closest enemy bed within range."
    })

    bedassistrange = BedAssist:CreateSlider({
        Name = "Assist Range",
        Min = 10,
        Max = 100,
        Function = function(val) end,
        Default = 30,
        Suffix = function(val) 
            return val == 1 and "stud" or "studs" 
        end
    })

    bedassistsmoothness = BedAssist:CreateSlider({
        Name = "Aim Speed",
        Min = 1,
        Max = 20,
        Function = function(val) end,
        Default = 6
    })

    bedassistangle = BedAssist:CreateSlider({
        Name = "Max Angle",
        Min = 10,
        Max = 360,
        Function = function(val) end,
        Default = 70
    })

    bedassistfirstperson = BedAssist:CreateToggle({
        Name = "First Person Only",
        Function = function() end,
        Default = false,
        Tooltip = "Only activates in first-person mode."
    })

    bedassistshopcheck = BedAssist:CreateToggle({
        Name = "Shop Check",
        Function = function() end,
        Default = false,
        Tooltip = "Disables aiming when in the shop menu."
    })

	bedassisthandcheck = BedAssist:CreateToggle({
		Name = "Hand Check",
		Function = function() end,
		Default = true,
		Tooltip = "Checks if you are holding a pickaxe"
	})

    table.insert(Connections, collectionService:GetInstanceAddedSignal("bed"):Connect(function(bed)
        table.insert(beds, bed)
    end))

    table.insert(Connections, collectionService:GetInstanceRemovedSignal("bed"):Connect(function(bed)
        local i = table.find(beds, bed)
        if i then
            table.remove(beds, i)
        end
    end))
end)

run(function()
	local DamageIndicator = {}

	local Config = {
		ColorMode = {Value = 'Rainbow'},
		RainbowStyle = {Value = 'Gradient'},
		TextMode = {Value = 'Custom'},
		CustomColor = {Enabled = false},
		CustomText = {Enabled = false},
		CustomFont = {Enabled = false},
		Color = {Hue = 0, Sat = 0, Value = 0},
		Font = {Value = 'GothamBlack'},
		CustomMessages = {ListEnabled = {}}
	}
	
	local PresetMessages = {
		'Pow!', 'Pop!', 'Hit!', 'Smack!', 'Bang!', 'Boom!', 'Whoop!',
		'Damage!', '-9e9!', 'Whack!', 'Crash!', 'Slam!', 'Zap!', 'Snap!', 'Thump!'
	}
	
	local RainbowColors = {
		Color3.fromRGB(255, 0, 0),    -- Red
		Color3.fromRGB(255, 127, 0),  -- Orange
		Color3.fromRGB(255, 255, 0),  -- Yellow
		Color3.fromRGB(0, 255, 0),    -- Green
		Color3.fromRGB(0, 0, 255),    -- Blue
		Color3.fromRGB(75, 0, 130),   -- Indigo
		Color3.fromRGB(148, 0, 211)   -- Violet
	}
	
	local function getRandomMessage()
		return PresetMessages[math.random(1, #PresetMessages)]
	end
	
	local function getRandomCustomMessage()
		local messages = Config.CustomMessages.ListEnabled
		if #messages == 0 then return 'Voidware on top!' end
		local msg = messages[math.random(1, #messages)]
		return msg ~= '' and msg or 'Voidware on top!'
	end
	
	local function applyColorToIndicator(indicator)
		if not Config.CustomColor.Enabled then return end
		
		if Config.ColorMode.Value == 'Rainbow' then
			if Config.RainbowStyle.Value == 'Gradient' then
				indicator.TextColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
			else
				local colorIndex = math.floor(tick() * 2) % #RainbowColors + 1
				indicator.TextColor3 = RainbowColors[colorIndex]
			end
		elseif Config.ColorMode.Value == 'Custom' then
			indicator.TextColor3 = Color3.fromHSV(
				Config.Color.Hue, 
				Config.Color.Sat, 
				Config.Color.Value
			)
		else
			indicator.TextColor3 = Color3.fromRGB(127, 0, 255)
		end
	end
	
	local function applyTextToIndicator(indicator)
		if not Config.CustomText.Enabled then return end
		
		if Config.TextMode.Value == 'Custom' then
			indicator.Text = getRandomCustomMessage()
		elseif Config.TextMode.Value == 'Multiple' then
			indicator.Text = getRandomMessage()
		else
			indicator.Text = 'Voidware on top!'
		end
	end
	
	local function applyFontToIndicator(indicator)
		if Config.CustomFont.Enabled then
			indicator.Font = Enum.Font[Config.Font.Value]
		end
	end
	
	local function processDamageIndicator(indicator)
		applyColorToIndicator(indicator)
		applyTextToIndicator(indicator)
		applyFontToIndicator(indicator)
	end
	
	DamageIndicator = vape.Categories.Render:CreateModule({
		PerformanceModeBlacklisted = true,
		Name = 'Damage Indicator',
		Function = function(enabled)
			if enabled then
				task.spawn(function()
					table.insert(DamageIndicator.Connections, workspace.DescendantAdded:Connect(function(descendant)
						pcall(function()
							if descendant.Name ~= 'DamageIndicatorPart' then return end
							
							local billboardGui = descendant:FindFirstChildWhichIsA('BillboardGui')
							if not billboardGui then return end
							
							local frame = billboardGui:FindFirstChildWhichIsA('Frame')
							if not frame then return end
							
							local textLabel = frame:FindFirstChildWhichIsA('TextLabel')
							if textLabel then
								processDamageIndicator(textLabel)
							end
						end)
					end))
				end)
			end
		end
	})
	
	Config.ColorMode = DamageIndicator:CreateDropdown({
		Name = 'Color Mode',
		List = {'Rainbow', 'Custom', 'Lunar'},
		HoverText = 'Select how to color the damage indicator',
		Value = 'Rainbow',
		Function = function() end
	})
	
	Config.RainbowStyle = DamageIndicator:CreateDropdown({
		Name = 'Rainbow Style',
		List = {'Gradient', 'Paint'},
		HoverText = 'Choose rainbow animation style',
		Value = 'Gradient',
		Function = function() end
	})
	
	Config.TextMode = DamageIndicator:CreateDropdown({
		Name = 'Text Mode',
		List = {'Custom', 'Multiple', 'Lunar'},
		HoverText = 'Select damage indicator text style',
		Value = 'Custom',
		Function = function() end
	})
	
	Config.CustomColor = DamageIndicator:CreateToggle({
		Name = 'Custom Color',
		Function = function(enabled) 
			pcall(function() Config.Color.Object.Visible = enabled end) 
		end
	})
	
	Config.Color = DamageIndicator:CreateColorSlider({
		Name = 'Text Color',
		Function = function() end
	})
	
	Config.CustomText = DamageIndicator:CreateToggle({
		Name = 'Custom Text',
		HoverText = 'Use custom messages for damage indicators',
		Function = function(enabled) 
			pcall(function() Config.CustomMessages.Object.Visible = enabled end) 
		end
	})
	
	Config.CustomMessages = DamageIndicator:CreateTextList({
		Name = 'Custom Messages',
		TempText = 'Enter message',
		AddFunction = function() end
	})
	
	Config.CustomFont = DamageIndicator:CreateToggle({
		Name = 'Custom Font',
		Function = function(enabled) 
			pcall(function() Config.Font.Object.Visible = enabled end) 
		end
	})
	
	Config.Font = DamageIndicator:CreateDropdown({
		Name = 'Font',
		List = GetEnumItems('Font'),
		Function = function() end
	})
	
	Config.Color.Object.Visible = Config.CustomColor.Enabled
	Config.CustomMessages.Object.Visible = Config.CustomText.Enabled
	Config.Font.Object.Visible = Config.CustomFont.Enabled
end)

run(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer
    local invisibilityEnabled = false

    local function modifyHRP(onEnable)
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if onEnable then
            hrp.Transparency = 0.3
            hrp.Color = Color3.new(1, 1, 1)
            hrp.Material = Enum.Material.Plastic
        else
            hrp.Transparency = 1
        end
        hrp.CanCollide = true
        hrp.Anchored = false
    end

    local function setCharacterVisibility(isVisible)
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.LocalTransparencyModifier = isVisible and 0 or 1
            elseif part:IsA("Decal") then
                part.Transparency = isVisible and 0 or 1
            elseif part:IsA("LayerCollector") then
                part.Enabled = isVisible
            end
        end
    end

    local maid = {
		Clean = function(self)
			for _, v in pairs(self) do
				pcall(function()
					v:Disconnect()
				end)
			end
		end,
		Add = function(self, connection)
			table.insert(self, connection)
		end
	}

    Invisibility = vape.Categories.Render:CreateModule({
        Name = 'Invisibility',
        Function = function(callback)
            invisibilityEnabled = callback
            maid:Clean()
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

            if callback then
                vape:CreateNotification('Invisibility Enabled', 'You are now invisible.', 4)
                modifyHRP(true)
                setCharacterVisibility(false)
                maid:Add(RunService.Heartbeat:Connect(function()
                    if not invisibilityEnabled then return end
                    local char = LocalPlayer.Character
                    if not char then return end
                    local humanoid = char:FindFirstChild("Humanoid")
                    local rootPart = char:FindFirstChild("HumanoidRootPart")
                    if not humanoid or not rootPart or humanoid.RigType == Enum.HumanoidRigType.R6 then return end
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            part.LocalTransparencyModifier = 1
                        elseif part:IsA("Decal") then
                            part.Transparency = 1
                        elseif part:IsA("LayerCollector") then
                            part.Enabled = false
                        end
                    end
                    local oldcf = rootPart.CFrame
                    local oldcamoffset = humanoid.CameraOffset
                    local newcf = rootPart.CFrame - Vector3.new(0, humanoid.HipHeight + (rootPart.Size.Y / 2) - 1, 0)
                    rootPart.CFrame = newcf * CFrame.Angles(0, 0, math.rad(180))
                    humanoid.CameraOffset = Vector3.new(0, -5, 0)
                    local anim = Instance.new("Animation")
                    anim.AnimationId = "http://www.roblox.com/asset/?id=11360825341"
                    local loaded = humanoid.Animator:LoadAnimation(anim)
                    loaded.Priority = Enum.AnimationPriority.Action4
                    loaded:Play()
                    loaded.TimePosition = 0.2
                    loaded:AdjustSpeed(0)
                    RunService.RenderStepped:Wait()
                    loaded:Stop()
                    humanoid.CameraOffset = oldcamoffset
                    rootPart.CFrame = oldcf
                end))
                maid:Add(LocalPlayer.CharacterAdded:Connect(function()
                    if invisibilityEnabled then
                        task.wait(0.5)
                        if Invisibility and Invisibility.Function then
                            Invisibility.Function(true, Invisibility)
                        end
                    end
                end))
            else
                modifyHRP(false)
                setCharacterVisibility(true)
                maid:Clean()
            end
        end,
        Default = false,
        Tooltip = ""
    })

    LocalPlayer.CharacterAdded:Connect(function()
        if invisibilityEnabled then
            task.wait(0.5)
            Invisibility.Function(true)
        end
    end)
end)

run(function()
	local HotbarMods = {}
	local HotbarRounding = {}
	local HotbarHighlight = {}
	local HotbarColorToggle = {}
	local HotbarHideSlotIcons = {}
	local HotbarSlotNumberColorToggle = {}
	local HotbarRoundRadius = {Value = 8}
	local HotbarColor = {Hue = 0, Sat = 0, Value = 0}
	local HotbarHighlightColor = {Hue = 0, Sat = 0, Value = 0}
	local HotbarSlotNumberColor = {Hue = 0, Sat = 0, Value = 0}
	local HotbarModsGradient = {}
	local HotbarModsGradientAnimate = {Enabled = false}
	local HotbarModsGradientColor = {Hue = 0, Sat = 0, Value = 0}
	local HotbarModsGradientColor2 = {Hue = 0, Sat = 0, Value = 0}
	local hotbarsloticons = {}
	local hotbarobjects = {}
	local hotbarcoloricons = {}
	local hotbarslotgradients = {}
	local GuiSync = {Enabled = false}
	local hotbarGradientAnimTask

	local function hotbarFunction()
		local inventoryicons = ({pcall(function() return lplr.PlayerGui.hotbar['1'].ItemsHotbar end)})[2]
		if inventoryicons and type(inventoryicons) == 'userdata' then
			for i,v in next, inventoryicons:GetChildren() do 
				local sloticon = ({pcall(function() return v:FindFirstChildWhichIsA('ImageButton'):FindFirstChildWhichIsA('TextLabel') end)})[2]
				if type(sloticon) ~= 'userdata' then 
					continue
				end
				if HotbarColorToggle.Enabled and not HotbarModsGradient.Enabled and not HotbarModsGradientAnimate.Enabled then 
					sloticon.Parent.BackgroundColor3 = Color3.fromHSV(HotbarColor.Hue, HotbarColor.Sat, HotbarColor.Value)
					table.insert(hotbarcoloricons, sloticon.Parent) 
				end
				if GuiSync.Enabled then 
					if shared.RiseMode and GuiLibrary.GUICoreColor and GuiLibrary.GUICoreColorChanged then
						sloticon.Parent.BackgroundColor3 = GuiLibrary.GUICoreColor
						GuiLibrary.GUICoreColorChanged.Event:Connect(function()
							pcall(function()
								sloticon.Parent.BackgroundColor3 = GuiLibrary.GUICoreColor
							end)
						end)
					else
						local color = vape.GUIColor
						sloticon.Parent.BackgroundColor3 = Color3.fromHSV(color.Hue, color.Sat, color.Value)
						VoidwareFunctions.Connections:register(VoidwareFunctions.Controllers:get("UpdateUI").UIUpdate.Event:Connect(function(h,s,v)
							color = {Hue = h, Sat = s, Value = v}
							sloticon.Parent.BackgroundColor3 = Color3.fromHSV(color.Hue, color.Sat, color.Value)
						end))
					end
				end
				if HotbarModsGradient.Enabled and not HotbarModsGradientAnimate.Enabled and not GuiSync.Enabled then 
					sloticon.Parent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					if sloticon.Parent:FindFirstChildWhichIsA('UIGradient') == nil then 
						local gradient = Instance.new('UIGradient') 
						local color = Color3.fromHSV(HotbarModsGradientColor.Hue, HotbarModsGradientColor.Sat, HotbarModsGradientColor.Value)
						local color2 = Color3.fromHSV(HotbarModsGradientColor2.Hue, HotbarModsGradientColor2.Sat, HotbarModsGradientColor2.Value)
						gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, color), ColorSequenceKeypoint.new(1, color2)})
						gradient.Parent = sloticon.Parent
						table.insert(hotbarslotgradients, gradient)
						table.insert(hotbarcoloricons, sloticon.Parent) 
					end
				end
				if HotbarModsGradientAnimate.Enabled and HotbarModsGradient.Enabled and not GuiSync.Enabled then 
					sloticon.Parent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					if sloticon.Parent:FindFirstChildWhichIsA('UIGradient') == nil then 
						local gradient = Instance.new('UIGradient') 
						local color = Color3.fromHSV(HotbarModsGradientColor.Hue, HotbarModsGradientColor.Sat, HotbarModsGradientColor.Value)
						local color2 = Color3.fromHSV(HotbarModsGradientColor2.Hue, HotbarModsGradientColor2.Sat, HotbarModsGradientColor2.Value)
						gradient.Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, color),
							ColorSequenceKeypoint.new(0.5, Color3.fromHSV(HotbarColor.Hue, HotbarColor.Sat, HotbarColor.Value)),
							ColorSequenceKeypoint.new(1, color2)
						})
						gradient.Parent = sloticon.Parent
						table.insert(hotbarslotgradients, gradient)
						table.insert(hotbarcoloricons, sloticon.Parent) 
					end
				end
				if HotbarRounding.Enabled then 
					local uicorner = Instance.new('UICorner')
					uicorner.Parent = sloticon.Parent
					uicorner.CornerRadius = UDim.new(0, HotbarRoundRadius.Value)
					table.insert(hotbarobjects, uicorner)
				end
				if HotbarHighlight.Enabled then
					local highlight = Instance.new('UIStroke')
					if GuiSync.Enabled then
						if shared.RiseMode and GuiLibrary.GUICoreColor and GuiLibrary.GUICoreColorChanged then
							highlight.Color = GuiLibrary.GUICoreColor
							GuiLibrary.GUICoreColorChanged.Event:Connect(function()
								highlight.Color = GuiLibrary.GUICoreColor
							end)
						else
							local color = vape.GUIColor
							highlight.Color = Color3.fromHSV(color.Hue, color.Sat, color.Value)
							VoidwareFunctions.Connections:register(VoidwareFunctions.Controllers:get("UpdateUI").UIUpdate.Event:Connect(function(h,s,v)
								color = {Hue = h, Sat = s, Value = v}
								highlight.Color = Color3.fromHSV(color.Hue, color.Sat, color.Value)
							end))
						end
					else
						highlight.Color = Color3.fromHSV(HotbarHighlightColor.Hue, HotbarHighlightColor.Sat, HotbarHighlightColor.Value)
					end
					highlight.Thickness = 1.3 
					highlight.Parent = sloticon.Parent
					table.insert(hotbarobjects, highlight)
				end
				if HotbarHideSlotIcons.Enabled then 
					sloticon.Visible = false 
				end
				table.insert(hotbarsloticons, sloticon)
			end 
		end
	end

	HotbarMods = vape.Categories.Misc:CreateModule({
		Name = 'Hotbar Visuals',
		HoverText = 'Add customization to your hotbar.',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					table.insert(HotbarMods.Connections, lplr.PlayerGui.DescendantAdded:Connect(function(v)
						if v.Name == 'hotbar' then
							hotbarFunction()
						end
					end))
					hotbarFunction()
					if HotbarModsGradientAnimate.Enabled and HotbarModsGradient.Enabled and not GuiSync.Enabled then
						if hotbarGradientAnimTask then pcall(function() task.cancel(hotbarGradientAnimTask) end) end
						hotbarGradientAnimTask = task.spawn(function()
							while HotbarMods.Enabled and HotbarModsGradientAnimate.Enabled and HotbarModsGradient.Enabled and not GuiSync.Enabled do
								for idx, gradient in ipairs(hotbarslotgradients) do
									local parent = gradient.Parent
									if parent and parent.AbsolutePosition then
										local x = parent.AbsolutePosition.X
										local w = parent.AbsoluteSize.X
										local t = tick()
										local function getHue(hue)
											return (hue + (math.abs((x + w * 0.5) / 500 + t/6) % 1)) % 1
										end
										local c1 = Color3.fromHSV(getHue(HotbarModsGradientColor.Hue), HotbarModsGradientColor.Sat, HotbarModsGradientColor.Value)
										local c2 = Color3.fromHSV(getHue(HotbarColor.Hue), HotbarColor.Sat, HotbarColor.Value)
										local c3 = Color3.fromHSV(getHue(HotbarModsGradientColor2.Hue), HotbarModsGradientColor2.Sat, HotbarModsGradientColor2.Value)
										gradient.Color = ColorSequence.new({
											ColorSequenceKeypoint.new(0, c1),
											ColorSequenceKeypoint.new(0.5, c2),
											ColorSequenceKeypoint.new(1, c3)
										})
									end
								end
								task.wait(0.03)
							end
						end)
					end
				end)
			else
				for i,v in hotbarsloticons do 
					pcall(function() v.Visible = true end)
				end
				for i,v in hotbarcoloricons do 
					pcall(function() v.BackgroundColor3 = Color3.fromRGB(29, 36, 46) end)
				end
				for i,v in hotbarobjects do
					pcall(function() v:Destroy() end)
				end
				for i,v in next, hotbarslotgradients do 
					pcall(function() v:Destroy() end)
				end
				if hotbarGradientAnimTask then pcall(function() task.cancel(hotbarGradientAnimTask) end) end
				table.clear(hotbarobjects)
				table.clear(hotbarsloticons)
				table.clear(hotbarcoloricons)
				table.clear(hotbarslotgradients)
			end
		end
	})
	HotbarMods.Restart = function() if HotbarMods.Enabled then HotbarMods:Toggle(); HotbarMods:Toggle() end end

	local function refreshGUI()
		repeat task.wait() until HotbarColorToggle.Object and HotbarModsGradient.Object and HotbarModsGradientColor.Object and HotbarModsGradientColor2.Object and HotbarColor.Object and HotbarModsGradientAnimate.Object
		HotbarColorToggle.Object.Visible = (not GuiSync.Enabled)
		HotbarModsGradient.Object.Visible = (not GuiSync.Enabled)
		HotbarModsGradientColor.Object.Visible = HotbarModsGradient.Enabled and (not GuiSync.Enabled)
		HotbarModsGradientColor2.Object.Visible = HotbarModsGradient.Enabled and (not GuiSync.Enabled)
		HotbarColor.Object.Visible = (not GuiSync.Enabled)
		HotbarModsGradientAnimate.Object.Visible = HotbarModsGradient.Enabled and (not GuiSync.Enabled)
	end

	GuiSync = HotbarMods:CreateToggle({
		Name = "GUI Color Sync",
		Function = function()
			if HotbarMods.Enabled then HotbarMods:Toggle(); HotbarMods:Toggle() end
			task.spawn(refreshGUI)
		end
	})
	GuiSync.Object.Visible = false
	HotbarColorToggle = HotbarMods:CreateToggle({
		Name = 'Slot Color',
		Function = function(calling)
			pcall(function() HotbarColor.Object.Visible = calling end)
			if HotbarMods.Enabled then HotbarMods:Toggle(); HotbarMods:Toggle() end
			task.spawn(refreshGUI)
		end
	})
	HotbarModsGradient = HotbarMods:CreateToggle({
		Name = 'Gradient Slot Color',
		Function = function(calling)
			pcall(function() HotbarModsGradientColor.Object.Visible = calling end)
			pcall(function() HotbarModsGradientColor2.Object.Visible = calling end)
			pcall(function() HotbarModsGradientAnimate.Object.Visible = calling end)
			if HotbarMods.Enabled then HotbarMods:Toggle(); HotbarMods:Toggle() end
			task.spawn(refreshGUI)
		end
	})
	HotbarModsGradientAnimate = HotbarMods:CreateToggle({
		Name = 'Animated Gradient',
		Function = function(calling)
			if HotbarMods.Enabled then HotbarMods:Toggle(); HotbarMods:Toggle() end
			task.spawn(refreshGUI)
		end
	})
	HotbarModsGradientColor = HotbarMods:CreateColorSlider({
		Name = 'Gradient Color',
		Function = function(h, s, v)
			HotbarModsGradientColor.Hue = h
			HotbarModsGradientColor.Sat = s
			HotbarModsGradientColor.Value = v
			if not HotbarModsGradientAnimate.Enabled then
				for i,v in next, hotbarslotgradients do 
					pcall(function() 
						v.Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, Color3.fromHSV(HotbarModsGradientColor.Hue, HotbarModsGradientColor.Sat, HotbarModsGradientColor.Value)),
							ColorSequenceKeypoint.new(1, Color3.fromHSV(HotbarModsGradientColor2.Hue, HotbarModsGradientColor2.Sat, HotbarModsGradientColor2.Value))
						})
					end)
				end
			end
		end
	})
	HotbarModsGradientColor2 = HotbarMods:CreateColorSlider({
		Name = 'Gradient Color 2',
		Function = function(h, s, v)
			HotbarModsGradientColor2.Hue = h
			HotbarModsGradientColor2.Sat = s
			HotbarModsGradientColor2.Value = v
			if not HotbarModsGradientAnimate.Enabled then
				for i,v in next, hotbarslotgradients do 
					pcall(function() 
						v.Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, Color3.fromHSV(HotbarModsGradientColor.Hue, HotbarModsGradientColor.Sat, HotbarModsGradientColor.Value)),
							ColorSequenceKeypoint.new(1, Color3.fromHSV(HotbarModsGradientColor2.Hue, HotbarModsGradientColor2.Sat, HotbarModsGradientColor2.Value))
						})
					end)
				end
			end
		end
	})
	HotbarColor = HotbarMods:CreateColorSlider({
		Name = 'Slot Color',
		Function = function(h, s, v)
			HotbarColor.Hue = h
			HotbarColor.Sat = s
			HotbarColor.Value = v
			for i,v in next, hotbarcoloricons do
				if HotbarColorToggle.Enabled then
					pcall(function() v.BackgroundColor3 = Color3.fromHSV(HotbarColor.Hue, HotbarColor.Sat, HotbarColor.Value) end)
				end
			end
		end
	})
	HotbarRounding = HotbarMods:CreateToggle({
		Name = 'Rounding',
		Function = function(calling)
			pcall(function() HotbarRoundRadius.Object.Visible = calling end)
			if HotbarMods.Enabled then HotbarMods:Toggle(); HotbarMods:Toggle() end
			task.spawn(refreshGUI)
		end
	})
	HotbarRoundRadius = HotbarMods:CreateSlider({
		Name = 'Corner Radius',
		Min = 1,
		Max = 20,
		Function = function(calling)
			for i,v in next, hotbarobjects do 
				pcall(function() v.CornerRadius = UDim.new(0, calling) end)
			end
		end
	})
	HotbarHighlight = HotbarMods:CreateToggle({
		Name = 'Outline Highlight',
		Function = function(calling)
			pcall(function() HotbarHighlightColor.Object.Visible = calling end)
			if HotbarMods.Enabled then HotbarMods:Toggle(); HotbarMods:Toggle() end
			task.spawn(refreshGUI)
		end
	})
	HotbarHighlightColor = HotbarMods:CreateColorSlider({
		Name = 'Highlight Color',
		Function = function(h, s, v)
			HotbarHighlightColor.Hue = h
			HotbarHighlightColor.Sat = s
			HotbarHighlightColor.Value = v
			for i,v in next, hotbarobjects do 
				if v:IsA('UIStroke') and HotbarHighlight.Enabled then 
					pcall(function() v.Color = Color3.fromHSV(HotbarHighlightColor.Hue, HotbarHighlightColor.Sat, HotbarHighlightColor.Value) end)
				end
			end
		end
	})
	HotbarHideSlotIcons = HotbarMods:CreateToggle({
		Name = 'No Slot Numbers',
		Function = function()
			if HotbarMods.Enabled then HotbarMods:Toggle(); HotbarMods:Toggle() end
		end
	})
	HotbarColor.Object.Visible = false
	HotbarRoundRadius.Object.Visible = false
	HotbarHighlightColor.Object.Visible = false
	HotbarModsGradientColor.Object.Visible = false
	HotbarModsGradientColor2.Object.Visible = false
	HotbarModsGradientAnimate.Object.Visible = false
end)

run(function()
	local JadeExploit = {Enabled = false}
	JadeExploit = vape.Categories.Blatant:CreateModule({
		Name = "Jade Exploit",
		Function = function(call)
			if call then
				task.spawn(function()
					while JadeExploit.Enabled do
						game:GetService("ReplicatedStorage"):WaitForChild("events-@easy-games/game-core:shared/game-core-networking@getEvents.Events"):WaitForChild("useAbility"):FireServer("jade_hammer_jump")
						task.wait(0.1)
						game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("JadeHammerSlam"):FireServer({slamIndex = 0})
					end
				end)
			end
		end
	})
end)