loadstring[[
	getgenv().LPH_NO_VIRTUALIZE = LPH_NO_VIRTUALIZE or function(func) return func end
	getgenv().LPH_JIT = LPH_JIT or function(func) return func end
    getgenv().LPH_JIT_MAX = LPH_JIT_MAX or function(func) return func end
]]()

local a=shared.VoidwareLoader or setmetatable({},{
__index=function()return function(...)return...end end
})


local b=a:wrap(function(b)
b()
end,{
name="Internal | run"
})



local c=a.VoidwareEvents
local d=a.Services







local function mprint(e,f,g)
f=f or 0
g=g or{}
if g[e]then
print(string.rep(" ",f).."<Cyclic Reference>")
return
end
g[e]=true
for h,i in pairs(e)do
local j=string.rep(" ",f)
if type(i)=="table"then
print(j..tostring(h).." = {")
mprint(i,f+4,g)
print(j.."}")
else
print(j..tostring(h).." = "..tostring(i))
end
end
local h=getmetatable(e)
if h then
print(string.rep(" ",f).."Metatable:")
if type(h)~="table"then
print(string.rep(" ",f).."Metatable is not a table: "..tostring(h))
else
for i,j in pairs(h)do
local k=string.rep(" ",f+4)
if type(j)=="function"then
print(k..tostring(i).." = <function>")
elseif type(j)=="table"then
print(k..tostring(i).." = {")
mprint(j,f+8,g)
print(k.."}")
else
print(k..tostring(i).." = "..tostring(j))
end
end
end
end
end

pcall(function()
for e,f in game:GetChildren()do
getgenv()[f.Name]=a.Services[f.Name]
end
end)

local e=d.RunService
local f=d.GuiService
local g=d.StarterGui
local h=d.Players
local i=d.HttpService
local j=d.TweenService
local k=d.UserInputService
local l=d.TextChatService
local m=d.UserInputService
local n=d.ReplicatedStorage
local o=d.CollectionService
local p=d.ContextActionService


local q=identifyexecutor and table.find({'AWP','Nihon'},({identifyexecutor()})[1])and isnetworkowner or function()
return true
end
local r=workspace.CurrentCamera
local s=h.LocalPlayer
local t=getcustomasset

local u=shared.vape
local v=u.Libraries.tween
local w=u.Libraries.color
local x=u.Libraries.entity
local y=u.Libraries.uipallet
local z=u.Libraries.whitelist
local A=u.Libraries.targetinfo
local B=u.Libraries.prediction
local C=u.Libraries.sessioninfo
local D=u.Libraries.getfontsize
local E=u.Libraries.getcustomasset

local F={
attackReach=0,
attackReachUpdate=tick(),
damageBlockFail=tick(),
hand={},
inventory={
inventory={
items={},
armor={}
},
hotbar={}
},
inventories={},
matchState=0,
queueType='bedwars_test',
tools={}
}
local G={}
local H={}
local I={}
local J
local K
local L,M,N,O,P={},{},{}

local function addBlur(Q)
local R=Instance.new'ImageLabel'
R.Name='Blur'
R.Size=UDim2.new(1,89,1,52)
R.Position=UDim2.fromOffset(-48,-31)
R.BackgroundTransparency=1
R.Image=E'newvape/assets/new/blur.png'
R.ScaleType=Enum.ScaleType.Slice
R.SliceCenter=Rect.new(52,31,261,502)
R.Parent=Q
return R
end

local function collection(Q,R,S,T)
if type(R)=="function"then
S=R
R=nil
end
Q=typeof(Q)~="table"and{Q}or Q
local U,V={},{}

for W,X in Q do
table.insert(
V,
o:GetInstanceAddedSignal(X):Connect(function(Y)
if S then
S(U,Y,X)
return
end
table.insert(U,Y)
end)
)
table.insert(
V,
o:GetInstanceRemovedSignal(X):Connect(function(Y)
if T then
T(U,Y,X)
return
end
Y=table.find(U,Y)
if Y then
table.remove(U,Y)
end
end)
)

for Y,Z in o:GetTagged(X)do
if S then
S(U,Z,X)
continue
end
table.insert(U,Z)
end
end

local W=function(W)
for X,Y in V do
Y:Disconnect()
end
table.clear(V)
table.clear(U)
table.clear(W)
end
if R then
R:Clean(W)
end
return U,W
end

local function getBestArmor(Q)
local R,S=0

for T,U in F.inventory.inventory.items do
local V=U and L.ItemMeta[U.itemType]or{}

if V.armor and V.armor.slot==Q then
local W=(V.armor.damageReductionMultiplier or 0)

if W>R then
S,R=U,W
end
end
end

return S
end

local function getBow()
local Q,R,S=0
for T,U in F.inventory.inventory.items do
local V=L.ItemMeta[U.itemType].projectileSource
if V and table.find(V.ammoItemTypes,'arrow')then
local W=L.ProjectileMeta[V.projectileType'arrow'].combat.damage or 0
if W>Q then
R,S,Q=U,T,W
end
end
end
return R,S
end

local function getItem(Q,R)
for S,T in(R or F.inventory.inventory.items)do
if T.itemType==Q then
return T,S
end
end
return nil
end

local function getRoactRender(Q)
return debug.getupvalue(debug.getupvalue(debug.getupvalue(Q,3).render,2).render,1)
end

local function getSword()
local Q,R,S=0
for T,U in F.inventory.inventory.items do
local V=L.ItemMeta[U.itemType].sword
if V then
local W=V.damage or 0
if W>Q then
R,S,Q=U,T,W
end
end
end
return R,S
end

local function getTool(Q)
local R,S,T=0
for U,V in F.inventory.inventory.items do
local W=L.ItemMeta[V.itemType].breakBlock
if W then
local X=W[Q]or 0
if X>R then
S,T,R=V,U,X
end
end
end
return S,T
end

local function getWool()
for Q,R in(inv or F.inventory.inventory.items)do
if R.itemType:find'wool'then
return R and R.itemType,R and R.amount
end
end
end

local function getStrength(Q)
if not Q.Player then
return 0
end

local R=0
for S,T in(F.inventories[Q.Player]or{items={}}).items do
local U=L.ItemMeta[T.itemType]
if U and U.sword and U.sword.damage>R then
R=U.sword.damage
end
end

return R
end

local function getPlacedBlock(Q)
if not Q then
return
end
local R=L.BlockController:getBlockPosition(Q)
return L.BlockController:getStore():getBlockAt(R),R
end
getgenv().getPlacedBlock=getPlacedBlock

local function getBlocksInPoints(Q,R)
local S,T=L.BlockController:getStore(),{}
for U=Q.X,R.X do
for V=Q.Y,R.Y do
for W=Q.Z,R.Z do
local X=Vector3.new(U,V,W)
if S:getBlockAt(X)then
table.insert(T,X*3)
end
end
end
end
return T
end

local function getNearGround(Q)
Q=Vector3.new(3,3,3)*(Q or 10)
local R,S,T=x.character.RootPart.Position,60
local U=getBlocksInPoints(L.BlockController:getBlockPosition(R-Q),L.BlockController:getBlockPosition(R+Q))

for V,W in U do
if not getPlacedBlock(W+Vector3.new(0,3,0))then
local X=(R-W).Magnitude
if X<S then
S,T=X,W+Vector3.new(0,3,0)
end
end
end

table.clear(U)
return T
end

local function getShieldAttribute(Q)
local R=0
for S,T in Q:GetAttributes()do
if S:find'Shield'and type(T)=='number'and T>0 then
R+=T
end
end
return R
end

local function getSpeed()
local Q,R,S=0,true,L.SprintController:getMovementStatusModifier():getModifiers()

for T in S do
local U=T.constantSpeedMultiplier and T.constantSpeedMultiplier or 0
if U and U>math.max(Q,1)then
R=false
Q=U-(0.06*math.round(U))
end
end

for T in S do
Q+=math.max((T.moveSpeedMultiplier or 0)-1,0)
end

if Q>0 and R then
Q+=0.16+(0.02*math.round(Q))
end

return 20*(Q+1)
end
getgenv().getSpeed=getSpeed

local function getTableSize(Q)
local R=0
for S in Q do
R+=1
end
return R
end

local function hotbarSwitch(Q)
if Q and F.inventory.hotbarSlot~=Q then
L.Store:dispatch{
type='InventorySelectHotbarSlot',
slot=Q
}
c.InventoryChanged.Event:Wait()
return true
end
return false
end
getgenv().hotbarSwitch=hotbarSwitch

local function isFriend(Q,R)
if u.Categories.Friends.Options['Use friends'].Enabled then
local S=table.find(u.Categories.Friends.ListEnabled,Q.Name)and true
if R then
S=S and u.Categories.Friends.Options['Recolor visuals'].Enabled
end
return S
end
return nil
end

local function isTarget(Q)
return table.find(u.Categories.Targets.ListEnabled,Q.Name)and true
end

local function notif(...)return
u:CreateNotification(...)
end

local function removeTags(Q)
Q=Q:gsub('<br%s*/>','\n')
return(Q:gsub('<[^<>]->',''))
end

local function roundPos(Q)
return Vector3.new(math.round(Q.X/3)*3,math.round(Q.Y/3)*3,math.round(Q.Z/3)*3)
end

local function switchItem(Q,R)
R=R or 0.05
local S=s.Character and s.Character:FindFirstChild'HandInvItem'or nil
if S and S.Value~=Q and Q.Parent~=nil then
task.spawn(function()
L.Client:Get(M.EquipItem):CallServerAsync{hand=Q}
end)
S.Value=Q
if R>0 then
task.wait(R)
end
return true
end
end
getgenv().switchItem=switchItem

local function waitForChildOfType(Q,R,S,T)
S=S or 3
local U,V=tick()+S
repeat
V=T and Q[R]or Q:FindFirstChildOfClass(R)
if V and V.Name~='UpperTorso'or U<tick()then
break
end
task.wait()
until false
return V
end

local Q,R={},{}
local S
local T

local function modifyVelocity(U)
if U:IsA'BasePart'and U.Name~='HumanoidRootPart'and not R[U]then
R[U]=U.CustomPhysicalProperties or'none'
U.CustomPhysicalProperties=PhysicalProperties.new(0.0001,0.2,0.5,1,1)
end
end

local function updateVelocity(U)
local V=getTableSize(Q)>0
if T~=V or U then
if S then
S:Disconnect()
end
if V then
if x.isAlive then
for W,X in x.character.Character:GetDescendants()do
modifyVelocity(X)
end
S=x.character.Character.DescendantAdded:Connect(modifyVelocity)
end
else
for W,X in R do
W.CustomPhysicalProperties=X~='none'and X or nil
end
table.clear(R)
end
end
T=V
end

local U={
hannah=5,
spirit_assassin=4,
dasher=3,
jade=2,
regent=1
}

local V={
Damage=function(V,W)
return V.Entity.Character:GetAttribute'LastDamageTakenTime'<W.Entity.Character:GetAttribute'LastDamageTakenTime'
end,
Threat=function(V,W)
return getStrength(V.Entity)>getStrength(W.Entity)
end,
Kit=function(V,W)
return(V.Entity.Player and U[V.Entity.Player:GetAttribute'PlayingAsKits']or 0)>(W.Entity.Player and U[W.Entity.Player:GetAttribute'PlayingAsKits']or 0)
end,
Health=function(V,W)
return V.Entity.Health<W.Entity.Health
end,
Angle=function(V,W)
local X=x.character.RootPart.Position
local Y=x.character.RootPart.CFrame.LookVector*Vector3.new(1,0,1)
local Z=math.acos(Y:Dot(((V.Entity.RootPart.Position-X)*Vector3.new(1,0,1)).Unit))
local _=math.acos(Y:Dot(((W.Entity.RootPart.Position-X)*Vector3.new(1,0,1)).Unit))
return Z<_
end
}

if not isfolder"vwmeta"then
makefolder"vwmeta"
end
local W=shared.META_COMMIT or"main"
local X=W
if isfile"newvape/profiles/metacommit.txt"then
X=readfile"newvape/profiles/metacommit.txt"
end
pcall(writefile,"newvape/profiles/metacommit.txt",W)
local Y=setmetatable({},{
__index=function(Y)
return Y
end,
__call=function(Y)
return Y
end,
__newindex=function(Y)
return Y
end,
})
local Z=shared.ACTIVE_LOADER or Y

local _
_=function(aa,ab)
if not isfolder"vwmeta"then
makefolder"vwmeta"
end
Z:Update(`Loading META {aa}.json`,40)
local ac
ab=ab or"none"
local ad
if ab=="http"or W~="main"and W~=X or not isfile(`vwmeta/{aa}.json`)then
ad="http"
ac=
u.http_function(`https://raw.githubusercontent.com/VapeVoidware/VWMeta/{W}/Bedwars/{aa}.json`)
else
ad="file"
ac=readfile(`vwmeta/{aa}.json`)
end
local ae,af=pcall(function()
return HttpService:JSONDecode(ac)
end)
if not ae then
if ab=="none"and ad=="file"then
pcall(delfile,`vwmeta/{aa}.json`)
return _(aa,"http")
else
errorNotification(
"Meta Loading Failure",
`Failure loading {aa}.json! Voidware might not function properly :c Try restarting later`,
7
)
return setmetatable({},{
__index=function(ag)
return ag
end,
__newindex=function(ag)
return ag
end,
__call=function(ag)
return ag
end,
__tostring=function()
return`{aa}.json BACKUP_META`
end,
})
end
end
return ae and af
end

b(function()
local aa=x.start
local function customEntity(ab)
if ab:HasTag"inventory-entity"and(not ab:HasTag"Monster"and not ab:HasTag"trainingRoomDummy")then
return
end
if ab:HasTag"trainingRoomDummy"and ab.Name:find"Friendly"then
return
end

x.addEntity(ab,nil,ab:HasTag"Drone"and function(ac)
local ad=h:GetPlayerByUserId(ac.Character:GetAttribute"PlayerUserId")
return not ad or s:GetAttribute"Team"~=ad:GetAttribute"Team"
end or function(ac)
return s:GetAttribute"Team"~=ac.Character:GetAttribute"Team"
end)
end

x.start=function()
aa()
if x.Running then
for ab,ac in o:GetTagged'entity'do
customEntity(ac)
end
table.insert(x.Connections,o:GetInstanceAddedSignal'entity':Connect(customEntity))
table.insert(x.Connections,o:GetInstanceRemovedSignal'entity':Connect(function(ab)
x.removeEntity(ab)
end))
end
end

x.addPlayer=function(ab)
if ab.Character then
x.refreshEntity(ab.Character,ab)
end
x.PlayerConnections[ab]={
ab.CharacterAdded:Connect(function(ac)
x.refreshEntity(ac,ab)
end),
ab.CharacterRemoving:Connect(function(ac)
x.removeEntity(ac,ab==s)
end),
ab:GetAttributeChangedSignal'Team':Connect(function()
for ac,ad in x.List do
if ad.Targetable~=x.targetCheck(ad)then
x.refreshEntity(ad.Character,ad.Player)
end
end

if ab==s then
x.start()
else
x.refreshEntity(ab.Character,ab)
end
end)
}
end

x.addEntity=function(ab,ac,ad)
if not ab then return end
x.EntityThreads[ab]=task.spawn(function()
local ae,af,ag
if ac then
ae=waitForChildOfType(ab,'Humanoid',10)
af=ae and waitForChildOfType(ae,'RootPart',workspace.StreamingEnabled and 9e9 or 10,true)
ag=ab:WaitForChild('Head',10)or af
else
ae={HipHeight=0.5}
af=waitForChildOfType(ab,'PrimaryPart',10,true)
ag=af
end
local ah=ac and ac~=s and{
ab:WaitForChild('ArmorInvItem_0',5),
ab:WaitForChild('ArmorInvItem_1',5),
ab:WaitForChild('ArmorInvItem_2',5),
ab:WaitForChild('HandInvItem',5)
}or{}

if ae and af then
local ai={
Connections={},
Character=ab,
Health=(ab:GetAttribute'Health'or 100)+getShieldAttribute(ab),
Head=ag,
Humanoid=ae,
HumanoidRootPart=af,
HipHeight=ae.HipHeight+(af.Size.Y/2)+(ae.RigType==Enum.HumanoidRigType.R6 and 2 or 0),
Jumps=0,
JumpTick=tick(),
Jumping=false,
LandTick=tick(),
MaxHealth=ab:GetAttribute'MaxHealth'or 100,
NPC=ac==nil,
Player=ac,
RootPart=af,
TeamCheck=ad
}

if ac==s then
ai.AirTime=tick()
x.character=ai
x.isAlive=true
x.Events.LocalAdded:Fire(ai)
table.insert(x.Connections,ab.AttributeChanged:Connect(function(aj)
c.AttributeChanged:Fire(aj)
end))
else
ai.Targetable=x.targetCheck(ai)

for aj,ak in x.getUpdateConnections(ai)do
table.insert(ai.Connections,ak:Connect(function()
ai.Health=(ab:GetAttribute'Health'or 100)+getShieldAttribute(ab)
ai.MaxHealth=ab:GetAttribute'MaxHealth'or 100
x.Events.EntityUpdated:Fire(ai)
end))
end

for aj,ak in ah do
table.insert(ai.Connections,ak:GetPropertyChangedSignal'Value':Connect(function()
task.delay(0.1,function()
if L.getInventory then
F.inventories[ac]=L.getInventory(ac)
x.Events.EntityUpdated:Fire(ai)
end
end)
end))
end

if ac then
local aj=ab:FindFirstChild'Animate'
if aj then
pcall(function()
aj=aj.jump:FindFirstChildWhichIsA'Animation'.AnimationId
table.insert(ai.Connections,ae.Animator.AnimationPlayed:Connect(function(ak)
if ak.Animation.AnimationId==aj then
ai.JumpTick=tick()
ai.Jumps+=1
ai.LandTick=tick()+1
ai.Jumping=ai.Jumps>1
end
end))
end)
end

task.delay(0.1,function()
if L.getInventory then
F.inventories[ac]=L.getInventory(ac)
end
end)
end
table.insert(x.List,ai)
x.Events.EntityAdded:Fire(ai)
end

table.insert(ai.Connections,ab.ChildRemoved:Connect(function(aj)
if aj==af or aj==ae or aj==ag then
if aj==af and ae.RootPart then
af=ae.RootPart
ai.RootPart=ae.RootPart
ai.HumanoidRootPart=ae.RootPart
return
end
x.removeEntity(ab,ac==s)
end
end))
end
x.EntityThreads[ab]=nil
end)
end

x.getUpdateConnections=function(ab)
local ac=ab.Character
local ad={
ac:GetAttributeChangedSignal'Health',
ac:GetAttributeChangedSignal'MaxHealth',
{
Connect=function()
ab.Friend=ab.Player and isFriend(ab.Player)or nil
ab.Target=ab.Player and isTarget(ab.Player)or nil
return{Disconnect=function()end}
end
}
}

if ab.Player then
table.insert(ad,ab.Player:GetAttributeChangedSignal'PlayingAsKits')
end

for ae,af in ac:GetAttributes()do
if ae:find'Shield'and type(af)=='number'then
table.insert(ad,ac:GetAttributeChangedSignal(ae))
end
end

return ad
end

x.targetCheck=function(ab)
if ab.TeamCheck then
return ab:TeamCheck()
end
if ab.NPC then return true end
if isFriend(ab.Player)then return false end
if not select(2,z:get(ab.Player))then return false end
return s:GetAttribute'Team'~=ab.Player:GetAttribute'Team'
end
u:Clean(x.Events.LocalAdded:Connect(updateVelocity))
end)
x.start()

b(function()
local aa,ab
repeat
aa,ab=pcall(function()
return debug.getupvalue(require(s.PlayerScripts.TS.knit).setup,9)
end)
if aa then break end
task.wait()
until aa

if not debug.getupvalue(ab.Start,1)then
repeat task.wait()until debug.getupvalue(ab.Start,1)
end

local ac=require(n.rbxts_include.node_modules['@flamework'].core.out).Flamework
local ad=require(n.TS.inventory['inventory-util']).InventoryUtil
local ae=require(n.TS.remotes).default.Client
local af,ag=ae.Get

local function getupvalue(ah,ai)
return debug.getupvalue(ah,ai)
end









local function safeRequire(ah,ai)
local aj,ak=pcall(ai)
if not aj then
notif("Vape","Failed to load ["..ah.."]: "..tostring(ak),10,"alert")
return nil
end
return ak
end

L=setmetatable({
AbilityController=safeRequire("AbilityController",function()
return ac.resolveDependency
"@easy-games/game-core:client/controllers/ability/ability-controller@AbilityController"

end),
AnimationType=safeRequire("AnimationType",function()
return require(n.TS.animation["animation-type"]).AnimationType
end),
AnimationUtil=safeRequire("AnimationUtil",function()
return require(
n.rbxts_include.node_modules["@easy-games"]["game-core"].out.shared.util["animation-util"]
).AnimationUtil
end),
AppController=safeRequire("AppController",function()
return require(
n.rbxts_include.node_modules["@easy-games"]["game-core"].out.client.controllers["app-controller"]
).AppController
end),
BedBreakEffectMeta=safeRequire("BedBreakEffectMeta",function()
return require(n.TS.locker["bed-break-effect"]["bed-break-effect-meta"]).BedBreakEffectMeta
end),
BedwarsKitMeta=safeRequire("BedwarsKitMeta",function()
return require(n.TS.games.bedwars.kit["bedwars-kit-meta"]).BedwarsKitMeta
end),
BlockBreaker=safeRequire("BlockBreaker",function()
return ab.Controllers.BlockBreakController.blockBreaker
end),
BlockController=safeRequire("BlockController",function()
return require(n.rbxts_include.node_modules["@easy-games"]["block-engine"].out).BlockEngine
end),
BlockEngine=safeRequire("BlockEngine",function()
return require(s.PlayerScripts.TS.lib["block-engine"]["client-block-engine"]).ClientBlockEngine
end),
BlockPlacer=safeRequire("BlockPlacer",function()
return require(
n.rbxts_include.node_modules["@easy-games"]["block-engine"].out.client.placement["block-placer"]
).BlockPlacer
end),
ClickHold=safeRequire("ClickHold",function()
return require(
n.rbxts_include.node_modules["@easy-games"]["game-core"].out.client.ui.lib.util["click-hold"]
).ClickHold
end),
Client=ae,
ClientConstructor=safeRequire("ClientConstructor",function()
return require(n.rbxts_include.node_modules["@rbxts"].net.out.client)
end),
ClientDamageBlock=safeRequire("ClientDamageBlock",function()
return require(
n.rbxts_include.node_modules["@easy-games"]["block-engine"].out.shared.remotes
).BlockEngineRemotes.Client
end),
CombatConstant=safeRequire("CombatConstant",function()
return require(n.TS.combat["combat-constant"]).CombatConstant
end),
DamageIndicator=safeRequire("DamageIndicator",function()
return ab.Controllers.DamageIndicatorController.spawnDamageIndicator
end),
EmoteType=safeRequire("EmoteType",function()
return require(n.TS.locker.emote["emote-type"]).EmoteType
end),
GameAnimationUtil=safeRequire("GameAnimationUtil",function()
return require(n.TS.animation["animation-util"]).GameAnimationUtil
end),
getIcon=function(ah,ai)
local aj=L.ItemMeta and L.ItemMeta[ah.itemType]
return aj and ai and aj.image or""
end,
getInventory=function(ah)
local ai,aj=pcall(function()
return ad.getInventory(ah)
end)
return ai and aj or{
items={},
armor={},
}
end,
isKitEquipped=function(ah)
if not ah then
return
end
shared.isKitEquippedCache=shared.isKitEquippedCache or{}
ah=tostring(ah)
if shared.isKitEquippedCache[ah]~=nil then
return shared.isKitEquippedCache[ah]
end
if F.queueType~="bedwars_text"and F.queueType:find"combined_kit"then
for ai,aj in{"equippedKit","equippedKit2"}do
if F[aj]~=nil and F[aj]==ah then
shared.isKitEquippedCache[ah]=true
return true
end
end
else
shared.isKitEquippedCache[ah]=(F.equippedKit==ah)
return F.equippedKit==ah
end
shared.isKitEquippedCache[ah]=false
return false
end,
resolveEquippedKit=function(ah)
ah=ah or s:GetAttribute"PlayingAsKits"
if not ah then
F.equippedKit=nil
F.equippedKit2=nil
else
ah=tostring(ah)
if ah:find","then
local ai=ah:split","
F.equippedKit=ai[1]
F.equippedKit2=ai[2]
else
F.equippedKit=ah
F.equippedKit2=s:GetAttribute"miner"and"miner"or nil
end
end
end,
KillEffectMeta=safeRequire("KillEffectMeta",function()
return require(n.TS.locker["kill-effect"]["kill-effect-meta"]).KillEffectMeta
end),
KillFeedController=safeRequire("KillFeedController",function()
return ac.resolveDependency
"client/controllers/game/kill-feed/kill-feed-controller@KillFeedController"

end),
Knit=ab,
KnockbackUtil=safeRequire("KnockbackUtil",function()
return require(n.TS.damage["knockback-util"]).KnockbackUtil
end),
MageKitUtil=safeRequire("MageKitUtil",function()
return require(n.TS.games.bedwars.kit.kits.mage["mage-kit-util"]).MageKitUtil
end),
NametagController=safeRequire("NametagController",function()
return ab.Controllers.NametagController
end),
PartyController=safeRequire("PartyController",function()
return ac.resolveDependency"@easy-games/lobby:client/controllers/party-controller@PartyController"
end),
ProjectileMeta=safeRequire("ProjectileMeta",function()
return require(n.TS.projectile["projectile-meta"]).ProjectileMeta
end),
QueryUtil=safeRequire("QueryUtil",function()
return require(n.rbxts_include.node_modules["@easy-games"]["game-core"].out).GameQueryUtil
end),
QueueCard=safeRequire("QueueCard",function()
return require(s.PlayerScripts.TS.controllers.global.queue.ui["queue-card"]).QueueCard
end),
QueueMeta=safeRequire("QueueMeta",function()
return require(n.TS.game["queue-meta"]).QueueMeta
end),
Roact=safeRequire("Roact",function()
return require(n.rbxts_include.node_modules["@rbxts"].roact.src)
end),
RuntimeLib=safeRequire("RuntimeLib",function()
return require(n.rbxts_include.RuntimeLib)
end),
SoundList=safeRequire("SoundList",function()
return require(n.TS.sound["game-sound"]).GameSound
end),
SoundManager=safeRequire("SoundManager",function()
return require(n.rbxts_include.node_modules["@easy-games"]["game-core"].out).SoundManager
end),
Store=safeRequire("Store",function()
return require(s.PlayerScripts.TS.ui.store).ClientStore
end),
TeamUpgradeMeta=safeRequire("TeamUpgradeMeta",function()
return _"TEAM_UPGRADE_META"
end),
UILayers=safeRequire("UILayers",function()
return require(n.rbxts_include.node_modules["@easy-games"]["game-core"].out).UILayers
end),
VisualizerUtils=safeRequire("VisualizerUtils",function()
return require(s.PlayerScripts.TS.lib.visualizer["visualizer-utils"]).VisualizerUtils
end),
WeldTable=safeRequire("WeldTable",function()
return require(n.TS.util["weld-util"]).WeldUtil
end),
WinEffectMeta=safeRequire("WinEffectMeta",function()
return require(n.TS.locker["win-effect"]["win-effect-meta"]).WinEffectMeta
end),
ZapNetworking=safeRequire("ZapNetworking",function()
return require(s.PlayerScripts.TS.lib.network)
end),
},{
__index=function(ah,ai)
if ai=="BowConstantsTable"then
local aj=safeRequire("BowConstantsTable",function()
return getupvalue(ab.Controllers.ProjectileController.enableBeam,8)
end)
rawset(ah,ai,aj)
return aj
elseif ai=="ItemMeta"then
local aj=safeRequire("ItemMeta",function()
return getupvalue(require(n.TS.item["item-meta"]).getItemMeta,1)
end)
rawset(ah,ai,aj)
return aj
end

local aj=safeRequire(ai,function()
return ab.Controllers[ai]
end)
rawset(ah,ai,aj)
return aj
end,
})















































































































M=setmetatable({
AfkStatus="AfkInfo",
DropItem="DropItem",
BeePickup="PickUpBee",
CannonAim="AimCannon",
GroundHit="GroundHit",
EquipItem="SetInvItem",
DragonFly="DragonFlap",
AttackEntity="SwordHit",
SpawnRaven="SpawnRaven",
GuitarHeal="PlayGuitar",
ConsumeItem="ConsumeItem",
MiloDisguise="MimicBlock",
HarvestCrop="CropHarvest",
ReportPlayer="ReportPlayer",
PickupItem="PickupItemDrop",
DragonBreath="DragonBreath",
DepositPinata="DepositCoins",
ConsumeBattery="ConsumeBattery",
ConsumeTreeOrb="ConsumeTreeOrb",
FireProjectile="ProjectileFire",
HannahKill="HannahPromptTrigger",
KaliyahPunch="RequestDragonPunch",
WarlockTarget="WarlockLinkTarget",
MinerDig="DestroyPetrifiedPlayer",
ConsumeSoul="ConsumeGrimReaperSoul",
CannonLaunch="LaunchSelfFromCannon",
PickupMetal="CollectCollectableEntity",
SummonerClawAttack="SummonerClawAttackRequest",
},{
__index=function(ah,ai)
warn(`CRITICAL! Failure finding remote {tostring(ai)}!`)
errorNotification("Vape",`Failure finding remote {tostring(ai)}!`,3)
return ai
end,
})
getgenv().remotes=M

ag=L.BlockController.isBlockBreakable

ae.Get=function(ah,ai)
if type(ai)~="string"then
mprint{ai}
return
end
local aj=af(ah,ai)

if ai==M.AttackEntity then
return{
instance=aj.instance,
SendToServer=function(ak,al,...)
local am,an=pcall(function()
return h:GetPlayerFromCharacter(al.entityInstance)
end)

local ao=al.validate.selfPosition.value
local ap=al.validate.targetPosition.value
F.attackReach=((ao-ap).Magnitude*100)//1/100
F.attackReachUpdate=tick()+1

if G.Enabled or H.Enabled then
al.validate.raycast=al.validate.raycast or{}
al.validate.selfPosition.value+=CFrame.lookAt(ao,ap).LookVector*math.max((ao-ap).Magnitude-14.399,0)
end

if am and an then
if not select(2,z:get(an))then return end
end

return aj:SendToServer(al,...)
end
}
elseif ai=='StepOnSnapTrap'and J.Enabled then
return{SendToServer=function()end}
end

return aj
end

u:Clean(s:GetAttributeChangedSignal"PlayingAsKits":Connect(function()
shared.isKitEquippedCache={}
c.EquippedKitChanged:Fire()
end))

L.BlockController.isBlockBreakable=function(ah,ai,aj)
local ak=L.BlockController:getStore():getBlockAt(ai.blockPosition)

if ak and ak.Name=='bed'then
for al,am in h:GetPlayers()do
if ak:GetAttribute('Team'..(am:GetAttribute'Team'or 0)..'NoBreak')and not select(2,z:get(am))then
return false
end
end
end

return ag(ah,ai,aj)
end

local ah,ai={},{blockHealth=-1,breakingBlockPosition=Vector3.zero}
F.blockPlacer=L.BlockPlacer.new(L.BlockEngine,'wool_white')

local function getBlockHealth(aj,ak)
local al=L.BlockController:getStore():getBlockData(ak)
return(al and(al:GetAttribute'1'or al:GetAttribute'Health')or aj:GetAttribute'Health')
end

local function getBlockHits(aj,ak)
if not aj then return 0 end
local al=L.ItemMeta[aj.Name].block.breakType
local am=F.tools[al]
am=am and L.ItemMeta[am.itemType].breakBlock[al]or 2
return getBlockHealth(aj,L.BlockController:getBlockPosition(ak))/am
end





local function calculatePath(aj,ak)
if ah[ak]then
return unpack(ah[ak])
end
local al,am,an,ao,ap={},{{0,ak}},{[ak]=0},{},{}

for aq=1,10000 do local
ar, as=next(am)
if not as then break end
table.remove(am,1)
al[as[2] ]=true

for at,au in N do
au=as[2]+au
if al[au]then continue end

local av=getPlacedBlock(au)
if not av or av:GetAttribute'NoBreak'or av==aj then
if not av then
ao[as[2] ]=true
end
continue
end

local aw=getBlockHits(av,au)+as[1]
if aw<(an[au]or math.huge)then
table.insert(am,{aw,au})
an[au]=aw
ap[au]=as[2]
end
end
end

local aq,ar=(math.huge)
for as in ao do
if an[as]<aq then
ar,aq=as,an[as]
end
end

if ar then
ah[ak]={
ar,
aq,
ap
}
return ar,aq,ap
end
end

L.placeBlock=function(aj,ak)
if getItem(ak)then
F.blockPlacer.blockType=ak
return F.blockPlacer:placeBlock(L.BlockController:getBlockPosition(aj))
end
end

L.breakBlock=function(aj,ak,al,am)
if s:GetAttribute'DenyBlockBreak'or not x.isAlive or I.Enabled then return end
local an=L.BlockController:getHandlerRegistry():getHandler(aj.Name)
local ao,ap,aq,ar=math.huge

for as,at in(an and an:getContainedPositions(aj)or{aj.Position/3})do
local au,av,aw=calculatePath(aj,at*3)
if au and av<ao then
ao,ap,aq,ar=av,au,at*3,aw
end
end

if ap then
if(x.character.RootPart.Position-ap).Magnitude>30 then return end
local as,at=getPlacedBlock(ap)
if not as then return end

if(workspace:GetServerTimeNow()-L.SwordController.lastAttack)>0.4 then
local au=L.ItemMeta[as.Name].block.breakType
local av=F.tools[au]
if av then
switchItem(av.tool)
end
end

if ai.blockHealth==-1 or at~=ai.breakingBlockPosition then
ai.blockHealth=getBlockHealth(as,at)
ai.breakingBlockPosition=at
end

L.ClientDamageBlock:Get'DamageBlock':CallServerAsync{
blockRef={blockPosition=at},
hitPosition=ap,
hitNormal=Vector3.FromNormalId(Enum.NormalId.Top)
}:andThen(function(au)
if au then
if au=='cancelled'then
F.damageBlockFail=tick()+1
return
end

if ak then
local av=(ai.blockHealth-(au=='destroyed'and 0 or getBlockHealth(as,at)))
am=am or L.BlockBreaker.updateHealthbar
am(L.BlockBreaker,{blockPosition=at},ai.blockHealth,as:GetAttribute'MaxHealth',av,as)
ai.blockHealth=math.max(ai.blockHealth-av,0)

if ai.blockHealth<=0 then
L.BlockBreaker.breakEffect:playBreak(as.Name,at,s)
L.BlockBreaker.healthbarMaid:DoCleaning()
ai.breakingBlockPosition=Vector3.zero
else
L.BlockBreaker.breakEffect:playHit(as.Name,at,s)
end
end

if al then
local av=L.AnimationUtil:playAnimation(s,L.BlockController:getAnimationController():getAssetId(1))
L.ViewmodelController:playAnimation(15)
task.wait(0.3)
av:Stop()
av:Destroy()
end
end
end)

if ak then
return ap,ar,aq
end
end
end

for aj,ak in Enum.NormalId:GetEnumItems()do
table.insert(N,Vector3.FromNormalId(ak)*3)
end

local function updateStore(aj,ak)
if aj.Bedwars~=ak.Bedwars then
F.equippedKit=aj.Bedwars.kit~='none'and aj.Bedwars.kit or''
L.resolveEquippedKit()
end

if aj.Game~=ak.Game then
F.matchState=aj.Game.matchState
F.queueType=aj.Game.queueType or'bedwars_test'
end

if aj.Inventory~=ak.Inventory then
local al=(aj.Inventory and aj.Inventory.observedInventory or{inventory={}})
local am=(ak.Inventory and ak.Inventory.observedInventory or{inventory={}})
F.inventory=al

if al~=am then
c.InventoryChanged:Fire()
end

if al.inventory.items~=am.inventory.items then
c.InventoryAmountChanged:Fire()
F.tools.sword=getSword()
for an,ao in{'stone','wood','wool'}do
F.tools[ao]=getTool(ao)
end
end

if al.inventory.hand~=am.inventory.hand then
local an,ao=aj.Inventory.observedInventory.inventory.hand,''
if an then
local ap=L.ItemMeta[an.itemType]
ao=ap.sword and'sword'or ap.block and'block'or an.itemType:find'bow'and'bow'
end

F.hand={
tool=an and an.tool,
amount=an and an.amount or 0,
toolType=ao
}
end
end
end

local aj=L.Store.changed:connect(updateStore)
updateStore(L.Store:getState(),{})

for ak,al in{'MatchEndEvent','EntityDeathEvent','BedwarsBedBreak','BalloonPopped','AngelProgress','GrapplingHookFunctions'}do
if not u.Connections then return end
L.Client:WaitFor(al):andThen(function(am)
u:Clean(am:Connect(function(...)
c[al]:Fire(...)
end))
end)
end

u:Clean(L.ZapNetworking.EntityDamageEventZap.On(function(...)
c.EntityDamageEvent:Fire{
entityInstance=...,
damage=select(2,...),
damageType=select(3,...),
fromPosition=select(4,...),
fromEntity=select(5,...),
knockbackMultiplier=select(6,...),
knockbackId=select(7,...),
disableDamageHighlight=select(13,...)
}
end))

for ak,al in{'PlaceBlockEvent','BreakBlockEvent'}do
u:Clean(L.ZapNetworking[al..'Zap'].On(function(...)
local am={
blockRef={
blockPosition=...,
},
player=select(5,...)
}
for an,ao in ah do
if((am.blockRef.blockPosition*3)-ao[1]).Magnitude<=30 then
table.clear(ao[3])
table.clear(ao)
ah[an]=nil
end
end
c[al]:Fire(am)
end))
end

F.blocks=collection('block',gui)
F.shop=collection({'BedwarsItemShop','TeamUpgradeShopkeeper'},gui,function(ak,al)
table.insert(ak,{
Id=al.Name,
RootPart=al,
Shop=al:HasTag'BedwarsItemShop',
Upgrades=al:HasTag'TeamUpgradeShopkeeper'
})
end)
F.enchant=collection({'enchant-table','broken-enchant-table'},gui,nil,function(ak,al,am)
if al:HasTag'enchant-table'and am=='broken-enchant-table'then return end
al=table.find(ak,al)
if al then
table.remove(ak,al)
end
end)

local ak=C:AddItem'Kills'
local al=C:AddItem'Beds'
local am=C:AddItem'Wins'
local an=C:AddItem'Games'

local ao='Unknown'
C:AddItem('Map',0,function()
return ao
end,false)

task.delay(1,function()
an:Increment()
end)

task.spawn(function()
pcall(function()
repeat task.wait()until F.matchState~=0 or u.Loaded==nil
if u.Loaded==nil then return end
ao=workspace:WaitForChild('Map',5):WaitForChild('Worlds',5):GetChildren()[1].Name
ao=string.gsub(string.split(ao,'_')[2]or ao,'-','')or'Blank'
end)
end)

u:Clean(c.BedwarsBedBreak.Event:Connect(function(ap)
if ap.player and ap.player.UserId==s.UserId then
al:Increment()
end
end))

u:Clean(c.MatchEndEvent.Event:Connect(function(ap)
if(L.Store:getState().Game.myTeam or{}).id==ap.winningTeamId or s.Neutral then
am:Increment()
end
end))

u:Clean(c.EntityDeathEvent.Event:Connect(function(ap)
local aq=h:GetPlayerFromCharacter(ap.fromEntity)
local ar=h:GetPlayerFromCharacter(ap.entityInstance)
if not ar or not aq then return end

if ar~=s and aq==s then
ak:Increment()
end
end))

task.spawn(function()
repeat
if x.isAlive then
x.character.AirTime=x.character.Humanoid.FloorMaterial~=Enum.Material.Air and tick()or x.character.AirTime
end

for ap,aq in x.List do
aq.LandTick=math.abs(aq.RootPart.Velocity.Y)<0.1 and aq.LandTick or tick()
if(tick()-aq.LandTick)>0.2 and aq.Jumps~=0 then
aq.Jumps=0
aq.Jumping=false
end
end
task.wait()
until u.Loaded==nil
end)

pcall(function()
if getthreadidentity and setthreadidentity then
local ap=getthreadidentity()
setthreadidentity(2)

L.Shop=require(n.TS.games.bedwars.shop['bedwars-shop']).BedwarsShop
L.ShopItems=debug.getupvalue(debug.getupvalue(L.Shop.getShopItem,1),2)
L.Shop.getShopItem('iron_sword',s)

setthreadidentity(ap)
F.shopLoaded=true
else
task.spawn(function()
repeat
task.wait(0.1)
until u.Loaded==nil or L.AppController:isAppOpen'BedwarsItemShopApp'

L.Shop=require(n.TS.games.bedwars.shop['bedwars-shop']).BedwarsShop
L.ShopItems=debug.getupvalue(debug.getupvalue(L.Shop.getShopItem,1),2)
F.shopLoaded=true
end)
end
end)

u:Clean(function()
ae.Get=af
L.BlockController.isBlockBreakable=ag
F.blockPlacer:disable()
for ap,aq in c do
aq:Destroy()
end
for ap,aq in ah do
table.clear(aq[3])
table.clear(aq)
end
table.clear(F.blockPlacer)
table.clear(c)
table.clear(L)
table.clear(F)
table.clear(ah)
table.clear(N)
table.clear(M)
aj:disconnect()
aj=nil
end)
end,{
name="Internal | Bedwars"
})
if not L.Client then
error"Bedwars.Client missing!"
return
end

