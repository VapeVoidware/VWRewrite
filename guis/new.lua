local a=shared.VoidwareLoader
assert(a~=nil and type(a)=="table","[GuiLibrary]: VoidwareLoader is invalid :c")
local b=a:setupDecoratedCustomSignal"GUILIBRARY_INTERNAL"
local c=function(c)
return b(`TOGGLE_CUSTOM_SIGNAL_{tostring(c)}`)
end
local d={
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
d.DefaultColor=Color3.fromHSV(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
for e,f in{"PreloadEvent","GUIColorChanged","SelfDestructEvent","VisibilityChanged","OnLoadEvent","ProfileChangedEvent","MainGuiSettingsOpenedEvent"}do
if d[f]then continue end
d[f]=b(f)
end
for e,f in{"Categories","Modules","Overlays"}do
if d[f]==nil then
d[f]={}
end
end
d.libraries=setmetatable(d.Libraries,{
__index=function(e,f)
local g=d.Libraries[f]
if g then
rawset(e,f,g)
end
return g
end,
__newindex=function(e,f,g)
if not d.Libraries[f]then
d.Libraries[f]=g
end
rawset(e,f,g)
end
})
function d.connectOnLoad(e,f)
e.loadconns=e.loadconns or{}
if f==nil then return end
if type(f)~="function"then return end
if e.loadconns[tostring(f)]then return end
e.loadconns[tostring(f)]=f
end
function d.onload(e)
if not e.loadconns then return end
e.ProfileChangedEvent:Fire()
for f,g in e.loadconns do
task.spawn(pcall,g,d)
e.loadconns[f]=nil
end
end

local e=cloneref or function(e)
return e
end
local f=setmetatable({},{
__index=function(f,g)
local h,i=pcall(function()
local h=game:GetService(g)
if not h then
error(`Service {tostring(g)} not found!`)
return
end
return e(h)
end)
if not h then
a:report{
type="Services-gui-api",
err=i,
args={g},
}
else
rawset(f,g,i)
end
return h and i
end,
})
local g=f.TweenService
local h=f.UserInputService
local i=f.TextService
local j=f.GuiService local k=
f.RunService
local l=f.HttpService

d.isMobile=h.TouchEnabled and not h.KeyboardEnabled

local m={}
local n={
tweens={},
tweenstwo={},
}
local o={
Main=Color3.fromRGB(0,0,0),
Text=Color3.fromRGB(255,255,255),
Font=Font.fromEnum(Enum.Font.Arial),
FontSemiBold=Font.fromEnum(Enum.Font.Arial,Enum.FontWeight.SemiBold),
Tween=TweenInfo.new(0.16,Enum.EasingStyle.Linear),
}

local function getTableSize(p)
local q=0
for r in p do
q+=1
end
return q
end

local function loopClean(p,q)
q=q or{}
if q[p]then
return
end
q[p]=true

local r={
ModuleCategory=true,
CategoryApi=true,
}

for s,t in pairs(p)do
if not r[s]and type(t)=="table"then
loopClean(t,q)
end
p[s]=nil
end
end

local function addMaid(p)
p.Connections={}
function p.Clean(q,r)
if typeof(r)=="Instance"then
table.insert(q.Connections,{
Disconnect=function()
r:ClearAllChildren()
r:Destroy()
end,
})
elseif type(r)=="function"then
table.insert(q.Connections,{
Disconnect=r,
})
elseif typeof(r)=="thread"then
table.insert(q.Connections,{
Disconnect=function()
pcall(task.cancel,r)
end,
})
else
table.insert(q.Connections,r)
end
end
end
addMaid(d)

local function loadJson(p,q)
local r,s=pcall(function()
local r=q and p or readfile(p)
return l:JSONDecode(r)
end)
return r and type(s)=="table"and s or nil
end

local function decode(p)
return loadJson(p,true)
end

local function encode(p)
local q,r=pcall(function()
return l:JSONEncode(p)
end)
if not q then
warn(`[encode]: {tostring(r)}`)
end
return q and r
end

local function flickerTextEffect(p,q,r)
if q==true and p.TextTransparency==0 then
n:Tween(p,TweenInfo.new(0.15),{
TextTransparency=1,
}).Completed:Wait()
end
if r~=nil then
p.Text=r
end
n:Tween(p,TweenInfo.new(0.15),{
TextTransparency=q and 0 or 1,
}).Completed:Wait()
end

local function flickerImageEffect(p,q,r)
if not p or not(p:IsA"ImageButton"or p:IsA"ImageLabel")then
return
end

q=q or 0.5
r=r or 0.15

local s=tick()
local t=p.Size
local u=p.ImageColor3
local v=p.ImageTransparency

local w=Instance.new"UIScale"
w.Scale=1
w.Parent=p

task.spawn(function()
n:Tween(w,TweenInfo.new(r),{
Scale=1.2
})
while tick()-s<q and p.Parent do
n:Tween(p,TweenInfo.new(r),{
ImageTransparency=0,
ImageColor3=Color3.fromRGB(255,255,255)
})

task.wait(r)

n:Tween(p,TweenInfo.new(r),{
ImageTransparency=v,
ImageColor3=u
})

task.wait(r)
end

pcall(function()
w:Destroy()
end)
n:Tween(w,TweenInfo.new(r),{
Scale=1,
})
p.Size=t
p.ImageTransparency=v
end)
end

local function Color3ToHex(p)
local q=math.floor(p.R*255)
local r=math.floor(p.G*255)
local s=math.floor(p.B*255)
return string.format("#%02x%02x%02x",q,r,s)
end

local function hsv(p,q,r)
local s,t=pcall(function()
return Color3.fromHSV(p,q,r)
end)
return s,t
end

local function str(p)
return tostring(p)
end

local function tblcheck(p)
return(p~=nil and type(p)=="table")
end

local function num(p)
if p==nil then
return p
end
return tonumber(p)
end

local function count(p)
local q=0
for r,s in p do
q=q+1
end
return q
end

local function wrap(p)
return a:wrap(p,{
name="wrap:api"
})
end
d.wrap=wrap

local function connectDoubleClick(p,q,s)
local t=0
s=s or 0.25
if not(q~=nil and type(q)=="function")then
q=function()end
else
d.wrap(q)
end

warn("connectDoubleClick set up for",p)

p.Activated:Connect(function()
local u=tick()

print(u-t,s)
if u-t<=s then
q()
end

t=u
end)
end
d.connectDoubleClick=connectDoubleClick

local function connectguicolorchange(p,q)
p=wrap(p)
local s
if type(p)=="function"then
p(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
s=d.GUIColorChanged.Event:Connect(p)
else
p.BackgroundColor3=Color3.fromHSV(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
s=d.GUIColorChanged.Event:Connect(function(t,u,v)
p.BackgroundColor3=Color3.fromHSV(t,u,v)
end)
end
if q and type(p)=="function"then
d:Clean(s)
return{
run=function()
p(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
end,
conn=s
}
end
return s
end
d.connectguicolorchange=connectguicolorchange

d.GuiColorSyncAPI={}
function d.setupguicolorsync(p,q,s,t)
if not(t~=nil and type(t)=="function")then
t=function()end
else
t=wrap(t)
end
if not tblcheck(q)then
a:throw(`[setupguicolorsync]: api invalid! {tostring(q)}`)
return
end
if not(tblcheck(s)and tblcheck(s.Color1))then
a:throw(`[setupguicolorsync]: options invalid! {tostring(s)}`)
return
end

local u,v,w=s.Color1,s.Color2,s.Color3
local x=false
























local y=function()end

local z
q.Name=q.Name or l:GenerateGUID(false)
z=p.GuiColorSyncAPI[q.Name]or q:CreateToggle{
Name="GUI Color Sync",
Function=function(A)
t(A)
if A then
y()
end
end,
Tooltip=s.Tooltip or"Syncs with the gui theme color",
Default=s.Default
}
p.GuiColorSyncAPI[q.Name]=z

for A,B in{u,v,w}do
B:ConnectCallback(function()
if z.Enabled and not x then
InfoNotification(`GUI Sync - {q.Name}`,"Disabled due to color slider change! Re-enable if you want :D",5)
z:Toggle()
end
end)
end

y=connectguicolorchange(function(A,B,C)
if not z.Enabled then return end
local D={Hue=A,Sat=B,Value=C}

x=true

if w then
local E=D

if s.Color1HueShift then
local F=(A+s.Color1HueShift)%1
E={Hue=F,Sat=B,Value=C}
end
local F=(A+(s.Color2HueShift or 0.1))%1
local G=(A+(s.Color3HueShift or 0.2))%1
local H={Hue=F,Sat=B,Value=C}
local I={Hue=G,Sat=B,Value=C}

u:SetValue(E.Hue,E.Sat,E.Value)
v:SetValue(H.Hue,H.Sat,H.Value)
w:SetValue(I.Hue,I.Sat,I.Value)
elseif v then
local E=D
local F=(A+(s.Color2HueShift or 0.1))%1
local G={Hue=F,Sat=B,Value=C}

u:SetValue(E.Hue,E.Sat,E.Value)
v:SetValue(G.Hue,G.Sat,G.Value)
else
if s.Color1HueShift then
local E=(A+s.Color1HueShift)%1
D={Hue=E,Sat=B,Value=C}
end
u:SetValue(D.Hue,D.Sat,D.Value)
end

x=false
end,true).run

return z
end

local function connectvisibilitychange(p)
return d.VisibilityChanged.Event:Connect(p)
end
d.connectvisibilitychange=connectvisibilitychange

local p=Instance.new"GetTextBoundsParams"
p.Width=math.huge
local q
local s
local t=getcustomasset
local u
local v
local w
local x
local y
local z
local A
local B

local C={
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

local D=isfile
or function(D)
local E,F=pcall(function()
return readfile(D)
end)
return E and F~=nil and F~=""
end

local E=function(E,F,G)
p.Text=E
p.Size=F
if typeof(G)=="Font"then
p.Font=G
end
local H,I=pcall(function()
return i:GetTextBoundsAsync(p)
end)
if not H then
a:report{
type="getfontsize-function",
err=I,
args={E,F,G},
notifyBlacklisted=true,
}
end
return H and I
end

local function addBlur(F,G)
local H=Instance.new"ImageLabel"
H.Name="Blur"
H.Size=UDim2.new(1,89,1,52)
H.Position=UDim2.fromOffset(-48,-31)
H.BackgroundTransparency=1
H.Image=u("vape/assets/new/"..(G and"blurnotif"or"blur")..".png")
H.ScaleType=Enum.ScaleType.Slice
H.SliceCenter=Rect.new(52,31,261,502)
H.Parent=F

return H
end

local function addCorner(F,G)
local H=Instance.new"UICorner"
H.CornerRadius=G or UDim.new(0,5)
H.Parent=F

return H
end

local function addCloseButton(F,G)
local H=Instance.new"ImageButton"
H.Name="Close"
H.Size=UDim2.fromOffset(24,24)
H.Position=UDim2.new(1,-35,0,G or 9)
H.BackgroundColor3=Color3.new(1,1,1)
H.BackgroundTransparency=1
H.AutoButtonColor=false
H.Image=u"vape/assets/new/close.png"
H.ImageColor3=m.Light(o.Text,0.2)
H.ImageTransparency=0.5
H.Parent=F
addCorner(H,UDim.new(1,0))

H.MouseEnter:Connect(function()
H.ImageTransparency=0.3
n:Tween(H,o.Tween,{
BackgroundTransparency=0.6,
})
end)
H.MouseLeave:Connect(function()
H.ImageTransparency=0.5
n:Tween(H,o.Tween,{
BackgroundTransparency=1,
})
end)

return H
end





local function addTooltip(F,G)
if d.isMobile then return end
if not G then
return
end

local function tooltipMoved(H,I)
local J=H+16+z.Size.X.Offset>(A.Scale*1920)
z.Position=UDim2.fromOffset(
(J and H-(z.Size.X.Offset*A.Scale)-16 or H+16)/A.Scale,
((I+11)-(z.Size.Y.Offset/2))/A.Scale
)
z.Visible=y.Visible
end

local H={}
H[1]=F.MouseEnter:Connect(function(I,J)
local K=E(G,z.TextSize,o.Font)
z.Size=UDim2.fromOffset(K.X+10,K.Y+10)
z.Text=G
tooltipMoved(I,J)
end)
H[2]=F.MouseMoved:Connect(tooltipMoved)
H[3]=F.MouseLeave:Connect(function()
z.Visible=false
end)
F.Destroying:Once(function()
for I,J in H do
pcall(function()
J:Disconnect()
end)
H[I]=nil
end
end)
end
d.addTooltip=addTooltip

local function checkKeybinds(F,G,H)
if type(G)=="table"then
if table.find(G,H)then
for I,J in G do
if not table.find(F,J)then
return false
end
end
return true
end
end

return false
end



















local function createMobileButton(F,G)
local H=false
local I=Instance.new"TextButton"
I.Size=UDim2.fromOffset(40,40)
I.Position=UDim2.fromOffset(G.X,G.Y)
I.AnchorPoint=Vector2.new(0.5,0.5)
I.BackgroundColor3=F.Enabled and Color3.new(0,0.7,0)or Color3.new()
I.BackgroundTransparency=0.5
I.Text=F.Name
I.TextColor3=Color3.new(1,1,1)
I.TextScaled=true
I.Font=Enum.Font.Gotham
I.Parent=d.gui
local J=Instance.new"UITextSizeConstraint"
J.MaxTextSize=16
J.Parent=I
addCorner(I,UDim.new(1,0))

I.MouseButton1Down:Connect(function()
H=true
local K,L=tick(),h:GetMouseLocation()
repeat
H=(h:GetMouseLocation()-L).Magnitude<6
task.wait()
until(tick()-K)>1 or not H
if H then
F.Bind={}
I:Destroy()
end
end)
I.MouseButton1Up:Connect(function()
H=false
end)
I.Activated:Connect(function()
F:Toggle()
I.BackgroundColor3=F.Enabled and Color3.new(0,0.7,0)or Color3.new()
end)

F.Bind={Button=I}
end

d.http_function=function(F)
if F==nil then
return
end
F=tostring(F)
local G,H=pcall(function()
return{game:HttpGet(F)}
end)
if not(G~=nil and G==true and H~=nil and type(H)=="table")then
return
end
if H[1]~=nil and H[1]==game then
return H[4]
else
return H[1]
end
end



























local F=function(F,G,H)
local I,J
task.spawn(function()
I,J=pcall(function()
return F()
end)
end)
G=G or 5
local K=tick()
repeat task.wait()until I~=nil or tick()-K>=G
if I==nil then
I=false
J="TIMEOUT_EXCEEDED"
end
if not I and shared.VoidDev then
warn(debug.traceback(J))
end
if H~=nil then
return H(I,J)
end
return I,J
end

local G=shared.CACHED_ICON_LIBRARY
if not G then
F(function()
local H,I=pcall(function()
local H=loadstring(d.http_function"https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua")()
H.SetIconsType"lucide"
return H
end)
if not H then
pcall(function()
d:CreateNotification("Vape | Icons","Failure loading custom icons :c",5,'alert')
end)
warn(`[Icons Failure]: {tostring(G)}`)
end
G=H and I or nil
shared.CACHED_ICON_LIBRARY=G
end,3)
end
local function getCustomIcon(H)
if not G then return false end
local I,J=pcall(function()
return G.GetIcon(H)
end)
if not I then
warn(`[getCustomIcon Failure]: {tostring(H)} -> {tostring(J)}`)
end
return I and J~=nil and J or false
end

u=function(H,I)
if I then
local J=getCustomIcon(H)
if J~=false then
return J
else
return''
end
end
return C[H]or getCustomIcon(H)or select(2,pcall(t,H))or''
end

local function makeDraggable(H,I)
H.InputBegan:Connect(function(J)
if I and not I.Visible then
return
end
if
(
J.UserInputType==Enum.UserInputType.MouseButton1
or J.UserInputType==Enum.UserInputType.Touch
)and(J.Position.Y-H.AbsolutePosition.Y<40 or I)
then
local K=Vector2.new(
H.AbsolutePosition.X-J.Position.X,
H.AbsolutePosition.Y-J.Position.Y+j:GetGuiInset().Y
)/A.Scale

local L=h.InputChanged:Connect(function(L)
if
L.UserInputType
==(
J.UserInputType==Enum.UserInputType.MouseButton1
and Enum.UserInputType.MouseMovement
or Enum.UserInputType.Touch
)
then
local M=L.Position
if h:IsKeyDown(Enum.KeyCode.LeftShift)then
K=(K//3)*3
M=(M//3)*3
end
H.AnchorPoint=Vector2.new(0,0)
H.Position=UDim2.fromOffset(
(M.X/A.Scale)+K.X,
(M.Y/A.Scale)+K.Y
)
end
end)

local M
M=J.Changed:Connect(function()
if J.UserInputState==Enum.UserInputState.End then
if L then
L:Disconnect()
end
if M then
M:Disconnect()
end
end
end)
end
end)
end

local function makeDraggable2(H,I)
H.InputBegan:Connect(function(J)
if not I.Visible then
return
end

if
J.UserInputType==Enum.UserInputType.MouseButton1
or J.UserInputType==Enum.UserInputType.Touch
then

local K=J.Position
local L=I.Position

local M
M=h.InputChanged:Connect(function(N)
if
N.UserInputType==Enum.UserInputType.MouseMovement
or N.UserInputType==Enum.UserInputType.Touch
then

local O=N.Position-K

I.Position=UDim2.fromOffset(L.X.Offset+O.X,L.Y.Offset+O.Y)
end
end)

J.Changed:Connect(function()
if J.UserInputState==Enum.UserInputState.End then
if M then
M:Disconnect()
end
end
end)
end
end)
end

local function setupGuiMoveCheck(H,I)
local J=false
local K
H.InputBegan:Connect(function()
J=true
K=I.Position.X.Offset
end)
H.InputEnded:Connect(function()
J=false

end)
return function()
return K==nil or I.Position.X.Offset-K<2.1
end
end

















































local function randomString()
local H={}
for I=1,math.random(10,100)do
H[I]=string.char(math.random(32,126))
end
return table.concat(H)
end

local function removeTags(H)
H=H:gsub("<br%s*/>","\n")
return H:gsub("<[^<>]->","")
end

do
local H=D"vape/profiles/color.txt"and loadJson"vape/profiles/color.txt"
if H then
o.Main=H.Main and Color3.fromRGB(unpack(H.Main))or o.Main
o.Text=H.Text and Color3.fromRGB(unpack(H.Text))or o.Text
o.Font=H.Font
and Font.new(
H.Font:find"rbxasset"and H.Font
or string.format("rbxasset://fonts/families/%s.json",H.Font)
)
or o.Font
o.FontSemiBold=Font.new(o.Font.Family,Enum.FontWeight.SemiBold)
end
p.Font=o.Font
end

do
function m.Dark(H,I)
local J,K,L=H:ToHSV()
return Color3.fromHSV(J,K,math.clamp(select(3,o.Main:ToHSV())>0.5 and L+I or L-I,0,1))
end

function m.Light(H,I)
local J,K,L=H:ToHSV()
return Color3.fromHSV(J,K,math.clamp(select(3,o.Main:ToHSV())>0.5 and L-I or L+I,0,1))
end

function d.Color(H,I)
local J=0.75+(0.15*math.min(I/0.03,1))
if I>0.57 then
J=0.9-(0.4*math.min((I-0.57)/0.09,1))
end
if I>0.66 then
J=0.5+(0.4*math.min((I-0.66)/0.16,1))
end
if I>0.87 then
J=0.9-(0.15*math.min((I-0.87)/0.13,1))
end
return I,J,1
end

function d.TextColor(H,I,J,K)
if K>=0.7 and(J<0.6 or I>0.04 and I<0.56)then
return Color3.new(0.19,0.19,0.19)
end
return Color3.new(1,1,1)
end
end

do
function n.Tween(H,I,J,K,L,M,N)
if type(L)=="boolean"then
M=L
L=nil
end
if type(J)=="table"then
K=J
J=TweenInfo.new(0.15)
end

L=L or H.tweens

if L[I]then
L[I]:Cancel()
L[I]=nil
end

if I.Parent then
local O=g:Create(I,J,K)
L[I]=O

O.Completed:Once(function()
L[I]=nil

if not N then
pcall(function()
for P,Q in pairs(K)do
I[P]=Q
end
end)
end
end)

if not M then
O:Play()
end

return O
else
for O,P in pairs(K)do
I[O]=P
end
end
end
n.tween=n.Tween

function n.Cancel(H,I)
if H.tweens[I]then
H.tweens[I]:Cancel()
H.tweens[I]=nil
end
end
n.cancel=n.Cancel
end

d.Libraries={
color=m,
getcustomasset=u,
getfontsize=E,
tween=n,
uipallet=o,
}

local H
H={
Button=function(I,J,K)
local L={
Name=I.Name,
Visible=I.Visible==nil or I.Visible
}
local M=Instance.new"TextButton"
M.Name=I.Name.."Button"
M.Size=UDim2.new(1,0,0,31)
M.BackgroundColor3=m.Dark(J.BackgroundColor3,I.Darker and 0.02 or 0)
M.BackgroundTransparency=I.BackgroundTransparency or 0
M.BorderSizePixel=0
M.AutoButtonColor=false
M.Visible=L.Visible
M.Text=""
M.Parent=J
M:GetPropertyChangedSignal"Visible":Connect(function()
L.Visible=M.Visible
end)
addTooltip(M,I.Tooltip)
local N=Instance.new"Frame"
N.Size=UDim2.fromOffset(200,27)
N.Position=UDim2.fromOffset(10,2)
N.BackgroundColor3=m.Light(o.Main,0.05)
N.Parent=M
addCorner(N)
local O=Instance.new"TextLabel"
O.Size=UDim2.new(1,-4,1,-4)
O.Position=UDim2.fromOffset(2,2)
O.BackgroundColor3=o.Main
O.Text=I.Name
O.TextColor3=m.Dark(o.Text,0.16)
O.TextSize=14
O.FontFace=o.Font
O.Parent=N
addCorner(O,UDim.new(0,4))
I.Function=I.Function and wrap(I.Function)or function()end

function L.SetVisible(P,Q)
if Q==nil then
Q=not L.Visible
end
M.Visible=Q
end

M.MouseEnter:Connect(function()
n:Tween(N,o.Tween,{
BackgroundColor3=m.Light(o.Main,0.3),
})
end)
M.MouseLeave:Connect(function()
n:Tween(N,o.Tween,{
BackgroundColor3=m.Light(o.Main,0.05),
})
end)
M.Activated:Connect(I.Function)
L.Object=M
L.Label=O
return L
end,
ColorSlider=function(I,J,K)
if I.Color then
I.DefaultHue,I.DefaultSat,I.DefaultValue=I.Color:ToHSV()
end
local L={
Type="ColorSlider",
Hue=I.DefaultHue or 0.44,
Sat=I.DefaultSat or 1,
Value=I.DefaultValue or 1,
Opacity=I.DefaultOpacity or 1,
Rainbow=false,
Index=0,
}

local function createSlider(M,N)
local O=Instance.new"TextButton"
O.Name=I.Name.."Slider"..M
O.Size=UDim2.new(1,0,0,50)
O.BackgroundColor3=m.Dark(J.BackgroundColor3,I.Darker and 0.02 or 0)
O.BorderSizePixel=0
O.AutoButtonColor=false
O.Visible=false
O.Text=""
O.Parent=J
local P=Instance.new"TextLabel"
P.Name="Title"
P.Size=UDim2.fromOffset(60,30)
P.Position=UDim2.fromOffset(10,2)
P.BackgroundTransparency=1
P.Text=M
P.TextXAlignment=Enum.TextXAlignment.Left
P.TextColor3=m.Dark(o.Text,0.16)
P.TextSize=11
P.FontFace=o.Font
P.Parent=O
local Q=Instance.new"Frame"
Q.Name="Slider"
Q.Size=UDim2.new(1,-20,0,2)
Q.Position=UDim2.fromOffset(10,37)
Q.BackgroundColor3=Color3.new(1,1,1)
Q.BorderSizePixel=0
Q.Parent=O
local R=Instance.new"UIGradient"
R.Color=N
R.Parent=Q
local S=Q:Clone()
S.Name="Fill"
S.Size=UDim2.fromScale(
math.clamp(
M=="Saturation"and L.Sat
or M=="Vibrance"and L.Value
or L.Opacity,
0.04,
0.96
),
1
)
S.Position=UDim2.new()
S.BackgroundTransparency=1
S.Parent=Q
local T=Instance.new"Frame"
T.Name="Knob"
T.Size=UDim2.fromOffset(24,4)
T.Position=UDim2.fromScale(1,0.5)
T.AnchorPoint=Vector2.new(0.5,0.5)
T.BackgroundColor3=O.BackgroundColor3
T.BorderSizePixel=0
T.Parent=S
local U=Instance.new"Frame"
U.Name="Knob"
U.Size=UDim2.fromOffset(14,14)
U.Position=UDim2.fromScale(0.5,0.5)
U.AnchorPoint=Vector2.new(0.5,0.5)
U.BackgroundColor3=o.Text
U.Parent=T
addCorner(U,UDim.new(1,0))

O.InputBegan:Connect(function(V)
if
(
V.UserInputType==Enum.UserInputType.MouseButton1
or V.UserInputType==Enum.UserInputType.Touch
)and(V.Position.Y-O.AbsolutePosition.Y)>(20*A.Scale)
then
local W=h.InputChanged:Connect(function(W)
if
W.UserInputType
==(
V.UserInputType==Enum.UserInputType.MouseButton1
and Enum.UserInputType.MouseMovement
or Enum.UserInputType.Touch
)
then
L:SetValue(
nil,
M=="Saturation"
and math.clamp(
(W.Position.X-Q.AbsolutePosition.X)/Q.AbsoluteSize.X,
0,
1
)
or nil,
M=="Vibrance"
and math.clamp(
(W.Position.X-Q.AbsolutePosition.X)/Q.AbsoluteSize.X,
0,
1
)
or nil,
M=="Opacity"
and math.clamp(
(W.Position.X-Q.AbsolutePosition.X)/Q.AbsoluteSize.X,
0,
1
)
or nil
)
if L._InternalCallback then
L._InternalCallback()
end
end
end)

local X
X=V.Changed:Connect(function()
if V.UserInputState==Enum.UserInputState.End then
if W then
W:Disconnect()
end
if X then
X:Disconnect()
end
end
end)
end
end)
O.MouseEnter:Connect(function()
n:Tween(U,o.Tween,{
Size=UDim2.fromOffset(16,16),
})
end)
O.MouseLeave:Connect(function()
n:Tween(U,o.Tween,{
Size=UDim2.fromOffset(14,14),
})
end)

return O
end

local M=Instance.new"TextButton"
M.Name=I.Name.."Slider"
M.Size=UDim2.new(1,0,0,50)
M.BackgroundColor3=m.Dark(J.BackgroundColor3,I.Darker and 0.02 or 0)
M.BorderSizePixel=0
M.AutoButtonColor=false
M.Visible=I.Visible==nil or I.Visible
M.Text=""
M.Parent=J
addTooltip(M,I.Tooltip)
local N=Instance.new"TextLabel"
N.Name="Title"
N.Size=UDim2.fromOffset(60,30)
N.Position=UDim2.fromOffset(10,2)
N.BackgroundTransparency=1
N.Text=I.Name
N.TextXAlignment=Enum.TextXAlignment.Left
N.TextColor3=m.Dark(o.Text,0.16)
N.TextSize=11
N.FontFace=o.Font
N.Parent=M
local O=Instance.new"TextBox"
O.Name="Box"
O.Size=UDim2.fromOffset(60,15)
O.Position=UDim2.new(1,-69,0,9)
O.BackgroundTransparency=1
O.Visible=false
O.Text=""
O.TextXAlignment=Enum.TextXAlignment.Right
O.TextColor3=m.Dark(o.Text,0.16)
O.TextSize=11
O.FontFace=o.Font
O.ClearTextOnFocus=true
O.Parent=M
local P=Instance.new"Frame"
P.Name="Slider"
P.Size=UDim2.new(1,-20,0,2)
P.Position=UDim2.fromOffset(10,39)
P.BackgroundColor3=Color3.new(1,1,1)
P.BorderSizePixel=0
P.Parent=M
local Q={}
for R=0,1,0.1 do
table.insert(Q,ColorSequenceKeypoint.new(R,Color3.fromHSV(R,1,1)))
end
local R=Instance.new"UIGradient"
R.Color=ColorSequence.new(Q)
R.Parent=P
local S=P:Clone()
S.Name="Fill"
S.Size=UDim2.fromScale(math.clamp(L.Hue,0.04,0.96),1)
S.Position=UDim2.new()
S.BackgroundTransparency=1
S.Parent=P
local T=Instance.new"ImageButton"
T.Name="Preview"
T.Size=UDim2.fromOffset(12,12)
T.Position=UDim2.new(1,-22,0,10)
T.BackgroundTransparency=1
T.Image=u"vape/assets/new/colorpreview.png"
T.ImageColor3=Color3.fromHSV(L.Hue,L.Sat,L.Value)
T.ImageTransparency=1-L.Opacity
T.Parent=M
local U=Instance.new"TextButton"
U.Name="Expand"
U.Size=UDim2.fromOffset(17,13)
U.Position=UDim2.new(
0,
i:GetTextSize(N.Text,N.TextSize,N.Font,Vector2.new(1000,1000)).X+11,
0,
7
)
U.BackgroundTransparency=1
U.Text=""
U.Parent=M
local V=Instance.new"ImageLabel"
V.Name="Expand"
V.Size=UDim2.fromOffset(9,5)
V.Position=UDim2.fromOffset(4,4)
V.BackgroundTransparency=1
V.Image=u"vape/assets/new/expandicon.png"
V.ImageColor3=m.Dark(o.Text,0.43)
V.Parent=U
local W=Instance.new"TextButton"
W.Name="Rainbow"
W.Size=UDim2.fromOffset(12,12)
W.Position=UDim2.new(1,-42,0,10)
W.BackgroundTransparency=1
W.Text=""
W.Parent=M
local X=Instance.new"ImageLabel"
X.Size=UDim2.fromOffset(12,12)
X.BackgroundTransparency=1
X.Image=u"vape/assets/new/rainbow_1.png"
X.ImageColor3=m.Light(o.Main,0.37)
X.Parent=W
local Y=X:Clone()
Y.Image=u"vape/assets/new/rainbow_2.png"
Y.Parent=W
local Z=X:Clone()
Z.Image=u"vape/assets/new/rainbow_3.png"
Z.Parent=W
local _=X:Clone()
_.Image=u"vape/assets/new/rainbow_4.png"
_.Parent=W
local aa=Instance.new"Frame"
aa.Name="Knob"
aa.Size=UDim2.fromOffset(24,4)
aa.Position=UDim2.fromScale(1,0.5)
aa.AnchorPoint=Vector2.new(0.5,0.5)
aa.BackgroundColor3=M.BackgroundColor3
aa.BorderSizePixel=0
aa.Parent=S
local ab=Instance.new"Frame"
ab.Name="Knob"
ab.Size=UDim2.fromOffset(14,14)
ab.Position=UDim2.fromScale(0.5,0.5)
ab.AnchorPoint=Vector2.new(0.5,0.5)
ab.BackgroundColor3=o.Text
ab.Parent=aa
addCorner(ab,UDim.new(1,0))
I.Function=I.Function or function()end

if K.OptionsVisibilityChanged~=nil then
K.OptionsVisibilityChanged:Connect(function(ac)
if ac==nil then
ac=J.Visible
end
n:Tween(ab,TweenInfo.new(0.1,Enum.EasingStyle.Quad),{
Size=ac and UDim2.fromOffset(14,14)or UDim2.fromOffset(0,0)
})
end)
end

local ac=createSlider(
"Saturation",
ColorSequence.new{
ColorSequenceKeypoint.new(0,Color3.fromHSV(0,0,L.Value)),
ColorSequenceKeypoint.new(1,Color3.fromHSV(L.Hue,1,L.Value)),
}
)
local ad=createSlider(
"Vibrance",
ColorSequence.new{
ColorSequenceKeypoint.new(0,Color3.fromHSV(0,0,0)),
ColorSequenceKeypoint.new(1,Color3.fromHSV(L.Hue,L.Sat,1)),
}
)
local ae=createSlider(
"Opacity",
ColorSequence.new{
ColorSequenceKeypoint.new(0,m.Dark(o.Main,0.02)),
ColorSequenceKeypoint.new(1,Color3.fromHSV(L.Hue,L.Sat,L.Value)),
}
)

function L.Save(af,ag)
ag[I.Name]={
Hue=af.Hue,
Sat=af.Sat,
Value=af.Value,
Opacity=af.Opacity,
Rainbow=af.Rainbow,
}
end

function L.Load(af,ag)
if ag.Rainbow~=af.Rainbow then
af:Toggle()
end
if af.Hue~=ag.Hue or af.Sat~=ag.Sat or af.Value~=ag.Value or af.Opacity~=ag.Opacity then
af:SetValue(ag.Hue,ag.Sat,ag.Value,ag.Opacity,false)
end
end

function L.ConnectCallback(af,ag)
if not(ag~=nil and type(ag)=="function")then return end
if L._InternalCallback and shared.VoidDev then
warn(debug.traceback(`Overriding InternalCallback!!!`))
end
L._InternalCallback=wrap(ag)
end

function L.SetValue(af,ag,ah,ai,aj)
af.Hue=ag or af.Hue
af.Sat=ah or af.Sat
af.Value=ai or af.Value
af.Opacity=aj or af.Opacity
T.ImageColor3=Color3.fromHSV(af.Hue,af.Sat,af.Value)
T.ImageTransparency=1-af.Opacity
ac.Slider.UIGradient.Color=ColorSequence.new{
ColorSequenceKeypoint.new(0,Color3.fromHSV(0,0,af.Value)),
ColorSequenceKeypoint.new(1,Color3.fromHSV(af.Hue,1,af.Value)),
}
ad.Slider.UIGradient.Color=ColorSequence.new{
ColorSequenceKeypoint.new(0,Color3.fromHSV(0,0,0)),
ColorSequenceKeypoint.new(1,Color3.fromHSV(af.Hue,af.Sat,1)),
}
ae.Slider.UIGradient.Color=ColorSequence.new{
ColorSequenceKeypoint.new(0,m.Dark(o.Main,0.02)),
ColorSequenceKeypoint.new(1,Color3.fromHSV(af.Hue,af.Sat,af.Value)),
}

if af.Rainbow then
S.Size=UDim2.fromScale(math.clamp(af.Hue,0.04,0.96),1)
else
n:Tween(S,o.Tween,{
Size=UDim2.fromScale(math.clamp(af.Hue,0.04,0.96),1),
})
end

if ah then
n:Tween(ac.Slider.Fill,o.Tween,{
Size=UDim2.fromScale(math.clamp(af.Sat,0.04,0.96),1),
})
end
if ai then
n:Tween(ad.Slider.Fill,o.Tween,{
Size=UDim2.fromScale(math.clamp(af.Value,0.04,0.96),1),
})
end
if aj then
n:Tween(ae.Slider.Fill,o.Tween,{
Size=UDim2.fromScale(math.clamp(af.Opacity,0.04,0.96),1),
})
end

I.Function(af.Hue,af.Sat,af.Value,af.Opacity)
end

function L.ToColor(af)
return Color3.fromHSV(af.Hue,af.Sat,af.Value)
end

function L.Toggle(af)
af.Rainbow=not af.Rainbow
if af.Rainbow then
table.insert(d.RainbowTable,af)
X.ImageColor3=Color3.fromRGB(5,127,100)
task.delay(0.1,function()
if not af.Rainbow then
return
end
Y.ImageColor3=Color3.fromRGB(228,125,43)
task.delay(0.1,function()
if not af.Rainbow then
return
end
Z.ImageColor3=Color3.fromRGB(225,46,52)
end)
end)
else
local ag=table.find(d.RainbowTable,af)
if ag then
table.remove(d.RainbowTable,ag)
end
Z.ImageColor3=m.Light(o.Main,0.37)
task.delay(0.1,function()
if af.Rainbow then
return
end
Y.ImageColor3=m.Light(o.Main,0.37)
task.delay(0.1,function()
if af.Rainbow then
return
end
X.ImageColor3=m.Light(o.Main,0.37)
end)
end)
end
end

local af=tick()
T.Activated:Connect(function()
T.Visible=false
O.Visible=true
O:CaptureFocus()
local ag=Color3.fromHSV(L.Hue,L.Sat,L.Value)
O.Text=math.round(ag.R*255)
..", "
..math.round(ag.G*255)
..", "
..math.round(ag.B*255)
end)
M.InputBegan:Connect(function(ag)
if
(
ag.UserInputType==Enum.UserInputType.MouseButton1
or ag.UserInputType==Enum.UserInputType.Touch
)and(ag.Position.Y-M.AbsolutePosition.Y)>(20*A.Scale)
then
if af>tick()then
L:Toggle()
end
af=tick()+0.3
local ah=h.InputChanged:Connect(function(ah)
if
ah.UserInputType
==(
ag.UserInputType==Enum.UserInputType.MouseButton1
and Enum.UserInputType.MouseMovement
or Enum.UserInputType.Touch
)
then
L:SetValue(
math.clamp((ah.Position.X-P.AbsolutePosition.X)/P.AbsoluteSize.X,0,1),
nil,nil,nil,true
)
if L._InternalCallback then
L._InternalCallback()
end
end
end)

local ai
ai=ag.Changed:Connect(function()
if ag.UserInputState==Enum.UserInputState.End then
if ah then
ah:Disconnect()
end
if ai then
ai:Disconnect()
end
end
end)
end
end)
M.MouseEnter:Connect(function()
n:Tween(ab,o.Tween,{
Size=UDim2.fromOffset(16,16),
})
end)
M.MouseLeave:Connect(function()
n:Tween(ab,o.Tween,{
Size=UDim2.fromOffset(14,14),
})
end)
M:GetPropertyChangedSignal"Visible":Connect(function()
ac.Visible=V.Rotation==180 and M.Visible
ad.Visible=ac.Visible
ae.Visible=ac.Visible
end)
U.MouseEnter:Connect(function()
V.ImageColor3=m.Dark(o.Text,0.16)
end)
U.MouseLeave:Connect(function()
V.ImageColor3=m.Dark(o.Text,0.43)
end)
U.Activated:Connect(function()
ac.Visible=not ac.Visible
ad.Visible=ac.Visible
ae.Visible=ac.Visible
V.Rotation=ac.Visible and 180 or 0
end)
W.Activated:Connect(function()
L:Toggle()
end)
O.FocusLost:Connect(function(ag)
T.Visible=true
O.Visible=false
if ag then
local ah=O.Text:split","
local ai,aj=pcall(function()
return tonumber(ah[1])
and Color3.fromRGB(tonumber(ah[1]),tonumber(ah[2]),tonumber(ah[3]))
or Color3.fromHex(O.Text)
end)
if ai then
if L.Rainbow then
L:Toggle()
end
L:SetValue(aj:ToHSV())
if L._InternalCallback then
L._InternalCallback()
end
end
end
end)

L.Object=M
K.Options[I.Name]=L

return L
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
af.BackgroundColor3=m.Dark(ab.BackgroundColor3,aa.Darker and 0.02 or 0)
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
ag.BackgroundColor3=m.Light(o.Main,0.034)
ag.Parent=af
addCorner(ag,UDim.new(0,6))
local ah=Instance.new"UIStroke"
ah.Name="GlowStroke"
ah.Thickness=2
ah.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
ah.Color=m.Light(o.Main,0.35)
ah.Transparency=1
ah.Parent=ag
local ai=Instance.new"TextButton"
ai.Name="Dropdown"
ai.Size=UDim2.new(1,-2,1,-2)
ai.Position=UDim2.fromOffset(1,1)
ai.BackgroundColor3=o.Main
ai.AutoButtonColor=false
ai.Text=""
ai.Parent=ag
local aj=Instance.new"TextLabel"
aj.Name="Title"
aj.Size=UDim2.new(1,0,0,29)
aj.BackgroundTransparency=1
aj.Text="         "..aa.Name.." - "..ae.Value
aj.TextXAlignment=Enum.TextXAlignment.Left
aj.TextColor3=m.Dark(o.Text,0.16)
aj.TextSize=13
aj.TextTruncate=Enum.TextTruncate.AtEnd
aj.FontFace=o.Font
aj.Parent=ai
addCorner(ai,UDim.new(0,6))
local I=Instance.new"ImageLabel"
I.Name="Arrow"
I.Size=UDim2.fromOffset(4,8)
I.Position=UDim2.new(1,-17,0,11)
I.BackgroundTransparency=1
I.Image=u"vape/assets/new/expandright.png"
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
aj.Text="         "..aa.Name.." - "..L.Value
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
N.BackgroundColor3=m.Light(o.Main,0.02)
N.PlaceholderText=" Search..."
N.Text=""
N.TextColor3=o.Text
N.TextSize=13
N.FontFace=o.Font
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
P.FontFace=o.Font
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
U.BackgroundColor3=o.Main
U.BorderSizePixel=0
U.AutoButtonColor=false
U.Text="   "..T
U.TextColor3=o.Text
U.TextXAlignment=Enum.TextXAlignment.Left
U.TextSize=13
U.FontFace=o.Font
U.Parent=M
addTooltip(U,T)

U.MouseEnter:Connect(function()
n:Tween(U,o.Tween,{
BackgroundColor3=m.Light(o.Main,0.04),
})
end)
U.MouseLeave:Connect(function()
n:Tween(U,o.Tween,{
BackgroundColor3=o.Main,
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
n:Tween(ag,o.Tween,{
BackgroundColor3=m.Light(o.Main,0.0875),
})
n:Tween(ah,o.Tween,{
Transparency=0.15,
})
end)
af.MouseLeave:Connect(function()
n:Tween(ag,o.Tween,{
BackgroundColor3=m.Light(o.Main,0.034),
})
n:Tween(ah,o.Tween,{
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

af=H.Dropdown({
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
ag=H.TextBox({
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
ae.BackgroundColor3=m.Dark(ab.BackgroundColor3,aa.Darker and 0.02 or 0)
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
af.TextColor3=m.Dark(o.Text,0.16)
af.TextSize=11
af.FontFace=o.Font
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
ag.TextColor3=m.Dark(o.Text,0.16)
ag.TextSize=11
ag.FontFace=o.Font
ag.Parent=ae
local ah=Instance.new"TextBox"
ah.Name="Box"
ah.Size=ag.Size
ah.Position=ag.Position
ah.BackgroundTransparency=1
ah.Visible=false
ah.Text=ad.Value
ah.TextXAlignment=Enum.TextXAlignment.Right
ah.TextColor3=m.Dark(o.Text,0.16)
ah.TextSize=11
ah.FontFace=o.Font
ah.ClearTextOnFocus=false
ah.Parent=ae
local ai=Instance.new"Frame"
ai.Name="Slider"
ai.Size=UDim2.new(1,-20,0,2)
ai.Position=UDim2.fromOffset(10,37)
ai.BackgroundColor3=m.Light(o.Main,0.034)
ai.BorderSizePixel=0
ai.Parent=ae
local aj=ai:Clone()
aj.Name="Fill"
aj.Size=
UDim2.fromScale(math.clamp((ad.Value-aa.Min)/aa.Max,0.04,0.96),1)
aj.Position=UDim2.new()
aj.BackgroundColor3=Color3.fromHSV(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
aj.Parent=ai
local I=Instance.new"Frame"
I.Name="Knob"
I.Size=UDim2.fromOffset(24,4)
I.Position=UDim2.fromScale(1,0.5)
I.AnchorPoint=Vector2.new(0.5,0.5)
I.BackgroundColor3=ae.BackgroundColor3
I.BorderSizePixel=0
I.Parent=aj
local J=Instance.new"Frame"
J.Name="Knob"
J.Size=UDim2.fromOffset(14,14)
J.Position=UDim2.fromScale(0.5,0.5)
J.AnchorPoint=Vector2.new(0.5,0.5)
J.BackgroundColor3=Color3.fromHSV(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
J.Parent=I
addCorner(J,UDim.new(1,0))
aa.Function=aa.Function or function()end
aa.Decimal=aa.Decimal or 1

if ac.OptionsVisibilityChanged~=nil then
ac.OptionsVisibilityChanged:Connect(function(K)
if K==nil then
K=ab.Visible
end
n:Tween(J,TweenInfo.new(0.1,Enum.EasingStyle.Quad),{
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
aj.BackgroundColor3=O and Color3.fromHSV(d:Color((L-(K.Index*0.075))%1))
or Color3.fromHSV(L,M,N)
J.BackgroundColor3=aj.BackgroundColor3
end

function ad.SetValue(K,L,M,N)
if tonumber(L)==math.huge or L~=L then
return
end
local O=K.Value~=L
K.Value=L
n:Tween(aj,o.Tween,{
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
)and(K.Position.Y-ae.AbsolutePosition.Y)>(20*A.Scale)
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

local O=h.InputChanged:Connect(function(O)
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
n:Tween(J,o.Tween,{
Size=UDim2.fromOffset(16,16),
})
end)
ae.MouseLeave:Connect(function()
n:Tween(J,o.Tween,{
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
ae.BackgroundColor3=m.Dark(ab.BackgroundColor3,aa.Darker and 0.02 or 0)
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
af.BackgroundColor3=m.Light(o.Main,0.034)
af.Parent=ae
addCorner(af,UDim.new(0,4))
local ag=Instance.new"TextButton"
ag.Name="TextList"
ag.Size=UDim2.new(1,-2,1,-2)
ag.Position=UDim2.fromOffset(1,1)
ag.BackgroundColor3=o.Main
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
ah.TextColor3=m.Dark(o.Text,0.16)
ah.TextSize=15
ah.TextTruncate=Enum.TextTruncate.AtEnd
ah.FontFace=o.Font
ah.Parent=ag
local ai=ah:Clone()
ai.Name="Items"
ai.Position=UDim2.fromOffset(5,21)
ai.Text="Ignore none"
ai.TextColor3=m.Dark(o.Text,0.16)
ai.TextSize=11
ai.Parent=ag
addCorner(ag,UDim.new(0,4))
local aj=Instance.new"Frame"
aj.Size=UDim2.fromOffset(65,12)
aj.Position=UDim2.fromOffset(52,8)
aj.BackgroundTransparency=1
aj.Parent=ag
local I=Instance.new"UIListLayout"
I.FillDirection=Enum.FillDirection.Horizontal
I.Padding=UDim.new(0,6)
I.Parent=aj
local J=Instance.new"TextButton"
J.Name="TargetsTextWindow"
J.Size=UDim2.fromOffset(220,145)
J.BackgroundColor3=o.Main
J.BorderSizePixel=0
J.AutoButtonColor=false
J.Visible=false
J.Text=""
J.Parent=v
ad.Window=J
addBlur(J)
addCorner(J)
local K=Instance.new"ImageLabel"
K.Name="Icon"
K.Size=UDim2.fromOffset(18,12)
K.Position=UDim2.fromOffset(10,15)
K.BackgroundTransparency=1
K.Image=u"vape/assets/new/targetstab.png"
K.Parent=J
local L=Instance.new"TextLabel"
L.Name="Title"
L.Size=UDim2.new(1,-36,0,20)
L.Position=UDim2.fromOffset(math.abs(L.Size.X.Offset),11)
L.BackgroundTransparency=1
L.Text="Target settings"
L.TextXAlignment=Enum.TextXAlignment.Left
L.TextColor3=o.Text
L.TextSize=13
L.FontFace=o.Font
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
af.BackgroundColor3=R and Color3.fromHSV(d:Color((O-(N.Index*0.075))%1))
or Color3.fromHSV(O,P,Q)
if N.Players.Enabled then
n:Cancel(N.Players.Object.Frame)
N.Players.Object.Frame.BackgroundColor3=Color3.fromHSV(O,P,Q)
end
if N.NPCs.Enabled then
n:Cancel(N.NPCs.Object.Frame)
N.NPCs.Object.Frame.BackgroundColor3=Color3.fromHSV(O,P,Q)
end
if N.Invisible.Enabled then
n:Cancel(N.Invisible.Object.Knob)
N.Invisible.Object.Knob.BackgroundColor3=Color3.fromHSV(O,P,Q)
end
if N.Walls.Enabled then
n:Cancel(N.Walls.Object.Knob)
N.Walls.Object.Knob.BackgroundColor3=Color3.fromHSV(O,P,Q)
end
end

ad.Players=H.TargetsButton({
Position=UDim2.fromOffset(11,45),
Icon=u"vape/assets/new/targetplayers1.png",
IconSize=UDim2.fromOffset(15,16),
IconParent=aj,
ToolIcon=u"vape/assets/new/targetplayers2.png",
ToolSize=UDim2.fromOffset(11,12),
Tooltip="Players",
Function=aa.Function,
},J,aj)
ad.NPCs=H.TargetsButton({
Position=UDim2.fromOffset(112,45),
Icon=u"vape/assets/new/targetnpc1.png",
IconSize=UDim2.fromOffset(12,16),
IconParent=aj,
ToolIcon=u"vape/assets/new/targetnpc2.png",
ToolSize=UDim2.fromOffset(9,12),
Tooltip="NPCs",
Function=aa.Function,
},J,aj)
ad.Invisible=H.Toggle({
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
ad.Walls=H.Toggle({
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
n:Cancel(af)
af.BackgroundColor3=J.Visible
and Color3.fromHSV(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
or m.Light(o.Main,0.37)
end)
ae.MouseEnter:Connect(function()
if not ad.Window.Visible then
n:Tween(af,o.Tween,{
BackgroundColor3=m.Light(o.Main,0.37),
})
end
end)
ae.MouseLeave:Connect(function()
if not ad.Window.Visible then
n:Tween(af,o.Tween,{
BackgroundColor3=m.Light(o.Main,0.034),
})
end
end)
ae:GetPropertyChangedSignal"AbsolutePosition":Connect(function()
if d.ThreadFix then
setthreadidentity(8)
end
local N=(ae.AbsolutePosition+Vector2.new(0,60))/A.Scale
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
ae.BackgroundColor3=m.Light(o.Main,0.05)
ae.AutoButtonColor=false
ae.Visible=aa.Visible==nil or aa.Visible
ae.Text=""
ae.Parent=ab
addCorner(ae)
addTooltip(ae,aa.Tooltip)
local af=Instance.new"Frame"
af.Size=UDim2.new(1,-2,1,-2)
af.Position=UDim2.fromOffset(1,1)
af.BackgroundColor3=o.Main
af.Parent=ae
addCorner(af)
local ag=Instance.new"ImageLabel"
ag.Size=aa.IconSize
ag.Position=UDim2.fromScale(0.5,0.5)
ag.AnchorPoint=Vector2.new(0.5,0.5)
ag.BackgroundTransparency=1
ag.Image=aa.Icon
ag.ImageColor3=m.Light(o.Main,0.37)
ag.Parent=af
aa.Function=aa.Function or function()end
local ah

function ad.Toggle(ai)
ai.Enabled=not ai.Enabled
n:Tween(af,o.Tween,{
BackgroundColor3=ai.Enabled
and Color3.fromHSV(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
or o.Main,
})
n:Tween(ag,o.Tween,{
ImageColor3=ai.Enabled and Color3.new(1,1,1)or m.Light(o.Main,0.37),
})
if ah then
ah:Destroy()
end
if ai.Enabled then
ah=Instance.new"ImageLabel"
ah.Size=aa.ToolSize
ah.BackgroundTransparency=1
ah.Image=aa.ToolIcon
ah.ImageColor3=o.Text
ah.Parent=aa.IconParent
end
aa.Function(ai.Enabled)
end

ae.MouseEnter:Connect(function()
if not ad.Enabled then
n:Tween(af,o.Tween,{
BackgroundColor3=Color3.fromHSV(
d.GUIColor.Hue,
d.GUIColor.Sat,
d.GUIColor.Value-0.25
),
})
n:Tween(ag,o.Tween,{
ImageColor3=Color3.new(1,1,1),
})
end
end)
ae.MouseLeave:Connect(function()
if not ad.Enabled then
n:Tween(af,o.Tween,{
BackgroundColor3=o.Main,
})
n:Tween(ag,o.Tween,{
ImageColor3=m.Light(o.Main,0.37),
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
ae.BackgroundColor3=m.Dark(ab.BackgroundColor3,aa.Darker and 0.02 or 0)
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
af.TextColor3=o.Text
af.TextSize=12
af.FontFace=o.Font
af.Parent=ae
local ag=Instance.new"Frame"
ag.Name="BKG"
ag.Size=UDim2.new(1,-20,0,29)
ag.Position=UDim2.fromOffset(10,23)
ag.BackgroundColor3=m.Light(o.Main,0.02)
ag.Parent=ae
addCorner(ag,UDim.new(0,4))
local ah=Instance.new"TextBox"
ah.Size=UDim2.new(1,-8,1,0)
ah.Position=UDim2.fromOffset(8,0)
ah.BackgroundTransparency=1
ah.Text=aa.Default or""
ah.PlaceholderText=aa.Placeholder or"Click to set"
ah.TextXAlignment=Enum.TextXAlignment.Left
ah.TextColor3=m.Dark(o.Text,0.16)
ah.PlaceholderColor3=m.Dark(o.Text,0.31)
ah.TextSize=12
ah.FontFace=o.Font
ah.ClearTextOnFocus=false
ah.Parent=ag
aa.Function=aa.Function or function()end

function ad.Save(ai,aj)
aj[aa.Name]={Value=ai.Value}
end

function ad.Load(ai,aj)
if ai.Value~=aj.Value then
ai:SetValue(aj.Value)
end
end

function ad.SetValue(ai,aj,I)
ai.Value=aj
ah.Text=aj
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
ae.BackgroundColor3=m.Dark(ab.BackgroundColor3,aa.Darker and 0.02 or 0)
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
af.BackgroundColor3=m.Light(o.Main,0.034)
af.Parent=ae
addCorner(af,UDim.new(0,4))
local ag=Instance.new"TextButton"
ag.Name="TextList"
ag.Size=UDim2.new(1,-2,1,-2)
ag.Position=UDim2.fromOffset(1,1)
ag.BackgroundColor3=o.Main
ag.AutoButtonColor=false
ag.Text=""
ag.Parent=af
local ah=Instance.new"ImageLabel"
ah.Name="Icon"
ah.Size=UDim2.fromOffset(14,12)
ah.Position=UDim2.fromOffset(10,14)
ah.BackgroundTransparency=1
ah.Image=aa.Icon or u"vape/assets/new/allowedicon.png"
ah.Parent=ag
local ai=Instance.new"TextLabel"
ai.Name="Title"
ai.Size=UDim2.new(1,-35,0,15)
ai.Position=UDim2.fromOffset(35,6)
ai.BackgroundTransparency=1
ai.Text=aa.Name
ai.TextXAlignment=Enum.TextXAlignment.Left
ai.TextColor3=m.Dark(o.Text,0.16)
ai.TextSize=15
ai.TextTruncate=Enum.TextTruncate.AtEnd
ai.FontFace=o.Font
ai.Parent=ag
local aj=ai:Clone()
aj.Name="Amount"
aj.Size=UDim2.new(1,-13,0,15)
aj.Position=UDim2.fromOffset(0,6)
aj.Text="0"
aj.TextXAlignment=Enum.TextXAlignment.Right
aj.Parent=ag
local I=ai:Clone()
I.Name="Items"
I.Position=UDim2.fromOffset(35,21)
I.Text="None"
I.TextColor3=m.Dark(o.Text,0.43)
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
N.BackgroundColor3=o.Main
N.BorderSizePixel=0
N.AutoButtonColor=false
N.Visible=false
N.Text=""
N.ClipsDescendants=true
N.Parent=ac.Legit and d.Legit.Window or v
ad.Window=N
addBlur(N)
addCorner(N)

local O=Instance.new"ImageLabel"
O.Name="Icon"
O.Size=aa.TabSize or UDim2.fromOffset(19,16)
O.Position=UDim2.fromOffset(10,13)
O.BackgroundTransparency=1
O.Image=aa.Tab or u"vape/assets/new/allowedtab.png"
O.Parent=N
local P=Instance.new"TextLabel"
P.Name="Title"
P.Size=UDim2.new(1,-36,0,20)
P.Position=UDim2.fromOffset(math.abs(P.Size.X.Offset),11)
P.BackgroundTransparency=1
P.Text=aa.Name
P.TextXAlignment=Enum.TextXAlignment.Left
P.TextColor3=o.Text
P.TextSize=13
P.FontFace=o.Font
P.Parent=N
local Q=addCloseButton(N)

local R=Instance.new"Frame"
R.Name="Add"
R.Size=UDim2.fromOffset(200,31)
R.Position=UDim2.fromOffset(10,45)
R.BackgroundColor3=m.Light(o.Main,0.02)
R.Parent=N
addCorner(R)
local S=R:Clone()
S.Size=UDim2.new(1,-2,1,-2)
S.Position=UDim2.fromOffset(1,1)
S.BackgroundColor3=m.Dark(o.Main,0.02)
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
T.FontFace=o.Font
T.ClearTextOnFocus=false
T.Parent=R
local U=Instance.new"ImageButton"
U.Name="AddButton"
U.Size=UDim2.fromOffset(16,16)
U.Position=UDim2.new(1,-26,0,8)
U.BackgroundTransparency=1
U.Image=u"vape/assets/new/add.png"
U.ImageColor3=aa.Color
U.ImageTransparency=0.3
U.Parent=R


local V=Instance.new"Frame"
V.Name="SearchBKG"
V.Size=UDim2.fromOffset(200,31)
V.Position=UDim2.fromOffset(10,82)
V.BackgroundColor3=m.Light(o.Main,0.02)
V.Parent=N
addCorner(V)
local W=V:Clone()
W.Size=UDim2.new(1,-2,1,-2)
W.Position=UDim2.fromOffset(1,1)
W.BackgroundColor3=m.Dark(o.Main,0.02)
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
X.FontFace=o.Font
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
Z.FontFace=o.Font
Z.Visible=false
Z.Parent=Y

aa.Function=aa.Function or function()end

function ad.Save(_,ak)
ak[aa.Name]={
List=_.List,
ListEnabled=_.ListEnabled,
}
end

function ad.Load(ak,_)
ak.List=_.List or{}
ak.ListEnabled=_.ListEnabled or{}
ak:ChangeValue()
end

function ad.Color(ak,_,al,am,an)
if N.Visible then
af.BackgroundColor3=an and Color3.fromHSV(d:Color((_-(ak.Index*0.075))%1))
or Color3.fromHSV(_,al,am)
end
end

local ak=""

function ad.UpdateWindowSize(al,am)
local an=math.min(am,M)*L
local _=119+an

Y.Size=UDim2.fromOffset(200,an)

n:Tween(N,o.Tween,{
Size=UDim2.fromOffset(220,_),
})
end

function ad.FilterItems(al,am)
ak=am:lower()
local an=0

for _,ao in al.Objects do
local ap=ao.Name:lower()
local aq=ak==""or ap:find(ak,1,true)

if aq then
an=an+1
ao.Position=UDim2.fromOffset(0,(an-1)*L)


ao.Visible=true
n:Tween(ao,TweenInfo.new(0.15),{
BackgroundTransparency=0,
})
for ar,as in ao:GetDescendants()do
if as:IsA"TextLabel"then
n:Tween(as,TweenInfo.new(0.15),{
TextTransparency=0,
})
elseif as:IsA"ImageButton"or as:IsA"ImageLabel"then
n:Tween(as,TweenInfo.new(0.15),{
ImageTransparency=as.Name=="AddButton"and 0.3 or 0.5,
})
elseif as:IsA"Frame"and as.Name~="BKG"then
n:Tween(as,TweenInfo.new(0.15),{
BackgroundTransparency=0,
})
end
end
else

n:Tween(ao,TweenInfo.new(0.15),{
BackgroundTransparency=1,
})
for ar,as in ao:GetDescendants()do
if as:IsA"TextLabel"then
n:Tween(as,TweenInfo.new(0.15),{
TextTransparency=1,
})
elseif as:IsA"ImageButton"or as:IsA"ImageLabel"then
n:Tween(as,TweenInfo.new(0.15),{
ImageTransparency=1,
})
elseif as:IsA"Frame"then
n:Tween(as,TweenInfo.new(0.15),{
BackgroundTransparency=1,
})
end
end
task.delay(0.15,function()
ao.Visible=false
end)
end
end

Z.Visible=an==0 and#al.List>0
al:UpdateWindowSize(an==0 and 1 or an)
end

function ad.ChangeValue(al,am)
if am then
local an=table.find(al.List,am)
if an then
table.remove(al.List,an)
an=table.find(al.ListEnabled,am)
if an then
table.remove(al.ListEnabled,an)
end
else
table.insert(al.List,am)
table.insert(al.ListEnabled,am)
end
end

aa.Function(al.List)
for an,ao in al.Objects do
ao:Destroy()
end
table.clear(al.Objects)
aj.Text=#al.List

local an="None"
for ao,ap in al.ListEnabled do
if ao==1 then
an=""
end
an=an..(ao==1 and ap or", "..ap)
end
I.Text=an

for ao,ap in al.List do
local aq=table.find(al.ListEnabled,ap)
local ar=Instance.new"TextButton"
ar.Name=ap
ar.Size=UDim2.fromOffset(200,32)
ar.Position=UDim2.fromOffset(0,(ao-1)*L)
ar.BackgroundColor3=m.Light(o.Main,0.02)
ar.AutoButtonColor=false
ar.Text=""
ar.Parent=Y
addCorner(ar)
local as=Instance.new"Frame"
as.Name="BKG"
as.Size=UDim2.new(1,-2,1,-2)
as.Position=UDim2.fromOffset(1,1)
as.BackgroundColor3=o.Main
as.Visible=false
as.Parent=ar
addCorner(as)
local _=Instance.new"Frame"
_.Name="Dot"
_.Size=UDim2.fromOffset(10,11)
_.Position=UDim2.fromOffset(10,12)
_.BackgroundColor3=aq and aa.Color or m.Light(o.Main,0.37)
_.Parent=ar
addCorner(_,UDim.new(1,0))
local at=_:Clone()
at.Size=UDim2.fromOffset(8,9)
at.Position=UDim2.fromOffset(1,1)
at.BackgroundColor3=aq and aa.Color or m.Light(o.Main,0.02)
at.Parent=_
local au=Instance.new"TextLabel"
au.Name="Title"
au.Size=UDim2.new(1,-30,1,0)
au.Position=UDim2.fromOffset(30,0)
au.BackgroundTransparency=1
au.Text=ap
au.TextXAlignment=Enum.TextXAlignment.Left
au.TextColor3=m.Dark(o.Text,0.16)
au.TextSize=15
au.FontFace=o.Font
au.Parent=ar
local av=Instance.new"ImageButton"
av.Name="Close"
av.Size=UDim2.fromOffset(16,16)
av.Position=UDim2.new(1,-26,0,8)
av.BackgroundColor3=Color3.new(1,1,1)
av.BackgroundTransparency=1
av.AutoButtonColor=false
av.Image=u"vape/assets/new/closemini.png"
av.ImageColor3=m.Light(o.Text,0.2)
av.ImageTransparency=0.5
av.Parent=ar
addCorner(av,UDim.new(1,0))

av.MouseEnter:Connect(function()
av.ImageTransparency=0.3
n:Tween(av,o.Tween,{
BackgroundTransparency=0.6,
})
end)
av.MouseLeave:Connect(function()
av.ImageTransparency=0.5
n:Tween(av,o.Tween,{
BackgroundTransparency=1,
})
end)
av.Activated:Connect(function()
al:ChangeValue(ap)
al:FilterItems(ak)
end)
ar.MouseEnter:Connect(function()
as.Visible=true
end)
ar.MouseLeave:Connect(function()
as.Visible=false
end)
ar.Activated:Connect(function()
local aw=table.find(al.ListEnabled,ap)
if aw then
table.remove(al.ListEnabled,aw)
_.BackgroundColor3=m.Light(o.Main,0.37)
at.BackgroundColor3=m.Light(o.Main,0.02)
else
table.insert(al.ListEnabled,ap)
_.BackgroundColor3=aa.Color
at.BackgroundColor3=aa.Color
end

local ax="None"
for ay,az in al.ListEnabled do
if ay==1 then
ax=""
end
ax=ax..(ay==1 and az or", "..az)
end

I.Text=ax
aa.Function()
end)

table.insert(al.Objects,ar)
end


al:FilterItems(ak)
end


X:GetPropertyChangedSignal"Text":Connect(function()
ad:FilterItems(X.Text)
end)

X.MouseEnter:Connect(function()
n:Tween(V,o.Tween,{
BackgroundColor3=m.Light(o.Main,0.14),
})
end)
X.MouseLeave:Connect(function()
n:Tween(V,o.Tween,{
BackgroundColor3=m.Light(o.Main,0.02),
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
d:CreateNotification("Vape","You need to specify a value!",3)
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
T.FocusLost:Connect(function(al)
if al and not table.find(ad.List,T.Text)and T.Text~=""then
ad:ChangeValue(T.Text)
T.Text=""
X.Text=""
end
end)
T.MouseEnter:Connect(function()
n:Tween(R,o.Tween,{
BackgroundColor3=m.Light(o.Main,0.14),
})
end)
T.MouseLeave:Connect(function()
n:Tween(R,o.Tween,{
BackgroundColor3=m.Light(o.Main,0.02),
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
n:Cancel(af)
af.BackgroundColor3=N.Visible
and Color3.fromHSV(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
or m.Light(o.Main,0.37)
end)
ae.MouseEnter:Connect(function()
if not ad.Window.Visible then
n:Tween(af,o.Tween,{
BackgroundColor3=m.Light(o.Main,0.37),
})
end
end)
ae.MouseLeave:Connect(function()
if not ad.Window.Visible then
n:Tween(af,o.Tween,{
BackgroundColor3=m.Light(o.Main,0.034),
})
end
end)
ae:GetPropertyChangedSignal"AbsolutePosition":Connect(function()
if d.ThreadFix then
setthreadidentity(8)
end
local al=(
ae.AbsolutePosition
-(ac.Legit and d.Legit.Window.AbsolutePosition or-j:GetGuiInset())
)/A.Scale
N.Position=UDim2.fromOffset(al.X+220,al.Y)
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
Name=aa.Name,
Toggled=c(`{tostring(aa.Name)}_{tostring(ac.Name)}`),
}

local ae=false
local af=Instance.new"TextButton"
af.Name=aa.Name.."Toggle"
af.Size=UDim2.new(1,0,0,30)
af.BackgroundColor3=m.Dark(ab.BackgroundColor3,aa.Darker and 0.02 or 0)
af.BorderSizePixel=0
af.AutoButtonColor=false
af.Visible=aa.Visible==nil or aa.Visible
af.Text="          "..aa.Name
af.TextXAlignment=Enum.TextXAlignment.Left
af.TextColor3=m.Dark(o.Text,0.16)
af.TextSize=14
af.FontFace=o.Font
af.Parent=ab
addTooltip(af,aa.Tooltip)
local ag=Instance.new"Frame"
ag.Name="Knob"
ag.Size=UDim2.fromOffset(22,12)
ag.Position=UDim2.new(1,-30,0,9)
ag.BackgroundColor3=m.Light(o.Main,0.14)
ag.Parent=af
addCorner(ag,UDim.new(1,0))
local ah=ag:Clone()
ah.Size=UDim2.fromOffset(8,8)
ah.Position=UDim2.fromOffset(2,2)
ah.BackgroundColor3=o.Main
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
n:Cancel(ag)
ag.BackgroundColor3=am
and Color3.fromHSV(d:Color((aj-(ai.Index*0.075))%1))
or Color3.fromHSV(aj,ak,al)
end
end

function ad.Toggle(ai)
ai.Enabled=not ai.Enabled
ai.Toggled:Fire()
local aj=d.GUIColor.Rainbow and d.RainbowMode.Value~="Retro"
n:Tween(ag,o.Tween,{
BackgroundColor3=ai.Enabled
and(aj and Color3.fromHSV(
d:Color((d.GUIColor.Hue-(ai.Index*0.075))%1)
)or Color3.fromHSV(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value))
or(ae and m.Light(o.Main,0.37)or m.Light(o.Main,0.14)),
})
n:Tween(ah,o.Tween,{
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
n:Tween(ag,o.Tween,{
BackgroundColor3=m.Light(o.Main,0.37),
})
end
end)
af.MouseLeave:Connect(function()
ae=false
if not ad.Enabled then
n:Tween(ag,o.Tween,{
BackgroundColor3=m.Light(o.Main,0.14),
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
ae.BackgroundColor3=m.Dark(ab.BackgroundColor3,aa.Darker and 0.02 or 0)
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
af.TextColor3=m.Dark(o.Text,0.16)
af.TextSize=11
af.FontFace=o.Font
af.Parent=ae
local ag=Instance.new"TextButton"
ag.Name="Value"
ag.Size=UDim2.fromOffset(60,15)
ag.Position=UDim2.new(1,-69,0,9)
ag.BackgroundTransparency=1
ag.Text=ad.ValueMax
ag.TextXAlignment=Enum.TextXAlignment.Right
ag.TextColor3=m.Dark(o.Text,0.16)
ag.TextSize=11
ag.FontFace=o.Font
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
ai.TextColor3=m.Dark(o.Text,0.16)
ai.TextSize=11
ai.FontFace=o.Font
ai.ClearTextOnFocus=false
ai.Parent=ae
local aj=ai:Clone()
aj.Position=ah.Position
aj.Parent=ae
local ak=Instance.new"Frame"
ak.Name="Slider"
ak.Size=UDim2.new(1,-20,0,2)
ak.Position=UDim2.fromOffset(10,37)
ak.BackgroundColor3=m.Light(o.Main,0.034)
ak.BorderSizePixel=0
ak.Parent=ae
local al=ak:Clone()
al.Name="Fill"
al.Position=UDim2.fromScale(math.clamp(ad.ValueMin/aa.Max,0.04,0.96),0)
al.Size=UDim2.fromScale(
math.clamp(math.clamp(ad.ValueMax/aa.Max,0,1),0.04,0.96)-al.Position.X.Scale,
1
)
al.BackgroundColor3=Color3.fromHSV(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
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
an.Image=u"vape/assets/new/range.png"
an.ImageColor3=Color3.fromHSV(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
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
ap.Image=u"vape/assets/new/rangearrow.png"
ap.ImageColor3=m.Light(o.Main,0.14)
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
al.BackgroundColor3=av and Color3.fromHSV(d:Color((as-(ar.Index*0.075))%1))
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
n:Tween(al,TweenInfo.new(0.1),{
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
n:Tween(an,o.Tween,{
Size=UDim2.fromOffset(11,18),
})
end)
am.MouseLeave:Connect(function()
n:Tween(an,o.Tween,{
Size=UDim2.fromOffset(9,16),
})
end)
ao.MouseEnter:Connect(function()
n:Tween(ao.Knob,o.Tween,{
Size=UDim2.fromOffset(11,18),
})
end)
ao.MouseLeave:Connect(function()
n:Tween(ao.Knob,o.Tween,{
Size=UDim2.fromOffset(9,16),
})
end)
ae.InputBegan:Connect(function(ar)
if
(
ar.UserInputType==Enum.UserInputType.MouseButton1
or ar.UserInputType==Enum.UserInputType.Touch
)and(ar.Position.Y-ae.AbsolutePosition.Y)>(20*A.Scale)
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

local au=h.InputChanged:Connect(function(au)
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
ac.BackgroundColor3=m.Light(o.Main,0.02)
ac.BorderSizePixel=0
ac.Parent=aa
if ab then
local ad=Instance.new"TextLabel"
ad.Name="DividerLabel"
ad.Size=UDim2.fromOffset(218,27)
ad.BackgroundTransparency=1
ad.Text="          "..ab:upper()
ad.TextXAlignment=Enum.TextXAlignment.Left
ad.TextColor3=m.Dark(o.Text,0.43)
ad.TextSize=9
ad.FontFace=o.Font
ad.Parent=aa
ac.Position=UDim2.fromOffset(0,26)
ac.Parent=ad
end
end,
}

for aa,ab in H do
local ac=ab
H[aa]=function(ad,...)
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

d.Components=setmetatable(H,{
__newindex=function(aa,ab,ac)
for ad,ae in d.Modules do
rawset(ae,"Create"..ab,function(af,ag)
return ac(ag,ae.Children,ae)
end)
rawset(ae,"Add"..ab,function(af,ag)
return ac(ag,ae.Children,ae)
end)
end

if d.Legit then
for ad,ae in d.Legit.Modules do
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
local aa=tick()*(0.2*d.RainbowSpeed.Value)%1
for ab,ac in d.RainbowTable do
if ac.Type=="GUISlider"then
ac:SetValue(d:Color(aa))
else
ac:SetValue(aa)
end
end
task.wait(1/d.RainbowUpdateSpeed.Value)
until d.Loaded==nil
end)

function d.BlurCheck(aa)end

function d.CreateGUI(aa)
local ab={
Type="MainWindow",
Buttons={},
Options={},
}

local ac=Instance.new"TextButton"
ac.Name="GUICategory"
ac.Position=UDim2.fromOffset(6,60)
ac.BackgroundColor3=m.Dark(o.Main,0.02)
ac.AutoButtonColor=false
ac.Text=""
ac.Parent=v
addBlur(ac)
addCorner(ac)
makeDraggable(ac)
local ad=Instance.new"ImageLabel"
ad.Name="VapeLogo"
ad.Size=UDim2.fromOffset(62,18)
ad.Position=UDim2.fromOffset(11,10)
ad.BackgroundTransparency=1
ad.Image=u"vape/assets/new/guivape.png"
ad.ImageColor3=select(3,o.Main:ToHSV())>0.5 and o.Text or Color3.new(1,1,1)
ad.Parent=ac
local ae=Instance.new"ImageLabel"
ae.Name="V4Logo"
ae.Size=UDim2.fromOffset(28,16)
ae.Position=UDim2.new(1,1,0,1)
ae.BackgroundTransparency=1
ae.Image=u"vape/assets/new/guiv4.png"
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
ai.Image=u"vape/assets/new/guisettings.png"
ai.ImageColor3=m.Light(o.Main,0.37)
ai.Parent=ah
local aj=Instance.new"ImageButton"
aj.Size=UDim2.fromOffset(16,16)
aj.Position=UDim2.new(1,-56,0,11)
aj.BackgroundTransparency=1
aj.Image=u"vape/assets/new/discord.png"
aj.Parent=ac
addTooltip(aj,"Join discord")
local ak=Instance.new"TextButton"
ak.Size=UDim2.fromScale(1,1)
ak.BackgroundColor3=m.Dark(o.Main,0.02)
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
al.TextColor3=o.Text
al.TextSize=13
al.FontFace=o.Font
al.Parent=ak
local am=addCloseButton(ak)
local an=Instance.new"ImageButton"
an.Name="Back"
an.Size=UDim2.fromOffset(16,16)
an.Position=UDim2.fromOffset(11,13)
an.BackgroundTransparency=1
an.Image=u"vape/assets/new/back.png"
an.ImageColor3=m.Light(o.Main,0.37)
an.Parent=ak
local ao=Instance.new"TextLabel"
ao.Name="Version"
ao.Size=UDim2.new(1,0,0,16)
ao.Position=UDim2.new(0,0,1,-16)
ao.BackgroundTransparency=1
ao.Text="Vape "
..d.Version
.." "
..(D"vape/profiles/commit.txt"and readfile"vape/profiles/commit.txt":sub(1,6)or"")
.." "
ao.TextColor3=m.Dark(o.Text,0.43)
ao.TextXAlignment=Enum.TextXAlignment.Right
ao.TextSize=10
ao.FontFace=o.Font
ao.Parent=ak
addCorner(ak)
local ap=Instance.new"Frame"
ap.Name="Children"
ap.Size=UDim2.new(1,0,1,-57)
ap.Position=UDim2.fromOffset(0,41)
ap.BackgroundColor3=o.Main
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
at.BackgroundColor3=o.Main
at.BorderSizePixel=0
at.AutoButtonColor=false
at.Text="          Rebind GUI"
at.TextXAlignment=Enum.TextXAlignment.Left
at.TextColor3=m.Dark(o.Text,0.16)
at.TextSize=14
at.FontFace=o.Font
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
av.Image=u"vape/assets/new/bind.png"
av.ImageColor3=m.Dark(o.Text,0.43)
av.Parent=au
local aw=Instance.new"TextLabel"
aw.Name="Text"
aw.Size=UDim2.fromScale(1,1)
aw.Position=UDim2.fromOffset(0,1)
aw.BackgroundTransparency=1
aw.Visible=false
aw.Text=""
aw.TextColor3=m.Dark(o.Text,0.43)
aw.TextSize=12
aw.FontFace=o.Font
aw.Parent=au

function as.SetBind(ax,ay)
d.Keybind=#ay<=0 and d.Keybind or table.clone(ay)
ax.Bind=d.Keybind
if d.VapeButton then
d.VapeButton:Destroy()
d.VapeButton=nil
end

au.Visible=true
aw.Visible=true
av.Visible=false
aw.Text=table.concat(d.Keybind," + "):upper()
au.Size=UDim2.fromOffset(math.max(E(aw.Text,aw.TextSize,aw.Font).X+10,20),21)
end

au.MouseEnter:Connect(function()
aw.Visible=false
av.Visible=not aw.Visible
av.Image=u"vape/assets/new/edit.png"
av.ImageColor3=m.Dark(o.Text,0.16)
end)
au.MouseLeave:Connect(function()
aw.Visible=true
av.Visible=not aw.Visible
av.Image=u"vape/assets/new/bind.png"
av.ImageColor3=m.Dark(o.Text,0.43)
end)
au.Activated:Connect(function()
d.Binding=as
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
au.BackgroundColor3=o.Main
au.BorderSizePixel=0
au.AutoButtonColor=false
au.Text=(
as.Icon
and"                                 "
or"             "
)..as.Name
au.TextXAlignment=Enum.TextXAlignment.Left
au.TextColor3=m.Dark(o.Text,0.16)
au.TextSize=14
au.FontFace=o.Font
au.Parent=af
local av
if as.Icon then
av=Instance.new"ImageLabel"
av.Name="Icon"
av.Size=as.Size
av.Position=UDim2.fromOffset(13,13)
av.BackgroundTransparency=1
av.Image=as.Icon
av.ImageColor3=m.Dark(o.Text,0.16)
av.Parent=au
end
if as.Name=="Profiles"then
local aw=Instance.new"TextLabel"
aw.Name="ProfileLabel"
aw.Size=UDim2.fromOffset(53,24)
aw.Position=UDim2.new(1,-36,0,8)
aw.AnchorPoint=Vector2.new(1,0)
aw.BackgroundColor3=m.Light(o.Main,0.04)
aw.Text="default"
aw.TextColor3=m.Dark(o.Text,0.29)
aw.TextSize=12
aw.FontFace=o.Font
aw.Parent=au
addCorner(aw)
d.ProfileLabel=aw
end
local aw=Instance.new"ImageLabel"
aw.Name="Arrow"
aw.Size=UDim2.fromOffset(4,8)
aw.Position=UDim2.new(1,-20,0,16)
aw.BackgroundTransparency=1
aw.Image=u"vape/assets/new/expandright.png"
aw.ImageColor3=m.Light(o.Main,0.37)
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
n:Tween(aw,o.Tween,{
Position=UDim2.new(1,ax.Enabled and-14 or-20,0,16),
})
au.TextColor3=ax.Enabled
and Color3.fromHSV(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
or o.Text
if av then
av.ImageColor3=au.TextColor3
end
au.BackgroundColor3=m.Light(o.Main,0.02)
as.Window.Visible=ax.Enabled
end

if as.Default and not at.Enabled then
at:Toggle()
end

au.MouseEnter:Connect(function()
if not at.Enabled then
au.TextColor3=o.Text
if buttonicon then
buttonicon.ImageColor3=o.Text
end
au.BackgroundColor3=m.Light(o.Main,0.02)
end
end)
au.MouseLeave:Connect(function()
if not at.Enabled then
au.TextColor3=m.Dark(o.Text,0.16)
if buttonicon then
buttonicon.ImageColor3=m.Dark(o.Text,0.16)
end
au.BackgroundColor3=o.Main
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
return H.Divider(af,as)
end

function ab.CreateOverlayBar(ar)
local as={Toggles={}}

local at=Instance.new"Frame"
at.Name="Overlays"
at.Size=UDim2.fromOffset(220,36)
at.BackgroundColor3=o.Main
at.BorderSizePixel=0
at.Parent=af
H.Divider(at)
local au=Instance.new"ImageButton"
au.Size=UDim2.fromOffset(24,24)
au.Position=UDim2.new(1,-29,0,7)
au.BackgroundTransparency=1
au.AutoButtonColor=false
au.Image=u"vape/assets/new/overlaysicon.png"
au.ImageColor3=m.Light(o.Main,0.37)
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
aw.BackgroundColor3=o.Main
aw.Parent=av
addCorner(aw)
local ax=Instance.new"ImageLabel"
ax.Name="Icon"
ax.Size=UDim2.fromOffset(14,12)
ax.Position=UDim2.fromOffset(10,13)
ax.BackgroundTransparency=1
ax.Image=u"vape/assets/new/overlaystab.png"
ax.ImageColor3=o.Text
ax.Parent=aw
local ay=Instance.new"TextLabel"
ay.Name="Title"
ay.Size=UDim2.new(1,-36,0,38)
ay.Position=UDim2.fromOffset(36,0)
ay.BackgroundTransparency=1
ay.Text="Overlays"
ay.TextXAlignment=Enum.TextXAlignment.Left
ay.TextColor3=o.Text
ay.TextSize=15
ay.FontFace=o.Font
ay.Parent=aw
local az=addCloseButton(aw,7)
local I=Instance.new"Frame"
I.Name="Divider"
I.Size=UDim2.new(1,0,0,1)
I.Position=UDim2.fromOffset(0,37)
I.BackgroundColor3=m.Light(o.Main,0.02)
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
Toggled=c(`{tostring(M.Name)}_Overlays`),
Name=M.Name
}

local O=false
local P=Instance.new"TextButton"
P.Name=M.Name.."Toggle"
P.Size=UDim2.new(1,0,0,40)
P.BackgroundTransparency=1
P.AutoButtonColor=false
P.Text=string.rep(" ",33*A.Scale)..M.Name
P.TextXAlignment=Enum.TextXAlignment.Left
P.TextColor3=m.Dark(o.Text,0.16)
P.TextSize=14
P.FontFace=o.Font
P.Parent=J
local Q=Instance.new"ImageLabel"
Q.Name="Icon"
Q.Size=M.Size
Q.Position=M.Position
Q.BackgroundTransparency=1
Q.Image=M.Icon
Q.ImageColor3=o.Text
Q.Parent=P
local R=Instance.new"Frame"
R.Name="Knob"
R.Size=UDim2.fromOffset(22,12)
R.Position=UDim2.new(1,-30,0,14)
R.BackgroundColor3=m.Light(o.Main,0.14)
R.Parent=P
addCorner(R,UDim.new(1,0))
local S=R:Clone()
S.Size=UDim2.fromOffset(8,8)
S.Position=UDim2.fromOffset(2,2)
S.BackgroundColor3=o.Main
S.Parent=R
N.Object=P

function N.Toggle(T)
T.Enabled=not T.Enabled
T.Toggled:Fire()
n:Tween(R,o.Tween,{
BackgroundColor3=T.Enabled
and Color3.fromHSV(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
or(O and m.Light(o.Main,0.37)or m.Light(o.Main,0.14)),
})
n:Tween(S,o.Tween,{
Position=UDim2.fromOffset(T.Enabled and 12 or 2,2),
})
M.Function(T.Enabled)
end

A:GetPropertyChangedSignal"Scale":Connect(function()
P.Text=string.rep(" ",33*A.Scale)..M.Name
end)
P.MouseEnter:Connect(function()
O=true
if not N.Enabled then
n:Tween(R,o.Tween,{
BackgroundColor3=m.Light(o.Main,0.37),
})
end
end)
P.MouseLeave:Connect(function()
O=false
if not N.Enabled then
n:Tween(R,o.Tween,{
BackgroundColor3=m.Light(o.Main,0.14),
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
au.ImageColor3=o.Text
n:Tween(au,o.Tween,{
BackgroundTransparency=0.9,
})
end)
au.MouseLeave:Connect(function()
au.ImageColor3=m.Light(o.Main,0.37)
n:Tween(au,o.Tween,{
BackgroundTransparency=1,
})
end)
au.Activated:Connect(function()
av.Visible=true
n:Tween(av,o.Tween,{
BackgroundTransparency=0.5,
})
n:Tween(aw,o.Tween,{
Position=UDim2.new(0,0,1,-aw.Size.Y.Offset),
})
end)
az.Activated:Connect(function()
n:Tween(av,o.Tween,{
BackgroundTransparency=1,
})
n:Tween(aw,o.Tween,{
Position=UDim2.fromScale(0,1),
})
task.wait(0.2)
av.Visible=false
end)
av.Activated:Connect(function()
n:Tween(av,o.Tween,{
BackgroundTransparency=1,
})
n:Tween(aw,o.Tween,{
Position=UDim2.fromScale(0,1),
})
task.wait(0.2)
av.Visible=false
end)
K:GetPropertyChangedSignal"AbsoluteContentSize":Connect(function()
if d.ThreadFix then
setthreadidentity(8)
end
aw.Size=UDim2.fromOffset(220,math.min(37+K.AbsoluteContentSize.Y/A.Scale,605))
J.Size=UDim2.fromOffset(220,aw.Size.Y.Offset-5)
end)

d.Overlays=as

return as
end

function ab.CreateSettingsDivider(ar)
H.Divider(ap)
end

function ab.CreateSettingsPane(ar,as)
local at={}

local au=Instance.new"TextButton"
au.Name=as.Name
au.Size=UDim2.fromOffset(220,40)
au.BackgroundColor3=o.Main
au.BorderSizePixel=0
au.AutoButtonColor=false
au.Text="          "..as.Name
au.TextXAlignment=Enum.TextXAlignment.Left
au.TextColor3=m.Dark(o.Text,0.16)
au.TextSize=14
au.FontFace=o.Font
au.Parent=ap
local av=Instance.new"ImageLabel"
av.Name="Arrow"
av.Size=UDim2.fromOffset(4,8)
av.Position=UDim2.new(1,-20,0,16)
av.BackgroundTransparency=1
av.Image=u"vape/assets/new/expandright.png"
av.ImageColor3=m.Light(o.Main,0.37)
av.Parent=au
local aw=Instance.new"TextButton"
aw.Size=UDim2.fromScale(1,1)
aw.BackgroundColor3=o.Main
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
ax.TextColor3=o.Text
ax.TextSize=13
ax.FontFace=o.Font
ax.Parent=aw
local ay=addCloseButton(aw)
local az=Instance.new"ImageButton"
az.Name="Back"
az.Size=UDim2.fromOffset(16,16)
az.Position=UDim2.fromOffset(11,13)
az.BackgroundTransparency=1
az.Image=u"vape/assets/new/back.png"
az.ImageColor3=m.Light(o.Main,0.37)
az.Parent=aw
addCorner(aw)
local I=Instance.new"Frame"
I.Name="Children"
I.Size=UDim2.new(1,0,1,-57)
I.Position=UDim2.fromOffset(0,41)
I.BackgroundColor3=o.Main
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

for L,M in H do
at["Create"..L]=function(N,O)
return M(O,I,ab)
end
at["Add"..L]=at["Create"..L]
end

az.MouseEnter:Connect(function()
az.ImageColor3=o.Text
end)
az.MouseLeave:Connect(function()
az.ImageColor3=m.Light(o.Main,0.37)
end)
az.Activated:Connect(function()
aw.Visible=false
end)
au.MouseEnter:Connect(function()
au.TextColor3=o.Text
au.BackgroundColor3=m.Light(o.Main,0.02)
end)
au.MouseLeave:Connect(function()
au.TextColor3=m.Dark(o.Text,0.16)
au.BackgroundColor3=o.Main
end)
au.Activated:Connect(function()
aw.Visible=true
end)
ay.Activated:Connect(function()
aw.Visible=false
end)
ag:GetPropertyChangedSignal"AbsoluteContentSize":Connect(function()
if d.ThreadFix then
setthreadidentity(8)
end
ac.Size=UDim2.fromOffset(220,45+ag.AbsoluteContentSize.Y/A.Scale)
for L,M in ab.Buttons do
if M.Icon then
M.Object.Text=string.rep(" ",33*A.Scale)..M.Name
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
ay.BackgroundColor3=m.Dark(o.Main,0.02)
ay.BorderSizePixel=0
ay.AutoButtonColor=false
ay.Visible=false
ay.Text=""
ay.Parent=ap
local az=Instance.new"TextLabel"
az.Name="Title"
az.Size=UDim2.fromOffset(60,30)
az.Position=UDim2.fromOffset(10,2)
az.BackgroundTransparency=1
az.Text=aw
az.TextXAlignment=Enum.TextXAlignment.Left
az.TextColor3=m.Dark(o.Text,0.16)
az.TextSize=11
az.FontFace=o.Font
az.Parent=ay
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
L.BackgroundColor3=m.Dark(o.Main,0.02)
L.BorderSizePixel=0
L.Parent=K
local M=Instance.new"Frame"
M.Name="Knob"
M.Size=UDim2.fromOffset(14,14)
M.Position=UDim2.fromScale(0.5,0.5)
M.AnchorPoint=Vector2.new(0.5,0.5)
M.BackgroundColor3=o.Text
M.Parent=L
addCorner(M,UDim.new(1,0))
if aw=="Custom color"then
local N=Instance.new"TextButton"
N.Size=UDim2.fromOffset(45,20)
N.Position=UDim2.new(1,-52,0,5)
N.BackgroundTransparency=1
N.Text="RESET"
N.TextColor3=m.Dark(o.Text,0.16)
N.TextSize=11
N.FontFace=o.Font
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
)and(N.Position.Y-ay.AbsolutePosition.Y)>(20*A.Scale)
then
local O=h.InputChanged:Connect(function(O)
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
n:Tween(M,o.Tween,{
Size=UDim2.fromOffset(16,16),
})
end)
ay.MouseLeave:Connect(function()
n:Tween(M,o.Tween,{
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
ax.TextColor3=m.Dark(o.Text,0.16)
ax.TextSize=11
ax.FontFace=o.Font
ax.Parent=aw
local ay=Instance.new"Frame"
ay.Name="Slider"
ay.Size=UDim2.fromOffset(200,2)
ay.Position=UDim2.fromOffset(10,37)
ay.BackgroundTransparency=1
ay.BorderSizePixel=0
ay.Parent=aw
local az=0
for I,J in au do
local K=Instance.new"Frame"
K.Size=UDim2.fromOffset(27+(((I+1)%2)==0 and 1 or 0),2)
K.Position=UDim2.fromOffset(az,0)
K.BackgroundColor3=J
K.BorderSizePixel=0
K.Parent=ay
az+=(K.Size.X.Offset+1)
end
local I=Instance.new"ImageButton"
I.Name="Preview"
I.Size=UDim2.fromOffset(12,12)
I.Position=UDim2.new(1,-22,0,10)
I.BackgroundTransparency=1
I.Image=u"vape/assets/new/colorpreview.png"
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
J.TextColor3=m.Dark(o.Text,0.16)
J.TextSize=11
J.FontFace=o.Font
J.ClearTextOnFocus=true
J.Parent=aw
local K=Instance.new"TextButton"
K.Name="Expand"
K.Size=UDim2.fromOffset(17,13)
K.Position=UDim2.new(0,E(ax.Text,ax.TextSize,ax.Font).X+11,0,7)
K.BackgroundTransparency=1
K.Text=""
K.Parent=aw
local L=Instance.new"ImageLabel"
L.Name="Expand"
L.Size=UDim2.fromOffset(9,5)
L.Position=UDim2.fromOffset(4,4)
L.BackgroundTransparency=1
L.Image=u"vape/assets/new/expandicon.png"
L.ImageColor3=m.Dark(o.Text,0.43)
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
N.Image=u"vape/assets/new/rainbow_1.png"
N.ImageColor3=m.Light(o.Main,0.37)
N.Parent=M
local O=N:Clone()
O.Image=u"vape/assets/new/rainbow_2.png"
O.Parent=M
local P=N:Clone()
P.Image=u"vape/assets/new/rainbow_3.png"
P.Parent=M
local Q=N:Clone()
Q.Image=u"vape/assets/new/rainbow_4.png"
Q.Parent=M
local R=Instance.new"ImageLabel"
R.Name="Knob"
R.Size=UDim2.fromOffset(26,12)
R.Position=UDim2.fromOffset(av[4]-3,-5)
R.BackgroundTransparency=1
R.Image=u"vape/assets/new/guislider.png"
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
local W=u"vape/assets/new/guislider.png"
local X=u"vape/assets/new/guisliderrain.png"
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

function at.SetValue(Z,_,aA,aB,aC)
if aC then
if Z.Rainbow then
Z:Toggle()
end
Z.CustomColor=false
_,aA,aB=au[aC]:ToHSV()
else
Z.CustomColor=true
end

Z.Hue=_ or Z.Hue
Z.Sat=aA or Z.Sat
Z.Value=aB or Z.Value
Z.Notch=aC
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
n:Tween(R,o.Tween,{
Position=UDim2.fromOffset(av[4]-3,-5),
})
else
R.Image=W
R.ImageColor3=Color3.fromHSV(Z.Hue,Z.Sat,Z.Value)
n:Tween(R,o.Tween,{
Position=UDim2.fromOffset(av[aC or 4]-3,-5),
})
end

if Z.Rainbow then
if _ then
T.Slider.Fill.Size=UDim2.fromScale(math.clamp(Z.Hue,0.04,0.96),1)
end
if aA then
U.Slider.Fill.Size=UDim2.fromScale(math.clamp(Z.Sat,0.04,0.96),1)
end
if aB then
V.Slider.Fill.Size=UDim2.fromScale(math.clamp(Z.Value,0.04,0.96),1)
end
else
if _ then
n:Tween(T.Slider.Fill,o.Tween,{
Size=UDim2.fromScale(math.clamp(Z.Hue,0.04,0.96),1),
})
end
if aA then
n:Tween(U.Slider.Fill,o.Tween,{
Size=UDim2.fromScale(math.clamp(Z.Sat,0.04,0.96),1),
})
end
if aB then
n:Tween(V.Slider.Fill,o.Tween,{
Size=UDim2.fromScale(math.clamp(Z.Value,0.04,0.96),1),
})
end
end
as.Function(Z.Hue,Z.Sat,Z.Value)
end

function at.ToColor(aA)
return Color3.fromHSV(aA.Hue,aA.Sat,aA.Value)
end

function at.Toggle(aA)
aA.Rainbow=not aA.Rainbow
if Y then
task.cancel(Y)
end

if aA.Rainbow then
R.Image=X
table.insert(d.RainbowTable,aA)

N.ImageColor3=Color3.fromRGB(5,127,100)
Y=task.delay(0.1,function()
O.ImageColor3=Color3.fromRGB(228,125,43)
Y=task.delay(0.1,function()
P.ImageColor3=Color3.fromRGB(225,46,52)
Y=nil
end)
end)
else
aA:SetValue(nil,nil,nil,4)
R.Image=W
local aB=table.find(d.RainbowTable,aA)
if aB then
table.remove(d.RainbowTable,aB)
end

P.ImageColor3=m.Light(o.Main,0.37)
Y=task.delay(0.1,function()
O.ImageColor3=m.Light(o.Main,0.37)
Y=task.delay(0.1,function()
N.ImageColor3=m.Light(o.Main,0.37)
end)
end)
end
end

K.MouseEnter:Connect(function()
L.ImageColor3=m.Dark(o.Text,0.16)
end)
K.MouseLeave:Connect(function()
L.ImageColor3=m.Dark(o.Text,0.43)
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
local aA=Color3.fromHSV(at.Hue,at.Sat,at.Value)
J.Text=math.round(aA.R*255)
..", "
..math.round(aA.G*255)
..", "
..math.round(aA.B*255)
end)
aw.InputBegan:Connect(function(aA)
if
(
aA.UserInputType==Enum.UserInputType.MouseButton1
or aA.UserInputType==Enum.UserInputType.Touch
)and(aA.Position.Y-aw.AbsolutePosition.Y)>(20*A.Scale)
then
local aB=h.InputChanged:Connect(function(aB)
if
aB.UserInputType
==(
aA.UserInputType==Enum.UserInputType.MouseButton1
and Enum.UserInputType.MouseMovement
or Enum.UserInputType.Touch
)
then
at:SetValue(
nil,
nil,
nil,
math.clamp(
math.round((aB.Position.X-ay.AbsolutePosition.X)/A.Scale/27),
1,
7
)
)
end
end)

local aC
aC=aA.Changed:Connect(function()
if aA.UserInputState==Enum.UserInputState.End then
if aB then
aB:Disconnect()
end
if aC then
aC:Disconnect()
end
end
end)
at:SetValue(
nil,
nil,
nil,
math.clamp(math.round((aA.Position.X-ay.AbsolutePosition.X)/A.Scale/27),1,7)
)
end
end)
M.Activated:Connect(function()
at:Toggle()
end)
J.FocusLost:Connect(function(aA)
I.Visible=true
J.Visible=false
if aA then
local aB=J.Text:split","
local aC,Z=pcall(function()
return tonumber(aB[1])
and Color3.fromRGB(tonumber(aB[1]),tonumber(aB[2]),tonumber(aB[3]))
or Color3.fromHex(J.Text)
end)

if aC then
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
an.ImageColor3=o.Text
end)
an.MouseLeave:Connect(function()
an.ImageColor3=m.Light(o.Main,0.37)
end)
an.Activated:Connect(function()
ak.Visible=false
end)
am.Activated:Connect(function()
ak.Visible=false
end)
aj.Activated:Connect(function()
task.spawn(function()
local ar=l:JSONEncode{
nonce=l:GenerateGUID(false),
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
z.Text="Copied!"
setclipboard"https://discord.gg/voidware"
end)
end)
ah.MouseEnter:Connect(function()
ai.ImageColor3=o.Text
end)
ah.MouseLeave:Connect(function()
ai.ImageColor3=m.Light(o.Main,0.37)
end)
ah.Activated:Connect(function()
d.MainGuiSettingsOpenedEvent:Fire()
ak.Visible=true
end)
ag:GetPropertyChangedSignal"AbsoluteContentSize":Connect(function()
if aa.ThreadFix then
setthreadidentity(8)
end
ac.Size=UDim2.fromOffset(220,42+ag.AbsoluteContentSize.Y/A.Scale)
for ar,as in ab.Buttons do
if as.Icon then
as.Object.Text=string.rep(" ",36*A.Scale)..as.Name
end
end
end)

ab.MainGui=af

aa.Categories.Main=ab

return ab
end

function d.CreateCategory(aa,ab)
local ac={
Type="Category",
OriginalCategory=true,
Expanded=false,
}

local ad=Instance.new"TextButton"
ad.Name=ab.Name.."Category"
ad.Size=UDim2.fromOffset(220,41)
ad.Position=UDim2.fromOffset(236,60)
ad.BackgroundColor3=o.Main
ad.AutoButtonColor=false
ad.Visible=false
ad.Text=""
ad.Parent=v
addBlur(ad)
addCorner(ad)

local ae=Instance.new"ImageLabel"
ae.Name="Icon"
ae.Size=ab.Size
ae.Position=UDim2.fromOffset(12,(ae.Size.X.Offset>20 and 14 or 13))
ae.BackgroundTransparency=1
ae.Image=ab.Icon
ae.ImageColor3=o.Text
ae.Parent=ad
local af=Instance.new"TextLabel"
af.Name="Title"
af.Size=UDim2.new(1,-(ab.Size.X.Offset>18 and 40 or 33),0,41)
af.Position=UDim2.fromOffset(math.abs(af.Size.X.Offset),0)
af.BackgroundTransparency=1
af.Text=ab.Name
af.TextXAlignment=Enum.TextXAlignment.Left
af.TextColor3=o.Text
af.TextSize=13
af.FontFace=o.Font
af.Parent=ad
local ag=Instance.new"TextButton"
ag.Name="Arrow"


ag.Size=UDim2.new(1,0,0,41)
ag.Position=UDim2.fromOffset(0,0)
ag.BackgroundTransparency=1
ag.Text=""
ag.Parent=ad
makeDraggable2(ag,ad)
local ah=setupGuiMoveCheck(ag,ad)
local ai=Instance.new"ImageLabel"
ai.Name="Arrow"
ai.Size=UDim2.fromOffset(9,4)

ai.Position=UDim2.new(0.9,0,0,18)
ai.BackgroundTransparency=1
ai.Image=u"vape/assets/new/expandup.png"
ai.ImageColor3=Color3.fromRGB(140,140,140)
ai.Rotation=180
ai.Parent=ag
local aj=Instance.new"ScrollingFrame"
aj.Name="Children"
aj.Size=UDim2.new(1,0,1,-41)
aj.Position=UDim2.fromOffset(0,37)
aj.BackgroundTransparency=1
aj.BorderSizePixel=0
aj.Visible=false
aj.ScrollBarThickness=2
aj.ScrollBarImageTransparency=0.75
aj.CanvasSize=UDim2.new()
aj.ClipsDescendants=true
aj.Parent=ad
local ak=Instance.new"Frame"
ak.Name="Divider"
ak.Size=UDim2.new(1,0,0,1)
ak.Position=UDim2.fromOffset(0,37)
ak.BackgroundColor3=Color3.new(1,1,1)
ak.BackgroundTransparency=0.928
ak.BorderSizePixel=0
ak.Visible=false
ak.Parent=ad
local al=Instance.new"UIListLayout"
al.SortOrder=Enum.SortOrder.LayoutOrder
al.HorizontalAlignment=Enum.HorizontalAlignment.Center
al.Parent=aj

function ac.CreateModule(am,an)
an.Function=a:wrap(an.Function,{
type="module",
name=an.Name,
category=ab.Name,
})
d:Remove(an.Name)
local ao={
Enabled=false,
Options={},
Bind={},
NoSave=an.NoSave,
Index=getTableSize(d.Modules),
ExtraText=an.ExtraText,
Name=an.Name,
Category=ab.Name,
SavingID=an.SavingID,
Toggled=c(`{tostring(an.Name)}_{tostring(ac.Name)}_{tostring(an.SavingID)}_{tostring(an.ExtraText)}`),
}
an.Tooltip=an.Tooltip or an.Name

local ap=an.DisplayName or an.Name
local aq=false
local ar=Instance.new"TextButton"
ar.Name=an.Name
ar.Size=UDim2.fromOffset(220,40)
ar.BackgroundColor3=o.Main
ar.BorderSizePixel=0
ar.AutoButtonColor=false
ar.Text="            "..ap
ar.TextXAlignment=Enum.TextXAlignment.Left
ar.TextColor3=m.Dark(o.Text,0.16)
ar.TextSize=14
ar.FontFace=o.Font
ar.Parent=aj
if an.Premium then
local as=Instance.new"TextLabel"
as.Parent=ar
as.SizeConstraint=Enum.SizeConstraint.RelativeXX
as.AutomaticSize=Enum.AutomaticSize.X
as.Size=UDim2.new(0,0,0,21)
as.BackgroundColor3=Color3.new(1,1,1)
as.TextSize=14
as.TextTransparency=1
as.AnchorPoint=Vector2.new(0,0.5)
as.Text="Premium"
as.Position=UDim2.new(0,128,0.5,0)
as.TextColor3=Color3.new(0,0,0)
as.FontFace=o.Font

connectvisibilitychange(function(at)
n:Tween(as,TweenInfo.new(0.5,Enum.EasingStyle.Quad),{
BackgroundTransparency=at and 0 or 1
})
end)

addCorner(as,UDim.new(0,5))

local at=as:Clone()
at.Parent=as
at.Position=UDim2.new()
at.Size=UDim2.fromScale(1,1)
at.BackgroundTransparency=1
at.AnchorPoint=Vector2.new()
at.AutomaticSize=Enum.AutomaticSize.None
at.TextSize=12
at.TextTransparency=0
at.SizeConstraint=Enum.SizeConstraint.RelativeXY

table.insert(d.Indicators,as)
end
local as=Instance.new"UIGradient"
as.Rotation=90
as.Enabled=false
as.Parent=ar
local at=Instance.new"Frame"
local au=Instance.new"TextButton"
addTooltip(ar,an.Tooltip)
addTooltip(au,"Click to bind")
au.Name="Bind"
au.Size=UDim2.fromOffset(20,21)
au.Position=UDim2.new(1,-36,0,9)
au.AnchorPoint=Vector2.new(1,0)
au.BackgroundColor3=Color3.new(1,1,1)
au.BackgroundTransparency=0.92
au.BorderSizePixel=0
au.AutoButtonColor=false
au.Visible=false
au.Text=""
addCorner(au,UDim.new(0,4))
local av=Instance.new"ImageLabel"
av.Name="Icon"
av.Size=UDim2.fromOffset(12,12)
av.Position=UDim2.new(0.5,-6,0,5)
av.BackgroundTransparency=1
av.Image=u"vape/assets/new/bind.png"
av.ImageColor3=m.Dark(o.Text,0.43)
av.Parent=au
local aw=Instance.new"TextLabel"
aw.Size=UDim2.fromScale(1,1)
aw.Position=UDim2.fromOffset(0,1)
aw.BackgroundTransparency=1
aw.Visible=false
aw.Text=""
aw.TextColor3=m.Dark(o.Text,0.43)
aw.TextSize=12
aw.FontFace=o.Font
aw.Parent=au
local ax=Instance.new"ImageLabel"
ax.Name="Cover"
ax.Size=UDim2.fromOffset(154,40)
ax.BackgroundTransparency=1
ax.Visible=false
ax.Image=u"vape/assets/new/bindbkg.png"
ax.ScaleType=Enum.ScaleType.Slice
ax.SliceCenter=Rect.new(0,0,141,40)
ax.Parent=ar
local ay=Instance.new"TextLabel"
ay.Name="Text"
ay.Size=UDim2.new(1,-10,1,-3)
ay.BackgroundTransparency=1
ay.Text="PRESS A KEY TO BIND"
ay.TextColor3=o.Text
ay.TextSize=11
ay.FontFace=o.Font
ay.Parent=ax
au.Parent=ar

local az=au:Clone()
az.Parent=ar
az.Name="Star"
az.Icon.Image=u"vape/assets/new/star.png"
az.BackgroundColor3=Color3.fromRGB(255,255,255)
az.Visible=false
az.BackgroundTransparency=0
az.Position=UDim2.new(1,-70,0,9)
addTooltip(az,"Click to favorite")

local aA=Instance.new"UIStroke"
aA.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
aA.Transparency=0
aA.Thickness=2
aA.Color=Color3.fromRGB(255,255,0)
aA.Parent=ar
aA.Enabled=false
local aB=aA
connectvisibilitychange(function(aC)
aB.Enabled=ao.StarActive
if not aB.Enabled then return end
n:Tween(aB,TweenInfo.new(0.5,Enum.EasingStyle.Quad),{
Thickness=aC and 2 or 0,
})
end)

ao.InternalAddOnChange=Instance.new"BindableEvent"
ao.InternalAddOnChange.Event:Connect(function()
az.Position=au.Visible and UDim2.new(1,-70,0,9)or UDim2.new(1,-36,0,9)
end)
au:GetPropertyChangedSignal"Visible":Connect(function()
ao.InternalAddOnChange:Fire()
end)

local function updateModuleSorting()
local aC={}

for I,J in d.Modules do
aC[J.Category]=aC[J.Category]or{starred={},normal={}}

local K={
name=J.Name,

textSize=E(J.Name,J.Object.TextSize,J.Object.Font).X
}

if J.StarActive then
table.insert(aC[J.Category].starred,K)
else
table.insert(aC[J.Category].normal,K)
end
end

local function sortByTextSize(I,J)
if I.textSize==J.textSize then
return I.name>J.name
end
return I.textSize>J.textSize
end

for I,J in aC do
table.sort(J.starred,sortByTextSize)
table.sort(J.normal,sortByTextSize)

local K={}
for L,M in J.starred do
table.insert(K,M.name)
end
for L,M in J.normal do
table.insert(K,M.name)
end

for L,M in K do
if d.Modules[M]then
d.Modules[M].Index=L
d.Modules[M].Object.LayoutOrder=L
d.Modules[M].Children.LayoutOrder=L
end
end
end
end

for aC,I in{az,au}do
I:GetPropertyChangedSignal"Visible":Connect(function()
if I.Visible and an.Premium then
I.Visible=false
end
end)
end

ao.StarActive=false
function ao.ToggleStar(aC,I)
if an.Premium then
ao.StarActive=false
else
ao.StarActive=not ao.StarActive
end
az.BackgroundColor3=ao.StarActive and Color3.fromRGB(255,255,127)or Color3.fromRGB(255,255,255)
aB.Enabled=ao.StarActive
az.Visible=ao.StarActive or aq or at.Visible
if not I then
if d.FavoriteNotifications~=nil and d.FavoriteNotifications.Enabled then
d:CreateNotification(
"Module Favorite",
tostring(an.Name)
.."<font color='#FFFFFF'> has been </font>"
..(ao.StarActive and"<font color='#FAFF5A'>Favorited</font>"or"<font color='#FF5A5A'>Unfaved</font>")
.."<font color='#FFFFFF'>!</font>",
0.75
)
end
end
ao.InternalAddOnChange:Fire()
updateModuleSorting()
end
if an.Star and not an.Premium then
ao:ToggleStar(true)
end

local aC=Instance.new"TextButton"
aC.Name="Dots"
aC.Size=UDim2.fromOffset(25,40)
aC.Position=UDim2.new(1,-25,0,0)
aC.BackgroundTransparency=1
aC.Text=""
aC.Parent=ar
local I=Instance.new"ImageLabel"
I.Name="Dots"
I.Size=UDim2.fromOffset(3,16)
I.Position=UDim2.fromOffset(4,12)
I.BackgroundTransparency=1
I.Image=u"vape/assets/new/dots.png"
I.ImageColor3=m.Light(o.Main,0.37)
I.Parent=aC
at.Name=an.Name.."Children"
at.Size=UDim2.new(1,0,0,0)
at.BackgroundColor3=m.Dark(o.Main,0.02)
at.BorderSizePixel=0
at.Visible=false
at.Parent=aj
at.ClipsDescendants=true
ao.Children=at
local J=Instance.new"UIListLayout"
J.SortOrder=Enum.SortOrder.LayoutOrder
J.HorizontalAlignment=Enum.HorizontalAlignment.Center
J.Parent=at
local K=Instance.new"Frame"
K.Name="Divider"
K.Size=UDim2.new(1,0,0,1)
K.Position=UDim2.new(0,0,1,-1)
K.BackgroundColor3=Color3.new(0.19,0.19,0.19)
K.BackgroundTransparency=0.52
K.BorderSizePixel=0
K.Visible=false
K.Parent=ar
an.Function=an.Function or function()end
addMaid(ao)

local L
local M

ao.OptionsVisibilityChanged=a.createCustomSignal(`OPTIONS_VISIBILITY_CHANGE_{tostring(an.Name)}_{tostring(ab.Name)}`)

local function openOptions()
if L then
L:Cancel()
end
if M then
M:Cancel()
end

at.Visible=true
ao.OptionsVisibilityChanged:Fire(true)

local N=J.AbsoluteContentSize.Y/A.Scale

L=n:Tween(
at,
TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
{Size=UDim2.new(1,0,0,N)}
)
end

local function closeOptions()
if L then
L:Cancel()
end
if M then
M:Cancel()
end

M=n:Tween(
at,
TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
{Size=UDim2.new(1,0,0,0)}
)

M.Completed:Once(function()
at.Visible=false
end)
task.delay(0.1,function()
ao.OptionsVisibilityChanged:Fire(false)
end)
end


function ao.SetBind(N,O,P,Q)
if O.Mobile then
createMobileButton(ao,Vector2.new(O.X,O.Y))
return
end

N.Bind=table.clone(O)
if P then
ay.Text=#O<=0 and"BIND REMOVED"or"BOUND TO"
ax.Size=UDim2.fromOffset(E(ay.Text,ay.TextSize).X+20,40)
task.delay(1,function()
ax.Visible=false
end)
end

if#O<=0 then
aw.Visible=false
av.Visible=true
au.Size=UDim2.fromOffset(20,21)
else
au.Visible=true
aw.Visible=true
av.Visible=false
aw.Text=table.concat(O," + "):upper()
au.Size=UDim2.fromOffset(
math.max(E(aw.Text,aw.TextSize,aw.Font).X+10,20),
21
)
end

local R=ay.Text

if R=="BOUND TO"then
R=([[Bound to (<b><font color="#ffffff">%s</font></b>)]]):format(tostring(aw.Text))
elseif R=="BIND REMOVED"then
R="Bind Removed"
else
R=nil
end

if R~=nil and an.Name~=nil then
d:CreateNotification(an.Name,R,1.5,"info")
end
if#O>0 and not Q then
d:CheckBounds(aw.Text,ao.Name)
end
ao.InternalAddOnChange:Fire()
end

function ao.Toggle(N,O)
if d.ThreadFix then
setthreadidentity(8)
end
N.Enabled=not N.Enabled
N.Toggled:Fire()
K.Visible=N.Enabled
as.Enabled=N.Enabled
ar.TextColor3=(aq or at.Visible)and o.Text
or m.Dark(o.Text,0.16)
ar.BackgroundColor3=(aq or at.Visible)and m.Light(o.Main,0.02)
or o.Main
I.ImageColor3=N.Enabled and Color3.fromRGB(50,50,50)or m.Light(o.Main,0.37)
av.ImageColor3=m.Dark(o.Text,0.43)
aw.TextColor3=m.Dark(o.Text,0.43)
if not N.Enabled then
for P,Q in N.Connections do
if type(Q)=="function"then
pcall(Q)
else
pcall(function()
Q:Disconnect()
end)
end
end
table.clear(N.Connections)
end
if not O then
d:UpdateTextGUI()
end
task.spawn(an.Function,N.Enabled)
end

for N,O in H do
ao["Create"..N]=function(P,Q)
return O(Q,at,ao)
end
ao["Add"..N]=ao["Create"..N]
end

au.MouseEnter:Connect(function()
aw.Visible=false
av.Visible=not aw.Visible
av.Image=u"vape/assets/new/edit.png"
if not ao.Enabled then
av.ImageColor3=m.Dark(o.Text,0.16)
end
end)
au.MouseLeave:Connect(function()
aw.Visible=#ao.Bind>0
av.Visible=not aw.Visible
av.Image=u"vape/assets/new/bind.png"
if not ao.Enabled then
av.ImageColor3=m.Dark(o.Text,0.43)
end
end)
au.Activated:Connect(function()
ay.Text="PRESS A KEY TO BIND"
ax.Size=UDim2.fromOffset(E(ay.Text,ay.TextSize).X+20,40)
ax.Visible=true
d.Binding=ao
end)
az.Activated:Connect(function()
ao:ToggleStar()
end)
aC.MouseEnter:Connect(function()
if not ao.Enabled then
I.ImageColor3=o.Text
end
end)
aC.MouseLeave:Connect(function()
if not ao.Enabled then
I.ImageColor3=m.Light(o.Main,0.37)
end
end)
aC.Activated:Connect(function()

if at.Visible then
closeOptions()
else
openOptions()
end
end)
aC.MouseButton2Click:Connect(function()

if at.Visible then
closeOptions()
else
openOptions()
end
end)
ar.MouseEnter:Connect(function()
aq=true
if not ao.Enabled and not at.Visible then
ar.TextColor3=o.Text
ar.BackgroundColor3=m.Light(o.Main,0.02)
end
au.Visible=#ao.Bind>0 or aq or at.Visible
az.Visible=ao.StarActive or aq or at.Visible
end)
ar.MouseLeave:Connect(function()
aq=false
if not ao.Enabled and not at.Visible then
ar.TextColor3=m.Dark(o.Text,0.16)
ar.BackgroundColor3=o.Main
end
au.Visible=#ao.Bind>0 or aq or at.Visible
az.Visible=ao.StarActive or aq or at.Visible
end)
at:GetPropertyChangedSignal"Visible":Connect(function()
local N=at.Visible
if N then
if count(ao.Options)<=0 then
d:CreateNotification("Vape",`<font color="#ff8080"><b>⚠ No options found</b></font> for <font color="#7db8ff"><b>{tostring(an.Name)}</b></font> :c`,3)
at.Visible=false
end
end
end)
ar.Activated:Connect(function()
ao:Toggle()
end)
ar.MouseButton2Click:Connect(function()

if at.Visible then
closeOptions()
else
openOptions()
end
end)
if d.isMobile then
local N=false
local O

ar.MouseButton1Down:Connect(function()
N=true
local P,Q=tick(),h:GetMouseLocation()
local R=0.75


local S=Instance.new"Frame"
S.Name="HoldProgress"
S.Size=UDim2.new(0,0,0,3)
S.Position=UDim2.new(0,0,1,-3)
S.BackgroundColor3=Color3.fromRGB(100,150,255)
S.BorderSizePixel=0
S.Parent=ar

n:Tween(
S,
TweenInfo.new(R,Enum.EasingStyle.Linear),
{Size=UDim2.new(1,0,0,3)}
)

repeat
N=(h:GetMouseLocation()-Q).Magnitude<10
task.wait()
until(tick()-P)>R or not N or not v.Visible or d.Loaded==nil

if S and S.Parent then
S:Destroy()
end

if N and v.Visible then
if d.ThreadFix then
setthreadidentity(8)
end


O=Instance.new"Frame"
O.Name="BindingOverlay"
O.Size=UDim2.fromScale(1,1)
O.Position=UDim2.fromScale(0,0)
O.BackgroundColor3=Color3.fromRGB(0,0,0)
O.BackgroundTransparency=0.5
O.BorderSizePixel=0
O.ZIndex=1000
O.Parent=v.Parent

local T=Instance.new"TextLabel"
T.Size=UDim2.fromScale(0.8,0.2)
T.Position=UDim2.fromScale(0.5,0.4)
T.AnchorPoint=Vector2.new(0.5,0.5)
T.BackgroundColor3=m.Dark(o.Main,0.1)
T.BackgroundTransparency=0
T.BorderSizePixel=0
T.Text="TAP ANYWHERE TO SET BUTTON POSITION"
T.TextColor3=o.Text
T.TextSize=18
T.TextWrapped=true
T.FontFace=o.Font
T.Parent=O

addCorner(T,UDim.new(0,8))

local U=Instance.new"TextLabel"
U.Size=UDim2.fromScale(0.8,0.1)
U.Position=UDim2.fromScale(0.5,0.55)
U.AnchorPoint=Vector2.new(0.5,0)
U.BackgroundTransparency=1
U.Text="Module: "..an.Name
U.TextColor3=Color3.fromRGB(150,200,255)
U.TextSize=14
U.FontFace=o.Font
U.Parent=O


local V=n:Tween(
T,
TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut,-1,true),
{TextTransparency=0.3}
)

v.Visible=false
z.Visible=false
d:BlurCheck()


for W,X in d.Modules do
if X.Bind.Button then
X.Bind.Button.Visible=true
X.Bind.Button.BackgroundTransparency=0.7
end
end

local W
W=h.InputBegan:Connect(function(X)
if X.UserInputType==Enum.UserInputType.Touch then
if d.ThreadFix then
setthreadidentity(8)
end


if V then
V:Cancel()
end
if O then
O:Destroy()
end


createMobileButton(
ao,
X.Position+Vector3.new(0,j:GetGuiInset().Y,0)
)


d:CreateNotification(
"Mobile Bind Created",
"<font color='#FFFFFF'>Button for </font><font color='#7db8ff'><b>"
..an.Name
.."</b></font><font color='#FFFFFF'> has been placed!</font>",
2
)

v.Visible=true
d:BlurCheck()


for Y,Z in d.Modules do
if Z.Bind.Button then
Z.Bind.Button.Visible=false
Z.Bind.Button.BackgroundTransparency=0
end
end

W:Disconnect()
end
end)



local X

X=task.delay(15,function()
if W then
W:Disconnect()
end
if O then
O:Destroy()
end
if V then
V:Cancel()
end

v.Visible=true
d:BlurCheck()

for Y,Z in d.Modules do
if Z.Bind.Button then
Z.Bind.Button.Visible=false
Z.Bind.Button.BackgroundTransparency=0
end
end

d:CreateNotification(
"Binding Cancelled",
"<font color='#ff8080'>Mobile bind timed out</font>",
2
)
end)
else

if S and S.Parent then
S:Destroy()
end
end
end)

ar.MouseButton1Up:Connect(function()
N=false
end)
end
J:GetPropertyChangedSignal"AbsoluteContentSize":Connect(function()
if d.ThreadFix then
setthreadidentity(8)
end
at.Size=UDim2.new(1,0,0,J.AbsoluteContentSize.Y/A.Scale)
end)

function ao.SetVisible(N,O)
if O==nil then
O=not N.Object.Visible
end
N.Object.Visible=O
end

ao.Object=ar
ao.Children=at

d.Modules[an.SavingID or an.Name]=ao

updateModuleSorting()
















function ao.Restart(N)
if N.Enabled then
N:Toggle()
task.wait(0.1)
if N.Enabled then return end
N:Toggle()
end
end

return ao
end

function ac.Expand(am,an)
if an~=nil then
if an==am.Expanded then return end
am.Expanded=an
else
am.Expanded=not am.Expanded
end
n:Tween(ai,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
Rotation=am.Expanded and 0 or 180,
})
if not d.Loaded then
aj.Visible=am.Expanded
ad.Size=UDim2.fromOffset(
220,
am.Expanded and math.min(41+al.AbsoluteContentSize.Y/A.Scale,601)or 41
)
else
if am.Expanded then
aj.Visible=true
end
n:Tween(ad,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
Size=UDim2.fromOffset(
220,
am.Expanded and math.min(41+al.AbsoluteContentSize.Y/A.Scale,601)or 41
)
})





end
ak.Visible=aj.CanvasPosition.Y>10 and aj.Visible
end

if not ac.Expanded and ab.Visible then
ac:Expand()
end

ag.Activated:Connect(function()



print(ah())
if not ah()then
return
end
ac:Expand()
end)
ag.MouseButton2Click:Connect(function()
ac:Expand()
end)
ag.MouseEnter:Connect(function()
ai.ImageColor3=Color3.fromRGB(220,220,220)
end)
ag.MouseLeave:Connect(function()
ai.ImageColor3=Color3.fromRGB(140,140,140)
end)
aj:GetPropertyChangedSignal"CanvasPosition":Connect(function()
if aa.ThreadFix then
setthreadidentity(8)
end
ak.Visible=aj.CanvasPosition.Y>10 and aj.Visible
end)
ad.InputBegan:Connect(function(am)
if
am.Position.Y<ad.AbsolutePosition.Y+41
and am.UserInputType==Enum.UserInputType.MouseButton2
then
ac:Expand()
end
end)
al:GetPropertyChangedSignal"AbsoluteContentSize":Connect(function()
if aa.ThreadFix then
setthreadidentity(8)
end
aj.CanvasSize=UDim2.fromOffset(0,al.AbsoluteContentSize.Y/A.Scale)
if ac.Expanded then
ad.Size=UDim2.fromOffset(220,math.min(41+al.AbsoluteContentSize.Y/A.Scale,601))
end
end)

function ac.SetVisible(am,an)
if an==nil then
an=not am.Object.Visible
end
am.LockedVisibility=an
am.Object.Visible=an
if an==false then
pcall(function()
am.Button.Object.Visible=false
end)
end
end

function ac.CreateModuleCategory(am,an)
local ao,ap=pcall(function()
local ao={
Type="ModuleCategory",
Expanded=false,
Modules={},
Name=an.Name,
CategoryApi=ac,
ExpandEvent=c(`ModuleCategory_ExpandEvent_{tostring(an.Name)}_{tostring(ac.Name)}`),
UpExpand=an.UpExpand or false,
}


local ap
success,err=pcall(function()
ap=Instance.new"Frame"
ap.Name=an.Name.."ModuleCategory"
ap.Size=UDim2.fromOffset(220,45)
ap.BackgroundColor3=an.BackgroundColor or m.Dark(o.Main,0.08)
ap.BorderSizePixel=0
if not(aj~=nil and aj.Parent~=nil)then
error(`{an.Name}: Category Children are invalid!`)
return
end
ap.Parent=aj
end)
if not success then
warn("[ModuleCategory] Frame creation failed:",err)
return
end


success,err=pcall(function()
addTooltip(
ap,
an.Name
.." "
..(an.Name~="Special"and"Special Category"or"Category")
)
end)
if not success then
warn("[ModuleCategory] Tooltip failed:",err)
end


if an.StrokeColor then
success,err=pcall(function()
local aq=Instance.new"UIStroke"
aq.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
aq.Color=an.StrokeColor
aq.Thickness=an.StrokeThickness or 1
aq.Transparency=an.StrokeTransparency or 0.5
aq.Parent=ap
if an.GuiColorSync then
connectguicolorchange(function(ar,as,at)
aq.Color=Color3.fromHSV(ar,as,at)
end)
end
end)
if not success then
warn("[ModuleCategory] Stroke creation failed:",err)
end
end


success,err=pcall(function()
addCorner(ap,UDim.new(0,4))
end)
if not success then
warn("[ModuleCategory] Corner failed:",err)
end


local aq
success,err=pcall(function()
aq=Instance.new"TextButton"
aq.Name="Header"
aq.Size=UDim2.fromOffset(220,45)

if ao.UpExpand then
aq.AnchorPoint=Vector2.new(0,1)
aq.Position=UDim2.new(0,0,1,0)
else
aq.Position=UDim2.fromOffset(0,0)
end

aq.BackgroundTransparency=1
aq.BorderSizePixel=0
aq.AutoButtonColor=false
aq.Text=""
aq.Parent=ap
end)
if not success then
warn("[ModuleCategory] Header button creation failed:",err)
return
end


local ar
success,err=pcall(function()
ar=Instance.new"Frame"
ar.Name="AccentBar"
ar.Size=UDim2.fromOffset(3,45)

ar.Position=ao.UpExpand and UDim2.new(0,0,1,-45)or UDim2.fromOffset(0,0)

ar.BackgroundColor3=an.AccentColor
or an.StrokeColor
or Color3.fromRGB(100,150,255)
ar.BorderSizePixel=0
ar.Parent=ap

if an.GuiColorSync then
connectguicolorchange(function(as,at,au)
ar.BackgroundColor3=Color3.fromHSV(as,at,au)
end)
end

local as=Instance.new"UICorner"
as.CornerRadius=UDim.new(0,4)
as.Parent=ar
end)
if not success then
warn("[ModuleCategory] Accent bar creation failed:",err)
end


local as
success,err=pcall(function()
as=Instance.new"ImageLabel"
as.Name="Icon"
as.Size=an.Size or UDim2.fromOffset(20,20)
as.Position=UDim2.fromOffset(15,15)
as.BackgroundTransparency=1
as.Image=an.Icon or""
as.ImageColor3=o.Text
as.Parent=aq
end)
if not success then
warn("[ModuleCategory] Icon creation failed:",err)
end


local at
success,err=pcall(function()
at=Instance.new"TextLabel"
at.Name="Title"
at.Size=UDim2.new(1,-90,0,45)
at.Position=UDim2.fromOffset(45,0)
at.BackgroundTransparency=1
at.Text=an.Name
at.TextXAlignment=Enum.TextXAlignment.Left
at.TextColor3=o.Text
at.TextSize=14
at.FontFace=Font.new(o.Font.Family,Enum.FontWeight.SemiBold)
at.Parent=aq
end)
if not success then
warn("[ModuleCategory] Title creation failed:",err)
end


local au
success,err=pcall(function()
au=Instance.new"TextLabel"
au.Name="Count"
au.Size=UDim2.fromOffset(40,45)
au.Position=UDim2.new(1,-85,0,0)
au.BackgroundTransparency=1
au.Text="0"
au.TextXAlignment=Enum.TextXAlignment.Right
au.TextColor3=m.Dark(o.Text,0.4)
au.TextSize=12
au.FontFace=o.Font
au.Parent=aq
end)
if not success then
warn("[ModuleCategory] Count label creation failed:",err)
end


local av,aw
success,err=pcall(function()
av=Instance.new"TextButton"
av.Name="Arrow"
av.Size=UDim2.fromOffset(45,45)
av.Position=UDim2.new(1,-45,0,0)
av.BackgroundTransparency=1
av.Text=""
av.Parent=aq

aw=Instance.new"ImageLabel"
aw.Name="Arrow"
aw.Size=UDim2.fromOffset(12,7)
aw.Position=UDim2.fromOffset(17,19)
aw.BackgroundTransparency=1
aw.Image=u"vape/assets/new/expandup.png"
aw.ImageColor3=o.Text

aw.Rotation=ao.UpExpand and 0 or 180

aw.Parent=av
end)
if not success then
warn("[ModuleCategory] Arrow button creation failed:",err)
end


success,err=pcall(function()
local ax=Instance.new"UIGradient"
ax.Color=ColorSequence.new{
ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),
ColorSequenceKeypoint.new(1,Color3.fromRGB(0.95,0.95,0.95)),
}
ax.Rotation=90
ax.Parent=ap
end)
if not success then
warn("[ModuleCategory] Gradient creation failed:",err)
end


local ax,ay
success,err=pcall(function()
ax=Instance.new"Frame"
ax.Name="ModulesContainer"
ax.Size=UDim2.new(1,0,0,0)

if ao.UpExpand then
ax.AnchorPoint=Vector2.new(0,1)
ax.Position=UDim2.new(0,0,1,-45)
else
ax.Position=UDim2.fromOffset(0,45)
end

ax.BackgroundTransparency=1
ax.BorderSizePixel=0
ax.Visible=false
ax.ClipsDescendants=true
ax.Parent=ap

ay=Instance.new"UIListLayout"
ay.SortOrder=Enum.SortOrder.LayoutOrder
ay.HorizontalAlignment=Enum.HorizontalAlignment.Center
ay.Padding=UDim.new(0,2)

ay.VerticalAlignment=ao.UpExpand and Enum.VerticalAlignment.Bottom or Enum.VerticalAlignment.Top

ay.Parent=ax
end)
if not success then
warn("[ModuleCategory] Modules container creation failed:",err)
return
end

local function updateCount()
success,err=pcall(function()
au.Text=tostring(#ao.Modules)
end)
if not success then
warn("[ModuleCategory] updateCount failed:",err)
end
end

function ao.Toggle(az,aA)
success,err=pcall(function()
if aA~=nil then
if aA==az.Expanded then
return
end
az.Expanded=aA
else
az.Expanded=not az.Expanded
end

ao.ExpandEvent:Fire()

local aB=az.Expanded and ay.AbsoluteContentSize.Y/A.Scale or 0

task.spawn(function()
flickerTextEffect(at,true,an.Name)
end)

local aC=az.UpExpand and 180 or 0
local I=az.UpExpand and 0 or 180

n:Tween(aw,TweenInfo.new(0.25,Enum.EasingStyle.Quad),{
Rotation=az.Expanded and aC or I,
ImageColor3=az.Expanded
and(an.AccentColor or an.StrokeColor or Color3.fromRGB(
100,
150,
255
))
or o.Text,
})

n:Tween(as,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
ImageColor3=az.Expanded
and(an.AccentColor or an.StrokeColor or Color3.fromRGB(
100,
150,
255
))
or o.Text,
})

n:Tween(as,TweenInfo.new(0.5,Enum.EasingStyle.Quad),{
Rotation=az.Expanded and 360 or 0,
})

n:Tween(ap,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
BackgroundColor3=az.Expanded and m.Dark(o.Main,0.12)
or(an.BackgroundColor or m.Dark(o.Main,0.08)),
})

ax.Visible=true
n:Tween(ax,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
Size=UDim2.new(1,0,0,aB),
})

if az.UpExpand then
n:Tween(ap,TweenInfo.new(0.3,Enum.EasingStyle.Quad),{
Size=UDim2.fromOffset(220,45+aB),
Position=UDim2.fromOffset(0,-(az.Expanded and aB or 0)),
})
else
n:Tween(ap,TweenInfo.new(0.3,Enum.EasingStyle.Quad),{
Size=UDim2.fromOffset(220,45+aB),
})
end

if not az.Expanded then
task.delay(0.3,function()
if not az.Expanded then
ax.Visible=false
end
end)
end
end)
if not success then
warn("[ModuleCategory] Toggle failed:",err)
end
end

function ao.Expand(az)
az:Toggle()
end

function ao.Load(az,aA)
success,err=pcall(function()
for aB,aC in aA do
local I=d.Modules[aC]
if I then
az:AddModule(I)
end
end
end)
if not success then
warn("[ModuleCategory] Load failed:",err)
end
end

function ao.AddModule(az,aA)
success,err=pcall(function()
if not aA or not aA.Object then
return
end

table.insert(az.Modules,aA)
updateCount()

aA.Object.Parent=ax
if aA.Children then
aA.Children.Parent=ax
end
aA.ModuleCategory=ao
end)
if not success then
warn("[ModuleCategory] AddModule failed:",err)
end

return aA
end

function ao.AddToggle(az,aA)
local aB
aB=ac:CreateModule{
Name=aA.Name,
Function=function(aC)
task.spawn(function()
if aA.Enabled~=aC then
aA:Toggle()
end
end)
end,
Default=aA.Enabled,
Tooltip=aA.Name,
NoSave=true,
}
aA.Toggled:Connect(function()
if aB.Enabled~=aA.Enabled then
print("toggleapi called",aA.Name,aA.Enabled,aB.Enabled)
aB:Toggle()
end
end)
az:AddModule(aB)
end

function ao.SetVisible(az,aA)
success,err=pcall(function()
if aA==nil then
aA=not ap.Visible
end
ap.Visible=aA
end)
if not success then
warn("[ModuleCategory] SetVisible failed:",err)
end
end

ao.Button={Toggle=function()end}

function ao.CreateModule(az,aA)
local aB
success,err=pcall(function()
aB=ac:CreateModule(aA)
az:AddModule(aB)
end)
if not success then
warn("[ModuleCategory] CreateModule failed:",err)
end
return aB
end


success,err=pcall(function()
aq.Activated:Connect(function()
ao:Toggle()
end)

av.Activated:Connect(function()
ao:Toggle()
end)

aq.MouseEnter:Connect(function()
if not ao.Expanded then
n:Tween(ap,TweenInfo.new(0.15),{
BackgroundColor3=m.Light(an.BackgroundColor or o.Main,0.05),
})
n:Tween(aw,TweenInfo.new(0.15),{
ImageColor3=an.AccentColor
or an.StrokeColor
or Color3.fromRGB(100,150,255),
})
end
end)

aq.MouseLeave:Connect(function()
if not ao.Expanded then
n:Tween(ap,TweenInfo.new(0.15),{
BackgroundColor3=an.BackgroundColor or m.Dark(o.Main,0.08),
})
n:Tween(aw,TweenInfo.new(0.15),{
ImageColor3=o.Text,
})
end
end)

ay:GetPropertyChangedSignal"AbsoluteContentSize":Connect(function()
if ao.Expanded then
local az=ay.AbsoluteContentSize.Y/A.Scale
ax.Size=UDim2.new(1,0,0,az)
ap.Size=UDim2.fromOffset(220,45+az)

if ao.UpExpand then
ap.Position=UDim2.fromOffset(0,-az)
end
end
end)
end)
if not success then
warn("[ModuleCategory] Event connections failed:",err)
end

ao.Object=ap
ao.Container=ax

return ao
end)

if not ao then
warn("[ModuleCategory] CreateModuleCategory failed:",ap)
return nil
end
return ao and ap
end

ad:GetPropertyChangedSignal"Visible":Connect(function()
local am=ac
if am.LockedVisibility==nil then return end
if ad.Visible~=am.LockedVisibility then
ad.Visible=am.LockedVisibility
end
end)

ac.Button=aa.Categories.Main:CreateButton{
Name=ab.Name,
Icon=ab.Icon,
Size=ab.Size,
Window=ad,
Default=ab.Visible
}
function ac.ToggleCategoryButton(am,an)
ac.Button:Toggle(an)
end
if ac.Button~=nil and ac.Button.Object~=nil and ac.Button.Object.Parent~=nil then
ac.Button.Object:GetPropertyChangedSignal"Visible":Connect(function()
local am=ac
if am.LockedVisibility==nil then return end
if am.LockedVisibility then return end
ac.Button.Object.Visible=false
end)
end

ac.Object=ad
aa.Categories[ab.Name]=ac

return ac
end

local aa=shared.LANGUAGE_FLAGS_CACHE
or F(
function()
return game:GetService"HttpService":JSONDecode(
d.http_function(
`https://raw.githubusercontent.com/VapeVoidware/translations/main/LanguageFlags.json`,
true
)
)
end,
10,
function(aa,ab)
if not(aa and ab~=nil and type(ab)=="table")then
return F(
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
F(function()
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
d.LanguageFlags=aa

local ab=shared.TargetLanguage and tostring(shared.TargetLanguage)
or F(
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
or F(
function()
return game:GetService"HttpService":JSONDecode(
d.http_function(
`https://raw.githubusercontent.com/VapeVoidware/translations/main/Languages.json`,
true
)
)
end,
10,
function(ac,ad)
if not(ac and ad~=nil and type(ad)=="table")then
return F(
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
F(function()
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
or F(
function()
if ab=="en"then
return{}
end
if tostring(shared.environment)=="translator_env"and isfolder"voidware_translations"and D(`voidware_translations/{ab}.json`)then
return decode(readfile(`voidware_translations/{ab}.json`))
end
return decode(
d.http_function(
`https://raw.githubusercontent.com/VapeVoidware/translations/main/locales/{ab}.json`,
true
)
)
end,
10,
function(ac,ad)
if not(ac and ad~=nil and type(ad)=="table")then
return F(
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
F(function()
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
d.TranslationAPI=ac

shared.REVERT_TRANSLATION_META={}

local ad={}
local ae={}
function d.GetTranslation(af,ag)
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

d.CreateCategory=customHook(d.CreateCategory,function(af,ag)
if ag.Name then

end
return{af,ag}
end,function(af)
af.CreateModule=customHook(af.CreateModule,function(ag,ah)
if ah.Name then
ah.SavingID=ah.Name

end
if ah.Tooltip then
ah.Tooltip=d:GetTranslation(ah.Tooltip)
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

function d.CreateOverlay(af,ag)
local ah
ag.Size=ag.Size or UDim2.fromOffset(14,14)
ag.Position=ag.Position or UDim2.fromOffset(12,14)
if ag.CustomOverlay then
ag.Pinned=true
ag.CategorySize=100
ag.Size=UDim2.fromOffset(14,14)
end

local ai
ai={
Type="Overlay",
Expanded=false,
UpExpand=ag.UpExpand or false,
Button=af.Overlays:CreateToggle{
Name=ag.Name,
Function=function(aj)
ah.Visible=aj and(v.Visible or ai.Pinned)
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

if d.OverlaysModuleCategory then
d.OverlaysModuleCategory:AddToggle(ai.Button,ag.Star)
end

ah=Instance.new"TextButton"
ah.Name=ag.Name.."Overlay"
ah.Size=UDim2.fromOffset(ag.CategorySize or 220,41)
ah.Position=UDim2.fromOffset(240,46)
ah.BackgroundColor3=o.Main
ah.AutoButtonColor=false
ah.Visible=false
ah.Text=""
ah.Parent=w

ai.WindowXOffset=(ag.CategorySize or 220)

local aj=addBlur(ah)
addCorner(ah)
makeDraggable(ah)

local ak=Instance.new"ImageLabel"
ak.Name="Icon"
ak.Size=ag.Size
ak.Position=UDim2.fromOffset(12,(ak.Size.X.Offset>14 and 14 or 13))
ak.BackgroundTransparency=1
ak.Image=ag.Icon
ak.ImageColor3=o.Text
ak.Parent=ah

local al=Instance.new"TextLabel"
al.Name="Title"
al.Size=UDim2.new(1,-32,0,41)
al.Position=UDim2.fromOffset(math.abs(al.Size.X.Offset),0)
al.BackgroundTransparency=1
al.Text=ag.Name
al.TextXAlignment=Enum.TextXAlignment.Left
al.TextColor3=o.Text
al.TextSize=13
al.FontFace=o.Font
al.Parent=ah

local am=Instance.new"ImageButton"
am.Name="Pin"
am.Size=UDim2.fromOffset(16,16)
am.Position=UDim2.new(1,-47,0,12)
am.BackgroundTransparency=1
am.AutoButtonColor=false
am.Image=u"vape/assets/new/pin.png"
am.ImageColor3=m.Dark(o.Text,0.43)
am.Parent=ah
am.Visible=not ag.Pinned

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
ao.Image=u"vape/assets/new/dots.png"
ao.ImageColor3=m.Light(o.Main,0.37)
ao.Parent=an

local ap=Instance.new"Frame"
ap.Name="CustomChildren"
ap.Size=UDim2.new(1,0,0,ag.CustomOverlay and 40 or 200)
ap.Position=UDim2.fromScale(0,1)
ap.BackgroundTransparency=1
ap.Parent=ah

local aq=Instance.new"ScrollingFrame"
aq.Name="Children"
aq.Size=UDim2.new(1,0,1,-41)

if ai.UpExpand then
aq.AnchorPoint=Vector2.new(0,1)
aq.Position=UDim2.new(0,0,1,-4)
else
aq.Position=UDim2.fromOffset(0,37)
end

aq.BackgroundColor3=m.Dark(o.Main,0.02)
aq.BorderSizePixel=0
aq.Visible=false
aq.ScrollBarThickness=2
aq.ScrollBarImageTransparency=0.75
aq.CanvasSize=UDim2.new()
aq.Parent=ah

local ar=Instance.new"UIListLayout"
ar.SortOrder=Enum.SortOrder.LayoutOrder
ar.HorizontalAlignment=Enum.HorizontalAlignment.Center
ar.VerticalAlignment=ai.UpExpand and Enum.VerticalAlignment.Bottom or Enum.VerticalAlignment.Top
ar.Parent=aq

addMaid(ai)

function ai.Expand(as,at)
if at and not aj.Visible then
return
end
as.Expanded=not as.Expanded
aq.Visible=as.Expanded
ao.ImageColor3=as.Expanded and o.Text or m.Light(o.Main,0.37)

local au=ar.AbsoluteContentSize.Y/A.Scale
local av=math.min(41+au,601)

if as.Expanded then
if as.UpExpand then
n:Tween(ah,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
Size=UDim2.fromOffset(220,av),
Position=UDim2.fromOffset(ah.Position.X.Offset,ah.Position.Y.Offset-(av-41)),
})
else
n:Tween(ah,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
Size=UDim2.fromOffset(220,av),
})
end
else
if as.UpExpand then
local aw=ah.Size.Y.Offset
n:Tween(ah,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
Size=UDim2.fromOffset(as.WindowXOffset,41),
Position=UDim2.fromOffset(ah.Position.X.Offset,ah.Position.Y.Offset+(aw-41)),
})
else
n:Tween(ah,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
Size=UDim2.fromOffset(as.WindowXOffset,41),
})
end
end
end

function ai.Pin(as)
as.Pinned=not as.Pinned
if ag.Pinned then
as.Pinned=true
end
am.ImageColor3=as.Pinned and o.Text or m.Dark(o.Text,0.43)
end

if ag.Pinned then
ai.Pinned=true
end

function ai.Update(as)
ah.Visible=as.Button.Enabled and(v.Visible or as.Pinned)
if as.Expanded then
as:Expand()
end
if v.Visible then
ah.Size=UDim2.fromOffset(ah.Size.X.Offset,41)
ah.BackgroundTransparency=0
aj.Visible=true
ak.Visible=true
al.Visible=true
am.Visible=not ag.Pinned
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

for as,at in H do
ai["Create"..as]=function(au,av)
return at(av,aq,ai)
end
ai["Add"..as]=ai["Create"..as]
end

an.MouseEnter:Connect(function()
if not aq.Visible then
ao.ImageColor3=o.Text
end
end)
an.MouseLeave:Connect(function()
if not aq.Visible then
ao.ImageColor3=m.Light(o.Main,0.37)
end
end)
an.Activated:Connect(function()
ai:Expand(true)
end)
an.MouseButton2Click:Connect(function()
ai:Expand(true)
end)
connectDoubleClick(an,function()
if not ai.Expanded then
ai:Expand(true)
end
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
aq.CanvasSize=UDim2.fromOffset(0,ar.AbsoluteContentSize.Y/A.Scale)
if ai.Expanded then
local as=ar.AbsoluteContentSize.Y/A.Scale
local at=math.min(41+as,601)

if ai.UpExpand then
local au=ah.Size.Y.Offset
local av=at-au
ah.Size=UDim2.fromOffset(ah.Size.X.Offset,at)
ah.Position=UDim2.fromOffset(ah.Position.X.Offset,ah.Position.Y.Offset-av)
else
ah.Size=UDim2.fromOffset(ah.Size.X.Offset,at)
end
end
end)
af:Clean(v:GetPropertyChangedSignal"Visible":Connect(function()
ai:Update()
end))

ai:Update()
ai.Object=ah
ai.Children=ap
af.Overlays[ag.Name]=ai
af.Categories[ag.Name]=ai

return ai
end

local af=Instance.new"BindableEvent"
function d.CreateProfilesGUI(ag,ah)
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
aw.BackgroundColor3=o.Main
aw.BackgroundColor3=Color3.fromRGB(20,20,20)
aw.Visible=false
aw.Parent=w
x=aw
addBlur(aw)
addCorner(aw)
makeDraggable(aw)

ai.Window=aw
table.insert(d.Windows,aw)


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
g:Create(ay,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(10,160,120)}):Play()
end)
ay.MouseLeave:Connect(function()
if av then return end
g:Create(ay,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(5,134,105)}):Play()
end)


local az=Instance.new"Frame"
az.Name="UploadPopup"
az.Parent=aw
az.AnchorPoint=Vector2.new(0.5,0.5)
az.Position=UDim2.fromScale(0.5,0.55)
az.Size=UDim2.fromOffset(420,320)
az.BackgroundColor3=m.Dark(o.Main,0.1)
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

local aC=true


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
for N,O in d.Profiles do
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
P.BackgroundColor3=Color3.fromHSV(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
end)
end
J.CanvasSize=UDim2.fromOffset(0,L.AbsoluteContentSize.Y+10)
end

populateLocalProfiles()


local N=Instance.new"TextBox"
N.Parent=az
N.BackgroundColor3=m.Light(o.Main,0.3)
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
O.BackgroundColor3=m.Light(o.Main,0.3)
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
g:Create(T,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(220,50,50)}):Play()
end)
T.MouseLeave:Connect(function()
if at then return end
g:Create(T,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(180,40,40)}):Play()
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
g:Create(U,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(130,100,230)}):Play()
end)
U.MouseLeave:Connect(function()
if au then return end
g:Create(U,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(100,80,200)}):Play()
end)

local function revertToNormalMode(V)
au=false
if not V then
as()
end

for W,X in ai do
if X.instance and X.deleteIcon and X.canDelete and not X.specialDelete then
X.deleteIcon.Image=u("trash",true)
n:Tween(X.deleteIcon,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{
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
X.deleteIcon.Image=u("upload",true)
n:Tween(X.deleteIcon,TweenInfo.new(0.3,Enum.EasingStyle.Quad),{
BackgroundColor3=Color3.fromRGB(70,60,140)
})


local Y=Instance.new"UIStroke"
Y.Name="UpdateStroke"
Y.Color=Color3.fromRGB(130,100,230)
Y.Thickness=0
Y.Transparency=1
n:Tween(Y,TweenInfo.new(0.3,Enum.EasingStyle.Quad),{
Thickness=1.5,
Transparency=0.3
})
Y.Parent=X.deleteIcon
end
end
if V==0 then
flickerTextEffect(U,true,"UPDATE CONFIG")
n:Tween(U,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(100,80,200),
})
revertToNormalMode(true)
ar("No Configs To Update :c",true)
task.delay(1.3,function()
as()
end)
else
d:CreateNotification("Vape","Click the upload icon on any of your configs to update them",5,"info")
ar("Click the 'Upload' icon to update a config",true)
end
end

al:Connect(function(V)
if V=="Update"then return end
if au then
flickerTextEffect(U,true,"UPDATE CONFIG")
n:Tween(U,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(100,80,200),
})
revertToNormalMode()
end
end)

U.Activated:Connect(function()
if not getgenv().username or not getgenv().password then
d:CreateNotification("Vape","You must be logged in to update configs",6,"warning")
return
end

al:Fire"Update"

if au then

flickerTextEffect(U,true,"UPDATE CONFIG")
n:Tween(U,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(100,80,200),
})
revertToNormalMode()
d:CreateNotification("Vape","Update mode cancelled",3,"info")
else

flickerTextEffect(U,true,"STOP UPDATING")
n:Tween(U,TweenInfo.new(0.15),{
BackgroundColor3=m.Dark(Color3.fromRGB(100,80,200),0.3)
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

local aD={
["6872265039"]="BW Lobby",
["6872274481"]="BW Game"
}

local function createPlaceFilterButton(aE,aF)
local aG=Instance.new"TextButton"
aG.Name=aD[aE]or aE
aG.Parent=Y
aG.ZIndex=3
aG.BackgroundColor3=Color3.fromHSV(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
aG.BackgroundTransparency=(X==aF)and 0 or 0.8
aG.Size=UDim2.fromOffset(85,28)
aG.Font=Enum.Font.GothamBold
aG.Text=aG.Name:upper()
aG.TextColor3=Color3.new(1,1,1)
aG.TextSize=10
aG.TextTransparency=(X==aF)and 0 or 0.6
aG.AutoButtonColor=false
addCorner(aG)

local aH={
Button=aG,
PlaceId=aF,
SetActive=function(aH,aI)
aG.BackgroundTransparency=aI and 0 or 0.8
aG.TextTransparency=aI and 0 or 0.6
end,
}

aG.Activated:Connect(function()
X=aF
for aI,aJ in _ do
aJ:SetActive(false)
end
aH:SetActive(true)
ao()
end)

connectguicolorchange(function(aI,aJ,aK)
aG.BackgroundColor3=Color3.fromHSV(aI,aJ,aK)
end)

table.insert(_,aH)
return aH
end

local function populateDeleteConfigs()
for aE,aF in J:GetChildren()do
if aF:IsA"TextButton"or aF:IsA"TextLabel"then
aF:Destroy()
end
end

local aE={}
for aF,aG in V do
local aH=tostring(aG.place or"")
if X=="all"then
table.insert(aE,aG)
elseif X=="no_place"then
if aH==""or aH=="nil"then
table.insert(aE,aG)
end
else
if aH==X then
table.insert(aE,aG)
end
end
end

if#aE==0 then
local aF=Instance.new"TextLabel"
aF.Parent=J
aF.BackgroundTransparency=1
aF.Size=UDim2.new(1,-10,0,40)
aF.Text="No configs found for this filter"
aF.TextColor3=Color3.fromRGB(150,150,150)
aF.Font=Enum.Font.Gotham
aF.TextSize=13
return
end

for aF,aG in aE do
local aH=Instance.new"TextButton"
aH.Parent=J
aH.BackgroundColor3=Color3.fromRGB(40,40,40)
aH.Size=UDim2.new(1,-10,0,40)

local aI=""
local aJ=tostring(aG.place or"")
if aJ~=""and aJ~="nil"then
aI=" [Place: "..aJ.."]"
end

aH.Text=aG.name..aI.." (Last Edited: "..timestampToDate(aG.edited)..")"
aH.TextColor3=Color3.new(1,1,1)
aH.Font=Enum.Font.Gotham
aH.TextSize=14
aH.TextTruncate=Enum.TextTruncate.AtEnd
addCorner(aH)

aH.Activated:Connect(function()
W=aG.name
for aK,aL in J:GetChildren()do
if aL:IsA"TextButton"then
aL.BackgroundColor3=Color3.fromRGB(40,40,40)
end
end
aH.BackgroundColor3=Color3.fromRGB(180,40,40)
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


for aE,aF in _ do
aF.Button:Destroy()
end
_={}

if#V==0 then
Y.Visible=false
for aE,aF in J:GetChildren()do
if aF:IsA"TextButton"or aF:IsA"TextLabel"then
aF:Destroy()
end
end
local aE=Instance.new"TextLabel"
aE.Parent=J
aE.BackgroundTransparency=1
aE.Size=UDim2.new(1,-10,0,40)
aE.Text="No uploaded configs found"
aE.TextColor3=Color3.fromRGB(150,150,150)
aE.Font=Enum.Font.Gotham
aE.TextSize=13
return
end


local aE={}
local aF=false
for aG,aH in V do
local aI=tostring(aH.place or"")
if aI==""or aI=="nil"then
aF=true
else
if not table.find(aE,aI)then
table.insert(aE,aI)
end
end
end


createPlaceFilterButton("All","all")


if aF then
createPlaceFilterButton("No Place","no_place")
end


table.sort(aE)
for aG,aH in aE do
local aI=aH

if#aH>10 then
aI=aH:sub(1,8)..".."
end
createPlaceFilterButton(aI,aH)
end


for aG,aH in _ do
aH:SetActive(aH.PlaceId==X)
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

































































local aE={
oldest=function(aE,aF)
return(aE.edited or 0)<(aF.edited or 0)
end,
newest=function(aE,aF)
return(aE.edited or 0)>(aF.edited or 0)
end,
}

am:Connect(function()
if at then
flickerTextEffect(T,true,"DELETE CONFIG")
n:Tween(T,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(180,40,40),
})
as()
end
at=false
end)

al:Connect(function(aF)
if aF=="Delete"then return end
if at then
flickerTextEffect(T,true,"DELETE CONFIG")
n:Tween(T,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(180,40,40),
})
end
at=false
az.Visible=false
end)

T.Activated:Connect(function()
if not getgenv().username or not getgenv().password then
d:CreateNotification("Vape","You must be logged in to delete configs",6,"warning")
return
end
al:Fire"Delete"

d:CreateNotification("Vape","Fetching your uploaded configs...",4,"info")
ar("Fetching uploaded configs...",true)

local aF,aG=pcall(function()
return request{
Url="https://configs.vapevoidware.xyz/configs/by-username",
Method="POST",
Headers={["Content-Type"]="application/json"},
Body=l:JSONEncode{
username=getgenv().username,
password=getgenv().password,
},
}
end)

if at then
flickerTextEffect(T,true,"DELETE CONFIG")
n:Tween(T,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(180,40,40),
})
else
flickerTextEffect(T,true,"STOP DELETING")
n:Tween(T,TweenInfo.new(0.15),{
BackgroundColor3=m.Dark(Color3.fromRGB(180,40,40),0.3),
})
end

if aF and aG and aG.StatusCode==200 then
local aH=l:JSONDecode(aG.Body)
V=aH.configs or{}

if#V==0 then
d:CreateNotification("Vape","You have no uploaded configs",5,"info")
return
end

at=true
ao()
J.Visible=true
az.Visible=true
else
local aH=aG and aG.Body or"Request failed"
if aG and aG.StatusCode==401 then
aH="Invalid username/password"
else
local aI=decode(aH)
if aI~=nil and type(aI)=="table"and aI.detail~=nil then
aH=aI.detail
end
end

ar("Couldn't fetch your configs :c",true)
task.delay(0.5,function()
as()
end)
d:CreateNotification("Vape","Failed to fetch your configs: "..aH,8,"warning")
end
end)

P.Activated:Connect(function()
if at then
if not W then
d:CreateNotification("Vape","Please select a config to delete",5,"warning")
return
end

d:CreateNotification("Vape",`Deleting {W}...`,5,"info")

local aF,aG=pcall(function()
return request{
Url="https://configs.vapevoidware.xyz/configs",
Method="DELETE",
Headers={["Content-Type"]="application/json"},
Body=l:JSONEncode{
username=getgenv().username,
password=getgenv().password,
config=W,
place=tostring(d.Place or game.PlaceId)
}
}
end)

if aF and aG and aG.StatusCode==200 then
d:CreateNotification("Vape",`Successfully deleted {W}`,6,"info")
az.Visible=false
am:Fire()

task.spawn(function()
task.wait(1)
S()
end)
else
local aH=aG and aG.Body or"Unknown error"
if aG and aG.StatusCode==401 then
aH="Invalid username/password!"
else
local aI=decode(aH)
if aI~=nil and type(aI)=="table"and aI.detail~=nil then
aH=aI.detail
end
end
d:CreateNotification("Vape","Delete failed: "..aH,8,"warning")
end
else
if not M then
d:CreateNotification("Vape","Please select a local profile first",5,"warning")
return
end
if N.Text==""then
d:CreateNotification("Vape","Config name is required",5,"warning")
flickerTextEffect(N,true,"Name Required!")
task.wait(0.3)
flickerTextEffect(N,true,"")
return
end

local aF="vape/profiles/"..M..d.Place..".txt"
if not D(aF)then
d:CreateNotification("Vape","Failed to read config file. Please choose different profile :c",6,"warning")
return
end
local aG,aH=pcall(readfile,aF)
if not(aG and aH~=nil)then
d:CreateNotification("Vape","Failed to read config file. Please choose different profile :c",6,"warning")
return
end

d:CreateNotification("Vape","Publishing config...",5,"info")

local aI={
username=getgenv().username,
password=getgenv().password,
config_name=N.Text,
config=aH,
color={d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value},
description=O.Text,
}
if aC then
aI.place=d.Place or game.PlaceId
aI.place=tostring(aI.place)
end

local aJ,aK=pcall(function()
return request{
Url="https://configs.vapevoidware.xyz/configs",
Method="POST",
Headers={["Content-Type"]="application/json"},
Body=l:JSONEncode(aI)
}
end)

if aJ and aK and aK.StatusCode==200 then
local aL=aK.Body
local aM=string.find(aL,"isOverwritten")and true or false
d:CreateNotification(
"Vape",
`Successfully published "{N.Text}"`
..(aM and" (overwritten)"or"")
..(aC and" [Place Based]"or""),
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
local aL=aJ and(aK and aK.Body or"Unknown error")or tostring(aK)
if aK.StatusCode==401 then
aL="Username or Password missing/invalid!"
else
local aM=decode(aL)
if aM~=nil and type(aM)=="table"and aM.detail~=nil then
aL=aM.detail
end
end
if string.lower(aL):find"rate limit"then
ar("Please wait before uploading a config!",true)
task.delay(2,function()
ar("Click on the config you want to upload",true)
end)
end
d:CreateNotification("Vape","Failed to publish: "..aL,10,"warning")
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
n:Tween(ay,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(5,134,105),
})
av=false
as()
end
end)

al:Connect(function(aF)
if aF=="Upload"then return end
if av then
flickerTextEffect(ay,true,"UPLOAD CONFIG")
n:Tween(ay,TweenInfo.new(0.15),{
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
n:Tween(ay,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(5,134,105),
})
av=false
az.Visible=false
as()
else
flickerTextEffect(ay,true,"STOP UPLOADING")
n:Tween(ay,TweenInfo.new(0.15),{
BackgroundColor3=m.Dark(Color3.fromRGB(5,134,105),0.3),
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


local aF=Instance.new"ImageLabel"
aF.Name="Icon"
aF.Size=UDim2.fromOffset(16,16)
aF.Position=UDim2.fromOffset(16,14)
aF.BackgroundTransparency=1
aF.Image=u"vape/assets/new/profilesicon.png"
aF.ImageColor3=o.Text
aF.Parent=aw

local aG=Instance.new"TextLabel"
aG.Parent=aF
aG.BackgroundTransparency=1
aG.Position=UDim2.new(0,24,0,0)
aG.Size=UDim2.new(1,100,0,16)
aG.Font=Enum.Font.GothamBold
aG.Text="Public Profiles"
aG.TextColor3=o.Text
aG.TextSize=14
aG.TextXAlignment=Enum.TextXAlignment.Left


local aH=Instance.new"Frame"
aH.Name="BadgeContainer"
aH.Parent=aw
aH.BackgroundTransparency=1
aH.Position=UDim2.new(0,160,0,12)
aH.Size=UDim2.fromOffset(400,20)

local aI=Instance.new"UIListLayout"
aI.Parent=aH
aI.FillDirection=Enum.FillDirection.Horizontal
aI.SortOrder=Enum.SortOrder.LayoutOrder
aI.Padding=UDim.new(0,6)
aI.VerticalAlignment=Enum.VerticalAlignment.Center


if getgenv().username then
local aJ=Instance.new"Frame"
aJ.Name="UserBadge"
aJ.Parent=aH
aJ.BackgroundColor3=Color3.fromRGB(45,45,45)
aJ.Size=UDim2.fromOffset(0,20)
aJ.AutomaticSize=Enum.AutomaticSize.X
addCorner(aJ,UDim.new(0,10))

local aK=Instance.new"UIPadding"
aK.Parent=aJ
aK.PaddingLeft=UDim.new(0,8)
aK.PaddingRight=UDim.new(0,8)

local aL=Instance.new"TextLabel"
aL.Parent=aJ
aL.BackgroundTransparency=1
aL.Position=UDim2.fromOffset(4,-1)
aL.Size=UDim2.fromOffset(12,20)
aL.Font=Enum.Font.GothamBold
aL.Text="@"
aL.TextColor3=Color3.fromRGB(150,150,150)
aL.TextSize=12

local aM=Instance.new"TextLabel"
aM.Parent=aJ
aM.BackgroundTransparency=1
aM.Position=UDim2.fromOffset(16,0)
aM.Size=UDim2.fromOffset(0,20)
aM.AutomaticSize=Enum.AutomaticSize.X
aM.Font=Enum.Font.Gotham
aM.Text=tostring(getgenv().username)
aM.TextColor3=Color3.fromRGB(200,200,200)
aM.TextSize=13
aM.TextXAlignment=Enum.TextXAlignment.Left

local aN=Instance.new"UIStroke"
aN.Color=Color3.fromRGB(70,70,70)
aN.Thickness=1
aN.Parent=aJ
end


if getgenv().admin_config_api_key~=nil and shared.VoidDev then
local aJ=Instance.new"Frame"
aJ.Name="AdminBadge"
aJ.Parent=aH
aJ.BackgroundColor3=Color3.fromRGB(60,30,30)
aJ.Size=UDim2.fromOffset(0,20)
aJ.AutomaticSize=Enum.AutomaticSize.X
addCorner(aJ,UDim.new(0,10))

local aK=Instance.new"UIPadding"
aK.Parent=aJ
aK.PaddingLeft=UDim.new(0,8)
aK.PaddingRight=UDim.new(0,8)

local aL=Instance.new"TextLabel"
aL.Parent=aJ
aL.BackgroundTransparency=1
aL.Position=UDim2.fromOffset(3,-1)
aL.Size=UDim2.fromOffset(12,20)
aL.Font=Enum.Font.GothamBold
aL.Text="★"
aL.TextColor3=Color3.fromRGB(255,100,100)
aL.TextSize=12

local aM=Instance.new"TextLabel"
aM.Parent=aJ
aM.BackgroundTransparency=1
aM.Position=UDim2.fromOffset(16,0)
aM.Size=UDim2.fromOffset(0,20)
aM.AutomaticSize=Enum.AutomaticSize.X
aM.Font=Enum.Font.GothamBold
aM.Text="ADMIN"
aM.TextColor3=Color3.fromRGB(255,120,120)
aM.TextSize=13
aM.TextXAlignment=Enum.TextXAlignment.Left

local aN=Instance.new"UIStroke"
aN.Color=Color3.fromRGB(255,80,80)
aN.Thickness=1
aN.Transparency=0.3
aN.Parent=aJ
end

local aJ=Instance.new"TextLabel"
aJ.Parent=aF
aJ.BackgroundTransparency=1
aJ.Position=UDim2.new(0,24,0,0)
aJ.Size=UDim2.new(1,100,0,16)
aJ.Font=Enum.Font.GothamBold
aJ.Text="Public Profiles"
aJ.TextColor3=o.Text
aJ.TextSize=14
aJ.TextXAlignment=Enum.TextXAlignment.Left


local aK=Instance.new"ImageButton"
aK.Name="CloseButton"
aK.Size=UDim2.fromOffset(24,24)
aK.Position=UDim2.new(1,-40,0,12)
aK.BackgroundColor3=Color3.fromRGB(60,60,60)
aK.AutoButtonColor=false
aK.Image=u"vape/assets/new/close.png"
aK.ImageColor3=Color3.fromRGB(200,200,200)
aK.Parent=aw
addCorner(aK)

aK.MouseEnter:Connect(function()
g
:Create(aK,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{
BackgroundColor3=Color3.fromRGB(220,53,53),
ImageColor3=Color3.fromRGB(255,255,255),
})
:Play()
end)

aK.MouseLeave:Connect(function()
g
:Create(aK,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{
BackgroundColor3=Color3.fromRGB(60,60,60),
ImageColor3=Color3.fromRGB(200,200,200),
})
:Play()
end)

aK.Activated:Connect(function()
aw.Visible=false
v.Visible=true
if d.TutorialAPI.isActive then
d.TutorialAPI:setText"Tutorial Cancelled"
task.delay(0.3,function()
d.TutorialAPI:revertTutorialMode()
end)
end
end)

local aL=Instance.new"Frame"
aL.Parent=aw
aL.BackgroundColor3=Color3.new(1,1,1)
aL.BackgroundTransparency=0.95
aL.BorderSizePixel=0
aL.Position=UDim2.new(0,0,0,44)
aL.Size=UDim2.new(1,0,0,1)

local aM=Instance.new"Frame"
aM.Name="Search"
aM.Parent=aw
aM.BackgroundColor3=m.Dark(o.Main,0.05)
aM.BorderSizePixel=0
aM.Position=UDim2.new(0,16,0,54)
aM.Size=UDim2.fromOffset(968,40)

local aN=Instance.new"UIStroke"
aN.Color=Color3.fromRGB(42,41,42)
aN.Thickness=1
aN.Parent=aM

addCorner(aM)

local aO=Instance.new"ImageLabel"
aO.Parent=aM
aO.BackgroundTransparency=1
aO.BorderSizePixel=0
aO.Position=UDim2.new(0,14,0.5,-8)
aO.Size=UDim2.fromOffset(16,16)
aO.Image=u"vape/assets/new/search.png"
aO.ImageColor3=Color3.fromRGB(150,150,150)

local aP=Instance.new"TextBox"
aP.Parent=aM
aP.BackgroundTransparency=1
aP.BorderSizePixel=0
aP.Position=UDim2.new(0,40,0,0)
aP.Size=UDim2.new(1,-50,1,0)
aP.Font=Enum.Font.Gotham
aP.PlaceholderColor3=Color3.fromRGB(180,180,180)
aP.PlaceholderText="Search profile name or username..."
aP.Text=""
aP.TextColor3=Color3.fromRGB(200,200,200)
aP.TextSize=15
aP.TextXAlignment=Enum.TextXAlignment.Left

local aQ=Instance.new"Frame"
aQ.Parent=aw
aQ.BackgroundTransparency=1
aQ.BorderSizePixel=0
aQ.Position=UDim2.new(0,16,0,104)
aQ.Size=UDim2.fromOffset(968,32)

local aR=Instance.new"UIListLayout"
aR.Parent=aQ
aR.FillDirection=Enum.FillDirection.Horizontal
aR.SortOrder=Enum.SortOrder.LayoutOrder
aR.VerticalAlignment=Enum.VerticalAlignment.Center
aR.Padding=UDim.new(0,8)

local aS=Instance.new"ScrollingFrame"
aS.Name="Children"
aS.Parent=aw
aS.Position=UDim2.new(0,16,0,144)
aS.Size=UDim2.fromOffset(968,390)
aS.BackgroundTransparency=1
aS.BorderSizePixel=0
aS.ScrollBarThickness=3
aS.ScrollBarImageTransparency=0.5
aS.AutomaticCanvasSize=Enum.AutomaticSize.XY
aS.CanvasSize=UDim2.new()
aS.ClipsDescendants=false

local aT=Instance.new"TextLabel"
aT.Name="ConfigsInfo"
aT.Parent=aw
aT.Position=aS.Position
aT.Size=aS.Size
aT.Text="No configs found :c"
aT.BackgroundColor3=Color3.fromRGB(30,30,30)
aT.TextSize=18
aT.Visible=false

local aU={
SetStep=function(aU,aV,aW)
if aW~=nil then
aT.Visible=aW
end
if aV~=nil then
aT.Text=aV
end
end
}

S=function()
ar("Refreshing Configs...",true)
local aV,aW=F(function()
return l:JSONDecode(d.http_function"https://configs.vapevoidware.xyz")
end,3)
if not aV then
errorNotification("Voidware | Configs","Couldn't load the configs data :c Try again later",5)
ar("Couldn't load configs :c",true)
return
end

resetConfigs()
for aX,aY in aS:GetChildren()do
pcall(function()
if aY:IsA"TextButton"then
aY:Destroy()
end
end)
end
ai={Sorts=ai.Sorts}

table.sort(aW,aE[an])
local aX=0
for aY,aZ in aW do
local a_=d.Place or game.PlaceId
if not aZ.place or tostring(aZ.place)==tostring(a_)then
aX=aX+1
aS.ClipsDescendants=(aX>10)
R(aZ.name,aZ.username,aZ)
end
end
if aX<1 then
aU:SetStep("No Configs found :C",true)
else
aU:SetStep(nil,false)
end
if aj~=nil then
local aY={"all"}
for aZ,a_ in table.clone(aW)do
if not a_.username then continue end
a_.username=tostring(a_.username)
if table.find(aY,a_.username)then continue end
table.insert(aY,a_.username)
end
aj:SetValues(aY,"all")
end
as()
end
d.ConfigsAPIRefresh=function()
task.spawn(S)
end

local aV=Instance.new"UIGridLayout"
aV.Parent=aS
aV.SortOrder=Enum.SortOrder.LayoutOrder
aV.CellSize=UDim2.fromOffset(180,180)
aV.CellPadding=UDim2.fromOffset(12,12)
aV.HorizontalAlignment=Enum.HorizontalAlignment.Center

aV:GetPropertyChangedSignal"AbsoluteContentSize":Connect(function()
if ag.ThreadFix then
setthreadidentity(8)
end
aS.CanvasSize=UDim2.fromOffset(0,aV.AbsoluteContentSize.Y+20)
end)

ak:Connect(function()
local aW=aj.Value
for aX,aY in ai do
if aY.instance~=nil and aY.username~=nil then
aY.instance.Visible=(aW=="all"or tostring(aY.username)==aW)
end
end
end)

R=function(aW,aX,aY)
if ai[aW]then return end
ai[aW]=table.clone(aY)

local aZ=false
local a_=false

if getgenv().username and aX and aX:lower()==tostring(getgenv().username):lower()then
a_=true
elseif getgenv().admin_config_api_key~=nil and shared.VoidDev then
a_=true
aZ=true
end
local a0=Instance.new"TextButton"
a0.Parent=aS
a0.BackgroundTransparency=1
a0.LayoutOrder=#aS:GetChildren()+1
a0.ClipsDescendants=false
a0.AutoButtonColor=false
a0.Text=""
a0.Size=UDim2.fromOffset(220,220)

ai[aW].instance=a0

local a1,a2
if aY.color~=nil and type(aY.color)=="table"then
a1,a2=hsv(unpack(aY.color))
else
a1=false
a2=nil
end

local a3=a1 and a2~=nil and"config"or"gui"
local function getStrokeColor()
return a3=="gui"and Color3.fromHSV(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)or a2
end

local a4=Instance.new"UIStroke"
a4.Color=Color3.fromRGB(50,50,50)
if a3=="gui"then
connectguicolorchange(function(a5,a6,a7)
a4.Color=Color3.fromHSV(a5,a6,a7)
end)
else
a4.Color=a2
end
a4.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
a4.Thickness=1
a4.Parent=a0

addCorner(a0)


local a5=Instance.new"TextLabel"
a5.Parent=a0
a5.BackgroundTransparency=1
a5.Position=UDim2.new(0,12,0,12)
a5.Size=UDim2.new(1,-24,0,40)
a5.Font=Enum.Font.GothamBold
a5.RichText=true
a5.Text=aW
a5.TextColor3=Color3.fromRGB(220,220,220)
a5.TextSize=15
a5.TextWrapped=true
a5.TextXAlignment=Enum.TextXAlignment.Left
a5.TextYAlignment=Enum.TextYAlignment.Top


local a6=Instance.new"TextLabel"
a6.Parent=a0
a6.BackgroundTransparency=1
a6.Position=UDim2.new(0,12,0,52)
a6.Size=UDim2.new(1,-24,0,18)
a6.Font=Enum.Font.Gotham
a6.Text="By: @"..aX
a6.TextColor3=Color3.fromRGB(150,150,150)
a6.TextSize=15
a6.TextXAlignment=Enum.TextXAlignment.Left


local a7=Instance.new"TextLabel"
a7.Parent=a0
a7.BackgroundTransparency=1
a7.Position=UDim2.new(0,12,0,70)
a7.Size=UDim2.new(1,-24,0,65)
a7.Font=Enum.Font.Gotham
a7.Text=aY.description or"No description provided"
a7.TextColor3=Color3.fromRGB(130,130,130)
a7.TextSize=15
a7.TextWrapped=true
a7.TextXAlignment=Enum.TextXAlignment.Left
a7.TextYAlignment=Enum.TextYAlignment.Top


local a8=Instance.new"TextLabel"
a8.Parent=a0
a8.BackgroundTransparency=1
a8.Position=UDim2.new(0,12,0,100)
a8.Size=UDim2.new(1,-24,0,16)
a8.Font=Enum.Font.Gotham
a8.Text="Last Update: "..timestampToDate(aY.edited)
a8.TextColor3=Color3.fromRGB(100,100,100)
a8.TextSize=14

local a9=false


local ba=Instance.new"TextButton"
ba.Parent=a0
ba.BackgroundColor3=Color3.fromRGB(5,134,105)
connectguicolorchange(function(bb,bc,bd)
ba.BackgroundColor3=a9 and m.Dark(Color3.fromHSV(bb,bc,bd),0.3)or Color3.fromHSV(bb,bc,bd)
end)
ba.Size=a_ and UDim2.new(1,-64,0,38)or UDim2.new(1,-24,0,38)
ba.Position=UDim2.new(0,12,1,-50)
ba.Font=Enum.Font.GothamBold
ba.Text="DOWNLOAD"
ba.TextColor3=Color3.fromRGB(255,255,255)
ba.TextSize=12
ba.AutoButtonColor=false
ba.BorderSizePixel=0

addCorner(ba)

ba.MouseEnter:Connect(function()
local bb,bc,bd=d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value
local be=a9 and m.Dark(Color3.fromHSV(bb,bc,bd),0.3)or Color3.fromHSV(bb,bc,bd)
g
:Create(ba,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{
BackgroundColor3=m.Light(be,0.3),
})
:Play()
end)

ba.MouseLeave:Connect(function()
local bb,bc,bd=d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value
local be=a9 and m.Dark(Color3.fromHSV(bb,bc,bd),0.3)or Color3.fromHSV(bb,bc,bd)
g
:Create(ba,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{
BackgroundColor3=be
})
:Play()
end)

if a_ then
local bb=aZ

local bc=bb
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

local bd=Instance.new"ImageButton"
bd.Parent=a0
bd.Size=UDim2.fromOffset(35,35)
bd.Position=UDim2.new(1,-47,1,-50)
bd.BackgroundColor3=Color3.fromRGB(60,60,60)
bd.AutoButtonColor=false
bd.Image=u((aZ and"hammer"or"trash"),true)
bd.ImageColor3=Color3.fromRGB(220,220,220)
bd.ZIndex=ba.ZIndex
addCorner(bd)

ai[aW].deleteIcon=bd
ai[aW].canDelete=a_
ai[aW].specialDelete=aZ

if bb then
bd.BackgroundColor3=Color3.fromRGB(90,30,30)

local be=Instance.new"UIStroke"
be.Color=Color3.fromRGB(255,80,80)
be.Thickness=1.5
be.Transparency=0.3
be.Parent=bd
else
bd.MouseEnter:Connect(function()
g:Create(bd,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(180,40,40),
ImageColor3=Color3.fromRGB(255,255,255),
}):Play()
end)

bd.MouseLeave:Connect(function()
g:Create(bd,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(60,60,60),
ImageColor3=Color3.fromRGB(220,220,220),
}):Play()
end)
end

bd.Activated:Connect(function()
if au then

local be=d.Profile or"Unknown Profile"

d:CreatePrompt{
Title="Update Config",
Text=string.format(
'Overwrite <b><font color="rgb(150,150,255)">"%s"</font></b> with your current profile <b><font color="rgb(100,200,100)">"%s"</font></b>?\n\n<font color="rgb(180,180,180)">This will update the config with your current settings and GUI color.</font>',
aW,
be
),
ConfirmText="UPDATE",
CancelText="CANCEL",
OnConfirm=function()

local bf="vape/profiles/"..be..d.Place..".txt"
if not D(bf)then
d:CreateNotification(
"Vape",
"Failed to read current profile config file",
6,
"warning"
)
revertToNormalMode()
return
end
local bg,bh=pcall(readfile,bf)
if not(bg and bh~=nil)then
d:CreateNotification(
"Vape",
"Failed to read current profile config file",
6,
"warning"
)
revertToNormalMode()
return
end

d:CreateNotification("Vape",`Updating "{aW}"...`,5,"info")

local bi={
username=getgenv().username,
password=getgenv().password,
config_name=aW,
config=bh,
color={d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value},
description=aY.description or"",
}

if aC then
bi.place=d.Place or game.PlaceId
bi.place=tostring(bi.place)
end

local bj,bk=pcall(function()
return request{
Url="https://configs.vapevoidware.xyz/configs",
Method="POST",
Headers={["Content-Type"]="application/json"},
Body=l:JSONEncode(bi),
}
end)

if bj and bk and bk.StatusCode==200 then
d:CreateNotification(
"Vape",
`Successfully updated "{aW}" with profile "{be}"!`,
8,
"info"
)

revertToNormalMode()

task.spawn(function()
task.wait(1)
S()
end)
else
local bl=bj and(bk and bk.Body or"Unknown error")
or tostring(bk)
if bk and bk.StatusCode==401 then
bl="Username or Password missing/invalid!"
else
local bm=decode(bl)
if bm~=nil and type(bm)=="table"and bm.detail~=nil then
bl=bm.detail
end
end
d:CreateNotification("Vape","Failed to update: "..bl,10,"warning")
revertToNormalMode()
end
end,
OnCancel=function()
revertToNormalMode()
end,
}
else

d:CreatePrompt{
Title=bc.Title,
Text=([[Are you sure you want to delete "%s"?%s]]):format(aW,bc.PromptNote),
ConfirmText="DELETE",
CancelText="CANCEL",
OnConfirm=function()
d:CreateNotification(
"Vape",
(bc.ActionWord..' "%s"...'):format(aW),
5,
"info"
)

local be={
username=getgenv().username,
password=getgenv().password,
config=aW,
place=tostring(d.Place or game.PlaceId),
}

if bb then
be.adminkey=getgenv().admin_config_api_key
be.username=tostring(aX)
be.password=nil
end

local bf,bg=pcall(function()
return request{
Url="https://configs.vapevoidware.xyz/configs",
Method="DELETE",
Headers={["Content-Type"]="application/json"},
Body=l:JSONEncode(be),
}
end)

if bf and bg and bg.StatusCode==200 then
d:CreateNotification(
"Vape",
(bc.DoneWord..' "%s"'):format(aW),
6,
"info"
)
S()
else
local bh=bg and bg.Body or"Unknown error"
if bg and bg.StatusCode==401 then
bh="Invalid username/password!"
else
local bi=decode(bh)
if bi and type(bi)=="table"and bi.detail then
bh=bi.detail
end
end

d:CreateNotification(
"Vape",
(bc.FailWord..": %s"):format(bh),
8,
"warning"
)
end
end,
}
end
end)
end

n:Tween(a0,TweenInfo.new(0.3,Enum.EasingStyle.Quad),{
BackgroundColor3=m.Light(o.Main,0.08),
BackgroundTransparency=0,
})

a0.MouseEnter:Connect(function()
n:Tween(a0,TweenInfo.new(0.1,Enum.EasingStyle.Quad),{
BackgroundColor3=m.Light(o.Main,0.2),
})
n:Tween(a5,TweenInfo.new(0.1,Enum.EasingStyle.Quad),{
TextSize=17,
})
n:Tween(a6,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{
TextColor3=Color3.fromRGB(230,230,230),
})
n:Tween(a8,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{
TextColor3=Color3.fromRGB(200,200,200),
})
n:Tween(a4,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{

Color=getStrokeColor(),
Thickness=2,
})
end)

a0.MouseLeave:Connect(function()
n:Tween(a0,TweenInfo.new(0.1,Enum.EasingStyle.Quad),{
BackgroundColor3=m.Light(o.Main,0.08),
})
n:Tween(a5,TweenInfo.new(0.1,Enum.EasingStyle.Quad),{
TextSize=15,
})
n:Tween(a6,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{
TextColor3=Color3.fromRGB(150,150,150),
})
n:Tween(a8,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{
TextColor3=Color3.fromRGB(100,100,100),
})
n:Tween(a4,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{

Color=m.Dark(getStrokeColor(),0.3),
Thickness=1,
})
end)

pcall(function()
local bb=ai[aW]
if bb then
local bc=`{bb.name} ({bb.username})`
local bd=d.Profiles
if(bd~=nil and type(bd)=="table")then
for be,bf in bd do
if type(bf)~="table"then continue end
if bf.Name==bc then
ba.Text="REINSTALL"
a9=true
local bg,bh,bi=d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value
ba.BackgroundColor3=a9
and m.Dark(Color3.fromHSV(bg,bh,bi),0.3)
or Color3.fromHSV(bg,bh,bi)
break
end
end
end
end
end)

ba.Activated:Connect(function()
local bb=ai[aW]
if bb then
local bc=string.format("%s (%s)",bb.name,bb.username)
local bd,be=bb.link:match"^(.-/)([^/]+)$"
if not bd or not be then
errorNotification("Voidware | Configs",`Invalid URL for {tostring(aW)}. Please report this to a developer in discord.gg/voidware`,10)
warn("Invalid URL:",bb.link)
return
end local
bf, bg=pcall(function()
return bd..l:UrlEncode(be)
end)
if not bg then
errorNotification("Voidware | Configs",`Couldn't resolve the url for {tostring(aW)}. Please report this to a developer in discord.gg/voidware`,10)
warn(`Invalid URL resolve: {tostring(bg)}`)
return
end
local bh=d.http_function(bg)
if bh:sub(1,1)=='"'and bh:sub(-1)=='"'then
local bi,bj=pcall(function()
return l:JSONDecode(bh)
end)
if bi then
bh=bj
end
end
local bi=false
for bj,bk in d.Profiles do
if bk.Name==bc then
bi=true
break
end
end
if not bi then
table.insert(d.Profiles,{Name=bc,Bind={}})
end
local bj
if bb.color~=nil and type(bb.color)=="table"then
local bk,bl,bm=unpack(bb.color)
bk,bl,bm=num(bk),num(bl),num(bm)
if bk~=nil and bl~=nil and bm~=nil then
bj={
Hue=bk,
Sat=bl,
Value=bm,
CustomColor=true,
Rainbow=false
}
shared[`FORCE_PROFILE_GUI_COLOR_SET_{tostring(bc)}`]=bj
end
end
if bb.description~=nil then
shared[`FORCE_PROFILE_TEXT_GUI_CUSTOM_TEXT_{tostring(bc)}`]=tostring(bb.description)
end
d:Save(bc)
writefile("vape/profiles/"..bc..d.Place..".txt",bh)
d:Load(true,bc)
local bk=bi and"Reinstalled"or"Downloaded"
d:CreateNotification("Vape",`{bk} "{aW}" by @{bb.username}`,5,"info")
ba.Text="REINSTALL"
a9=true
local bl,bm,bn=d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value
ba.BackgroundColor3=a9 and m.Dark(Color3.fromHSV(bl,bm,bn),0.3)
or Color3.fromHSV(bl,bm,bn)
S()
else
d:CreateNotification("Vape",`Failed to fetch config ({aW})`,10,"warning")
end
end)
task.wait(0.15)
end


local function addSorting(aW,aX,aY)
local aZ=aY.Size
local a_=aY.On

local a0=Instance.new"TextButton"
a0.Name=aW
a0.Parent=aQ
a0.BackgroundColor3=Color3.fromHSV(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
connectguicolorchange(a0)
a0.BackgroundTransparency=a_ and 0 or 0.8
a0.BorderSizePixel=0
a0.Text=""
a0.AutoButtonColor=false
a0.Size=aZ

local a1=Instance.new"TextLabel"
a1.Parent=a0
a1.Name="label"
a1.BackgroundTransparency=1
a1.BorderSizePixel=0
a1.Size=UDim2.new(1,0,1,0)
a1.Font=Enum.Font.GothamBold
a1.TextTransparency=a_ and 0 or 0.6
a1.Text=aW:upper()
a1.TextColor3=Color3.new(1,1,1)
a1.TextSize=11

addCorner(a0,UDim.new(1,0))

local a2={
SetVisible=function(a2)
for a3,a4 in ai.Sorts do
a4.Window.BackgroundTransparency=0.8
a4.Window.label.TextTransparency=0.6
end

a0.BackgroundTransparency=a2 and 0 or 0.8
a1.TextTransparency=a2 and 0 or 0.6
end,
Window=a0,
}

a0.Activated:Connect(function()
a2:SetVisible(true)
an=aW:lower()
S()
end)

table.insert(ai.Sorts,a2)

return a2
end

addSorting("newest",nil,{
Size=UDim2.fromOffset(90,32),
On=true,
})

addSorting("oldest",nil,{
Size=UDim2.fromOffset(90,32),
On=false,
})

aj=H.Dropdown({
Name="Author",
List={"all"},
Function=function(aW)
ak:Fire(aW)
end,
Default="all",
Size=UDim2.new(0.2,0,0,40),
Visible=false,
},aQ,{Options={}})
aj.Object.BackgroundTransparency=1

local aW=Instance.new"TextLabel"
aW.Parent=aQ
aW.TextSize=15
aW.LayoutOrder=5
aW.TextColor3=Color3.fromRGB(200,200,200)
aW.TextTransparency=1
aW.Size=UDim2.new(0,600,1,0)
aW.BackgroundTransparency=1

ar=function(aX,aY)
task.spawn(function()
if aY~=nil then
flickerTextEffect(aW,aY,aX)
elseif aX~=nil then
aW.Text=aX
end
end)
end

if getgenv().username~=nil then
ar(`Welcome back {tostring(getgenv().username)}!`,true)
end

as=function()
ar(`Awesome configs made by & for awesome people :D`,true)
end


aP:GetPropertyChangedSignal"Text":Connect(function()
for aX,aY in ai do
if aY and typeof(aY)=="table"and aY.instance then
aY.instance.Visible=false

if
aX:lower():gsub(" ",""):find(aP.Text:lower():gsub(" ",""),1,true)
or aP.Text==""
then
aY.instance.Visible=true
end
end
end
end)

af.Event:Connect(S)


local aX=false
aw:GetPropertyChangedSignal"Visible":Connect(function()
if not aw.Visible then
if aX then
v.Visible=true
aX=false
end
az.Visible=false
else
v.Visible=false
aX=true
end
local aY=d
if not aY.UpdateGUI then return end
aY:UpdateGUI(aY.GUIColor.Hue,aY.GUIColor.Sat,aY.GUIColor.Value)
end)

ag.PublicConfigs=ai

return ai
end

function d.CreateCategoryList(ag,ah)
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
aj.BackgroundColor3=o.Main
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
am.Color=m.Light(aq,0.2)
else
am.Color=Color3.fromRGB(255,255,255)
end
end)
local an=false

d.ProfilesCategoryListWindow={
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
n:Tween(am,TweenInfo.new(0.15),{
Thickness=3
})
end)
aj.MouseLeave:Connect(function()
n:Tween(am,TweenInfo.new(0.15),{
Thickness=0
})
end)
end
return ao
end
}
end
aj.Text=""
aj.Parent=v
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
al.ImageColor3=o.Text
al.Parent=aj
local am=Instance.new"TextLabel"
am.Name="Title"
am.Size=UDim2.new(1,-(ah.Size.X.Offset>20 and 44 or 36),0,20)
am.Position=UDim2.fromOffset(math.abs(am.Size.X.Offset),12)
am.BackgroundTransparency=1
am.Text=ah.Name
am.TextXAlignment=Enum.TextXAlignment.Left
am.TextColor3=o.Text
am.TextSize=13
am.FontFace=o.Font
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
ao.Image=u"vape/assets/new/expandup.png"
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
aq.BackgroundColor3=m.Dark(o.Main,0.02)
aq.Visible=false
aq.Parent=ap
local ar=Instance.new"ImageButton"
ar.Name="Settings"
ar.Size=UDim2.fromOffset(16,16)
ar.Position=UDim2.new(1,-52,0,13)
ar.BackgroundTransparency=1
ar.AutoButtonColor=false
ar.Image=ah.Name~="Profiles"and u"vape/assets/new/customsettings.png"or u"vape/assets/new/worldicon.png"
ar.ImageColor3=m.Dark(o.Text,0.43)
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
av=H.Button({
Name="Sync to 'default' profile",
Function=function()
local ax=d.Profile
d.Profile='default'
d:Save'default'
d:Load(true,'default')
local ay=Color3ToHex(Color3.fromHSV(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value))
local az="#ffffff"
local aA=([[Transferred Data from <font color="%s"><b>%s</b></font> to <font color="%s"><b>default</b></font> Profile]]):format(ay,tostring(ax),az)
d:CreateNotification("Vape",aA,3)
end,
Tooltip="Transfers your current profile to the 'default' one",
Visible=false,
BackgroundTransparency=1
},ap,{Options={}})
aw=H.Button({
Name="Create new profile",
Function=function()
d:CreatePrompt{
Title="Create Profile",
Text="Choose a name for your new profile.",
Input=true,
InputPlaceholder="What should the profile be called?",
OnConfirm=function(ax)
if ax and ax~=""then
for ay,az in d.Profiles do
if tostring(az.Name)==ax then
d:CreateNotification("Vape",`Profile {tostring(ax)} already exists!`,3)
return
end
end
table.insert(d.Profiles,{Name=ax,Bind={}})
d:Save(ax,true)
d:Load(ax)
else
d:CreateNotification("Vape","No Profile Name given",3)
end
end,
}
end,
Tooltip="Creates a brand new profile",
Visible=false,
BackgroundTransparency=1,
},ap,{Options={}})
H.Button({
Name="Reset current profile",
Function=function()
d:CreatePrompt{
Title="Reset Profile",
Text="Are you sure you want to <b><font color='#ff5a5a'>delete</font></b> your current profile?\n<font color='#ff7777'><i>This action cannot be undone.</i></font>",
ConfirmText="Yes",
CancelText="Nevermind",
ConfirmColor=Color3.fromRGB(120,40,40),
ConfirmHoverColor=Color3.fromRGB(170,60,60),
CancelColor=Color3.fromRGB(40,120,40),
CancelHoverColor=Color3.fromRGB(60,170,60),
OnConfirm=function()
d.Save=function()end
if D("vape/profiles/"..d.Profile..d.Place..".txt")and delfile then
delfile("vape/profiles/"..d.Profile..d.Place..".txt")
end
shared.vapereload=true
if shared.VapeDeveloper then
loadstring(readfile"vape/loader.lua","loader")()
else
loadstring(
d.http_function(
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
ax.BackgroundColor3=m.Light(o.Main,0.02)
ax.Parent=ap
addCorner(ax)
local ay=ax:Clone()
ay.Size=UDim2.new(1,-2,1,-2)
ay.Position=UDim2.fromOffset(1,1)
ay.BackgroundColor3=m.Dark(o.Main,0.02)
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
az.FontFace=o.Font
az.ClearTextOnFocus=false
az.Parent=ax
local aA=Instance.new"ImageButton"
aA.Name="AddButton"
aA.Size=UDim2.fromOffset(16,16)
aA.Position=UDim2.new(1,-26,0,8)
aA.BackgroundTransparency=1
aA.Image=u"vape/assets/new/add.png"
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
table.remove(d.Profiles,aE)
if D("vape/profiles/"..aD..d.Place..".txt")and delfile then
delfile("vape/profiles/"..aD..d.Place..".txt")
end
end
else
table.insert(d.Profiles,{Name=aD,Bind={}})
end
if d.ConfigsAPIRefresh then pcall(d.ConfigsAPIRefresh)end
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
for aE,aF in aC.Objects do
aF:Destroy()
end
table.clear(aC.Objects)
aC.Selected=nil

for aE,aF in(ah.Profiles and d.Profiles or aC.List)do
if ah.Profiles then
local aH=Instance.new"TextButton"
aH.Name=aF.Name
aH.Size=UDim2.fromOffset(200,33)
aH.BackgroundColor3=m.Light(o.Main,0.02)
aH.AutoButtonColor=false
aH.Text=""
aH.Parent=ap
addCorner(aH)
local aI=Instance.new"UIStroke"
aI.Color=m.Light(o.Main,0.1)
aI.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
aI.Enabled=false
aI.Parent=aH
local aJ=Instance.new"TextLabel"
aJ.Name="Title"
aJ.Size=UDim2.new(1,-10,1,0)
aJ.Position=UDim2.fromOffset(10,0)
aJ.BackgroundTransparency=1
aJ.Text=aF.Name
aJ.TextTruncate=Enum.TextTruncate.AtEnd
aJ.TextXAlignment=Enum.TextXAlignment.Left
aJ.TextColor3=m.Dark(o.Text,0.4)
aJ.TextSize=15
aJ.FontFace=o.Font
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
aL.Image=u"vape/assets/new/dots.png"
aL.ImageColor3=m.Light(o.Main,0.37)
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
aN.Image=u"vape/assets/new/bind.png"
aN.ImageColor3=m.Dark(o.Text,0.43)
aN.Parent=aM
local aO=Instance.new"TextLabel"
aO.Size=UDim2.fromScale(1,1)
aO.Position=UDim2.fromOffset(0,1)
aO.BackgroundTransparency=1
aO.Visible=false
aO.Text=""
aO.TextColor3=m.Dark(o.Text,0.43)
aO.TextSize=12
aO.FontFace=o.Font
aO.Parent=aM
aM.MouseEnter:Connect(function()
aO.Visible=false
aN.Visible=not aO.Visible
aN.Image=u"vape/assets/new/edit.png"
if aF.Name~=d.Profile then
aN.ImageColor3=m.Dark(o.Text,0.16)
end
end)
aM.MouseLeave:Connect(function()
aO.Visible=#aF.Bind>0
aN.Visible=not aO.Visible
aN.Image=u"vape/assets/new/bind.png"
if aF.Name~=d.Profile then
aN.ImageColor3=m.Dark(o.Text,0.43)
end
end)
local aP=Instance.new"ImageLabel"
aP.Name="Cover"
aP.Size=UDim2.fromOffset(154,33)
aP.BackgroundTransparency=1
aP.Visible=false
aP.Image=u"vape/assets/new/bindbkg.png"
aP.ScaleType=Enum.ScaleType.Slice
aP.SliceCenter=Rect.new(0,0,141,40)
aP.Parent=aH
local aQ=Instance.new"TextLabel"
aQ.Name="Text"
aQ.Size=UDim2.new(1,-10,1,-3)
aQ.BackgroundTransparency=1
aQ.Text="PRESS A KEY TO BIND"
aQ.TextColor3=o.Text
aQ.TextSize=11
aQ.FontFace=o.Font
aQ.Parent=aP
aM.Parent=aH
aK.MouseEnter:Connect(function()
if aF.Name~=d.Profile then
aL.ImageColor3=o.Text
end
end)
aK.MouseLeave:Connect(function()
if aF.Name~=d.Profile then
aL.ImageColor3=m.Light(o.Main,0.37)
end
end)
aK.Activated:Connect(function()
if aF.Name~=d.Profile then
ai:ChangeValue(aF.Name)
end
end)
aH.Activated:Connect(function()
d:Save(aF.Name,not D("vape/profiles/"..aF.Name..d.Place..".txt"))
d:Load(true,aF.Name)
end)
aH.MouseEnter:Connect(function()
aM.Visible=true
if aF.Name~=d.Profile then
aI.Enabled=true
aJ.TextColor3=m.Dark(o.Text,0.16)
end
end)
aH.MouseLeave:Connect(function()
aM.Visible=#aF.Bind>0
if aF.Name~=d.Profile then
aI.Enabled=false
aJ.TextColor3=m.Dark(o.Text,0.4)
end
end)

local function bindFunction(aR,aS,aT)
aF.Bind=table.clone(aS)
if aT then
aQ.Text=#aS<=0 and"BIND REMOVED"
or"BOUND TO "..table.concat(aS," + "):upper()
aP.Size=
UDim2.fromOffset(E(aQ.Text,aQ.TextSize).X+20,40)
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
math.max(E(aO.Text,aO.TextSize,aO.Font).X+10,20),
21
)
end
end

bindFunction({},aF.Bind)
aM.Activated:Connect(function()
aQ.Text="PRESS A KEY TO BIND"
aP.Size=
UDim2.fromOffset(E(aQ.Text,aQ.TextSize).X+20,40)
aP.Visible=true
d.Binding={SetBind=bindFunction,Bind=aF.Bind}
end)
if aF.Name==d.Profile then
aC.Selected=aH
end
table.insert(aC.Objects,aH)
else
local aH=table.find(aC.ListEnabled,aF)
local aI=Instance.new"TextButton"
aI.Name=aF
aI.Size=UDim2.fromOffset(200,32)
aI.BackgroundColor3=m.Light(o.Main,0.02)
aI.AutoButtonColor=false
aI.Text=""
aI.Parent=ap
addCorner(aI)
local aJ=Instance.new"Frame"
aJ.Name="BKG"
aJ.Size=UDim2.new(1,-2,1,-2)
aJ.Position=UDim2.fromOffset(1,1)
aJ.BackgroundColor3=o.Main
aJ.Visible=false
aJ.Parent=aI
addCorner(aJ)
local aK=Instance.new"Frame"
aK.Name="Dot"
aK.Size=UDim2.fromOffset(10,11)
aK.Position=UDim2.fromOffset(10,12)
aK.BackgroundColor3=aH and ah.Color or m.Light(o.Main,0.37)
aK.Parent=aI
addCorner(aK,UDim.new(1,0))
local aL=aK:Clone()
aL.Size=UDim2.fromOffset(8,9)
aL.Position=UDim2.fromOffset(1,1)
aL.BackgroundColor3=aH and ah.Color or m.Light(o.Main,0.02)
aL.Parent=aK
local aM=Instance.new"TextLabel"
aM.Name="Title"
aM.Size=UDim2.new(1,-30,1,0)
aM.Position=UDim2.fromOffset(30,0)
aM.BackgroundTransparency=1
aM.Text=aF
aM.TextXAlignment=Enum.TextXAlignment.Left
aM.TextColor3=m.Dark(o.Text,0.16)
aM.TextSize=15
aM.FontFace=o.Font
aM.Parent=aI
if d.ThreadFix then
setthreadidentity(8)
end
local aN=Instance.new"ImageButton"
aN.Name="Close"
aN.Size=UDim2.fromOffset(16,16)
aN.Position=UDim2.new(1,-23,0,8)
aN.BackgroundColor3=Color3.new(1,1,1)
aN.BackgroundTransparency=1
aN.AutoButtonColor=false
aN.Image=u"vape/assets/new/closemini.png"
aN.ImageColor3=m.Light(o.Text,0.2)
aN.ImageTransparency=0.5
aN.Parent=aI
addCorner(aN,UDim.new(1,0))
aN.MouseEnter:Connect(function()
aN.ImageTransparency=0.3
n:Tween(aN,o.Tween,{
BackgroundTransparency=0.6,
})
end)
aN.MouseLeave:Connect(function()
aN.ImageTransparency=0.5
n:Tween(aN,o.Tween,{
BackgroundTransparency=1,
})
end)
aN.Activated:Connect(function()
ai:ChangeValue(aF)
end)
aI.MouseEnter:Connect(function()
aJ.Visible=true
end)
aI.MouseLeave:Connect(function()
aJ.Visible=false
end)
aI.Activated:Connect(function()
local aO=table.find(aC.ListEnabled,aF)
if aO then
table.remove(aC.ListEnabled,aO)
aK.BackgroundColor3=m.Light(o.Main,0.37)
aL.BackgroundColor3=m.Light(o.Main,0.02)
else
table.insert(aC.ListEnabled,aF)
aK.BackgroundColor3=ah.Color
aL.BackgroundColor3=ah.Color
end
ah.Function()
end)
table.insert(aC.Objects,aI)
end
end
d:UpdateGUI(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
end

function ai.Expand(aC)
aC.Expanded=not aC.Expanded
ap.Visible=aC.Expanded
ao.Rotation=aC.Expanded and 0 or 180
aj.Size=UDim2.fromOffset(
220,
aC.Expanded and math.min(51+at.AbsoluteContentSize.Y/A.Scale,611)or 45
)
as.Visible=ap.CanvasPosition.Y>10 and ap.Visible
end

function ai.GetValue(aC,aD)
for aE,aF in d.Profiles do
if aF.Name==aD then
return aE
end
end
end

for aC,aD in H do
ai["Create"..aC]=function(aE,aF)
return aD(aF,aq,ai)
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
d:CreateNotification("Vape","You need to specify a value!",3)
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
n:Tween(ax,o.Tween,{
BackgroundColor3=m.Light(o.Main,0.14),
})
end)
az.MouseLeave:Connect(function()
n:Tween(ax,o.Tween,{
BackgroundColor3=m.Light(o.Main,0.02),
})
end)
ap:GetPropertyChangedSignal"CanvasPosition":Connect(function()
as.Visible=ap.CanvasPosition.Y>10 and ap.Visible
end)
ar.MouseEnter:Connect(function()
ar.ImageColor3=o.Text
end)
ar.MouseLeave:Connect(function()
ar.ImageColor3=m.Light(o.Main,0.37)
end)

if ah.Profiles then
ag:CreateProfilesGUI(ar)
end

ar.Activated:Connect(function()
if ah.Profiles then
aq.Visible=false
ag.PublicConfigs.Window.Visible=not ag.PublicConfigs.Window.Visible
af:Fire()
if d.TutorialAPI.isActive then
d.TutorialAPI.GlobeIconWait=false
d.TutorialAPI:tweenToSecondPosition()
d.TutorialAPI:setText"Pick a config of your choice :D"
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
ap.CanvasSize=UDim2.fromOffset(0,at.AbsoluteContentSize.Y/A.Scale)
if ai.Expanded then
aj.Size=UDim2.fromOffset(220,math.min(51+at.AbsoluteContentSize.Y/A.Scale,611))
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
n:Tween(ah,TweenInfo.new(0.5),{
BackgroundTransparency=1,
})
task.delay(0.5,ah.Destroy,ah)
end

function d.CreateSearch(ag)
local ah=Instance.new"Frame"
ah.Name="Search"
ah.Size=UDim2.fromOffset(220,37)
ah.Position=UDim2.new(0.5,0,0,13)
ah.AnchorPoint=Vector2.new(0.5,0)
ah.BackgroundColor3=m.Dark(o.Main,0.02)
ah.Parent=v
local ai=Instance.new"ImageLabel"
ai.Name="Icon"
ai.Size=UDim2.fromOffset(14,14)
ai.Position=UDim2.new(1,-23,0,11)
ai.BackgroundTransparency=1
ai.Image=u"vape/assets/new/search.png"
ai.ImageColor3=m.Light(o.Main,0.37)
ai.Parent=ah
local aj=Instance.new"ImageButton"
aj.Name="Legit"
aj.Size=UDim2.fromOffset(29,16)
aj.Position=UDim2.fromOffset(8,11)
aj.BackgroundTransparency=1
aj.Image=u"vape/assets/new/legit.png"
aj.Parent=ah
local ak=Instance.new"Frame"
ak.Name="LegitDivider"
ak.Size=UDim2.fromOffset(2,12)
ak.Position=UDim2.fromOffset(43,13)
ak.BackgroundColor3=m.Light(o.Main,0.14)
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
al.TextColor3=o.Text
al.TextSize=12
al.FontFace=o.Font
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
v.Visible=false
ag.Legit.Window.Visible=true
ag.Legit.Window.Position=UDim2.new(0.5,-350,0.5,-194)
end)



























local ap=false
local aq
al:GetPropertyChangedSignal"Text":Connect(function()
if aq~=nil then
pcall(function()
task.cancel(aq)
end)
aq=nil
end
for ar,as in am:GetChildren()do
if as:IsA"TextButton"then
as:Destroy()
end
end
if al.Text=="Type to search..."then
return
end
if al.Text==""then
if not ap then
flickerTextEffect(al,true,"Type to search...")
end
return
end

aq=task.spawn(function()
for ar,as in ag.Modules do
if ar:lower():find(al.Text:lower())then
local at=as.Object:Clone()
at.Bind:Destroy()
at.Activated:Connect(function()
as:Toggle()
end)

at.MouseButton2Click:Connect(function()
as.Object.Parent.Parent.Visible=true
local au=as.Object.Parent
createHighlight(as.Object)
local av=as.ModuleCategory
if av~=nil then

av:Toggle(true)
end
local aw=as.CategoryApi
if aw~=nil then

aw:ToggleCategoryButton(true)
end

n:Tween(au,TweenInfo.new(0.5),{
CanvasPosition=Vector2.new(
0,
(as.Object.LayoutOrder*40)-(math.min(au.CanvasSize.Y.Offset,600)/2)
),
})
end)

at.Parent=am
at.Name=ar:lower()
task.spawn(function()
repeat
pcall(function()
for au,av in{"Text","TextColor3","BackgroundColor3"}do
at[av]=as.Object[av]
end
at.UIGradient.Color=as.Object.UIGradient.Color
at.UIGradient.Enabled=as.Object.UIGradient.Enabled
at.Dots.Dots.ImageColor3=as.Object.Dots.Dots.ImageColor3
end)
task.wait()
until not at.Parent
end)
end
end
end)
end)
al.Focused:Connect(function()
ap=true
if al.Text=="Type to search..."then
al.Text=""
end
end)
d.VisibilityChanged:Connect(function()
if not ap and v.Visible then
flickerTextEffect(al,true,"Type to search...")
end
end)
al.FocusLost:Connect(function()
ap=false
if al.Text==""then
flickerTextEffect(al,true,"Type to search...")
end
end)
ao:GetPropertyChangedSignal"AbsoluteContentSize":Connect(function()
if ag.ThreadFix then
setthreadidentity(8)
end
am.CanvasSize=UDim2.fromOffset(0,ao.AbsoluteContentSize.Y/A.Scale)
ah.Size=UDim2.fromOffset(220,math.min(37+ao.AbsoluteContentSize.Y/A.Scale,437))
end)
d.PreloadEvent:Connect(function()
flickerTextEffect(al,true,"Type to search...")
end)

ag.Legit.Icon=aj
end
































































































































































































































































































































































function d.CreateLegit(ag)
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
aj.BackgroundColor3=o.Main
aj.Visible=false
aj.Parent=w
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
al.Image=u"vape/assets/new/legittab.png"
al.ImageColor3=o.Text
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
table.insert(d.Windows,aj)

function ah.CreateModule(ap,aq)
d:Remove(aq.Name)



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
av.BackgroundColor3=m.Light(o.Main,0.02)
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
aw.TextColor3=m.Dark(o.Text,0.31)
aw.TextSize=13
aw.FontFace=o.Font
aw.Parent=av

local ax=Instance.new"Frame"
ax.Name="Knob"
ax.Size=UDim2.fromOffset(22,12)
ax.Position=UDim2.new(1,-57,0,14)
ax.BackgroundColor3=m.Light(o.Main,0.14)
ax.Parent=av
addCorner(ax,UDim.new(1,0))

local ay=ax:Clone()
ay.Size=UDim2.fromOffset(8,8)
ay.Position=UDim2.fromOffset(2,2)
ay.BackgroundColor3=o.Main
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
aA.Image=u"vape/assets/new/dots.png"
aA.ImageColor3=m.Light(o.Main,0.37)
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
aC.BackgroundColor3=o.Main
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
aD.TextColor3=m.Dark(o.Text,0.16)
aD.TextSize=13
aD.FontFace=o.Font
aD.Parent=aC

local aE=Instance.new"ImageButton"
aE.Name="Back"
aE.Size=UDim2.fromOffset(16,16)
aE.Position=UDim2.fromOffset(11,13)
aE.BackgroundTransparency=1
aE.Image=u"vape/assets/new/back.png"
aE.ImageColor3=m.Light(o.Main,0.37)
aE.Parent=aC
addCorner(aC)

local aF=Instance.new"ScrollingFrame"
aF.Name="Children"
aF.Size=UDim2.new(1,0,1,-45)
aF.Position=UDim2.fromOffset(0,41)
aF.BackgroundColor3=o.Main
aF.BorderSizePixel=0
aF.ScrollBarThickness=2
aF.ScrollBarImageTransparency=0.75
aF.CanvasSize=UDim2.new()
aF.Parent=aC

local aH=Instance.new"UIListLayout"
aH.SortOrder=Enum.SortOrder.LayoutOrder
aH.HorizontalAlignment=Enum.HorizontalAlignment.Center
aH.Parent=aF

if aq.Size then
local aI=Instance.new"Frame"
aI.Size=aq.Size
aI.BackgroundTransparency=1
aI.Visible=false
aI.Parent=w
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

aw.TextColor3=ar.Enabled and m.Light(o.Text,0.2)or m.Dark(o.Text,0.31)
av.BackgroundColor3=ar.Enabled and m.Light(o.Main,0.05)
or m.Light(o.Main,0.02)

n:Tween(ax,o.Tween,{
BackgroundColor3=ar.Enabled
and Color3.fromHSV(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
or m.Light(o.Main,0.14),
})
n:Tween(ay,o.Tween,{
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


for aI,aJ in H do
ar["Create"..aI]=function(aK,aL)
return createSyncedOption(
aJ,
aL,
aF,
au.Children,
ar,
au
)
end
ar["Add"..aI]=ar["Create"..aI]
end


for aI,aJ in H do
ar["Create"..aI]=function(aK,aL)
return createSyncedOption(
aJ,
aL,
aF,
au.Children,
ar,
au
)
end
ar["Add"..aI]=ar["Create"..aI]
end


aE.MouseEnter:Connect(function()
aE.ImageColor3=o.Text
end)
aE.MouseLeave:Connect(function()
aE.ImageColor3=m.Light(o.Main,0.37)
end)
aE.Activated:Connect(function()
n:Tween(aB,o.Tween,{
BackgroundTransparency=1,
})
n:Tween(aC,o.Tween,{
Position=UDim2.fromScale(1,0),
})
task.wait(0.2)
aB.Visible=false
end)

az.Activated:Connect(function()
aB.Visible=true
n:Tween(aB,o.Tween,{
BackgroundTransparency=0.5,
})
n:Tween(aC,o.Tween,{
Position=UDim2.new(1,-220,0,0),
})
end)

az.MouseEnter:Connect(function()
aA.ImageColor3=o.Text
end)
az.MouseLeave:Connect(function()
aA.ImageColor3=m.Light(o.Main,0.37)
end)

av.MouseEnter:Connect(function()
if not ar.Enabled then
av.BackgroundColor3=m.Light(o.Main,0.05)
end
end)
av.MouseLeave:Connect(function()
if not ar.Enabled then
av.BackgroundColor3=m.Light(o.Main,0.02)
end
end)

av.Activated:Connect(function()
ar:Toggle()
end)

av.MouseButton2Click:Connect(function()
aB.Visible=true
n:Tween(aB,o.Tween,{
BackgroundTransparency=0.5,
})
n:Tween(aC,o.Tween,{
Position=UDim2.new(1,-220,0,0),
})
end)

aB.Activated:Connect(function()
n:Tween(aB,o.Tween,{
BackgroundTransparency=1,
})
n:Tween(aC,o.Tween,{
Position=UDim2.fromScale(1,0),
})
task.wait(0.2)
aB.Visible=false
end)

aH:GetPropertyChangedSignal"AbsoluteContentSize":Connect(function()
if d.ThreadFix then
setthreadidentity(8)
end
aF.CanvasSize=UDim2.fromOffset(0,aH.AbsoluteContentSize.Y/A.Scale)
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
local ar=v.Visible
for as,at in ag.Windows do
ar=ar or at.Visible
end
aq.Children.Visible=(not ar or aj.Visible)and aq.Enabled
end
end
end

am.Activated:Connect(function()
aj.Visible=false
v.Visible=true
end)

ag:Clean(v:GetPropertyChangedSignal"Visible":Connect(visibleCheck))
aj:GetPropertyChangedSignal"Visible":Connect(function()
ag:UpdateGUI(ag.GUIColor.Hue,ag.GUIColor.Sat,ag.GUIColor.Value)
visibleCheck()
end)

ao:GetPropertyChangedSignal"AbsoluteContentSize":Connect(function()
if ag.ThreadFix then
setthreadidentity(8)
end
an.CanvasSize=UDim2.fromOffset(0,ao.AbsoluteContentSize.Y/A.Scale)
end)

ag.Legit=ah

return ah
end

function d.CreateNotification(ag,ah,ai,aj,ak)
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
local am=#q:GetChildren()+1
local an=Instance.new"ImageLabel"
an.Name="Notification"
an.Size=UDim2.fromOffset(math.max(E(removeTags(ai),14,o.Font).X+80,266),75)
an.Position=UDim2.new(1,0,1,-(29+(78*am)))
an.ZIndex=5
an.BackgroundTransparency=1
an.Image=u"vape/assets/new/notification.png"
an.ScaleType=Enum.ScaleType.Slice
an.SliceCenter=Rect.new(7,7,9,9)
an.Parent=q
addBlur(an,true)
local ao=Instance.new"ImageLabel"
ao.Name="Icon"
ao.Size=UDim2.fromOffset(60,60)
ao.Position=UDim2.fromOffset(-5,-8)
ao.ZIndex=5
ao.BackgroundTransparency=1
ao.Image=u("vape/assets/new/"..(al or"info")..".png")
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
aq.FontFace=o.FontSemiBold
aq.Parent=an
local ar=aq:Clone()
ar.Name="Text"
ar.Position=UDim2.fromOffset(47,44)
ar.Text=removeTags(ai)
ar.TextColor3=Color3.new()
ar.TextTransparency=0.5
ar.RichText=true
ar.FontFace=o.Font
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
if n.Tween then
n:Tween(an,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{
AnchorPoint=Vector2.new(1,0),
},n.tweenstwo)
n:Tween(at,TweenInfo.new(aj,Enum.EasingStyle.Linear),{
Size=UDim2.fromOffset(0,2),
})
end
task.delay(aj,function()
if n.Tween then
n:Tween(an,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{
AnchorPoint=Vector2.new(0,0),
},n.tweenstwo)
end
task.wait(0.2)
an:ClearAllChildren()
an:Destroy()
end)
end)
end

local ag
function d.CreatePrompt(ah,ai)
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
if d.ThreadFix then
setthreadidentity(8)
end


local aw=Instance.new"ImageLabel"
aw.Name="Prompt"
aw.Size=UDim2.fromOffset(360,180)
aw.AnchorPoint=Vector2.new(0.5,0.5)
aw.Position=UDim2.fromScale(0.5,0.45)
aw.BackgroundTransparency=1
aw.ZIndex=20
aw.Image=u"vape/assets/new/notification.png"
aw.ScaleType=Enum.ScaleType.Slice
aw.SliceCenter=Rect.new(7,7,9,9)
aw.Parent=s

local ax=Instance.new"UIScale"
ax.Scale=1
ax.Parent=aw

aw.MouseEnter:Connect(function()
n:Tween(ax,TweenInfo.new(0.15),{
Scale=1.05,
})
end)

aw.MouseLeave:Connect(function()
n:Tween(ax,TweenInfo.new(0.15),{
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
ay.FontFace=o.Font
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
az.FontFace=o.FontSemiBold
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
aA.FontFace=o.Font
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
aC.FontFace=o.FontSemiBold
aC.ZIndex=22
aC.Parent=aB
addCorner(aC)


local aD=aC:Clone()
aD.BackgroundColor3=ao
aD.Position=UDim2.new(0.5,6,0,0)
aD.Text=am
aD.Parent=aB

local function hover(aE,aF,aH,aI)
n:Tween(aE,TweenInfo.new(0.15),{
BackgroundColor3=aI and aF or aH,
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

if n.Tween then
n:Tween(aw,TweenInfo.new(0.25,Enum.EasingStyle.Exponential),{
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
local aF=ay and ay.Text or nil
close()
if typeof(ar)=="function"then
task.spawn(ar,aF)
end
end)

aD.Activated:Connect(function()
close()
if typeof(as)=="function"then
task.spawn(as)
end
end)


if n.Tween then
aw.Size=UDim2.fromOffset(340,160)
n:Tween(aw,TweenInfo.new(0.35,Enum.EasingStyle.Exponential),{
Size=UDim2.fromOffset(360,180),
},n.tweenstwo)
end
end)
end

function d.Load(ah,ai,aj)
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
if not D(am)then
am="vape/profiles/"..str(game.GameId)..".gui.txt"
end
if D(am)then
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
d.settextguicustomtext(ao)
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
if aq.Expanded~=nil and aq.Expanded~=ar.Expanded and ar.Expand~=nil then
ar:Expand()
end
if aq.List and(#ar.List>0 or#aq.List>0)then
ar.List=aq.List or{}
ar.ListEnabled=aq.ListEnabled or{}
ar:ChangeValue()
end
if aq.Position then
d:LoadPosition(ar.Object,aq.Position)
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
E(ah.ProfileLabel.Text,ah.ProfileLabel.TextSize,ah.ProfileLabel.Font).X+16,
24
)
end

local an=D("vape/profiles/"..ah.Profile..ah.Place..".txt")

if an then
local ao=loadJson("vape/profiles/"..ah.Profile..ah.Place..".txt")
if not ao then
ao={Categories={},Modules={},Legit={}}
ah:CreateNotification("Vape","Failed to load "..ah.Profile.." profile.",10,"alert")
if ah.Profile~="default"then

pcall(function()
local ap
for aq,ar in d.Profiles do
if ar.Name==ah.Profile then
ap=aq
end
end
if ap then
table.remove(d.Profiles,ap)
end
end)
d:Load(true,"default")
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
if aq.Expanded~=nil and aq.Expanded~=ar.Expanded and ar.Expand~=nil then
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
d:LoadPosition(ar.Object,aq.Position)
end
end

for ap,aq in ao.Modules do
local ar=ah.Modules[ap]
if not ar then
continue
end
if ar.StarActive~=nil and aq.Favorited~=nil and ar.StarActive~=aq.Favorited and ar.ToggleStar~=nil and type(ar.ToggleStar)=="function"then
ar:ToggleStar(true)
end
if ar.NoSave then continue end
if ar.Options and aq.Options then
ah:LoadOptions(ar,aq.Options)
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
x.Visible=false
v.Visible=true
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

if d.isMobile then
local ao=Instance.new"TextButton"
ao.Size=UDim2.fromOffset(32,32)
ao.Position=UDim2.new(1,-90,0,4)
ao.BackgroundColor3=Color3.new()
ao.BackgroundTransparency=0.5
ao.Text=""
ao.Parent=B
local ap=Instance.new"ImageLabel"
ap.Size=UDim2.fromOffset(26,26)
ap.Position=UDim2.fromOffset(3,3)
ap.BackgroundTransparency=1
ap.Image=u"vape/assets/new/vape.png"
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
as.Bind.Button.Visible=v.Visible
end
end
v.Visible=not v.Visible
z.Visible=false
ah:BlurCheck()
end)
end
ah:onload()
end

function d.LoadOptions(ah,ai,aj)
for ak,al in aj do
local am=ai.Options[ak]
if not am then
continue
end
if am.NoSave then continue end
am:Load(al)
end
end

function d.CheckBounds(ah,ai,aj)
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

d:CreateNotification("Vape",ap,10,"warning")
end
end
end


function d.Remove(ah,ai)
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

function d.SavePosition(ah,ai)
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

function d.LoadPosition(ah,ai,aj)
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

function d.Save(ah,ai,aj)
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
Options=d:SaveOptions(an,an.Options),
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
Options=d:SaveOptions(an,true),
}
end

for am,an in ah.Legit.Modules do
if an.NoSave then continue end
al.Legit[am]={
Enabled=an.Enabled,
Position=an.Children and{X=an.Children.Position.X.Offset,Y=an.Children.Position.Y.Offset}or nil,
Options=d:SaveOptions(an,an.Options),
}
end
end

writefile("vape/profiles/"..str(game.GameId).."_"..str(ah.Place)..".gui.txt",l:JSONEncode(ak))
writefile("vape/profiles/"..ah.Profile..ah.Place..".txt",l:JSONEncode(al))
end

function d.DisableSaving(ah)
d:CreateNotification("Vape","Saving is disabled due to an error in Voidware!",30,"warning")
ah.Loaded=false
ah.Save=function()end
end

function d.SaveOptions(ah,ai,aj)
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

function d.Uninject(ah,ai)
local aj=print
local ak=function(...)
local ak={...}
if not shared.UninjectDebug then return end
aj(unpack(ak))
end
ak"save started"
if not ai then
d:Save()
end
ak"save ended"
d.Loaded=nil
d.SelfDestructEvent:Fire()
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
for al,am in d.Connections do
pcall(function()
am:Disconnect()
end)
end
ak"api maid cleaning ended"
ak("api thread fix check ",d.ThreadFix)
if d.ThreadFix then
setthreadidentity(8)
v.Visible=false
d:BlurCheck()
end
ak"api thread fix check ended"
d.gui:ClearAllChildren()
d.gui:Destroy()
ak"destroyed gui"
table.clear(d.Libraries)
ak"loopclean started"
loopClean(d)
ak"loopclean ended"
shared.vape=nil
shared.vapereload=nil
shared.VapeIndependent=nil
end

B=Instance.new"ScreenGui"
B.Name=randomString()
B.DisplayOrder=9999999
B.ZIndexBehavior=Enum.ZIndexBehavior.Global
B.IgnoreGuiInset=true
pcall(function()
B.OnTopOfCoreBlur=true
end)



B.Parent=e(game:GetService"Players").LocalPlayer.PlayerGui
B.ResetOnSpawn=false

d.gui=B
w=Instance.new"Frame"
w.Name="ScaledGui"
w.Size=UDim2.fromScale(1,1)
w.BackgroundTransparency=1
w.Parent=B
v=Instance.new"Frame"
v.Name="ClickGui"
v.Size=UDim2.fromScale(1,1)
v.BackgroundTransparency=1
v.Visible=false
v.Parent=w
d:Clean(v:GetPropertyChangedSignal"Visible":Connect(function()
d.VisibilityChanged:Fire(v.Visible)
end))
local ah=Instance.new"TextLabel"
ah.Size=UDim2.fromScale(1,0.02)
ah.Position=UDim2.fromScale(0,0.97)
ah.BackgroundTransparency=1
ah.Text="discord.gg/voidware"
ah.TextScaled=true
ah.TextColor3=Color3.new(1,1,1)
ah.TextStrokeTransparency=0.5
ah.FontFace=o.Font
ah.Parent=v
d.TutorialAPI={
tutorialType=2,
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
n:Tween(ai.label,TweenInfo.new(1.5),{
TextSize=30,
Position=UDim2.fromScale(0.5,0.6)
})
ai:setText"Welcome to Voidware!"
ai.label.Parent=w
end,
tweenToSecondPosition=function(ai)
if not ai.isActive then return end
ai.GlobeIconWait=false
n:Tween(ai.label,TweenInfo.new(1.5),{
Position=UDim2.fromScale(0.5,0.78)
})
end,
revertTutorialMode=function(ai,aj)
ai:cleanTutorialLabel()
ai.GlobeIconWait=false
ai.isActive=false
ai.label.TextScaled=true
ai.label.AutomaticSize=Enum.AutomaticSize.None
n:Tween(ai.label,TweenInfo.new(0.5),{
Position=UDim2.fromScale(0.5,0.97)
}).Completed:Connect(function()
ai:setText(ai.defaultText)
ai.label.Parent=v
end)
if aj then
d:CreateNotification("Tutorial Complete!","Thank you for using Voidware <3",10)
end
end,
setText=function(ai,aj)
if not ai.isActive and aj~=ai.defaultText then return end
ai.flickerTextEffect(ai.label,true,aj)
end
}
d.VisibilityChanged:Connect(function()
if d.TutorialAPI.isActive and d.TutorialAPI.GlobeIconWait and not x.Visible then
d.TutorialAPI:setText"Tutorial Cancelled"
task.delay(0.3,function()
d.TutorialAPI:revertTutorialMode()
end)
end
end)
local ai=Instance.new"TextButton"
ai.BackgroundTransparency=1
ai.Modal=true
ai.Text=""
ai.Parent=v
local aj=Instance.new"ImageLabel"
aj.Size=UDim2.fromOffset(64,64)
aj.BackgroundTransparency=1
aj.Visible=false
aj.Image="rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png"
aj.Parent=B
q=Instance.new"Folder"
q.Name="Notifications"
q.Parent=w
s=Instance.new"Folder"
s.Name="Prompts"
s.Parent=w








z=Instance.new"TextLabel"
z.Name="Tooltip"
z.Position=UDim2.fromScale(-1,-1)
z.ZIndex=5
z.BackgroundColor3=m.Dark(o.Main,0.02)
z.Visible=false
z.Text=""
z.TextColor3=m.Dark(o.Text,0.16)
z.TextSize=15
z.FontFace=o.Font
z.Parent=w
y=addBlur(z)
addCorner(z)
local ak=Instance.new"Frame"
ak.Size=UDim2.new(1,-2,1,-2)
ak.Position=UDim2.fromOffset(1,1)
ak.ZIndex=6
ak.BackgroundTransparency=1
ak.Parent=z
local al=Instance.new"UIStroke"
al.Color=m.Light(o.Main,0.02)
al.Parent=ak
addCorner(ak,UDim.new(0,4))
A=Instance.new"UIScale"
A.Scale=math.max(B.AbsoluteSize.X/1920,0.6)
A.Parent=w
d.guiscale=A
w.Size=UDim2.fromScale(1/A.Scale,1/A.Scale)

d:Clean(B:GetPropertyChangedSignal"AbsoluteSize":Connect(function()
if d.Scale.Enabled then
A.Scale=math.max(B.AbsoluteSize.X/1920,0.6)
end
end))

d:Clean(A:GetPropertyChangedSignal"Scale":Connect(function()
w.Size=UDim2.fromScale(1/A.Scale,1/A.Scale)
for am,an in w:GetDescendants()do
if an:IsA"GuiObject"and an.Visible then
an.Visible=false
an.Visible=true
end
end
end))

d:Clean(v:GetPropertyChangedSignal"Visible":Connect(function()
d:UpdateGUI(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value,true)
if v.Visible and h.MouseEnabled then
repeat
local am=v.Visible
for an,ao in d.Windows do
am=am or ao.Visible
end
if not am then
break
end

aj.Visible=not h.MouseIconEnabled
if aj.Visible then
local an=h:GetMouseLocation()
aj.Position=UDim2.fromOffset(an.X-31,an.Y-32)
end

task.wait()
until d.Loaded==nil
aj.Visible=false
end
end))

d:CreateGUI()
d.Categories.Main:CreateDivider()
d.Categories.Main:CreateSettingsDivider()





local am=d.Categories.Main:CreateSettingsPane{Name="General"}
d.MultiKeybind=am:CreateToggle{
Name="Enable Multi-Keybinding",
Tooltip="Allows multiple keys to be bound to a module (eg. G + H)",
}
d.QueueTeleportEnabledToggle=am:CreateToggle{
Name="Queue On Teleport",
Default=true,
Tooltip="Makes Voidware auto execute every time you teleport",
Function=function(an)
shared.DISABLED_QUEUE_ON_TELEPORT=not an
if not d.Notifications then return end
d:CreateNotification(
"Voidware",
"Auto Execute"
.."<font color='#FFFFFF'> was </font>"
..(an and"<font color='#5AFF5A'>Enabled</font>"or"<font color='#FF5A5A'>Disabled</font>")
.."<font color='#FFFFFF'>!</font>",
5
)
end
}
d.TranslationDropdown=am:CreateDropdown{
Name="Language",
Tooltip="Choose your language :D",
List={},
Function=function()end,
NoSave=true,
}
F(function()
d.Languages={}
local an={}
local ao
for ap,aq in ac.languages do
ap=tostring(ap)
local ar=aa[ap]or""
local as=`{ap} {tostring(ar)}`
d.Languages[as]=ap
if shared.TargetLanguage==ap then
ao=as
end
if table.find(an,as)then
continue
end
table.insert(an,as)
end
d.TranslationDropdown:SetValues(an,ab)
if ao then
d.TranslationDropdown:SetValue(ao)
end
d.TranslationDropdown:SetCallback(function(ap)
local aq=d.Languages[ap]
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

d:CreateNotification("Language Updated",au,3,"info")
end
end)
end)
am:CreateButton{
Name="Reset current profile",
Function=function()
d.Save=function()end
if D("vape/profiles/"..d.Profile..d.Place..".txt")and delfile then
delfile("vape/profiles/"..d.Profile..d.Place..".txt")
end
shared.vapereload=true
if shared.VapeDeveloper then
loadstring(readfile"vape/loader.lua","loader")()
else
loadstring(
d.http_function(
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
d:Uninject()
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
d.http_function(
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

d:CreateCategory{
Name="Combat",
Icon=u"vape/assets/new/combaticon.png",
Size=UDim2.fromOffset(13,14),
Visible=true,
}
d:CreateCategory{
Name="Blatant",
Icon=u"vape/assets/new/blatanticon.png",
Size=UDim2.fromOffset(14,14),
Visible=true,
}
d:CreateCategory{
Name="Render",
Icon=u"vape/assets/new/rendericon.png",
Size=UDim2.fromOffset(15,14),
Visible=true,
}
d:CreateCategory{
Name="Utility",
Icon=u"vape/assets/new/utilityicon.png",
Size=UDim2.fromOffset(15,14),
Visible=true,
}
d:CreateCategory{
Name="World",
Icon=u"vape/assets/new/worldicon.png",
Size=UDim2.fromOffset(14,14),
Visible=true,
}
for an,ao in{
{
Name="Inventory",
Icon=u"vape/assets/new/inventoryicon.png",
Size=UDim2.fromOffset(15,14),
GuiColorSync=true,
},
{
Name="Minigames",
Icon=u"vape/assets/new/miniicon.png",
Size=UDim2.fromOffset(19,12),
GuiColorSync=true,
}
}do
d.Categories[ao.Name]=d.Categories.World:CreateModuleCategory(ao)
end
d:CreateCategory{
Name="Legit",
Icon=u"vape/assets/new/legittab.png",
Size=UDim2.fromOffset(14,14),
Visible=true
}
d.Categories.Main:CreateDivider"misc"
d.PreloadEvent:Connect(function()
d.SortGuiCallback(true)
end)




local an
local ao={
Hue=1,
Sat=1,
Value=1,
}
local ap={
Name="Friends",
Icon=u"vape/assets/new/friendstab.png",
Size=UDim2.fromOffset(17,16),
Placeholder="Roblox username",
Color=Color3.fromRGB(5,134,105),
Function=function()
an.Update:Fire()
an.ColorUpdate:Fire(ao.Hue,ao.Sat,ao.Value)
end,
}
an=d:CreateCategoryList(ap)
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
if av and av.BackgroundColor3~=m.Light(o.Main,0.37)then
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
d:Clean(an.Update)
d:Clean(an.ColorUpdate)




d:CreateCategoryList{
Name="Profiles",
Icon=u"vape/assets/new/profilesicon.png",
Size=UDim2.fromOffset(17,10),
Position=UDim2.fromOffset(12,16),
Placeholder="Type name",
Profiles=true,
}

d:connectOnLoad(function(aq)
if aq.NewUser then
task.spawn(function()
task.wait(1.5)
if v.Visible then
v.Visible=false
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
local ar=d.ProfilesCategoryListWindow
if ar then
d.TutorialAPI:activateTutorial()
ar:setup()
n:Tween(ar.scale,TweenInfo.new(0.15),{
Scale=1.1
})
n:Tween(ar.stroke,TweenInfo.new(0.15),{
Thickness=3
})
ar.window.MouseLeave:Once(function()
n:Tween(ar.scale,TweenInfo.new(0.15),{
Scale=1
})
end)
v.Visible=true
task.delay(0.1,function()
d.TutorialAPI.GlobeIconWait=true
d.TutorialAPI:setText"Click on the globe icon to open the configs window"
flickerImageEffect(ar.globeicon,5,0.22)
end)
end
end,
OnCancel=function()
v.Visible=true
d.TutorialAPI:activateTutorial()
d.TutorialAPI:tweenToSecondPosition()
task.wait(1)
d.TutorialAPI:setText(d.VapeButton and"Press the button in the top right to open GUI"or"Press "..table.concat(d.Keybind," + "):upper().." to open & close the GUI")
task.wait(3)
d.TutorialAPI:revertTutorialMode(true)
end,
}
end)
end
end)




local aq
aq=d:CreateCategoryList{
Name="Targets",
Icon=u"vape/assets/new/friendstab.png",
Size=UDim2.fromOffset(17,16),
Placeholder="Roblox username",
Function=function()
aq.Update:Fire()
end,
}
aq.Update=Instance.new"BindableEvent"
d:Clean(aq.Update)

d:CreateLegit()
d:CreateSearch()
d.Categories.Main:CreateDivider"overlays"
local ar=d.Categories.World:CreateModuleCategory{
Name="Overlays",
Icon=u"vape/assets/new/overlaysicon.png",
Size=UDim2.fromOffset(24,18),
GuiColorSync=true,
UpExpand=true,
}
ar.ExpandEvent:Connect(function()
local as=d.Categories.Main.MainGui
for at,au in as:GetChildren()do
if au:IsA"TextButton"then
if not ar.Expanded then
au.Visible=true
end
local av=n:Tween(au,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
Size=UDim2.fromOffset(220,ar.Expanded and 0 or 40),
TextTransparency=ar.Expanded and 1 or 0,
})
if ar.Expanded then
av.Completed:Once(function()
au.Visible=false
end)
end
elseif au:IsA"TextLabel"and not au.Name:lower():find"overlays"then
n:Tween(au,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
Size=UDim2.fromOffset(218,ar.Expanded and 0 or 27),
TextTransparency=ar.Expanded and 1 or 0,
})
end
end
for at,au in d.Categories do
if not(au.OriginalCategory or(au.Type~=nil and au.Type=="CategoryList"))then continue end
if not au.Object then continue end
if au.Object.Parent==nil then continue end
if not au.Button then continue end
if not au.Button.Enabled then continue end
local av=au.Object:FindFirstChild"Title"
if av then
n:Tween(av,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
TextTransparency=ar.Expanded and 1 or 0
})
end
local aw=au.Object:FindFirstChild"Icon"
if aw then
n:Tween(aw,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
ImageTransparency=ar.Expanded and 1 or 0,
})
end
if ar.Expanded and not au.OriginalCategorySize then
au.OriginalCategorySize=au.Object.Size.Y.Offset
end
if au.OriginalCategorySize then
if not ar.Expanded then
au.Object.Visible=true
end
local ax=n:Tween(au.Object,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
Size=UDim2.fromOffset(220,(ar.Expanded and 0 or au.OriginalCategorySize))
})
if ar.Expanded then
ax.Completed:Connect(function()
au.Object.Visible=false
end)
end
end
end
end)
d.MainGuiSettingsOpenedEvent:Connect(function()
if ar.Expanded then
ar:Toggle()
end
end)
d.VisibilityChanged:Connect(function()
if ar.Expanded then
ar:Toggle()
end
end)
ar.Object.Parent=d.Categories.Main.MainGui
d.OverlaysModuleCategory=ar
d.Categories.Main:CreateOverlayBar()





local as=d.Categories.Main:CreateSettingsPane{Name="Modules"}
as:CreateToggle{
Name="Teams by server",
Tooltip="Ignore players on your team designated by the server",
Default=true,
Function=function()
if d.Libraries.entity and d.Libraries.entity.Running then
d.Libraries.entity.refresh()
end
end,
}
as:CreateToggle{
Name="Use team color",
Tooltip="Uses the TeamColor property on players for render modules",
Default=true,
Function=function()
if d.Libraries.entity and d.Libraries.entity.Running then
d.Libraries.entity.refresh()
end
end,
}





local at=d.Categories.Main:CreateSettingsPane{Name="GUI"}
d.Blur=at:CreateToggle{
Name="Blur background",
Function=function()
d:BlurCheck()
end,
Default=true,
Tooltip="Blur the background of the GUI",
}
at:CreateToggle{
Name="GUI bind indicator",
Default=true,
Tooltip="Displays a message indicating your GUI upon injecting.\nI.E. 'Press RSHIFT to open GUI'",
}
at:CreateToggle{
Name="Show tooltips",
Function=function(au)
z.Visible=false
y.Visible=au
end,
Default=true,
Tooltip="Toggles visibility of these",
}
at:CreateToggle{
Name="Show legit mode",
Function=function(au)
v.Search.Legit.Visible=au
v.Search.LegitDivider.Visible=au
v.Search.TextBox.Size=UDim2.new(1,au and-50 or-10,0,37)
v.Search.TextBox.Position=UDim2.fromOffset(au and 50 or 10,0)
end,
Default=true,
Tooltip="Shows the button to change to Legit Mode",
}
local au={Object={},Value=1}
d.Scale=at:CreateToggle{
Name="Auto rescale",
Default=true,
Function=function(av)
au.Object.Visible=not av
if av then
A.Scale=math.max(B.AbsoluteSize.X/1920,0.6)
else
A.Scale=au.Value
end
end,
Tooltip="Automatically rescales the gui using the screens resolution",
}
au=at:CreateSlider{
Name="Scale",
Min=0.1,
Max=2,
Decimal=10,
Function=function(av,aw)
if aw and not d.Scale.Enabled then
A.Scale=av
end
end,
Default=1.5,
Darker=true,
Visible=false,
}
d.RainbowMode=at:CreateDropdown{
Name="Rainbow Mode",
List={"Normal","Gradient","Retro"},
Tooltip="Normal - Smooth color fade\nGradient - Gradient color fade\nRetro - Static color",
}
d.RainbowSpeed=at:CreateSlider{
Name="Rainbow speed",
Min=0.1,
Max=10,
Decimal=10,
Default=1,
Tooltip="Adjusts the speed of rainbow values",
}
d.RainbowUpdateSpeed=at:CreateSlider{
Name="Rainbow update rate",
Min=1,
Max=144,
Default=60,
Tooltip="Adjusts the update rate of rainbow values",
Suffix="hz",
}
d.TooltipSlider=at:CreateSlider{
Name="Tooltip Text Size",
Min=5,
Max=30,
Default=15,
Tooltip="Adjusts the tooltip's text size",
Function=function(av)
z.TextSize=av
end
}
at:CreateButton{
Name="Reset GUI positions",
Function=function()
for av,aw in d.Categories do
aw.Object.Position=UDim2.fromOffset(6,42)
end
end,
Tooltip="This will reset your GUI back to default",
}
d.SortGuiCallback=function(av)
local aw={
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
local ax={}
for ay,az in d.Categories do
if az.Type=="Overlay"then continue end
if av and az.Object.Name=="ProfilesCategoryList"then continue end
table.insert(ax,az)
end
table.sort(ax,function(ay,az)
return(aw[ay.Object.Name]or 99)<(aw[az.Object.Name]or 99)
end)

local ay=0
for az,aA in ax do
if aA.Object.Visible then
aA.Object.Position=UDim2.fromOffset(6+(ay%8*230),60+(ay>7 and 360 or 0))
ay+=1
end
end
end
at:CreateButton{
Name="Sort GUI",
Function=d.SortGuiCallback,
Tooltip="Sorts GUI",
}





local av=d.Categories.Main:CreateSettingsPane{Name="Notifications"}
d.NotificationsBackground=av:CreateToggle{
Name="GUI Theme Background",
Tooltip="Syncs the Background with the GUI Theme",
Default=false,
Darker=true,
}
d.Notifications=av:CreateToggle{
Name="Notifications",
Function=function(aw)
if d.ToggleNotifications.Object then
d.ToggleNotifications.Object.Visible=aw
end
end,
Tooltip="Shows notifications",
Default=true,
}
d.ToggleNotifications=av:CreateToggle{
Name="Toggle alert",
Tooltip="Notifies you if a module is enabled/disabled.",
Default=true,
Darker=true,
}
d.FavoriteNotifications=av:CreateToggle{
Name="Favorite notify",
Tooltip="Notifies you if when you favorite a module.",
Default=true,
Darker=true,
}
d.BindNotifications=av:CreateToggle{
Name="Bind notify",
Tooltip="Notifies you if when you bind a module.",
Default=true,
Darker=true,
}

d.GUIColor=d.Categories.Main:CreateGUISlider{
Name="GUI Theme",
Function=function(aw,ax,ay)
d:UpdateGUI(aw,ax,ay,true)
end,
}
d.Categories.Main:CreateBind()





local aw=d:CreateOverlay{
Name="Text GUI",
Icon=u"vape/assets/new/textguiicon.png",
Size=UDim2.fromOffset(16,12),
Position=UDim2.fromOffset(12,14),
Function=function()
d:UpdateTextGUI()
end,
}
local ax=aw:CreateDropdown{
Name="Sort",
List={"Alphabetical","Length"},
Default="Length",
Function=function()
d:UpdateTextGUI()
end,
}
local ay=aw:CreateFont{
Name="Font",
Blacklist="Arial",
Function=function()
d:UpdateTextGUI()
end,
}
local az
local aA=aw:CreateDropdown{
Name="Color Mode",
List={"Match GUI color","Custom color"},
Function=function(aA)
az.Object.Visible=aA=="Custom color"
d:UpdateTextGUI()
end,
}
az=aw:CreateColorSlider{
Name="Text GUI color",
Function=function()
d:UpdateGUI(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
end,
Darker=true,
Visible=false,
}
local aB=Instance.new"UIScale"
aB.Parent=aw.Children
aw:CreateSlider{
Name="Scale",
Min=0,
Max=2,
Decimal=10,
Default=1,
Function=function(aC)
aB.Scale=aC
d:UpdateTextGUI()
end,
}
local aC=aw:CreateToggle{
Name="Shadow",
Tooltip="Renders shadowed text.",
Default=true,
NoDefaultCallback=true,
Function=function()
d:UpdateTextGUI()
end,
}
local aD
local aE=aw:CreateToggle{
Name="Gradient",
Tooltip="Renders a gradient",
Default=true,
NoDefaultCallback=true,
Function=function(aE)
aD.Object.Visible=aE
d:UpdateTextGUI()
end,
}
aD=aw:CreateToggle{
Name="V4 Gradient",
Function=function()
d:UpdateTextGUI()
end,
Default=true,
NoDefaultCallback=true,
Darker=true,
Visible=aE.Enabled
}
local aF=aw:CreateToggle{
Name="Animations",
Tooltip="Use animations on text gui",
Function=function()
d:UpdateTextGUI()
end,
}
local aH=aw:CreateToggle{
Name="Watermark",
Tooltip="Renders a vape watermark",
Default=true,
NoDefaultCallback=true,
Function=function()
d:UpdateTextGUI()
end,
}
local aI={
Value=0.5,
Object={Visible={}},
}
local aJ={Enabled=false}
local aK=aw:CreateToggle{
Name="Render background",
Default=true,
NoDefaultCallback=true,
Function=function(aK)
aI.Object.Visible=aK
aJ.Object.Visible=aK
d:UpdateTextGUI()
end,
}
aI=aw:CreateSlider{
Name="Transparency",
Min=0,
Max=1,
Default=0.6,
Decimal=10,
Function=function()
d:UpdateTextGUI()
end,
Darker=true,
Visible=aK.Enabled
}
aJ=aw:CreateToggle{
Name="Tint",
Function=function()
d:UpdateTextGUI()
end,
Default=true,
NoDefaultCallback=true,
Darker=true,
Visible=aK.Enabled
}
local aL
local aM=aw:CreateToggle{
Name="Hide modules",
Tooltip="Allows you to blacklist certain modules from being shown.",
Function=function(aM)
aL.Object.Visible=aM
d:UpdateTextGUI()
end,
}
aL=aw:CreateTextList{
Name="Blacklist",
Tooltip="Name of module to hide.",
Icon=u"vape/assets/new/blockedicon.png",
Tab=u"vape/assets/new/blockedtab.png",
TabSize=UDim2.fromOffset(21,16),
Color=Color3.fromRGB(250,50,56),
Function=function()
d:UpdateTextGUI()
end,
Visible=false,
Darker=true,
}
local aN=aw:CreateToggle{
Name="Hide render",
Function=function()
d:UpdateTextGUI()
end,
}
local aO
local aP
local aQ
local aR
local aS=aw:CreateToggle{
Name="Add custom text",
Function=function(aS)
aO.Object.Visible=aS
aP.Object.Visible=aS
aQ.Object.Visible=aS
aR.Object.Visible=aQ.Enabled and aS
d:UpdateTextGUI()
end,
}
aO=aw:CreateTextBox{
Name="Custom text",
Function=function()
d:UpdateTextGUI()
end,
Darker=true,
Visible=false,
}
d.settextguicustomtext=function(aT)
aS:SetValue(true)
aK:SetValue(aT)
end
aP=aw:CreateFont{
Name="Custom Font",
Blacklist="Arial",
Function=function()
d:UpdateTextGUI()
end,
Darker=true,
Visible=false,
}
aQ=aw:CreateToggle{
Name="Set custom text color",
Function=function(aT)
aR.Object.Visible=aT
d:UpdateGUI(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
end,
Darker=true,
Visible=false,
}
aR=aw:CreateColorSlider{
Name="Color of custom text",
Function=function()
d:UpdateGUI(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
end,
Darker=true,
Visible=false,
}





local aT={}
local aU=Instance.new"ImageLabel"
aU.Name="Logo"
aU.Size=UDim2.fromOffset(80,21)
aU.Position=UDim2.new(1,-142,0,3)
aU.BackgroundTransparency=1
aU.BorderSizePixel=0
aU.Visible=false
aU.BackgroundColor3=Color3.new()
aU.Image=u"vape/assets/new/textvape.png"
aU.Parent=aw.Children

local aV=aw.Children.AbsolutePosition.X>(B.AbsoluteSize.X/2)
d:Clean(aw.Children:GetPropertyChangedSignal"AbsolutePosition":Connect(function()
if d.ThreadFix then
setthreadidentity(8)
end
local aW=aw.Children.AbsolutePosition.X>(B.AbsoluteSize.X/2)
if aV~=aW then
aV=aW
d:UpdateTextGUI()
end
end))

local aW=Instance.new"ImageLabel"
aW.Name="Logo2"
aW.Size=UDim2.fromOffset(33,18)
aW.Position=UDim2.new(1,1,0,1)
aW.BackgroundColor3=Color3.new()
aW.BackgroundTransparency=1
aW.BorderSizePixel=0
aW.Image=u"vape/assets/new/textv4.png"
aW.Parent=aU
local aX=aU:Clone()
aX.Position=UDim2.fromOffset(1,1)
aX.ZIndex=0
aX.Visible=true
aX.ImageColor3=Color3.new()
aX.ImageTransparency=0.65
aX.Parent=aU
aX.Logo2.ZIndex=0
aX.Logo2.ImageColor3=Color3.new()
aX.Logo2.ImageTransparency=0.65
local aY=Instance.new"UIGradient"
aY.Rotation=90
aY.Parent=aU
local aZ=Instance.new"UIGradient"
aZ.Rotation=90
aZ.Parent=aW
local a_=Instance.new"TextLabel"
a_.Position=UDim2.fromOffset(5,2)
a_.BackgroundTransparency=1
a_.BorderSizePixel=0
a_.Visible=false
a_.Text=""
a_.TextSize=25
a_.FontFace=aP.Value
a_.RichText=true
local a0=a_:Clone()
a_:GetPropertyChangedSignal"Position":Connect(function()
a0.Position=UDim2.new(
a_.Position.X.Scale,
a_.Position.X.Offset+1,
0,
a_.Position.Y.Offset+1
)
end)
a_:GetPropertyChangedSignal"FontFace":Connect(function()
a0.FontFace=a_.FontFace
end)
a_:GetPropertyChangedSignal"Text":Connect(function()
a0.Text=removeTags(a_.Text)
end)
a_:GetPropertyChangedSignal"Size":Connect(function()
a0.Size=a_.Size
end)
a0.TextColor3=Color3.new()
a0.TextTransparency=0.65
a0.Parent=aw.Children
a_.Parent=aw.Children
local a1=Instance.new"Frame"
a1.Name="Holder"
a1.Size=UDim2.fromScale(1,1)
a1.Position=UDim2.fromOffset(5,37)
a1.BackgroundTransparency=1
a1.Parent=aw.Children
local a2=Instance.new"UIListLayout"
a2.HorizontalAlignment=Enum.HorizontalAlignment.Right
a2.VerticalAlignment=Enum.VerticalAlignment.Top
a2.SortOrder=Enum.SortOrder.LayoutOrder
a2.Parent=a1





local a3
local a4
local a5
a4=d:CreateOverlay{
Name="Target Info",
Icon=u"vape/assets/new/targetinfoicon.png",
Size=UDim2.fromOffset(14,14),
Position=UDim2.fromOffset(12,14),
CategorySize=240,
Function=function(a6)
if a6 then
task.spawn(function()
repeat
a3:UpdateInfo()
task.wait()
until not a4.Button or not a4.Button.Enabled
end)
end
end,
}

local a6=Instance.new"Frame"
a6.Size=UDim2.fromOffset(240,89)
a6.BackgroundColor3=m.Dark(o.Main,0.1)
a6.BackgroundTransparency=0.5
a6.Parent=a4.Children
local a7=addBlur(a6)
a7.Visible=false
addCorner(a6)
local a8=Instance.new"ImageLabel"
a8.Size=UDim2.fromOffset(26,27)
a8.Position=UDim2.fromOffset(19,17)
a8.BackgroundColor3=o.Main
a8.Image="rbxthumb://type=AvatarHeadShot&id=1&w=420&h=420"
a8.Parent=a6
local a9=Instance.new"Frame"
a9.Size=UDim2.fromScale(1,1)
a9.BackgroundTransparency=1
a9.BackgroundColor3=Color3.new(1,0,0)
a9.Parent=a8
addCorner(a9)
local ba=addBlur(a8)
ba.Visible=false
addCorner(a8)
local bb=Instance.new"TextLabel"
bb.Size=UDim2.fromOffset(145,20)
bb.Position=UDim2.fromOffset(54,20)
bb.BackgroundTransparency=1
bb.Text="Target name"
bb.TextXAlignment=Enum.TextXAlignment.Left
bb.TextYAlignment=Enum.TextYAlignment.Top
bb.TextScaled=true
bb.TextColor3=m.Light(o.Text,0.4)
bb.TextStrokeTransparency=1
bb.FontFace=o.Font
local bc=bb:Clone()
bc.Position=UDim2.fromOffset(55,21)
bc.TextColor3=Color3.new()
bc.TextTransparency=0.65
bc.Visible=false
bc.Parent=a6
bb:GetPropertyChangedSignal"Size":Connect(function()
bc.Size=bb.Size
end)
bb:GetPropertyChangedSignal"Text":Connect(function()
bc.Text=bb.Text
end)
bb:GetPropertyChangedSignal"FontFace":Connect(function()
bc.FontFace=bb.FontFace
end)
bb.Parent=a6
local bd=Instance.new"Frame"
bd.Name="HealthBKG"
bd.Size=UDim2.fromOffset(200,9)
bd.Position=UDim2.fromOffset(20,56)
bd.BackgroundColor3=o.Main
bd.BorderSizePixel=0
bd.Parent=a6
addCorner(bd,UDim.new(1,0))
local be=bd:Clone()
be.Size=UDim2.fromScale(0.8,1)
be.Position=UDim2.new()
be.BackgroundColor3=Color3.fromHSV(0.4,0.89,0.75)
be.Parent=bd
be:GetPropertyChangedSignal"Size":Connect(function()
be.Visible=be.Size.X.Scale>0.01
end)
local bf=be:Clone()
bf.Size=UDim2.new()
bf.Position=UDim2.fromScale(1,0)
bf.AnchorPoint=Vector2.new(1,0)
bf.BackgroundColor3=Color3.fromRGB(255,170,0)
bf.Visible=false
bf.Parent=bd
bf:GetPropertyChangedSignal"Size":Connect(function()
bf.Visible=bf.Size.X.Scale>0.01
end)
local bg=addBlur(bd)
bg.SliceCenter=Rect.new(52,31,261,510)
bg.ImageColor3=Color3.new()
bg.Visible=false
local bh=Instance.new"UIStroke"
bh.Enabled=false
bh.Color=Color3.fromHSV(0.44,1,1)
bh.Parent=a6

a4:CreateFont{
Name="Font",
Blacklist="Arial",
Function=function(bi)
bb.FontFace=bi
end,
}
local bi={
Value=0.5,
Object={Visible={}},
}
local bj=a4:CreateToggle{
Name="Use Displayname",
Default=true,
}
a4:CreateToggle{
Name="Render Background",
Function=function(bk)
a6.BackgroundTransparency=bk and bi.Value or 1
bc.Visible=not bk
a7.Visible=bk
bg.Visible=not bk
ba.Visible=not bk
bi.Object.Visible=bk
end,
Default=true,
}
bi=a4:CreateSlider{
Name="Transparency",
Min=0,
Max=1,
Default=0.5,
Decimal=10,
Function=function(bk)
a6.BackgroundTransparency=bk
end,
Darker=true,
}
local bk
local bl=a4:CreateToggle{
Name="Custom Color",
Function=function(bl)
bk.Object.Visible=bl
if bl then
a6.BackgroundColor3=
Color3.fromHSV(bk.Hue,bk.Sat,bk.Value)
a8.BackgroundColor3=
Color3.fromHSV(bk.Hue,bk.Sat,math.max(bk.Value-0.1,0.075))
bd.BackgroundColor3=a8.BackgroundColor3
else
a6.BackgroundColor3=m.Dark(o.Main,0.1)
a8.BackgroundColor3=o.Main
bd.BackgroundColor3=o.Main
end
end,
}
bk=a4:CreateColorSlider{
Name="Color",
Function=function(bm,bn,I)
if bl.Enabled then
a6.BackgroundColor3=Color3.fromHSV(bm,bn,I)
a8.BackgroundColor3=Color3.fromHSV(bm,bn,math.max(I-0.1,0))
bd.BackgroundColor3=a8.BackgroundColor3
end
end,
Darker=true,
Visible=false,
}
d:setupguicolorsync(a4,{
Color1=bk,
Default=true
})
a4:CreateToggle{
Name="Border",
Function=function(bm)
bh.Enabled=bm
a5.Object.Visible=bm
end,
}
a5=a4:CreateColorSlider{
Name="Border Color",
Function=function(bm,bn,I,J)
bh.Color=Color3.fromHSV(bm,bn,I)
bh.Transparency=1-J
end,
Darker=true,
Visible=false,
}

local bm=0
local bn=0
a3={
Targets={},
Object=a6,
UpdateInfo=function(I)
local J=d.Libraries
if not J then
return
end

for K,L in I.Targets do
if L<tick()then
I.Targets[K]=nil
end
end

local K,L=(tick())
for M,N in I.Targets do
if N>K then
L=M
K=N
end
end

a6.Visible=L~=nil or v.Visible
if L then
bb.Text=L.Player and(bj.Enabled and L.Player.DisplayName or L.Player.Name)
or L.Character and L.Character.Name
or bb.Text
a8.Image="rbxthumb://type=AvatarHeadShot&id="
..(L.Player and L.Player.UserId or 1)
.."&w=420&h=420"

if not L.Character then
L.Health=L.Health or 0
L.MaxHealth=L.MaxHealth or 100
end

if L.Health~=bm or L.MaxHealth~=bn then
local M=math.max(L.Health/L.MaxHealth,0)
n:Tween(be,TweenInfo.new(0.3),{
Size=UDim2.fromScale(math.min(M,1),1),
BackgroundColor3=Color3.fromHSV(math.clamp(M/2.5,0,1),0.89,0.75),
})
n:Tween(bf,TweenInfo.new(0.3),{
Size=UDim2.fromScale(math.clamp(M-1,0,0.8),1),
})
if bm>L.Health and I.LastTarget==L then
n:Cancel(a9)
a9.BackgroundTransparency=0.3
n:Tween(a9,TweenInfo.new(0.5),{
BackgroundTransparency=1,
})
end
bm=L.Health
bn=L.MaxHealth
end

if not L.Character then
table.clear(L)
end
I.LastTarget=L
end
return L
end,
}
d.Libraries.targetinfo=a3

function d.UpdateTextGUI(I,J)
if not J and not d.Loaded then
return
end
if aw.Button.Enabled then
local K=aw.Children.AbsolutePosition.X>(B.AbsoluteSize.X/2)
aU.Visible=aH.Enabled
aU.Position=K and UDim2.new(1/aB.Scale,-113,0,6)or UDim2.fromOffset(0,6)
aX.Visible=aC.Enabled
a_.Text=aO.Value
a_.FontFace=aP.Value
a_.Visible=a_.Text~=""and aS.Enabled
a0.Visible=a_.Visible and aC.Enabled
a2.HorizontalAlignment=K and Enum.HorizontalAlignment.Right or Enum.HorizontalAlignment.Left
a1.Size=UDim2.fromScale(1/aB.Scale,1)
a1.Position=UDim2.fromOffset(
K and 3 or 0,
11
+(aU.Visible and aU.Size.Y.Offset or 0)
+(a_.Visible and 28 or 0)
+(aK.Enabled and 3 or 0)
)
if a_.Visible then
local L=
E(removeTags(a_.Text),a_.TextSize,a_.FontFace)
a_.Size=UDim2.fromOffset(L.X,L.Y)
a_.Position=UDim2.new(
K and 1/aB.Scale or 0,
K and-L.X or 0,
0,
(aU.Visible and 32 or 8)
)
end

local L={}
for M,N in aT do
if N.Enabled then
table.insert(L,N.Object.Name)
end
N.Object:Destroy()
end
table.clear(aT)

local M=TweenInfo.new(0.3,Enum.EasingStyle.Exponential)
for N,O in d.Modules do
if aM.Enabled and table.find(aL.ListEnabled,N)then
continue
end
if aN.Enabled and O.Category=="Render"then
continue
end
if O.Enabled or table.find(L,N)then
local P=Instance.new"Frame"
P.Name=N
P.Size=UDim2.fromOffset()
P.BackgroundTransparency=1
P.ClipsDescendants=true
P.Parent=a1
local Q
local R
if aK.Enabled then
Q=Instance.new"Frame"
Q.Size=UDim2.new(1,3,1,0)
Q.BackgroundColor3=m.Dark(o.Main,0.15)
Q.BackgroundTransparency=aI.Value
Q.BorderSizePixel=0
Q.Parent=P
local S=Instance.new"Frame"
S.Size=UDim2.new(1,0,0,1)
S.Position=UDim2.new(0,0,1,-1)
S.BackgroundColor3=Color3.new()
S.BackgroundTransparency=0.928
+(0.072*math.clamp((aI.Value-0.5)/0.5,0,1))
S.BorderSizePixel=0
S.Parent=Q
local T=S:Clone()
T.Name="Line"
T.Position=UDim2.new()
T.Parent=Q
R=Instance.new"Frame"
R.Size=UDim2.new(0,2,1,0)
R.Position=K and UDim2.new(1,-5,0,0)or UDim2.new()
R.BorderSizePixel=0
R.Parent=Q
end
local S=Instance.new"TextLabel"
S.Position=UDim2.fromOffset(K and 3 or 6,2)
S.BackgroundTransparency=1
S.BorderSizePixel=0
S.Text=N..(O.ExtraText and" <font color='#A8A8A8'>"..O.ExtraText().."</font>"or"")
S.TextSize=15
S.FontFace=ay.Value
S.RichText=true
local T=E(removeTags(S.Text),S.TextSize,S.FontFace)
S.Size=UDim2.fromOffset(T.X,T.Y)
if aC.Enabled then
local U=S:Clone()
U.Position=
UDim2.fromOffset(S.Position.X.Offset+1,S.Position.Y.Offset+1)
U.Text=removeTags(S.Text)
U.TextColor3=Color3.new()
U.Parent=P
end
S.Parent=P
local U=UDim2.fromOffset(T.X+10,T.Y+(aK.Enabled and 5 or 3))
if aF.Enabled then
if not table.find(L,N)then
n:Tween(P,M,{
Size=U,
})
else
P.Size=U
if not O.Enabled then
n:Tween(P,M,{
Size=UDim2.fromOffset(),
})
end
end
else
P.Size=O.Enabled and U or UDim2.fromOffset()
end
table.insert(aT,{
Object=P,
Text=S,
Background=Q,
Color=R,
Enabled=O.Enabled,
})
end
end

if ax.Value=="Alphabetical"then
table.sort(aT,function(N,O)
return N.Text.Text<O.Text.Text
end)
else
table.sort(aT,function(N,O)
return N.Text.Size.X.Offset>O.Text.Size.X.Offset
end)
end

for N,O in aT do
if O.Color then
O.Color.Parent.Line.Visible=N~=1
end
O.Object.LayoutOrder=N
end
end

d:UpdateGUI(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value,true)
end

function d.UpdateGUI(I,J,K,L,M)
if d.Loaded==nil then
return
end
d.GUIColorChanged:Fire(J,K,L,M)
if not M and d.GUIColor.Rainbow then
return
end
if aw.Button.Enabled then
aY.Color=ColorSequence.new{
ColorSequenceKeypoint.new(0,Color3.fromHSV(J,K,L)),
ColorSequenceKeypoint.new(
1,
aE.Enabled and Color3.fromHSV(d:Color((J-0.075)%1))
or Color3.fromHSV(J,K,L)
),
}
aZ.Color=aE.Enabled and aD.Enabled and aY.Color
or ColorSequence.new{
ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),
ColorSequenceKeypoint.new(1,Color3.new(1,1,1)),
}
a_.TextColor3=aQ.Enabled
and Color3.fromHSV(aR.Hue,aR.Sat,aR.Value)
or aY.Color.Keypoints[2].Value

local N=aA.Value=="Custom color"
and Color3.fromHSV(az.Hue,az.Sat,az.Value)
or nil
for O,P in aT do
P.Text.TextColor3=N
or(
d.GUIColor.Rainbow
and Color3.fromHSV(d:Color((J-((aE and O+2 or O)*0.025))%1))
or aY.Color.Keypoints[2].Value
)
if P.Color then
P.Color.BackgroundColor3=P.Text.TextColor3
end
if aJ.Enabled and P.Background then
P.Background.BackgroundColor3=m.Dark(P.Text.TextColor3,0.75)
end
end
end

if not v.Visible and not d.Legit.Window.Visible then
return
end
local N=d.GUIColor.Rainbow and d.RainbowMode.Value~="Retro"

for O,P in d.Categories do
if O=="Main"then
P.Object.VapeLogo.V4Logo.ImageColor3=Color3.fromHSV(J,K,L)
for Q,R in P.Buttons do
if R.Enabled then
R.Object.TextColor3=N
and Color3.fromHSV(d:Color((J-(R.Index*0.025))%1))
or Color3.fromHSV(J,K,L)
if R.Icon then
R.Icon.ImageColor3=R.Object.TextColor3
end
end
end
end

if P.Options then
for Q,R in P.Options do
if R.Color then
R:Color(J,K,L,N)
end
end
end

if P.Type=="CategoryList"then
P.Object.Children.Add.AddButton.ImageColor3=N and Color3.fromHSV(d:Color(J%1))
or Color3.fromHSV(J,K,L)
if P.Selected then
P.Selected.BackgroundColor3=N and Color3.fromHSV(d:Color(J%1))
or Color3.fromHSV(J,K,L)
P.Selected.Title.TextColor3=d.GUIColor.Rainbow and Color3.new(0.19,0.19,0.19)
or d:TextColor(J,K,L)
P.Selected.Dots.Dots.ImageColor3=P.Selected.Title.TextColor3
P.Selected.Bind.Icon.ImageColor3=P.Selected.Title.TextColor3
P.Selected.Bind.TextLabel.TextColor3=P.Selected.Title.TextColor3
end
end
end

for O,P in d.Modules do
if P.Enabled then
P.Object.BackgroundColor3=N
and Color3.fromHSV(d:Color((J-(P.Index*0.025))%1))
or Color3.fromHSV(J,K,L)
P.Object.TextColor3=d.GUIColor.Rainbow and Color3.new(0.19,0.19,0.19)
or d:TextColor(J,K,L)
P.Object.UIGradient.Enabled=N and d.RainbowMode.Value=="Gradient"
if P.Object.UIGradient.Enabled then
P.Object.BackgroundColor3=Color3.new(1,1,1)
P.Object.UIGradient.Color=ColorSequence.new{
ColorSequenceKeypoint.new(0,Color3.fromHSV(d:Color((J-(P.Index*0.025))%1))),
ColorSequenceKeypoint.new(
1,
Color3.fromHSV(d:Color((J-((P.Index+1)*0.025))%1))
),
}
end
P.Object.Bind.Icon.ImageColor3=P.Object.TextColor3
P.Object.Bind.TextLabel.TextColor3=P.Object.TextColor3
P.Object.Dots.Dots.ImageColor3=P.Object.TextColor3
end

for Q,R in P.Options do
if R.Color then
R:Color(J,K,L,N)
end
end
end

for O,P in d.Overlays.Toggles do
if P.Enabled then
n:Cancel(P.Object.Knob)
P.Object.Knob.BackgroundColor3=N and Color3.fromHSV(d:Color((J-(O*0.075))%1))
or Color3.fromHSV(J,K,L)
end
end

if d.Legit.Icon then
d.Legit.Icon.ImageColor3=Color3.fromHSV(J,K,L)
end

if d.Legit.Window.Visible then
for O,P in d.Legit.Modules do
if P.Enabled then
n:Cancel(P.Object.Knob)
P.Object.Knob.BackgroundColor3=Color3.fromHSV(J,K,L)
end

for Q,R in P.Options do
if R.Color then
R:Color(J,K,L,N)
end
end
end
end
end

d:Clean(q.ChildRemoved:Connect(function()
for I,J in q:GetChildren()do
if n.Tween then
n:Tween(J,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{
Position=UDim2.new(1,0,1,-(29+(78*I))),
})
end
end
end))

d:Clean(h.InputBegan:Connect(function(I)
if not h:GetFocusedTextBox()and I.KeyCode~=Enum.KeyCode.Unknown then
table.insert(d.HeldKeybinds,I.KeyCode.Name)
if d.Binding then
return
end

if checkKeybinds(d.HeldKeybinds,d.Keybind,I.KeyCode.Name)then
if d.ThreadFix then
setthreadidentity(8)
end
for J,K in d.Windows do
K.Visible=false
end
v.Visible=not v.Visible
z.Visible=false
d:BlurCheck()
end

local J=false
for K,L in d.Modules do
if checkKeybinds(d.HeldKeybinds,L.Bind,I.KeyCode.Name)then
J=true
if d.ToggleNotifications.Enabled then
d:CreateNotification(
"Module Toggled",
K
.."<font color='#FFFFFF'> has been </font>"
..(not L.Enabled and"<font color='#5AFF5A'>Enabled</font>"or"<font color='#FF5A5A'>Disabled</font>")
.."<font color='#FFFFFF'>!</font>",
0.75
)
end
L:Toggle(true)
end
end
if J then
d:UpdateTextGUI()
end

for K,L in d.Profiles do
if checkKeybinds(d.HeldKeybinds,L.Bind,I.KeyCode.Name)and L.Name~=d.Profile then
d:Save(L.Name)
d:Load(true)
break
end
end
end
end))

d:Clean(h.InputEnded:Connect(function(I)
if not h:GetFocusedTextBox()and I.KeyCode~=Enum.KeyCode.Unknown then
if d.Binding then
if not d.MultiKeybind.Enabled then
d.HeldKeybinds={I.KeyCode.Name}
end
d.Binding:SetBind(
checkKeybinds(d.HeldKeybinds,d.Binding.Bind,I.KeyCode.Name)and{}
or d.HeldKeybinds,
true
)
d.Binding=nil
end
end

local J=table.find(d.HeldKeybinds,I.KeyCode.Name)
if J then
table.remove(d.HeldKeybinds,J)
end
end))

return d