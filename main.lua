repeat
	task.wait()
until game:IsLoaded()
repeat
	task.wait()
until getgenv() ~= nil
if shared.vape then
	local suc, err = pcall(shared.vape.Uninject, shared.vape)
	if not suc then
		warn(`[vape:uninject]: {tostring(err)}`)
	end
end

task.spawn(function()
	pcall(function()
		if not isfile("Local_VW_Update_Log.json") then
			shared.UpdateLogBypass = true
		end
		loadstring(game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/VWExtra/main/VWUpdateLog.lua", true))()
		shared.UpdateLogBypass = nil
	end)
end)

local vape
local queue_on_teleport = queue_on_teleport or function() end
local isfile = isfile
	or function(file)
		local suc, res = pcall(function()
			return readfile(file)
		end)
		return suc and res ~= nil and res ~= ""
	end
local cloneref = cloneref or function(obj)
	return obj
end
local playersService = cloneref(game:GetService("Players"))

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet(
				"https://raw.githubusercontent.com/"
					.. "VapeVoidware"
					.. "/VWRewrite/"
					.. readfile("vape/profiles/commit.txt")
					.. "/"
					.. select(1, path:gsub("vape/", "")),
				true
			)
		end)
		if not suc or res == "404: Not Found" then
			error(res)
		end
		if path:find(".lua") then
			res = "--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n"
				.. res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local TELEPORT_META = {
	"VoidwareBedwarsObfuscationDebug",
	"BedwarsCheatEngineLoadingDebug",
	"TeleportExploitAutowinEnabled",
	"VoidwareBedwarsLoadingDebug",
	"InternalStatisticsDisabled",
	"VoidwareNetworkingDebug",
	"LOADER_BYPASS_SLOWMODE",
	"VoidwareLoadingDebug",
	"admin_config_api_key",
	"BedwarsClientDebug",
	"VapeCustomProfile",
	"NoVoidwareModules",
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
	"VoidDev",
	"username",
	"password",
}

local function resolveIndex(a)
	if typeof(a) == "string" then
		return "'" .. tostring(a) .. "'"
	else
		return tostring(a)
	end
end

local function finishLoading()
	vape.Init = nil
	local suc, err = pcall(function()
		vape:Load()
	end)
	if not suc then
		warn("LOADING ERROR:", suc, err)
	end
	task.spawn(function()
		repeat
			vape:Save()
			task.wait(10)
		until not vape.Loaded
	end)

	local teleportedServers
	vape:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
		if (not teleportedServers) and not shared.VapeIndependent and not shared.DISABLED_QUEUE_ON_TELEPORT and not shared.FORCE_DISABLED_QUEUE_ON_TELEPORT then
			teleportedServers = true
			local teleportScript = [[
				shared.vapereload = true
				task.wait(2.5)
				if shared.VapeDeveloper and isfile('vape/loader.lua') then
					loadstring(readfile('vape/loader.lua'), 'loader')()
				else
					loadstring(game:HttpGet('https://raw.githubusercontent.com/VapeVoidware/VWRewrite/'..readfile('vape/profiles/commit.txt')..'/loader.lua', true), 'loader')()
				end
			]]
			for _, v in pairs(TELEPORT_META) do
				if shared[v] ~= nil or getgenv()[v] ~= nil then
					local a, b
					if shared[v] ~= nil then
						a = shared[v]
						b = "shared"
					elseif getgenv()[v] ~= nil then
						a = getgenv()[v]
						b = "getgenv()"
					end
					if not (a ~= nil and b ~= nil) then
						continue
					end
					teleportScript = b .. "['" .. tostring(v) .. "'] = " .. resolveIndex(a) .. "\n" .. teleportScript
				end
			end
			vape:Save()
			queue_on_teleport(teleportScript)
		end
	end))

	if not shared.vapereload then
		if not vape.Categories then
			return
		end
		if vape.Categories.Main.Options["GUI bind indicator"].Enabled then
			vape:CreateNotification(
				"Finished Loading",
				vape.VapeButton and "Press the button in the top right to open GUI"
					or "Press " .. table.concat(vape.Keybind, " + "):upper() .. " to open GUI",
				5
			)
		end
	end
end