for aa,ab in{'AntiRagdoll','TriggerBot','SilentAim','AutoRejoin','Rejoin','Disabler','Timer','ServerHop','MouseTP','MurderMystery'}do
u:Remove(ab)
end
b(function()
local aa=game:GetService"Players"
function getColor3FromDecimal(ab)
if not ab then
return false
end
local ac=math.floor(ab/(65536))%256
local ad=math.floor(ab/256)%256
local ae=ab%256

return Color3.new(ac/255,ad/255,ae/255)
end
u:Clean(c.EntityDeathEvent.Event:Connect(function(ab)
local ac=h:GetPlayerFromCharacter(ab.fromEntity)
local ad=h:GetPlayerFromCharacter(ab.entityInstance)
if not ad or not ac then
return
end
shared.custom_notify("kill",ac,ad,ab.finalKill)
end))
u:Clean(c.BedwarsBedBreak.Event:Connect(function(ab)
if
not(
ab~=nil
and type(ab)=="table"
and ab.brokenBedTeam~=nil
and type(ab.brokenBedTeam)=="table"
and ab.brokenBedTeam.id~=nil
)
then
return
end
local ac=L.QueueMeta[F.queueType].teams[tonumber(ab.brokenBedTeam.id)]
local ad=aa:GetPlayerByUserId(tonumber(ab.player.UserId))or{Name="Unknown player"}
if not ad then
ad="Unknown player"
end
shared.custom_notify("bedbreak",ad,nil,nil,{
Name=ac and ac.displayName:upper()or"WHITE",
Color=ac and ac.colorHex and getColor3FromDecimal(tonumber(ac.colorHex))
or Color3.fromRGB(255,255,255),
})
end))
u:Clean(c.MatchEndEvent.Event:Connect(function(ab)
local ac=L.QueueMeta[F.queueType].teams[tonumber(ab.winningTeamId)]
if ab.winningTeamId==s:GetAttribute"Team"then
shared.custom_notify("win",nil,nil,false,{
Name=ac and ac.displayName:upper()or"WHITE",
Color=ac and ac.colorHex and getColor3FromDecimal(tonumber(ac.colorHex))
or Color3.fromRGB(255,255,255),
})
else
shared.custom_notify("defeat",nil,nil,false,{
Name=ac and ac.displayName:upper()or"WHITE",
Color=ac and ac.colorHex and getColor3FromDecimal(tonumber(ac.colorHex))
or Color3.fromRGB(255,255,255),
})
end
end))
end)

b(function()
local aa
local ab
local ac
local ad
local ae
local af
local ag
local ah
local ai
local aj
local ak

local function isFirstPerson()
if not(s.Character and s.Character:FindFirstChild"Head")then
return nil
end
return(s.Character.Head.Position-r.CFrame.Position).Magnitude<2
end

aa=u.Categories.Combat:CreateModule{
Name="AimAssist",
Function=function(al)
if al then
aa:Clean(e.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function(am)
if
x.isAlive
and F.hand.toolType=="sword"
and((not ai.Enabled)or(tick()-L.SwordController.lastSwing)<0.4)
then
local an=not ah.Enabled
and x.EntityPosition{
Range=ae.Value,
Part="RootPart",
Wallcheck=ab.Walls.Enabled,
Players=ab.Players.Enabled,
NPCs=ab.NPCs.Enabled,
Sort=V[ac.Value],
}
or F.KillauraTarget

if an then
local ao=(an.RootPart.Position-x.character.RootPart.Position)
local ap=x.character.RootPart.CFrame.LookVector*Vector3.new(1,0,1)
local aq=math.acos(ap:Dot((ao*Vector3.new(1,0,1)).Unit))
if ak.Enabled then
if not isFirstPerson()then
return
end
end
if aj.Enabled then
local ar=s:FindFirstChild"PlayerGui"
and s:FindFirstChild"PlayerGui":FindFirstChild"ItemShop"
or nil
if ar then
return
end
end
if an~=F.KillauraTarget and aq>=(math.rad(af.Value)/2)then
return
end
A.Targets[an]=tick()+1
r.CFrame=r.CFrame:Lerp(
CFrame.lookAt(r.CFrame.p,an.RootPart.Position),
(
ad.Value
+(
ag.Enabled
and(k:IsKeyDown(Enum.KeyCode.A)or k:IsKeyDown(
Enum.KeyCode.D
))
and 10
or 0
)
)*am
)
end
end
end)))
end
end,
Tooltip="Smoothly aims to closest valid target with sword",
}
ab=aa:CreateTargets{
Players=true,
Walls=true,
}
local al={"Damage","Distance"}
for am in V do
if not table.find(al,am)then
table.insert(al,am)
end
end
ac=aa:CreateDropdown{
Name="Target Mode",
List=al,
}
ad=aa:CreateSlider{
Name="Aim Speed",
Min=1,
Max=20,
Default=6,
}
ae=aa:CreateSlider{
Name="Distance",
Min=1,
Max=30,
Default=30,
Suffx=function(am)
return am==1 and"stud"or"studs"
end,
}
af=aa:CreateSlider{
Name="Max angle",
Min=1,
Max=360,
Default=70,
}
ai=aa:CreateToggle{
Name="Click Aim",
Default=true,
}
ah=aa:CreateToggle{
Name="Use killaura target",
}
aj=aa:CreateToggle{
Name="Shop Check",
Function=function()end,
Default=false,
}
ak=aa:CreateToggle{
Name="First Person Check",
Function=function()end,
Default=false,
}
ag=aa:CreateToggle{Name="Strafe increase"}
end)

b(function()
local aa
local ab
local ac={}
local ad

local function AutoClick()
if ad then
task.cancel(ad)
end

ad=task.delay(0.14285714285714285,function()
repeat
if not L.AppController:isLayerOpen(L.UILayers.MAIN)then
local ae=L.BlockPlacementController.blockPlacer
if F.hand.toolType=='block'and ae then
if(workspace:GetServerTimeNow()-L.BlockCpsController.lastPlaceTimestamp)>=(4.1666666666666664E-2)then
local af=ae.clientManager:getBlockSelector():getMouseInfo(0)
if af and af.placementPosition==af.placementPosition then
task.spawn(ae.placeBlock,ae,af.placementPosition)
end
end
elseif F.hand.toolType=='sword'then
L.SwordController:swingSwordAtMouse(0.39)
end
end

task.wait(1/(F.hand.toolType=='block'and ac or ab).GetRandomValue())
until not aa.Enabled
end)
end

aa=u.Categories.Combat:CreateModule{
Name='AutoClicker',
Function=function(ae)
if ae then
aa:Clean(k.InputBegan:Connect(function(af)
if af.UserInputType==Enum.UserInputType.MouseButton1 then
AutoClick()
end
end))

aa:Clean(k.InputEnded:Connect(function(af)
if af.UserInputType==Enum.UserInputType.MouseButton1 and ad then
task.cancel(ad)
ad=nil
end
end))

if k.TouchEnabled then
pcall(function()
aa:Clean(s.PlayerGui.MobileUI['2'].MouseButton1Down:Connect(AutoClick))
aa:Clean(s.PlayerGui.MobileUI['2'].MouseButton1Up:Connect(function()
if ad then
task.cancel(ad)
ad=nil
end
end))
end)
end
else
if ad then
task.cancel(ad)
ad=nil
end
end
end,
Tooltip='Hold attack button to automatically click'
}
ab=aa:CreateTwoSlider{
Name='CPS',
Min=1,
Max=9,
DefaultMin=7,
DefaultMax=7
}
aa:CreateToggle{
Name='Place Blocks',
Default=true,
Function=function(ae)
if ac.Object then
ac.Object.Visible=ae
end
end
}
ac=aa:CreateTwoSlider{
Name='Block CPS',
Min=1,
Max=12,
DefaultMin=12,
DefaultMax=12,
Darker=true
}
end)

b(function()
local aa

u.Categories.Combat:CreateModule{
Name='NoClickDelay',
Function=function(ab)
if ab then
aa=L.SwordController.isClickingTooFast
L.SwordController.isClickingTooFast=function(ac)
ac.lastSwing=os.clock()
return false
end
else
L.SwordController.isClickingTooFast=aa
end
end,
Tooltip='Remove the CPS cap'
}
end)

b(function()
local aa,ab,ac

local ad

G=u.Categories.Combat:CreateModule{
Name="Reach",
Tooltip="Extends reach for attacking, mining & placing",
Function=function(ae)
if ae then
oldAttackReach=L.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE

pcall(function()
local af=L.BlockBreakController:getBlockBreaker()
if af then
oldMineReach=af:getRange()
end
end)

ad=ad or L.BlockSelector.getMouseInfo

L.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE=aa.Value+2

L.BlockSelector.getMouseInfo=function(af,ag,ah)
ah=ah or{}
ah.range=ac.Value
return ad(af,ag,ah)
end

task.spawn(function()
repeat task.wait()until L.BlockBreakController or not G.Enabled
if not G.Enabled then return end

pcall(function()
local af=L.BlockBreakController:getBlockBreaker()
if af then
af:setRange(ab.Value)
end
end)
end)

task.spawn(function()
while G.Enabled do
if L.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE~=aa.Value+2 then
L.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE=aa.Value+2
end

pcall(function()
local af=L.BlockBreakController:getBlockBreaker()
if af and af:getRange()~=ab.Value then
af:setRange(ab.Value)
end
end)

task.wait(0.4)
end
end)

else
L.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE=oldAttackReach or 14.4

pcall(function()
local af=L.BlockBreakController:getBlockBreaker()
if af then
af:setRange(oldMineReach or 18)
end
end)

if ad then
L.BlockSelector.getMouseInfo=ad
end

oldAttackReach=nil
oldMineReach=nil
end
end
}

aa=G:CreateSlider{
Name="Attack Range",
Min=0,
Max=20,
Default=18,
Function=function(ae)
if G.Enabled then
L.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE=ae+2
end
end,
Suffix=function(ae)
return ae==1 and"stud"or"studs"
end
}

ac=G:CreateSlider{
Name="Place Range",
Min=0,
Max=40,
Default=18,
Function=function(ae)
if G.Enabled then
BlockSelector.getMouseInfo=function(af,ag,ah)
ah=ah or{}
ah.range=ae
return ad(af,ag,ah)
end
end
end,
Suffix=function(ae)
return ae==1 and"stud"or"studs"
end
}

ab=G:CreateSlider{
Name="Mine Range",
Min=0,
Max=30,
Default=18,
Function=function(ae)
if G.Enabled then
pcall(function()
local af=L.BlockBreakController:getBlockBreaker()
if af then
af:setRange(ae)
end
end)
end
end,
Suffix=function(ae)
return ae==1 and"stud"or"studs"
end
}
end)

b(function()
local aa
local ab

aa=u.Categories.Combat:CreateModule{
Name='Sprint',
Function=function(ac)
if ac then
if k.TouchEnabled then
pcall(function()
s.PlayerGui.MobileUI['4'].Visible=false
end)
end
ab=L.SprintController.stopSprinting
L.SprintController.stopSprinting=function(...)
local ad=ab(...)
L.SprintController:startSprinting()
return ad
end
aa:Clean(x.Events.LocalAdded:Connect(function()
task.delay(0.1,function()
L.SprintController:stopSprinting()
end)
end))
L.SprintController:stopSprinting()
else
if k.TouchEnabled then
pcall(function()
s.PlayerGui.MobileUI['4'].Visible=true
end)
end
L.SprintController.stopSprinting=ab
L.SprintController:stopSprinting()
end
end,
Tooltip='Sets your sprinting to true.'
}
end)

b(function()
local aa
local ab
local ac=RaycastParams.new()

aa=u.Categories.Combat:CreateModule{
Name='TriggerBot',
Function=function(ad)
if ad then
repeat
local ae
if not L.AppController:isLayerOpen(L.UILayers.MAIN)then
if x.isAlive and F.hand.toolType=='sword'and L.DaoController.chargingMaid==nil then
local af=L.ItemMeta[F.hand.tool.Name].sword.attackRange
ac.FilterDescendantsInstances={s.Character}

local ag=s:GetMouse().UnitRay
local ah=x.character.RootPart.Position
local ai=(af or 14.4)
local aj=L.QueryUtil:raycast(ag.Origin,ag.Direction*200,ac)
if aj and(ah-aj.Instance.Position).Magnitude<=ai then

for ak,al in x.List do
ae=al.Targetable and aj.Instance:IsDescendantOf(al.Character)and(ah-al.RootPart.Position).Magnitude<=ai
if ae then
break
end
end
end

ae=ae or L.SwordController:getTargetInRegion(af or 11.399999999999999,0)
if ae then
L.SwordController:swingSwordAtMouse()
end
end
end

task.wait(ae and 1/ab.GetRandomValue()or 0.016)
until not aa.Enabled
end
end,
Tooltip='Automatically swings when hovering over a entity'
}
ab=aa:CreateTwoSlider{
Name='CPS',
Min=1,
Max=9,
DefaultMin=7,
DefaultMax=7
}
end)

b(function()
local aa
local ab
local ac
local ad
local ae
local af,ag=Random.new()

aa=u.Categories.Combat:CreateModule{
Name='Velocity',
Function=function(ah)
if ah then
ag=L.KnockbackUtil.applyKnockback
L.KnockbackUtil.applyKnockback=function(ai,aj,ak,al,...)
if af:NextNumber(0,100)>ad.Value then return end
local am=(not ae.Enabled)or x.EntityPosition{
Range=50,
Part='RootPart',
Players=true
}

if am then
al=al or{}
if ab.Value==0 and ac.Value==0 then return end
al.horizontal=(al.horizontal or 1)*(ab.Value/100)
al.vertical=(al.vertical or 1)*(ac.Value/100)
end

return ag(ai,aj,ak,al,...)
end
else
L.KnockbackUtil.applyKnockback=ag
end
end,
Tooltip='Reduces knockback taken'
}
ab=aa:CreateSlider{
Name='Horizontal',
Min=0,
Max=100,
Default=0,
Suffix='%'
}
ac=aa:CreateSlider{
Name='Vertical',
Min=0,
Max=100,
Default=0,
Suffix='%'
}
ad=aa:CreateSlider{
Name='Chance',
Min=0,
Max=100,
Default=100,
Suffix='%'
}
ae=aa:CreateToggle{Name='Only when targeting'}
end)

F.RAYCAST_BLACKLISTED={
objs={},
add=function(aa,ab)
if not table.find(aa.objs,ab)and ab.Parent~=nil then
table.insert(aa.objs,ab)
ab.Destroying:Once(function()
aa:remove(ab)
end)
end
end,
remove=function(aa,ab)
local ac=table.find(aa.objs,ab)
if ac then
table.remove(aa.objs,ac)
end
end,
}









local function blocksRaycast(aa)
local ab=s.Character
if not s.Character then
return false
end
local ac=ab.PrimaryPart
if ac~=nil then
ac=ac.Position
end
if not ac then
return false
end
local ad=RaycastParams.new()
ad.CollisionGroup="Blocks"
ad.FilterType=Enum.RaycastFilterType.Exclude
ad.IgnoreWater=true
local ae=0
local af={r,workspace:FindFirstChild"Terrain"}
ae=#af
for ag,ah in Players:GetPlayers()do
local ai=ah.Character
if ai~=nil then
ae=ae+1
af[ae]=ai
end
end
for ag,ah in(F.RAYCAST_BLACKLISTED.objs or{})do
ae=ae+1
af[ae]=ah
end
ad.FilterDescendantsInstances=af
if not aa or type(aa)=="number"then
local ag=aa or 400
ag=-ag
aa=Vector3.new(0,ag,0)
end
return workspace:Raycast(ac,aa,ad)
end
global().blocksRaycast=blocksRaycast

local aa
b(function()
local ab
local ac
local ad
local ae
local af=RaycastParams.new()
af.RespectCanCollide=true

local function getLowGround()
local ag=math.huge
for ah,ai in L.BlockController:getStore():getAllBlockPositions()do
ai=ai*3
if ai.Y<ag and not getPlacedBlock(ai+Vector3.new(0,3,0))then
ag=ai.Y
end
end
return ag
end

ab=u.Categories.Blatant:CreateModule{
Name='AntiFall',
Function=function(ag)
if ag then
repeat task.wait()until F.matchState~=0 or(not ab.Enabled)
if not ab.Enabled then return end

local ah,ai=getLowGround(),tick()
if ah~=math.huge then
K=Instance.new'Part'
K.Size=Vector3.new(10000,1,10000)
K.Transparency=1-ae.Opacity
K.Material=Enum.Material[ad.Value]
K.Color=Color3.fromHSV(ae.Hue,ae.Sat,ae.Value)
K.Position=Vector3.new(0,ah-2,0)
K.CanCollide=ac.Value=='Collide'
K.Anchored=true
K.CanQuery=false
K.Parent=workspace
F.RAYCAST_BLACKLISTED:add(K)
ab:Clean(K)
ab:Clean(K.Touched:Connect(function(aj)
if aj.Parent==s.Character and x.isAlive and ai<tick()then
ai=tick()+0.1
if ac.Value=='Normal'then
local ak=getNearGround()
if ak then
local al=s:GetAttribute'LastTeleported'
local am
am=e.PreSimulation:Connect(LPH_NO_VIRTUALIZE(function()
if u.Modules.Fly.Enabled or u.Modules.InfiniteFly.Enabled or u.Modules.LongJump.Enabled then
am:Disconnect()
aa=nil
return
end

if x.isAlive and s:GetAttribute'LastTeleported'==al then
local an=((ak-x.character.RootPart.Position)*Vector3.new(1,0,1))
local ao=x.character.RootPart
aa=an.Unit==an.Unit and an.Unit or Vector3.zero
ao.Velocity*=Vector3.new(1,0,1)
af.FilterDescendantsInstances={r,s.Character}
af.CollisionGroup=ao.CollisionGroup

local ap=blocksRaycast(aa)

if ap then
for aq=1,10 do
local ar=roundPos(ap.Position+ap.Normal*1.5)+Vector3.new(0,3,0)
if not getPlacedBlock(ar)then
ak=Vector3.new(ak.X,ah.Y,ak.Z)
break
end
end
end

ao.CFrame+=Vector3.new(0,ak.Y-ao.Position.Y,0)
if not Q.Speed then
ao.AssemblyLinearVelocity=(aa*getSpeed())+Vector3.new(0,ao.AssemblyLinearVelocity.Y,0)
end

if an.Magnitude<1 then
am:Disconnect()
aa=nil
end
else
am:Disconnect()
aa=nil
end
end))
ab:Clean(am)
end
elseif ac.Value=='Velocity'then
x.character.RootPart.Velocity=Vector3.new(x.character.RootPart.Velocity.X,100,x.character.RootPart.Velocity.Z)
end
end
end))
end
else
aa=nil
end
end,
Tooltip='Help\'s you with your Parkinson\'s\nPrevents you from falling into the void.'
}
ac=ab:CreateDropdown{
Name='Move Mode',
List={'Normal','Collide','Velocity'},
Function=function(ag)
if K then
K.CanCollide=ag=='Collide'
end
end,
Tooltip='Normal - Smoothly moves you towards the nearest safe point\nVelocity - Launches you upward after touching\nCollide - Allows you to walk on the part'
}
local ag={'ForceField'}
for ah,ai in Enum.Material:GetEnumItems()do
if ai.Name~='ForceField'then
table.insert(ag,ai.Name)
end
end
ad=ab:CreateDropdown{
Name='Material',
List=ag,
Function=function(ah)
if K then
K.Material=Enum.Material[ah]
end
end
}
ae=ab:CreateColorSlider{
Name='Color',
DefaultOpacity=0.5,
Function=function(ah,ai,aj,ak)
if K then
K.Color=Color3.fromHSV(ah,ai,aj)
K.Transparency=1-ak
end
end
}
end)

b(function()
local ab
local ac

ab=u.Categories.Blatant:CreateModule{
Name='FastBreak',
Function=function(ad)
if ad then
repeat
L.BlockBreakController.blockBreaker:setCooldown(ac.Value)
task.wait(0.1)
until not ab.Enabled
else
L.BlockBreakController.blockBreaker:setCooldown(0.3)
end
end,
Tooltip='Decreases block hit cooldown'
}
ac=ab:CreateSlider{
Name='Break speed',
Min=0,
Max=0.3,
Default=0.25,
Decimal=100,
Suffix='seconds'
}
end)

