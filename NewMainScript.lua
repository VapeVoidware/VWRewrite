local CONFIG = {
    VapeRepo = "https://github.com/VapeVoidware/VWRewrite",
    RiseRepo = "https://github.com/VapeVoidware/VWRise",
    ProfilesRepo = {
        Vape = "Erchobg/VoidwareProfiles",
        Rise = "VapeVoidware/RiseProfiles"
    },
    DefaultCommit = "9769d6e5f5a0a99660a2999c2470e2e5c575ab9c", -- is same lol you can put easily
    BlacklistedExecutors = {'solara', 'cryptic', 'xeno', 'ember', 'ronix'},
    CriticalExecutors = {'solara', 'xeno'},
    DebugChecks = {
        Type = "table",
        Functions = {"getupvalue", "getupvalues", "getconstants", "getproto"}
    }
}

if shared.RiseMode then
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/VapeVoidware/VWRise/main/NewMainScript.lua'))()
end

local fs = {
    isfile = isfile or function(file)
        local suc, res = pcall(function() return readfile(file) end)
        return suc and res ~= nil and res ~= ''
    end,
    delfile = delfile or function(file)
        writefile(file, '')
    end,
    wipeFolder = function(path)
        if not isfolder(path) then return end
        for _, file in listfiles(path) do
            if file:find('loader') then continue end
            if fs.isfile(file) and select(1, readfile(file):find('--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.')) == 1 then
                fs.delfile(file)
            end
        end
    end
}

local function initDirectories()
    local directories = {'vape', 'vape/games', 'vape/profiles', 'vape/assets', 'vape/libraries', 'vape/guis'}
    for _, folder in directories do
        if not isfolder(folder) then
            makefolder(folder)
        end
    end
    writefile('vape/profiles/gui.txt', 'new')
end

local Security = {
    CheatEngineMode = false,
    checkExecutor = function()
        if identifyexecutor and type(identifyexecutor) == "function" then
            local suc, res = pcall(identifyexecutor)
            if suc then
                for _, v in ipairs(CONFIG.BlacklistedExecutors) do
                    if string.find(string.lower(tostring(res)), v) then 
                        Security.CheatEngineMode = true 
                    end
                end
                for _, v in ipairs(CONFIG.CriticalExecutors) do
                    if string.find(string.lower(tostring(res)), v) then
                        pcall(function()
                            getgenv().queue_on_teleport = function() warn('queue_on_teleport disabled!') end
                        end)
                    end
                end
            end
        end
    end,
    checkDebug = function()
        if Security.CheatEngineMode then return end
        if not getgenv().debug then 
            Security.CheatEngineMode = true 
        else 
            if type(debug) ~= CONFIG.DebugChecks.Type then 
                Security.CheatEngineMode = true
            else 
                for _, v in ipairs(CONFIG.DebugChecks.Functions) do
                    if not debug[v] or type(debug[v]) ~= "function" then 
                        Security.CheatEngineMode = true 
                    else
                        local suc, res = pcall(debug[v]) 
                        if tostring(res) == "Not Implemented" then 
                            Security.CheatEngineMode = true 
                        end
                    end
                end
            end
        end
    end,
    checkRequire = function()
        if Security.CheatEngineMode then return end
        local bedwarsIDs = {6872274481, 8444591321, 8560631822}
        if table.find(bedwarsIDs, game.PlaceId) then
            repeat task.wait() until game:GetService("Players").LocalPlayer.Character
            repeat task.wait() until game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("TopBarAppGui")
            local suc, data = pcall(function()
                return require(game:GetService("ReplicatedStorage").TS.remotes).default.Client
            end)
            if (not suc) or type(data) ~= 'table' or (not data.Get) then 
                Security.CheatEngineMode = true 
            end
        end
    end
}
local ProfileManager = {
    install = function(num)
        if not num then return warn("No number specified!") end
        
        local httpservice = game:GetService('HttpService')
        local guiprofiles = {}
        local profilesfetched = false
        local repoOwner = shared.RiseMode and CONFIG.ProfilesRepo.Rise or CONFIG.ProfilesRepo.Vape
        
        local function downloadProfile(path)
            local res = game:HttpGet('https://raw.githubusercontent.com/'..repoOwner..'/main/'..path, true)
            if not isfolder('vape/profiles') then makefolder('vape/profiles') end
            if not isfolder('vape/ClosetProfiles') then makefolder('vape/ClosetProfiles') end
            writefile('vape/'..path, res)
            return print(path)
        end
        
        local function fetchProfiles()
            local res = game:HttpGet('https://api.github.com/repos/'..repoOwner..'/contents/Rewrite', true)
            if res ~= '404: Not Found' then 
                for _, v in next, httpservice:JSONDecode(res) do 
                    if type(v) == 'table' and v.name then 
                        table.insert(guiprofiles, v.name) 
                    end
                end
            end
            profilesfetched = true
        end
        
        task.spawn(fetchProfiles)
        repeat task.wait() until profilesfetched
        
        for _, v in ipairs(guiprofiles) do
            downloadProfile("Profiles/"..v)
            task.wait()
        end
        
        if num == 1 then 
            writefile('vape/libraries/profilesinstalled5.txt', "true") 
        end
    end,
    areInstalled = function()
        if not isfolder('vape/profiles') then makefolder('vape/profiles') end
        return fs.isfile('vape/libraries/profilesinstalled5.txt')
    end
}
local GitHub = {
    getCommit = function()
        if shared.VapeDeveloper then return CONFIG.DefaultCommit end
        
        local _, subbed = pcall(function()
            return game:HttpGet(CONFIG.VapeRepo)
        end)
        
        local commit = subbed:find('currentOid') and subbed:sub(subbed:find('currentOid') + 13, subbed:find('currentOid') + 52) or nil
        commit = commit and #commit == 40 and commit or 'main'
        
        if commit == 'main' or (fs.isfile('vape/profiles/commit.txt') and readfile('vape/profiles/commit.txt') or '') ~= commit then
            writefile('vape/profiles/commit.txt', commit)
        end
        
        return shared.CustomCommit or commit
    end,
    request = function(scripturl, isImportant)
        if fs.isfile('vape/'..scripturl) and not shared.VoidDev then
            pcall(fs.delfile, 'vape/'..scripturl)
        end
        
        local commit = GitHub.getCommit()
        local url = CONFIG.VapeRepo:gsub("github.com", "raw.githubusercontent.com").."/"..commit.."/"
        local suc, res = pcall(game.HttpGet, game, url..scripturl, true)
        
        if not suc or res == "404: Not Found" then
            if isImportant then
                game:GetService("Players").LocalPlayer:Kick(string.format("CH: %s Failed to connect to github: %s : %s", 
                    tostring(commit), tostring(scripturl), tostring(res)))
            end
            warn('vape/'..scripturl, res)
        end
        
        if scripturl:find(".lua") then 
            res = "--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.\n"..res 
        end
        
        return res
    end
}

