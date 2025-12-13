repeat task.wait() until game:IsLoaded()
if shared.vape then shared.vape:Uninject(); shared.VapeExecuted = false end

if identifyexecutor and ({identifyexecutor()})[1] == 'Argon' then
	getgenv().setthreadidentity = nil
end

shared.OLD_SETTHREADIDENTITY = shared.OLD_SETTHREADIDENTITY or getgenv().setthreadidentity or function() end
getgenv().setthreadidentity = function(...)
	local args = {...}
	local suc, err = pcall(function()
		return shared.OLD_SETTHREADIDENTITY(unpack(args))
	end)
	if not suc and shared.VoidDev then
		warn(`SETTHREADIDENTITY ERROR: {tostring(err)}`)
	end
	return suc and err
end
getgenv().run = function(func)
	local suc, err = pcall(function() func() end)
	if (not suc) then
		warn('Error in module! Error log: '..debug.traceback(tostring(err)))
	end
end

local vape
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and vape then
		vape:CreateNotification('Vape', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
if hookfunction == nil then getgenv().hookfunction = function() end end
local queue_on_teleport = queue_on_teleport or function() end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
getgenv().cloneref = function(obj) return obj end
local cloneref = cloneref or function(obj)
	return obj
end
local playersService = cloneref(game:GetService('Players'))

local isInkGame = false

local savingTable = {
	"TeleportExploitAutowinEnabled",
	"NoVoidwareModules",
	"VapeCustomProfile",
	"ProfilesDisabled",
	"CheatEngineMode",
	"ClosetCheatMode",
	"NoAutoExecute",
	"VapeDeveloper",
	"CustomCommit",
	"RiseVapeMode",
	"TestingMode",
	"VapePrivate",
	"RiseMode",
	"VoidDev"
}

local oldtbl = {}
local function finishLoading()
	vape.Init = nil
	vape:Load()
	task.spawn(function()
		repeat
			shared.VapeFullyLoaded = vape.Loaded
			vape:Save()
			task.wait(10)
		until not vape.Loaded
	end)

	if not isInkGame then
		task.spawn(function()
			repeat
				shared.vape.ObjectsThatCanBeSaved = shared.vape.ObjectsThatCanBeSaved or {}
				if oldtbl ~= vape.Modules then
					oldtbl = vape.Modules
					for i,v in pairs(vape.Modules) do
						v.ToggleButton = function(...)
							v:Toggle(...)
						end
						if tostring(i) == "Breaker" then
							shared.vape.ObjectsThatCanBeSaved.NukerOptionsButton = {Api = v}
						end
						shared.vape.ObjectsThatCanBeSaved[tostring(i).."OptionsButton"] = {Api = v}
					end
				end
				pcall(function()
					local uipallet = vape.libraries.uipallet
					local hue, saturation, value = Color3.toHSV(uipallet.Main)
					shared.vape.ObjectsThatCanBeSaved["Gui ColorSliderColor"] = {Api = {Hue = vape.GUIColor.Hue, Sat = vape.GUIColor.Sat, Value = vape.GUIColor}}
				end)
				shared.GuiLibrary = shared.vape
				task.wait(10)
			until not vape.Loaded
		end)

		local teleportedServers
		vape:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
			if (not teleportedServers) and (not shared.VapeIndependent) then
				teleportedServers = true
				local teleportScript = [[
					repeat task.wait() until game:IsLoaded()
					if getgenv and not getgenv().shared then shared.CheatEngineMode = true; getgenv().shared = {}; end
					shared.VapeSwitchServers = true
					shared.vapereload = true
					if shared.VapeDeveloper or shared.VoidDev then
						if isfile('vape/NewMainScript.lua') then
							loadstring(readfile("vape/NewMainScript.lua"))()
						else
							loadstring(game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/VWRewrite/main/NewMainScript.lua", true))()
						end
					else
						loadstring(game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/VWRewrite/main/NewMainScript.lua", true))()
					end
				]]
				for _, v in pairs(savingTable) do
					if shared[v] ~= nil then
						teleportScript = 'shared.'..tostring(v).." = "..tostring(shared[v]).."\n"..teleportScript
					end
				end
				if shared.VoidDev then
					teleportScript = 'shared.VoidDev = true\n'..teleportScript
				end
				vape:Save()
				queue_on_teleport(teleportScript)
			end
		end))
	end

	if isInkGame or not shared.vapereload then
		if not vape.Categories then return end
		if vape.Categories.Main.Options['GUI bind indicator'].Enabled then
			vape:CreateNotification('Finished Loading', vape.VapeButton and 'Press the button in the top right to open GUI' or 'Press '..table.concat(vape.Keybind, ' + '):upper()..' to open GUI', 5)
		end
	end
end

if not isfile('vape/profiles/gui.txt') then
	writefile('vape/profiles/gui.txt', 'new')
end
local gui = readfile('vape/profiles/gui.txt')

if not isfolder('vape/assets/'..gui) then
	makefolder('vape/assets/'..gui)
end

local VWFunctions = loadstring(game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/VWRewrite/main/libraries/VoidwareFunctions.lua", true))()
--pload('libraries/VoidwareFunctions.lua', true, true)
VWFunctions.GlobaliseObject("VoidwareFunctions", VWFunctions)
VWFunctions.GlobaliseObject("VWFunctions", VWFunctions)

if shared.RiseVapeMode then gui = "rise" end
vape = pload('guis/'..gui..'.lua', true, true)
shared.vape = vape
getgenv().vape = vape
getgenv().GuiLibrary = vape
shared.GuiLibrary = vape
shared.VapeExecuted = true

getgenv().InfoNotification = function(title, msg, dur)
	--warn('info', tostring(title), tostring(msg), tostring(dur))
	vape:CreateNotification(title, msg, dur)
end
getgenv().warningNotification = function(title, msg, dur)
	--warn('warn', tostring(title), tostring(msg), tostring(dur))
	vape:CreateNotification(title, msg, dur, 'warning')
end
getgenv().errorNotification = function(title, msg, dur)
	--warn("error", tostring(title), tostring(msg), tostring(dur))
	vape:CreateNotification(title, msg, dur, 'alert')
end
if shared.CheatEngineMode then
	InfoNotification("Voidware | CheatEngineMode", "Due to your executor not supporting some functions \n some modules might be missing!", 5) 
end
--[[pcall(function()
	if (not isfile('vape/discord2.txt')) then
		task.spawn(function() InfoNotification("Whitelist", "Was whitelisted and your whitelist dissapeared? Join back the discord server :D       ", 30) end)
		task.spawn(function() InfoNotification("Discord", "New server! discord.gg/voidware!              ", 30) end)
		task.spawn(function() warningNotification("Discord", "New server! discord.gg/voidware!             ", 30) end)
		task.spawn(function() errorNotification("Discord", "New server! discord.gg/voidware!              ", 30) end)
		writefile('vape/discord2.txt', '')
	end
end)--]]

local bedwarsID = {
	game = {6872274481, 8444591321, 8560631822},
	lobby = {6872265039}
}
local InkGameID = {
	main = {99567941238278, 125009265613167}
}
if not shared.VapeIndependent then
	isInkGame = table.find(InkGameID.main, game.PlaceId)
	if not isInkGame then
		pload('games/universal.lua', true)
		if not shared.NoVoidwareModules then
			pload('games/VWUniversal.lua', true)
		end
	end
	local fileName1 = game.PlaceId..".lua"
	local fileName2 = game.PlaceId..".lua"
	--local fileName3
	local isGame = table.find(bedwarsID.game, game.PlaceId)
	local isLobby = table.find(bedwarsID.lobby, game.PlaceId)
	local CE = shared.CheatEngineMode and "CE" or ""
	if isGame then
		if game.PlaceId ~= 6872274481 then vape.Place = 6872274481 end
		fileName1 = CE.."6872274481.lua"
		fileName2 = "VW6872274481.lua"
	end
	if isLobby then
		fileName1 = CE.."6872265039.lua"
		fileName2 = "VW6872265039.lua"
	end
	if not (isGame or isLobby) then fileName2 = "VW"..fileName2 end
	if isInkGame then
		vape.Place = 99567941238278
		pload('games/99567941238278.lua')
	else
		warn("[CheatEngineMode]: ", tostring(shared.CheatEngineMode))
		warn("[TestingMode]: ", tostring(shared.TestingMode))
		warn("[FileName1]: ", tostring(fileName1), " [FileName2]: ", tostring(fileName2), " [FileName3]: ", tostring(fileName3))

		pload('games/'..tostring(fileName1))
		if not shared.NoVoidwareModules then
			pload('games/'..tostring(fileName2))
		end
	end
	finishLoading()
else
	vape.Init = finishLoading
	return vape
end