local ab
local ac
b(function()
local ad
local ae
local af
local ag
local ah
local ai

local aj
local ak=RaycastParams.new()
ak.RespectCanCollide=true
local al,am,an=0,0

local ao={}

local function createMobileButton(ap,aq,ar)
local as=Instance.new"TextButton"

as.Name=ap
as.Size=UDim2.new(0,60,0,60)
as.Position=aq
as.BackgroundColor3=Color3.fromRGB(30,30,30)
as.BackgroundTransparency=0.3
as.BorderSizePixel=0
as.Text=ar
as.TextColor3=Color3.fromRGB(255,255,255)
as.TextScaled=true
as.FontFace=Font.new("SourceSansPro",Enum.FontWeight.Bold)
as.AutoButtonColor=false

local at=Instance.new"UICorner"
at.CornerRadius=UDim.new(0,12)
at.Parent=as

return as
end

local function cleanupMobileControls()
for ap,aq in pairs(ao)do
if aq and aq.Parent then
aq:Destroy()
end
end
ao={}
end

local function setupMobileControls()
cleanupMobileControls()

local ap=u.gui

local aq=createMobileButton("UpButton",UDim2.new(0.9,-70,0.5,-100),"↑")

local ar=createMobileButton("DownButton",UDim2.new(0.9,-70,0.5,-20),"↓")

ao.UpButton=aq
ao.DownButton=ar

aq.Parent=ap
ar.Parent=ap

return aq,ar
end

local function cleanProgressBar()
if aj~=nil and aj.Parent~=nil then
aj:Destroy()
end
aj=nil
end

local function createProgressBar()
pcall(cleanProgressBar)
aj=Instance.new"Frame"
aj.AnchorPoint=Vector2.new(0.5,0)
aj.Position=UDim2.new(0.5,0,1,-200)
aj.Size=UDim2.new(0.2,0,0,20)
aj.BackgroundTransparency=0.5
aj.BorderSizePixel=0
aj.BackgroundColor3=Color3.new(0,0,0)
aj.Visible=ab.Enabled
aj.Parent=u.gui
local ap=aj:Clone()
ap.AnchorPoint=Vector2.new(0,0)
ap.Position=UDim2.new(0,0,0,0)
ap.Size=UDim2.new(1,0,0,20)
ap.BackgroundTransparency=0
ap.Visible=true
ap.Parent=aj
local aq=Instance.new"TextLabel"
aq.Text="2s"
aq.Font=Enum.Font.Gotham
aq.TextStrokeTransparency=0
aq.TextColor3=Color3.new(0.9,0.9,0.9)
aq.TextSize=20
aq.Size=UDim2.new(1,0,1,0)
aq.BackgroundTransparency=1
aq.Position=UDim2.new(0,0,-1,0)
aq.Parent=aj
return u.connectguicolorchange(function(ar,as,at)
if aj~=nil and aj.Parent~=nil then
aj.BackgroundColor3=Color3.fromHSV(ar,as,at)
if ap~=nil and ap.Parent~=nil then
ap.BackgroundColor3=Color3.fromHSV(ar,as,at)
end
end
end)
end

ab=u.Categories.Blatant:CreateModule{
Name="Fly",
Function=function(ap)
Q.Fly=ap or nil
updateVelocity()
if ap then
al,am,an=0,0,L.BalloonController.deflateBalloon
L.BalloonController.deflateBalloon=function()end
local aq,ar,as=tick(),true

if
s.Character
and(s.Character:GetAttribute"InflatedBalloons"or 0)==0
and getItem"balloon"
then
L.BalloonController:inflateBalloon()
end

if ai.Enabled then
local at,au=pcall(createProgressBar)
if at and au~=nil then
ab:Clean(createProgressBar)
else
errorNotification("Fly",`Couldn't create Progress Bar -> {tostring(au)}`,5)
warn(`[Fly - ProgressBar]: {tostring(au)}`)
end
end

ab:Clean(k.InputBegan:Connect(function(at)
if k:GetFocusedTextBox()==nil then
if at.KeyCode==Enum.KeyCode.Space or at.KeyCode==Enum.KeyCode.ButtonA then
al=1
end
if at.KeyCode==Enum.KeyCode.LeftShift or at.KeyCode==Enum.KeyCode.ButtonL2 then
am=-1
end
end
end))
ab:Clean(k.InputEnded:Connect(function(at)
if at.KeyCode==Enum.KeyCode.Space or at.KeyCode==Enum.KeyCode.ButtonA then
al=0
end
if at.KeyCode==Enum.KeyCode.LeftShift or at.KeyCode==Enum.KeyCode.ButtonL2 then
am=0
end
end))

local at=k.TouchEnabled
and not k.KeyboardEnabled
and not k.MouseEnabled
if FlyMobileButtons.Enabled or at then
local au,av=setupMobileControls()

ab:Clean(au.MouseButton1Down:Connect(function()
al=1
end))
ab:Clean(au.MouseButton1Up:Connect(function()
al=0
end))
ab:Clean(av.MouseButton1Down:Connect(function()
am=-1
end))
ab:Clean(av.MouseButton1Up:Connect(function()
am=0
end))
end

ab:Clean(c.AttributeChanged.Event:Connect(function(au)
if
au=="InflatedBalloons"
and(s.Character:GetAttribute"InflatedBalloons"or 0)==0
and getItem"balloon"
then
L.BalloonController:inflateBalloon()
end
end))
ab:Clean(e.PreSimulation:Connect(LPH_NO_VIRTUALIZE(function(au)
if
x.isAlive
and not I.Enabled
and q(x.character.RootPart)
then
local av=(
s.Character:GetAttribute"InflatedBalloons"
and s.Character:GetAttribute"InflatedBalloons">0
)or F.matchState==2
local aw=(1.5+(av and 6 or 0)*(tick()%0.4<0.2 and-1 or 1))
+((al+am)*ae.Value)
local ax,ay=
x.character.RootPart,x.character.Humanoid.MoveDirection
local az=getSpeed()
local aA=(ay*math.max(ad.Value-az,0)*au)
ak.FilterDescendantsInstances={s.Character,r,K}
ak.CollisionGroup=ax.CollisionGroup

if ai.Enabled and aj~=nil and aj.Parent~=nil then
aj.Visible=ab.Enabled and not av
end

if af.Enabled then
local aB=blocksRaycast(aA)

if aB then
aA=((aB.Position+aB.Normal)-ax.Position)
end
end

if not av then
if ar then
local aB=(tick()-x.character.AirTime)
if
ai.Enabled
and aj~=nil
and aj.Parent~=nil
then
if aj:FindFirstChild"Frame"then
if aB<0.1 then
aj.Frame:TweenSize(
UDim2.new(1,0,0,20),
Enum.EasingDirection.InOut,
Enum.EasingStyle.Linear,
0,
true
)
else
aj.Frame:TweenSize(
UDim2.new(0,0,0,20),
Enum.EasingDirection.InOut,
Enum.EasingStyle.Linear,
(2.5-aB),
true
)
end
end
if aj:FindFirstChild"TextLabel"and aB~=nil then
aj.TextLabel.Text=math.max(
aB<0.1 and 2.5 or math.floor((2.5-aB)*10)/10,
0
).."s"
end
end
if aB>2 then
if not as then
local aC=blocksRaycast(1000)

if not aC then
aj.Frame:TweenSize(
UDim2.new(0,0,0,20),
Enum.EasingDirection.InOut,
Enum.EasingStyle.Linear,
0,
true
)
end
if aC and ah.Enabled then
ar=false
as=ax.Position.Y
aq=tick()+0.11
ax.CFrame=CFrame.lookAlong(
Vector3.new(
ax.Position.X,
aC.Position.Y+x.character.HipHeight,
ax.Position.Z
),
ax.CFrame.LookVector
)
end
end
end
else
if as then
if aq<tick()then
local aB=Vector3.new(ax.Position.X,as,ax.Position.Z)
ax.CFrame=CFrame.lookAlong(aB,ax.CFrame.LookVector)
ar=true
as=nil
else
aw=0
end
end
end
end

ax.CFrame+=aA
ax.AssemblyLinearVelocity=(ay*az)+Vector3.new(0,aw,0)
end
end)))
ab:Clean(k.InputBegan:Connect(function(au)
if not k:GetFocusedTextBox()then
if au.KeyCode==Enum.KeyCode.Space or au.KeyCode==Enum.KeyCode.ButtonA then
al=1
elseif au.KeyCode==Enum.KeyCode.LeftShift or au.KeyCode==Enum.KeyCode.ButtonL2 then
am=-1
end
end
end))
ab:Clean(k.InputEnded:Connect(function(au)
if au.KeyCode==Enum.KeyCode.Space or au.KeyCode==Enum.KeyCode.ButtonA then
al=0
elseif au.KeyCode==Enum.KeyCode.LeftShift or au.KeyCode==Enum.KeyCode.ButtonL2 then
am=0
end
end))
if k.TouchEnabled then
pcall(function()
local au=s.PlayerGui.TouchGui.TouchControlFrame.JumpButton
ab:Clean(au:GetPropertyChangedSignal"ImageRectOffset":Connect(function()
al=au.ImageRectOffset.X==146 and 1 or 0
end))
end)
end
else
L.BalloonController.deflateBalloon=an
if
ag.Enabled
and x.isAlive
and(s.Character:GetAttribute"InflatedBalloons"or 0)>0
then
for aq=1,3 do
L.BalloonController:deflateBalloon()
end
end
pcall(cleanProgressBar)
pcall(cleanupMobileControls)
end
end,
ExtraText=function()
return"Heatseeker"
end,
Tooltip="Makes you go zoom.",
}

ad=ab:CreateSlider{
Name="Speed",
Min=1,
Max=23,
Default=23,
Suffix=function(ap)
return ap==1 and"stud"or"studs"
end,
}
ae=ab:CreateSlider{
Name="Vertical Speed",
Min=1,
Max=150,
Default=50,
Suffix=function(ap)
return ap==1 and"stud"or"studs"
end,
}
af=ab:CreateToggle{
Name="Wall Check",
Default=true,
}
FlyMobileButtons=ab:CreateToggle{
Name="Mobile Buttons",
Default=m.TouchEnabled and not m.KeyboardEnabled,
Function=function()
if ab.Enabled then
ab:Toggle()
task.wait(0.1)
ab:Toggle()
end
end,
}
ag=ab:CreateToggle{
Name="Pop Balloons",
Default=true,
}
ah=ab:CreateToggle{
Name="TP Down",
Default=true,
}
ai=ab:CreateToggle{
Name="Progress Bar",
Default=true,
Function=function(ap)
if not ap then
pcall(cleanProgressBar)
end
if ab.Enabled then
ab:Toggle()
task.wait(0.1)
ab:Toggle()
end
end,
}
end)

b(function()
local ad
local ae
local af,ag={}

local function createHitbox(ah)
if ah.Targetable and ah.Player then
local ai=Instance.new'Part'
ai.Size=Vector3.new(3,6,3)+Vector3.one*(ae.Value/5)
ai.Position=ah.RootPart.Position
ai.CanCollide=false
ai.Massless=true
ai.Transparency=1
ai.Parent=ah.Character
local aj=Instance.new'Motor6D'
aj.Part0=ai
aj.Part1=ah.RootPart
aj.Parent=ai
af[ah]=ai
end
end

H=u.Categories.Blatant:CreateModule{
Name='HitBoxes',
Function=function(ah)
if ah then
if ad.Value=='Sword'then
debug.setconstant(L.SwordController.swingSwordInRegion,6,(ae.Value/3))
ag=true
else
H:Clean(x.Events.EntityAdded:Connect(createHitbox))
H:Clean(x.Events.EntityRemoving:Connect(function(ai)
if af[ai]then
af[ai]:Destroy()
af[ai]=nil
end
end))
for ai,aj in x.List do
createHitbox(aj)
end
end
else
if ag then
debug.setconstant(L.SwordController.swingSwordInRegion,6,3.8)
ag=nil
end
for ai,aj in af do
aj:Destroy()
end
table.clear(af)
end
end,
Tooltip='Expands attack hitbox'
}
ad=H:CreateDropdown{
Name='Mode',
List={'Sword','Player'},
Function=function()
if H.Enabled then
H:Toggle()
H:Toggle()
end
end,
Tooltip='Sword - Increases the range around you to hit entities\nPlayer - Increases the players hitbox'
}
ae=H:CreateSlider{
Name='Expand amount',
Min=0,
Max=14.4,
Default=14.4,
Decimal=10,
Function=function(ah)
if H.Enabled then
if ad.Value=='Sword'then
debug.setconstant(L.SwordController.swingSwordInRegion,6,(ah/3))
else
for ai,aj in af do
aj.Size=Vector3.new(3,6,3)+Vector3.one*(ah/5)
end
end
end
end,
Suffix=function(ah)
return ah==1 and'stud'or'studs'
end
}
end)

b(function()
u.Categories.Blatant:CreateModule{
Name='KeepSprint',
Function=function(ad)
debug.setconstant(L.SprintController.startSprinting,5,ad and'blockSprinting'or'blockSprint')
L.SprintController:stopSprinting()
end,
Tooltip='Lets you sprint with a speed potion.'
}
end)

local ad
local ae
b(function()
local af
local ag
local ah
local ai
local aj

local ak
local al
local am
local an
local ao
local ap
local aq
local ar
local as
local at
local au
local av
local aw
local ax
local ay
local az
local aA
local aB
local aC
local aD
local aE
local aF={}
local aG,aH={},{}
local aI,aJ,aK,aL=u.Libraries.auraanims,tick()
local aM={FireServer=function()end}
task.spawn(function()
aM=L.Client:Get(M.AttackEntity).instance
end)

local function createRangeCircle()
local aN,aO=pcall(function()
if not shared.CheatEngineMode then
ax=Instance.new"MeshPart"
ax.MeshId="rbxassetid://3726303797"
u.connectguicolorchange(function(aN,aO,aP)
ax.Color=Color3.fromHSV(aN,aO,aP)
end)
ax.CanCollide=false
ax.Anchored=true
ax.Material=Enum.Material.Neon
ax.Size=Vector3.new(aj.Value*0.7,0.01,aj.Value*0.7)
if af.Enabled then
ax.Parent=r
end
ax:SetAttribute("gamecore_GameQueryIgnore",true)
end
end)
if not aN then
pcall(function()
if ax then
ax:Destroy()
ax=nil
end
InfoNotification(
"Killaura - Range Visualiser Circle",
"There was an error creating the circle. Disabling...",
2
)
warn(aO)
end)
end
end

local function getAttackData()
if an.Enabled then
if not k:IsMouseButtonPressed(0)then return false end
end

if ap.Enabled then
if L.AppController:isLayerOpen(L.UILayers.MAIN)then return false end
end

local aN=aD.Enabled and F.hand or F.tools.sword
if not aN or not aN.tool then return false end

local aO=L.ItemMeta[aN.tool.Name]
if aD.Enabled then
if F.hand.toolType~='sword'or L.DaoController.chargingMaid then return false end
end

if aF.Enabled then
if(tick()-L.SwordController.lastSwing)>0.2 then return false end
end

return aN,aO
end

af=u.Categories.Blatant:CreateModule{
Name='Killaura',
Function=function(aN)
if aN then
if aw.Enabled then
createRangeCircle()
end
if k.TouchEnabled then
pcall(function()
s.PlayerGui.MobileUI['2'].Visible=aD.Enabled
end)
end

if az.Enabled and not(identifyexecutor and table.find({'Argon','Delta'},({identifyexecutor()})[1]))then
local aO={
Controllers={
ViewmodelController={
isVisible=function()
return not ad
end,
playAnimation=function(...)
if not ad then
L.ViewmodelController:playAnimation(select(2,...))
end
end
}
}
}
debug.setupvalue(P or L.SwordController.playSwordEffect,6,aO)
debug.setupvalue(L.ScytheController.playLocalAnimation,3,aO)

task.spawn(function()
local aP=false
repeat
if ad then
if not aL then
aL=r.Viewmodel.RightHand.RightWrist.C0
end
local aQ=not aP
aP=true

if aA.Value=='Random'then
aI.Random={{CFrame=CFrame.Angles(math.rad(math.random(1,360)),math.rad(math.random(1,360)),math.rad(math.random(1,360))),Time=0.12}}
end

for aR,aS in aI[aA.Value]do
aK=j:Create(r.Viewmodel.RightHand.RightWrist,TweenInfo.new(aQ and(aC.Enabled and 0.001 or 0.1)or aS.Time/aB.Value,Enum.EasingStyle.Linear),{
C0=aL*aS.CFrame
})
aK:Play()
aK.Completed:Wait()
aQ=false
if(not af.Enabled)or(not ad)then break end
end
elseif aP then
aP=false
aK=j:Create(r.Viewmodel.RightHand.RightWrist,TweenInfo.new(aC.Enabled and 0.001 or 0.3,Enum.EasingStyle.Exponential),{
C0=aL
})
aK:Play()
end

if not aP then
task.wait(1/ak.Value)
end
until(not af.Enabled)or(not az.Enabled)
end)
end
local aO=0
local aP=0
local aQ=a:wrap(function()
pcall(function()
if ax~=nil and ax.Parent~=nil and x.isAlive and x.character.HumanoidRootPart then
j:Create(
ax,
TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),
{
Position=x.character.HumanoidRootPart.Position
-Vector3.new(0,x.character.Humanoid.HipHeight,0),
Size=Vector3.new(aj.Value*0.7,0.01,aj.Value*0.7)
}
):Play()
end
end)
local aQ,aR,aS={},getAttackData()
ad=false
F.KillauraTarget=nil
if aR then
local aT=x.AllPosition{
Range=ai.Value,
Wallcheck=ag.Walls.Enabled or nil,
Part="RootPart",
Players=ag.Players.Enabled,
NPCs=ag.NPCs.Enabled,
Limit=am.Value,
Sort=V[ah.Value],
}

if#aT>0 then
switchItem(aR.tool,0)
local aU=x.character.RootPart.Position
local aV=x.character.RootPart.CFrame.LookVector*Vector3.new(1,0,1)

for aW,aX in aT do
local aY=(aX.RootPart.Position-aU)
local aZ=math.acos(aV:Dot((aY*Vector3.new(1,0,1)).Unit))
if aZ>(math.rad(al.Value)/2)then
continue
end

table.insert(aQ,{
Entity=aX,
Check=aY.Magnitude>aj.Value and aq or ar,
})
A.Targets[aX]=tick()+1

if not ad then
ad=true
F.KillauraTarget=aX
if not ao.Enabled and aJ<tick()and not aF.Enabled then
aJ=tick()
+(aS.sword.respectAttackSpeedForEffects and aS.sword.attackSpeed or 0)
L.SwordController:playSwordEffect(aS,false)
if aS.displayName:find" Scythe"then
L.ScytheController:playLocalAnimation()
end

if u.ThreadFix then
setthreadidentity(8)
end
end
end

if aY.Magnitude>aj.Value then
continue
end

local a_=aX.Character.PrimaryPart
if a_ then
local a0=CFrame.lookAt(aU,a_.Position).LookVector
local a1=aU+a0*math.max(aY.Magnitude-14.399,0)
aO=tick()
L.SwordController.lastAttack=workspace:GetServerTimeNow()
F.attackReach=(aY.Magnitude*100)//1/100
F.attackReachUpdate=tick()+1

if aY.Magnitude<14.4 then
aJ=tick()
end
if tick()>aO then
aO=tick()+(ae.Enabled and 0.22 or 0.1)
aM:FireServer{
weapon=aR.tool,
chargedAttack={chargeRatio=0},
entityInstance=aX.Character,
validate={
raycast={
cameraPosition={value=a1+Vector3.new(0,5,0)},
cursorDirection={value=a0},
},
targetPosition={value=a_.Position},
selfPosition={value=a1},
},
}
aP+=1
end
local a2=getgenv().projectileCount or{}
if#a2>0 then do

aP=0
if ae.Enabled and aE.Enabled then
getgenv().projectileTick=tick()+0.2
task.wait(0.02)
break
end end

end
end
end
end
end

for aT,aU in aH do
aU.Adornee=aQ[aT]and aQ[aT].Entity.RootPart or nil
if aU.Adornee then
aU.Color3=Color3.fromHSV(aQ[aT].Check.Hue,aQ[aT].Check.Sat,aQ[aT].Check.Value)
aU.Transparency=1-aQ[aT].Check.Opacity
end
end

for aT,aU in aG do
aU.Position=aQ[aT]and aQ[aT].Entity.RootPart.Position or Vector3.new(9e9,9e9,9e9)
aU.Parent=aQ[aT]and r or nil
end


if ay.Enabled and aQ[1]then
local aT=aQ[1].Entity.RootPart.Position*Vector3.new(1,0,1)
x.character.RootPart.CFrame=CFrame.lookAt(
x.character.RootPart.Position,
Vector3.new(aT.X,x.character.RootPart.Position.Y+0.001,aT.Z)
)
end
end,{
name="KillauraFunction"
})
repeat
aQ()

task.wait(1/ak.Value)
until not af.Enabled
else
F.KillauraTarget=nil
for aO,aP in aH do
aP.Adornee=nil
end
for aO,aP in aG do
aP.Parent=nil
end
if k.TouchEnabled then
pcall(function()
s.PlayerGui.MobileUI['2'].Visible=true
end)
end
if ax then
pcall(function()
ax:Destroy()
end)
ax=nil
end
debug.setupvalue(P or L.SwordController.playSwordEffect,6,L.Knit)
debug.setupvalue(L.ScytheController.playLocalAnimation,3,L.Knit)
ad=false
if aL then
aK=j:Create(r.Viewmodel.RightHand.RightWrist,TweenInfo.new(aC.Enabled and 0.001 or 0.3,Enum.EasingStyle.Exponential),{
C0=aL
})
aK:Play()
end
end
end,
Tooltip='Attack players around you\nwithout aiming at them.'
}
ag=af:CreateTargets{
Players=true,
NPCs=true
}
local aN={'Damage','Distance'}
for aO in V do
if not table.find(aN,aO)then
table.insert(aN,aO)
end
end
ai=af:CreateSlider{
Name='Swing range',
Min=1,
Max=21,
Default=21,
Suffix=function(aO)
return aO==1 and'stud'or'studs'
end
}
aj=af:CreateSlider{
Name='Attack range',
Min=1,
Max=21,
Default=21,
Suffix=function(aO)
return aO==1 and'stud'or'studs'
end
}
aw=af:CreateToggle{
Name="Range Visualiser",
Function=function(aO)
if aO then
createRangeCircle()
else
if ax then
ax:Destroy()
ax=nil
end
end
end,
}
al=af:CreateSlider{
Name='Max angle',
Min=1,
Max=360,
Default=360
}
ak=af:CreateSlider{
Name='Update rate',
Min=1,
Max=240,
Default=60,
Suffix='hz'
}
am=af:CreateSlider{
Name='Max targets',
Min=1,
Max=5,
Default=5
}
ah=af:CreateDropdown{
Name='Target Mode',
List=aN
}
an=af:CreateToggle{Name='Require mouse down'}
ao=af:CreateToggle{Name='No Swing'}
ap=af:CreateToggle{Name='GUI check'}
af:CreateToggle{
Name='Show target',
Function=function(aO)
aq.Object.Visible=aO
ar.Object.Visible=aO
if aO then
for aP=1,10 do
local aQ=Instance.new'BoxHandleAdornment'
aQ.Adornee=nil
aQ.AlwaysOnTop=true
aQ.Size=Vector3.new(3,5,3)
aQ.CFrame=CFrame.new(0,-0.5,0)
aQ.ZIndex=0
aQ.Parent=u.gui
aH[aP]=aQ
end
else
for aP,aQ in aH do
aQ:Destroy()
end
table.clear(aH)
end
end
}
aq=af:CreateColorSlider{
Name='Target Color',
Darker=true,
DefaultHue=0.6,
DefaultOpacity=0.5,
Visible=false
}
ar=af:CreateColorSlider{
Name='Attack Color',
Darker=true,
DefaultOpacity=0.5,
Visible=false
}
af:CreateToggle{
Name='Target particles',
Function=function(aO)
as.Object.Visible=aO
at.Object.Visible=aO
au.Object.Visible=aO
av.Object.Visible=aO
if aO then
for aP=1,10 do
local aQ=Instance.new'Part'
aQ.Size=Vector3.new(2,4,2)
aQ.Anchored=true
aQ.CanCollide=false
aQ.Transparency=1
aQ.CanQuery=false
aQ.Parent=af.Enabled and r or nil
local aR=Instance.new'ParticleEmitter'
aR.Brightness=1.5
aR.Size=NumberSequence.new(av.Value)
aR.Shape=Enum.ParticleEmitterShape.Sphere
aR.Texture=as.Value
aR.Transparency=NumberSequence.new(0)
aR.Lifetime=NumberRange.new(0.4)
aR.Speed=NumberRange.new(16)
aR.Rate=128
aR.Drag=16
aR.ShapePartial=1
aR.Color=ColorSequence.new{
ColorSequenceKeypoint.new(0,Color3.fromHSV(at.Hue,at.Sat,at.Value)),
ColorSequenceKeypoint.new(1,Color3.fromHSV(au.Hue,au.Sat,au.Value))
}
aR.Parent=aQ
aG[aP]=aQ
end
else
for aP,aQ in aG do
aQ:Destroy()
end
table.clear(aG)
end
end
}
as=af:CreateTextBox{
Name='Texture',
Default='rbxassetid://14736249347',
Function=function()
for aO,aP in aG do
aP.ParticleEmitter.Texture=as.Value
end
end,
Darker=true,
Visible=false
}
at=af:CreateColorSlider{
Name='Color Begin',
Function=function(aO,aP,aQ)
for aR,aS in aG do
aS.ParticleEmitter.Color=ColorSequence.new{
ColorSequenceKeypoint.new(0,Color3.fromHSV(aO,aP,aQ)),
ColorSequenceKeypoint.new(1,Color3.fromHSV(au.Hue,au.Sat,au.Value))
}
end
end,
Darker=true,
Visible=false
}
au=af:CreateColorSlider{
Name='Color End',
Function=function(aO,aP,aQ)
for aR,aS in aG do
aS.ParticleEmitter.Color=ColorSequence.new{
ColorSequenceKeypoint.new(0,Color3.fromHSV(at.Hue,at.Sat,at.Value)),
ColorSequenceKeypoint.new(1,Color3.fromHSV(aO,aP,aQ))
}
end
end,
Darker=true,
Visible=false
}
av=af:CreateSlider{
Name='Size',
Min=0,
Max=1,
Default=0.2,
Decimal=100,
Function=function(aO)
for aP,aQ in aG do
aQ.ParticleEmitter.Size=NumberSequence.new(aO)
end
end,
Darker=true,
Visible=false
}
ay=af:CreateToggle{Name='Face target'}
az=af:CreateToggle{
Name='Custom Animation',
Function=function(aO)
aA.Object.Visible=aO
aC.Object.Visible=aO
aB.Object.Visible=aO
if af.Enabled then
af:Toggle()
af:Toggle()
end
end
}
local aO={}
for aP in aI do
table.insert(aO,aP)
end
aA=af:CreateDropdown{
Name='Animation Mode',
List=aO,
Darker=true,
Visible=false
}
aB=af:CreateSlider{
Name='Animation Speed',
Min=0,
Max=2,
Default=1,
Decimal=10,
Darker=true,
Visible=false
}
aC=af:CreateToggle{
Name='No Tween',
Darker=true,
Visible=false
}
aD=af:CreateToggle{
Name='Limit to items',
Function=function(aP)
if k.TouchEnabled and af.Enabled then
pcall(function()
s.PlayerGui.MobileUI['2'].Visible=aP
end)
end
end,
Tooltip='Only attacks when the sword is held'
}
aF=af:CreateToggle{
Name='Swing only',
Tooltip='Only attacks while swinging manually'
}
end)

