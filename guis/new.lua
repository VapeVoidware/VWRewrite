local a=shared.VoidwareLoader
assert(a~=nil and type(a)=="table","[GuiLibrary]: VoidwareLoader is invalid :c")
local b=a:setupDecoratedCustomSignal"GUILIBRARY_INTERNAL"
local c={
GUIColor={
Hue=0.46,
Sat=0.96,
Value=0.52,
},
HeldKeybinds={},
Keybind={"RightShift"},
Loaded=false,
Libraries={},
Place=game.PlaceId,
Profile="default",
Profiles={},
RainbowSpeed={Value=1},
RainbowUpdateSpeed={Value=60},
RainbowTable={},
Scale={Value=1},
ThreadFix=not shared.CheatEngineMode
and setthreadidentity~=nil
and type(setthreadidentity)=="function"
and true
or false,
ToggleNotifications={},
FavoriteNotifications={},
BindNotifications={},
Version="4.18",
Windows={},
Indicators={}
}
c.DefaultColor=Color3.fromHSV(c.GUIColor.Hue,c.GUIColor.Sat,c.GUIColor.Value)
for d,e in{"PreloadEvent","GUIColorChanged","SelfDestructEvent","VisibilityChanged","OnLoadEvent","ProfileChangedEvent"}do
if c[e]then continue end
c[e]=b(e)
end
c.libraries=setmetatable(c.Libraries,{
__index=function(d,e)
local f=c.Libraries[e]
if f then
rawset(d,e,f)
end
return f
end,
__newindex=function(d,e,f)
if not c.Libraries[e]then
c.Libraries[e]=f
end
rawset(d,e,f)
end
})
function c.connectOnLoad(d,e)
d.loadconns=d.loadconns or{}
if e==nil then return end
if type(e)~="function"then return end
if d.loadconns[tostring(e)]then return end
d.loadconns[tostring(e)]=e
end
function c.onload(d)
if not d.loadconns then return end
d.ProfileChangedEvent:Fire()
for e,f in d.loadconns do
task.spawn(pcall,f,c)
d.loadconns[e]=nil
end
end

c.Categories={}
c.Modules={}

local d=cloneref or function(d)
return d
end
local e=setmetatable({},{
__index=function(e,f)
local g,h=pcall(function()
local g=game:GetService(f)
if not g then
error(`Service {tostring(f)} not found!`)
return
end
return d(g)
end)
if not g then
a:report{
type="Services-gui-api",
err=h,
args={f},
}
else
rawset(e,f,h)
end
return g and h
end,
})
local f=e.TweenService
local g=e.UserInputService
local h=e.TextService
local i=e.GuiService local j=
e.RunService
local k=e.HttpService

c.isMobile=g.TouchEnabled and not g.KeyboardEnabled

local l={}
local m={
tweens={},
tweenstwo={},
}
local n={
Main=Color3.fromRGB(0,0,0),
Text=Color3.fromRGB(255,255,255),
Font=Font.fromEnum(Enum.Font.Arial),
FontSemiBold=Font.fromEnum(Enum.Font.Arial,Enum.FontWeight.SemiBold),
Tween=TweenInfo.new(0.16,Enum.EasingStyle.Linear),
}

local function getTableSize(o)
local p=0
for q in o do
p+=1
end
return p
end

local function loopClean(o,p)
p=p or{}
if p[o]then
return
end
p[o]=true

local q={
ModuleCategory=true,
CategoryApi=true,
}

for r,s in pairs(o)do
if not q[r]and type(s)=="table"then
loopClean(s,p)
end
o[r]=nil
end
end

local function addMaid(o)
o.Connections={}
function o.Clean(p,q)
if typeof(q)=="Instance"then
table.insert(p.Connections,{
Disconnect=function()
q:ClearAllChildren()
q:Destroy()
end,
})
elseif type(q)=="function"then
table.insert(p.Connections,{
Disconnect=q,
})
elseif typeof(q)=="thread"then
table.insert(p.Connections,{
Disconnect=function()
pcall(task.cancel,q)
end,
})
else
table.insert(p.Connections,q)
end
end
end
addMaid(c)

local function loadJson(o,p)
local q,r=pcall(function()
local q=p and o or readfile(o)
return k:JSONDecode(q)
end)
return q and type(r)=="table"and r or nil
end

local function decode(o)
return loadJson(o,true)
end

local function encode(o)
local p,q=pcall(function()
return k:JSONEncode(o)
end)
if not p then
warn(`[encode]: {tostring(q)}`)
end
return p and q
end

local function flickerTextEffect(o,p,q)
if p==true and o.TextTransparency==0 then
m:Tween(o,TweenInfo.new(0.15),{
TextTransparency=1,
}).Completed:Wait()
end
if q~=nil then
o.Text=q
end
m:Tween(o,TweenInfo.new(0.15),{
TextTransparency=p and 0 or 1,
}).Completed:Wait()
end

local function flickerImageEffect(o,p,q)
if not o or not(o:IsA"ImageButton"or o:IsA"ImageLabel")then
return
end

p=p or 0.5
q=q or 0.15

local r=tick()
local s=o.Size
local t=o.ImageColor3
local u=o.ImageTransparency

local v=Instance.new"UIScale"
v.Scale=1
v.Parent=o

task.spawn(function()
m:Tween(v,TweenInfo.new(q),{
Scale=1.2
})
while tick()-r<p and o.Parent do
m:Tween(o,TweenInfo.new(q),{
ImageTransparency=0,
ImageColor3=Color3.fromRGB(255,255,255)
})

task.wait(q)

m:Tween(o,TweenInfo.new(q),{
ImageTransparency=u,
ImageColor3=t
})

task.wait(q)
end

pcall(function()
v:Destroy()
end)
m:Tween(v,TweenInfo.new(q),{
Scale=1,
})
o.Size=s
o.ImageTransparency=u
end)
end

local function Color3ToHex(o)
local p=math.floor(o.R*255)
local q=math.floor(o.G*255)
local r=math.floor(o.B*255)
return string.format("#%02x%02x%02x",p,q,r)
end

local function hsv(o,p,q)
local r,s=pcall(function()
return Color3.fromHSV(o,p,q)
end)
return r,s
end

local function str(o)
return tostring(o)
end

local function tblcheck(o)
return(o~=nil and type(o)=="table")
end

local function num(o)
if o==nil then
return o
end
return tonumber(o)
end

local function count(o)
local p=0
for q,r in o do
p=p+1
end
return p
end

local function wrap(o)
return a:wrap(o,{
name="wrap:api"
})
end
c.wrap=wrap

local function connectguicolorchange(o,p)
o=wrap(o)
local r
if type(o)=="function"then
o(c.GUIColor.Hue,c.GUIColor.Sat,c.GUIColor.Value)
r=c.GUIColorChanged.Event:Connect(o)
else
o.BackgroundColor3=Color3.fromHSV(c.GUIColor.Hue,c.GUIColor.Sat,c.GUIColor.Value)
r=c.GUIColorChanged.Event:Connect(function(s,t,u)
o.BackgroundColor3=Color3.fromHSV(s,t,u)
end)
end
if p and type(o)=="function"then
c:Clean(r)
return{
run=function()
o(c.GUIColor.Hue,c.GUIColor.Sat,c.GUIColor.Value)
end,
conn=r
}
end
return r
end
c.connectguicolorchange=connectguicolorchange

c.GuiColorSyncAPI={}
function c.setupguicolorsync(o,p,r,s)
if not(s~=nil and type(s)=="function")then
s=function()end
else
s=wrap(s)
end
if not tblcheck(p)then
a:throw(`[setupguicolorsync]: api invalid! {tostring(p)}`)
return
end
if not(tblcheck(r)and tblcheck(r.Color1))then
a:throw(`[setupguicolorsync]: options invalid! {tostring(r)}`)
return
end

local t,u,v=r.Color1,r.Color2,r.Color3
local w=false
























local x=function()end

local y
p.Name=p.Name or k:GenerateGUID(false)
y=o.GuiColorSyncAPI[p.Name]or p:CreateToggle{
Name="GUI Color Sync",
Function=function(z)
s(z)
if z then
x()
end
end,
Tooltip=r.Tooltip or"Syncs with the gui theme color",
Default=r.Default
}
o.GuiColorSyncAPI[p.Name]=y

for z,A in{t,u,v}do
A:ConnectCallback(function()
if y.Enabled and not w then
InfoNotification(`GUI Sync - {p.Name}`,"Disabled due to color slider change! Re-enable if you want :D",5)
y:Toggle()
end
end)
end

x=connectguicolorchange(function(z,A,B)
if not y.Enabled then return end
local C={Hue=z,Sat=A,Value=B}

w=true

if v then
local D=C

local E=(z+0.1)%1
local F=(z+0.2)%1
local G={Hue=E,Sat=A,Value=B}
local H={Hue=F,Sat=A,Value=B}

t:SetValue(D.Hue,D.Sat,D.Value)
u:SetValue(G.Hue,G.Sat,G.Value)
v:SetValue(H.Hue,H.Sat,H.Value)
elseif u then
local D=C
local E=(z+0.1)%1
local F={Hue=E,Sat=A,Value=B}

t:SetValue(D.Hue,D.Sat,D.Value)
u:SetValue(F.Hue,F.Sat,F.Value)
else
t:SetValue(C.Hue,C.Sat,C.Value)
end

w=false
end,true).run

return y
end

local function connectvisibilitychange(o)
return c.VisibilityChanged.Event:Connect(o)
end
c.connectvisibilitychange=connectvisibilitychange

local o=Instance.new"GetTextBoundsParams"
o.Width=math.huge
local p
local r
local s=getcustomasset
local t
local u
local v
local w
local x
local y
local z
local A

local B={
["vape/assets/new/add.png"]="rbxassetid://14368300605",
["vape/assets/new/alert.png"]="rbxassetid://14368301329",
["vape/assets/new/allowedicon.png"]="rbxassetid://14368302000",
["vape/assets/new/allowedtab.png"]="rbxassetid://14368302875",
["vape/assets/new/arrowmodule.png"]="rbxassetid://14473354880",
["vape/assets/new/back.png"]="rbxassetid://14368303894",
["vape/assets/new/bind.png"]="rbxassetid://14368304734",
["vape/assets/new/bindbkg.png"]="rbxassetid://14368305655",
["vape/assets/new/blatanticon.png"]="rbxassetid://14368306745",
["vape/assets/new/blockedicon.png"]="rbxassetid://14385669108",
["vape/assets/new/blockedtab.png"]="rbxassetid://14385672881",
["vape/assets/new/blur.png"]="rbxassetid://14898786664",
["vape/assets/new/blurnotif.png"]="rbxassetid://16738720137",
["vape/assets/new/close.png"]="rbxassetid://14368309446",
["vape/assets/new/closemini.png"]="rbxassetid://14368310467",
["vape/assets/new/colorpreview.png"]="rbxassetid://14368311578",
["vape/assets/new/combaticon.png"]="rbxassetid://14368312652",
["vape/assets/new/customsettings.png"]="rbxassetid://14403726449",
["vape/assets/new/discord.png"]="",
["vape/assets/new/dots.png"]="rbxassetid://14368314459",
["vape/assets/new/edit.png"]="rbxassetid://14368315443",
["vape/assets/new/expandicon.png"]="rbxassetid://14368353032",
["vape/assets/new/expandright.png"]="rbxassetid://14368316544",
["vape/assets/new/expandup.png"]="rbxassetid://14368317595",
["vape/assets/new/friendstab.png"]="rbxassetid://14397462778",
["vape/assets/new/guisettings.png"]="rbxassetid://14368318994",
["vape/assets/new/guislider.png"]="rbxassetid://14368320020",
["vape/assets/new/guisliderrain.png"]="rbxassetid://14368321228",
["vape/assets/new/guiv4.png"]="rbxassetid://14368322199",
["vape/assets/new/guivape.png"]="rbxassetid://14657521312",
["vape/assets/new/info.png"]="rbxassetid://14368324807",
["vape/assets/new/inventoryicon.png"]="rbxassetid://14928011633",
["vape/assets/new/legit.png"]="rbxassetid://14425650534",
["vape/assets/new/legittab.png"]="rbxassetid://14426740825",
["vape/assets/new/miniicon.png"]="rbxassetid://14368326029",
["vape/assets/new/notification.png"]="rbxassetid://16738721069",
["vape/assets/new/overlaysicon.png"]="rbxassetid://14368339581",
["vape/assets/new/overlaystab.png"]="rbxassetid://14397380433",
["vape/assets/new/pin.png"]="rbxassetid://14368342301",
["vape/assets/new/profilesicon.png"]="rbxassetid://14397465323",
["vape/assets/new/radaricon.png"]="rbxassetid://14368343291",
["vape/assets/new/rainbow_1.png"]="rbxassetid://14368344374",
["vape/assets/new/rainbow_2.png"]="rbxassetid://14368345149",
["vape/assets/new/rainbow_3.png"]="rbxassetid://14368345840",
["vape/assets/new/rainbow_4.png"]="rbxassetid://14368346696",
["vape/assets/new/range.png"]="rbxassetid://14368347435",
["vape/assets/new/rangearrow.png"]="rbxassetid://14368348640",
["vape/assets/new/rendericon.png"]="rbxassetid://14368350193",
["vape/assets/new/rendertab.png"]="rbxassetid://14397373458",
["vape/assets/new/search.png"]="rbxassetid://14425646684",
["vape/assets/new/targetinfoicon.png"]="rbxassetid://14368354234",
["vape/assets/new/targetnpc1.png"]="rbxassetid://14497400332",
["vape/assets/new/targetnpc2.png"]="rbxassetid://14497402744",
["vape/assets/new/targetplayers1.png"]="rbxassetid://14497396015",
["vape/assets/new/targetplayers2.png"]="rbxassetid://14497397862",
["vape/assets/new/targetstab.png"]="rbxassetid://14497393895",
["vape/assets/new/textguiicon.png"]="rbxassetid://14368355456",
["vape/assets/new/textv4.png"]="rbxassetid://14368357095",
["vape/assets/new/textvape.png"]="rbxassetid://14368358200",
["vape/assets/new/utilityicon.png"]="rbxassetid://14368359107",
["vape/assets/new/vape.png"]="rbxassetid://14373395239",
["vape/assets/new/warning.png"]="rbxassetid://14368361552",
["vape/assets/new/worldicon.png"]="rbxassetid://14368362492",
["vape/assets/new/star.png"]="rbxassetid://137405505909578"
}

local C=isfile
or function(C)
local D,E=pcall(function()
return readfile(C)
end)
return D and E~=nil and E~=""
end

local D=function(D,E,F)
o.Text=D
o.Size=E
if typeof(F)=="Font"then
o.Font=F
end
local G,H=pcall(function()
return h:GetTextBoundsAsync(o)
end)
if not G then
a:report{
type="getfontsize-function",
err=H,
args={D,E,F},
notifyBlacklisted=true,
}
end
return G and H
end

local function addBlur(E,F)
local G=Instance.new"ImageLabel"
G.Name="Blur"
G.Size=UDim2.new(1,89,1,52)
G.Position=UDim2.fromOffset(-48,-31)
G.BackgroundTransparency=1
G.Image=t("vape/assets/new/"..(F and"blurnotif"or"blur")..".png")
G.ScaleType=Enum.ScaleType.Slice
G.SliceCenter=Rect.new(52,31,261,502)
G.Parent=E

return G
end

local function addCorner(E,F)
local G=Instance.new"UICorner"
G.CornerRadius=F or UDim.new(0,5)
G.Parent=E

return G
end

local function addCloseButton(E,F)
local G=Instance.new"ImageButton"
G.Name="Close"
G.Size=UDim2.fromOffset(24,24)
G.Position=UDim2.new(1,-35,0,F or 9)
G.BackgroundColor3=Color3.new(1,1,1)
G.BackgroundTransparency=1
G.AutoButtonColor=false
G.Image=t"vape/assets/new/close.png"
G.ImageColor3=l.Light(n.Text,0.2)
G.ImageTransparency=0.5
G.Parent=E
addCorner(G,UDim.new(1,0))

G.MouseEnter:Connect(function()
G.ImageTransparency=0.3
m:Tween(G,n.Tween,{
BackgroundTransparency=0.6,
})
end)
G.MouseLeave:Connect(function()
G.ImageTransparency=0.5
m:Tween(G,n.Tween,{
BackgroundTransparency=1,
})
end)

return G
end





local function addTooltip(E,F)
if c.isMobile then return end
if not F then
return
end

local function tooltipMoved(G,H)
local I=G+16+y.Size.X.Offset>(z.Scale*1920)
y.Position=UDim2.fromOffset(
(I and G-(y.Size.X.Offset*z.Scale)-16 or G+16)/z.Scale,
((H+11)-(y.Size.Y.Offset/2))/z.Scale
)
y.Visible=x.Visible
end

local G={}
G[1]=E.MouseEnter:Connect(function(H,I)
local J=D(F,y.TextSize,n.Font)
y.Size=UDim2.fromOffset(J.X+10,J.Y+10)
y.Text=F
tooltipMoved(H,I)
end)
G[2]=E.MouseMoved:Connect(tooltipMoved)
G[3]=E.MouseLeave:Connect(function()
y.Visible=false
end)
E.Destroying:Once(function()
for H,I in G do
pcall(function()
I:Disconnect()
end)
G[H]=nil
end
end)
end
c.addTooltip=addTooltip

local function checkKeybinds(E,F,G)
if type(F)=="table"then
if table.find(F,G)then
for H,I in F do
if not table.find(E,I)then
return false
end
end
return true
end
end

return false
end



















local function createMobileButton(E,F)
local G=false
local H=Instance.new"TextButton"
H.Size=UDim2.fromOffset(40,40)
H.Position=UDim2.fromOffset(F.X,F.Y)
H.AnchorPoint=Vector2.new(0.5,0.5)
H.BackgroundColor3=E.Enabled and Color3.new(0,0.7,0)or Color3.new()
H.BackgroundTransparency=0.5
H.Text=E.Name
H.TextColor3=Color3.new(1,1,1)
H.TextScaled=true
H.Font=Enum.Font.Gotham
H.Parent=c.gui
local I=Instance.new"UITextSizeConstraint"
I.MaxTextSize=16
I.Parent=H
addCorner(H,UDim.new(1,0))

H.MouseButton1Down:Connect(function()
G=true
local J,K=tick(),g:GetMouseLocation()
repeat
G=(g:GetMouseLocation()-K).Magnitude<6
task.wait()
until(tick()-J)>1 or not G
if G then
E.Bind={}
H:Destroy()
end
end)
H.MouseButton1Up:Connect(function()
G=false
end)
H.Activated:Connect(function()
E:Toggle()
H.BackgroundColor3=E.Enabled and Color3.new(0,0.7,0)or Color3.new()
end)

E.Bind={Button=H}
end

c.http_function=function(E)
if E==nil then
return
end
E=tostring(E)
local F,G=pcall(function()
return{game:HttpGet(E)}
end)
if not(F~=nil and F==true and G~=nil and type(G)=="table")then
return
end
if G[1]~=nil and G[1]==game then
return G[4]
else
return G[1]
end
end



























local E=function(E,F,G)
local H,I
task.spawn(function()
H,I=pcall(function()
return E()
end)
end)
F=F or 5
local J=tick()
repeat task.wait()until H~=nil or tick()-J>=F
if H==nil then
H=false
I="TIMEOUT_EXCEEDED"
end
if not H and shared.VoidDev then
warn(debug.traceback(I))
end
if G~=nil then
return G(H,I)
end
return H,I
end

local F=shared.CACHED_ICON_LIBRARY
if not F then
E(function()
local G,H=pcall(function()
local G=loadstring(c.http_function"https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua")()
G.SetIconsType"lucide"
return G
end)
if not G then
pcall(function()
c:CreateNotification("Vape | Icons","Failure loading custom icons :c",5,'alert')
end)
warn(`[Icons Failure]: {tostring(F)}`)
end
F=G and H or nil
shared.CACHED_ICON_LIBRARY=F
end,3)
end
local function getCustomIcon(G)
if not F then return false end
local H,I=pcall(function()
return F.GetIcon(G)
end)
if not H then
warn(`[getCustomIcon Failure]: {tostring(G)} -> {tostring(I)}`)
end
return H and I~=nil and I or false
end

t=function(G,H)
if H then
local I=getCustomIcon(G)
if I~=false then
return I
else
return''
end
end
return B[G]or getCustomIcon(G)or select(2,pcall(s,G))or''
end

local function makeDraggable(G,H)
G.InputBegan:Connect(function(I)
if H and not H.Visible then
return
end
if
(
I.UserInputType==Enum.UserInputType.MouseButton1
or I.UserInputType==Enum.UserInputType.Touch
)and(I.Position.Y-G.AbsolutePosition.Y<40 or H)
then
local J=Vector2.new(
G.AbsolutePosition.X-I.Position.X,
G.AbsolutePosition.Y-I.Position.Y+i:GetGuiInset().Y
)/z.Scale

local K=g.InputChanged:Connect(function(K)
if
K.UserInputType
==(
I.UserInputType==Enum.UserInputType.MouseButton1
and Enum.UserInputType.MouseMovement
or Enum.UserInputType.Touch
)
then
local L=K.Position
if g:IsKeyDown(Enum.KeyCode.LeftShift)then
J=(J//3)*3
L=(L//3)*3
end
G.AnchorPoint=Vector2.new(0,0)
G.Position=UDim2.fromOffset(
(L.X/z.Scale)+J.X,
(L.Y/z.Scale)+J.Y
)
end
end)

local L
L=I.Changed:Connect(function()
if I.UserInputState==Enum.UserInputState.End then
if K then
K:Disconnect()
end
if L then
L:Disconnect()
end
end
end)
end
end)
end

local function randomString()
local G={}
for H=1,math.random(10,100)do
G[H]=string.char(math.random(32,126))
end
return table.concat(G)
end

local function removeTags(G)
G=G:gsub("<br%s*/>","\n")
return G:gsub("<[^<>]->","")
end

do
local G=C"vape/profiles/color.txt"and loadJson"vape/profiles/color.txt"
if G then
n.Main=G.Main and Color3.fromRGB(unpack(G.Main))or n.Main
n.Text=G.Text and Color3.fromRGB(unpack(G.Text))or n.Text
n.Font=G.Font
and Font.new(
G.Font:find"rbxasset"and G.Font
or string.format("rbxasset://fonts/families/%s.json",G.Font)
)
or n.Font
n.FontSemiBold=Font.new(n.Font.Family,Enum.FontWeight.SemiBold)
end
o.Font=n.Font
end

do
function l.Dark(G,H)
local I,J,K=G:ToHSV()
return Color3.fromHSV(I,J,math.clamp(select(3,n.Main:ToHSV())>0.5 and K+H or K-H,0,1))
end

function l.Light(G,H)
local I,J,K=G:ToHSV()
return Color3.fromHSV(I,J,math.clamp(select(3,n.Main:ToHSV())>0.5 and K-H or K+H,0,1))
end

function c.Color(G,H)
local I=0.75+(0.15*math.min(H/0.03,1))
if H>0.57 then
I=0.9-(0.4*math.min((H-0.57)/0.09,1))
end
if H>0.66 then
I=0.5+(0.4*math.min((H-0.66)/0.16,1))
end
if H>0.87 then
I=0.9-(0.15*math.min((H-0.87)/0.13,1))
end
return H,I,1
end

function c.TextColor(G,H,I,J)
if J>=0.7 and(I<0.6 or H>0.04 and H<0.56)then
return Color3.new(0.19,0.19,0.19)
end
return Color3.new(1,1,1)
end
end

do
function m.Tween(G,H,I,J,K,L,M)
if type(K)=="boolean"then
L=K
K=nil
end
if type(I)=="table"then
J=I
I=TweenInfo.new(0.15)
end

K=K or G.tweens

if K[H]then
K[H]:Cancel()
K[H]=nil
end

if H.Parent then
local N=f:Create(H,I,J)
K[H]=N

N.Completed:Once(function()
K[H]=nil

if not M then
pcall(function()
for O,P in pairs(J)do
H[O]=P
end
end)
end
end)

if not L then
N:Play()
end

return N
else
for N,O in pairs(J)do
H[N]=O
end
end
end
m.tween=m.Tween

function m.Cancel(G,H)
if G.tweens[H]then
G.tweens[H]:Cancel()
G.tweens[H]=nil
end
end
m.cancel=m.Cancel
end

c.Libraries={
color=l,
getcustomasset=t,
getfontsize=D,
tween=m,
uipallet=n,
}

local G
G={
Button=function(H,I,J)
local K={
Name=H.Name,
Visible=H.Visible==nil or H.Visible
}
local L=Instance.new"TextButton"
L.Name=H.Name.."Button"
L.Size=UDim2.new(1,0,0,31)
L.BackgroundColor3=l.Dark(I.BackgroundColor3,H.Darker and 0.02 or 0)
L.BackgroundTransparency=H.BackgroundTransparency or 0
L.BorderSizePixel=0
L.AutoButtonColor=false
L.Visible=K.Visible
L.Text=""
L.Parent=I
L:GetPropertyChangedSignal"Visible":Connect(function()
K.Visible=L.Visible
end)
addTooltip(L,H.Tooltip)
local M=Instance.new"Frame"
M.Size=UDim2.fromOffset(200,27)
M.Position=UDim2.fromOffset(10,2)
M.BackgroundColor3=l.Light(n.Main,0.05)
M.Parent=L
addCorner(M)
local N=Instance.new"TextLabel"
N.Size=UDim2.new(1,-4,1,-4)
N.Position=UDim2.fromOffset(2,2)
N.BackgroundColor3=n.Main
N.Text=H.Name
N.TextColor3=l.Dark(n.Text,0.16)
N.TextSize=14
N.FontFace=n.Font
N.Parent=M
addCorner(N,UDim.new(0,4))
H.Function=H.Function and wrap(H.Function)or function()end

function K.SetVisible(O,P)
if P==nil then
P=not K.Visible
end
L.Visible=P
end

L.MouseEnter:Connect(function()
m:Tween(M,n.Tween,{
BackgroundColor3=l.Light(n.Main,0.3),
})
end)
L.MouseLeave:Connect(function()
m:Tween(M,n.Tween,{
BackgroundColor3=l.Light(n.Main,0.05),
})
end)
L.Activated:Connect(H.Function)
K.Object=L
K.Label=N
return K
end,
ColorSlider=function(H,I,J)
if H.Color then
H.DefaultHue,H.DefaultSat,H.DefaultValue=H.Color:ToHSV()
end
local K={
Type="ColorSlider",
Hue=H.DefaultHue or 0.44,
Sat=H.DefaultSat or 1,
Value=H.DefaultValue or 1,
Opacity=H.DefaultOpacity or 1,
Rainbow=false,
Index=0,
}

local function createSlider(L,M)
local N=Instance.new"TextButton"
N.Name=H.Name.."Slider"..L
N.Size=UDim2.new(1,0,0,50)
N.BackgroundColor3=l.Dark(I.BackgroundColor3,H.Darker and 0.02 or 0)
N.BorderSizePixel=0
N.AutoButtonColor=false
N.Visible=false
N.Text=""
N.Parent=I
local O=Instance.new"TextLabel"
O.Name="Title"
O.Size=UDim2.fromOffset(60,30)
O.Position=UDim2.fromOffset(10,2)
O.BackgroundTransparency=1
O.Text=L
O.TextXAlignment=Enum.TextXAlignment.Left
O.TextColor3=l.Dark(n.Text,0.16)
O.TextSize=11
O.FontFace=n.Font
O.Parent=N
local P=Instance.new"Frame"
P.Name="Slider"
P.Size=UDim2.new(1,-20,0,2)
P.Position=UDim2.fromOffset(10,37)
P.BackgroundColor3=Color3.new(1,1,1)
P.BorderSizePixel=0
P.Parent=N
local Q=Instance.new"UIGradient"
Q.Color=M
Q.Parent=P
local R=P:Clone()
R.Name="Fill"
R.Size=UDim2.fromScale(
math.clamp(
L=="Saturation"and K.Sat
or L=="Vibrance"and K.Value
or K.Opacity,
0.04,
0.96
),
1
)
R.Position=UDim2.new()
R.BackgroundTransparency=1
R.Parent=P
local S=Instance.new"Frame"
S.Name="Knob"
S.Size=UDim2.fromOffset(24,4)
S.Position=UDim2.fromScale(1,0.5)
S.AnchorPoint=Vector2.new(0.5,0.5)
S.BackgroundColor3=N.BackgroundColor3
S.BorderSizePixel=0
S.Parent=R
local T=Instance.new"Frame"
T.Name="Knob"
T.Size=UDim2.fromOffset(14,14)
T.Position=UDim2.fromScale(0.5,0.5)
T.AnchorPoint=Vector2.new(0.5,0.5)
T.BackgroundColor3=n.Text
T.Parent=S
addCorner(T,UDim.new(1,0))

N.InputBegan:Connect(function(U)
if
(
U.UserInputType==Enum.UserInputType.MouseButton1
or U.UserInputType==Enum.UserInputType.Touch
)and(U.Position.Y-N.AbsolutePosition.Y)>(20*z.Scale)
then
local V=g.InputChanged:Connect(function(V)
if
V.UserInputType
==(
U.UserInputType==Enum.UserInputType.MouseButton1
and Enum.UserInputType.MouseMovement
or Enum.UserInputType.Touch
)
then
K:SetValue(
nil,
L=="Saturation"
and math.clamp(
(V.Position.X-P.AbsolutePosition.X)/P.AbsoluteSize.X,
0,
1
)
or nil,
L=="Vibrance"
and math.clamp(
(V.Position.X-P.AbsolutePosition.X)/P.AbsoluteSize.X,
0,
1
)
or nil,
L=="Opacity"
and math.clamp(
(V.Position.X-P.AbsolutePosition.X)/P.AbsoluteSize.X,
0,
1
)
or nil
)
if K._InternalCallback then
K._InternalCallback()
end
end
end)

local W
W=U.Changed:Connect(function()
if U.UserInputState==Enum.UserInputState.End then
if V then
V:Disconnect()
end
if W then
W:Disconnect()
end
end
end)
end
end)
N.MouseEnter:Connect(function()
m:Tween(T,n.Tween,{
Size=UDim2.fromOffset(16,16),
})
end)
N.MouseLeave:Connect(function()
m:Tween(T,n.Tween,{
Size=UDim2.fromOffset(14,14),
})
end)

return N
end

local L=Instance.new"TextButton"
L.Name=H.Name.."Slider"
L.Size=UDim2.new(1,0,0,50)
L.BackgroundColor3=l.Dark(I.BackgroundColor3,H.Darker and 0.02 or 0)
L.BorderSizePixel=0
L.AutoButtonColor=false
L.Visible=H.Visible==nil or H.Visible
L.Text=""
L.Parent=I
addTooltip(L,H.Tooltip)
local M=Instance.new"TextLabel"
M.Name="Title"
M.Size=UDim2.fromOffset(60,30)
M.Position=UDim2.fromOffset(10,2)
M.BackgroundTransparency=1
M.Text=H.Name
M.TextXAlignment=Enum.TextXAlignment.Left
M.TextColor3=l.Dark(n.Text,0.16)
M.TextSize=11
M.FontFace=n.Font
M.Parent=L
local N=Instance.new"TextBox"
N.Name="Box"
N.Size=UDim2.fromOffset(60,15)
N.Position=UDim2.new(1,-69,0,9)
N.BackgroundTransparency=1
N.Visible=false
N.Text=""
N.TextXAlignment=Enum.TextXAlignment.Right
N.TextColor3=l.Dark(n.Text,0.16)
N.TextSize=11
N.FontFace=n.Font
N.ClearTextOnFocus=true
N.Parent=L
local O=Instance.new"Frame"
O.Name="Slider"
O.Size=UDim2.new(1,-20,0,2)
O.Position=UDim2.fromOffset(10,39)
O.BackgroundColor3=Color3.new(1,1,1)
O.BorderSizePixel=0
O.Parent=L
local P={}
for Q=0,1,0.1 do
table.insert(P,ColorSequenceKeypoint.new(Q,Color3.fromHSV(Q,1,1)))
end
local Q=Instance.new"UIGradient"
Q.Color=ColorSequence.new(P)
Q.Parent=O
local R=O:Clone()
R.Name="Fill"
R.Size=UDim2.fromScale(math.clamp(K.Hue,0.04,0.96),1)
R.Position=UDim2.new()
R.BackgroundTransparency=1
R.Parent=O
local S=Instance.new"ImageButton"
S.Name="Preview"
S.Size=UDim2.fromOffset(12,12)
S.Position=UDim2.new(1,-22,0,10)
S.BackgroundTransparency=1
S.Image=t"vape/assets/new/colorpreview.png"
S.ImageColor3=Color3.fromHSV(K.Hue,K.Sat,K.Value)
S.ImageTransparency=1-K.Opacity
S.Parent=L
local T=Instance.new"TextButton"
T.Name="Expand"
T.Size=UDim2.fromOffset(17,13)
T.Position=UDim2.new(
0,
h:GetTextSize(M.Text,M.TextSize,M.Font,Vector2.new(1000,1000)).X+11,
0,
7
)
T.BackgroundTransparency=1
T.Text=""
T.Parent=L
local U=Instance.new"ImageLabel"
U.Name="Expand"
U.Size=UDim2.fromOffset(9,5)
U.Position=UDim2.fromOffset(4,4)
U.BackgroundTransparency=1
U.Image=t"vape/assets/new/expandicon.png"
U.ImageColor3=l.Dark(n.Text,0.43)
U.Parent=T
local V=Instance.new"TextButton"
V.Name="Rainbow"
V.Size=UDim2.fromOffset(12,12)
V.Position=UDim2.new(1,-42,0,10)
V.BackgroundTransparency=1
V.Text=""
V.Parent=L
local W=Instance.new"ImageLabel"
W.Size=UDim2.fromOffset(12,12)
W.BackgroundTransparency=1
W.Image=t"vape/assets/new/rainbow_1.png"
W.ImageColor3=l.Light(n.Main,0.37)
W.Parent=V
local X=W:Clone()
X.Image=t"vape/assets/new/rainbow_2.png"
X.Parent=V
local Y=W:Clone()
Y.Image=t"vape/assets/new/rainbow_3.png"
Y.Parent=V
local Z=W:Clone()
Z.Image=t"vape/assets/new/rainbow_4.png"
Z.Parent=V
local _=Instance.new"Frame"
_.Name="Knob"
_.Size=UDim2.fromOffset(24,4)
_.Position=UDim2.fromScale(1,0.5)
_.AnchorPoint=Vector2.new(0.5,0.5)
_.BackgroundColor3=L.BackgroundColor3
_.BorderSizePixel=0
_.Parent=R
local aa=Instance.new"Frame"
aa.Name="Knob"
aa.Size=UDim2.fromOffset(14,14)
aa.Position=UDim2.fromScale(0.5,0.5)
aa.AnchorPoint=Vector2.new(0.5,0.5)
aa.BackgroundColor3=n.Text
aa.Parent=_
addCorner(aa,UDim.new(1,0))
H.Function=H.Function or function()end

if J.OptionsVisibilityChanged~=nil then
J.OptionsVisibilityChanged:Connect(function(ab)
if ab==nil then
ab=I.Visible
end
m:Tween(aa,TweenInfo.new(0.1,Enum.EasingStyle.Quad),{
Size=ab and UDim2.fromOffset(14,14)or UDim2.fromOffset(0,0)
})
end)
end

local ab=createSlider(
"Saturation",
ColorSequence.new{
ColorSequenceKeypoint.new(0,Color3.fromHSV(0,0,K.Value)),
ColorSequenceKeypoint.new(1,Color3.fromHSV(K.Hue,1,K.Value)),
}
)
local ac=createSlider(
"Vibrance",
ColorSequence.new{
ColorSequenceKeypoint.new(0,Color3.fromHSV(0,0,0)),
ColorSequenceKeypoint.new(1,Color3.fromHSV(K.Hue,K.Sat,1)),
}
)
local ad=createSlider(
"Opacity",
ColorSequence.new{
ColorSequenceKeypoint.new(0,l.Dark(n.Main,0.02)),
ColorSequenceKeypoint.new(1,Color3.fromHSV(K.Hue,K.Sat,K.Value)),
}
)

function K.Save(ae,af)
af[H.Name]={
Hue=ae.Hue,
Sat=ae.Sat,
Value=ae.Value,
Opacity=ae.Opacity,
Rainbow=ae.Rainbow,
}
end

function K.Load(ae,af)
if af.Rainbow~=ae.Rainbow then
ae:Toggle()
end
if ae.Hue~=af.Hue or ae.Sat~=af.Sat or ae.Value~=af.Value or ae.Opacity~=af.Opacity then
ae:SetValue(af.Hue,af.Sat,af.Value,af.Opacity,false)
end
end

function K.ConnectCallback(ae,af)
if not(af~=nil and type(af)=="function")then return end
if K._InternalCallback and shared.VoidDev then
warn(debug.traceback(`Overriding InternalCallback!!!`))
end
K._InternalCallback=wrap(af)
end

function K.SetValue(ae,af,ag,ah,ai)
ae.Hue=af or ae.Hue
ae.Sat=ag or ae.Sat
ae.Value=ah or ae.Value
ae.Opacity=ai or ae.Opacity
S.ImageColor3=Color3.fromHSV(ae.Hue,ae.Sat,ae.Value)
S.ImageTransparency=1-ae.Opacity
ab.Slider.UIGradient.Color=ColorSequence.new{
ColorSequenceKeypoint.new(0,Color3.fromHSV(0,0,ae.Value)),
ColorSequenceKeypoint.new(1,Color3.fromHSV(ae.Hue,1,ae.Value)),
}
ac.Slider.UIGradient.Color=ColorSequence.new{
ColorSequenceKeypoint.new(0,Color3.fromHSV(0,0,0)),
ColorSequenceKeypoint.new(1,Color3.fromHSV(ae.Hue,ae.Sat,1)),
}
ad.Slider.UIGradient.Color=ColorSequence.new{
ColorSequenceKeypoint.new(0,l.Dark(n.Main,0.02)),
ColorSequenceKeypoint.new(1,Color3.fromHSV(ae.Hue,ae.Sat,ae.Value)),
}

if ae.Rainbow then
R.Size=UDim2.fromScale(math.clamp(ae.Hue,0.04,0.96),1)
else
m:Tween(R,n.Tween,{
Size=UDim2.fromScale(math.clamp(ae.Hue,0.04,0.96),1),
})
end

if ag then
m:Tween(ab.Slider.Fill,n.Tween,{
Size=UDim2.fromScale(math.clamp(ae.Sat,0.04,0.96),1),
})
end
if ah then
m:Tween(ac.Slider.Fill,n.Tween,{
Size=UDim2.fromScale(math.clamp(ae.Value,0.04,0.96),1),
})
end
if ai then
m:Tween(ad.Slider.Fill,n.Tween,{
Size=UDim2.fromScale(math.clamp(ae.Opacity,0.04,0.96),1),
})
end

H.Function(ae.Hue,ae.Sat,ae.Value,ae.Opacity)
end

function K.ToColor(ae)
return Color3.fromHSV(ae.Hue,ae.Sat,ae.Value)
end

function K.Toggle(ae)
ae.Rainbow=not ae.Rainbow
if ae.Rainbow then
table.insert(c.RainbowTable,ae)
W.ImageColor3=Color3.fromRGB(5,127,100)
task.delay(0.1,function()
if not ae.Rainbow then
return
end
X.ImageColor3=Color3.fromRGB(228,125,43)
task.delay(0.1,function()
if not ae.Rainbow then
return
end
Y.ImageColor3=Color3.fromRGB(225,46,52)
end)
end)
else
local af=table.find(c.RainbowTable,ae)
if af then
table.remove(c.RainbowTable,af)
end
Y.ImageColor3=l.Light(n.Main,0.37)
task.delay(0.1,function()
if ae.Rainbow then
return
end
X.ImageColor3=l.Light(n.Main,0.37)
task.delay(0.1,function()
if ae.Rainbow then
return
end
W.ImageColor3=l.Light(n.Main,0.37)
end)
end)
end
end

local ae=tick()
S.Activated:Connect(function()
S.Visible=false
N.Visible=true
N:CaptureFocus()
local af=Color3.fromHSV(K.Hue,K.Sat,K.Value)
N.Text=math.round(af.R*255)
..", "
..math.round(af.G*255)
..", "
..math.round(af.B*255)
end)
L.InputBegan:Connect(function(af)
if
(
af.UserInputType==Enum.UserInputType.MouseButton1
or af.UserInputType==Enum.UserInputType.Touch
)and(af.Position.Y-L.AbsolutePosition.Y)>(20*z.Scale)
then
if ae>tick()then
K:Toggle()
end
ae=tick()+0.3
local ag=g.InputChanged:Connect(function(ag)
if
ag.UserInputType
==(
af.UserInputType==Enum.UserInputType.MouseButton1
and Enum.UserInputType.MouseMovement
or Enum.UserInputType.Touch
)
then
K:SetValue(
math.clamp((ag.Position.X-O.AbsolutePosition.X)/O.AbsoluteSize.X,0,1),
nil,nil,nil,true
)
if K._InternalCallback then
K._InternalCallback()
end
end
end)

local ah
ah=af.Changed:Connect(function()
if af.UserInputState==Enum.UserInputState.End then
if ag then
ag:Disconnect()
end
if ah then
ah:Disconnect()
end
end
end)
end
end)
L.MouseEnter:Connect(function()
m:Tween(aa,n.Tween,{
Size=UDim2.fromOffset(16,16),
})
end)
L.MouseLeave:Connect(function()
m:Tween(aa,n.Tween,{
Size=UDim2.fromOffset(14,14),
})
end)
L:GetPropertyChangedSignal"Visible":Connect(function()
ab.Visible=U.Rotation==180 and L.Visible
ac.Visible=ab.Visible
ad.Visible=ab.Visible
end)
T.MouseEnter:Connect(function()
U.ImageColor3=l.Dark(n.Text,0.16)
end)
T.MouseLeave:Connect(function()
U.ImageColor3=l.Dark(n.Text,0.43)
end)
T.Activated:Connect(function()
ab.Visible=not ab.Visible
ac.Visible=ab.Visible
ad.Visible=ab.Visible
U.Rotation=ab.Visible and 180 or 0
end)
V.Activated:Connect(function()
K:Toggle()
end)
N.FocusLost:Connect(function(af)
S.Visible=true
N.Visible=false
if af then
local ag=N.Text:split","
local ah,ai=pcall(function()
return tonumber(ag[1])
and Color3.fromRGB(tonumber(ag[1]),tonumber(ag[2]),tonumber(ag[3]))
or Color3.fromHex(N.Text)
end)
if ah then
if K.Rainbow then
K:Toggle()
end
K:SetValue(ai:ToHSV())
if K._InternalCallback then
K._InternalCallback()
end
end
end
end)

K.Object=L
J.Options[H.Name]=K

return K
end,
Dropdown=function(aa,ab,ac)
local ad
aa.List=aa.List or aa.Values
aa.Default=aa.Default or aa.Value
if not aa.List then
warn(`[gui - Dropdown]: optionsettings.List not set! Using default tbl`)
aa.List={}
end
if aa.Default and table.find(aa.List,aa.Default)then
ad=aa.Default
else
ad=aa.List[1]or"None"
end
local ae={
Type="Dropdown",
Value=ad,
Index=0,
}

local af=Instance.new"TextButton"
af.Name=aa.Name.."Dropdown"
af.Size=aa.Size or UDim2.new(1,0,0,40)
af.BackgroundColor3=l.Dark(ab.BackgroundColor3,aa.Darker and 0.02 or 0)
af.BorderSizePixel=0
af.AutoButtonColor=false
af.Visible=aa.Visible==nil or aa.Visible
af.Text=""
af.Parent=ab
addTooltip(af,aa.Tooltip or aa.Name)
local ag=Instance.new"Frame"
ag.Name="BKG"
ag.Size=UDim2.new(1,-20,1,-9)
ag.Position=UDim2.fromOffset(10,4)
ag.BackgroundColor3=l.Light(n.Main,0.034)
ag.Parent=af
addCorner(ag,UDim.new(0,6))
local ah=Instance.new"UIStroke"
ah.Name="GlowStroke"
ah.Thickness=2
ah.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
ah.Color=l.Light(n.Main,0.35)
ah.Transparency=1
ah.Parent=ag
local ai=Instance.new"TextButton"
ai.Name="Dropdown"
ai.Size=UDim2.new(1,-2,1,-2)
ai.Position=UDim2.fromOffset(1,1)
ai.BackgroundColor3=n.Main
ai.AutoButtonColor=false
ai.Text=""
ai.Parent=ag
local H=Instance.new"TextLabel"
H.Name="Title"
H.Size=UDim2.new(1,0,0,29)
H.BackgroundTransparency=1
H.Text="         "..aa.Name.." - "..ae.Value
H.TextXAlignment=Enum.TextXAlignment.Left
H.TextColor3=l.Dark(n.Text,0.16)
H.TextSize=13
H.TextTruncate=Enum.TextTruncate.AtEnd
H.FontFace=n.Font
H.Parent=ai
addCorner(ai,UDim.new(0,6))
local I=Instance.new"ImageLabel"
I.Name="Arrow"
I.Size=UDim2.fromOffset(4,8)
I.Position=UDim2.new(1,-17,0,11)
I.BackgroundTransparency=1
I.Image=t"vape/assets/new/expandright.png"
I.ImageColor3=Color3.fromRGB(140,140,140)
I.Rotation=90
I.Parent=ai
aa.Function=aa.Function or function()end
local J
local K

function ae.Save(L,M)
if aa.NoSave then
return
end
M[aa.Name]={Value=L.Value}
end

function ae.Load(L,M)
if aa.NoSave then
return
end
if L.Value~=M.Value then
L:SetValue(M.Value)
end
end

function ae.Change(L,M,N)
aa.List=M or{}
if not N and not table.find(aa.List,L.Value)then
L:SetValue(L.Value)
end
end

function ae.SetValues(L,M,N)
if N then
L.Value=(type(N)=="string"and N)or"None"
end
L:Change(M,N~=nil)
end

function ae.SetCallback(L,M)
if not(M~=nil and type(M)=="function")then
return
end
aa.Function=M
end

function ae.SetValue(L,M,N)
L.Value=table.find(aa.List,M)and M or aa.List[1]or"None"
H.Text="         "..aa.Name.." - "..L.Value
if J then
I.Rotation=90
J:Destroy()
J=nil
af.Size=aa.Size or UDim2.new(1,0,0,40)
end
pcall(function()
ab.Parent.ScrollingEnabled=true
end)
aa.Function(L.Value,N)
end

ai.Activated:Connect(function()
if not J then
I.Rotation=270

local L=7

J=Instance.new"Frame"
J.Name="Children"
J.BackgroundTransparency=1
J.Position=UDim2.fromOffset(0,27)
J.Parent=ai

local M=Instance.new"ScrollingFrame"
M.Name="Scroll"
M.BackgroundTransparency=1
M.ScrollBarImageTransparency=0.5
M.ScrollBarThickness=4
M.CanvasSize=UDim2.new(0,0,0,0)
M.Size=UDim2.new(1,0,0,0)
M.AutomaticCanvasSize=Enum.AutomaticSize.Y
M.ScrollingDirection=Enum.ScrollingDirection.Y
M.Parent=J
K=M

M.MouseEnter:Connect(function()
pcall(function()
ab.Parent.ScrollingEnabled=false
end)
end)
M.MouseLeave:Connect(function()
pcall(function()
ab.Parent.ScrollingEnabled=true
end)
end)

local N
local O=true

if O then
N=Instance.new"TextBox"
N.Name="SearchBar"
N.Size=UDim2.new(1,0,0,26)
N.BackgroundColor3=l.Light(n.Main,0.02)
N.PlaceholderText=" Search..."
N.Text=""
N.TextColor3=n.Text
N.TextSize=13
N.FontFace=n.Font
N.ClearTextOnFocus=false
N.Parent=J
addTooltip(N,"Type to search options")

addCorner(N,UDim.new(0,6))
end

local P=Instance.new"TextLabel"
P.Name="NoResults"
P.Size=UDim2.new(1,0,0,O and 26 or 0)
P.Position=UDim2.fromOffset(0,0)
P.BackgroundTransparency=1
P.Text="  No Results Found"
P.TextColor3=Color3.fromRGB(150,150,150)
P.TextSize=13
P.FontFace=n.Font
P.Visible=false
P.TextXAlignment=Enum.TextXAlignment.Left
P.Parent=M

local Q={}

local R=O and 1 or 0
for S,T in aa.List do
local U=Instance.new"TextButton"
U.Name=T.."Option"
U.Size=UDim2.new(1,0,0,26)
U.Position=UDim2.fromOffset(0,R*26)
U.BackgroundColor3=n.Main
U.BorderSizePixel=0
U.AutoButtonColor=false
U.Text="   "..T
U.TextColor3=n.Text
U.TextXAlignment=Enum.TextXAlignment.Left
U.TextSize=13
U.FontFace=n.Font
U.Parent=M
addTooltip(U,T)

U.MouseEnter:Connect(function()
m:Tween(U,n.Tween,{
BackgroundColor3=l.Light(n.Main,0.04),
})
end)
U.MouseLeave:Connect(function()
m:Tween(U,n.Tween,{
BackgroundColor3=n.Main,
})
end)

U.Activated:Connect(function()
ae:SetValue(T,true)
end)

Q[#Q+1]={Button=U,Name=T}
R+=1
end

local function Filter(S)
if not O then
for T,U in Q do
local V=U.Button
V.Visible=true
V.TextTransparency=0
V.BackgroundTransparency=0
end

P.Visible=false

af.Size=aa.Size~=nil and aa.Size+UDim2.fromOffset(0,#Q*26)or UDim2.new(1,0,0,40+(#Q*26))
J.Size=aa.Size~=nil and UDim2.new(aa.Size.X.Scale,aa.Size.X.Offset,aa.Size.Y.Scale,0)+UDim2.fromOffset(0,#Q*26)or UDim2.new(1,0,0,#Q*26)
return
end

S=S:lower()

local T=0
local U=false

for V,W in Q do
local X=W.Button
local Y=W.Name:lower()
local Z=(S==""or Y:find(S))

X.Visible=Z
if Z then
U=true
T+=1

X.Position=UDim2.fromOffset(0,(T-1)*26)

X.TextTransparency=0
X.BackgroundTransparency=0
else
X.TextTransparency=0.6
X.BackgroundTransparency=0.3
end
end

if not U and O then
P.Visible=true
else
P.Visible=false
end

local V=T>0 and T or 1

local W=L*26
local X=O and 26 or 0
local Y=math.min(W,V*26)
af.Size=aa.Size and aa.Size+UDim2.fromOffset(0,X+Y)or UDim2.new(1,0,0,40+X+Y)
J.Size=UDim2.new(1,0,0,X+Y)

M.Position=UDim2.fromOffset(0,X)
M.Size=UDim2.new(1,0,0,Y)
end

if O then
N:GetPropertyChangedSignal"Text":Connect(function()
Filter(N.Text)
end)
end

Filter""
else
ae:SetValue(ae.Value,true)
end
end)

af.MouseEnter:Connect(function()
m:Tween(ag,n.Tween,{
BackgroundColor3=l.Light(n.Main,0.0875),
})
m:Tween(ah,n.Tween,{
Transparency=0.15,
})
end)
af.MouseLeave:Connect(function()
m:Tween(ag,n.Tween,{
BackgroundColor3=l.Light(n.Main,0.034),
})
m:Tween(ah,n.Tween,{
Transparency=1,
})
end)

ae.Object=af
ac.Options[aa.Name]=ae

return ae
end,
Font=function(aa,ab,ac)
local ad={
aa.Blacklist,
"Custom",
}
for ae,af in Enum.Font:GetEnumItems()do
if not table.find(ad,af.Name)then
table.insert(ad,af.Name)
end
end

local ae={Value=Font.fromEnum(Enum.Font[ad[1] ])}
local af
local ag
aa.Function=aa.Function or function()end

af=G.Dropdown({
Name=aa.Name,
List=ad,
Function=function(ah)
ag.Object.Visible=ah=="Custom"and af.Object.Visible
if ah~="Custom"then
ae.Value=Font.fromEnum(Enum.Font[ah])
aa.Function(ae.Value)
else
pcall(function()
ae.Value=Font.fromId(tonumber(ag.Value))
end)
aa.Function(ae.Value)
end
end,
Darker=aa.Darker,
Visible=aa.Visible,
Default=aa.Default,
},ab,ac)
ae.Object=af.Object
ag=G.TextBox({
Name=aa.Name.." Asset",
Placeholder="font (rbxasset)",
Function=function()
if af.Value=="Custom"then
pcall(function()
ae.Value=Font.fromId(tonumber(ag.Value))
end)
aa.Function(ae.Value)
end
end,
Visible=false,
Darker=true,
},ab,ac)

af.Object:GetPropertyChangedSignal"Visible":Connect(function()
ag.Object.Visible=af.Object.Visible and af.Value=="Custom"
end)

return ae
end,
Slider=function(aa,ab,ac)
local ad={
Type="Slider",
Value=aa.Default or aa.Min,
Max=aa.Max,
Index=getTableSize(ac.Options),
}

local ae=Instance.new"TextButton"
ae.Name=aa.Name.."Slider"
ae.Size=UDim2.new(1,0,0,50)
ae.BackgroundColor3=l.Dark(ab.BackgroundColor3,aa.Darker and 0.02 or 0)
ae.BorderSizePixel=0
ae.AutoButtonColor=false
ae.Visible=aa.Visible==nil or aa.Visible
ae.Text=""
ae.Parent=ab
addTooltip(ae,aa.Tooltip)
local af=Instance.new"TextLabel"
af.Name="Title"
af.Size=UDim2.fromOffset(60,30)
af.Position=UDim2.fromOffset(10,2)
af.BackgroundTransparency=1
af.Text=aa.Name
af.TextXAlignment=Enum.TextXAlignment.Left
af.TextColor3=l.Dark(n.Text,0.16)
af.TextSize=11
af.FontFace=n.Font
af.Parent=ae
local ag=Instance.new"TextButton"
ag.Name="Value"
ag.Size=UDim2.fromOffset(60,15)
ag.Position=UDim2.new(1,-69,0,9)
ag.BackgroundTransparency=1
ag.Text=ad.Value
..(
aa.Suffix
and" "..(type(aa.Suffix)=="function"and aa.Suffix(ad.Value)or aa.Suffix)
or""
)
ag.TextXAlignment=Enum.TextXAlignment.Right
ag.TextColor3=l.Dark(n.Text,0.16)
ag.TextSize=11
ag.FontFace=n.Font
ag.Parent=ae
local ah=Instance.new"TextBox"
ah.Name="Box"
ah.Size=ag.Size
ah.Position=ag.Position
ah.BackgroundTransparency=1
ah.Visible=false
ah.Text=ad.Value
ah.TextXAlignment=Enum.TextXAlignment.Right
ah.TextColor3=l.Dark(n.Text,0.16)
ah.TextSize=11
ah.FontFace=n.Font
ah.ClearTextOnFocus=false
ah.Parent=ae
local ai=Instance.new"Frame"
ai.Name="Slider"
ai.Size=UDim2.new(1,-20,0,2)
ai.Position=UDim2.fromOffset(10,37)
ai.BackgroundColor3=l.Light(n.Main,0.034)
ai.BorderSizePixel=0
ai.Parent=ae
local H=ai:Clone()
H.Name="Fill"
H.Size=
UDim2.fromScale(math.clamp((ad.Value-aa.Min)/aa.Max,0.04,0.96),1)
H.Position=UDim2.new()
H.BackgroundColor3=Color3.fromHSV(c.GUIColor.Hue,c.GUIColor.Sat,c.GUIColor.Value)
H.Parent=ai
local I=Instance.new"Frame"
I.Name="Knob"
I.Size=UDim2.fromOffset(24,4)
I.Position=UDim2.fromScale(1,0.5)
I.AnchorPoint=Vector2.new(0.5,0.5)
I.BackgroundColor3=ae.BackgroundColor3
I.BorderSizePixel=0
I.Parent=H
local J=Instance.new"Frame"
J.Name="Knob"
J.Size=UDim2.fromOffset(14,14)
J.Position=UDim2.fromScale(0.5,0.5)
J.AnchorPoint=Vector2.new(0.5,0.5)
J.BackgroundColor3=Color3.fromHSV(c.GUIColor.Hue,c.GUIColor.Sat,c.GUIColor.Value)
J.Parent=I
addCorner(J,UDim.new(1,0))
aa.Function=aa.Function or function()end
aa.Decimal=aa.Decimal or 1

if ac.OptionsVisibilityChanged~=nil then
ac.OptionsVisibilityChanged:Connect(function(K)
if K==nil then
K=ab.Visible
end
m:Tween(J,TweenInfo.new(0.1,Enum.EasingStyle.Quad),{
Size=K and UDim2.fromOffset(14,14)or UDim2.fromOffset(0,0)
})
end)
end

function ad.Save(K,L)
L[aa.Name]={
Value=K.Value,
Max=K.Max,
}
end

function ad.Load(K,L)
local M=L.Value==L.Max and L.Max~=K.Max and K.Max or L.Value
if K.Value~=M then
K:SetValue(M,nil,true)
end
end

function ad.Color(K,L,M,N,O)
H.BackgroundColor3=O and Color3.fromHSV(c:Color((L-(K.Index*0.075))%1))
or Color3.fromHSV(L,M,N)
J.BackgroundColor3=H.BackgroundColor3
end

function ad.SetValue(K,L,M,N)
if tonumber(L)==math.huge or L~=L then
return
end
local O=K.Value~=L
K.Value=L
m:Tween(H,n.Tween,{
Size=UDim2.fromScale(math.clamp(M or math.clamp(L/aa.Max,0,1),0.04,0.96),1),
})
ag.Text=K.Value
..(
aa.Suffix
and" "..(type(aa.Suffix)=="function"and aa.Suffix(K.Value)or aa.Suffix)
or""
)
if O or N then
aa.Function(L,N)
end
end

ae.InputBegan:Connect(function(K)
if
(
K.UserInputType==Enum.UserInputType.MouseButton1
or K.UserInputType==Enum.UserInputType.Touch
)and(K.Position.Y-ae.AbsolutePosition.Y)>(20*z.Scale)
then
local L=
math.clamp((K.Position.X-ai.AbsolutePosition.X)/ai.AbsoluteSize.X,0,1)
ad:SetValue(
math.floor(
(aa.Min+(aa.Max-aa.Min)*L)
*aa.Decimal
)/aa.Decimal,
L
)
local M=ad.Value
local N=L

local O=g.InputChanged:Connect(function(O)
if
O.UserInputType
==(
K.UserInputType==Enum.UserInputType.MouseButton1
and Enum.UserInputType.MouseMovement
or Enum.UserInputType.Touch
)
then
local P=
math.clamp((O.Position.X-ai.AbsolutePosition.X)/ai.AbsoluteSize.X,0,1)
ad:SetValue(
math.floor(
(aa.Min+(aa.Max-aa.Min)*P)
*aa.Decimal
)/aa.Decimal,
P
)
M=ad.Value
N=P
end
end)

local P
P=K.Changed:Connect(function()
if K.UserInputState==Enum.UserInputState.End then
if O then
O:Disconnect()
end
if P then
P:Disconnect()
end
ad:SetValue(M,N,true)
end
end)
end
end)
ae.MouseEnter:Connect(function()
m:Tween(J,n.Tween,{
Size=UDim2.fromOffset(16,16),
})
end)
ae.MouseLeave:Connect(function()
m:Tween(J,n.Tween,{
Size=UDim2.fromOffset(14,14),
})
end)
ag.Activated:Connect(function()
ag.Visible=false
ah.Visible=true
ah.Text=ad.Value
ah:CaptureFocus()
end)
ah.FocusLost:Connect(function(K)
ag.Visible=true
ah.Visible=false
if K and tonumber(ah.Text)then
ad:SetValue(tonumber(ah.Text),nil,true)
end
end)

ad.Object=ae
ac.Options[aa.Name]=ad

return ad
end,
Targets=function(aa,ab,ac)
local ad={
Type="Targets",
Index=getTableSize(ac.Options),
}

local ae=Instance.new"TextButton"
ae.Name="Targets"
ae.Size=UDim2.new(1,0,0,50)
ae.BackgroundColor3=l.Dark(ab.BackgroundColor3,aa.Darker and 0.02 or 0)
ae.BorderSizePixel=0
ae.AutoButtonColor=false
ae.Visible=aa.Visible==nil or aa.Visible
ae.Text=""
ae.Parent=ab
addTooltip(ae,aa.Tooltip)
local af=Instance.new"Frame"
af.Name="BKG"
af.Size=UDim2.new(1,-20,1,-9)
af.Position=UDim2.fromOffset(10,4)
af.BackgroundColor3=l.Light(n.Main,0.034)
af.Parent=ae
addCorner(af,UDim.new(0,4))
local ag=Instance.new"TextButton"
ag.Name="TextList"
ag.Size=UDim2.new(1,-2,1,-2)
ag.Position=UDim2.fromOffset(1,1)
ag.BackgroundColor3=n.Main
ag.AutoButtonColor=false
ag.Text=""
ag.Parent=af
local ah=Instance.new"TextLabel"
ah.Name="Title"
ah.Size=UDim2.new(1,-5,0,15)
ah.Position=UDim2.fromOffset(5,6)
ah.BackgroundTransparency=1
ah.Text="Target:"
ah.TextXAlignment=Enum.TextXAlignment.Left
ah.TextColor3=l.Dark(n.Text,0.16)
ah.TextSize=15
ah.TextTruncate=Enum.TextTruncate.AtEnd
ah.FontFace=n.Font
ah.Parent=ag
local ai=ah:Clone()
ai.Name="Items"
ai.Position=UDim2.fromOffset(5,21)
ai.Text="Ignore none"
ai.TextColor3=l.Dark(n.Text,0.16)
ai.TextSize=11
ai.Parent=ag
addCorner(ag,UDim.new(0,4))
local H=Instance.new"Frame"
H.Size=UDim2.fromOffset(65,12)
H.Position=UDim2.fromOffset(52,8)
H.BackgroundTransparency=1
H.Parent=ag
local I=Instance.new"UIListLayout"
I.FillDirection=Enum.FillDirection.Horizontal
I.Padding=UDim.new(0,6)
I.Parent=H
local J=Instance.new"TextButton"
J.Name="TargetsTextWindow"
J.Size=UDim2.fromOffset(220,145)
J.BackgroundColor3=n.Main
J.BorderSizePixel=0
J.AutoButtonColor=false
J.Visible=false
J.Text=""
J.Parent=u
ad.Window=J
addBlur(J)
addCorner(J)
local K=Instance.new"ImageLabel"
K.Name="Icon"
K.Size=UDim2.fromOffset(18,12)
K.Position=UDim2.fromOffset(10,15)
K.BackgroundTransparency=1
K.Image=t"vape/assets/new/targetstab.png"
K.Parent=J
local L=Instance.new"TextLabel"
L.Name="Title"
L.Size=UDim2.new(1,-36,0,20)
L.Position=UDim2.fromOffset(math.abs(L.Size.X.Offset),11)
L.BackgroundTransparency=1
L.Text="Target settings"
L.TextXAlignment=Enum.TextXAlignment.Left
L.TextColor3=n.Text
L.TextSize=13
L.FontFace=n.Font
L.Parent=J
local M=addCloseButton(J)
aa.Function=aa.Function or function()end

function ad.Save(N,O)
O.Targets={
Players=N.Players.Enabled,
NPCs=N.NPCs.Enabled,
Invisible=N.Invisible.Enabled,
Walls=N.Walls.Enabled,
}
end

function ad.Load(N,O)
if N.Players.Enabled~=O.Players then
N.Players:Toggle()
end
if N.NPCs.Enabled~=O.NPCs then
N.NPCs:Toggle()
end
if N.Invisible.Enabled~=O.Invisible then
N.Invisible:Toggle()
end
if N.Walls.Enabled~=O.Walls then
N.Walls:Toggle()
end
end

function ad.Color(N,O,P,Q,R)
af.BackgroundColor3=R and Color3.fromHSV(c:Color((O-(N.Index*0.075))%1))
or Color3.fromHSV(O,P,Q)
if N.Players.Enabled then
m:Cancel(N.Players.Object.Frame)
N.Players.Object.Frame.BackgroundColor3=Color3.fromHSV(O,P,Q)
end
if N.NPCs.Enabled then
m:Cancel(N.NPCs.Object.Frame)
N.NPCs.Object.Frame.BackgroundColor3=Color3.fromHSV(O,P,Q)
end
if N.Invisible.Enabled then
m:Cancel(N.Invisible.Object.Knob)
N.Invisible.Object.Knob.BackgroundColor3=Color3.fromHSV(O,P,Q)
end
if N.Walls.Enabled then
m:Cancel(N.Walls.Object.Knob)
N.Walls.Object.Knob.BackgroundColor3=Color3.fromHSV(O,P,Q)
end
end

ad.Players=G.TargetsButton({
Position=UDim2.fromOffset(11,45),
Icon=t"vape/assets/new/targetplayers1.png",
IconSize=UDim2.fromOffset(15,16),
IconParent=H,
ToolIcon=t"vape/assets/new/targetplayers2.png",
ToolSize=UDim2.fromOffset(11,12),
Tooltip="Players",
Function=aa.Function,
},J,H)
ad.NPCs=G.TargetsButton({
Position=UDim2.fromOffset(112,45),
Icon=t"vape/assets/new/targetnpc1.png",
IconSize=UDim2.fromOffset(12,16),
IconParent=H,
ToolIcon=t"vape/assets/new/targetnpc2.png",
ToolSize=UDim2.fromOffset(9,12),
Tooltip="NPCs",
Function=aa.Function,
},J,H)
ad.Invisible=G.Toggle({
Name="Ignore invisible",
Function=function()
local N="none"
if ad.Invisible.Enabled then
N="invisible"
end
if ad.Walls.Enabled then
N=N=="none"and"behind walls"or N..", behind walls"
end
ai.Text="Ignore "..N
aa.Function()
end,
},J,{Options={}})
ad.Invisible.Object.Position=UDim2.fromOffset(0,81)
ad.Walls=G.Toggle({
Name="Ignore behind walls",
Function=function()
local N="none"
if ad.Invisible.Enabled then
N="invisible"
end
if ad.Walls.Enabled then
N=N=="none"and"behind walls"or N..", behind walls"
end
ai.Text="Ignore "..N
aa.Function()
end,
},J,{Options={}})
ad.Walls.Object.Position=UDim2.fromOffset(0,111)
if aa.Players then
ad.Players:Toggle()
end
if aa.NPCs then
ad.NPCs:Toggle()
end
if aa.Invisible then
ad.Invisible:Toggle()
end
if aa.Walls then
ad.Walls:Toggle()
end

M.Activated:Connect(function()
J.Visible=false
end)
ag.Activated:Connect(function()
J.Visible=not J.Visible
m:Cancel(af)
af.BackgroundColor3=J.Visible
and Color3.fromHSV(c.GUIColor.Hue,c.GUIColor.Sat,c.GUIColor.Value)
or l.Light(n.Main,0.37)
end)
ae.MouseEnter:Connect(function()
if not ad.Window.Visible then
m:Tween(af,n.Tween,{
BackgroundColor3=l.Light(n.Main,0.37),
})
end
end)
ae.MouseLeave:Connect(function()
if not ad.Window.Visible then
m:Tween(af,n.Tween,{
BackgroundColor3=l.Light(n.Main,0.034),
})
end
end)
ae:GetPropertyChangedSignal"AbsolutePosition":Connect(function()
if c.ThreadFix then
setthreadidentity(8)
end
local N=(ae.AbsolutePosition+Vector2.new(0,60))/z.Scale
J.Position=UDim2.fromOffset(N.X+220,N.Y)
end)

ad.Object=ae
ac.Options.Targets=ad

return ad
end,
TargetsButton=function(aa,ab,ac)
local ad={Enabled=false}

local ae=Instance.new"TextButton"
ae.Size=UDim2.fromOffset(98,31)
ae.Position=aa.Position
ae.BackgroundColor3=l.Light(n.Main,0.05)
ae.AutoButtonColor=false
ae.Visible=aa.Visible==nil or aa.Visible
ae.Text=""
ae.Parent=ab
addCorner(ae)
addTooltip(ae,aa.Tooltip)
local af=Instance.new"Frame"
af.Size=UDim2.new(1,-2,1,-2)
af.Position=UDim2.fromOffset(1,1)
af.BackgroundColor3=n.Main
af.Parent=ae
addCorner(af)
local ag=Instance.new"ImageLabel"
ag.Size=aa.IconSize
ag.Position=UDim2.fromScale(0.5,0.5)
ag.AnchorPoint=Vector2.new(0.5,0.5)
ag.BackgroundTransparency=1
ag.Image=aa.Icon
ag.ImageColor3=l.Light(n.Main,0.37)
ag.Parent=af
aa.Function=aa.Function or function()end
local ah

function ad.Toggle(ai)
ai.Enabled=not ai.Enabled
m:Tween(af,n.Tween,{
BackgroundColor3=ai.Enabled
and Color3.fromHSV(c.GUIColor.Hue,c.GUIColor.Sat,c.GUIColor.Value)
or n.Main,
})
m:Tween(ag,n.Tween,{
ImageColor3=ai.Enabled and Color3.new(1,1,1)or l.Light(n.Main,0.37),
})
if ah then
ah:Destroy()
end
if ai.Enabled then
ah=Instance.new"ImageLabel"
ah.Size=aa.ToolSize
ah.BackgroundTransparency=1
ah.Image=aa.ToolIcon
ah.ImageColor3=n.Text
ah.Parent=aa.IconParent
end
aa.Function(ai.Enabled)
end

ae.MouseEnter:Connect(function()
if not ad.Enabled then
m:Tween(af,n.Tween,{
BackgroundColor3=Color3.fromHSV(
c.GUIColor.Hue,
c.GUIColor.Sat,
c.GUIColor.Value-0.25
),
})
m:Tween(ag,n.Tween,{
ImageColor3=Color3.new(1,1,1),
})
end
end)
ae.MouseLeave:Connect(function()
if not ad.Enabled then
m:Tween(af,n.Tween,{
BackgroundColor3=n.Main,
})
m:Tween(ag,n.Tween,{
ImageColor3=l.Light(n.Main,0.37),
})
end
end)
ae.Activated:Connect(function()
ad:Toggle()
end)

ad.Object=ae

return ad
end,
TextBox=function(aa,ab,ac)
local ad={
Type="TextBox",
Value=aa.Default or"",
Index=0,
}

local ae=Instance.new"TextButton"
ae.Name=aa.Name.."TextBox"
ae.Size=UDim2.new(1,0,0,58)
ae.BackgroundColor3=l.Dark(ab.BackgroundColor3,aa.Darker and 0.02 or 0)
ae.BorderSizePixel=0
ae.AutoButtonColor=false
ae.Visible=aa.Visible==nil or aa.Visible
ae.Text=""
ae.Parent=ab
addTooltip(ae,aa.Tooltip)
local af=Instance.new"TextLabel"
af.Size=UDim2.new(1,-10,0,20)
af.Position=UDim2.fromOffset(10,3)
af.BackgroundTransparency=1
af.Text=aa.Name
af.TextXAlignment=Enum.TextXAlignment.Left
af.TextColor3=n.Text
af.TextSize=12
af.FontFace=n.Font
af.Parent=ae
local ag=Instance.new"Frame"
ag.Name="BKG"
ag.Size=UDim2.new(1,-20,0,29)
ag.Position=UDim2.fromOffset(10,23)
ag.BackgroundColor3=l.Light(n.Main,0.02)
ag.Parent=ae
addCorner(ag,UDim.new(0,4))
local ah=Instance.new"TextBox"
ah.Size=UDim2.new(1,-8,1,0)
ah.Position=UDim2.fromOffset(8,0)
ah.BackgroundTransparency=1
ah.Text=aa.Default or""
ah.PlaceholderText=aa.Placeholder or"Click to set"
ah.TextXAlignment=Enum.TextXAlignment.Left
ah.TextColor3=l.Dark(n.Text,0.16)
ah.PlaceholderColor3=l.Dark(n.Text,0.31)
ah.TextSize=12
ah.FontFace=n.Font
ah.ClearTextOnFocus=false
ah.Parent=ag
aa.Function=aa.Function or function()end

function ad.Save(ai,H)
H[aa.Name]={Value=ai.Value}
end

function ad.Load(ai,H)
if ai.Value~=H.Value then
ai:SetValue(H.Value)
end
end

function ad.SetValue(ai,H,I)
ai.Value=H
ah.Text=H
aa.Function(I)
end

ae.Activated:Connect(function()
ah:CaptureFocus()
end)
ah.FocusLost:Connect(function(ai)
ad:SetValue(ah.Text,ai)
end)
ah:GetPropertyChangedSignal"Text":Connect(function()
ad:SetValue(ah.Text)
end)

ad.Object=ae
ac.Options[aa.Name]=ad

return ad
end,
TextList=function(aa,ab,ac)
local ad={
Type="TextList",
List=aa.Default or{},
ListEnabled=aa.Default or{},
Objects={},
Window={Visible=false},
Index=getTableSize(ac.Options),
}
aa.Color=aa.Color or Color3.fromRGB(5,134,105)

local ae=Instance.new"TextButton"
ae.Name=aa.Name.."TextList"
ae.Size=UDim2.new(1,0,0,50)
ae.BackgroundColor3=l.Dark(ab.BackgroundColor3,aa.Darker and 0.02 or 0)
ae.BorderSizePixel=0
ae.AutoButtonColor=false
ae.Visible=aa.Visible==nil or aa.Visible
ae.Text=""
ae.Parent=ab
addTooltip(ae,aa.Tooltip)
local af=Instance.new"Frame"
af.Name="BKG"
af.Size=UDim2.new(1,-20,1,-9)
af.Position=UDim2.fromOffset(10,4)
af.BackgroundColor3=l.Light(n.Main,0.034)
af.Parent=ae
addCorner(af,UDim.new(0,4))
local ag=Instance.new"TextButton"
ag.Name="TextList"
ag.Size=UDim2.new(1,-2,1,-2)
ag.Position=UDim2.fromOffset(1,1)
ag.BackgroundColor3=n.Main
ag.AutoButtonColor=false
ag.Text=""
ag.Parent=af
local ah=Instance.new"ImageLabel"
ah.Name="Icon"
ah.Size=UDim2.fromOffset(14,12)
ah.Position=UDim2.fromOffset(10,14)
ah.BackgroundTransparency=1
ah.Image=aa.Icon or t"vape/assets/new/allowedicon.png"
ah.Parent=ag
local ai=Instance.new"TextLabel"
ai.Name="Title"
ai.Size=UDim2.new(1,-35,0,15)
ai.Position=UDim2.fromOffset(35,6)
ai.BackgroundTransparency=1
ai.Text=aa.Name
ai.TextXAlignment=Enum.TextXAlignment.Left
ai.TextColor3=l.Dark(n.Text,0.16)
ai.TextSize=15
ai.TextTruncate=Enum.TextTruncate.AtEnd
ai.FontFace=n.Font
ai.Parent=ag
local H=ai:Clone()
H.Name="Amount"
H.Size=UDim2.new(1,-13,0,15)
H.Position=UDim2.fromOffset(0,6)
H.Text="0"
H.TextXAlignment=Enum.TextXAlignment.Right
H.Parent=ag
local I=ai:Clone()
I.Name="Items"
I.Position=UDim2.fromOffset(35,21)
I.Text="None"
I.TextColor3=l.Dark(n.Text,0.43)
I.TextSize=11
I.Parent=ag
addCorner(ag,UDim.new(0,4))

local J=400
local K=85
local L=35
local M=math.floor((J-K)/L)

local N=Instance.new"TextButton"
N.Name=aa.Name.."TextWindow"
N.Size=UDim2.fromOffset(220,K)
N.BackgroundColor3=n.Main
N.BorderSizePixel=0
N.AutoButtonColor=false
N.Visible=false
N.Text=""
N.ClipsDescendants=true
N.Parent=ac.Legit and c.Legit.Window or u
ad.Window=N
addBlur(N)
addCorner(N)

local O=Instance.new"ImageLabel"
O.Name="Icon"
O.Size=aa.TabSize or UDim2.fromOffset(19,16)
O.Position=UDim2.fromOffset(10,13)
O.BackgroundTransparency=1
O.Image=aa.Tab or t"vape/assets/new/allowedtab.png"
O.Parent=N
local P=Instance.new"TextLabel"
P.Name="Title"
P.Size=UDim2.new(1,-36,0,20)
P.Position=UDim2.fromOffset(math.abs(P.Size.X.Offset),11)
P.BackgroundTransparency=1
P.Text=aa.Name
P.TextXAlignment=Enum.TextXAlignment.Left
P.TextColor3=n.Text
P.TextSize=13
P.FontFace=n.Font
P.Parent=N
local Q=addCloseButton(N)

local R=Instance.new"Frame"
R.Name="Add"
R.Size=UDim2.fromOffset(200,31)
R.Position=UDim2.fromOffset(10,45)
R.BackgroundColor3=l.Light(n.Main,0.02)
R.Parent=N
addCorner(R)
local S=R:Clone()
S.Size=UDim2.new(1,-2,1,-2)
S.Position=UDim2.fromOffset(1,1)
S.BackgroundColor3=l.Dark(n.Main,0.02)
S.Parent=R
local T=Instance.new"TextBox"
T.Size=UDim2.new(1,-35,1,0)
T.Position=UDim2.fromOffset(10,0)
T.BackgroundTransparency=1
T.Text=""
T.PlaceholderText=aa.Placeholder or"Add entry..."
T.TextXAlignment=Enum.TextXAlignment.Left
T.TextColor3=Color3.new(1,1,1)
T.TextSize=15
T.FontFace=n.Font
T.ClearTextOnFocus=false
T.Parent=R
local U=Instance.new"ImageButton"
U.Name="AddButton"
U.Size=UDim2.fromOffset(16,16)
U.Position=UDim2.new(1,-26,0,8)
U.BackgroundTransparency=1
U.Image=t"vape/assets/new/add.png"
U.ImageColor3=aa.Color
U.ImageTransparency=0.3
U.Parent=R


local V=Instance.new"Frame"
V.Name="SearchBKG"
V.Size=UDim2.fromOffset(200,31)
V.Position=UDim2.fromOffset(10,82)
V.BackgroundColor3=l.Light(n.Main,0.02)
V.Parent=N
addCorner(V)
local W=V:Clone()
W.Size=UDim2.new(1,-2,1,-2)
W.Position=UDim2.fromOffset(1,1)
W.BackgroundColor3=l.Dark(n.Main,0.02)
W.Parent=V
local X=Instance.new"TextBox"
X.Name="SearchBox"
X.Size=UDim2.new(1,-20,1,0)
X.Position=UDim2.fromOffset(10,0)
X.BackgroundTransparency=1
X.Text=""
X.PlaceholderText="Search..."
X.TextXAlignment=Enum.TextXAlignment.Left
X.TextColor3=Color3.new(1,1,1)
X.TextSize=13
X.FontFace=n.Font
X.ClearTextOnFocus=false
X.Parent=V
addTooltip(V,"Type to search entries")

local Y=Instance.new"ScrollingFrame"
Y.Name="ItemScroll"
Y.Size=UDim2.fromOffset(200,0)
Y.Position=UDim2.fromOffset(10,119)
Y.BackgroundTransparency=1
Y.BorderSizePixel=0
Y.ScrollBarThickness=4
Y.ScrollBarImageTransparency=0.5
Y.CanvasSize=UDim2.new(0,0,0,0)
Y.AutomaticCanvasSize=Enum.AutomaticSize.Y
Y.ScrollingDirection=Enum.ScrollingDirection.Y
Y.Parent=N

local Z=Instance.new"TextLabel"
Z.Name="NoResults"
Z.Size=UDim2.new(1,0,0,40)
Z.Position=UDim2.fromOffset(0,0)
Z.BackgroundTransparency=1
Z.Text="No Results Found"
Z.TextColor3=Color3.fromRGB(150,150,150)
Z.TextSize=13
Z.FontFace=n.Font
Z.Visible=false
Z.Parent=Y

aa.Function=aa.Function or function()end

function ad.Save(_,aj)
aj[aa.Name]={
List=_.List,
ListEnabled=_.ListEnabled,
}
end

function ad.Load(aj,_)
aj.List=_.List or{}
aj.ListEnabled=_.ListEnabled or{}
aj:ChangeValue()
end

function ad.Color(aj,_,ak,al,am)
if N.Visible then
af.BackgroundColor3=am and Color3.fromHSV(c:Color((_-(aj.Index*0.075))%1))
or Color3.fromHSV(_,ak,al)
end
end

local aj=""

function ad.UpdateWindowSize(ak,al)
local am=math.min(al,M)*L
local _=119+am

Y.Size=UDim2.fromOffset(200,am)

m:Tween(N,n.Tween,{
Size=UDim2.fromOffset(220,_),
})
end

function ad.FilterItems(ak,al)
aj=al:lower()
local am=0

for _,an in ak.Objects do
local ao=an.Name:lower()
local ap=aj==""or ao:find(aj,1,true)

if ap then
am=am+1
an.Position=UDim2.fromOffset(0,(am-1)*L)


an.Visible=true
m:Tween(an,TweenInfo.new(0.15),{
BackgroundTransparency=0,
})
for aq,ar in an:GetDescendants()do
if ar:IsA"TextLabel"then
m:Tween(ar,TweenInfo.new(0.15),{
TextTransparency=0,
})
elseif ar:IsA"ImageButton"or ar:IsA"ImageLabel"then
m:Tween(ar,TweenInfo.new(0.15),{
ImageTransparency=ar.Name=="AddButton"and 0.3 or 0.5,
})
elseif ar:IsA"Frame"and ar.Name~="BKG"then
m:Tween(ar,TweenInfo.new(0.15),{
BackgroundTransparency=0,
})
end
end
else

m:Tween(an,TweenInfo.new(0.15),{
BackgroundTransparency=1,
})
for aq,ar in an:GetDescendants()do
if ar:IsA"TextLabel"then
m:Tween(ar,TweenInfo.new(0.15),{
TextTransparency=1,
})
elseif ar:IsA"ImageButton"or ar:IsA"ImageLabel"then
m:Tween(ar,TweenInfo.new(0.15),{
ImageTransparency=1,
})
elseif ar:IsA"Frame"then
m:Tween(ar,TweenInfo.new(0.15),{
BackgroundTransparency=1,
})
end
end
task.delay(0.15,function()
an.Visible=false
end)
end
end

Z.Visible=am==0 and#ak.List>0
ak:UpdateWindowSize(am==0 and 1 or am)
end

function ad.ChangeValue(ak,al)
if al then
local am=table.find(ak.List,al)
if am then
table.remove(ak.List,am)
am=table.find(ak.ListEnabled,al)
if am then
table.remove(ak.ListEnabled,am)
end
else
table.insert(ak.List,al)
table.insert(ak.ListEnabled,al)
end
end

aa.Function(ak.List)
for am,an in ak.Objects do
an:Destroy()
end
table.clear(ak.Objects)
H.Text=#ak.List

local am="None"
for an,ao in ak.ListEnabled do
if an==1 then
am=""
end
am=am..(an==1 and ao or", "..ao)
end
I.Text=am

for an,ao in ak.List do
local ap=table.find(ak.ListEnabled,ao)
local aq=Instance.new"TextButton"
aq.Name=ao
aq.Size=UDim2.fromOffset(200,32)
aq.Position=UDim2.fromOffset(0,(an-1)*L)
aq.BackgroundColor3=l.Light(n.Main,0.02)
aq.AutoButtonColor=false
aq.Text=""
aq.Parent=Y
addCorner(aq)
local ar=Instance.new"Frame"
ar.Name="BKG"
ar.Size=UDim2.new(1,-2,1,-2)
ar.Position=UDim2.fromOffset(1,1)
ar.BackgroundColor3=n.Main
ar.Visible=false
ar.Parent=aq
addCorner(ar)
local _=Instance.new"Frame"
_.Name="Dot"
_.Size=UDim2.fromOffset(10,11)
_.Position=UDim2.fromOffset(10,12)
_.BackgroundColor3=ap and aa.Color or l.Light(n.Main,0.37)
_.Parent=aq
addCorner(_,UDim.new(1,0))
local as=_:Clone()
as.Size=UDim2.fromOffset(8,9)
as.Position=UDim2.fromOffset(1,1)
as.BackgroundColor3=ap and aa.Color or l.Light(n.Main,0.02)
as.Parent=_
local at=Instance.new"TextLabel"
at.Name="Title"
at.Size=UDim2.new(1,-30,1,0)
at.Position=UDim2.fromOffset(30,0)
at.BackgroundTransparency=1
at.Text=ao
at.TextXAlignment=Enum.TextXAlignment.Left
at.TextColor3=l.Dark(n.Text,0.16)
at.TextSize=15
at.FontFace=n.Font
at.Parent=aq
local au=Instance.new"ImageButton"
au.Name="Close"
au.Size=UDim2.fromOffset(16,16)
au.Position=UDim2.new(1,-26,0,8)
au.BackgroundColor3=Color3.new(1,1,1)
au.BackgroundTransparency=1
au.AutoButtonColor=false
au.Image=t"vape/assets/new/closemini.png"
au.ImageColor3=l.Light(n.Text,0.2)
au.ImageTransparency=0.5
au.Parent=aq
addCorner(au,UDim.new(1,0))

au.MouseEnter:Connect(function()
au.ImageTransparency=0.3
m:Tween(au,n.Tween,{
BackgroundTransparency=0.6,
})
end)
au.MouseLeave:Connect(function()
au.ImageTransparency=0.5
m:Tween(au,n.Tween,{
BackgroundTransparency=1,
})
end)
au.Activated:Connect(function()
ak:ChangeValue(ao)
ak:FilterItems(aj)
end)
aq.MouseEnter:Connect(function()
ar.Visible=true
end)
aq.MouseLeave:Connect(function()
ar.Visible=false
end)
aq.Activated:Connect(function()
local av=table.find(ak.ListEnabled,ao)
if av then
table.remove(ak.ListEnabled,av)
_.BackgroundColor3=l.Light(n.Main,0.37)
as.BackgroundColor3=l.Light(n.Main,0.02)
else
table.insert(ak.ListEnabled,ao)
_.BackgroundColor3=aa.Color
as.BackgroundColor3=aa.Color
end

local aw="None"
for ax,ay in ak.ListEnabled do
if ax==1 then
aw=""
end
aw=aw..(ax==1 and ay or", "..ay)
end

I.Text=aw
aa.Function()
end)

table.insert(ak.Objects,aq)
end


ak:FilterItems(aj)
end


X:GetPropertyChangedSignal"Text":Connect(function()
ad:FilterItems(X.Text)
end)

X.MouseEnter:Connect(function()
m:Tween(V,n.Tween,{
BackgroundColor3=l.Light(n.Main,0.14),
})
end)
X.MouseLeave:Connect(function()
m:Tween(V,n.Tween,{
BackgroundColor3=l.Light(n.Main,0.02),
})
end)

U.MouseEnter:Connect(function()
U.ImageTransparency=0
end)
U.MouseLeave:Connect(function()
U.ImageTransparency=0.3
end)
U.Activated:Connect(function()
if not table.find(ad.List,T.Text)then
if T.Text==""or T.Text=="Invalid Entry!"then
c:CreateNotification("Vape","You need to specify a value!",3)
flickerTextEffect(T,true,"Invalid Entry!")
task.delay(0.5,function()
flickerTextEffect(T,true,"")
end)
return
end
ad:ChangeValue(T.Text)
T.Text=""
X.Text=""
end
end)
T.FocusLost:Connect(function(ak)
if ak and not table.find(ad.List,T.Text)and T.Text~=""then
ad:ChangeValue(T.Text)
T.Text=""
X.Text=""
end
end)
T.MouseEnter:Connect(function()
m:Tween(R,n.Tween,{
BackgroundColor3=l.Light(n.Main,0.14),
})
end)
T.MouseLeave:Connect(function()
m:Tween(R,n.Tween,{
BackgroundColor3=l.Light(n.Main,0.02),
})
end)
Q.Activated:Connect(function()
N.Visible=false
X.Text=""
end)
ag.Activated:Connect(function()
N.Visible=not N.Visible
if not N.Visible then
X.Text=""
end
m:Cancel(af)
af.BackgroundColor3=N.Visible
and Color3.fromHSV(c.GUIColor.Hue,c.GUIColor.Sat,c.GUIColor.Value)
or l.Light(n.Main,0.37)
end)
ae.MouseEnter:Connect(function()
if not ad.Window.Visible then
m:Tween(af,n.Tween,{
BackgroundColor3=l.Light(n.Main,0.37),
})
end
end)
ae.MouseLeave:Connect(function()
if not ad.Window.Visible then
m:Tween(af,n.Tween,{
BackgroundColor3=l.Light(n.Main,0.034),
})
end
end)
ae:GetPropertyChangedSignal"AbsolutePosition":Connect(function()
if c.ThreadFix then
setthreadidentity(8)
end
local ak=(
ae.AbsolutePosition
-(ac.Legit and c.Legit.Window.AbsolutePosition or-i:GetGuiInset())
)/z.Scale
N.Position=UDim2.fromOffset(ak.X+220,ak.Y)
end)

if aa.Default then
ad:ChangeValue()
end
ad.Object=ae
ac.Options[aa.Name]=ad

return ad
end,
Toggle=function(aa,ab,ac)
local ad={
Type="Toggle",
Enabled=false,
Index=getTableSize(ac.Options),
}

local ae=false
local af=Instance.new"TextButton"
af.Name=aa.Name.."Toggle"
af.Size=UDim2.new(1,0,0,30)
af.BackgroundColor3=l.Dark(ab.BackgroundColor3,aa.Darker and 0.02 or 0)
af.BorderSizePixel=0
af.AutoButtonColor=false
af.Visible=aa.Visible==nil or aa.Visible
af.Text="          "..aa.Name
af.TextXAlignment=Enum.TextXAlignment.Left
af.TextColor3=l.Dark(n.Text,0.16)
af.TextSize=14
af.FontFace=n.Font
af.Parent=ab
addTooltip(af,aa.Tooltip)
local ag=Instance.new"Frame"
ag.Name="Knob"
ag.Size=UDim2.fromOffset(22,12)
ag.Position=UDim2.new(1,-30,0,9)
ag.BackgroundColor3=l.Light(n.Main,0.14)
ag.Parent=af
addCorner(ag,UDim.new(1,0))
local ah=ag:Clone()
ah.Size=UDim2.fromOffset(8,8)
ah.Position=UDim2.fromOffset(2,2)
ah.BackgroundColor3=n.Main
ah.Parent=ag
aa.Function=aa.Function or function()end

function ad.Save(ai,aj)
aj[aa.Name]={Enabled=ai.Enabled}
end

function ad.Load(ai,aj)
if ai.Enabled~=aj.Enabled then
ai:Toggle()
end
end

function ad.Color(ai,aj,ak,al,am)
if ai.Enabled then
m:Cancel(ag)
ag.BackgroundColor3=am
and Color3.fromHSV(c:Color((aj-(ai.Index*0.075))%1))
or Color3.fromHSV(aj,ak,al)
end
end

function ad.Toggle(ai)
ai.Enabled=not ai.Enabled
local aj=c.GUIColor.Rainbow and c.RainbowMode.Value~="Retro"
m:Tween(ag,n.Tween,{
BackgroundColor3=ai.Enabled
and(aj and Color3.fromHSV(
c:Color((c.GUIColor.Hue-(ai.Index*0.075))%1)
)or Color3.fromHSV(c.GUIColor.Hue,c.GUIColor.Sat,c.GUIColor.Value))
or(ae and l.Light(n.Main,0.37)or l.Light(n.Main,0.14)),
})
m:Tween(ah,n.Tween,{
Position=UDim2.fromOffset(ai.Enabled and 12 or 2,2),
})
aa.Function(ai.Enabled)
end

function ad.SetValue(ai,aj)
if aj==nil then
aj=not ai.Enabled
end
if ai.Enabled==aj then return end
ai:Toggle()
end

af.MouseEnter:Connect(function()
ae=true
if not ad.Enabled then
m:Tween(ag,n.Tween,{
BackgroundColor3=l.Light(n.Main,0.37),
})
end
end)
af.MouseLeave:Connect(function()
ae=false
if not ad.Enabled then
m:Tween(ag,n.Tween,{
BackgroundColor3=l.Light(n.Main,0.14),
})
end
end)
af.Activated:Connect(function()
ad:Toggle()
end)

if aa.Default then
if aa.NoDefaultCallback then
ad.Enabled=true
else
ad:Toggle()
end
end
ad.Object=af
ac.Options[aa.Name]=ad

return ad
end,
TwoSlider=function(aa,ab,ac)
local ad={
Type="TwoSlider",
ValueMin=aa.DefaultMin or aa.Min,
ValueMax=aa.DefaultMax or 10,
Max=aa.Max,
Index=getTableSize(ac.Options),
}

local ae=Instance.new"TextButton"
ae.Name=aa.Name.."Slider"
ae.Size=UDim2.new(1,0,0,50)
ae.BackgroundColor3=l.Dark(ab.BackgroundColor3,aa.Darker and 0.02 or 0)
ae.BorderSizePixel=0
ae.AutoButtonColor=false
ae.Visible=aa.Visible==nil or aa.Visible
ae.Text=""
ae.Parent=ab
addTooltip(ae,aa.Tooltip)
local af=Instance.new"TextLabel"
af.Name="Title"
af.Size=UDim2.fromOffset(60,30)
af.Position=UDim2.fromOffset(10,2)
af.BackgroundTransparency=1
af.Text=aa.Name
af.TextXAlignment=Enum.TextXAlignment.Left
af.TextColor3=l.Dark(n.Text,0.16)
af.TextSize=11
af.FontFace=n.Font
af.Parent=ae
local ag=Instance.new"TextButton"
ag.Name="Value"
ag.Size=UDim2.fromOffset(60,15)
ag.Position=UDim2.new(1,-69,0,9)
ag.BackgroundTransparency=1
ag.Text=ad.ValueMax
ag.TextXAlignment=Enum.TextXAlignment.Right
ag.TextColor3=l.Dark(n.Text,0.16)
ag.TextSize=11
ag.FontFace=n.Font
ag.Parent=ae
local ah=ag:Clone()
ah.Position=UDim2.new(1,-125,0,9)
ah.Text=ad.ValueMin
ah.Parent=ae
local ai=Instance.new"TextBox"
ai.Name="Box"
ai.Size=ag.Size
ai.Position=ag.Position
ai.BackgroundTransparency=1
ai.Visible=false
ai.Text=ad.ValueMin
ai.TextXAlignment=Enum.TextXAlignment.Right
ai.TextColor3=l.Dark(n.Text,0.16)
ai.TextSize=11
ai.FontFace=n.Font
ai.ClearTextOnFocus=false
ai.Parent=ae
local aj=ai:Clone()
aj.Position=ah.Position
aj.Parent=ae
local ak=Instance.new"Frame"
ak.Name="Slider"
ak.Size=UDim2.new(1,-20,0,2)
ak.Position=UDim2.fromOffset(10,37)
ak.BackgroundColor3=l.Light(n.Main,0.034)
ak.BorderSizePixel=0
ak.Parent=ae
local al=ak:Clone()
al.Name="Fill"
al.Position=UDim2.fromScale(math.clamp(ad.ValueMin/aa.Max,0.04,0.96),0)
al.Size=UDim2.fromScale(
math.clamp(math.clamp(ad.ValueMax/aa.Max,0,1),0.04,0.96)-al.Position.X.Scale,
1
)
al.BackgroundColor3=Color3.fromHSV(c.GUIColor.Hue,c.GUIColor.Sat,c.GUIColor.Value)
al.Parent=ak
local am=Instance.new"Frame"
am.Name="Knob"
am.Size=UDim2.fromOffset(16,4)
am.Position=UDim2.fromScale(0,0.5)
am.AnchorPoint=Vector2.new(0.5,0.5)
am.BackgroundColor3=ae.BackgroundColor3
am.BorderSizePixel=0
am.Parent=al
local an=Instance.new"ImageLabel"
an.Name="Knob"
an.Size=UDim2.fromOffset(9,16)
an.Position=UDim2.fromScale(0.5,0.5)
an.AnchorPoint=Vector2.new(0.5,0.5)
an.BackgroundTransparency=1
an.Image=t"vape/assets/new/range.png"
an.ImageColor3=Color3.fromHSV(c.GUIColor.Hue,c.GUIColor.Sat,c.GUIColor.Value)
an.Parent=am
local ao=am:Clone()
ao.Name="KnobMax"
ao.Position=UDim2.fromScale(1,0.5)
ao.Parent=al
ao.Knob.Rotation=180
local ap=Instance.new"ImageLabel"
ap.Name="Arrow"
ap.Size=UDim2.fromOffset(12,6)
ap.Position=UDim2.new(1,-56,0,10)
ap.BackgroundTransparency=1
ap.Image=t"vape/assets/new/rangearrow.png"
ap.ImageColor3=l.Light(n.Main,0.14)
ap.Parent=ae
aa.Function=aa.Function or function()end
aa.Decimal=aa.Decimal or 1
local aq=Random.new()

function ad.Save(ar,as)
as[aa.Name]={ValueMin=ar.ValueMin,ValueMax=ar.ValueMax}
end

function ad.Load(ar,as)
if ar.ValueMin~=as.ValueMin then
ar:SetValue(false,as.ValueMin)
end
if ar.ValueMax~=as.ValueMax then
ar:SetValue(true,as.ValueMax)
end
end

function ad.Color(ar,as,at,au,av)
al.BackgroundColor3=av and Color3.fromHSV(c:Color((as-(ar.Index*0.075))%1))
or Color3.fromHSV(as,at,au)
an.ImageColor3=al.BackgroundColor3
ao.Knob.ImageColor3=al.BackgroundColor3
end

function ad.GetRandomValue(ar)
return aq:NextNumber(ad.ValueMin,ad.ValueMax)
end

function ad.SetValue(ar,as,at)
if tonumber(at)==math.huge or at~=at then
return
end
ar[as and"ValueMax"or"ValueMin"]=at
ag.Text=ar.ValueMax
ah.Text=ar.ValueMin
local au=math.clamp(math.clamp(ar.ValueMin/aa.Max,0,1),0.04,0.96)
m:Tween(al,TweenInfo.new(0.1),{
Position=UDim2.fromScale(au,0),
Size=UDim2.fromScale(
math.clamp(
math.clamp(math.clamp(ar.ValueMax/aa.Max,0.04,0.96),0.04,0.96)-au,
0,
1
),
1
),
})
end

am.MouseEnter:Connect(function()
m:Tween(an,n.Tween,{
Size=UDim2.fromOffset(11,18),
})
end)
am.MouseLeave:Connect(function()
m:Tween(an,n.Tween,{
Size=UDim2.fromOffset(9,16),
})
end)
ao.MouseEnter:Connect(function()
m:Tween(ao.Knob,n.Tween,{
Size=UDim2.fromOffset(11,18),
})
end)
ao.MouseLeave:Connect(function()
m:Tween(ao.Knob,n.Tween,{
Size=UDim2.fromOffset(9,16),
})
end)
ae.InputBegan:Connect(function(ar)
if
(
ar.UserInputType==Enum.UserInputType.MouseButton1
or ar.UserInputType==Enum.UserInputType.Touch
)and(ar.Position.Y-ae.AbsolutePosition.Y)>(20*z.Scale)
then
local as=(ar.Position.X-ao.AbsolutePosition.X)>-10
local at=
math.clamp((ar.Position.X-ak.AbsolutePosition.X)/ak.AbsoluteSize.X,0,1)
ad:SetValue(
as,
math.floor(
(aa.Min+(aa.Max-aa.Min)*at)
*aa.Decimal
)/aa.Decimal,
at
)

local au=g.InputChanged:Connect(function(au)
if
au.UserInputType
==(
ar.UserInputType==Enum.UserInputType.MouseButton1
and Enum.UserInputType.MouseMovement
or Enum.UserInputType.Touch
)
then
local av=
math.clamp((au.Position.X-ak.AbsolutePosition.X)/ak.AbsoluteSize.X,0,1)
ad:SetValue(
as,
math.floor(
(aa.Min+(aa.Max-aa.Min)*av)
*aa.Decimal
)/aa.Decimal,
av
)
end
end)

local av
av=ar.Changed:Connect(function()
if ar.UserInputState==Enum.UserInputState.End then
if au then
au:Disconnect()
end
if av then
av:Disconnect()
end
end
end)
end
end)
ag.Activated:Connect(function()
ag.Visible=false
ai.Visible=true
ai.Text=ad.ValueMax
ai:CaptureFocus()
end)
ah.Activated:Connect(function()
ah.Visible=false
aj.Visible=true
aj.Text=ad.ValueMin
aj:CaptureFocus()
end)
ai.FocusLost:Connect(function(ar)
ag.Visible=true
ai.Visible=false
if ar and tonumber(ai.Text)then
ad:SetValue(true,tonumber(ai.Text))
end
end)
aj.FocusLost:Connect(function(ar)
ah.Visible=true
aj.Visible=false
if ar and tonumber(aj.Text)then
ad:SetValue(false,tonumber(aj.Text))
end
end)

ad.Object=ae
ac.Options[aa.Name]=ad

return ad
end,
Divider=function(aa,ab)
local ac=Instance.new"Frame"
ac.Name="Divider"
ac.Size=UDim2.new(1,0,0,1)
ac.BackgroundColor3=l.Light(n.Main,0.02)
ac.BorderSizePixel=0
ac.Parent=aa
if ab then
local ad=Instance.new"TextLabel"
ad.Name="DividerLabel"
ad.Size=UDim2.fromOffset(218,27)
ad.BackgroundTransparency=1
ad.Text="          "..ab:upper()
ad.TextXAlignment=Enum.TextXAlignment.Left
ad.TextColor3=l.Dark(n.Text,0.43)
ad.TextSize=9
ad.FontFace=n.Font
ad.Parent=aa
ac.Position=UDim2.fromOffset(0,26)
ac.Parent=ad
end
end,
}

for aa,ab in G do
local ac=ab
G[aa]=function(ad,...)
local ae={...}
if type(ad)~="table"then
return ac(ad,unpack(ae))
end
ad.Function=a:wrap(ad.Function,{
type="component",
component=tostring(aa),
name=ad.Name,
})
return ac(ad,unpack(ae))
end
end

c.Components=setmetatable(G,{
__newindex=function(aa,ab,ac)
for ad,ae in c.Modules do
rawset(ae,"Create"..ab,function(af,ag)
return ac(ag,ae.Children,ae)
end)
rawset(ae,"Add"..ab,function(af,ag)
return ac(ag,ae.Children,ae)
end)
end

if c.Legit then
for ad,ae in c.Legit.Modules do
rawset(ae,"Create"..ab,function(af,ag)
return ac(ag,ae.Children,ae)
end)
rawset(ae,"Add"..ab,function(af,ag)
return ac(ag,ae.Children,ae)
end)
end
end

rawset(aa,ab,ac)
end,
})

task.spawn(function()
repeat
local aa=tick()*(0.2*c.RainbowSpeed.Value)%1
for ab,ac in c.RainbowTable do
if ac.Type=="GUISlider"then
ac:SetValue(c:Color(aa))
else
ac:SetValue(aa)
end
end
task.wait(1/c.RainbowUpdateSpeed.Value)
until c.Loaded==nil
end)

function c.BlurCheck(aa)end

function c.CreateGUI(aa)
local ab={
Type="MainWindow",
Buttons={},
Options={},
}

local ac=Instance.new"TextButton"
ac.Name="GUICategory"
ac.Position=UDim2.fromOffset(6,60)
ac.BackgroundColor3=l.Dark(n.Main,0.02)
ac.AutoButtonColor=false
ac.Text=""
ac.Parent=u
addBlur(ac)
addCorner(ac)
makeDraggable(ac)
local ad=Instance.new"ImageLabel"
ad.Name="VapeLogo"
ad.Size=UDim2.fromOffset(62,18)
ad.Position=UDim2.fromOffset(11,10)
ad.BackgroundTransparency=1
ad.Image=t"vape/assets/new/guivape.png"
ad.ImageColor3=select(3,n.Main:ToHSV())>0.5 and n.Text or Color3.new(1,1,1)
ad.Parent=ac
local ae=Instance.new"ImageLabel"
ae.Name="V4Logo"
ae.Size=UDim2.fromOffset(28,16)
ae.Position=UDim2.new(1,1,0,1)
ae.BackgroundTransparency=1
ae.Image=t"vape/assets/new/guiv4.png"
ae.Parent=ad
local af=Instance.new"Frame"
af.Name="Children"
af.Size=UDim2.new(1,0,1,-33)
af.Position=UDim2.fromOffset(0,37)
af.BackgroundTransparency=1
af.Parent=ac
local ag=Instance.new"UIListLayout"
ag.SortOrder=Enum.SortOrder.LayoutOrder
ag.HorizontalAlignment=Enum.HorizontalAlignment.Center
ag.Parent=af
local ah=Instance.new"TextButton"
ah.Name="Settings"
ah.Size=UDim2.fromOffset(40,40)
ah.Position=UDim2.new(1,-40,0,0)
ah.BackgroundTransparency=1
ah.Text=""
ah.Parent=ac
addTooltip(ah,"Open settings")
local ai=Instance.new"ImageLabel"
ai.Size=UDim2.fromOffset(14,14)
ai.Position=UDim2.fromOffset(15,12)
ai.BackgroundTransparency=1
ai.Image=t"vape/assets/new/guisettings.png"
ai.ImageColor3=l.Light(n.Main,0.37)
ai.Parent=ah
local aj=Instance.new"ImageButton"
aj.Size=UDim2.fromOffset(16,16)
aj.Position=UDim2.new(1,-56,0,11)
aj.BackgroundTransparency=1
aj.Image=t"vape/assets/new/discord.png"
aj.Parent=ac
addTooltip(aj,"Join discord")
local ak=Instance.new"TextButton"
ak.Size=UDim2.fromScale(1,1)
ak.BackgroundColor3=l.Dark(n.Main,0.02)
ak.AutoButtonColor=false
ak.Visible=false
ak.Text=""
ak.Parent=ac
local al=Instance.new"TextLabel"
al.Name="Title"
al.Size=UDim2.new(1,-36,0,20)
al.Position=UDim2.fromOffset(math.abs(al.Size.X.Offset),11)
al.BackgroundTransparency=1
al.Text="Settings"
al.TextXAlignment=Enum.TextXAlignment.Left
al.TextColor3=n.Text
al.TextSize=13
al.FontFace=n.Font
al.Parent=ak
local am=addCloseButton(ak)
local an=Instance.new"ImageButton"
an.Name="Back"
an.Size=UDim2.fromOffset(16,16)
an.Position=UDim2.fromOffset(11,13)
an.BackgroundTransparency=1
an.Image=t"vape/assets/new/back.png"
an.ImageColor3=l.Light(n.Main,0.37)
an.Parent=ak
local ao=Instance.new"TextLabel"
ao.Name="Version"
ao.Size=UDim2.new(1,0,0,16)
ao.Position=UDim2.new(0,0,1,-16)
ao.BackgroundTransparency=1
ao.Text="Vape "
..c.Version
.." "
..(C"vape/profiles/commit.txt"and readfile"vape/profiles/commit.txt":sub(1,6)or"")
.." "
ao.TextColor3=l.Dark(n.Text,0.43)
ao.TextXAlignment=Enum.TextXAlignment.Right
ao.TextSize=10
ao.FontFace=n.Font
ao.Parent=ak
addCorner(ak)
local ap=Instance.new"Frame"
ap.Name="Children"
ap.Size=UDim2.new(1,0,1,-57)
ap.Position=UDim2.fromOffset(0,41)
ap.BackgroundColor3=n.Main
ap.BorderSizePixel=0
ap.Parent=ak
local aq=Instance.new"UIListLayout"
aq.SortOrder=Enum.SortOrder.LayoutOrder
aq.HorizontalAlignment=Enum.HorizontalAlignment.Center
aq.Parent=ap
ab.Object=ac

function ab.CreateBind(ar)
local as={Bind={"RightShift"}}

local at=Instance.new"TextButton"
at.Size=UDim2.fromOffset(220,40)
at.BackgroundColor3=n.Main
at.BorderSizePixel=0
at.AutoButtonColor=false
at.Text="          Rebind GUI"
at.TextXAlignment=Enum.TextXAlignment.Left
at.TextColor3=l.Dark(n.Text,0.16)
at.TextSize=14
at.FontFace=n.Font
at.Parent=ap
addTooltip(at,"Change the bind of the GUI")
local au=Instance.new"TextButton"
au.Name="Bind"
au.Size=UDim2.fromOffset(20,21)
au.Position=UDim2.new(1,-10,0,9)
au.AnchorPoint=Vector2.new(1,0)
au.BackgroundColor3=Color3.new(1,1,1)
au.BackgroundTransparency=0.92
au.BorderSizePixel=0
au.AutoButtonColor=false
au.Text=""
au.Parent=at
addTooltip(au,"Click to bind")
addCorner(au,UDim.new(0,4))
local av=Instance.new"ImageLabel"
av.Name="Icon"
av.Size=UDim2.fromOffset(12,12)
av.Position=UDim2.new(0.5,-6,0,5)
av.BackgroundTransparency=1
av.Image=t"vape/assets/new/bind.png"
av.ImageColor3=l.Dark(n.Text,0.43)
av.Parent=au
local aw=Instance.new"TextLabel"
aw.Name="Text"
aw.Size=UDim2.fromScale(1,1)
aw.Position=UDim2.fromOffset(0,1)
aw.BackgroundTransparency=1
aw.Visible=false
aw.Text=""
aw.TextColor3=l.Dark(n.Text,0.43)
aw.TextSize=12
aw.FontFace=n.Font
aw.Parent=au

function as.SetBind(ax,ay)
c.Keybind=#ay<=0 and c.Keybind or table.clone(ay)
ax.Bind=c.Keybind
if c.VapeButton then
c.VapeButton:Destroy()
c.VapeButton=nil
end

au.Visible=true
aw.Visible=true
av.Visible=false
aw.Text=table.concat(c.Keybind," + "):upper()
au.Size=UDim2.fromOffset(math.max(D(aw.Text,aw.TextSize,aw.Font).X+10,20),21)
end

au.MouseEnter:Connect(function()
aw.Visible=false
av.Visible=not aw.Visible
av.Image=t"vape/assets/new/edit.png"
av.ImageColor3=l.Dark(n.Text,0.16)
end)
au.MouseLeave:Connect(function()
aw.Visible=true
av.Visible=not aw.Visible
av.Image=t"vape/assets/new/bind.png"
av.ImageColor3=l.Dark(n.Text,0.43)
end)
au.Activated:Connect(function()
c.Binding=as
end)

ab.Options.Bind=as

return as
end

function ab.CreateButton(ar,as)
local at={
Enabled=false,
Index=getTableSize(ab.Buttons),
}

local au=Instance.new"TextButton"
au.Name=as.Name
au.Size=UDim2.fromOffset(220,40)
au.BackgroundColor3=n.Main
au.BorderSizePixel=0
au.AutoButtonColor=false
au.Text=(
as.Icon
and"                                 "
or"             "
)..as.Name
au.TextXAlignment=Enum.TextXAlignment.Left
au.TextColor3=l.Dark(n.Text,0.16)
au.TextSize=14
au.FontFace=n.Font
au.Parent=af
local av
if as.Icon then
av=Instance.new"ImageLabel"
av.Name="Icon"
av.Size=as.Size
av.Position=UDim2.fromOffset(13,13)
av.BackgroundTransparency=1
av.Image=as.Icon
av.ImageColor3=l.Dark(n.Text,0.16)
av.Parent=au
end
if as.Name=="Profiles"then
local aw=Instance.new"TextLabel"
aw.Name="ProfileLabel"
aw.Size=UDim2.fromOffset(53,24)
aw.Position=UDim2.new(1,-36,0,8)
aw.AnchorPoint=Vector2.new(1,0)
aw.BackgroundColor3=l.Light(n.Main,0.04)
aw.Text="default"
aw.TextColor3=l.Dark(n.Text,0.29)
aw.TextSize=12
aw.FontFace=n.Font
aw.Parent=au
addCorner(aw)
c.ProfileLabel=aw
end
local aw=Instance.new"ImageLabel"
aw.Name="Arrow"
aw.Size=UDim2.fromOffset(4,8)
aw.Position=UDim2.new(1,-20,0,16)
aw.BackgroundTransparency=1
aw.Image=t"vape/assets/new/expandright.png"
aw.ImageColor3=l.Light(n.Main,0.37)
aw.Parent=au
at.Name=as.Name
at.Icon=av
at.Object=au

function at.Toggle(ax,ay)
if ay~=nil then
if ay==ax.Enabled then return end
ax.Enabled=ay
else
ax.Enabled=not ax.Enabled
end
m:Tween(aw,n.Tween,{
Position=UDim2.new(1,ax.Enabled and-14 or-20,0,16),
})
au.TextColor3=ax.Enabled
and Color3.fromHSV(c.GUIColor.Hue,c.GUIColor.Sat,c.GUIColor.Value)
or n.Text
if av then
av.ImageColor3=au.TextColor3
end
au.BackgroundColor3=l.Light(n.Main,0.02)
as.Window.Visible=ax.Enabled
end

if as.Default and not at.Enabled then
at:Toggle()
end

au.MouseEnter:Connect(function()
if not at.Enabled then
au.TextColor3=n.Text
if buttonicon then
buttonicon.ImageColor3=n.Text
end
au.BackgroundColor3=l.Light(n.Main,0.02)
end
end)
au.MouseLeave:Connect(function()
if not at.Enabled then
au.TextColor3=l.Dark(n.Text,0.16)
if buttonicon then
buttonicon.ImageColor3=l.Dark(n.Text,0.16)
end
au.BackgroundColor3=n.Main
end
end)
au.Activated:Connect(function()
at:Toggle()
end)

at.Object=au
ab.Buttons[as.Name]=at

return at
end

function ab.CreateDivider(ar,as)
return G.Divider(af,as)
end

function ab.CreateOverlayBar(ar)
local as={Toggles={}}

local at=Instance.new"Frame"
at.Name="Overlays"
at.Size=UDim2.fromOffset(220,36)
at.BackgroundColor3=n.Main
at.BorderSizePixel=0
at.Parent=af
G.Divider(at)
local au=Instance.new"ImageButton"
au.Size=UDim2.fromOffset(24,24)
au.Position=UDim2.new(1,-29,0,7)
au.BackgroundTransparency=1
au.AutoButtonColor=false
au.Image=t"vape/assets/new/overlaysicon.png"
au.ImageColor3=l.Light(n.Main,0.37)
au.Parent=at
addCorner(au,UDim.new(1,0))
addTooltip(au,"Open overlays menu")
local av=Instance.new"TextButton"
av.Name="Shadow"
av.Size=UDim2.new(1,0,1,-5)
av.BackgroundColor3=Color3.new()
av.BackgroundTransparency=1
av.AutoButtonColor=false
av.ClipsDescendants=true
av.Visible=false
av.Text=""
av.Parent=ac
addCorner(av)
local aw=Instance.new"Frame"
aw.Size=UDim2.fromOffset(220,42)
aw.Position=UDim2.fromScale(0,1)
aw.BackgroundColor3=n.Main
aw.Parent=av
addCorner(aw)
local ax=Instance.new"ImageLabel"
ax.Name="Icon"
ax.Size=UDim2.fromOffset(14,12)
ax.Position=UDim2.fromOffset(10,13)
ax.BackgroundTransparency=1
ax.Image=t"vape/assets/new/overlaystab.png"
ax.ImageColor3=n.Text
ax.Parent=aw
local ay=Instance.new"TextLabel"
ay.Name="Title"
ay.Size=UDim2.new(1,-36,0,38)
ay.Position=UDim2.fromOffset(36,0)
ay.BackgroundTransparency=1
ay.Text="Overlays"
ay.TextXAlignment=Enum.TextXAlignment.Left
ay.TextColor3=n.Text
ay.TextSize=15
ay.FontFace=n.Font
ay.Parent=aw
local H=addCloseButton(aw,7)
local I=Instance.new"Frame"
I.Name="Divider"
I.Size=UDim2.new(1,0,0,1)
I.Position=UDim2.fromOffset(0,37)
I.BackgroundColor3=l.Light(n.Main,0.02)
I.BorderSizePixel=0
I.Parent=aw
local J=Instance.new"Frame"
J.Position=UDim2.fromOffset(0,38)
J.BackgroundTransparency=1
J.Parent=aw
local K=Instance.new"UIListLayout"
K.SortOrder=Enum.SortOrder.LayoutOrder
K.HorizontalAlignment=Enum.HorizontalAlignment.Center
K.Parent=J

function as.CreateToggle(L,M)
local N={
Enabled=false,
Index=getTableSize(as.Toggles),
}

local O=false
local P=Instance.new"TextButton"
P.Name=M.Name.."Toggle"
P.Size=UDim2.new(1,0,0,40)
P.BackgroundTransparency=1
P.AutoButtonColor=false
P.Text=string.rep(" ",33*z.Scale)..M.Name
P.TextXAlignment=Enum.TextXAlignment.Left
P.TextColor3=l.Dark(n.Text,0.16)
P.TextSize=14
P.FontFace=n.Font
P.Parent=J
local Q=Instance.new"ImageLabel"
Q.Name="Icon"
Q.Size=M.Size
Q.Position=M.Position
Q.BackgroundTransparency=1
Q.Image=M.Icon
Q.ImageColor3=n.Text
Q.Parent=P
local R=Instance.new"Frame"
R.Name="Knob"
R.Size=UDim2.fromOffset(22,12)
R.Position=UDim2.new(1,-30,0,14)
R.BackgroundColor3=l.Light(n.Main,0.14)
R.Parent=P
addCorner(R,UDim.new(1,0))
local S=R:Clone()
S.Size=UDim2.fromOffset(8,8)
S.Position=UDim2.fromOffset(2,2)
S.BackgroundColor3=n.Main
S.Parent=R
N.Object=P

function N.Toggle(T)
T.Enabled=not T.Enabled
m:Tween(R,n.Tween,{
BackgroundColor3=T.Enabled
and Color3.fromHSV(c.GUIColor.Hue,c.GUIColor.Sat,c.GUIColor.Value)
or(O and l.Light(n.Main,0.37)or l.Light(n.Main,0.14)),
})
m:Tween(S,n.Tween,{
Position=UDim2.fromOffset(T.Enabled and 12 or 2,2),
})
M.Function(T.Enabled)
end

z:GetPropertyChangedSignal"Scale":Connect(function()
P.Text=string.rep(" ",33*z.Scale)..M.Name
end)
P.MouseEnter:Connect(function()
O=true
if not N.Enabled then
m:Tween(R,n.Tween,{
BackgroundColor3=l.Light(n.Main,0.37),
})
end
end)
P.MouseLeave:Connect(function()
O=false
if not N.Enabled then
m:Tween(R,n.Tween,{
BackgroundColor3=l.Light(n.Main,0.14),
})
end
end)
P.Activated:Connect(function()
N:Toggle()
end)

table.insert(as.Toggles,N)

return N
end

au.MouseEnter:Connect(function()
au.ImageColor3=n.Text
m:Tween(au,n.Tween,{
BackgroundTransparency=0.9,
})
end)
au.MouseLeave:Connect(function()
au.ImageColor3=l.Light(n.Main,0.37)
m:Tween(au,n.Tween,{
BackgroundTransparency=1,
})
end)
au.Activated:Connect(function()
av.Visible=true
m:Tween(av,n.Tween,{
BackgroundTransparency=0.5,
})
m:Tween(aw,n.Tween,{
Position=UDim2.new(0,0,1,-aw.Size.Y.Offset),
})
end)
H.Activated:Connect(function()
m:Tween(av,n.Tween,{
BackgroundTransparency=1,
})
m:Tween(aw,n.Tween,{
Position=UDim2.fromScale(0,1),
})
task.wait(0.2)
av.Visible=false
end)
av.Activated:Connect(function()
m:Tween(av,n.Tween,{
BackgroundTransparency=1,
})
m:Tween(aw,n.Tween,{
Position=UDim2.fromScale(0,1),
})
task.wait(0.2)
av.Visible=false
end)
K:GetPropertyChangedSignal"AbsoluteContentSize":Connect(function()
if c.ThreadFix then
setthreadidentity(8)
end
aw.Size=UDim2.fromOffset(220,math.min(37+K.AbsoluteContentSize.Y/z.Scale,605))
J.Size=UDim2.fromOffset(220,aw.Size.Y.Offset-5)
end)

c.Overlays=as

return as
end

function ab.CreateSettingsDivider(ar)
G.Divider(ap)
end

function ab.CreateSettingsPane(ar,as)
local at={}

local au=Instance.new"TextButton"
au.Name=as.Name
au.Size=UDim2.fromOffset(220,40)
au.BackgroundColor3=n.Main
au.BorderSizePixel=0
au.AutoButtonColor=false
au.Text="          "..as.Name
au.TextXAlignment=Enum.TextXAlignment.Left
au.TextColor3=l.Dark(n.Text,0.16)
au.TextSize=14
au.FontFace=n.Font
au.Parent=ap
local av=Instance.new"ImageLabel"
av.Name="Arrow"
av.Size=UDim2.fromOffset(4,8)
av.Position=UDim2.new(1,-20,0,16)
av.BackgroundTransparency=1
av.Image=t"vape/assets/new/expandright.png"
av.ImageColor3=l.Light(n.Main,0.37)
av.Parent=au
local aw=Instance.new"TextButton"
aw.Size=UDim2.fromScale(1,1)
aw.BackgroundColor3=n.Main
aw.AutoButtonColor=false
aw.Visible=false
aw.Text=""
aw.Parent=ac
local ax=Instance.new"TextLabel"
ax.Name="Title"
ax.Size=UDim2.new(1,-36,0,20)
ax.Position=UDim2.fromOffset(math.abs(ax.Size.X.Offset),11)
ax.BackgroundTransparency=1
ax.Text=as.Name
ax.TextXAlignment=Enum.TextXAlignment.Left
ax.TextColor3=n.Text
ax.TextSize=13
ax.FontFace=n.Font
ax.Parent=aw
local ay=addCloseButton(aw)
local H=Instance.new"ImageButton"
H.Name="Back"
H.Size=UDim2.fromOffset(16,16)
H.Position=UDim2.fromOffset(11,13)
H.BackgroundTransparency=1
H.Image=t"vape/assets/new/back.png"
H.ImageColor3=l.Light(n.Main,0.37)
H.Parent=aw
addCorner(aw)
local I=Instance.new"Frame"
I.Name="Children"
I.Size=UDim2.new(1,0,1,-57)
I.Position=UDim2.fromOffset(0,41)
I.BackgroundColor3=n.Main
I.BorderSizePixel=0
I.Parent=aw
local J=Instance.new"Frame"
J.Name="Divider"
J.Size=UDim2.new(1,0,0,1)
J.BackgroundColor3=Color3.new(1,1,1)
J.BackgroundTransparency=0.928
J.BorderSizePixel=0
J.Parent=I
local K=Instance.new"UIListLayout"
K.SortOrder=Enum.SortOrder.LayoutOrder
K.HorizontalAlignment=Enum.HorizontalAlignment.Center
K.Parent=I

for L,M in G do
at["Create"..L]=function(N,O)
return M(O,I,ab)
end
at["Add"..L]=at["Create"..L]
end

H.MouseEnter:Connect(function()
H.ImageColor3=n.Text
end)
H.MouseLeave:Connect(function()
H.ImageColor3=l.Light(n.Main,0.37)
end)
H.Activated:Connect(function()
aw.Visible=false
end)
au.MouseEnter:Connect(function()
au.TextColor3=n.Text
au.BackgroundColor3=l.Light(n.Main,0.02)
end)
au.MouseLeave:Connect(function()
au.TextColor3=l.Dark(n.Text,0.16)
au.BackgroundColor3=n.Main
end)
au.Activated:Connect(function()
aw.Visible=true
end)
ay.Activated:Connect(function()
aw.Visible=false
end)
ag:GetPropertyChangedSignal"AbsoluteContentSize":Connect(function()
if c.ThreadFix then
setthreadidentity(8)
end
ac.Size=UDim2.fromOffset(220,45+ag.AbsoluteContentSize.Y/z.Scale)
for L,M in ab.Buttons do
if M.Icon then
M.Object.Text=string.rep(" ",33*z.Scale)..M.Name
end
end
end)

return at
end

function ab.CreateGUISlider(ar,as)
local at={
Type="GUISlider",
Notch=4,
Hue=0.46,
Sat=0.96,
Value=0.52,
Rainbow=false,
CustomColor=false,
}
local au={
Color3.fromRGB(250,50,56),
Color3.fromRGB(242,99,33),
Color3.fromRGB(252,179,22),
Color3.fromRGB(5,133,104),
Color3.fromRGB(47,122,229),
Color3.fromRGB(126,84,217),
Color3.fromRGB(232,96,152),
}
local av={
4,
33,
62,
90,
119,
148,
177,
}

local function createSlider(aw,ax)
local ay=Instance.new"TextButton"
ay.Name=as.Name.."Slider"..aw
ay.Size=UDim2.fromOffset(220,50)
ay.BackgroundColor3=l.Dark(n.Main,0.02)
ay.BorderSizePixel=0
ay.AutoButtonColor=false
ay.Visible=false
ay.Text=""
ay.Parent=ap
local H=Instance.new"TextLabel"
H.Name="Title"
H.Size=UDim2.fromOffset(60,30)
H.Position=UDim2.fromOffset(10,2)
H.BackgroundTransparency=1
H.Text=aw
H.TextXAlignment=Enum.TextXAlignment.Left
H.TextColor3=l.Dark(n.Text,0.16)
H.TextSize=11
H.FontFace=n.Font
H.Parent=ay
local I=Instance.new"Frame"
I.Name="Slider"
I.Size=UDim2.fromOffset(200,2)
I.Position=UDim2.fromOffset(10,37)
I.BackgroundColor3=Color3.new(1,1,1)
I.BorderSizePixel=0
I.Parent=ay
local J=Instance.new"UIGradient"
J.Color=ax
J.Parent=I
local K=I:Clone()
K.Name="Fill"
K.Size=UDim2.fromScale(math.clamp(1,0.04,0.96),1)
K.Position=UDim2.new()
K.BackgroundTransparency=1
K.Parent=I
local L=Instance.new"Frame"
L.Name="Knob"
L.Size=UDim2.fromOffset(24,4)
L.Position=UDim2.fromScale(1,0.5)
L.AnchorPoint=Vector2.new(0.5,0.5)
L.BackgroundColor3=l.Dark(n.Main,0.02)
L.BorderSizePixel=0
L.Parent=K
local M=Instance.new"Frame"
M.Name="Knob"
M.Size=UDim2.fromOffset(14,14)
M.Position=UDim2.fromScale(0.5,0.5)
M.AnchorPoint=Vector2.new(0.5,0.5)
M.BackgroundColor3=n.Text
M.Parent=L
addCorner(M,UDim.new(1,0))
if aw=="Custom color"then
local N=Instance.new"TextButton"
N.Size=UDim2.fromOffset(45,20)
N.Position=UDim2.new(1,-52,0,5)
N.BackgroundTransparency=1
N.Text="RESET"
N.TextColor3=l.Dark(n.Text,0.16)
N.TextSize=11
N.FontFace=n.Font
N.Parent=ay
N.Activated:Connect(function()
at:SetValue(nil,nil,nil,4)
end)
end

ay.InputBegan:Connect(function(N)
if
(
N.UserInputType==Enum.UserInputType.MouseButton1
or N.UserInputType==Enum.UserInputType.Touch
)and(N.Position.Y-ay.AbsolutePosition.Y)>(20*z.Scale)
then
local O=g.InputChanged:Connect(function(O)
if
O.UserInputType
==(
N.UserInputType==Enum.UserInputType.MouseButton1
and Enum.UserInputType.MouseMovement
or Enum.UserInputType.Touch
)
then
local P=
math.clamp((O.Position.X-I.AbsolutePosition.X)/I.AbsoluteSize.X,0,1)
at:SetValue(
aw=="Custom color"and P or nil,
aw=="Saturation"and P or nil,
aw=="Vibrance"and P or nil,
aw=="Opacity"and P or nil
)
end
end)

local P
P=N.Changed:Connect(function()
if N.UserInputState==Enum.UserInputState.End then
if O then
O:Disconnect()
end
if P then
P:Disconnect()
end
end
end)
end
end)
ay.MouseEnter:Connect(function()
m:Tween(M,n.Tween,{
Size=UDim2.fromOffset(16,16),
})
end)
ay.MouseLeave:Connect(function()
m:Tween(M,n.Tween,{
Size=UDim2.fromOffset(14,14),
})
end)

return ay
end

local aw=Instance.new"TextButton"
aw.Name=as.Name.."Slider"
aw.Size=UDim2.fromOffset(220,50)
aw.BackgroundTransparency=1
aw.AutoButtonColor=false
aw.Text=""
aw.Parent=ap
local ax=Instance.new"TextLabel"
ax.Name="Title"
ax.Size=UDim2.fromOffset(60,30)
ax.Position=UDim2.fromOffset(10,2)
ax.BackgroundTransparency=1
ax.Text=as.Name
ax.TextXAlignment=Enum.TextXAlignment.Left
ax.TextColor3=l.Dark(n.Text,0.16)
ax.TextSize=11
ax.FontFace=n.Font
ax.Parent=aw
local ay=Instance.new"Frame"
ay.Name="Slider"
ay.Size=UDim2.fromOffset(200,2)
ay.Position=UDim2.fromOffset(10,37)
ay.BackgroundTransparency=1
ay.BorderSizePixel=0
ay.Parent=aw
local H=0
for I,J in au do
local K=Instance.new"Frame"
K.Size=UDim2.fromOffset(27+(((I+1)%2)==0 and 1 or 0),2)
K.Position=UDim2.fromOffset(H,0)
K.BackgroundColor3=J
K.BorderSizePixel=0
K.Parent=ay
H+=(K.Size.X.Offset+1)
end
local I=Instance.new"ImageButton"
I.Name="Preview"
I.Size=UDim2.fromOffset(12,12)
I.Position=UDim2.new(1,-22,0,10)
I.BackgroundTransparency=1
I.Image=t"vape/assets/new/colorpreview.png"
I.ImageColor3=Color3.fromHSV(at.Hue,1,1)
I.Parent=aw
local J=Instance.new"TextBox"
J.Name="Box"
J.Size=UDim2.fromOffset(60,15)
J.Position=UDim2.new(1,-69,0,9)
J.BackgroundTransparency=1
J.Visible=false
J.Text=""
J.TextXAlignment=Enum.TextXAlignment.Right
J.TextColor3=l.Dark(n.Text,0.16)
J.TextSize=11
J.FontFace=n.Font
J.ClearTextOnFocus=true
J.Parent=aw
local K=Instance.new"TextButton"
K.Name="Expand"
K.Size=UDim2.fromOffset(17,13)
K.Position=UDim2.new(0,D(ax.Text,ax.TextSize,ax.Font).X+11,0,7)
K.BackgroundTransparency=1
K.Text=""
K.Parent=aw
local L=Instance.new"ImageLabel"
L.Name="Expand"
L.Size=UDim2.fromOffset(9,5)
L.Position=UDim2.fromOffset(4,4)
L.BackgroundTransparency=1
L.Image=t"vape/assets/new/expandicon.png"
L.ImageColor3=l.Dark(n.Text,0.43)
L.Parent=K
local M=Instance.new"TextButton"
M.Name="Rainbow"
M.Size=UDim2.fromOffset(12,12)
M.Position=UDim2.new(1,-42,0,10)
M.BackgroundTransparency=1
M.Text=""
M.Parent=aw
local N=Instance.new"ImageLabel"
N.Size=UDim2.fromOffset(12,12)
N.BackgroundTransparency=1
N.Image=t"vape/assets/new/rainbow_1.png"
N.ImageColor3=l.Light(n.Main,0.37)
N.Parent=M
local O=N:Clone()
O.Image=t"vape/assets/new/rainbow_2.png"
O.Parent=M
local P=N:Clone()
P.Image=t"vape/assets/new/rainbow_3.png"
P.Parent=M
local Q=N:Clone()
Q.Image=t"vape/assets/new/rainbow_4.png"
Q.Parent=M
local R=Instance.new"ImageLabel"
R.Name="Knob"
R.Size=UDim2.fromOffset(26,12)
R.Position=UDim2.fromOffset(av[4]-3,-5)
R.BackgroundTransparency=1
R.Image=t"vape/assets/new/guislider.png"
R.ImageColor3=au[4]
R.Parent=ay
as.Function=as.Function or function()end
local S={}
for T=0,1,0.1 do
table.insert(S,ColorSequenceKeypoint.new(T,Color3.fromHSV(T,1,1)))
end
local T=createSlider("Custom color",ColorSequence.new(S))
local U=createSlider(
"Saturation",
ColorSequence.new{
ColorSequenceKeypoint.new(0,Color3.fromHSV(0,0,at.Value)),
ColorSequenceKeypoint.new(1,Color3.fromHSV(at.Hue,1,at.Value)),
}
)
local V=createSlider(
"Vibrance",
ColorSequence.new{
ColorSequenceKeypoint.new(0,Color3.fromHSV(0,0,0)),
ColorSequenceKeypoint.new(1,Color3.fromHSV(at.Hue,at.Sat,1)),
}
)
local W=t"vape/assets/new/guislider.png"
local X=t"vape/assets/new/guisliderrain.png"
local Y

function at.Save(Z,_)
_[as.Name]={
Hue=Z.Hue,
Sat=Z.Sat,
Value=Z.Value,
Notch=Z.Notch,
CustomColor=Z.CustomColor,
Rainbow=Z.Rainbow,
}
end

function at.Load(Z,_)
if _.Rainbow then
Z:Toggle()
end
if Z.Rainbow or _.CustomColor then
Z:SetValue(_.Hue,_.Sat,_.Value)
else
Z:SetValue(nil,nil,nil,_.Notch)
end
end

function at.SetValue(Z,_,az,aA,aB)
if aB then
if Z.Rainbow then
Z:Toggle()
end
Z.CustomColor=false
_,az,aA=au[aB]:ToHSV()
else
Z.CustomColor=true
end

Z.Hue=_ or Z.Hue
Z.Sat=az or Z.Sat
Z.Value=aA or Z.Value
Z.Notch=aB
I.ImageColor3=Color3.fromHSV(Z.Hue,Z.Sat,Z.Value)
U.Slider.UIGradient.Color=ColorSequence.new{
ColorSequenceKeypoint.new(0,Color3.fromHSV(0,0,Z.Value)),
ColorSequenceKeypoint.new(1,Color3.fromHSV(Z.Hue,1,Z.Value)),
}
V.Slider.UIGradient.Color=ColorSequence.new{
ColorSequenceKeypoint.new(0,Color3.fromHSV(0,0,0)),
ColorSequenceKeypoint.new(1,Color3.fromHSV(Z.Hue,Z.Sat,1)),
}

if Z.Rainbow or Z.CustomColor then
R.Image=X
R.ImageColor3=Color3.new(1,1,1)
m:Tween(R,n.Tween,{
Position=UDim2.fromOffset(av[4]-3,-5),
})
else
R.Image=W
R.ImageColor3=Color3.fromHSV(Z.Hue,Z.Sat,Z.Value)
m:Tween(R,n.Tween,{
Position=UDim2.fromOffset(av[aB or 4]-3,-5),
})
end

if Z.Rainbow then
if _ then
T.Slider.Fill.Size=UDim2.fromScale(math.clamp(Z.Hue,0.04,0.96),1)
end
if az then
U.Slider.Fill.Size=UDim2.fromScale(math.clamp(Z.Sat,0.04,0.96),1)
end
if aA then
V.Slider.Fill.Size=UDim2.fromScale(math.clamp(Z.Value,0.04,0.96),1)
end
else
if _ then
m:Tween(T.Slider.Fill,n.Tween,{
Size=UDim2.fromScale(math.clamp(Z.Hue,0.04,0.96),1),
})
end
if az then
m:Tween(U.Slider.Fill,n.Tween,{
Size=UDim2.fromScale(math.clamp(Z.Sat,0.04,0.96),1),
})
end
if aA then
m:Tween(V.Slider.Fill,n.Tween,{
Size=UDim2.fromScale(math.clamp(Z.Value,0.04,0.96),1),
})
end
end
as.Function(Z.Hue,Z.Sat,Z.Value)
end

function at.ToColor(az)
return Color3.fromHSV(az.Hue,az.Sat,az.Value)
end

function at.Toggle(az)
az.Rainbow=not az.Rainbow
if Y then
task.cancel(Y)
end

if az.Rainbow then
R.Image=X
table.insert(c.RainbowTable,az)

N.ImageColor3=Color3.fromRGB(5,127,100)
Y=task.delay(0.1,function()
O.ImageColor3=Color3.fromRGB(228,125,43)
Y=task.delay(0.1,function()
P.ImageColor3=Color3.fromRGB(225,46,52)
Y=nil
end)
end)
else
az:SetValue(nil,nil,nil,4)
R.Image=W
local aA=table.find(c.RainbowTable,az)
if aA then
table.remove(c.RainbowTable,aA)
end

P.ImageColor3=l.Light(n.Main,0.37)
Y=task.delay(0.1,function()
O.ImageColor3=l.Light(n.Main,0.37)
Y=task.delay(0.1,function()
N.ImageColor3=l.Light(n.Main,0.37)
end)
end)
end
end

K.MouseEnter:Connect(function()
L.ImageColor3=l.Dark(n.Text,0.16)
end)
K.MouseLeave:Connect(function()
L.ImageColor3=l.Dark(n.Text,0.43)
end)
K.Activated:Connect(function()
T.Visible=not T.Visible
U.Visible=T.Visible
V.Visible=U.Visible
L.Rotation=U.Visible and 180 or 0
end)
I.Activated:Connect(function()
I.Visible=false
J.Visible=true
J:CaptureFocus()
local az=Color3.fromHSV(at.Hue,at.Sat,at.Value)
J.Text=math.round(az.R*255)
..", "
..math.round(az.G*255)
..", "
..math.round(az.B*255)
end)
aw.InputBegan:Connect(function(az)
if
(
az.UserInputType==Enum.UserInputType.MouseButton1
or az.UserInputType==Enum.UserInputType.Touch
)and(az.Position.Y-aw.AbsolutePosition.Y)>(20*z.Scale)
then
local aA=g.InputChanged:Connect(function(aA)
if
aA.UserInputType
==(
az.UserInputType==Enum.UserInputType.MouseButton1
and Enum.UserInputType.MouseMovement
or Enum.UserInputType.Touch
)
then
at:SetValue(
nil,
nil,
nil,
math.clamp(
math.round((aA.Position.X-ay.AbsolutePosition.X)/z.Scale/27),
1,
7
)
)
end
end)

local aB
aB=az.Changed:Connect(function()
if az.UserInputState==Enum.UserInputState.End then
if aA then
aA:Disconnect()
end
if aB then
aB:Disconnect()
end
end
end)
at:SetValue(
nil,
nil,
nil,
math.clamp(math.round((az.Position.X-ay.AbsolutePosition.X)/z.Scale/27),1,7)
)
end
end)
M.Activated:Connect(function()
at:Toggle()
end)
J.FocusLost:Connect(function(az)
I.Visible=true
J.Visible=false
if az then
local aA=J.Text:split","
local aB,Z=pcall(function()
return tonumber(aA[1])
and Color3.fromRGB(tonumber(aA[1]),tonumber(aA[2]),tonumber(aA[3]))
or Color3.fromHex(J.Text)
end)

if aB then
if at.Rainbow then
at:Toggle()
end
at:SetValue(Z:ToHSV())
end
end
end)

at.Object=aw
ab.Options[as.Name]=at

return at
end

an.MouseEnter:Connect(function()
an.ImageColor3=n.Text
end)
an.MouseLeave:Connect(function()
an.ImageColor3=l.Light(n.Main,0.37)
end)
an.Activated:Connect(function()
ak.Visible=false
end)
am.Activated:Connect(function()
ak.Visible=false
end)
aj.Activated:Connect(function()
task.spawn(function()
local ar=k:JSONEncode{
nonce=k:GenerateGUID(false),
args={
invite={code="voidware"},
code="voidware",
},
cmd="INVITE_BROWSER",
}

for as=1,14 do
task.spawn(function()
request{
Method="POST",
Url="http://127.0.0.1:64"..(53+as).."/rpc?v=1",
Headers={
["Content-Type"]="application/json",
Origin="https://discord.com",
},
Body=ar,
}
end)
end
end)

task.spawn(function()
y.Text="Copied!"
setclipboard"https://discord.gg/voidware"
end)
end)
ah.MouseEnter:Connect(function()
ai.ImageColor3=n.Text
end)
ah.MouseLeave:Connect(function()
ai.ImageColor3=l.Light(n.Main,0.37)
end)
ah.Activated:Connect(function()
ak.Visible=true
end)
ag:GetPropertyChangedSignal"AbsoluteContentSize":Connect(function()
if aa.ThreadFix then
setthreadidentity(8)
end
ac.Size=UDim2.fromOffset(220,42+ag.AbsoluteContentSize.Y/z.Scale)
for ar,as in ab.Buttons do
if as.Icon then
as.Object.Text=string.rep(" ",36*z.Scale)..as.Name
end
end
end)

aa.Categories.Main=ab

return ab
end

function c.CreateCategory(aa,ab)
local ac={
Type="Category",
Expanded=false,
}

local ad=Instance.new"TextButton"
ad.Name=ab.Name.."Category"
ad.Size=UDim2.fromOffset(220,41)
ad.Position=UDim2.fromOffset(236,60)
ad.BackgroundColor3=n.Main
ad.AutoButtonColor=false
ad.Visible=false
ad.Text=""
ad.Parent=u
addBlur(ad)
addCorner(ad)
makeDraggable(ad)
local ae=Instance.new"ImageLabel"
ae.Name="Icon"
ae.Size=ab.Size
ae.Position=UDim2.fromOffset(12,(ae.Size.X.Offset>20 and 14 or 13))
ae.BackgroundTransparency=1
ae.Image=ab.Icon
ae.ImageColor3=n.Text
ae.Parent=ad
local af=Instance.new"TextLabel"
af.Name="Title"
af.Size=UDim2.new(1,-(ab.Size.X.Offset>18 and 40 or 33),0,41)
af.Position=UDim2.fromOffset(math.abs(af.Size.X.Offset),0)
af.BackgroundTransparency=1
af.Text=ab.Name
af.TextXAlignment=Enum.TextXAlignment.Left
af.TextColor3=n.Text
af.TextSize=13
af.FontFace=n.Font
af.Parent=ad
local ag=Instance.new"TextButton"
ag.Name="Arrow"
ag.Size=UDim2.fromOffset(40,40)
ag.Position=UDim2.new(1,-40,0,0)
ag.BackgroundTransparency=1
ag.Text=""
ag.Parent=ad
local ah=Instance.new"ImageLabel"
ah.Name="Arrow"
ah.Size=UDim2.fromOffset(9,4)
ah.Position=UDim2.fromOffset(20,18)
ah.BackgroundTransparency=1
ah.Image=t"vape/assets/new/expandup.png"
ah.ImageColor3=Color3.fromRGB(140,140,140)
ah.Rotation=180
ah.Parent=ag
local ai=Instance.new"ScrollingFrame"
ai.Name="Children"
ai.Size=UDim2.new(1,0,1,-41)
ai.Position=UDim2.fromOffset(0,37)
ai.BackgroundTransparency=1
ai.BorderSizePixel=0
ai.Visible=false
ai.ScrollBarThickness=2
ai.ScrollBarImageTransparency=0.75
ai.CanvasSize=UDim2.new()
ai.ClipsDescendants=true
ai.Parent=ad
local aj=Instance.new"Frame"
aj.Name="Divider"
aj.Size=UDim2.new(1,0,0,1)
aj.Position=UDim2.fromOffset(0,37)
aj.BackgroundColor3=Color3.new(1,1,1)
aj.BackgroundTransparency=0.928
aj.BorderSizePixel=0
aj.Visible=false
aj.Parent=ad
local ak=Instance.new"UIListLayout"
ak.SortOrder=Enum.SortOrder.LayoutOrder
ak.HorizontalAlignment=Enum.HorizontalAlignment.Center
ak.Parent=ai

function ac.CreateModule(al,am)
am.Function=a:wrap(am.Function,{
type="module",
name=am.Name,
category=ab.Name,
})
c:Remove(am.Name)
local an={
Enabled=false,
Options={},
Bind={},
Index=getTableSize(c.Modules),
ExtraText=am.ExtraText,
Name=am.Name,
Category=ab.Name,
SavingID=am.SavingID
}
am.Tooltip=am.Tooltip or am.Name

local ao=am.DisplayName or am.Name
local ap=false
local aq=Instance.new"TextButton"
aq.Name=am.Name
aq.Size=UDim2.fromOffset(220,40)
aq.BackgroundColor3=n.Main
aq.BorderSizePixel=0
aq.AutoButtonColor=false
aq.Text="            "..ao
aq.TextXAlignment=Enum.TextXAlignment.Left
aq.TextColor3=l.Dark(n.Text,0.16)
aq.TextSize=14
aq.FontFace=n.Font
aq.Parent=ai
if am.Premium then
local ar=Instance.new"TextLabel"
ar.Parent=aq
ar.SizeConstraint=Enum.SizeConstraint.RelativeXX
ar.AutomaticSize=Enum.AutomaticSize.X
ar.Size=UDim2.new(0,0,0,21)
ar.BackgroundColor3=Color3.new(1,1,1)
ar.TextSize=14
ar.TextTransparency=1
ar.AnchorPoint=Vector2.new(0,0.5)
ar.Text="Premium"
ar.Position=UDim2.new(0,128,0.5,0)
ar.TextColor3=Color3.new(0,0,0)
ar.FontFace=n.Font

connectvisibilitychange(function(as)
m:Tween(ar,TweenInfo.new(0.5,Enum.EasingStyle.Quad),{
BackgroundTransparency=as and 0 or 1
})
end)

addCorner(ar,UDim.new(0,5))

local as=ar:Clone()
as.Parent=ar
as.Position=UDim2.new()
as.Size=UDim2.fromScale(1,1)
as.BackgroundTransparency=1
as.AnchorPoint=Vector2.new()
as.AutomaticSize=Enum.AutomaticSize.None
as.TextSize=12
as.TextTransparency=0
as.SizeConstraint=Enum.SizeConstraint.RelativeXY

table.insert(c.Indicators,ar)
end
local ar=Instance.new"UIGradient"
ar.Rotation=90
ar.Enabled=false
ar.Parent=aq
local as=Instance.new"Frame"
local at=Instance.new"TextButton"
addTooltip(aq,am.Tooltip)
addTooltip(at,"Click to bind")
at.Name="Bind"
at.Size=UDim2.fromOffset(20,21)
at.Position=UDim2.new(1,-36,0,9)
at.AnchorPoint=Vector2.new(1,0)
at.BackgroundColor3=Color3.new(1,1,1)
at.BackgroundTransparency=0.92
at.BorderSizePixel=0
at.AutoButtonColor=false
at.Visible=false
at.Text=""
addCorner(at,UDim.new(0,4))
local au=Instance.new"ImageLabel"
au.Name="Icon"
au.Size=UDim2.fromOffset(12,12)
au.Position=UDim2.new(0.5,-6,0,5)
au.BackgroundTransparency=1
au.Image=t"vape/assets/new/bind.png"
au.ImageColor3=l.Dark(n.Text,0.43)
au.Parent=at
local av=Instance.new"TextLabel"
av.Size=UDim2.fromScale(1,1)
av.Position=UDim2.fromOffset(0,1)
av.BackgroundTransparency=1
av.Visible=false
av.Text=""
av.TextColor3=l.Dark(n.Text,0.43)
av.TextSize=12
av.FontFace=n.Font
av.Parent=at
local aw=Instance.new"ImageLabel"
aw.Name="Cover"
aw.Size=UDim2.fromOffset(154,40)
aw.BackgroundTransparency=1
aw.Visible=false
aw.Image=t"vape/assets/new/bindbkg.png"
aw.ScaleType=Enum.ScaleType.Slice
aw.SliceCenter=Rect.new(0,0,141,40)
aw.Parent=aq
local ax=Instance.new"TextLabel"
ax.Name="Text"
ax.Size=UDim2.new(1,-10,1,-3)
ax.BackgroundTransparency=1
ax.Text="PRESS A KEY TO BIND"
ax.TextColor3=n.Text
ax.TextSize=11
ax.FontFace=n.Font
ax.Parent=aw
at.Parent=aq

local ay=at:Clone()
ay.Parent=aq
ay.Name="Star"
ay.Icon.Image=t"vape/assets/new/star.png"
ay.BackgroundColor3=Color3.fromRGB(255,255,255)
ay.Visible=false
ay.BackgroundTransparency=0
ay.Position=UDim2.new(1,-70,0,9)
addTooltip(ay,"Click to favorite")

local az=Instance.new"UIStroke"
az.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
az.Transparency=0
az.Thickness=2
az.Color=Color3.fromRGB(255,255,0)
az.Parent=aq
local aA=az
connectvisibilitychange(function(aB)
aA.Enabled=an.StarActive
if not aA.Enabled then return end
m:Tween(aA,TweenInfo.new(0.5,Enum.EasingStyle.Quad),{
Thickness=aB and 2 or 0,
})
end)

an.InternalAddOnChange=Instance.new"BindableEvent"
an.InternalAddOnChange.Event:Connect(function()
ay.Position=at.Visible and UDim2.new(1,-70,0,9)or UDim2.new(1,-36,0,9)
end)
at:GetPropertyChangedSignal"Visible":Connect(function()
an.InternalAddOnChange:Fire()
end)

local function updateModuleSorting()
local aB={}

for H,I in c.Modules do
aB[I.Category]=aB[I.Category]or{starred={},normal={}}

local J={
name=I.Name,

textSize=D(I.Name,I.Object.TextSize,I.Object.Font).X
}

if I.StarActive then
table.insert(aB[I.Category].starred,J)
else
table.insert(aB[I.Category].normal,J)
end
end

local function sortByTextSize(H,I)
if H.textSize==I.textSize then
return H.name>I.name
end
return H.textSize>I.textSize
end

for H,I in aB do
table.sort(I.starred,sortByTextSize)
table.sort(I.normal,sortByTextSize)

local J={}
for K,L in I.starred do
table.insert(J,L.name)
end
for K,L in I.normal do
table.insert(J,L.name)
end

for K,L in J do
if c.Modules[L]then
c.Modules[L].Index=K
c.Modules[L].Object.LayoutOrder=K
c.Modules[L].Children.LayoutOrder=K
end
end
end
end

for aB,H in{ay,at}do
H:GetPropertyChangedSignal"Visible":Connect(function()
if H.Visible and am.Premium then
H.Visible=false
end
end)
end

an.StarActive=false
function an.ToggleStar(aB,H)
if am.Premium then
an.StarActive=false
else
an.StarActive=not an.StarActive
end
ay.BackgroundColor3=an.StarActive and Color3.fromRGB(255,255,127)or Color3.fromRGB(255,255,255)
aA.Enabled=an.StarActive
ay.Visible=an.StarActive or ap or as.Visible
if not H then
if c.FavoriteNotifications~=nil and c.FavoriteNotifications.Enabled then
c:CreateNotification(
"Module Favorite",
tostring(am.Name)
.."<font color='#FFFFFF'> has been </font>"
..(an.StarActive and"<font color='#FAFF5A'>Favorited</font>"or"<font color='#FF5A5A'>Unfaved</font>")
.."<font color='#FFFFFF'>!</font>",
0.75
)
end
end
an.InternalAddOnChange:Fire()
updateModuleSorting()
end
if am.Star and not am.Premium then
an:ToggleStar(true)
end

local aB=Instance.new"TextButton"
aB.Name="Dots"
aB.Size=UDim2.fromOffset(25,40)
aB.Position=UDim2.new(1,-25,0,0)
aB.BackgroundTransparency=1
aB.Text=""
aB.Parent=aq
local H=Instance.new"ImageLabel"
H.Name="Dots"
H.Size=UDim2.fromOffset(3,16)
H.Position=UDim2.fromOffset(4,12)
H.BackgroundTransparency=1
H.Image=t"vape/assets/new/dots.png"
H.ImageColor3=l.Light(n.Main,0.37)
H.Parent=aB
as.Name=am.Name.."Children"
as.Size=UDim2.new(1,0,0,0)
as.BackgroundColor3=l.Dark(n.Main,0.02)
as.BorderSizePixel=0
as.Visible=false
as.Parent=ai
as.ClipsDescendants=true
an.Children=as
local I=Instance.new"UIListLayout"
I.SortOrder=Enum.SortOrder.LayoutOrder
I.HorizontalAlignment=Enum.HorizontalAlignment.Center
I.Parent=as
local J=Instance.new"Frame"
J.Name="Divider"
J.Size=UDim2.new(1,0,0,1)
J.Position=UDim2.new(0,0,1,-1)
J.BackgroundColor3=Color3.new(0.19,0.19,0.19)
J.BackgroundTransparency=0.52
J.BorderSizePixel=0
J.Visible=false
J.Parent=aq
am.Function=am.Function or function()end
addMaid(an)

local K
local L

an.OptionsVisibilityChanged=a.createCustomSignal(`OPTIONS_VISIBILITY_CHANGE_{tostring(am.Name)}_{tostring(ab.Name)}`)

local function openOptions()
if K then
K:Cancel()
end
if L then
L:Cancel()
end

as.Visible=true
an.OptionsVisibilityChanged:Fire(true)

local M=I.AbsoluteContentSize.Y/z.Scale

K=m:Tween(
as,
TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
{Size=UDim2.new(1,0,0,M)}
)
end

local function closeOptions()
if K then
K:Cancel()
end
if L then
L:Cancel()
end

L=m:Tween(
as,
TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
{Size=UDim2.new(1,0,0,0)}
)

L.Completed:Once(function()
as.Visible=false
end)
task.delay(0.1,function()
an.OptionsVisibilityChanged:Fire(false)
end)
end


function an.SetBind(M,N,O,P)
if N.Mobile then
createMobileButton(an,Vector2.new(N.X,N.Y))
return
end

M.Bind=table.clone(N)
if O then
ax.Text=#N<=0 and"BIND REMOVED"or"BOUND TO"
aw.Size=UDim2.fromOffset(D(ax.Text,ax.TextSize).X+20,40)
task.delay(1,function()
aw.Visible=false
end)
end

if#N<=0 then
av.Visible=false
au.Visible=true
at.Size=UDim2.fromOffset(20,21)
else
at.Visible=true
av.Visible=true
au.Visible=false
av.Text=table.concat(N," + "):upper()
at.Size=UDim2.fromOffset(
math.max(D(av.Text,av.TextSize,av.Font).X+10,20),
21
)
end

local Q=ax.Text

if Q=="BOUND TO"then
Q=([[Bound to (<b><font color="#ffffff">%s</font></b>)]]):format(tostring(av.Text))
elseif Q=="BIND REMOVED"then
Q="Bind Removed"
else
Q=nil
end

if Q~=nil and am.Name~=nil then
c:CreateNotification(am.Name,Q,1.5,"info")
end
if#N>0 and not P then
c:CheckBounds(av.Text,an.Name)
end
an.InternalAddOnChange:Fire()
end

function an.Toggle(M,N)
if c.ThreadFix then
setthreadidentity(8)
end
M.Enabled=not M.Enabled
J.Visible=M.Enabled
ar.Enabled=M.Enabled
aq.TextColor3=(ap or as.Visible)and n.Text
or l.Dark(n.Text,0.16)
aq.BackgroundColor3=(ap or as.Visible)and l.Light(n.Main,0.02)
or n.Main
H.ImageColor3=M.Enabled and Color3.fromRGB(50,50,50)or l.Light(n.Main,0.37)
au.ImageColor3=l.Dark(n.Text,0.43)
av.TextColor3=l.Dark(n.Text,0.43)
if not M.Enabled then
for O,P in M.Connections do
if type(P)=="function"then
pcall(P)
else
pcall(function()
P:Disconnect()
end)
end
end
table.clear(M.Connections)
end
if not N then
c:UpdateTextGUI()
end
task.spawn(am.Function,M.Enabled)
end

for M,N in G do
an["Create"..M]=function(O,P)
return N(P,as,an)
end
an["Add"..M]=an["Create"..M]
end

at.MouseEnter:Connect(function()
av.Visible=false
au.Visible=not av.Visible
au.Image=t"vape/assets/new/edit.png"
if not an.Enabled then
au.ImageColor3=l.Dark(n.Text,0.16)
end
end)
at.MouseLeave:Connect(function()
av.Visible=#an.Bind>0
au.Visible=not av.Visible
au.Image=t"vape/assets/new/bind.png"
if not an.Enabled then
au.ImageColor3=l.Dark(n.Text,0.43)
end
end)
at.Activated:Connect(function()
ax.Text="PRESS A KEY TO BIND"
aw.Size=UDim2.fromOffset(D(ax.Text,ax.TextSize).X+20,40)
aw.Visible=true
c.Binding=an
end)
ay.Activated:Connect(function()
an:ToggleStar()
end)
aB.MouseEnter:Connect(function()
if not an.Enabled then
H.ImageColor3=n.Text
end
end)
aB.MouseLeave:Connect(function()
if not an.Enabled then
H.ImageColor3=l.Light(n.Main,0.37)
end
end)
aB.Activated:Connect(function()

if as.Visible then
closeOptions()
else
openOptions()
end
end)
aB.MouseButton2Click:Connect(function()

if as.Visible then
closeOptions()
else
openOptions()
end
end)
aq.MouseEnter:Connect(function()
ap=true
if not an.Enabled and not as.Visible then
aq.TextColor3=n.Text
aq.BackgroundColor3=l.Light(n.Main,0.02)
end
at.Visible=#an.Bind>0 or ap or as.Visible
ay.Visible=an.StarActive or ap or as.Visible
end)
aq.MouseLeave:Connect(function()
ap=false
if not an.Enabled and not as.Visible then
aq.TextColor3=l.Dark(n.Text,0.16)
aq.BackgroundColor3=n.Main
end
at.Visible=#an.Bind>0 or ap or as.Visible
ay.Visible=an.StarActive or ap or as.Visible
end)
as:GetPropertyChangedSignal"Visible":Connect(function()
local M=as.Visible
if M then
if count(an.Options)<=0 then
c:CreateNotification("Vape",`<font color="#ff8080"><b>⚠ No options found</b></font> for <font color="#7db8ff"><b>{tostring(am.Name)}</b></font> :c`,3)
as.Visible=false
end
end
end)
aq.Activated:Connect(function()
an:Toggle()
end)
aq.MouseButton2Click:Connect(function()

if as.Visible then
closeOptions()
else
openOptions()
end
end)
if c.isMobile then
local M=false
local N

aq.MouseButton1Down:Connect(function()
M=true
local O,P=tick(),g:GetMouseLocation()
local Q=0.75


local R=Instance.new"Frame"
R.Name="HoldProgress"
R.Size=UDim2.new(0,0,0,3)
R.Position=UDim2.new(0,0,1,-3)
R.BackgroundColor3=Color3.fromRGB(100,150,255)
R.BorderSizePixel=0
R.Parent=aq

m:Tween(
R,
TweenInfo.new(Q,Enum.EasingStyle.Linear),
{Size=UDim2.new(1,0,0,3)}
)

repeat
M=(g:GetMouseLocation()-P).Magnitude<10
task.wait()
until(tick()-O)>Q or not M or not u.Visible or c.Loaded==nil

if R and R.Parent then
R:Destroy()
end

if M and u.Visible then
if c.ThreadFix then
setthreadidentity(8)
end


N=Instance.new"Frame"
N.Name="BindingOverlay"
N.Size=UDim2.fromScale(1,1)
N.Position=UDim2.fromScale(0,0)
N.BackgroundColor3=Color3.fromRGB(0,0,0)
N.BackgroundTransparency=0.5
N.BorderSizePixel=0
N.ZIndex=1000
N.Parent=u.Parent

local S=Instance.new"TextLabel"
S.Size=UDim2.fromScale(0.8,0.2)
S.Position=UDim2.fromScale(0.5,0.4)
S.AnchorPoint=Vector2.new(0.5,0.5)
S.BackgroundColor3=l.Dark(n.Main,0.1)
S.BackgroundTransparency=0
S.BorderSizePixel=0
S.Text="TAP ANYWHERE TO SET BUTTON POSITION"
S.TextColor3=n.Text
S.TextSize=18
S.TextWrapped=true
S.FontFace=n.Font
S.Parent=N

addCorner(S,UDim.new(0,8))

local T=Instance.new"TextLabel"
T.Size=UDim2.fromScale(0.8,0.1)
T.Position=UDim2.fromScale(0.5,0.55)
T.AnchorPoint=Vector2.new(0.5,0)
T.BackgroundTransparency=1
T.Text="Module: "..am.Name
T.TextColor3=Color3.fromRGB(150,200,255)
T.TextSize=14
T.FontFace=n.Font
T.Parent=N


local U=m:Tween(
S,
TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut,-1,true),
{TextTransparency=0.3}
)

u.Visible=false
y.Visible=false
c:BlurCheck()


for V,W in c.Modules do
if W.Bind.Button then
W.Bind.Button.Visible=true
W.Bind.Button.BackgroundTransparency=0.7
end
end

local V
V=g.InputBegan:Connect(function(W)
if W.UserInputType==Enum.UserInputType.Touch then
if c.ThreadFix then
setthreadidentity(8)
end


if U then
U:Cancel()
end
if N then
N:Destroy()
end


createMobileButton(
an,
W.Position+Vector3.new(0,i:GetGuiInset().Y,0)
)


c:CreateNotification(
"Mobile Bind Created",
"<font color='#FFFFFF'>Button for </font><font color='#7db8ff'><b>"
..am.Name
.."</b></font><font color='#FFFFFF'> has been placed!</font>",
2
)

u.Visible=true
c:BlurCheck()


for X,Y in c.Modules do
if Y.Bind.Button then
Y.Bind.Button.Visible=false
Y.Bind.Button.BackgroundTransparency=0
end
end

V:Disconnect()
end
end)



local W

W=task.delay(15,function()
if V then
V:Disconnect()
end
if N then
N:Destroy()
end
if U then
U:Cancel()
end

u.Visible=true
c:BlurCheck()

for X,Y in c.Modules do
if Y.Bind.Button then
Y.Bind.Button.Visible=false
Y.Bind.Button.BackgroundTransparency=0
end
end

c:CreateNotification(
"Binding Cancelled",
"<font color='#ff8080'>Mobile bind timed out</font>",
2
)
end)
else

if R and R.Parent then
R:Destroy()
end
end
end)

aq.MouseButton1Up:Connect(function()
M=false
end)
end
I:GetPropertyChangedSignal"AbsoluteContentSize":Connect(function()
if c.ThreadFix then
setthreadidentity(8)
end
as.Size=UDim2.new(1,0,0,I.AbsoluteContentSize.Y/z.Scale)
end)

function an.SetVisible(M,N)
if N==nil then
N=not M.Object.Visible
end
M.Object.Visible=N
end

an.Object=aq
an.Children=as

if not am.NoSave then
c.Modules[am.SavingID or am.Name]=an
end

updateModuleSorting()
















function an.Restart(M)
if M.Enabled then
M:Toggle()
task.wait(0.1)
if M.Enabled then return end
M:Toggle()
end
end

return an
end

function ac.Expand(al,am)
if am~=nil then
if am==al.Expanded then return end
al.Expanded=am
else
al.Expanded=not al.Expanded
end
ai.Visible=al.Expanded
ah.Rotation=al.Expanded and 0 or 180
ad.Size=UDim2.fromOffset(
220,
al.Expanded and math.min(41+ak.AbsoluteContentSize.Y/z.Scale,601)or 41
)
aj.Visible=ai.CanvasPosition.Y>10 and ai.Visible
end

if not ac.Expanded and ab.Visible then
ac:Expand()
end

ag.Activated:Connect(function()
ac:Expand()
end)
ag.MouseButton2Click:Connect(function()
ac:Expand()
end)
ag.MouseEnter:Connect(function()
ah.ImageColor3=Color3.fromRGB(220,220,220)
end)
ag.MouseLeave:Connect(function()
ah.ImageColor3=Color3.fromRGB(140,140,140)
end)
ai:GetPropertyChangedSignal"CanvasPosition":Connect(function()
if aa.ThreadFix then
setthreadidentity(8)
end
aj.Visible=ai.CanvasPosition.Y>10 and ai.Visible
end)
ad.InputBegan:Connect(function(al)
if
al.Position.Y<ad.AbsolutePosition.Y+41
and al.UserInputType==Enum.UserInputType.MouseButton2
then
ac:Expand()
end
end)
ak:GetPropertyChangedSignal"AbsoluteContentSize":Connect(function()
if aa.ThreadFix then
setthreadidentity(8)
end
ai.CanvasSize=UDim2.fromOffset(0,ak.AbsoluteContentSize.Y/z.Scale)
if ac.Expanded then
ad.Size=UDim2.fromOffset(220,math.min(41+ak.AbsoluteContentSize.Y/z.Scale,601))
end
end)

function ac.SetVisible(al,am)
if am==nil then
am=not al.Object.Visible
end
al.LockedVisibility=am
al.Object.Visible=am
if am==false then
pcall(function()
al.Button.Object.Visible=false
end)
end
end

function ac.CreateModuleCategory(al,am)
local an={
Type="ModuleCategory",
Expanded=false,
Modules={},
Name=am.Name
}

local ao=Instance.new"Frame"
ao.Name=am.Name.."ModuleCategory"
ao.Size=UDim2.fromOffset(220,45)
ao.BackgroundColor3=am.BackgroundColor or l.Dark(n.Main,0.08)
ao.BorderSizePixel=0
ao.Parent=ai

addTooltip(ao,am.Name.." "..(am.Name~="Special"and"Special Category"or"Category"))

if am.StrokeColor then
local ap=Instance.new"UIStroke"
ap.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
ap.Color=am.StrokeColor
ap.Thickness=am.StrokeThickness or 1
ap.Transparency=am.StrokeTransparency or 0.5
ap.Parent=ao
end

addCorner(ao,UDim.new(0,4))

local ap=Instance.new"TextButton"
ap.Name="Header"
ap.Size=UDim2.fromOffset(220,45)
ap.BackgroundTransparency=1
ap.BorderSizePixel=0
ap.AutoButtonColor=false
ap.Text=""
ap.Parent=ao

local aq=Instance.new"Frame"
aq.Name="AccentBar"
aq.Size=UDim2.fromOffset(3,45)
aq.Position=UDim2.fromOffset(0,0)
aq.BackgroundColor3=am.AccentColor or am.StrokeColor or Color3.fromRGB(100,150,255)
aq.BorderSizePixel=0
aq.Parent=ao

local ar=Instance.new"UICorner"
ar.CornerRadius=UDim.new(0,4)
ar.Parent=aq

local as=Instance.new"ImageLabel"
as.Name="Icon"
as.Size=am.Size or UDim2.fromOffset(20,20)
as.Position=UDim2.fromOffset(15,15)
as.BackgroundTransparency=1
as.Image=am.Icon or""
as.ImageColor3=n.Text
as.Parent=ap

local at=Instance.new"TextLabel"
at.Name="Title"
at.Size=UDim2.new(1,-90,0,45)
at.Position=UDim2.fromOffset(45,0)
at.BackgroundTransparency=1
at.Text=am.Name
at.TextXAlignment=Enum.TextXAlignment.Left
at.TextColor3=n.Text
at.TextSize=14
at.FontFace=Font.new(n.Font.Family,Enum.FontWeight.SemiBold)
at.Parent=ap

local au=Instance.new"TextLabel"
au.Name="Count"
au.Size=UDim2.fromOffset(40,45)
au.Position=UDim2.new(1,-85,0,0)
au.BackgroundTransparency=1
au.Text="0"
au.TextXAlignment=Enum.TextXAlignment.Right
au.TextColor3=l.Dark(n.Text,0.4)
au.TextSize=12
au.FontFace=n.Font
au.Parent=ap

local av=Instance.new"TextButton"
av.Name="Arrow"
av.Size=UDim2.fromOffset(45,45)
av.Position=UDim2.new(1,-45,0,0)
av.BackgroundTransparency=1
av.Text=""
av.Parent=ap

local aw=Instance.new"ImageLabel"
aw.Name="Arrow"
aw.Size=UDim2.fromOffset(12,7)
aw.Position=UDim2.fromOffset(17,19)
aw.BackgroundTransparency=1
aw.Image=t"vape/assets/new/expandup.png"
aw.ImageColor3=n.Text
aw.Rotation=180
aw.Parent=av

local ax=Instance.new"UIGradient"
ax.Color=ColorSequence.new{
ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),
ColorSequenceKeypoint.new(1,Color3.fromRGB(0.95,0.95,0.95))
}
ax.Rotation=90
ax.Parent=ao

local ay=Instance.new"Frame"
ay.Name="ModulesContainer"
ay.Size=UDim2.new(1,0,0,0)
ay.Position=UDim2.fromOffset(0,45)
ay.BackgroundTransparency=1
ay.BorderSizePixel=0
ay.Visible=false
ay.ClipsDescendants=true
ay.Parent=ao

local az=Instance.new"UIListLayout"
az.SortOrder=Enum.SortOrder.LayoutOrder
az.HorizontalAlignment=Enum.HorizontalAlignment.Center
az.Padding=UDim.new(0,2)
az.Parent=ay

local function updateCount()
au.Text=tostring(#an.Modules)
end

function an.Toggle(aA,aB)
if aB~=nil then
if aB==aA.Expanded then return end
aA.Expanded=aB
else
aA.Expanded=not aA.Expanded
end

local H=aA.Expanded and az.AbsoluteContentSize.Y/z.Scale or 0

m:Tween(aw,TweenInfo.new(0.25,Enum.EasingStyle.Quad),{
Rotation=aA.Expanded and 0 or 180,
ImageColor3=aA.Expanded and(am.AccentColor or am.StrokeColor or Color3.fromRGB(100,150,255))or n.Text
})

m:Tween(as,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
ImageColor3=aA.Expanded and(am.AccentColor or am.StrokeColor or Color3.fromRGB(100,150,255))or n.Text
})

m:Tween(aq,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
Size=UDim2.fromOffset(3,aA.Expanded and(45+H)or 45)
})

m:Tween(ao,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
BackgroundColor3=aA.Expanded and l.Dark(n.Main,0.12)or(am.BackgroundColor or l.Dark(n.Main,0.08))
})

ay.Visible=true
m:Tween(ay,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
Size=UDim2.new(1,0,0,H)
})

m:Tween(ao,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
Size=UDim2.fromOffset(220,45+H)
})

if not aA.Expanded then
task.delay(0.3,function()
if not aA.Expanded then
ay.Visible=false
end
end)
end
end

function an.Load(aA,aB)
for H,I in aB do
local J=c.Modules[I]
if J then
aA:AddModule(J)
end
end
end

function an.AddModule(aA,aB)
if not aB or not aB.Object then return end

table.insert(aA.Modules,aB)
updateCount()

aB.Object.Parent=ay
if aB.Children then
aB.Children.Parent=ay
end
aB.ModuleCategory=an

return aB
end

function an.SetVisible(aA,aB)
if aB==nil then
aB=not ao.Visible
end
ao.Visible=aB
end
an.Button={Toggle=function()end}

function an.CreateModule(aA,aB)
local H=ac:CreateModule(aB)
aA:AddModule(H)
return H
end

ap.Activated:Connect(function()
an:Toggle()
end)

av.Activated:Connect(function()
an:Toggle()
end)

ap.MouseEnter:Connect(function()
if not an.Expanded then
m:Tween(ao,TweenInfo.new(0.15),{
BackgroundColor3=l.Light(am.BackgroundColor or n.Main,0.05)
})
m:Tween(aw,TweenInfo.new(0.15),{
ImageColor3=am.AccentColor or am.StrokeColor or Color3.fromRGB(100,150,255)
})
end
end)

ap.MouseLeave:Connect(function()
if not an.Expanded then
m:Tween(ao,TweenInfo.new(0.15),{
BackgroundColor3=am.BackgroundColor or l.Dark(n.Main,0.08)
})
m:Tween(aw,TweenInfo.new(0.15),{
ImageColor3=n.Text
})
end
end)

az:GetPropertyChangedSignal"AbsoluteContentSize":Connect(function()
if an.Expanded then
local aA=az.AbsoluteContentSize.Y/z.Scale
ay.Size=UDim2.new(1,0,0,aA)
ao.Size=UDim2.fromOffset(220,45+aA)
aq.Size=UDim2.fromOffset(3,45+aA)
end
end)

an.Object=ao
an.Container=ay

return an
end

ad:GetPropertyChangedSignal"Visible":Connect(function()
local al=ac
if al.LockedVisibility==nil then return end
if ad.Visible~=al.LockedVisibility then
ad.Visible=al.LockedVisibility
end
end)

ac.Button=aa.Categories.Main:CreateButton{
Name=ab.Name,
Icon=ab.Icon,
Size=ab.Size,
Window=ad,
Default=ab.Visible
}
function ac.ToggleCategoryButton(al,am)
ac.Button:Toggle(am)
end
if ac.Button~=nil and ac.Button.Object~=nil and ac.Button.Object.Parent~=nil then
ac.Button.Object:GetPropertyChangedSignal"Visible":Connect(function()
local al=ac
if al.LockedVisibility==nil then return end
if al.LockedVisibility then return end
ac.Button.Object.Visible=false
end)
end

ac.Object=ad
aa.Categories[ab.Name]=ac

return ac
end

local aa=shared.LANGUAGE_FLAGS_CACHE
or E(
function()
return game:GetService"HttpService":JSONDecode(
c.http_function(
`https://raw.githubusercontent.com/VapeVoidware/translations/main/LanguageFlags.json`,
true
)
)
end,
10,
function(aa,ab)
if not(aa and ab~=nil and type(ab)=="table")then
return E(
function()
return game:GetService"HttpService"
:JSONDecode(readfile(`voidware_translations/LanguageFlags.json`))
end,
10,
function(ac,ad)
if not(ac and ad~=nil and type(ad)=="table")then
return{en="🇺🇸"}
else
return ad
end
end
)
else
E(function()
if not isfolder"voidware_translations"then
makefolder"voidware_translations"
end
writefile(
`voidware_translations/LanguageFlags.json`,
game:GetService"HttpService":JSONEncode(ab)
)
end,5)
shared.LANGUAGE_FLAGS_CACHE=ab
return ab
end
end
)
c.LanguageFlags=aa

local ab=shared.TargetLanguage and tostring(shared.TargetLanguage)
or E(
function()
return readfile"voidware_translations/lang.txt"
end,
10,
function(ab,ac)
if ab then
return ac
else
pcall(function()
if not isfolder"voidware_translations"then
makefolder"voidware_translations"
end
writefile("voidware_translations/lang.txt","en")
end)
return"en"
end
end
)
local function populateLanguages(ac)
if
tostring(shared.environment)=="translator_env"
and shared.language~=nil
and type(shared.language)=="table"
then
for ad,ae in shared.language do
ac[ad]=ae
end
end
return ac
end
if tostring(shared.environment)=="translator_env"then
shared[`TRANSLATION_API_LANGUAGE_CACHE_{tostring(ab)}`]=nil
end
shared.TargetLanguage=ab
local ac={
lang=ab,
languages=shared.LANGUAGES_TRANSLATION_API_CACHE
or E(
function()
return game:GetService"HttpService":JSONDecode(
c.http_function(
`https://raw.githubusercontent.com/VapeVoidware/translations/main/Languages.json`,
true
)
)
end,
10,
function(ac,ad)
if not(ac and ad~=nil and type(ad)=="table")then
return E(
function()
return game:GetService"HttpService"
:JSONDecode(readfile(`voidware_translations/Languages.json`))
end,
10,
function(ae,af)
if not(ae and af~=nil and type(af)=="table")then
return populateLanguages{"en"}
else
return populateLanguages(af)
end
end
)
else
E(function()
if not isfolder"voidware_translations"then
makefolder"voidware_translations"
end
writefile(
`voidware_translations/Languages.json`,
game:GetService"HttpService":JSONEncode(ad)
)
end,5)
local ae=populateLanguages(ad)
shared.LANGUAGES_TRANSLATION_API_CACHE=ae
return ae
end
end
),
data=shared[`TRANSLATION_API_LANGUAGE_CACHE_{tostring(ab)}`]
or E(
function()
if ab=="en"then
return{}
end
if tostring(shared.environment)=="translator_env"and isfolder"voidware_translations"and C(`voidware_translations/{ab}.json`)then
return decode(readfile(`voidware_translations/{ab}.json`))
end
return decode(
c.http_function(
`https://raw.githubusercontent.com/VapeVoidware/translations/main/locales/{ab}.json`,
true
)
)
end,
10,
function(ac,ad)
if not(ac and ad~=nil and type(ad)=="table")then
return E(
function()
return game:GetService"HttpService"
:JSONDecode(readfile(`voidware_translations/{ab}.json`))
end,
10,
function(ae,af)
if not(ae and af~=nil and type(af)=="table")then
return{}
else
return af
end
end
)
else
E(function()
if not isfolder"voidware_translations"then
makefolder"voidware_translations"
end
writefile(`voidware_translations/{ab}.json`,game:GetService"HttpService":JSONEncode(ad))
end,5)
shared[`TRANSLATION_API_LANGUAGE_CACHE_{tostring(ab)}`]=ad
return ad
end
end
),
}
c.TranslationAPI=ac

shared.REVERT_TRANSLATION_META={}

local ad={}
local ae={}
function c.GetTranslation(af,ag)
if ag=="Information"then
return"Information"
end
if ac.lang=="en"then
return ag
end
if ae[ag]then
return ae[ag]
end
local ah=ac.data or{}
local ai=ah[ag]
if not ai then
local aj={}
for ak in string.gmatch(ag,"%S+")do
table.insert(aj,ah[ak]or ak)
end
ai=table.concat(aj," ")
end
shared.REVERT_TRANSLATION_META[ai]=ag
ae[ag]=ai
if ag==ai and not table.find(ad,ag)and shared.VoidDev then
table.insert(ad,ag)
writefile("FAILED_TRANSLATION.json",encode(ad))
end
return ai
end

local function customHook(af,ag,ah)
return function(...)
local ai={...}
ai=ag(unpack(ai))
local aj=af(unpack(ai))
if ah then
aj=ah(aj,unpack(ai))
end
return aj
end
end

c.CreateCategory=customHook(c.CreateCategory,function(af,ag)
if ag.Name then

end
return{af,ag}
end,function(af)
af.CreateModule=customHook(af.CreateModule,function(ag,ah)
if ah.Name then
ah.SavingID=ah.Name

end
if ah.Tooltip then
ah.Tooltip=c:GetTranslation(ah.Tooltip)
end
return{ag,ah}
end)
af.CreateModuleCategory=customHook(af.CreateModuleCategory,function(ag,ah)
if ah.Name then
ah.SavingID=ah.Name

end
return{ag,ah}
end)
return af
end)

shared.TRANSLATION_FUNCTION=function(af)
return Library:GetTranslation(af)
end

function c.CreateOverlay(af,ag)
local ah
local ai
ai={
Type="Overlay",
Expanded=false,
Button=af.Overlays:CreateToggle{
Name=ag.Name,
Function=function(aj)
ah.Visible=aj and(u.Visible or ai.Pinned)
if not aj then
for ak,al in ai.Connections do
al:Disconnect()
end
table.clear(ai.Connections)
end

if ag.Function then
task.spawn(ag.Function,aj)
end
end,
Icon=ag.Icon,
Size=ag.Size,
Position=ag.Position,
},
Pinned=false,
Options={},
}

ah=Instance.new"TextButton"
ah.Name=ag.Name.."Overlay"
ah.Size=UDim2.fromOffset(ag.CategorySize or 220,41)
ah.Position=UDim2.fromOffset(240,46)
ah.BackgroundColor3=n.Main
ah.AutoButtonColor=false
ah.Visible=false
ah.Text=""
ah.Parent=v
local aj=addBlur(ah)
addCorner(ah)
makeDraggable(ah)
local ak=Instance.new"ImageLabel"
ak.Name="Icon"
ak.Size=ag.Size
ak.Position=UDim2.fromOffset(12,(ak.Size.X.Offset>14 and 14 or 13))
ak.BackgroundTransparency=1
ak.Image=ag.Icon
ak.ImageColor3=n.Text
ak.Parent=ah
local al=Instance.new"TextLabel"
al.Name="Title"
al.Size=UDim2.new(1,-32,0,41)
al.Position=UDim2.fromOffset(math.abs(al.Size.X.Offset),0)
al.BackgroundTransparency=1
al.Text=ag.Name
al.TextXAlignment=Enum.TextXAlignment.Left
al.TextColor3=n.Text
al.TextSize=13
al.FontFace=n.Font
al.Parent=ah
local am=Instance.new"ImageButton"
am.Name="Pin"
am.Size=UDim2.fromOffset(16,16)
am.Position=UDim2.new(1,-47,0,12)
am.BackgroundTransparency=1
am.AutoButtonColor=false
am.Image=t"vape/assets/new/pin.png"
am.ImageColor3=l.Dark(n.Text,0.43)
am.Parent=ah
local an=Instance.new"TextButton"
an.Name="Dots"
an.Size=UDim2.fromOffset(17,40)
an.Position=UDim2.new(1,-17,0,0)
an.BackgroundTransparency=1
an.Text=""
an.Parent=ah
local ao=Instance.new"ImageLabel"
ao.Name="Dots"
ao.Size=UDim2.fromOffset(3,16)
ao.Position=UDim2.fromOffset(4,12)
ao.BackgroundTransparency=1
ao.Image=t"vape/assets/new/dots.png"
ao.ImageColor3=l.Light(n.Main,0.37)
ao.Parent=an
local ap=Instance.new"Frame"
ap.Name="CustomChildren"
ap.Size=UDim2.new(1,0,0,200)
ap.Position=UDim2.fromScale(0,1)
ap.BackgroundTransparency=1
ap.Parent=ah
local aq=Instance.new"ScrollingFrame"
aq.Name="Children"
aq.Size=UDim2.new(1,0,1,-41)
aq.Position=UDim2.fromOffset(0,37)
aq.BackgroundColor3=l.Dark(n.Main,0.02)
aq.BorderSizePixel=0
aq.Visible=false
aq.ScrollBarThickness=2
aq.ScrollBarImageTransparency=0.75
aq.CanvasSize=UDim2.new()
aq.Parent=ah
local ar=Instance.new"UIListLayout"
ar.SortOrder=Enum.SortOrder.LayoutOrder
ar.HorizontalAlignment=Enum.HorizontalAlignment.Center
ar.Parent=aq
addMaid(ai)

function ai.Expand(as,at)
if at and not aj.Visible then
return
end
as.Expanded=not as.Expanded
aq.Visible=as.Expanded
ao.ImageColor3=as.Expanded and n.Text or l.Light(n.Main,0.37)
if as.Expanded then
ah.Size=UDim2.fromOffset(
ah.Size.X.Offset,
math.min(41+ar.AbsoluteContentSize.Y/z.Scale,601)
)
else
ah.Size=UDim2.fromOffset(ah.Size.X.Offset,41)
end
end

function ai.Pin(as)
as.Pinned=not as.Pinned
am.ImageColor3=as.Pinned and n.Text or l.Dark(n.Text,0.43)
end

function ai.Update(as)
ah.Visible=as.Button.Enabled and(u.Visible or as.Pinned)
if as.Expanded then
as:Expand()
end
if u.Visible then
ah.Size=UDim2.fromOffset(ah.Size.X.Offset,41)
ah.BackgroundTransparency=0
aj.Visible=true
ak.Visible=true
al.Visible=true
am.Visible=true
an.Visible=true
else
ah.Size=UDim2.fromOffset(ah.Size.X.Offset,0)
ah.BackgroundTransparency=1
aj.Visible=false
ak.Visible=false
al.Visible=false
am.Visible=false
an.Visible=false
end
end

for as,at in G do
ai["Create"..as]=function(au,av)
return at(av,aq,ai)
end
ai["Add"..as]=ai["Create"..as]
end

an.MouseEnter:Connect(function()
if not aq.Visible then
ao.ImageColor3=n.Text
end
end)
an.MouseLeave:Connect(function()
if not aq.Visible then
ao.ImageColor3=l.Light(n.Main,0.37)
end
end)
an.Activated:Connect(function()
ai:Expand(true)
end)
an.MouseButton2Click:Connect(function()
ai:Expand(true)
end)
am.Activated:Connect(function()
ai:Pin()
end)
ah.MouseButton2Click:Connect(function()
ai:Expand(true)
end)
ar:GetPropertyChangedSignal"AbsoluteContentSize":Connect(function()
if af.ThreadFix then
setthreadidentity(8)
end
aq.CanvasSize=UDim2.fromOffset(0,ar.AbsoluteContentSize.Y/z.Scale)
if ai.Expanded then
ah.Size=UDim2.fromOffset(
ah.Size.X.Offset,
math.min(41+ar.AbsoluteContentSize.Y/z.Scale,601)
)
end
end)
af:Clean(u:GetPropertyChangedSignal"Visible":Connect(function()
ai:Update()
end))

ai:Update()
ai.Object=ah
ai.Children=ap
af.Categories[ag.Name]=ai

return ai
end

local af=Instance.new"BindableEvent"
function c.CreateProfilesGUI(ag,ah)
local ai={Sorts={}}
local aj
local ak=a.createCustomSignal"ProfilesGUI_DropdownEvent"
local al=a.createCustomSignal"modeActivated_Signal"
local am=a.createCustomSignal"uploadPopupClosed_Signal"
ag.PublicConfigs=ai

local an="newest"

local ao=function()end
local ap=function()end
local aq=function()end
local ar=function()end
local as=function()end

local at=false
local au=false
local av=false


local aw=Instance.new"Frame"
aw.Name="ConfigGUI"
aw.Size=UDim2.fromOffset(1000,550)
aw.Position=UDim2.new(0.5,-500,0.5,-275)
aw.BackgroundColor3=n.Main
aw.BackgroundColor3=Color3.fromRGB(20,20,20)
aw.Visible=false
aw.Parent=v
w=aw
addBlur(aw)
addCorner(aw)
makeDraggable(aw)

ai.Window=aw
table.insert(c.Windows,aw)


local ax=Instance.new"TextButton"
ax.BackgroundTransparency=1
ax.Text=""
ax.Modal=true
ax.Parent=aw


local ay=Instance.new"TextButton"
ay.Name="UploadButton"
ay.Parent=aw
ay.BackgroundColor3=Color3.fromRGB(5,134,105)
ay.Size=UDim2.fromOffset(140,40)
ay.Position=UDim2.new(1,-156,0,54)
ay.Font=Enum.Font.GothamBold
ay.Text="UPLOAD CONFIG"
ay.TextColor3=Color3.new(1,1,1)
ay.TextSize=12
ay.AutoButtonColor=false
ay.ZIndex=3
ay.Visible=(getgenv().username~=nil and getgenv().password~=nil)
addCorner(ay)

ay.MouseEnter:Connect(function()
if av then return end
f:Create(ay,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(10,160,120)}):Play()
end)
ay.MouseLeave:Connect(function()
if av then return end
f:Create(ay,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(5,134,105)}):Play()
end)


local az=Instance.new"Frame"
az.Name="UploadPopup"
az.Parent=aw
az.AnchorPoint=Vector2.new(0.5,0.5)
az.Position=UDim2.fromScale(0.5,0.55)
az.Size=UDim2.fromOffset(420,320)
az.BackgroundColor3=l.Dark(n.Main,0.1)
az.Visible=false
az.ZIndex=2
az.ChildAdded:Connect(function(aA)
pcall(function()
aA.ZIndex=2
end)
end)
addCorner(az)
addBlur(az)

local aA=Instance.new"UIStroke"
aA.Color=Color3.fromRGB(42,41,42)
aA.Thickness=2
aA.Parent=az

local aB=addCloseButton(az)
aB.ZIndex=11






aB.Activated:Connect(function()
az.Visible=false
am:Fire()
al:Fire""
end)

local H=true


local I=Instance.new"TextLabel"
I.Parent=az
I.BackgroundTransparency=1
I.Position=UDim2.new(0,16,0,12)
I.Size=UDim2.new(1,-32,0,30)
I.Font=Enum.Font.GothamBold
I.Text="Upload Config"
I.TextColor3=Color3.fromRGB(220,220,220)
I.TextSize=16
I.TextXAlignment=Enum.TextXAlignment.Left

local J=Instance.new"ScrollingFrame"
J.Parent=az
J.BackgroundTransparency=1
J.Size=UDim2.fromScale(1,0.23)
J.AutomaticCanvasSize=Enum.AutomaticSize.Y
J.ScrollBarThickness=4
J.Position=UDim2.new(0,10,0,60)
J.CanvasSize=UDim2.new()

local K=Instance.new"UIScale"
K.Parent=J
K.Scale=0.97

J.ChildAdded:Connect(function(L)
pcall(function()
L.ZIndex=3
end)
end)

local L=Instance.new"UIListLayout"
L.Parent=J
L.Padding=UDim.new(0,6)
L.SortOrder=Enum.SortOrder.LayoutOrder

local M

local function populateLocalProfiles()
for N,O in J:GetChildren()do
if O:IsA"TextButton"then
O:Destroy()
end
end
for N,O in c.Profiles do
local P=Instance.new"TextButton"
P.Parent=J
P.BackgroundColor3=Color3.fromRGB(40,40,40)
P.Size=UDim2.new(1,-10,0,38)
P.Text=O.Name
P.TextColor3=Color3.new(1,1,1)
P.Font=Enum.Font.Gotham
P.TextSize=16
P.ZIndex=2
P.TextTruncate=Enum.TextTruncate.AtEnd
addCorner(P)

P.Activated:Connect(function()
M=O.Name
for Q,R in J:GetChildren()do
if R:IsA"TextButton"then
R.BackgroundColor3=Color3.fromRGB(40,40,40)
end
end
P.BackgroundColor3=Color3.fromHSV(c.GUIColor.Hue,c.GUIColor.Sat,c.GUIColor.Value)
end)
end
J.CanvasSize=UDim2.fromOffset(0,L.AbsoluteContentSize.Y+10)
end

populateLocalProfiles()


local N=Instance.new"TextBox"
N.Parent=az
N.BackgroundColor3=l.Light(n.Main,0.3)
N.Position=UDim2.new(0,16,0,150)
N.Size=UDim2.new(1,-32,0,36)
N.PlaceholderText="Config name (required)"
N.Text=""
N.Font=Enum.Font.Gotham
N.TextColor3=Color3.new(1,1,1)
N.TextSize=15
addCorner(N)


local O=Instance.new"TextBox"
O.Parent=az
O.BackgroundColor3=l.Light(n.Main,0.3)
O.Position=UDim2.new(0,16,0,190)
O.Size=UDim2.new(1,-32,0,36)
O.PlaceholderText="Description (optional)"
O.Text=""
O.Font=Enum.Font.Gotham
O.TextColor3=Color3.new(1,1,1)
O.TextSize=15
addCorner(O)


local P=Instance.new"TextButton"
P.Parent=az
P.BackgroundColor3=Color3.fromRGB(5,134,105)
P.Position=UDim2.new(0,16,1,-60)
P.Size=UDim2.new(0.5,-24,0,40)
P.Text="PUBLISH"
P.TextColor3=Color3.new(1,1,1)
P.Font=Enum.Font.GothamBold
P.TextSize=13
addCorner(P)

local Q=Instance.new"TextButton"
Q.Parent=az
Q.BackgroundColor3=Color3.fromRGB(60,60,60)
Q.Position=UDim2.new(0.5,8,1,-60)
Q.Size=UDim2.new(0.5,-24,0,40)
Q.Text="CANCEL"
Q.TextColor3=Color3.new(1,1,1)
Q.Font=Enum.Font.GothamBold
Q.TextSize=13
addCorner(Q)

local R=function()end
local function resetConfigs()
for S,T in ai do
pcall(function()
if T.instance~=nil then
pcall(function()
T:Destroy()
end)
end
end)
end
end

local S=function()end

local T=Instance.new"TextButton"
T.Name="DeleteButton"
T.Parent=aw
T.BackgroundColor3=Color3.fromRGB(180,40,40)
T.Size=UDim2.fromOffset(140,40)
T.Position=UDim2.new(1,-312,0,54)
T.Font=Enum.Font.GothamBold
T.Text="DELETE CONFIG"
T.TextColor3=Color3.new(1,1,1)
T.TextSize=12
T.AutoButtonColor=false
T.Visible=(getgenv().username and getgenv().password)and true or false
T.ZIndex=2
addCorner(T)

T.MouseEnter:Connect(function()
if at then return end
f:Create(T,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(220,50,50)}):Play()
end)
T.MouseLeave:Connect(function()
if at then return end
f:Create(T,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(180,40,40)}):Play()
end)

local U=Instance.new"TextButton"
U.Name="UpdateButton"
U.Parent=aw
U.BackgroundColor3=Color3.fromRGB(100,80,200)
U.Size=UDim2.fromOffset(140,40)
U.Position=UDim2.new(1,-468,0,54)
U.Font=Enum.Font.GothamBold
U.Text="UPDATE CONFIG"
U.TextColor3=Color3.new(1,1,1)
U.TextSize=12
U.AutoButtonColor=false
U.Visible=(getgenv().username and getgenv().password)and true or false
U.ZIndex=2
addCorner(U)



U.MouseEnter:Connect(function()
if au then return end
f:Create(U,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(130,100,230)}):Play()
end)
U.MouseLeave:Connect(function()
if au then return end
f:Create(U,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(100,80,200)}):Play()
end)

local function revertToNormalMode(V)
au=false
if not V then
as()
end

for W,X in ai do
if X.instance and X.deleteIcon and X.canDelete and not X.specialDelete then
X.deleteIcon.Image=t("trash",true)
m:Tween(X.deleteIcon,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{
BackgroundColor3=Color3.fromRGB(60,60,60)
})
local Y=X.deleteIcon:FindFirstChild"UpdateStroke"
if Y then
Y:Destroy()
end
end
end
end

aq=function()
au=true

local V=0

for W,X in ai do
if X.instance and X.deleteIcon and X.canDelete and not X.specialDelete then
V=V+1
X.deleteIcon.Image=t("upload",true)
m:Tween(X.deleteIcon,TweenInfo.new(0.3,Enum.EasingStyle.Quad),{
BackgroundColor3=Color3.fromRGB(70,60,140)
})


local Y=Instance.new"UIStroke"
Y.Name="UpdateStroke"
Y.Color=Color3.fromRGB(130,100,230)
Y.Thickness=0
Y.Transparency=1
m:Tween(Y,TweenInfo.new(0.3,Enum.EasingStyle.Quad),{
Thickness=1.5,
Transparency=0.3
})
Y.Parent=X.deleteIcon
end
end
if V==0 then
flickerTextEffect(U,true,"UPDATE CONFIG")
m:Tween(U,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(100,80,200),
})
revertToNormalMode(true)
ar("No Configs To Update :c",true)
task.delay(1.3,function()
as()
end)
else
c:CreateNotification("Vape","Click the upload icon on any of your configs to update them",5,"info")
ar("Click the 'Upload' icon to update a config",true)
end
end

al:Connect(function(V)
if V=="Update"then return end
if au then
flickerTextEffect(U,true,"UPDATE CONFIG")
m:Tween(U,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(100,80,200),
})
revertToNormalMode()
end
end)

U.Activated:Connect(function()
if not getgenv().username or not getgenv().password then
c:CreateNotification("Vape","You must be logged in to update configs",6,"warning")
return
end

al:Fire"Update"

if au then

flickerTextEffect(U,true,"UPDATE CONFIG")
m:Tween(U,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(100,80,200),
})
revertToNormalMode()
c:CreateNotification("Vape","Update mode cancelled",3,"info")
else

flickerTextEffect(U,true,"STOP UPDATING")
m:Tween(U,TweenInfo.new(0.15),{
BackgroundColor3=l.Dark(Color3.fromRGB(100,80,200),0.3)
})
aq()
end
end)


local function timestampToDate(V)
local W=(os.time()-(tonumber(V)or 0))/86400
if W<1 then
return"Today"
else
local X=math.floor(W)
return X.." day"..(X>1 and"s"or"").." ago"
end
end

local V={}
local W
local X="all"

local Y=Instance.new"Frame"
Y.Name="PlaceFilterFrame"
Y.Parent=az
Y.BackgroundTransparency=1
Y.Position=UDim2.new(0,16,0,50)
Y.Size=UDim2.new(1,-32,0,30)
Y.Visible=false

local Z=Instance.new"UIListLayout"
Z.Parent=Y
Z.FillDirection=Enum.FillDirection.Horizontal
Z.SortOrder=Enum.SortOrder.LayoutOrder
Z.Padding=UDim.new(0,6)
Z.HorizontalAlignment=Enum.HorizontalAlignment.Left

local _={}

local aC={
["6872265039"]="BW Lobby",
["6872274481"]="BW Game"
}

local function createPlaceFilterButton(aD,aE)
local aF=Instance.new"TextButton"
aF.Name=aC[aD]or aD
aF.Parent=Y
aF.ZIndex=3
aF.BackgroundColor3=Color3.fromHSV(c.GUIColor.Hue,c.GUIColor.Sat,c.GUIColor.Value)
aF.BackgroundTransparency=(X==aE)and 0 or 0.8
aF.Size=UDim2.fromOffset(85,28)
aF.Font=Enum.Font.GothamBold
aF.Text=aF.Name:upper()
aF.TextColor3=Color3.new(1,1,1)
aF.TextSize=10
aF.TextTransparency=(X==aE)and 0 or 0.6
aF.AutoButtonColor=false
addCorner(aF)

local aG={
Button=aF,
PlaceId=aE,
SetActive=function(aG,aH)
aF.BackgroundTransparency=aH and 0 or 0.8
aF.TextTransparency=aH and 0 or 0.6
end,
}

aF.Activated:Connect(function()
X=aE
for aH,aI in _ do
aI:SetActive(false)
end
aG:SetActive(true)
ao()
end)

connectguicolorchange(function(aH,aI,aJ)
aF.BackgroundColor3=Color3.fromHSV(aH,aI,aJ)
end)

table.insert(_,aG)
return aG
end

local function populateDeleteConfigs()
for aD,aE in J:GetChildren()do
if aE:IsA"TextButton"or aE:IsA"TextLabel"then
aE:Destroy()
end
end

local aD={}
for aE,aF in V do
local aG=tostring(aF.place or"")
if X=="all"then
table.insert(aD,aF)
elseif X=="no_place"then
if aG==""or aG=="nil"then
table.insert(aD,aF)
end
else
if aG==X then
table.insert(aD,aF)
end
end
end

if#aD==0 then
local aE=Instance.new"TextLabel"
aE.Parent=J
aE.BackgroundTransparency=1
aE.Size=UDim2.new(1,-10,0,40)
aE.Text="No configs found for this filter"
aE.TextColor3=Color3.fromRGB(150,150,150)
aE.Font=Enum.Font.Gotham
aE.TextSize=13
return
end

for aE,aF in aD do
local aG=Instance.new"TextButton"
aG.Parent=J
aG.BackgroundColor3=Color3.fromRGB(40,40,40)
aG.Size=UDim2.new(1,-10,0,40)

local aH=""
local aI=tostring(aF.place or"")
if aI~=""and aI~="nil"then
aH=" [Place: "..aI.."]"
end

aG.Text=aF.name..aH.." (Last Edited: "..timestampToDate(aF.edited)..")"
aG.TextColor3=Color3.new(1,1,1)
aG.Font=Enum.Font.Gotham
aG.TextSize=14
aG.TextTruncate=Enum.TextTruncate.AtEnd
addCorner(aG)

aG.Activated:Connect(function()
W=aF.name
for aJ,aK in J:GetChildren()do
if aK:IsA"TextButton"then
aK.BackgroundColor3=Color3.fromRGB(40,40,40)
end
end
aG.BackgroundColor3=Color3.fromRGB(180,40,40)
end)
end

J.CanvasSize=UDim2.fromOffset(0,L.AbsoluteContentSize.Y+10)
end

ao=function()
ar("Click on the config you want to delete",true)
I.Text="Delete Config"
J.Size=UDim2.fromScale(1,0.52)
J.Position=UDim2.new(0,10,0,90)
N.Visible=false
O.Visible=false
P.Text="DELETE"
P.BackgroundColor3=Color3.fromRGB(180,40,40)
Q.Text="CANCEL"
Y.Visible=true


for aD,aE in _ do
aE.Button:Destroy()
end
_={}

if#V==0 then
Y.Visible=false
for aD,aE in J:GetChildren()do
if aE:IsA"TextButton"or aE:IsA"TextLabel"then
aE:Destroy()
end
end
local aD=Instance.new"TextLabel"
aD.Parent=J
aD.BackgroundTransparency=1
aD.Size=UDim2.new(1,-10,0,40)
aD.Text="No uploaded configs found"
aD.TextColor3=Color3.fromRGB(150,150,150)
aD.Font=Enum.Font.Gotham
aD.TextSize=13
return
end


local aD={}
local aE=false
for aF,aG in V do
local aH=tostring(aG.place or"")
if aH==""or aH=="nil"then
aE=true
else
if not table.find(aD,aH)then
table.insert(aD,aH)
end
end
end


createPlaceFilterButton("All","all")


if aE then
createPlaceFilterButton("No Place","no_place")
end


table.sort(aD)
for aF,aG in aD do
local aH=aG

if#aG>10 then
aH=aG:sub(1,8)..".."
end
createPlaceFilterButton(aH,aG)
end


for aF,aG in _ do
aG:SetActive(aG.PlaceId==X)
end

populateDeleteConfigs()
end

ap=function()
ar("Click on the config you want to upload",true)
av=true
I.Text="Upload Config"
N.Visible=true
O.Visible=true
P.Text="PUBLISH"
P.BackgroundColor3=Color3.fromRGB(5,134,105)
Q.Text="CANCEL"
M=nil
Y.Visible=false
J.Size=UDim2.fromScale(1,0.23)
J.Position=UDim2.new(0,10,0,60)
populateLocalProfiles()
end

































































local aD={
oldest=function(aD,aE)
return(aD.edited or 0)<(aE.edited or 0)
end,
newest=function(aD,aE)
return(aD.edited or 0)>(aE.edited or 0)
end,
}

am:Connect(function()
if at then
flickerTextEffect(T,true,"DELETE CONFIG")
m:Tween(T,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(180,40,40),
})
as()
end
at=false
end)

al:Connect(function(aE)
if aE=="Delete"then return end
if at then
flickerTextEffect(T,true,"DELETE CONFIG")
m:Tween(T,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(180,40,40),
})
end
at=false
az.Visible=false
end)

T.Activated:Connect(function()
if not getgenv().username or not getgenv().password then
c:CreateNotification("Vape","You must be logged in to delete configs",6,"warning")
return
end
al:Fire"Delete"

c:CreateNotification("Vape","Fetching your uploaded configs...",4,"info")
ar("Fetching uploaded configs...",true)

local aE,aF=pcall(function()
return request{
Url="https://configs.vapevoidware.xyz/configs/by-username",
Method="POST",
Headers={["Content-Type"]="application/json"},
Body=k:JSONEncode{
username=getgenv().username,
password=getgenv().password,
},
}
end)

if at then
flickerTextEffect(T,true,"DELETE CONFIG")
m:Tween(T,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(180,40,40),
})
else
flickerTextEffect(T,true,"STOP DELETING")
m:Tween(T,TweenInfo.new(0.15),{
BackgroundColor3=l.Dark(Color3.fromRGB(180,40,40),0.3),
})
end

if aE and aF and aF.StatusCode==200 then
local aG=k:JSONDecode(aF.Body)
V=aG.configs or{}

if#V==0 then
c:CreateNotification("Vape","You have no uploaded configs",5,"info")
return
end

at=true
ao()
J.Visible=true
az.Visible=true
else
local aG=aF and aF.Body or"Request failed"
if aF and aF.StatusCode==401 then
aG="Invalid username/password"
else
local aH=decode(aG)
if aH~=nil and type(aH)=="table"and aH.detail~=nil then
aG=aH.detail
end
end

ar("Couldn't fetch your configs :c",true)
task.delay(0.5,function()
as()
end)
c:CreateNotification("Vape","Failed to fetch your configs: "..aG,8,"warning")
end
end)

P.Activated:Connect(function()
if at then
if not W then
c:CreateNotification("Vape","Please select a config to delete",5,"warning")
return
end

c:CreateNotification("Vape",`Deleting {W}...`,5,"info")

local aE,aF=pcall(function()
return request{
Url="https://configs.vapevoidware.xyz/configs",
Method="DELETE",
Headers={["Content-Type"]="application/json"},
Body=k:JSONEncode{
username=getgenv().username,
password=getgenv().password,
config=W,
place=tostring(c.Place or game.PlaceId)
}
}
end)

if aE and aF and aF.StatusCode==200 then
c:CreateNotification("Vape",`Successfully deleted {W}`,6,"info")
az.Visible=false
am:Fire()

task.spawn(function()
task.wait(1)
S()
end)
else
local aG=aF and aF.Body or"Unknown error"
if aF and aF.StatusCode==401 then
aG="Invalid username/password!"
else
local aH=decode(aG)
if aH~=nil and type(aH)=="table"and aH.detail~=nil then
aG=aH.detail
end
end
c:CreateNotification("Vape","Delete failed: "..aG,8,"warning")
end
else
if not M then
c:CreateNotification("Vape","Please select a local profile first",5,"warning")
return
end
if N.Text==""then
c:CreateNotification("Vape","Config name is required",5,"warning")
flickerTextEffect(N,true,"Name Required!")
task.wait(0.3)
flickerTextEffect(N,true,"")
return
end

local aE="vape/profiles/"..M..c.Place..".txt"
if not C(aE)then
c:CreateNotification("Vape","Failed to read config file. Please choose different profile :c",6,"warning")
return
end
local aF,aG=pcall(readfile,aE)
if not(aF and aG~=nil)then
c:CreateNotification("Vape","Failed to read config file. Please choose different profile :c",6,"warning")
return
end

c:CreateNotification("Vape","Publishing config...",5,"info")

local aH={
username=getgenv().username,
password=getgenv().password,
config_name=N.Text,
config=aG,
color={c.GUIColor.Hue,c.GUIColor.Sat,c.GUIColor.Value},
description=O.Text,
}
if H then
aH.place=c.Place or game.PlaceId
aH.place=tostring(aH.place)
end

local aI,aJ=pcall(function()
return request{
Url="https://configs.vapevoidware.xyz/configs",
Method="POST",
Headers={["Content-Type"]="application/json"},
Body=k:JSONEncode(aH)
}
end)

if aI and aJ and aJ.StatusCode==200 then
local aK=aJ.Body
local aL=string.find(aK,"isOverwritten")and true or false
c:CreateNotification(
"Vape",
`Successfully published "{N.Text}"`
..(aL and" (overwritten)"or"")
..(H and" [Place Based]"or""),
8,
"info"
)

az.Visible=false
am:Fire()

task.spawn(function()
task.wait(1)
S()
end)
else
local aK=aI and(aJ and aJ.Body or"Unknown error")or tostring(aJ)
if aJ.StatusCode==401 then
aK="Username or Password missing/invalid!"
else
local aL=decode(aK)
if aL~=nil and type(aL)=="table"and aL.detail~=nil then
aK=aL.detail
end
end
if string.lower(aK):find"rate limit"then
ar("Please wait before uploading a config!",true)
task.delay(2,function()
ar("Click on the config you want to upload",true)
end)
end
c:CreateNotification("Vape","Failed to publish: "..aK,10,"warning")
end
end
end)

Q.Activated:Connect(function()
az.Visible=false
at=false
av=false
ap()
end)

am:Connect(function()
if av then
flickerTextEffect(ay,true,"UPLOAD CONFIG")
m:Tween(ay,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(5,134,105),
})
av=false
as()
end
end)

al:Connect(function(aE)
if aE=="Upload"then return end
if av then
flickerTextEffect(ay,true,"UPLOAD CONFIG")
m:Tween(ay,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(5,134,105),
})
av=false
az.Visible=false
as()
end
end)

ay.Activated:Connect(function()
al:Fire"Upload"
at=false

if av then

flickerTextEffect(ay,true,"UPLOAD CONFIG")
m:Tween(ay,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(5,134,105),
})
av=false
az.Visible=false
as()
else
flickerTextEffect(ay,true,"STOP UPLOADING")
m:Tween(ay,TweenInfo.new(0.15),{
BackgroundColor3=l.Dark(Color3.fromRGB(5,134,105),0.3),
})
av=true
ap()
populateLocalProfiles()
O.Text=""
az.Visible=true
end
end)

local function updateDeleteButtonVisibility()
T.Visible=(getgenv().username~=nil and getgenv().password~=nil)
ay.Visible=T.Visible
U.Visible=T.Visible
end
updateDeleteButtonVisibility()


local aE=Instance.new"ImageLabel"
aE.Name="Icon"
aE.Size=UDim2.fromOffset(16,16)
aE.Position=UDim2.fromOffset(16,14)
aE.BackgroundTransparency=1
aE.Image=t"vape/assets/new/profilesicon.png"
aE.ImageColor3=n.Text
aE.Parent=aw

local aF=Instance.new"TextLabel"
aF.Parent=aE
aF.BackgroundTransparency=1
aF.Position=UDim2.new(0,24,0,0)
aF.Size=UDim2.new(1,100,0,16)
aF.Font=Enum.Font.GothamBold
aF.Text="Public Profiles"
aF.TextColor3=n.Text
aF.TextSize=14
aF.TextXAlignment=Enum.TextXAlignment.Left


local aG=Instance.new"Frame"
aG.Name="BadgeContainer"
aG.Parent=aw
aG.BackgroundTransparency=1
aG.Position=UDim2.new(0,160,0,12)
aG.Size=UDim2.fromOffset(400,20)

local aH=Instance.new"UIListLayout"
aH.Parent=aG
aH.FillDirection=Enum.FillDirection.Horizontal
aH.SortOrder=Enum.SortOrder.LayoutOrder
aH.Padding=UDim.new(0,6)
aH.VerticalAlignment=Enum.VerticalAlignment.Center


if getgenv().username then
local aI=Instance.new"Frame"
aI.Name="UserBadge"
aI.Parent=aG
aI.BackgroundColor3=Color3.fromRGB(45,45,45)
aI.Size=UDim2.fromOffset(0,20)
aI.AutomaticSize=Enum.AutomaticSize.X
addCorner(aI,UDim.new(0,10))

local aJ=Instance.new"UIPadding"
aJ.Parent=aI
aJ.PaddingLeft=UDim.new(0,8)
aJ.PaddingRight=UDim.new(0,8)

local aK=Instance.new"TextLabel"
aK.Parent=aI
aK.BackgroundTransparency=1
aK.Position=UDim2.fromOffset(4,-1)
aK.Size=UDim2.fromOffset(12,20)
aK.Font=Enum.Font.GothamBold
aK.Text="@"
aK.TextColor3=Color3.fromRGB(150,150,150)
aK.TextSize=12

local aL=Instance.new"TextLabel"
aL.Parent=aI
aL.BackgroundTransparency=1
aL.Position=UDim2.fromOffset(16,0)
aL.Size=UDim2.fromOffset(0,20)
aL.AutomaticSize=Enum.AutomaticSize.X
aL.Font=Enum.Font.Gotham
aL.Text=tostring(getgenv().username)
aL.TextColor3=Color3.fromRGB(200,200,200)
aL.TextSize=13
aL.TextXAlignment=Enum.TextXAlignment.Left

local aM=Instance.new"UIStroke"
aM.Color=Color3.fromRGB(70,70,70)
aM.Thickness=1
aM.Parent=aI
end


if getgenv().admin_config_api_key~=nil and shared.VoidDev then
local aI=Instance.new"Frame"
aI.Name="AdminBadge"
aI.Parent=aG
aI.BackgroundColor3=Color3.fromRGB(60,30,30)
aI.Size=UDim2.fromOffset(0,20)
aI.AutomaticSize=Enum.AutomaticSize.X
addCorner(aI,UDim.new(0,10))

local aJ=Instance.new"UIPadding"
aJ.Parent=aI
aJ.PaddingLeft=UDim.new(0,8)
aJ.PaddingRight=UDim.new(0,8)

local aK=Instance.new"TextLabel"
aK.Parent=aI
aK.BackgroundTransparency=1
aK.Position=UDim2.fromOffset(3,-1)
aK.Size=UDim2.fromOffset(12,20)
aK.Font=Enum.Font.GothamBold
aK.Text="★"
aK.TextColor3=Color3.fromRGB(255,100,100)
aK.TextSize=12

local aL=Instance.new"TextLabel"
aL.Parent=aI
aL.BackgroundTransparency=1
aL.Position=UDim2.fromOffset(16,0)
aL.Size=UDim2.fromOffset(0,20)
aL.AutomaticSize=Enum.AutomaticSize.X
aL.Font=Enum.Font.GothamBold
aL.Text="ADMIN"
aL.TextColor3=Color3.fromRGB(255,120,120)
aL.TextSize=13
aL.TextXAlignment=Enum.TextXAlignment.Left

local aM=Instance.new"UIStroke"
aM.Color=Color3.fromRGB(255,80,80)
aM.Thickness=1
aM.Transparency=0.3
aM.Parent=aI
end

local aI=Instance.new"TextLabel"
aI.Parent=aE
aI.BackgroundTransparency=1
aI.Position=UDim2.new(0,24,0,0)
aI.Size=UDim2.new(1,100,0,16)
aI.Font=Enum.Font.GothamBold
aI.Text="Public Profiles"
aI.TextColor3=n.Text
aI.TextSize=14
aI.TextXAlignment=Enum.TextXAlignment.Left


local aJ=Instance.new"ImageButton"
aJ.Name="CloseButton"
aJ.Size=UDim2.fromOffset(24,24)
aJ.Position=UDim2.new(1,-40,0,12)
aJ.BackgroundColor3=Color3.fromRGB(60,60,60)
aJ.AutoButtonColor=false
aJ.Image=t"vape/assets/new/close.png"
aJ.ImageColor3=Color3.fromRGB(200,200,200)
aJ.Parent=aw
addCorner(aJ)

aJ.MouseEnter:Connect(function()
f
:Create(aJ,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{
BackgroundColor3=Color3.fromRGB(220,53,53),
ImageColor3=Color3.fromRGB(255,255,255),
})
:Play()
end)

aJ.MouseLeave:Connect(function()
f
:Create(aJ,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{
BackgroundColor3=Color3.fromRGB(60,60,60),
ImageColor3=Color3.fromRGB(200,200,200),
})
:Play()
end)

aJ.Activated:Connect(function()
aw.Visible=false
u.Visible=true
if c.TutorialAPI.isActive then
c.TutorialAPI:setText"Tutorial Cancelled"
task.delay(0.3,function()
c.TutorialAPI:revertTutorialMode()
end)
end
end)

local aK=Instance.new"Frame"
aK.Parent=aw
aK.BackgroundColor3=Color3.new(1,1,1)
aK.BackgroundTransparency=0.95
aK.BorderSizePixel=0
aK.Position=UDim2.new(0,0,0,44)
aK.Size=UDim2.new(1,0,0,1)

local aL=Instance.new"Frame"
aL.Name="Search"
aL.Parent=aw
aL.BackgroundColor3=l.Dark(n.Main,0.05)
aL.BorderSizePixel=0
aL.Position=UDim2.new(0,16,0,54)
aL.Size=UDim2.fromOffset(968,40)

local aM=Instance.new"UIStroke"
aM.Color=Color3.fromRGB(42,41,42)
aM.Thickness=1
aM.Parent=aL

addCorner(aL)

local aN=Instance.new"ImageLabel"
aN.Parent=aL
aN.BackgroundTransparency=1
aN.BorderSizePixel=0
aN.Position=UDim2.new(0,14,0.5,-8)
aN.Size=UDim2.fromOffset(16,16)
aN.Image=t"vape/assets/new/search.png"
aN.ImageColor3=Color3.fromRGB(150,150,150)

local aO=Instance.new"TextBox"
aO.Parent=aL
aO.BackgroundTransparency=1
aO.BorderSizePixel=0
aO.Position=UDim2.new(0,40,0,0)
aO.Size=UDim2.new(1,-50,1,0)
aO.Font=Enum.Font.Gotham
aO.PlaceholderColor3=Color3.fromRGB(180,180,180)
aO.PlaceholderText="Search profile name or username..."
aO.Text=""
aO.TextColor3=Color3.fromRGB(200,200,200)
aO.TextSize=15
aO.TextXAlignment=Enum.TextXAlignment.Left

local aP=Instance.new"Frame"
aP.Parent=aw
aP.BackgroundTransparency=1
aP.BorderSizePixel=0
aP.Position=UDim2.new(0,16,0,104)
aP.Size=UDim2.fromOffset(968,32)

local aQ=Instance.new"UIListLayout"
aQ.Parent=aP
aQ.FillDirection=Enum.FillDirection.Horizontal
aQ.SortOrder=Enum.SortOrder.LayoutOrder
aQ.VerticalAlignment=Enum.VerticalAlignment.Center
aQ.Padding=UDim.new(0,8)

local aR=Instance.new"ScrollingFrame"
aR.Name="Children"
aR.Parent=aw
aR.Position=UDim2.new(0,16,0,144)
aR.Size=UDim2.fromOffset(968,390)
aR.BackgroundTransparency=1
aR.BorderSizePixel=0
aR.ScrollBarThickness=3
aR.ScrollBarImageTransparency=0.5
aR.AutomaticCanvasSize=Enum.AutomaticSize.XY
aR.CanvasSize=UDim2.new()
aR.ClipsDescendants=false

local aS=Instance.new"TextLabel"
aS.Name="ConfigsInfo"
aS.Parent=aw
aS.Position=aR.Position
aS.Size=aR.Size
aS.Text="No configs found :c"
aS.BackgroundColor3=Color3.fromRGB(30,30,30)
aS.TextSize=18
aS.Visible=false

local aT={
SetStep=function(aT,aU,aV)
if aV~=nil then
aS.Visible=aV
end
if aU~=nil then
aS.Text=aU
end
end
}

S=function()
ar("Refreshing Configs...",true)
local aU,aV=E(function()
return k:JSONDecode(c.http_function"https://configs.vapevoidware.xyz")
end,3)
if not aU then
errorNotification("Voidware | Configs","Couldn't load the configs data :c Try again later",5)
ar("Couldn't load configs :c",true)
return
end

resetConfigs()
for aW,aX in aR:GetChildren()do
pcall(function()
if aX:IsA"TextButton"then
aX:Destroy()
end
end)
end
ai={Sorts=ai.Sorts}

table.sort(aV,aD[an])
local aW=0
for aX,aY in aV do
local aZ=c.Place or game.PlaceId
if not aY.place or tostring(aY.place)==tostring(aZ)then
aW=aW+1
aR.ClipsDescendants=(aW>10)
R(aY.name,aY.username,aY)
end
end
if aW<1 then
aT:SetStep("No Configs found :C",true)
else
aT:SetStep(nil,false)
end
if aj~=nil then
local aX={"all"}
for aY,aZ in table.clone(aV)do
if not aZ.username then continue end
aZ.username=tostring(aZ.username)
if table.find(aX,aZ.username)then continue end
table.insert(aX,aZ.username)
end
aj:SetValues(aX,"all")
end
as()
end
c.ConfigsAPIRefresh=function()
task.spawn(S)
end

local aU=Instance.new"UIGridLayout"
aU.Parent=aR
aU.SortOrder=Enum.SortOrder.LayoutOrder
aU.CellSize=UDim2.fromOffset(180,180)
aU.CellPadding=UDim2.fromOffset(12,12)
aU.HorizontalAlignment=Enum.HorizontalAlignment.Center

aU:GetPropertyChangedSignal"AbsoluteContentSize":Connect(function()
if ag.ThreadFix then
setthreadidentity(8)
end
aR.CanvasSize=UDim2.fromOffset(0,aU.AbsoluteContentSize.Y+20)
end)

ak:Connect(function()
local aV=aj.Value
for aW,aX in ai do
if aX.instance~=nil and aX.username~=nil then
aX.instance.Visible=(aV=="all"or tostring(aX.username)==aV)
end
end
end)

R=function(aV,aW,aX)
if ai[aV]then return end
ai[aV]=table.clone(aX)

local aY=false
local aZ=false

if getgenv().username and aW and aW:lower()==tostring(getgenv().username):lower()then
aZ=true
elseif getgenv().admin_config_api_key~=nil and shared.VoidDev then
aZ=true
aY=true
end
local a_=Instance.new"TextButton"
a_.Parent=aR
a_.BackgroundTransparency=1
a_.LayoutOrder=#aR:GetChildren()+1
a_.ClipsDescendants=false
a_.AutoButtonColor=false
a_.Text=""
a_.Size=UDim2.fromOffset(220,220)

ai[aV].instance=a_

local a0,a1
if aX.color~=nil and type(aX.color)=="table"then
a0,a1=hsv(unpack(aX.color))
else
a0=false
a1=nil
end

local a2=a0 and a1~=nil and"config"or"gui"
local function getStrokeColor()
return a2=="gui"and Color3.fromHSV(c.GUIColor.Hue,c.GUIColor.Sat,c.GUIColor.Value)or a1
end

local a3=Instance.new"UIStroke"
a3.Color=Color3.fromRGB(50,50,50)
if a2=="gui"then
connectguicolorchange(function(a4,a5,a6)
a3.Color=Color3.fromHSV(a4,a5,a6)
end)
else
a3.Color=a1
end
a3.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
a3.Thickness=1
a3.Parent=a_

addCorner(a_)


local a4=Instance.new"TextLabel"
a4.Parent=a_
a4.BackgroundTransparency=1
a4.Position=UDim2.new(0,12,0,12)
a4.Size=UDim2.new(1,-24,0,40)
a4.Font=Enum.Font.GothamBold
a4.RichText=true
a4.Text=aV
a4.TextColor3=Color3.fromRGB(220,220,220)
a4.TextSize=15
a4.TextWrapped=true
a4.TextXAlignment=Enum.TextXAlignment.Left
a4.TextYAlignment=Enum.TextYAlignment.Top


local a5=Instance.new"TextLabel"
a5.Parent=a_
a5.BackgroundTransparency=1
a5.Position=UDim2.new(0,12,0,52)
a5.Size=UDim2.new(1,-24,0,18)
a5.Font=Enum.Font.Gotham
a5.Text="By: @"..aW
a5.TextColor3=Color3.fromRGB(150,150,150)
a5.TextSize=15
a5.TextXAlignment=Enum.TextXAlignment.Left


local a6=Instance.new"TextLabel"
a6.Parent=a_
a6.BackgroundTransparency=1
a6.Position=UDim2.new(0,12,0,70)
a6.Size=UDim2.new(1,-24,0,65)
a6.Font=Enum.Font.Gotham
a6.Text=aX.description or"No description provided"
a6.TextColor3=Color3.fromRGB(130,130,130)
a6.TextSize=15
a6.TextWrapped=true
a6.TextXAlignment=Enum.TextXAlignment.Left
a6.TextYAlignment=Enum.TextYAlignment.Top


local a7=Instance.new"TextLabel"
a7.Parent=a_
a7.BackgroundTransparency=1
a7.Position=UDim2.new(0,12,0,100)
a7.Size=UDim2.new(1,-24,0,16)
a7.Font=Enum.Font.Gotham
a7.Text="Last Update: "..timestampToDate(aX.edited)
a7.TextColor3=Color3.fromRGB(100,100,100)
a7.TextSize=14

local a8=false


local a9=Instance.new"TextButton"
a9.Parent=a_
a9.BackgroundColor3=Color3.fromRGB(5,134,105)
connectguicolorchange(function(ba,bb,bc)
a9.BackgroundColor3=a8 and l.Dark(Color3.fromHSV(ba,bb,bc),0.3)or Color3.fromHSV(ba,bb,bc)
end)
a9.Size=aZ and UDim2.new(1,-64,0,38)or UDim2.new(1,-24,0,38)
a9.Position=UDim2.new(0,12,1,-50)
a9.Font=Enum.Font.GothamBold
a9.Text="DOWNLOAD"
a9.TextColor3=Color3.fromRGB(255,255,255)
a9.TextSize=12
a9.AutoButtonColor=false
a9.BorderSizePixel=0

addCorner(a9)

a9.MouseEnter:Connect(function()
local ba,bb,bc=c.GUIColor.Hue,c.GUIColor.Sat,c.GUIColor.Value
local bd=a8 and l.Dark(Color3.fromHSV(ba,bb,bc),0.3)or Color3.fromHSV(ba,bb,bc)
f
:Create(a9,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{
BackgroundColor3=l.Light(bd,0.3),
})
:Play()
end)

a9.MouseLeave:Connect(function()
local ba,bb,bc=c.GUIColor.Hue,c.GUIColor.Sat,c.GUIColor.Value
local bd=a8 and l.Dark(Color3.fromHSV(ba,bb,bc),0.3)or Color3.fromHSV(ba,bb,bc)
f
:Create(a9,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{
BackgroundColor3=bd
})
:Play()
end)

if aZ then
local ba=aY

local bb=ba
and{
Title="Force Delete Config",
ActionWord='<b><font color="#ff3b3b">Force Deleting</font></b>',
DoneWord='<b><font color="#ff6b6b">Force Deleted</font></b>',
FailWord='<b><font color="#ffb86b">Force Failed</font></b>',
PromptNote='<br/><font color="#ff6b6b"><b>Admin action.</b> This will permanently remove the config.</font>',
Accent=Color3.fromRGB(200,45,45),
}
or{
Title="Delete Config",
ActionWord='<b><font color="#ff6b6b">Deleting</font></b>',
DoneWord='<b><font color="#7CFF7C">Deleted</font></b>',
FailWord='<b><font color="#ffb86b">Failed</font></b>',
PromptNote='<br/><font color="#aaaaaa">This action cannot be undone.</font>',
Accent=Color3.fromRGB(180,40,40),
}

local bc=Instance.new"ImageButton"
bc.Parent=a_
bc.Size=UDim2.fromOffset(35,35)
bc.Position=UDim2.new(1,-47,1,-50)
bc.BackgroundColor3=Color3.fromRGB(60,60,60)
bc.AutoButtonColor=false
bc.Image=t((aY and"hammer"or"trash"),true)
bc.ImageColor3=Color3.fromRGB(220,220,220)
bc.ZIndex=a9.ZIndex
addCorner(bc)

ai[aV].deleteIcon=bc
ai[aV].canDelete=aZ
ai[aV].specialDelete=aY

if ba then
bc.BackgroundColor3=Color3.fromRGB(90,30,30)

local bd=Instance.new"UIStroke"
bd.Color=Color3.fromRGB(255,80,80)
bd.Thickness=1.5
bd.Transparency=0.3
bd.Parent=bc
else
bc.MouseEnter:Connect(function()
f:Create(bc,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(180,40,40),
ImageColor3=Color3.fromRGB(255,255,255),
}):Play()
end)

bc.MouseLeave:Connect(function()
f:Create(bc,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(60,60,60),
ImageColor3=Color3.fromRGB(220,220,220),
}):Play()
end)
end

bc.Activated:Connect(function()
if au then

local bd=c.Profile or"Unknown Profile"

c:CreatePrompt{
Title="Update Config",
Text=string.format(
'Overwrite <b><font color="rgb(150,150,255)">"%s"</font></b> with your current profile <b><font color="rgb(100,200,100)">"%s"</font></b>?\n\n<font color="rgb(180,180,180)">This will update the config with your current settings and GUI color.</font>',
aV,
bd
),
ConfirmText="UPDATE",
CancelText="CANCEL",
OnConfirm=function()

local be="vape/profiles/"..bd..c.Place..".txt"
if not C(be)then
c:CreateNotification(
"Vape",
"Failed to read current profile config file",
6,
"warning"
)
revertToNormalMode()
return
end
local bf,bg=pcall(readfile,be)
if not(bf and bg~=nil)then
c:CreateNotification(
"Vape",
"Failed to read current profile config file",
6,
"warning"
)
revertToNormalMode()
return
end

c:CreateNotification("Vape",`Updating "{aV}"...`,5,"info")

local bh={
username=getgenv().username,
password=getgenv().password,
config_name=aV,
config=bg,
color={c.GUIColor.Hue,c.GUIColor.Sat,c.GUIColor.Value},
description=aX.description or"",
}

if H then
bh.place=c.Place or game.PlaceId
bh.place=tostring(bh.place)
end

local bi,bj=pcall(function()
return request{
Url="https://configs.vapevoidware.xyz/configs",
Method="POST",
Headers={["Content-Type"]="application/json"},
Body=k:JSONEncode(bh),
}
end)

if bi and bj and bj.StatusCode==200 then
c:CreateNotification(
"Vape",
`Successfully updated "{aV}" with profile "{bd}"!`,
8,
"info"
)

revertToNormalMode()

task.spawn(function()
task.wait(1)
S()
end)
else
local bk=bi and(bj and bj.Body or"Unknown error")
or tostring(bj)
if bj and bj.StatusCode==401 then
bk="Username or Password missing/invalid!"
else
local bl=decode(bk)
if bl~=nil and type(bl)=="table"and bl.detail~=nil then
bk=bl.detail
end
end
c:CreateNotification("Vape","Failed to update: "..bk,10,"warning")
revertToNormalMode()
end
end,
OnCancel=function()
revertToNormalMode()
end,
}
else

c:CreatePrompt{
Title=bb.Title,
Text=([[Are you sure you want to delete "%s"?%s]]):format(aV,bb.PromptNote),
ConfirmText="DELETE",
CancelText="CANCEL",
OnConfirm=function()
c:CreateNotification(
"Vape",
(bb.ActionWord..' "%s"...'):format(aV),
5,
"info"
)

local bd={
username=getgenv().username,
password=getgenv().password,
config=aV,
place=tostring(c.Place or game.PlaceId),
}

if ba then
bd.adminkey=getgenv().admin_config_api_key
bd.username=tostring(aW)
bd.password=nil
end

local be,bf=pcall(function()
return request{
Url="https://configs.vapevoidware.xyz/configs",
Method="DELETE",
Headers={["Content-Type"]="application/json"},
Body=k:JSONEncode(bd),
}
end)

if be and bf and bf.StatusCode==200 then
c:CreateNotification(
"Vape",
(bb.DoneWord..' "%s"'):format(aV),
6,
"info"
)
S()
else
local bg=bf and bf.Body or"Unknown error"
if bf and bf.StatusCode==401 then
bg="Invalid username/password!"
else
local bh=decode(bg)
if bh and type(bh)=="table"and bh.detail then
bg=bh.detail
end
end

c:CreateNotification(
"Vape",
(bb.FailWord..": %s"):format(bg),
8,
"warning"
)
end
end,
}
end
end)
end

m:Tween(a_,TweenInfo.new(0.3,Enum.EasingStyle.Quad),{
BackgroundColor3=l.Light(n.Main,0.08),
BackgroundTransparency=0,
})

a_.MouseEnter:Connect(function()
m:Tween(a_,TweenInfo.new(0.1,Enum.EasingStyle.Quad),{
BackgroundColor3=l.Light(n.Main,0.2),
})
m:Tween(a4,TweenInfo.new(0.1,Enum.EasingStyle.Quad),{
TextSize=17,
})
m:Tween(a5,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{
TextColor3=Color3.fromRGB(230,230,230),
})
m:Tween(a7,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{
TextColor3=Color3.fromRGB(200,200,200),
})
m:Tween(a3,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{

Color=getStrokeColor(),
Thickness=2,
})
end)

a_.MouseLeave:Connect(function()
m:Tween(a_,TweenInfo.new(0.1,Enum.EasingStyle.Quad),{
BackgroundColor3=l.Light(n.Main,0.08),
})
m:Tween(a4,TweenInfo.new(0.1,Enum.EasingStyle.Quad),{
TextSize=15,
})
m:Tween(a5,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{
TextColor3=Color3.fromRGB(150,150,150),
})
m:Tween(a7,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{
TextColor3=Color3.fromRGB(100,100,100),
})
m:Tween(a3,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{

Color=l.Dark(getStrokeColor(),0.3),
Thickness=1,
})
end)

pcall(function()
local ba=ai[aV]
if ba then
local bb=`{ba.name} ({ba.username})`
local bc=c.Profiles
if(bc~=nil and type(bc)=="table")then
for bd,be in bc do
if type(be)~="table"then continue end
if be.Name==bb then
a9.Text="REINSTALL"
a8=true
local bf,bg,bh=c.GUIColor.Hue,c.GUIColor.Sat,c.GUIColor.Value
a9.BackgroundColor3=a8
and l.Dark(Color3.fromHSV(bf,bg,bh),0.3)
or Color3.fromHSV(bf,bg,bh)
break
end
end
end
end
end)

a9.Activated:Connect(function()
local ba=ai[aV]
if ba then
local bb=string.format("%s (%s)",ba.name,ba.username)
local bc,bd=ba.link:match"^(.-/)([^/]+)$"
if not bc or not bd then
errorNotification("Voidware | Configs",`Invalid URL for {tostring(aV)}. Please report this to a developer in discord.gg/voidware`,10)
warn("Invalid URL:",ba.link)
return
end local
be, bf=pcall(function()
return bc..k:UrlEncode(bd)
end)
if not bf then
errorNotification("Voidware | Configs",`Couldn't resolve the url for {tostring(aV)}. Please report this to a developer in discord.gg/voidware`,10)
warn(`Invalid URL resolve: {tostring(bf)}`)
return
end
local bg=c.http_function(bf)
if bg:sub(1,1)=='"'and bg:sub(-1)=='"'then
local bh,bi=pcall(function()
return k:JSONDecode(bg)
end)
if bh then
bg=bi
end
end
local bh=false
for bi,bj in c.Profiles do
if bj.Name==bb then
bh=true
break
end
end
if not bh then
table.insert(c.Profiles,{Name=bb,Bind={}})
end
local bi
if ba.color~=nil and type(ba.color)=="table"then
local bj,bk,bl=unpack(ba.color)
bj,bk,bl=num(bj),num(bk),num(bl)
if bj~=nil and bk~=nil and bl~=nil then
bi={
Hue=bj,
Sat=bk,
Value=bl,
CustomColor=true,
Rainbow=false
}
shared[`FORCE_PROFILE_GUI_COLOR_SET_{tostring(bb)}`]=bi
end
end
if ba.description~=nil then
shared[`FORCE_PROFILE_TEXT_GUI_CUSTOM_TEXT_{tostring(bb)}`]=tostring(ba.description)
end
c:Save(bb)
writefile("vape/profiles/"..bb..c.Place..".txt",bg)
c:Load(true,bb)
local bj=bh and"Reinstalled"or"Downloaded"
c:CreateNotification("Vape",`{bj} "{aV}" by @{ba.username}`,5,"info")
a9.Text="REINSTALL"
a8=true
local bk,bl,bm=c.GUIColor.Hue,c.GUIColor.Sat,c.GUIColor.Value
a9.BackgroundColor3=a8 and l.Dark(Color3.fromHSV(bk,bl,bm),0.3)
or Color3.fromHSV(bk,bl,bm)
S()
else
c:CreateNotification("Vape",`Failed to fetch config ({aV})`,10,"warning")
end
end)
task.wait(0.15)
end


local function addSorting(aV,aW,aX)
local aY=aX.Size
local aZ=aX.On

local a_=Instance.new"TextButton"
a_.Name=aV
a_.Parent=aP
a_.BackgroundColor3=Color3.fromHSV(c.GUIColor.Hue,c.GUIColor.Sat,c.GUIColor.Value)
connectguicolorchange(a_)
a_.BackgroundTransparency=aZ and 0 or 0.8
a_.BorderSizePixel=0
a_.Text=""
a_.AutoButtonColor=false
a_.Size=aY

local a0=Instance.new"TextLabel"
a0.Parent=a_
a0.Name="label"
a0.BackgroundTransparency=1
a0.BorderSizePixel=0
a0.Size=UDim2.new(1,0,1,0)
a0.Font=Enum.Font.GothamBold
a0.TextTransparency=aZ and 0 or 0.6
a0.Text=aV:upper()
a0.TextColor3=Color3.new(1,1,1)
a0.TextSize=11

addCorner(a_,UDim.new(1,0))

local a1={
SetVisible=function(a1)
for a2,a3 in ai.Sorts do
a3.Window.BackgroundTransparency=0.8
a3.Window.label.TextTransparency=0.6
end

a_.BackgroundTransparency=a1 and 0 or 0.8
a0.TextTransparency=a1 and 0 or 0.6
end,
Window=a_,
}

a_.Activated:Connect(function()
a1:SetVisible(true)
an=aV:lower()
S()
end)

table.insert(ai.Sorts,a1)

return a1
end

addSorting("newest",nil,{
Size=UDim2.fromOffset(90,32),
On=true,
})

addSorting("oldest",nil,{
Size=UDim2.fromOffset(90,32),
On=false,
})

aj=G.Dropdown({
Name="Author",
List={"all"},
Function=function(aV)
ak:Fire(aV)
end,
Default="all",
Size=UDim2.new(0.2,0,0,40),
Visible=false,
},aP,{Options={}})
aj.Object.BackgroundTransparency=1

local aV=Instance.new"TextLabel"
aV.Parent=aP
aV.TextSize=15
aV.LayoutOrder=5
aV.TextColor3=Color3.fromRGB(200,200,200)
aV.TextTransparency=1
aV.Size=UDim2.new(0,600,1,0)
aV.BackgroundTransparency=1

ar=function(aW,aX)
task.spawn(function()
if aX~=nil then
flickerTextEffect(aV,aX,aW)
elseif aW~=nil then
aV.Text=aW
end
end)
end

if getgenv().username~=nil then
ar(`Welcome back {tostring(getgenv().username)}!`,true)
end

as=function()
ar(`Awesome configs made by & for awesome people :D`,true)
end


aO:GetPropertyChangedSignal"Text":Connect(function()
for aW,aX in ai do
if aX and typeof(aX)=="table"and aX.instance then
aX.instance.Visible=false

if
aW:lower():gsub(" ",""):find(aO.Text:lower():gsub(" ",""),1,true)
or aO.Text==""
then
aX.instance.Visible=true
end
end
end
end)

af.Event:Connect(S)


local aW=false
aw:GetPropertyChangedSignal"Visible":Connect(function()
if not aw.Visible then
if aW then
u.Visible=true
aW=false
end
az.Visible=false
else
u.Visible=false
aW=true
end
local aX=c
if not aX.UpdateGUI then return end
aX:UpdateGUI(aX.GUIColor.Hue,aX.GUIColor.Sat,aX.GUIColor.Value)
end)

ag.PublicConfigs=ai

return ai
end

function c.CreateCategoryList(ag,ah)
local ai={
Type="CategoryList",
Expanded=false,
List={},
ListEnabled={},
Objects={},
Options={},
}
ah.Color=ah.Color or Color3.fromRGB(5,134,105)

local aj=Instance.new"TextButton"
aj.Name=ah.Name.."CategoryList"
aj.Size=UDim2.fromOffset(220,45)
aj.Position=UDim2.fromOffset(240,46)
aj.BackgroundColor3=n.Main
aj.AutoButtonColor=false
aj.Visible=false
local ak
if ah.Profiles then

aj.AnchorPoint=Vector2.new(0.5,0.5)
aj.Position=UDim2.fromScale(0.5,0.5)
aj.Visible=true
local al=Instance.new"UIScale"
al.Scale=1
al.Parent=aj
local am=Instance.new"UIStroke"
am.Parent=aj
am.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
am.Thickness=0
connectguicolorchange(function(an,ao,ap)
local aq=Color3.fromHSV(an,ao,ap)
if not ag.NewUser then
am.Color=l.Light(aq,0.2)
else
am.Color=Color3.fromRGB(255,255,255)
end
end)
local an=false

c.ProfilesCategoryListWindow={
window=aj,
scale=al,
stroke=am,
globeicon=ak,
setup=function(ao)
aj.AnchorPoint=Vector2.new(0.5,0.5)
aj.Position=UDim2.fromScale(0.5,0.5)
aj.Visible=true
al.Scale=1
am.Thickness=0
ao.globeicon=ak
if not an then
an=true
aj.MouseEnter:Connect(function()
m:Tween(am,TweenInfo.new(0.15),{
Thickness=3
})
end)
aj.MouseLeave:Connect(function()
m:Tween(am,TweenInfo.new(0.15),{
Thickness=0
})
end)
end
return ao
end
}
end
aj.Text=""
aj.Parent=u
addBlur(aj)
addCorner(aj)
makeDraggable(aj)
local al=Instance.new"ImageLabel"
al.Name="Icon"
al.Size=ah.Size
al.Position=ah.Position
or UDim2.fromOffset(12,(ah.Size.X.Offset>20 and 13 or 12))
al.BackgroundTransparency=1
al.Image=ah.Icon
al.ImageColor3=n.Text
al.Parent=aj
local am=Instance.new"TextLabel"
am.Name="Title"
am.Size=UDim2.new(1,-(ah.Size.X.Offset>20 and 44 or 36),0,20)
am.Position=UDim2.fromOffset(math.abs(am.Size.X.Offset),12)
am.BackgroundTransparency=1
am.Text=ah.Name
am.TextXAlignment=Enum.TextXAlignment.Left
am.TextColor3=n.Text
am.TextSize=13
am.FontFace=n.Font
am.Parent=aj
local an=Instance.new"TextButton"
an.Name="Arrow"
an.Size=UDim2.fromOffset(40,40)
an.Position=UDim2.new(1,-40,0,0)
an.BackgroundTransparency=1
an.Text=""
an.Parent=aj
local ao=Instance.new"ImageLabel"
ao.Name="Arrow"
ao.Size=UDim2.fromOffset(9,4)
ao.Position=UDim2.fromOffset(20,19)
ao.BackgroundTransparency=1
ao.Image=t"vape/assets/new/expandup.png"
ao.ImageColor3=Color3.fromRGB(140,140,140)
ao.Rotation=180
ao.Parent=an
local ap=Instance.new"ScrollingFrame"
ap.Name="Children"
ap.Size=UDim2.new(1,0,1,-45)
ap.Position=UDim2.fromOffset(0,45)
ap.BackgroundTransparency=1
ap.BorderSizePixel=0
ap.Visible=false
ap.ScrollBarThickness=2
ap.ScrollBarImageTransparency=0.75
ap.CanvasSize=UDim2.new()
ap.Parent=aj
local aq=Instance.new"Frame"
aq.BackgroundTransparency=1
aq.BackgroundColor3=l.Dark(n.Main,0.02)
aq.Visible=false
aq.Parent=ap
local ar=Instance.new"ImageButton"
ar.Name="Settings"
ar.Size=UDim2.fromOffset(16,16)
ar.Position=UDim2.new(1,-52,0,13)
ar.BackgroundTransparency=1
ar.AutoButtonColor=false
ar.Image=ah.Name~="Profiles"and t"vape/assets/new/customsettings.png"or t"vape/assets/new/worldicon.png"
ar.ImageColor3=l.Dark(n.Text,0.43)
ar.Parent=aj
if ah.Profiles then
ak=ar
addTooltip(ar,"Opens the Public Configs Window")
end
local as=Instance.new"Frame"
as.Name="Divider"
as.Size=UDim2.new(1,0,0,1)
as.Position=UDim2.fromOffset(0,41)
as.BorderSizePixel=0
as.Visible=false
as.BackgroundColor3=Color3.new(1,1,1)
as.BackgroundTransparency=0.928
as.Parent=aj
local at=Instance.new"UIListLayout"
at.SortOrder=Enum.SortOrder.LayoutOrder
at.HorizontalAlignment=Enum.HorizontalAlignment.Center
at.Padding=UDim.new(0,3)
at.Parent=ap
local au=Instance.new"UIListLayout"
au.SortOrder=Enum.SortOrder.LayoutOrder
au.HorizontalAlignment=Enum.HorizontalAlignment.Center
au.Parent=aq
local av
local aw
if ah.Profiles then
av=G.Button({
Name="Sync to 'default' profile",
Function=function()
local ax=c.Profile
c.Profile='default'
c:Save'default'
c:Load(true,'default')
local ay=Color3ToHex(Color3.fromHSV(c.GUIColor.Hue,c.GUIColor.Sat,c.GUIColor.Value))
local az="#ffffff"
local aA=([[Transferred Data from <font color="%s"><b>%s</b></font> to <font color="%s"><b>default</b></font> Profile]]):format(ay,tostring(ax),az)
c:CreateNotification("Vape",aA,3)
end,
Tooltip="Transfers your current profile to the 'default' one",
Visible=false,
BackgroundTransparency=1
},ap,{Options={}})
aw=G.Button({
Name="Create new profile",
Function=function()
c:CreatePrompt{
Title="Create Profile",
Text="Choose a name for your new profile.",
Input=true,
InputPlaceholder="What should the profile be called?",
OnConfirm=function(ax)
if ax and ax~=""then
for ay,az in c.Profiles do
if tostring(az.Name)==ax then
c:CreateNotification("Vape",`Profile {tostring(ax)} already exists!`,3)
return
end
end
table.insert(c.Profiles,{Name=ax,Bind={}})
c:Save(ax,true)
c:Load(ax)
else
c:CreateNotification("Vape","No Profile Name given",3)
end
end,
}
end,
Tooltip="Creates a brand new profile",
Visible=false,
BackgroundTransparency=1,
},ap,{Options={}})
G.Button({
Name="Reset current profile",
Function=function()
c:CreatePrompt{
Title="Reset Profile",
Text="Are you sure you want to <b><font color='#ff5a5a'>delete</font></b> your current profile?\n<font color='#ff7777'><i>This action cannot be undone.</i></font>",
ConfirmText="Yes",
CancelText="Nevermind",
ConfirmColor=Color3.fromRGB(120,40,40),
ConfirmHoverColor=Color3.fromRGB(170,60,60),
CancelColor=Color3.fromRGB(40,120,40),
CancelHoverColor=Color3.fromRGB(60,170,60),
OnConfirm=function()
c.Save=function()end
if C("vape/profiles/"..c.Profile..c.Place..".txt")and delfile then
delfile("vape/profiles/"..c.Profile..c.Place..".txt")
end
shared.vapereload=true
if shared.VapeDeveloper then
loadstring(readfile"vape/loader.lua","loader")()
else
loadstring(
c.http_function(
'https://raw.githubusercontent.com/VapeVoidware/VWRewrite/'
..readfile"vape/profiles/commit.txt"
.."/loader.lua",
true
)
)()
end
end,
OnCancel=function()end
}
end,
Tooltip="This will set your profile to the default settings of Vape",
BackgroundTransparency=1,
},ap,{Options={}})
end
local ax=Instance.new"Frame"
ax.Name="Add"
ax.Size=UDim2.fromOffset(200,31)
ax.Position=UDim2.fromOffset(10,45)
ax.BackgroundColor3=l.Light(n.Main,0.02)
ax.Parent=ap
addCorner(ax)
local ay=ax:Clone()
ay.Size=UDim2.new(1,-2,1,-2)
ay.Position=UDim2.fromOffset(1,1)
ay.BackgroundColor3=l.Dark(n.Main,0.02)
ay.Parent=ax
local az=Instance.new"TextBox"
az.Size=UDim2.new(1,-35,1,0)
az.Position=UDim2.fromOffset(10,0)
az.BackgroundTransparency=1
az.Text=""
az.PlaceholderText=ah.Placeholder or"Add entry..."
az.TextXAlignment=Enum.TextXAlignment.Left
az.TextColor3=Color3.new(1,1,1)
az.TextSize=15
az.FontFace=n.Font
az.ClearTextOnFocus=false
az.Parent=ax
local aA=Instance.new"ImageButton"
aA.Name="AddButton"
aA.Size=UDim2.fromOffset(16,16)
aA.Position=UDim2.new(1,-26,0,8)
aA.BackgroundTransparency=1
aA.Image=t"vape/assets/new/add.png"
aA.ImageColor3=ah.Color
aA.ImageTransparency=0.3
aA.Parent=ax
local aB=Instance.new"Frame"
aB.Size=UDim2.fromOffset()
aB.BackgroundTransparency=1
aB.Parent=ap
ah.Function=ah.Function or function()end

local function profilesButtonRefresh()
if not ah.Profiles then return end
local aC=ag.Profile
if not aC then
if shared.VoidDev then
warn"profilesButtonRefresh: local profile not found!"
end
return
end
av:SetVisible(aC~="default")
aw:SetVisible(aC=="default")
end

function ai.ChangeValue(aC,aD)
if aD then
if ah.Profiles then
local aE=aC:GetValue(aD)
if aE then
if aD~="default"then
table.remove(c.Profiles,aE)
if C("vape/profiles/"..aD..c.Place..".txt")and delfile then
delfile("vape/profiles/"..aD..c.Place..".txt")
end
end
else
table.insert(c.Profiles,{Name=aD,Bind={}})
end
if c.ConfigsAPIRefresh then pcall(c.ConfigsAPIRefresh)end
profilesButtonRefresh()
else
local aE=table.find(aC.List,aD)
if aE then
table.remove(aC.List,aE)
aE=table.find(aC.ListEnabled,aD)
if aE then
table.remove(aC.ListEnabled,aE)
end
else
table.insert(aC.List,aD)
table.insert(aC.ListEnabled,aD)
end
end
end

ah.Function()
if ah.Profiles then
profilesButtonRefresh()
end
for aE,aG in aC.Objects do
aG:Destroy()
end
table.clear(aC.Objects)
aC.Selected=nil

for aE,aG in(ah.Profiles and c.Profiles or aC.List)do
if ah.Profiles then
local aH=Instance.new"TextButton"
aH.Name=aG.Name
aH.Size=UDim2.fromOffset(200,33)
aH.BackgroundColor3=l.Light(n.Main,0.02)
aH.AutoButtonColor=false
aH.Text=""
aH.Parent=ap
addCorner(aH)
local aI=Instance.new"UIStroke"
aI.Color=l.Light(n.Main,0.1)
aI.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
aI.Enabled=false
aI.Parent=aH
local aJ=Instance.new"TextLabel"
aJ.Name="Title"
aJ.Size=UDim2.new(1,-10,1,0)
aJ.Position=UDim2.fromOffset(10,0)
aJ.BackgroundTransparency=1
aJ.Text=aG.Name
aJ.TextTruncate=Enum.TextTruncate.AtEnd
aJ.TextXAlignment=Enum.TextXAlignment.Left
aJ.TextColor3=l.Dark(n.Text,0.4)
aJ.TextSize=15
aJ.FontFace=n.Font
aJ.Parent=aH
local aK=Instance.new"TextButton"
aK.Name="Dots"
aK.Size=UDim2.fromOffset(25,33)
aK.Position=UDim2.new(1,-25,0,0)
aK.BackgroundTransparency=1
aK.Text=""
aK.Parent=aH
local aL=Instance.new"ImageLabel"
aL.Name="Dots"
aL.Size=UDim2.fromOffset(3,16)
aL.Position=UDim2.fromOffset(10,9)
aL.BackgroundTransparency=1
aL.Image=t"vape/assets/new/dots.png"
aL.ImageColor3=l.Light(n.Main,0.37)
aL.Parent=aK
local aM=Instance.new"TextButton"
addTooltip(aM,"Click to bind")
aM.Name="Bind"
aM.Size=UDim2.fromOffset(20,21)
aM.Position=UDim2.new(1,-30,0,6)
aM.AnchorPoint=Vector2.new(1,0)
aM.BackgroundColor3=Color3.new(1,1,1)
aM.BackgroundTransparency=0.92
aM.BorderSizePixel=0
aM.AutoButtonColor=false
aM.Visible=false
aM.Text=""
addCorner(aM,UDim.new(0,4))
local aN=Instance.new"ImageLabel"
aN.Name="Icon"
aN.Size=UDim2.fromOffset(12,12)
aN.Position=UDim2.new(0.5,-6,0,5)
aN.BackgroundTransparency=1
aN.Image=t"vape/assets/new/bind.png"
aN.ImageColor3=l.Dark(n.Text,0.43)
aN.Parent=aM
local aO=Instance.new"TextLabel"
aO.Size=UDim2.fromScale(1,1)
aO.Position=UDim2.fromOffset(0,1)
aO.BackgroundTransparency=1
aO.Visible=false
aO.Text=""
aO.TextColor3=l.Dark(n.Text,0.43)
aO.TextSize=12
aO.FontFace=n.Font
aO.Parent=aM
aM.MouseEnter:Connect(function()
aO.Visible=false
aN.Visible=not aO.Visible
aN.Image=t"vape/assets/new/edit.png"
if aG.Name~=c.Profile then
aN.ImageColor3=l.Dark(n.Text,0.16)
end
end)
aM.MouseLeave:Connect(function()
aO.Visible=#aG.Bind>0
aN.Visible=not aO.Visible
aN.Image=t"vape/assets/new/bind.png"
if aG.Name~=c.Profile then
aN.ImageColor3=l.Dark(n.Text,0.43)
end
end)
local aP=Instance.new"ImageLabel"
aP.Name="Cover"
aP.Size=UDim2.fromOffset(154,33)
aP.BackgroundTransparency=1
aP.Visible=false
aP.Image=t"vape/assets/new/bindbkg.png"
aP.ScaleType=Enum.ScaleType.Slice
aP.SliceCenter=Rect.new(0,0,141,40)
aP.Parent=aH
local aQ=Instance.new"TextLabel"
aQ.Name="Text"
aQ.Size=UDim2.new(1,-10,1,-3)
aQ.BackgroundTransparency=1
aQ.Text="PRESS A KEY TO BIND"
aQ.TextColor3=n.Text
aQ.TextSize=11
aQ.FontFace=n.Font
aQ.Parent=aP
aM.Parent=aH
aK.MouseEnter:Connect(function()
if aG.Name~=c.Profile then
aL.ImageColor3=n.Text
end
end)
aK.MouseLeave:Connect(function()
if aG.Name~=c.Profile then
aL.ImageColor3=l.Light(n.Main,0.37)
end
end)
aK.Activated:Connect(function()
if aG.Name~=c.Profile then
ai:ChangeValue(aG.Name)
end
end)
aH.Activated:Connect(function()
c:Save(aG.Name,not C("vape/profiles/"..aG.Name..c.Place..".txt"))
c:Load(true,aG.Name)
end)
aH.MouseEnter:Connect(function()
aM.Visible=true
if aG.Name~=c.Profile then
aI.Enabled=true
aJ.TextColor3=l.Dark(n.Text,0.16)
end
end)
aH.MouseLeave:Connect(function()
aM.Visible=#aG.Bind>0
if aG.Name~=c.Profile then
aI.Enabled=false
aJ.TextColor3=l.Dark(n.Text,0.4)
end
end)

local function bindFunction(aR,aS,aT)
aG.Bind=table.clone(aS)
if aT then
aQ.Text=#aS<=0 and"BIND REMOVED"
or"BOUND TO "..table.concat(aS," + "):upper()
aP.Size=
UDim2.fromOffset(D(aQ.Text,aQ.TextSize).X+20,40)
task.delay(1,function()
aP.Visible=false
end)
end

if#aS<=0 then
aO.Visible=false
aN.Visible=true
aM.Size=UDim2.fromOffset(20,21)
else
aM.Visible=true
aO.Visible=true
aN.Visible=false
aO.Text=table.concat(aS," + "):upper()
aM.Size=UDim2.fromOffset(
math.max(D(aO.Text,aO.TextSize,aO.Font).X+10,20),
21
)
end
end

bindFunction({},aG.Bind)
aM.Activated:Connect(function()
aQ.Text="PRESS A KEY TO BIND"
aP.Size=
UDim2.fromOffset(D(aQ.Text,aQ.TextSize).X+20,40)
aP.Visible=true
c.Binding={SetBind=bindFunction,Bind=aG.Bind}
end)
if aG.Name==c.Profile then
aC.Selected=aH
end
table.insert(aC.Objects,aH)
else
local aH=table.find(aC.ListEnabled,aG)
local aI=Instance.new"TextButton"
aI.Name=aG
aI.Size=UDim2.fromOffset(200,32)
aI.BackgroundColor3=l.Light(n.Main,0.02)
aI.AutoButtonColor=false
aI.Text=""
aI.Parent=ap
addCorner(aI)
local aJ=Instance.new"Frame"
aJ.Name="BKG"
aJ.Size=UDim2.new(1,-2,1,-2)
aJ.Position=UDim2.fromOffset(1,1)
aJ.BackgroundColor3=n.Main
aJ.Visible=false
aJ.Parent=aI
addCorner(aJ)
local aK=Instance.new"Frame"
aK.Name="Dot"
aK.Size=UDim2.fromOffset(10,11)
aK.Position=UDim2.fromOffset(10,12)
aK.BackgroundColor3=aH and ah.Color or l.Light(n.Main,0.37)
aK.Parent=aI
addCorner(aK,UDim.new(1,0))
local aL=aK:Clone()
aL.Size=UDim2.fromOffset(8,9)
aL.Position=UDim2.fromOffset(1,1)
aL.BackgroundColor3=aH and ah.Color or l.Light(n.Main,0.02)
aL.Parent=aK
local aM=Instance.new"TextLabel"
aM.Name="Title"
aM.Size=UDim2.new(1,-30,1,0)
aM.Position=UDim2.fromOffset(30,0)
aM.BackgroundTransparency=1
aM.Text=aG
aM.TextXAlignment=Enum.TextXAlignment.Left
aM.TextColor3=l.Dark(n.Text,0.16)
aM.TextSize=15
aM.FontFace=n.Font
aM.Parent=aI
if c.ThreadFix then
setthreadidentity(8)
end
local aN=Instance.new"ImageButton"
aN.Name="Close"
aN.Size=UDim2.fromOffset(16,16)
aN.Position=UDim2.new(1,-23,0,8)
aN.BackgroundColor3=Color3.new(1,1,1)
aN.BackgroundTransparency=1
aN.AutoButtonColor=false
aN.Image=t"vape/assets/new/closemini.png"
aN.ImageColor3=l.Light(n.Text,0.2)
aN.ImageTransparency=0.5
aN.Parent=aI
addCorner(aN,UDim.new(1,0))
aN.MouseEnter:Connect(function()
aN.ImageTransparency=0.3
m:Tween(aN,n.Tween,{
BackgroundTransparency=0.6,
})
end)
aN.MouseLeave:Connect(function()
aN.ImageTransparency=0.5
m:Tween(aN,n.Tween,{
BackgroundTransparency=1,
})
end)
aN.Activated:Connect(function()
ai:ChangeValue(aG)
end)
aI.MouseEnter:Connect(function()
aJ.Visible=true
end)
aI.MouseLeave:Connect(function()
aJ.Visible=false
end)
aI.Activated:Connect(function()
local aO=table.find(aC.ListEnabled,aG)
if aO then
table.remove(aC.ListEnabled,aO)
aK.BackgroundColor3=l.Light(n.Main,0.37)
aL.BackgroundColor3=l.Light(n.Main,0.02)
else
table.insert(aC.ListEnabled,aG)
aK.BackgroundColor3=ah.Color
aL.BackgroundColor3=ah.Color
end
ah.Function()
end)
table.insert(aC.Objects,aI)
end
end
c:UpdateGUI(c.GUIColor.Hue,c.GUIColor.Sat,c.GUIColor.Value)
end

function ai.Expand(aC)
aC.Expanded=not aC.Expanded
ap.Visible=aC.Expanded
ao.Rotation=aC.Expanded and 0 or 180
aj.Size=UDim2.fromOffset(
220,
aC.Expanded and math.min(51+at.AbsoluteContentSize.Y/z.Scale,611)or 45
)
as.Visible=ap.CanvasPosition.Y>10 and ap.Visible
end

function ai.GetValue(aC,aD)
for aE,aG in c.Profiles do
if aG.Name==aD then
return aE
end
end
end

for aC,aD in G do
ai["Create"..aC]=function(aE,aG)
return aD(aG,aq,ai)
end
ai["Add"..aC]=ai["Create"..aC]
end

aA.MouseEnter:Connect(function()
aA.ImageTransparency=0
end)
aA.MouseLeave:Connect(function()
aA.ImageTransparency=0.3
end)
aA.Activated:Connect(function()
if not table.find(ai.List,az.Text)then
if az.Text==""or az.Text=="Invalid Name!"then
c:CreateNotification("Vape","You need to specify a value!",3)
flickerTextEffect(az,true,"Invalid Name!")
task.delay(0.5,function()
flickerTextEffect(az,true,"")
end)
return
end
ai:ChangeValue(az.Text)
az.Text=""
end
end)
an.MouseEnter:Connect(function()
ao.ImageColor3=Color3.fromRGB(220,220,220)
end)
an.MouseLeave:Connect(function()
ao.ImageColor3=Color3.fromRGB(140,140,140)
end)
an.Activated:Connect(function()
ai:Expand()
end)
an.MouseButton2Click:Connect(function()
ai:Expand()
end)
az.FocusLost:Connect(function(aC)
if aC and not table.find(ai.List,az.Text)then
ai:ChangeValue(az.Text)
az.Text=""
end
end)
az.MouseEnter:Connect(function()
m:Tween(ax,n.Tween,{
BackgroundColor3=l.Light(n.Main,0.14),
})
end)
az.MouseLeave:Connect(function()
m:Tween(ax,n.Tween,{
BackgroundColor3=l.Light(n.Main,0.02),
})
end)
ap:GetPropertyChangedSignal"CanvasPosition":Connect(function()
as.Visible=ap.CanvasPosition.Y>10 and ap.Visible
end)
ar.MouseEnter:Connect(function()
ar.ImageColor3=n.Text
end)
ar.MouseLeave:Connect(function()
ar.ImageColor3=l.Light(n.Main,0.37)
end)

if ah.Profiles then
ag:CreateProfilesGUI(ar)
end

ar.Activated:Connect(function()
if ah.Profiles then
aq.Visible=false
ag.PublicConfigs.Window.Visible=not ag.PublicConfigs.Window.Visible
af:Fire()
if c.TutorialAPI.isActive then
c.TutorialAPI.GlobeIconWait=false
c.TutorialAPI:tweenToSecondPosition()
c.TutorialAPI:setText"Pick a config of your choice :D"
end

else
aq.Visible=not aq.Visible
end
end)
aj.InputBegan:Connect(function(aC)
if
aC.Position.Y<aj.AbsolutePosition.Y+41
and aC.UserInputType==Enum.UserInputType.MouseButton2
then
ai:Expand()
end
end)
at:GetPropertyChangedSignal"AbsoluteContentSize":Connect(function()
if ag.ThreadFix then
setthreadidentity(8)
end
ap.CanvasSize=UDim2.fromOffset(0,at.AbsoluteContentSize.Y/z.Scale)
if ai.Expanded then
aj.Size=UDim2.fromOffset(220,math.min(51+at.AbsoluteContentSize.Y/z.Scale,611))
end
end)
au:GetPropertyChangedSignal"AbsoluteContentSize":Connect(function()
if ag.ThreadFix then
setthreadidentity(8)
end
aq.Size=UDim2.fromOffset(220,au.AbsoluteContentSize.Y)
end)

ai.Button=ag.Categories.Main:CreateButton{
Name=ah.Name,
Icon=ah.CategoryIcon,
Size=ah.CategorySize,
Window=aj,
Default=ah.Profiles
}

ai.Object=aj
ag.Categories[ah.Name]=ai

if ah.Profiles and not ai.Expanded then
ai:Expand()
end

return ai
end

local function createHighlight(ag)
local ah=Instance.new"Frame"
ah.Size=UDim2.fromScale(1,1)
ah.BackgroundColor3=Color3.new(1,1,1)
ah.BackgroundTransparency=0.6
ah.BorderSizePixel=0
ah.Parent=ag
m:Tween(ah,TweenInfo.new(0.5),{
BackgroundTransparency=1,
})
task.delay(0.5,ah.Destroy,ah)
end

function c.CreateSearch(ag)
local ah=Instance.new"Frame"
ah.Name="Search"
ah.Size=UDim2.fromOffset(220,37)
ah.Position=UDim2.new(0.5,0,0,13)
ah.AnchorPoint=Vector2.new(0.5,0)
ah.BackgroundColor3=l.Dark(n.Main,0.02)
ah.Parent=u
local ai=Instance.new"ImageLabel"
ai.Name="Icon"
ai.Size=UDim2.fromOffset(14,14)
ai.Position=UDim2.new(1,-23,0,11)
ai.BackgroundTransparency=1
ai.Image=t"vape/assets/new/search.png"
ai.ImageColor3=l.Light(n.Main,0.37)
ai.Parent=ah
local aj=Instance.new"ImageButton"
aj.Name="Legit"
aj.Size=UDim2.fromOffset(29,16)
aj.Position=UDim2.fromOffset(8,11)
aj.BackgroundTransparency=1
aj.Image=t"vape/assets/new/legit.png"
aj.Parent=ah
local ak=Instance.new"Frame"
ak.Name="LegitDivider"
ak.Size=UDim2.fromOffset(2,12)
ak.Position=UDim2.fromOffset(43,13)
ak.BackgroundColor3=l.Light(n.Main,0.14)
ak.BorderSizePixel=0
ak.Parent=ah
addBlur(ah)
addCorner(ah)
local al=Instance.new"TextBox"
al.Size=UDim2.new(1,-50,0,37)
al.Position=UDim2.fromOffset(50,0)
al.BackgroundTransparency=1
al.Text=""
al.PlaceholderText=""
al.TextXAlignment=Enum.TextXAlignment.Left
al.TextColor3=n.Text
al.TextSize=12
al.FontFace=n.Font
al.ClearTextOnFocus=false
al.Parent=ah
local am=Instance.new"ScrollingFrame"
am.Name="Children"
am.Size=UDim2.new(1,0,1,-37)
am.Position=UDim2.fromOffset(0,34)
am.BackgroundTransparency=1
am.BorderSizePixel=0
am.ScrollBarThickness=2
am.ScrollBarImageTransparency=0.75
am.CanvasSize=UDim2.new()
am.Parent=ah
local an=Instance.new"Frame"
an.Name="Divider"
an.Size=UDim2.new(1,0,0,1)
an.Position=UDim2.fromOffset(0,33)
an.BackgroundColor3=Color3.new(1,1,1)
an.BackgroundTransparency=0.928
an.BorderSizePixel=0
an.Visible=false
an.Parent=ah
local ao=Instance.new"UIListLayout"
ao.SortOrder=Enum.SortOrder.LayoutOrder
ao.HorizontalAlignment=Enum.HorizontalAlignment.Center
ao.Parent=am

am:GetPropertyChangedSignal"CanvasPosition":Connect(function()
an.Visible=am.CanvasPosition.Y>10 and am.Visible
end)
aj.Activated:Connect(function()
u.Visible=false
ag.Legit.Window.Visible=true
ag.Legit.Window.Position=UDim2.new(0.5,-350,0.5,-194)
end)
al:GetPropertyChangedSignal"Text":Connect(function()
for ap,aq in am:GetChildren()do
if aq:IsA"TextButton"then
aq:Destroy()
end
end
if al.Text==""then
return
end

for ap,aq in ag.Modules do
if ap:lower():find(al.Text:lower())then
local ar=aq.Object:Clone()
ar.Bind:Destroy()
ar.Activated:Connect(function()
aq:Toggle()
end)

ar.MouseButton2Click:Connect(function()
aq.Object.Parent.Parent.Visible=true
local as=aq.Object.Parent
createHighlight(aq.Object)
local at=aq.ModuleCategory
if at~=nil then

at:Toggle(true)
end
local au=aq.CategoryApi
if au~=nil then

au:ToggleCategoryButton(true)
end

m:Tween(as,TweenInfo.new(0.5),{
CanvasPosition=Vector2.new(0,(aq.Object.LayoutOrder*40)-(math.min(as.CanvasSize.Y.Offset,600)/2))
})
end)

ar.Parent=am
task.spawn(function()
repeat
pcall(function()
for as,at in{"Text","TextColor3","BackgroundColor3"}do
ar[at]=aq.Object[at]
end
ar.UIGradient.Color=aq.Object.UIGradient.Color
ar.UIGradient.Enabled=aq.Object.UIGradient.Enabled
ar.Dots.Dots.ImageColor3=aq.Object.Dots.Dots.ImageColor3
end)
task.wait()
until not ar.Parent
end)
end
end
end)
ao:GetPropertyChangedSignal"AbsoluteContentSize":Connect(function()
if ag.ThreadFix then
setthreadidentity(8)
end
am.CanvasSize=UDim2.fromOffset(0,ao.AbsoluteContentSize.Y/z.Scale)
ah.Size=UDim2.fromOffset(220,math.min(37+ao.AbsoluteContentSize.Y/z.Scale,437))
end)

ag.Legit.Icon=aj
end
































































































































































































































































































































































function c.CreateLegit(ag)
local ah={Modules={}}


local ai=ag.Categories.Legit
if not ai then
warn"Legit category must be created before CreateLegit()"
return
end

local aj=Instance.new"Frame"
aj.Name="LegitGUI"
aj.Size=UDim2.fromOffset(700,389)
aj.Position=UDim2.new(0.5,-350,0.5,-194)
aj.BackgroundColor3=n.Main
aj.Visible=false
aj.Parent=v
addBlur(aj)
addCorner(aj)
makeDraggable(aj)

local ak=Instance.new"TextButton"
ak.BackgroundTransparency=1
ak.Text=""
ak.Modal=true
ak.Parent=aj

local al=Instance.new"ImageLabel"
al.Name="Icon"
al.Size=UDim2.fromOffset(16,16)
al.Position=UDim2.fromOffset(18,13)
al.BackgroundTransparency=1
al.Image=t"vape/assets/new/legittab.png"
al.ImageColor3=n.Text
al.Parent=aj

local am=addCloseButton(aj)

local an=Instance.new"ScrollingFrame"
an.Name="Children"
an.Size=UDim2.fromOffset(684,340)
an.Position=UDim2.fromOffset(14,41)
an.BackgroundTransparency=1
an.BorderSizePixel=0
an.ScrollBarThickness=2
an.ScrollBarImageTransparency=0.75
an.CanvasSize=UDim2.new()
an.Parent=aj

local ao=Instance.new"UIGridLayout"
ao.SortOrder=Enum.SortOrder.LayoutOrder
ao.FillDirectionMaxCells=4
ao.CellSize=UDim2.fromOffset(163,114)
ao.CellPadding=UDim2.fromOffset(6,5)
ao.Parent=an

ah.Window=aj
ah.Category=ai
table.insert(c.Windows,aj)

function ah.CreateModule(ap,aq)
c:Remove(aq.Name)



local ar={
Enabled=false,
Options={},
Name=aq.Name,
Legit=true,
CategoryModule=categoryModule,
_syncing=false,
}
local as=function(as)
if ar.Enabled~=as and ar.Toggle~=nil then
ar:Toggle()
end
end

local at=table.clone(aq)
at.Function=as
local au=ai:CreateModule(at)

local av=Instance.new"TextButton"
av.Name=aq.Name
av.BackgroundColor3=l.Light(n.Main,0.02)
av.Text=""
av.AutoButtonColor=false
av.Parent=an
addTooltip(av,aq.Tooltip)
addCorner(av)

local aw=Instance.new"TextLabel"
aw.Name="Title"
aw.Size=UDim2.new(1,-16,0,20)
aw.Position=UDim2.fromOffset(16,81)
aw.BackgroundTransparency=1
aw.Text=aq.Name
aw.TextXAlignment=Enum.TextXAlignment.Left
aw.TextColor3=l.Dark(n.Text,0.31)
aw.TextSize=13
aw.FontFace=n.Font
aw.Parent=av

local ax=Instance.new"Frame"
ax.Name="Knob"
ax.Size=UDim2.fromOffset(22,12)
ax.Position=UDim2.new(1,-57,0,14)
ax.BackgroundColor3=l.Light(n.Main,0.14)
ax.Parent=av
addCorner(ax,UDim.new(1,0))

local ay=ax:Clone()
ay.Size=UDim2.fromOffset(8,8)
ay.Position=UDim2.fromOffset(2,2)
ay.BackgroundColor3=n.Main
ay.Parent=ax

local az=Instance.new"TextButton"
az.Name="Dots"
az.Size=UDim2.fromOffset(14,24)
az.Position=UDim2.new(1,-27,0,8)
az.BackgroundTransparency=1
az.Text=""
az.Parent=av

local aA=Instance.new"ImageLabel"
aA.Name="Dots"
aA.Size=UDim2.fromOffset(2,12)
aA.Position=UDim2.fromOffset(6,6)
aA.BackgroundTransparency=1
aA.Image=t"vape/assets/new/dots.png"
aA.ImageColor3=l.Light(n.Main,0.37)
aA.Parent=az

local aB=Instance.new"TextButton"
aB.Name="Shadow"
aB.Size=UDim2.new(1,0,1,-5)
aB.BackgroundColor3=Color3.new()
aB.BackgroundTransparency=1
aB.AutoButtonColor=false
aB.ClipsDescendants=true
aB.Visible=false
aB.Text=""
aB.Parent=aj
addCorner(aB)

local aC=Instance.new"TextButton"
aC.Size=UDim2.new(0,220,1,0)
aC.Position=UDim2.fromScale(1,0)
aC.BackgroundColor3=n.Main
aC.AutoButtonColor=false
aC.Text=""
aC.Parent=aB

local aD=Instance.new"TextLabel"
aD.Name="Title"
aD.Size=UDim2.new(1,-36,0,20)
aD.Position=UDim2.fromOffset(36,12)
aD.BackgroundTransparency=1
aD.Text=aq.Name
aD.TextXAlignment=Enum.TextXAlignment.Left
aD.TextColor3=l.Dark(n.Text,0.16)
aD.TextSize=13
aD.FontFace=n.Font
aD.Parent=aC

local aE=Instance.new"ImageButton"
aE.Name="Back"
aE.Size=UDim2.fromOffset(16,16)
aE.Position=UDim2.fromOffset(11,13)
aE.BackgroundTransparency=1
aE.Image=t"vape/assets/new/back.png"
aE.ImageColor3=l.Light(n.Main,0.37)
aE.Parent=aC
addCorner(aC)

local aG=Instance.new"ScrollingFrame"
aG.Name="Children"
aG.Size=UDim2.new(1,0,1,-45)
aG.Position=UDim2.fromOffset(0,41)
aG.BackgroundColor3=n.Main
aG.BorderSizePixel=0
aG.ScrollBarThickness=2
aG.ScrollBarImageTransparency=0.75
aG.CanvasSize=UDim2.new()
aG.Parent=aC

local aH=Instance.new"UIListLayout"
aH.SortOrder=Enum.SortOrder.LayoutOrder
aH.HorizontalAlignment=Enum.HorizontalAlignment.Center
aH.Parent=aG

if aq.Size then
local aI=Instance.new"Frame"
aI.Size=aq.Size
aI.BackgroundTransparency=1
aI.Visible=false
aI.Parent=v
makeDraggable(aI,aj)
local aJ=Instance.new"UIStroke"
aJ.Color=Color3.fromRGB(5,134,105)
aJ.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
aJ.Thickness=0
aJ.Parent=aI
ar.Children=aI
end

aq.Function=aq.Function or function()end
addMaid(ar)

function ar.Toggle(aI)
if aI._syncing then
return
end

aI._syncing=true
ar.Enabled=not ar.Enabled

if ar.Children then
ar.Children.Visible=ar.Enabled
end


if au and au.Enabled~=ar.Enabled then
au._syncing=true
au:Toggle()
au._syncing=false
end

aw.TextColor3=ar.Enabled and l.Light(n.Text,0.2)or l.Dark(n.Text,0.31)
av.BackgroundColor3=ar.Enabled and l.Light(n.Main,0.05)
or l.Light(n.Main,0.02)

m:Tween(ax,n.Tween,{
BackgroundColor3=ar.Enabled
and Color3.fromHSV(c.GUIColor.Hue,c.GUIColor.Sat,c.GUIColor.Value)
or l.Light(n.Main,0.14),
})
m:Tween(ay,n.Tween,{
Position=UDim2.fromOffset(ar.Enabled and 12 or 2,2),
})

if not ar.Enabled then
for aJ,aK in ar.Connections do
aK:Disconnect()
end
table.clear(ar.Connections)
end

aI._syncing=false
task.spawn(aq.Function,ar.Enabled)
end

local function createSyncedOption(
aI,
aJ,
aK,
aL,
aM,
aN
)

local aO=aI(aJ,aK,aM)
local aP=aI(table.clone(aJ),aL,aN)


aO._syncing=false
aP._syncing=false


local aQ={"ChangeValue","Color","SetValue","Toggle","ConnectCallback","SetValues"}


for aR,aS in aQ do
if aO[aS]and type(aO[aS])=="function"then
local aT=aO[aS]
aO[aS]=function(aU,...)

if aU._syncing then
return aT(aU,...)
end

aU._syncing=true
local aV={...}
local aW=aT(aU,unpack(aV))


if
aP[aS]
and type(aP[aS])=="function"
and not aP._syncing
then
pcall(function()
aP._syncing=true
aP[aS](aP,unpack(aV))
aP._syncing=false
end)
end

aU._syncing=false
return aW
end
end
end


for aR,aS in aQ do
if aP[aS]and type(aP[aS])=="function"then
local aT=aP[aS]
aP[aS]=function(aU,...)

if aU._syncing then
return aT(aU,...)
end

aU._syncing=true
local aV={...}
local aW=aT(aU,unpack(aV))


if
aO[aS]
and type(aO[aS])=="function"
and not aO._syncing
then
pcall(function()
aO._syncing=true
aO[aS](aO,unpack(aV))
aO._syncing=false
end)
end

aU._syncing=false
return aW
end
end
end


for aR,aS in{"Load","Save"}do
if aO[aS]and type(aO[aS])=="function"then
local aT=aO[aS]
aO[aS]=function(aU,...)

return aT(aU,...)
end
end
end


aO.CategoryComponent=aP
aP.LegitComponent=aO

return aO
end


for aI,aJ in G do
ar["Create"..aI]=function(aK,aL)
return createSyncedOption(
aJ,
aL,
aG,
au.Children,
ar,
au
)
end
ar["Add"..aI]=ar["Create"..aI]
end


for aI,aJ in G do
ar["Create"..aI]=function(aK,aL)
return createSyncedOption(
aJ,
aL,
aG,
au.Children,
ar,
au
)
end
ar["Add"..aI]=ar["Create"..aI]
end


aE.MouseEnter:Connect(function()
aE.ImageColor3=n.Text
end)
aE.MouseLeave:Connect(function()
aE.ImageColor3=l.Light(n.Main,0.37)
end)
aE.Activated:Connect(function()
m:Tween(aB,n.Tween,{
BackgroundTransparency=1,
})
m:Tween(aC,n.Tween,{
Position=UDim2.fromScale(1,0),
})
task.wait(0.2)
aB.Visible=false
end)

az.Activated:Connect(function()
aB.Visible=true
m:Tween(aB,n.Tween,{
BackgroundTransparency=0.5,
})
m:Tween(aC,n.Tween,{
Position=UDim2.new(1,-220,0,0),
})
end)

az.MouseEnter:Connect(function()
aA.ImageColor3=n.Text
end)
az.MouseLeave:Connect(function()
aA.ImageColor3=l.Light(n.Main,0.37)
end)

av.MouseEnter:Connect(function()
if not ar.Enabled then
av.BackgroundColor3=l.Light(n.Main,0.05)
end
end)
av.MouseLeave:Connect(function()
if not ar.Enabled then
av.BackgroundColor3=l.Light(n.Main,0.02)
end
end)

av.Activated:Connect(function()
ar:Toggle()
end)

av.MouseButton2Click:Connect(function()
aB.Visible=true
m:Tween(aB,n.Tween,{
BackgroundTransparency=0.5,
})
m:Tween(aC,n.Tween,{
Position=UDim2.new(1,-220,0,0),
})
end)

aB.Activated:Connect(function()
m:Tween(aB,n.Tween,{
BackgroundTransparency=1,
})
m:Tween(aC,n.Tween,{
Position=UDim2.fromScale(1,0),
})
task.wait(0.2)
aB.Visible=false
end)

aH:GetPropertyChangedSignal"AbsoluteContentSize":Connect(function()
if c.ThreadFix then
setthreadidentity(8)
end
aG.CanvasSize=UDim2.fromOffset(0,aH.AbsoluteContentSize.Y/z.Scale)
end)

ar.Object=av
ar.LegitTabModule=ar
au.LegitTabModule=ar
au._syncing=false

ah.Modules[aq.Name]=ar


local aI={}
for aJ,aK in ah.Modules do
table.insert(aI,aK.Name)
end
table.sort(aI)

for aJ,aK in aI do
ah.Modules[aK].Object.LayoutOrder=aJ
end

return ar
end

local function visibleCheck()
for ap,aq in ah.Modules do
if aq.Children then
local ar=u.Visible
for as,at in ag.Windows do
ar=ar or at.Visible
end
aq.Children.Visible=(not ar or aj.Visible)and aq.Enabled
end
end
end

am.Activated:Connect(function()
aj.Visible=false
u.Visible=true
end)

ag:Clean(u:GetPropertyChangedSignal"Visible":Connect(visibleCheck))
aj:GetPropertyChangedSignal"Visible":Connect(function()
ag:UpdateGUI(ag.GUIColor.Hue,ag.GUIColor.Sat,ag.GUIColor.Value)
visibleCheck()
end)

ao:GetPropertyChangedSignal"AbsoluteContentSize":Connect(function()
if ag.ThreadFix then
setthreadidentity(8)
end
an.CanvasSize=UDim2.fromOffset(0,ao.AbsoluteContentSize.Y/z.Scale)
end)

ag.Legit=ah

return ah
end

function c.CreateNotification(ag,ah,ai,aj,ak)
if not ag.Notifications.Enabled then
return
end
if type(ai)~="string"then
warn(ai,debug.traceback(type(ai)))
end
local al=ak
task.delay(0,function()
if ag.ThreadFix then
setthreadidentity(8)
end
local am=#p:GetChildren()+1
local an=Instance.new"ImageLabel"
an.Name="Notification"
an.Size=UDim2.fromOffset(math.max(D(removeTags(ai),14,n.Font).X+80,266),75)
an.Position=UDim2.new(1,0,1,-(29+(78*am)))
an.ZIndex=5
an.BackgroundTransparency=1
an.Image=t"vape/assets/new/notification.png"
an.ScaleType=Enum.ScaleType.Slice
an.SliceCenter=Rect.new(7,7,9,9)
an.Parent=p
addBlur(an,true)
local ao=Instance.new"ImageLabel"
ao.Name="Icon"
ao.Size=UDim2.fromOffset(60,60)
ao.Position=UDim2.fromOffset(-5,-8)
ao.ZIndex=5
ao.BackgroundTransparency=1
ao.Image=t("vape/assets/new/"..(al or"info")..".png")
ao.ImageColor3=Color3.new()
ao.ImageTransparency=0.5
ao.Parent=an
local ap=ao:Clone()
ap.Position=UDim2.fromOffset(-1,-1)
ap.ImageColor3=Color3.new(1,1,1)
ap.ImageTransparency=0
ap.Parent=ao
local aq=Instance.new"TextLabel"
aq.Name="Title"
aq.Size=UDim2.new(1,-56,0,20)
aq.Position=UDim2.fromOffset(46,16)
aq.ZIndex=5
aq.BackgroundTransparency=1
aq.Text="<stroke color='#FFFFFF' joins='round' thickness='0.3' transparency='0.5'>"
..ah
.."</stroke>"
aq.TextXAlignment=Enum.TextXAlignment.Left
aq.TextYAlignment=Enum.TextYAlignment.Top
aq.TextColor3=Color3.fromRGB(209,209,209)
aq.TextSize=14
aq.RichText=true
aq.FontFace=n.FontSemiBold
aq.Parent=an
local ar=aq:Clone()
ar.Name="Text"
ar.Position=UDim2.fromOffset(47,44)
ar.Text=removeTags(ai)
ar.TextColor3=Color3.new()
ar.TextTransparency=0.5
ar.RichText=true
ar.FontFace=n.Font
ar.Parent=an
local as=ar:Clone()
as.Position=UDim2.fromOffset(-1,-1)
as.Text=ai
as.TextColor3=Color3.fromRGB(170,170,170)
as.TextTransparency=0
as.RichText=true
as.Parent=ar
local at=Instance.new"Frame"
at.Name="Progress"
at.Size=UDim2.new(1,-13,0,2)
at.Position=UDim2.new(0,3,1,-4)
at.ZIndex=5
at.BackgroundColor3=ag.NotificationsBackground and ag.NotificationsBackground.Enabled and Color3.fromHSV(ag.GUIColor.Hue,ag.GUIColor.Sat,ag.GUIColor.Value)or al=="alert"and Color3.fromRGB(250,50,56)
or al=="warning"and Color3.fromRGB(236,129,43)
or Color3.fromRGB(220,220,220)
at.BorderSizePixel=0
at.Parent=an
if m.Tween then
m:Tween(an,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{
AnchorPoint=Vector2.new(1,0),
},m.tweenstwo)
m:Tween(at,TweenInfo.new(aj,Enum.EasingStyle.Linear),{
Size=UDim2.fromOffset(0,2),
})
end
task.delay(aj,function()
if m.Tween then
m:Tween(an,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{
AnchorPoint=Vector2.new(0,0),
},m.tweenstwo)
end
task.wait(0.2)
an:ClearAllChildren()
an:Destroy()
end)
end)
end

local ag
function c.CreatePrompt(ah,ai)
if ag then
pcall(ag)
ag=nil
end

ai=ai or{}

local aj=ai.Title or"Confirm"
local ak=ai.Text or"Are you sure?"

local al=ai.ConfirmText or"OK"
local am=ai.CancelText or"Cancel"

local an=ai.ConfirmColor or Color3.fromRGB(60,60,60)
local ao=ai.CancelColor or Color3.fromRGB(60,60,60)

local ap=ai.ConfirmHoverColor or Color3.fromRGB(90,90,90)
local aq=ai.CancelHoverColor or Color3.fromRGB(90,90,90)

local ar=ai.OnConfirm
local as=ai.OnCancel

local at=ai.Input
local au=ai.InputPlaceholder or""
local av=ai.InputDefault or""

task.delay(0,function()
if c.ThreadFix then
setthreadidentity(8)
end


local aw=Instance.new"ImageLabel"
aw.Name="Prompt"
aw.Size=UDim2.fromOffset(360,180)
aw.AnchorPoint=Vector2.new(0.5,0.5)
aw.Position=UDim2.fromScale(0.5,0.45)
aw.BackgroundTransparency=1
aw.ZIndex=20
aw.Image=t"vape/assets/new/notification.png"
aw.ScaleType=Enum.ScaleType.Slice
aw.SliceCenter=Rect.new(7,7,9,9)
aw.Parent=r

local ax=Instance.new"UIScale"
ax.Scale=1
ax.Parent=aw

aw.MouseEnter:Connect(function()
m:Tween(ax,TweenInfo.new(0.15),{
Scale=1.05,
})
end)

aw.MouseLeave:Connect(function()
m:Tween(ax,TweenInfo.new(0.15),{
Scale=1,
})
end)

addBlur(aw,true)

local ay
if at then
ay=Instance.new"TextBox"
ay.Size=UDim2.new(1,-24,0,32)
ay.Position=UDim2.fromOffset(12,90)
ay.BackgroundColor3=Color3.fromRGB(45,45,45)
ay.PlaceholderText=au
ay.Text=av
ay.TextColor3=Color3.fromRGB(230,230,230)
ay.PlaceholderColor3=Color3.fromRGB(140,140,140)
ay.TextSize=14
ay.FontFace=n.Font
ay.ClearTextOnFocus=false
ay.ZIndex=22
ay.Parent=aw

addCorner(ay)
end


local az=Instance.new"TextLabel"
az.Size=UDim2.new(1,-20,0,26)
az.Position=UDim2.fromOffset(12,10)
az.BackgroundTransparency=1
az.TextXAlignment=Enum.TextXAlignment.Left
az.TextYAlignment=Enum.TextYAlignment.Top
az.RichText=true
az.Text="<stroke color='#FFFFFF' thickness='0.3' transparency='0.5'>"..aj.."</stroke>"
az.TextColor3=Color3.fromRGB(220,220,220)
az.TextSize=16
az.FontFace=n.FontSemiBold
az.ZIndex=21
az.Parent=aw


local aA=Instance.new"TextLabel"
aA.Size=UDim2.new(1,-24,0,70)
aA.Position=UDim2.fromOffset(12,44)
aA.BackgroundTransparency=1
aA.TextWrapped=true
aA.TextXAlignment=Enum.TextXAlignment.Left
aA.TextYAlignment=Enum.TextYAlignment.Top
aA.RichText=true
aA.Text=ak
aA.TextColor3=Color3.fromRGB(170,170,170)
aA.TextSize=20
aA.FontFace=n.Font
aA.ZIndex=21
aA.Parent=aw


local aB=Instance.new"Frame"
aB.Size=UDim2.new(1,-20,0,38)
aB.Position=UDim2.new(0,10,1,-48)
aB.BackgroundTransparency=1
aB.ZIndex=21
aB.Parent=aw


local aC=Instance.new"TextButton"
aC.Size=UDim2.new(0.5,-6,1,0)
aC.Position=UDim2.new(0,0,0,0)
aC.Text=al
aC.AutoButtonColor=false
aC.BackgroundColor3=an
aC.TextColor3=Color3.fromRGB(230,230,230)
aC.TextSize=14
aC.FontFace=n.FontSemiBold
aC.ZIndex=22
aC.Parent=aB
addCorner(aC)


local aD=aC:Clone()
aD.BackgroundColor3=ao
aD.Position=UDim2.new(0.5,6,0,0)
aD.Text=am
aD.Parent=aB

local function hover(aE,aG,aH,aI)
m:Tween(aE,TweenInfo.new(0.15),{
BackgroundColor3=aI and aG or aH,
})
end

aC.MouseEnter:Connect(function()
hover(aC,ap,an,true)
end)
aC.MouseLeave:Connect(function()
hover(aC,ap,an,false)
end)

aD.MouseEnter:Connect(function()
hover(aD,aq,ao,true)
end)
aD.MouseLeave:Connect(function()
hover(aD,aq,ao,false)
end)


local aE=false
local function close()
ag=nil
if aE then
return
end
aE=true

if m.Tween then
m:Tween(aw,TweenInfo.new(0.25,Enum.EasingStyle.Exponential),{
Size=UDim2.fromOffset(340,160),
ImageTransparency=1,
})
end

task.delay(0.2,function()
aw:Destroy()
end)
end
ag=function()
pcall(close)
if typeof(as)=="function"then
task.spawn(as)
end
end

aC.Activated:Connect(function()
local aG=ay and ay.Text or nil
close()
if typeof(ar)=="function"then
task.spawn(ar,aG)
end
end)

aD.Activated:Connect(function()
close()
if typeof(as)=="function"then
task.spawn(as)
end
end)


if m.Tween then
aw.Size=UDim2.fromOffset(340,160)
m:Tween(aw,TweenInfo.new(0.35,Enum.EasingStyle.Exponential),{
Size=UDim2.fromOffset(360,180),
},m.tweenstwo)
end
end)
end

function c.Load(ah,ai,aj)
if not ah._profile_loaded then
ah.PreloadEvent:Fire()
end
ah._profile_loaded=true
if not ai then
ah.GUIColor:SetValue(nil,nil,nil,4)
end
local ak={}
local al=true

local am="vape/profiles/"..str(game.GameId).."_"..str(ah.Place)..".gui.txt"
if not C(am)then
am="vape/profiles/"..str(game.GameId)..".gui.txt"
end
if C(am)then
ak=loadJson(am)
if not ak then
ak={Categories={}}
ah:CreateNotification("Vape","Failed to load GUI settings.",10,"alert")
al=false
end
ah.Profile=aj or ak.Profile or"default"

local an=shared[`FORCE_PROFILE_GUI_COLOR_SET_{tostring(ah.Profile)}`]or(ak.GUIColor~=nil and type(ak.GUIColor)=="table"and ak.GUIColor[ah.Profile])
if an then
ah.GUIColor:SetValue(an.Hue,an.Sat,an.Value)
shared[`FORCE_PROFILE_GUI_COLOR_SET_{tostring(ah.Profile)}`]=nil
end

local ao=shared[`FORCE_PROFILE_TEXT_GUI_CUSTOM_TEXT_{tostring(ah.Profile)}`]
if ao then
c.settextguicustomtext(ao)
shared[`FORCE_PROFILE_TEXT_GUI_CUSTOM_TEXT_{tostring(ah.Profile)}`]=nil
end

if not ai then
ah.Keybind=ak.Keybind
for ap,aq in ak.Categories do
local ar=ah.Categories[ap]
if not ar then
continue
end
if ar.Options and aq.Options then
ah:LoadOptions(ar,aq.Options)
task.wait(0.1)
end
if ar.Button~=nil and aq.Enabled~=nil and(ar.Button.Enabled~=aq.Enabled)then
ar.Button:Toggle()
end
if aq.Pinned~=ar.Pinned then
ar:Pin()
end
if aq.Expanded~=nil and aq.Expanded~=ar.Expanded then
ar:Expand()
end
if aq.List and(#ar.List>0 or#aq.List>0)then
ar.List=aq.List or{}
ar.ListEnabled=aq.ListEnabled or{}
ar:ChangeValue()
end
if aq.Position then
c:LoadPosition(ar.Object,aq.Position)
end
end
end
end
ah.GUI_DATA=ak

ah.Profile=aj or ak.Profile or"default"
ah.Profiles=ak.Profiles or{{
Name="default",
Bind={},
}}

ah.Categories.Profiles:ChangeValue()
if ah.ProfileLabel then
ah.ProfileLabel.Text=#ah.Profile>10 and ah.Profile:sub(1,10).."..."or ah.Profile
ah.ProfileLabel.Size=UDim2.fromOffset(
D(ah.ProfileLabel.Text,ah.ProfileLabel.TextSize,ah.ProfileLabel.Font).X+16,
24
)
end

local an=C("vape/profiles/"..ah.Profile..ah.Place..".txt")

if an then
local ao=loadJson("vape/profiles/"..ah.Profile..ah.Place..".txt")
if not ao then
ao={Categories={},Modules={},Legit={}}
ah:CreateNotification("Vape","Failed to load "..ah.Profile.." profile.",10,"alert")
if ah.Profile~="default"then

pcall(function()
local ap
for aq,ar in c.Profiles do
if ar.Name==ah.Profile then
ap=aq
end
end
if ap then
table.remove(c.Profiles,ap)
end
end)
c:Load(true,"default")
end
al=false
else
for ap,aq in ao.Categories do
local ar=ah.Categories[ap]
if not ar then
continue
end
if ar.Options and aq.Options then
ah:LoadOptions(ar,aq.Options)
end
if aq.Pinned~=ar.Pinned then
ar:Pin()
end
if aq.Expanded~=nil and aq.Expanded~=ar.Expanded then
ar:Expand()
end
if ar.Button~=nil and aq.Enabled~=nil and(ar.Button.Enabled~=aq.Enabled)then
ar.Button:Toggle()
end
if aq.List and(#ar.List>0 or#aq.List>0)then
ar.List=aq.List or{}
ar.ListEnabled=aq.ListEnabled or{}
ar:ChangeValue()
end
if aq.Position then
c:LoadPosition(ar.Object,aq.Position)
end
end

for ap,aq in ao.Modules do
local ar=ah.Modules[ap]
if not ar then
continue
end
if ar.Options and aq.Options then
ah:LoadOptions(ar,aq.Options)
end
if ar.StarActive~=nil and aq.Favorited~=nil and ar.StarActive~=aq.Favorited and ar.ToggleStar~=nil and type(ar.ToggleStar)=="function"then
ar:ToggleStar(true)
end
if aq.Enabled~=ar.Enabled then
if ai then
if ah.ToggleNotifications.Enabled then
ah:CreateNotification(
"Module Toggled",
ap
.."<font color='#FFFFFF'> has been </font>"
..(aq.Enabled and"<font color='#5AFF5A'>Enabled</font>"or"<font color='#FF5A5A'>Disabled</font>")
.."<font color='#FFFFFF'>!</font>",
0.75
)
end
end
ar:Toggle(true)
end
ar:SetBind(aq.Bind,nil,true)
ar.Object.Bind.Visible=#aq.Bind>0
end

for ap,aq in ao.Legit do
local ar=ah.Legit.Modules[ap]
if not ar then
continue
end
if ar.Options and aq.Options then
ah:LoadOptions(ar,aq.Options)
end
if ar.Enabled~=aq.Enabled then
ar:Toggle()
end
if aq.Position and ar.Children then
ar.Children.Position=UDim2.fromOffset(aq.Position.X,aq.Position.Y)
end
end
end
ah:UpdateTextGUI(true)
else
ah:Save(ah.Profile,true)
end

if shared.ForceVoidwareTutorial or(not an and tostring(ah.Profile)=="default")then
ah.NewUser=true
else
ah.NewUser=false
end

if not ah.NewUser and ah.TutorialAPI.isActive then
task.spawn(function()
w.Visible=false
u.Visible=true
ah.TutorialAPI:setText"Tutorial Complete!"
task.wait(1)
ah.TutorialAPI:setText"Thanks for using Voidware <3"
task.wait(1.5)
ah.TutorialAPI:revertTutorialMode(true)
end)
end

if ah.Downloader then
ah.Downloader:Destroy()
ah.Downloader=nil
end
ah.Loaded=al
ah.Categories.Main.Options.Bind:SetBind(ah.Keybind)

if g.TouchEnabled and#ah.Keybind==1 and ah.Keybind[1]=="RightShift"then
local ao=Instance.new"TextButton"
ao.Size=UDim2.fromOffset(32,32)
ao.Position=UDim2.new(1,-90,0,4)
ao.BackgroundColor3=Color3.new()
ao.BackgroundTransparency=0.5
ao.Text=""
ao.Parent=A
local ap=Instance.new"ImageLabel"
ap.Size=UDim2.fromOffset(26,26)
ap.Position=UDim2.fromOffset(3,3)
ap.BackgroundTransparency=1
ap.Image=t"vape/assets/new/vape.png"
ap.Parent=ao
local aq=Instance.new"UICorner"
aq.Parent=ao
ah.VapeButton=ao
ao.Activated:Connect(function()
if ah.ThreadFix then
setthreadidentity(8)
end
for ar,as in ah.Windows do
as.Visible=false
end
for ar,as in ah.Modules do
if as.Bind.Button then
as.Bind.Button.Visible=u.Visible
end
end
u.Visible=not u.Visible
y.Visible=false
ah:BlurCheck()
end)
end
ah:onload()
end

function c.LoadOptions(ah,ai,aj)
for ak,al in aj do
local am=ai.Options[ak]
if not am then
continue
end
if am.NoSave then continue end
am:Load(al)
end
end

function c.CheckBounds(ah,ai,aj)
for ak,al in ah.Modules do
if al.Name==aj then
continue
end
if not al.Bind then
continue
end
if type(al.Bind)~="table"then
continue
end

local am=table.concat(al.Bind," + "):upper()

if am==ai then
local an=([[<font color="#ffd966"><b>%s</b></font>]]):format(am)
local ao=([[<font color="#6ab7ff"><b>%s</b></font>]]):format(al.Name)

local ap=([[<b><font color="#ffb347">Duplicate Bind:</font></b> %s <font color="#ffb347">is already used in</font> %s <font color="#ffb347"></font>]]):format(
an,
ao
)

c:CreateNotification("Vape",ap,10,"warning")
end
end
end


function c.Remove(ah,ai)
local aj=(
ah.Modules[ai]and ah.Modules
or ah.Legit.Modules[ai]and ah.Legit.Modules
)local ak=
ah.Modules[ai]and"Modules"or ah.Legit.Modules[ai]and"Legit"or ah.Categories and"Categories"
if aj and aj[ai]then

local al=aj[ai]
if ah.ThreadFix then
setthreadidentity(8)
end

for am,an in{"Object","Children","Toggle","Button"}do
local ao=typeof(al[an])=="table"and al[an].Object or al[an]
if typeof(ao)=="Instance"then
ao:Destroy()
ao:ClearAllChildren()
end
end

loopClean(al)
aj[ai]=nil
end
end

function c.SavePosition(ah,ai)
if not ai then return nil end
return{
X={
Scale=ai.Position.X.Scale,
Offset=ai.Position.X.Offset
},
Y={
Scale=ai.Position.Y.Scale,
Offset=ai.Position.Y.Offset
}
}
end

function c.LoadPosition(ah,ai,aj)
if not aj then
warn(`LoadPositions: {tostring(ai)} has INVALID DATA!`)
return
end
local ak={X={Scale=0,Offset=0},Y={Scale=0,Offset=0}}
local function load(al,am)
for an,ao in{"Scale","Offset"}do
if not am[ao]then continue end
ak[al][ao]=am[ao]
end
end
for al,am in{"X","Y"}do
if aj[am]~=nil then
if type(aj[am])=="table"then
load(am,aj[am])
else
ak[am].Offset=aj[am]
end
end
end
ai.Position=UDim2.new(ak.X.Scale,ak.X.Offset,ak.Y.Scale,ak.Y.Offset)
end

function c.Save(ah,ai,aj)
if not ah.Loaded then
return
end
local ak={
Categories={},
Profile=ai or ah.Profile,
Profiles=ah.Profiles,
Keybind=ah.Keybind
}
ak.GUIColor=ah.GUI_DATA and ah.GUI_DATA.GUIColor or{}
ak.GUIColor[ah.Profile]={
Hue=ah.GUIColor.Hue,
Sat=ah.GUIColor.Sat,
Value=ah.GUIColor.Value
}
local al={
Modules={},
Categories={},
Legit={},
}

if not aj then
for am,an in ah.Categories do
(an.Type~="Category"and am~="Main"and al or ak).Categories[am]={
Enabled=am~="Main"and an.Button and an.Button.Enabled or nil,
Expanded=an.Type~="Overlay"and an.Type~="ModuleCategory"and an.Expanded or nil,
Pinned=an.Pinned,
Position=an.Type~="ModuleCategory"and ah:SavePosition(an.Object)or nil,
Options=c:SaveOptions(an,an.Options),
List=an.List,
ListEnabled=an.ListEnabled,
}
end

for am,an in ah.Modules do
al.Modules[an.SavingID or am]={
Enabled=an.Enabled,
Favorited=an.StarActive,
Bind=an.Bind.Button
and{Mobile=true,X=an.Bind.Button.Position.X.Offset,Y=an.Bind.Button.Position.Y.Offset}
or an.Bind,
Options=c:SaveOptions(an,true),
}
end

for am,an in ah.Legit.Modules do
al.Legit[am]={
Enabled=an.Enabled,
Position=an.Children and{X=an.Children.Position.X.Offset,Y=an.Children.Position.Y.Offset}or nil,
Options=c:SaveOptions(an,an.Options),
}
end
end

writefile("vape/profiles/"..str(game.GameId).."_"..str(ah.Place)..".gui.txt",k:JSONEncode(ak))
writefile("vape/profiles/"..ah.Profile..ah.Place..".txt",k:JSONEncode(al))
end

function c.DisableSaving(ah)
c:CreateNotification("Vape","Saving is disabled due to an error in Voidware!",30,"warning")
ah.Loaded=false
ah.Save=function()end
end

function c.SaveOptions(ah,ai,aj)
if not aj then
return
end
aj={}
for ak,al in ai.Options do
if not al.Save then
continue
end
if al.NoSave then continue end
al:Save(aj)
end
return aj
end

function c.Uninject(ah,ai)
local aj=print
local ak=function(...)
local ak={...}
if not shared.UninjectDebug then return end
aj(unpack(ak))
end
ak"save started"
if not ai then
c:Save()
end
ak"save ended"
c.Loaded=nil
c.SelfDestructEvent:Fire()
ak"module disabling started"
for al,am in ah.Modules do
if am.Enabled then
a:wrap(function()
am:Toggle()
end)()
end
end
ak"module disabling ended"
ak"legit disabling started"
for al,am in ah.Legit.Modules do
if am.Enabled then
a:wrap(function()
am:Toggle()
end)()
end
end
ak"legit disabling ended"
ak"category disabling started"
for al,am in ah.Categories do
if am.Type=="Overlay"and am.Button.Enabled then
a:wrap(function()
am.Button:Toggle()
end)()
end
end
ak"category disabling ended"
ak"api maid cleaning started"
for al,am in c.Connections do
pcall(function()
am:Disconnect()
end)
end
ak"api maid cleaning ended"
ak("api thread fix check ",c.ThreadFix)
if c.ThreadFix then
setthreadidentity(8)
u.Visible=false
c:BlurCheck()
end
ak"api thread fix check ended"
c.gui:ClearAllChildren()
c.gui:Destroy()
ak"destroyed gui"
table.clear(c.Libraries)
ak"loopclean started"
loopClean(c)
ak"loopclean ended"
shared.vape=nil
shared.vapereload=nil
shared.VapeIndependent=nil
end

A=Instance.new"ScreenGui"
A.Name=randomString()
A.DisplayOrder=9999999
A.ZIndexBehavior=Enum.ZIndexBehavior.Global
A.IgnoreGuiInset=true
pcall(function()
A.OnTopOfCoreBlur=true
end)



A.Parent=d(game:GetService"Players").LocalPlayer.PlayerGui
A.ResetOnSpawn=false

c.gui=A
v=Instance.new"Frame"
v.Name="ScaledGui"
v.Size=UDim2.fromScale(1,1)
v.BackgroundTransparency=1
v.Parent=A
u=Instance.new"Frame"
u.Name="ClickGui"
u.Size=UDim2.fromScale(1,1)
u.BackgroundTransparency=1
u.Visible=false
u.Parent=v
c:Clean(u:GetPropertyChangedSignal"Visible":Connect(function()
c.VisibilityChanged:Fire(u.Visible)
end))
local ah=Instance.new"TextLabel"
ah.Size=UDim2.fromScale(1,0.02)
ah.Position=UDim2.fromScale(0,0.97)
ah.BackgroundTransparency=1
ah.Text="discord.gg/voidware"
ah.TextScaled=true
ah.TextColor3=Color3.new(1,1,1)
ah.TextStrokeTransparency=0.5
ah.FontFace=n.Font
ah.Parent=u
c.TutorialAPI={
isActive=false,
label=ah,
flickerTextEffect=flickerTextEffect,
defaultText=ah.Text,
cleanTutorialLabel=function(ai)
if ai.addedBlur then
ai.addedBlur:Destroy()
ai.addedBlur=nil
end
end,
activateTutorial=function(ai)
ai:cleanTutorialLabel()
ai.isActive=true
ai.label.TextScaled=false
ai.label.AutomaticSize=Enum.AutomaticSize.Y
ai.label.BackgroundTransparency=0.8
ai.label.BackgroundColor3=Color3.fromRGB(0,0,0)
ai.label.AnchorPoint=Vector2.new(0.5,0)
ai.addedBlur={
Destroy=function()
ai.label.BackgroundTransparency=1
end
}
m:Tween(ai.label,TweenInfo.new(1.5),{
TextSize=30,
Position=UDim2.fromScale(0.5,0.6)
})
ai:setText"Welcome to Voidware!"
ai.label.Parent=v
end,
tweenToSecondPosition=function(ai)
if not ai.isActive then return end
ai.GlobeIconWait=false
m:Tween(ai.label,TweenInfo.new(1.5),{
Position=UDim2.fromScale(0.5,0.78)
})
end,
revertTutorialMode=function(ai,aj)
ai:cleanTutorialLabel()
ai.GlobeIconWait=false
ai.isActive=false
ai.label.TextScaled=true
ai.label.AutomaticSize=Enum.AutomaticSize.None
m:Tween(ai.label,TweenInfo.new(0.5),{
Position=UDim2.fromScale(0.5,0.97)
}).Completed:Connect(function()
ai:setText(ai.defaultText)
ai.label.Parent=u
end)
if aj then
c:CreateNotification("Tutorial Complete!","Thank you for using Voidware <3",10)
end
end,
setText=function(ai,aj)
if not ai.isActive and aj~=ai.defaultText then return end
ai.flickerTextEffect(ai.label,true,aj)
end
}
c.VisibilityChanged:Connect(function()
if c.TutorialAPI.isActive and c.TutorialAPI.GlobeIconWait and not w.Visible then
c.TutorialAPI:setText"Tutorial Cancelled"
task.delay(0.3,function()
c.TutorialAPI:revertTutorialMode()
end)
end
end)
local ai=Instance.new"TextButton"
ai.BackgroundTransparency=1
ai.Modal=true
ai.Text=""
ai.Parent=u
local aj=Instance.new"ImageLabel"
aj.Size=UDim2.fromOffset(64,64)
aj.BackgroundTransparency=1
aj.Visible=false
aj.Image="rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png"
aj.Parent=A
p=Instance.new"Folder"
p.Name="Notifications"
p.Parent=v
r=Instance.new"Folder"
r.Name="Prompts"
r.Parent=v








y=Instance.new"TextLabel"
y.Name="Tooltip"
y.Position=UDim2.fromScale(-1,-1)
y.ZIndex=5
y.BackgroundColor3=l.Dark(n.Main,0.02)
y.Visible=false
y.Text=""
y.TextColor3=l.Dark(n.Text,0.16)
y.TextSize=15
y.FontFace=n.Font
y.Parent=v
x=addBlur(y)
addCorner(y)
local ak=Instance.new"Frame"
ak.Size=UDim2.new(1,-2,1,-2)
ak.Position=UDim2.fromOffset(1,1)
ak.ZIndex=6
ak.BackgroundTransparency=1
ak.Parent=y
local al=Instance.new"UIStroke"
al.Color=l.Light(n.Main,0.02)
al.Parent=ak
addCorner(ak,UDim.new(0,4))
z=Instance.new"UIScale"
z.Scale=math.max(A.AbsoluteSize.X/1920,0.6)
z.Parent=v
c.guiscale=z
v.Size=UDim2.fromScale(1/z.Scale,1/z.Scale)

c:Clean(A:GetPropertyChangedSignal"AbsoluteSize":Connect(function()
if c.Scale.Enabled then
z.Scale=math.max(A.AbsoluteSize.X/1920,0.6)
end
end))

c:Clean(z:GetPropertyChangedSignal"Scale":Connect(function()
v.Size=UDim2.fromScale(1/z.Scale,1/z.Scale)
for am,an in v:GetDescendants()do
if an:IsA"GuiObject"and an.Visible then
an.Visible=false
an.Visible=true
end
end
end))

c:Clean(u:GetPropertyChangedSignal"Visible":Connect(function()
c:UpdateGUI(c.GUIColor.Hue,c.GUIColor.Sat,c.GUIColor.Value,true)
if u.Visible and g.MouseEnabled then
repeat
local am=u.Visible
for an,ao in c.Windows do
am=am or ao.Visible
end
if not am then
break
end

aj.Visible=not g.MouseIconEnabled
if aj.Visible then
local an=g:GetMouseLocation()
aj.Position=UDim2.fromOffset(an.X-31,an.Y-32)
end

task.wait()
until c.Loaded==nil
aj.Visible=false
end
end))

c:CreateGUI()
c.Categories.Main:CreateDivider()
c.Categories.Main:CreateSettingsDivider()





local am=c.Categories.Main:CreateSettingsPane{Name="General"}
c.MultiKeybind=am:CreateToggle{
Name="Enable Multi-Keybinding",
Tooltip="Allows multiple keys to be bound to a module (eg. G + H)",
}
c.QueueTeleportEnabledToggle=am:CreateToggle{
Name="Queue On Teleport",
Default=true,
Tooltip="Makes Voidware auto execute every time you teleport",
Function=function(an)
shared.DISABLED_QUEUE_ON_TELEPORT=not an
if not c.Notifications then return end
c:CreateNotification(
"Voidware",
"Auto Execute"
.."<font color='#FFFFFF'> was </font>"
..(an and"<font color='#5AFF5A'>Enabled</font>"or"<font color='#FF5A5A'>Disabled</font>")
.."<font color='#FFFFFF'>!</font>",
5
)
end
}
c.TranslationDropdown=am:CreateDropdown{
Name="Language",
Tooltip="Choose your language :D",
List={},
Function=function()end,
NoSave=true,
}
E(function()
c.Languages={}
local an={}
local ao
for ap,aq in ac.languages do
ap=tostring(ap)
local ar=aa[ap]or""
local as=`{ap} {tostring(ar)}`
c.Languages[as]=ap
if shared.TargetLanguage==ap then
ao=as
end
if table.find(an,as)then
continue
end
table.insert(an,as)
end
c.TranslationDropdown:SetValues(an,ab)
if ao then
c.TranslationDropdown:SetValue(ao)
end
c.TranslationDropdown:SetCallback(function(ap)
local aq=c.Languages[ap]
if aq then
shared.TargetLanguage=aq

pcall(function()
if not isfolder"voidware_translations"then
makefolder"voidware_translations"
end
writefile("voidware_translations/lang.txt",tostring(shared.TargetLanguage))
end)

local ar=aa[aq]or""
local as=([[<font color="#6ab7ff"><b>%s</b></font>]]):format(aq)
local at=([[<font color="#ffffff"><b>%s</b></font>]]):format(ar)

local au=([[<b><font color="#7df9ff">🌐 Language switched to:</font></b> %s %s]]):format(
as,
at
)

c:CreateNotification("Language Updated",au,3,"info")
end
end)
end)
am:CreateButton{
Name="Reset current profile",
Function=function()
c.Save=function()end
if C("vape/profiles/"..c.Profile..c.Place..".txt")and delfile then
delfile("vape/profiles/"..c.Profile..c.Place..".txt")
end
shared.vapereload=true
if shared.VapeDeveloper then
loadstring(readfile"vape/loader.lua","loader")()
else
loadstring(
c.http_function(
'https://raw.githubusercontent.com/VapeVoidware/VWRewrite/'
..readfile"vape/profiles/commit.txt"
.."/loader.lua",
true
)
)()
end
end,
Tooltip="This will set your profile to the default settings of Vape",
}
am:CreateButton{
Name="Self destruct",
Function=function()
c:Uninject()
end,
Tooltip="Removes vape from the current game",
}
am:CreateButton{
Name="Reinject",
Function=function()
shared.vapereload=true
if shared.VapeDeveloper then
loadstring(readfile"vape/loader.lua","loader")()
else
loadstring(
c.http_function(
"https://raw.githubusercontent.com/"
.."VapeVoidware"
.."/VWRewrite/"
..readfile"vape/profiles/commit.txt"
.."/loader.lua",
true
)
)()
end
end,
Tooltip="Reloads vape for debugging purposes",
}

c:CreateCategory{
Name="Combat",
Icon=t"vape/assets/new/combaticon.png",
Size=UDim2.fromOffset(13,14),
Visible=true,
}
c:CreateCategory{
Name="Blatant",
Icon=t"vape/assets/new/blatanticon.png",
Size=UDim2.fromOffset(14,14),
Visible=true,
}
c:CreateCategory{
Name="Render",
Icon=t"vape/assets/new/rendericon.png",
Size=UDim2.fromOffset(15,14),
Visible=true,
}
c:CreateCategory{
Name="Utility",
Icon=t"vape/assets/new/utilityicon.png",
Size=UDim2.fromOffset(15,14),
Visible=true,
}
c:CreateCategory{
Name="World",
Icon=t"vape/assets/new/worldicon.png",
Size=UDim2.fromOffset(14,14),
Visible=true,
}
for an,ao in{
{
Name="Inventory",
Icon=t"vape/assets/new/inventoryicon.png",
Size=UDim2.fromOffset(15,14),
},
{
Name="Minigames",
Icon=t"vape/assets/new/miniicon.png",
Size=UDim2.fromOffset(19,12),
}
}do
c.Categories[ao.Name]=c.Categories.World:CreateModuleCategory(ao)
end
c:CreateCategory{
Name="Legit",
Icon=t"vape/assets/new/legittab.png",
Size=UDim2.fromOffset(14,14),
Visible=true
}
c.Categories.Main:CreateDivider"misc"
c.PreloadEvent:Connect(function()
c.SortGuiCallback(true)
end)




local an
local ao={
Hue=1,
Sat=1,
Value=1,
}
local ap={
Name="Friends",
Icon=t"vape/assets/new/friendstab.png",
Size=UDim2.fromOffset(17,16),
Placeholder="Roblox username",
Color=Color3.fromRGB(5,134,105),
Function=function()
an.Update:Fire()
an.ColorUpdate:Fire(ao.Hue,ao.Sat,ao.Value)
end,
}
an=c:CreateCategoryList(ap)
an.Update=Instance.new"BindableEvent"
an.ColorUpdate=Instance.new"BindableEvent"
an:CreateToggle{
Name="Recolor visuals",
Darker=true,
Default=true,
Function=function()
an.Update:Fire()
an.ColorUpdate:Fire(ao.Hue,ao.Sat,ao.Value)
end,
}
ao=an:CreateColorSlider{
Name="Friends color",
Darker=true,
Function=function(aq,ar,as)
for at,au in an.Object.Children:GetChildren()do
local av=au:FindFirstChild"Dot"
if av and av.BackgroundColor3~=l.Light(n.Main,0.37)then
av.BackgroundColor3=Color3.fromHSV(aq,ar,as)
av.Dot.BackgroundColor3=av.BackgroundColor3
end
end
ap.Color=Color3.fromHSV(aq,ar,as)
an.ColorUpdate:Fire(aq,ar,as)
end,
}
an:CreateToggle{
Name="Use friends",
Darker=true,
Default=true,
Function=function()
an.Update:Fire()
an.ColorUpdate:Fire(ao.Hue,ao.Sat,ao.Value)
end,
}
c:Clean(an.Update)
c:Clean(an.ColorUpdate)




c:CreateCategoryList{
Name="Profiles",
Icon=t"vape/assets/new/profilesicon.png",
Size=UDim2.fromOffset(17,10),
Position=UDim2.fromOffset(12,16),
Placeholder="Type name",
Profiles=true,
}

c:connectOnLoad(function(aq)
if aq.NewUser then
task.spawn(function()
task.wait(1.5)
if u.Visible then
u.Visible=false
end
task.wait(0.1)
aq:CreatePrompt{
Title="Welcome to Voidware",
Text="Would you like to pick out a pre made config?",
ConfirmText="Yeah",
CancelText="No, Thank you",
CancelColor=Color3.fromRGB(120,40,40),
CancelHoverColor=Color3.fromRGB(170,60,60),
ConfirmColor=Color3.fromRGB(40,120,40),
ConfirmHoverColor=Color3.fromRGB(60,170,60),
OnConfirm=function()
local ar=c.ProfilesCategoryListWindow
if ar then
c.TutorialAPI:activateTutorial()
ar:setup()
m:Tween(ar.scale,TweenInfo.new(0.15),{
Scale=1.1
})
m:Tween(ar.stroke,TweenInfo.new(0.15),{
Thickness=3
})
ar.window.MouseLeave:Once(function()
m:Tween(ar.scale,TweenInfo.new(0.15),{
Scale=1
})
end)
u.Visible=true
task.delay(0.1,function()
c.TutorialAPI.GlobeIconWait=true
c.TutorialAPI:setText"Click on the globe icon to open the configs window"
flickerImageEffect(ar.globeicon,5,0.22)
end)
end
end,
OnCancel=function()
u.Visible=true
c.TutorialAPI:activateTutorial()
c.TutorialAPI:tweenToSecondPosition()
task.wait(1)
c.TutorialAPI:setText(c.VapeButton and"Press the button in the top right to open GUI"or"Press "..table.concat(c.Keybind," + "):upper().." to open & close the GUI")
task.wait(3)
c.TutorialAPI:revertTutorialMode(true)
end,
}
end)
end
end)




local aq
aq=c:CreateCategoryList{
Name="Targets",
Icon=t"vape/assets/new/friendstab.png",
Size=UDim2.fromOffset(17,16),
Placeholder="Roblox username",
Function=function()
aq.Update:Fire()
end,
}
aq.Update=Instance.new"BindableEvent"
c:Clean(aq.Update)

c:CreateLegit()
c:CreateSearch()
c.Categories.Main:CreateOverlayBar()





local ar=c.Categories.Main:CreateSettingsPane{Name="Modules"}
ar:CreateToggle{
Name="Teams by server",
Tooltip="Ignore players on your team designated by the server",
Default=true,
Function=function()
if c.Libraries.entity and c.Libraries.entity.Running then
c.Libraries.entity.refresh()
end
end,
}
ar:CreateToggle{
Name="Use team color",
Tooltip="Uses the TeamColor property on players for render modules",
Default=true,
Function=function()
if c.Libraries.entity and c.Libraries.entity.Running then
c.Libraries.entity.refresh()
end
end,
}





local as=c.Categories.Main:CreateSettingsPane{Name="GUI"}
c.Blur=as:CreateToggle{
Name="Blur background",
Function=function()
c:BlurCheck()
end,
Default=true,
Tooltip="Blur the background of the GUI",
}
as:CreateToggle{
Name="GUI bind indicator",
Default=true,
Tooltip="Displays a message indicating your GUI upon injecting.\nI.E. 'Press RSHIFT to open GUI'",
}
as:CreateToggle{
Name="Show tooltips",
Function=function(at)
y.Visible=false
x.Visible=at
end,
Default=true,
Tooltip="Toggles visibility of these",
}
as:CreateToggle{
Name="Show legit mode",
Function=function(at)
u.Search.Legit.Visible=at
u.Search.LegitDivider.Visible=at
u.Search.TextBox.Size=UDim2.new(1,at and-50 or-10,0,37)
u.Search.TextBox.Position=UDim2.fromOffset(at and 50 or 10,0)
end,
Default=true,
Tooltip="Shows the button to change to Legit Mode",
}
local at={Object={},Value=1}
c.Scale=as:CreateToggle{
Name="Auto rescale",
Default=true,
Function=function(au)
at.Object.Visible=not au
if au then
z.Scale=math.max(A.AbsoluteSize.X/1920,0.6)
else
z.Scale=at.Value
end
end,
Tooltip="Automatically rescales the gui using the screens resolution",
}
at=as:CreateSlider{
Name="Scale",
Min=0.1,
Max=2,
Decimal=10,
Function=function(au,av)
if av and not c.Scale.Enabled then
z.Scale=au
end
end,
Default=1.5,
Darker=true,
Visible=false,
}
c.RainbowMode=as:CreateDropdown{
Name="Rainbow Mode",
List={"Normal","Gradient","Retro"},
Tooltip="Normal - Smooth color fade\nGradient - Gradient color fade\nRetro - Static color",
}
c.RainbowSpeed=as:CreateSlider{
Name="Rainbow speed",
Min=0.1,
Max=10,
Decimal=10,
Default=1,
Tooltip="Adjusts the speed of rainbow values",
}
c.RainbowUpdateSpeed=as:CreateSlider{
Name="Rainbow update rate",
Min=1,
Max=144,
Default=60,
Tooltip="Adjusts the update rate of rainbow values",
Suffix="hz",
}
c.TooltipSlider=as:CreateSlider{
Name="Tooltip Text Size",
Min=5,
Max=30,
Default=15,
Tooltip="Adjusts the tooltip's text size",
Function=function(au)
y.TextSize=au
end
}
as:CreateButton{
Name="Reset GUI positions",
Function=function()
for au,av in c.Categories do
av.Object.Position=UDim2.fromOffset(6,42)
end
end,
Tooltip="This will reset your GUI back to default",
}
c.SortGuiCallback=function(au)
local av={
GUICategory=1,
CombatCategory=2,
BlatantCategory=3,
RenderCategory=4,
UtilityCategory=5,
WorldCategory=6,
InventoryCategory=7,
MinigamesCategory=8,
LegitCategory=9,
ProfilesCategoryList=10,
TargetsCategoryList=11,
FriendsCategoryList=12
}
local aw={}
for ax,ay in c.Categories do
if ay.Type=="Overlay"then continue end
if au and ay.Object.Name=="ProfilesCategoryList"then continue end
table.insert(aw,ay)
end
table.sort(aw,function(ax,ay)
return(av[ax.Object.Name]or 99)<(av[ay.Object.Name]or 99)
end)

local ax=0
for ay,az in aw do
if az.Object.Visible then
az.Object.Position=UDim2.fromOffset(6+(ax%8*230),60+(ax>7 and 360 or 0))
ax+=1
end
end
end
as:CreateButton{
Name="Sort GUI",
Function=c.SortGuiCallback,
Tooltip="Sorts GUI",
}





local au=c.Categories.Main:CreateSettingsPane{Name="Notifications"}
c.NotificationsBackground=au:CreateToggle{
Name="GUI Theme Background",
Tooltip="Syncs the Background with the GUI Theme",
Default=false,
Darker=true,
}
c.Notifications=au:CreateToggle{
Name="Notifications",
Function=function(av)
if c.ToggleNotifications.Object then
c.ToggleNotifications.Object.Visible=av
end
end,
Tooltip="Shows notifications",
Default=true,
}
c.ToggleNotifications=au:CreateToggle{
Name="Toggle alert",
Tooltip="Notifies you if a module is enabled/disabled.",
Default=true,
Darker=true,
}
c.FavoriteNotifications=au:CreateToggle{
Name="Favorite notify",
Tooltip="Notifies you if when you favorite a module.",
Default=true,
Darker=true,
}
c.BindNotifications=au:CreateToggle{
Name="Bind notify",
Tooltip="Notifies you if when you bind a module.",
Default=true,
Darker=true,
}

c.GUIColor=c.Categories.Main:CreateGUISlider{
Name="GUI Theme",
Function=function(av,aw,ax)
c:UpdateGUI(av,aw,ax,true)
end,
}
c.Categories.Main:CreateBind()





local av=c:CreateOverlay{
Name="Text GUI",
Icon=t"vape/assets/new/textguiicon.png",
Size=UDim2.fromOffset(16,12),
Position=UDim2.fromOffset(12,14),
Function=function()
c:UpdateTextGUI()
end,
}
local aw=av:CreateDropdown{
Name="Sort",
List={"Alphabetical","Length"},
Default="Length",
Function=function()
c:UpdateTextGUI()
end,
}
local ax=av:CreateFont{
Name="Font",
Blacklist="Arial",
Function=function()
c:UpdateTextGUI()
end,
}
local ay
local az=av:CreateDropdown{
Name="Color Mode",
List={"Match GUI color","Custom color"},
Function=function(az)
ay.Object.Visible=az=="Custom color"
c:UpdateTextGUI()
end,
}
ay=av:CreateColorSlider{
Name="Text GUI color",
Function=function()
c:UpdateGUI(c.GUIColor.Hue,c.GUIColor.Sat,c.GUIColor.Value)
end,
Darker=true,
Visible=false,
}
local aA=Instance.new"UIScale"
aA.Parent=av.Children
av:CreateSlider{
Name="Scale",
Min=0,
Max=2,
Decimal=10,
Default=1,
Function=function(aB)
aA.Scale=aB
c:UpdateTextGUI()
end,
}
local aB=av:CreateToggle{
Name="Shadow",
Tooltip="Renders shadowed text.",
Default=true,
NoDefaultCallback=true,
Function=function()
c:UpdateTextGUI()
end,
}
local aC
local aD=av:CreateToggle{
Name="Gradient",
Tooltip="Renders a gradient",
Default=true,
NoDefaultCallback=true,
Function=function(aD)
aC.Object.Visible=aD
c:UpdateTextGUI()
end,
}
aC=av:CreateToggle{
Name="V4 Gradient",
Function=function()
c:UpdateTextGUI()
end,
Default=true,
NoDefaultCallback=true,
Darker=true,
Visible=aD.Enabled
}
local aE=av:CreateToggle{
Name="Animations",
Tooltip="Use animations on text gui",
Function=function()
c:UpdateTextGUI()
end,
}
local aG=av:CreateToggle{
Name="Watermark",
Tooltip="Renders a vape watermark",
Default=true,
NoDefaultCallback=true,
Function=function()
c:UpdateTextGUI()
end,
}
local aH={
Value=0.5,
Object={Visible={}},
}
local aI={Enabled=false}
local aJ=av:CreateToggle{
Name="Render background",
Default=true,
NoDefaultCallback=true,
Function=function(aJ)
aH.Object.Visible=aJ
aI.Object.Visible=aJ
c:UpdateTextGUI()
end,
}
aH=av:CreateSlider{
Name="Transparency",
Min=0,
Max=1,
Default=0.6,
Decimal=10,
Function=function()
c:UpdateTextGUI()
end,
Darker=true,
Visible=aJ.Enabled
}
aI=av:CreateToggle{
Name="Tint",
Function=function()
c:UpdateTextGUI()
end,
Default=true,
NoDefaultCallback=true,
Darker=true,
Visible=aJ.Enabled
}
local aK
local aL=av:CreateToggle{
Name="Hide modules",
Tooltip="Allows you to blacklist certain modules from being shown.",
Function=function(aL)
aK.Object.Visible=aL
c:UpdateTextGUI()
end,
}
aK=av:CreateTextList{
Name="Blacklist",
Tooltip="Name of module to hide.",
Icon=t"vape/assets/new/blockedicon.png",
Tab=t"vape/assets/new/blockedtab.png",
TabSize=UDim2.fromOffset(21,16),
Color=Color3.fromRGB(250,50,56),
Function=function()
c:UpdateTextGUI()
end,
Visible=false,
Darker=true,
}
local aM=av:CreateToggle{
Name="Hide render",
Function=function()
c:UpdateTextGUI()
end,
}
local aN
local aO
local aP
local aQ
local aR=av:CreateToggle{
Name="Add custom text",
Function=function(aR)
aN.Object.Visible=aR
aO.Object.Visible=aR
aP.Object.Visible=aR
aQ.Object.Visible=aP.Enabled and aR
c:UpdateTextGUI()
end,
}
aN=av:CreateTextBox{
Name="Custom text",
Function=function()
c:UpdateTextGUI()
end,
Darker=true,
Visible=false,
}
c.settextguicustomtext=function(aS)
aR:SetValue(true)
aJ:SetValue(aS)
end
aO=av:CreateFont{
Name="Custom Font",
Blacklist="Arial",
Function=function()
c:UpdateTextGUI()
end,
Darker=true,
Visible=false,
}
aP=av:CreateToggle{
Name="Set custom text color",
Function=function(aS)
aQ.Object.Visible=aS
c:UpdateGUI(c.GUIColor.Hue,c.GUIColor.Sat,c.GUIColor.Value)
end,
Darker=true,
Visible=false,
}
aQ=av:CreateColorSlider{
Name="Color of custom text",
Function=function()
c:UpdateGUI(c.GUIColor.Hue,c.GUIColor.Sat,c.GUIColor.Value)
end,
Darker=true,
Visible=false,
}





local aS={}
local aT=Instance.new"ImageLabel"
aT.Name="Logo"
aT.Size=UDim2.fromOffset(80,21)
aT.Position=UDim2.new(1,-142,0,3)
aT.BackgroundTransparency=1
aT.BorderSizePixel=0
aT.Visible=false
aT.BackgroundColor3=Color3.new()
aT.Image=t"vape/assets/new/textvape.png"
aT.Parent=av.Children

local aU=av.Children.AbsolutePosition.X>(A.AbsoluteSize.X/2)
c:Clean(av.Children:GetPropertyChangedSignal"AbsolutePosition":Connect(function()
if c.ThreadFix then
setthreadidentity(8)
end
local aV=av.Children.AbsolutePosition.X>(A.AbsoluteSize.X/2)
if aU~=aV then
aU=aV
c:UpdateTextGUI()
end
end))

local aV=Instance.new"ImageLabel"
aV.Name="Logo2"
aV.Size=UDim2.fromOffset(33,18)
aV.Position=UDim2.new(1,1,0,1)
aV.BackgroundColor3=Color3.new()
aV.BackgroundTransparency=1
aV.BorderSizePixel=0
aV.Image=t"vape/assets/new/textv4.png"
aV.Parent=aT
local aW=aT:Clone()
aW.Position=UDim2.fromOffset(1,1)
aW.ZIndex=0
aW.Visible=true
aW.ImageColor3=Color3.new()
aW.ImageTransparency=0.65
aW.Parent=aT
aW.Logo2.ZIndex=0
aW.Logo2.ImageColor3=Color3.new()
aW.Logo2.ImageTransparency=0.65
local aX=Instance.new"UIGradient"
aX.Rotation=90
aX.Parent=aT
local aY=Instance.new"UIGradient"
aY.Rotation=90
aY.Parent=aV
local aZ=Instance.new"TextLabel"
aZ.Position=UDim2.fromOffset(5,2)
aZ.BackgroundTransparency=1
aZ.BorderSizePixel=0
aZ.Visible=false
aZ.Text=""
aZ.TextSize=25
aZ.FontFace=aO.Value
aZ.RichText=true
local a_=aZ:Clone()
aZ:GetPropertyChangedSignal"Position":Connect(function()
a_.Position=UDim2.new(
aZ.Position.X.Scale,
aZ.Position.X.Offset+1,
0,
aZ.Position.Y.Offset+1
)
end)
aZ:GetPropertyChangedSignal"FontFace":Connect(function()
a_.FontFace=aZ.FontFace
end)
aZ:GetPropertyChangedSignal"Text":Connect(function()
a_.Text=removeTags(aZ.Text)
end)
aZ:GetPropertyChangedSignal"Size":Connect(function()
a_.Size=aZ.Size
end)
a_.TextColor3=Color3.new()
a_.TextTransparency=0.65
a_.Parent=av.Children
aZ.Parent=av.Children
local a0=Instance.new"Frame"
a0.Name="Holder"
a0.Size=UDim2.fromScale(1,1)
a0.Position=UDim2.fromOffset(5,37)
a0.BackgroundTransparency=1
a0.Parent=av.Children
local a1=Instance.new"UIListLayout"
a1.HorizontalAlignment=Enum.HorizontalAlignment.Right
a1.VerticalAlignment=Enum.VerticalAlignment.Top
a1.SortOrder=Enum.SortOrder.LayoutOrder
a1.Parent=a0





local a2
local a3
local a4
a3=c:CreateOverlay{
Name="Target Info",
Icon=t"vape/assets/new/targetinfoicon.png",
Size=UDim2.fromOffset(14,14),
Position=UDim2.fromOffset(12,14),
CategorySize=240,
Function=function(a5)
if a5 then
task.spawn(function()
repeat
a2:UpdateInfo()
task.wait()
until not a3.Button or not a3.Button.Enabled
end)
end
end,
}

local a5=Instance.new"Frame"
a5.Size=UDim2.fromOffset(240,89)
a5.BackgroundColor3=l.Dark(n.Main,0.1)
a5.BackgroundTransparency=0.5
a5.Parent=a3.Children
local a6=addBlur(a5)
a6.Visible=false
addCorner(a5)
local a7=Instance.new"ImageLabel"
a7.Size=UDim2.fromOffset(26,27)
a7.Position=UDim2.fromOffset(19,17)
a7.BackgroundColor3=n.Main
a7.Image="rbxthumb://type=AvatarHeadShot&id=1&w=420&h=420"
a7.Parent=a5
local a8=Instance.new"Frame"
a8.Size=UDim2.fromScale(1,1)
a8.BackgroundTransparency=1
a8.BackgroundColor3=Color3.new(1,0,0)
a8.Parent=a7
addCorner(a8)
local a9=addBlur(a7)
a9.Visible=false
addCorner(a7)
local ba=Instance.new"TextLabel"
ba.Size=UDim2.fromOffset(145,20)
ba.Position=UDim2.fromOffset(54,20)
ba.BackgroundTransparency=1
ba.Text="Target name"
ba.TextXAlignment=Enum.TextXAlignment.Left
ba.TextYAlignment=Enum.TextYAlignment.Top
ba.TextScaled=true
ba.TextColor3=l.Light(n.Text,0.4)
ba.TextStrokeTransparency=1
ba.FontFace=n.Font
local bb=ba:Clone()
bb.Position=UDim2.fromOffset(55,21)
bb.TextColor3=Color3.new()
bb.TextTransparency=0.65
bb.Visible=false
bb.Parent=a5
ba:GetPropertyChangedSignal"Size":Connect(function()
bb.Size=ba.Size
end)
ba:GetPropertyChangedSignal"Text":Connect(function()
bb.Text=ba.Text
end)
ba:GetPropertyChangedSignal"FontFace":Connect(function()
bb.FontFace=ba.FontFace
end)
ba.Parent=a5
local bc=Instance.new"Frame"
bc.Name="HealthBKG"
bc.Size=UDim2.fromOffset(200,9)
bc.Position=UDim2.fromOffset(20,56)
bc.BackgroundColor3=n.Main
bc.BorderSizePixel=0
bc.Parent=a5
addCorner(bc,UDim.new(1,0))
local bd=bc:Clone()
bd.Size=UDim2.fromScale(0.8,1)
bd.Position=UDim2.new()
bd.BackgroundColor3=Color3.fromHSV(0.4,0.89,0.75)
bd.Parent=bc
bd:GetPropertyChangedSignal"Size":Connect(function()
bd.Visible=bd.Size.X.Scale>0.01
end)
local be=bd:Clone()
be.Size=UDim2.new()
be.Position=UDim2.fromScale(1,0)
be.AnchorPoint=Vector2.new(1,0)
be.BackgroundColor3=Color3.fromRGB(255,170,0)
be.Visible=false
be.Parent=bc
be:GetPropertyChangedSignal"Size":Connect(function()
be.Visible=be.Size.X.Scale>0.01
end)
local bf=addBlur(bc)
bf.SliceCenter=Rect.new(52,31,261,510)
bf.ImageColor3=Color3.new()
bf.Visible=false
local bg=Instance.new"UIStroke"
bg.Enabled=false
bg.Color=Color3.fromHSV(0.44,1,1)
bg.Parent=a5

a3:CreateFont{
Name="Font",
Blacklist="Arial",
Function=function(bh)
ba.FontFace=bh
end,
}
local bh={
Value=0.5,
Object={Visible={}},
}
local bi=a3:CreateToggle{
Name="Use Displayname",
Default=true,
}
a3:CreateToggle{
Name="Render Background",
Function=function(bj)
a5.BackgroundTransparency=bj and bh.Value or 1
bb.Visible=not bj
a6.Visible=bj
bf.Visible=not bj
a9.Visible=not bj
bh.Object.Visible=bj
end,
Default=true,
}
bh=a3:CreateSlider{
Name="Transparency",
Min=0,
Max=1,
Default=0.5,
Decimal=10,
Function=function(bj)
a5.BackgroundTransparency=bj
end,
Darker=true,
}
local bj
local bk=a3:CreateToggle{
Name="Custom Color",
Function=function(bk)
bj.Object.Visible=bk
if bk then
a5.BackgroundColor3=
Color3.fromHSV(bj.Hue,bj.Sat,bj.Value)
a7.BackgroundColor3=
Color3.fromHSV(bj.Hue,bj.Sat,math.max(bj.Value-0.1,0.075))
bc.BackgroundColor3=a7.BackgroundColor3
else
a5.BackgroundColor3=l.Dark(n.Main,0.1)
a7.BackgroundColor3=n.Main
bc.BackgroundColor3=n.Main
end
end,
}
bj=a3:CreateColorSlider{
Name="Color",
Function=function(bl,bm,H)
if bk.Enabled then
a5.BackgroundColor3=Color3.fromHSV(bl,bm,H)
a7.BackgroundColor3=Color3.fromHSV(bl,bm,math.max(H-0.1,0))
bc.BackgroundColor3=a7.BackgroundColor3
end
end,
Darker=true,
Visible=false,
}
c:setupguicolorsync(a3,{
Color1=bj,
Default=true
})
a3:CreateToggle{
Name="Border",
Function=function(bl)
bg.Enabled=bl
a4.Object.Visible=bl
end,
}
a4=a3:CreateColorSlider{
Name="Border Color",
Function=function(bl,bm,H,I)
bg.Color=Color3.fromHSV(bl,bm,H)
bg.Transparency=1-I
end,
Darker=true,
Visible=false,
}

local bl=0
local bm=0
a2={
Targets={},
Object=a5,
UpdateInfo=function(H)
local I=c.Libraries
if not I then
return
end

for J,K in H.Targets do
if K<tick()then
H.Targets[J]=nil
end
end

local J,K=(tick())
for L,M in H.Targets do
if M>J then
K=L
J=M
end
end

a5.Visible=K~=nil or u.Visible
if K then
ba.Text=K.Player and(bi.Enabled and K.Player.DisplayName or K.Player.Name)
or K.Character and K.Character.Name
or ba.Text
a7.Image="rbxthumb://type=AvatarHeadShot&id="
..(K.Player and K.Player.UserId or 1)
.."&w=420&h=420"

if not K.Character then
K.Health=K.Health or 0
K.MaxHealth=K.MaxHealth or 100
end

if K.Health~=bl or K.MaxHealth~=bm then
local L=math.max(K.Health/K.MaxHealth,0)
m:Tween(bd,TweenInfo.new(0.3),{
Size=UDim2.fromScale(math.min(L,1),1),
BackgroundColor3=Color3.fromHSV(math.clamp(L/2.5,0,1),0.89,0.75),
})
m:Tween(be,TweenInfo.new(0.3),{
Size=UDim2.fromScale(math.clamp(L-1,0,0.8),1),
})
if bl>K.Health and H.LastTarget==K then
m:Cancel(a8)
a8.BackgroundTransparency=0.3
m:Tween(a8,TweenInfo.new(0.5),{
BackgroundTransparency=1,
})
end
bl=K.Health
bm=K.MaxHealth
end

if not K.Character then
table.clear(K)
end
H.LastTarget=K
end
return K
end,
}
c.Libraries.targetinfo=a2

function c.UpdateTextGUI(H,I)
if not I and not c.Loaded then
return
end
if av.Button.Enabled then
local J=av.Children.AbsolutePosition.X>(A.AbsoluteSize.X/2)
aT.Visible=aG.Enabled
aT.Position=J and UDim2.new(1/aA.Scale,-113,0,6)or UDim2.fromOffset(0,6)
aW.Visible=aB.Enabled
aZ.Text=aN.Value
aZ.FontFace=aO.Value
aZ.Visible=aZ.Text~=""and aR.Enabled
a_.Visible=aZ.Visible and aB.Enabled
a1.HorizontalAlignment=J and Enum.HorizontalAlignment.Right or Enum.HorizontalAlignment.Left
a0.Size=UDim2.fromScale(1/aA.Scale,1)
a0.Position=UDim2.fromOffset(
J and 3 or 0,
11
+(aT.Visible and aT.Size.Y.Offset or 0)
+(aZ.Visible and 28 or 0)
+(aJ.Enabled and 3 or 0)
)
if aZ.Visible then
local K=
D(removeTags(aZ.Text),aZ.TextSize,aZ.FontFace)
aZ.Size=UDim2.fromOffset(K.X,K.Y)
aZ.Position=UDim2.new(
J and 1/aA.Scale or 0,
J and-K.X or 0,
0,
(aT.Visible and 32 or 8)
)
end

local K={}
for L,M in aS do
if M.Enabled then
table.insert(K,M.Object.Name)
end
M.Object:Destroy()
end
table.clear(aS)

local L=TweenInfo.new(0.3,Enum.EasingStyle.Exponential)
for M,N in c.Modules do
if aL.Enabled and table.find(aK.ListEnabled,M)then
continue
end
if aM.Enabled and N.Category=="Render"then
continue
end
if N.Enabled or table.find(K,M)then
local O=Instance.new"Frame"
O.Name=M
O.Size=UDim2.fromOffset()
O.BackgroundTransparency=1
O.ClipsDescendants=true
O.Parent=a0
local P
local Q
if aJ.Enabled then
P=Instance.new"Frame"
P.Size=UDim2.new(1,3,1,0)
P.BackgroundColor3=l.Dark(n.Main,0.15)
P.BackgroundTransparency=aH.Value
P.BorderSizePixel=0
P.Parent=O
local R=Instance.new"Frame"
R.Size=UDim2.new(1,0,0,1)
R.Position=UDim2.new(0,0,1,-1)
R.BackgroundColor3=Color3.new()
R.BackgroundTransparency=0.928
+(0.072*math.clamp((aH.Value-0.5)/0.5,0,1))
R.BorderSizePixel=0
R.Parent=P
local S=R:Clone()
S.Name="Line"
S.Position=UDim2.new()
S.Parent=P
Q=Instance.new"Frame"
Q.Size=UDim2.new(0,2,1,0)
Q.Position=J and UDim2.new(1,-5,0,0)or UDim2.new()
Q.BorderSizePixel=0
Q.Parent=P
end
local R=Instance.new"TextLabel"
R.Position=UDim2.fromOffset(J and 3 or 6,2)
R.BackgroundTransparency=1
R.BorderSizePixel=0
R.Text=M..(N.ExtraText and" <font color='#A8A8A8'>"..N.ExtraText().."</font>"or"")
R.TextSize=15
R.FontFace=ax.Value
R.RichText=true
local S=D(removeTags(R.Text),R.TextSize,R.FontFace)
R.Size=UDim2.fromOffset(S.X,S.Y)
if aB.Enabled then
local T=R:Clone()
T.Position=
UDim2.fromOffset(R.Position.X.Offset+1,R.Position.Y.Offset+1)
T.Text=removeTags(R.Text)
T.TextColor3=Color3.new()
T.Parent=O
end
R.Parent=O
local T=UDim2.fromOffset(S.X+10,S.Y+(aJ.Enabled and 5 or 3))
if aE.Enabled then
if not table.find(K,M)then
m:Tween(O,L,{
Size=T,
})
else
O.Size=T
if not N.Enabled then
m:Tween(O,L,{
Size=UDim2.fromOffset(),
})
end
end
else
O.Size=N.Enabled and T or UDim2.fromOffset()
end
table.insert(aS,{
Object=O,
Text=R,
Background=P,
Color=Q,
Enabled=N.Enabled,
})
end
end

if aw.Value=="Alphabetical"then
table.sort(aS,function(M,N)
return M.Text.Text<N.Text.Text
end)
else
table.sort(aS,function(M,N)
return M.Text.Size.X.Offset>N.Text.Size.X.Offset
end)
end

for M,N in aS do
if N.Color then
N.Color.Parent.Line.Visible=M~=1
end
N.Object.LayoutOrder=M
end
end

c:UpdateGUI(c.GUIColor.Hue,c.GUIColor.Sat,c.GUIColor.Value,true)
end

function c.UpdateGUI(H,I,J,K,L)
if c.Loaded==nil then
return
end
c.GUIColorChanged:Fire(I,J,K,L)
if not L and c.GUIColor.Rainbow then
return
end
if av.Button.Enabled then
aX.Color=ColorSequence.new{
ColorSequenceKeypoint.new(0,Color3.fromHSV(I,J,K)),
ColorSequenceKeypoint.new(
1,
aD.Enabled and Color3.fromHSV(c:Color((I-0.075)%1))
or Color3.fromHSV(I,J,K)
),
}
aY.Color=aD.Enabled and aC.Enabled and aX.Color
or ColorSequence.new{
ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),
ColorSequenceKeypoint.new(1,Color3.new(1,1,1)),
}
aZ.TextColor3=aP.Enabled
and Color3.fromHSV(aQ.Hue,aQ.Sat,aQ.Value)
or aX.Color.Keypoints[2].Value

local M=az.Value=="Custom color"
and Color3.fromHSV(ay.Hue,ay.Sat,ay.Value)
or nil
for N,O in aS do
O.Text.TextColor3=M
or(
c.GUIColor.Rainbow
and Color3.fromHSV(c:Color((I-((aD and N+2 or N)*0.025))%1))
or aX.Color.Keypoints[2].Value
)
if O.Color then
O.Color.BackgroundColor3=O.Text.TextColor3
end
if aI.Enabled and O.Background then
O.Background.BackgroundColor3=l.Dark(O.Text.TextColor3,0.75)
end
end
end

if not u.Visible and not c.Legit.Window.Visible then
return
end
local M=c.GUIColor.Rainbow and c.RainbowMode.Value~="Retro"

for N,O in c.Categories do
if N=="Main"then
O.Object.VapeLogo.V4Logo.ImageColor3=Color3.fromHSV(I,J,K)
for P,Q in O.Buttons do
if Q.Enabled then
Q.Object.TextColor3=M
and Color3.fromHSV(c:Color((I-(Q.Index*0.025))%1))
or Color3.fromHSV(I,J,K)
if Q.Icon then
Q.Icon.ImageColor3=Q.Object.TextColor3
end
end
end
end

if O.Options then
for P,Q in O.Options do
if Q.Color then
Q:Color(I,J,K,M)
end
end
end

if O.Type=="CategoryList"then
O.Object.Children.Add.AddButton.ImageColor3=M and Color3.fromHSV(c:Color(I%1))
or Color3.fromHSV(I,J,K)
if O.Selected then
O.Selected.BackgroundColor3=M and Color3.fromHSV(c:Color(I%1))
or Color3.fromHSV(I,J,K)
O.Selected.Title.TextColor3=c.GUIColor.Rainbow and Color3.new(0.19,0.19,0.19)
or c:TextColor(I,J,K)
O.Selected.Dots.Dots.ImageColor3=O.Selected.Title.TextColor3
O.Selected.Bind.Icon.ImageColor3=O.Selected.Title.TextColor3
O.Selected.Bind.TextLabel.TextColor3=O.Selected.Title.TextColor3
end
end
end

for N,O in c.Modules do
if O.Enabled then
O.Object.BackgroundColor3=M
and Color3.fromHSV(c:Color((I-(O.Index*0.025))%1))
or Color3.fromHSV(I,J,K)
O.Object.TextColor3=c.GUIColor.Rainbow and Color3.new(0.19,0.19,0.19)
or c:TextColor(I,J,K)
O.Object.UIGradient.Enabled=M and c.RainbowMode.Value=="Gradient"
if O.Object.UIGradient.Enabled then
O.Object.BackgroundColor3=Color3.new(1,1,1)
O.Object.UIGradient.Color=ColorSequence.new{
ColorSequenceKeypoint.new(0,Color3.fromHSV(c:Color((I-(O.Index*0.025))%1))),
ColorSequenceKeypoint.new(
1,
Color3.fromHSV(c:Color((I-((O.Index+1)*0.025))%1))
),
}
end
O.Object.Bind.Icon.ImageColor3=O.Object.TextColor3
O.Object.Bind.TextLabel.TextColor3=O.Object.TextColor3
O.Object.Dots.Dots.ImageColor3=O.Object.TextColor3
end

for P,Q in O.Options do
if Q.Color then
Q:Color(I,J,K,M)
end
end
end

for N,O in c.Overlays.Toggles do
if O.Enabled then
m:Cancel(O.Object.Knob)
O.Object.Knob.BackgroundColor3=M and Color3.fromHSV(c:Color((I-(N*0.075))%1))
or Color3.fromHSV(I,J,K)
end
end

if c.Legit.Icon then
c.Legit.Icon.ImageColor3=Color3.fromHSV(I,J,K)
end

if c.Legit.Window.Visible then
for N,O in c.Legit.Modules do
if O.Enabled then
m:Cancel(O.Object.Knob)
O.Object.Knob.BackgroundColor3=Color3.fromHSV(I,J,K)
end

for P,Q in O.Options do
if Q.Color then
Q:Color(I,J,K,M)
end
end
end
end
end

c:Clean(p.ChildRemoved:Connect(function()
for H,I in p:GetChildren()do
if m.Tween then
m:Tween(I,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{
Position=UDim2.new(1,0,1,-(29+(78*H))),
})
end
end
end))

c:Clean(g.InputBegan:Connect(function(H)
if not g:GetFocusedTextBox()and H.KeyCode~=Enum.KeyCode.Unknown then
table.insert(c.HeldKeybinds,H.KeyCode.Name)
if c.Binding then
return
end

if checkKeybinds(c.HeldKeybinds,c.Keybind,H.KeyCode.Name)then
if c.ThreadFix then
setthreadidentity(8)
end
for I,J in c.Windows do
J.Visible=false
end
u.Visible=not u.Visible
y.Visible=false
c:BlurCheck()
end

local I=false
for J,K in c.Modules do
if checkKeybinds(c.HeldKeybinds,K.Bind,H.KeyCode.Name)then
I=true
if c.ToggleNotifications.Enabled then
c:CreateNotification(
"Module Toggled",
J
.."<font color='#FFFFFF'> has been </font>"
..(not K.Enabled and"<font color='#5AFF5A'>Enabled</font>"or"<font color='#FF5A5A'>Disabled</font>")
.."<font color='#FFFFFF'>!</font>",
0.75
)
end
K:Toggle(true)
end
end
if I then
c:UpdateTextGUI()
end

for J,K in c.Profiles do
if checkKeybinds(c.HeldKeybinds,K.Bind,H.KeyCode.Name)and K.Name~=c.Profile then
c:Save(K.Name)
c:Load(true)
break
end
end
end
end))

c:Clean(g.InputEnded:Connect(function(H)
if not g:GetFocusedTextBox()and H.KeyCode~=Enum.KeyCode.Unknown then
if c.Binding then
if not c.MultiKeybind.Enabled then
c.HeldKeybinds={H.KeyCode.Name}
end
c.Binding:SetBind(
checkKeybinds(c.HeldKeybinds,c.Binding.Bind,H.KeyCode.Name)and{}
or c.HeldKeybinds,
true
)
c.Binding=nil
end
end

local I=table.find(c.HeldKeybinds,H.KeyCode.Name)
if I then
table.remove(c.HeldKeybinds,I)
end
end))

return c