local function mprint(tbl, indent, visited)
	indent = indent or 0
	visited = visited or {}
	if visited[tbl] then
		print(string.rep(" ", indent) .. "<Cyclic Reference>")
		return
	end
	visited[tbl] = true
	for key, value in pairs(tbl) do
		local prefix = string.rep(" ", indent)
		if type(value) == "table" then
			print(prefix .. tostring(key) .. " = {")
			mprint(value, indent + 4, visited)
			print(prefix .. "}")
		else
			print(prefix .. tostring(key) .. " = " .. tostring(value))
		end
	end
	local meta = getmetatable(tbl)
	if meta then
		print(string.rep(" ", indent) .. "Metatable:")
		if type(meta) ~= "table" then
			print(string.rep(" ", indent) .. "Metatable is not a table: " .. tostring(meta))
		else
			for key, value in pairs(meta) do
				local prefix = string.rep(" ", indent + 4)
				if type(value) == "function" then
					print(prefix .. tostring(key) .. " = <function>")
				elseif type(value) == "table" then
					print(prefix .. tostring(key) .. " = {")
					mprint(value, indent + 8, visited)
					print(prefix .. "}")
				else
					print(prefix .. tostring(key) .. " = " .. tostring(value))
				end
			end
		end
	end
end
getgenv().mprint = mprint

local VoidwareLoader
local createCustomSignal = function(key, delay)
	key = key or "Unknown"
	delay = delay or 0
	return setmetatable({
		__conns = {},
		__args = true,
		__delay = delay,
		__lastFire = nil,
		Connect = function(self, func, cleanFunc)
			if VoidwareLoader.Unloaded then
				return
			end
			assert(func ~= nil and type(func) == "function", "req not met")
			local connection = {
				func = func,
				once = false,
			}
			table.insert(self.__conns, connection)
			return {
				Disconnect = function()
					local id = table.find(self.__conns, connection)
					if id then
						table.remove(self.__conns, id)
						return true
					end
					return false
				end,
			}
		end,
		Once = function(self, func)
			if VoidwareLoader.Unloaded then
				return
			end
			assert(func ~= nil and type(func) == "function", "req not met")
			local connection = {
				func = func,
				once = true,
			}
			table.insert(self.__conns, connection)
			return {
				Disconnect = function()
					local id = table.find(self.__conns, connection)
					if id then
						table.remove(self.__conns, id)
						return true
					end
					return false
				end,
			}
		end,
		Fire = function(self, ...)
			if VoidwareLoader.Unloaded then
				return
			end
			if not self.__conns then
				return
			end
			local args = { ... }
			if not self.__args then
				bypass = args[1]
			end
			local delay = self.__delay
			if not bypass and self.__lastFire ~= nil and tick() - self.__lastFire < delay then
				if shared.VoidDev and shared.VoidwareNetworkingDebug then
					warn(`[Events]: Fire dropped for {tostring(key)}!`)
				end
				return
			end
			self.__lastFire = tick()
			if #self.__conns < 1 then
				if shared.VoidDev and shared.VoidwareNetworkingDebug then
					warn(`[Events]: Fired with no conns for {tostring(key)}!`)
				end
			end
			local toRemove = {}
			for i, connection in self.__conns do
				pcall(connection.func, unpack(args))
				if connection.once then
					table.insert(toRemove, i)
				end
			end
			for i = #toRemove, 1, -1 do
				table.remove(self.__conns, toRemove[i])
			end
			return self
		end,
		SetCooldown = function(self, val)
			self.__delay = val
			return self
		end,
		ArgCheck = function(self, val)
			if val == nil then
				val = not self.__args
			end
			self.__args = val
			return self
		end,
	}, {
		__index = function(self, key)
			if key == "Event" then
				return self
			elseif key == "Destroy" then
				return function()
					table.clear(self.__conns)
					self.__conns = nil
					self.__args = nil
					self.__delay = nil
					self.__lastFire = nil
					self = setmetatable({}, {
						__index = function()
							error(`Voidware Event "{tostring(key)}" was destroyed!`)
						end,
					})
				end
			end
			return rawget(self, key)
		end,
		__tostring = function()
			return `VOIDWARE_INTERNAL_EVENT_{tostring(key)}`
		end,
	})