b(function()
local af
local ag
local ah
local ai,aj,ak=tick(),0
local al={InvokeServer=function()end}
task.spawn(function()
al=L.Client:Get(M.FireProjectile).instance
end)

local function launchProjectile(am,an,ao,ap,aq)
if not an then return end

an=an-aq*0.1
local ar=(CFrame.lookAlong(an,Vector3.new(0,-ap,0))*CFrame.new(Vector3.new(-L.BowConstantsTable.RelX,-L.BowConstantsTable.RelY,-L.BowConstantsTable.RelZ)))
switchItem(am.tool,0)
L.ProjectileController:createLocalProjectile(L.ProjectileMeta[ao],ao,ao,ar.Position,'',ar.LookVector*ap,{drawDurationSeconds=1})
if al:InvokeServer(am.tool,ao,ao,ar.Position,an,ar.LookVector*ap,i:GenerateGUID(true),{drawDurationSeconds=1},workspace:GetServerTimeNow()-0.045)then
local as=L.ItemMeta[am.itemType].projectileSource.launchSound
as=as and as[math.random(1,#as)]or nil
if as then
L.SoundManager:playSound(as)
end
end
end

local an={
cannon=function(am,an,ao)
an=an-Vector3.new(0,(x.character.HipHeight+(x.character.RootPart.Size.Y/2))-3,0)
local ap=Vector3.new(math.round(an.X/3)*3,math.round(an.Y/3)*3,math.round(an.Z/3)*3)
L.placeBlock(ap,'cannon',false)

task.delay(0,function()
local aq,ar=getPlacedBlock(ap)
if aq and aq.Name=='cannon'and(x.character.RootPart.Position-aq.Position).Magnitude<20 then
local as=L.ItemMeta[aq.Name].block.breakType
local at=F.tools[as]
if at then
switchItem(at.tool)
end

L.Client:Get(M.CannonAim):SendToServer{
cannonBlockPos=ar,
lookVector=ao
}

local au=0.1
if L.BlockController:calculateBlockDamage(s,{blockPosition=ar})<aq:GetAttribute'Health'then
au=0.4
L.breakBlock(aq,true,true)
end

task.delay(au,function()
for av=1,3 do
local aw=L.Client:Get(M.CannonLaunch):CallServer{cannonBlockPos=ar}
if aw then
L.breakBlock(aq,true,true)
aj=5.25*af.Value
ai=tick()+2.3
ak=Vector3.new(ao.X,0,ao.Z).Unit
break
end
task.wait(0.1)
end
end)
end
end)
end,
cat=function(am,an,ao)
ac:Clean(c.CatPounce.Event:Connect(function()
aj=4*af.Value
ai=tick()+2.5
ak=Vector3.new(ao.X,0,ao.Z).Unit
x.character.RootPart.Velocity=Vector3.zero
end))

if not L.AbilityController:canUseAbility'CAT_POUNCE'then
repeat task.wait()until L.AbilityController:canUseAbility'CAT_POUNCE'or not ac.Enabled
end

if L.AbilityController:canUseAbility'CAT_POUNCE'and ac.Enabled then
L.AbilityController:useAbility'CAT_POUNCE'
end
end,
fireball=function(an,ao,ap)
launchProjectile(an,ao,'fireball',60,ap)
end,
grappling_hook=function(an,ao,ap)
launchProjectile(an,ao,'grappling_hook_projectile',140,ap)
end,
jade_hammer=function(an,ao,ap)
if not L.AbilityController:canUseAbility(an.itemType..'_jump')then
repeat task.wait()until L.AbilityController:canUseAbility(an.itemType..'_jump')or not ac.Enabled
end

if L.AbilityController:canUseAbility(an.itemType..'_jump')and ac.Enabled then
L.AbilityController:useAbility(an.itemType..'_jump')
aj=1.4*af.Value
ai=tick()+2.5
ak=Vector3.new(ap.X,0,ap.Z).Unit
end
end,
tnt=function(an,ao,ap)
ao=ao-Vector3.new(0,(x.character.HipHeight+(x.character.RootPart.Size.Y/2))-3,0)
local aq=Vector3.new(math.round(ao.X/3)*3,math.round(ao.Y/3)*3,math.round(ao.Z/3)*3)
ah=Vector3.new(aq.X,ah.Y,aq.Z)+(ap*(an.itemType=='pirate_gunpowder_barrel'and 2.6 or 0.2))
L.placeBlock(aq,an.itemType,false)
end,
wood_dao=function(an,ao,ap)
if(s.Character:GetAttribute'CanDashNext'or 0)>workspace:GetServerTimeNow()or not L.AbilityController:canUseAbility'dash'then
repeat task.wait()until(s.Character:GetAttribute'CanDashNext'or 0)<workspace:GetServerTimeNow()and L.AbilityController:canUseAbility'dash'or not ac.Enabled
end

if ac.Enabled then
L.SwordController.lastAttack=workspace:GetServerTimeNow()
switchItem(an.tool,0.1)
n['events-@easy-games/game-core:shared/game-core-networking@getEvents.Events'].useAbility:FireServer('dash',{
direction=ap,
origin=ao,
weapon=an.itemType
})
aj=4.5*af.Value
ai=tick()+2.4
ak=Vector3.new(ap.X,0,ap.Z).Unit
end
end
}
for ao,ap in{'stone_dao','iron_dao','diamond_dao','emerald_dao'}do
an[ap]=an.wood_dao
end
an.void_axe=an.jade_hammer
an.siege_tnt=an.tnt
an.pirate_gunpowder_barrel=an.tnt

ac=u.Categories.Blatant:CreateModule{
Name='LongJump',
Function=function(ao)
Q.LongJump=ao or nil
updateVelocity()
if ao then
ac:Clean(c.EntityDamageEvent.Event:Connect(function(ap)
if ap.entityInstance==s.Character and ap.fromEntity==s.Character and(not ap.knockbackMultiplier or not ap.knockbackMultiplier.disabled)then
local aq=L.KnockbackUtil.calculateKnockbackVelocity(Vector3.one,1,{
vertical=0,
horizontal=(ap.knockbackMultiplier and ap.knockbackMultiplier.horizontal or 1)
}).Magnitude*1.1

if aq>=aj then
local ar=ap.fromPosition and Vector3.new(ap.fromPosition.X,ap.fromPosition.Y,ap.fromPosition.Z)or ap.fromEntity and ap.fromEntity.PrimaryPart.Position
if not ar then return end
local as=(x.character.RootPart.Position-ar)
aj=aq
ai=tick()+2.5
ak=Vector3.new(as.X,0,as.Z).Unit
end
end
end))
ac:Clean(c.GrapplingHookFunctions.Event:Connect(function(ap)
if ap.hookFunction=='PLAYER_IN_TRANSIT'then
local aq=x.character.RootPart.CFrame.LookVector
aj=2.5*af.Value
ai=tick()+2.5
ak=Vector3.new(aq.X,0,aq.Z).Unit
end
end))

ah=x.isAlive and x.character.RootPart.Position or nil
ac:Clean(e.PreSimulation:Connect(LPH_NO_VIRTUALIZE(function(ap)
local aq=x.isAlive and x.character.RootPart or nil

if aq and q(aq)then
if ai>tick()then
aq.AssemblyLinearVelocity=ak*(getSpeed()+((ai-tick())>1.1 and aj or 0))+Vector3.new(0,aq.AssemblyLinearVelocity.Y,0)
if x.character.Humanoid.FloorMaterial==Enum.Material.Air and not ah then
aq.AssemblyLinearVelocity+=Vector3.new(0,ap*(workspace.Gravity-23),0)
else
aq.AssemblyLinearVelocity=Vector3.new(aq.AssemblyLinearVelocity.X,15,aq.AssemblyLinearVelocity.Z)
end
ah=nil
else
if ah then
aq.CFrame=CFrame.lookAlong(ah,aq.CFrame.LookVector)
end
aq.AssemblyLinearVelocity=Vector3.zero
aj=0
end
else
ah=nil
end
end)))

if F.hand and an[F.hand.tool.Name]then
task.spawn(an[F.hand.tool.Name],getItem(F.hand.tool.Name),ah,(ag.Enabled and r or x.character.RootPart).CFrame.LookVector)
return
end

for ap,aq in an do
local ar=getItem(ap)
if ar or L.isKitEquipped(ap)then
task.spawn(aq,ar,ah,(ag.Enabled and r or x.character.RootPart).CFrame.LookVector)
break
end
end
else
ai=tick()
ak=nil
aj=0
end
end,
ExtraText=function()
return'Heatseeker'
end,
Tooltip='Lets you jump farther'
}
af=ac:CreateSlider{
Name='Speed',
Min=1,
Max=37,
Default=37,
Suffix=function(ao)
return ao==1 and'stud'or'studs'
end
}
ag=ac:CreateToggle{
Name='Camera Direction'
}
end)

b(function()
local af
local ag
local ah=RaycastParams.new()
local ai
task.spawn(function()
ai=L.Client:Get(M.GroundHit).instance
end)

af=u.Categories.Blatant:CreateModule{
Name='NoFall',
Function=function(aj)
if aj then
local ak=0
if ag.Value=='Gravity'then
local al=0
af:Clean(e.PreSimulation:Connect(LPH_NO_VIRTUALIZE(function(an)
if x.isAlive then
local ao=x.character.RootPart
if ao.AssemblyLinearVelocity.Y<-85 then
ah.FilterDescendantsInstances={s.Character,r}
ah.CollisionGroup=ao.CollisionGroup

local ap=ao.Size.Y/2+x.character.HipHeight
local aq=workspace:Blockcast(ao.CFrame,Vector3.new(3,3,3),Vector3.new(0,(ak*0.1)-ap,0),ah)
if not aq then
ao.AssemblyLinearVelocity=Vector3.new(ao.AssemblyLinearVelocity.X,-86,ao.AssemblyLinearVelocity.Z)
ao.CFrame+=Vector3.new(0,al*an,0)
al+=-workspace.Gravity*an
end
else
al=0
end
end
end)))
else
repeat
if x.isAlive then
local al=x.character.RootPart
ak=x.character.Humanoid.FloorMaterial==Enum.Material.Air and math.min(ak,al.AssemblyLinearVelocity.Y)or 0

if ak<-85 then
if ag.Value=='Packet'then

else
ah.FilterDescendantsInstances={s.Character,r}
ah.CollisionGroup=al.CollisionGroup

local an=al.Size.Y/2+x.character.HipHeight
if ag.Value=='Teleport'then
local ao=workspace:Blockcast(al.CFrame,Vector3.new(3,3,3),Vector3.new(0,-1E3,0),ah)
if ao then
al.CFrame-=Vector3.new(0,al.Position.Y-(ao.Position.Y+an),0)
end
else
local ao=workspace:Blockcast(al.CFrame,Vector3.new(3,3,3),Vector3.new(0,(ak*0.1)-an,0),ah)
if ao then
ak=0
al.AssemblyLinearVelocity=Vector3.new(al.AssemblyLinearVelocity.X,-80,al.AssemblyLinearVelocity.Z)
end
end
end
end
end

task.wait(0.03)
until not af.Enabled
end
end
end,
Tooltip='Prevents taking fall damage.'
}
ag=af:CreateDropdown{
Name='Mode',
List={'Gravity','Teleport','Bounce'},
Function=function()
if af.Enabled then
af:Toggle()
af:Toggle()
end
end
}
end)

b(function()
local af

u.Categories.Blatant:CreateModule{
Name='NoSlowdown',
Function=function(ag)
local ah=L.SprintController:getMovementStatusModifier()
if ag then
af=ah.addModifier
ah.addModifier=function(ai,aj)
if aj.moveSpeedMultiplier then
aj.moveSpeedMultiplier=math.max(aj.moveSpeedMultiplier,1)
end
return af(ai,aj)
end

for ai in ah.modifiers do
if(ai.moveSpeedMultiplier or 1)<1 then
ah:removeModifier(ai)
end
end
else
ah.addModifier=af
af=nil
end
end,
Tooltip='Prevents slowing down when using items.'
}
end)

b(function()
local af
local ag
local ah
local ai
local aj
local ak=RaycastParams.new()
ak.FilterType=Enum.RaycastFilterType.Include
ak.FilterDescendantsInstances={workspace:FindFirstChild'Map'}
local al

local an=u.Categories.Blatant:CreateModule{
Name='ProjectileAimbot',
Function=function(an)
if an then
al=L.ProjectileController.calculateImportantLaunchValues
L.ProjectileController.calculateImportantLaunchValues=function(...)
local ao,ap,aq,ar,as=...
local at=x.EntityMouse{
Part='RootPart',
Range=ah.Value,
Players=ag.Players.Enabled,
NPCs=ag.NPCs.Enabled,
Wallcheck=ag.Walls.Enabled,
Origin=x.isAlive and(as or x.character.RootPart.Position)or Vector3.zero
}

if at then
local au=as or ao:getLaunchPosition(ar)
if not au then
return al(...)
end

if(not ai.Enabled)and not ap.projectile:find'arrow'then
return al(...)
end

local av=ap:getProjectileMeta()
local aw=(aq and av.predictionLifetimeSec or av.lifetimeSec or 3)
local ax=(av.gravitationalAcceleration or 196.2)*ap.gravityMultiplier
local ay=(av.launchVelocity or 100)
local az=au+(ap.projectile=='owl_projectile'and Vector3.zero or ap.fromPositionOffset)
local aA=at.Character:GetAttribute'InflatedBalloons'
local aB=workspace.Gravity

if aA and aA>0 then
aB=(workspace.Gravity*(1-((aA>=4 and 1.2 or aA>=3 and 1 or 0.975))))
end

if at.Character.PrimaryPart:FindFirstChild'rbxassetid://8200754399'then
aB=6
end

if at.Player then
if at.Player:GetAttribute'IsOwlTarget'then
for aC,aD in o:GetTagged'Owl'do
if aD:GetAttribute'Target'==at.Player.UserId and aD:GetAttribute'Status'==2 then
aB=0
end
end
end
end

if math.random(1,100)>aj.Value then
local aC=Vector3.new(
(math.random()-0.5)*20,
(math.random()-0.5)*20,
(math.random()-0.5)*20
)
local aD=CFrame.new(az,at[af.Value].Position+aC)*CFrame.new(ap.projectile=='owl_projectile'and Vector3.zero or Vector3.new(L.BowConstantsTable.RelX,L.BowConstantsTable.RelY,L.BowConstantsTable.RelZ))
local aE=B.SolveTrajectory(aD.p,ay,ax,at[af.Value].Position+aC,ap.projectile=='telepearl'and Vector3.zero or at[af.Value].Velocity,aB,at.HipHeight,at.Jumping and 42.6 or nil,ak)
if aE then
return{
initialVelocity=CFrame.new(aD.Position,aE).LookVector*ay,
positionFrom=az,
deltaT=aw,
gravitationalAcceleration=ax,
drawDurationSeconds=5
}
end
else
local aC=CFrame.new(az,at[af.Value].Position)*CFrame.new(ap.projectile=='owl_projectile'and Vector3.zero or Vector3.new(L.BowConstantsTable.RelX,L.BowConstantsTable.RelY,L.BowConstantsTable.RelZ))
local aD=B.SolveTrajectory(aC.p,ay,ax,at[af.Value].Position,ap.projectile=='telepearl'and Vector3.zero or at[af.Value].Velocity,aB,at.HipHeight,at.Jumping and 42.6 or nil,ak)
if aD then
A.Targets[at]=tick()+1
return{
initialVelocity=CFrame.new(aC.Position,aD).LookVector*ay,
positionFrom=az,
deltaT=aw,
gravitationalAcceleration=ax,
drawDurationSeconds=5
}
end
end
end

return al(...)
end
else
L.ProjectileController.calculateImportantLaunchValues=al
end
end,
Tooltip='Silently adjusts your aim towards the enemy'
}
ag=an:CreateTargets{
Players=true,
Walls=true
}
af=an:CreateDropdown{
Name='Part',
List={'RootPart','Head'}
}
ah=an:CreateSlider{
Name='FOV',
Min=1,
Max=1000,
Default=1000
}
ai=an:CreateToggle{
Name='Other Projectiles',
Default=true
}
aj=an:CreateSlider{
Name='Hit Chance',
Min=0,
Max=100,
Default=100,
Suffix='%'
}
end)

b(function()
local af
local ag
local ah
local ai=RaycastParams.new()
ai.FilterType=Enum.RaycastFilterType.Include
local aj={InvokeServer=function()end}
local ak={}
task.spawn(function()
aj=L.Client:Get(M.FireProjectile).instance
end)

local function getAmmo(al)
for an,ao in F.inventory.inventory.items do
if al.ammoItemTypes and table.find(al.ammoItemTypes,ao.itemType)then
return ao.itemType
end
end
end

local function getProjectiles()
local al={}
for an,ao in F.inventory.inventory.items do
local ap=L.ItemMeta[ao.itemType].projectileSource
if not ap then
continue
end
local aq=ap and getAmmo(ap)
if not ap.projectileType then

continue
end
if aq and table.find(ah.ListEnabled,aq)then
table.insert(al,{
ao,
aq,
ap.projectileType(aq),
ap,
})
end
end
return al
end
local function fireRaven(al,an)
if not an then
return
end
if not al then
return
end
if not al.tool then
return
end
pcall(switchItem,al.tool)
L.Client:Get(M.SpawnRaven):CallServerAsync():andThen(function(ao)
if ao then
local ap=Instance.new"BodyForce"
ap.Force=Vector3.new(0,ao.PrimaryPart.AssemblyMass*workspace.Gravity,0)
ap.Parent=ao.PrimaryPart

if an then
task.spawn(function()
for aq=1,20 do
if an and ao then
ao:SetPrimaryPartCFrame(
CFrame.lookAlong(an.Position,r.CFrame.LookVector)
)
end
task.wait(0.05)
end
end)
task.wait(0.3)
L.RavenController:detonateRaven()
end
end
end)
end
local al
getgenv().projectileTick=tick()
getgenv().projectileCount={}
ae=u.Categories.Blatant:CreateModule{
Name="ProjectileAura",
Function=function(an)
if an then
repeat
if F.matchState==0 then
task.wait(1)
return
end
if
(workspace:GetServerTimeNow()-L.SwordController.lastAttack)>0.5
or getgenv().projectileTick>=tick()
then
local ao=x.EntityPosition{
Part="RootPart",
Range=ag.Value,
Players=af.Players.Enabled,
NPCs=af.NPCs.Enabled,
Wallcheck=af.Walls.Enabled,
}

if ao then
local ap=x.character.RootPart.Position
if al.Enabled then
local aq=getItem"raven"
if aq then
local ar,as=pcall(fireRaven,aq,ao.RootPart)
if not ar then
errorNotification("ProjectileAura - Raven Aura",tostring(as),5)
end
end
end
local aq=getProjectiles()
getgenv().projectileCount=aq
for ar,as in aq do
local at,au,av,aw=unpack(as)
if(ak[at.itemType]or 0)<tick()then
ai.FilterDescendantsInstances={workspace.Map}
local ax=L.ProjectileMeta[av]
local ay,az=
ax.launchVelocity,ax.gravitationalAcceleration or 196.2
local aA=B.SolveTrajectory(
ap,
ay,
az,
ao.RootPart.Position,
ao.RootPart.Velocity,
workspace.Gravity,
ao.HipHeight,
ao.Jumping and 42.6 or nil,
ai
)
if aA then
A.Targets[ao]=tick()+1
local aB=switchItem(at.tool)

task.spawn(function()
local aC,aD=
CFrame.lookAt(ap,aA).LookVector,i:GenerateGUID(true)
local aE=(CFrame.new(ap,aA)*CFrame.new(
Vector3.new(
-L.BowConstantsTable.RelX,
-L.BowConstantsTable.RelY,
-L.BowConstantsTable.RelZ
)
)).Position
local aF=aj:InvokeServer(
at.tool,
au,
av,
aE,
ap,
aC*ay,
aD,
{drawDurationSeconds=1,shotId=i:GenerateGUID(false)},
workspace:GetServerTimeNow()-0.045
)
if not aF then
ak[at.itemType]=tick()
else
local aG=aw.launchSound
aG=aG and aG[math.random(1,#aG)]or nil
if aG then
L.SoundManager:playSound(aG)
end
end
end)

ak[at.itemType]=tick()+aw.fireDelaySec
if aB then
task.wait(0.05)
end
end
end
end
end
end
task.wait(0.1)
until not ae.Enabled
end
end,
Tooltip="Shoots people around you",
}
af=ae:CreateTargets{
Players=true,
Walls=true,
}
ah=ae:CreateTextList{
Name="Projectiles",
Default={"arrow","snowball"},
}
ag=ae:CreateSlider{
Name="Range",
Min=1,
Max=50,
Default=50,
Suffix=function(an)
return an==1 and"stud"or"studs"
end,
}
al=ae:CreateToggle{
Name="Raven Aura",
Function=function()end,
Default=false,
}
end)

b(function()
local af
local ag
local ah
local ai
local aj
local ak=RaycastParams.new()
ak.RespectCanCollide=true

af=u.Categories.Blatant:CreateModule{
Name='Speed',
Function=function(al)
Q.Speed=al or nil
updateVelocity()
pcall(function()
debug.setconstant(L.WindWalkerController.updateSpeed,7,al and'constantSpeedMultiplier'or'moveSpeedMultiplier')
end)

if al then
af:Clean(e.PreSimulation:Connect(LPH_NO_VIRTUALIZE(function(an)
L.StatefulEntityKnockbackController.lastImpulseTime=al and math.huge or time()
if x.isAlive and not ab.Enabled and not I.Enabled and not ac.Enabled and q(x.character.RootPart)then
local ao=x.character.Humanoid:GetState()
if ao==Enum.HumanoidStateType.Climbing then return end

local ap,aq=x.character.RootPart,getSpeed()
local ar=aa or x.character.Humanoid.MoveDirection
local as=(ar*math.max(ag.Value-aq,0)*an)

if ah.Enabled then
ak.FilterDescendantsInstances={s.Character,r}
ak.CollisionGroup=ap.CollisionGroup
local at=blocksRaycast(as)

if at then
as=((at.Position+at.Normal)-ap.Position)
end
end

ap.CFrame+=as
ap.AssemblyLinearVelocity=(ar*aq)+Vector3.new(0,ap.AssemblyLinearVelocity.Y,0)
if ai.Enabled and(ao==Enum.HumanoidStateType.Running or ao==Enum.HumanoidStateType.Landed)and ar~=Vector3.zero and(ad or aj.Enabled)then
x.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end
end
end)))
end
end,
ExtraText=function()
return'Heatseeker'
end,
Tooltip='Increases your movement with various methods.'
}
ag=af:CreateSlider{
Name='Speed',
Min=1,
Max=23,
Default=23,
Suffix=function(al)
return al==1 and'stud'or'studs'
end
}
ah=af:CreateToggle{
Name='Wall Check',
Default=true
}
ai=af:CreateToggle{
Name='AutoJump',
Function=function(al)
aj.Object.Visible=al
end
}
aj=af:CreateToggle{
Name='Always Jump',
Visible=false,
Darker=true
}
end)

b(function()
local af
local ag={}
local ah=Instance.new'Folder'
ah.Parent=u.gui

local function Added(ai)
if not af.Enabled then return end
local aj=Instance.new'Folder'
aj.Parent=ah
ag[ai]=aj
local ak=ai:GetChildren()
table.sort(ak,function(al,an)
return al.Name>an.Name
end)

for al,an in ak do
if an:IsA'BasePart'and an.Name~='Blanket'then
local ao=Instance.new'BoxHandleAdornment'
ao.Size=an.Size+Vector3.new(.01,.01,.01)
ao.AlwaysOnTop=true
ao.ZIndex=2
ao.Visible=true
ao.Adornee=an
ao.Color3=an.Color
if an.Name=='Legs'then
ao.Color3=Color3.fromRGB(167,112,64)
ao.Size=an.Size+Vector3.new(.01,-1,.01)
ao.CFrame=CFrame.new(0,-0.4,0)
ao.ZIndex=0
end
ao.Parent=aj
end
end

table.clear(ak)
end

af=u.Categories.Render:CreateModule{
Name='BedESP',
Function=function(ai)
if ai then
af:Clean(o:GetInstanceAddedSignal'bed':Connect(function(aj)
task.delay(0.2,Added,aj)
end))
af:Clean(o:GetInstanceRemovedSignal'bed':Connect(function(aj)
if ag[aj]then
ag[aj]:Destroy()
ag[aj]=nil
end
end))
for aj,ak in o:GetTagged'bed'do
Added(ak)
end
else
ah:ClearAllChildren()
table.clear(ag)
end
end,
Tooltip='Render Beds through walls'
}
end)

b(function()
local af

af=u.Categories.Render:CreateModule{
Name='Health',
Function=function(ag)
if ag then
local ah=Instance.new'TextLabel'
ah.Size=UDim2.fromOffset(100,20)
ah.Position=UDim2.new(0.5,6,0.5,30)
ah.BackgroundTransparency=1
ah.AnchorPoint=Vector2.new(0.5,0)
ah.Text=x.isAlive and math.round(s.Character:GetAttribute'Health')..' ❤️'or''
ah.TextColor3=x.isAlive and Color3.fromHSV((s.Character:GetAttribute'Health'/s.Character:GetAttribute'MaxHealth')/2.8,0.86,1)or Color3.new()
ah.TextSize=18
ah.Font=Enum.Font.Arial
ah.Parent=u.gui
af:Clean(ah)
af:Clean(c.AttributeChanged.Event:Connect(function()
ah.Text=x.isAlive and math.round(s.Character:GetAttribute'Health')..' ❤️'or''
ah.TextColor3=x.isAlive and Color3.fromHSV((s.Character:GetAttribute'Health'/s.Character:GetAttribute'MaxHealth')/2.8,0.86,1)or Color3.new()
end))
end
end,
Tooltip='Displays your health in the center of your screen.'
}
end)

b(function()
local af
local ag
local ah={}
local ai={}
local aj=Instance.new"Folder"
aj.Parent=u.gui

local ak={
alchemist={"alchemist_ingedients","wild_flower"},
beekeeper={"bee","bee"},
bigman={"treeOrb","natures_essence_1"},
ghost_catcher={"ghost","ghost_orb"},
metal_detector={"hidden-metal","iron"},
sheep_herder={"SheepModel","purple_hay_bale"},
sorcerer={"alchemy_crystal","wild_flower"},
star_collector={"stars","crit_star"},
}

local function Added(al,an)
local ao=Instance.new"BillboardGui"
ao.Parent=aj
ao.Name=an
ao.StudsOffsetWorldSpace=Vector3.new(0,3,0)
ao.Size=UDim2.fromOffset(36,36)
ao.AlwaysOnTop=true
ao.ClipsDescendants=false
ao.Adornee=al
local ap=addBlur(ao)
ap.Visible=ag.Enabled
local aq=Instance.new"ImageLabel"
aq.Size=UDim2.fromOffset(36,36)
aq.Position=UDim2.fromScale(0.5,0.5)
aq.AnchorPoint=Vector2.new(0.5,0.5)
aq.BackgroundColor3=Color3.fromHSV(ah.Hue,ah.Sat,ah.Value)
aq.BackgroundTransparency=1-(ag.Enabled and ah.Opacity or 0)
aq.BorderSizePixel=0
aq.Image=L.getIcon({itemType=an},true)
aq.Parent=ao
local ar=Instance.new"UICorner"
ar.CornerRadius=UDim.new(0,4)
ar.Parent=aq
ai[al]=ao
end

local function addKit(al,an)
af:Clean(o:GetInstanceAddedSignal(al):Connect(function(ao)
Added(ao.PrimaryPart,an)
end))
af:Clean(o:GetInstanceRemovedSignal(al):Connect(function(ao)
if ai[ao.PrimaryPart]then
ai[ao.PrimaryPart]:Destroy()
ai[ao.PrimaryPart]=nil
end
end))
for ao,ap in o:GetTagged(al)do
Added(ap.PrimaryPart,an)
end
end

local al
af=u.Categories.Render:CreateModule{
Name="KitESP",
Function=function(an)
if an then
repeat
task.wait()
until F.equippedKit~=""or not af.Enabled
al=true
for ao,ap in ak do
local aq=af.Enabled and L.isKitEquipped(ao)and ak[ao]or nil
if aq then
addKit(aq[1],aq[2])
end
end
else
aj:ClearAllChildren()
table.clear(ai)
end
end,
Tooltip="ESP for certain kit related objects",
}
c.EquippedKitChanged:Connect(function()
if af.Enabled and al then
af:Toggle()
task.wait(0.1)
af:Toggle()
end
end)
ag=af:CreateToggle{
Name="Background",
Function=function(an)
if ah.Object then
ah.Object.Visible=an
end
for ao,ap in ai do
ap.ImageLabel.BackgroundTransparency=1-(an and ah.Opacity or 0)
ap.Blur.Visible=an
end
end,
Default=true,
}
ah=af:CreateColorSlider{
Name="Background Color",
DefaultValue=0,
DefaultOpacity=0.5,
Function=function(an,ao,ap,aq)
for ar,as in ai do
as.ImageLabel.BackgroundColor3=Color3.fromHSV(an,ao,ap)
as.ImageLabel.BackgroundTransparency=1-aq
end
end,
Darker=true,
}
end)

b(function()
local af
local ag
local ah
local ai
local aj
local ak
local al
local an
local ao
local ap
local aq
local ar
local as
local at
local au
local av,aw,ax={},{},{}
local ay=Instance.new"Folder"
ay.Parent=u.gui
local az

local aA={
Normal=function(aA)
if not ag.Players.Enabled and aA.Player then
return
end
if not ag.NPCs.Enabled and aA.NPC then
return
end
if as.Enabled and not aA.Targetable and not aA.Friend then
return
end

local aB=Instance.new"TextLabel"
av[aA]=aA.Player
and z:tag(aA.Player,true,true)..(aj.Enabled and aA.Player.DisplayName or aA.Player.Name)
or aA.Character.Name

if ak.Enabled then
local aC=Color3.fromHSV(math.clamp(aA.Health/aA.MaxHealth,0,1)/2.5,0.89,0.75)
av[aA]=av[aA]
..' <font color="rgb('
..tostring(math.floor(aC.R*255))
..","
..tostring(math.floor(aC.G*255))
..","
..tostring(math.floor(aC.B*255))
..')">'
..math.round(aA.Health)
.."</font>"
end

if al.Enabled then
av[aA]='<font color="rgb(85, 255, 85)">[</font><font color="rgb(255, 255, 255)">%s</font><font color="rgb(85, 255, 85)">]</font> '
..av[aA]
end























local aC=30
local aD=2

local aE=an.Enabled and 0 or 0
local aF=(ao.Enabled and aA.Player)and 1 or 0
local aG=aE+aF

local aH=(aG*aC)+((aG-1)*aD)
local aI=-(aH/2)

if ao.Enabled and aA.Player then
local aJ=Instance.new"ImageLabel"
aJ.Name="Enchant"
aJ.Size=UDim2.fromOffset(aC,aC)
aJ.Position=UDim2.fromOffset(aI,-30)
aJ.BackgroundTransparency=1
aJ.Image=""
aJ.Parent=aB

aI=aI+aC+aD
end

if an.Enabled then
for aJ,aK in{"Hand","Helmet","Chestplate","Boots","Kit"}do
local aL=Instance.new"ImageLabel"
aL.Name=aK
aL.Size=UDim2.fromOffset(aC,aC)
aL.Position=UDim2.fromOffset(aI+((aJ-1)*(aC+aD)),-30)
aL.BackgroundTransparency=1
aL.Image=""
aL.Parent=aB
end
end

aB.TextSize=14*aq.Value
aB.FontFace=ar.Value
local aJ=
D(removeTags(av[aA]),aB.TextSize,aB.FontFace,Vector2.new(100000,100000))
aB.Name=aA.Player and aA.Player.Name or aA.Character.Name
aB.Size=UDim2.fromOffset(aJ.X+8,aJ.Y+7)
aB.AnchorPoint=Vector2.new(0.5,1)
aB.BackgroundColor3=Color3.new()
aB.BackgroundTransparency=ai.Value
aB.BorderSizePixel=0
aB.Visible=false
aB.Text=av[aA]
aB.TextColor3=x.getEntityColor(aA)or Color3.fromHSV(ah.Hue,ah.Sat,ah.Value)
aB.RichText=true
aB.Parent=ay
ax[aA]=aB
end,
Drawing=function(aA)
if not ag.Players.Enabled and aA.Player then
return
end
if not ag.NPCs.Enabled and aA.NPC then
return
end
if as.Enabled and not aA.Targetable and not aA.Friend then
return
end

local aB={}
aB.BG=Drawing.new"Square"
aB.BG.Filled=true
aB.BG.Transparency=1-ai.Value
aB.BG.Color=Color3.new()
aB.BG.ZIndex=1
aB.Text=Drawing.new"Text"
aB.Text.Size=15*aq.Value
aB.Text.Font=0
aB.Text.ZIndex=2
av[aA]=aA.Player
and z:tag(aA.Player,true)..(aj.Enabled and aA.Player.DisplayName or aA.Player.Name)
or aA.Character.Name

if ak.Enabled then
av[aA]=av[aA].." "..math.round(aA.Health)
end

if al.Enabled then
av[aA]="[%s] "..av[aA]
end

aB.Text.Text=av[aA]
aB.Text.Color=x.getEntityColor(aA)or Color3.fromHSV(ah.Hue,ah.Sat,ah.Value)
aB.BG.Size=Vector2.new(aB.Text.TextBounds.X+8,aB.Text.TextBounds.Y+7)
ax[aA]=aB
end,
}

local aB={
Normal=function(aB)
local aC=ax[aB]
if aC then
ax[aB]=nil
av[aB]=nil
aw[aB]=nil
aC:Destroy()
end
end,
Drawing=function(aB)
local aC=ax[aB]
if aC then
ax[aB]=nil
av[aB]=nil
aw[aB]=nil
for aD,aE in aC do
pcall(function()
aE.Visible=false
aE:Remove()
end)
end
end
end,
}

local aC={
Normal=function(aC)
local aD=ax[aC]
if aD then
aw[aC]=nil
av[aC]=aC.Player
and z:tag(aC.Player,true,true)..(aj.Enabled and aC.Player.DisplayName or aC.Player.Name)
or aC.Character.Name

if ak.Enabled then
local aE=Color3.fromHSV(math.clamp(aC.Health/aC.MaxHealth,0,1)/2.5,0.89,0.75)
av[aC]=av[aC]
..' <font color="rgb('
..tostring(math.floor(aE.R*255))
..","
..tostring(math.floor(aE.G*255))
..","
..tostring(math.floor(aE.B*255))
..')">'
..math.round(aC.Health)
.."</font>"
end

if al.Enabled then
av[aC]='<font color="rgb(85, 255, 85)">[</font><font color="rgb(255, 255, 255)">%s</font><font color="rgb(85, 255, 85)">]</font> '
..av[aC]
end

if an.Enabled and F.inventories[aC.Player]then
local aE=aC.Player:GetAttribute"PlayingAsKits"
local aF=F.inventories[aC.Player]
aD.Hand.Image=L.getIcon(aF.hand or{itemType=""},true)
aD.Helmet.Image=L.getIcon(aF.armor[1]or{itemType=""},true)
aD.Chestplate.Image=L.getIcon(aF.armor[2]or{itemType=""},true)
aD.Boots.Image=L.getIcon(aF.armor[3]or{itemType=""},true)
aD.Kit.Image=aE and aE~="none"and L.BedwarsKitMeta[aE]and L.BedwarsKitMeta[aE]and L.BedwarsKitMeta[aE].renderImage or""
end

if ao.Enabled and aC.Player and aD:FindFirstChild"Enchant"then
local aE=L.EnchantTableController.enchants[aC.Player.UserId]
if aE~=nil and aE.image then
aD.Enchant.Image=aE.image
else
aD.Enchant.Image=""
end
end

local aE=D(
removeTags(av[aC]),
aD.TextSize,
aD.FontFace,
Vector2.new(100000,100000)
)
aD.Size=UDim2.fromOffset(aE.X+8,aE.Y+7)
aD.Text=av[aC]
end
end,
Drawing=function(aC)
local aD=ax[aC]
if aD then
if u.ThreadFix then
setthreadidentity(8)
end
aw[aC]=nil
av[aC]=aC.Player
and z:tag(aC.Player,true)..(aj.Enabled and aC.Player.DisplayName or aC.Player.Name)
or aC.Character.Name

if ak.Enabled then
av[aC]=av[aC].." "..math.round(aC.Health)
end

if al.Enabled then
av[aC]="[%s] "..av[aC]
aD.Text.Text=x.isAlive
and string.format(
av[aC],
math.floor((x.character.RootPart.Position-aC.RootPart.Position).Magnitude)
)
or av[aC]
else
aD.Text.Text=av[aC]
end

aD.BG.Size=Vector2.new(aD.Text.TextBounds.X+8,aD.Text.TextBounds.Y+7)
aD.Text.Color=x.getEntityColor(aC)or Color3.fromHSV(ah.Hue,ah.Sat,ah.Value)
end
end,
}

local aD={
Normal=function(aD,aE,aF)
local aG=Color3.fromHSV(aD,aE,aF)
for aH,aI in ax do
aI.TextColor3=x.getEntityColor(aH)or aG
end
end,
Drawing=function(aD,aE,aF)
local aG=Color3.fromHSV(aD,aE,aF)
for aH,aI in ax do
aI.Text.Color=x.getEntityColor(aH)or aG
end
end,
}

local aE={
Normal=function()
for aE,aF in ax do
if at.Enabled then
local aG=x.isAlive
and(x.character.RootPart.Position-aE.RootPart.Position).Magnitude
or math.huge
if aG<au.ValueMin or aG>au.ValueMax then
aF.Visible=false
continue
end
end

local aG,aH=
r:WorldToViewportPoint(aE.RootPart.Position+Vector3.new(0,aE.HipHeight+1,0))
aF.Visible=aH
if not aH then
continue
end

if al.Enabled then
local aI=x.isAlive
and math.floor((x.character.RootPart.Position-aE.RootPart.Position).Magnitude)
or 0
if aw[aE]~=aI then
aF.Text=string.format(av[aE],aI)
local aJ=D(
removeTags(aF.Text),
aF.TextSize,
aF.FontFace,
Vector2.new(100000,100000)
)
aF.Size=UDim2.fromOffset(aJ.X+8,aJ.Y+7)
aw[aE]=aI
end
end
aF.Position=UDim2.fromOffset(aG.X,aG.Y)

if an.Enabled and F.inventories[aE.Player]then
local aI=aE.Player:GetAttribute"PlayingAsKits"
local aJ=F.inventories[aE.Player]
aF.Hand.Image=L.getIcon(aJ.hand or{itemType=""},true)
aF.Helmet.Image=L.getIcon(aJ.armor[1]or{itemType=""},true)
aF.Chestplate.Image=L.getIcon(aJ.armor[2]or{itemType=""},true)
aF.Boots.Image=L.getIcon(aJ.armor[3]or{itemType=""},true)
aF.Kit.Image=aI and aI~="none"and L.BedwarsKitMeta[aI]and L.BedwarsKitMeta[aI].renderImage or""
end
end
end,
Drawing=function()
for aE,aF in ax do
if at.Enabled then
local aG=x.isAlive
and(x.character.RootPart.Position-aE.RootPart.Position).Magnitude
or math.huge
if aG<au.ValueMin or aG>au.ValueMax then
aF.Text.Visible=false
aF.BG.Visible=false
continue
end
end

local aG,aH=
r:WorldToViewportPoint(aE.RootPart.Position+Vector3.new(0,aE.HipHeight+1,0))
aF.Text.Visible=aH
aF.BG.Visible=aH
if not aH then
continue
end

if al.Enabled then
local aI=x.isAlive
and math.floor((x.character.RootPart.Position-aE.RootPart.Position).Magnitude)
or 0
if aw[aE]~=aI then
aF.Text.Text=string.format(av[aE],aI)
aF.BG.Size=Vector2.new(aF.Text.TextBounds.X+8,aF.Text.TextBounds.Y+7)
aw[aE]=aI
end
end
aF.BG.Position=Vector2.new(aG.X-(aF.BG.Size.X/2),aG.Y-aF.BG.Size.Y)
aF.Text.Position=aF.BG.Position+Vector2.new(4,3)
end
end,
}

af=u.Categories.Render:CreateModule{
Name="NameTags",
Function=function(aF)
if aF then
az=ap.Enabled and"Drawing"or"Normal"
if aB[az]then
af:Clean(x.Events.EntityRemoved:Connect(aB[az]))
end
if aA[az]then
for aG,aH in x.List do
if ax[aH]then
aB[az](aH)
end
aA[az](aH)
end
af:Clean(x.Events.EntityAdded:Connect(function(aG)
if ax[aG]then
aB[az](aG)
end
aA[az](aG)
end))
end
if aC[az]then
af:Clean(x.Events.EntityUpdated:Connect(aC[az]))
for aG,aH in x.List do
aC[az](aH)
end
end
if aD[az]then
af:Clean(u.Categories.Friends.ColorUpdate.Event:Connect(function()
aD[az](ah.Hue,ah.Sat,ah.Value)
end))
end
if aE[az]then
af:Clean(e.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
aE[az]()
end)))
end
else
if aB[az]then
for aG in ax do
aB[az](aG)
end
end
end
end,
Tooltip="Renders nametags on entities through walls.",
}
ag=af:CreateTargets{
Players=true,
Function=function()
if af.Enabled then
af:Toggle()
af:Toggle()
end
end,
}
ar=af:CreateFont{
Name="Font",
Blacklist="Arial",
Function=function()
if af.Enabled then
af:Toggle()
af:Toggle()
end
end,
}
ah=af:CreateColorSlider{
Name="Player Color",
Function=function(aF,aG,aH)
if af.Enabled and aD[az]then
aD[az](aF,aG,aH)
end
end,
}
aq=af:CreateSlider{
Name="Scale",
Function=function()
if af.Enabled then
af:Toggle()
af:Toggle()
end
end,
Default=1,
Min=0.1,
Max=1.5,
Decimal=10,
}
ai=af:CreateSlider{
Name="Transparency",
Function=function()
if af.Enabled then
af:Toggle()
af:Toggle()
end
end,
Default=0.5,
Min=0,
Max=1,
Decimal=10,
}
ak=af:CreateToggle{
Name="Health",
Function=function()
if af.Enabled then
af:Toggle()
af:Toggle()
end
end,
}
al=af:CreateToggle{
Name="Distance",
Function=function()
if af.Enabled then
af:Toggle()
af:Toggle()
end
end,
}
an=af:CreateToggle{
Name="Equipment",
Function=function()
if af.Enabled then
af:Toggle()
af:Toggle()
end
end,
}
ao=af:CreateToggle{
Name="Enchant",
Function=function()
if af.Enabled then
af:Toggle()
af:Toggle()
end
end,
}
aj=af:CreateToggle{
Name="Use Displayname",
Function=function()
if af.Enabled then
af:Toggle()
af:Toggle()
end
end,
Default=true,
}
as=af:CreateToggle{
Name="Priority Only",
Function=function()
if af.Enabled then
af:Toggle()
af:Toggle()
end
end,
Default=true,
}
ap=af:CreateToggle{
Name="Drawing",
Function=function()
if af.Enabled then
af:Toggle()
af:Toggle()
end
end,
}
at=af:CreateToggle{
Name="Distance Check",
Function=function(aF)
au.Object.Visible=aF
end,
}
au=af:CreateTwoSlider{
Name="Player Distance",
Min=0,
Max=256,
DefaultMin=0,
DefaultMax=64,
Darker=true,
Visible=false,
}
end)

b(function()
local af
local ag
local ah
local ai={}
local aj={}
local ak=Instance.new'Folder'
ak.Parent=u.gui

local function nearStorageItem(al)
for an,ao in ag.ListEnabled do
if al:find(ao)then return ao end
end
end

local function refreshAdornee(al)
local an=al.Adornee:FindFirstChild'ChestFolderValue'
an=an and an.Value or nil
if not an then
al.Enabled=false
return
end

local ao=an and an:GetChildren()or{}
for ap,aq in al.Frame:GetChildren()do
if aq:IsA'ImageLabel'and aq.Name~='Blur'then
aq:Destroy()
end
end

al.Enabled=false
local ap={}
for aq,ar in ao do
if not ap[ar.Name]and(table.find(ag.ListEnabled,ar.Name)or nearStorageItem(ar.Name))then
ap[ar.Name]=true
al.Enabled=true
local as=Instance.new'ImageLabel'
as.Size=UDim2.fromOffset(32,32)
as.BackgroundTransparency=1
as.Image=L.getIcon({itemType=ar.Name},true)
as.Parent=al.Frame
end
end
table.clear(ao)
end

local function Added(al)
local an=al:WaitForChild('ChestFolderValue',3)
if not(an and af.Enabled)then return end
an=an.Value
local ao=Instance.new'BillboardGui'
ao.Parent=ak
ao.Name='chest'
ao.StudsOffsetWorldSpace=Vector3.new(0,3,0)
ao.Size=UDim2.fromOffset(36,36)
ao.AlwaysOnTop=true
ao.ClipsDescendants=false
ao.Adornee=al
local ap=addBlur(ao)
ap.Visible=ah.Enabled
local aq=Instance.new'Frame'
aq.Size=UDim2.fromScale(1,1)
aq.BackgroundColor3=Color3.fromHSV(ai.Hue,ai.Sat,ai.Value)
aq.BackgroundTransparency=1-(ah.Enabled and ai.Opacity or 0)
aq.Parent=ao
local ar=Instance.new'UIListLayout'
ar.FillDirection=Enum.FillDirection.Horizontal
ar.Padding=UDim.new(0,4)
ar.VerticalAlignment=Enum.VerticalAlignment.Center
ar.HorizontalAlignment=Enum.HorizontalAlignment.Center
ar:GetPropertyChangedSignal'AbsoluteContentSize':Connect(function()
ao.Size=UDim2.fromOffset(math.max(ar.AbsoluteContentSize.X+4,36),36)
end)
ar.Parent=aq
local as=Instance.new'UICorner'
as.CornerRadius=UDim.new(0,4)
as.Parent=aq
aj[al]=ao
af:Clean(an.ChildAdded:Connect(function(at)
if table.find(ag.ListEnabled,at.Name)or nearStorageItem(at.Name)then
refreshAdornee(ao)
end
end))
af:Clean(an.ChildRemoved:Connect(function(at)
if table.find(ag.ListEnabled,at.Name)or nearStorageItem(at.Name)then
refreshAdornee(ao)
end
end))
task.spawn(refreshAdornee,ao)
end

af=u.Categories.Render:CreateModule{
Name='ChestESP',
Function=function(al)
if al then
af:Clean(o:GetInstanceAddedSignal'chest':Connect(Added))
for an,ao in o:GetTagged'chest'do
task.spawn(Added,ao)
end
else
table.clear(aj)
ak:ClearAllChildren()
end
end,
Tooltip='Displays items in chests'
}
ag=af:CreateTextList{
Name='Item',
Function=function()
for al,an in aj do
task.spawn(refreshAdornee,an)
end
end,
Default={"speed_potion"}
}
ah=af:CreateToggle{
Name='Background',
Function=function(al)
if ai.Object then ai.Object.Visible=al end
for an,ao in aj do
ao.Frame.BackgroundTransparency=1-(al and ai.Opacity or 0)
ao.Blur.Visible=al
end
end,
Default=true
}
ai=af:CreateColorSlider{
Name='Background Color',
DefaultValue=0,
DefaultOpacity=0.5,
Function=function(al,an,ao,ap)
for aq,ar in aj do
ar.Frame.BackgroundColor3=Color3.fromHSV(al,an,ao)
ar.Frame.BackgroundTransparency=1-ap
end
end,
Darker=true
}
end)

b(function()
local af

af=u.Categories.Utility:CreateModule{
Name='AutoBalloon',
Function=function(ag)
if ag then
repeat task.wait()until F.matchState~=0 or(not af.Enabled)
if not af.Enabled then return end

local ah=math.huge
for ai,aj in F.blocks do
local ak=(aj.Position.Y-(aj.Size.Y/2))-50
if ak<ah then
ah=ak
end
end

repeat
if x.isAlive then
if x.character.RootPart.Position.Y<ah and(s.Character:GetAttribute'InflatedBalloons'or 0)<3 then
local ai=getItem'balloon'
if ai then
for aj=1,3 do
L.BalloonController:inflateBalloon()
end
end
task.wait(0.1)
end
end
task.wait(0.1)
until not af.Enabled
end
end,
Tooltip='Inflates when you fall into the void'
}
end)

b(function()
local af
local ag
local ah={}

local function kitCollection(ai,aj,ak,al)
local an=type(ai)=='table'and ai or collection(ai,af)
repeat
if x.isAlive then
local ao=x.character.RootPart.Position
for ap,aq in an do
if I.Enabled or not af.Enabled then break end
local ar=not aq:IsA'Model'and aq or aq.PrimaryPart
if ar and(ar.Position-ao).Magnitude<=(not ag.Enabled and al and math.huge or ak)then
aj(aq)
end
end
end
task.wait(0.1)
until not af.Enabled
end

local ai={
battery=function()
repeat
if x.isAlive then
local ai=x.character.RootPart.Position
for aj,ak in L.BatteryEffectsController.liveBatteries do
if(ak.position-ai).Magnitude<=10 then
local al=L.BatteryEffectsController:getBatteryInfo(aj)
if not al or al.activateTime>=workspace:GetServerTimeNow()or al.consumeTime+0.1>=workspace:GetServerTimeNow()then continue end
al.consumeTime=workspace:GetServerTimeNow()
L.Client:Get(M.ConsumeBattery):SendToServer{batteryId=aj}
end
end
end
task.wait(0.1)
until not af.Enabled
end,
beekeeper=function()
kitCollection('bee',function(ai)
L.Client:Get(M.BeePickup):SendToServer{beeId=ai:GetAttribute'BeeId'}
end,18,false)
end,
bigman=function()
kitCollection('treeOrb',function(ai)
if L.Client:Get(M.ConsumeTreeOrb):CallServer{treeOrbSecret=ai:GetAttribute'TreeOrbSecret'}then
ai:Destroy()
end
end,12,false)
end,
block_kicker=function()
local ai=L.BlockKickerKitController.getKickBlockProjectileOriginPosition
L.BlockKickerKitController.getKickBlockProjectileOriginPosition=function(...)
local aj,ak=select(2,...)
local al=x.EntityMouse{
Part='RootPart',
Range=1000,
Origin=aj,
Players=true,
Wallcheck=true
}

if al then
local an=B.SolveTrajectory(aj,100,20,al.RootPart.Position,al.RootPart.Velocity,workspace.Gravity,al.HipHeight,al.Jumping and 42.6 or nil)

if an then
for ao,ap in debug.getstack(2)do
if ap==ak then
debug.setstack(2,ao,CFrame.lookAt(aj,an).LookVector)
end
end
end
end

return ai(...)
end

af:Clean(function()
L.BlockKickerKitController.getKickBlockProjectileOriginPosition=ai
end)
end,
cat=function()
local ai=L.CatController.leap
L.CatController.leap=function(...)
c.CatPounce:Fire()
return ai(...)
end

af:Clean(function()
L.CatController.leap=ai
end)
end,
davey=function()
local ai=L.CannonHandController.launchSelf
L.CannonHandController.launchSelf=function(...)
local aj={ai(...)}local
ak, al=...

if al:GetAttribute'PlacedByUserId'==s.UserId and(al.Position-x.character.RootPart.Position).Magnitude<30 then
task.spawn(L.breakBlock,al,false,nil,true)
end

return unpack(aj)
end

af:Clean(function()
L.CannonHandController.launchSelf=ai
end)
end,
dragon_slayer=function()
kitCollection('KaliyahPunchInteraction',function(ai)
L.DragonSlayerController:deleteEmblem(ai)
L.DragonSlayerController:playPunchAnimation(Vector3.zero)
L.Client:Get(M.KaliyahPunch):SendToServer{
target=ai
}
end,18,true)
end,
farmer_cletus=function()
kitCollection('HarvestableCrop',function(ai)
if L.Client:Get(M.HarvestCrop):CallServer{position=L.BlockController:getBlockPosition(ai.Position)}then
L.GameAnimationUtil:playAnimation(s.Character,L.AnimationType.PUNCH)
L.SoundManager:playSound(L.SoundList.CROP_HARVEST)
end
end,10,false)
end,
fisherman=function()
local ai=L.FishingMinigameController.startMinigame
L.FishingMinigameController.startMinigame=function(aj,ak,al,an)
ai(aj,ak,function()end,an)
task.wait(0.3)
al{win=true}
end

af:Clean(function()
L.FishingMinigameController.startMinigame=ai
end)
end,
gingerbread_man=function()
local ai=L.LaunchPadController.attemptLaunch
L.LaunchPadController.attemptLaunch=function(...)
local aj={ai(...)}
local ak,al=...

if(workspace:GetServerTimeNow()-ak.lastLaunch)<0.4 then
if al:GetAttribute'PlacedByUserId'==s.UserId and(al.Position-x.character.RootPart.Position).Magnitude<30 then
task.spawn(L.breakBlock,al,false,nil,true)
end
end

return unpack(aj)
end

af:Clean(function()
L.LaunchPadController.attemptLaunch=ai
end)
end,
hannah=function()
kitCollection('HannahExecuteInteraction',function(ai)
local aj=L.Client:Get(M.HannahKill):CallServer{
user=s,
victimEntity=ai
}and ai:FindFirstChild'Hannah Execution Icon'

if aj then
aj:Destroy()
end
end,30,true)
end,
jailor=function()
kitCollection('jailor_soul',function(ai)
L.JailorController:collectEntity(s,ai,'JailorSoul')
end,20,false)
end,
grim_reaper=function()
kitCollection(L.GrimReaperController.soulsByPosition,function(ai)
if x.isAlive and s.Character:GetAttribute'Health'<=(s.Character:GetAttribute'MaxHealth'/4)and(not s.Character:GetAttribute'GrimReaperChannel')then
L.Client:Get(M.ConsumeSoul):CallServer{
secret=ai:GetAttribute'GrimReaperSoulSecret'
}
end
end,120,false)
end,
melody=function()
repeat
local ai,aj,ak=30,math.huge
if x.isAlive then
local al=x.character.RootPart.Position
for an,ao in x.List do
if ao.Player and ao.Player:GetAttribute'Team'==s:GetAttribute'Team'then
local ap=(al-ao.RootPart.Position).Magnitude
if ap<=ai and ao.Health<aj and ao.Health<ao.MaxHealth then
ai,aj,ak=ap,ao.Health,ao
end
end
end
end

if ak and getItem'guitar'then
L.Client:Get(M.GuitarHeal):SendToServer{
healTarget=ak.Character
}
end

task.wait(0.1)
until not af.Enabled
end,
metal_detector=function()
kitCollection('hidden-metal',function(ai)
L.Client:Get(M.PickupMetal):SendToServer{
id=ai:GetAttribute'Id'
}
end,20,false)
end,
miner=function()
kitCollection('petrified-player',function(ai)
L.Client:Get(M.MinerDig):SendToServer{
petrifyId=ai:GetAttribute'PetrifyId'
}
end,6,true)
end,
pinata=function()
kitCollection(s.Name..':pinata',function(ai)
if getItem'candy'then
L.Client:Get(M.DepositPinata):CallServer(ai)
end
end,6,true)
end,
spirit_assassin=function()
kitCollection('EvelynnSoul',function(ai)
L.SpiritAssassinController:useSpirit(s,ai)
end,120,true)
end,
star_collector=function()
kitCollection('stars',function(ai)
L.StarCollectorController:collectEntity(s,ai,ai.Name)
end,20,false)
end,
summoner=function()
repeat
local ai=x.EntityPosition{
Range=31,
Part='RootPart',
Players=true,
Sort=V.Health
}

if ai and(not ag.Enabled or(s.Character:GetAttribute'Health'or 0)>0)then
local aj=x.character.RootPart.Position
local ak=CFrame.lookAt(aj,ai.RootPart.Position).LookVector
aj+=ak*math.max((aj-ai.RootPart.Position).Magnitude-16,0)

L.Client:Get(M.SummonerClawAttack):SendToServer{
position=aj,
direction=ak,
clientTime=workspace:GetServerTimeNow()
}
end

task.wait(0.1)
until not af.Enabled
end,
void_dragon=function()
local ai=L.VoidDragonController.flapWings
local aj

L.VoidDragonController.flapWings=function(ak)
if not aj and L.Client:Get(M.DragonFly):CallServer()then
local al=L.SprintController:getMovementStatusModifier():addModifier{
blockSprint=true,
constantSpeedMultiplier=2
}
ak.SpeedMaid:GiveTask(al)
ak.SpeedMaid:GiveTask(function()
aj=false
end)
aj=true
end
end

af:Clean(function()
L.VoidDragonController.flapWings=ai
end)

repeat
if L.VoidDragonController.inDragonForm then
local ak=x.EntityPosition{
Range=30,
Part='RootPart',
Players=true
}

if ak then
L.Client:Get(M.DragonBreath):SendToServer{
player=s,
targetPoint=ak.RootPart.Position
}
end
end
task.wait(0.1)
until not af.Enabled
end,
warlock=function()
local ai
repeat
if F.hand.tool and F.hand.tool.Name=='warlock_staff'then
local aj=x.EntityPosition{
Range=30,
Part='RootPart',
Players=true,
NPCs=true
}

if aj and aj.Character~=ai then
if not L.Client:Get(M.WarlockTarget):CallServer{
target=aj.Character
}then
aj=nil
end
end

ai=aj and aj.Character
else
ai=nil
end

task.wait(0.1)
until not af.Enabled
end,
wizard=function()
repeat
local ai=s:GetAttribute'WizardAbility'
if ai and L.AbilityController:canUseAbility(ai)then
local aj=x.EntityPosition{
Range=50,
Part='RootPart',
Players=true,
Sort=V.Health
}

if aj then
L.AbilityController:useAbility(ai,newproxy(true),{target=aj.RootPart.Position})
end
end

task.wait(0.1)
until not af.Enabled
end
}

af=u.Categories.Utility:CreateModule{
Name='AutoKit',
Function=function(aj)
if aj then
repeat task.wait()until F.equippedKit~=''and F.matchState~=0 or(not af.Enabled)
for ak,al in{
wizard="AutoZeno",
fisherman="AutoFish",
metal_detector="AutoMetal"
}do
if af.Enabled and F.equippedKit==ak and u.Modules[al]and u.Modules[al].Enabled then
warningNotification("AutoKit",`Disabled {tostring(al)} to prevent breaking logic`,3)
pcall(function()
u.Modules[al]:Toggle()
end)
end
end
if af.Enabled and ai[F.equippedKit]and ah[F.equippedKit].Enabled then
ai[F.equippedKit]()
end
end
end,
Tooltip='Automatically uses kit abilities.'
}
ag=af:CreateToggle{Name='Legit Range'}
local aj={}
for ak in ai do
table.insert(aj,ak)
end
table.sort(aj,function(ak,al)
return(L.BedwarsKitMeta[ak]and L.BedwarsKitMeta[ak].name or'')<(L.BedwarsKitMeta[al]and L.BedwarsKitMeta[al].name or'')
end)
for ak,al in aj do
ah[al]=af:CreateToggle{
Name=(L.BedwarsKitMeta[al]and L.BedwarsKitMeta[al].name or tostring(al)),
Default=true
}
end
end)

b(function()
local af
local ag=RaycastParams.new()
ag.RespectCanCollide=true
local ah={InvokeServer=function()end}
task.spawn(function()
ah=L.Client:Get(M.FireProjectile).instance
end)

local function firePearl(ai,aj,ak)
switchItem(ak.tool)
local al=L.ProjectileMeta.telepearl
local an=B.SolveTrajectory(ai,al.launchVelocity,al.gravitationalAcceleration,aj,Vector3.zero,workspace.Gravity,0,0)

if an then
local ao=CFrame.lookAt(ai,an).LookVector*al.launchVelocity
L.ProjectileController:createLocalProjectile(al,'telepearl','telepearl',ai,nil,ao,{drawDurationSeconds=1})
ah:InvokeServer(ak.tool,'telepearl','telepearl',ai,ai,ao,i:GenerateGUID(true),{drawDurationSeconds=1,shotId=i:GenerateGUID(false)},workspace:GetServerTimeNow()-0.045)
end

if F.hand then
switchItem(F.hand.tool)
end
end

af=u.Categories.Utility:CreateModule{
Name='AutoPearl',
Function=function(ai)
if ai then
local aj
repeat
if x.isAlive then
local ak=x.character.RootPart
local al=getItem'telepearl'
ag.FilterDescendantsInstances={s.Character,r,K}
ag.CollisionGroup=ak.CollisionGroup

if al and ak.Velocity.Y<-100 and not blocksRaycast(200)then

if not aj then
aj=true
local an=getNearGround(20)

if an then
firePearl(ak.Position,an,al)
end
end
else
aj=false
end
end
task.wait(0.1)
until not af.Enabled
end
end,
Tooltip='Automatically throws a pearl onto nearby ground after\nfalling a certain distance.'
}
end)

b(function()
local af
local ag

local function isEveryoneDead()
return#L.Store:getState().Party.members<=0
end

local ah=false
local function joinQueue()
if not L.Store:getState().Game.customMatch and L.Store:getState().Party.leader.userId==s.UserId and L.Store:getState().Party.queueState==0 then
if ah then
return
end
local ai=F.queueType
if ag.Enabled then
local aj={}
for ak,al in L.QueueMeta do
if not al.disabled and not al.voiceChatOnly and not al.rankCategory then
table.insert(aj,ak)
end
end
ai=aj[math.random(1,#aj)]
end
if not ai then
ai=F.queueType
end
local aj=ai
local ak=L.QueueMeta[ai]
if ak and ak.title then
aj=tostring(ak.title)
end
ah=true
InfoNotification("AutoQueue",`Joining queue for {tostring(aj)}...`,3)
L.QueueController:joinQueue(ai)
end
end

af=u.Categories.Utility:CreateModule{
Name='AutoQueue',
Function=function(ai)
ah=false
if ai then
af:Clean(c.EntityDeathEvent.Event:Connect(function(aj)
if aj.finalKill and aj.entityInstance==s.Character and isEveryoneDead()and F.matchState~=2 then
joinQueue()
end
end))
af:Clean(c.MatchEndEvent.Event:Connect(joinQueue))
end
end,
Tooltip='Automatically queues after the match ends.'
}
ag=af:CreateToggle{
Name='Random',
Tooltip='Chooses a random mode'
}
end)

b(function()
local af,ag=false

local function getCrossbows()
local ah={}
for ai,aj in F.inventory.hotbar do
if aj.item and aj.item.itemType:find'crossbow'and ai~=(F.inventory.hotbarSlot+1)then table.insert(ah,ai-1)end
end
return ah
end

u.Categories.Utility:CreateModule{
Name='AutoShoot',
Function=function(ah)
if ah then
ag=L.ProjectileController.createLocalProjectile
L.ProjectileController.createLocalProjectile=function(...)local
ai, aj, ak=...
if ai and(ak=='arrow'or ak=='fireball')and not af then
task.spawn(function()
local al=getCrossbows()
if#al>0 then
af=true
task.wait(0.15)
local an=F.inventory.hotbarSlot
for ao,ap in getCrossbows()do
if hotbarSwitch(ap)then
task.wait(0.05)
mouse1click()
task.wait(0.05)
end
end
hotbarSwitch(an)
af=false
end
end)
end
return ag(...)
end
else
L.ProjectileController.createLocalProjectile=ag
end
end,
Tooltip='Automatically crossbow macro\'s'
}

end)

b(function()
local af
local ag
local ah,ai,aj,ak={},{},{}

local function sendMessage(al,an,ao)
local ap=ai[al].ListEnabled
local aq=#ap>0 and ap[math.random(1,#ap)]or ao
if not aq then return end
if#ap>1 and aq==aj[al]then
repeat
task.wait()
aq=ap[math.random(1,#ap)]
until aq~=aj[al]
end
aj[al]=aq

aq=aq and aq:gsub('<obj>',an or'')or''
if l.ChatVersion==Enum.ChatVersion.TextChatService then
l.ChatInputBarConfiguration.TargetTextChannel:SendAsync(aq)
else
n.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(aq,'All')
end
end

af=u.Categories.Utility:CreateModule{
Name='AutoToxic',
Function=function(al)
if al then
af:Clean(c.BedwarsBedBreak.Event:Connect(function(an)
if ah.BedDestroyed.Enabled and an.brokenBedTeam.id==s:GetAttribute'Team'then
sendMessage('BedDestroyed',(an.player.DisplayName or an.player.Name),'how dare you >:( | <obj>')
elseif ah.Bed.Enabled and an.player.UserId==s.UserId then
local ao=L.QueueMeta[F.queueType].teams[tonumber(an.brokenBedTeam.id)]
sendMessage('Bed',ao and ao.displayName:lower()or'white','nice bed lul | <obj>')
end
end))
af:Clean(c.EntityDeathEvent.Event:Connect(function(an)
if an.finalKill then
local ao=h:GetPlayerFromCharacter(an.fromEntity)
local ap=h:GetPlayerFromCharacter(an.entityInstance)
if not ap or not ao then return end
if ap==s then
if(not ak)and ao~=s and ah.Death.Enabled then
ak=true
sendMessage('Death',(ao.DisplayName or ao.Name),'my gaming chair subscription expired :( | <obj>')
end
elseif ao==s and ah.Kill.Enabled then
sendMessage('Kill',(ap.DisplayName or ap.Name),'vxp on top | <obj>')
end
end
end))
af:Clean(c.MatchEndEvent.Event:Connect(function(an)
if ag.Enabled then
if l.ChatVersion==Enum.ChatVersion.TextChatService then
l.ChatInputBarConfiguration.TargetTextChannel:SendAsync'gg'
else
n.DefaultChatSystemChatEvents.SayMessageRequest:FireServer('gg','All')
end
end

local ao=L.Store:getState().Game.myTeam
if ao and ao.id==an.winningTeamId or s.Neutral then
if ah.Win.Enabled then
sendMessage('Win',nil,'yall garbage')
end
end
end))
end
end,
Tooltip='Says a message after a certain action'
}
ag=af:CreateToggle{
Name='AutoGG',
Default=true
}
for al,an in{'Kill','Death','Bed','BedDestroyed','Win'}do
ah[an]=af:CreateToggle{
Name=an..' ',
Function=function(ao)
if ai[an]then
ai[an].Object.Visible=ao
end
end
}
ai[an]=af:CreateTextList{
Name=an,
Darker=true,
Visible=false
}
end
end)

b(function()
local af
local ag

af=u.Categories.Utility:CreateModule{
Name='AutoVoidDrop',
Function=function(ah)
if ah then
repeat task.wait()until F.matchState~=0 or(not af.Enabled)
if not af.Enabled then return end

local ai=math.huge
for aj,ak in F.blocks do
local al=(ak.Position.Y-(ak.Size.Y/2))-50
if al<ai then
ai=al
end
end

repeat
if x.isAlive then
local aj=x.character.RootPart
if aj.Position.Y<ai and(s.Character:GetAttribute'InflatedBalloons'or 0)<=0 and not getItem'balloon'then
if not ag.Enabled or not aj:FindFirstChild'OwlLiftForce'then
for ak,al in{'iron','diamond','emerald','gold'}do
al=getItem(al)
if al then
al=L.Client:Get(M.DropItem):CallServer{
item=al.tool,
amount=al.amount
}

if al then
al:SetAttribute('ClientDropTime',tick()+100)
end
end
end
end
end
end

task.wait(0.1)
until not af.Enabled
end
end,
Tooltip='Drops resources when you fall into the void'
}
ag=af:CreateToggle{
Name='Owl check',
Default=true,
Tooltip='Refuses to drop items if being picked up by an owl'
}
end)

b(function()
local af

af=u.Categories.Utility:CreateModule{
Name='MissileTP',
Function=function(ag)
if ag then
af:Toggle()
local ah=x.EntityMouse{
Range=1000,
Players=true,
Part='RootPart'
}

if getItem'guided_missile'and ah then
local ai=L.RuntimeLib.await(L.GuidedProjectileController.fireGuidedProjectile:CallServerAsync'guided_missile')
if ai then
local aj=ai.model
if not aj.PrimaryPart then
aj:GetPropertyChangedSignal'PrimaryPart':Wait()
end

local ak=Instance.new'BodyForce'
ak.Force=Vector3.new(0,aj.PrimaryPart.AssemblyMass*workspace.Gravity,0)
ak.Name='AntiGravity'
ak.Parent=aj.PrimaryPart

repeat
ai.model:SetPrimaryPartCFrame(CFrame.lookAlong(ah.RootPart.CFrame.p,r.CFrame.LookVector))
task.wait(0.1)
until not ai.model or not ai.model.Parent
else
notif('MissileTP','Missile on cooldown.',3)
end
end
end
end,
Tooltip='Spawns and teleports a missile to a player\nnear your mouse.'
}
end)

b(function()
local af
local ag
local ah
local ai

af=u.Categories.Utility:CreateModule{
Name='PickupRange',
Function=function(aj)
if aj then
local ak=collection('ItemDrop',af)
repeat
if x.isAlive then
local al=x.character.RootPart.Position
for an,ao in ak do
if tick()-(ao:GetAttribute'ClientDropTime'or 0)<2 then continue end
if q(ao)and ah.Enabled and x.character.Humanoid.Health>0 then
ao.CFrame=CFrame.new(al-Vector3.new(0,3,0))
end

if(al-ao.Position).Magnitude<=ag.Value then
if ai.Enabled and(al.Y-ao.Position.Y)<(x.character.HipHeight-1)then continue end
task.spawn(function()
L.Client:Get(M.PickupItem):CallServerAsync{
itemDrop=ao
}:andThen(function(ap)
if ap and L.SoundList then
L.SoundManager:playSound(L.SoundList.PICKUP_ITEM_DROP)
local aq=L.ItemMeta[ao.Name].pickUpOverlaySound
if aq then
L.SoundManager:playSound(aq,{
position=ao.Position,
volumeMultiplier=0.9
})
end
end
end)
end)
end
end
end
task.wait(0.1)
until not af.Enabled
end
end,
Tooltip='Picks up items from a farther distance'
}
ag=af:CreateSlider{
Name='Range',
Min=1,
Max=10,
Default=10,
Suffix=function(aj)
return aj==1 and'stud'or'studs'
end
}




ah={Enabled=false}
ai=af:CreateToggle{Name='Feet Check'}
end)

b(function()
local af

af=u.Categories.Utility:CreateModule{
Name='RavenTP',
Function=function(ag)
if ag then
af:Toggle()
local ah=x.EntityMouse{
Range=1000,
Players=true,
Part='RootPart'
}

if getItem'raven'and ah then
L.Client:Get(M.SpawnRaven):CallServerAsync():andThen(function(ai)
if ai then
local aj=Instance.new'BodyForce'
aj.Force=Vector3.new(0,ai.PrimaryPart.AssemblyMass*workspace.Gravity,0)
aj.Parent=ai.PrimaryPart

if ah then
task.spawn(function()
for ak=1,20 do
if ah.RootPart and ai then
ai:SetPrimaryPartCFrame(CFrame.lookAlong(ah.RootPart.Position,r.CFrame.LookVector))
end
task.wait(0.05)
end
end)
task.wait(0.3)
L.RavenController:detonateRaven()
end
end
end)
end
end
end,
Tooltip='Spawns and teleports a raven to a player\nnear your mouse.'
}
end)

b(function()
local af
local ag
local ah
local ai
local aj
local ak
local al
local an,ao,ap={},Vector3.zero

for aq=-3,3,3 do
for ar=-3,3,3 do
for as=-3,3,3 do
local at=Vector3.new(aq,ar,as)
if at~=Vector3.zero then
table.insert(an,at)
end
end
end
end

local function nearCorner(aq,ar)
local as=aq-Vector3.new(3,3,3)
local at=aq+Vector3.new(3,3,3)
local au=aq+(ar-aq).Unit*100
return Vector3.new(math.clamp(au.X,as.X,at.X),math.clamp(au.Y,as.Y,at.Y),math.clamp(au.Z,as.Z,at.Z))
end

local function blockProximity(aq)
local ar,as=60
local at=getBlocksInPoints(L.BlockController:getBlockPosition(aq-Vector3.new(21,21,21)),L.BlockController:getBlockPosition(aq+Vector3.new(21,21,21)))
for au,av in at do
local aw=nearCorner(av,aq)
local ax=(aq-aw).Magnitude
if ax<ar then
ar,as=ax,aw
end
end
table.clear(at)
return as
end

local function checkAdjacent(aq)
for ar,as in an do
if getPlacedBlock(aq+as)then
return true
end
end
return false
end

local function getScaffoldBlock()
if F.hand.toolType=='block'then
return F.hand.tool.Name,F.hand.amount
elseif(not ak.Enabled)then
local aq,ar=getWool()
if aq then
return aq,ar
else
for as,at in F.inventory.inventory.items do
if L.ItemMeta[at.itemType].block then
return at.itemType,at.amount
end
end
end
end

return nil,0
end

af=u.Categories.Utility:CreateModule{
Name='Scaffold',
Function=function(aq)
if ap then
ap.Visible=aq
end

if aq then
repeat
if x.isAlive then
local ar,as=getScaffoldBlock()

if al.Enabled then
if not k:IsMouseButtonPressed(0)then
ar=nil
end
end

if ap then
as=as or 0
ap.Text=as..' <font color="rgb(170, 170, 170)">(Scaffold)</font>'
ap.TextColor3=Color3.fromHSV((as/128)/2.8,0.86,1)
end

if ar then
local at=x.character.RootPart
if ah.Enabled and k:IsKeyDown(Enum.KeyCode.Space)and(not k:GetFocusedTextBox())then
at.Velocity=Vector3.new(at.Velocity.X,38,at.Velocity.Z)
end

for au=ag.Value,1,-1 do
local av=roundPos(at.Position-Vector3.new(0,x.character.HipHeight+(ai.Enabled and k:IsKeyDown(Enum.KeyCode.LeftShift)and 4.5 or 1.5),0)+x.character.Humanoid.MoveDirection*(au*3))
if aj.Enabled then
if math.abs(math.round(math.deg(math.atan2(-x.character.Humanoid.MoveDirection.X,-x.character.Humanoid.MoveDirection.Z))/45)*45)%90==45 then
local aw=(ao-av)
if((aw.X==0 and aw.Z~=0)or(aw.X~=0 and aw.Z==0))and((ao-at.Position)*Vector3.new(1,0,1)).Magnitude<2.5 then
av=ao
end
end
end

local aw,ax=getPlacedBlock(av)
if not aw then
ax=checkAdjacent(ax*3)and ax*3 or blockProximity(av)
if ax then
task.spawn(L.placeBlock,ax,ar,false)
end
end
ao=av
end
end
end

task.wait(0.03)
until not af.Enabled
else
Label=nil
end
end,
Tooltip='Helps you make bridges/scaffold walk.'
}
ag=af:CreateSlider{
Name='Expand',
Min=1,
Max=6
}
ah=af:CreateToggle{
Name='Tower',
Default=true
}
ai=af:CreateToggle{
Name='Downwards',
Default=true
}
aj=af:CreateToggle{
Name='Diagonal',
Default=true
}
ak=af:CreateToggle{Name='Limit to items'}
al=af:CreateToggle{Name='Require mouse down'}
Count=af:CreateToggle{
Name='Block Count',
Function=function(aq)
if aq then
ap=Instance.new'TextLabel'
ap.Size=UDim2.fromOffset(100,20)
ap.Position=UDim2.new(0.5,6,0.5,60)
ap.BackgroundTransparency=1
ap.AnchorPoint=Vector2.new(0.5,0)
ap.Text='0'
ap.TextColor3=Color3.new(0,1,0)
ap.TextSize=18
ap.RichText=true
ap.Font=Enum.Font.Arial
ap.Visible=af.Enabled
ap.Parent=u.gui
else
ap:Destroy()
ap=nil
end
end
}
end)

b(function()
local af
local ag,ah={},{}

af=u.Categories.Utility:CreateModule{
Name='ShopTierBypass',
Function=function(ai)
if ai then
repeat task.wait()until F.shopLoaded or not af.Enabled
if af.Enabled then
for aj,ak in L.Shop.ShopItems do
ag[ak]=ak.tiered
ah[ak]=ak.nextTier
ak.nextTier=nil
ak.tiered=nil
end
end
else
for aj,ak in ag do
aj.tiered=ak
end
for aj,ak in ah do
aj.nextTier=ak
end
table.clear(ah)
table.clear(ag)
end
end,
Tooltip='Lets you buy things like armor early.'
}
end)

b(function()
local af
local ag
local ah
local ai
local aj
local ak
local al={'gg','gg2','DV','DV2'}
local an={1502104539,3826146717,4531785383,1049767300,4926350670,653085195,184655415,2752307430,5087196317,5744061325,1536265275}
local ao={}

local function getRole(ap,aq)
local ar,as=pcall(function()
return ap:GetRankInGroup(aq)
end)
if not ar then
notif('StaffDetector',as,30,'alert')
end
return ar and as or 0
end

local function staffFunction(ap,aq)
if not u.Loaded then
repeat task.wait()until u.Loaded
end

notif('StaffDetector','Staff Detected ('..aq..'): '..ap.Name..' ('..ap.UserId..')',60,'alert')
z.customtags[ap.Name]={{text='GAME STAFF',color=Color3.new(1,0,0)}}

if ai.Enabled and not aq:find'clan'then
L.PartyController:leaveParty()
end

if ag.Value=='Uninject'then
task.spawn(function()
u:Uninject()
end)
game:GetService'StarterGui':SetCore('SendNotification',{
Title='StaffDetector',
Text='Staff Detected ('..aq..')\n'..ap.Name..' ('..ap.UserId..')',
Duration=60,
})
elseif ag.Value=='Requeue'then
L.QueueController:joinQueue(F.queueType)
elseif ag.Value=='Profile'then
u.Save=function()end
if u.Profile~=aj.Value then
u:Load(true,aj.Value)
end
elseif ag.Value=='AutoConfig'then
local ar={'AutoClicker','Reach','Sprint','HitFix','StaffDetector'}
u.Save=function()end
for as,at in u.Modules do
if not(table.find(ar,as)or at.Category=='Render')then
if at.Enabled then
at:Toggle()
end
at:SetBind''
end
end
end
end

local function checkFriends(ap)
for aq,ar in ap do
if ao[ar]then
return ao[ar]
end
end
return nil
end

local function checkJoin(ap,aq)
if not ap:GetAttribute'Team'and ap:GetAttribute'Spectator'and not L.Store:getState().Game.customMatch then
aq:Disconnect()
local ar,as={},h:GetFriendsAsync(ap.UserId)
for at=1,4 do
for au,av in as:GetCurrentPage()do
table.insert(ar,av.Id)
end
if as.IsFinished then break end
as:AdvanceToNextPageAsync()
end

local at=checkFriends(ar)
if not at then
staffFunction(ap,'impossible_join')
return true
else
notif('StaffDetector',string.format('Spectator %s joined from %s',ap.Name,at),20,'warning')
end
end
end

local function playerAdded(ap)
ao[ap.UserId]=ap.Name
if ap==s then return end

if table.find(an,ap.UserId)or table.find(ak.ListEnabled,tostring(ap.UserId))then
staffFunction(ap,'blacklisted_user')
elseif getRole(ap,5774246)>=100 then
staffFunction(ap,'staff_role')
else
local aq
aq=ap:GetAttributeChangedSignal'Spectator':Connect(function()
checkJoin(ap,aq)
end)
af:Clean(aq)
if checkJoin(ap,aq)then
return
end

if not ap:GetAttribute'ClanTag'then
ap:GetAttributeChangedSignal'ClanTag':Wait()
end

if table.find(al,ap:GetAttribute'ClanTag')and u.Loaded and ah.Enabled then
aq:Disconnect()
staffFunction(ap,'blacklisted_clan_'..ap:GetAttribute'ClanTag':lower())
end
end
end

af=u.Categories.Utility:CreateModule{
Name='StaffDetector',
Function=function(ap)
if ap then
af:Clean(h.PlayerAdded:Connect(playerAdded))
for aq,ar in h:GetPlayers()do
task.spawn(playerAdded,ar)
end
else
table.clear(ao)
end
end,
Tooltip='Detects people with a staff rank ingame'
}
ag=af:CreateDropdown{
Name='Mode',
List={'Uninject','Profile','Requeue','AutoConfig','Notify'},
Function=function(ap)
if aj.Object then
aj.Object.Visible=ap=='Profile'
end
end
}
ah=af:CreateToggle{
Name='Blacklist clans',
Default=true
}
ai=af:CreateToggle{
Name='Leave party'
}
aj=af:CreateTextBox{
Name='Profile',
Default='default',
Darker=true,
Visible=false
}
ak=af:CreateTextList{
Name='Users',
Placeholder='player (userid)'
}

task.spawn(function()
repeat task.wait(1)until u.Loaded or u.Loaded==nil
if u.Loaded and not af.Enabled then
af:Toggle()
end
end)
end)

b(function()
J=u.Categories.Utility:CreateModule{
Name='TrapDisabler',
Tooltip='Disables Snap Traps'
}
end)

b(function()
u.Categories.World:CreateModule{
Name='Anti-AFK',
Function=function(af)
if af then
for ag,ah in getconnections(s.Idled)do
ah:Disconnect()
end

for ag,ah in getconnections(e.Heartbeat)do
if type(ah.Function)=='function'and table.find(debug.getconstants(ah.Function),M.AfkStatus)then
ah:Disconnect()
end
end

L.Client:Get(M.AfkStatus):SendToServer{
afk=false
}
end
end,
Tooltip='Lets you stay ingame without getting kicked'
}
end)

b(function()
local af
local ag
local ah

local function fixPosition(ai)
return L.BlockController:getBlockPosition(ai)*3
end

af=u.Categories.World:CreateModule{
Name='AutoSuffocate',
Function=function(ai)
if ai then
repeat
local aj=F.hand.toolType=='block'and F.hand.tool.Name or not ah.Enabled and getWool()

if aj then
local ak=x.AllPosition{
Part='RootPart',
Range=ag.Value,
Players=true
}

for al,an in ak do
local ao={}

for ap,aq in Enum.NormalId:GetEnumItems()do
aq=Vector3.fromNormalId(aq)
if aq.Y~=0 then continue end

aq=fixPosition(an.RootPart.Position+aq*2)
if not getPlacedBlock(aq)then
table.insert(ao,aq)
end
end

if#ao<3 then
table.insert(ao,fixPosition(an.Head.Position))
table.insert(ao,fixPosition(an.RootPart.Position-Vector3.new(0,1,0)))

for ap,aq in ao do
if not getPlacedBlock(aq)then
task.spawn(L.placeBlock,aq,aj)
break
end
end
end
end
end

task.wait(0.09)
until not af.Enabled
end
end,
Tooltip='Places blocks on nearby confined entities'
}
ag=af:CreateSlider{
Name='Range',
Min=1,
Max=20,
Default=20,
Suffix=function(ai)
return ai==1 and'stud'or'studs'
end
}
ah=af:CreateToggle{
Name='Limit to Items',
Default=true
}
end)

b(function()
local af
local ag,ah

local function switchHotbarItem(ai)
if ai and not ai:GetAttribute'NoBreak'and not ai:GetAttribute('Team'..(s:GetAttribute'Team'or 0)..'NoBreak')then
local aj,ak=(F.tools[L.ItemMeta[ai.Name].block.breakType])
if aj then
for al,an in F.inventory.hotbar do
if an.item and an.item.itemType==aj.itemType then ak=al-1 break end
end

if hotbarSwitch(ak)then
if k:IsMouseButtonPressed(0)then
ah:Fire()
end
return true
end
end
end
end

af=u.Categories.World:CreateModule{
Name='AutoTool',
Function=function(ai)
if ai then
ah=Instance.new'BindableEvent'
af:Clean(ah)
af:Clean(ah.Event:Connect(function()
p:CallFunction('block-break',Enum.UserInputState.Begin,newproxy(true))
end))
ag=L.BlockBreaker.hitBlock
L.BlockBreaker.hitBlock=function(aj,ak,al,...)
local an=aj.clientManager:getBlockSelector():getMouseInfo(1,{ray=al})
if switchHotbarItem(an and an.target and an.target.blockInstance or nil)then return end
return ag(aj,ak,al,...)
end
else
L.BlockBreaker.hitBlock=ag
ag=nil
end
end,
Tooltip='Automatically selects the correct tool'
}
end)

b(function()
local af

local function getBedNear()
local ag=x.isAlive and x.character.RootPart.Position or Vector3.zero
for ah,ai in o:GetTagged'bed'do
if(ag-ai.Position).Magnitude<20 and ai:GetAttribute('Team'..(s:GetAttribute'Team'or-1)..'NoBreak')then
return ai
end
end
end

local function getBlocks()
local ag={}
for ah,ai in F.inventory.inventory.items do
local aj=L.ItemMeta[ai.itemType].block
if aj then
table.insert(ag,{ai.itemType,aj.health})
end
end
table.sort(ag,function(ah,ai)
return ah[2]>ai[2]
end)
return ag
end

local function getPyramid(ag,ah)
local ai={}
for aj=ag,0,-1 do
for ak=aj,0,-1 do
table.insert(ai,Vector3.new(ak,(ag-aj),((aj+1)-ak))*ah)
table.insert(ai,Vector3.new(ak*-1,(ag-aj),((aj+1)-ak))*ah)
table.insert(ai,Vector3.new(ak,(ag-aj),(aj-ak)*-1)*ah)
table.insert(ai,Vector3.new(ak*-1,(ag-aj),(aj-ak)*-1)*ah)
end
end
return ai
end

af=u.Categories.World:CreateModule{
Name='BedProtector',
Function=function(ag)
if ag then
local ah=getBedNear()
ah=ah and ah.Position or nil
if ah then
for ai,aj in getBlocks()do
for ak,al in getPyramid(ai,3)do
if not af.Enabled then break end
if getPlacedBlock(ah+al)then continue end
L.placeBlock(ah+al,aj[1],false)
end
end
if af.Enabled then
af:Toggle()
end
else
notif('BedProtector','Unable to locate bed',5)
af:Toggle()
end
end
end,
Tooltip='Automatically places strong blocks around the bed.'
}
end)

b(function()
local af
local ag
local ah
local ai
local aj,ak,al={},{},{}
local an,ao

for ap=-3,3,3 do
for aq=-3,3,3 do
for ar=-3,3,3 do
if Vector3.new(ap,aq,ar)~=Vector3.zero then
table.insert(al,Vector3.new(ap,aq,ar))
end
end
end
end

local function checkAdjacent(ap)
for aq,ar in al do
if getPlacedBlock(ap+ar)then return true end
end
return false
end

local function getPlacedBlocksInPoints(ap,aq)
local ar,as={},L.BlockController:getStore()
for at=(aq.X>ap.X and ap.X or aq.X),(aq.X>ap.X and aq.X or ap.X)do
for au=(aq.Y>ap.Y and ap.Y or aq.Y),(aq.Y>ap.Y and aq.Y or ap.Y)do
for av=(aq.Z>ap.Z and ap.Z or aq.Z),(aq.Z>ap.Z and aq.Z or ap.Z)do
local aw=Vector3.new(at,au,av)
local ax=as:getBlockAt(aw)
if ax and ax:GetAttribute'PlacedByUserId'==s.UserId then
ar[aw]=ax
end
end
end
end
return ar
end

local function loadMaterials()
for ap,aq in ak do
aq:Destroy()
end
local ap,aq=pcall(function()
return isfile(ag.Value)and i:JSONDecode(readfile(ag.Value))
end)

if ap and aq then
local ar={}
for as,at in aq do
ar[at[2] ]=(ar[at[2] ]or 0)+1
end

for as,at in ar do
local au=Instance.new'Frame'
au.Size=UDim2.new(1,0,0,32)
au.BackgroundTransparency=1
au.Parent=af.Children
local av=Instance.new'ImageLabel'
av.Size=UDim2.fromOffset(24,24)
av.Position=UDim2.fromOffset(4,4)
av.BackgroundTransparency=1
av.Image=L.getIcon({itemType=as},true)
av.Parent=au
local aw=Instance.new'TextLabel'
aw.Size=UDim2.fromOffset(100,32)
aw.Position=UDim2.fromOffset(32,0)
aw.BackgroundTransparency=1
aw.Text=(L.ItemMeta[as]and L.ItemMeta[as].displayName or as)..': '..at
aw.TextXAlignment=Enum.TextXAlignment.Left
aw.TextColor3=y.Text
aw.TextSize=14
aw.FontFace=y.Font
aw.Parent=au
table.insert(ak,au)
end
table.clear(aq)
table.clear(ar)
end
end

local function save()
if an and ao then
local ap=getPlacedBlocksInPoints(an,ao)
local aq={}
an=an*3
for ar,as in ap do
ar=L.BlockController:getBlockPosition(CFrame.lookAlong(an,x.character.RootPart.CFrame.LookVector):PointToObjectSpace(ar*3))*3
table.insert(aq,{
{
x=ar.X,
y=ar.Y,
z=ar.Z
},
as.Name
})
end
an,ao=nil,nil
writefile(ag.Value,i:JSONEncode(aq))
notif('Schematica','Saved '..getTableSize(ap)..' blocks',5)
loadMaterials()
table.clear(ap)
table.clear(aq)
else
local ap=L.BlockBreaker.clientManager:getBlockSelector():getMouseInfo(0)
if ap and ap.target then
if an then
ao=ap.target.blockRef.blockPosition
notif('Schematica','Selected position 2, toggle again near position 1 to save it',3)
else
an=ap.target.blockRef.blockPosition
notif('Schematica','Selected position 1',3)
end
end
end
end

local function load(ap)
local aq=L.BlockBreaker.clientManager:getBlockSelector():getMouseInfo(0)
if aq and aq.target then
local ar=CFrame.new(aq.placementPosition*3)*CFrame.Angles(0,math.rad(math.round(math.deg(math.atan2(-x.character.RootPart.CFrame.LookVector.X,-x.character.RootPart.CFrame.LookVector.Z))/45)*45),0)

for as,at in ap do
local au=L.BlockController:getBlockPosition((ar*CFrame.new(at[1].x,at[1].y,at[1].z)).p)*3
if aj[au]then continue end
local av=L.BlockController:getHandlerRegistry():getHandler(at[2]:find'wool'and getWool()or at[2])
if av then
local aw=av:place(au/3,0)
aw.Transparency=ai.Value
aw.CanCollide=false
aw.Anchored=true
aw.Parent=workspace
aj[au]=aw
end
end
table.clear(ap)

repeat
if x.isAlive then
local as=x.character.RootPart.Position
for at,au in aj do
if(at-as).Magnitude<60 and checkAdjacent(at)then
if not af.Enabled then break end
if not getItem(au.Name)then continue end
L.placeBlock(at,au.Name,false)
task.delay(0.1,function()
local av=getPlacedBlock(at)
if av then
au:Destroy()
aj[at]=nil
end
end)
end
end
end
task.wait()
until getTableSize(aj)<=0

if getTableSize(aj)<=0 and af.Enabled then
notif('Schematica','Finished building',5)
af:Toggle()
end
end
end

af=u.Categories.World:CreateModule{
Name='Schematica',
Function=function(ap)
if ap then
if not ag.Value:find'.json'then
notif('Schematica','Invalid file',3)
af:Toggle()
return
end

if ah.Value=='Save'then
save()
af:Toggle()
else
local aq,ar=pcall(function()
return isfile(ag.Value)and i:JSONDecode(readfile(ag.Value))
end)

if aq and ar then
load(ar)
else
notif('Schematica','Missing / corrupted file',3)
af:Toggle()
end
end
else
for aq,ar in aj do
ar:Destroy()
end
table.clear(aj)
end
end,
Tooltip='Save and load placements of buildings'
}
ag=af:CreateTextBox{
Name='File',
Function=function()
loadMaterials()
an,ao=nil,nil
end
}
ah=af:CreateDropdown{
Name='Mode',
List={'Load','Save'}
}
ai=af:CreateSlider{
Name='Transparency',
Min=0,
Max=1,
Default=0.7,
Decimal=10,
Function=function(ap)
for aq,ar in aj do
ar.Transparency=ap
end
end
}
end)

b(function()
local af
local ag
local ah
local ai

af=u.Categories.Inventory:CreateModule{
Name='ArmorSwitch',
Function=function(aj)
if aj then
if ag.Value=='Toggle'then
repeat
local ak=x.EntityPosition{
Part='RootPart',
Range=ai.Value,
Players=ah.Players.Enabled,
NPCs=ah.NPCs.Enabled,
Wallcheck=ah.Walls.Enabled
}and true or false

for al=0,2 do
if(F.inventory.inventory.armor[al+1]~='empty')~=ak and af.Enabled then
L.Store:dispatch{
type='InventorySetArmorItem',
item=F.inventory.inventory.armor[al+1]=='empty'and ak and getBestArmor(al)or nil,
armorSlot=al
}
c.InventoryChanged.Event:Wait()
end
end
task.wait(0.1)
until not af.Enabled
else
af:Toggle()
for ak=0,2 do
L.Store:dispatch{
type='InventorySetArmorItem',
item=F.inventory.inventory.armor[ak+1]=='empty'and getBestArmor(ak)or nil,
armorSlot=ak
}
c.InventoryChanged.Event:Wait()
end
end
end
end,
Tooltip='Puts on / takes off armor when toggled for baiting.'
}
ag=af:CreateDropdown{
Name='Mode',
List={'Toggle','On Key'}
}
ah=af:CreateTargets{
Players=true,
NPCs=true
}
ai=af:CreateSlider{
Name='Range',
Min=1,
Max=30,
Default=30,
Suffix=function(aj)
return aj==1 and'stud'or'studs'
end
}
end)

b(function()
local af
local ag
local ah
local ai
local aj={}

local function addItem(ak,al)
local an=Instance.new'ImageLabel'
an.Image=L.getIcon({itemType=ak},true)
an.Size=UDim2.fromOffset(32,32)
an.Name=ak
an.BackgroundTransparency=1
an.LayoutOrder=#ah:GetChildren()
an.Parent=ah
local ao=Instance.new'TextLabel'
ao.Name='Amount'
ao.Size=UDim2.fromScale(1,1)
ao.BackgroundTransparency=1
ao.Text=''
ao.TextColor3=Color3.new(1,1,1)
ao.TextSize=16
ao.TextStrokeTransparency=0.3
ao.Font=Enum.Font.Arial
ao.Parent=an
aj[ak]={Object=ao,Type=al}
end

local function refreshBank(ak)
for al,an in aj do
local ao=ak:FindFirstChild(al)
an.Object.Text=ao and ao:GetAttribute'Amount'or''
end
end

local function nearChest()
if x.isAlive then
local ak=x.character.RootPart.Position
for al,an in ai do
if(an.Position-ak).Magnitude<20 then
return true
end
end
end
end

local function handleState()
local ak=n.Inventories:FindFirstChild(s.Name..'_personal')
if not ak then return end

local al=workspace.MapCFrames:FindFirstChild((s:GetAttribute'Team'or 1)..'_spawn')
if al and(x.character.RootPart.Position-al.Value.Position).Magnitude<80 then
for an,ao in ak:GetChildren()do
local ap=aj[ao.Name]
if ap then
task.spawn(function()
L.Client:GetNamespace'Inventory':Get'ChestGetItem':CallServer(ak,ao)
refreshBank(ak)
end)
end
end
else
for an,ao in F.inventory.inventory.items do
local ap=aj[ao.itemType]
if ap then
task.spawn(function()
L.Client:GetNamespace'Inventory':Get'ChestGiveItem':CallServer(ak,ao.tool)
refreshBank(ak)
end)
end
end
end
end

af=u.Categories.Inventory:CreateModule{
Name='AutoBank',
Function=function(ak)
if ak then
ai=collection('personal-chest',af)
ah=Instance.new'Frame'
ah.Size=UDim2.new(1,0,0,32)
ah.Position=UDim2.fromOffset(0,-240)
ah.BackgroundTransparency=1
ah.Visible=ag.Enabled
ah.Parent=u.gui
af:Clean(ah)
local al=Instance.new'UIListLayout'
al.FillDirection=Enum.FillDirection.Horizontal
al.HorizontalAlignment=Enum.HorizontalAlignment.Center
al.SortOrder=Enum.SortOrder.LayoutOrder
al.Parent=ah
addItem('iron',true)
addItem('gold',true)
addItem('diamond',false)
addItem('emerald',true)
addItem('void_crystal',true)

repeat
local an=s.PlayerGui:FindFirstChild'hotbar'
an=an and an['1']:FindFirstChild'HotbarHealthbarContainer'
if an then
ah.Position=UDim2.fromOffset(0,(an.AbsolutePosition.Y+f:GetGuiInset().Y)-40)
end

local ao=nearChest()
if ao then
handleState()
end

task.wait(0.1)
until(not af.Enabled)
else
table.clear(aj)
end
end,
Tooltip='Automatically puts resources in ender chest'
}
ag=af:CreateToggle{
Name='UI',
Function=function(ak)
if af.Enabled then
ah.Visible=ak
end
end,
Default=true
}
end)

b(function()
local af
local ag
local ah
local ai
local aj
local ak
local al
local an
local ao={}
local ap={}
local aq={}
local ar,as={}
local at={ao,ar,ap}
local au=tick()

local av={
'wood_sword',
'stone_sword',
'iron_sword',
'diamond_sword',
'emerald_sword'
}

local aw={
'none',
'leather_chestplate',
'iron_chestplate',
'diamond_chestplate',
'emerald_chestplate'
}

local ax={
'none',
'wood_axe',
'stone_axe',
'iron_axe',
'diamond_axe'
}

local ay={
'none',
'wood_pickaxe',
'stone_pickaxe',
'iron_pickaxe',
'diamond_pickaxe'
}

local function getShopNPC()
local az,aA,aB,aC=false,false
if x.isAlive then
local aD=x.character.RootPart.Position
for aE,aF in F.shop do
if(aF.RootPart.Position-aD).Magnitude<=20 then
aB=aF.Upgrades or aF.Shop or nil
aA=aA or aF.Upgrades
az=az or aF.Shop
aC=aF.Shop and aF.Id or aC
end
end
end
return aB,az,aA,aC
end

local function canBuy(az,aA,aB)
aB=aB or 1
if not aA[az.currency]then
local aC=getItem(az.currency)
aA[az.currency]=aC and aC.amount or 0
end
if az.ignoredByKit and(table.find(az.ignoredByKit,F.equippedKit or"")or table.find(az.ignoredByKit,F.equippedKit2 or""))then
return false
end
if az.lockedByForge or az.disabled then
return false
end
if az.require and az.require.teamUpgrade then
if(L.Store:getState().Bedwars.teamUpgrades[az.require.teamUpgrade.upgradeId]or-1)<az.require.teamUpgrade.lowestTierIndex then
return false
end
end
return aA[az.currency]>=(az.price*aB)
end

local function buyItem(az,aA)
if not as then return end
notif('AutoBuy','Bought '..L.ItemMeta[az.itemType].displayName,3)
L.Client:Get'BedwarsPurchaseItem':CallServerAsync{
shopItem=az,
shopId=as
}:andThen(function(aB)
if aB then
L.SoundManager:playSound(L.SoundList.BEDWARS_PURCHASE_ITEM)
L.Store:dispatch{
type='BedwarsAddItemPurchased',
itemType=az.itemType
}
L.BedwarsShopController.alreadyPurchasedMap[az.itemType]=true
end
end)
aA[az.currency]-=az.price
end

local function buyUpgrade(az,aA)
if not ai.Enabled then return end
local aB=L.TeamUpgradeMeta[az]
local aC=L.Store:getState().Bedwars.teamUpgrades[s:GetAttribute'Team']or{}
local aD=(aC[az]or 0)+1
local aE=false

for aF=aD,#aB.tiers do
local aG=aB.tiers[aF]
if aG.availableOnlyInQueue and not table.find(aG.availableOnlyInQueue,F.queueType)then continue end

if canBuy({currency='diamond',price=aG.cost},aA)then
notif('AutoBuy','Bought '..(aB.name=='Armor'and'Protection'or aB.name)..' '..aF,3)
L.Client:Get'RequestPurchaseTeamUpgrade':CallServerAsync(az)
aA.diamond-=aG.cost
aE=true
else
break
end
end

return aE
end

local function buyTool(az,aA,aB)
local aC,aD=false
az=az and table.find(aA,az.itemType)and table.find(aA,az.itemType)+1 or math.huge

for aE=az,#aA do
local aF=L.Shop.getShopItem(aA[aE],s)
if canBuy(aF,aB)then
if an.Enabled and L.ItemMeta[aA[aE] ].breakBlock and aE>2 then
if ah.Enabled then
local aG=F.inventory.inventory.armor[2]
aG=aG and aG~='empty'and aG.itemType or'none'
if(table.find(aw,aG)or 3)<3 then break end
end
if ag.Enabled then
if F.tools.sword and(table.find(av,F.tools.sword.itemType)or 2)<2 then break end
end
end
aC=true
aD=aF
end
if aj.Enabled and aF.nextTier then break end
end

if aD then
buyItem(aD,aB)
end

return aC
end

af=u.Categories.Inventory:CreateModule{
Name='AutoBuy',
Function=function(az)
if az then
repeat task.wait()until F.queueType~='bedwars_test'
if ak.Enabled and not F.queueType:find'bedwars'then return end

local aA
af:Clean(c.InventoryAmountChanged.Event:Connect(function()
if(au-tick())>1 then au=tick()end
end))

repeat
local aB,aC,aD,aE=getShopNPC()
as=aE
if al.Enabled then
if not(L.AppController:isAppOpen'BedwarsItemShopApp'or L.AppController:isAppOpen'TeamUpgradeApp')then
aB=nil
end
end

if aB and aA~=aD then
if(au-tick())>1 then au=tick()end
aA=aD
end

if aB and au<=tick()and F.matchState~=2 and F.shopLoaded then
local aF={}
local aG
local aH,aI=pcall(function()
for aH,aI in at do
for aJ,aK in aI do
if aK(aF,aC,aD)then
aG=true
end
end
end
end)
if not aH then
warn(aI)
end
au=tick()+(aG and 0.4 or math.huge)
end

task.wait(0.1)
until not af.Enabled
else
au=tick()
end
end,
Tooltip='Automatically buys items when you go near the shop'
}
ag=af:CreateToggle{
Name='Buy Sword',
Function=function(az)
au=tick()
ar[2]=az and function(aA,aB)
if not aB then return end

if L.isKitEquipped'dasher'then
av={
[1]='wood_dao',
[2]='stone_dao',
[3]='iron_dao',
[4]='diamond_dao',
[5]='emerald_dao'
}
elseif L.isKitEquipped'ice_queen'then
av[5]='ice_sword'
elseif L.isKitEquipped'ember'then
av[5]='infernal_saber'
elseif L.isKitEquipped'lumen'then
av[5]='light_sword'
end

return buyTool(F.tools.sword,av,aA)
end or nil
end
}
ah=af:CreateToggle{
Name='Buy Armor',
Function=function(az)
au=tick()
ar[1]=az and function(aA,aB)
if not aB then return end
local aC=F.inventory.inventory.armor[2]~='empty'and F.inventory.inventory.armor[2]or getBestArmor(1)
aC=aC and aC.itemType or'none'
return buyTool({itemType=aC},aw,aA)
end or nil
end,
Default=true
}
af:CreateToggle{
Name='Buy Axe',
Function=function(az)
au=tick()
ar[3]=az and function(aA,aB)
if not aB then return end
return buyTool(F.tools.wood or{itemType='none'},ax,aA)
end or nil
end
}
af:CreateToggle{
Name='Buy Pickaxe',
Function=function(az)
au=tick()
ar[4]=az and function(aA,aB)
if not aB then return end
return buyTool(F.tools.stone,ay,aA)
end or nil
end
}
ai=af:CreateToggle{
Name='Buy Upgrades',
Function=function(az)
for aA,aB in aq do
aB.Object.Visible=az
end
end,
Default=true
}
local az=0
for aA,aB in L.TeamUpgradeMeta do
local aC=az
table.insert(aq,af:CreateToggle{
Name='Buy '..(aB.name=='Armor'and'Protection'or aB.name),
Function=function(aD)
au=tick()
ar[5+aC+(aB.name=='Armor'and 20 or 0)]=aD and function(aE,aF,aG)
if not aG then return end
if aB.disabledInQueue and table.find(aB.disabledInQueue,F.queueType)then return end
return buyUpgrade(aA,aE)
end or nil
end,
Darker=true,
Default=(aA=='ARMOR'or aA=='DAMAGE')
})
az+=1
end
aj=af:CreateToggle{Name='Tier Check'}
ak=af:CreateToggle{
Name='Only Bedwars',
Function=function()
if af.Enabled then
af:Toggle()
af:Toggle()
end
end,
Default=true
}
al=af:CreateToggle{Name='GUI check'}
an=af:CreateToggle{
Name='Smart check',
Default=true,
Tooltip='Buys iron armor before iron axe'
}
af:CreateTextList{
Name='Item',
Placeholder='priority/item/amount/after',
Function=function(aA)
table.clear(ao)
table.clear(ap)
for aB,aC in aA do
local aD=aC:split'/'
local aE=tonumber(aD[1])
if aE then
(aD[4]and ap or ao)[aE]=function(aF,aG)
if not aG then return end

local aH=L.Shop.getShopItem(aD[2],s)
if aH then
local aI=getItem(aD[2]=='wool_white'and L.Shop.getTeamWool(s:GetAttribute'Team')or aD[2])
aI=(aI and tonumber(aD[3])-aI.amount or tonumber(aD[3]))//aH.amount
if aI>0 and canBuy(aH,aF,aI)then
for aJ=1,aI do
buyItem(aH,aF)
end
return true
end
end
end
end
end
end
}
end)

b(function()
local af
local ag
local ah
local ai
local aj

local function consumeCheck(ak)
if x.isAlive then
if ah.Enabled and(not ak or ak=='StatusEffect_speed')then
local al=getItem'speed_potion'
if al and(not s.Character:GetAttribute'StatusEffect_speed')then
for an=1,4 do
if L.Client:Get(M.ConsumeItem):CallServer{item=al.tool}then break end
end
end
end

if ai.Enabled and(not ak or ak:find'Health')then
if(s.Character:GetAttribute'Health'/s.Character:GetAttribute'MaxHealth')<=(ag.Value/100)then
local al=getItem'orange'or(not s.Character:GetAttribute'StatusEffect_golden_apple'and getItem'golden_apple')or getItem'apple'

if al then
L.Client:Get(M.ConsumeItem):CallServerAsync{
item=al.tool
}
end
end
end

if aj.Enabled and(not ak or ak:find'Shield')then
if(s.Character:GetAttribute'Shield_POTION'or 0)==0 then
local al=getItem'big_shield'or getItem'mini_shield'

if al then
L.Client:Get(M.ConsumeItem):CallServerAsync{
item=al.tool
}
end
end
end
end
end

af=u.Categories.Inventory:CreateModule{
Name='AutoConsume',
Function=function(ak)
if ak then
af:Clean(c.InventoryAmountChanged.Event:Connect(consumeCheck))
af:Clean(c.AttributeChanged.Event:Connect(function(al)
if al:find'Shield'or al:find'Health'or al=='StatusEffect_speed'then
consumeCheck(al)
end
end))
consumeCheck()
end
end,
Tooltip='Automatically heals for you when health or shield is under threshold.'
}
ag=af:CreateSlider{
Name='Health Percent',
Min=1,
Max=99,
Default=70,
Suffix='%'
}
ah=af:CreateToggle{
Name='Speed Potions',
Default=true
}
ai=af:CreateToggle{
Name='Apple',
Default=true
}
aj=af:CreateToggle{
Name='Shield Potions',
Default=true
}
end)

b(function()
local af
local ag
local ah
local ai
local aj

local function CreateWindow(ak)
local al=1
local an=Instance.new'Frame'
an.Name='HotbarGUI'
an.Size=UDim2.fromOffset(660,465)
an.Position=UDim2.fromScale(0.5,0.5)
an.BackgroundColor3=y.Main
an.AnchorPoint=Vector2.new(0.5,0.5)
an.Visible=false
an.Parent=u.gui.ScaledGui
local ao=Instance.new'TextLabel'
ao.Name='Title'
ao.Size=UDim2.new(1,-10,0,20)
ao.Position=UDim2.fromOffset(math.abs(ao.Size.X.Offset),12)
ao.BackgroundTransparency=1
ao.Text='AutoHotbar'
ao.TextXAlignment=Enum.TextXAlignment.Left
ao.TextColor3=y.Text
ao.TextSize=13
ao.FontFace=y.Font
ao.Parent=an
local ap=Instance.new'Frame'
ap.Name='Divider'
ap.Size=UDim2.new(1,0,0,1)
ap.Position=UDim2.fromOffset(0,40)
ap.BackgroundColor3=w.Light(y.Main,0.04)
ap.BorderSizePixel=0
ap.Parent=an
addBlur(an)
local aq=Instance.new'TextButton'
aq.Text=''
aq.BackgroundTransparency=1
aq.Modal=true
aq.Parent=an
local ar=Instance.new'UICorner'
ar.CornerRadius=UDim.new(0,5)
ar.Parent=an
local as=Instance.new'ImageButton'
as.Name='Close'
as.Size=UDim2.fromOffset(24,24)
as.Position=UDim2.new(1,-35,0,9)
as.BackgroundColor3=Color3.new(1,1,1)
as.BackgroundTransparency=1
as.Image=E'newvape/assets/new/close.png'
as.ImageColor3=w.Light(y.Text,0.2)
as.ImageTransparency=0.5
as.AutoButtonColor=false
as.Parent=an
as.MouseEnter:Connect(function()
as.ImageTransparency=0.3
v:Tween(as,TweenInfo.new(0.2),{
BackgroundTransparency=0.6
})
end)
as.MouseLeave:Connect(function()
as.ImageTransparency=0.5
v:Tween(as,TweenInfo.new(0.2),{
BackgroundTransparency=1
})
end)
as.MouseButton1Click:Connect(function()
an.Visible=false
u.gui.ScaledGui.ClickGui.Visible=true
end)
local at=Instance.new'UICorner'
at.CornerRadius=UDim.new(1,0)
at.Parent=as
local au=Instance.new'Frame'
au.Size=UDim2.fromOffset(110,111)
au.Position=UDim2.fromOffset(11,71)
au.BackgroundColor3=w.Dark(y.Main,0.02)
au.Parent=an
local av=Instance.new'UICorner'
av.CornerRadius=UDim.new(0,4)
av.Parent=au
local aw=Instance.new'UIStroke'
aw.Color=w.Light(y.Main,0.034)
aw.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
aw.Parent=au
local ax=Instance.new'TextLabel'
ax.Size=UDim2.fromOffset(80,20)
ax.Position=UDim2.fromOffset(25,200)
ax.BackgroundTransparency=1
ax.Text='SLOT 1'
ax.TextColor3=w.Dark(y.Text,0.1)
ax.TextSize=12
ax.FontFace=y.Font
ax.Parent=an
for ay=1,9 do
local az=Instance.new'TextButton'
az.Name='Slot'..ay
az.Size=UDim2.fromOffset(51,52)
az.Position=UDim2.fromOffset(89+(ay*55),382)
az.BackgroundColor3=w.Dark(y.Main,0.02)
az.Text=''
az.AutoButtonColor=false
az.Parent=an
local aA=Instance.new'ImageLabel'
aA.Size=UDim2.fromOffset(32,32)
aA.Position=UDim2.new(0.5,-16,0.5,-16)
aA.BackgroundTransparency=1
aA.Image=''
aA.Parent=az
local aB=Instance.new'UICorner'
aB.CornerRadius=UDim.new(0,4)
aB.Parent=az
local aC=Instance.new'UIStroke'
aC.Color=w.Light(y.Main,0.04)
aC.Thickness=2
aC.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
aC.Enabled=ay==al
aC.Parent=az
az.MouseEnter:Connect(function()
az.BackgroundColor3=w.Light(y.Main,0.034)
end)
az.MouseLeave:Connect(function()
az.BackgroundColor3=w.Dark(y.Main,0.02)
end)
az.MouseButton1Click:Connect(function()
an['Slot'..al].UIStroke.Enabled=false
al=ay
aC.Enabled=true
ax.Text='SLOT '..al
end)
az.MouseButton2Click:Connect(function()
local aD=ak.Hotbars[ak.Selected]
if aD then
an['Slot'..ay].ImageLabel.Image=''
aD.Hotbar[tostring(ay)]=nil
aD.Object['Slot'..ay].Image='	'
end
end)
end
local ay=Instance.new'Frame'
ay.Size=UDim2.fromOffset(496,31)
ay.Position=UDim2.fromOffset(142,80)
ay.BackgroundColor3=w.Light(y.Main,0.034)
ay.Parent=an
local az=Instance.new'TextBox'
az.Size=UDim2.new(1,-10,0,31)
az.Position=UDim2.fromOffset(10,0)
az.BackgroundTransparency=1
az.Text=''
az.PlaceholderText=''
az.TextXAlignment=Enum.TextXAlignment.Left
az.TextColor3=y.Text
az.TextSize=12
az.FontFace=y.Font
az.ClearTextOnFocus=false
az.Parent=ay
local aA=Instance.new'UICorner'
aA.CornerRadius=UDim.new(0,4)
aA.Parent=ay
local aB=Instance.new'ImageLabel'
aB.Size=UDim2.fromOffset(14,14)
aB.Position=UDim2.new(1,-26,0,8)
aB.BackgroundTransparency=1
aB.Image=E'newvape/assets/new/search.png'
aB.ImageColor3=w.Light(y.Main,0.37)
aB.Parent=ay
local aC=Instance.new'ScrollingFrame'
aC.Name='Children'
aC.Size=UDim2.fromOffset(500,240)
aC.Position=UDim2.fromOffset(144,122)
aC.BackgroundTransparency=1
aC.BorderSizePixel=0
aC.ScrollBarThickness=2
aC.ScrollBarImageTransparency=0.75
aC.CanvasSize=UDim2.new()
aC.Parent=an
local aD=Instance.new'UIGridLayout'
aD.SortOrder=Enum.SortOrder.LayoutOrder
aD.FillDirectionMaxCells=9
aD.CellSize=UDim2.fromOffset(51,52)
aD.CellPadding=UDim2.fromOffset(4,3)
aD.Parent=aC
aD:GetPropertyChangedSignal'AbsoluteContentSize':Connect(function()
if u.ThreadFix then
setthreadidentity(8)
end
aC.CanvasSize=UDim2.fromOffset(0,aD.AbsoluteContentSize.Y/u.guiscale.Scale)
end)
table.insert(u.Windows,an)

local function createitem(aE,aF)
local aG=Instance.new'TextButton'
aG.BackgroundColor3=w.Light(y.Main,0.02)
aG.Text=''
aG.AutoButtonColor=false
aG.Parent=aC
local aH=Instance.new'ImageLabel'
aH.Size=UDim2.fromOffset(32,32)
aH.Position=UDim2.new(0.5,-16,0.5,-16)
aH.BackgroundTransparency=1
aH.Image=aF
aH.Parent=aG
local aI=Instance.new'UICorner'
aI.CornerRadius=UDim.new(0,4)
aI.Parent=aG
aG.MouseEnter:Connect(function()
aG.BackgroundColor3=w.Light(y.Main,0.04)
end)
aG.MouseLeave:Connect(function()
aG.BackgroundColor3=w.Light(y.Main,0.02)
end)
aG.MouseButton1Click:Connect(function()
local aJ=ak.Hotbars[ak.Selected]
if aJ then
an['Slot'..al].ImageLabel.Image=aF
aJ.Hotbar[tostring(al)]=aE
aJ.Object['Slot'..al].Image=aF
end
end)
end

local function indexSearch(aE)
for aF,aG in aC:GetChildren()do
if aG:IsA'TextButton'then
aG:ClearAllChildren()
aG:Destroy()
end
end

if aE==''then
for aF,aG in{'diamond_sword','diamond_pickaxe','diamond_axe','shears','wood_bow','wool_white','fireball','apple','iron','gold','diamond','emerald'}do
createitem(aG,L.ItemMeta[aG].image)
end
return
end

for aF,aG in L.ItemMeta do
if aE:lower()==aF:lower():sub(1,aE:len())then
if not aG.image then continue end
createitem(aF,aG.image)
end
end
end

az:GetPropertyChangedSignal'Text':Connect(function()
indexSearch(az.Text)
end)
indexSearch''

return an
end

u.Components.HotbarList=function(ak,al,an)
if u.ThreadFix then
setthreadidentity(8)
end
local ao={
Type='HotbarList',
Hotbars={},
Selected=1
}
local ap=Instance.new'TextButton'
ap.Name='HotbarList'
ap.Size=UDim2.fromOffset(220,40)
ap.BackgroundColor3=ak.Darker and(al.BackgroundColor3==w.Dark(y.Main,0.02)and w.Dark(y.Main,0.04)or w.Dark(y.Main,0.02))or al.BackgroundColor3
ap.Text=''
ap.BorderSizePixel=0
ap.AutoButtonColor=false
ap.Parent=al
local aq=Instance.new'Frame'
aq.Name='BKG'
aq.Size=UDim2.new(1,-20,0,31)
aq.Position=UDim2.fromOffset(10,4)
aq.BackgroundColor3=w.Light(y.Main,0.034)
aq.Parent=ap
local ar=Instance.new'UICorner'
ar.CornerRadius=UDim.new(0,4)
ar.Parent=aq
local as=Instance.new'TextButton'
as.Name='HotbarList'
as.Size=UDim2.new(1,-2,1,-2)
as.Position=UDim2.fromOffset(1,1)
as.BackgroundColor3=y.Main
as.Text=''
as.AutoButtonColor=false
as.Parent=aq
as.MouseEnter:Connect(function()
v:Tween(aq,TweenInfo.new(0.2),{
BackgroundColor3=w.Light(y.Main,0.14)
})
end)
as.MouseLeave:Connect(function()
v:Tween(aq,TweenInfo.new(0.2),{
BackgroundColor3=w.Light(y.Main,0.034)
})
end)
local at=Instance.new'UICorner'
at.CornerRadius=UDim.new(0,4)
at.Parent=as
local au=Instance.new'ImageLabel'
au.Size=UDim2.fromOffset(12,12)
au.Position=UDim2.fromScale(0.5,0.5)
au.AnchorPoint=Vector2.new(0.5,0.5)
au.BackgroundTransparency=1
au.Image=E'newvape/assets/new/add.png'
au.ImageColor3=Color3.fromHSV(0.46,0.96,0.52)
au.Parent=as
local av=Instance.new'Frame'
av.Size=UDim2.new(1,0,1,-40)
av.Position=UDim2.fromOffset(0,40)
av.BackgroundTransparency=1
av.Parent=ap
local aw=Instance.new'UIListLayout'
aw.SortOrder=Enum.SortOrder.LayoutOrder
aw.HorizontalAlignment=Enum.HorizontalAlignment.Center
aw.Padding=UDim.new(0,3)
aw.Parent=av
aw:GetPropertyChangedSignal'AbsoluteContentSize':Connect(function()
if u.ThreadFix then
setthreadidentity(8)
end
ap.Size=UDim2.fromOffset(220,math.min(43+aw.AbsoluteContentSize.Y/u.guiscale.Scale,603))
end)
as.MouseButton1Click:Connect(function()
ao:AddHotbar()
end)
ao.Window=CreateWindow(ao)

function ao.Save(ax,ay)
local az={}
for aA,aB in ax.Hotbars do
table.insert(az,aB.Hotbar)
end
ay.HotbarList={
Selected=ax.Selected,
Hotbars=az
}
end

function ao.Load(ax,ay)
for az,aA in ax.Hotbars do
aA.Object:ClearAllChildren()
aA.Object:Destroy()
table.clear(aA.Hotbar)
end
table.clear(ax.Hotbars)
for az,aA in ay.Hotbars do
ax:AddHotbar(aA)
end
ax.Selected=ay.Selected or 1
end

function ao.AddHotbar(ax,ay)
local az={Hotbar=ay or{}}
table.insert(ax.Hotbars,az)
local aA=Instance.new'TextButton'
aA.Size=UDim2.fromOffset(200,27)
aA.BackgroundColor3=table.find(ax.Hotbars,az)==ax.Selected and w.Light(y.Main,0.034)or y.Main
aA.Text=''
aA.AutoButtonColor=false
aA.Parent=av
az.Object=aA
local aB=Instance.new'UICorner'
aB.CornerRadius=UDim.new(0,4)
aB.Parent=aA
for aC=1,9 do
local aD=Instance.new'ImageLabel'
aD.Name='Slot'..aC
aD.Size=UDim2.fromOffset(17,18)
aD.Position=UDim2.fromOffset(-7+(aC*18),5)
aD.BackgroundColor3=w.Dark(y.Main,0.02)
aD.Image=az.Hotbar[tostring(aC)]and L.getIcon({itemType=az.Hotbar[tostring(aC)]},true)or''
aD.BorderSizePixel=0
aD.Parent=aA
end
aA.MouseButton1Click:Connect(function()
local aC=table.find(ao.Hotbars,az)
if aC==ao.Selected then
u.gui.ScaledGui.ClickGui.Visible=false
ao.Window.Visible=true
for aD=1,9 do
ao.Window['Slot'..aD].ImageLabel.Image=az.Hotbar[tostring(aD)]and L.getIcon({itemType=az.Hotbar[tostring(aD)]},true)or''
end
else
if ao.Hotbars[ao.Selected]then
ao.Hotbars[ao.Selected].Object.BackgroundColor3=y.Main
end
aA.BackgroundColor3=w.Light(y.Main,0.034)
ao.Selected=aC
end
end)
local aC=Instance.new'ImageButton'
aC.Name='Close'
aC.Size=UDim2.fromOffset(16,16)
aC.Position=UDim2.new(1,-23,0,6)
aC.BackgroundColor3=Color3.new(1,1,1)
aC.BackgroundTransparency=1
aC.Image=E'newvape/assets/new/closemini.png'
aC.ImageColor3=w.Light(y.Text,0.2)
aC.ImageTransparency=0.5
aC.AutoButtonColor=false
aC.Parent=aA
local aD=Instance.new'UICorner'
aD.CornerRadius=UDim.new(1,0)
aD.Parent=aC
aC.MouseEnter:Connect(function()
aC.ImageTransparency=0.3
v:Tween(aC,TweenInfo.new(0.2),{
BackgroundTransparency=0.6
})
end)
aC.MouseLeave:Connect(function()
aC.ImageTransparency=0.5
v:Tween(aC,TweenInfo.new(0.2),{
BackgroundTransparency=1
})
end)
aC.MouseButton1Click:Connect(function()
local aE=table.find(ax.Hotbars,az)
local aF=ax.Hotbars[ax.Selected]
local aG=ax.Hotbars[aE]
if aF and aG then
aG.Object:ClearAllChildren()
aG.Object:Destroy()
table.remove(ax.Hotbars,aE)
aE=table.find(ax.Hotbars,aF)
ax.Selected=table.find(ax.Hotbars,aF)or 1
end
end)
end

an.Options.HotbarList=ao

return ao
end

local function getBlock()
local ak=table.clone(F.inventory.inventory.items)
table.sort(ak,function(al,an)
return al.amount<an.amount
end)

for al,an in ak do
local ao=L.ItemMeta[an.itemType].block
if ao and not ao.seeThrough then
return an
end
end
end

local function getCustomItem(ak)
if ak=='diamond_sword'then
local al=F.tools.sword
ak=al and al.itemType or'wood_sword'
elseif ak=='diamond_pickaxe'then
local al=F.tools.stone
ak=al and al.itemType or'wood_pickaxe'
elseif ak=='diamond_axe'then
local al=F.tools.wood
ak=al and al.itemType or'wood_axe'
elseif ak=='wood_bow'then
local al=getBow()
ak=al and al.itemType or'wood_bow'
elseif ak=='wool_white'then
local al=getBlock()
ak=al and al.itemType or'wool_white'
end

return ak
end

local function findItemInTable(ak,al)
for an,ao in ak do
if al.itemType==getCustomItem(ao)then
return tonumber(an)
end
end
end

local function findInHotbar(ak)
for al,an in F.inventory.hotbar do
if an.item and an.item.itemType==ak.itemType then
return al-1,an.item
end
end
end

local function findInInventory(ak)
for al,an in F.inventory.inventory.items do
if an.itemType==ak.itemType then
return an
end
end
end

local function dispatch(...)
L.Store:dispatch(...)
c.InventoryChanged.Event:Wait()
end

local function sortCallback()
if aj then return end
aj=true
local ak=(ai.Hotbars[ai.Selected]and ai.Hotbars[ai.Selected].Hotbar or{})

for al,an in F.inventory.inventory.items do
local ao=findItemInTable(ak,an)
if ao then
local ap=F.inventory.hotbar[ao]
if ap.item and ap.item.itemType==an.itemType then continue end
if ap.item then
dispatch{
type='InventoryRemoveFromHotbar',
slot=ao-1
}
end

local aq=findInHotbar(an)
if aq then
dispatch{
type='InventoryRemoveFromHotbar',
slot=aq
}
if ap.item then
dispatch{
type='InventoryAddToHotbar',
item=findInInventory(ap.item),
slot=aq
}
end
end

dispatch{
type='InventoryAddToHotbar',
item=findInInventory(an),
slot=ao-1
}
elseif ah.Enabled then
local ap=findInHotbar(an)
if ap then
dispatch{
type='InventoryRemoveFromHotbar',
slot=ap
}
end
end
end

aj=false
end

af=u.Categories.Inventory:CreateModule{
Name='AutoHotbar',
Function=function(ak)
if ak then
task.spawn(sortCallback)
if ag.Value=='On Key'then
af:Toggle()
return
end

af:Clean(c.InventoryAmountChanged.Event:Connect(sortCallback))
end
end,
Tooltip='Automatically arranges hotbar to your liking.'
}
ag=af:CreateDropdown{
Name='Activation',
List={'Toggle','On Key'},
Function=function()
if not af then return end
if af.Enabled then
af:Toggle()
af:Toggle()
end
end
}
ah=af:CreateToggle{Name='Clear Hotbar'}
ai=af:CreateHotbarList{}
end)

b(function()
local af
local ag,ah

local ai=u.Categories.Inventory:CreateModule{
Name='FastConsume',
Function=function(ai)
if ai then
ag=L.ClickHold.startClick
ah=L.ClickHold.showProgress
L.ClickHold.startClick=function(aj)
aj.startedClickTime=tick()
local ak=aj:showProgress()
local al=aj.startedClickTime
L.RuntimeLib.Promise.defer(function()
task.wait(aj.durationSeconds*(af.Value/40))
if ak==aj.handle and al==aj.startedClickTime and aj.closeOnComplete then
aj:hideProgress()
if aj.onComplete then aj.onComplete()end
if aj.onPartialComplete then aj.onPartialComplete(1)end
aj.startedClickTime=-1
end
end)
end

L.ClickHold.showProgress=function(aj)
local ak=debug.getupvalue(ah,1)
local al=ak.mount(ak.createElement('ScreenGui',{},{ak.createElement('Frame',{
[ak.Ref]=aj.wrapperRef,
Size=UDim2.new(),
Position=UDim2.fromScale(0.5,0.55),
AnchorPoint=Vector2.new(0.5,0),
BackgroundColor3=Color3.fromRGB(0,0,0),
BackgroundTransparency=0.8
},{ak.createElement('Frame',{
[ak.Ref]=aj.progressRef,
Size=UDim2.fromScale(0,1),
BackgroundColor3=Color3.new(1,1,1),
BackgroundTransparency=0.5
})})}),s:FindFirstChild'PlayerGui')

aj.handle=al
local an=j:Create(aj.wrapperRef:getValue(),TweenInfo.new(0.1),{
Size=UDim2.fromScale(0.11,0.005)
})
local ao=j:Create(aj.progressRef:getValue(),TweenInfo.new(aj.durationSeconds*(af.Value/100),Enum.EasingStyle.Linear),{
Size=UDim2.fromScale(1,1)
})

an:Play()
ao:Play()
table.insert(aj.tweens,ao)
table.insert(aj.tweens,an)

return al
end
else
L.ClickHold.startClick=ag
L.ClickHold.showProgress=ah
ag=nil
ah=nil
end
end,
Tooltip='Use/Consume items quicker.'
}
af=ai:CreateSlider{
Name='Multiplier',
Min=0,
Max=100
}
end)

b(function()
local af

af=u.Categories.Inventory:CreateModule{
Name='FastDrop',
Function=function(ag)
if ag then
repeat
if x.isAlive and(not F.inventory.opened)and(k:IsKeyDown(Enum.KeyCode.H)or k:IsKeyDown(Enum.KeyCode.Backspace))and k:GetFocusedTextBox()==nil then
task.spawn(L.ItemDropController.dropItemInHand)
task.wait()
else
task.wait(0.1)
end
until not af.Enabled
end
end,
Tooltip='Drops items fast when you hold Q'
}
end)

b(function()
local af
local ag
local ah={}
local ai={}
local aj=Instance.new'Folder'
aj.Parent=u.gui

local function scanSide(ak,al,an)
for ao,ap in N do
for aq=1,15 do
local ar=getPlacedBlock(al+(ap*aq))
if not ar or ar==ak then break end
if not ar:GetAttribute'NoBreak'and not table.find(an,ar.Name)then
table.insert(an,ar.Name)
end
end
end
end

local function refreshAdornee(ak)
for al,an in ak.Frame:GetChildren()do
if an:IsA'ImageLabel'and an.Name~='Blur'then
an:Destroy()
end
end

local al=ak.Adornee.Position
local an={}
scanSide(ak.Adornee,al,an)
scanSide(ak.Adornee,al+Vector3.new(0,0,3),an)
table.sort(an,function(ao,ap)
return(L.ItemMeta[ao].block and L.ItemMeta[ao].block.health or 0)>(L.ItemMeta[ap].block and L.ItemMeta[ap].block.health or 0)
end)
ak.Enabled=#an>0

for ao,ap in an do
local aq=Instance.new'ImageLabel'
aq.Size=UDim2.fromOffset(32,32)
aq.BackgroundTransparency=1
aq.Image=L.getIcon({itemType=ap},true)
aq.Parent=ak.Frame
end
end

local function Added(ak)
local al=Instance.new'BillboardGui'
al.Parent=aj
al.Name='bed'
al.StudsOffsetWorldSpace=Vector3.new(0,3,0)
al.Size=UDim2.fromOffset(36,36)
al.AlwaysOnTop=true
al.ClipsDescendants=false
al.Adornee=ak
local an=addBlur(al)
an.Visible=ag.Enabled
local ao=Instance.new'Frame'
ao.Size=UDim2.fromScale(1,1)
ao.BackgroundColor3=Color3.fromHSV(ah.Hue,ah.Sat,ah.Value)
ao.BackgroundTransparency=1-(ag.Enabled and ah.Opacity or 0)
ao.Parent=al
local ap=Instance.new'UIListLayout'
ap.FillDirection=Enum.FillDirection.Horizontal
ap.Padding=UDim.new(0,4)
ap.VerticalAlignment=Enum.VerticalAlignment.Center
ap.HorizontalAlignment=Enum.HorizontalAlignment.Center
ap:GetPropertyChangedSignal'AbsoluteContentSize':Connect(function()
al.Size=UDim2.fromOffset(math.max(ap.AbsoluteContentSize.X+4,36),36)
end)
ap.Parent=ao
local aq=Instance.new'UICorner'
aq.CornerRadius=UDim.new(0,4)
aq.Parent=ao
ai[ak]=al
refreshAdornee(al)
end

local function refreshNear(ak)
ak=ak.blockRef.blockPosition*3
for al,an in ai do
if(ak-al.Position).Magnitude<=30 then
refreshAdornee(an)
end
end
end

af=u.Categories.Minigames:CreateModule{
Name='BedPlates',
Function=function(ak)
if ak then
for al,an in o:GetTagged'bed'do
task.spawn(Added,an)
end
af:Clean(c.PlaceBlockEvent.Event:Connect(refreshNear))
af:Clean(c.BreakBlockEvent.Event:Connect(refreshNear))
af:Clean(o:GetInstanceAddedSignal'bed':Connect(Added))
af:Clean(o:GetInstanceRemovedSignal'bed':Connect(function(al)
if ai[al]then
ai[al]:Destroy()
ai[al]:ClearAllChildren()
ai[al]=nil
end
end))
else
table.clear(ai)
aj:ClearAllChildren()
end
end,
Tooltip='Displays blocks over the bed'
}
ag=af:CreateToggle{
Name='Background',
Function=function(ak)
if ah.Object then
ah.Object.Visible=ak
end
for al,an in ai do
an.Frame.BackgroundTransparency=1-(ak and ah.Opacity or 0)
an.Blur.Visible=ak
end
end,
Default=true
}
ah=af:CreateColorSlider{
Name='Background Color',
DefaultValue=0,
DefaultOpacity=0.5,
Function=function(ak,al,an,ao)
for ap,aq in ai do
aq.Frame.BackgroundColor3=Color3.fromHSV(ak,al,an)
aq.Frame.BackgroundTransparency=1-ao
end
end,
Darker=true
}
end)

b(function()
local af
local ag
local ah
local ai
local aj
local ak
local al
local an
local ao
local ap={}
local aq
local ar
local as
local at
local au,av={},{}

local function customHealthbar(aw,ax,ay,az,aA,aB)
if aB:GetAttribute'NoHealthbar'then return end
if not aw.healthbarPart or not aw.healthbarBlockRef or aw.healthbarBlockRef.blockPosition~=ax.blockPosition then
aw.healthbarMaid:DoCleaning()
aw.healthbarBlockRef=ax
local aC=L.Roact.createElement
local aD=math.clamp(ay/az,0,1)
local aE=true
local aF=Instance.new'Part'
aF.Size=Vector3.one
aF.CFrame=CFrame.new(L.BlockController:getWorldPosition(ax.blockPosition))
aF.Transparency=1
aF.Anchored=true
aF.CanCollide=false
aF.Parent=workspace
aw.healthbarPart=aF
L.QueryUtil:setQueryIgnored(aw.healthbarPart,true)

local aG=L.Roact.mount(aC('BillboardGui',{
Size=UDim2.fromOffset(249,102),
StudsOffset=Vector3.new(0,2.5,0),
Adornee=aF,
MaxDistance=40,
AlwaysOnTop=true
},{
aC('Frame',{
Size=UDim2.fromOffset(160,50),
Position=UDim2.fromOffset(44,32),
BackgroundColor3=Color3.new(),
BackgroundTransparency=0.5
},{
aC('UICorner',{CornerRadius=UDim.new(0,5)}),
aC('ImageLabel',{
Size=UDim2.new(1,89,1,52),
Position=UDim2.fromOffset(-48,-31),
BackgroundTransparency=1,
Image=E'newvape/assets/new/blur.png',
ScaleType=Enum.ScaleType.Slice,
SliceCenter=Rect.new(52,31,261,502)
}),
aC('TextLabel',{
Size=UDim2.fromOffset(145,14),
Position=UDim2.fromOffset(13,12),
BackgroundTransparency=1,
Text=L.ItemMeta[aB.Name].displayName or aB.Name,
TextXAlignment=Enum.TextXAlignment.Left,
TextYAlignment=Enum.TextYAlignment.Top,
TextColor3=Color3.new(),
TextScaled=true,
Font=Enum.Font.Arial
}),
aC('TextLabel',{
Size=UDim2.fromOffset(145,14),
Position=UDim2.fromOffset(12,11),
BackgroundTransparency=1,
Text=L.ItemMeta[aB.Name].displayName or aB.Name,
TextXAlignment=Enum.TextXAlignment.Left,
TextYAlignment=Enum.TextYAlignment.Top,
TextColor3=w.Dark(y.Text,0.16),
TextScaled=true,
Font=Enum.Font.Arial
}),
aC('Frame',{
Size=UDim2.fromOffset(138,4),
Position=UDim2.fromOffset(12,32),
BackgroundColor3=y.Main
},{
aC('UICorner',{CornerRadius=UDim.new(1,0)}),
aC('Frame',{
[L.Roact.Ref]=aw.healthbarProgressRef,
Size=UDim2.fromScale(aD,1),
BackgroundColor3=Color3.fromHSV(math.clamp(aD/2.5,0,1),0.89,0.75)
},{aC('UICorner',{CornerRadius=UDim.new(1,0)})})
})
})
}),aF)

aw.healthbarMaid:GiveTask(function()
aE=false
aw.healthbarBlockRef=nil
L.Roact.unmount(aG)
if aw.healthbarPart then
aw.healthbarPart:Destroy()
end
aw.healthbarPart=nil
end)

L.RuntimeLib.Promise.delay(5):andThen(function()
if aE then
aw.healthbarMaid:DoCleaning()
end
end)
end

local aC=math.clamp((ay-aA)/az,0,1)
j:Create(aw.healthbarProgressRef:getValue(),TweenInfo.new(0.3),{
Size=UDim2.fromScale(aC,1),BackgroundColor3=Color3.fromHSV(math.clamp(aC/2.5,0,1),0.89,0.75)
}):Play()
end

local aw=0

local function attemptBreak(ax,ay)
if not ax then return end
if F.matchState==2 then return end
for az,aA in ax do
if(aA.Position-ay).Magnitude<ag.Value and L.BlockController:isBlockBreakable({blockPosition=aA.Position/3},s)then
if not ar.Enabled and aA:GetAttribute'PlacedByUserId'==s.UserId then continue end
if(aA:GetAttribute'BedShieldEndTime'or 0)>workspace:GetServerTimeNow()then continue end
if at.Enabled and not(F.hand.tool and L.ItemMeta[F.hand.tool.Name].breakBlock)then continue end

aw+=1
local aB,aC,aD=L.breakBlock(aA,ao.Enabled,aq.Enabled,ap.Enabled and customHealthbar or nil,as.Enabled)
if aC then
local aE=aB
for aF,aG in av do
aG.Position=aE or Vector3.zero
if aE then
aG.BoxHandleAdornment.Color3=aE==aD and Color3.new(1,0.2,0.2)or aE==aB and Color3.new(0.2,0.2,1)or Color3.new(0.2,1,0.2)
end
aE=aC[aE]
end
end

task.wait(as.Enabled and(F.damageBlockFail>tick()and 4.5 or 0)or ah.Value)

return true
end
end

return false
end

af=u.Categories.Minigames:CreateModule{
Name='Nuker',
Function=function(ax)
if ax then
for ay=1,30 do
local az=Instance.new'Part'
az.Anchored=true
az.CanQuery=false
az.CanCollide=false
az.Transparency=1
az.Parent=r
local aA=Instance.new'BoxHandleAdornment'
aA.Size=Vector3.one
aA.AlwaysOnTop=true
aA.ZIndex=1
aA.Transparency=0.5
aA.Adornee=az
aA.Parent=az
table.insert(av,az)
end

local ay=collection('bed',af)
local az={}
for aA,aB in{'NewYearsLuckyBlock','HalloweenLuckyBlock','GrowingHalloweenLuckyBlock','ForgeLuckyBlock','LuckyBlock','GlitchedLuckyBlock','MagicalHeroLuckyBlock'}do
collection(aB,af,function(aC,aD)
table.insert(az,aD)
end,function(aC,aD)
local aE=table.find(az,aD)
if aE then
table.remove(az,aE)
end
end)
end
local aA=collection("iron_ore_mesh_block",af)
au=collection('block',af,function(aB,aC)
if table.find(aj.ListEnabled,aC.Name)then
table.insert(aB,aC)
end
end)

repeat
task.wait(1/ai.Value)
if not af.Enabled then break end
if x.isAlive then
local aB=x.character.RootPart.Position

if attemptBreak(ak.Enabled and ay,aB)then continue end
if attemptBreak(au,aB)then continue end
if attemptBreak(al.Enabled and az,aB)then continue end
if attemptBreak(an.Enabled and aA,aB)then continue end

for aC,aD in av do
aD.Position=Vector3.zero
end
end
until not af.Enabled
else
for ay,az in av do
az:ClearAllChildren()
az:Destroy()
end
table.clear(av)
end
end,
Tooltip='Break blocks around you automatically'
}
ag=af:CreateSlider{
Name='Break range',
Min=1,
Max=30,
Default=30,
Suffix=function(ax)
return ax==1 and'stud'or'studs'
end
}
ah=af:CreateSlider{
Name='Break speed',
Min=0,
Max=0.3,
Default=0.25,
Decimal=100,
Suffix='seconds'
}
ai=af:CreateSlider{
Name='Update rate',
Min=1,
Max=120,
Default=60,
Suffix='hz'
}
aj=af:CreateTextList{
Name='Custom',
Function=function()
if not au then return end
table.clear(au)
for ax,ay in F.blocks do
if table.find(aj.ListEnabled,ay.Name)then
table.insert(au,ay)
end
end
end
}
ak=af:CreateToggle{
Name='Break Bed',
Default=true
}
al=af:CreateToggle{
Name='Break Lucky Block',
Default=true
}
an=af:CreateToggle{
Name='Break Iron Ore',
Default=true
}
ao=af:CreateToggle{
Name='Show Healthbar & Effects',
Function=function(ax)
if ap.Object then
ap.Object.Visible=ax
end
end,
Default=true
}
ap=af:CreateToggle{
Name='Custom Healthbar',
Default=true,
Darker=true
}
aq=af:CreateToggle{Name='Animation'}
ar=af:CreateToggle{Name='Self Break'}
as=af:CreateToggle{Name='Instant Break'}
at=af:CreateToggle{
Name='Limit to items',
Tooltip='Only breaks when tools are held'
}
end)

b(function()
local af

local ag
local ah={}

af=u.Legit:CreateModule{
Name='Bed Break Effect',
Function=function(ai)
if ai then
af:Clean(c.BedwarsBedBreak.Event:Connect(function(aj)
firesignal(L.Client:Get'BedBreakEffectTriggered'.instance.OnClientEvent,{
player=aj.player,
position=aj.bedBlockPosition*3,
effectType=ah[ag.Value],
teamId=aj.brokenBedTeam.id,
centerBedPosition=aj.bedBlockPosition*3
})
end))
end
end,
Tooltip='Custom bed break effects'
}
local ai={}
for aj,ak in L.BedBreakEffectMeta do
table.insert(ai,ak.name)
ah[ak.name]=aj
end
table.sort(ai)
ag=af:CreateDropdown{
Name='Effect',
List=ai
}
end)

b(function()
u.Legit:CreateModule{
Name='Clean Kit',
Function=function(af)
if af then
L.WindWalkerController.spawnOrb=function()end
local ag=s.PlayerGui:FindFirstChild('WindWalkerEffect',true)
if ag then
ag.Visible=false
end
end
end,
Tooltip='Removes zephyr status indicator'
}
end)

b(function()
local af
local ag

local ah=u.Legit:CreateModule{
Name='Crosshair',
Function=function(ah)
if ah then
af=debug.getconstant(L.ViewmodelController.showCrosshair,25)
debug.setconstant(L.ViewmodelController.showCrosshair,25,ag.Value)
debug.setconstant(L.ViewmodelController.showCrosshair,37,ag.Value)
else
debug.setconstant(L.ViewmodelController.showCrosshair,25,af)
debug.setconstant(L.ViewmodelController.showCrosshair,37,af)
af=nil
end

if L.ViewmodelController.crosshair then
L.ViewmodelController:hideCrosshair()
L.ViewmodelController:showCrosshair()
end
end,
Tooltip='Custom first person crosshair depending on the image choosen.'
}
ag=ah:CreateTextBox{
Name='Image',
Placeholder='image id (roblox)',
Function=function(ai)
if ai and ah.Enabled then
ah:Toggle()
ah:Toggle()
end
end
}
end)

b(function()
local af
local ag
local ah
local ai
local aj
local ak
local al,an=pcall(function()
return debug.getupvalue(L.DamageIndicator,2)
end)
an=al and an or{}
local ao,ap={}

af=u.Legit:CreateModule{
Name='Damage Indicator',
Function=function(aq)
if aq then
ao=table.clone(an)
ap=debug.getconstant(L.DamageIndicator,86)
debug.setconstant(L.DamageIndicator,86,Enum.Font[ag.Value])
debug.setconstant(L.DamageIndicator,119,ak.Enabled and'Thickness'or'Enabled')
an.strokeThickness=ak.Enabled and 1 or false
an.textSize=ai.Value
an.blowUpSize=ai.Value
an.blowUpDuration=0
an.baseColor=Color3.fromHSV(ah.Hue,ah.Sat,ah.Value)
an.blowUpCompleteDuration=0
an.anchoredDuration=aj.Value
else
for ar,as in ao do
an[ar]=as
end
debug.setconstant(L.DamageIndicator,86,ap)
debug.setconstant(L.DamageIndicator,119,'Thickness')
end
end,
Tooltip='Customize the damage indicator'
}
local aq={'GothamBlack'}
for ar,as in Enum.Font:GetEnumItems()do
if as.Name~='GothamBlack'then
table.insert(aq,as.Name)
end
end
ag=af:CreateDropdown{
Name='Font',
List=aq,
Function=function(ar)
if af.Enabled then
debug.setconstant(L.DamageIndicator,86,Enum.Font[ar])
end
end
}
ah=af:CreateColorSlider{
Name='Color',
DefaultHue=0,
Function=function(ar,as,at)
if af.Enabled then
an.baseColor=Color3.fromHSV(ar,as,at)
end
end
}
ai=af:CreateSlider{
Name='Size',
Min=1,
Max=32,
Default=32,
Function=function(ar)
if af.Enabled then
an.textSize=ar
an.blowUpSize=ar
end
end
}
aj=af:CreateSlider{
Name='Anchor',
Min=0,
Max=1,
Decimal=10,
Function=function(ar)
if af.Enabled then
an.anchoredDuration=ar
end
end
}
ak=af:CreateToggle{
Name='Stroke',
Function=function(ar)
if af.Enabled then
debug.setconstant(L.DamageIndicator,119,ar and'Thickness'or'Enabled')
an.strokeThickness=ar and 1 or false
end
end
}
end)

b(function()
local af
local ag
local ah,ai

af=u.Legit:CreateModule{
Name='FOV',
Function=function(aj)
if aj then
ah=L.FovController.setFOV
ai=L.FovController.getFOV
L.FovController.setFOV=function(ak)
return ah(ak,ag.Value)
end
L.FovController.getFOV=function()
return ag.Value
end
r.FieldOfView=ag.Value
else
L.FovController.setFOV=ah
L.FovController.getFOV=ai
end

L.FovController:setFOV(L.Store:getState().Settings.fov)
end,
Tooltip='Adjusts camera vision'
}
ag=af:CreateSlider{
Name='FOV',
Min=30,
Max=120
}
end)

b(function()
local af
local ag
local ah
local ai,aj={},{}

af=u.Legit:CreateModule{
Name='FPS Boost',
Function=function(ak)
if ak then
if ag.Enabled then
for al,an in L.KillEffectController.killEffects do
if not al:find'Custom'then
ai[al]=an
L.KillEffectController.killEffects[al]={
new=function()
return{
onKill=function()end,
isPlayDefaultKillEffect=function()
return true
end
}
end
}
end
end
end

if ah.Enabled then
for al,an in L.VisualizerUtils do
aj[al]=an
L.VisualizerUtils[al]=function()end
end
end

repeat task.wait()until F.matchState~=0
if not L.AppController then return end
L.NametagController.addGameNametag=function()end
for al,an in L.AppController:getOpenApps()do
if tostring(an):find'Nametag'then
L.AppController:closeApp(tostring(an))
end
end
else
for al,an in ai do
L.KillEffectController.killEffects[al]=an
end
for al,an in aj do
L.VisualizerUtils[al]=an
end
table.clear(ai)
table.clear(aj)
end
end,
Tooltip='Improves the framerate by turning off certain effects'
}
ag=af:CreateToggle{
Name='Kill Effects',
Function=function()
if af.Enabled then
af:Toggle()
af:Toggle()
end
end,
Default=true
}
ah=af:CreateToggle{
Name='Visualizer',
Function=function()
if af.Enabled then
af:Toggle()
af:Toggle()
end
end,
Default=true
}
end)

b(function()
local af
local ag
local ah={}

af=u.Legit:CreateModule{
Name='Hit Color',
Function=function(ai)
if ai then
repeat
for aj,ak in x.List do
local al=ak.Character and ak.Character:FindFirstChild'_DamageHighlight_'
if al then
if not table.find(ah,al)then
table.insert(ah,al)
end
al.FillColor=Color3.fromHSV(ag.Hue,ag.Sat,ag.Value)
al.FillTransparency=ag.Opacity
end
end
task.wait(0.1)
until not af.Enabled
else
for aj,ak in ah do
ak.FillColor=Color3.new(1,0,0)
ak.FillTransparency=0.4
end
table.clear(ah)
end
end,
Tooltip='Customize the hit highlight options'
}
ag=af:CreateColorSlider{
Name='Color',
DefaultOpacity=0.4
}
u:setupguicolorsync(af,{
Color1=ag,
Default=true,
})
end)

b(function()
local af
local ag=require(s.PlayerScripts.TS.controllers.global.hotbar.ui['hotbar-open-inventory']).HotbarOpenInventory
local ah=require(s.PlayerScripts.TS.controllers.global.hotbar.ui.healthbar['hotbar-healthbar']).HotbarHealthbar
local ai=getRoactRender(require(s.PlayerScripts.TS.controllers.global.hotbar.ui['hotbar-app']).HotbarApp.render)
local aj,ak={},{}

u:Clean(function()
for al,an in ak do
table.clear(an)
end
for al,an in aj do
table.clear(an)
end
table.clear(ak)
table.clear(aj)
end)

local function modifyconstant(al,an,ao)
if not al then return end
if not aj[al]then aj[al]={}end
if not ak[al]then ak[al]={}end
if not aj[al][an]then
aj[al][an]=debug.getconstant(al,an)
end
if typeof(aj[al][an])~=typeof(ao)then return end
ak[al][an]=ao

if af.Enabled then
if ao then
debug.setconstant(al,an,ao)
else
debug.setconstant(al,an,aj[al][an])
aj[al][an]=nil
end
end
end

af=u.Legit:CreateModule{
Name='Interface',
Function=function(al)
for an,ao in(al and ak or aj)do
for ap,aq in ao do
debug.setconstant(an,ap,aq)
end
end
end,
Tooltip='Customize bedwars UI'
}
local al={'LuckiestGuy'}
for an,ao in Enum.Font:GetEnumItems()do
if ao.Name~='LuckiestGuy'then
table.insert(al,ao.Name)
end
end
af:CreateDropdown{
Name='Health Font',
List=al,
Function=function(an)
modifyconstant(ah.render,77,an)
end
}
af:CreateColorSlider{
Name='Health Color',
Function=function(an,ao,ap)
modifyconstant(ah.render,16,tonumber(Color3.fromHSV(an,ao,ap):ToHex(),16))
if af.Enabled then
local aq=s.PlayerGui:FindFirstChild'hotbar'
aq=aq and aq:FindFirstChild('HealthbarProgressWrapper',true)
if aq then
aq['1'].BackgroundColor3=Color3.fromHSV(an,ao,ap)
end
end
end
}
af:CreateColorSlider{
Name='Hotbar Color',
DefaultOpacity=0.8,
Function=function(an,ao,ap,aq)
local ar=O or ag.render
modifyconstant(debug.getupvalue(ai,23).render,51,tonumber(Color3.fromHSV(an,ao,ap):ToHex(),16))
modifyconstant(debug.getupvalue(ai,23).render,58,tonumber(Color3.fromHSV(an,ao,math.clamp(ap>0.5 and ap-0.2 or ap+0.2,0,1)):ToHex(),16))
modifyconstant(debug.getupvalue(ai,23).render,54,1-aq)
modifyconstant(debug.getupvalue(ai,23).render,55,math.clamp(1.2-aq,0,1))
modifyconstant(ar,31,tonumber(Color3.fromHSV(an,ao,ap):ToHex(),16))
modifyconstant(ar,32,math.clamp(1.2-aq,0,1))
modifyconstant(ar,34,tonumber(Color3.fromHSV(an,ao,math.clamp(ap>0.5 and ap-0.2 or ap+0.2,0,1)):ToHex(),16))
end
}
end)

b(function()
local af
local ag
local ah
local ai={}

local aq={
Gravity=function(aj,ak,al,an)
al:BreakJoints()
local ao=al:FindFirstChildWhichIsA'Highlight'
local ap=al:FindFirstChild('Nametag',true)
if ao then
ao:Destroy()
end
if ap then
ap:Destroy()
end

task.spawn(function()
local aq={}
for ar,as in al:GetDescendants()do
if as:IsA'BasePart'then
aq[as.Name]=as.Velocity
end
end
al.Archivable=true
local ar=al:Clone()
ar.Humanoid.Health=100
ar.Parent=workspace
game:GetService'Debris':AddItem(ar,30)
al:Destroy()
task.wait(0.01)
ar.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
ar:BreakJoints()
task.wait(0.01)
for as,at in ar:GetDescendants()do
if at:IsA'BasePart'then
local au=Instance.new'BodyForce'
au.Force=Vector3.new(0,(workspace.Gravity-10)*at:GetMass(),0)
au.Parent=at
at.CanCollide=true
at.Velocity=aq[at.Name]or Vector3.zero
end
end
end)
end,
Lightning=function(al,an,ao,ap)
ao:BreakJoints()
local aq=ao:FindFirstChildWhichIsA'Highlight'
if aq then
aq:Destroy()
end
local ar=1125
local as=ao.PrimaryPart.CFrame.p-Vector3.new(0,8,0)
local at=Vector3.new((math.random(1,10)-5)*2,ar,(math.random(1,10)-5)*2)

for au=ar-75,0,-75 do
local av=Vector3.new((math.random(1,10)-5)*2,au,(math.random(1,10)-5)*2)
if au==0 then
av=Vector3.zero
end
local aw=Instance.new'Part'
aw.Size=Vector3.new(1.5,1.5,77)
aw.Material=Enum.Material.SmoothPlastic
aw.Anchored=true
aw.Material=Enum.Material.Neon
aw.CanCollide=false
aw.CFrame=CFrame.new(as+at+((av-at)*0.5),as+av)
aw.Parent=workspace
local ax=aw:Clone()
ax.Size=Vector3.new(3,3,78)
ax.Color=Color3.new(0.7,0.7,0.7)
ax.Transparency=0.7
ax.Material=Enum.Material.SmoothPlastic
ax.Parent=workspace
game:GetService'Debris':AddItem(aw,0.5)
game:GetService'Debris':AddItem(ax,0.5)
L.QueryUtil:setQueryIgnored(aw,true)
L.QueryUtil:setQueryIgnored(ax,true)
if au==0 then
local ay=Instance.new'Part'
ay.Transparency=1
ay.Anchored=true
ay.Size=Vector3.zero
ay.Position=as
ay.Parent=workspace
L.QueryUtil:setQueryIgnored(ay,true)
local az=Instance.new'Sound'
az.SoundId='rbxassetid://6993372814'
az.Volume=2
az.Pitch=0.5+(math.random(1,3)/10)
az.Parent=ay
az:Play()
az.Ended:Connect(function()
ay:Destroy()
end)
end
at=av
end
end,
Delete=function(ao,ap,aq,ar)
aq:Destroy()
end
}

af=u.Legit:CreateModule{
Name='Kill Effect',
Function=function(ar)
if ar then
for as,at in aq do
L.KillEffectController.killEffects['Custom'..as]={
new=function()
return{
onKill=at,
isPlayDefaultKillEffect=function()
return false
end
}
end
}
end
af:Clean(s:GetAttributeChangedSignal'KillEffectType':Connect(function()
s:SetAttribute('KillEffectType',ag.Value=='Bedwars'and ai[ah.Value]or'Custom'..ag.Value)
end))
s:SetAttribute('KillEffectType',ag.Value=='Bedwars'and ai[ah.Value]or'Custom'..ag.Value)
else
for as in aq do
L.KillEffectController.killEffects['Custom'..as]=nil
end
s:SetAttribute('KillEffectType','default')
end
end,
Tooltip='Custom final kill effects'
}
local ar={'Bedwars'}
for as in aq do
table.insert(ar,as)
end
ag=af:CreateDropdown{
Name='Mode',
List=ar,
Function=function(as)
ah.Object.Visible=as=='Bedwars'
if af.Enabled then
s:SetAttribute('KillEffectType',as=='Bedwars'and ai[ah.Value]or'Custom'..as)
end
end
}
local as={}
for at,au in L.KillEffectMeta do
table.insert(as,au.name)
ai[au.name]=at
end
table.sort(as)
ah=af:CreateDropdown{
Name='Bedwars',
List=as,
Function=function(at)
if af.Enabled then
s:SetAttribute('KillEffectType',ai[at])
end
end,
Darker=true
}
end)

b(function()
local af
local ag

af=u.Legit:CreateModule{
Name='Reach Display',
Function=function(ah)
if ah then
repeat
ag.Text=(F.attackReachUpdate>tick()and F.attackReach or'0.00')..' studs'
task.wait(0.4)
until not af.Enabled
end
end,
Size=UDim2.fromOffset(100,41)
}
af:CreateFont{
Name='Font',
Blacklist='Gotham',
Function=function(ah)
ag.FontFace=ah
end
}
af:CreateColorSlider{
Name='Color',
DefaultValue=0,
DefaultOpacity=0.5,
Function=function(ah,ai,aq,ar)
ag.BackgroundColor3=Color3.fromHSV(ah,ai,aq)
ag.BackgroundTransparency=1-ar
end
}
ag=Instance.new'TextLabel'
ag.Size=UDim2.fromScale(1,1)
ag.BackgroundTransparency=0.5
ag.TextSize=15
ag.Font=Enum.Font.Gotham
ag.Text='0.00 studs'
ag.TextColor3=Color3.new(1,1,1)
ag.BackgroundColor3=Color3.new()
ag.Parent=af.Children
local ah=Instance.new'UICorner'
ah.CornerRadius=UDim.new(0,4)
ah.Parent=ag
end)

b(function()
local af
local ag
local ah
local ai={}
local aq
local ar={}
local as=tick()
local at,au,av,aw

local function choosesong()
local ax=ag.ListEnabled
if#ar>=#ax then
table.clear(ar)
end

if#ax<=0 then
notif('SongBeats','no songs',10)
af:Toggle()
return
end

local ay=ax[math.random(1,#ax)]
if#ax>1 and table.find(ar,ay)then
repeat
task.wait()
ay=ax[math.random(1,#ax)]
until not table.find(ar,ay)or not af.Enabled
end
if not af.Enabled then return end

local az=ay:split'/'
if not isfile(az[1])then
notif('SongBeats','Missing song ('..az[1]..')',10)
af:Toggle()
return
end

au.SoundId=t(az[1])
repeat task.wait()until au.IsLoaded or not af.Enabled
if af.Enabled then
as=tick()+(tonumber(az[3])or 0)
av=60/(tonumber(az[2])or 50)
au:Play()
end
end

af=u.Legit:CreateModule{
Name='Song Beats',
Function=function(ax)
if ax then
au=Instance.new'Sound'
au.Volume=aq.Value/100
au.Parent=workspace
repeat
if not au.Playing then choosesong()end
if as<tick()and af.Enabled and ah.Enabled then
as=tick()+av
at=math.min(L.FovController:getFOV()*(L.SprintController.sprinting and 1.1 or 1),120)
r.FieldOfView=at-ai.Value
aw=j:Create(r,TweenInfo.new(math.min(av,0.2),Enum.EasingStyle.Linear),{FieldOfView=at})
aw:Play()
end
task.wait()
until not af.Enabled
else
if au then
au:Destroy()
end
if aw then
aw:Cancel()
end
if at then
r.FieldOfView=at
end
table.clear(ar)
end
end,
Tooltip='Built in mp3 player'
}
ag=af:CreateTextList{
Name='Songs',
Placeholder='filepath/bpm/start'
}
ah=af:CreateToggle{
Name='Beat FOV',
Function=function(ax)
if ai.Object then
ai.Object.Visible=ax
end
if af.Enabled then
af:Toggle()
af:Toggle()
end
end,
Default=true
}
ai=af:CreateSlider{
Name='Adjustment',
Min=1,
Max=30,
Default=5,
Darker=true
}
aq=af:CreateSlider{
Name='Volume',
Function=function(ax)
if au then
au.Volume=ax/100
end
end,
Min=1,
Max=100,
Default=100,
Suffix='%'
}
end)

b(function()
local af
local ag
local ah={}
local ai

af=u.Legit:CreateModule{
Name='SoundChanger',
Function=function(aq)
if aq then
ai=L.SoundManager.playSound
L.SoundManager.playSound=function(ar,as,...)
if ah[as]then
as=ah[as]
end

return ai(ar,as,...)
end
else
L.SoundManager.playSound=ai
ai=nil
end
end,
Tooltip='Change ingame sounds to custom ones.'
}
ag=af:CreateTextList{
Name='Sounds',
Placeholder='(DAMAGE_1/ben.mp3)',
Function=function()
table.clear(ah)
for aq,ar in ag.ListEnabled do
local as=ar:split'/'
local at=L.SoundList[as[1] ]
if at and#as>1 then
ah[at]=as[2]:find'rbxasset'and as[2]or isfile(as[2])and t(as[2])or''
end
end
end
}
end)

b(function()
local af
local ag
local ah
local ai
local aq=getRoactRender(require(s.PlayerScripts.TS.controllers.global.hotbar.ui['hotbar-app']).HotbarApp.render)
local ar=require(s.PlayerScripts.TS.controllers.global.hotbar.ui['hotbar-open-inventory']).HotbarOpenInventory
local as,at={},{}
local au

u:Clean(function()
for av,aw in at do
table.clear(aw)
end
for av,aw in as do
table.clear(aw)
end
table.clear(at)
table.clear(as)
end)

local function modifyconstant(av,aw,ax)
if not as[av]then as[av]={}end
if not at[av]then at[av]={}end
if not as[av][aw]then
local ay=type(as[av][aw])
if ay=='function'or ay=='userdata'then return end
as[av][aw]=debug.getconstant(av,aw)
end
if typeof(as[av][aw])~=typeof(ax)and ax~=nil then return end

at[av][aw]=ax
if af.Enabled then
if ax then
debug.setconstant(av,aw,ax)
else
debug.setconstant(av,aw,as[av][aw])
as[av][aw]=nil
end
end
end

af=u.Legit:CreateModule{
Name='UI Cleanup',
Function=function(av)
for aw,ax in(av and at or as)do
for ay,az in ax do
debug.setconstant(aw,ay,az)
end
end
if av then
if ag.Enabled then
O=ar.render
ar.render=function()
return L.Roact.createElement('TextButton',{Visible=false},{})
end
end

if ah.Enabled then
au=L.KillFeedController.addToKillFeed
L.KillFeedController.addToKillFeed=function()end
end

if ai.Enabled then
g:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList,true)
end
else
if O then
ar.render=O
O=nil
end

if ah.Enabled then
L.KillFeedController.addToKillFeed=au
au=nil
end

if ai.Enabled then
g:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList,false)
end
end
end,
Tooltip='Cleans up the UI for kits & main'
}
af:CreateToggle{
Name='Resize Health',
Function=function(av)
modifyconstant(aq,60,av and 1 or nil)
modifyconstant(debug.getupvalue(aq,15).render,30,av and 1 or nil)
modifyconstant(debug.getupvalue(aq,23).tweenPosition,16,av and 0 or nil)
end,
Default=true
}
af:CreateToggle{
Name='No Hotbar Numbers',
Function=function(av)
local aw=O or ar.render
modifyconstant(debug.getupvalue(aq,23).render,90,av and 0 or nil)
modifyconstant(aw,71,av and 0 or nil)
end,
Default=true
}
ag=af:CreateToggle{
Name='No Inventory Button',
Function=function(av)
modifyconstant(aq,78,av and 0 or nil)
if af.Enabled then
if av then
O=ar.render
ar.render=function()
return L.Roact.createElement('TextButton',{Visible=false},{})
end
else
ar.render=O
O=nil
end
end
end,
Default=true
}
ah=af:CreateToggle{
Name='No Kill Feed',
Function=function(av)
if af.Enabled then
if av then
au=L.KillFeedController.addToKillFeed
L.KillFeedController.addToKillFeed=function()end
else
L.KillFeedController.addToKillFeed=au
au=nil
end
end
end,
Default=true
}
ai=af:CreateToggle{
Name='Old Player List',
Function=function(av)
if af.Enabled then
g:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList,av)
end
end,
Default=true
}
af:CreateToggle{
Name='Fix Queue Card',
Function=function(av)
modifyconstant(L.QueueCard.render,15,av and 0.1 or nil)
end,
Default=true
}
end)

b(function()
local af
local ag
local ah
local ai
local aq
local ar={}
local as,at

af=u.Legit:CreateModule{
Name='Viewmodel',
Function=function(au)
local av=r:FindFirstChild'Viewmodel'
if au then
as=L.ViewmodelController.playAnimation
at=av and av.RightHand.RightWrist.C1 or CFrame.identity
if aq.Enabled then
L.ViewmodelController.playAnimation=function(aw,ax,...)
if L.AnimationType and ax==L.AnimationType.FP_WALK then return end
return as(aw,ax,...)
end
end

L.InventoryViewmodelController:handleStore(L.Store:getState())
if av then
r.Viewmodel.RightHand.RightWrist.C1=at*CFrame.Angles(math.rad(ar[1].Value),math.rad(ar[2].Value),math.rad(ar[3].Value))
end
s.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_DEPTH_OFFSET',-ag.Value)
s.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_HORIZONTAL_OFFSET',ah.Value)
s.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_VERTICAL_OFFSET',ai.Value)
else
L.ViewmodelController.playAnimation=as
if av then
av.RightHand.RightWrist.C1=at
end

L.InventoryViewmodelController:handleStore(L.Store:getState())
s.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_DEPTH_OFFSET',0)
s.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_HORIZONTAL_OFFSET',0)
s.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_VERTICAL_OFFSET',0)
as=nil
end
end,
Tooltip='Changes the viewmodel animations'
}
ag=af:CreateSlider{
Name='Depth',
Min=0,
Max=2,
Default=0.8,
Decimal=10,
Function=function(au)
if af.Enabled then
s.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_DEPTH_OFFSET',-au)
end
end
}
ah=af:CreateSlider{
Name='Horizontal',
Min=0,
Max=2,
Default=0.8,
Decimal=10,
Function=function(au)
if af.Enabled then
s.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_HORIZONTAL_OFFSET',au)
end
end
}
ai=af:CreateSlider{
Name='Vertical',
Min=-0.2,
Max=2,
Default=-0.2,
Decimal=10,
Function=function(au)
if af.Enabled then
s.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_VERTICAL_OFFSET',au)
end
end
}
for au,av in{'Rotation X','Rotation Y','Rotation Z'}do
table.insert(ar,af:CreateSlider{
Name=av,
Min=0,
Max=360,
Function=function(aw)
if af.Enabled then
r.Viewmodel.RightHand.RightWrist.C1=at*CFrame.Angles(math.rad(ar[1].Value),math.rad(ar[2].Value),math.rad(ar[3].Value))
end
end
})
end
aq=af:CreateToggle{
Name='No Bobbing',
Default=true,
Function=function()
if af.Enabled then
af:Toggle()
af:Toggle()
end
end
}
end)

b(function()
local af
local ag
local ah={}

af=u.Legit:CreateModule{
Name='WinEffect',
Function=function(ai)
if ai then
af:Clean(c.MatchEndEvent.Event:Connect(function()
for aq,ar in getconnections(L.Client:Get'WinEffectTriggered'.instance.OnClientEvent)do
if ar.Function then
ar.Function{
winEffectType=ah[ag.Value],
winningPlayer=s
}
end
end
end))
end
end,
Tooltip='Allows you to select any clientside win effect'
}
local ai={}
for aq,ar in L.WinEffectMeta do
table.insert(ai,ar.name)
ah[ar.name]=aq
end
table.sort(ai)
ag=af:CreateDropdown{
Name='Effects',
List=ai
}
end)

local function createMonitoredTable(af,ag)
local ah={}
local ai={
__index=af,
__newindex=function(ai,aq,ar)
local as=af[aq]
af[aq]=ar
if ag then
ag(aq,as,ar)
end
end,
}
setmetatable(ah,ai)
return ah
end
local function onChange(af,ag,ah)
getgenv().GlobalStore=F
shared.GlobalStore=F
end
local function onChange2(af,ag,ah)
getgenv().GlobalBedwars=L
shared.GlobalBedwars=L
end

F=createMonitoredTable(F,onChange)
L=createMonitoredTable(L,onChange2)

getgenv().GlobalStore=F
shared.GlobalStore=F

getgenv().GlobalBedwars=L
shared.GlobalBedwars=L