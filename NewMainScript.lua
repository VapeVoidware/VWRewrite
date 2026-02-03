local wait = not game:IsLoaded()
repeat
	task.wait()
until game:IsLoaded()
if wait then
	task.wait(7)
end
local isfile = isfile
	or function(file)
		local suc, res = pcall(function()
			return readfile(file)
		end)
		return suc and res ~= nil and res ~= ""
	end
local delfile = delfile or function(file)
	writefile(file, "")
end

if shared.VoidDev then
	shared.VapeDeveloper = shared.VoidDev
end

local CEMode
if shared.CheatEngineMode ~= nil then
	CEMode = shared.CheatEngineMode
end

local CE_EXECUTORS = shared.CE_EXECUTORS or {
	"solara",
	"cryptic",
	"xeno",
	"ember",
	"ronix",
}
local DEBUG_CHECK_TABLE = {
	type = "table",
	funcs = {
		"getupvalue",
		"getupvalues",
		"getconstants",
		"getproto",
	},
}
local function checkExecutor()
	if CEMode ~= nil then
		return CEMode
	end
	if (not getgenv) or (getgenv and type(getgenv) ~= "function") then
		return true
	end
	if getgenv and not global.shared then
		global.shared = {}
		return true
	end
	if getgenv and not global.debug then
		global.debug = {
			traceback = function(string)
				return string
			end,
		}
		return true
	end
	if getgenv and not global.require then
		return true
	end
	if getgenv and global.require and type(global.require) ~= "function" then
		return true
	end

	local executor = "UNKNOWN"
	local res = select(
		2,
		pcall(function()
			return string.lower(tostring(identifyexecutor()))
		end)
	)
	if not res then
		return true
	end
	executor = res
	if table.find(CE_EXECUTORS, executor) then
		return true
	end

	if type(debug) ~= DEBUG_CHECK_TABLE.type then
		return true
	else
		for i, v in pairs(DEBUG_CHECK_TABLE.funcs) do
			if not debug[v] or (debug[v] and type(debug[v]) ~= "function") then
				return true
			else
				--[[local suc, res = pcall(debug[v]) 
                if tostring(res) == "Not Implemented" then 
                    return true
                end--]]
			end
		end
	end

	return false
end

local suc, res = pcall(checkExecutor)
if suc and res ~= nil then
	CEMode = res
else
	CEMode = true
	warn(`Failure checking executor {tostring(res)}!`)
end

if CEMode then
	getgenv().cloneref = function(a)
		return a
	end
	local old = setthreadidentity
	if old then
		getgenv().setthreadidentity = function(...)
			local args = { ... }
			local suc, err = pcall(old, unpack(args))
			return suc and err
		end
	else
		getgenv().setthreadidentity = function() end
	end
	warn(`[CEMode]: Voidware Cheat Engine mode overwrite done`)
end

local function wipeFolder(path)
	if shared.VoidDev then
		return
	end
	if not isfolder(path) then
		return
	end
	for _, file in listfiles(path) do
		if file:find("loader") then
			continue
		end
		if isfile(file) then
			delfile(file)
		end
	end
end

for _, folder in { "vape", "vape/games", "vape/profiles", "vape/assets", "vape/libraries", "vape/guis" } do
	if not isfolder(folder) then
		makefolder(folder)
	end
end

if not shared.VapeDeveloper then
	local TESTING_COMMIT = "master"
	local PRODUCTION_COMMIT = "6220c44e18e94d003d4b94db4af97a805aac328b"
	local commit = shared.CustomCommit
		or (shared.TestingMode or shared.StagingMode) and TESTING_COMMIT
		or PRODUCTION_COMMIT
	if (isfile("vape/profiles/commit.txt") and readfile("vape/profiles/commit.txt") or "") ~= commit then
		wipeFolder("vape")
		wipeFolder("vape/games")
		wipeFolder("vape/guis")
		wipeFolder("vape/libraries")
	end
	writefile("vape/profiles/commit.txt", commit)
end

local REPO_OWNER = shared.REPO_OWNER or "VapeVoidware"
shared.REPO_OWNER = REPO_OWNER