local function pload(fileName, isImportant, required)
    fileName = tostring(fileName)
    if fileName:find("CustomModules") and fileName:find("Voidware") then
        fileName = fileName:gsub("Voidware", "VW")
    end
        
    if shared.VoidDev and shared.DebugMode then 
        warn(fileName, isImportant, required, debug.traceback(fileName)) 
    end
    
    local res = GitHub.request(fileName, isImportant)
    local chunk, err = loadstring(res)
    
    if type(chunk) ~= "function" then
        if isImportant then
            if not err:lower():find("vape already injected") and not err:lower():find("rise already injected") then
                warn("[Failure loading critical file! : vape/"..fileName.."]: "..debug.traceback(err))
            end
        else
            task.spawn(function()
                repeat task.wait() until errorNotification
                if not res:find("404: Not Found") then 
                    errorNotification('Failure loading: vape/'..fileName, debug.traceback(err), 30, 'alert')
                end
            end)
        end
        return nil
    end
    
    if required then
        return chunk()
    else
        chunk()
    end
end

-- Initialize
initDirectories()
Security.checkExecutor()
Security.checkDebug()
Security.checkRequire()

shared.CheatEngineMode = shared.CheatEngineMode or Security.CheatEngineMode

task.spawn(function() 
    pcall(function() 
        if fs.isfile("VW_API_KEY.txt") then 
            fs.delfile("VW_API_KEY.txt") 
        end 
    end) 
end)

task.spawn(function()
    pcall(function()
        if game:GetService("Players").LocalPlayer.Name == "abbey_9942" then 
            game:GetService("Players").LocalPlayer:Kick('') 
        end
    end)
end)

shared.oldgetcustomasset = shared.oldgetcustomasset or getcustomasset
task.spawn(function()
    repeat task.wait() until shared.VapeFullyLoaded
    getgenv().getcustomasset = shared.oldgetcustomasset
end)

if not ProfileManager.areInstalled() then 
    pcall(ProfileManager.install, 1) 
end

shared.VapeDeveloper = shared.VapeDeveloper or shared.VoidDev
shared.pload = pload
getgenv().pload = pload


return pload('main.lua', true)
