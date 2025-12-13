repeat task.wait() until game:IsLoaded()

local vape = shared.vape
local tween = vape.Libraries.tween
local color = vape.Libraries.color
local entitylib = vape.Libraries.entity
local uipallet = vape.Libraries.uipallet
local whitelist = vape.Libraries.whitelist
local prediction = vape.Libraries.prediction
local targetinfo = vape.Libraries.targetinfo
local sessioninfo = vape.Libraries.sessioninfo
local getfontsize = vape.Libraries.getfontsize
local getcustomasset = vape.Libraries.getcustomasset

local GuiLibrary = vape

local playersService = 		game:GetService("Players")
local lightingService = 	game:GetService("Lighting")
local runService = 			game:GetService("RunService")
local textService = 		game:GetService("TextService")
local tweenService =		game:GetService("TweenService")
local textChatService = 	game:GetService("TextChatService")
local inputService = 		game:GetService("UserInputService")
local collectionService = 	game:GetService("CollectionService")
local replicatedStorage = 	game:GetService("ReplicatedStorage")
local runservice = runService
local RunService = runservice
local entityLibrary = entitylib
local tweenservice = tweenService 
local lplr = playersService.LocalPlayer
local gameCamera = game.Workspace.CurrentCamera
local vapeConnections = {}
local vapeCachedAssets = {}
local function encode(tbl)
    return game:GetService("HttpService"):JSONEncode(tbl)
end
local function decode(tbl)
    return game:GetService("HttpService"):JSONDecode(tbl)
end
local function cprint(tbl)
	for i, v in pairs(tbl) do
		print(tostring(tbl), tostring(i), tostring(v))
	end
end
VoidwareFunctions.GlobaliseObject("encode", encode)
VoidwareFunctions.GlobaliseObject("decode", decode)
VoidwareFunctions.GlobaliseObject("cprint", cprint)

local function removeTags(str)
	str = str:gsub('<br%s*/>', '\n')
	return (str:gsub('<[^<>]->', ''))
end

local vapeEvents = setmetatable({}, {
	__index = function(self, index)
		self[index] = Instance.new("BindableEvent")
		return self[index]
	end
})
local vapeTargetInfo = shared.VapeTargetInfo or {Targets = {}}
local vapeInjected = true

local CheatEngineHelper = {
    SprintEnabled = false
}
local store = {
	attackReach = 0,
	attackReachUpdate = tick(),
	blocks = {},
	blockPlacer = {},
	blockPlace = tick(),
	blockRaycast = RaycastParams.new(),
	equippedKit = "",
	forgeMasteryPoints = 0,
	forgeUpgrades = {},
	grapple = tick(),
	inventories = {},
	localInventory = {
		inventory = {
			items = {},
			armor = {}
		},
		hotbar = {}
	},
	localHand = {},
	hand = {},
	matchState = 1,
	matchStateChanged = tick(),
	pots = {},
	queueType = "bedwars_test",
	scythe = tick(),
	statistics = {
		beds = 0,
		kills = 0,
		lagbacks = 0,
		lagbackEvent = Instance.new("BindableEvent"),
		reported = 0,
		universalLagbacks = 0
	},
	whitelist = {
		chatStrings1 = {helloimusinginhaler = "vape"},
		chatStrings2 = {vape = "helloimusinginhaler"},
		clientUsers = {},
		oldChatFunctions = {}
	},
	zephyrOrb = 0
}
local bedwars = {
    ProjectileRemote = "ProjectileFire",
    EquipItemRemote = "SetInvItem",
    DamageBlockRemote = "DamageBlock",
    ReportRemote = "ReportPlayer",
    PickupRemote = "PickupItemDrop",
    CannonAimRemote = "AimCannon",
    CannonLaunchRemote = "LaunchSelfFromCannon",
    AttackRemote = "SwordHit",
    GuitarHealRemote = "PlayGuitar",
	EatRemote = "ConsumeItem",
	SpawnRavenRemote = "SpawnRaven",
	MageRemote = "LearnElementTome",
	DragonRemote = "RequestDragonPunch",
	ConsumeSoulRemote = "ConsumeGrimReaperSoul",
	TreeRemote = "ConsumeTreeOrb",
	PickupMetalRemote = "CollectCollectableEntity",
	BatteryRemote = "ConsumeBattery"
}
local function extractTime(timeText)
	local minutes, seconds = string.match(timeText, "(%d+):(%d%d)")
    local tbl = {
        minutes = tonumber(minutes),
        seconds = tonumber(seconds)
    }
	function tbl:toSeconds()
		return tonumber(minutes) and tonumber(seconds) and tonumber(minutes)*60 + tonumber(seconds)
	end
	return tbl
end
local function getRemotes(paths)
    local allRemotes = {}
    local function filterDescendants(descendants, classNames)
        local filtered = {}
        if typeof(classNames) ~= "table" then
            classNames = {classNames}
        end
        for _, descendant in pairs(descendants) do
            for _, className in pairs(classNames) do
                if descendant:IsA(className) then
                    table.insert(filtered, descendant)
                    break 
                end
            end
        end
        return filtered
    end
    for _, path in pairs(paths) do
        local objectToGetDescendantsFrom = game
        for _, subfolder in pairs(string.split(path, ".")) do
            objectToGetDescendantsFrom = objectToGetDescendantsFrom:FindFirstChild(subfolder)
            if not objectToGetDescendantsFrom then
                --warn("Path " .. path .. " does not exist.")
                break
            end
        end
        if objectToGetDescendantsFrom then
            local remotes = filterDescendants(objectToGetDescendantsFrom:GetDescendants(), {"BindableEvent", "RemoteEvent", "RemoteFunction", "UnreliableRemoteEvent"})
            for _, remote in pairs(remotes) do
                table.insert(allRemotes, remote)
            end
        end
    end
    return allRemotes
end

bedwars.Client = {}
local cache = {} 
local namespaceCache = {}

local NetworkLogger = {
    usageStats = {},
    threshold = 20, 
    warningCooldown = 5, 
    lastWarning = {}
}

local function logRemoteUsage(remoteName, callType)
	remoteName = tostring(remoteName)
    local timeNow = tick()
    local key = remoteName .. "_" .. callType
    
    if not NetworkLogger.usageStats[key] then
        NetworkLogger.usageStats[key] = {
            count = 0,
            lastReset = timeNow,
            peakRate = 0
        }
    end
    
    local stats = NetworkLogger.usageStats[key]
    stats.count = stats.count + 1

	if shared.VoidDev then
		print(`Logged fire from {tostring(remoteName)} | {tostring(stats.count)}`)
	end
    
    if timeNow - stats.lastReset >= 1 then
        local rate = stats.count / (timeNow - stats.lastReset)
        stats.peakRate = math.max(stats.peakRate, rate)
        stats.count = 0
        stats.lastReset = timeNow
        
        if rate > NetworkLogger.threshold then
            if not NetworkLogger.lastWarning[key] or (timeNow - NetworkLogger.lastWarning[key] >= NetworkLogger.warningCooldown) then
				if shared.VoidDev then
					warn(string.format("[NetworkLogger] Excessive remote usage detected!\n" .."Remote: %s\nCallType: %s\nRate: %.2f calls/sec\nPeak: %.2f calls/sec", remoteName, callType, rate, stats.peakRate))
					warningNotification("NetworkLogger", string.format("Excessive remote usage detected!\n" .."Remote: %s\nCallType: %s\nRate: %.2f calls/sec\nPeak: %.2f calls/sec", remoteName, callType, rate, stats.peakRate), 3)
				end
                NetworkLogger.lastWarning[key] = timeNow
            end
        end
    end
end

local remoteThrottleTable = {}
local REMOTE_THROTTLE_TIME = {
    SwordHit = 0.1,
    ChestGetItem = 1.0,
    SetObservedChest = 0.2,
    _default = 0.1
}

local function shouldThrottle(remoteName)
    local now = tick()
    local throttleTime = REMOTE_THROTTLE_TIME[remoteName] or REMOTE_THROTTLE_TIME._default
    if not remoteThrottleTable[remoteName] or now - remoteThrottleTable[remoteName] > throttleTime then
        remoteThrottleTable[remoteName] = now
        return false
    end
	if shared.VoidDev and shared.ThrottleDebug then
   	 	warn("[Remote Throttle] Throttled remote call to '" .. tostring(remoteName) .. "' at " .. tostring(now))
	end
    return true
end

local function decorateRemote(remote, src)
    local isFunction = string.find(string.lower(remote.ClassName), "function")
    local isEvent = string.find(string.lower(remote.ClassName), "remoteevent")
    local isBindable = string.find(string.lower(remote.ClassName), "bindable")

    local function middlewareCall(method, ...)
        local remoteName = remote.Name
		local args = {...}
        if shouldThrottle(remoteName) then
            return
        end
        return method(...)
    end

    if isFunction then
        function src:CallServer(...)
			logRemoteUsage(remote, "InvokeServer")
            return middlewareCall(function(...) return remote:InvokeServer(...) end, ...)
        end
    elseif isEvent then
        function src:CallServer(...)
			logRemoteUsage(remote, "FireServer")
            return middlewareCall(function(...) return remote:FireServer(...) end, ...)
        end
    elseif isBindable then
        function src:CallServer(...)
			logRemoteUsage(remote, "BindableFire")
            return middlewareCall(function(...) return remote:Fire(...) end, ...)
        end
    end

    function src:InvokeServer(...)
        local args = {...}
        src:CallServer(unpack(args))
    end

    function src:FireServer(...)
        local args = {...}
        src:CallServer(unpack(args))
    end

    function src:SendToServer(...)
        local args = {...}
        src:CallServer(unpack(args))
    end

    function src:CallServerAsync(...)
        local args = {...}
        src:CallServer(unpack(args))
    end

    src.instance = remote
	src._custom = true

    return src
end

function bedwars.Client:Get(remName, customTable, resRequired, blacklist)
    if cache[remName] then
        return cache[remName] 
    end
	blacklist = blacklist or {}
	if remName == bedwars.ProjectileRemote then
		--customTable = bedwars.Client:GetNamespace(bedwars.ProjectileRemote, {"OasisProjectileFire"})
		blacklist = {"OasisProjectileFired"}
	end
    local remotes = customTable or getRemotes({"ReplicatedStorage"})
    for _, v in pairs(remotes) do
        if v.Name == remName or string.find(v.Name, remName) and not table.find(blacklist, v.Name) then  
            local remote
            if not resRequired then
                remote = decorateRemote(v, {})
            else
                local tbl = {}
                function tbl:InvokeServer()
                    local tbl2 = {}
                    local res = v:InvokeServer()
                    function tbl2:andThen(func)
                        func(res)
                    end
                    return tbl2
                end
				tbl = decorateRemote(v, tbl)
                remote = tbl
            end
            
            cache[remName] = remote 
            return remote
        end
    end
    warn(debug.traceback("[bedwars.Client:Get]: Failure finding remote! Remote: " .. tostring(remName) .. " CustomTable: " .. tostring(customTable or "no table specified") .. " Using backup table..."))
    local backupTable = {}
    function backupTable:FireServer() return false end
    function backupTable:InvokeServer() return false end
    cache[remName] = backupTable
    return backupTable
end

function bedwars.Client:GetNamespace(nameSpace, blacklist)
    local cacheKey = nameSpace .. (blacklist and table.concat(blacklist, ",") or "")
    if namespaceCache[cacheKey] then
        return namespaceCache[cacheKey]
    end
    local remotes = getRemotes({"ReplicatedStorage"})
    local resolvedRemotes = {}
    blacklist = blacklist or {}
    for _, v in pairs(remotes) do
        if (v.Name == nameSpace or string.find(v.Name, nameSpace)) and not table.find(blacklist, v.Name) then
            table.insert(resolvedRemotes, v)
        end
    end
    local resolveFunctionTable = {Namespace = resolvedRemotes}
    function resolveFunctionTable:Get(remName)
        return bedwars.Client:Get(remName, resolvedRemotes)
    end
    namespaceCache[cacheKey] = resolveFunctionTable 
    return resolveFunctionTable
end

function bedwars.Client:WaitFor(remName)
	local tbl = {}
	function tbl:andThen(func)
		repeat task.wait() until bedwars.Client:Get(remName)
		func(bedwars.Client:Get(remName).instance.OnClientEvent)
	end
	return tbl
end
bedwars.ClientStoreHandler = {}
function bedwars.ClientStoreHandler:dispatch() end
bedwars.KitMeta = decode(VoidwareFunctions.fetchCheatEngineSupportFile("KitMeta.json"))
bedwars.QueueMeta = decode(VoidwareFunctions.fetchCheatEngineSupportFile("QueueMeta.json"))
bedwars.SoundList = decode(VoidwareFunctions.fetchCheatEngineSupportFile("SoundListMeta.json"))
bedwars.ShopItemsMeta = decode(VoidwareFunctions.fetchCheatEngineSupportFile("ShopItemsMeta.json"))
bedwars.BalanceFile = decode(VoidwareFunctions.fetchCheatEngineSupportFile("BalanceFireMeta.json"))
bedwars.ProjectileMeta = decode(VoidwareFunctions.fetchCheatEngineSupportFile("ProjectileMeta.json"))
bedwars.KillEffectMeta = decode(VoidwareFunctions.fetchCheatEngineSupportFile("KillEffectMeta.json"))
bedwars.MageKitUtileMeta = decode(VoidwareFunctions.fetchCheatEngineSupportFile("MageKitUtileMeta.json"))
bedwars.AnimationTypeMeta = decode(VoidwareFunctions.fetchCheatEngineSupportFile("AnimationTypeMeta.json"))
bedwars.ItemHandler = { ItemMeta = decode(VoidwareFunctions.fetchCheatEngineSupportFile("ItemMeta.json")) }
bedwars.ProdAnimationsMeta = decode(VoidwareFunctions.fetchCheatEngineSupportFile("ProdAnimationsMeta.json"))
bedwars.ItemHandler.getItemMeta = function(item)
    for i,v in pairs(bedwars.ItemHandler.ItemMeta) do
        if i == item then return v end
    end
    return nil
end
bedwars.ItemMeta = bedwars.ItemTable
bedwars.AnimationType = bedwars.AnimationTypeMeta
bedwars.ShopItems = bedwars.ShopItemsMeta.ShopItems
bedwars.ItemTable = bedwars.ItemHandler.ItemMeta.items
bedwars.AnimationController = { 
	ProdAnimationsMeta = bedwars.ProdAnimationsMeta, 
	AnimationTypeMeta = bedwars.AnimationTypeMeta,
	getAssetId = function(self, IndexId) return self.ProdAnimationsMeta[IndexId] end
}
bedwars.AnimationUtil = {
	playAnimation = function(self, plr, id)
		repeat task.wait() until plr.Character
		local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
		if not humanoid then warn("[bedwars.AnimationUtil:playAnimation]: Humanoid not found in the character"); return end
		local animation = Instance.new("Animation")
		animation.AnimationId = id
		local animator = humanoid:FindFirstChildOfClass("Animator")
		if not animator then
			animator = Instance.new("Animator")
			animator.Parent = humanoid
		end
		local animationTrack = animator:LoadAnimation(animation)
		animationTrack:Play()
		return animationTrack 
	end,
	fetchAnimationIndexId = function(self, name)
		if not bedwars.AnimationController.AnimationTypeMeta[name] then return nil end
		for i,v in pairs(bedwars.AnimationController.AnimationTypeMeta) do
			if i == name then return v end
		end
		return nil
	end
}
bedwars.GameAnimationUtil = {
	playAnimation = function(plr, id)
		return bedwars.AnimationUtil:playAnimation(plr, bedwars.AnimationController:getAssetId(id))
	end
}
bedwars.ViewmodelController = {
	playAnimation = function(id)
		return bedwars.AnimationUtil:playAnimation(lplr, bedwars.AnimationController:getAssetId(id))
	end
}
local function getBestTool(block)
	local tool = nil
	local blockmeta = bedwars.ItemTable[block]
	if not blockmeta then return end
	local blockType = blockmeta.block and blockmeta.block.breakType
	if blockType then
		local best = 0
		for i,v in pairs(store.localInventory.inventory.items) do
			local meta = bedwars.ItemTable[v.itemType]
			if meta.breakBlock and meta.breakBlock[blockType] and meta.breakBlock[blockType] >= best then
				best = meta.breakBlock[blockType]
				tool = v
			end
		end
	end
	return tool
end
local cachedNormalSides = {}
for i,v in pairs(Enum.NormalId:GetEnumItems()) do if v.Name ~= "Bottom" then table.insert(cachedNormalSides, v) end end
local function getPlacedBlock(pos, strict)
    if not pos then 
        warn(debug.traceback("[getPlacedBlock]: pos is nil!")) 
        return nil 
    end

    local checkDistance = 1
    local regionSize = Vector3.new(0.1, 0.1, 0.1) 
    
    local nearbyParts = {}
    local directions = {
        Vector3.new(1, 0, 0),  
        Vector3.new(-1, 0, 0), 
        Vector3.new(0, 1, 0),  
        Vector3.new(0, -1, 0),  
        Vector3.new(0, 0, 1), 
        Vector3.new(0, 0, -1)  
    }
    
    local centerRegion = Region3.new(pos - regionSize/2, pos + regionSize/2)
    local centerParts = game.Workspace:FindPartsInRegion3(centerRegion, nil, math.huge)
    for _, part in pairs(centerParts) do
        if part and part.ClassName == "Part" and part.Parent then
			if bedwars.QueryUtil:isQueryIgnored(part) then continue end
            if strict then
                if part.Parent.Name == 'Blocks' and part.Parent.ClassName == "Folder" then
                    table.insert(nearbyParts, part)
                end
            else
                table.insert(nearbyParts, part)
            end
        end
    end
    
    for _, dir in pairs(directions) do
        local checkPos = pos + dir * checkDistance
        local region = Region3.new(checkPos - regionSize/2, checkPos + regionSize/2)
        local parts = game.Workspace:FindPartsInRegion3(region, nil, math.huge)
        
        for _, part in pairs(parts) do
            if part and part.ClassName == "Part" and part.Parent then
				if bedwars.QueryUtil:isQueryIgnored(part) then continue end
                if strict then
                    if part.Parent.Name == 'Blocks' and part.Parent.ClassName == "Folder" then
                        table.insert(nearbyParts, part)
                    end
                else
                    table.insert(nearbyParts, part)
                end
            end
        end
    end
    
    if #nearbyParts > 0 then
        return nearbyParts[1]
    end
    return nil
end
VoidwareFunctions.GlobaliseObject("getPlacedBlock", getPlacedBlock)
bedwars.BlockController = {
	isBlockBreakable = function() return true end,
	getBlockPosition = function(self, block, nearestBed) 
		local RayParams = RaycastParams.new()
		RayParams.FilterType = Enum.RaycastFilterType.Exclude
		local ignoreTable = bedwars.QueryUtil.queryIgnored
		if lplr.Character then
			table.insert(ignoreTable, lplr.Character)
		end
		RayParams.FilterDescendantsInstances = ignoreTable
		RayParams.IgnoreWater = true
		local RayRes = game.Workspace:Raycast(type(block) == "userdata" and block.Position or block + Vector3.new(0, 30, 0), Vector3.new(0, -35, 0), RayParams)
		local targetBlock
		if RayRes then
			targetBlock = RayRes.Instance or type(block) == "userdata" and black or nil	
			if RayRes.Instance ~= nil and RayRes.Instance:GetAttribute("NoBreak") and nearestBed ~= nil then
				targetBlock = nearestBed
			end	
			local function resolvePos(pos) return Vector3.new(math.round(pos.X / 3), math.round(pos.Y / 3), math.round(pos.Z / 3)) end
			return resolvePos(targetBlock.Position), targetBlock
		else
			return false
		end
	end,
	getBlockPosition2 = function(self, position)
		local RayParams = RaycastParams.new()
		RayParams.FilterType = Enum.RaycastFilterType.Exclude
		RayParams.FilterDescendantsInstances = {lplr.Character, game.Workspace.Camera}
		RayParams.IgnoreWater = true
		local startPosition = position + Vector3.new(0, 30, 0)
		local direction = Vector3.new(0, -35, 0)
		local RayRes = game.Workspace:Raycast(startPosition, direction, RayParams)
		if RayRes then
			local targetBlock = RayRes.Instance
			if targetBlock then
				local function resolvePos(pos)
					return Vector3.new(
						math.round(pos.X / 3),
						math.round(pos.Y / 3),
						math.round(pos.Z / 3)
					)
				end
				return resolvePos(targetBlock.Position)
			end
		end
		return nil
	end,
	calculateBlockDamage = function(self, plr, posTbl)
		local tool = getBestTool(tostring(posTbl.block))
		if not tool then return 0 end
		local tooldmg = bedwars.ItemTable[tostring(tool.itemType)].breakBlock
		if table.find(tooldmg, tostring(tool)) then tooldmg = tooldmg[tostring(tool)] else
			for i,v in pairs(tooldmg) do tooldmg = v break end
		end
		return tooldmg
	end,
	getAnimationController = function() return bedwars.AnimationController end,
	resolveBreakPosition = function(self, pos) return Vector3.new(math.round(pos.X / 3), math.round(pos.Y / 3), math.round(pos.Z / 3)) end,
	resolveRaycastResult = function(self, block)
		local RayParams = RaycastParams.new()
		RayParams.FilterType = Enum.RaycastFilterType.Exclude
		RayParams.FilterDescendantsInstances = {lplr.Character}
		RayParams.IgnoreWater = true
		return game.Workspace:Raycast(block.Position + Vector3.new(0, 30, 0), Vector3.new(0, -35, 0), RayParams)
	end,
	getStore = function()
		return {
			getBlockData = function(self, pos)
				return getPlacedBlock(pos)
			end,
			getBlockAt = function(self, pos)
				return getPlacedBlock(pos)
			end	
		}
	end
}
local function isBlockCovered(pos)
	local coveredsides = 0
	for i, v in pairs(cachedNormalSides) do
		local blockpos = (pos + (Vector3.FromNormalId(v) * 3))
		local block = getPlacedBlock(blockpos)
		if block then
			coveredsides = coveredsides + 1
		end
	end
	return coveredsides == #cachedNormalSides
end
local failedBreak = 0
bedwars.breakBlock = function(block, anim)
    if vape.Modules.InfiniteFly.Enabled or lplr:GetAttribute("DenyBlockBreak") then return end
	if block.Name == "bed" and tostring(block:GetAttribute("TeamId")) == tostring(lplr:GetAttribute("Team")) then return end
    local resolvedPos = bedwars.BlockController:getBlockPosition(block)
    if resolvedPos then
		local result = bedwars.Client:Get(bedwars.DamageBlockRemote):InvokeServer({
            blockRef = {
                blockPosition = resolvedPos
            },
            hitPosition = resolvedPos,
            hitNormal = Vector3.FromNormalId(Enum.NormalId.Right)
        })
		if result ~= "failed" then
			failedBreak = 0
			task.spawn(function()
				local animation
				if anim then
					animation = bedwars.AnimationUtil:playAnimation(lplr, bedwars.BlockController:getAnimationController():getAssetId(bedwars.AnimationUtil:fetchAnimationIndexId("BREAK_BLOCK")))
				end
				task.wait(0.3)
				if animation ~= nil then
					animation:Stop()
					animation:Destroy()
				end
			end)
		else
			failedBreak = failedBreak + 1
		end
    end
end
local updateitem = Instance.new("BindableEvent")
table.insert(vapeConnections, updateitem.Event:Connect(function(inputObj)
	if inputService:IsMouseButtonPressed(0) then
		game:GetService("ContextActionService"):CallFunction("block-break", Enum.UserInputState.Begin, newproxy(true))
	end
end))
local function encode(tbl)
    return game:GetService("HttpService"):JSONEncode(tbl)
end
local function corehotbarswitch(tool)
	local function findChild(name, className, children, nodebug)
		children = children:GetChildren()
        for i,v in pairs(children) do if v.Name == name and v.ClassName == className then return v end end
        local args = {Name = tostring(name), ClassName == tostring(className), Children = children}
        return nil
    end
	local function resolveHotbar()
		local hotbar
		hotbar = findChild("hotbar", "ScreenGui", lplr:WaitForChild("PlayerGui"))
		if not hotbar then return false end

		local _1 = findChild("1", "Frame", hotbar)
		if not _1 then return false end

		local ItemsHotbar = findChild("ItemsHotbar", "Frame", _1)
		if not ItemsHotbar then return false end

		return {
			hotbar = hotbar,
			items = ItemsHotbar
		}
	end
	local function resolveItemHotbar(hotbar)
		if tostring(hotbar) == "10" then return "blacklisted" end
		local res = {
			id = hotbar.Name,
			toolImage = "",
			toolAmount = 0,
			object = hotbar
		}
		if not tonumber(res.id) then return false end

		local _1 = findChild("1", "ImageButton", hotbar)
		if not _1 then return false end

		local __1 = findChild("1", "TextLabel", _1, true)
		if __1 then 
			res.toolAmount = tonumber(__1.Text) or nil
		end

		local _3 = findChild("3", "Frame", _1, true)
		if not _3 then return false end

		local ___1 = findChild("1", "ImageLabel", _3, true)
		if not ___1 then return false end
		res.toolImage = ___1.Image

		return res
	end
	local function resolveItemsHotbar(hotbar)
		local res = {}
		for i,v in pairs(hotbar:GetChildren()) do
			local rev = resolveItemHotbar(v)
			local name = tostring(v.Name)
			if rev and type(rev) == "table" then 
				if res[name] then warn("Duplication found! Overwriting... ["..name.."]") end
				res[name] = rev
			else
				if rev == "blacklisted" then continue end
				if res[name] then warn("Duplication found! Overwriting... ["..name.."]") end
				res[name] = {
					object = v
				}
			end
		end
		return res
	end
	local function findTool(items_rev, img)
		local res = {
			tool = nil,
			activated = nil
		}
		for i,v in pairs(items_rev) do
			if v.toolImage and tostring(v.toolImage) == tostring(img) then 
				res.tool = v
			end
			local img = findChild("1", "ImageButton", v.object)
			if img and img.Position ~= UDim2.new(0, 0, 0, 0) then
				res.activated = v
			end
		end
		return res
	end
	local function deactivatify(object)
		local img = findChild("1", "ImageButton", object)
		if img then
			img.Position = UDim2.new(0, 0, 0, 0)
			img.BorderColor3 = Color3.fromRGB(114, 127, 172)
			local text = findChild("1", "TextLabel", img)
			text.TextColor3 = Color3.fromRGB(255, 255, 255)
			text.BackgroundColor3 = Color3.fromRGB(114, 127, 172)
		end
	end
	local function activatify(object)
		local img = findChild("1", "ImageButton", object)
		if img then
			img.Position = UDim2.new(0, 0, -0.075, 0)
			img.BorderColor3 = Color3.fromRGB(255, 255, 255)
			local text = findChild("1", "TextLabel", img)
			text.TextColor3 = Color3.fromRGB(0, 0, 0)
			text.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		end
	end
	task.spawn(function()
		local function run(func)
			local suc, err = pcall(function()
				func()
			end)
			if err then warn("[CoreSwitch Error]: "..tostring(debug.traceback(err))) end
		end
		run(function()
			if not lplr.Character then return false end

			if not tool then
				tool = lplr.Character and lplr.Character:FindFirstChild('HandInvItem') and lplr.Character:FindFirstChild('HandInvItem').Value or nil
			end
			if not tool then return false end
			tool = tostring(tool)

			local hotbar_rev = resolveHotbar()
			if not hotbar_rev then return false end

			local ItemsHotbar = hotbar_rev.items
			local items_rev = resolveItemsHotbar(ItemsHotbar)
			if not items_rev then return false end
		
			repeat task.wait() until (bedwars.ItemMeta ~= nil and type(bedwars.ItemMeta) == "table") or (bedwars.ItemTable ~= nil and type(bedwars.ItemTable) == "table")
			local meta = ((bedwars.ItemMeta and bedwars.ItemMeta[tool]) or (bedwars.ItemTable and bedwars.ItemTable[tool]))
			if ((not meta) or (meta ~= nil and (not meta.image))) then return false end

			local img = meta.image
			
			local tool_rev = findTool(items_rev, img)
			if ((not tool_rev) or ((tool_rev ~= nil) and (not tool_rev.tool))) then return false end
			local rev = {
				image = findChild("1", "ImageButton", tool_rev.tool.object)
			}
			if tool_rev.activated then 
				rev.activate = findChild("1", "ImageButton", tool_rev.activated.object)
			end
			if (not rev.image) then return false end

			if rev.activate then
				deactivatify(tool_rev.activated.object)
			end
			activatify(tool_rev.tool.object)
		end)	
	end)
end

local function coreswitch(tool, ignore)
    local character = lplr.Character
    if not character then return end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end

	if not ignore then
		local currentHandItem
		for _, acc in character:GetChildren() do
			if acc:IsA("Accessory") and acc:GetAttribute("InvItem") == true and acc:GetAttribute("ArmorSlot") == nil and acc:GetAttribute("IsBackpack") == nil then
				currentHandItem = acc
				break
			end
		end
		if currentHandItem then
			currentHandItem:Destroy()
		end
	
		for _, weld in pairs(character:GetDescendants()) do
			if weld:IsA("Weld") and weld.Name == "HandItemWeld" then
				weld:Destroy()
			end
		end
	
		local inventoryFolder = character:FindFirstChild("InventoryFolder")
		if not inventoryFolder or not inventoryFolder.Value then return end
		local toolInstance = inventoryFolder.Value:FindFirstChild(tool.Name)
		if not toolInstance then return end
		local clone = toolInstance:Clone()
	
		clone:SetAttribute("InvItem", true)
	
		humanoid:AddAccessory(clone)
	
		local handle = clone:FindFirstChild("Handle")
		if handle and handle:IsA("BasePart") then
			local attachment = handle:FindFirstChildWhichIsA("Attachment")
			if attachment then
				local characterAttachment = character:FindFirstChild(attachment.Name, true)
				if characterAttachment and characterAttachment:IsA("Attachment") then
					local weld = Instance.new("Weld")
					weld.Name = "HandItemWeld"
					weld.Part0 = characterAttachment.Parent 
					weld.Part1 = handle
					weld.C0 = characterAttachment.CFrame
					weld.C1 = attachment.CFrame
					weld.Parent = handle
				end
			end
		end
	
		local handInvItem = character:FindFirstChild("HandInvItem")
		if handInvItem then
			handInvItem.Value = tool
		end
	end

	pcall(function()
		local res = bedwars.Client:Get(bedwars.EquipItemRemote):InvokeServer({hand = tool})
		if res ~= nil and res == true then
			local handInvItem = character:FindFirstChild("HandInvItem")
			if handInvItem then
				handInvItem.Value = tool
			end
		elseif string.find(string.lower(tostring(res)), 'promise') then
			res:andThen(function(res)
				if res == true then
					local handInvItem = character:FindFirstChild("HandInvItem")
					if handInvItem then
						handInvItem.Value = tool
					end
				end
			end)
		end
	end)

    return true
end

local function getItem(itemName, inv)
	for slot, item in pairs(inv or store.localInventory.inventory.items) do
		if item.itemType == itemName then
			return item, slot
		end
	end
	return nil
end
VoidwareFunctions.GlobaliseObject("getItem", getItem)

local function switchItem(tool, delayTime)
	if tool ~= nil and type(tool) == "string" then
		tool = getItem(tool) and getItem(tool).tool
	end
	local _tool = lplr.Character and lplr.Character:FindFirstChild('HandInvItem') and lplr.Character:FindFirstChild('HandInvItem').Value or nil
	if _tool ~= nil and _tool ~= tool then
		coreswitch(tool, true)
		corehotbarswitch()
	end
end

local switchitem = switchItem
VoidwareFunctions.GlobaliseObject("switchItem", switchItem)
local function switchToAndUseTool(block, legit)
	local tool = getBestTool(block.Name)
	if tool and (entityLibrary.isAlive and lplr.Character:FindFirstChild("HandInvItem") and lplr.Character.HandInvItem.Value ~= tool.tool) then
		switchItem(tool.tool)
	end
end
bedwars.ClientDamageBlock = {}
function bedwars.ClientDamageBlock:Get(rem)
	local a = bedwars.Client:Get(bedwars.DamageBlockRemote)
	local tbl = {}
	function tbl:CallServerAsync(call)
		local res = a:InvokeServer(call)
		local tbl2 = {}
		function tbl2:andThen(func)
			func(res)
		end
		return tbl2
	end
	return tbl
end
function bedwars.ClientDamageBlock:WaitFor(remName)
	return bedwars.Client:WaitFor(remName)
end
local function getLastCovered(pos, normal)
	local lastfound, lastpos = nil, nil
	for i = 1, 20 do
		local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
		local extrablock, extrablockpos = getPlacedBlock(blockpos)
		local covered = isBlockCovered(blockpos)
		if extrablock then
			lastfound, lastpos = extrablock, extrablockpos
			if not covered then
				break
			end
		else
			break
		end
	end
	return lastfound, lastpos
end

local healthbarblocktable = {
	blockHealth = -1,
	breakingBlockPosition = Vector3.zero
}
local physicsUpdate = 1 / 60
local getBlockHealth = function() end
getBlockHealth = function(block, blockpos)
	return block:GetAttribute('Health')
end

local function getTool(breakType)
	local bestTool, bestToolSlot, bestToolDamage = nil, nil, 0
	for slot, item in store.localInventory.inventory.items do
		local toolMeta = bedwars.ItemTable[item.itemType].breakBlock
		if toolMeta then
			local toolDamage = toolMeta[breakType] or 0
			if toolDamage > bestToolDamage then
				bestTool, bestToolSlot, bestToolDamage = item, slot, toolDamage
			end
		end
	end
	return bestTool, bestToolSlot
end

local getBlockHits = function() end
getBlockHits = function(block, blockpos)
	if not block then return 0 end
	local suc, res = pcall(function()
		local breaktype = bedwars.ItemTable[block.Name] and bedwars.ItemTable[block.Name].block and bedwars.ItemTable[block.Name].block.breakType
		local tool = getTool(breaktype)
		tool = tool and bedwars.ItemTable[tool.itemType].breakBlock[breaktype] or 2
		return getBlockHealth(block, bedwars.BlockController:getBlockPosition(blockpos)) / tool
	end)
	return suc and res or 0
end

local cache = {}
local sides = {
    Vector3.new(3, 0, 0),  
    Vector3.new(-3, 0, 0),
    Vector3.new(0, 3, 0), 
    Vector3.new(0, -3, 0), 
    Vector3.new(0, 0, 3),  
    Vector3.new(0, 0, -3)
}
local calculatePath = function() end
calculatePath = function(target, blockpos)
	if cache[blockpos] then
		return unpack(cache[blockpos])
	end
	local visited, unvisited, distances, air, path = {}, {{0, blockpos}}, {[blockpos] = 0}, {}, {}
	local blocks = {}
	for _ = 1, 10000 do
		local _, node = next(unvisited)
		if not node then break end
		table.remove(unvisited, 1)
		visited[node[2]] = true
		for _, side in sides do
			side = node[2] + side
			if visited[side] then continue end
			local block = getPlacedBlock(side)
			if not block or block:GetAttribute('NoBreak') or block == target then
				if not block then
					air[node[2]] = true
				end
				continue
			end
			table.insert(blocks, block)
			local curdist = getBlockHits(block, side) + node[1]
			if curdist < (distances[side] or math.huge) then
				table.insert(unvisited, {curdist, side})
				distances[side] = curdist
				path[side] = node[2]
			end
		end
	end
	local pos, cost = nil, math.huge
	for node in air do
		if distances[node] < cost then
			pos, cost = node, distances[node]
		end
	end
	if pos then
		cache[blockpos] = { pos, cost, path, blocks }
		return pos, cost, path, blocks
	end
end

local getPickaxe = function() end

local function run(func)
	local suc, err = pcall(function()
		func()
	end)
	if err then warn("[CE687224481.lua Module Error]: "..tostring(debug.traceback(err))) end
end

run(function()
    local VisualizerHighlight = nil
    local LastBlock = nil
    local VisualizerTimeout = 1
    local LastBreakTime = 0
    local IsBreaking = false

    local function updateVisualizer(block, isBreaking)
        local currentTime = tick()

        if not isBreaking and not block then
            if VisualizerHighlight then
                VisualizerHighlight:Destroy()
                VisualizerHighlight = nil
            end
            LastBlock = nil
            LastBreakTime = 0
            IsBreaking = false
            return
        end

        if block then
            local blockKey = tostring(block.Position) 

            if blockKey ~= LastBlock or not VisualizerHighlight or not VisualizerHighlight.Parent then
                if VisualizerHighlight then
                    VisualizerHighlight:Destroy()
                end

                VisualizerHighlight = Instance.new("Highlight")
                VisualizerHighlight.Adornee = block
                VisualizerHighlight.FillTransparency = 1
                VisualizerHighlight.OutlineTransparency = 0.3 
                VisualizerHighlight.Parent = workspace

                VisualizerHighlight.OutlineColor = (blockKey ~= LastBlock) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 165, 0)
                LastBlock = blockKey
            end

            IsBreaking = isBreaking
            LastBreakTime = currentTime

            task.spawn(function()
                while VisualizerHighlight and VisualizerHighlight.Parent and (tick() - LastBreakTime < VisualizerTimeout) and IsBreaking do
                    task.wait(0.1)
                end
                if VisualizerHighlight and VisualizerHighlight.Parent then
                    VisualizerHighlight:Destroy()
                    VisualizerHighlight = nil
                    LastBlock = nil
                    IsBreaking = false
                end
            end)
        end
    end
end)
bedwars.placeBlock = function(pos, blockName)
	bedwars.Client:GetNamespace("PlaceBlock", {"PlaceBlockEvent", "DefenderRequestPlaceBlock"}):Get("PlaceBlock"):InvokeServer({
		["blockType"] = blockName,
		["position"] = Vector3.new(pos.X/3, pos.Y/3, pos.Z/3),
		["blockData"] = 0
	})
end
bedwars.getIcon = function(item, showinv)
	local itemmeta = bedwars.ItemTable[item.itemType]
	if itemmeta and showinv then
		return itemmeta.image or ""
	end
	return ""
end
bedwars.getInventory = function(plr)
	local inv = {
		items = {},
		armor = {}
	}
	local repInv = plr.Character and plr.Character:FindFirstChild("InventoryFolder") and plr.Character:FindFirstChild("InventoryFolder").Value
	if repInv then
		if repInv.ClassName and repInv.ClassName == "Folder" then
			for i,v in pairs(repInv:GetChildren()) do
				if not v:GetAttribute("CustomSpawned") then
					table.insert(inv.items, {
						tool = v,
						itemType = tostring(v),
						amount = v:GetAttribute("Amount")
					})
				end
			end
		end
	end
	local plrInvTbl = {
		"ArmorInvItem_0",
		"ArmorInvItem_1",
		"ArmorInvItem_2"
	}
	local function allowed(char)
		local state = true
		for i,v in pairs(plrInvTbl) do if (not char:FindFirstChild(v)) then state = false end end
		return state
	end
	local plrInv = plr.Character and allowed(plr.Character)
	if plrInv then
		for i,v in pairs(plrInvTbl) do
			table.insert(inv.armor, tostring(plr.Character:FindFirstChild(v).Value) == "" and "empty" or tostring(plr.Character:FindFirstChild(v).Value) ~= "" and {
				tool = v,
				itemType = tostring(plr.Character:FindFirstChild(v).Value)
			})
		end
	end
	return inv
end
bedwars.getKit = function(plr)
	return plr:GetAttribute("PlayingAsKits") or "none"
end
bedwars.QueueController = {
	leaveParty = function() bedwars.Client:Get("LeaveParty"):InvokeServer() end,
	joinQueue = function(self, queueType) bedwars.Client:Get("joinQueue"):FireServer({["queueType"] = queueType}) end
}
bedwars.InfernalShieldController = {
	raiseShield = function() bedwars.Client:Get("UseInfernalShield"):FireServer({["raised"] = true}) end
}
bedwars.SwordController = {
    lastSwing = tick(),
	lastAttack = game.Workspace:GetServerTimeNow(),
	isClickingTooFast = function() end,
	canSee = function() return true end,
	playSwordEffect = function(swordmeta, status)
		task.spawn(function()
			local animation
			local animName = swordmeta.displayName:find(" Scythe") and "SCYTHE_SWING" or "SWORD_SWING"
			local animCooldown = swordmeta.displayName:find(" Scythe") and 0.3 or 0.15
			animation = bedwars.AnimationUtil:playAnimation(lplr, bedwars.BlockController:getAnimationController():getAssetId(bedwars.AnimationUtil:fetchAnimationIndexId(animName)))
			task.wait(animCooldown)
			if animation ~= nil then animation:Stop(); animation:Destroy() end
		end)
	end,
	swingSwordAtMouse = function() pcall(function() return bedwars.Client:Get("SwordSwingMiss"):FireServer({["weapon"] = store.localHand.tool, ["chargeRatio"] = 0}) end) end
}
bedwars.ScytheController = {
	playLocalAnimation = function()
		task.spawn(function()
			local animation
			animation = bedwars.AnimationUtil:playAnimation(lplr, bedwars.BlockController:getAnimationController():getAssetId(bedwars.AnimationUtil:fetchAnimationIndexId("SCYTHE_SWING")))
			task.wait(0.3)
			if animation ~= nil then
				animation:Stop()
				animation:Destroy()
			end
		end)
	end
}
bedwars.SettingsController = {
	setFOV = function(self, num) gameCamera.FieldOfView = num end
}
bedwars.AppController = {
	isAppOpen = function(appName) return lplr.PlayerGui:FindFirstChild(appName) end
}
bedwars.BalloonController = {}
function bedwars.BalloonController:inflateBalloon()
	bedwars.Client:Get("InflateBalloon"):FireServer()
end
bedwars.SoundManager = {}
function bedwars.SoundManager:playSound(soundId)
	local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Parent = game.Workspace
    sound:Play()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end
bedwars.QueryUtil = {
	queryIgnored = {},
	setQueryIgnored = function(self, object, status)
		if status == nil then status = true end
		if status == true then table.insert(self.queryIgnored, object) else 
			local index = table.find(self.queryIgnored, object) 
			if index then table.remove(self.queryIgnored, index) end
		end
		object:SetAttribute("gamecore_GameQueryIgnore", status)
	end,
	isQueryIgnored = function(self, object)
		return object:GetAttribute("gamecore_GameQueryIgnore")
	end
}
bedwars.MatchController = {
	fetchPlayerTeam = function(self, plr)
		return tostring(plr.Team)
	end,
	fetchGameTime = function(self)
		local time, timeTable, suc = 0, {seconds = 0, minutes = 0}, false
		local window = lplr.PlayerGui:FindFirstChild("TopBarAppGui")
		if window then
			local frame = window:FindFirstChild("TopBarApp")
			if frame then
				for i,v in pairs(frame:GetChildren()) do
					if v.ClassName == "Frame" and v:FindFirstChild("4") and v:FindFirstChild("5") then
						if v:FindFirstChild("4").ClassName == "ImageLabel" and v:FindFirstChild("5").ClassName == "TextLabel" then
							time, timeTable, suc = extractTime(v:FindFirstChild("5").Text):toSeconds(), {
								seconds = extractTime(v:FindFirstChild("5").Text).seconds,
								minutes = extractTime(v:FindFirstChild("5").Text).minutes
							}, true
							break
						end
					end
				end
			end
		end
		return time, timeTable, suc
	end
}
local lastTime, timeMoving = 0, true
task.spawn(function()
	repeat 
		local time, timeTable, suc = bedwars.MatchController:fetchGameTime()
		if time == lastTime then timeMoving = false else timeMoving = true end
		lastTime = time
		task.wait(2)
	until (not shared.VapeExecuted)
end)
function bedwars.MatchController:fetchMatchState()
	local matchState = 0

	local time, timeTable, suc
	time, timeTable, suc = bedwars.MatchController:fetchGameTime()
	if (not suc) then time, timeTable, suc = bedwars.MatchController:fetchGameTime() end
	local plrTeam = bedwars.MatchController:fetchPlayerTeam(lplr)

	if time > 0 then matchState = plrTeam == "Spectators" and 2 or 1 else matchState = 0 end
	if (not timeMoving) and time > 0 then matchState = 2 end

	if (not suc) then warn("[bedwars.MatchController:fetchMatchState]: Failure getting valid time!"); matchState = 1 end

	return matchState
end
bedwars.RavenController = {}
function bedwars.RavenController:detonateRaven()
	bedwars.Client:Get("DetonateRaven"):InvokeServer()
end
bedwars.DefaultKillEffect = {
	onKill = function() end
}
vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
	local killer = playersService:GetPlayerFromCharacter(deathTable.fromEntity)
	local killed = playersService:GetPlayerFromCharacter(deathTable.entityInstance)
	bedwars.DefaultKillEffect.onKill(nil, nil, killed, nil)
end)
bedwars.CooldownController = {}
local cooldownTable = {}
function cooldownTable:fetchIndexes()
	local indexes = {}
	for i,v in pairs(cooldownTable) do if type(v) ~= "function" then table.insert(indexes, v) end end
	return indexes
end
function cooldownTable:fetchItemIndex(item)
	local itemIndex
	for i,v in pairs(cooldownTable:fetchIndexes()) do if v.item == item then itemIndex = i end break end
	if (not itemIndex) then warn("[cooldownTable:fetchItemIndex]: FAILURE! itemIndex for "..tostring(item).." not found!"); return nil end
	return itemIndex
end
function cooldownTable:revokeCooldownAction(item)
	local itemIndex = cooldownTable:fetchItemIndex(item)
	if (not itemIndex) then warn("[cooldownTable:revokeCooldownAction]: Failure! Item: "..tostring(item)); return end
	cooldownTable[itemIndex].canceled = true
end
function cooldownTable:activateCooldownAction(item)
	local itemIndex = cooldownTable:fetchItemIndex(item)
	if (not itemIndex) then warn("[cooldownTable:activateCooldownAction]: Failure! Item: "..tostring(item)); return end
	task.spawn(function()
		repeat
			cooldownTable[itemIndex].cooldown = cooldownTable[itemIndex].cooldown - 0.1
			task.wait(0.1)
		until cooldownTable[itemIndex].cooldown == 0 or cooldownTable[itemIndex].cooldown < 0 or cooldownTable[itemIndex].canceled
		cooldownTable[itemIndex].cooldown = 0
		cooldownTable[itemIndex] = nil
	end)
end
function cooldownTable:registerCooldownItem(item, cooldown)
	cooldownTable[tostring(game:GetService("HttpService"):GenerateGUID(false))] = {["item"] = item, ["cooldown"] = cooldown, ["canceled"] = false} 
end
bedwars.CooldownController.CooldownTable = cooldownTable
function bedwars.CooldownController:setOnCooldown(item, cooldown)
	cooldownTable:registerCooldownItem(item, cooldown)
	cooldownTable:activateCooldownAction(item)
end
function bedwars.CooldownController:getRemainingCooldown(item)
	local itemIndex = cooldownTable:fetchItemIndex(item)
	if (not itemIndex) then cooldownTable:registerCooldownItem(item, 0) return 0 end
	return cooldownTable[itemIndex].cooldown
end
bedwars.AbilityController = {
	canUseAbility = function() return true end,
	useAbility = function(self, ability, ...) bedwars.Client:Get("useAbility"):FireServer(ability, ...) end
}
local bowConstants = {}
local function getBowConstants()
	return {
		RelZ = 0,
		RelX = 0.8,
		RelY = -0.6,
		CameraMultiplier = 10,
		BeamGrowthMultiplier = 0.08
	}
end
bowConstants = getBowConstants()
bedwars.BowConstantsTable = bowConstants
bedwars.ProjectileUtil = {}
function bedwars.ProjectileUtil:createProjectile(p15, p16, p17, p18)
	local l__Projectiles__19, l__ProjectileMeta__5, l__Workspace__3, l__CollectionService__12 = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Projectiles"), bedwars.ProjectileMeta, game.Workspace, collectionService
	local u20 = nil;
	u20 = function(p19)
		return "projectile:" .. tostring(p19);
	end;
	local v68 = l__ProjectileMeta__5[p16].projectileModel;
	if v68 == nil then
		v68 = p16;
	end;
	local v69 = l__Projectiles__19:WaitForChild(v68);
	assert(v69, "Projectile model for projectile " .. p16 .. " can't be found.");
	local v70 = v69:Clone();
	assert(v70.PrimaryPart, "Primary part missing on projectile " .. v70.Name);
	v70.Name = p16;
	if p18 == nil then
		return nil;
	end;
	v70:SetPrimaryPartCFrame(p18);
	v70.Parent = l__Workspace__3;
	v70:SetAttribute("ProjectileShooter", p15.UserId);
	l__CollectionService__12:AddTag(v70, u20(p15.UserId));
	return v70;
end
function bedwars.ProjectileUtil.setupProjectileConstantOrientation(p22, p23)
	local l__ProjectileMeta__5, l__Players__9 = bedwars.ProjectileMeta, game:GetService("Players")
	local v76 = l__ProjectileMeta__5[p22.Name];
	if v76.useServerModel and p23 ~= l__Players__9.LocalPlayer then
		return v75;
	end;
	return v75;
end
bedwars.ProjectileController = {}
function bedwars.ProjectileController:createLocalProjectile(p29, p30, p31, p32, p33, p34, p35, p36)
	local l__ProjectileMeta__18, l__ProjectileUtil__20, l__Players__10 = bedwars.ProjectileMeta, bedwars.ProjectileUtil, game:GetService("Players")
	local v40 = l__ProjectileMeta__18[p31];
	local v41 = l__ProjectileUtil__20.createProjectile(l__Players__10.LocalPlayer, p30, p31, (l__Players__10.LocalPlayer.Character:GetPrimaryPartCFrame()));
	if not v41 or not (not v40.useServerModel) then
		return;
	end;
	l__ProjectileUtil__20.setupProjectileConstantOrientation(v41, l__Players__10.LocalPlayer);
	local v42 = 1;
	local v43 = p36;
	if v43 ~= nil then
		v43 = v43.drawDurationSeconds;
	end;
	local v44 = v43 ~= nil;
	p30 = bedwars.ItemTable[p31]
	if v44 then
		local v45 = p30;
		if v45 ~= nil then
			v45 = v45.maxStrengthChargeSec;
		end;
		v44 = v45;
	end;
	if v44 ~= 0 and v44 == v44 and v44 then
		v42 = math.clamp(p36.drawDurationSeconds / p30.maxStrengthChargeSec, 0, 1);
	end;
	local v46 = v40.gravitationalAcceleration;
	if v46 == nil then
		v46 = 196.2;
	end;
	local v47 = {};
	local v48 = p30;
	if v48 ~= nil then
		v48 = v48.relativeOverride;
	end;
	v47.relative = v48;
	v47.projectileSource = p30;
	v47.drawPercent = v42;
	return v41;
end
bedwars.MageElementMeta = bedwars.MageKitUtileMeta.MageElementMeta
bedwars.MageKitUtil = { MageElementVisualizations = bedwars.MageElementMeta }
bedwars.MageController = {}
bedwars.FishermanController = { startMinigame = function() end }
bedwars.DragonSlayerController = {
	emblemCache = {},
	playPunchAnimation = function(self, animPos) return bedwars.GameAnimationUtil.playAnimation(lplr, bedwars.AnimationType.DRAGON_SLAYER_PUNCH) end,
	fetchDragonEmblems = function() return game.Workspace:FindFirstChild("DragonEmblems") and game.Workspace:FindFirstChild("DragonEmblems").ClassName and game.Workspace:FindFirstChild("DragonEmblems").ClassName == "Folder" and game.Workspace:FindFirstChild("DragonEmblems"):GetChildren() or {} end,
	fetchDragonEmblemData = function(self, emblem)
		--[[if self.emblemCache[emblem] then
			return self.emblemCache[emblem] 
		end--]]
		local c = emblem and emblem.Parent and emblem.ClassName and emblem.ClassName == "Model" and emblem:GetChildren() or {}
		local cn = #c
		local tbl = {
			stackCount = 0,
			CFrame = emblem:GetPrimaryPartCFrame()
		}
		if cn == 3 then
			for i, v in pairs(c) do
				if v.Parent and v.ClassName and v.ClassName == "MeshPart" then
					if tostring(v.BrickColor) == "Persimmon" then
						tbl.stackCount = tbl.stackCount + 1
					end
				end
			end
		end
		self.emblemCache[emblem] = tbl
		return tbl
	end,
	deleteEmblem = function(self, emblem) pcall(function() emblem:Destroy() end) end,
	resolveTarget = function(self, emblemCFrame)
		local target
		local maxDistance = 5
		for i, v in pairs(game.Workspace:GetChildren()) do
			if v and v.Parent and v.ClassName == "Model" and #v:GetChildren() > 0 and v.PrimaryPart then
				local distance = (v:GetPrimaryPartCFrame().Position - emblemCFrame.Position).Magnitude
				if distance <= maxDistance then target = v break end
			end
		end
		return target
	end
}
bedwars.GrimReaperController = {
	fetchSoulsByPosition = function()
		local souls = {}
		for i,v in pairs(game.Workspace:GetChildren()) do
			if v and v.Parent and v.ClassName and v.ClassName == "Model" and v.Name == "GrimReaperSoul" and v:FindFirstChild("GrimSoul") then
				table.insert(souls, v)
			end
		end
		return souls
	end
}
bedwars.SpiritAssassinController = {
	fetchSpiritOrbs = function()
		local orbs = {}
		for i,v in pairs(game.Workspace:GetChildren()) do
			if v.Name == "SpiritOrb" and v.ClassName == "Model" and v:GetAttribute("SpiritSecret") then
				table.insert(orbs, v)
			end
		end
		return orbs
	end,
	activateOrb = function(self, orb) bedwars.Client:GetNamespace("UseSpirit", {"SpiritAssassinWinEffectUseSpirit", "SpiritAssassinUseSpirit"}):Get("UseSpirit"):InvokeServer({["secret"] = tostring(orb:GetAttribute("SpiritSecret"))}) end,
	Invoke = function() for i,v in pairs(self:fetchSpiritOrbs()) do self:activateOrb(v) end end
}
bedwars.WarlockController = { 
	cooldown = 3, 
	last = 0,
	link = function(self, target)
		if not target then return end
		local current = tick()
		if current - self.last < self.cooldown then return end
		self.last = current
		return bedwars.Client:Get("WarlockLinkTarget"):InvokeServer({["target"] = target})
	end
}
bedwars.EmberController = {
	BladeRelease = function(self, blade)
		if not blade then return end
		return bedwars.Client:Get('HellBladeRelease'):FireServer({chargeTime = 1, player = lplr, weapon = blade})
	end
}
bedwars.KaidaController = {
	request = function(self, target)
		if not target then return end
		return bedwars.Client:Get("SummonerClawAttackRequest"):FireServer({["clientTime"] = tick(), ["direction"] = (target:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("HumanoidRootPart").Position - lplr.Character.HumanoidRootPart.Position).unit, ["position"] = target:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("HumanoidRootPart").Position})
	end
}
bedwars.DaoController = {chargingMaid = nil}
local function applyProps(instance, props)
    for prop, value in next, props do
        if prop ~= "Parent" and prop ~= "Adornee" then
            instance[prop] = value
        end
    end
    if props.Adornee then
        instance.Adornee = props.Adornee
    end
    if props.Parent then
        instance.Parent = props.Parent
    end
end

local function createInstanceFromElement(element)
    local instance
    if element.Type == "BillboardGui" then
        instance = Instance.new("BillboardGui")
    elseif element.Type == "Frame" then
        instance = Instance.new("Frame")
    elseif element.Type == "UICorner" then
        instance = Instance.new("UICorner")
    elseif element.Type == "ImageLabel" then
        instance = Instance.new("ImageLabel")
    elseif element.Type == "TextLabel" then
        instance = Instance.new("TextLabel")
    else
        return nil
    end
    applyProps(instance, element.Props)
    if element.Ref then
        element.Ref.Value = instance
    end
    for _, child in next, element.Children do
        local childInstance = createInstanceFromElement(child)
        if childInstance then
            childInstance.Parent = instance
        end
    end
    return instance
end

bedwars.Roact = {
	createElement = function(elementType, props, children)
		local element = { Type = elementType, Props = props or {}, Children = children or {} }
		if props and props[CustomRoact.Ref] then
			element.Ref = props[CustomRoact.Ref]
			props[CustomRoact.Ref] = nil
		end
		return element
	end,
	Ref = function()
		return {
			Value = nil,
			getValue = function(self)
				return self.Value
			end
		}
	end,
	mount = function(element, parent)
		local instance = createInstanceFromElement(element)
		if instance then
			instance.Parent = parent
		end
		return {Instance = instance}
	end,
	unmount = function(mounted) 
		if mounted and mounted.Instance then
			mounted.Instance:Destroy()
		end
	end
}

bedwars.RuntimeLib = {
	Promise = {
		new = function(executor)
			local i = {
				Status = "Pending",
				Callbacks = {},
				andThen = function(self, callback)
					if self.Status == "Fulfilled" then
						task.spawn(callback)
					elseif self.Status == "Pending" then
						table.insert(self.Callbacks, callback)
					end
					return self
				end
			}
			task.spawn(pcall, function() executor(i) end)
			return i
		end,
		delay = function(seconds)
			return bedwars.RuntimeLib.Promise.new(function(resolve)
				task.wait(seconds)
				resolve()
			end)
		end
	}	
}

local function collection(tags, module, customadd, customremove)
	tags = typeof(tags) ~= 'table' and {tags} or tags
	local objs, connections = {}, {}

	for _, tag in tags do
		table.insert(connections, collectionService:GetInstanceAddedSignal(tag):Connect(function(v)
			if customadd then
				customadd(objs, v, tag)
				return
			end
			table.insert(objs, v)
		end))
		table.insert(connections, collectionService:GetInstanceRemovedSignal(tag):Connect(function(v)
			if customremove then
				customremove(objs, v, tag)
				return
			end
			v = table.find(objs, v)
			if v then
				table.remove(objs, v)
			end
		end))

		for _, v in collectionService:GetTagged(tag) do
			if customadd then
				customadd(objs, v, tag)
				continue
			end
			table.insert(objs, v)
		end
	end

	local cleanFunc = function(self)
		for _, v in connections do
			v:Disconnect()
		end
		table.clear(connections)
		table.clear(objs)
		table.clear(self)
	end

	return objs, cleanFunc
end

bedwars.StoreController = {
	fetchLocalHand = function()
		repeat task.wait() until lplr.Character
		return lplr.Character:FindFirstChild("HandInvItem")
	end,
	updateLocalInventory = function()
		store.localInventory.inventory = bedwars.getInventory(lplr)
		store.inventory = store.localInventory
	end,
	updateEquippedKit = function()
		store.equippedKit = bedwars.getKit(lplr)
	end,
	updateMatchState = function()
		store.matchState = bedwars.MatchController:fetchMatchState()
	end,
	updateBowConstantsTable = function(self, targetPos)
		bedwars.BowConstantsTable = getBowConstants(targetPos)
	end,
	updateStoreBlocks = function()
		--[[if store.blocksConnected then return end
		store.blocksConnected = true
		store.blocks = collection("blocks")--]]
	end,
	updateZephyrOrb = function()
		if lplr:FindFirstChild("PlayerGui") and lplr:FindFirstChild("PlayerGui"):FindFirstChild("StatusEffectHudScreen") and lplr:FindFirstChild("PlayerGui"):FindFirstChild("StatusEffectHudScreen"):FindFirstChild("StatusEffectHud") and lplr:FindFirstChild("PlayerGui"):FindFirstChild("StatusEffectHudScreen"):FindFirstChild("StatusEffectHud"):FindFirstChild("WindWalkerEffect") and lplr:FindFirstChild("PlayerGui"):FindFirstChild("StatusEffectHudScreen"):FindFirstChild("StatusEffectHud"):FindFirstChild("WindWalkerEffect"):FindFirstChild("EffectStack") and lplr:FindFirstChild("PlayerGui"):FindFirstChild("StatusEffectHudScreen"):FindFirstChild("StatusEffectHud"):FindFirstChild("WindWalkerEffect"):FindFirstChild("EffectStack").ClassName and lplr:FindFirstChild("PlayerGui"):FindFirstChild("StatusEffectHudScreen"):FindFirstChild("StatusEffectHud"):FindFirstChild("WindWalkerEffect"):FindFirstChild("EffectStack").ClassName == "TextLabel" then store.zephyrOrb = tonumber(lplr:FindFirstChild("PlayerGui"):FindFirstChild("StatusEffectHudScreen"):FindFirstChild("StatusEffectHud"):FindFirstChild("WindWalkerEffect"):FindFirstChild("EffectStack").Text) end
	end,
	updateLocalHand = function(self)
		local currentHand = self:fetchLocalHand()
		if (not currentHand) then store.localHand = {} return end
		local handType = ""
		if currentHand and currentHand.Value and currentHand.Value ~= "" then
			local handData = bedwars.ItemTable[tostring(currentHand.Value)]
			handType = handData.sword and "sword" or handData.block and "block" or tostring(currentHand.Value):find("bow") and "bow"
		end
		store.localHand = {tool = currentHand and currentHand.Value, itemType = currentHand and currentHand.Value and tostring(currentHand.Value) or "", Type = handType, amount = currentHand and currentHand:GetAttribute("Amount") and type(currentHand:GetAttribute("Amount")) == "number" or 0}
		store.localHand.toolType = store.localHand.Type
		store.hand = store.localHand
	end,
	executeStoreTable = function()
		if not shared.StoreTable then return end
		for i,v in pairs(shared.StoreTable) do
			if type(v) == "function" then task.spawn(function() pcall(function() v() end) end) end
		end
	end,
	updateQueueType = function()
		local att = game:GetService("Workspace"):GetAttribute("QueueType")
		if not att then return end
		store.queueType = att
	end
}
VoidwareFunctions.GlobaliseObject("StoreTable", {})

function bedwars.StoreController:updateStore()
	task.spawn(function() pcall(function() self:updateLocalHand() end) end)
	task.wait(0.1)
	task.spawn(function() pcall(function() self:updateLocalInventory() end) end)
	task.wait(0.1)
	task.spawn(function() pcall(function() self:updateEquippedKit() end) end)
	task.wait(0.1)
	task.spawn(function() pcall(function() self:updateMatchState() end) end)
	task.wait(0.1)
	task.spawn(function() pcall(function() self:updateStoreBlocks() end) end)
	task.wait(0.1)
	if store.equippedKit == "wind_walker" then
		task.wait(0.1)
		task.spawn(function() pcall(function() self:updateZephyrOrb() end) end)
	end
	if store.queueType == "bedwars_test" then
		task.spawn(function() pcall(function() self:updateQueueType() end) end)
	end
end

pcall(bedwars.StoreController.updateStore, bedwars.StoreController)

for i, v in pairs({"MatchEndEvent", "EntityDeathEvent", "BedwarsBedBreak", "BalloonPopped", "AngelProgress"}) do
	bedwars.Client:WaitFor(v):andThen(function(connection)
		table.insert(vapeConnections, connection:Connect(function(...)
			vapeEvents[v]:Fire(...)
		end))
	end)
end
for i, v in pairs({"PlaceBlockEvent", "BreakBlockEvent"}) do
	bedwars.ClientDamageBlock:WaitFor(v):andThen(function(connection)
		table.insert(vapeConnections, connection:Connect(function(...)
			vapeEvents[v]:Fire(...)
		end))
	end)
end
VoidwareFunctions.GlobaliseObject("vapeEvents", vapeEvents)
table.insert(shared.StoreTable, function()
	VoidwareFunctions.GlobaliseObject("vapeEvents", vapeEvents)
end)

store.blocks = collectionService:GetTagged("block")
store.blockRaycast.FilterDescendantsInstances = {store.blocks}
store.blockRaycast.FilterType = Enum.RaycastFilterType.Include
table.insert(vapeConnections, collectionService:GetInstanceAddedSignal("block"):Connect(function(block)
	table.insert(store.blocks, block)
	store.blockRaycast.FilterDescendantsInstances = {store.blocks}
end))
table.insert(vapeConnections, collectionService:GetInstanceRemovedSignal("block"):Connect(function(block)
	local index = table.find(store.blocks, block)
	if index then
		table.remove(store.blocks, index)
		store.blockRaycast.FilterDescendantsInstances = {store.blocks}
	end
end))
local AutoLeave = {Enabled = false}

run(function()
	local Players = game:GetService("Players")
	local playersService = Players
	function getColor3FromDecimal(decimal)
		if not decimal then return false end
		local r = math.floor(decimal / (256 * 256)) % 256
		local g = math.floor(decimal / 256) % 256
		local b = decimal % 256
		
		return Color3.new(r / 255, g / 255, b / 255)
	end
	if shared.CORE_CUSTOM_CONNECTIONS and type(shared.CORE_CUSTOM_CONNECTIONS) == "table" then
		for i,v in pairs(shared.CORE_CUSTOM_CONNECTIONS) do
			pcall(function()
				v:Disconnect()
			end)
		end
		table.clear(shared.CORE_CUSTOM_CONNECTIONS)
	end
	shared.CORE_CUSTOM_CONNECTIONS = {}
	shared.CORE_CUSTOM_CONNECTIONS.EntityDeathEvent = vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
        local killer = playersService:GetPlayerFromCharacter(deathTable.fromEntity)
        local killed = playersService:GetPlayerFromCharacter(deathTable.entityInstance)
        if not killed or not killer then return end
		shared.custom_notify("kill", killer, killed, deathTable.finalKill)
    end)
	shared.CORE_CUSTOM_CONNECTIONS.BedwarsBedBreak = vapeEvents.BedwarsBedBreak.Event:Connect(function(bedTable)
		if not (bedTable ~= nil and type(bedTable) == "table" and bedTable.brokenBedTeam ~= nil and type(bedTable.brokenBedTeam) == "table" and bedTable.brokenBedTeam.id ~= nil) then return end
		local team = bedwars.QueueMeta[store.queueType].teams[tonumber(bedTable.brokenBedTeam.id)]
		local destroyer = Players:GetPlayerByUserId(tonumber(bedTable.player.UserId)) or {Name = "Unknown player"}
		if not destroyer then destroyer = "Unknown player" end
		shared.custom_notify("bedbreak", destroyer, nil, nil, {
			Name = team and team.displayName:upper() or 'WHITE',
			Color = team and team.colorHex and getColor3FromDecimal(tonumber(team.colorHex)) or Color3.fromRGB(255, 255, 255)
		})
	end)
	shared.CORE_CUSTOM_CONNECTIONS.MatchEndEvent = vapeEvents.MatchEndEvent.Event:Connect(function(winTable)
		local team = bedwars.QueueMeta[store.queueType].teams[tonumber(winTable.winningTeamId)]
		if winTable.winningTeamId == lplr:GetAttribute('Team') then
			shared.custom_notify("win", nil, nil, false, {
				Name = team and team.displayName:upper() or 'WHITE',
				Color = team and team.colorHex and getColor3FromDecimal(tonumber(team.colorHex)) or Color3.fromRGB(255, 255, 255)
			})
		else
			shared.custom_notify("defeat", nil, nil, false, {
				Name = team and team.displayName:upper() or 'WHITE',
				Color = team and team.colorHex and getColor3FromDecimal(tonumber(team.colorHex)) or Color3.fromRGB(255, 255, 255)
			})
		end
    end)
end)

task.spawn(function()
	repeat
		task.wait(1)
		pcall(bedwars.StoreController.updateStore, bedwars.StoreController)
	until (not shared.vape)
end)

table.insert(vapeConnections, game.Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	gameCamera = game.Workspace.CurrentCamera or game.Workspace:FindFirstChildWhichIsA("gameCamera")
end))
local isfile = isfile or function(file)
	local suc, res = pcall(function() return readfile(file) end)
	return suc and res ~= nil
end
local networkownerswitch = tick()
local isnetworkowner = function(part)
	local suc, res = pcall(function() return gethiddenproperty(part, "NetworkOwnershipRule") end)
	if suc and res == Enum.NetworkOwnership.Manual then
		networkownerswitch = tick() + 8
	end
	return networkownerswitch <= tick()
end
VoidwareFunctions.GlobaliseObject("isnetworkowner", isnetworkowner)
local getcustomasset = getsynasset or getcustomasset or function(location) return "rbxasset://"..location end
local queueonteleport = syn and syn.queue_on_teleport or queue_on_teleport or function() end
local synapsev3 = syn and syn.toast_notification and "V3" or ""
local worldtoscreenpoint = function(pos)
	if synapsev3 == "V3" then
		local scr = worldtoscreen({pos})
		return scr[1] - Vector3.new(0, 36, 0), scr[1].Z > 0
	end
	return gameCamera.WorldToScreenPoint(gameCamera, pos)
end
local worldtoviewportpoint = function(pos)
	if synapsev3 == "V3" then
		local scr = worldtoscreen({pos})
		return scr[1], scr[1].Z > 0
	end
	return gameCamera.WorldToViewportPoint(gameCamera, pos)
end

local function vapeGithubRequest(scripturl)
	if not isfile("vape/"..scripturl) then
		local suc, res = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/vapevoidware/"..readfile("vape/commithash.txt").."/"..scripturl, true) end)
		assert(suc, res)
		assert(res ~= "404: Not Found", res)
		if scripturl:find(".lua") then res = "--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.\n"..res end
		writefile("vape/"..scripturl, res)
	end
	return readfile("vape/"..scripturl)
end

local function downloadVapeAsset(path)
	if not isfile(path) then
		task.spawn(function()
			local textlabel = Instance.new("TextLabel")
			textlabel.Size = UDim2.new(1, 0, 0, 36)
			textlabel.Text = "Downloading "..path
			textlabel.BackgroundTransparency = 1
			textlabel.TextStrokeTransparency = 0
			textlabel.TextSize = 30
			textlabel.Font = Enum.Font.SourceSans
			textlabel.TextColor3 = Color3.new(1, 1, 1)
			textlabel.Position = UDim2.new(0, 0, 0, -36)
			textlabel.Parent = vape.gui
			task.wait(0.1)
			textlabel:Destroy()
		end)
		local suc, req = pcall(function() return vapeGithubRequest(path:gsub("vape/assets", "assets")) end)
		if suc and req then
			writefile(path, req)
		else
			return ""
		end
	end
	if not vapeCachedAssets[path] then vapeCachedAssets[path] = getcustomasset(path) end
	return vapeCachedAssets[path]
end

local function run(func)
	local suc, err = pcall(function()
		func()
	end)
	if err then warn("[CE687224481.lua Module Error]: "..tostring(debug.traceback(err))) end
end

local function isTarget(plr) return false end
local function isFriend(plr, recolor) return false end
local function attackValue(vec) return {value = vec} end
local function getPlayerColor(plr) return tostring(plr.TeamColor) ~= "White" and plr.TeamColor.Color end
local function isVulnerable(plr) return plr.Humanoid.Health > 0 and not plr.Character.FindFirstChildWhichIsA(plr.Character, "ForceField") end
VoidwareFunctions.GlobaliseObject("isVulnarable", isVulnarable)

local function LaunchAngle(v, g, d, h, higherArc)
	local v2 = v * v
	local v4 = v2 * v2
	local root = -math.sqrt(v4 - g*(g*d*d + 2*h*v2))
	return math.atan((v2 + root) / (g * d))
end

local function LaunchDirection(start, target, v, g)
	local horizontal = Vector3.new(target.X - start.X, 0, target.Z - start.Z)
	local h = target.Y - start.Y
	local d = horizontal.Magnitude
	local a = LaunchAngle(v, g, d, h)

	if a ~= a then
		return g == 0 and (target - start).Unit * v
	end

	local vec = horizontal.Unit * v
	local rotAxis = Vector3.new(-horizontal.Z, 0, horizontal.X)
	return CFrame.fromAxisAngle(rotAxis, a) * vec
end

local physicsUpdate = 1 / 60

local function predictGravity(playerPosition, vel, bulletTime, targetPart, Gravity)
	local estimatedVelocity = vel.Y
	local rootSize = (targetPart.Humanoid.HipHeight + (targetPart.RootPart.Size.Y / 2))
	local velocityCheck = (tick() - targetPart.JumpTick) < 0.2
	vel = vel * physicsUpdate

	for i = 1, math.ceil(bulletTime / physicsUpdate) do
		if velocityCheck then
			estimatedVelocity = estimatedVelocity - (Gravity * physicsUpdate)
		else
			estimatedVelocity = 0
			playerPosition = playerPosition + Vector3.new(0, -0.03, 0)
			rootSize = rootSize - 0.03
		end

		local floorDetection = game.Workspace:Raycast(playerPosition, Vector3.new(vel.X, (estimatedVelocity * physicsUpdate) - rootSize, vel.Z), store.blockRaycast)
		if floorDetection then
			playerPosition = Vector3.new(playerPosition.X, floorDetection.Position.Y + rootSize, playerPosition.Z)
			local bouncepad = floorDetection.Instance:FindFirstAncestor("gumdrop_bounce_pad")
			if bouncepad and bouncepad:GetAttribute("PlacedByUserId") == targetPart.Player.UserId then
				estimatedVelocity = 130 - (Gravity * physicsUpdate)
				velocityCheck = true
			else
				estimatedVelocity = targetPart.Humanoid.JumpPower - (Gravity * physicsUpdate)
				velocityCheck = targetPart.Jumping
			end
		end

		playerPosition = playerPosition + Vector3.new(vel.X, velocityCheck and estimatedVelocity * physicsUpdate or 0, vel.Z)
	end

	return playerPosition, Vector3.new(0, 0, 0)
end

local whitelist = shared.vapewhitelist
local RunLoops = shared.RunLoops

vape:Clean(function()
	vapeInjected = false
	for i, v in pairs(vapeConnections) do
		if v.Disconnect then pcall(function() v:Disconnect() end) continue end
		if v.disconnect then pcall(function() v:disconnect() end) continue end
	end
end)

local cache = {}
local function getItemNear(itemName, inv)
    inv = inv or store.localInventory.inventory.items
    if cache[itemName] then
        local cachedItem, cachedSlot = cache[itemName].item, cache[itemName].slot
        if inv[cachedSlot] and inv[cachedSlot].itemType == cachedItem.itemType then
            return cachedItem, cachedSlot
        else
            cache[itemName] = nil
        end
    end
    for slot, item in pairs(inv) do
        if item.itemType == itemName or item.itemType:find(itemName) then
            cache[itemName] = { item = item, slot = slot }
            return item, slot
        end
    end
    return nil
end
VoidwareFunctions.GlobaliseObject("getItemNear", getItemNear)

local function getHotbarSlot(itemName)
	for slotNumber, slotTable in pairs(store.localInventory.hotbar) do
		if slotTable.item and slotTable.item.itemType == itemName then
			return slotNumber - 1
		end
	end
	return nil
end
VoidwareFunctions.GlobaliseObject("getHotbarSlot", getHotbarSlot)

local function getNearbyObjects(origin, distance)
    assert(typeof(origin) == "Vector3", "Origin must be a Vector3")
    assert(typeof(distance) == "number" and distance > 0, "Distance must be a positive number")
    local minBound = origin - Vector3.new(distance, distance, distance)
    local maxBound = origin + Vector3.new(distance, distance, distance)
    local region = Region3.new(minBound, maxBound)
    local workspaceObjects = game.Workspace:FindPartsInRegion3WithIgnoreList(region, {}, math.huge)
    local nearbyObjects = {}
    for _, part in pairs(workspaceObjects) do
        if (part.Position - origin).Magnitude <= distance then
            table.insert(nearbyObjects, part)
        end
    end
    return nearbyObjects
end
VoidwareFunctions.GlobaliseObject("getNearyObjects", getNearbyObjects)

local function getShieldAttribute(char)
	local returnedShield = 0
	for attributeName, attributeValue in pairs(char:GetAttributes()) do
		if attributeName:find("Shield") and type(attributeValue) == "number" then
			returnedShield = returnedShield + attributeValue
		end
	end
	return returnedShield
end
VoidwareFunctions.GlobaliseObject("getShieldAttribute", getShieldAttribute)

getPickaxe = function()
	return getItemNear("pick")
end

local function getAxe()
	local bestAxe, bestAxeSlot = nil, nil
	for slot, item in pairs(store.localInventory.inventory.items) do
		if item.itemType:find("axe") and item.itemType:find("pickaxe") == nil and item.itemType:find("void") == nil then
			bextAxe, bextAxeSlot = item, slot
		end
	end
	return bestAxe, bestAxeSlot
end

local function getClaw()
	for slot, item in store.localInventory.inventory.items do
		if item.itemType and string.find(string.lower(tostring(item.itemType)), "summoner_claw") then
			return item, slot, 12
		end
	end
end

local function getSword()
	local bestSword, bestSwordSlot, bestSwordDamage = nil, nil, 0
	for slot, item in pairs(store.localInventory.inventory.items) do
		if store.equippedKit == "summoner" then
			return getClaw()
		end
		local swordMeta = bedwars.ItemTable[item.itemType].sword
		if swordMeta then
			local swordDamage = swordMeta.baseDamage or 0
			if not bestSword or swordDamage > bestSwordDamage then
				bestSword, bestSwordSlot, bestSwordDamage = item, slot, swordDamage
			end
		end
	end
	return bestSword, bestSwordSlot
end
VoidwareFunctions.GlobaliseObject("getSword", getSword)

local function getBow()
	local bestBow, bestBowSlot, bestBowStrength = nil, nil, 0
	for slot, item in pairs(store.localInventory.inventory.items) do
		if item.itemType:find("bow") then
			local tab = bedwars.ItemTable[item.itemType].projectileSource
			local ammo = tab.projectileType("arrow")
			local dmg = bedwars.ProjectileMeta[ammo].combat.damage
			if dmg > bestBowStrength then
				bestBow, bestBowSlot, bestBowStrength = item, slot, dmg
			end
		end
	end
	return bestBow, bestBowSlot
end

local function getWool()
	local wool = getItemNear("wool")
	return wool and wool.itemType, wool and wool.amount
end

local function getBlock()
	for slot, item in pairs(store.localInventory.inventory.items) do
		if bedwars.ItemTable[item.itemType].block then
			return item.itemType, item.amount
		end
	end
end

local isZephyr = false
local oldhealth
local lastdamagetick = tick()
task.spawn(function()
	repeat task.wait() until entityLibrary.isAlive
	oldhealth = lplr.Character.Humanoid.Health
	lplr.Character.Humanoid.HealthChanged:Connect(function(new)
		repeat task.wait() until entityLibrary.isAlive
		if new < oldhealth then
			lastdamagetick = tick() + 0.25
		end
		oldhealth = new
	end)
end)
lplr.CharacterAdded:Connect(function()
	pcall(function()
		repeat task.wait() until entityLibrary.isAlive
		local oldhealth = lplr.Character.Humanoid.Health
		repeat task.wait() until lplr.Character.Humanoid
		lplr.Character.Humanoid.HealthChanged:Connect(function(new)
			if new < oldhealth then
				lastdamagetick = tick() + 0.25
			end
			oldhealth = new
		end)
	end)
end)
shared.zephyrActive = false
shared.scytheActive = false
shared.SpeedBoostEnabled = false
shared.scytheSpeed = 5
local function getSpeed(reduce)
	local speed = 0
	if lplr.Character then
		local SpeedDamageBoost = lplr.Character:GetAttribute("SpeedBoost")
		if SpeedDamageBoost and SpeedDamageBoost > 1 then
			speed = speed + (8 * (SpeedDamageBoost - 1))
		end
		if store.grapple > tick() then
			speed = speed + 90
		end
		if store.scythe > tick() and shared.scytheActive then
			speed = speed + shared.scytheSpeed
		end
		if lplr.Character:GetAttribute("GrimReaperChannel") then
			speed = speed + 20
		end
		if lastdamagetick > tick() and shared.SpeedBoostEnabled then
			speed = speed + 10
		end;
		local armor = store.localInventory.inventory.armor[3]
		if type(armor) ~= "table" then armor = {itemType = ""} end
		if armor.itemType == "speed_boots" then
			speed = speed + 12
		end
		if store.zephyrOrb ~= 0 then
			speed = speed + 12
		end
		if store.zephyrOrb ~= 0 and shared.zephyrActive then
			isZephyr = true
		else
			isZephyr = false
		end
	end
	return reduce and speed ~= 1 and math.max(speed * (0.8 - (0.3 * math.floor(speed))), 1) or speed
end
VoidwareFunctions.GlobaliseObject("getSpeed", getSpeed)

local Reach = {Enabled = false}
local blacklistedblocks = {bed = true, ceramic = true}
local oldpos = Vector3.zero

local function getScaffold(vec, diagonaltoggle)
	local realvec = Vector3.new(math.floor((vec.X / 3) + 0.5) * 3, math.floor((vec.Y / 3) + 0.5) * 3, math.floor((vec.Z / 3) + 0.5) * 3)
	local speedCFrame = (oldpos - realvec)
	local returedpos = realvec
	if entityLibrary.isAlive then
		local angle = math.deg(math.atan2(-entityLibrary.character.Humanoid.MoveDirection.X, -entityLibrary.character.Humanoid.MoveDirection.Z))
		local goingdiagonal = (angle >= 130 and angle <= 150) or (angle <= -35 and angle >= -50) or (angle >= 35 and angle <= 50) or (angle <= -130 and angle >= -150)
		if goingdiagonal and ((speedCFrame.X == 0 and speedCFrame.Z ~= 0) or (speedCFrame.X ~= 0 and speedCFrame.Z == 0)) and diagonaltoggle then
			return oldpos
		end
	end
	return realvec
end
VoidwareFunctions.GlobaliseObject("getScaffold", getScaffold)

local function waitForChildOfType(obj, name, timeout, prop)
	local check, returned = tick() + timeout
	repeat
		returned = prop and obj[name] or obj:FindFirstChildOfClass(name)
		if returned or check < tick() then
			break
		end
		task.wait()
	until false
	return returned
end

local function getBestTool(block)
	local tool = nil
	local blockmeta = bedwars.ItemTable[block]
	local blockType = blockmeta.block and blockmeta.block.breakType
	if blockType then
		local best = 0
		for i,v in pairs(store.localInventory.inventory.items) do
			local meta = bedwars.ItemTable[v.itemType]
			if meta.breakBlock and meta.breakBlock[blockType] and meta.breakBlock[blockType] >= best then
				best = meta.breakBlock[blockType]
				tool = v
			end
		end
	end
	return tool
end
VoidwareFunctions.GlobaliseObject("getBestTool", getBestTool)

local function GetPlacedBlocksNear(pos, normal)
	local blocks = {}
	local lastfound = nil
	for i = 1, 20 do
		local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
		local extrablock = getPlacedBlock(blockpos)
		local covered = isBlockCovered(blockpos)
		if extrablock then
			if bedwars.BlockController:isBlockBreakable({blockPosition = blockpos}, lplr) and (not blacklistedblocks[extrablock.Name]) then
				table.insert(blocks, extrablock.Name)
			end
			lastfound = extrablock
			if not covered then
				break
			end
		else
			break
		end
	end
	return blocks
end

local function getBestBreakSide(pos)
	local softest, softestside = 9e9, Enum.NormalId.Top
	for i,v in pairs(cachedNormalSides) do
		local sidehardness = 0
		for i2,v2 in pairs(GetPlacedBlocksNear(pos, v)) do
			if bedwars.ItemTable[v2] then
				local blockmeta = bedwars.ItemTable[v2].block
				sidehardness = sidehardness + (blockmeta and blockmeta.health or 10)
				if blockmeta then
					local tool = getBestTool(v2)
					if tool then
						sidehardness = sidehardness - bedwars.ItemTable[tool.itemType].breakBlock[blockmeta.breakType]
					end
				end
			end
		end
		if sidehardness <= softest then
			softest = sidehardness
			softestside = v
		end
	end
	return softestside, softest
end

local function EntityNearPosition(distance, ignore, overridepos)
	local closestEntity, closestMagnitude = nil, distance
	if entityLibrary.isAlive then
		for i, v in pairs(entityLibrary.List) do
			if not v.Targetable then continue end
			local mag = (entityLibrary.character.HumanoidRootPart.Position - v.RootPart.Position).magnitude
			if overridepos and mag > distance then
				mag = (overridepos - v.RootPart.Position).magnitude
			end
			if mag <= closestMagnitude then
				closestEntity, closestMagnitude = v, mag
			end
		end
		if not ignore then
			for i, v in pairs(collectionService:GetTagged("trainingRoomDummy")) do
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
					if mag <= closestMagnitude then
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
					if mag <= closestMagnitude then
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
					if mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = "Pot", UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
		end
	end
	return closestEntity
end
VoidwareFunctions.GlobaliseObject("EntityNearPosition", EntityNearPosition)

local function EntityNearMouse(distance)
	local closestEntity, closestMagnitude = nil, distance
	if entityLibrary.isAlive then
		local mousepos = inputService.GetMouseLocation(inputService)
		for i, v in pairs(entityLibrary.entityList) do
			if not v.Targetable then continue end
			if isVulnerable(v) then
				local vec, vis = worldtoscreenpoint(v.RootPart.Position)
				local mag = (mousepos - Vector2.new(vec.X, vec.Y)).magnitude
				if vis and mag <= closestMagnitude then
					closestEntity, closestMagnitude = v, v.Target and -1 or mag
				end
			end
		end
	end
	return closestEntity
end
VoidwareFunctions.GlobaliseObject("EntityNearMouse", EntityNearMouse)

local function AllNearPosition(distance, amount, sortfunction, prediction, npcIncluded)
	local returnedplayer = {}
	local currentamount = 0
	if entityLibrary.isAlive then
		local sortedentities = {}
		if npcIncluded then
			for _, npc in pairs(game.Workspace:GetChildren()) do
				if npc.Name == "Void Enemy Dummy" or npc.Name == "Emerald Enemy Dummy" or npc.Name == "Diamond Enemy Dummy" or npc.Name == "Leather Enemy Dummy" or npc.Name == "Regular Enemy Dummy" or npc.Name == "Iron Enemy Dummy" then
					if npc:FindFirstChild("HumanoidRootPart") then
						local distance2 = (npc.HumanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).Magnitude
						if distance2 < distance then
							table.insert(sortedentities, npc)
						end
					end
				end
			end
		end
		for i, v in pairs(entityLibrary.entityList) do
			if not v.Targetable then continue end
			if isVulnerable(v) then
				local playerPosition = v.RootPart.Position
				local mag = (entityLibrary.character.HumanoidRootPart.Position - playerPosition).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - playerPosition).magnitude
				end
				if mag <= distance then
					table.insert(sortedentities, v)
				end
			end
		end
		for i, v in pairs(collectionService:GetTagged("Monster")) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
				if mag <= distance then
					if v:GetAttribute("Team") == lplr:GetAttribute("Team") then end
					table.insert(sortedentities, {Player = {Name = v.Name, UserId = (v.Name == "Duck" and 2020831224 or 1443379645), GetAttribute = function() return "none" end}, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
				end
			end
		end
		for i, v in pairs(collectionService:GetTagged("GuardianOfDream")) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
				if mag <= distance then
					if v:GetAttribute("Team") == lplr:GetAttribute("Team") then end
					table.insert(sortedentities, {Player = {Name = v.Name, UserId = (v.Name == "Duck" and 2020831224 or 1443379645), GetAttribute = function() return "none" end}, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
				end
			end
		end
		for i, v in pairs(collectionService:GetTagged("DiamondGuardian")) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
				if mag <= distance then
					table.insert(sortedentities, {Player = {Name = "DiamondGuardian", UserId = 1443379645, GetAttribute = function() return "none" end}, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
				end
			end
		end
		for i, v in pairs(collectionService:GetTagged("GolemBoss")) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
				if mag <= distance then
					table.insert(sortedentities, {Player = {Name = "GolemBoss", UserId = 1443379645, GetAttribute = function() return "none" end}, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
				end
			end
		end
		for i, v in pairs(collectionService:GetTagged("Drone")) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
				if mag <= distance then
					if tonumber(v:GetAttribute("PlayerUserId")) == lplr.UserId then end
					local droneplr = playersService:GetPlayerByUserId(v:GetAttribute("PlayerUserId"))
					if droneplr and droneplr.Team == lplr.Team then end
					table.insert(sortedentities, {Player = {Name = "Drone", UserId = 1443379645}, GetAttribute = function() return "none" end, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
				end
			end
		end
		for i,v in pairs(game.Workspace:GetChildren()) do
			if v.Name == "InfectedCrateEntity" and v.ClassName == "Model" and v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
				if mag <= distance then
					table.insert(sortedentities, {Player = {Name = "InfectedCrateEntity", UserId = 1443379645, GetAttribute = function() return "none" end}, Character = v, RootPart = v.PrimaryPart, Humanoid = {Health = 100, MaxHealth = 100}})
				end
			end
		end
		for i, v in pairs(store.pots) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
				if mag <= distance then
					table.insert(sortedentities, {Player = {Name = "Pot", UserId = 1443379645, GetAttribute = function() return "none" end}, Character = v, RootPart = v.PrimaryPart, Humanoid = {Health = 100, MaxHealth = 100}})
				end
			end
		end
		if sortfunction then
			table.sort(sortedentities, sortfunction)
		end
		for i,v in pairs(sortedentities) do
			table.insert(returnedplayer, v)
			currentamount = currentamount + 1
			if currentamount >= amount then break end
		end
	end
	return returnedplayer
end
VoidwareFunctions.GlobaliseObject("AllNearPosition", AllNearPosition)

local function isWhitelistedBed(bed)
    if bed and bed.Name == 'bed' then
        for i, v in pairs(playersService:GetPlayers()) do
            if bed:GetAttribute("Team"..(v:GetAttribute("Team") or 0).."NoBreak") and not ({whitelist:get(v)})[2] then
                return true
            end
        end
    end
    return false
end

run(function()
	local oldstart = entitylib.start
	local function customEntity(ent)
		if ent:HasTag('inventory-entity') and not ent:HasTag('Monster') then
			return
		end

		entitylib.addEntity(ent, nil, ent:HasTag('Drone') and function(self)
			local droneplr = playersService:GetPlayerByUserId(self.Character:GetAttribute('PlayerUserId'))
			return not droneplr or lplr:GetAttribute('Team') ~= droneplr:GetAttribute('Team')
		end or function(self)
			return lplr:GetAttribute('Team') ~= self.Character:GetAttribute('Team')
		end)
	end

	task.spawn(function()
		repeat
			task.wait()
			if entitylib.isAlive then
				entitylib.groundTick = entitylib.character.Humanoid.FloorMaterial ~= Enum.Material.Air and tick() or entitylib.groundTick
			end
		until not shared.vape
	end)

	entitylib.start = function()
		oldstart()
		if entitylib.Running then
			for _, ent in collectionService:GetTagged('entity') do
				customEntity(ent)
			end
			table.insert(entitylib.Connections, collectionService:GetInstanceAddedSignal('entity'):Connect(customEntity))
			table.insert(entitylib.Connections, collectionService:GetInstanceRemovedSignal('entity'):Connect(function(ent)
				entitylib.removeEntity(ent)
			end))
		end
	end

	entitylib.addPlayer = function(plr)
		if plr.Character then
			entitylib.refreshEntity(plr.Character, plr)
		end
		entitylib.PlayerConnections[plr] = {
			plr.CharacterAdded:Connect(function(char)
				entitylib.refreshEntity(char, plr)
			end),
			plr.CharacterRemoving:Connect(function(char)
				entitylib.removeEntity(char, plr == lplr)
			end),
			plr:GetAttributeChangedSignal('Team'):Connect(function()
				for _, v in entitylib.List do
					if v.Targetable ~= entitylib.targetCheck(v) then
						entitylib.refreshEntity(v.Character, v.Player)
					end
				end

				if plr == lplr then
					entitylib.start()
				else
					entitylib.refreshEntity(plr.Character, plr)
				end
			end)
		}
	end

	entitylib.addEntity = function(char, plr, teamfunc)
		if not char then return end
		entitylib.EntityThreads[char] = task.spawn(function()
			local hum, humrootpart, head
			if plr then
				hum = waitForChildOfType(char, 'Humanoid', 10)
				humrootpart = hum and waitForChildOfType(hum, 'RootPart', game.Workspace.StreamingEnabled and 9e9 or 10, true)
				head = char:WaitForChild('Head', 10) or humrootpart
			else
				hum = {HipHeight = 0.5}
				humrootpart = waitForChildOfType(char, 'PrimaryPart', 10, true)
				head = humrootpart
			end
			local updateobjects = plr and plr ~= lplr and {
				char:WaitForChild('ArmorInvItem_0', 5),
				char:WaitForChild('ArmorInvItem_1', 5),
				char:WaitForChild('ArmorInvItem_2', 5),
				char:WaitForChild('HandInvItem', 5)
			} or {}

			if hum and humrootpart then
				local entity = {
					Connections = {},
					Character = char,
					Health = (char:GetAttribute('Health') or 100) + getShieldAttribute(char),
					Head = head,
					Humanoid = hum,
					HumanoidRootPart = humrootpart,
					HipHeight = hum.HipHeight + (humrootpart.Size.Y / 2) + (hum.RigType == Enum.HumanoidRigType.R6 and 2 or 0),
					Jumps = 0,
					JumpTick = tick(),
					Jumping = false,
					LandTick = tick(),
					MaxHealth = char:GetAttribute('MaxHealth') or 100,
					NPC = plr == nil,
					Player = plr,
					RootPart = humrootpart,
					TeamCheck = teamfunc
				}

				if plr == lplr then
					entity.AirTime = tick()
					entitylib.character = entity
					entitylib.isAlive = true
					entitylib.Events.LocalAdded:Fire(entity)
					table.insert(entitylib.Connections, char.AttributeChanged:Connect(function(attr)
						vapeEvents.AttributeChanged:Fire(attr)
					end))
				else
					entity.Targetable = entitylib.targetCheck(entity)

					for _, v in entitylib.getUpdateConnections(entity) do
						table.insert(entity.Connections, v:Connect(function()
							entity.Health = (char:GetAttribute('Health') or 100) + getShieldAttribute(char)
							entity.MaxHealth = char:GetAttribute('MaxHealth') or 100
							entitylib.Events.EntityUpdated:Fire(entity)
						end))
					end

					for _, v in updateobjects do
						table.insert(entity.Connections, v:GetPropertyChangedSignal('Value'):Connect(function()
							task.delay(0.1, function()
								if bedwars.getInventory then
									store.inventories[plr] = bedwars.getInventory(plr)
									entitylib.Events.EntityUpdated:Fire(entity)
								end
							end)
						end))
					end

					if plr then
						local anim = char:FindFirstChild('Animate')
						if anim then
							pcall(function()
								anim = anim.jump:FindFirstChildWhichIsA('Animation').AnimationId
								table.insert(entity.Connections, hum.Animator.AnimationPlayed:Connect(function(playedanim)
									if playedanim.Animation.AnimationId == anim then
										entity.JumpTick = tick()
										entity.Jumps += 1
										entity.LandTick = tick() + 1
										entity.Jumping = entity.Jumps > 1
									end
								end))
							end)
						end

						task.delay(0.1, function()
							if bedwars.getInventory then
								store.inventories[plr] = bedwars.getInventory(plr)
							end
						end)
					end
					table.insert(entitylib.List, entity)
					entitylib.Events.EntityAdded:Fire(entity)
				end

				table.insert(entity.Connections, char.ChildRemoved:Connect(function(part)
					if part == humrootpart or part == hum or part == head then
						if part == humrootpart and hum.RootPart then
							humrootpart = hum.RootPart
							entity.RootPart = hum.RootPart
							entity.HumanoidRootPart = hum.RootPart
							return
						end
						entitylib.removeEntity(char, plr == lplr)
					end
				end))
			end
			entitylib.EntityThreads[char] = nil
		end)
	end

	entitylib.getUpdateConnections = function(ent)
		local char = ent.Character
		local tab = {
			char:GetAttributeChangedSignal('Health'),
			char:GetAttributeChangedSignal('MaxHealth'),
			{
				Connect = function()
					ent.Friend = ent.Player and isFriend(ent.Player) or nil
					ent.Target = ent.Player and isTarget(ent.Player) or nil
					return {Disconnect = function() end}
				end
			}
		}

		for name, val in char:GetAttributes() do
			if name:find('Shield') and type(val) == 'number' then
				table.insert(tab, char:GetAttributeChangedSignal(name))
			end
		end

		return tab
	end

	entitylib.targetCheck = function(ent)
		if ent.TeamCheck then
			return ent:TeamCheck()
		end
		if ent.NPC then return true end
		if isFriend(ent.Player) then return false end
		if not select(2, whitelist:get(ent.Player)) then return false end
		return lplr:GetAttribute('Team') ~= ent.Player:GetAttribute('Team')
	end
	vape:Clean(entitylib.Events.LocalAdded:Connect(updateVelocity))
end)
entitylib.start()

run(function()
	local checked = {}
	local function check(v)
		if table.find(checked, v) then return end
		local npcNames = {"Void Enemy Dummy", "Emerald Enemy Dummy", "Diamond Enemy Dummy", "Leather Enemy Dummy", "Regular Enemy Dummy", "Iron Enemy Dummy"}
		local function isNPC(name)
			for i,v in pairs(npcNames) do
				if string.find(string.lower(name), string.lower(v)) then return true end
			end
			return false
		end
		if isNPC(v.Name) then
			if not v.PrimaryPart then task.wait(1) end
			if not v:FindFirstChild("HumanoidRootPart") then task.wait(1) end
			if v.PrimaryPart then
				v.Name = v.Name.." | "..tostring(#checked)
				entitylib.addEntity(v, nil, function() return true end)
				table.insert(checked, v)
			end
		end
	end
	for i, v in pairs(collectionService:GetTagged("trainingRoomDummy")) do
		check(v)
	end
	local con
	local con2
	con = collectionService:GetInstanceAddedSignal("trainingRoomDummy"):Connect(function(v)
		if not shared.vape then pcall(function()
			con:Disconnect()
			table.clear(checked)
		end) end
		check(v)
	end)
	con2 = collectionService:GetInstanceRemovedSignal("trainingRoomDummy"):Connect(function(v)
		if not shared.vape then pcall(function()
			con2:Disconnect()
			table.clear(checked)
		end) end
		if table.find(checked, v) then
			entitylib.removeEntity(v)
		end
	end)
end)

pcall(function()
    local options = {
        "SilentAimOptionsButton",
        "ReachOptionsButton",
        "MouseTPOptionsButton",
        "PhaseOptionsButton",
        "AutoClickerOptionsButton",
        "SpiderOptionsButton",
        "LongJumpOptionsButton",
        "HitBoxesOptionsButton",
        "KillauraOptionsButton",
        "TriggerBotOptionsButton",
        "AutoLeaveOptionsButton",
        "SpeedOptionsButton",
        "FlyOptionsButton",
        "ClientKickDisablerOptionsButton",
        "NameTagsOptionsButton",
        "SafeWalkOptionsButton",
        "BlinkOptionsButton",
        "FOVChangerOptionsButton",
        "AntiVoidOptionsButton",
        "SongBeatsOptionsButton"
    }

    for _, option in ipairs(options) do
        task.spawn(function()
            pcall(function()
                GuiLibrary.RemoveObject(option)
            end)
        end)
    end
end)

local sortmethods = {
	Damage = function(a, b) return a.Entity.Character:GetAttribute('LastDamageTakenTime') < b.Entity.Character:GetAttribute('LastDamageTakenTime') end,
	Threat = function(a, b) return getStrength(a.Entity) > getStrength(b.Entity) end,
	Kit = function(a, b) return (a.Entity.Player and kitorder[a.Entity.Player:GetAttribute('PlayingAsKit')] or 0) > (b.Entity.Player and kitorder[b.Entity.Player:GetAttribute('PlayingAsKit')] or 0) end,
	Health = function(a, b) return a.Entity.Health < b.Entity.Health end,
	Angle = function(a, b)
		local selfrootpos = entitylib.character.RootPart.Position
		local localfacing = entitylib.character.RootPart.CFrame.LookVector * Vector3.new(1, 0, 1)
		local angle = math.acos(localfacing:Dot(((a.Entity.RootPart.Position - selfrootpos) * Vector3.new(1, 0, 1)).Unit))
		local angle2 = math.acos(localfacing:Dot(((b.Entity.RootPart.Position - selfrootpos) * Vector3.new(1, 0, 1)).Unit))
		return angle < angle2
	end
}

local function Wallcheck(attackerCharacter, targetCharacter, additionalIgnore)
    if not (attackerCharacter and targetCharacter) then
        return false
    end

    local humanoidRootPart = attackerCharacter.PrimaryPart
    local targetRootPart = targetCharacter.PrimaryPart
    if not (humanoidRootPart and targetRootPart) then
        return false
    end

    local origin = humanoidRootPart.Position
    local targetPosition = targetRootPart.Position
    local direction = targetPosition - origin

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.RespectCanCollide = true

    local ignoreList = {attackerCharacter}
    
    if additionalIgnore and typeof(additionalIgnore) == "table" then
        for _, item in pairs(additionalIgnore) do
            table.insert(ignoreList, item)
        end
    end

    raycastParams.FilterDescendantsInstances = ignoreList

    local raycastResult = workspace:Raycast(origin, direction, raycastParams)

    if raycastResult then
        if raycastResult.Instance:IsDescendantOf(targetCharacter) then
            return true
        else
            return false
        end
    else
        return true
    end
end

run(function()
	local function isFirstPerson()
		if not (lplr.Character and lplr.Character:FindFirstChild("Head")) then return nil end
		return (lplr.Character.Head.Position - gameCamera.CFrame.Position).Magnitude < 2
	end
	local AimAssist
	local Targets
	local Sort
	local AimSpeed
	local Distance
	local AngleSlider
	local StrafeIncrease
	local KillauraTarget
	local ClickAim
	local ShopCheck
	local FirstPersonCheck
	
	AimAssist = vape.Categories.Combat:CreateModule({
		Name = 'AimAssist',
		Function = function(callback)
			if callback then
				AimAssist:Clean(runService.Heartbeat:Connect(function(dt)
					if entitylib.isAlive and store.localHand.Type == 'sword' and ((not ClickAim.Enabled) or (workspace:GetServerTimeNow() - bedwars.SwordController.lastAttack) < 0.4) then
						local ent = entitylib.EntityPosition({
							Range = Distance.Value,
							Part = 'RootPart',
							Players = Targets.Players.Enabled,
							NPCs = Targets.NPCs.Enabled,
							Sort = sortmethods[Sort.Value]
						})
	
						if ent then
							if FirstPersonCheck.Enabled then
								if not isFirstPerson() then return end
							end
							if ShopCheck.Enabled then
								local isShop = lplr:FindFirstChild("PlayerGui") and lplr:FindFirstChild("PlayerGui"):FindFirstChild("ItemShop") or nil
								if isShop then return end
							end
							if Targets.Walls.Enabled then
								if not Wallcheck(lplr.Character, ent.Character) then return end
							end
							pcall(function()
								local plr = ent
								vapeTargetInfo.Targets.AimAssist = {
									Humanoid = {
										Health = (plr.Character:GetAttribute("Health") or plr.Humanoid.Health) + getShieldAttribute(plr.Character),
										MaxHealth = plr.Character:GetAttribute("MaxHealth") or plr.Humanoid.MaxHealth
									},
									Player = plr.Player
								}
							end)
							local delta = (ent.RootPart.Position - entitylib.character.RootPart.Position)
							local localfacing = entitylib.character.RootPart.CFrame.LookVector * Vector3.new(1, 0, 1)
							local angle = math.acos(localfacing:Dot((delta * Vector3.new(1, 0, 1)).Unit))
							if angle >= (math.rad(AngleSlider.Value) / 2) then return end
							pcall(function()
								targetinfo.Targets[ent] = tick() + 1
							end)
							gameCamera.CFrame = gameCamera.CFrame:Lerp(CFrame.lookAt(gameCamera.CFrame.p, ent.RootPart.Position), (AimSpeed.Value + (StrafeIncrease.Enabled and (inputService:IsKeyDown(Enum.KeyCode.A) or inputService:IsKeyDown(Enum.KeyCode.D)) and 10 or 0)) * dt)
						end
					end
				end))
			else pcall(function() vapeTargetInfo.Targets.AimAssist = nil end) end
		end,
		Tooltip = 'Smoothly aims to closest valid target with sword'
	})
	Targets = AimAssist:CreateTargets({
		Players = true, 
		Walls = true
	})
	local methods = {'Damage', 'Distance'}
	for i in sortmethods do
		if not table.find(methods, i) then
			table.insert(methods, i)
		end
	end
	Sort = AimAssist:CreateDropdown({
		Name = 'Target Mode',
		List = methods
	})
	AimSpeed = AimAssist:CreateSlider({
		Name = 'Aim Speed',
		Min = 1,
		Max = 20,
		Default = 6
	})
	Distance = AimAssist:CreateSlider({
		Name = 'Distance',
		Min = 1,
		Max = 30,
		Default = 30,
		Suffx = function(val) 
			return val == 1 and 'stud' or 'studs' 
		end
	})
	AngleSlider = AimAssist:CreateSlider({
		Name = 'Max angle',
		Min = 1,
		Max = 360,
		Default = 70
	})
	ClickAim = AimAssist:CreateToggle({
		Name = 'Click Aim',
		Default = true
	})
	KillauraTarget = AimAssist:CreateToggle({
		Name = 'Use killaura target'
	})
	ShopCheck = AimAssist:CreateToggle({
		Name = "Shop Check",
		Function = function() end,
		Default = false
	})
	FirstPersonCheck = AimAssist:CreateToggle({
		Name = "First Person Check",
		Function = function() end,
		Default = false
	})
	StrafeIncrease = AimAssist:CreateToggle({Name = 'Strafe increase'})
end)

run(function()
	local Sprint = {Enabled = false}
	local oldSprintFunction
	Sprint = vape.Categories.Combat:CreateModule({
		Name = "Sprint",
		Function = function(callback)
			if callback then
				sprinten = true
				thread = task.spawn(function()
					repeat task.wait()
						if lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
							lplr:SetAttribute("Sprinting", true)
							lplr.Character.Humanoid.WalkSpeed = 20
						end
					until not sprinten
				end)
			else 
				sprinten = false
				if lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
					lplr.Character.Humanoid.WalkSpeed = 16
				end
				lplr:SetAttribute("Sprinting", false)
				if thread then
					task.cancel(thread)
					thread = nil
				end
			end 
		end,
		Tooltip = "Sets your sprinting to true."
	})
	lplr.CharacterAdded:Connect(function(character)
		if sprinten then
			character:WaitForChild("Humanoid").WalkSpeed = 23
		else
			character:WaitForChild("Humanoid").WalkSpeed = 16
		end
	end)
	lplr.CharacterRemoving:Connect(function(character)
		if character:WaitForChild("Humanoid") then
			character:WaitForChild("Humanoid").WalkSpeed = 16
		end
	end)
end)

run(function()
	local replicatedStorage = game:GetService("ReplicatedStorage")
	local kbUtil = replicatedStorage:WaitForChild("TS"):WaitForChild("damage")["knockback-util"]
	local orig = {
		kbDirectionStrength = 11750,
		kbUpwardStrength = 10000
	}

    local Velocity
    local Horizontal
    local Vertical
    local Chance
    local TargetCheck
    local rand, old = Random.new()
    
    Velocity = vape.Categories.Combat:CreateModule({
        Name = 'Velocity',
        Function = function(callback)
            if callback then
				task.spawn(function()
					repeat
						local check = (not TargetCheck.Enabled) or entitylib.EntityPosition({
							Range = 50,
							Part = 'RootPart',
							Players = true
						})
		
						if check then
							kbUtil:SetAttribute("ConstantManager_kbDirectionStrength", orig.kbDirectionStrength * (Horizontal.Value / 100))
							kbUtil:SetAttribute("ConstantManager_kbUpwardStrength", orig.kbDirectionStrength * (Vertical.Value / 100))
						else
							kbUtil:SetAttribute("ConstantManager_kbDirectionStrength", orig.kbDirectionStrength)
							kbUtil:SetAttribute("ConstantManager_kbUpwardStrength", orig.kbDirectionStrength)
						end

						task.wait()
					until not Velocity.Enabled
				end)
            else
                task.wait()
                kbUtil:SetAttribute("ConstantManager_kbDirectionStrength", orig.kbDirectionStrength)
                kbUtil:SetAttribute("ConstantManager_kbUpwardStrength", orig.kbDirectionStrength)
            end
        end,
        Tooltip = 'Reduces knockback taken'
    })
    Horizontal = Velocity:CreateSlider({
        Name = 'Horizontal',
        Min = 0,
        Max = 100,
        Default = 0,
        Suffix = '%'
    })
    Vertical = Velocity:CreateSlider({
        Name = 'Vertical',
        Min = 0,
        Max = 100,
        Default = 0,
        Suffix = '%'
    })
    TargetCheck = Velocity:CreateToggle({Name = 'Only when targeting'})
end)

run(function()
	local StaffDetector
	local Mode
	local Profile
	local Users
	local blacklistedclans = {'gg', 'gg2', 'DV', 'DV2'}
	local blacklisteduserids = {1502104539, 3826146717, 4531785383, 1049767300, 4926350670, 653085195, 184655415, 2752307430, 5087196317, 5744061325, 1536265275}
	local joined = {}
	
	local permissions = {
		[87365146] = {
			"admin",
			"freecam"
		},
		[78390760] = {
			"filmer"
		},
		[225721992] = {
			"admin",
			"freecam"
		},
		[21406719] = {
			"admin",
			"freecam"
		},
		[1776734677] = {
			"filmer"
		},
		[308165] = {
			"admin",
			"freecam"
		},
		[172603477] = {
			"artist",
			"freecam"
		},
		[281575310] = {
			"admin",
			"freecam"
		},
		[2237298638] = {
			"artist",
			"freecam"
		},
		[437492645] = {
			"artist",
			"freecam"
		},
		[34466481] = {
			"artist",
			"freecam"
		},
		[205430552] = {
			"artist",
			"freecam"
		},
		[3361695884] = {
			"admin",
			"freecam"
		},
		[22808138] = {
			"admin",
			"freecam",
			"filmer",
			"anticheat_mod"
		},
		[1793668872] = {
			"admin"
		},
		[22641473] = {
			"admin",
			"freecam"
		},
		[4001781] = {
			"admin",
			"freecam"
		},
		[75380482] = {
			"admin",
			"freecam"
		},
		[20663325] = {
			"admin",
			"freecam"
		},
		[4308133] = {
			"admin",
			"freecam"
		}
	}
	
	local function getRole(plr, id)
		local suc, res = pcall(function() 
			return plr:GetRankInGroup(id)
		end)
		if not suc then 
			InfoNotification('StaffDetector', res, 30, 'alert') 
		end
		return suc and res or 0
	end
	
	local function staffFunction(plr, checktype)
		if not vape.Loaded then
			repeat task.wait() until vape.Loaded
		end
	
		notif('StaffDetector', 'Staff Detected ('..checktype..'): '..plr.Name..' ('..plr.UserId..')', 60, 'alert')
		whitelist.customtags[plr.Name] = {{text = 'GAME STAFF', color = Color3.new(1, 0, 0)}}
	
		if Mode.Value == 'Uninject' then
			task.spawn(function()
				vape:Uninject()
			end)
			game:GetService('StarterGui'):SetCore('SendNotification', {
				Title = 'StaffDetector',
				Text = 'Staff Detected ('..checktype..')\n'..plr.Name..' ('..plr.UserId..')',
				Duration = 60,
			})
		elseif Mode.Value == 'Profile' then
			vape.Save = function() end
			if vape.Profile ~= Profile.Value then
				vape:Load(true, Profile.Value)
			end
		elseif Mode.Value == 'AutoConfig' then
			local safe = {'AutoClicker', 'Reach', 'Sprint', 'HitFix', 'StaffDetector'}
			vape.Save = function() end
			for i, v in vape.Modules do
				if not (table.find(safe, i) or v.Category == 'Render') then
					if v.Enabled then
						v:Toggle()
					end
					v:SetBind('')
				end
			end
		end
	end
	
	local function checkFriends(list)
		for _, v in list do
			if joined[v] then
				return joined[v]
			end
		end
		return nil
	end
	
	local function checkJoin(plr, connection)
		if not plr:GetAttribute('Team') and plr:GetAttribute('Spectator') and not bedwars.Store:getState().Game.customMatch then
			connection:Disconnect()
			local tab, pages = {}, playersService:GetFriendsAsync(plr.UserId)
			for _ = 1, 4 do
				for _, v in pages:GetCurrentPage() do
					table.insert(tab, v.Id)
				end
				if pages.IsFinished then break end
				pages:AdvanceToNextPageAsync()
			end
	
			local friend = checkFriends(tab)
			if not friend then
				staffFunction(plr, 'impossible_join')
			else
				InfoNotification('StaffDetector', string.format('Spectator %s joined from %s', plr.Name, friend), 20, 'warning')
			end
		end
	end
	
	local function playerAdded(plr)
		joined[plr.UserId] = plr.Name
		if plr == lplr then return end
	
		if table.find(blacklisteduserids, plr.UserId) or table.find(Users.ListEnabled, tostring(plr.UserId)) then
			staffFunction(plr, 'blacklisted_user')
		elseif getRole(plr, 5774246) >= 100 then
			staffFunction(plr, 'staff_role')
		elseif permissions[plr.UserId] and table.find(permissions[plr.UserId], "admin") then
			staffFunction(plr, 'permissions_detected')
		else
			local perms = permissions[plr.UserId]
			if perms then
				pcall(function()
					if not table.find(perms, "admin") then
						warningNotification("StaffDetector", plr.Name.." is "..tostring(perms[1]).."!", 3)
					end
				end)	
			end
			local connection
			connection = plr:GetAttributeChangedSignal('Spectator'):Connect(function()
				checkJoin(plr, connection)
			end)
			StaffDetector:Clean(connection)
			if checkJoin(plr, connection) then
				return
			end
	
			if not plr:GetAttribute('ClanTag') then
				plr:GetAttributeChangedSignal('ClanTag'):Wait()
			end
	
			if table.find(blacklistedclans, plr:GetAttribute('ClanTag')) and vape.Loaded then
				connection:Disconnect()
				staffFunction(plr, 'blacklisted_clan_'..plr:GetAttribute('ClanTag'):lower())
			end
		end
	end
	
	StaffDetector = vape.Categories.Utility:CreateModule({
		Name = 'StaffDetector',
		Function = function(callback)
			if callback then
				StaffDetector:Clean(playersService.PlayerAdded:Connect(playerAdded))
				for _, v in playersService:GetPlayers() do 
					task.spawn(playerAdded, v) 
				end
			else
				table.clear(joined)
			end
		end,
		Tooltip = 'Detects people with a staff rank ingame'
	})
	Mode = StaffDetector:CreateDropdown({
		Name = 'Mode',
		List = {'Uninject', 'Profile', 'AutoConfig', 'Notify'},
		Function = function(val)
			if Profile.Object then
				Profile.Object.Visible = val == 'Profile'
			end
		end
	})
	Profile = StaffDetector:CreateTextBox({
		Name = 'Profile',
		Default = 'default',
		Darker = true,
		Visible = false
	})
	Users = StaffDetector:CreateTextList({
		Name = 'Users',
		Placeholder = 'player (userid)'
	})
	
	task.spawn(function()
		repeat task.wait(1) until vape.Loaded or vape.Loaded == nil
		if vape.Loaded and not StaffDetector.Enabled then
			StaffDetector:Toggle()
		end
	end)
end)

local autobankballoon = false
run(function()
	local Fly = {Enabled = false}
	local FlyMode = {Value = "CFrame"}
	local FlyVerticalSpeed = {Value = 40}
	local FlyVertical = {Enabled = true}
	local FlyAutoPop = {Enabled = true}
	local FlyAnyway = {Enabled = false}
	local FlyAnywayProgressBar = {Enabled = false}
	local FlyDamageAnimation = {Enabled = false}
	local FlyTP = {Enabled = false}
	local FlyMobileButtons = {Enabled = false}
	local FlyAnywayProgressBarFrame
	local olddeflate
	local FlyUp = false
	local FlyDown = false
	local FlyCoroutine
	local groundtime = tick()
	local onground = false
	local lastonground = false
	local alternatelist = {"Normal", "AntiCheat A", "AntiCheat B"}
	local mobileControls = {}

	local function createMobileButton(name, position, icon)
		local button = Instance.new("TextButton")
		button.Name = name
		button.Size = UDim2.new(0, 60, 0, 60)
		button.Position = position
		button.BackgroundTransparency = 0.2
		button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		button.BorderSizePixel = 0
		button.Text = icon
		button.TextScaled = true
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.Font = Enum.Font.SourceSansBold
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = button
		return button
	end

	local function cleanupMobileControls()
		for _, control in pairs(mobileControls) do
			if control then
				control:Destroy()
			end
		end
		mobileControls = {}
	end

	local function setupMobileControls()
		cleanupMobileControls()
		local gui = Instance.new("ScreenGui")
		gui.Name = "FlyControls"
		gui.ResetOnSpawn = false
		gui.Parent = lplr.PlayerGui

		local upButton = createMobileButton("UpButton", UDim2.new(0.9, -70, 0.7, -140), "↑")
		local downButton = createMobileButton("DownButton", UDim2.new(0.9, -70, 0.7, -70), "↓")

		mobileControls.UpButton = upButton
		mobileControls.DownButton = downButton
		mobileControls.ScreenGui = gui

		upButton.Parent = gui
		downButton.Parent = gui

		return upButton, downButton
	end

	local function inflateBalloon()
		if not Fly.Enabled then return end
		if entityLibrary.isAlive and (lplr.Character:GetAttribute("InflatedBalloons") or 0) < 1 then
			autobankballoon = true
			if getItem("balloon") then
				bedwars.BalloonController:inflateBalloon()
				return true
			end
		end
		return false
	end

	Fly = vape.Categories.Blatant:CreateModule({
		Name = "Fly",
		Function = function(callback)
			if callback then
				olddeflate = bedwars.BalloonController.deflateBalloon
				bedwars.BalloonController.deflateBalloon = function() end
				Fly:Clean(inputService.InputBegan:Connect(function(input1)
					if FlyVertical.Enabled and inputService:GetFocusedTextBox() == nil then
						if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
							FlyUp = true
						end
						if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
							FlyDown = true
						end
					end
				end))
				Fly:Clean(inputService.InputEnded:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
						FlyUp = false
					end
					if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
						FlyDown = false
					end
				end))

				local isMobile = inputService.TouchEnabled and not inputService.KeyboardEnabled and not inputService.MouseEnabled
				if FlyMobileButtons.Enabled or isMobile then
					local upButton, downButton = setupMobileControls()
					
					Fly:Clean(upButton.MouseButton1Down:Connect(function()
						if FlyVertical.Enabled then FlyUp = true end
					end))
					Fly:Clean(upButton.MouseButton1Up:Connect(function()
						FlyUp = false
					end))
					Fly:Clean(downButton.MouseButton1Down:Connect(function()
						if FlyVertical.Enabled then FlyDown = true end
					end))
					Fly:Clean(downButton.MouseButton1Up:Connect(function()
						FlyDown = false
					end))
				end

				if inputService.TouchEnabled then
					pcall(function()
						local jumpButton = lplr.PlayerGui.TouchGui.TouchControlFrame.JumpButton
						Fly:Clean(jumpButton:GetPropertyChangedSignal("ImageRectOffset"):Connect(function()
							if not mobileControls.UpButton then 
								FlyUp = jumpButton.ImageRectOffset.X == 146 and FlyVertical.Enabled
							end
						end))
						if not mobileControls.UpButton then
							FlyUp = jumpButton.ImageRectOffset.X == 146 and FlyVertical.Enabled
						end
					end)
				end

				Fly:Clean(vapeEvents.BalloonPopped.Event:Connect(function(poppedTable)
					if poppedTable.inflatedBalloon and poppedTable.inflatedBalloon:GetAttribute("BalloonOwner") == lplr.UserId then
						lastonground = not onground
						repeat task.wait() until (lplr.Character:GetAttribute("InflatedBalloons") or 0) <= 0 or not Fly.Enabled
						inflateBalloon()
					end
				end))
				Fly:Clean(vapeEvents.AutoBankBalloon.Event:Connect(function()
					repeat task.wait() until getItem("balloon")
					inflateBalloon()
				end))

				local balloons
				if entityLibrary.isAlive and (not store.queueType:find("mega")) then
					balloons = inflateBalloon()
				end
				local megacheck = store.queueType:find("mega") or store.queueType == "winter_event"

				task.spawn(function()
					repeat task.wait() until store.queueType ~= "bedwars_test" or (not Fly.Enabled)
					if not Fly.Enabled then return end
					megacheck = store.queueType:find("mega") or store.queueType == "winter_event"
				end)

				local flyAllowed = entityLibrary.isAlive and ((lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") > 0) or store.matchState == 2 or megacheck) and 1 or 0
				if flyAllowed <= 0 and shared.damageanim and (not balloons) then
					shared.damageanim()
					bedwars.SoundManager:playSound(bedwars.SoundList["DAMAGE_"..math.random(1, 3)])
				end

				if FlyAnywayProgressBarFrame and flyAllowed <= 0 and (not balloons) then
					FlyAnywayProgressBarFrame.Visible = true
					pcall(function() FlyAnywayProgressBarFrame.Frame:TweenSize(UDim2.new(1, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true) end)
				end

				groundtime = tick() + (2.6 + (entityLibrary.groundTick - tick()))
				FlyCoroutine = coroutine.create(function()
					repeat
						repeat task.wait() until (groundtime - tick()) < 0.6 and not onground
						flyAllowed = ((lplr.Character and lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") > 0) or store.matchState == 2 or megacheck) and 1 or 0
						if (not Fly.Enabled) then break end
						local Flytppos = -99999
						if flyAllowed <= 0 and FlyTP.Enabled and entityLibrary.isAlive then
							local ray = game.Workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(0, -1000, 0), store.blockRaycast)
							if ray then
								Flytppos = entityLibrary.character.HumanoidRootPart.Position.Y
								local args = {entityLibrary.character.HumanoidRootPart.CFrame:GetComponents()}
								args[2] = ray.Position.Y + (entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight
								entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(unpack(args))
								task.wait(0.12)
								if (not Fly.Enabled) then break end
								flyAllowed = ((lplr.Character and lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") > 0) or store.matchState == 2 or megacheck) and 1 or 0
								if flyAllowed <= 0 and Flytppos ~= -99999 and entityLibrary.isAlive then
									local args = {entityLibrary.character.HumanoidRootPart.CFrame:GetComponents()}
									args[2] = Flytppos
									entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(unpack(args))
								end
							end
						end
					until (not Fly.Enabled)
				end)
				coroutine.resume(FlyCoroutine)
				Fly:Clean(runservice.Heartbeat:Connect(function(delta)
					if entityLibrary.isAlive then
						local playerMass = (entityLibrary.character.HumanoidRootPart:GetMass() - 1.4) * (delta * 100)
						flyAllowed = ((lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") > 0) or store.matchState == 2 or megacheck) and 1 or 0
						playerMass = playerMass + (flyAllowed > 0 and 4 or 0) * (tick() % 0.4 < 0.2 and -1 or 1)

						if FlyAnywayProgressBarFrame then
							FlyAnywayProgressBarFrame.Visible = Fly.Enabled and flyAllowed <= 0
							FlyAnywayProgressBarFrame.BackgroundColor3 = Color3.fromHSV(vape.GUIColor.Hue, vape.GUIColor.Sat, vape.GUIColor.Value)
							pcall(function()
								FlyAnywayProgressBarFrame.Frame.BackgroundColor3 = Color3.fromHSV(vape.GUIColor.Hue, vape.GUIColor.Sat, vape.GUIColor.Value)
							end)
						end

						if flyAllowed <= 0 then
							local newray = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + Vector3.new(0, (entityLibrary.character.Humanoid.HipHeight * -2) - 1, 0))
							onground = newray and true or false
							if lastonground ~= onground then
								if (not onground) then
									groundtime = tick() + (2.6 + (entityLibrary.groundTick - tick()))
									if FlyAnywayProgressBarFrame then
										FlyAnywayProgressBarFrame.Frame:TweenSize(UDim2.new(0, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, groundtime - tick(), true)
									end
								else
									if FlyAnywayProgressBarFrame then
										FlyAnywayProgressBarFrame.Frame:TweenSize(UDim2.new(1, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true)
									end
								end
							end
							if FlyAnywayProgressBarFrame then
								FlyAnywayProgressBarFrame.Visible = Fly.Enabled and groundtime ~= nil
								if groundtime ~= nil then
									FlyAnywayProgressBarFrame.TextLabel.Text = math.max(onground and 2.5 or math.floor((groundtime - tick()) * 10) / 10, 0).."s"
								end
							end
							lastonground = onground
						else
							onground = true
							lastonground = true
						end

						local flyVelocity = entityLibrary.character.Humanoid.MoveDirection * (FlyMode.Value == "Normal" and FlySpeed.Value or 20)
						entityLibrary.character.HumanoidRootPart.Velocity = flyVelocity + (Vector3.new(0, playerMass + (FlyUp and FlyVerticalSpeed.Value or 0) + (FlyDown and -FlyVerticalSpeed.Value or 0), 0))
						if FlyMode.Value ~= "Normal" then
							entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + (entityLibrary.character.Humanoid.MoveDirection * ((FlySpeed.Value + getSpeed()) - 20)) * delta
						end
					end
				end))
			else
				pcall(function() coroutine.close(FlyCoroutine) end)
				autobankballoon = false
				waitingforballoon = false
				lastonground = nil
				FlyUp = false
				FlyDown = false
				if FlyAnywayProgressBarFrame then
					FlyAnywayProgressBarFrame.Visible = false
				end
				if FlyAutoPop.Enabled then
					if entityLibrary.isAlive and lplr.Character:GetAttribute("InflatedBalloons") then
						for i = 1, lplr.Character:GetAttribute("InflatedBalloons") do
							olddeflate()
						end
					end
				end
				bedwars.BalloonController.deflateBalloon = olddeflate
				olddeflate = nil
				cleanupMobileControls()
			end
		end,
		Tooltip = "Makes you go zoom (longer Fly discovered by exelys and Cqded)",
		ExtraText = function()
			return "Heatseeker"
		end
	})
	FlySpeed = Fly:CreateSlider({
		Name = "Speed",
		Min = 1,
		Max = 23,
		Function = function(val) end,
		Default = 23
	})
	FlyVerticalSpeed = Fly:CreateSlider({
		Name = "Vertical Speed",
		Min = 1,
		Max = 100,
		Function = function(val) end,
		Default = 44
	})
	FlyVertical = Fly:CreateToggle({
		Name = "Y Level",
		Function = function() end,
		Default = true
	})
	FlyAutoPop = Fly:CreateToggle({
		Name = "Pop Balloon",
		Function = function() end,
		Tooltip = "Pops balloons when Fly is disabled."
	})
	FlyAnywayProgressBar = Fly:CreateToggle({
		Name = "Progress Bar",
		Function = function(callback)
			if callback then
				FlyAnywayProgressBarFrame = Instance.new("Frame")
				FlyAnywayProgressBarFrame.AnchorPoint = Vector2.new(0.5, 0)
				FlyAnywayProgressBarFrame.Position = UDim2.new(0.5, 0, 1, -200)
				FlyAnywayProgressBarFrame.Size = UDim2.new(0.2, 0, 0, 20)
				FlyAnywayProgressBarFrame.BackgroundTransparency = 0.5
				FlyAnywayProgressBarFrame.BorderSizePixel = 0
				FlyAnywayProgressBarFrame.BackgroundColor3 = Color3.new(0, 0, 0)
				FlyAnywayProgressBarFrame.Visible = Fly.Enabled
				FlyAnywayProgressBarFrame.Parent = vape.gui
				local FlyAnywayProgressBarFrame2 = FlyAnywayProgressBarFrame:Clone()
				FlyAnywayProgressBarFrame2.AnchorPoint = Vector2.new(0, 0)
				FlyAnywayProgressBarFrame2.Position = UDim2.new(0, 0, 0, 0)
				FlyAnywayProgressBarFrame2.Size = UDim2.new(1, 0, 0, 20)
				FlyAnywayProgressBarFrame2.BackgroundTransparency = 0
				FlyAnywayProgressBarFrame2.Visible = true
				FlyAnywayProgressBarFrame2.Parent = FlyAnywayProgressBarFrame
				local FlyAnywayProgressBartext = Instance.new("TextLabel")
				FlyAnywayProgressBartext.Text = "2s"
				FlyAnywayProgressBartext.Font = Enum.Font.Gotham
				FlyAnywayProgressBartext.TextStrokeTransparency = 0
				FlyAnywayProgressBartext.TextColor3 =  Color3.new(0.9, 0.9, 0.9)
				FlyAnywayProgressBartext.TextSize = 20
				FlyAnywayProgressBartext.Size = UDim2.new(1, 0, 1, 0)
				FlyAnywayProgressBartext.BackgroundTransparency = 1
				FlyAnywayProgressBartext.Position = UDim2.new(0, 0, -1, 0)
				FlyAnywayProgressBartext.Parent = FlyAnywayProgressBarFrame
			else
				if FlyAnywayProgressBarFrame then FlyAnywayProgressBarFrame:Destroy() FlyAnywayProgressBarFrame = nil end
			end
		end,
		Tooltip = "show amount of Fly time",
		Default = true
	})
	local oldcamupdate
	local camcontrol
	local Flydamagecamera = {Enabled = false}
	FlyDamageAnimation = Fly:CreateToggle({
		Name = "Damage Animation",
		Function = function(callback)
			if Flydamagecamera.Object then
				Flydamagecamera.Object.Visible = callback
			end
			if callback then
				task.spawn(function()
					repeat
						task.wait(0.1)
						for i,v in pairs(getconnections(gameCamera:GetPropertyChangedSignal("CameraType"))) do
							if v.Function then
								camcontrol = debug.getupvalue(v.Function, 1)
							end
						end
					until camcontrol
					local caminput = require(lplr.PlayerScripts.PlayerModule.CameraModule.CameraInput)
					local num = Instance.new("IntValue")
					local numanim
					shared.damageanim = function()
						if numanim then numanim:Cancel() end
						if Flydamagecamera.Enabled then
							num.Value = 1000
							numanim = tweenService:Create(num, TweenInfo.new(0.5), {Value = 0})
							numanim:Play()
						end
					end
					oldcamupdate = camcontrol.Update
					camcontrol.Update = function(self, dt)
						if camcontrol.activeCameraController then
							camcontrol.activeCameraController:UpdateMouseBehavior()
							local newCameraCFrame, newCameraFocus = camcontrol.activeCameraController:Update(dt)
							gameCamera.CFrame = newCameraCFrame * CFrame.Angles(0, 0, math.rad(num.Value / 100))
							gameCamera.Focus = newCameraFocus
							if camcontrol.activeTransparencyController then
								camcontrol.activeTransparencyController:Update(dt)
							end
							if caminput.getInputEnabled() then
								caminput.resetInputForFrameEnd()
							end
						end
					end
				end)
			else
				shared.damageanim = nil
				if camcontrol then
					camcontrol.Update = oldcamupdate
				end
			end
		end
	})
	Flydamagecamera = Fly:CreateToggle({
		Name = "Camera Animation",
		Function = function() end,
		Default = true
	})
	Flydamagecamera.Object.BorderSizePixel = 0
	Flydamagecamera.Object.BackgroundTransparency = 0
	Flydamagecamera.Object.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	Flydamagecamera.Object.Visible = false
	FlyTP = Fly:CreateToggle({
		Name = "TP Down",
		Function = function() end,
		Default = true
	})
	FlyMobileButtons = Fly:CreateToggle({
		Name = "Mobile Buttons",
		Default = false,
		Function = function(callback)
			if Fly.Enabled then
				Fly:Toggle()
				Fly:Toggle()
			end
		end
	})
end)

run(function()
	local InfiniteFly
	InfiniteFly = vape.Categories.Blatant:CreateModule({
		Name = "InfiniteFly",
		Function = function(callback)
			if callback then
				InfiniteFly:Toggle()
			end
		end,
		Tooltip = "Makes you go zoom",
		ExtraText = function()
			return "Heatseeker"
		end
	})
end)

local weaplist = {
	{"rageblade", 100}, {"emerald_sword", 99}, {"deathbloom", 99},
	{"glitch_void_sword", 98}, {"sky_scythe", 98}, {"diamond_sword", 97},
	{"iron_sword", 96}, {"stone_sword", 95}, {"wood_sword", 94},
	{"emerald_dao", 93}, {"diamond_dao", 99}, {"diamond_dagger", 99},
	{"diamond_great_hammer", 99}, {"diamond_scythe", 99}, {"iron_dao", 97},
	{"iron_scythe", 97}, {"iron_dagger", 97}, {"iron_great_hammer", 97},
	{"stone_dao", 96}, {"stone_dagger", 96}, {"stone_great_hammer", 96},
	{"stone_scythe", 96}, {"wood_dao", 95}, {"wood_scythe", 95},
	{"wood_great_hammer", 95}, {"wood_dagger", 95}, {"frosty_hammer", 1}
}

local function getweapon()
	local bestrank = 0
	local inv = lplr.Character.InventoryFolder.Value
	local bestweap
	
	for _, weap in ipairs(weaplist) do
		if weap[2] > bestrank and inv:FindFirstChild(weap[1]) then
			bestweap = weap[1]
			bestrank = weap[2]
		end
	end
	return inv:FindFirstChild(bestweap)
end

local function gettargets(range, maxt, limit)
	local targets = {}
	local playerpos = lplr.Character.PrimaryPart.Position
	local playerlook = lplr.Character.PrimaryPart.CFrame.LookVector * Vector3.new(1, 0, 1)
	
	for _, plr in pairs(game.Players:GetPlayers()) do
		pcall(function()
			if plr == lplr or plr.Team == lplr.Team then return end
			if not plr.Character or not plr.Character:FindFirstChild("Humanoid") then return end
			
			local dist = (plr.Character.PrimaryPart.Position - playerpos).Magnitude
			
			if plr.Character.Humanoid.Health > 0 and dist <= range then
				if limit then
					local delta = (plr.Character.PrimaryPart.Position - playerpos)
					local angle = math.acos(playerlook:Dot((delta * Vector3.new(1, 0, 1)).Unit))
					if angle > (math.rad(limit) / 2) then return end
				end
				
				local dat = {
					Player = plr,
					Character = plr.Character,
					Health = plr.Character.Humanoid.Health,
					MaxHealth = plr.Character.Humanoid.MaxHealth
				}
				
				table.insert(targets, dat)
				targetinfo.Targets[dat] = tick() + 1
			end
		end)
	end
	
	table.sort(targets, function(a, b)
		local distA = (a.Character.PrimaryPart.Position - playerpos).Magnitude
		local distB = (b.Character.PrimaryPart.Position - playerpos).Magnitude
		return distA < distB
	end)
	
	if maxt and #targets > maxt then
		for i = maxt + 1, #targets do
			targets[i] = nil
		end
	end
	
	return targets
end

local RunLoops = { RenderStepTable = {}, StepTable = {}, HeartTable = {} }

local function BindToLoop(tableName, service, name, func)
	local oldfunc = func
	func = function(delta) VoidwareFunctions.handlepcall(pcall(function() oldfunc(delta) end)) end
    if RunLoops[tableName][name] == nil then
        RunLoops[tableName][name] = service:Connect(func)
        table.insert(vapeConnections, RunLoops[tableName][name])
    end
end

local function UnbindFromLoop(tableName, name)
    if RunLoops[tableName][name] then
        RunLoops[tableName][name]:Disconnect()
        RunLoops[tableName][name] = nil
    end
end

function RunLoops:BindToRenderStep(name, func)
    BindToLoop("RenderStepTable", runService.RenderStepped, name, func)
end

function RunLoops:UnbindFromRenderStep(name)
    UnbindFromLoop("RenderStepTable", name)
end

function RunLoops:BindToStepped(name, func)
    BindToLoop("StepTable", runService.Stepped, name, func)
end

function RunLoops:UnbindFromStepped(name)
    UnbindFromLoop("StepTable", name)
end

function RunLoops:BindToHeartbeat(name, func)
    BindToLoop("HeartTable", runService.Heartbeat, name, func)
end

function RunLoops:UnbindFromHeartbeat(name)
    UnbindFromLoop("HeartTable", name)
end

local cleanTable = function(tab)
	local res = {}
	for i,v in pairs(tab) do table.insert(res, tostring(i)) end
	return res
end

local function isFirstPerson()
	if not entitylib.isAlive then return false end
	return (entitylib.character.Head.Position - gameCamera.CFrame.Position).Magnitude < 2
end

local originalArmC0, originalNeckC0, originalRootC0

local Attacking
local killauraNearPlayer = Attacking
run(function()
	local inputService = inputService or game:GetService("UserInputService")
	local tweenService = tweenService or game:GetService("TweenService")
	local TweenService = TweenService or tweenService
	vape.Libraries = vape.Libraries or {}
	vape.Libraries.auraanims = vape.Libraries.auraanims or {
		Normal = {
			{CFrame = CFrame.new(-0.17, -0.14, -0.12) * CFrame.Angles(math.rad(-53), math.rad(50), math.rad(-64)), Time = 0.1},
			{CFrame = CFrame.new(-0.55, -0.59, -0.1) * CFrame.Angles(math.rad(-161), math.rad(54), math.rad(-6)), Time = 0.08},
			{CFrame = CFrame.new(-0.62, -0.68, -0.07) * CFrame.Angles(math.rad(-167), math.rad(47), math.rad(-1)), Time = 0.03},
			{CFrame = CFrame.new(-0.56, -0.86, 0.23) * CFrame.Angles(math.rad(-167), math.rad(49), math.rad(-1)), Time = 0.03}
		},
		Random = {},
		['Horizontal Spin'] = {
			{CFrame = CFrame.Angles(math.rad(-10), math.rad(-90), math.rad(-80)), Time = 0.12},
			{CFrame = CFrame.Angles(math.rad(-10), math.rad(180), math.rad(-80)), Time = 0.12},
			{CFrame = CFrame.Angles(math.rad(-10), math.rad(90), math.rad(-80)), Time = 0.12},
			{CFrame = CFrame.Angles(math.rad(-10), 0, math.rad(-80)), Time = 0.12}
		},
		['Vertical Spin'] = {
			{CFrame = CFrame.Angles(math.rad(-90), 0, math.rad(15)), Time = 0.12},
			{CFrame = CFrame.Angles(math.rad(180), 0, math.rad(15)), Time = 0.12},
			{CFrame = CFrame.Angles(math.rad(90), 0, math.rad(15)), Time = 0.12},
			{CFrame = CFrame.Angles(0, 0, math.rad(15)), Time = 0.12}
		},
		Exhibition = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
		},
		['Exhibition Old'] = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.05},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
			{CFrame = CFrame.new(0.63, -0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.15}
		}
	}
	local Killaura
	local Targets
	local Sort
	local Range
	local RangeCircle
	local RangeCirclePart
	local UpdateRate
	local AngleSlider
	local MaxTargets
	local Mouse
	local Swing
	local GUI
	local BoxColor
	local ParticleTexture
	local ParticleColor1
	local ParticleColor2
	local ParticleSize
	local Face
	local Animation
	local AnimationMode
	local AnimationSpeed
	local AnimationTween
	local Limit
	local LegitAura
	local Sync
	local Particles, Boxes = {}, {}
	local anims, AnimDelay, AnimTween, armC0 = vape.Libraries.auraanims, tick()
	local AttackRemote = {FireServer = function() end}
	task.spawn(function()
		AttackRemote = bedwars.Client:Get(bedwars.AttackRemote)
		local Reach = Reach or {Enabled = false}
		local HitBoxes = HitBoxes or {Enabled = false}
		AttackRemote.FireServer = function(self, attackTable, ...)
			local suc, plr = pcall(function()
				return playersService:GetPlayerFromCharacter(attackTable.entityInstance)
			end)

			local selfpos = attackTable.validate.selfPosition.value
			local targetpos = attackTable.validate.targetPosition.value
			store.attackReach = ((selfpos - targetpos).Magnitude * 100) // 1 / 100
			store.attackReachUpdate = tick() + 1
			if Reach.Enabled or HitBoxes.Enabled then
				attackTable.validate.raycast = attackTable.validate.raycast or {}
				attackTable.validate.selfPosition.value += CFrame.lookAt(selfpos, targetpos).LookVector * math.max((selfpos - targetpos).Magnitude - 14.399, 0)
			end

			if suc and plr then
				if not select(2, whitelist:get(plr)) then return end
			end

			return self:SendToServer(attackTable, ...)
		end
	end)

	local lastSwingServerTime = 0
	local lastSwingServerTimeDelta = 0

	local OneTapCooldown = {Value = 5}

	local function createRangeCircle()
		local suc, err = pcall(function()
			if (not shared.CheatEngineMode) then
				RangeCirclePart = Instance.new("MeshPart")
				RangeCirclePart.MeshId = "rbxassetid://3726303797"
				if shared.RiseMode and GuiLibrary.GUICoreColor and GuiLibrary.GUICoreColorChanged then
					RangeCirclePart.Color = GuiLibrary.GUICoreColor
					GuiLibrary.GUICoreColorChanged.Event:Connect(function()
						RangeCirclePart.Color = GuiLibrary.GUICoreColor
					end)
				else
					RangeCirclePart.Color = Color3.fromHSV(BoxColor["Hue"], BoxColor["Sat"], BoxColor.Value)
				end
				RangeCirclePart.CanCollide = false
				RangeCirclePart.Anchored = true
				RangeCirclePart.Material = Enum.Material.Neon
				RangeCirclePart.Size = Vector3.new(Range.Value * 0.7, 0.01, Range.Value * 0.7)
				if Killaura.Enabled then
					RangeCirclePart.Parent = gameCamera
				end
				RangeCirclePart:SetAttribute("gamecore_GameQueryIgnore", true)
			end
		end)
		if (not suc) then
			pcall(function()
				if RangeCirclePart then
					RangeCirclePart:Destroy()
					RangeCirclePart = nil
				end
				InfoNotification("Killaura - Range Visualiser Circle", "There was an error creating the circle. Disabling...", 2)
			end)
		end
	end

	local function getAttackData()
		if Mouse.Enabled then
			if not inputService:IsMouseButtonPressed(0) then return false end
		end

		local sword = Limit.Enabled and store.localHand or getSword()
		if not sword or not sword.tool then return false end

		local meta = bedwars.ItemTable[sword.tool.Name]
		if Limit.Enabled then
			if store.localHand.Type ~= 'sword' or bedwars.DaoController.chargingMaid then return false end
		end

		if LegitAura.Enabled then
			if (workspace:GetServerTimeNow() - bedwars.SwordController.lastAttack) > 0.1 then return false end
		end

		return sword, meta
	end

	local preserveSwordIcon = false
	local sigridcheck = false

	Killaura = vape.Categories.Blatant:CreateModule({
		Name = 'Killaura',
		Function = function(callback)
			if callback then
				lastSwingServerTime = Workspace:GetServerTimeNow()
                lastSwingServerTimeDelta = 0

				if RangeCircle.Enabled then
					createRangeCircle()
				end
				if inputService.TouchEnabled and not preserveSwordIcon then
					pcall(function()
						lplr.PlayerGui.MobileUI['2'].Visible = Limit.Enabled
					end)
				end

				if Animation.Enabled and not (identifyexecutor and table.find({'Argon', 'Delta'}, ({identifyexecutor()})[1])) then
					local fake = {
						Controllers = {
							ViewmodelController = {
								isVisible = function()
									return not Attacking
								end,
								playAnimation = function(...)
									local args = {...}
									if not Attacking then
										pcall(function()
											bedwars.ViewmodelController:playAnimation(select(2, unpack(args)))
										end)
									end
								end
							}
						}
					}

					task.spawn(function()
						local started = false
						repeat
							if Attacking then
								if not armC0 then
									armC0 = gameCamera.Viewmodel.RightHand.RightWrist.C0
								end
								local first = not started
								started = true

								if AnimationMode.Value == 'Random' then
									anims.Random = {{CFrame = CFrame.Angles(math.rad(math.random(1, 360)), math.rad(math.random(1, 360)), math.rad(math.random(1, 360))), Time = 0.12}}
								end

								for _, v in anims[AnimationMode.Value] do
									AnimTween = tweenService:Create(gameCamera.Viewmodel.RightHand.RightWrist, TweenInfo.new(first and (AnimationTween.Enabled and 0.001 or 0.1) or v.Time / AnimationSpeed.Value, Enum.EasingStyle.Linear), {
										C0 = armC0 * v.CFrame
									})
									AnimTween:Play()
									AnimTween.Completed:Wait()
									first = false
									if (not Killaura.Enabled) or (not Attacking) then break end
								end
							elseif started then
								started = false
								AnimTween = tweenService:Create(gameCamera.Viewmodel.RightHand.RightWrist, TweenInfo.new(AnimationTween.Enabled and 0.001 or 0.3, Enum.EasingStyle.Exponential), {
									C0 = armC0
								})
								AnimTween:Play()
							end

							if not started then
								task.wait(1 / UpdateRate.Value)
							end
						until (not Killaura.Enabled) or (not Animation.Enabled)
					end)
				end

				repeat
					pcall(function()
						if entitylib.isAlive and entitylib.character.HumanoidRootPart then
							TweenService:Create(RangeCirclePart, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = entitylib.character.HumanoidRootPart.Position - Vector3.new(0, entitylib.character.Humanoid.HipHeight, 0)}):Play()
						end
					end)
					local attacked, sword, meta = {}, getAttackData()
					Attacking = false
					killauraNearPlayer = Attacking
					store.KillauraTarget = nil
					pcall(function() vapeTargetInfo.Targets.Killaura = nil end)
					if sword and meta then
						if sigridcheck and entitylib.isAlive and lplr.Character:FindFirstChild("elk") then return end
						local isClaw = string.find(string.lower(tostring(sword and sword.itemType or "")), "summoner_claw")
						local plrs = entitylib.AllPosition({
							Range = Range.Value,
							Part = 'RootPart',
							Players = Targets.Players.Enabled,
							NPCs = Targets.NPCs.Enabled,
							Limit = MaxTargets.Value,
							Sort = sortmethods[Sort.Value]
						})
						if #plrs < 1 then
							plrs = {EntityNearPosition(Range.Value, Targets.NPCs.Enabled)}
						end
						if #plrs > 0 then
							--switchItem(sword.tool, 0)
							if store.equippedKit == "ember" and shared.EmberAutoKit and sword.itemType == "infernal_saber" then
								bedwars.EmberController:BladeRelease(sword)
							end
							local selfpos = entitylib.character.RootPart.Position
							local localfacing = entitylib.character.RootPart.CFrame.LookVector * Vector3.new(1, 0, 1)

							for _, v in plrs do
								--if not ({whitelist:get(v)})[2] then continue end
								--if workspace:GetServerTimeNow() - bedwars.SwordController.lastAttack < OneTapCooldown.Value/10 then continue end
								pcall(function()
									if type(v) == "table" and v.Character ~= nil and v.Character:HasTag("Crystal") then
										local a, b = getPickaxe()
										if a ~= nil and a.tool ~= nil then
											sword = a
										end
									end
									switchItem(sword.tool, 0)
								end)
								if Targets.Walls.Enabled then
									if not Wallcheck(lplr.Character, v.Character) then continue end
								end
								local delta = (v.RootPart.Position - selfpos)
								local angle = math.acos(localfacing:Dot((delta * Vector3.new(1, 0, 1)).Unit))
								if angle > (math.rad(AngleSlider.Value) / 2) then continue end

								table.insert(attacked, v)
								targetinfo.Targets[v] = tick() + 1
								pcall(function()
									local plr = v
									vapeTargetInfo.Targets.Killaura = {
										Humanoid = {
											Health = (plr.Character:GetAttribute("Health") or plr.Humanoid.Health) + getShieldAttribute(plr.Character),
											MaxHealth = plr.Character:GetAttribute("MaxHealth") or plr.Humanoid.MaxHealth
										},
										Player = plr.Player
									}
								end)
								if not Attacking then
									Attacking = true
									killauraNearPlayer = Attacking
									store.KillauraTarget = v
									if not isClaw then
										if not Swing.Enabled and AnimDelay <= tick() then
											AnimDelay = tick() + (meta.sword.respectAttackSpeedForEffects and meta.sword.attackSpeed or (Sync.Enabled and 0.24 or 0.14))
											bedwars.SwordController:playSwordEffect(meta, 0)
											if meta.displayName:find(' Scythe') then
												bedwars.ScytheController:playLocalAnimation()
											end
	
											if vape.ThreadFix then
												setthreadidentity(8)
											end
										end
									end
								end
								
								local actualRoot = v.Character.PrimaryPart
								if actualRoot then
									local dir = CFrame.lookAt(selfpos, actualRoot.Position).LookVector
									local pos = selfpos + dir * math.max(delta.Magnitude - 14.399, 0)

									bedwars.SwordController.lastAttack = workspace:GetServerTimeNow()
                                    bedwars.SwordController.lastSwingServerTime = workspace:GetServerTimeNow()

									lastSwingServerTimeDelta = workspace:GetServerTimeNow() - lastSwingServerTime
                                    lastSwingServerTime = workspace:GetServerTimeNow()

									store.attackReach = (delta.Magnitude * 100) // 1 / 100
									store.attackReachUpdate = tick() + 1
									if isClaw then
										bedwars.KaidaController:request(v.Character)
									else
										AttackRemote:FireServer({
											weapon = sword.tool,
											chargedAttack = {chargeRatio = 0},
											entityInstance = v.Character,
											validate = {
												raycast = {
													cameraPosition = {value = pos},
													cursorDirection = {value = dir}
												},
												targetPosition = {value = actualRoot.Position},
												selfPosition = {value = pos}
											},
                                            --lastSwingServerTimeDelta = lastSwingServerTimeDelta
										})
									end
								end
							end
						end
					end

					pcall(function()
						for i, v in Boxes do
							v.Adornee = attacked[i] and attacked[i].RootPart or nil
							if v.Adornee then
								v.Color3 = Color3.fromHSV(BoxColor.Hue, BoxColor.Sat, BoxColor.Value)
								v.Transparency = 1 - BoxColor.Opacity
							end
						end
	
						for i, v in Particles do
							v.Position = attacked[i] and attacked[i].RootPart.Position or Vector3.new(9e9, 9e9, 9e9)
							v.Parent = attacked[i] and gameCamera or nil
						end
					end)

					if Face.Enabled and attacked[1] then
						local vec = attacked[1].RootPart.Position * Vector3.new(1, 0, 1)
						entitylib.character.RootPart.CFrame = CFrame.lookAt(entitylib.character.RootPart.Position, Vector3.new(vec.X, entitylib.character.RootPart.Position.Y + 0.001, vec.Z))
					end
					pcall(function() if RangeCirclePart ~= nil then RangeCirclePart.Parent = gameCamera end end)

					--task.wait(#attacked > 0 and #attacked * 0.02 or 1 / UpdateRate.Value)
					task.wait(1 / UpdateRate.Value)
				until not Killaura.Enabled
			else
				store.KillauraTarget = nil
				for _, v in Boxes do
					v.Adornee = nil
				end
				for _, v in Particles do
					v.Parent = nil
				end
				if inputService.TouchEnabled then
					pcall(function()
						lplr.PlayerGui.MobileUI['2'].Visible = true
					end)
				end
				Attacking = false
				killauraNearPlayer = Attacking
				if armC0 then
					AnimTween = tweenService:Create(gameCamera.Viewmodel.RightHand.RightWrist, TweenInfo.new(AnimationTween.Enabled and 0.001 or 0.3, Enum.EasingStyle.Exponential), {
						C0 = armC0
					})
					AnimTween:Play()
				end
				if RangeCirclePart ~= nil then RangeCirclePart:Destroy() end
			end
		end,
		Tooltip = 'Attack players around you\nwithout aiming at them.'
	})

	pcall(function()
		local PSI = Killaura:CreateToggle({
			Name = 'Preserve Sword Icon',
			Function = function(callback)
				preserveSwordIcon = callback
			end,
			Default = true
		})
		PSI.Object.Visible = inputService.TouchEnabled
	end)

	Targets = Killaura:CreateTargets({
		Players = true,
		NPCs = true
	})
	local methods = {'Damage', 'Distance'}
	for i in sortmethods do
		if not table.find(methods, i) then
			table.insert(methods, i)
		end
	end
	Range = Killaura:CreateSlider({
		Name = 'Attack range',
		Min = 1,
		Max = 18,
		Default = 18,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	RangeCircle = Killaura:CreateToggle({
		Name = "Range Visualiser",
		Function = function(call)
			if call then
				createRangeCircle()
			else
				if RangeCirclePart then
					RangeCirclePart:Destroy()
					RangeCirclePart = nil
				end
			end
		end
	})
	AngleSlider = Killaura:CreateSlider({
		Name = 'Max angle',
		Min = 1,
		Max = 360,
		Default = 360
	})
	UpdateRate = Killaura:CreateSlider({
		Name = 'Update rate',
		Min = 1,
		Max = 120,
		Default = 60,
		Suffix = 'hz'
	})
	MaxTargets = Killaura:CreateSlider({
		Name = 'Max targets',
		Min = 1,
		Max = 5,
		Default = 5
	})
	Sort = Killaura:CreateDropdown({
		Name = 'Target Mode',
		List = methods
	})
	Mouse = Killaura:CreateToggle({Name = 'Require mouse down'})
	Swing = Killaura:CreateToggle({Name = 'No Swing'})
	GUI = Killaura:CreateToggle({Name = 'GUI check'})
	Killaura:CreateToggle({
		Name = 'Show target',
		Function = function(callback)
			BoxColor.Object.Visible = callback
			if callback then
				for i = 1, 10 do
					local box = Instance.new('BoxHandleAdornment')
					box.Adornee = nil
					box.AlwaysOnTop = true
					box.Size = Vector3.new(3, 5, 3)
					box.CFrame = CFrame.new(0, -0.5, 0)
					box.ZIndex = 0
					box.Parent = vape.gui
					Boxes[i] = box
				end
			else
				for _, v in Boxes do
					v:Destroy()
				end
				table.clear(Boxes)
			end
		end
	})
	BoxColor = Killaura:CreateColorSlider({
		Name = 'Attack Color',
		Darker = true,
		DefaultOpacity = 0.5,
		Visible = false,
		Function = function(hue, sat, val)
			if Killaura.Enabled and RangeCirclePart ~= nil then
				RangeCirclePart.Color = Color3.fromHSV(hue, sat, val)
			end
		end
	})
	Killaura:CreateToggle({
		Name = 'Target particles',
		Function = function(callback)
			ParticleTexture.Object.Visible = callback
			ParticleColor1.Object.Visible = callback
			ParticleColor2.Object.Visible = callback
			ParticleSize.Object.Visible = callback
			if callback then
				for i = 1, 10 do
					local part = Instance.new('Part')
					part.Size = Vector3.new(2, 4, 2)
					part.Anchored = true
					part.CanCollide = false
					part.Transparency = 1
					part.CanQuery = false
					part.Parent = Killaura.Enabled and gameCamera or nil
					local particles = Instance.new('ParticleEmitter')
					particles.Brightness = 1.5
					particles.Size = NumberSequence.new(ParticleSize.Value)
					particles.Shape = Enum.ParticleEmitterShape.Sphere
					particles.Texture = ParticleTexture.Value
					particles.Transparency = NumberSequence.new(0)
					particles.Lifetime = NumberRange.new(0.4)
					particles.Speed = NumberRange.new(16)
					particles.Rate = 128
					particles.Drag = 16
					particles.ShapePartial = 1
					particles.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHSV(ParticleColor1.Hue, ParticleColor1.Sat, ParticleColor1.Value)),
						ColorSequenceKeypoint.new(1, Color3.fromHSV(ParticleColor2.Hue, ParticleColor2.Sat, ParticleColor2.Value))
					})
					particles.Parent = part
					Particles[i] = part
				end
			else
				for _, v in Particles do
					v:Destroy()
				end
				table.clear(Particles)
			end
		end
	})
	ParticleTexture = Killaura:CreateTextBox({
		Name = 'Texture',
		Default = 'rbxassetid://14736249347',
		Function = function()
			for _, v in Particles do
				v.ParticleEmitter.Texture = ParticleTexture.Value
			end
		end,
		Darker = true,
		Visible = false
	})
	ParticleColor1 = Killaura:CreateColorSlider({
		Name = 'Color Begin',
		Function = function(hue, sat, val)
			for _, v in Particles do
				v.ParticleEmitter.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHSV(hue, sat, val)),
					ColorSequenceKeypoint.new(1, Color3.fromHSV(ParticleColor2.Hue, ParticleColor2.Sat, ParticleColor2.Value))
				})
			end
		end,
		Darker = true,
		Visible = false
	})
	ParticleColor2 = Killaura:CreateColorSlider({
		Name = 'Color End',
		Function = function(hue, sat, val)
			for _, v in Particles do
				v.ParticleEmitter.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHSV(ParticleColor1.Hue, ParticleColor1.Sat, ParticleColor1.Value)),
					ColorSequenceKeypoint.new(1, Color3.fromHSV(hue, sat, val))
				})
			end
		end,
		Darker = true,
		Visible = false
	})
	ParticleSize = Killaura:CreateSlider({
		Name = 'Size',
		Min = 0,
		Max = 1,
		Default = 0.2,
		Decimal = 100,
		Function = function(val)
			for _, v in Particles do
				v.ParticleEmitter.Size = NumberSequence.new(val)
			end
		end,
		Darker = true,
		Visible = false
	})
	Face = Killaura:CreateToggle({Name = 'Face target'})
	Animation = Killaura:CreateToggle({
		Name = 'Custom Animation',
		Function = function(callback)
			AnimationMode.Object.Visible = callback
			AnimationTween.Object.Visible = callback
			AnimationSpeed.Object.Visible = callback
			if Killaura.Enabled then
				Killaura:Toggle()
				Killaura:Toggle()
			end
		end
	})
	local animnames = {}
	for i in anims do
		table.insert(animnames, i)
	end
	AnimationMode = Killaura:CreateDropdown({
		Name = 'Animation Mode',
		List = animnames,
		Darker = true,
		Visible = false
	})
	AnimationSpeed = Killaura:CreateSlider({
		Name = 'Animation Speed',
		Min = 0,
		Max = 2,
		Default = 1,
		Decimal = 10,
		Darker = true,
		Visible = false
	})
	AnimationTween = Killaura:CreateToggle({
		Name = 'No Tween',
		Darker = true,
		Visible = false
	})
	Limit = Killaura:CreateToggle({
		Name = 'Limit to items',
		Function = function(callback)
			if inputService.TouchEnabled and Killaura.Enabled then
				pcall(function()
					lplr.PlayerGui.MobileUI['2'].Visible = callback
				end)
			end
		end,
		Tooltip = 'Only attacks when the sword is held'
	})
	LegitAura = Killaura:CreateToggle({
		Name = 'Swing only',
		Tooltip = 'Only attacks while swinging manually'
	})
	Sync = Killaura:CreateToggle({
		Name = 'Synced Animation',
		Tooltip = 'Plays animation with hit attempt'
	})
	Killaura:CreateToggle({
		Name = "Sigrid Check",
		Default = false,
		Function = function(call)
			sigridcheck = call
		end
	})
end)

local LongJump = {Enabled = false}
run(function()
	local damagetimer = 0
	local damagetimertick = 0
	local directionvec
	local LongJumpSpeed = {Value = 1.5}
	local projectileRemote = bedwars.Client:Get(bedwars.ProjectileRemote)

	local function calculatepos(vec)
		local returned = vec
		if entityLibrary.isAlive then
			local newray = game.Workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, returned, store.blockRaycast)
			if newray then returned = (newray.Position - entityLibrary.character.HumanoidRootPart.Position) end
		end
		return returned
	end

	local damagemethods = {
		--[[fireball = function(fireball, pos)
			if not LongJump.Enabled then return end
			pos = pos - (entityLibrary.character.HumanoidRootPart.CFrame.lookVector * 0.2)
			if not (getPlacedBlock(pos - Vector3.new(0, 3, 0)) or getPlacedBlock(pos - Vector3.new(0, 6, 0))) then
				local sound = Instance.new("Sound")
				sound.SoundId = "rbxassetid://4809574295"
				sound.Parent = game.Workspace
				sound.Ended:Connect(function()
					sound:Destroy()
				end)
				sound:Play()
			end
			local origpos = pos
			local offsetshootpos = (CFrame.new(pos, pos + Vector3.new(0, -60, 0)) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, -bedwars.BowConstantsTable.RelZ))).p
			local ray = game.Workspace:Raycast(pos, Vector3.new(0, -30, 0), store.blockRaycast)
			if ray then
				pos = ray.Position
				offsetshootpos = pos
			end
			task.spawn(function()
				switchItem(fireball.tool)
				bedwars.ProjectileController:createLocalProjectile(bedwars.ProjectileMeta.fireball, "fireball", "fireball", offsetshootpos, "", Vector3.new(0, -60, 0), {drawDurationSeconds = 1})
				projectileRemote:InvokeServer(fireball.tool, "fireball", "fireball", offsetshootpos, pos, Vector3.new(0, -60, 0), game:GetService("HttpService"):GenerateGUID(true), {drawDurationSeconds = 1}, game.Workspace:GetServerTimeNow() - 0.045)
			end)
		end,--]]
		tnt = function(tnt, pos2)
			if not LongJump.Enabled then return end
			local pos = Vector3.new(pos2.X, getScaffold(Vector3.new(0, pos2.Y - (((entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight) - 1.5), 0)).Y, pos2.Z)
			local block = bedwars.placeBlock(pos, "tnt")
		end,
		cannon = function(tnt, pos2)
			task.spawn(function()
				local pos = Vector3.new(pos2.X, getScaffold(Vector3.new(0, pos2.Y - (((entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight) - 1.5), 0)).Y, pos2.Z)
				local block = bedwars.placeBlock(pos, "cannon")
				task.delay(0.1, function()
					local block, pos2 = getPlacedBlock(pos)
					if block and block.Name == "cannon" and (entityLibrary.character.HumanoidRootPart.CFrame.p - block.Position).Magnitude < 20 then
						switchToAndUseTool(block)
						local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
						local damage = bedwars.BlockController:calculateBlockDamage(lplr, {
							blockPosition = pos2,
							block = block
						})
						bedwars.Client:Get(bedwars.CannonAimRemote):FireServer({
							cannonBlockPos = pos2,
							lookVector = vec
						})
						local broken = 0.1
						if damage < block:GetAttribute("Health") then
							task.spawn(function()
								broken = 0.4
								bedwars.breakBlock(block)
							end)
						end
						task.delay(broken, function()
							for i = 1, 3 do
								local call = bedwars.Client:Get(bedwars.CannonLaunchRemote):InvokeServer({cannonBlockPos = bedwars.BlockController:getBlockPosition(block)})
								if call then
									bedwars.breakBlock(block)
									task.delay(0.1, function()
										damagetimer = LongJumpSpeed.Value * 5
										damagetimertick = tick() + 2.5
										directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
									end)
									break
								end
								task.wait(0.1)
							end
						end)
					end
				end)
			end)
		end,
		wood_dao = function(tnt, pos2)
			task.spawn(function()
				switchItem(tnt.tool)
				if not (not lplr.Character:GetAttribute("CanDashNext") or lplr.Character:GetAttribute("CanDashNext") < game.Workspace:GetServerTimeNow()) then
					repeat task.wait() until (not lplr.Character:GetAttribute("CanDashNext") or lplr.Character:GetAttribute("CanDashNext") < game.Workspace:GetServerTimeNow()) or not LongJump.Enabled
				end
				if LongJump.Enabled then
					local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
					replicatedStorage["events-@easy-games/game-core:shared/game-core-networking@getEvents.Events"].useAbility:FireServer("dash", {
						direction = vec,
						origin = entityLibrary.character.HumanoidRootPart.CFrame.p,
						weapon = tnt.itemType
					})
					damagetimer = LongJumpSpeed.Value * 3.5
					damagetimertick = tick() + 2.5
					directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
				end
			end)
		end,
		jade_hammer = function(tnt, pos2)
			task.spawn(function()
				if not bedwars.AbilityController:canUseAbility("jade_hammer_jump") then
					repeat task.wait() until bedwars.AbilityController:canUseAbility("jade_hammer_jump") or not LongJump.Enabled
					task.wait(0.1)
				end
				if bedwars.AbilityController:canUseAbility("jade_hammer_jump") and LongJump.Enabled then
					bedwars.AbilityController:useAbility("jade_hammer_jump")
					local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
					damagetimer = LongJumpSpeed.Value * 2.75
					damagetimertick = tick() + 2.5
					directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
				end
			end)
		end,
		void_axe = function(tnt, pos2)
			task.spawn(function()
				if not bedwars.AbilityController:canUseAbility("void_axe_jump") then
					repeat task.wait() until bedwars.AbilityController:canUseAbility("void_axe_jump") or not LongJump.Enabled
					task.wait(0.1)
				end
				if bedwars.AbilityController:canUseAbility("void_axe_jump") and LongJump.Enabled then
					bedwars.AbilityController:useAbility("void_axe_jump")
					local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
					damagetimer = LongJumpSpeed.Value * 2.75
					damagetimertick = tick() + 2.5
					directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
				end
			end)
		end
	}
	damagemethods.stone_dao = damagemethods.wood_dao
	damagemethods.iron_dao = damagemethods.wood_dao
	damagemethods.diamond_dao = damagemethods.wood_dao
	damagemethods.emerald_dao = damagemethods.wood_dao

	local oldgrav
	local LongJumpacprogressbarframe = Instance.new("Frame")
	LongJumpacprogressbarframe.AnchorPoint = Vector2.new(0.5, 0)
	LongJumpacprogressbarframe.Position = UDim2.new(0.5, 0, 1, -200)
	LongJumpacprogressbarframe.Size = UDim2.new(0.2, 0, 0, 20)
	LongJumpacprogressbarframe.BackgroundTransparency = 0.5
	LongJumpacprogressbarframe.BorderSizePixel = 0
	LongJumpacprogressbarframe.BackgroundColor3 = Color3.fromHSV(vape.GUIColor.Hue, vape.GUIColor.Sat, vape.GUIColor.Value)
	LongJumpacprogressbarframe.Visible = LongJump.Enabled
	LongJumpacprogressbarframe.Parent = vape.gui
	local LongJumpacprogressbarframe2 = LongJumpacprogressbarframe:Clone()
	LongJumpacprogressbarframe2.AnchorPoint = Vector2.new(0, 0)
	LongJumpacprogressbarframe2.Position = UDim2.new(0, 0, 0, 0)
	LongJumpacprogressbarframe2.Size = UDim2.new(1, 0, 0, 20)
	LongJumpacprogressbarframe2.BackgroundTransparency = 0
	LongJumpacprogressbarframe2.Visible = true
	LongJumpacprogressbarframe2.BackgroundColor3 = Color3.fromHSV(vape.GUIColor.Hue, vape.GUIColor.Sat, vape.GUIColor.Value)
	LongJumpacprogressbarframe2.Parent = LongJumpacprogressbarframe
	local LongJumpacprogressbartext = Instance.new("TextLabel")
	LongJumpacprogressbartext.Text = "2.5s"
	LongJumpacprogressbartext.Font = Enum.Font.Gotham
	LongJumpacprogressbartext.TextStrokeTransparency = 0
	LongJumpacprogressbartext.TextColor3 =  Color3.new(0.9, 0.9, 0.9)
	LongJumpacprogressbartext.TextSize = 20
	LongJumpacprogressbartext.Size = UDim2.new(1, 0, 1, 0)
	LongJumpacprogressbartext.BackgroundTransparency = 1
	LongJumpacprogressbartext.Position = UDim2.new(0, 0, -1, 0)
	LongJumpacprogressbartext.Parent = LongJumpacprogressbarframe
	LongJump = vape.Categories.Blatant:CreateModule({
		Name = "LongJump",
		Function = function(callback)
			if callback then
				LongJump:Clean(vapeEvents.EntityDamageEvent.Event:Connect(function(damageTable)
					if damageTable.entityInstance == lplr.Character and (not damageTable.knockbackMultiplier or not damageTable.knockbackMultiplier.disabled) then
						local knockbackBoost = damageTable.knockbackMultiplier and damageTable.knockbackMultiplier.horizontal and damageTable.knockbackMultiplier.horizontal * LongJumpSpeed.Value or LongJumpSpeed.Value
						if damagetimertick < tick() or knockbackBoost >= damagetimer then
							damagetimer = knockbackBoost
							damagetimertick = tick() + 2.5
							local newDirection = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
							directionvec = Vector3.new(newDirection.X, 0, newDirection.Z).Unit
						end
					end
				end))
				task.spawn(function()
					task.spawn(function()
						repeat
							task.wait()
							if LongJumpacprogressbarframe then
								LongJumpacprogressbarframe.BackgroundColor3 = Color3.fromHSV(vape.GUIColor.Hue, vape.GUIColor.Sat, vape.GUIColor.Value)
								LongJumpacprogressbarframe2.BackgroundColor3 = Color3.fromHSV(vape.GUIColor.Hue, vape.GUIColor.Sat, vape.GUIColor.Value)
							end
						until (not LongJump.Enabled)
					end)
					local LongJumpOrigin = entityLibrary.isAlive and entityLibrary.character.HumanoidRootPart.Position
					local tntcheck
					local foundItem = false
					for i,v in pairs(damagemethods) do
						local item = getItem(i)
						if item then
							foundItem = true
							if i == "tnt" then
								local pos = getScaffold(LongJumpOrigin)
								tntcheck = Vector3.new(pos.X, LongJumpOrigin.Y, pos.Z)
								v(item, pos)
							else
								v(item, LongJumpOrigin)
							end
							break
						end
					end
					if not foundItem then
						warningNotification("LongJump", "Unable to find tool to use Long Jump with :c", 3)
						LongJump:Toggle()
						return
					end
					local changecheck
					LongJumpacprogressbarframe.Visible = true
					LongJump:Clean(runservice.Heartbeat:Connect(function(dt)
						if entityLibrary.isAlive then
							if entityLibrary.character.Humanoid.Health <= 0 then
								LongJump:Toggle(false)
								return
							end
							if not LongJumpOrigin then
								LongJumpOrigin = entityLibrary.character.HumanoidRootPart.Position
							end
							local newval = damagetimer ~= 0
							if changecheck ~= newval then
								if newval then
									LongJumpacprogressbarframe2:TweenSize(UDim2.new(0, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 2.5, true)
								else
									LongJumpacprogressbarframe2:TweenSize(UDim2.new(1, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true)
								end
								changecheck = newval
							end
							if newval then
								local newnum = math.max(math.floor((damagetimertick - tick()) * 10) / 10, 0)
								if LongJumpacprogressbartext then
									LongJumpacprogressbartext.Text = newnum.."s"
								end
								if directionvec == nil then
									directionvec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
								end
								local longJumpCFrame = Vector3.new(directionvec.X, 0, directionvec.Z)
								local newvelo = longJumpCFrame.Unit == longJumpCFrame.Unit and longJumpCFrame.Unit * (newnum > 1 and damagetimer or 20) or Vector3.zero
								newvelo = Vector3.new(newvelo.X, 0, newvelo.Z)
								longJumpCFrame = longJumpCFrame * (getSpeed() + 3) * dt
								local ray = game.Workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, longJumpCFrame, store.blockRaycast)
								if ray then
									longJumpCFrame = Vector3.zero
									newvelo = Vector3.zero
								end

								entityLibrary.character.HumanoidRootPart.Velocity = newvelo
								entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + longJumpCFrame
							else
								LongJumpacprogressbartext.Text = "2.5s"
								entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(LongJumpOrigin, LongJumpOrigin + entityLibrary.character.HumanoidRootPart.CFrame.lookVector)
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
								if tntcheck then
									entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(tntcheck + entityLibrary.character.HumanoidRootPart.CFrame.lookVector, tntcheck + (entityLibrary.character.HumanoidRootPart.CFrame.lookVector * 2))
								end
							end
						else
							if LongJumpacprogressbartext then
								LongJumpacprogressbartext.Text = "2.5s"
							end
							LongJumpOrigin = nil
							tntcheck = nil
						end
					end))
				end)
			else
				LongJumpacprogressbarframe.Visible = false
				directionvec = nil
				tntcheck = nil
				LongJumpOrigin = nil
				damagetimer = 0
				damagetimertick = 0
			end
		end,
		Tooltip = "Lets you jump farther (Not landing on same level & Spamming can lead to lagbacks)"
	})
	LongJumpSpeed = LongJump:CreateSlider({
		Name = "Speed",
		Min = 1,
		Max = 52,
		Function = function() end,
		Default = 52
	})
end)

local vapeConnections = {}

local runService = game:GetService("RunService")

local RunLoops = {
    RenderStepTable = {},
    StepTable = {},
    HeartTable = {}
}

local function BindToLoop(tableName, service, name, func)
	local oldfunc = func
	func = function(delta) VoidwareFunctions.handlepcall(pcall(function() oldfunc(delta) end)) end
    if RunLoops[tableName][name] == nil then
        RunLoops[tableName][name] = service:Connect(func)
        table.insert(vapeConnections, RunLoops[tableName][name])
    end
end

local function UnbindFromLoop(tableName, name)
    if RunLoops[tableName][name] then
        RunLoops[tableName][name]:Disconnect()
        RunLoops[tableName][name] = nil
    end
end

function RunLoops:BindToRenderStep(name, func)
    BindToLoop("RenderStepTable", runService.RenderStepped, name, func)
end

function RunLoops:UnbindFromRenderStep(name)
    UnbindFromLoop("RenderStepTable", name)
end

function RunLoops:BindToStepped(name, func)
    BindToLoop("StepTable", runService.Stepped, name, func)
end

function RunLoops:UnbindFromStepped(name)
    UnbindFromLoop("StepTable", name)
end

function RunLoops:BindToHeartbeat(name, func)
    BindToLoop("HeartTable", runService.Heartbeat, name, func)
end

function RunLoops:UnbindFromHeartbeat(name)
    UnbindFromLoop("HeartTable", name)
end

run(function()
    local NoFall = {}
	local MitigationChoice = {Value = "VelocityClamp"}
	local RishThreshold = {Value = 30}
    local PredictiveAnalysis = {}
    local MitigationStrategies = {}
    local velocityHistory = {}
    local maxHistory = 10
	local tracked = 0
    
    local function recordVelocity()
        if not entitylib.isAlive or not entitylib.character or not entitylib.character.RootPart then return end
        local velocity = entitylib.character.RootPart.Velocity
        table.insert(velocityHistory, velocity.Y)
        if #velocityHistory > maxHistory then
            table.remove(velocityHistory, 1)
        end
    end
    
    local function analyzeFallRisk()
        if #velocityHistory < maxHistory then return 0 end
        local downwardTrend = 0
        for i = 2, #velocityHistory do
            if velocityHistory[i] < velocityHistory[i - 1] and velocityHistory[i] < 0 then
                downwardTrend = downwardTrend + (velocityHistory[i - 1] - velocityHistory[i])
            end
        end
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        raycastParams.FilterDescendantsInstances = {lplr.Character}
        local rootPos = entitylib.character.RootPart.Position
        local rayResult = workspace:Raycast(rootPos, Vector3.new(0, -50, 0), raycastParams)
        local distanceToGround = rayResult and (rootPos.Y - rayResult.Position.Y) or math.huge
        local riskFactor = downwardTrend * (distanceToGround > 10 and 1.5 or 1)
        return riskFactor, distanceToGround
    end
    
    local function hasMitigationItem()
        for _, item in pairs(store.localInventory.inventory.items) do
			if item and item.itemType and string.find(string.lower(tostring(item.itemType)), 'wool') then 
				return item
			end
        end
        return nil
    end
    
    MitigationStrategies.VelocityClamp = function(risk)
        if not entitylib.isAlive or not entitylib.character or not entitylib.character.RootPart then return end
        local root = entitylib.character.RootPart
        local currentVelocity = root.Velocity
        if currentVelocity.Y < -50 then
            root.Velocity = Vector3.new(currentVelocity.X, math.clamp(currentVelocity.Y, -50, math.huge), currentVelocity.Z)
        end
    end
    
    MitigationStrategies.TeleportBuffer = function(distance)
        if not entitylib.isAlive or not entitylib.character or not entitylib.character.RootPart then return end
        local root = entitylib.character.RootPart
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        raycastParams.FilterDescendantsInstances = {lplr.Character}
        local rayResult = workspace:Raycast(root.Position, Vector3.new(0, -distance - 2, 0), raycastParams)
        if rayResult and distance > 10 then
            local safePos = rayResult.Position + Vector3.new(0, 3, 0)
            pcall(function()
                root.CFrame = CFrame.new(safePos)
            end)
        end
    end
    
    MitigationStrategies.ItemDeploy = function(item)
        if not item then return end
        local root = entitylib.character.RootPart
        local belowPos = root.Position - Vector3.new(0, 3, 0)
        bedwars.placeBlock(belowPos, item.itemType, true)
    end

	MitigationStrategies.HumanoidState = function()
		if entitylib.isAlive then
			tracked = entitylib.character.Humanoid.FloorMaterial == Enum.Material.Air and math.min(tracked, entitylib.character.RootPart.AssemblyLinearVelocity.Y) or 0
			if tracked < -85 then
				entitylib.character.Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
			end
		end
	end
    
    NoFall = vape.Categories.Utility:CreateModule({
        Name = 'NoFall',
        Function = function(callback)
            if callback then
                RunLoops:BindToHeartbeat('NoFallMonitor', function()
					recordVelocity()
					local risk, distance = analyzeFallRisk()
					if risk > RishThreshold.Value then
						if MitigationChoice.Value ~= "ItemDeploy" then
							MitigationStrategies[MitigationChoice.Value](MitigationChoice.Value == "VelocityClamp" and risk or MitigationChoice.Value == "TeleportBuffer" and distance)
						else
							local mitigationItem = hasMitigationItem()
							if mitigationItem then
								if distance < 10 then
									MitigationStrategies.ItemDeploy(mitigationItem)
								end
							else
								warningNotification("NoFall", "Mitigation Item not found. Using VelocityClamp instead...", 3)
								MitigationStrategies.VelocityClamp(risk)
							end
						end
					end
                end)
            else
                RunLoops:UnbindFromHeartbeat('NoFallMonitor')
                table.clear(velocityHistory)
				tracked = 0
            end
        end,
        Tooltip = 'Prevents fall damage'
    })

	RishThreshold = NoFall:CreateSlider({
		Name = "Risk Threshold",
		Function = function() end,
		Min = 5,
		Max = 100,
		Default = 30
	})

	MitigationChoice = NoFall:CreateDropdown({
		Name = "Mitigation Strategies",
		Default = "HumanoidState",
		List = {"HumanoidState", "VelocityClamp", "TeleportBuffer", "ItemDeploy"},
		Function = function()
			if MitigationChoice.Value == "ItemDeploy" then
				warningNotification("Mitigation Strategies - ItemDeploy", "Not yet finished! Its recommended to use VelocityClamp instead.", 1.5)
			end
		end
	})
end)

local spiderActive = false
local holdingshift = false
run(function()
	local activatePhase = false
	local oldActivatePhase = false
	local PhaseDelay = tick()
	local Phase = {Enabled = false}
	local PhaseStudLimit = {Value = 1}
	local PhaseModifiedParts = {}
	local raycastparameters = RaycastParams.new()
	raycastparameters.RespectCanCollide = true
	raycastparameters.FilterType = Enum.RaycastFilterType.Whitelist
	local overlapparams = OverlapParams.new()
	overlapparams.RespectCanCollide = true

	local function isPointInMapOccupied(p)
		overlapparams.FilterDescendantsInstances = {lplr.Character, gameCamera}
		local possible = game.Workspace:GetPartBoundsInBox(CFrame.new(p), Vector3.new(1, 2, 1), overlapparams)
		return (#possible == 0)
	end

	Phase = vape.Categories.Blatant:CreateModule({
		Name = "Phase",
		Function = function(callback)
			if callback then
				Phase:Clean(runservice.Heartbeat:Connect(function()
					if entityLibrary.isAlive and entityLibrary.character.Humanoid.MoveDirection ~= Vector3.zero and (not vape.Modules.Spider.Enabled or holdingshift) then
						if PhaseDelay <= tick() then
							raycastparameters.FilterDescendantsInstances = {store.blocks, collectionService:GetTagged("spawn-cage")}
							local PhaseRayCheck = game.Workspace:Raycast(entityLibrary.character.Head.CFrame.p, entityLibrary.character.Humanoid.MoveDirection * 1.15, raycastparameters)
							if PhaseRayCheck then
								local PhaseDirection = (PhaseRayCheck.Normal.Z ~= 0 or not PhaseRayCheck.Instance:GetAttribute("GreedyBlock")) and "Z" or "X"
								if PhaseRayCheck.Instance.Size[PhaseDirection] <= PhaseStudLimit.Value * 3 and PhaseRayCheck.Instance.CanCollide and PhaseRayCheck.Normal.Y == 0 then
									local PhaseDestination = entityLibrary.character.HumanoidRootPart.CFrame + (PhaseRayCheck.Normal * (-(PhaseRayCheck.Instance.Size[PhaseDirection]) - (entityLibrary.character.HumanoidRootPart.Size.X / 1.5)))
									if isPointInMapOccupied(PhaseDestination.p) then
										PhaseDelay = tick() + 1
										entityLibrary.character.HumanoidRootPart.CFrame = PhaseDestination
									end
								end
							end
						end
					end
				end))
			end
		end,
		Tooltip = "Lets you Phase/Clip through walls. (Hold shift to use Phase over spider)"
	})
	PhaseStudLimit = Phase:CreateSlider({
		Name = "Blocks",
		Min = 1,
		Max = 3,
		Function = function() end
	})
end)

local Scaffold = {Enabled = false}
run(function()
	local scaffoldtext = Instance.new("TextLabel")
	scaffoldtext.Font = Enum.Font.SourceSans
	scaffoldtext.TextSize = 20
	scaffoldtext.BackgroundTransparency = 1
	scaffoldtext.TextColor3 = Color3.fromRGB(255, 0, 0)
	scaffoldtext.Size = UDim2.new(0, 0, 0, 0)
	scaffoldtext.Position = UDim2.new(0.5, 0, 0.5, 30)
	scaffoldtext.Text = "0"
	scaffoldtext.Visible = false
	scaffoldtext.Parent = vape.gui
	local ScaffoldExpand = {Value = 1}
	local ScaffoldDiagonal = {Enabled = false}
	local ScaffoldTower = {Enabled = false}
	local ScaffoldDownwards = {Enabled = false}
	local ScaffoldStopMotion = {Enabled = false}
	local ScaffoldBlockCount = {Enabled = false}
	local ScaffoldHandCheck = {Enabled = false}
	local ScaffoldMouseCheck = {Enabled = false}
	local ScaffoldAnimation = {Enabled = false}
	local scaffoldstopmotionval = false
	local scaffoldposcheck = tick()
	local scaffoldstopmotionpos = Vector3.zero
	local scaffoldposchecklist = {}
	local AutoSwitch = {Enabled = false}
	task.spawn(function()
		for x = -3, 3, 3 do
			for y = -3, 3, 3 do
				for z = -3, 3, 3 do
					if Vector3.new(x, y, z) ~= Vector3.new(0, 0, 0) then
						table.insert(scaffoldposchecklist, Vector3.new(x, y, z))
					end
				end
			end
		end
	end)

	local function checkblocks(pos)
		for i,v in pairs(scaffoldposchecklist) do
			if getPlacedBlock(pos + v) then
				return true
			end
		end
		return false
	end

	local function closestpos(block, pos)
		local startpos = block.Position - (block.Size / 2) - Vector3.new(1.5, 1.5, 1.5)
		local endpos = block.Position + (block.Size / 2) + Vector3.new(1.5, 1.5, 1.5)
		local speedCFrame = block.Position + (pos - block.Position)
		return Vector3.new(math.clamp(speedCFrame.X, startpos.X, endpos.X), math.clamp(speedCFrame.Y, startpos.Y, endpos.Y), math.clamp(speedCFrame.Z, startpos.Z, endpos.Z))
	end

	local function getclosesttop(newmag, pos)
		local closest, closestmag = pos, newmag * 3
		if entityLibrary.isAlive then
			for i,v in pairs(store.blocks) do
				local close = closestpos(v, pos)
				local mag = (close - pos).magnitude
				if mag <= closestmag then
					closest = close
					closestmag = mag
				end
			end
		end
		return closest
	end

	local WoolOnly = {Enabled = false}

	local oldspeed
	Scaffold = vape.Categories.Blatant:CreateModule({
		Name = "Scaffold",
		Function = function(callback)
			if callback then
				scaffoldtext.Visible = ScaffoldBlockCount.Enabled
				if entityLibrary.isAlive then
					scaffoldstopmotionpos = entityLibrary.character.HumanoidRootPart.CFrame.p
				end
				task.spawn(function()
					repeat
						task.wait()
						if ScaffoldHandCheck.Enabled and not AutoSwitch.Enabled then
							if store.localHand.Type ~= "block" then continue end
						end
						if ScaffoldMouseCheck.Enabled then
							if not inputService:IsMouseButtonPressed(0) then continue end
						end
						if entityLibrary.isAlive then
							local wool, woolamount = getWool()
							if store.localHand.Type == "block" then
								wool = store.localHand.tool.Name
								woolamount = getItem(store.localHand.tool.Name).amount or 0
							elseif (not wool) and (not WoolOnly.Enabled) then
								wool, woolamount = getBlock()
							end

							scaffoldtext.Text = (woolamount and tostring(woolamount) or "0")
							scaffoldtext.TextColor3 = woolamount and (woolamount >= 128 and Color3.fromRGB(9, 255, 198) or woolamount >= 64 and Color3.fromRGB(255, 249, 18)) or Color3.fromRGB(255, 0, 0)
							if not wool then continue end

							if AutoSwitch.Enabled then
								pcall(function() switchItem(wool) end)
							end
							local towering = ScaffoldTower.Enabled and inputService:IsKeyDown(Enum.KeyCode.Space) and game:GetService("UserInputService"):GetFocusedTextBox() == nil
							if towering then
								if (not scaffoldstopmotionval) and ScaffoldStopMotion.Enabled then
									scaffoldstopmotionval = true
									scaffoldstopmotionpos = entityLibrary.character.HumanoidRootPart.CFrame.p
								end
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, 28, entityLibrary.character.HumanoidRootPart.Velocity.Z)
								if ScaffoldStopMotion.Enabled and scaffoldstopmotionval then
									entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(scaffoldstopmotionpos.X, entityLibrary.character.HumanoidRootPart.CFrame.p.Y, scaffoldstopmotionpos.Z))
								end
							else
								scaffoldstopmotionval = false
							end

							for i = 1, ScaffoldExpand.Value do
								local speedCFrame = getScaffold((entityLibrary.character.HumanoidRootPart.Position + ((scaffoldstopmotionval and Vector3.zero or entityLibrary.character.Humanoid.MoveDirection) * (i * 3.5))) + Vector3.new(0, -((entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight + (inputService:IsKeyDown(Enum.KeyCode.LeftShift) and ScaffoldDownwards.Enabled and 4.5 or 1.5))), 0)
								speedCFrame = Vector3.new(speedCFrame.X, speedCFrame.Y - (towering and 4 or 0), speedCFrame.Z)
								if speedCFrame ~= oldpos then
									if not checkblocks(speedCFrame) then
										local oldspeedCFrame = speedCFrame
										speedCFrame = getScaffold(getclosesttop(20, speedCFrame))
										if getPlacedBlock(speedCFrame) then speedCFrame = oldspeedCFrame end
									end
									if ScaffoldAnimation.Enabled then
										if not getPlacedBlock(speedCFrame) then
										bedwars.ViewmodelController:playAnimation(bedwars.AnimationType.FP_USE_ITEM)
										end
									end
									task.spawn(bedwars.placeBlock, speedCFrame, wool, ScaffoldAnimation.Enabled)
									if ScaffoldExpand.Value > 1 then
										task.wait(0.01)
									end
									oldpos = speedCFrame
								end
							end
						end
					until (not Scaffold.Enabled)
				end)
			else
				scaffoldtext.Visible = false
				oldpos = Vector3.zero
				oldpos2 = Vector3.zero
			end
		end,
		Tooltip = "Helps you make bridges/scaffold walk."
	})
	ScaffoldExpand = Scaffold:CreateSlider({
		Name = "Expand",
		Min = 1,
		Max = 8,
		Function = function(val) end,
		Default = 1,
		Tooltip = "Build range"
	})
	ScaffoldDiagonal = Scaffold:CreateToggle({
		Name = "Diagonal",
		Function = function() end,
		Default = true
	})
	ScaffoldTower = Scaffold:CreateToggle({
		Name = "Tower",
		Function = function() end
	})
	WoolOnly = Scaffold:CreateToggle({
		Name = "Wool Only",
		Function = function() end,
		Tooltip = "Only places blocks if they are wool."
	})
	AutoSwitch = Scaffold:CreateToggle({
		Name = "Auto Switch",
		Function = function() end
	})
	ScaffoldMouseCheck = Scaffold:CreateToggle({
		Name = "Require mouse down",
		Function = function() end,
		Tooltip = "Only places when left click is held.",
	})
	ScaffoldDownwards  = Scaffold:CreateToggle({
		Name = "Downwards",
		Function = function() end,
		Tooltip = "Goes down when left shift is held."
	})
	ScaffoldStopMotion = Scaffold:CreateToggle({
		Name = "Stop Motion",
		Function = function() end,
		Tooltip = "Stops your movement when going up"
	})
	ScaffoldStopMotion.Object.BackgroundTransparency = 0
	ScaffoldStopMotion.Object.BorderSizePixel = 0
	ScaffoldStopMotion.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	ScaffoldStopMotion.Object.Visible = ScaffoldTower.Enabled
	ScaffoldBlockCount = Scaffold:CreateToggle({
		Name = "Block Count",
		Function = function(callback)
			if Scaffold.Enabled then
				scaffoldtext.Visible = callback
			end
		end,
		Tooltip = "Shows the amount of blocks in the middle."
	})
	ScaffoldHandCheck = Scaffold:CreateToggle({
		Name = "Hand Check",
		Function = function() end,
		Tooltip = "Only builds with blocks in your hand.",
		Default = false
	})
	ScaffoldAnimation = Scaffold:CreateToggle({
		Name = "Animation",
		Function = function() end
	})
end)

local antivoidvelo
run(function()
	local Speed = {Enabled = false}
	local SpeedMode = {Value = "CFrame"}
	local SpeedValue = {Value = 1}
	local SpeedValueLarge = {Value = 1}
	local SpeedJump = {Enabled = false}
	local SpeedJumpHeight = {Value = 20}
	local SpeedJumpAlways = {Enabled = false}
	local SpeedJumpSound = {Enabled = false}
	local SpeedJumpVanilla = {Enabled = false}
	local SpeedAnimation = {Enabled = false}
	local SpeedDamageBoost = {Enabled = false}
	local raycastparameters = RaycastParams.new()
	local damagetick = tick()

	local alternatelist = {"Normal", "AntiCheat A", "AntiCheat B"}
	Speed = vape.Categories.Blatant:CreateModule({
		Name = "Speed",
		Function = function(callback)
			if callback then
				if SpeedValue.Value == 23.3 then SpeedValue.Value = 21 end
				shared.SpeedBoostEnabled = SpeedDamageBoost.Enabled
				Speed:Clean(vapeEvents.EntityDamageEvent.Event:Connect(function(damageTable)
					if damageTable.entityInstance == lplr.Character and (damageTable.damageType ~= 0 or damageTable.extra and damageTable.extra.chargeRatio ~= nil) and (not (damageTable.knockbackMultiplier and damageTable.knockbackMultiplier.disabled or damageTable.knockbackMultiplier and damageTable.knockbackMultiplier.horizontal == 0)) and SpeedDamageBoost.Enabled then 
						damagetick = tick() + 0.4
						lastdamagetick = tick() + 0.4
					end
				end))
				Speed:Clean(runservice.Heartbeat:Connect(function(delta)
					if entityLibrary.isAlive then
						if not (isnetworkowner(entityLibrary.character.HumanoidRootPart) and entityLibrary.character.Humanoid:GetState() ~= Enum.HumanoidStateType.Climbing and (not spiderActive) and (not vape.Modules.InfiniteFly.Enabled) and (not vape.Modules.Fly.Enabled)) then return end
						if vape.Modules.GrappleExploitOptionsButton and vape.Modules.GrappleExploit.Enabled then return end
						if LongJump.Enabled then return end
						if SpeedAnimation.Enabled then
							for i, v in pairs(entityLibrary.character.Humanoid:GetPlayingAnimationTracks()) do
								if v.Name == "WalkAnim" or v.Name == "RunAnim" then
									v:AdjustSpeed(entityLibrary.character.Humanoid.WalkSpeed / 16)
								end
							end
						end

						local speedValue = damagetick > tick() and SpeedValue.Value * 2.25 - 1 or SpeedValue.Value + getSpeed()
						local speedVelocity = entityLibrary.character.Humanoid.MoveDirection * (SpeedMode.Value == "Normal" and SpeedValue.Value or 20)
						entityLibrary.character.HumanoidRootPart.Velocity = antivoidvelo or Vector3.new(speedVelocity.X, entityLibrary.character.HumanoidRootPart.Velocity.Y, speedVelocity.Z)
						if SpeedMode.Value ~= "Normal" then
							local speedCFrame = entityLibrary.character.Humanoid.MoveDirection * (speedValue - 20) * delta
							raycastparameters.FilterDescendantsInstances = {lplr.Character}
							local ray = game.Workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, speedCFrame, raycastparameters)
							if ray then speedCFrame = (ray.Position - entityLibrary.character.HumanoidRootPart.Position) end
							entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + speedCFrame
						end

						if SpeedJump.Enabled and (not Scaffold.Enabled) and (SpeedJumpAlways.Enabled or killauraNearPlayer) then
							if (entityLibrary.character.Humanoid.FloorMaterial ~= Enum.Material.Air) and entityLibrary.character.Humanoid.MoveDirection ~= Vector3.zero then
								if SpeedJumpSound.Enabled then
									pcall(function() entityLibrary.character.HumanoidRootPart.Jumping:Play() end)
								end
								if SpeedJumpVanilla.Enabled then
									entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
								else
									entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, SpeedJumpHeight.Value, entityLibrary.character.HumanoidRootPart.Velocity.Z)
								end
							end
						end
					end
				end))
			end
		end,
		Tooltip = "Increases your movement.",
		ExtraText = function()
			return "Heatseeker"
		end
	})
	Speed.Restart = function()
		if Speed.Enabled then Speed:Toggle(false); Speed:Toggle(false) end
	end
	--[[SpeedDamageBoost = Speed:CreateToggle({
		Name = "Damage Boost",
		Function = Speed.Restart,
		Default = false
	})--]]
	SpeedValue = Speed:CreateSlider({
		Name = "Speed",
		Min = 1,
		Max = 23,
		Function = function(val) end,
		Default = 21
	})
	SpeedValueLarge = Speed:CreateSlider({
		Name = "Big Mode Speed",
		Min = 1,
		Max = 23,
		Function = function(val) end,
		Default = 23
	})
	SpeedJump = Speed:CreateToggle({
		Name = "AutoJump",
		Function = function(callback)
			if SpeedJumpHeight.Object then SpeedJumpHeight.Object.Visible = callback end
			if SpeedJumpAlways.Object then
				SpeedJumpAlways.Object.Visible = callback
			end
			if SpeedJumpSound.Object then SpeedJumpSound.Object.Visible = callback end
			if SpeedJumpVanilla.Object then SpeedJumpVanilla.Object.Visible = callback end
		end,
		Default = true
	})
	SpeedJumpHeight = Speed:CreateSlider({
		Name = "Jump Height",
		Min = 0,
		Max = 30,
		Default = 25,
		Function = function() end
	})
	SpeedJumpAlways = Speed:CreateToggle({
		Name = "Always Jump",
		Function = function() end
	})
	SpeedJumpSound = Speed:CreateToggle({
		Name = "Jump Sound",
		Function = function() end
	})
	SpeedJumpVanilla = Speed:CreateToggle({
		Name = "Real Jump",
		Function = function() end
	})
	SpeedAnimation = Speed:CreateToggle({
		Name = "Slowdown Anim",
		Function = function() end
	})
end)

run(function()
	local function roundpos(dir, pos, size)
		local suc, res = pcall(function() return Vector3.new(math.clamp(dir.X, pos.X - (size.X / 2), pos.X + (size.X / 2)), math.clamp(dir.Y, pos.Y - (size.Y / 2), pos.Y + (size.Y / 2)), math.clamp(dir.Z, pos.Z - (size.Z / 2), pos.Z + (size.Z / 2))) end)
		return suc and res or Vector3.zero
	end

	local function getPlacedBlock(pos, strict)
		if (not pos) then warn(debug.traceback("[getPlacedBlock]: pos is nil!")) return nil end
		local regionSize = Vector3.new(1, 1, 1)
		local region = Region3.new(pos - regionSize / 2, pos + regionSize / 2)
		local parts = game.Workspace:FindPartsInRegion3(region, nil, math.huge)
		local res 
		for _, part in pairs(parts) do
			if part and part.ClassName and part.ClassName == "Part" and part.Parent then
				if strict then
					if part.Parent.Name == 'Blocks' and part.Parent.ClassName == "Folder" then res = part end
				else
					res = part 
				end
			end
			break
		end
		return res
	end

	local Spider = {Enabled = false}
	local SpiderSpeed = {Value = 0}
	local SpiderMode = {Value = "Normal"}
	local SpiderPart
	Spider = vape.Categories.Blatant:CreateModule({
		Name = "Spider",
		Function = function(callback)
			if callback then
				Spider:Clean(inputService.InputBegan:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.LeftShift then
						holdingshift = true
					end
				end))
				Spider:Clean(inputService.InputEnded:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.LeftShift then
						holdingshift = false
					end
				end))
				Spider:Clean(runservice.Heartbeat:Connect(function()
					if entityLibrary.isAlive and (vape.Modules.Phase.Enabled == false or holdingshift == false) then
						if SpiderMode.Value == "Normal" then
							local vec = entityLibrary.character.Humanoid.MoveDirection * 2
							local newray = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + (vec + Vector3.new(0, 0.1, 0)), true)
							local newray2 = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + (vec - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight, 0)), true)
							if newray and (not newray.CanCollide) then newray = nil end
							if newray2 and (not newray2.CanCollide) then newray2 = nil end
							if spiderActive and (not newray) and (not newray2) then
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, 0, entityLibrary.character.HumanoidRootPart.Velocity.Z)
							end
							spiderActive = ((newray or newray2) and true or false)
							if (newray or newray2) then
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(newray2 and newray == nil and entityLibrary.character.HumanoidRootPart.Velocity.X or 0, SpiderSpeed.Value, newray2 and newray == nil and entityLibrary.character.HumanoidRootPart.Velocity.Z or 0)
							end
						else
							if not SpiderPart then
								SpiderPart = Instance.new("TrussPart", gameCamera)
								if (not SpiderPart) then return end
								SpiderPart.Size = Vector3.new(2, 2, 2)
								SpiderPart.Transparency = 1
								SpiderPart.Anchored = true
								SpiderPart.Parent = gameCamera
							end
							local newray2, newray2pos = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + ((entityLibrary.character.HumanoidRootPart.CFrame.lookVector * 1.5) - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight, 0)), true)
							if newray2 and (not newray2.CanCollide) then newray2 = nil end
							spiderActive = (newray2 and true or false)
							if newray2 then
								newray2pos = newray2pos * 3
								local newpos = roundpos(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(newray2pos.X, math.min(entityLibrary.character.HumanoidRootPart.Position.Y, newray2pos.Y), newray2pos.Z), Vector3.new(1.1, 1.1, 1.1))
								SpiderPart.Position = newpos
							else
								SpiderPart.Position = Vector3.zero
							end
						end
					end
				end))
			else
				if SpiderPart then SpiderPart:Destroy() end
				holdingshift = false
			end
		end,
		Tooltip = "Lets you climb up walls"
	})
	SpiderMode = Spider:CreateDropdown({
		Name = "Mode",
		List = {"Normal", "Classic"},
		Function = function()
			if SpiderPart then SpiderPart:Destroy() end
		end
	})
	SpiderSpeed = Spider:CreateSlider({
		Name = "Speed",
		Min = 0,
		Max = 40,
		Function = function() end,
		Default = 40
	})
end)

run(function()
	local BedESP = {Enabled = false}
	local BedESPFolder = Instance.new("Folder")
	BedESPFolder.Name = "BedESPFolder"
	BedESPFolder.Parent = vape.gui
	local BedESPTable = {}
	local BedESPColor = {Value = 0.44}
	local BedESPTransparency = {Value = 1}
	local BedESPOnTop = {Enabled = true}
	BedESP = vape.Categories.Render:CreateModule({
		Name = "BedESP",
		Function = function(callback)
			if callback then
				BedESP:Clean(collectionService:GetInstanceAddedSignal("bed"):Connect(function(bed)
					task.wait(0.2)
					if not BedESP.Enabled then return end
					local BedFolder = Instance.new("Folder")
					BedFolder.Parent = BedESPFolder
					BedESPTable[bed] = BedFolder
					for bedespnumber, bedesppart in pairs(bed:GetChildren()) do
						if bedesppart.Name ~= 'Bed' then continue end
						local boxhandle = Instance.new("BoxHandleAdornment")
						boxhandle.Size = bedesppart.Size + Vector3.new(.01, .01, .01)
						boxhandle.AlwaysOnTop = true
						boxhandle.ZIndex = (bedesppart.Name == "Covers" and 10 or 0)
						boxhandle.Visible = true
						boxhandle.Adornee = bedesppart
						boxhandle.Color3 = bedesppart.Color
						boxhandle.Name = bedespnumber
						boxhandle.Parent = BedFolder
					end
				end))
				BedESP:Clean(collectionService:GetInstanceRemovedSignal("bed"):Connect(function(bed)
					if BedESPTable[bed] then
						BedESPTable[bed]:Destroy()
						BedESPTable[bed] = nil
					end
				end))
				for i, bed in pairs(collectionService:GetTagged("bed")) do
					local BedFolder = Instance.new("Folder")
					BedFolder.Parent = BedESPFolder
					BedESPTable[bed] = BedFolder
					for bedespnumber, bedesppart in pairs(bed:GetChildren()) do
						if bedesppart:IsA("BasePart") then
							local boxhandle = Instance.new("BoxHandleAdornment")
							boxhandle.Size = bedesppart.Size + Vector3.new(.01, .01, .01)
							boxhandle.AlwaysOnTop = true
							boxhandle.ZIndex = (bedesppart.Name == "Covers" and 10 or 0)
							boxhandle.Visible = true
							boxhandle.Adornee = bedesppart
							boxhandle.Color3 = bedesppart.Color
							boxhandle.Parent = BedFolder
						end
					end
				end
			else
				BedESPFolder:ClearAllChildren()
				table.clear(BedESPTable)
			end
		end,
		Tooltip = "Render Beds through walls"
	})
end)

run(function()
	local function getallblocks2(pos, normal)
		local blocks = {}
		local lastfound = nil
		for i = 1, 20 do
			local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
			local extrablock = getPlacedBlock(blockpos)
			local covered = true
			if extrablock and extrablock.Parent ~= nil then
				if bedwars.BlockController:isBlockBreakable({blockPosition = blockpos}, lplr) then
					table.insert(blocks, extrablock:GetAttribute("NoBreak") and "unbreakable" or extrablock.Name)
				else
					table.insert(blocks, "unbreakable")
					break
				end
				lastfound = extrablock
				if covered == false then
					break
				end
			else
				break
			end
		end
		return blocks
	end

	local function getallbedblocks(pos)
		local blocks = {}
		for i,v in pairs(cachedNormalSides) do
			for i2,v2 in pairs(getallblocks2(pos, v)) do
				if table.find(blocks, v2) == nil and v2 ~= "bed" then
					table.insert(blocks, v2)
				end
			end
			for i2,v2 in pairs(getallblocks2(pos + Vector3.new(0, 0, 3), v)) do
				if table.find(blocks, v2) == nil and v2 ~= "bed" then
					table.insert(blocks, v2)
				end
			end
		end
		return blocks
	end

	local function refreshAdornee(v)
		local bedblocks = getallbedblocks(v.Adornee.Position)
		for i2,v2 in pairs(v.Frame:GetChildren()) do
			if v2:IsA("ImageLabel") then
				v2:Remove()
			end
		end
		for i3,v3 in pairs(bedblocks) do
			local blockimage = Instance.new("ImageLabel")
			blockimage.Size = UDim2.new(0, 32, 0, 32)
			blockimage.BackgroundTransparency = 1
			blockimage.Image = bedwars.getIcon({itemType = v3}, true)
			blockimage.Parent = v.Frame
		end
	end

	local BedPlatesFolder = Instance.new("Folder")
	BedPlatesFolder.Name = "BedPlatesFolder"
	BedPlatesFolder.Parent = vape.gui
	local BedPlatesTable = {}
	local BedPlates = {Enabled = false}

	local function addBed(v)
		local billboard = Instance.new("BillboardGui")
		billboard.Parent = BedPlatesFolder
		billboard.Name = "bed"
		billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 1.5)
		billboard.Size = UDim2.new(0, 42, 0, 42)
		billboard.AlwaysOnTop = true
		billboard.Adornee = v
		BedPlatesTable[v] = billboard
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 1, 0)
		frame.BackgroundColor3 = Color3.new(0, 0, 0)
		frame.BackgroundTransparency = 0.5
		frame.Parent = billboard
		local uilistlayout = Instance.new("UIListLayout")
		uilistlayout.FillDirection = Enum.FillDirection.Horizontal
		uilistlayout.Padding = UDim.new(0, 4)
		uilistlayout.VerticalAlignment = Enum.VerticalAlignment.Center
		uilistlayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uilistlayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			billboard.Size = UDim2.new(0, math.max(uilistlayout.AbsoluteContentSize.X + 12, 42), 0, 42)
		end)
		uilistlayout.Parent = frame
		local uicorner = Instance.new("UICorner")
		uicorner.CornerRadius = UDim.new(0, 4)
		uicorner.Parent = frame
		refreshAdornee(billboard)
	end

	BedPlates = vape.Categories.Render:CreateModule({
		Name = "BedPlates",
		Function = function(callback)
			if callback then
				BedPlates:Clean(vapeEvents.PlaceBlockEvent.Event:Connect(function(p5)
					for i, v in pairs(BedPlatesFolder:GetChildren()) do
						if v.Adornee then
							if ((p5.blockRef.blockPosition * 3) - v.Adornee.Position).magnitude <= 20 then
								refreshAdornee(v)
							end
						end
					end
				end))
				BedPlates:Clean(vapeEvents.BreakBlockEvent.Event:Connect(function(p5)
					for i, v in pairs(BedPlatesFolder:GetChildren()) do
						if v.Adornee then
							if ((p5.blockRef.blockPosition * 3) - v.Adornee.Position).magnitude <= 20 then
								refreshAdornee(v)
							end
						end
					end
				end))
				BedPlates:Clean(collectionService:GetInstanceAddedSignal("bed"):Connect(function(v)
					addBed(v)
				end))
				BedPlates:Clean(collectionService:GetInstanceRemovedSignal("bed"):Connect(function(v)
					if BedPlatesTable[v] then
						BedPlatesTable[v]:Destroy()
						BedPlatesTable[v] = nil
					end
				end))
				task.spawn(function()
					repeat 
						for i, v in pairs(collectionService:GetTagged("bed")) do
							addBed(v)
						end
						task.wait(5)
						BedPlatesFolder:ClearAllChildren()
					until not BedPlates.Enabled
				end)
			else
				BedPlatesFolder:ClearAllChildren()
			end
		end
	})
end)

run(function()
	local ChestESPList = {ObjectList = {}, RefreshList = function() end}
	local function nearchestitem(item)
		for i,v in next, (ChestESPList.ObjectList) do 
			if item:find(v) then return v end
		end
	end
	local function refreshAdornee(v)
		local chest = v.Adornee.ChestFolderValue.Value
		local chestitems = chest and chest:GetChildren() or {}
		for i2,v2 in next, (v.Frame:GetChildren()) do
			if v2:IsA('ImageLabel') then
				v2:Remove()
			end
		end
		v.Enabled = false
		local alreadygot = {}
		for itemNumber, item in next, (chestitems) do
			if alreadygot[item.Name] == nil and (table.find(ChestESPList.ObjectList, item.Name) or nearchestitem(item.Name)) then 
				alreadygot[item.Name] = true
				v.Enabled = true
				local blockimage = Instance.new('ImageLabel')
				blockimage.Size = UDim2.new(0, 32, 0, 32)
				blockimage.BackgroundTransparency = 1
				blockimage.Image = bedwars.getIcon({itemType = item.Name}, true)
				blockimage.Parent = v.Frame
			end
		end
	end

	local ChestESPFolder = Instance.new('Folder')
	ChestESPFolder.Name = 'ChestESPFolder'
	ChestESPFolder.Parent = vape.gui
	local ChestESP = {}
	local ChestESPBackground = {}

	local function chestfunc(v)
		task.spawn(function()
			local billboard = Instance.new('BillboardGui')
			billboard.Parent = ChestESPFolder
			billboard.Name = 'chest'
			billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
			billboard.Size = UDim2.new(0, 42, 0, 42)
			billboard.AlwaysOnTop = true
			billboard.Adornee = v
			local frame = Instance.new('Frame')
			frame.Size = UDim2.new(1, 0, 1, 0)
			frame.BackgroundColor3 = Color3.new(0, 0, 0)
			frame.BackgroundTransparency = ChestESPBackground.Enabled and 0.5 or 1
			frame.Parent = billboard
			local uilistlayout = Instance.new('UIListLayout')
			uilistlayout.FillDirection = Enum.FillDirection.Horizontal
			uilistlayout.Padding = UDim.new(0, 4)
			uilistlayout.VerticalAlignment = Enum.VerticalAlignment.Center
			uilistlayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			uilistlayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
				billboard.Size = UDim2.new(0, math.max(uilistlayout.AbsoluteContentSize.X + 12, 42), 0, 42)
			end)
			uilistlayout.Parent = frame
			local uicorner = Instance.new('UICorner')
			uicorner.CornerRadius = UDim.new(0, 4)
			uicorner.Parent = frame
			local chest = v:WaitForChild('ChestFolderValue').Value
			if chest then 
				ChestESP:Clean(chest.ChildAdded:Connect(function(item)
					if table.find(ChestESPList.ObjectList, item.Name) or nearchestitem(item.Name) then 
						refreshAdornee(billboard)
					end
				end))
				ChestESP:Clean(chest.ChildRemoved:Connect(function(item)
					if table.find(ChestESPList.ObjectList, item.Name) or nearchestitem(item.Name) then 
						refreshAdornee(billboard)
					end
				end))
				refreshAdornee(billboard)
			end
		end)
	end

	ChestESP = vape.Categories.Render:CreateModule({
		Name = 'ChestESP',
		Function = function(calling)
			if calling then
				task.spawn(function()
					ChestESP:Clean(collectionService:GetInstanceAddedSignal('chest'):Connect(chestfunc))
					for i,v in next, (collectionService:GetTagged('chest')) do chestfunc(v) end
				end)
			else
				ChestESPFolder:ClearAllChildren()
			end
		end
	})
	ChestESPList = ChestESP:CreateTextList({
		Name = 'ItemList',
		TempText = 'item or part of item',
		AddFunction = function()
			if ChestESP.Enabled then 
				ChestESP:Toggle(false)
				ChestESP:Toggle(false)
			end
		end,
		RemoveFunction = function()
			if ChestESP.Enabled then 
				ChestESP:Toggle(false)
				ChestESP:Toggle(false)
			end
		end
	})
	ChestESPBackground = ChestESP:CreateToggle({
		Name = 'Background',
		Function = function()
			if ChestESP.Enabled then 
				ChestESP:Toggle(false)
				ChestESP:Toggle(false)
			end
		end,
		Default = true
	})
end)

run(function()
	local FieldOfViewValue = {Value = 70}
	local FieldOfView = {Enabled = false}
	FieldOfView = vape.Categories.Render:CreateModule({
		Name = "FOVChanger",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat 
						task.wait() 
						bedwars.SettingsController:setFOV(FieldOfViewValue.Value) 
					until (not FieldOfView.Enabled)
				end)
			end
		end
	})
	FieldOfViewValue = FieldOfView:CreateSlider({
		Name = "FOV",
		Min = 30,
		Max = 120,
		Function = function(val)
			if FieldOfView.Enabled then
				bedwars.SettingsController:setFOV(FieldOfViewValue.Value)
			end
		end
	})
end)

run(function()
	local old
	local old2
	local oldhitpart
	local FPSBoost = {Enabled = false}
	local removetextures = {Enabled = false}
	local removetexturessmooth = {Enabled = false}
	local originaltextures = {}

	local function fpsboosttextures()
		task.spawn(function()
			repeat task.wait() until store.matchState ~= 0
			for i,v in pairs(store.blocks) do
				if v:GetAttribute("PlacedByUserId") == 0 then
					v.Material = FPSBoost.Enabled and removetextures.Enabled and Enum.Material.SmoothPlastic or (v.Name:find("glass") and Enum.Material.SmoothPlastic or Enum.Material.Fabric)
					originaltextures[v] = originaltextures[v] or v.MaterialVariant
					v.MaterialVariant = FPSBoost.Enabled and removetextures.Enabled and "" or originaltextures[v]
					for i2,v2 in pairs(v:GetChildren()) do
						pcall(function()
							v2.Material = FPSBoost.Enabled and removetextures.Enabled and Enum.Material.SmoothPlastic or (v.Name:find("glass") and Enum.Material.SmoothPlastic or Enum.Material.Fabric)
							originaltextures[v2] = originaltextures[v2] or v2.MaterialVariant
							v2.MaterialVariant = FPSBoost.Enabled and removetextures.Enabled and "" or originaltextures[v2]
						end)
					end
				end
			end
		end)
	end

	FPSBoost = vape.Categories.Render:CreateModule({
		Name = "FPSBoost",
		Function = function(callback)
			if callback then
				fpsboosttextures()
			else
				fpsboosttextures()
			end
		end
	})
	removetextures = FPSBoost:CreateToggle({
		Name = "Remove Textures",
		Function = function(callback) if FPSBoost.Enabled then FPSBoost:Toggle(false) FPSBoost:Toggle(false) end end
	})
end)

run(function()
	local transformed = false
	local GameTheme = {Enabled = false}
	local GameThemeMode = {Value = "GameTheme"}

	local themefunctions = {
		Old = function()
			task.spawn(function()
				pcall(function() sethiddenproperty(lightingService, "Technology", "ShadowMap") end)
				lightingService.Ambient = Color3.fromRGB(69, 69, 69)
				lightingService.Brightness = 3
				lightingService.EnvironmentDiffuseScale = 1
				lightingService.EnvironmentSpecularScale = 1
				lightingService.OutdoorAmbient = Color3.fromRGB(69, 69, 69)
				lightingService.Atmosphere.Density = 0.1
				lightingService.Atmosphere.Offset = 0.25
				lightingService.Atmosphere.Color = Color3.fromRGB(198, 198, 198)
				lightingService.Atmosphere.Decay = Color3.fromRGB(104, 112, 124)
				lightingService.Atmosphere.Glare = 0
				lightingService.Atmosphere.Haze = 0
				lightingService.ClockTime = 13
				lightingService.GeographicLatitude = 0
				lightingService.GlobalShadows = false
				lightingService.TimeOfDay = "13:00:00"
				lightingService.Sky.SkyboxBk = "rbxassetid://7018684000"
				lightingService.Sky.SkyboxDn = "rbxassetid://6334928194"
				lightingService.Sky.SkyboxFt = "rbxassetid://7018684000"
				lightingService.Sky.SkyboxLf = "rbxassetid://7018684000"
				lightingService.Sky.SkyboxRt = "rbxassetid://7018684000"
				lightingService.Sky.SkyboxUp = "rbxassetid://7018689553"
			end)
		end,
		Winter = function()
			task.spawn(function()
				for i,v in pairs(lightingService:GetChildren()) do
					if v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("PostEffect") then
						v:Remove()
					end
				end
				local sky = Instance.new("Sky")
				sky.StarCount = 5000
				sky.SkyboxUp = "rbxassetid://8139676647"
				sky.SkyboxLf = "rbxassetid://8139676988"
				sky.SkyboxFt = "rbxassetid://8139677111"
				sky.SkyboxBk = "rbxassetid://8139677359"
				sky.SkyboxDn = "rbxassetid://8139677253"
				sky.SkyboxRt = "rbxassetid://8139676842"
				sky.SunTextureId = "rbxassetid://6196665106"
				sky.SunAngularSize = 11
				sky.MoonTextureId = "rbxassetid://8139665943"
				sky.MoonAngularSize = 30
				sky.Parent = lightingService
				local sunray = Instance.new("SunRaysEffect")
				sunray.Intensity = 0.03
				sunray.Parent = lightingService
				local bloom = Instance.new("BloomEffect")
				bloom.Threshold = 2
				bloom.Intensity = 1
				bloom.Size = 2
				bloom.Parent = lightingService
				local atmosphere = Instance.new("Atmosphere")
				atmosphere.Density = 0.3
				atmosphere.Offset = 0.25
				atmosphere.Color = Color3.fromRGB(198, 198, 198)
				atmosphere.Decay = Color3.fromRGB(104, 112, 124)
				atmosphere.Glare = 0
				atmosphere.Haze = 0
				atmosphere.Parent = lightingService
			end)
			task.spawn(function()
				local snowpart = Instance.new("Part")
				snowpart.Size = Vector3.new(240, 0.5, 240)
				snowpart.Name = "SnowParticle"
				snowpart.Transparency = 1
				snowpart.CanCollide = false
				snowpart.Position = Vector3.new(0, 120, 286)
				snowpart.Anchored = true
				snowpart.Parent = game.Workspace
				local snow = Instance.new("ParticleEmitter")
				snow.RotSpeed = NumberRange.new(300)
				snow.VelocitySpread = 35
				snow.Rate = 28
				snow.Texture = "rbxassetid://8158344433"
				snow.Rotation = NumberRange.new(110)
				snow.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.16939899325371,0),NumberSequenceKeypoint.new(0.23365999758244,0.62841498851776,0.37158501148224),NumberSequenceKeypoint.new(0.56209099292755,0.38797798752785,0.2771390080452),NumberSequenceKeypoint.new(0.90577298402786,0.51912599802017,0),NumberSequenceKeypoint.new(1,1,0)})
				snow.Lifetime = NumberRange.new(8,14)
				snow.Speed = NumberRange.new(8,18)
				snow.EmissionDirection = Enum.NormalId.Bottom
				snow.SpreadAngle = Vector2.new(35,35)
				snow.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0,0),NumberSequenceKeypoint.new(0.039760299026966,1.3114800453186,0.32786899805069),NumberSequenceKeypoint.new(0.7554469704628,0.98360699415207,0.44038599729538),NumberSequenceKeypoint.new(1,0,0)})
				snow.Parent = snowpart
				local windsnow = Instance.new("ParticleEmitter")
				windsnow.Acceleration = Vector3.new(0,0,1)
				windsnow.RotSpeed = NumberRange.new(100)
				windsnow.VelocitySpread = 35
				windsnow.Rate = 28
				windsnow.Texture = "rbxassetid://8158344433"
				windsnow.EmissionDirection = Enum.NormalId.Bottom
				windsnow.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.16939899325371,0),NumberSequenceKeypoint.new(0.23365999758244,0.62841498851776,0.37158501148224),NumberSequenceKeypoint.new(0.56209099292755,0.38797798752785,0.2771390080452),NumberSequenceKeypoint.new(0.90577298402786,0.51912599802017,0),NumberSequenceKeypoint.new(1,1,0)})
				windsnow.Lifetime = NumberRange.new(8,14)
				windsnow.Speed = NumberRange.new(8,18)
				windsnow.Rotation = NumberRange.new(110)
				windsnow.SpreadAngle = Vector2.new(35,35)
				windsnow.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0,0),NumberSequenceKeypoint.new(0.039760299026966,1.3114800453186,0.32786899805069),NumberSequenceKeypoint.new(0.7554469704628,0.98360699415207,0.44038599729538),NumberSequenceKeypoint.new(1,0,0)})
				windsnow.Parent = snowpart
				repeat
					task.wait()
					if entityLibrary.isAlive then
						snowpart.Position = entityLibrary.character.HumanoidRootPart.Position + Vector3.new(0, 100, 0)
					end
				until not vapeInjected
			end)
		end,
		Halloween = function()
			task.spawn(function()
				for i,v in pairs(lightingService:GetChildren()) do
					if v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("PostEffect") then
						v:Remove()
					end
				end
				lightingService.TimeOfDay = "00:00:00"
				pcall(function() game.Workspace.Clouds:Destroy() end)
				local colorcorrection = Instance.new("ColorCorrectionEffect")
				colorcorrection.TintColor = Color3.fromRGB(255, 185, 81)
				colorcorrection.Brightness = 0.05
				colorcorrection.Parent = lightingService
			end)
		end,
		Valentines = function()
			task.spawn(function()
				for i,v in pairs(lightingService:GetChildren()) do
					if v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("PostEffect") then
						v:Remove()
					end
				end
				local sky = Instance.new("Sky")
				sky.SkyboxBk = "rbxassetid://1546230803"
				sky.SkyboxDn = "rbxassetid://1546231143"
				sky.SkyboxFt = "rbxassetid://1546230803"
				sky.SkyboxLf = "rbxassetid://1546230803"
				sky.SkyboxRt = "rbxassetid://1546230803"
				sky.SkyboxUp = "rbxassetid://1546230451"
				sky.Parent = lightingService
				pcall(function() game.Workspace.Clouds:Destroy() end)
				local colorcorrection = Instance.new("ColorCorrectionEffect")
				colorcorrection.TintColor = Color3.fromRGB(255, 199, 220)
				colorcorrection.Brightness = 0.05
				colorcorrection.Parent = lightingService
			end)
		end
	}

	GameTheme = vape.Categories.Render:CreateModule({
		Name = "GameTheme",
		Function = function(callback)
			if callback then
				if not transformed then
					transformed = true
					themefunctions[GameThemeMode.Value]()
				else
					GameTheme:Toggle(false)
				end
			else
				warningNotification("GameTheme", "Disabled Next Game", 10)
			end
		end,
		ExtraText = function()
			return GameThemeMode.Value
		end
	})
	GameThemeMode = GameTheme:CreateDropdown({
		Name = "Theme",
		Function = function() end,
		List = {"Old", "Winter", "Halloween", "Valentines"}
	})
end)

run(function()
	local oldkilleffect
	local KillEffectMode = {Value = "Gravity"}
	local KillEffectList = {Value = "None"}
	local KillEffectName2 = {}
	local killeffects = {
		Gravity = function(p3, p4, p5, p6)
			pcall(function() p5:BreakJoints() end)
			task.spawn(function()
				local partvelo = {}
				for i,v in pairs(p5:GetDescendants()) do
					if v:IsA("BasePart") then
						partvelo[v.Name] = v.Velocity * 3
					end
				end
				p5.Archivable = true
				local clone = p5:Clone()
				clone.Humanoid.Health = 100
				clone.Parent = game.Workspace
				local nametag = clone:FindFirstChild("Nametag", true)
				if nametag then nametag:Destroy() end
				game:GetService("Debris"):AddItem(clone, 30)
				p5:Destroy()
				task.wait(0.01)
				clone.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
				pcall(function() clone:BreakJoints() end)
				task.wait(0.01)
				for i,v in pairs(clone:GetDescendants()) do
					if v:IsA("BasePart") then
						local bodyforce = Instance.new("BodyForce")
						bodyforce.Force = Vector3.new(0, (game.Workspace.Gravity - 10) * v:GetMass(), 0)
						bodyforce.Parent = v
						v.CanCollide = true
						v.Velocity = partvelo[v.Name] or Vector3.zero
					end
				end
			end)
		end,
		Lightning = function(p3, p4, p5, p6)
			pcall(function() p5:BreakJoints() end)
			local startpos = 1125
			local startcf = p5.Character.PrimaryPart.CFrame.p - Vector3.new(0, 8, 0)
			local newpos = Vector3.new((math.random(1, 10) - 5) * 2, startpos, (math.random(1, 10) - 5) * 2)
			for i = startpos - 75, 0, -75 do
				local newpos2 = Vector3.new((math.random(1, 10) - 5) * 2, i, (math.random(1, 10) - 5) * 2)
				if i == 0 then
					newpos2 = Vector3.zero
				end
				local part = Instance.new("Part")
				part.Size = Vector3.new(1.5, 1.5, 77)
				part.Material = Enum.Material.SmoothPlastic
				part.Anchored = true
				part.Material = Enum.Material.Neon
				part.CanCollide = false
				part.CFrame = CFrame.new(startcf + newpos + ((newpos2 - newpos) * 0.5), startcf + newpos2)
				part.Parent = game.Workspace
				local part2 = part:Clone()
				part2.Size = Vector3.new(3, 3, 78)
				part2.Color = Color3.new(0.7, 0.7, 0.7)
				part2.Transparency = 0.7
				part2.Material = Enum.Material.SmoothPlastic
				part2.Parent = game.Workspace
				game:GetService("Debris"):AddItem(part, 0.5)
				game:GetService("Debris"):AddItem(part2, 0.5)
				bedwars.QueryUtil:setQueryIgnored(part, true)
				bedwars.QueryUtil:setQueryIgnored(part2, true)
				if i == 0 then
					local soundpart = Instance.new("Part")
					soundpart.Transparency = 1
					soundpart.Anchored = true
					soundpart.Size = Vector3.zero
					soundpart.Position = startcf
					soundpart.Parent = game.Workspace
					bedwars.QueryUtil:setQueryIgnored(soundpart, true)
					local sound = Instance.new("Sound")
					sound.SoundId = "rbxassetid://6993372814"
					sound.Volume = 2
					sound.Pitch = 0.5 + (math.random(1, 3) / 10)
					sound.Parent = soundpart
					sound:Play()
					sound.Ended:Connect(function()
						soundpart:Destroy()
					end)
				end
				newpos = newpos2
			end
		end
	}
	local KillEffectName = {}
	for i,v in pairs(bedwars.KillEffectMeta) do
		table.insert(KillEffectName, v.name)
		KillEffectName[v.name] = i
	end
	table.sort(KillEffectName, function(a, b) return a:lower() < b:lower() end)
	local KillEffect = {Enabled = false}
	KillEffect = vape.Categories.Render:CreateModule({
		Name = "KillEffect",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat task.wait() until store.matchState ~= 0 or not KillEffect.Enabled
					if KillEffect.Enabled then
						lplr:SetAttribute("KillEffectType", "none")
						if KillEffectMode.Value == "Bedwars" then
							lplr:SetAttribute("KillEffectType", KillEffectName[KillEffectList.Value])
						end
					end
				end)
				oldkilleffect = bedwars.DefaultKillEffect.onKill
				bedwars.DefaultKillEffect.onKill = function(p3, p4, p5, p6)
					killeffects[KillEffectMode.Value](p3, p4, p5, p6)
				end
			else
				bedwars.DefaultKillEffect.onKill = oldkilleffect
			end
		end
	})
	local modes = {"Bedwars"}
	for i,v in pairs(killeffects) do
		table.insert(modes, i)
	end
	KillEffectMode = KillEffect:CreateDropdown({
		Name = "Mode",
		Function = function()
			if KillEffect.Enabled then
				KillEffect:Toggle(false)
				KillEffect:Toggle(false)
			end
		end,
		List = modes
	})
	KillEffectList = KillEffect:CreateDropdown({
		Name = "Bedwars",
		Function = function()
			if KillEffect.Enabled then
				KillEffect:Toggle(false)
				KillEffect:Toggle(false)
			end
		end,
		List = KillEffectName
	})
end)

run(function()
	local KitESP = {Enabled = false}
	local Background
	local Color
	local espobjs = {}
	local espfold = Instance.new("Folder")
	espfold.Parent = vape.gui

	local function espadd(v, icon)
		local billboard = Instance.new("BillboardGui")
		billboard.Parent = espfold
		billboard.Name = icon
		billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
		billboard.Size = UDim2.fromOffset(36, 36)
		billboard.AlwaysOnTop = true
		billboard.Adornee = v
		local image = Instance.new("ImageLabel")
		image.BorderSizePixel = 0
		image.Image = bedwars.getIcon({itemType = icon}, true)
		image.BackgroundColor3 = Color3.fromHSV(Color.Hue, Color.Sat, Color.Value)
		image.BackgroundTransparency = 1 - (Background.Enabled and Color.Opacity or 0)
		image.Size = UDim2.fromOffset(36, 36)
		image.AnchorPoint = Vector2.new(0.5, 0.5)
		image.Parent = billboard
		local uicorner = Instance.new("UICorner")
		uicorner.CornerRadius = UDim.new(0, 4)
		uicorner.Parent = image
		espobjs[v] = billboard
	end

	local function addKit(tag, icon, custom)
		if (not custom) then
			KitESP:Clean(collectionService:GetInstanceAddedSignal(tag):Connect(function(v)
				espadd(v.PrimaryPart, icon)
			end))
			KitESP:Clean(collectionService:GetInstanceRemovedSignal(tag):Connect(function(v)
				if espobjs[v.PrimaryPart] then
					espobjs[v.PrimaryPart]:Destroy()
					espobjs[v.PrimaryPart] = nil
				end
			end))
			for i,v in pairs(collectionService:GetTagged(tag)) do
				espadd(v.PrimaryPart, icon)
			end
		else
			local function check(v)
				if v.Name == tag and v.ClassName == "Model" then
					espadd(v.PrimaryPart, icon)
				end
			end
			KitESP:Clean(game.Workspace.ChildAdded:Connect(check))
			KitESP:Clean(game.Workspace.ChildRemoved:Connect(function(v)
				pcall(function()
					if espobjs[v.PrimaryPart] then
						espobjs[v.PrimaryPart]:Destroy()
						espobjs[v.PrimaryPart] = nil
					end
				end)
			end))
			for i,v in pairs(game.Workspace:GetChildren()) do
				check(v)
			end
		end
	end

	local esptbl = {
		["metal_detector"] = {
			{"hidden-metal", "iron"}
		},
		["beekeeper"] = {
			{"bee", "bee"}
		},
		["bigman"] = {
			{"treeOrb", "natures_essence_1"}
		},
		["alchemist"] = {
			{"Thorns", "thorns", true},
			{"Mushrooms", "mushrooms", true},
			{"Flower", "wild_flower", true}
		},
		["star_collector"] = {
			{"CritStar", "crit_star", true},
			{"VitalityStar", "vitality_star", true}
		},
		["spirit_gardener"] = {
			{"SpiritGardenerEnergy", "spirit", true}
		}
	}

	KitESP = vape.Categories.Render:CreateModule({
		Name = "KitESP",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat task.wait() until store.equippedKit ~= ""
					if KitESP.Enabled then
						local p1 = esptbl[store.equippedKit]
						if (not p1) then return end
						for i,v in pairs(p1) do 
							addKit(unpack(v))
						end
					end
				end)
			else
				espfold:ClearAllChildren()
				table.clear(espobjs)
			end
		end
	})
	
	Background = KitESP:CreateToggle({
		Name = 'Background',
		Function = function(callback)
			if Color and Color.Object then Color.Object.Visible = callback end
			for _, v in espobjs do
				v.ImageLabel.BackgroundTransparency = 1 - (callback and Color.Opacity or 0)
				v.Blur.Visible = callback
			end
		end,
		Default = true
	})
	Color = KitESP:CreateColorSlider({
		Name = 'Background Color',
		DefaultValue = 0,
		DefaultOpacity = 0.5,
		Function = function(hue, sat, val, opacity)
			for _, v in espobjs do
				v.ImageLabel.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
				v.ImageLabel.BackgroundTransparency = 1 - opacity
			end
		end,
		Darker = true
	})
end)

run(function()
	local NameTags
	local Targets
	local Color
	local Background
	local DisplayName
	local Health
	local Distance
	local Equipment
	local DrawingToggle
	local Scale
	local FontOption
	local Teammates
	local DistanceCheck
	local DistanceLimit
	local Strings, Sizes, Reference = {}, {}, {}
	local Folder = Instance.new('Folder')
	Folder.Parent = vape.gui
	local methodused
	local fontitems = {'Arial'}
	local kititems = {
		jade = 'jade_hammer',
		archer = 'tactical_crossbow',
		cowgirl = 'lasso',
		dasher = 'wood_dao',
		axolotl = 'axolotl',
		yeti = 'snowball',
		smoke = 'smoke_block',
		trapper = 'snap_trap',
		pyro = 'flamethrower',
		davey = 'cannon',
		regent = 'void_axe',
		baker = 'apple',
		builder = 'builder_hammer',
		farmer_cletus = 'carrot_seeds',
		melody = 'guitar',
		barbarian = 'rageblade',
		gingerbread_man = 'gumdrop_bounce_pad',
		spirit_catcher = 'spirit',
		fisherman = 'fishing_rod',
		oil_man = 'oil_consumable',
		santa = 'tnt',
		miner = 'miner_pickaxe',
		sheep_herder = 'crook',
		beast = 'speed_potion',
		metal_detector = 'metal_detector',
		cyber = 'drone',
		vesta = 'damage_banner',
		lumen = 'light_sword',
		ember = 'infernal_saber',
		queen_bee = 'bee'
	}
	
	local Added = {
		Normal = function(ent)
			if not Targets.Players.Enabled and ent.Player then return end
			if not Targets.NPCs.Enabled and ent.NPC then return end
			if Teammates.Enabled and (not ent.Targetable) and (not ent.Friend) then return end
			local EntityNameTag = Instance.new('TextLabel')
			EntityNameTag.BackgroundColor3 = Color3.new()
			EntityNameTag.BorderSizePixel = 0
			EntityNameTag.Visible = false
			EntityNameTag.RichText = true
			EntityNameTag.AnchorPoint = Vector2.new(0.5, 1)
			EntityNameTag.Name = ent.Player and ent.Player.Name or ent.Character.Name
			EntityNameTag.FontFace = FontOption.Value
			EntityNameTag.TextSize = 14 * Scale.Value
			EntityNameTag.BackgroundTransparency = Background.Value
			Strings[ent] = ent.Player and whitelist:tag(ent.Player, true, true)..(DisplayName.Enabled and ent.Player.DisplayName or ent.Player.Name) or ent.Character.Name
			if Health.Enabled then
				local healthColor = Color3.fromHSV(math.clamp(ent.Health / ent.MaxHealth, 0, 1) / 2.5, 0.89, 0.75)
				Strings[ent] = Strings[ent]..' <font color="rgb('..tostring(math.floor(healthColor.R * 255))..','..tostring(math.floor(healthColor.G * 255))..','..tostring(math.floor(healthColor.B * 255))..')">'..math.round(ent.Health)..'</font>'
			end
			if Distance.Enabled then
				Strings[ent] = '<font color="rgb(85, 255, 85)">[</font><font color="rgb(255, 255, 255)">%s</font><font color="rgb(85, 255, 85)">]</font> '..Strings[ent]
			end
			if Equipment.Enabled then
				for i, v in {'Hand', 'Helmet', 'Chestplate', 'Boots', 'Kit'} do
					local Icon = Instance.new('ImageLabel')
					Icon.Name = v
					Icon.Size = UDim2.fromOffset(30, 30)
					Icon.Position = UDim2.fromOffset(-60 + (i * 30), -30)
					Icon.BackgroundTransparency = 1
					Icon.Image = ''
					Icon.Parent = EntityNameTag
				end
			end
			local nametagSize = getfontsize(removeTags(Strings[ent]), EntityNameTag.TextSize, EntityNameTag.FontFace, Vector2.new(100000, 100000))
			EntityNameTag.Size = UDim2.fromOffset(nametagSize.X + 8, nametagSize.Y + 7)
			EntityNameTag.Text = Strings[ent]
			EntityNameTag.TextColor3 = entitylib.getEntityColor(ent) or Color3.fromHSV(Color.Hue, Color.Sat, Color.Value)
			EntityNameTag.Parent = Folder
			Reference[ent] = EntityNameTag
		end,
		Drawing = function(ent)
			if not Targets.Players.Enabled and ent.Player then return end
			if not Targets.NPCs.Enabled and ent.NPC then return end
			if Teammates.Enabled and (not ent.Targetable) and (not ent.Friend) then return end
			local EntityNameTag = {}
			EntityNameTag.BG = Drawing.new('Square')
			EntityNameTag.BG.Filled = true
			EntityNameTag.BG.Transparency = 1 - Background.Value
			EntityNameTag.BG.Color = Color3.new()
			EntityNameTag.BG.ZIndex = 1
			EntityNameTag.Text = Drawing.new('Text')
			EntityNameTag.Text.Size = 15 * Scale.Value
			EntityNameTag.Text.Font = (math.clamp((table.find(fontitems, FontOption.Value) or 1) - 1, 0, 3))
			EntityNameTag.Text.ZIndex = 2
			Strings[ent] = ent.Player and whitelist:tag(ent.Player, true)..(DisplayName.Enabled and ent.Player.DisplayName or ent.Player.Name) or ent.Character.Name
			if Health.Enabled then
				Strings[ent] = Strings[ent]..' '..math.round(ent.Health)
			end
			if Distance.Enabled then
				Strings[ent] = '[%s] '..Strings[ent]
			end
			EntityNameTag.Text.Text = Strings[ent]
			EntityNameTag.Text.Color = entitylib.getEntityColor(ent) or Color3.fromHSV(Color.Hue, Color.Sat, Color.Value)
			EntityNameTag.BG.Size = Vector2.new(EntityNameTag.Text.TextBounds.X + 8, EntityNameTag.Text.TextBounds.Y + 7)
			Reference[ent] = EntityNameTag
		end
	}
	
	local Removed = {
		Normal = function(ent)
			local v = Reference[ent]
			if v then
				Reference[ent] = nil
				Strings[ent] = nil
				Sizes[ent] = nil
				v:Destroy()
			end
		end,
		Drawing = function(ent)
			local v = Reference[ent]
			if v then
				Reference[ent] = nil
				Strings[ent] = nil
				Sizes[ent] = nil
				for _, obj in v do
					pcall(function() 
						obj.Visible = false 
						obj:Remove() 
					end)
				end
			end
		end
	}
	
	local Updated = {
		Normal = function(ent)
			local EntityNameTag = Reference[ent]
			if EntityNameTag then
				Sizes[ent] = nil
				Strings[ent] = ent.Player and whitelist:tag(ent.Player, true, true)..(DisplayName.Enabled and ent.Player.DisplayName or ent.Player.Name) or ent.Character.Name
				if Health.Enabled then
					local healthColor = Color3.fromHSV(math.clamp(ent.Health / ent.MaxHealth, 0, 1) / 2.5, 0.89, 0.75)
					Strings[ent] = Strings[ent]..' <font color="rgb('..tostring(math.floor(healthColor.R * 255))..','..tostring(math.floor(healthColor.G * 255))..','..tostring(math.floor(healthColor.B * 255))..')">'..math.round(ent.Health)..'</font>'
				end
				if Distance.Enabled then
					Strings[ent] = '<font color="rgb(85, 255, 85)">[</font><font color="rgb(255, 255, 255)">%s</font><font color="rgb(85, 255, 85)">]</font> '..Strings[ent]
				end
				if Equipment.Enabled and store.inventories[ent.Player] then
					local inventory = store.inventories[ent.Player]
					EntityNameTag.Hand.Image = bedwars.getIcon(inventory.hand or {itemType = ''}, true)
					EntityNameTag.Helmet.Image = bedwars.getIcon(inventory.armor[4] or {itemType = ''}, true)
					EntityNameTag.Chestplate.Image = bedwars.getIcon(inventory.armor[5] or {itemType = ''}, true)
					EntityNameTag.Boots.Image = bedwars.getIcon(inventory.armor[6] or {itemType = ''}, true)
					EntityNameTag.Kit.Image = bedwars.getIcon({itemType = kititems[ent.Player:GetAttribute('PlayingAsKit')] or ''}, true)
				end
				local nametagSize = getfontsize(removeTags(Strings[ent]), EntityNameTag.TextSize, EntityNameTag.FontFace, Vector2.new(100000, 100000))
				EntityNameTag.Size = UDim2.fromOffset(nametagSize.X + 8, nametagSize.Y + 7)
				EntityNameTag.Text = Strings[ent]
			end
		end,
		Drawing = function(ent)
			local EntityNameTag = Reference[ent]
			if EntityNameTag then
				Sizes[ent] = nil
				Strings[ent] = ent.Player and whitelist:tag(ent.Player, true)..(DisplayName.Enabled and ent.Player.DisplayName or ent.Player.Name) or ent.Character.Name
				if Health.Enabled then
					Strings[ent] = Strings[ent]..' '..math.round(ent.Health)
				end
				if Distance.Enabled then
					Strings[ent] = '[%s] '..Strings[ent]
					EntityNameTag.Text.Text = entitylib.isAlive and string.format(Strings[ent], (entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude // 1) or Strings[ent]
				else
					EntityNameTag.Text.Text = Strings[ent]
				end
				EntityNameTag.BG.Size = Vector2.new(EntityNameTag.Text.TextBounds.X + 8, EntityNameTag.Text.TextBounds.Y + 7)
				EntityNameTag.Text.Color = entitylib.getEntityColor(ent) or Color3.fromHSV(Color.Hue, Color.Sat, Color.Value)
			end
		end
	}
	
	local ColorFunc = {
		Normal = function(hue, sat, val)
			local tagColor = Color3.fromHSV(hue, sat, val)
			for i, v in Reference do
				v.TextColor3 = entitylib.getEntityColor(i) or tagColor
			end
		end,
		Drawing = function(hue, sat, val)
			local tagColor = Color3.fromHSV(hue, sat, val)
			for i, v in Reference do
				v.Text.Text.Color = entitylib.getEntityColor(i) or tagColor
			end
		end
	}
	
	local Loop = {
		Normal = function()
			for ent, EntityNameTag in Reference do
				if DistanceCheck.Enabled then
					local distance = entitylib.isAlive and (entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude or math.huge
					if distance < DistanceLimit.ValueMin or distance > DistanceLimit.ValueMax then
						EntityNameTag.Visible = false
						continue
					end
				end
				local headPos, headVis = gameCamera:WorldToViewportPoint(ent.RootPart.Position + Vector3.new(0, ent.HipHeight + 1, 0))
				EntityNameTag.Visible = headVis
				if not headVis then
					continue
				end
				if Distance.Enabled and entitylib.isAlive then
					local mag = (entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude // 1
					if Sizes[ent] ~= mag then
						EntityNameTag.Text = string.format(Strings[ent], mag)
						local nametagSize = getfontsize(removeTags(EntityNameTag.Text), EntityNameTag.TextSize, EntityNameTag.FontFace, Vector2.new(100000, 100000))
						EntityNameTag.Size = UDim2.fromOffset(nametagSize.X + 8, nametagSize.Y + 7)
						Sizes[ent] = mag
					end
				end
				EntityNameTag.Position = UDim2.fromOffset(headPos.X, headPos.Y)
			end
		end,
		Drawing = function()
			for ent, EntityNameTag in Reference do
				if DistanceCheck.Enabled then
					local distance = entitylib.isAlive and (entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude or math.huge
					if distance < DistanceLimit.ValueMin or distance > DistanceLimit.ValueMax then
						EntityNameTag.Text.Visible = false
						EntityNameTag.BG.Visible = false
						continue
					end
				end
				local headPos, headVis = gameCamera:WorldToViewportPoint(ent.RootPart.Position + Vector3.new(0, ent.HipHeight + 1, 0))
				EntityNameTag.Text.Visible = headVis
				EntityNameTag.BG.Visible = headVis and Background.Enabled
				if not headVis then
					continue
				end
				if Distance.Enabled and entitylib.isAlive then
					local mag = (entitylib.character.RootPart.Position - ent.RootPart.Position).Magnitude // 1
					if Sizes[ent] ~= mag then
						EntityNameTag.Text.Text = string.format(Strings[ent], mag)
						EntityNameTag.BG.Size = Vector2.new(EntityNameTag.Text.TextBounds.X + 8, EntityNameTag.Text.TextBounds.Y + 7)
						Sizes[ent] = mag
					end
				end
				EntityNameTag.BG.Position = Vector2.new(headPos.X - (EntityNameTag.BG.Size.X / 2), headPos.Y + (EntityNameTag.BG.Size.Y / 2))
				EntityNameTag.Text.Position = EntityNameTag.BG.Position + Vector2.new(4, 2.5)
			end
		end
	}
	
	NameTags = vape.Categories.Render:CreateModule({
		Name = 'NameTags',
		Function = function(callback)
			if callback then
				methodused = DrawingToggle.Enabled and 'Drawing' or 'Normal'
				if Removed[methodused] then
					NameTags:Clean(entitylib.Events.EntityRemoved:Connect(Removed[methodused]))
				end
				if Added[methodused] then
					for _, v in entitylib.List do
						if Reference[v] then 
							Removed[methodused](v) 
						end
						Added[methodused](v)
					end
					NameTags:Clean(entitylib.Events.EntityAdded:Connect(function(ent)
						if Reference[ent] then 
							Removed[methodused](ent) 
						end
						Added[methodused](ent)
					end))
				end
				if Updated[methodused] then
					NameTags:Clean(entitylib.Events.EntityUpdated:Connect(Updated[methodused]))
					for _, v in entitylib.List do 
						Updated[methodused](v) 
					end
				end
				if ColorFunc[methodused] then
					NameTags:Clean(vape.Categories.Friends.ColorUpdate.Event:Connect(function()
						ColorFunc[methodused](Color.Hue, Color.Sat, Color.Value)
					end))
				end
				if Loop[methodused] then
					NameTags:Clean(runService.RenderStepped:Connect(Loop[methodused]))
				end
			else
				if Removed[methodused] then
					for i in Reference do 
						Removed[methodused](i) 
					end
				end
			end
		end,
		Tooltip = 'Renders nametags on entities through walls.'
	})
	Targets = NameTags:CreateTargets({
		Players = true, 
		Function = function()
		if NameTags.Enabled then
				NameTags:Toggle()
				NameTags:Toggle()
			end
		end
	})
	FontOption = NameTags:CreateFont({
		Name = 'Font',
		Blacklist = 'Arial',
		Function = function() 
			if NameTags.Enabled then 
				NameTags:Toggle() 
				NameTags:Toggle() 
			end 
		end
	})
	Color = NameTags:CreateColorSlider({
		Name = 'Player Color',
		Function = function(hue, sat, val)
			if NameTags.Enabled and ColorFunc[methodused] then
				ColorFunc[methodused](hue, sat, val)
			end
		end
	})
	Scale = NameTags:CreateSlider({
		Name = 'Scale',
		Function = function() 
			if NameTags.Enabled then 
				NameTags:Toggle() 
				NameTags:Toggle() 
			end 
		end,
		Default = 1,
		Min = 0.1,
		Max = 1.5,
		Decimal = 10
	})
	Background = NameTags:CreateSlider({
		Name = 'Transparency',
		Function = function() 
			if NameTags.Enabled then 
				NameTags:Toggle() 
				NameTags:Toggle() 
			end 
		end,
		Default = 0.5,
		Min = 0,
		Max = 1,
		Decimal = 10
	})
	Health = NameTags:CreateToggle({
		Name = 'Health',
		Function = function() 
			if NameTags.Enabled then 
				NameTags:Toggle() 
				NameTags:Toggle() 
			end 
		end
	})
	Distance = NameTags:CreateToggle({
		Name = 'Distance',
		Function = function() 
			if NameTags.Enabled then 
				NameTags:Toggle() 
				NameTags:Toggle() 
			end 
		end
	})
	Equipment = NameTags:CreateToggle({
		Name = 'Equipment',
		Function = function() 
			if NameTags.Enabled then 
				NameTags:Toggle() 
				NameTags:Toggle() 
			end 
		end
	})
	DisplayName = NameTags:CreateToggle({
		Name = 'Use Displayname',
		Function = function() 
			if NameTags.Enabled then 
				NameTags:Toggle() 
				NameTags:Toggle() 
			end 
		end,
		Default = true
	})
	Teammates = NameTags:CreateToggle({
		Name = 'Priority Only',
		Function = function() 
			if NameTags.Enabled then 
				NameTags:Toggle() 
				NameTags:Toggle() 
			end 
		end,
		Default = true
	})
	DrawingToggle = NameTags:CreateToggle({
		Name = 'Drawing',
		Function = function() 
			if NameTags.Enabled then 
				NameTags:Toggle() 
				NameTags:Toggle() 
			end 
		end,
	})
	DistanceCheck = NameTags:CreateToggle({
		Name = 'Distance Check',
		Function = function(callback)
			DistanceLimit.Object.Visible = callback
		end
	})
	DistanceLimit = NameTags:CreateTwoSlider({
		Name = 'Player Distance',
		Min = 0,
		Max = 256,
		DefaultMin = 0,
		DefaultMax = 64,
		Darker = true,
		Visible = false
	})
end)

run(function()
	local nobobdepth = {Value = 8}
	local nobobhorizontal = {Value = 8}
	local nobobvertical = {Value = -2}
	local rotationx = {Value = 0}
	local rotationy = {Value = 0}
	local rotationz = {Value = 0}
	local oldc1
	local oldfunc
	local nobob = vape.Categories.Render:CreateModule({
		Name = "NoBob",
		Function = function(callback)
			local viewmodel = gameCamera:FindFirstChild("Viewmodel")
			if viewmodel then
				if callback then
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_DEPTH_OFFSET", -(nobobdepth.Value / 10))
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_HORIZONTAL_OFFSET", (nobobhorizontal.Value / 10))
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_VERTICAL_OFFSET", (nobobvertical.Value / 10))
					oldc1 = viewmodel.RightHand.RightWrist.C1
					viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
				else
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_DEPTH_OFFSET", 0)
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_HORIZONTAL_OFFSET", 0)
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_VERTICAL_OFFSET", 0)
					viewmodel.RightHand.RightWrist.C1 = oldc1
				end
			end
		end,
		Tooltip = "Removes the ugly bobbing when you move and makes sword farther"
	})
	nobobdepth = nobob:CreateSlider({
		Name = "Depth",
		Min = 0,
		Max = 24,
		Default = 8,
		Function = function(val)
			if nobob.Enabled then
				lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_DEPTH_OFFSET", -(val / 10))
			end
		end
	})
	nobobhorizontal = nobob:CreateSlider({
		Name = "Horizontal",
		Min = 0,
		Max = 24,
		Default = 8,
		Function = function(val)
			if nobob.Enabled then
				lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_HORIZONTAL_OFFSET", (val / 10))
			end
		end
	})
	nobobvertical= nobob:CreateSlider({
		Name = "Vertical",
		Min = 0,
		Max = 24,
		Default = -2,
		Function = function(val)
			if nobob.Enabled then
				lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_VERTICAL_OFFSET", (val / 10))
			end
		end
	})
	rotationx = nobob:CreateSlider({
		Name = "RotX",
		Min = 0,
		Max = 360,
		Function = function(val)
			if nobob.Enabled then
				gameCamera.Viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
			end
		end
	})
	rotationy = nobob:CreateSlider({
		Name = "RotY",
		Min = 0,
		Max = 360,
		Function = function(val)
			if nobob.Enabled then
				gameCamera.Viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
			end
		end
	})
	rotationz = nobob:CreateSlider({
		Name = "RotZ",
		Min = 0,
		Max = 360,
		Function = function(val)
			if nobob.Enabled then
				gameCamera.Viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
			end
		end
	})
end)

run(function()
	local SongBeats = {Enabled = false}
	local SongBeatsList = {ObjectList = {}}
	local SongBeatsIntensity = {Value = 5}
	local SongTween
	local SongAudio

	local function PlaySong(arg)
		local args = arg:split(":")
		local song = isfile(args[1]) and getcustomasset(args[1]) or tonumber(args[1]) and "rbxassetid://"..args[1]
		if not song then
			warningNotification("SongBeats", "missing music file "..args[1], 5)
			SongBeats:Toggle(false)
			return
		end
		local bpm = 1 / (args[2] / 60)
		SongAudio = Instance.new("Sound")
		SongAudio.SoundId = song
		SongAudio.Parent = game.Workspace
		SongAudio:Play()
		repeat
			repeat task.wait() until SongAudio.IsLoaded or (not SongBeats.Enabled)
			if (not SongBeats.Enabled) then break end
			local newfov = math.min(bedwars.FovController:getFOV() * (bedwars.SprintController.sprinting and 1.1 or 1), 120)
			gameCamera.FieldOfView = newfov - SongBeatsIntensity.Value
			if SongTween then SongTween:Cancel() end
			SongTween = game:GetService("TweenService"):Create(gameCamera, TweenInfo.new(0.2), {FieldOfView = newfov})
			SongTween:Play()
			task.wait(bpm)
		until (not SongBeats.Enabled) or SongAudio.IsPaused
	end

	SongBeats = vape.Categories.Render:CreateModule({
		Name = "SongBeats",
		Function = function(callback)
			if callback then
				task.spawn(function()
					if #SongBeatsList.ObjectList <= 0 then
						warningNotification("SongBeats", "no songs", 5)
						SongBeats:Toggle(false)
						return
					end
					local lastChosen
					repeat
						local newSong
						repeat newSong = SongBeatsList.ObjectList[Random.new():NextInteger(1, #SongBeatsList.ObjectList)] task.wait() until newSong ~= lastChosen or #SongBeatsList.ObjectList <= 1
						lastChosen = newSong
						PlaySong(newSong)
						if not SongBeats.Enabled then break end
						task.wait(2)
					until (not SongBeats.Enabled)
				end)
			else
				if SongAudio then SongAudio:Destroy() end
				if SongTween then SongTween:Cancel() end
			end
		end
	})
	SongBeatsList = SongBeats:CreateTextList({
		Name = "SongList",
		TempText = "songpath:bpm"
	})
	SongBeatsIntensity = SongBeats:CreateSlider({
		Name = "Intensity",
		Function = function() end,
		Min = 1,
		Max = 10,
		Default = 5
	})
end)

run(function()
	local AntiAFK = {Enabled = false}
	AntiAFK = vape.Categories.Utility:CreateModule({
		Name = "AntiAFK",
		Function = function(callback)
			if callback then
				bedwars.Client:Get("AfkInfo"):FireServer({
					afk = false
				})
			end
		end
	})
end)

run(function()
	local AutoBalloonPart
	local AutoBalloonConnection
	local AutoBalloonDelay = {Value = 10}
	local AutoBalloonLegit = {Enabled = false}
	local AutoBalloonypos = 0
	local balloondebounce = false
	local AutoBalloon = {Enabled = false}
	AutoBalloon = vape.Categories.Utility:CreateModule({
		Name = "AutoBalloon",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat task.wait() until store.matchState ~= 0 or  not vapeInjected
					if vapeInjected and AutoBalloonypos == 0 and AutoBalloon.Enabled then
						local lowestypos = 99999
						for i,v in pairs(store.blocks) do
							local newray = game.Workspace:Raycast(v.Position + Vector3.new(0, 800, 0), Vector3.new(0, -1000, 0), store.blockRaycast)
							if i % 200 == 0 then
								task.wait(0.06)
							end
							if newray and newray.Position.Y <= lowestypos then
								lowestypos = newray.Position.Y
							end
						end
						AutoBalloonypos = lowestypos - 8
					end
				end)
				task.spawn(function()
					repeat task.wait() until AutoBalloonypos ~= 0
					if AutoBalloon.Enabled then
						AutoBalloonPart = Instance.new("Part")
						AutoBalloonPart.CanCollide = false
						AutoBalloonPart.Size = Vector3.new(10000, 1, 10000)
						AutoBalloonPart.Anchored = true
						AutoBalloonPart.Transparency = 1
						AutoBalloonPart.Material = Enum.Material.Neon
						AutoBalloonPart.Color = Color3.fromRGB(135, 29, 139)
						AutoBalloonPart.Position = Vector3.new(0, AutoBalloonypos - 50, 0)
						AutoBalloonConnection = AutoBalloonPart.Touched:Connect(function(touchedpart)
							if entityLibrary.isAlive and touchedpart:IsDescendantOf(lplr.Character) and balloondebounce == false then
								autobankballoon = true
								balloondebounce = true
								local oldtool = store.localHand.tool
								for i = 1, 3 do
									if getItem("balloon") and (AutoBalloonLegit.Enabled and getHotbarSlot("balloon") or AutoBalloonLegit.Enabled == false) and (lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") < 3 or lplr.Character:GetAttribute("InflatedBalloons") == nil) then
										if AutoBalloonLegit.Enabled then
											if getHotbarSlot("balloon") then
												bedwars.ClientStoreHandler:dispatch({
													type = "InventorySelectHotbarSlot",
													slot = getHotbarSlot("balloon")
												})
												task.wait(AutoBalloonDelay.Value / 100)
												bedwars.BalloonController:inflateBalloon()
											end
										else
											task.wait(AutoBalloonDelay.Value / 100)
											bedwars.BalloonController:inflateBalloon()
										end
									end
								end
								if AutoBalloonLegit.Enabled and oldtool and getHotbarSlot(oldtool.Name) then
									task.wait(0.2)
									bedwars.ClientStoreHandler:dispatch({
										type = "InventorySelectHotbarSlot",
										slot = (getHotbarSlot(oldtool.Name) or 0)
									})
								end
								balloondebounce = false
								autobankballoon = false
							end
						end)
						AutoBalloonPart.Parent = game.Workspace
					end
				end)
			else
				if AutoBalloonConnection then AutoBalloonConnection:Disconnect() end
				if AutoBalloonPart then
					AutoBalloonPart:Remove()
				end
			end
		end,
		Tooltip = "Automatically Inflates Balloons"
	})
	AutoBalloonDelay = AutoBalloon:CreateSlider({
		Name = "Delay",
		Min = 1,
		Max = 50,
		Default = 20,
		Function = function() end,
		Tooltip = "Delay to inflate balloons."
	})
	AutoBalloonLegit = AutoBalloon:CreateToggle({
		Name = "Legit Mode",
		Function = function() end,
		Tooltip = "Switches to balloons in hotbar and inflates them."
	})
end)

local autobankapple = false
run(function()
	local AutoBuy = {Enabled = false}
	local AutoBuyArmor = {Enabled = false}
	local AutoBuySword = {Enabled = false}
	local AutoBuyGen = {Enabled = false}
	local AutoBuyAxolotl = {Enabled = false}
	local AutoBuyProt = {Enabled = false}
	local AutoBuySharp = {Enabled = false}
	local AutoBuyDestruction = {Enabled = false}
	local AutoBuyDiamond = {Enabled = false}
	local AutoBuyAlarm = {Enabled = false}
	local AutoBuyGui = {Enabled = false}
	local AutoBuyTierSkip = {Enabled = true}
	local AutoBuyRange = {Value = 20}
	local AutoBuyCustom = {ObjectList = {}, RefreshList = function() end}
	local AutoBankUIToggle = {Enabled = false}
	local AutoBankDeath = {Enabled = false}
	local AutoBankStay = {Enabled = false}
	local buyingthing = false
	local shoothook
	local bedwarsshopnpcs = {}
	local id
	local armors = {
		[1] = "leather_chestplate",
		[2] = "iron_chestplate",
		[3] = "diamond_chestplate",
		[4] = "emerald_chestplate"
	}

	local swords = {
		[1] = "wood_sword",
		[2] = "stone_sword",
		[3] = "iron_sword",
		[4] = "diamond_sword",
		[5] = "emerald_sword"
	}

	local scythes = {
		[1] = "wood_scythe",
		[2] = "stone_scythe",
		[3] = "iron_scythe",
		[4] = "diamond_scythe",
		[5] = "mythic_scythe"
	}

	local axes = {
		[1] = "wood_axe",
		[2] = "stone_axe",
		[3] = "iron_axe",
		[4] = "diamond_axe"
	}

	local pickaxes = {
		[1] = "wood_pickaxe",
		[2] = "stone_pickaxe",
		[3] = "iron_pickaxe",
		[4] = "diamond_pickaxe"
	}

	local axolotls = {
		[1] = "shield_axolotl",
		[2] = "damage_axolotl",
		[3] = "break_speed_axolotl",
		[4] = "health_regen_axolotl"
 	}

	task.spawn(function()
		repeat task.wait() until store.matchState ~= 0 or not vapeInjected
		for i,v in pairs(collectionService:GetTagged("BedwarsItemShop")) do
			table.insert(bedwarsshopnpcs, {Position = v.Position, TeamUpgradeNPC = true, Id = v.Name})
		end
		for i,v in pairs(collectionService:GetTagged("TeamUpgradeShopkeeper")) do
			table.insert(bedwarsshopnpcs, {Position = v.Position, TeamUpgradeNPC = false, Id = v.Name})
		end
	end)

	local function nearNPC(range)
		local npc, npccheck, enchant, newid = nil, false, false, nil
		if entityLibrary.isAlive then
			local enchanttab = {}
			for i,v in pairs(collectionService:GetTagged("broken-enchant-table")) do
				table.insert(enchanttab, v)
			end
			for i,v in pairs(collectionService:GetTagged("enchant-table")) do
				table.insert(enchanttab, v)
			end
			for i,v in pairs(enchanttab) do
				if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= 6 then
					if ((not v:GetAttribute("Team")) or v:GetAttribute("Team") == lplr:GetAttribute("Team")) then
						npc, npccheck, enchant = true, true, true
					end
				end
			end
			for i, v in pairs(bedwarsshopnpcs) do
				if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= (range or 20) then
					npc, npccheck, enchant = true, (v.TeamUpgradeNPC or npccheck), false
					newid = v.TeamUpgradeNPC and v.Id or newid
				end
			end
			local suc, res = pcall(function() return lplr.leaderstats.Bed.Value == "✅"  end)
			if AutoBankDeath.Enabled and (game.Workspace:GetServerTimeNow() - lplr.Character:GetAttribute("LastDamageTakenTime")) < 2 and suc and res then
				return nil, false, false
			end
			if AutoBankStay.Enabled then
				return nil, false, false
			end
		end
		return npc, not npccheck, enchant, newid
	end

	local function buyItem(itemtab, waitdelay)
		if not id then return end
		local res
		res = bedwars.Client:Get("BedwarsPurchaseItem"):InvokeServer({
			shopItem = itemtab,
			shopId = id
		})
		if waitdelay then
			repeat task.wait() until res ~= nil
		end
	end

	local function getAxeNear(inv)
		for i5, v5 in pairs(inv or store.localInventory.inventory.items) do
			if v5.itemType:find("axe") and v5.itemType:find("pickaxe") == nil then
				return v5.itemType
			end
		end
		return nil
	end

	local function getPickaxeNear(inv)
		for i5, v5 in pairs(inv or store.localInventory.inventory.items) do
			if v5.itemType:find("pickaxe") then
				return v5.itemType
			end
		end
		return nil
	end

	local function getShopItem(itemType)
		if itemType == "axe" then
			itemType = getAxeNear() or "wood_axe"
			itemType = axes[table.find(axes, itemType) + 1] or itemType
		end
		if itemType == "pickaxe" then
			itemType = getPickaxeNear() or "wood_pickaxe"
			itemType = pickaxes[table.find(pickaxes, itemType) + 1] or itemType
		end
		for i,v in pairs(bedwars.ShopItems) do
			if v.itemType == itemType then return v end
		end
		return nil
	end

	local function metafyAxolotl(name)
		local data = {
			["ShieldAxolotl"] = "shield_axolotl",
			["DamageAxolotl"] = "damage_axolotl",
			["BreakSpeedAxolotl"] = "break_speed_axolotl",
			["HealthRegenAxolotl"] = "health_regen_axolotl"
		}
		return data[name] or ""
	end

	local function getAxolotls()
		local res = {}
		local data_folder = workspace:FindFirstChild("AxolotlModel")
		if not data_folder then return res, true end

		for i,v in pairs(data_folder:GetChildren()) do
			if v.ClassName ~= "Model" then continue end
			local owner = v:FindFirstChild("AxolotlData")
			if not owner then continue end
			if owner.ClassName ~= "ObjectValue" then continue end
			if not owner.Value then continue end
			if tostring(owner.Value) == lplr.Name.."_Axolotl" then
				table.insert(res, {
					axolotlType = v.Name,
					name = metafyAxolotl(v.Name)
				})
			end
		end

		return res
	end

	local function getAxolotl(metaName, inv)
		for i,v in pairs(inv) do
			if v.name == metaName then return v end
		end
		return nil
	end

	local buyfunctions = {
		Armor = function(inv, upgrades, shoptype)
			local inv = store.localInventory.inventory
			local armor = inv.armor
			local currentArmor = armor[2]
			if type(currentArmor) ~= "table" then currentArmor = {itemType = ""} end
			if tostring(currentArmor.itemType) == "nil" then currentArmor = {itemType = ""} end
			local armorToBuy
			if currentArmor.itemType == "" then armorToBuy = "leather_chestplate" end
			if currentArmor.itemType ~= "" and currentArmor.itemType:find("leather") then armorToBuy = "iron_chestplate" end
			if currentArmor.itemType ~= "" and currentArmor.itemType:find("iron") then armorToBuy = "diamond_chestplate" end
			if currentArmor.itemType ~= "" and currentArmor.itemType:find("diamond") then armorToBuy = "emerald_chestplate" end
			if currentArmor.itemType ~= "" and currentArmor.itemType:find("emerald") then armorToBuy = "none" end
			local shopitem = getShopItem(armorToBuy)
			if shopitem then
				local currency = getItem(shopitem.currency, inv.items)
				if currency and currency.amount >= shopitem.price then
					buyItem(getShopItem(armorToBuy))
				end
			end
		end,
		Sword = function(inv, upgrades, shoptype)
			local inv = store.localInventory.inventory
			local currentsword = shared.scythexp and getItemNear("scythe", inv.items) or getItemNear("sword", inv.items)
			local swordindex = (currentsword and table.find(swords, currentsword.itemType) or 0) + 1
			if shared.scythexp then
				swordindex = (currentsword and table.find(scythes, currentsword.itemType) or 0) + 1
			end
			if getItemNear("scythe", inv.items) then 
				if currentsword ~= nil and table.find(scythes, currentsword.itemType) == nil then return end
			else
				if currentsword ~= nil and table.find(swords, currentsword.itemType) == nil then return end
			end
			local highestbuyable = nil
			local tableToDo = shared.scythexp and scythes or swords
			for i = swordindex, #tableToDo, 1 do
				local shopitem = shared.scythexp and getShopItem(scythes[i]) or getShopItem(swords[i])
				if shopitem and i == swordindex then
					local currency = getItem(shopitem.currency, inv.items)
					if currency and currency.amount >= shopitem.price then
						highestbuyable = shopitem
					end
				end
			end
			if highestbuyable and (highestbuyable.ignoredByKit == nil or table.find(highestbuyable.ignoredByKit, store.equippedKit) == nil) then
				buyItem(highestbuyable)
			end
		end,
		Axolotl = function(inv, upgrades, shoptype)
			if store.equippedKit ~= "axolotl" then return end
			if not AutoBuyAxolotl.Enabled then return end

			local inv = store.localInventory.inventory
			local inv_axolotls, abort = getAxolotls()
			if abort then return end

			local tableToDo = axolotls

			local axolotlindex = 0
			for i,v in pairs(axolotls) do
				if getAxolotl(v, inv_axolotls) then
					axolotlindex = i
				end
			end
			axolotlindex = axolotlindex + 1

			local highestbuyable = nil
			for i = axolotlindex, #tableToDo, 1 do
				local shopitem = getShopItem(axolotls[i])
				if shopitem and i == axolotlindex then
					local currency = getItem(shopitem.currency, inv.items)
					if currency and currency.amount >= shopitem.price then
						highestbuyable = shopitem
					end
				end
			end

			if highestbuyable and (highestbuyable.ignoredByKit == nil or table.find(highestbuyable.ignoredByKit, store.equippedKit) == nil) then
				buyItem(highestbuyable)
			end
		end
	}

	AutoBuy = vape.Categories.Inventory:CreateModule({
		Name = "AutoBuy",
		Function = function(callback)
			if callback then
				buyingthing = false
				task.spawn(function()
					repeat
						task.wait()
						local found, npctype, enchant, newid = nearNPC(AutoBuyRange.Value)
						id = newid
						if found then
							local inv = store.localInventory.inventory
							local currentupgrades = {}
							if store.equippedKit == "dasher" then
								swords = {
									[1] = "wood_dao",
									[2] = "stone_dao",
									[3] = "iron_dao",
									[4] = "diamond_dao",
									[5] = "emerald_dao"
								}
							elseif store.equippedKit == "ice_queen" then
								swords[5] = "ice_sword"
							elseif store.equippedKit == "ember" then
								swords[5] = "infernal_saber"
							elseif store.equippedKit == "lumen" then
								swords[5] = "light_sword"
							elseif store.equippedKit == "pyro" then
								swords[6] = "flamethrower"
							end
							if (AutoBuyGui.Enabled == false or (bedwars.AppController:isAppOpen("BedwarsItemShopApp") or bedwars.AppController:isAppOpen("BedwarsTeamUpgradeApp"))) and (not enchant) then
								for i,v in pairs(AutoBuyCustom.ObjectList) do
									local autobuyitem = v:split("/")
									if #autobuyitem >= 3 and autobuyitem[4] ~= "true" then
										local shopitem = getShopItem(autobuyitem[1])
										if shopitem then
											local currency = getItem(shopitem.currency, inv.items)
											local actualitem = getItem(shopitem.itemType == "wool_white" and getWool() or shopitem.itemType, inv.items)
											if currency and currency.amount >= shopitem.price and (actualitem == nil or actualitem.amount < tonumber(autobuyitem[2])) then
												buyItem(shopitem, tonumber(autobuyitem[2]) > 1)
											end
										end
									end
								end
								for i,v in pairs(buyfunctions) do v(inv, currentupgrades, npctype and "upgrade" or "item") end
								for i,v in pairs(AutoBuyCustom.ObjectList) do
									local autobuyitem = v:split("/")
									if #autobuyitem >= 3 and autobuyitem[4] == "true" then
										local shopitem = getShopItem(autobuyitem[1])
										if shopitem then
											local currency = getItem(shopitem.currency, inv.items)
											local actualitem = getItem(shopitem.itemType == "wool_white" and getWool() or shopitem.itemType, inv.items)
											if currency and currency.amount >= shopitem.price and (actualitem == nil or actualitem.amount < tonumber(autobuyitem[2])) then
												buyItem(shopitem, tonumber(autobuyitem[2]) > 1)
											end
										end
									end
								end
							end
						end
					until (not AutoBuy.Enabled)
				end)
			end
		end,
		Tooltip = "Automatically Buys Swords, Armor, and Team Upgrades\nwhen you walk near the NPC"
	})
	AutoBuyRange = AutoBuy:CreateSlider({
		Name = "Range",
		Function = function() end,
		Min = 1,
		Max = 20,
		Default = 20
	})
	AutoBuyArmor = AutoBuy:CreateToggle({
		Name = "Buy Armor",
		Function = function() end,
		Default = true
	})
	AutoBuySword = AutoBuy:CreateToggle({
		Name = "Buy Sword",
		Function = function() end,
		Default = true
	})
	AutoBuyAxolotl = AutoBuy:CreateToggle({
		Name = "Buy Axolotl",
		Function = function() end,
		Default = true
	})
	AutoBuyAxolotl.Object.Visible = false
	task.spawn(function()
		pcall(function()
			repeat task.wait() until store.equippedKit ~= ""
			AutoBuyAxolotl.Object.Visible = store.equippedKit == "axolotl"
		end)
	end)
	AutoBuyGui = AutoBuy:CreateToggle({
		Name = "Shop GUI Check",
		Function = function() end,
	})
	AutoBuyTierSkip = AutoBuy:CreateToggle({
		Name = "Tier Skip",
		Function = function() end,
		Default = true
	})
	AutoBuyCustom = AutoBuy:CreateTextList({
		Name = "BuyList",
		TempText = "item/amount/priority/after",
		SortFunction = function(a, b)
			local amount1 = a:split("/")
			local amount2 = b:split("/")
			amount1 = #amount1 and tonumber(amount1[3]) or 1
			amount2 = #amount2 and tonumber(amount2[3]) or 1
			return amount1 < amount2
		end
	})
end)

run(function()
    local function getDiamonds()
        local function getItem(itemName, inv)
            for slot, item in pairs(inv or store.localInventory.inventory.items) do
                if item.itemType == itemName then
                    return item, slot
                end
            end
            return nil
        end
        local inv = store.localInventory.inventory
        if inv.items and type(inv.items) == "table" and getItem("diamond", inv.items) and getItem("diamond", inv.items).amount then 
            return tostring(getItem("diamond", inv.items).amount) ~= "inf" and tonumber(getItem("diamond", inv.items).amount) or 9999999999999
        else 
            return 0 
        end
    end
    local resolve = {
        ["Armor"] = {
            Name = "ARMOR",
            Upgrades = {[1] = 4, [2] = 8, [3] = 20},
            CurrentUpgrade = 0,
            Function = function()

            end
        },
        ["Damage"] = {
            Name = "DAMAGE",
            Upgrades = {[1] = 5, [2] = 10, [3] = 18},
            CurrentUpgrade = 0,
            Function = function()

            end
        },
        ["Diamond Gen"] = {
            Name = "DIAMOND_GENERATOR",
            Upgrades = {[1] = 4, [2] = 8, [3] = 12},
            CurrentUpgrade = 0,
            Function = function()

            end
        },
        ["Team Gen"] = {
            Name = "TEAM_GENERATOR",
            Upgrades = {[1] = 4, [2] = 8, [3] = 16},
            CurrentUpgrade = 0,
            Function = function()

            end
        }
    }
    local function buyUpgrade(translation)
        if not translation or not resolve[translation] or not type(resolve[translation]) == "table" then return warn(debug.traceback("[buyUpgrade]: Invalid translation given! "..tostring(translation))) end
        local res = bedwars.Client:Get("RequestPurchaseTeamUpgrade"):InvokeServer(resolve[translation].Name)
        if res == true then resolve[translation].CurrentUpgrade = resolve[translation].CurrentUpgrade + 1 else
            if getDiamonds() >= resolve[translation].Upgrades[resolve[translation].CurrentUpgrade + 1] then
                local res2 = bedwars.Client:Get("RequestPurchaseTeamUpgrade"):InvokeServer(resolve[translation].Name)
                if res2 == true then resolve[translation].CurrentUpgrade = resolve[translation].CurrentUpgrade + 1 else
                    warn("Using force use of current upgrade...", translation, tostring(res), tostring(res2))
                    resolve[translation].CurrentUpgrade = resolve[translation].CurrentUpgrade + 1
                end
            end
        end
    end
    local function resolveTeamUpgradeApp(app)
        if (not app) or not app:IsA("ScreenGui") then return "invalid app! "..tostring(app) end
        local function findChild(name, className, children)
            for i,v in pairs(children) do if v.Name == name and v.ClassName == className then return v end end
            local args = {Name = tostring(name), ClassName == tostring(className), Children = children}
            warn(debug.traceback("[findChild]: CHILD NOT FOUND! Args: "), game:GetService("HttpService"):JSONEncode(args), name, className, children)
            return nil
        end
        local function resolveCard(card, translation)
            local a = "["..tostring(card).." | "..tostring(translation).."] "
            local suc, res = true, a
            local function p(b) suc = false; res = a..tostring(b).." not found!" return suc, res end
            if not card or not translation or not card:IsA("Frame") then suc = false; res = a.."Invalid use of resolveCard!" return suc, res end
            translation = tostring(translation)
            local function resolveUpgradeCost(cost)
                if not cost then return warn(debug.traceback("[resolveUpgradeCost]: Invalid cost given!")) end
                cost = tonumber(cost)
                if resolve[translation] and resolve[translation].Upgrades and type(resolve[translation].Upgrades) == "table" then
                    for i,v in pairs(resolve[translation].Upgrades) do 
                        if v == cost then return i end
                    end
                end
            end
            local Content = findChild("Content", "Frame", card:GetChildren())
            if Content then
                local PurchaseSection = findChild("PurchaseSection", "Frame", Content:GetChildren())
                if PurchaseSection then
                    local Cost_Info = findChild("Cost Info", "Frame", PurchaseSection:GetChildren())
                    if Cost_Info then
                        local Current_Diamond_Required = findChild("2", "TextLabel", Cost_Info:GetChildren())
                        if Current_Diamond_Required then
                            local upgrade = resolveUpgradeCost(Current_Diamond_Required.Text)
                            if upgrade then
                                resolve[translation].CurrentUpgrade = upgrade - 1
                            else warn("invalid upgrade", translation, Current_Diamond_Required.Text) end
                        else return p("Card->Content->PurchaseSection->Cost Info") end
                    else resolve[translation].CurrentUpgrade = 3 return p("Card->Content->PurchaseSection->Cost Info") end
                else return p("Card->Content->PurchaseSection") end
            else return p("Card->Content") end
        end
        local frame2 = findChild("2", "Frame", app:GetChildren())
        if frame2 then
            local TeamUpgradeAppContainer = findChild("TeamUpgradeAppContainer", "ImageButton", frame2:GetChildren())
            if TeamUpgradeAppContainer then
                local UpgradesWrapper = findChild("UpgradesWrapper", "Frame", TeamUpgradeAppContainer:GetChildren())
                if UpgradesWrapper then
                    local suc1, res1, suc2, res2, suc3, res3, suc4, res4 = resolveCard(findChild("ARMOR_Card", "Frame", UpgradesWrapper:GetChildren()), "Armor"), resolveCard(findChild("DAMAGE_Card", "Frame", UpgradesWrapper:GetChildren()), "Damage"), resolveCard(findChild("DIAMOND_GENERATOR_Card", "Frame", UpgradesWrapper:GetChildren()), "Diamond Gen"), resolveCard(findChild("TEAM_GENERATOR_Card", "Frame", UpgradesWrapper:GetChildren()), "Team Gen")
                end
            end
        end
    end
    local function check(app) if app.Name and app:IsA("ScreenGui") and app.Name == "TeamUpgradeApp" then resolveTeamUpgradeApp(app) end end
    local con = lplr:WaitForChild("PlayerGui").ChildAdded:Connect(check)
    GuiLibrary.SelfDestructEvent.Event:Connect(function() pcall(function() con:Disconnect() end) end)
    for i, app in pairs(lplr:WaitForChild("PlayerGui"):GetChildren()) do check(app) end

    local bedwarsshopnpcs = {}
    task.spawn(function()
		repeat task.wait() until store.matchState ~= 0 or not shared.VapeExecuted
		for i,v in pairs(collectionService:GetTagged("TeamUpgradeShopkeeper")) do
			table.insert(bedwarsshopnpcs, {Position = v.Position, TeamUpgradeNPC = false, Id = v.Name})
		end
	end)

    local function nearNPC(range)
		local npc, npccheck, enchant, newid = nil, false, false, nil
		if entityLibrary.isAlive then
			for i, v in pairs(bedwarsshopnpcs) do
				if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= (range or 20) then
					npc, npccheck, enchant = true, (v.TeamUpgradeNPC or npccheck), false
					newid = v.TeamUpgradeNPC and v.Id or newid
				end
			end
		end
		return npc, not npccheck, enchant, newid
	end

    local AutoBuyDiamond = {Enabled = false}
    local PreferredUpgrade = {Value = "Damage"}
    local AutoBuyDiamondGui = {Enabled = false}
    local AutoBuyDiamondRange = {Value = 20}

    AutoBuyDiamond = vape.Categories.Utility:CreateModule({
        Name = "AutoBuyDiamondUpgrades",
        Function = function(call)
            if call then
                repeat task.wait()
                    if nearNPC(AutoBuyDiamondRange.Value) then
                        if (not AutoBuyDiamondGui.Enabled) or bedwars.AppController:isAppOpen("TeamUpgradeApp") then
                            if resolve[PreferredUpgrade.Value].CurrentUpgrade ~= 3 and getDiamonds() >= resolve[PreferredUpgrade.Value].Upgrades[resolve[PreferredUpgrade.Value].CurrentUpgrade + 1] then buyUpgrade(PreferredUpgrade.Value) end
                            for i,v in pairs(resolve) do if v.CurrentUpgrade ~= 3 and getDiamonds() >= v.Upgrades[v.CurrentUpgrade + 1] then buyUpgrade(i) end end
                        end
                    end
                until (not AutoBuyDiamond.Enabled)
            end
        end,
        Tooltip = "Auto buys diamond upgrades"
    })
    AutoBuyDiamond.Restart = function() if AutoBuyDiamond.Enabled then AutoBuyDiamond:Toggle(false); AutoBuyDiamond:Toggle(false) end end
    AutoBuyDiamondRange = AutoBuyDiamond:CreateSlider({
        Name = "Range",
        Function = function() end,
        Min = 1,
        Max = 20,
        Default = 20
    })
    local real_list = {}
    for i,v in pairs(resolve) do table.insert(real_list, tostring(i)) end
    PreferredUpgrade = AutoBuyDiamond:CreateDropdown({
        Name = "PreferredUpgrade",
        Function = AutoBuyDiamond.Restart,
        List = real_list,
        Default = "Damage"
    })
    AutoBuyDiamondGui = AutoBuyDiamond:CreateToggle({
        Name = "Gui Check",
        Function = AutoBuyDiamond.Restart
    })
end)

run(function()
	local AutoConsume = {Enabled = false}
	local AutoConsumeStar = {Enabled = false}
	local AutoConsumeHealth = {Value = 100}
	local AutoConsumeSpeed = {Enabled = true}
	local AutoConsumeDelay = tick()

	local function AutoConsumeFunc()
		if entityLibrary.isAlive then
			local speedpotion = getItem("speed_potion")
			if lplr.Character:GetAttribute("Health") <= (lplr.Character:GetAttribute("MaxHealth") - (100 - AutoConsumeHealth.Value)) then
				autobankapple = true
				local item = getItem("apple")
				local pot = getItem("heal_splash_potion")
				if (item or pot) and AutoConsumeDelay <= tick() then
					if item then
						bedwars.Client:Get(bedwars.EatRemote):InvokeServer({
							item = item.tool
						})
						AutoConsumeDelay = tick() + 0.6
					end
				end
			else
				autobankapple = false
			end
			local starItem = AutoConsumeStar.Enabled and (getItem("vitality_star") or getItem("crit_star"))
			if starItem then
				bedwars.Client:Get(bedwars.EatRemote):InvokeServer({
					item = starItem.tool
				})
			end
			if speedpotion and (not lplr.Character:GetAttribute("StatusEffect_speed")) and AutoConsumeSpeed.Enabled then
				bedwars.Client:Get(bedwars.EatRemote):InvokeServer({
					item = speedpotion.tool
				})
			end
			if lplr.Character:GetAttribute("Shield_POTION") and ((not lplr.Character:GetAttribute("Shield_POTION")) or lplr.Character:GetAttribute("Shield_POTION") == 0) then
				local shield = getItem("big_shield") or getItem("mini_shield")
				if shield then
					bedwars.Client:Get(bedwars.EatRemote):InvokeServer({
						item = shield.tool
					})
				end
			end
		end
	end

	AutoConsume = vape.Categories.Inventory:CreateModule({
		Name = "AutoConsume",
		Function = function(callback)
			if callback then
				AutoConsume:Clean(vapeEvents.InventoryAmountChanged.Event:Connect(AutoConsumeFunc))
				AutoConsume:Clean(vapeEvents.AttributeChanged.Event:Connect(function(changed)
					if changed:find("Shield") or changed:find("Health") or changed:find("speed") then
						AutoConsumeFunc()
					end
				end))
				task.spawn(function()
					repeat task.wait(1)
						AutoConsumeFunc()
					until (not AutoConsume.Enabled)
				end)
				AutoConsumeFunc()
			end
		end,
		Tooltip = "Automatically heals for you when health or shield is under threshold."
	})
	AutoConsume.Restart = function() if AutoConsume.Enabled then AutoConsume:Toggle(false); AutoConsume:Toggle(false) end end
	AutoConsumeStar = AutoConsume:CreateToggle({
		Name = "Auto Consume Stars",
		Function = AutoConsumeStar.Restart,
		Default = true
	})
	AutoConsumeStar.Object.Visible = (store.equippedKit == "star_collector")
	AutoConsumeHealth = AutoConsume:CreateSlider({
		Name = "Health",
		Min = 1,
		Max = 99,
		Default = 70,
		Function = function() end
	})
	AutoConsumeSpeed = AutoConsume:CreateToggle({
		Name = "Speed Potions",
		Function = function() end,
		Default = true
	})
end)

run(function()
	local AutoKit = {Enabled = false, Connections = {}}
	local AutoKitTrinity = {Value = "Void"}
	local Legit = {Enabled = false}
	local oldfish
	local function GetTeammateThatNeedsMost()
		local plrs = GetAllNearestHumanoidToPosition(true, 30, 1000, true)
		local lowest, lowestplayer = 10000, nil
		for i,v in pairs(plrs) do
			if not v.Targetable then
				if v.Character:GetAttribute("Health") <= lowest and v.Character:GetAttribute("Health") < v.Character:GetAttribute("MaxHealth") then
					lowest = v.Character:GetAttribute("Health")
					lowestplayer = v
				end
			end
		end
		return lowestplayer
	end

	local function kitCollection(id, func, range, specific)
		local objs = type(id) == 'table' and id or collection(id, AutoKit)
		repeat
			if entitylib.isAlive then
				local localPosition = entitylib.character.RootPart.Position
				for _, v in objs do
					if not AutoKit.Enabled then break end
					local part = not v:IsA('Model') and v or v.PrimaryPart
					if part and (part.Position - localPosition).Magnitude <= (not Legit.Enabled and specific and math.huge or range) then
						func(v)
					end
				end
			end
			task.wait(0.1)
		until not AutoKit.Enabled
	end

	local AutoKit_Functions = {
		pinata = function()
			kitCollection(lplr.Name..':pinata', function(v)
				if getItem('candy') then
					bedwars.Client:Get("DepositCoins"):CallServer(v)
				end
			end, 6, true)
		end,
		ember = function()
			shared.EmberAutoKit = true
		end,
		hannah = function()
			kitCollection('HannahExecuteInteraction', function(v)
				local billboard = bedwars.Client:Get("HannahPromptTrigger"):InvokeServer({
					user = lplr,
					victimEntity = v
				}) and v:FindFirstChild('Hannah Execution Icon')
	
				if billboard then
					billboard:Destroy()
				end
			end, 30, true)
		end,
		wizard = function()
			repeat
				local ability = lplr:GetAttribute('WizardAbility')
				if ability and bedwars.AbilityController:canUseAbility(ability) then
					local plr = entitylib.EntityPosition({
						Range = 50,
						Part = 'RootPart',
						Players = true,
						Sort = sortmethods.Health
					})
	
					if plr then
						bedwars.AbilityController:useAbility(ability, {target = plr.RootPart.Position})
					end
				end
	
				task.wait(0.1)
			until not AutoKit.Enabled
		end,
		warlock = function()
			local lastTarget
			repeat
				if store.hand.tool and store.hand.tool.Name == 'warlock_staff' then
					local plr = entitylib.EntityPosition({
						Range = 30,
						Part = 'RootPart',
						Players = true,
						NPCs = true
					})
	
					if plr and plr.Character ~= lastTarget then
						if not bedwars.WarlockController:link(plr) then
							plr = nil
						end
					end
	
					lastTarget = plr and plr.Character
				else
					lastTarget = nil
				end
	
				task.wait(0.1)
			until not AutoKit.Enabled
		end,
		["star_collector"] = function()
			local function fetchItem(obj)
				local args = {
					[1] = {
						["id"] = obj:GetAttribute("Id"),
						["collectableName"] = obj.Name
					}
				}
				local res = bedwars.Client:Get("CollectCollectableEntity"):FireServer(unpack(args))
			end
			local allowedNames = {"CritStar", "VitalityStar"}
			task.spawn(function()
				repeat
					task.wait()
					if entityLibrary.isAlive then 
						local maxDistance = 30
						for i,v in pairs(game.Workspace:GetChildren()) do
							if v.Parent and v.ClassName == "Model" and table.find(allowedNames, v.Name) and lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
								local pos1 = lplr.Character:FindFirstChild("HumanoidRootPart").Position
								local pos2 = v.PrimaryPart.Position
								if (pos1 - pos2).Magnitude <= maxDistance then
									fetchItem(v)
								end
							end
						end
					end
				until (not AutoKit.Enabled)
			end)
		end,
		["spirit_assassin"] = function()
			repeat
				task.wait()
				bedwars.SpiritAssassinController:Invoke()
			until (not AutoKit.Enabled)
		end,
		["alchemist"] = function()
			AutoKit:Clean(lplr.Chatted:Connect(function(msg)
				if AutoKit.Enabled then
					local parts = string.split(msg, " ")
					if parts[1] and (parts[1] == "/recipes" or parts[1] == "/potions") then
						local potions = bedwars.ItemTable["brewing_cauldron"].crafting.recipes
						local function resolvePotionsData(data)
							local finalData = {}
							for i,v in pairs(data) do
								local result = v.result
								local brewingTime = v.timeToCraft
								local recipe = ""
								for i2, v2 in pairs(v.ingredients) do
									recipe = recipe ~= "" and recipe.." + "..tostring(v2) or recipe == "" and recipe..tostring(v2)
								end
								table.insert(finalData, {
									Result = result, 
									BrewingTime = brewingTime,
									Recipe = recipe
								})
							end
							return finalData
						end
						for i,v in pairs(resolvePotionsData(potions)) do
							local text = v.Result..": "..v.Recipe.." ("..tostring(v.BrewingTime).."seconds)"
							game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
								Text = text,
								Color = Color3.new(255, 255, 255),
								Font = Enum.Font.SourceSans,
								FontSize = Enum.FontSize.Size36
							})
						end
					end
				end
			end))
			local function fetchItem(obj)
				local args = {
					[1] = {
						["id"] = obj:GetAttribute("Id"),
						["collectableName"] = obj.Name
					}
				}
				local res = bedwars.Client:Get("CollectCollectableEntity"):FireServer(unpack(args))
			end
			local allowedNames = {"Thorns", "Mushrooms", "Flower"}
			task.spawn(function()
				repeat
					task.wait()
					if entityLibrary.isAlive then 
						local maxDistance = 30
						for i,v in pairs(game.Workspace:GetChildren()) do
							if v.Parent and v.ClassName == "Model" and table.find(allowedNames, v.Name) and lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
								local pos1 = lplr.Character:FindFirstChild("HumanoidRootPart").Position
								local pos2 = v.PrimaryPart.Position
								if (pos1 - pos2).Magnitude <= maxDistance then
									fetchItem(v)
								end
							end
						end
					end
				until (not AutoKit.Enabled)
			end)
		end,
		["melody"] = function()
			task.spawn(function()
				repeat
					task.wait(0.1)
					if getItem("guitar") then
						local plr = GetTeammateThatNeedsMost()
						if plr and healtick <= tick() then
							bedwars.Client:Get(bedwars.GuitarHealRemote):FireServer({
								healTarget = plr.Character
							})
							healtick = tick() + 2
						end
					end
				until (not AutoKit.Enabled)
			end)
		end,
		["bigman"] = function()
			task.spawn(function()
				repeat
					task.wait()
					local itemdrops = collectionService:GetTagged("treeOrb")
					for i,v in pairs(itemdrops) do
						if entityLibrary.isAlive and v:FindFirstChild("Spirit") and (entityLibrary.character.HumanoidRootPart.Position - v.Spirit.Position).magnitude <= 20 then
							if bedwars.Client:Get(bedwars.TreeRemote):InvokeServer({
								treeOrbSecret = v:GetAttribute("TreeOrbSecret")
							}) then
								v:Destroy()
								collectionService:RemoveTag(v, "treeOrb")
							end
						end
					end
				until (not AutoKit.Enabled)
			end)
		end,
		["metal_detector"] = function()
			task.spawn(function()
				repeat
					task.wait()
					local itemdrops = collectionService:GetTagged("hidden-metal")
					for i,v in pairs(itemdrops) do
						if entityLibrary.isAlive and v.PrimaryPart and (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude <= 20 then
							bedwars.Client:Get(bedwars.PickupMetalRemote):InvokeServer({
								id = v:GetAttribute("Id")
							})
						end
					end
				until (not AutoKit.Enabled)
			end)
		end,
		--[[["battery"] = function()
			task.spawn(function()
				repeat
					task.wait()
					local itemdrops = bedwars.BatteryEffectsController.liveBatteries
					for i,v in pairs(itemdrops) do
						if entityLibrary.isAlive and (entityLibrary.character.HumanoidRootPart.Position - v.position).magnitude <= 10 then
							bedwars.Client:Get(bedwars.BatteryRemote):SendToServer({
								batteryId = i
							})
						end
					end
				until (not AutoKit.Enabled)
			end)
		end,--]]
		["grim_reaper"] = function()
			task.spawn(function()
				repeat
					task.wait()
					local itemdrops = bedwars.GrimReaperController:fetchSoulsByPosition()
					for i,v in pairs(itemdrops) do
						--if entityLibrary.isAlive and lplr.Character:GetAttribute("Health") <= (lplr.Character:GetAttribute("MaxHealth") / 4) and v.PrimaryPart and (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude <= 120 and (not lplr.Character:GetAttribute("GrimReaperChannel")) then
						if entityLibrary.isAlive then
							local res = bedwars.Client:Get(bedwars.ConsumeSoulRemote):InvokeServer({
								secret = v:GetAttribute("GrimReaperSoulSecret")
							})
							v:Destroy()
						end
						--end
					end
				until (not AutoKit.Enabled)
			end)
		end,
		["farmer_cletus"] = function()
			task.spawn(function()
				repeat
					task.wait()
					local itemdrops = collectionService:GetTagged("HarvestableCrop")
					for i,v in pairs(itemdrops) do
						if entityLibrary.isAlive and (entityLibrary.character.HumanoidRootPart.Position - v.Position).magnitude <= 10 then
							bedwars.Client:Get("CropHarvest"):InvokeServer({
								position = bedwars.BlockController:getBlockPosition(v)
							})
						end
					end
				until (not AutoKit.Enabled)
			end)
		end,
		["dragon_slayer"] = function()
			local lastFired
			task.spawn(function()
				repeat
					task.wait(0.5)
					if entityLibrary.isAlive then
						for i,v in pairs(bedwars.DragonSlayerController:fetchDragonEmblems()) do
							local data = bedwars.DragonSlayerController:fetchDragonEmblemData(v)
							if data.stackCount >= 3 then
								local ctarget = bedwars.DragonSlayerController:resolveTarget(v:GetPrimaryPartCFrame())
								bedwars.DragonSlayerController:deleteEmblem(v)
								if ctarget then 
									task.spawn(function()
										bedwars.Client:Get(bedwars.DragonRemote):FireServer({
											target = ctarget
										})
									end)
								end
							end
						end
					end
				until (not AutoKit.Enabled)
			end)
		end,
		["mage"] = function()
			task.spawn(function()
				repeat
					task.wait(0.1)
					if entityLibrary.isAlive then
						for i, v in pairs(collectionService:GetTagged("TomeGuidingBeam")) do
							local obj = v.Parent and v.Parent.Parent and v.Parent.Parent.Parent
							if obj and (entityLibrary.character.HumanoidRootPart.Position - obj.PrimaryPart.Position).Magnitude < 5 and obj:GetAttribute("TomeSecret") then
								local res = bedwars.Client:Get(bedwars.MageRemote):InvokeServer({
									secret = obj:GetAttribute("TomeSecret")
								})
								if res.success and res.element then
									bedwars.GameAnimationUtil.playAnimation(lplr, bedwars.AnimationType.PUNCH)
									bedwars.ViewmodelController:playAnimation(bedwars.AnimationType.FP_USE_ITEM)
									local sound = bedwars.MageKitUtil.MageElementVisualizations[res.element].learnSound
									if sound and sound ~= "" then
										local activeSound = bedwars.SoundManager:playSound(sound)
										if activeSound then task.wait(0.3) pcall(function() activeSound:Stop(); activeSound:Destroy() end) end
									end
									pcall(function() obj:Destroy() end)
								end
							end
						end
					end
				until (not AutoKit.Enabled)
			end)
		end,
		["miner"] = function()
			task.spawn(function()
				repeat 
					task.wait(0.1)
					if entityLibrary.isAlive then
						for i,v in pairs(game.Workspace:GetChildren()) do
							local a = game.Workspace:GetChildren()[i]
							if a.ClassName == "Model" and #a:GetChildren() > 1 then
								if a:GetAttribute("PetrifyId") then
									bedwars.Client:Get("DestroyPetrifiedPlayer"):FireServer({
										["petrifyId"] = a:GetAttribute("PetrifyId")
									})
								end
							end
						end
					end
				until (not AutoKit.Enabled)
			end)
		end,
		["sorcerer"] = function()
			task.spawn(function()
				repeat 
					task.wait(0.1)
					if entityLibrary.isAlive then
						local player = game.Players.LocalPlayer
						local character = player.Character or player.CharacterAdded:Wait()
						local thresholdDistance = 10
						for i, v in pairs(game.Workspace:GetChildren()) do
							local a = v
							pcall(function()
								if a.ClassName == "Model" and #a:GetChildren() > 1 then
									if a:GetAttribute("Id") then
										local c = (a:FindFirstChild(a.Name:lower().."_PESP") or Instance.new("BoxHandleAdornment"))
										c.Name = a.Name:lower().."_PESP"
										c.Parent = a
										c.Adornee = a
										c.AlwaysOnTop = true
										c.ZIndex = 0
										task.spawn(function()
											local d = a:WaitForChild("2")
											c.Size = d.Size
										end)
										c.Transparency = 0.3
										c.Color = BrickColor.new("Magenta")
										local playerPosition = character.HumanoidRootPart.Position
										local partPosition = a.PrimaryPart.Position
										local distance = (playerPosition - partPosition).Magnitude
										if distance <= thresholdDistance then
											bedwars.Client:Get("CollectCollectableEntity"):FireServer({
												["id"] = a:GetAttribute("Id"),
												["collectableName"] = "AlchemyCrystal"
											})
										end
									end
								end
							end)
						end										
					end
				until (not AutoKit.Enabled)
			end)
		end,
		["nazar"] = function()
			task.spawn(function()
				repeat 
					task.wait(0.5)
					if entityLibrary.isAlive then
						bedwars.AbilityController:useAbility("enable_life_force_attack")
						local function shouldUse()
							if not (lplr.Character:FindFirstChild("Humanoid")) then
								local healthbar = pcall(function() return lplr.PlayerGui.hotbar['1'].HotbarHealthbarContainer["1"] end)
								local classname = pcall(function() return healthbar.ClassName end)
								if healthbar and classname == "TextLabel" then 
									local health = tonumber(healthbar.Text)
									if health < 100 then return true, "SucBackup" else return false, "SucBackup" end
								else
									return true, "Backup"
								end
							else
								if lplr.Character.Humanoid.Health < lplr.Character.Humanoid.MaxHealth then return true else return false end
							end
						end
						local val, extra = shouldUse()
						if extra then if shared.VoidDev then print("Using backup method: "..tostring(extra)) end end
						if val then
							bedwars.AbilityController:useAbility("consume_life_foce")
						end
					end
				until (not AutoKit.Enabled)
			end)
		end,
		["necromancer"] = function()
			local function activateGrave(obj)
				if (not obj) then return warn("[AutoKit - necromancer.activateGrave]: No object specified!") end
				local required_args = {
					armorType = obj:GetAttribute("ArmorType"),
					weaponType = obj:GetAttribute("SwordType"),
					associatedPlayerUserId = obj:GetAttribute("GravestonePlayerUserId"),
					secret = obj:GetAttribute("GravestoneSecret"),
					position = obj:GetAttribute("GravestonePosition")
				}
				for i,v in pairs(required_args) do
					if (not v) then return warn("[AutoKit - necromancer.activateGrave]: A required arg is missing! ArgName: "..tostring(i).." ObjectName: "..tostring(obj.Name)) end
				end
				bedwars.Client:Get("ActivateGravestone"):InvokeServer({
					["skeletonData"] = {
						["armorType"] = armorType,
						["weaponType"] = weaponType,
						["associatedPlayerUserId"] = associatedPlayerUserId
					},
					["secret"] = secret,
					["position"] = position
				})
			end
			local function verifyAttributes(obj)
				if (not obj) then return warn("[AutoKit - necromancer.verifyAttributes]: No object specified!") end
				local required_attributes = {"ArmorType", "GravestonePlayerUserId", "GravestonePosition", "GravestoneSecret", "SwordType"}
				for i,v in pairs(required_attributes) do
					if (not obj:GetAttribute(v)) then print(v.." not found in "..obj.Name); return false end
				end
				return true
			end
			task.spawn(function()
				repeat
					task.wait(0.1)
					if entityLibrary.isAlive then
						for i,v in pairs(game.Workspace:GetChildren()) do
							local a = game.Workspace:GetChildren()[i]
							if (not a) then return warn("[AutoKit - Core]: The object went missing before it could get used!") end
							if a.ClassName == "Model" and a:FindFirstChild("Root") and a.Name == "Gravestone" then
								if verifyAttributes(a) then
									local res = activateGrave(a)
									warn("[AutoKit - necromancer.activateGrave - RESULT]: "..tostring(res))
								end
							end
						end
					end
				until (not AutoKit.Enabled)
			end)
		end,
		["jailor"] = function()
			local function activateSoul(obj)
				bedwars.Client:Get("CollectCollectableEntity"):FireServer({
					["id"] = obj:GetAttribute("Id"),
					["collectableName"] = "JailorSoul"
				})
			end
			local function verifyAttributes(obj)
				if obj:GetAttribute("Id") then return true else return false end
			end
			task.spawn(function()
				repeat
					task.wait(0.1)
					if entityLibrary.isAlive then
						for i,v in pairs(game.Workspace:GetChildren()) do
							local a = game.Workspace:GetChildren()[i]
							if (not a) then return warn("[AutoKit - Core]: The object went missing before it could get used!") end
							if a.ClassName == "Model" and a.Name == "JailorSoul" then
								if verifyAttributes(a) then
									local res = activateSoul(a)
									warn("[AutoKit - jailor.activateSoul - RESULT]: "..tostring(res))
								end
							end
						end
					end
				until (not AutoKit.Enabled)
			end)
		end
	}

	AutoKit = vape.Categories.Utility:CreateModule({
		Name = "AutoKit",
		Function = function(callback)
			if callback then
				oldfish = bedwars.FishermanController.startMinigame
				bedwars.FishermanController.startMinigame = function(Self, dropdata, func) func({win = true}) end
				task.spawn(function()
					repeat task.wait() until store.equippedKit ~= ""
					if AutoKit.Enabled then
						if AutoKit_Functions[store.equippedKit] then task.spawn(AutoKit_Functions[store.equippedKit]) end
					end
				end)
			else
				shared.EmberAutoKit = nil
				bedwars.FishermanController.startMinigame = oldfish
				oldfish = nil
			end
		end,
		Tooltip = "Automatically uses a kits ability"
	})
	local function resolveKitName(kitName)
		local repstorage = game:GetService("ReplicatedStorage")
		local KitMeta = bedwars.KitMeta
		if KitMeta[kitName] then return (KitMeta[kitName].name or kitName) else return kitName end
	end
	local function isSupportedKit(kit) if AutoKit_Functions[kit] then return "Supported" else return "Not Supported" end end
	Legit = AutoKit:CreateToggle({
		Name = "Legit",
		Function = function() end
	})
	AutoKitTrinity = AutoKit:CreateDropdown({
		Name = "Angel",
		List = {"Void", "Light"},
		Function = function() end
	})
	AutoKitTrinity.Object.Visible = (store.equippedKit == "angel")
end)

local sendmessage = function() end
sendmessage = function(text)
	local function createBypassMessage(message)
		local charMappings = {
			["a"] = "ɑ", ["b"] = "ɓ", ["c"] = "ɔ", ["d"] = "ɗ", ["e"] = "ɛ",
			["f"] = "ƒ", ["g"] = "ɠ", ["h"] = "ɦ", ["i"] = "ɨ", ["j"] = "ʝ",
			["k"] = "ƙ", ["l"] = "ɭ", ["m"] = "ɱ", ["n"] = "ɲ", ["o"] = "ɵ",
			["p"] = "ρ", ["q"] = "ɋ", ["r"] = "ʀ", ["s"] = "ʂ", ["t"] = "ƭ",
			["u"] = "ʉ", ["v"] = "ʋ", ["w"] = "ɯ", ["x"] = "x", ["y"] = "ɣ",
			["z"] = "ʐ", ["A"] = "Α", ["B"] = "Β", ["C"] = "Ϲ", ["D"] = "Δ",
			["E"] = "Ε", ["F"] = "Ϝ", ["G"] = "Γ", ["H"] = "Η", ["I"] = "Ι",
			["J"] = "ϳ", ["K"] = "Κ", ["L"] = "Λ", ["M"] = "Μ", ["N"] = "Ν",
			["O"] = "Ο", ["P"] = "Ρ", ["Q"] = "Ϙ", ["R"] = "Ϣ", ["S"] = "Ϛ",
			["T"] = "Τ", ["U"] = "ϒ", ["V"] = "ϝ", ["W"] = "Ω", ["X"] = "Χ",
			["Y"] = "Υ", ["Z"] = "Ζ"
		}
		local bypassMessage = ""
		for i = 1, #message do
			local char = message:sub(i, i)
			bypassMessage = bypassMessage .. (charMappings[char] or char)
		end
		return bypassMessage
	end
	--text = text.." | discord.gg/voidware"
	--text = createBypassMessage(text)
	local textChatService = game:GetService("TextChatService")
	local replicatedStorageService = game:GetService("ReplicatedStorage")
	if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
		textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(text)
	else
		replicatedStorageService.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(text, 'All')
	end
end
getgenv().sendmessage = sendmessage

local bedTeamCache = {}
local function get_bed_team(id)
	if bedTeamCache[id] then
		return true, bedTeamCache[id]
	end
	local teamName = "Unknown"
	for _, player in pairs(game:GetService("Players"):GetPlayers()) do
		if player ~= lplr then
			if player:GetAttribute("Team") and tostring(player:GetAttribute("Team")) == tostring(id) then
				teamName = tostring(player.Team)
				break
			end
		end
	end
	bedTeamCache[id] = teamName
	return false, teamName
end

run(function()
	local AutoToxic
	local GG
	local Toggles, Lists, said, dead = {}, {}, {}
	
	local function sendMessage(name, obj, default)
		local tab = Lists[name].ListEnabled
		local custommsg = #tab > 0 and tab[math.random(1, #tab)] or default
		if not custommsg then return end
		if #tab > 1 and custommsg == said[name] then
			repeat 
				task.wait() 
				custommsg = tab[math.random(1, #tab)] 
			until custommsg ~= said[name]
		end
		said[name] = custommsg
	
		custommsg = custommsg and custommsg:gsub('<obj>', obj or '') or ''
		if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
			textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(custommsg)
		else
			replicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(custommsg, 'All')
		end
	end
	
	AutoToxic = vape.Categories.Utility:CreateModule({
		Name = 'AutoToxic',
		Function = function(callback)
			if callback then
				AutoToxic:Clean(vapeEvents.BedwarsBedBreak.Event:Connect(function(bedTable)
					if Toggles.BedDestroyed.Enabled and bedTable.brokenBedTeam.id == lplr:GetAttribute('Team') then
						sendMessage('BedDestroyed', (bedTable.player.DisplayName or bedTable.player.Name), 'how dare you >:( | <obj>')
					elseif Toggles.Bed.Enabled and bedTable.player.UserId == lplr.UserId then
						local team = bedwars.QueueMeta[store.queueType].teams[tonumber(bedTable.brokenBedTeam.id)]
						sendMessage('Bed', team and team.displayName:lower() or 'white', 'nice bed lul | <obj>')
					end
				end))
				AutoToxic:Clean(vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
					if deathTable.finalKill then
						local killer = playersService:GetPlayerFromCharacter(deathTable.fromEntity)
						local killed = playersService:GetPlayerFromCharacter(deathTable.entityInstance)
						if not killed or not killer then return end
						if killed == lplr then
							if (not dead) and killer ~= lplr and Toggles.Death.Enabled then
								dead = true
								sendMessage('Death', (killer.DisplayName or killer.Name), 'my gaming chair subscription expired :( | <obj>')
							end
						elseif killer == lplr and Toggles.Kill.Enabled then
							sendMessage('Kill', (killed.DisplayName or killed.Name), 'vxp on top | <obj>')
						end
					end
				end))
				AutoToxic:Clean(vapeEvents.MatchEndEvent.Event:Connect(function(winstuff)
					if GG.Enabled then
						if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
							textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync('gg')
						else
							replicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer('gg', 'All')
						end
					end
					
					local myTeam = bedwars.Store:getState().Game.myTeam
					if myTeam and myTeam.id == winstuff.winningTeamId or lplr.Neutral then
						if Toggles.Win.Enabled then 
							sendMessage('Win', nil, 'yall garbage') 
						end
					end
				end))
			end
		end,
		Tooltip = 'Says a message after a certain action'
	})
	GG = AutoToxic:CreateToggle({
		Name = 'AutoGG',
		Default = true
	})
	for _, v in {'Kill', 'Death', 'Bed', 'BedDestroyed', 'Win'} do
		Toggles[v] = AutoToxic:CreateToggle({
			Name = v..' ',
			Function = function(callback)
				if Lists[v] then
					Lists[v].Object.Visible = callback
				end
			end
		})
		Lists[v] = AutoToxic:CreateTextList({
			Name = v,
			Darker = true,
			Visible = false
		})
	end
end)

run(function()
	local ChestStealer = {Enabled = false}
	local ChestStealerDistance = {Value = 1}
	local ChestStealerDelay = {Value = 1}
	local ChestStealerOpen = {Enabled = false}
	local ChestStealerSkywars = {Enabled = true}
	local doneChests = {}
	local cheststealerdelays = {}
	local chests = {}
	local cheststealerfuncs = {
		Open = function()
			if bedwars.AppController:isAppOpen("ChestApp") then
				local chest = lplr.Character:FindFirstChild("ObservedChestFolder")
				if table.find(doneChests, chest) then return end
				table.insert(doneChests, chest)
				local chestitems = chest and chest.Value and chest.Value:GetChildren() or {}
				if #chestitems > 0 then
					for i3,v3 in pairs(chestitems) do
						if v3:IsA("Accessory") and (cheststealerdelays[v3] == nil or cheststealerdelays[v3] < tick()) then
							task.spawn(function()
								pcall(function()
									cheststealerdelays[v3] = tick() + 0.2
									bedwars.Client:GetNamespace("Inventory"):Get("ChestGetItem"):InvokeServer(chest.Value, v3)
								end)
							end)
							task.wait(ChestStealerDelay.Value / 100)
						end
					end
				end
			end
		end,
		Closed = function()
			for i, v in pairs(chests) do
				if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= ChestStealerDistance.Value then
					local chest = v:FindFirstChild("ChestFolderValue")
					chest = chest and chest.Value or nil
					if table.find(doneChests, chest) then return end
					local chestitems = chest and chest:GetChildren() or {}
					if #chestitems > 0 then
						bedwars.Client:GetNamespace("Inventory"):Get("SetObservedChest"):FireServer(chest)
						for i3,v3 in pairs(chestitems) do
							task.wait(0.1)
							if v3:IsA("Accessory") and (cheststealerdelays[v3] == nil or cheststealerdelays[v3] < tick()) then
								task.spawn(function()
									pcall(function()
										cheststealerdelays[v3] = tick() + 0.2
										bedwars.Client:GetNamespace("Inventory"):Get("ChestGetItem"):InvokeServer(v.ChestFolderValue.Value, v3)
									end)
								end)
								task.wait(ChestStealerDelay.Value / 100)
							end
						end
						bedwars.Client:GetNamespace("Inventory"):Get("SetObservedChest"):FireServer(nil)
					end
					table.insert(doneChests, chest)
				end
			end
		end
	}

	ChestStealer = vape.Categories.Utility:CreateModule({
		Name = "ChestStealer",
		Function = function(callback)
			if callback then
				local chests = collection('chest', ChestSteal)
				task.spawn(function()
					repeat task.wait(5)
						chests = collectionService:GetTagged("chest")
					until (not ChestStealer.Enabled)
				end)
				task.spawn(function()
					repeat task.wait() until store.matchState > 0
					repeat
						task.wait(0.9)
						if entityLibrary.isAlive then
							cheststealerfuncs[ChestStealerOpen.Enabled and "Open" or "Closed"]()
						end
					until (not ChestStealer.Enabled)
				end)
			else table.clear(doneChests) end
		end,
		Tooltip = "Grabs items from near chests."
	})
	ChestStealerDistance = ChestStealer:CreateSlider({
		Name = "Range",
		Min = 0,
		Max = 18,
		Function = function() end,
		Default = 18
	})
	ChestStealerDelay = ChestStealer:CreateSlider({
		Name = "Delay",
		Min = 1,
		Max = 50,
		Function = function() end,
		Default = 1,
		Double = 100
	})
	ChestStealerOpen = ChestStealer:CreateToggle({
		Name = "GUI Check",
		Function = function() end
	})
	--[[ChestStealerSkywars = ChestStealer:CreateToggle({
		Name = "Only Skywars",
		Function = function() end,
		Default = true
	})--]]
end)

run(function()
	local PickupRangeRange = {Value = 1}
	local PickupRange = {Enabled = false}
	PickupRange = vape.Categories.Utility:CreateModule({
		Name = "PickupRange",
		Function = function(callback)
			if callback then
				local pickedup = {}
				task.spawn(function()
					repeat
						local itemdrops = collectionService:GetTagged("ItemDrop")
						for i,v in pairs(itemdrops) do
							if entityLibrary.isAlive and (v:GetAttribute("ClientDropTime") and tick() - v:GetAttribute("ClientDropTime") > 2 or v:GetAttribute("ClientDropTime") == nil) then
								if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= PickupRangeRange.Value and (pickedup[v] == nil or pickedup[v] <= tick()) then
									task.spawn(function()
										pickedup[v] = tick() + 0.2
										bedwars.Client:Get(bedwars.PickupRemote):InvokeServer({itemDrop = v})
									end)
								end
							end
						end
						task.wait(0.2)
					until (not PickupRange.Enabled)
				end)
			end
		end
	})
	PickupRangeRange = PickupRange:CreateSlider({
		Name = "Range",
		Min = 1,
		Max = 10,
		Function = function() end,
		Default = 10
	})
end)

run(function()
	local RavenTP = {Enabled = false}
	local RavenTPMode = {Value = "Toggle"}
	local function Raven()
		task.spawn(function()
			if getItem("raven") then
				local plr = EntityNearMouse(1000)
				if plr then
					local projectile = bedwars.Client:Get(bedwars.SpawnRavenRemote, nil, true):InvokeServer():andThen(function(projectile)
						if projectile then
							local projectilemodel = projectile
							if not projectilemodel then
								projectilemodel:GetPropertyChangedSignal("PrimaryPart"):Wait()
							end
							local bodyforce = Instance.new("BodyForce")
							bodyforce.Force = Vector3.new(0, projectilemodel.PrimaryPart.AssemblyMass * game.Workspace.Gravity, 0)
							bodyforce.Name = "AntiGravity"
							bodyforce.Parent = projectilemodel.PrimaryPart

							if plr then
								projectilemodel:SetPrimaryPartCFrame(CFrame.new(plr.RootPart.CFrame.p, plr.RootPart.CFrame.p + gameCamera.CFrame.lookVector))
								task.wait(0.3)
								bedwars.RavenController:detonateRaven()
							else
								if RavenTPMode.Value ~= "Toggle" then
									warningNotification("RavenTP", "Player died before it could TP.", 3)
								end
							end
						else
							if RavenTPMode.Value ~= "Toggle" then
								warningNotification("RavenTP", "Raven on cooldown.", 3)
							end
						end
					end)
				else
					if RavenTPMode.Value ~= "Toggle" then
						warningNotification("RavenTP", "Player not found.", 3)
					end
				end
			else
				if RavenTPMode.Value ~= "Toggle" then
					warningNotification("RavenTP", "Raven not found.", 3)
				end
			end
		end)
	end
	RavenTP = vape.Categories.Utility:CreateModule({
		Name = "RavenTP",
		Function = function(callback)
			if callback then
				pcall(function()
					if RavenTPMode.Value ~= "Toggle" then
						Raven()
						RavenTP:Toggle(true)
					else
						repeat Raven() task.wait() until not RavenTP.Enabled
					end
				end)
			end
		end,
		Tooltip = "Spawns and teleports a raven to a player\nnear your mouse."
	})
	RavenTPMode = RavenTP:CreateDropdown({
		Name = "Activation",
		List = {"On Key", "Toggle"},
		Function = function(val)
			if RavenTP.Enabled then
				RavenTP:Toggle(false)
				RavenTP:Toggle(false)
			end
		end
	})
end)

local lagbackedaftertouch = false
run(function()
	local AntiVoidPart
	local AntiVoidConnection
	local AntiVoidMode = {Value = "Normal"}
	local AntiVoidMoveMode = {Value = "Normal"}
	local AntiVoid = {Enabled = false, Connections = {}}
	local AntiVoidTransparent = {Value = 50}
	local AntiVoidColor = {Hue = 1, Sat = 1, Value = 0.55}
	local lastvalidpos

	local GuiSync = {Enabled = false}

	local function closestpos(block)
		local startpos = block.Position - (block.Size / 2) + Vector3.new(1.5, 1.5, 1.5)
		local endpos = block.Position + (block.Size / 2) - Vector3.new(1.5, 1.5, 1.5)
		local newpos = block.Position + (entityLibrary.character.HumanoidRootPart.Position - block.Position)
		return Vector3.new(math.clamp(newpos.X, startpos.X, endpos.X), endpos.Y + 3, math.clamp(newpos.Z, startpos.Z, endpos.Z))
	end

	local function getclosesttop(newmag)
		local closest, closestmag = nil, newmag * 3
		if entityLibrary.isAlive then
			local tops = {}
			for i,v in pairs(store.blocks) do
				local close = getScaffold(closestpos(v), false)
				if getPlacedBlock(close) then continue end
				if close.Y < entityLibrary.character.HumanoidRootPart.Position.Y then continue end
				if (close - entityLibrary.character.HumanoidRootPart.Position).magnitude <= newmag * 3 then
					table.insert(tops, close)
				end
			end
			for i,v in pairs(tops) do
				local mag = (v - entityLibrary.character.HumanoidRootPart.Position).magnitude
				if mag <= closestmag then
					closest = v
					closestmag = mag
				end
			end
		end
		return closest
	end

	local antivoidypos = 20
	local antivoiding = false
	AntiVoid = vape.Categories.World:CreateModule({
		Name = "AntiVoid",
		Function = function(callback)
			if callback then
				task.spawn(function()
					AntiVoidPart = Instance.new("Part")
					AntiVoidPart.CanCollide = AntiVoidMode.Value == "Collide"
					AntiVoidPart.Size = Vector3.new(10000, 1, 10000)
					AntiVoidPart.Anchored = true
					shared.AntiVoidPart = AntiVoidPart
					AntiVoidPart.Material = Enum.Material.Neon
					AntiVoidPart.Color = Color3.fromHSV(AntiVoidColor.Hue, AntiVoidColor.Sat, AntiVoidColor.Value)
					AntiVoidPart.Transparency = 1 - (AntiVoidTransparent.Value / 100)
					AntiVoidPart.Position = Vector3.new(0, antivoidypos, 0)
					AntiVoidPart.Parent = game.Workspace
					if AntiVoidMoveMode.Value == "Classic" and antivoidypos == 0 then
						AntiVoidPart.Parent = nil
					end
					if GuiSync.Enabled then
						pcall(function()
							if shared.RiseMode and GuiLibrary.GUICoreColor and GuiLibrary.GUICoreColorChanged then
								AntiVoidPart.Color = GuiLibrary.GUICoreColor
								AntiVoid:Clean(GuiLibrary.GUICoreColorChanged.Event:Connect(function()
									if AntiVoid.Enabled and GuiSync.Enabled then
										AntiVoidPart.Color = GuiLibrary.GUICoreColor
									end
								end))
							else
								local color = vape.GUIColor
								AntiVoidPart.Color = Color3.fromHSV(color.Hue, color.Sat, color.Value)
								AntiVoid:Clean(runservice.RenderStepped:Connect(function()
									if AntiVoid.Enabled then
										print('vape.guicolor: '..tostring(color))
										color = vape.GUIColor
										AntiVoidPart.Color = Color3.fromHSV(color.Hue, color.Sat, color.Value)
									end
								end))
							end
						end)
					end
					AntiVoidConnection = AntiVoidPart.Touched:Connect(function(touchedpart)
						if touchedpart.Parent == lplr.Character and entityLibrary.isAlive then
							if (not antivoiding) and (not vape.Modules.Fly.Enabled) and entityLibrary.character.Humanoid.Health > 0 and AntiVoidMode.Value ~= "Collide" then
								if AntiVoidMode.Value == "Velocity" then
									entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, 100, entityLibrary.character.HumanoidRootPart.Velocity.Z)
								else
									antivoiding = true
									local pos = getclosesttop(1000)
									if pos then
										local lastTeleport = lplr:GetAttribute("LastTeleported")
										AntiVoid:Clean(runservice.Heartbeat:Connect(function(dt)
											if entityLibrary.isAlive and entityLibrary.character.Humanoid.Health > 0 and isnetworkowner(entityLibrary.character.HumanoidRootPart) and (entityLibrary.character.HumanoidRootPart.Position - pos).Magnitude > 1 and AntiVoid.Enabled and lplr:GetAttribute("LastTeleported") == lastTeleport then
												local hori1 = Vector3.new(entityLibrary.character.HumanoidRootPart.Position.X, 0, entityLibrary.character.HumanoidRootPart.Position.Z)
												local hori2 = Vector3.new(pos.X, 0, pos.Z)
												local newpos = (hori2 - hori1).Unit
												local realnewpos = CFrame.new(newpos == newpos and entityLibrary.character.HumanoidRootPart.CFrame.p + (newpos * ((3 + getSpeed()) * dt)) or Vector3.zero)
												entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(realnewpos.p.X, pos.Y, realnewpos.p.Z)
												antivoidvelo = newpos == newpos and newpos * 20 or Vector3.zero
												entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(antivoidvelo.X, entityLibrary.character.HumanoidRootPart.Velocity.Y, antivoidvelo.Z)
												if getPlacedBlock((entityLibrary.character.HumanoidRootPart.CFrame.p - Vector3.new(0, 1, 0)) + entityLibrary.character.HumanoidRootPart.Velocity.Unit) or getPlacedBlock(entityLibrary.character.HumanoidRootPart.CFrame.p + Vector3.new(0, 3)) then
													pos = pos + Vector3.new(0, 1, 0)
												end
											else
												antivoidvelo = nil
												antivoiding = false
											end
										end))
									else
										entityLibrary.character.HumanoidRootPart.CFrame += Vector3.new(0, 100000, 0)
										antivoiding = false
									end
								end
							end
						end
					end)
					repeat
						if entityLibrary.isAlive and AntiVoidMoveMode.Value == "Normal" then
							local ray = game.Workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(0, -1000, 0), store.blockRaycast)
							if ray or vape.Modules.Fly.Enabled or vape.Modules.InfiniteFly.Enabled then
								AntiVoidPart.Position = entityLibrary.character.HumanoidRootPart.Position - Vector3.new(0, 21, 0)
							end
						end
						task.wait()
					until (not AntiVoid.Enabled)
				end)
			else
				if AntiVoidConnection then AntiVoidConnection:Disconnect() end
				if AntiVoidPart then
					AntiVoidPart:Destroy()
				end
			end
		end,
		Tooltip = "Gives you a chance to get on land (Bouncing Twice, abusing, or bad luck will lead to lagbacks)"
	})
	AntiVoid.Restart = function() if AntiVoid.Enbaled then AntiVoid:Toggle(false); AntiVoid:Toggle(false) end end
	AntiVoidMoveMode = AntiVoid:CreateDropdown({
		Name = "Position Mode",
		Function = function(val)
			if val == "Classic" then
				task.spawn(function()
					repeat task.wait() until store.matchState ~= 0 or not vapeInjected
					if vapeInjected and AntiVoidMoveMode.Value == "Classic" and antivoidypos == 0 and AntiVoid.Enabled then
						local lowestypos = 99999
						for i,v in pairs(store.blocks) do
							local newray = game.Workspace:Raycast(v.Position + Vector3.new(0, 800, 0), Vector3.new(0, -1000, 0), store.blockRaycast)
							if i % 200 == 0 then
								task.wait(0.06)
							end
							if newray and newray.Position.Y <= lowestypos then
								lowestypos = newray.Position.Y
							end
						end
						antivoidypos = lowestypos - 8
					end
					if AntiVoidPart then
						AntiVoidPart.Position = Vector3.new(0, antivoidypos, 0)
						AntiVoidPart.Parent = game.Workspace
					end
				end)
			end
		end,
		List = {"Normal", "Classic"}
	})
	AntiVoidMode = AntiVoid:CreateDropdown({
		Name = "Move Mode",
		Function = function(val)
			if AntiVoidPart then
				AntiVoidPart.CanCollide = val == "Collide"
			end
		end,
		List = {"Normal", "Collide", "Velocity"}
	})
	AntiVoidTransparent = AntiVoid:CreateSlider({
		Name = "Invisible",
		Min = 1,
		Max = 100,
		Default = 50,
		Function = function(val)
			if AntiVoidPart then
				AntiVoidPart.Transparency = 1 - (val / 100)
			end
		end,
	})
	AntiVoidColor = AntiVoid:CreateColorSlider({
		Name = "Color",
		Function = function(h, s, v)
			if AntiVoidPart then
				AntiVoidPart.Color = Color3.fromHSV(h, s, v)
			end
		end
	})
	GuiSync = AntiVoid:CreateToggle({
		Name = "GUI Color Sync",
		Function = function(call)
			pcall(function() AntiVoidColor.Object.Visible = not call end)	
			AntiVoid.Restart()
		end
	})
end)

run(function()
	local BedProtector
	local Priority
	local Layers 
	local CPS 
	local Mode
	local BlockTypeCheck 
	local AutoSwitch 
	local HandCheck 
    
    local function getBedNear()
        local localPosition = entitylib.isAlive and entitylib.character.RootPart.Position or Vector3.zero
        for _, v in collectionService:GetTagged('bed') do
            if (localPosition - v.Position).Magnitude < 20 and v:GetAttribute('Team'..(lplr:GetAttribute('Team') or -1)..'NoBreak') then
                return v
            end
        end
    end

	local function isAllowed(block)
		if not BlockTypeCheck.Enabled then return true end
		local allowed = {"wool", "stone_brick", "wood_plank_oak", "ceramic", "obsidian"}
		for _,v in pairs(allowed) do
			if string.find(string.lower(tostring(block)), v) then 
				return true
			end
		end
		return false
	end

	local function getBlocks()
        local blocks = {}
		for _, item in store.inventory.inventory.items do
            local block = bedwars.ItemMeta[item.itemType].block
            if block and isAllowed(item.itemType) then
                table.insert(blocks, {itemType = item.itemType, health = block.health, tool = item.tool})
            end
        end

        local priorityMap = {}
        for i, v in pairs(Priority.ListEnabled) do
			local core = v:split("/")
            local blockType, layer = core[1], core[2]
            if blockType and layer then
                priorityMap[blockType] = tonumber(layer)
            end
        end

        local prioritizedBlocks = {}
        local fallbackBlocks = {}

        for _, block in pairs(blocks) do
			local prioLayer
			for i,v in pairs(priorityMap) do
				if string.find(string.lower(tostring(block.itemType)), string.lower(tostring(i))) then
					prioLayer = v
					break
				end
			end
            if prioLayer then
                table.insert(prioritizedBlocks, {itemType = block.itemType, health = block.health, layer = prioLayer, tool = block.tool})
            else
                table.insert(fallbackBlocks, {itemType = block.itemType, health = block.health, tool = block.tool})
            end
        end

        table.sort(prioritizedBlocks, function(a, b)
            return a.layer < b.layer
        end)

        table.sort(fallbackBlocks, function(a, b)
            return a.health > b.health
        end)

        local finalBlocks = {}
        for _, block in pairs(prioritizedBlocks) do
            table.insert(finalBlocks, {block.itemType, block.health})
        end
        for _, block in pairs(fallbackBlocks) do
            table.insert(finalBlocks, {block.itemType, block.health})
        end

        return finalBlocks
    end
    
    local function getPyramid(size, grid)
        local positions = {}
        for h = size, 0, -1 do
            for w = h, 0, -1 do
                table.insert(positions, Vector3.new(w, (size - h), ((h + 1) - w)) * grid)
                table.insert(positions, Vector3.new(w * -1, (size - h), ((h + 1) - w)) * grid)
                table.insert(positions, Vector3.new(w, (size - h), (h - w) * -1) * grid)
                table.insert(positions, Vector3.new(w * -1, (size - h), (h - w) * -1) * grid)
            end
        end
        return positions
    end

    local function tblClone(cltbl)
        local restbl = table.clone(cltbl)
        for i, v in pairs(cltbl) do
            table.insert(restbl, v)
        end
        return restbl
    end

    local function cleantbl(restbl, req)
        for i = #restbl, req + 1, -1 do
            table.remove(restbl, i)
        end
        return restbl
    end

    local res_attempts = 0

	local autoCheckLoop

	local function autoCheck()
		if not BedProtector.Enabled or Mode.Value ~= "Toggle" then return end

		local bed = getBedNear()
		if not bed then return end

		local bedPos = bed.Position
		local playerPos = entitylib.isAlive and entitylib.character.RootPart.Position or Vector3.zero
		local distance = (playerPos - bedPos).Magnitude

		if distance < 12 then
			local blocks = getBlocks()
			if #blocks == 0 then return end

			local positions = getPyramid(Layers.Value - 1, 3)
			for _, pos in ipairs(positions) do
				local blockPos = bedPos + pos
				if not getPlacedBlock(blockPos) then
					bedwars.placeBlock(blockPos, blocks[1][1], false)
					task.wait(1 / CPS.Value)
				end
			end
		end
	end

	local function startAutoLoop()
		if autoCheckLoop then return end
		autoCheckLoop = task.spawn(function()
			while BedProtector.Enabled and Mode.Value == "Toggle" do
				autoCheck()
				task.wait(1.5)
			end
			autoCheckLoop = nil
		end)
	end

	local function stopAutoLoop()
		if autoCheckLoop then
			task.cancel(autoCheckLoop)
			autoCheckLoop = nil
		end
	end
    
	local function buildProtection(bedPos, blocks, layers, cps)
        local delay = 1 / cps 
        local blockIndex = 1
        local posIndex = 1
        
        local function placeNextBlock()
            if not BedProtector.Enabled or blockIndex > layers then
                BedProtector:Toggle()
                return
            end

            local block = blocks[blockIndex]
            if not block then
                BedProtector:Toggle()
                return
            end

			if AutoSwitch.Enabled then
				switchItem(block.tool)
			end

            local positions = getPyramid(blockIndex - 1, 3) 
            if posIndex > #positions then
                blockIndex = blockIndex + 1
                posIndex = 1
                task.delay(delay, placeNextBlock)
                return
            end

            local pos = positions[posIndex]
            if not getPlacedBlock(bedPos + pos) then
                bedwars.placeBlock(bedPos + pos, block[1], false)
            end
            
            posIndex = posIndex + 1
            task.delay(delay, placeNextBlock)
        end
        
        placeNextBlock()
    end

	BedProtector = vape.Categories.World:CreateModule({
        Name = 'BedProtector',
        Function = function(callback)
            if callback then
				if Mode.Value == "Toggle" then
					startAutoLoop()
					return
				end

                local bed = getBedNear()
                local bedPos = bed and bed.Position
                if bedPos then
					if HandCheck.Enabled and not AutoSwitch.Enabled then
						if not (store.hand and store.hand.toolType == "block") then
							errorNotification("BedProtector | Hand Check", "You aren't holding a block!", 1.5)
							BedProtector:Toggle()
							return
						end
					end

                    local blocks = getBlocks()
                    if #blocks == 0 then 
                        warningNotification("BedProtector", "No blocks for bed defense found!", 3) 
						BedProtector:Toggle()
                        return 
                    end
                    
                    if #blocks < Layers.Value then
                        repeat 
                            blocks = tblClone(blocks)
                            blocks = cleantbl(blocks, Layers.Value)
                            task.wait()
                            res_attempts = res_attempts + 1
                        until #blocks == Layers.Value or res_attempts > (Layers.Value < 10 and Layers.Value or 10)
                    elseif #blocks > Layers.Value then
                        blocks = cleantbl(blocks, Layers.Value)
                    end
                    res_attempts = 0
                    
                    buildProtection(bedPos, blocks, Layers.Value, CPS.Value)
                else
                    notif('BedProtector', 'Please get closer to your bed!', 3)
                    BedProtector:Toggle()
                end
            else
				stopAutoLoop()
                res_attempts = 0
            end
        end,
        Tooltip = 'Automatically places strong blocks around the bed with customizable speed.'
    })
	
    Layers = BedProtector:CreateSlider({
        Name = "Layers",
        Function = function() end,
        Min = 1,
        Max = 10,
        Default = 2,
    	Tooltip = "Number of protective layers around the bed"
    })

    CPS = BedProtector:CreateSlider({
        Name = "CPS",
        Function = function() end,
        Min = 5,
        Max = 50,
        Default = 50,
       	Tooltip = "Blocks placed per second"
    })

	AutoSwitch = BedProtector:CreateToggle({
		Name = "Auto Switch",
		Function = function() end,
		Default = true
	})

	Mode = BedProtector:CreateDropdown({
		Name = 'Mode',
		List = {'Toggle', 'On Key'},
		Function = function(val)
			if val == "Toggle" and BedProtector.Enabled then
				startAutoLoop()
			else
				stopAutoLoop()
			end
		end,
		Default = "On Key"
	})

	HandCheck = BedProtector:CreateToggle({
		Name = "Hand Check",
		Function = function() end
	})

	BlockTypeCheck = BedProtector:CreateToggle({
		Name = "Block Type Check",
		Function = function() end,
		Default = true
	})

	Priority = BedProtector:CreateTextList({
		Name = "Block/Layer",
		Function = function() end,
		TempText = "block/layer",
		SortFunction = function(a, b)
			local layer1 = a:split("/")
			local layer2 = b:split("/")
			layer1 = #layer1 and tonumber(layer1[2]) or 1
			layer2 = #layer2 and tonumber(layer2[2]) or 1
			return layer1 < layer2
		end
	})
end)

run(function()
	bedwars.BlockBreaker = {
		healthbarMaid = {
			DoCleaning = function(self)
				self._tasks = self._tasks or {}
				for i,v in pairs(self._tasks) do
					if type(v) == "function" then pcall(v) end
				end
				table.clear(self._tasks)
			end,
			GiveTask = function(self, task)
				self._tasks = self._tasks or {}
				table.insert(self._tasks, task)
			end
		},
		breakEffect = {
			playBreak = function(self, blockName, blockPosition, plr) end,
			playHit = function(self, blockName, blockPosition, plr) end
		}
	}
	local blockCache = {}
	local function customHealthbar(self, blockRef, health, maxHealth, changeHealth, block)
		if block:GetAttribute('NoHealthbar') then return end
		if not bedwars.ItemMeta[block.Name] then return end
		if not self.healthbarPart or not self.healthbarBlockRef or self.healthbarBlockRef.blockPosition ~= blockRef.blockPosition then
			self.healthbarMaid:DoCleaning()
			self.healthbarBlockRef = blockRef
			local create = bedwars.Roact.createElement
			local suc, res = pcall(function() return math.clamp(health / maxHealth, 0, 1) end)
			local percent = suc and res or 0.5
			local cleanCheck = true
			local part = Instance.new('Part')
			part.Size = Vector3.one
			part.CFrame = CFrame.new(blockRef.blockPosition*3)
			part.Transparency = 1
			part.Anchored = true
			part.CanCollide = false
			part.Parent = workspace
			self.healthbarPart = part
			bedwars.QueryUtil:setQueryIgnored(self.healthbarPart, true)
	
			local mounted = bedwars.Roact.mount(create('BillboardGui', {
				Size = UDim2.fromOffset(249, 102),
				StudsOffset = Vector3.new(0, 2.5, 0),
				Adornee = part,
				MaxDistance = 40,
				AlwaysOnTop = true
			}, {
				create('Frame', {
					Size = UDim2.fromOffset(160, 50),
					Position = UDim2.fromOffset(44, 32),
					BackgroundColor3 = Color3.new(),
					BackgroundTransparency = 0.5
				}, {
					create('UICorner', {CornerRadius = UDim.new(0, 5)}),
					create('ImageLabel', {
						Size = UDim2.new(1, 89, 1, 52),
						Position = UDim2.fromOffset(-48, -31),
						BackgroundTransparency = 1,
						Image = "rbxassetid://14898786664",
						ScaleType = Enum.ScaleType.Slice,
						SliceCenter = Rect.new(52, 31, 261, 502)
					}),
					create('TextLabel', {
						Size = UDim2.fromOffset(145, 14),
						Position = UDim2.fromOffset(13, 12),
						BackgroundTransparency = 1,
						Text = bedwars.ItemMeta[block.Name].displayName or block.Name,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
						TextColor3 = Color3.new(),
						TextScaled = true,
						Font = Enum.Font.Arial
					}),
					create('TextLabel', {
						Size = UDim2.fromOffset(145, 14),
						Position = UDim2.fromOffset(12, 11),
						BackgroundTransparency = 1,
						Text = bedwars.ItemMeta[block.Name].displayName or block.Name,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
						TextColor3 = color.Dark(uipallet.Text, 0.16),
						TextScaled = true,
						Font = Enum.Font.Arial
					}),
					create('Frame', {
						Size = UDim2.fromOffset(138, 4),
						Position = UDim2.fromOffset(12, 32),
						BackgroundColor3 = uipallet.Main
					}, {
						create('UICorner', {CornerRadius = UDim.new(1, 0)}),
						create('Frame', {
							[bedwars.Roact.Ref] = self.healthbarProgressRef,
							Size = UDim2.fromScale(percent, 1),
							BackgroundColor3 = Color3.fromHSV(math.clamp(percent / 2.5, 0, 1), 0.89, 0.75)
						}, {create('UICorner', {CornerRadius = UDim.new(1, 0)})})
					})
				})
			}), part)
	
			self.healthbarMaid:GiveTask(function()
				cleanCheck = false
				self.healthbarBlockRef = nil
				bedwars.Roact.unmount(mounted)
				if self.healthbarPart then
					self.healthbarPart:Destroy()
				end
				self.healthbarPart = nil
			end)
	
			bedwars.RuntimeLib.Promise.delay(5):andThen(function()
				if cleanCheck then
					self.healthbarMaid:DoCleaning()
				end
			end)
		end
		self.healthbarPart.CFrame = CFrame.new(blockRef.blockPosition*3)
		local newpercent = math.clamp((health - changeHealth) / maxHealth, 0, 1)
		tweenService:Create(self.healthbarPart:WaitForChild("BillboardGui"):WaitForChild("Frame"):WaitForChild("Frame"):WaitForChild("Frame"), TweenInfo.new(0.3), {
			Size = UDim2.fromScale(newpercent, 1), BackgroundColor3 = Color3.fromHSV(math.clamp(newpercent / 2.5, 0, 1), 0.89, 0.75)
		}):Play()
	end

	local healthbarblocktable = {
		blockHealth = -1,
		breakingBlockPosition = Vector3.zero
	}

	local function getLastCovered(pos, normal)
		local lastfound, lastpos = nil, nil
		for i = 1, 20 do
			local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
			local extrablock, extrablockpos = getPlacedBlock(blockpos)
			local covered = isBlockCovered(blockpos)
			if extrablock then
				lastfound, lastpos = extrablock, extrablockpos
				if not covered then
					break
				end
			else
				break
			end
		end
		return lastfound, lastpos
	end

	local function get(block, att)
		local suc, err = pcall(function() return block:GetAttribute(att) end)
		return suc and err or ""
	end

	local function isblockbreakable(block, plr)
		if tostring(block) == "Part" then return false end
		if get(block, "NoBreak") ~= "true" and get(block, "PlacedByUserId") ~= tostring(lplr.UserId) then 
			return true 
		else 
			return false 
		end
	end

	local VisualizerHighlight = nil
    local LastBlock = nil
    local VisualizerTimeout = 1
    local LastBreakTime = 0
    local IsBreaking = false

	local function updateVisualizer(block, isBreaking)
        local currentTime = tick()

        if not isBreaking and not block then
            if VisualizerHighlight then
                VisualizerHighlight:Destroy()
                VisualizerHighlight = nil
            end
            LastBlock = nil
            LastBreakTime = 0
            IsBreaking = false
            return
        end

        if block then
            local blockKey = tostring(block.Position) 

            if blockKey ~= LastBlock or not VisualizerHighlight or not VisualizerHighlight.Parent then
                if VisualizerHighlight then
                    VisualizerHighlight:Destroy()
                end

                VisualizerHighlight = Instance.new("Highlight")
                VisualizerHighlight.Adornee = block
                VisualizerHighlight.FillTransparency = 1
                VisualizerHighlight.OutlineTransparency = 0.3 
                VisualizerHighlight.Parent = workspace

                VisualizerHighlight.OutlineColor = (blockKey ~= LastBlock) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 165, 0)
                LastBlock = blockKey
            end

            IsBreaking = isBreaking
            LastBreakTime = currentTime

            task.spawn(function()
                while VisualizerHighlight and VisualizerHighlight.Parent and (tick() - LastBreakTime < VisualizerTimeout) and IsBreaking do
                    task.wait(0.1)
                end
                if VisualizerHighlight and VisualizerHighlight.Parent then
                    VisualizerHighlight:Destroy()
                    VisualizerHighlight = nil
                    LastBlock = nil
                    IsBreaking = false
                end
            end)
        end
    end
	
	local nearestBed

	local breakBlock = function(pos, effects, normal, bypass, anim)
		if vape.Modules.InfiniteFly and vape.Modules.InfiniteFly.Enabled then
			return
		end
		if lplr:GetAttribute("DenyBlockBreak") then
			return
		end
		local block, blockpos = nil, nil
		if not bypass then block, blockpos = getLastCovered(pos, normal) end
		if not block then blockpos, block = bedwars.BlockController:getBlockPosition(pos, nearestBed) end
		updateVisualizer(block, true)
		if not isblockbreakable(block, lplr) then blockpos, block = nil, nil end
		if blockpos and block then
			local blockhealthbarpos = {blockPosition = Vector3.zero}
			local blockdmg = 0
			if block and block.Parent ~= nil then
				if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - (blockpos * 3)).magnitude > 30 then return end
				store.blockPlace = tick() + 0.1
				switchToAndUseTool(block)
				blockhealthbarpos = {
					blockPosition = blockpos
				}
				task.spawn(function()
					bedwars.ClientDamageBlock:Get("DamageBlock"):CallServerAsync({
						blockRef = blockhealthbarpos,
						hitPosition = blockpos * 3,
						hitNormal = Vector3.FromNormalId(normal)
					}):andThen(function(result)
						if result ~= "failed" then
							failedBreak = 0
							if healthbarblocktable.blockHealth == -1 or blockhealthbarpos.blockPosition ~= healthbarblocktable.breakingBlockPosition then
								local blockhealth = block:GetAttribute("Health")
								healthbarblocktable.blockHealth = blockhealth
								healthbarblocktable.breakingBlockPosition = blockhealthbarpos.blockPosition
							end
							healthbarblocktable.blockHealth = result == "destroyed" and 0 or healthbarblocktable.blockHealth
							blockhealthbarpos.block = block
							blockdmg = bedwars.BlockController:calculateBlockDamage(lplr, blockhealthbarpos)
							if not healthbarblocktable.blockHealth then 
								healthbarblocktable.blockHealth = block:GetAttribute("Health")
							end
							if not healthbarblocktable.blockHealth then healthbarblocktable.blockHealth = blockdmg*3 end
							healthbarblocktable.blockHealth = math.max(healthbarblocktable.blockHealth - blockdmg, 0)
							if effects then
								bedwars.BlockBreaker.healthbarBlockRef = blockhealthbarpos
								customHealthbar(bedwars.BlockBreaker, blockhealthbarpos, healthbarblocktable.blockHealth, block:GetAttribute("MaxHealth"), blockdmg, block)
								if healthbarblocktable.blockHealth <= 0 then
									bedwars.BlockBreaker.breakEffect:playBreak(block.Name, blockhealthbarpos.blockPosition, lplr)
									bedwars.BlockBreaker.healthbarMaid:DoCleaning()
									healthbarblocktable.breakingBlockPosition = Vector3.zero
								else
									bedwars.BlockBreaker.breakEffect:playHit(block.Name, blockhealthbarpos.blockPosition, lplr)
								end
							end
							local animation
							if anim then
								animation = bedwars.AnimationUtil:playAnimation(lplr, bedwars.BlockController:getAnimationController():getAssetId(1))
								bedwars.ViewmodelController:playAnimation(15)
							end
							task.wait(0.3)
							if animation ~= nil then
								animation:Stop()
								animation:Destroy()
							end
						else
							failedBreak = failedBreak + 1
						end
					end)
				end)
				task.wait(physicsUpdate)
			end
		end
	end
	
	local sides = {}
    for _, v in Enum.NormalId:GetEnumItems() do
        if v.Name == "Bottom" then continue end
        table.insert(sides, Vector3.FromNormalId(v) * 3)
    end

    local function findClosestBreakableBlock(start, playerPos)
		local closestBlock = nil
		local closestDistance = math.huge
		local closestPos = nil
		local closestNormal = nil

		local vectorToNormalId = {
			[Vector3.new(1, 0, 0)] = Enum.NormalId.Right,
			[Vector3.new(-1, 0, 0)] = Enum.NormalId.Left,
			[Vector3.new(0, 1, 0)] = Enum.NormalId.Top,
			[Vector3.new(0, -1, 0)] = Enum.NormalId.Bottom,
			[Vector3.new(0, 0, 1)] = Enum.NormalId.Front,
			[Vector3.new(0, 0, -1)] = Enum.NormalId.Back
		}

		for _, side in sides do
			for i = 1, 15 do
				local blockPos = start + (side * i)
				local block = getPlacedBlock(blockPos)
				if not block or block:GetAttribute("NoBreak") then break end
				if bedwars.BlockController:isBlockBreakable({blockPosition = blockPos / 3}, lplr) then
					local distance = (playerPos - blockPos).Magnitude
					if distance < closestDistance then
						closestDistance = distance
						closestBlock = block
						closestPos = blockPos
						local normalizedSide = side.Unit 
						for vector, normalId in pairs(vectorToNormalId) do
							if (normalizedSide - vector).Magnitude < 0.01 then 
								closestNormal = normalId
								break
							end
						end
					end
				end
			end
		end

		return closestBlock, closestPos, closestNormal
	end

	local Nuker = {Enabled = false}
	local nukerrange = {Value = 1}
	local nukerslowmode = {Value = 0.2}
	local nukereffects = {Enabled = false}
	local nukeranimation = {Enabled = false}
	local nukernofly = {Enabled = false}
	local nukerlegit = {Enabled = false}
	local nukerown = {Enabled = false}
	local nukerluckyblock = {Enabled = false}
	local nukerironore = {Enabled = false}
	local nukerbeds = {Enabled = false}
	local nukerclosestblock = {Enabled = false}
	local nukercustom = {RefreshValues = function() end, ObjectList = {}}
	local luckyblocktable = {}

	local nearbed = false

	Nuker = vape.Categories.Minigames:CreateModule({
		Name = "Nuker",
		Function = function(callback)
			if callback then
				bedwars.ItemTable = bedwars.ItemTable or bedwars.ItemMeta
				for i,v in pairs(store.blocks) do
					if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) or (nukerironore.Enabled and v.Name == "iron_ore") then
						table.insert(luckyblocktable, v)
					end
				end
				table.insert(Nuker.Connections, collectionService:GetInstanceAddedSignal("block"):Connect(function(v)
					if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) or (nukerironore.Enabled and v.Name == "iron_ore") then
						table.insert(luckyblocktable, v)
					end
				end))
				table.insert(Nuker.Connections, collectionService:GetInstanceRemovedSignal("block"):Connect(function(v)
					if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) or (nukerironore.Enabled and v.Name == "iron_ore") then
						table.remove(luckyblocktable, table.find(luckyblocktable, v))
					end
				end))
				task.spawn(function()
					repeat
						nearbed = false
						if (not nukernofly.Enabled or not vape.Modules.Fly.Enabled) then
							local broke = not entityLibrary.isAlive
							local tool = (not nukerlegit.Enabled) and {Name = "wood_axe"} or store.localHand.tool
							if nukerbeds.Enabled then
								for i, obj in pairs(collectionService:GetTagged("bed")) do
									if broke then break end
									if obj.Parent ~= nil then
										if obj.Name == "bed" and tostring(obj:GetAttribute("TeamId")) == tostring(lplr:GetAttribute("Team")) then continue end
										if obj:GetAttribute("BedShieldEndTime") then
											if obj:GetAttribute("BedShieldEndTime") > game.Workspace:GetServerTimeNow() then continue end
										end
										if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - obj.Position).magnitude <= nukerrange.Value then
											if tool and bedwars.ItemTable[tool.Name].breakBlock and bedwars.BlockController:isBlockBreakable({blockPosition = obj.Position / 3}, lplr) then
												nearbed = true
												nearestBed = obj
												if nukerclosestblock.Enabled then
                                                    local playerPos = entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position
                                                    local closestBlock, closestPos, closestNormal = findClosestBreakableBlock(obj.Position, playerPos)
                                                    if closestBlock and closestPos then
                                                        broke = true
                                                        breakBlock(closestPos, nukereffects.Enabled, closestNormal, false, nukeranimation.Enabled)
                                                        task.wait(nukerslowmode.Value ~= 0 and nukerslowmode.Value/10 or 0)
                                                        break
                                                    end
                                                else
                                                    local res, amount = getBestBreakSide(obj.Position)
                                                    local res2, amount2 = getBestBreakSide(obj.Position + Vector3.new(0, 0, 3))
                                                    broke = true
                                                    breakBlock((amount < amount2 and obj.Position or obj.Position + Vector3.new(0, 0, 3)), nukereffects.Enabled, (amount < amount2 and res or res2), false, nukeranimation.Enabled)
                                                    task.wait(nukerslowmode.Value ~= 0 and nukerslowmode.Value/10 or 0)
                                                    break
                                                end
											end
										end
									end
								end
							end
							broke = broke and not entityLibrary.isAlive
							for i, obj in pairs(luckyblocktable) do
								if broke then break end
								if nearbed then break end
								if entityLibrary.isAlive then
									if obj and obj.Parent ~= nil then
										if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - obj.Position).magnitude <= nukerrange.Value and (nukerown.Enabled or obj:GetAttribute("PlacedByUserId") ~= lplr.UserId) then
											if tool and bedwars.ItemTable[tool.Name].breakBlock and bedwars.BlockController:isBlockBreakable({blockPosition = obj.Position / 3}, lplr) then
												breakBlock(obj.Position, nukereffects.Enabled, getBestBreakSide(obj.Position), true, nukeranimation.Enabled)
												task.wait(nukerslowmode.Value ~= 0 and nukerslowmode.Value/10 or 0)
												break
											end
										end
									end
								end
							end
						end
						task.wait()
					until (not Nuker.Enabled)
				end)
			else
				luckyblocktable = {}
			end
		end,
		Tooltip = "Automatically destroys beds & luckyblocks around you."
	})
	nukerslowmode = Nuker:CreateSlider({
		Name = "Break Slowmode",
		Min = 0,
		Max = 10,
		Function = function() end,
		Default = 2
	})
	nukerrange = Nuker:CreateSlider({
		Name = "Break range",
		Min = 1,
		Max = 30,
		Function = function(val) end,
		Default = 30
	})
	nukerlegit = Nuker:CreateToggle({
		Name = "Hand Check",
		Function = function() end
	})
	nukereffects = Nuker:CreateToggle({
		Name = "Show HealthBar & Effects",
		Function = function(callback)
			if not callback then
				bedwars.BlockBreaker.healthbarMaid:DoCleaning()
			end
		 end,
		Default = true
	})
	nukeranimation = Nuker:CreateToggle({
		Name = "Break Animation",
		Function = function() end
	})
	nukerown = Nuker:CreateToggle({
		Name = "Self Break",
		Function = function() end,
	})
	nukerbeds = Nuker:CreateToggle({
		Name = "Break Beds",
		Function = function(callback) end,
		Default = true
	})
	nukernofly = Nuker:CreateToggle({
		Name = "Fly Disable",
		Function = function() end
	})
	nukerclosestblock = Nuker:CreateToggle({
        Name = "Break Closest Block",
        Function = function(callback) end,
        Default = false,
        Tooltip = "Breaks the closest block when targeting beds, making it less blatant."
    })
	nukerluckyblock = Nuker:CreateToggle({
		Name = "Break LuckyBlocks",
		Function = function(callback)
			if callback then
				luckyblocktable = {}
				for i,v in pairs(store.blocks) do
					if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) or (nukerironore.Enabled and v.Name == "iron_ore") then
						table.insert(luckyblocktable, v)
					end
				end
			else
				luckyblocktable = {}
			end
		 end,
		Default = true
	})
	nukerironore = Nuker:CreateToggle({
		Name = "Break IronOre",
		Function = function(callback)
			if callback then
				luckyblocktable = {}
				for i,v in pairs(store.blocks) do
					if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) or (nukerironore.Enabled and v.Name == "iron_ore") then
						table.insert(luckyblocktable, v)
					end
				end
			else
				luckyblocktable = {}
			end
		end
	})
	nukercustom = Nuker:CreateTextList({
		Name = "NukerList",
		TempText = "block (tesla_trap)",
		AddFunction = function()
			luckyblocktable = {}
			for i,v in pairs(store.blocks) do
				if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) then
					table.insert(luckyblocktable, v)
				end
			end
		end
	})
end)

run(function() 
    local Settings = {
        BypassActive = {Enabled = false},
        ZephyrMode = {Enabled = false},
        ScytheEnabled = {Enabled = false},
        ScytheSpeed = {Value = 5},
        ScytheBypassSpeed = {Value = 50},
        NoKillauraForScythe = {Enabled = false},
        ClientMod = {Enabled = false},
        DirectionMode = {Value = "LookVector + MoveDirection"},
        DelayActive = {Enabled = false},
        Multiplier = {Value = 0.01},
        Divider = {Value = 0.01},
        DivVal = {Value = 2},
        BlinkStatus = false,
        TickCounter = 0,
        ScytheTickCounter = {Value = 2},
        ScytheDelay = {Value = 0},
        WeaponTiers = {
            [1] = 'stone_sword',
            [2] = 'iron_sword',
            [3] = 'diamond_sword',
            [4] = 'emerald_sword',
            [5] = 'rageblade'
        }
    }
    Settings.BypassActive = vape.Categories.Blatant:CreateModule({
        Name = "ActivateBypass",
        Function = function(toggle)
            if toggle then
				warningNotification("ActivateBypass", "WARNING! Using this might result in an AUTO-BAN (the chances are small but NOT 0)", 7)
                task.spawn(function()
					repeat task.wait(1.5)
						shared.zephyrActive = Settings.ZephyrMode.Enabled
						shared.scytheActive = Settings.ScytheEnabled
						shared.scytheSpeed = Settings.ScytheSpeed.Value
						if Settings.ScytheEnabled then
							local weapon = getItemNear("scythe")
							if weapon and (not killauraNearPlayer and store.queueType:find("skywars") or not store.queueType:find("skywars")) then
								switchItem(weapon.tool)
							end
							if weapon then
								if killauraNearPlayer and Settings.NoKillauraForScythe.Enabled then
									scytheSpeed = math.random(5, 10)
								end
								Settings.TickCounter = Settings.TickCounter + 1
								if entityLibrary.isAlive then
									if Settings.TickCounter >= Settings.ScytheBypassSpeed.Value then
										--pcall(function() sethiddenproperty(entityLibrary.character.HumanoidRootPart, "NetworkIsSleeping", false) end)
										Settings.TickCounter = 0
										Settings.BlinkStatus = false
									else
										--pcall(function() sethiddenproperty(entityLibrary.character.HumanoidRootPart, "NetworkIsSleeping", true) end)
										Settings.BlinkStatus = true
									end
								end
								store.holdingscythe = true
								local direction
								if Settings.DirectionMode.Value == "LookVector" then
									direction = entityLibrary.character.HumanoidRootPart.CFrame.LookVector
								elseif Settings.DirectionMode.Value == "MoveDirection" then
									direction = entityLibrary.character.Humanoid.MoveDirection
								elseif Settings.DirectionMode.Value == "LookVector + MoveDirection" then
									direction = entityLibrary.character.HumanoidRootPart.CFrame.LookVector + entityLibrary.character.Humanoid.MoveDirection
								end
								if Settings.Divider.Value ~= 0 then
									bedwars.Client:Get("ScytheDash"):FireServer({direction = direction / Settings.Divider.Value * Settings.Multiplier.Value})
								else
									bedwars.Client:Get("ScytheDash"):FireServer({direction = direction * Settings.Multiplier.Value})
								end
								if entityLibrary.isAlive and entityLibrary.character.Head.Transparency ~= 0 then
									store.scythe = tick() + 1
								else
									store.scythe = 0
								end
								if not isnetworkowner(entityLibrary.character.HumanoidRootPart) then
									store.scythe = 0
								end
							else
								store.holdingscythe = false
								store.scythe = 0
							end
						end
						if Settings.ClientMod.Enabled then
							local playerScripts = lplr.PlayerScripts
							if playerScripts.Modules:FindFirstChild("anticheat") then
								playerScripts.Modules.anticheat:Destroy()
							end
							if playerScripts:FindFirstChild("GameAnalyticsClient") then
								playerScripts.GameAnalyticsClient:Destroy()
							end
							if game:GetService("ReplicatedStorage").Modules:FindFirstChild("anticheat") then
								game:GetService("ReplicatedStorage").Modules.anticheat:Destroy()
							end
						end
					until (not Settings.BypassActive.Enabled)
                end)
            else
                Settings.TickCounter = 0
				--pcall(function() sethiddenproperty(entityLibrary.character.HumanoidRootPart, "NetworkIsSleeping", false) end)
            end
        end,
        Tooltip = "Disables AntiCheat and adjusts scythe mechanics",
        ExtraText = function()
            local activeCount = 0
            if Settings.ZephyrMode.Enabled then activeCount = activeCount + 1 end
            if Settings.ScytheEnabled then activeCount = activeCount + 1 end
            if Settings.ClientMod.Enabled then activeCount = activeCount + 1 end
            return activeCount.." Bypasses Activated"
        end
    })
    
    Settings.ClientMod = Settings.BypassActive:CreateToggle({
        Name = "Disable AntiCheat",
        Default = true,
        Function = function() end
    })
    
    Settings.ScytheEnabled = Settings.BypassActive:CreateToggle({
        Name = "Enable Scythe",
        Default = true,
        Function = function() end
    })

    Settings.ScytheSpeed = Settings.BypassActive:CreateSlider({
        Name = "Scythe Speed Control",
        Min = 0,
        Max = 35,
        Default = 25,
        Function = function() end
    })
    
    Settings.ScytheBypassSpeed = Settings.BypassActive:CreateSlider({
        Name = "Bypass Speed",
        Min = 0,
        Max = 300,
        Default = 50,
        Function = function() end
    })
    
    Settings.NoKillauraForScythe = Settings.BypassActive:CreateToggle({
        Name = "Disable Killaura",
        Default = true,
        Function = function() end
    })

    Settings.DirectionMode = Settings.BypassActive:CreateDropdown({
        Name = "Direction Control",
        List = {"LookVector", "MoveDirection", "LookVector + MoveDirection"},
        Function = function() end
    })
    
    Settings.Multiplier = Settings.BypassActive:CreateSlider({
        Name = "Direction Multiplier",
        Min = 0,
        Max = 0.01,
        Default = 0.001,
        Function = function() end
    })

    Settings.ZephyrMode = Settings.BypassActive:CreateToggle({
        Name = "Enable Zephyr",
        Default = true,
        Function = function() end
    })
end)

run(function()
	local WhisperAura = {Enabled = false}
	local WhisperRange = {Value = 100}
	local WhisperTask
	local function getServerOwl()
		return game.Workspace:FindFirstChild("ServerOwl")
	end
	local function getPlayerFromUserId(userId)
		for i,v in pairs(game:GetService("Players"):GetPlayers()) do
			if v.UserId == userId then return v end
		end
	end
	local function attack(plr)
		local suc, res = pcall(function()
			if (not plr) then return warn("[WhisperAura | attack]: Player not specified!") end
			local targetPosition = plr.Character.HumanoidRootPart.Position
			local direction = (targetPosition - lplr.Character.HumanoidRootPart.Position).unit
			local ProjectileRefId = game:GetService("HttpService"):GenerateGUID(true)
			local fromPosition
			local ServerOwl = game.Workspace:FindFirstChild("ServerOwl")
			if ServerOwl and ServerOwl.ClassName and ServerOwl.ClassName == "Model" and ServerOwl:GetAttribute("Owner") and ServerOwl:GetAttribute("Target") then
				if tonumber(ServerOwl:GetAttribute("Owner")) == lplr.UserId then
					local target = getPlayerFromUserId(tonumber(ServerOwl:GetAttribute("Target")))
					if target then
						fromPosition = target.Character.HumanoidRootPart.Position
					end
				end
			end
			local initialVelocity = direction
	
			return bedwars.Client:Get("OwlFireProjectile"):InvokeServer({
				["ProjectileRefId"] = ProjectileRefId,
				["direction"] = direction,
				["fromPosition"] = fromPosition,
				["initialVelocity"] = initialVelocity
			})
		end)
		return res
	end
	WhisperAura = vape.Categories.Blatant:CreateModule({
		Name = "WhisperAura",
		Function = function(call)
			if call then
				WhisperTask = task.spawn(function()
					repeat 
						task.wait()
						if entityLibrary.isAlive and store.matchState > 0 then
							local plr = EntityNearPosition(WhisperRange.Value, true)
							if plr then pcall(function() attack(plr) end) end
						end
					until (not WhisperAura.Enabled)
				end)
			else
				pcall(function()
					task.cancel(WhisperTask)
				end)
			end
		end
	})
	WhisperRange = WhisperAura:CreateSlider({
		Name = "Range",
		Function = function() end,
		Min = 10,
		Max = 1000,
		Default = 50
	})
end)

run(function()
	local function isXeno()
		local status = false

		if identifyexecutor ~= nil and type(identifyexecutor) == "function" then
			local suc, res = pcall(function()
				return identifyexecutor()
			end)   
			res = tostring(res)
			if string.find(string.lower(res), 'xeno') then status = true end
		else status = false end

		return status
	end
	if isXeno() then
		local CombatConstant

		local Value
		
		Reach = vape.Categories.Combat:CreateModule({
			Name = 'Reach',
			Function = function(callback)
				
			end,
			Tooltip = 'Extends attack reach'
		})
		Value = Reach:CreateSlider({
			Name = 'Range',
			Min = 0,
			Max = 18,
			Default = 18,
			Function = function(val)
				if Reach.Enabled then
					
				end
			end,
			Suffix = function(val)
				return val == 1 and 'stud' or 'studs'
			end
		})
	end
end)

run(function()
	local AutoSuffocate
	local Range
	local LimitItem
	
	local function fixPosition(pos)
		local blockPos = bedwars.BlockController:getBlockPosition(pos)
		if not blockPos then return nil end
		return blockPos * 3
	end
	
	AutoSuffocate = vape.Categories.World:CreateModule({
		Name = 'AutoSuffocate',
		Function = function(callback)
			if callback then
				repeat
					local item = store.hand.toolType == 'block' and store.hand.tool.Name or not LimitItem.Enabled and getWool()
	
					if item then
						local plrs = entitylib.AllPosition({
							Part = 'RootPart',
							Range = Range.Value,
							Players = true
						})
	
						for _, ent in plrs do
							local needPlaced = {}
	
							for _, side in Enum.NormalId:GetEnumItems() do
								side = Vector3.fromNormalId(side)
								if side.Y ~= 0 then continue end
	
								local fixedSide = fixPosition(ent.RootPart.Position + side * 2)
								if fixedSide and not getPlacedBlock(fixedSide) then
									table.insert(needPlaced, fixedSide)
								end
							end
	
							if #needPlaced < 3 then
								local headPos = fixPosition(ent.Head.Position)
								local rootBelowPos = fixPosition(ent.RootPart.Position - Vector3.new(0, 1, 0))
								if headPos then table.insert(needPlaced, headPos) end
								if rootBelowPos then table.insert(needPlaced, rootBelowPos) end
	
								for _, pos in needPlaced do
									if pos and not getPlacedBlock(pos) then
										task.spawn(bedwars.placeBlock, pos, item)
										break
									end
								end
							end
						end
					end
	
					task.wait(0.09)
				until not AutoSuffocate.Enabled
			end
		end,
		Tooltip = 'Places blocks on nearby confined entities'
	})
	Range = AutoSuffocate:CreateSlider({
		Name = 'Range',
		Min = 1,
		Max = 20,
		Default = 20,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	LimitItem = AutoSuffocate:CreateToggle({
		Name = 'Limit to Items',
		Default = true
	})
end)

run(function()
	local AutoVoidDrop
	local OwlCheck

	local DropItemRemote
	
	AutoVoidDrop = vape.Categories.Utility:CreateModule({
		Name = 'AutoVoidDrop',
		Function = function(callback)
			if callback then
				repeat task.wait() until store.matchState ~= 0 or (not AutoVoidDrop.Enabled)
				if not AutoVoidDrop.Enabled then return end

				if not DropItemRemote then DropItemRemote = game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("DropItem") end
	
				local lowestpoint = math.huge
				for _, v in store.blocks do
					local point = (v.Position.Y - (v.Size.Y / 2)) - 50
					if point < lowestpoint then 
						lowestpoint = point 
					end
				end
	
				repeat
					if entitylib.isAlive then
						local root = entitylib.character.RootPart
						if root.Position.Y < lowestpoint and (lplr.Character:GetAttribute('InflatedBalloons') or 0) <= 0 and not getItem('balloon') then
							if not OwlCheck.Enabled or not root:FindFirstChild('OwlLiftForce') then
								for _, item in {'iron', 'diamond', 'emerald', 'gold'} do
									item = getItem(item)
									if item then
										item = DropItemRemote:InvokeServer({
											item = item.tool,
											amount = item.amount
										})
	
										if item then
											item:SetAttribute('ClientDropTime', tick() + 100)
										end
									end
								end
							end
						end
					end
	
					task.wait(0.1)
				until not AutoVoidDrop.Enabled
			end
		end,
		Tooltip = 'Drops resources when you fall into the void'
	})
	OwlCheck = AutoVoidDrop:CreateToggle({
		Name = 'Owl check',
		Default = true,
		Tooltip = 'Refuses to drop items if being picked up by an owl'
	})
end)

run(function()
	local ProjectileAura
	local Targets
	local Range
	local List
	local rayCheck = RaycastParams.new()
	rayCheck.FilterType = Enum.RaycastFilterType.Include

	local projectileRemote = {InvokeServer = function() end}
	local FireDelays = {}
	task.spawn(function()
		projectileRemote = bedwars.Client:Get(bedwars.ProjectileRemote)
	end)

	local function getAmmo(check, item)
		if not check.ammoItemTypes then return item.itemType end
		for _, item in store.inventory.inventory.items do
			if check.ammoItemTypes and table.find(check.ammoItemTypes, item.itemType) then
				return item.itemType
			end
		end
	end

	local function projectileType(item, ammo)
		local res
		if not ammo then ammo = "" end
		ammo = tostring(ammo)
		local meta = bedwars.ItemMeta[item.itemType]
		if not (item ~= nil and type(item) == "table" and item.itemType ~= nil and meta ~= nil and type(meta) == "table" and meta.displayName ~= nil) then return res end
		if meta.displayName == "Crossbow" and ammo == "arrow" then
			res = "crossbow_arrow"
		elseif item.itemType == "snowball" then
			res = "snowball"
		elseif item.itemType == "wood_bow" then
			res = "arrow"
		else
			res = item.itemType.."_"..ammo
		end
		return res
	end
	
	local function getProjectiles()
		local items = {}
		for _, item in store.inventory.inventory.items do
			if item and item.itemType == "mage_spellbook" then
				table.insert(items, {
					item,
					nil, 
					nil,
					0.3
				})
				continue
			end
			if item and item.itemType == "owl_orb" then
				table.insert(items, {
					item,
					nil, 
					nil,
					0.3
				})
				continue
			end
			if item and item.itemType == "light_sword" then
				table.insert(items, {
					item,
					nil, 
					nil,
					0.3
				})
			end
			local proj = bedwars.ItemMeta[item.itemType].projectileSource
			local ammo = proj and getAmmo(proj, item)
			if not table.find(List.ListEnabled, 'sword_wave1') then table.insert(List.ListEnabled, 'sword_wave1') end
			if not table.find(List.ListEnabled, 'ninja_chakram_4') then table.insert(List.ListEnabled, 'ninja_chakram_4') end
			if ammo and table.find(List.ListEnabled, ammo) then
				local res = projectileType(item, ammo)
				if res then
					table.insert(items, {
						item,
						ammo,
						res,
						proj
					})
				end
			end
		end
		return items
	end

	local HttpService = game:GetService("HttpService")
	local httpService = HttpService

	local function specialGUID()
		return string.upper((tostring(HttpService:GenerateGUID(false)):split("-"))[1])
	end
	
	local function selfPosition()
		return lplr.Character and lplr.Character.PrimaryPart and lplr.Character.PrimaryPart.Position
	end

	local handle = {
		Lumen = function(ent, item, ammo, projectile, itemMeta)
			if not item.tool then return end
			if not ent then return end
			local selfPos = selfPosition()
			if not selfPos then return end
	
			local vec = ent.RootPart.Position * Vector3.new(1, 0, 1)
			lplr.Character.PrimaryPart.CFrame = CFrame.lookAt(lplr.Character.PrimaryPart.Position, Vector3.new(vec.X, lplr.Character.PrimaryPart.Position.Y + 0.001, vec.Z))
	
			local mag = lplr.Character.PrimaryPart.CFrame.LookVector*80
	
			projectileRemote:InvokeServer(
				item.tool,
				"light_sword",
				"sword_wave1",
				Vector3.new(selfPos.X, selfPos.Y + 2, selfPos.Z),
				selfPos,
				mag,
				specialGUID(),
				{
					["shotId"] = specialGUID(),
					["drawDurationSec"] = 0
				},
				workspace:GetServerTimeNow() - 0.045
			)

			targetinfo.Targets[ent] = tick() + 1
			
			pcall(function()
				FireDelays[item.itemType] = tick() + itemMeta.fireDelaySec
			end)
		end,
		Umeko = function(ent, item, ammo, projectile, itemMeta)
			if not item.tool then return end
			if not ent then return end
			local selfPos = selfPosition()
			if not selfPos then return end
	
			local vec = ent.RootPart.Position * Vector3.new(1, 0, 1)
			lplr.Character.PrimaryPart.CFrame = CFrame.lookAt(lplr.Character.PrimaryPart.Position, Vector3.new(vec.X, lplr.Character.PrimaryPart.Position.Y + 0.001, vec.Z))
	
			switchItem(item.tool)

			local targetPos = ent.RootPart.Position

			local expectedTime = (selfPos - targetPos).Magnitude / 160
			targetPos += (ent.RootPart.Velocity * expectedTime)

			targetinfo.Targets[ent] = tick() + 1

			projectileRemote:InvokeServer(
				item.tool,
				nil,
				"ninja_chakram_4",
				selfPos + Vector3.new(0, 2, 0),
				selfPos,
				(selfPos - targetPos).Unit * -160,
				specialGUID(),
				{
					["shotId"] = specialGUID(),
					["drawDurationSec"] = 1
				},
				workspace:GetServerTimeNow() - 0.045
			)
			
			pcall(function()
				FireDelays[item.itemType] = tick() + itemMeta.fireDelaySec
			end)
		end,
		Whim = function(ent, item, ammo, projectile, itemMeta)
			if not item.tool then return end
			if not ent then return end
			local selfPos = selfPosition()
			if not selfPos then return end
	
			local vec = ent.RootPart.Position * Vector3.new(1, 0, 1)
			lplr.Character.PrimaryPart.CFrame = CFrame.lookAt(lplr.Character.PrimaryPart.Position, Vector3.new(vec.X, lplr.Character.PrimaryPart.Position.Y + 0.001, vec.Z))
	
			switchItem(item.tool)

			local targetPos = ent.RootPart.Position

			local expectedTime = (selfPos - targetPos).Magnitude / 160
			targetPos += (ent.RootPart.Velocity * expectedTime)

			targetinfo.Targets[ent] = tick() + 1

			projectileRemote:InvokeServer(
				item.tool,
				nil,
				"mage_spell_base",
				selfPos + Vector3.new(0, 2, 0),
				selfPos,
				(selfPos - targetPos).Unit * -160,
				specialGUID(),
				{
					["shotId"] = specialGUID(),
					["drawDurationSec"] = 1
				},
				workspace:GetServerTimeNow() - 0.045
			)
			
			pcall(function()
				FireDelays[item.itemType] = tick() + itemMeta.fireDelaySec
			end)
		end,
		Whisper = function(ent, item, ammo, projectile, itemMeta)
			local function getPlayerFromUserId(userId)
				if not userId then return nil end
				local suc = pcall(function()
					userId = tonumber(userId)
				end)
				if not suc then return nil end
				for i,v in pairs(game:GetService("Players"):GetPlayers()) do
					if v.UserId == userId then return v end
				end
			end
			local function getOwl()
				local owl = Filter(game.Workspace:GetChildren(), function(v)
					if v.ClassName and v.ClassName == "Model" and v.Name and v.Name == "ServerOwl" and tostring(v:GetAttribute("Owner")) == tostring(lplr.UserId) and getPlayerFromUserId(tostring(v:GetAttribute("Target"))) then 
						return true
					else
						return false
					end
				end)
				if not owl then return end

				if not item.tool then return end
				if not ent then return end
				local selfPos = selfPosition()
				if not selfPos then return end

				local targetPosition = ent.RootPart.Position
				local direction = (targetPosition - lplr.Character.HumanoidRootPart.Position).unit

				local target = getPlayerFromUserId(tostring(owl:GetAttribute("Target")))
				local ProjectileRefId, direction, fromPosition, initialVelocity = specialGUID(), direction, nil, direction
				local suc = pcall(function()
					fromPosition = target.Character.HumanoidRootPart.Position
				end)
				if not suc then return end

				bedwars.Client:Get("OwlFireProjectile"):InvokeServer({
					ProjectileRefId = ProjectileRefId,
					direction = direction,
					fromPosition = fromPosition,
					initialVelocity = initialVelocity
				})
			end
		end
	}
	
	ProjectileAura = vape.Categories.Blatant:CreateModule({
		Name = 'ProjectileAura',
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat
						if (workspace:GetServerTimeNow() - bedwars.SwordController.lastAttack) > 0.5 then
							task.spawn(function()
								local ent = entitylib.EntityPosition({
									Range = Range.Value,
									Part = 'RootPart',
									Players = true,
									NPCs = true
								})
								if ent then
									if Targets.Walls.Enabled then
										if not Wallcheck(lplr.Character, ent.Character) then return end
									end
									local pos = entitylib.character.RootPart.Position
									for _, data in getProjectiles() do
										local item, ammo, projectile, itemMeta = unpack(data)
										if (FireDelays[item.itemType] or 0) < tick() then
											if item.itemType == "light_sword" then
												handle.Lumen(ent, unpack(data))
												continue
											elseif item.itemType == "ninja_chakram_4" then
												handle.Umeko(ent, unpack(data))
												continue
											elseif item.itemType == "mage_spellbook" then
												handle.Whim(ent, unpack(data))
												continue
											elseif item.itemType == "owl_orb" then
												handle.Whisper(ent, unpack(data))
												continue
											end
											rayCheck.FilterDescendantsInstances = {workspace.Map}
											local meta = bedwars.ProjectileMeta[projectile]
											if not meta then continue end
											local projSpeed, gravity = meta.launchVelocity, meta.gravitationalAcceleration or 196.2
											local calc = prediction.SolveTrajectory(pos, projSpeed, gravity, ent.RootPart.Position, ent.RootPart.Velocity, workspace.Gravity, ent.HipHeight, ent.Jumping and 42.6 or nil, rayCheck)
											if calc then
												targetinfo.Targets[ent] = tick() + 1
												local switched = switchItem(item.tool)
			
												task.spawn(function()
													local dir, id = CFrame.lookAt(pos, calc).LookVector, httpService:GenerateGUID(true)
													local shootPosition = (CFrame.new(pos, calc) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, -bedwars.BowConstantsTable.RelZ))).Position
													local res = projectileRemote:InvokeServer(item.tool, ammo, projectile, shootPosition, pos, dir * projSpeed, id, {drawDurationSeconds = 1, shotId = httpService:GenerateGUID(false)}, workspace:GetServerTimeNow() - 0.045)
													if not res then
														FireDelays[item.itemType] = tick()
													else
														local shoot = itemMeta.launchSound
														shoot = shoot and shoot[math.random(1, #shoot)] or nil
														if shoot then
															bedwars.SoundManager:playSound(shoot)
														end
													end
												end)
			
												FireDelays[item.itemType] = tick() + itemMeta.fireDelaySec
												if switched then
													task.wait(0.05)
												end
											end
										end
									end
								end
							end)
						end
						task.wait(0.1)
					until not ProjectileAura.Enabled
				end)
			end
		end,
		Tooltip = 'Shoots people around you'
	})
	Targets = ProjectileAura:CreateTargets({
		Players = true,
		Walls = true
	})
	List = ProjectileAura:CreateTextList({
		Name = 'Projectiles',
		Default = {'arrow', 'snowball'}
	})
	Range = ProjectileAura:CreateSlider({
		Name = 'Range',
		Min = 1,
		Max = 50,
		Default = 50,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
end)

store.shop = collection({'BedwarsItemShop', 'TeamUpgradeShopkeeper'}, vape, function(tab, obj)
	table.insert(tab, {Id = obj.Name, RootPart = obj, Shop = obj:HasTag('BedwarsItemShop'), Upgrades = obj:HasTag('TeamUpgradeShopkeeper')})
end)

run(function()
	local replicatedStorage = game:GetService("ReplicatedStorage")
	local guiService = game:GetService("GuiService")

	local AutoBank
	local UIToggle
	local UI
	local Chests
	local Items = {}

	local AutoBankMode = {Value = "Toggle"}
	
	local function addItem(itemType, shop)
		local item = Instance.new('ImageLabel')
		item.Image = bedwars.getIcon({itemType = itemType}, true)
		item.Size = UDim2.fromOffset(32, 32)
		item.Name = itemType
		item.BackgroundTransparency = 1
		item.LayoutOrder = #UI:GetChildren()
		item.Parent = UI
		local itemtext = Instance.new('TextLabel')
		itemtext.Name = 'Amount'
		itemtext.Size = UDim2.fromScale(1, 1)
		itemtext.BackgroundTransparency = 1
		itemtext.Text = ''
		itemtext.TextColor3 = Color3.new(1, 1, 1)
		itemtext.TextSize = 16
		itemtext.TextStrokeTransparency = 0.3
		itemtext.Font = Enum.Font.Arial
		itemtext.Parent = item
		Items[itemType] = {Object = itemtext, Type = shop}
	end
	
	local function refreshBank(echest)
		for i, v in Items do
			local item = echest:FindFirstChild(i)
			v.Object.Text = item and item:GetAttribute('Amount') or ''
		end
	end
	
	local function nearChest()
		if entitylib.isAlive then
			local pos = entitylib.character.HumanoidRootPart.Position
			for _, chest in Chests do
				if (chest.Position - pos).Magnitude < 20 then
					return true
				end
			end
		end
	end
	
	local function handleState()
		local chest = replicatedStorage.Inventories:FindFirstChild(lplr.Name..'_personal')
		if not chest then return end
	
		local mapCF = workspace.MapCFrames:FindFirstChild((lplr:GetAttribute('Team') or 1)..'_spawn')
		if AutoBankMode.Value ~= "Toggle" then
			if not nearChest() then
				warningNotification("AutoBank", "No chest close by.", 3)
			else
				warningNotification("AutoBank", "Successfully stored the loot in a personal chest!", 3)
			end
		end
		if mapCF and nearChest() then
			for _, v in chest:GetChildren() do
				local item = Items[v.Name]
				if item then
					task.spawn(function()
						bedwars.Client:GetNamespace('Inventory'):Get('ChestGetItem'):CallServer(chest, v)
						refreshBank(chest)
					end)
				end
			end
		else
			for _, v in store.inventory.inventory.items do
				local item = Items[v.itemType]
				if item then
					task.spawn(function()
						bedwars.Client:GetNamespace('Inventory'):Get('ChestGiveItem'):CallServer(chest, v.tool)
						refreshBank(chest)
					end)
				end
			end
		end
	end
	
	AutoBank = vape.Categories.Inventory:CreateModule({
		Name = 'AutoBank',
		Function = function(callback)
			if callback then
				Chests = collection('personal-chest', AutoBank)
				UI = Instance.new('Frame')
				UI.Size = UDim2.new(1, 0, 0, 32)
				UI.Position = UDim2.fromOffset(0, -240)
				UI.BackgroundTransparency = 1
				UI.Visible = UIToggle.Enabled
				UI.Parent = vape.gui
				AutoBank:Clean(UI)
				local Sort = Instance.new('UIListLayout')
				Sort.FillDirection = Enum.FillDirection.Horizontal
				Sort.HorizontalAlignment = Enum.HorizontalAlignment.Center
				Sort.SortOrder = Enum.SortOrder.LayoutOrder
				Sort.Parent = UI
				addItem('iron', true)
				addItem('gold', true)
				addItem('diamond', false)
				addItem('emerald', true)
				addItem('void_crystal', true)
	
				task.spawn(function()
					repeat
						local hotbar = lplr.PlayerGui:FindFirstChild('hotbar')
						hotbar = hotbar and hotbar['1']:FindFirstChild('HotbarHealthbarContainer')
						if hotbar then
							UI.Position = UDim2.fromOffset(0, (hotbar.AbsolutePosition.Y + guiService:GetGuiInset().Y) - 40)
						end
						pcall(handleState)
						task.wait(0.1)
					until (not AutoBank.Enabled)
				end)

				if AutoBankMode.Value ~= "Toggle" then
					AutoBank:Toggle()
				end
			else
				table.clear(Items)
			end
		end,
		Tooltip = 'Automatically puts resources in ender chest'
	})
	AutoBankMode = AutoBank:CreateDropdown({
		Name = "Activation",
		List = {"On Key", "Toggle"},
		Function = function()
			if AutoBank.Enabled then
				AutoBank:Toggle()
				AutoBank:Toggle()
			end
		end
	})
	UIToggle = AutoBank:CreateToggle({
		Name = 'UI',
		Function = function(callback)
			if AutoBank.Enabled then
				UI.Visible = callback
			end
		end,
		Default = true
	})
end)

run(function()
	local UICleanup
	local StarterGui = game:GetService("StarterGui")
	UICleanup = vape.Categories.World:CreateModule({
		Name = "UICleanup",
		Function = function(call)
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, not call)
		end
	})
end)

--VoidwareFunctions.GlobaliseObject("store", store)
VoidwareFunctions.GlobaliseObject("GlobalStore", store)

--VoidwareFunctions.GlobaliseObject("bedwars", bedwars)
VoidwareFunctions.GlobaliseObject("GlobalBedwars", bedwars)

VoidwareFunctions.GlobaliseObject("VapeBWLoaded", true)
local function createMonitoredTable(originalTable, onChange)
    local proxy = {}
    local mt = {
        __index = originalTable,
        __newindex = function(t, key, value)
            local oldValue = originalTable[key]
            originalTable[key] = value
            if onChange then
                onChange(key, oldValue, value)
            end
        end
    }
    setmetatable(proxy, mt)
    return proxy
end
local function onChange(key, oldValue, newValue)
   --print("Changed key:", key, "from", oldValue, "to", newValue)
   	--VoidwareFunctions.GlobaliseObject("store", store)
	VoidwareFunctions.GlobaliseObject("GlobalStore", store)
end
local function onChange2(key, oldValue, newValue)
	--print("Changed key:", key, "from", oldValue, "to", newValue)
	--VoidwareFunctions.GlobaliseObject("bedwars", bedwars)
	VoidwareFunctions.GlobaliseObject("GlobalBedwars", bedwars)
 end

store = createMonitoredTable(store, onChange)
bedwars = createMonitoredTable(bedwars, onChange2)

--if (not shared.CheatEngineMode) then pload("CustomModules/S6872274481.lua") end