local SAVE_BLACKLISTED = setmetatable({
	"6872274481",
	"main",
	__cache = {},
}, {
	__call = function(self, key)
		if shared.VoidDev then
			return false
		end
		if self.__cache[key] then
			return self.__cache[key]
		end
		for _, v in self do
			if type(v) == "table" then
				continue
			end
			if string.find(string.lower(tostring(key)), string.lower(v)) then
				self.__cache[key] = true
				return true
			end
		end
		self.__cache[key] = false
		return false
	end,
})
local function downloadFile(path, func)
	if not isfile(path) or SAVE_BLACKLISTED(path) then
		local suc, res = pcall(function()
			return game:HttpGet(
				'https://raw.githubusercontent.com/"..tostring(shared.REPO_OWNER).."/VWRewrite/'
					.. readfile("vape/profiles/commit.txt")
					.. "/"
					.. select(1, path:gsub("vape/", "")),
				true
			)
		end)
		if not suc or res == "404: Not Found" then
			error(res)
		end
		if SAVE_BLACKLISTED(path) then
			pcall(function()
				if isfile(path) then
					delfile(path)
				end
			end)
			return res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

if shared.VoidDev then
	shared.DEBUG_COUNT = shared.DEBUG_COUNT or 0
	shared.DEBUG_COUNT = shared.DEBUG_COUNT + 1
	warn(`DEBUG COUNT: {tostring(shared.DEBUG_COUNT)}`)
end

getgenv().pload = function(name, id, found)
	local part = ".lua"
	if name:find(".lua") or name:find(".json") then
		part = ""
	end
	if shared.VoidwareBedwarsObfuscationDebug and shared.VoidDev then
		if name:find("/") then
			local parts = name:split("/")
			local last = parts[#parts]
			if last then
				parts[#parts] = "obfuscated_" .. last
			end
			local resolved = ""
			for i, v in parts do
				resolved = resolved .. v .. (i == #parts and "" or "/")
			end
			if isfile(`vape/{resolved}{part}`) then
				warn(`[Obfuscation-Debug]: [1] Loading file ({tostring(resolved)}{part})!`)
				name = resolved
			end
		else
			local resolved = "obfuscated_" .. name
			if isfile(`vape/{resolved}{part}`) then
				warn(`[Obfuscation-Debug]: [2] Loading file ({tostring(resolved)}{part})!`)
				name = resolved
			end
		end
	end
	if shared.VoidwareBedwarsLoadingDebug then
		print(`vape/{name}{part}`)
	end
	local suc, download = pcall(function()
		return downloadFile(`vape/{name}{part}`), (id or name)
	end)
	if not suc and found then
		warn(`Load Error: [{tostring(id or name)}] {download}`)
		error(`Failure Loading {tostring(id or name)} [1]`)
	end
	local func, err = loadstring(download)
	if not (func ~= nil and type(func) == "function") and found then
		warn(`Load Error: [{tostring(id or name)}] {err}`)
		if shared.ACTIVE_LOADER then
			shared.ACTIVE_LOADER:Abort(`Couldn't load {(id or name)} [2] :c`)
			if shared.vape then
				pcall(function()
					shared.vape:DisableSaving()
				end)
			end
		end
		error(`Failure Loading {tostring(id or name)} [2]`)
	end
	local suc, res = pcall(function()
		return func()
	end)
	if not suc and found then
		warn(`Load Error: [{tostring(id or name)}] {res}`)
		if shared.ACTIVE_LOADER then
			shared.ACTIVE_LOADER:Abort(`Couldn't load {(id or name)} [3] :c`)
			if shared.vape then
				pcall(function()
					shared.vape:DisableSaving()
				end)
			end
		end
		error(`Failure Loading {tostring(id or name)} [3]`)
	end
	if shared.VoidwareBedwarsLoadingDebug then
		print(name, suc, res)
	end
	return suc and res
end

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
local loaderFile = pload("libraries/loader", "loader", true) or __def_table
loaderFile.Colors.Gradient = {
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(0.5, Color3.fromHex("#c41e3a")),
	ColorSequenceKeypoint.new(1, Color3.fromHex("#165b33")),
}
local loader = loaderFile:Loader()
pcall(function()
	shared.ACTIVE_LOADER:Destroy()
end)
shared.ACTIVE_LOADER = loader
loader:Update("Booting Up...", 0)
loader:Update("Loading main.lua", 10)

return pload("main")