end
VoidwareLoader = setmetatable({
	Unloaded = false,
	Services = setmetatable({}, {
		__index = function(self, key)
			key = tostring(key)
			if key == "InputService" then
				key = "UserInputService"
			end
			local a, b = pcall(function()
				return game:GetService(tostring(key))
			end)
			if not a then
				return
			end
			local c, d = pcall(function()
				return cloneref(b)
			end)
			if c then
				b = d
			end
			rawset(self, key, b)
			return b
		end,
	}),
	createCustomSignal = createCustomSignal,
	setupDecoratedCustomSignal = function(self, id)
		id = tostring(id)
		return function(sigName)
			sigName = tostring(sigName)
			return self.createCustomSignal(`{id}_{sigName}`)
		end
	end,
	VoidwareEvents = setmetatable({}, {
		__index = function(self, key)
			local res = createCustomSignal(key)
			rawset(self, key, res)
			return res
		end,
	}),
	wrap = function(self, func, reportDecorator)
		if not func then
			return
		end
		if type(func) ~= "function" then
			return func
		end
		return function(...)
			local args = { ... }
			local suc, err = pcall(func, unpack(args))
			if not suc then
				local report = { err = err }
				if reportDecorator then
					report = self:decorateReport(report, reportDecorator)
				end
				self:report(report)
			end
			return suc and err
		end
	end,
	decorateReport = function(self, report, decorator)
		if type(decorator) == "function" then
			return decorator(report)
		elseif type(decorator) == "table" then
			for i, v in decorator do
				report[i] = v
			end
			return report
		else
			return error(`Invalid decorator type: {tostring(type(decorator))}`)
		end
	end,
	throw = function(self, err)
		self:report({
			name = "Voidware Error",
			err = err,
		})
	end,
	report = function(self, report)
		report.name = report.name or report.type
		if not report.notifyBlacklisted and errorNotification ~= nil and type(errorNotification) == "function" then
			pcall(
				errorNotification,
				(report.name or "Voidware") .. " | Error",
				((report.err ~= nil and tostring(report.err)) or "Unknown Error"),
				10
			)
		end
		warn("[------------[ERROR REPORT]------------]")
		mprint(report)
		pcall(function()
			print(debug.traceback("traceback"))
		end)
		warn("[------------[ERROR REPORT]------------]")
	end,
}, {
	__index = function(self, key)
		error(`VoidwareLoader: Invalid key {tostring(key)}!`)
	end,
})
global().VoidwareLoader = VoidwareLoader

if not isfile("vape/profiles/gui.txt") then
	writefile("vape/profiles/gui.txt", "new")
end
local gui = "new"
if shared.RiseVapeMode then
	gui = "rise"
end

if not isfolder("vape/assets/" .. gui) then
	makefolder("vape/assets/" .. gui)
end
if shared.ACTIVE_LOADER then
	shared.ACTIVE_LOADER:Update("Loading Gui Library")
end
vape = pload(`guis/{gui}`, "GUI Library", true)
global().vape = vape

local PLACE_CONFIGS = setmetatable({
	CHEAT_ENGINE_SUPPORTED = setmetatable({
		["6872274481"] = true,
	}, {
		__call = function(self, place)
			place = tostring(place)
			if rawget(self, place) ~= nil then
				return `CE{place}`
			end
			return place
		end,
	}),
	[2619619496] = {
		[6872265039] = function()
			return tostring(game.PlaceId) == "6872265039"
		end,
		[6872274481] = function()
			return tostring(game.PlaceId) ~= "6872265039"
		end,
	},
}, {
	__call = function(self)
		local config = self[game.GameId]
		if not config then
			return game.PlaceId
		end
		if type(config) == "table" then
			for i, v in config do
				if not v() then
					continue
				end
				return i, true
			end
		else
			return config, true
		end
	end,
})

getgenv().InfoNotification = function(title, msg, dur)
	vape:CreateNotification(title, msg, dur)
end
getgenv().warningNotification = function(title, msg, dur)
	vape:CreateNotification(title, msg, dur, "warning")
end
getgenv().errorNotification = function(title, msg, dur)
	vape:CreateNotification(title, msg, dur, "alert")
end
getgenv().notif = function(...)
	return vape:CreateNotification(...)
end

--pload = VoidwareLoader:wrap(pload)

local __def_table = setmetatable({}, {
	__index = function(self)
		return self
	end,
	__call = function(self)
		return self
	end,
	__newindex = function(self)
		return self
	end,
})
local loader = shared.ACTIVE_LOADER or __def_table

if not shared.VapeIndependent then
	if shared.ACTIVE_LOADER then
		shared.ACTIVE_LOADER:Update("Loading Universal")
	end
	pload("games/universal")
	local place, found = PLACE_CONFIGS()
	vape.Place = place
	place = tostring(place)
	local id = shared.CheatEngineMode and PLACE_CONFIGS.CHEAT_ENGINE_SUPPORTED(place) or place
	if found then
		loader:Update(`Loading {id}.lua`, 20)
	end
	pload(`games/{id}`, place, found)
	pload(`games/VW{place}`, place, found)
	loader:Update("Finishing up...", 80)
	finishLoading()
	loader:Update("Successfully Loaded Voidware Bedwars :D", 100)
	task.delay(0.5, function()
		pcall(function()
			loader:Destroy()
		end)
	end)
else
	vape.Init = finishLoading
	return vape
end
