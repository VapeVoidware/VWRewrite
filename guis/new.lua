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
Indicators={},
AliasesConfig={KitESP=
{
"ElderESP",
"OrbESP",
"BeeESP",
"MetalESP"
}
}
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

local m=f.Players

d.isMobile=h.TouchEnabled and not h.KeyboardEnabled

local n={}
local o={
tweens={},
tweenstwo={},
}
local p={
Main=Color3.fromRGB(0,0,0),
Text=Color3.fromRGB(255,255,255),
Font=Font.fromEnum(Enum.Font.Arial),
FontSemiBold=Font.fromEnum(Enum.Font.Arial,Enum.FontWeight.SemiBold),
Tween=TweenInfo.new(0.16,Enum.EasingStyle.Linear),
}

local function getTableSize(q)
local r=0
for s in q do
r+=1
end
return r
end

local function loopClean(q,r)
r=r or{}
if r[q]then
return
end
r[q]=true

local s={
ModuleCategory=true,
CategoryApi=true,
}

for t,u in pairs(q)do
if not s[t]and type(u)=="table"then
loopClean(u,r)
end
q[t]=nil
end
end

local function addMaid(q)
q.Connections={}
function q.Clean(r,s)
if typeof(s)=="Instance"then
table.insert(r.Connections,{
Disconnect=function()
s:ClearAllChildren()
s:Destroy()
end,
})
elseif type(s)=="function"then
table.insert(r.Connections,{
Disconnect=s,
})
elseif typeof(s)=="thread"then
table.insert(r.Connections,{
Disconnect=function()
pcall(task.cancel,s)
end,
})
else
table.insert(r.Connections,s)
end
end
end
addMaid(d)

local function loadJson(q,r)
local s,t=pcall(function()
local s=r and q or readfile(q)
return l:JSONDecode(s)
end)
return s and type(t)=="table"and t or nil
end

local function decode(q)
return loadJson(q,true)
end

local function encode(q)
local r,s=pcall(function()
return l:JSONEncode(q)
end)
if not r then
warn(`[encode]: {tostring(s)}`)
end
return r and s
end

local function removeSpaces(q)
return q:gsub(" ","")
end

local function highlightIgnoringSpaces(q,r)
local s=q:lower():gsub("%s+","")
local t=r:lower():gsub("%s+","")

local u=s:find(t)
if not u then
return q
end


local v,w
local x=0

for y=1,#q do
local z=q:sub(y,y)
if z~=" "then
x+=1
end

if x==u and not v then
v=y
end

if x==u+#t-1 then
w=y
break
end
end

local y=q:sub(1,v-1)
local z=q:sub(v,w)
local A=q:sub(w+1)

return y..`<b><font color="#FFFFFF">{z}</font></b>`..A
end

local function flickerTextEffect(q,r,s)
if r==true and q.TextTransparency==0 then
o:Tween(q,TweenInfo.new(0.15),{
TextTransparency=1,
}).Completed:Wait()
end
if s~=nil then
q.Text=s
end
o:Tween(q,TweenInfo.new(0.15),{
TextTransparency=r and 0 or 1,
}).Completed:Wait()
end

local function flickerImageEffect(q,r,s)
if not q or not(q:IsA"ImageButton"or q:IsA"ImageLabel")then
return
end

r=r or 0.5
s=s or 0.15

local t=tick()
local u=q.Size
local v=q.ImageColor3
local w=q.ImageTransparency

local x=Instance.new"UIScale"
x.Scale=1
x.Parent=q

task.spawn(function()
o:Tween(x,TweenInfo.new(s),{
Scale=1.2
})
while tick()-t<r and q.Parent do
o:Tween(q,TweenInfo.new(s),{
ImageTransparency=0,
ImageColor3=Color3.fromRGB(255,255,255)
})

task.wait(s)

o:Tween(q,TweenInfo.new(s),{
ImageTransparency=w,
ImageColor3=v
})

task.wait(s)
end

pcall(function()
x:Destroy()
end)
o:Tween(x,TweenInfo.new(s),{
Scale=1,
})
q.Size=u
q.ImageTransparency=w
end)
end

local function Color3ToHex(q)
local r=math.floor(q.R*255)
local s=math.floor(q.G*255)
local t=math.floor(q.B*255)
return string.format("#%02x%02x%02x",r,s,t)
end

local function hsv(q,r,s)
local t,u=pcall(function()
return Color3.fromHSV(q,r,s)
end)
return t,u
end

local function str(q)
return tostring(q)
end

local function tblcheck(q)
return(q~=nil and type(q)=="table")
end

local function num(q)
if q==nil then
return q
end
return tonumber(q)
end

local function count(q)
local r=0
for s,t in q do
r=r+1
end
return r
end

local function wrap(q)
return a:wrap(q,{
name="wrap:api"
})
end
d.wrap=wrap

local function connectDoubleClick(q,r,t)
if not shared.VoidDev then return end
local u=0
t=t or 0.25
if not(r~=nil and type(r)=="function")then
r=function()end
else
d.wrap(r)
end

q.Activated:Connect(function()
local v=tick()

print(v-u,t)
if v-u<=t then
r()
end

u=v
end)
end
d.connectDoubleClick=connectDoubleClick

local function connectguicolorchange(q,r)
q=wrap(q)
local t
if type(q)=="function"then
q(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
t=d.GUIColorChanged.Event:Connect(q)
else
q.BackgroundColor3=Color3.fromHSV(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
t=d.GUIColorChanged.Event:Connect(function(u,v,w)
q.BackgroundColor3=Color3.fromHSV(u,v,w)
end)
end
if r and type(q)=="function"then
d:Clean(t)
return{
run=function()
q(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
end,
conn=t
}
end
return t
end
d.connectguicolorchange=connectguicolorchange

d.GuiColorSyncAPI={}
function d.setupguicolorsync(q,r,t,u)
if not(u~=nil and type(u)=="function")then
u=function()end
else
u=wrap(u)
end
if not tblcheck(r)then
a:throw(`[setupguicolorsync]: api invalid! {tostring(r)}`)
return
end
if not(tblcheck(t)and tblcheck(t.Color1))then
a:throw(`[setupguicolorsync]: options invalid! {tostring(t)}`)
return
end

local v,w,x=t.Color1,t.Color2,t.Color3
local y=false
























local z=function()end

local A
local B=false
if not r.Name then
B=true
r.Name=l:GenerateGUID(false)
end
A=q.GuiColorSyncAPI[r.Name]or r:CreateToggle{
Name="GUI Color Sync",
Function=function(C)
u(C)
if C then
z()
end
end,
Tooltip=t.Tooltip or"Syncs with the gui theme color",
Default=t.Default
}
q.GuiColorSyncAPI[r.Name]=A

for C,D in{v,w,x}do
D:ConnectCallback(function()
if A.Enabled and not y then
local E
if B then
E="GUI Sync"
else
E=`GUI Sync - {r.Name}`
end
InfoNotification(E,"Disabled due to color slider change! Re-enable if you want :D",5)
A:Toggle()
end
end)
end

z=connectguicolorchange(function(C,D,E)
if not A.Enabled then return end
local F={Hue=C,Sat=D,Value=E}

y=true

if x then
local G=F

if t.Color1HueShift then
local H=(C+t.Color1HueShift)%1
G={Hue=H,Sat=D,Value=E}
end
local H=(C+(t.Color2HueShift or 0.1))%1
local I=(C+(t.Color3HueShift or 0.2))%1
local J={Hue=H,Sat=D,Value=E}
local K={Hue=I,Sat=D,Value=E}

v:SetValue(G.Hue,G.Sat,G.Value)
w:SetValue(J.Hue,J.Sat,J.Value)
x:SetValue(K.Hue,K.Sat,K.Value)
elseif w then
local G=F
local H=(C+(t.Color2HueShift or 0.1))%1
local I={Hue=H,Sat=D,Value=E}

v:SetValue(G.Hue,G.Sat,G.Value)
w:SetValue(I.Hue,I.Sat,I.Value)
else
if t.Color1HueShift then
local G=(C+t.Color1HueShift)%1
F={Hue=G,Sat=D,Value=E}
end
v:SetValue(F.Hue,F.Sat,F.Value)
end

y=false
end,true).run

return A
end

local function connectvisibilitychange(q)
return d.VisibilityChanged.Event:Connect(q)
end
d.connectvisibilitychange=connectvisibilitychange

local q=Instance.new"GetTextBoundsParams"
q.Width=math.huge
local r
local t
local u=getcustomasset
local v
local w
local x
local y
local z
local A
local B
local C

local D={
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

local E=isfile
or function(E)
local F,G=pcall(function()
return readfile(E)
end)
return F and G~=nil and G~=""
end

local F=function(F,G,H)
q.Text=F
q.Size=G
if typeof(H)=="Font"then
q.Font=H
end
local I,J=pcall(function()
return i:GetTextBoundsAsync(q)
end)
if not I then
a:report{
type="getfontsize-function",
err=J,
args={F,G,H},
notifyBlacklisted=true,
}
end
return I and J
end

local function addBlur(G,H)
local I=Instance.new"ImageLabel"
I.Name="Blur"
I.Size=UDim2.new(1,89,1,52)
I.Position=UDim2.fromOffset(-48,-31)
I.BackgroundTransparency=1
I.Image=v("vape/assets/new/"..(H and"blurnotif"or"blur")..".png")
I.ScaleType=Enum.ScaleType.Slice
I.SliceCenter=Rect.new(52,31,261,502)
I.Parent=G

return I
end

local function addCorner(G,H)
local I=Instance.new"UICorner"
I.CornerRadius=H or UDim.new(0,5)
I.Parent=G

return I
end

local function addCloseButton(G,H)
local I=Instance.new"ImageButton"
I.Name="Close"
I.Size=UDim2.fromOffset(24,24)
I.Position=UDim2.new(1,-35,0,H or 9)
I.BackgroundColor3=Color3.new(1,1,1)
I.BackgroundTransparency=1
I.AutoButtonColor=false
I.Image=v"vape/assets/new/close.png"
I.ImageColor3=n.Light(p.Text,0.2)
I.ImageTransparency=0.5
I.Parent=G
addCorner(I,UDim.new(1,0))

I.MouseEnter:Connect(function()
I.ImageTransparency=0.3
o:Tween(I,p.Tween,{
BackgroundTransparency=0.6,
})
end)
I.MouseLeave:Connect(function()
I.ImageTransparency=0.5
o:Tween(I,p.Tween,{
BackgroundTransparency=1,
})
end)

return I
end





local function addTooltip(G,H)
if d.isMobile then return end
if not H then
return
end

local function tooltipMoved(I,J)
local K=I+16+A.Size.X.Offset>(B.Scale*1920)
A.Position=UDim2.fromOffset(
(K and I-(A.Size.X.Offset*B.Scale)-16 or I+16)/B.Scale,
((J+11)-(A.Size.Y.Offset/2))/B.Scale
)
A.Visible=z.Visible
end

local I={}
I[1]=G.MouseEnter:Connect(function(J,K)
local L=F(H,A.TextSize,p.Font)
A.Size=UDim2.fromOffset(L.X+10,L.Y+10)
A.Text=H
tooltipMoved(J,K)
end)
I[2]=G.MouseMoved:Connect(tooltipMoved)
I[3]=G.MouseLeave:Connect(function()
A.Visible=false
end)
G.Destroying:Once(function()
for J,K in I do
pcall(function()
K:Disconnect()
end)
I[J]=nil
end
end)
end
d.addTooltip=addTooltip

local function checkKeybinds(G,H,I)
if type(H)=="table"then
if table.find(H,I)then
for J,K in H do
if not table.find(G,K)then
return false
end
end
return true
end
end

return false
end



















local function createMobileButton(G,H)
local I=false
local J=Instance.new"TextButton"
J.Size=UDim2.fromOffset(40,40)
J.Position=UDim2.fromOffset(H.X,H.Y)
J.AnchorPoint=Vector2.new(0.5,0.5)
J.BackgroundColor3=G.Enabled and Color3.new(0,0.7,0)or Color3.new()
J.BackgroundTransparency=0.5
J.Text=G.Name
J.TextColor3=Color3.new(1,1,1)
J.TextScaled=true
J.Font=Enum.Font.Gotham
J.Parent=d.gui
local K=Instance.new"UITextSizeConstraint"
K.MaxTextSize=16
K.Parent=J
addCorner(J,UDim.new(1,0))

J.MouseButton1Down:Connect(function()
I=true
local L,M=tick(),h:GetMouseLocation()
repeat
I=(h:GetMouseLocation()-M).Magnitude<6
task.wait()
until(tick()-L)>1 or not I
if I then
G.Bind={}
J:Destroy()
end
end)
J.MouseButton1Up:Connect(function()
I=false
end)
J.Activated:Connect(function()
G:Toggle()
J.BackgroundColor3=G.Enabled and Color3.new(0,0.7,0)or Color3.new()
end)

G.Bind={Button=J}
end

d.http_function=function(G)
if G==nil then
return
end
G=tostring(G)
local H,I=pcall(function()
return{game:HttpGet(G)}
end)
if not(H~=nil and H==true and I~=nil and type(I)=="table")then
return
end
if I[1]~=nil and I[1]==game then
return I[4]
else
return I[1]
end
end



























local G=function(G,H,I)
local J,K
task.spawn(function()
J,K=pcall(function()
return G()
end)
end)
H=H or 5
local L=tick()
repeat task.wait()until J~=nil or tick()-L>=H
if J==nil then
J=false
K="TIMEOUT_EXCEEDED"
end
if not J and shared.VoidDev then
warn(debug.traceback(K))
end
if I~=nil then
return I(J,K)
end
return J,K
end

local H=shared.CACHED_ICON_LIBRARY
if not H then
G(function()
local I,J=pcall(function()
local I=loadstring(d.http_function"https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua")()
I.SetIconsType"lucide"
return I
end)
if not I then
pcall(function()
d:CreateNotification("Vape | Icons","Failure loading custom icons :c",5,'alert')
end)
warn(`[Icons Failure]: {tostring(H)}`)
end
H=I and J or nil
shared.CACHED_ICON_LIBRARY=H
end,3)
end
local function getCustomIcon(I)
if not H then return false end
local J,K=pcall(function()
return H.GetIcon(I)
end)
if not J then
warn(`[getCustomIcon Failure]: {tostring(I)} -> {tostring(K)}`)
end
return J and K~=nil and K or false
end

v=function(I,J)
if J then
local K=getCustomIcon(I)
if K~=false then
return K
else
return''
end
end
return D[I]or getCustomIcon(I)or select(2,pcall(u,I))or''
end

local function makeDraggable(I,J)
I.InputBegan:Connect(function(K)
if J and not J.Visible then
return
end
if
(
K.UserInputType==Enum.UserInputType.MouseButton1
or K.UserInputType==Enum.UserInputType.Touch
)and(K.Position.Y-I.AbsolutePosition.Y<40 or J)
then
local L=Vector2.new(
I.AbsolutePosition.X-K.Position.X,
I.AbsolutePosition.Y-K.Position.Y+j:GetGuiInset().Y
)/B.Scale

local M=h.InputChanged:Connect(function(M)
if
M.UserInputType
==(
K.UserInputType==Enum.UserInputType.MouseButton1
and Enum.UserInputType.MouseMovement
or Enum.UserInputType.Touch
)
then
local N=M.Position
if h:IsKeyDown(Enum.KeyCode.LeftShift)then
L=(L//3)*3
N=(N//3)*3
end
I.AnchorPoint=Vector2.new(0,0)
I.Position=UDim2.fromOffset(
(N.X/B.Scale)+L.X,
(N.Y/B.Scale)+L.Y
)
end
end)

local N
N=h.InputEnded:Connect(function(O)
if O==K and K.UserInputState==Enum.UserInputState.End then
if M then
M:Disconnect()
end
if N then
N:Disconnect()
end
end
end)
end
end)
end
d.makeDraggable=makeDraggable

local function makeDraggable2(I,J)
I.InputBegan:Connect(function(K)
if not J.Visible then
return
end

if
K.UserInputType==Enum.UserInputType.MouseButton1
or K.UserInputType==Enum.UserInputType.Touch
then

local L=K.Position
local M=J.Position

local N
N=h.InputChanged:Connect(function(O)
if
O.UserInputType==Enum.UserInputType.MouseMovement
or O.UserInputType==Enum.UserInputType.Touch
then

local P=O.Position-L

J.Position=UDim2.fromOffset(M.X.Offset+P.X,M.Y.Offset+P.Y)
end
end)

K.Changed:Connect(function()
if K.UserInputState==Enum.UserInputState.End then
if N then
N:Disconnect()
end
end
end)
end
end)
end
d.makeDraggable2=makeDraggable2

local function setupGuiMoveCheck(I,J)
local K=false
local L
I.InputBegan:Connect(function()
K=true
L=J.Position.X.Offset
end)
I.InputEnded:Connect(function()
K=false

end)
return function()
return L==nil or J.Position.X.Offset-L<2.1
end
end

















































local function randomString()
local I={}
for J=1,math.random(10,100)do
I[J]=string.char(math.random(32,126))
end
return table.concat(I)
end

local function removeTags(I)
I=I:gsub("<br%s*/>","\n")
return I:gsub("<[^<>]->","")
end

do
local I=E"vape/profiles/color.txt"and loadJson"vape/profiles/color.txt"
if I then
p.Main=I.Main and Color3.fromRGB(unpack(I.Main))or p.Main
p.Text=I.Text and Color3.fromRGB(unpack(I.Text))or p.Text
p.Font=I.Font
and Font.new(
I.Font:find"rbxasset"and I.Font
or string.format("rbxasset://fonts/families/%s.json",I.Font)
)
or p.Font
p.FontSemiBold=Font.new(p.Font.Family,Enum.FontWeight.SemiBold)
end
q.Font=p.Font
end

do
function n.Dark(I,J)
local K,L,M=I:ToHSV()
return Color3.fromHSV(K,L,math.clamp(select(3,p.Main:ToHSV())>0.5 and M+J or M-J,0,1))
end

function n.Light(I,J)
local K,L,M=I:ToHSV()
return Color3.fromHSV(K,L,math.clamp(select(3,p.Main:ToHSV())>0.5 and M-J or M+J,0,1))
end

function d.Color(I,J)
local K=0.75+(0.15*math.min(J/0.03,1))
if J>0.57 then
K=0.9-(0.4*math.min((J-0.57)/0.09,1))
end
if J>0.66 then
K=0.5+(0.4*math.min((J-0.66)/0.16,1))
end
if J>0.87 then
K=0.9-(0.15*math.min((J-0.87)/0.13,1))
end
return J,K,1
end

function d.TextColor(I,J,K,L)
if L>=0.7 and(K<0.6 or J>0.04 and J<0.56)then
return Color3.new(0.19,0.19,0.19)
end
return Color3.new(1,1,1)
end
end

do
function o.Tween(I,J,K,L,M,N,O)
if type(M)=="boolean"then
N=M
M=nil
end
if type(K)=="table"then
L=K
K=TweenInfo.new(0.15)
end

M=M or I.tweens

if M[J]then
M[J]:Cancel()
M[J]=nil
end

if J.Parent then
local P=g:Create(J,K,L)
M[J]=P

P.Completed:Once(function()
M[J]=nil

if not O then
pcall(function()
for Q,R in pairs(L)do
J[Q]=R
end
end)
end
end)

if not N then
P:Play()
end

return P
else
for P,Q in pairs(L)do
J[P]=Q
end
end
end
o.tween=o.Tween

function o.Cancel(I,J)
if I.tweens[J]then
I.tweens[J]:Cancel()
I.tweens[J]=nil
end
end
o.cancel=o.Cancel
end

d.Libraries={
color=n,
getcustomasset=v,
getfontsize=F,
tween=o,
uipallet=p,
}

local I
I={
Button=function(J,K,L)
local M={
Name=J.Name,
Visible=J.Visible==nil or J.Visible
}
local N=Instance.new"TextButton"
N.Name=J.Name.."Button"
N.Size=UDim2.new(1,0,0,31)
N.BackgroundColor3=n.Dark(K.BackgroundColor3,J.Darker and 0.02 or 0)
N.BackgroundTransparency=J.BackgroundTransparency or 0
N.BorderSizePixel=0
N.AutoButtonColor=false
N.Visible=M.Visible
N.Text=""
N.Parent=K
N:GetPropertyChangedSignal"Visible":Connect(function()
M.Visible=N.Visible
end)
addTooltip(N,J.Tooltip)
local O=Instance.new"Frame"
O.Size=UDim2.fromOffset(200,27)
O.Position=UDim2.fromOffset(10,2)
O.BackgroundColor3=n.Light(p.Main,0.05)
O.Parent=N
addCorner(O)
local P=Instance.new"TextLabel"
P.Size=UDim2.new(1,-4,1,-4)
P.Position=UDim2.fromOffset(2,2)
P.BackgroundColor3=p.Main
P.Text=J.Name
P.TextColor3=n.Dark(p.Text,0.16)
P.TextSize=14
P.FontFace=p.Font
P.Parent=O
addCorner(P,UDim.new(0,4))
J.Function=J.Function and wrap(J.Function)or function()end

function M.SetVisible(Q,R)
if R==nil then
R=not M.Visible
end
N.Visible=R
end

N.MouseEnter:Connect(function()
o:Tween(O,p.Tween,{
BackgroundColor3=n.Light(p.Main,0.3),
})
end)
N.MouseLeave:Connect(function()
o:Tween(O,p.Tween,{
BackgroundColor3=n.Light(p.Main,0.05),
})
end)
N.Activated:Connect(J.Function)
M.Object=N
M.Label=P
return M
end,
ColorSlider=function(J,K,L)
if J.Color then
J.DefaultHue,J.DefaultSat,J.DefaultValue=J.Color:ToHSV()
end
local M={
Type="ColorSlider",
Hue=J.DefaultHue or 0.44,
Sat=J.DefaultSat or 1,
Value=J.DefaultValue or 1,
Opacity=J.DefaultOpacity or 1,
Rainbow=false,
Index=0,
}

local function createSlider(N,O)
local P=Instance.new"TextButton"
P.Name=J.Name.."Slider"..N
P.Size=UDim2.new(1,0,0,50)
P.BackgroundColor3=n.Dark(K.BackgroundColor3,J.Darker and 0.02 or 0)
P.BorderSizePixel=0
P.AutoButtonColor=false
P.Visible=false
P.Text=""
P.Parent=K
local Q=Instance.new"TextLabel"
Q.Name="Title"
Q.Size=UDim2.fromOffset(60,30)
Q.Position=UDim2.fromOffset(10,2)
Q.BackgroundTransparency=1
Q.Text=N
Q.TextXAlignment=Enum.TextXAlignment.Left
Q.TextColor3=n.Dark(p.Text,0.16)
Q.TextSize=11
Q.FontFace=p.Font
Q.Parent=P
local R=Instance.new"Frame"
R.Name="Slider"
R.Size=UDim2.new(1,-20,0,2)
R.Position=UDim2.fromOffset(10,37)
R.BackgroundColor3=Color3.new(1,1,1)
R.BorderSizePixel=0
R.Parent=P
local S=Instance.new"UIGradient"
S.Color=O
S.Parent=R
local T=R:Clone()
T.Name="Fill"
T.Size=UDim2.fromScale(
math.clamp(
N=="Saturation"and M.Sat
or N=="Vibrance"and M.Value
or M.Opacity,
0.04,
0.96
),
1
)
T.Position=UDim2.new()
T.BackgroundTransparency=1
T.Parent=R
local U=Instance.new"Frame"
U.Name="Knob"
U.Size=UDim2.fromOffset(24,4)
U.Position=UDim2.fromScale(1,0.5)
U.AnchorPoint=Vector2.new(0.5,0.5)
U.BackgroundColor3=P.BackgroundColor3
U.BorderSizePixel=0
U.Parent=T
local V=Instance.new"Frame"
V.Name="Knob"
V.Size=UDim2.fromOffset(14,14)
V.Position=UDim2.fromScale(0.5,0.5)
V.AnchorPoint=Vector2.new(0.5,0.5)
V.BackgroundColor3=p.Text
V.Parent=U
addCorner(V,UDim.new(1,0))

P.InputBegan:Connect(function(W)
if
(
W.UserInputType==Enum.UserInputType.MouseButton1
or W.UserInputType==Enum.UserInputType.Touch
)and(W.Position.Y-P.AbsolutePosition.Y)>(20*B.Scale)
then
local X=h.InputChanged:Connect(function(X)
if
X.UserInputType
==(
W.UserInputType==Enum.UserInputType.MouseButton1
and Enum.UserInputType.MouseMovement
or Enum.UserInputType.Touch
)
then
M:SetValue(
nil,
N=="Saturation"
and math.clamp(
(X.Position.X-R.AbsolutePosition.X)/R.AbsoluteSize.X,
0,
1
)
or nil,
N=="Vibrance"
and math.clamp(
(X.Position.X-R.AbsolutePosition.X)/R.AbsoluteSize.X,
0,
1
)
or nil,
N=="Opacity"
and math.clamp(
(X.Position.X-R.AbsolutePosition.X)/R.AbsoluteSize.X,
0,
1
)
or nil
)
if M._InternalCallback then
M._InternalCallback()
end
end
end)

local Y
Y=h.InputEnded:Connect(function(Z)
if Z==W and W.UserInputState==Enum.UserInputState.End then
if X then
X:Disconnect()
end
if Y then
Y:Disconnect()
end
end
end)
end
end)
P.MouseEnter:Connect(function()
o:Tween(V,p.Tween,{
Size=UDim2.fromOffset(16,16),
})
end)
P.MouseLeave:Connect(function()
o:Tween(V,p.Tween,{
Size=UDim2.fromOffset(14,14),
})
end)

return P
end

local N=Instance.new"TextButton"
N.Name=J.Name.."Slider"
N.Size=UDim2.new(1,0,0,50)
N.BackgroundColor3=n.Dark(K.BackgroundColor3,J.Darker and 0.02 or 0)
N.BorderSizePixel=0
N.AutoButtonColor=false
N.Visible=J.Visible==nil or J.Visible
N.Text=""
N.Parent=K
addTooltip(N,J.Tooltip)
local O=Instance.new"TextLabel"
O.Name="Title"
O.Size=UDim2.fromOffset(60,30)
O.Position=UDim2.fromOffset(10,2)
O.BackgroundTransparency=1
O.Text=J.Name
O.TextXAlignment=Enum.TextXAlignment.Left
O.TextColor3=n.Dark(p.Text,0.16)
O.TextSize=11
O.FontFace=p.Font
O.Parent=N
local P=Instance.new"TextBox"
P.Name="Box"
P.Size=UDim2.fromOffset(60,15)
P.Position=UDim2.new(1,-69,0,9)
P.BackgroundTransparency=1
P.Visible=false
P.Text=""
P.TextXAlignment=Enum.TextXAlignment.Right
P.TextColor3=n.Dark(p.Text,0.16)
P.TextSize=11
P.FontFace=p.Font
P.ClearTextOnFocus=true
P.Parent=N
local Q=Instance.new"Frame"
Q.Name="Slider"
Q.Size=UDim2.new(1,-20,0,2)
Q.Position=UDim2.fromOffset(10,39)
Q.BackgroundColor3=Color3.new(1,1,1)
Q.BorderSizePixel=0
Q.Parent=N
local R={}
for S=0,1,0.1 do
table.insert(R,ColorSequenceKeypoint.new(S,Color3.fromHSV(S,1,1)))
end
local S=Instance.new"UIGradient"
S.Color=ColorSequence.new(R)
S.Parent=Q
local T=Q:Clone()
T.Name="Fill"
T.Size=UDim2.fromScale(math.clamp(M.Hue,0.04,0.96),1)
T.Position=UDim2.new()
T.BackgroundTransparency=1
T.Parent=Q
local U=Instance.new"ImageButton"
U.Name="Preview"
U.Size=UDim2.fromOffset(12,12)
U.Position=UDim2.new(1,-22,0,10)
U.BackgroundTransparency=1
U.Image=v"vape/assets/new/colorpreview.png"
U.ImageColor3=Color3.fromHSV(M.Hue,M.Sat,M.Value)
U.ImageTransparency=1-M.Opacity
U.Parent=N
local V=Instance.new"TextButton"
V.Name="Expand"
V.Size=UDim2.fromOffset(17,13)
V.Position=UDim2.new(
0,
i:GetTextSize(O.Text,O.TextSize,O.Font,Vector2.new(1000,1000)).X+11,
0,
7
)
V.BackgroundTransparency=1
V.Text=""
V.Parent=N
local W=Instance.new"ImageLabel"
W.Name="Expand"
W.Size=UDim2.fromOffset(9,5)
W.Position=UDim2.fromOffset(4,4)
W.BackgroundTransparency=1
W.Image=v"vape/assets/new/expandicon.png"
W.ImageColor3=n.Dark(p.Text,0.43)
W.Parent=V
local X=Instance.new"TextButton"
X.Name="Rainbow"
X.Size=UDim2.fromOffset(12,12)
X.Position=UDim2.new(1,-42,0,10)
X.BackgroundTransparency=1
X.Text=""
X.Parent=N
local Y=Instance.new"ImageLabel"
Y.Size=UDim2.fromOffset(12,12)
Y.BackgroundTransparency=1
Y.Image=v"vape/assets/new/rainbow_1.png"
Y.ImageColor3=n.Light(p.Main,0.37)
Y.Parent=X
local Z=Y:Clone()
Z.Image=v"vape/assets/new/rainbow_2.png"
Z.Parent=X
local _=Y:Clone()
_.Image=v"vape/assets/new/rainbow_3.png"
_.Parent=X
local aa=Y:Clone()
aa.Image=v"vape/assets/new/rainbow_4.png"
aa.Parent=X
local ab=Instance.new"Frame"
ab.Name="Knob"
ab.Size=UDim2.fromOffset(24,4)
ab.Position=UDim2.fromScale(1,0.5)
ab.AnchorPoint=Vector2.new(0.5,0.5)
ab.BackgroundColor3=N.BackgroundColor3
ab.BorderSizePixel=0
ab.Parent=T
local ac=Instance.new"Frame"
ac.Name="Knob"
ac.Size=UDim2.fromOffset(14,14)
ac.Position=UDim2.fromScale(0.5,0.5)
ac.AnchorPoint=Vector2.new(0.5,0.5)
ac.BackgroundColor3=p.Text
ac.Parent=ab
addCorner(ac,UDim.new(1,0))
J.Function=J.Function or function()end

if L.OptionsVisibilityChanged~=nil then
L.OptionsVisibilityChanged:Connect(function(ad)
if ad==nil then
ad=K.Visible
end
o:Tween(ac,TweenInfo.new(0.1,Enum.EasingStyle.Quad),{
Size=ad and UDim2.fromOffset(14,14)or UDim2.fromOffset(0,0)
})
end)
end

local ad=createSlider(
"Saturation",
ColorSequence.new{
ColorSequenceKeypoint.new(0,Color3.fromHSV(0,0,M.Value)),
ColorSequenceKeypoint.new(1,Color3.fromHSV(M.Hue,1,M.Value)),
}
)
local ae=createSlider(
"Vibrance",
ColorSequence.new{
ColorSequenceKeypoint.new(0,Color3.fromHSV(0,0,0)),
ColorSequenceKeypoint.new(1,Color3.fromHSV(M.Hue,M.Sat,1)),
}
)
local af=createSlider(
"Opacity",
ColorSequence.new{
ColorSequenceKeypoint.new(0,n.Dark(p.Main,0.02)),
ColorSequenceKeypoint.new(1,Color3.fromHSV(M.Hue,M.Sat,M.Value)),
}
)

function M.Save(ag,ah)
ah[J.Name]={
Hue=ag.Hue,
Sat=ag.Sat,
Value=ag.Value,
Opacity=ag.Opacity,
Rainbow=ag.Rainbow,
}
end

function M.Load(ag,ah)
if ah.Rainbow~=ag.Rainbow then
ag:Toggle()
end
if ag.Hue~=ah.Hue or ag.Sat~=ah.Sat or ag.Value~=ah.Value or ag.Opacity~=ah.Opacity then
ag:SetValue(ah.Hue,ah.Sat,ah.Value,ah.Opacity,false)
end
end

function M.ConnectCallback(ag,ah)
if not(ah~=nil and type(ah)=="function")then return end
if M._InternalCallback and shared.VoidDev then
warn(debug.traceback(`Overriding InternalCallback!!!`))
end
M._InternalCallback=wrap(ah)
end

function M.SetValue(ag,ah,ai,aj,ak)
ag.Hue=ah or ag.Hue
ag.Sat=ai or ag.Sat
ag.Value=aj or ag.Value
ag.Opacity=ak or ag.Opacity
U.ImageColor3=Color3.fromHSV(ag.Hue,ag.Sat,ag.Value)
U.ImageTransparency=1-ag.Opacity
ad.Slider.UIGradient.Color=ColorSequence.new{
ColorSequenceKeypoint.new(0,Color3.fromHSV(0,0,ag.Value)),
ColorSequenceKeypoint.new(1,Color3.fromHSV(ag.Hue,1,ag.Value)),
}
ae.Slider.UIGradient.Color=ColorSequence.new{
ColorSequenceKeypoint.new(0,Color3.fromHSV(0,0,0)),
ColorSequenceKeypoint.new(1,Color3.fromHSV(ag.Hue,ag.Sat,1)),
}
af.Slider.UIGradient.Color=ColorSequence.new{
ColorSequenceKeypoint.new(0,n.Dark(p.Main,0.02)),
ColorSequenceKeypoint.new(1,Color3.fromHSV(ag.Hue,ag.Sat,ag.Value)),
}

if ag.Rainbow then
T.Size=UDim2.fromScale(math.clamp(ag.Hue,0.04,0.96),1)
else
o:Tween(T,p.Tween,{
Size=UDim2.fromScale(math.clamp(ag.Hue,0.04,0.96),1),
})
end

if ai then
o:Tween(ad.Slider.Fill,p.Tween,{
Size=UDim2.fromScale(math.clamp(ag.Sat,0.04,0.96),1),
})
end
if aj then
o:Tween(ae.Slider.Fill,p.Tween,{
Size=UDim2.fromScale(math.clamp(ag.Value,0.04,0.96),1),
})
end
if ak then
o:Tween(af.Slider.Fill,p.Tween,{
Size=UDim2.fromScale(math.clamp(ag.Opacity,0.04,0.96),1),
})
end

J.Function(ag.Hue,ag.Sat,ag.Value,ag.Opacity)
end

function M.ToColor(ag)
return Color3.fromHSV(ag.Hue,ag.Sat,ag.Value)
end

function M.Toggle(ag)
ag.Rainbow=not ag.Rainbow
if ag.Rainbow then
table.insert(d.RainbowTable,ag)
Y.ImageColor3=Color3.fromRGB(5,127,100)
task.delay(0.1,function()
if not ag.Rainbow then
return
end
Z.ImageColor3=Color3.fromRGB(228,125,43)
task.delay(0.1,function()
if not ag.Rainbow then
return
end
_.ImageColor3=Color3.fromRGB(225,46,52)
end)
end)
else
local ah=table.find(d.RainbowTable,ag)
if ah then
table.remove(d.RainbowTable,ah)
end
_.ImageColor3=n.Light(p.Main,0.37)
task.delay(0.1,function()
if ag.Rainbow then
return
end
Z.ImageColor3=n.Light(p.Main,0.37)
task.delay(0.1,function()
if ag.Rainbow then
return
end
Y.ImageColor3=n.Light(p.Main,0.37)
end)
end)
end
end

local ag=tick()
U.Activated:Connect(function()
U.Visible=false
P.Visible=true
P:CaptureFocus()
local ah=Color3.fromHSV(M.Hue,M.Sat,M.Value)
P.Text=math.round(ah.R*255)
..", "
..math.round(ah.G*255)
..", "
..math.round(ah.B*255)
end)
N.InputBegan:Connect(function(ah)
if
(
ah.UserInputType==Enum.UserInputType.MouseButton1
or ah.UserInputType==Enum.UserInputType.Touch
)and(ah.Position.Y-N.AbsolutePosition.Y)>(20*B.Scale)
then
if ag>tick()then
M:Toggle()
end
ag=tick()+0.3
local ai=h.InputChanged:Connect(function(ai)
if
ai.UserInputType
==(
ah.UserInputType==Enum.UserInputType.MouseButton1
and Enum.UserInputType.MouseMovement
or Enum.UserInputType.Touch
)
then
M:SetValue(
math.clamp((ai.Position.X-Q.AbsolutePosition.X)/Q.AbsoluteSize.X,0,1),
nil,nil,nil,true
)
if M._InternalCallback then
M._InternalCallback()
end
end
end)

local aj
aj=h.InputEnded:Connect(function(ak)
if ak==ah and ah.UserInputState==Enum.UserInputState.End then
if ai then
ai:Disconnect()
end
if aj then
aj:Disconnect()
end
end
end)
end
end)
N.MouseEnter:Connect(function()
o:Tween(ac,p.Tween,{
Size=UDim2.fromOffset(16,16),
})
end)
N.MouseLeave:Connect(function()
o:Tween(ac,p.Tween,{
Size=UDim2.fromOffset(14,14),
})
end)
N:GetPropertyChangedSignal"Visible":Connect(function()
ad.Visible=W.Rotation==180 and N.Visible
ae.Visible=ad.Visible
af.Visible=ad.Visible
end)
V.MouseEnter:Connect(function()
W.ImageColor3=n.Dark(p.Text,0.16)
end)
V.MouseLeave:Connect(function()
W.ImageColor3=n.Dark(p.Text,0.43)
end)
V.Activated:Connect(function()
ad.Visible=not ad.Visible
ae.Visible=ad.Visible
af.Visible=ad.Visible
W.Rotation=ad.Visible and 180 or 0
end)
X.Activated:Connect(function()
M:Toggle()
end)
P.FocusLost:Connect(function(ah)
U.Visible=true
P.Visible=false
if ah then
local ai=P.Text:split","
local aj,ak=pcall(function()
return tonumber(ai[1])
and Color3.fromRGB(tonumber(ai[1]),tonumber(ai[2]),tonumber(ai[3]))
or Color3.fromHex(P.Text)
end)
if aj then
if M.Rainbow then
M:Toggle()
end
M:SetValue(ak:ToHSV())
if M._InternalCallback then
M._InternalCallback()
end
end
end
end)

M.Object=N
L.Options[J.Name]=M

return M
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
af.BackgroundColor3=n.Dark(ab.BackgroundColor3,aa.Darker and 0.02 or 0)
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
ag.BackgroundColor3=n.Light(p.Main,0.034)
ag.Parent=af
addCorner(ag,UDim.new(0,6))
local ah=Instance.new"UIStroke"
ah.Name="GlowStroke"
ah.Thickness=2
ah.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
ah.Color=n.Light(p.Main,0.35)
ah.Transparency=1
ah.Parent=ag
local ai=Instance.new"TextButton"
ai.Name="Dropdown"
ai.Size=UDim2.new(1,-2,1,-2)
ai.Position=UDim2.fromOffset(1,1)
ai.BackgroundColor3=p.Main
ai.AutoButtonColor=false
ai.Text=""
ai.Parent=ag
local aj=Instance.new"TextLabel"
aj.Name="Title"
aj.Size=UDim2.new(1,0,0,29)
aj.BackgroundTransparency=1
aj.Text="         "..aa.Name.." - "..ae.Value
aj.TextXAlignment=Enum.TextXAlignment.Left
aj.TextColor3=n.Dark(p.Text,0.16)
aj.TextSize=13
aj.TextTruncate=Enum.TextTruncate.AtEnd
aj.FontFace=p.Font
aj.Parent=ai
addCorner(ai,UDim.new(0,6))
local ak=Instance.new"ImageLabel"
ak.Name="Arrow"
ak.Size=UDim2.fromOffset(4,8)
ak.Position=UDim2.new(1,-17,0,11)
ak.BackgroundTransparency=1
ak.Image=v"vape/assets/new/expandright.png"
ak.ImageColor3=Color3.fromRGB(140,140,140)
ak.Rotation=90
ak.Parent=ai
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
ak.Rotation=90
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
ak.Rotation=270

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
N.BackgroundColor3=n.Light(p.Main,0.02)
N.PlaceholderText=" Search..."
N.Text=""
N.TextColor3=p.Text
N.TextSize=13
N.FontFace=p.Font
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
P.FontFace=p.Font
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
U.BackgroundColor3=p.Main
U.BorderSizePixel=0
U.AutoButtonColor=false
U.Text="   "..T
U.TextColor3=p.Text
U.TextXAlignment=Enum.TextXAlignment.Left
U.TextSize=13
U.FontFace=p.Font
U.Parent=M
addTooltip(U,T)

U.MouseEnter:Connect(function()
o:Tween(U,p.Tween,{
BackgroundColor3=n.Light(p.Main,0.04),
})
end)
U.MouseLeave:Connect(function()
o:Tween(U,p.Tween,{
BackgroundColor3=p.Main,
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
o:Tween(ag,p.Tween,{
BackgroundColor3=n.Light(p.Main,0.0875),
})
o:Tween(ah,p.Tween,{
Transparency=0.15,
})
end)
af.MouseLeave:Connect(function()
o:Tween(ag,p.Tween,{
BackgroundColor3=n.Light(p.Main,0.034),
})
o:Tween(ah,p.Tween,{
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

af=I.Dropdown({
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
ag=I.TextBox({
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
ae.BackgroundColor3=n.Dark(ab.BackgroundColor3,aa.Darker and 0.02 or 0)
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
af.TextColor3=n.Dark(p.Text,0.16)
af.TextSize=11
af.FontFace=p.Font
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
ag.TextColor3=n.Dark(p.Text,0.16)
ag.TextSize=11
ag.FontFace=p.Font
ag.Parent=ae
local ah=Instance.new"TextBox"
ah.Name="Box"
ah.Size=ag.Size
ah.Position=ag.Position
ah.BackgroundTransparency=1
ah.Visible=false
ah.Text=ad.Value
ah.TextXAlignment=Enum.TextXAlignment.Right
ah.TextColor3=n.Dark(p.Text,0.16)
ah.TextSize=11
ah.FontFace=p.Font
ah.ClearTextOnFocus=false
ah.Parent=ae
local ai=Instance.new"Frame"
ai.Name="Slider"
ai.Size=UDim2.new(1,-20,0,2)
ai.Position=UDim2.fromOffset(10,37)
ai.BackgroundColor3=n.Light(p.Main,0.034)
ai.BorderSizePixel=0
ai.Parent=ae
local aj=ai:Clone()
aj.Name="Fill"
aj.Size=
UDim2.fromScale(math.clamp((ad.Value-aa.Min)/aa.Max,0.04,0.96),1)
aj.Position=UDim2.new()
aj.BackgroundColor3=Color3.fromHSV(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
aj.Parent=ai
local ak=Instance.new"Frame"
ak.Name="Knob"
ak.Size=UDim2.fromOffset(24,4)
ak.Position=UDim2.fromScale(1,0.5)
ak.AnchorPoint=Vector2.new(0.5,0.5)
ak.BackgroundColor3=ae.BackgroundColor3
ak.BorderSizePixel=0
ak.Parent=aj
local J=Instance.new"Frame"
J.Name="Knob"
J.Size=UDim2.fromOffset(14,14)
J.Position=UDim2.fromScale(0.5,0.5)
J.AnchorPoint=Vector2.new(0.5,0.5)
J.BackgroundColor3=Color3.fromHSV(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
J.Parent=ak
addCorner(J,UDim.new(1,0))
aa.Function=aa.Function or function()end
aa.Decimal=aa.Decimal or 1

if ac.OptionsVisibilityChanged~=nil then
ac.OptionsVisibilityChanged:Connect(function(K)
if K==nil then
K=ab.Visible
end
o:Tween(J,TweenInfo.new(0.1,Enum.EasingStyle.Quad),{
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
o:Tween(aj,p.Tween,{
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
)and(K.Position.Y-ae.AbsolutePosition.Y)>(20*B.Scale)
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
P=h.InputEnded:Connect(function(Q)
if Q==K and K.UserInputState==Enum.UserInputState.End then
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
o:Tween(J,p.Tween,{
Size=UDim2.fromOffset(16,16),
})
end)
ae.MouseLeave:Connect(function()
o:Tween(J,p.Tween,{
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
ae.BackgroundColor3=n.Dark(ab.BackgroundColor3,aa.Darker and 0.02 or 0)
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
af.BackgroundColor3=n.Light(p.Main,0.034)
af.Parent=ae
addCorner(af,UDim.new(0,4))
local ag=Instance.new"TextButton"
ag.Name="TextList"
ag.Size=UDim2.new(1,-2,1,-2)
ag.Position=UDim2.fromOffset(1,1)
ag.BackgroundColor3=p.Main
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
ah.TextColor3=n.Dark(p.Text,0.16)
ah.TextSize=15
ah.TextTruncate=Enum.TextTruncate.AtEnd
ah.FontFace=p.Font
ah.Parent=ag
local ai=ah:Clone()
ai.Name="Items"
ai.Position=UDim2.fromOffset(5,21)
ai.Text="Ignore none"
ai.TextColor3=n.Dark(p.Text,0.16)
ai.TextSize=11
ai.Parent=ag
addCorner(ag,UDim.new(0,4))
local aj=Instance.new"Frame"
aj.Size=UDim2.fromOffset(65,12)
aj.Position=UDim2.fromOffset(52,8)
aj.BackgroundTransparency=1
aj.Parent=ag
local ak=Instance.new"UIListLayout"
ak.FillDirection=Enum.FillDirection.Horizontal
ak.Padding=UDim.new(0,6)
ak.Parent=aj
local J=Instance.new"TextButton"
J.Name="TargetsTextWindow"
J.Size=UDim2.fromOffset(220,145)
J.BackgroundColor3=p.Main
J.BorderSizePixel=0
J.AutoButtonColor=false
J.Visible=false
J.Text=""
J.Parent=w
ad.Window=J
addBlur(J)
addCorner(J)
local K=Instance.new"ImageLabel"
K.Name="Icon"
K.Size=UDim2.fromOffset(18,12)
K.Position=UDim2.fromOffset(10,15)
K.BackgroundTransparency=1
K.Image=v"vape/assets/new/targetstab.png"
K.Parent=J
local L=Instance.new"TextLabel"
L.Name="Title"
L.Size=UDim2.new(1,-36,0,20)
L.Position=UDim2.fromOffset(math.abs(L.Size.X.Offset),11)
L.BackgroundTransparency=1
L.Text="Target settings"
L.TextXAlignment=Enum.TextXAlignment.Left
L.TextColor3=p.Text
L.TextSize=13
L.FontFace=p.Font
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
o:Cancel(N.Players.Object.Frame)
N.Players.Object.Frame.BackgroundColor3=Color3.fromHSV(O,P,Q)
end
if N.NPCs.Enabled then
o:Cancel(N.NPCs.Object.Frame)
N.NPCs.Object.Frame.BackgroundColor3=Color3.fromHSV(O,P,Q)
end
if N.Invisible.Enabled then
o:Cancel(N.Invisible.Object.Knob)
N.Invisible.Object.Knob.BackgroundColor3=Color3.fromHSV(O,P,Q)
end
if N.Walls.Enabled then
o:Cancel(N.Walls.Object.Knob)
N.Walls.Object.Knob.BackgroundColor3=Color3.fromHSV(O,P,Q)
end
end

ad.Players=I.TargetsButton({
Position=UDim2.fromOffset(11,45),
Icon=v"vape/assets/new/targetplayers1.png",
IconSize=UDim2.fromOffset(15,16),
IconParent=aj,
ToolIcon=v"vape/assets/new/targetplayers2.png",
ToolSize=UDim2.fromOffset(11,12),
Tooltip="Players",
Function=aa.Function,
},J,aj)
ad.NPCs=I.TargetsButton({
Position=UDim2.fromOffset(112,45),
Icon=v"vape/assets/new/targetnpc1.png",
IconSize=UDim2.fromOffset(12,16),
IconParent=aj,
ToolIcon=v"vape/assets/new/targetnpc2.png",
ToolSize=UDim2.fromOffset(9,12),
Tooltip="NPCs",
Function=aa.Function,
},J,aj)
ad.Invisible=I.Toggle({
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
ad.Walls=I.Toggle({
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
o:Cancel(af)
af.BackgroundColor3=J.Visible
and Color3.fromHSV(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
or n.Light(p.Main,0.37)
end)
ae.MouseEnter:Connect(function()
if not ad.Window.Visible then
o:Tween(af,p.Tween,{
BackgroundColor3=n.Light(p.Main,0.37),
})
end
end)
ae.MouseLeave:Connect(function()
if not ad.Window.Visible then
o:Tween(af,p.Tween,{
BackgroundColor3=n.Light(p.Main,0.034),
})
end
end)
ae:GetPropertyChangedSignal"AbsolutePosition":Connect(function()
if d.ThreadFix then
setthreadidentity(8)
end
local N=(ae.AbsolutePosition+Vector2.new(0,60))/B.Scale
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
ae.BackgroundColor3=n.Light(p.Main,0.05)
ae.AutoButtonColor=false
ae.Visible=aa.Visible==nil or aa.Visible
ae.Text=""
ae.Parent=ab
addCorner(ae)
addTooltip(ae,aa.Tooltip)
local af=Instance.new"Frame"
af.Size=UDim2.new(1,-2,1,-2)
af.Position=UDim2.fromOffset(1,1)
af.BackgroundColor3=p.Main
af.Parent=ae
addCorner(af)
local ag=Instance.new"ImageLabel"
ag.Size=aa.IconSize
ag.Position=UDim2.fromScale(0.5,0.5)
ag.AnchorPoint=Vector2.new(0.5,0.5)
ag.BackgroundTransparency=1
ag.Image=aa.Icon
ag.ImageColor3=n.Light(p.Main,0.37)
ag.Parent=af
aa.Function=aa.Function or function()end
local ah

function ad.Toggle(ai)
ai.Enabled=not ai.Enabled
o:Tween(af,p.Tween,{
BackgroundColor3=ai.Enabled
and Color3.fromHSV(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
or p.Main,
})
o:Tween(ag,p.Tween,{
ImageColor3=ai.Enabled and Color3.new(1,1,1)or n.Light(p.Main,0.37),
})
if ah then
ah:Destroy()
end
if ai.Enabled then
ah=Instance.new"ImageLabel"
ah.Size=aa.ToolSize
ah.BackgroundTransparency=1
ah.Image=aa.ToolIcon
ah.ImageColor3=p.Text
ah.Parent=aa.IconParent
end
aa.Function(ai.Enabled)
end

ae.MouseEnter:Connect(function()
if not ad.Enabled then
o:Tween(af,p.Tween,{
BackgroundColor3=Color3.fromHSV(
d.GUIColor.Hue,
d.GUIColor.Sat,
d.GUIColor.Value-0.25
),
})
o:Tween(ag,p.Tween,{
ImageColor3=Color3.new(1,1,1),
})
end
end)
ae.MouseLeave:Connect(function()
if not ad.Enabled then
o:Tween(af,p.Tween,{
BackgroundColor3=p.Main,
})
o:Tween(ag,p.Tween,{
ImageColor3=n.Light(p.Main,0.37),
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
ae.BackgroundColor3=n.Dark(ab.BackgroundColor3,aa.Darker and 0.02 or 0)
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
af.TextColor3=p.Text
af.TextSize=12
af.FontFace=p.Font
af.Parent=ae
local ag=Instance.new"Frame"
ag.Name="BKG"
ag.Size=UDim2.new(1,-20,0,29)
ag.Position=UDim2.fromOffset(10,23)
ag.BackgroundColor3=n.Light(p.Main,0.02)
ag.Parent=ae
addCorner(ag,UDim.new(0,4))
local ah=Instance.new"TextBox"
ah.Size=UDim2.new(1,-8,1,0)
ah.Position=UDim2.fromOffset(8,0)
ah.BackgroundTransparency=1
ah.Text=aa.Default or""
ah.PlaceholderText=aa.Placeholder or"Click to set"
ah.TextXAlignment=Enum.TextXAlignment.Left
ah.TextColor3=n.Dark(p.Text,0.16)
ah.PlaceholderColor3=n.Dark(p.Text,0.31)
ah.TextSize=12
ah.FontFace=p.Font
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

function ad.SetValue(ai,aj,ak)
ai.Value=aj
ah.Text=aj
aa.Function(ak)
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
ae.BackgroundColor3=n.Dark(ab.BackgroundColor3,aa.Darker and 0.02 or 0)
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
af.BackgroundColor3=n.Light(p.Main,0.034)
af.Parent=ae
addCorner(af,UDim.new(0,4))
local ag=Instance.new"TextButton"
ag.Name="TextList"
ag.Size=UDim2.new(1,-2,1,-2)
ag.Position=UDim2.fromOffset(1,1)
ag.BackgroundColor3=p.Main
ag.AutoButtonColor=false
ag.Text=""
ag.Parent=af
local ah=Instance.new"ImageLabel"
ah.Name="Icon"
ah.Size=UDim2.fromOffset(14,12)
ah.Position=UDim2.fromOffset(10,14)
ah.BackgroundTransparency=1
ah.Image=aa.Icon or v"vape/assets/new/allowedicon.png"
ah.Parent=ag
local ai=Instance.new"TextLabel"
ai.Name="Title"
ai.Size=UDim2.new(1,-35,0,15)
ai.Position=UDim2.fromOffset(35,6)
ai.BackgroundTransparency=1
ai.Text=aa.Name
ai.TextXAlignment=Enum.TextXAlignment.Left
ai.TextColor3=n.Dark(p.Text,0.16)
ai.TextSize=15
ai.TextTruncate=Enum.TextTruncate.AtEnd
ai.FontFace=p.Font
ai.Parent=ag
local aj=ai:Clone()
aj.Name="Amount"
aj.Size=UDim2.new(1,-13,0,15)
aj.Position=UDim2.fromOffset(0,6)
aj.Text="0"
aj.TextXAlignment=Enum.TextXAlignment.Right
aj.Parent=ag
local ak=ai:Clone()
ak.Name="Items"
ak.Position=UDim2.fromOffset(35,21)
ak.Text="None"
ak.TextColor3=n.Dark(p.Text,0.43)
ak.TextSize=11
ak.Parent=ag
addCorner(ag,UDim.new(0,4))

local J=400
local K=85
local L=35
local M=math.floor((J-K)/L)

local N=Instance.new"TextButton"
N.Name=aa.Name.."TextWindow"
N.Size=UDim2.fromOffset(220,K)
N.BackgroundColor3=p.Main
N.BorderSizePixel=0
N.AutoButtonColor=false
N.Visible=false
N.Text=""
N.ClipsDescendants=true
N.Parent=ac.Legit and d.Legit.Window or w
ad.Window=N
addBlur(N)
addCorner(N)

local O=Instance.new"ImageLabel"
O.Name="Icon"
O.Size=aa.TabSize or UDim2.fromOffset(19,16)
O.Position=UDim2.fromOffset(10,13)
O.BackgroundTransparency=1
O.Image=aa.Tab or v"vape/assets/new/allowedtab.png"
O.Parent=N
local P=Instance.new"TextLabel"
P.Name="Title"
P.Size=UDim2.new(1,-36,0,20)
P.Position=UDim2.fromOffset(math.abs(P.Size.X.Offset),11)
P.BackgroundTransparency=1
P.Text=aa.Name
P.TextXAlignment=Enum.TextXAlignment.Left
P.TextColor3=p.Text
P.TextSize=13
P.FontFace=p.Font
P.Parent=N
local Q=addCloseButton(N)

local R=Instance.new"Frame"
R.Name="Add"
R.Size=UDim2.fromOffset(200,31)
R.Position=UDim2.fromOffset(10,45)
R.BackgroundColor3=n.Light(p.Main,0.02)
R.Parent=N
addCorner(R)
local S=R:Clone()
S.Size=UDim2.new(1,-2,1,-2)
S.Position=UDim2.fromOffset(1,1)
S.BackgroundColor3=n.Dark(p.Main,0.02)
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
T.FontFace=p.Font
T.ClearTextOnFocus=false
T.Parent=R
local U=Instance.new"ImageButton"
U.Name="AddButton"
U.Size=UDim2.fromOffset(16,16)
U.Position=UDim2.new(1,-26,0,8)
U.BackgroundTransparency=1
U.Image=v"vape/assets/new/add.png"
U.ImageColor3=aa.Color
U.ImageTransparency=0.3
U.Parent=R


local V=Instance.new"Frame"
V.Name="SearchBKG"
V.Size=UDim2.fromOffset(200,31)
V.Position=UDim2.fromOffset(10,82)
V.BackgroundColor3=n.Light(p.Main,0.02)
V.Parent=N
addCorner(V)
local W=V:Clone()
W.Size=UDim2.new(1,-2,1,-2)
W.Position=UDim2.fromOffset(1,1)
W.BackgroundColor3=n.Dark(p.Main,0.02)
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
X.FontFace=p.Font
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
Z.FontFace=p.Font
Z.Visible=false
Z.Parent=Y

aa.Function=aa.Function or function()end

function ad.Save(_,al)
al[aa.Name]={
List=_.List,
ListEnabled=_.ListEnabled,
}
end

function ad.Load(al,_)
al.List=_.List or{}
al.ListEnabled=_.ListEnabled or{}
al:ChangeValue()
end

function ad.Color(al,_,am,an,ao)
if N.Visible then
af.BackgroundColor3=ao and Color3.fromHSV(d:Color((_-(al.Index*0.075))%1))
or Color3.fromHSV(_,am,an)
end
end

local al=""

function ad.UpdateWindowSize(am,an)
local ao=math.min(an,M)*L
local _=119+ao

Y.Size=UDim2.fromOffset(200,ao)

o:Tween(N,p.Tween,{
Size=UDim2.fromOffset(220,_),
})
end

function ad.FilterItems(am,an)
al=an:lower()
local ao=0

for _,ap in am.Objects do
local aq=ap.Name:lower()
local ar=al==""or aq:find(al,1,true)

if ar then
ao=ao+1
ap.Position=UDim2.fromOffset(0,(ao-1)*L)


ap.Visible=true
o:Tween(ap,TweenInfo.new(0.15),{
BackgroundTransparency=0,
})
for as,at in ap:GetDescendants()do
if at:IsA"TextLabel"then
o:Tween(at,TweenInfo.new(0.15),{
TextTransparency=0,
})
elseif at:IsA"ImageButton"or at:IsA"ImageLabel"then
o:Tween(at,TweenInfo.new(0.15),{
ImageTransparency=at.Name=="AddButton"and 0.3 or 0.5,
})
elseif at:IsA"Frame"and at.Name~="BKG"then
o:Tween(at,TweenInfo.new(0.15),{
BackgroundTransparency=0,
})
end
end
else

o:Tween(ap,TweenInfo.new(0.15),{
BackgroundTransparency=1,
})
for as,at in ap:GetDescendants()do
if at:IsA"TextLabel"then
o:Tween(at,TweenInfo.new(0.15),{
TextTransparency=1,
})
elseif at:IsA"ImageButton"or at:IsA"ImageLabel"then
o:Tween(at,TweenInfo.new(0.15),{
ImageTransparency=1,
})
elseif at:IsA"Frame"then
o:Tween(at,TweenInfo.new(0.15),{
BackgroundTransparency=1,
})
end
end
task.delay(0.15,function()
ap.Visible=false
end)
end
end

Z.Visible=ao==0 and#am.List>0
am:UpdateWindowSize(ao==0 and 1 or ao)
end

function ad.ChangeValue(am,an)
if an then
local ao=table.find(am.List,an)
if ao then
table.remove(am.List,ao)
ao=table.find(am.ListEnabled,an)
if ao then
table.remove(am.ListEnabled,ao)
end
else
table.insert(am.List,an)
table.insert(am.ListEnabled,an)
end
end

aa.Function(am.List)
for ao,ap in am.Objects do
ap:Destroy()
end
table.clear(am.Objects)
aj.Text=#am.List

local ao="None"
for ap,aq in am.ListEnabled do
if ap==1 then
ao=""
end
ao=ao..(ap==1 and aq or", "..aq)
end
ak.Text=ao

for ap,aq in am.List do
local ar=table.find(am.ListEnabled,aq)
local as=Instance.new"TextButton"
as.Name=aq
as.Size=UDim2.fromOffset(200,32)
as.Position=UDim2.fromOffset(0,(ap-1)*L)
as.BackgroundColor3=n.Light(p.Main,0.02)
as.AutoButtonColor=false
as.Text=""
as.Parent=Y
addCorner(as)
local at=Instance.new"Frame"
at.Name="BKG"
at.Size=UDim2.new(1,-2,1,-2)
at.Position=UDim2.fromOffset(1,1)
at.BackgroundColor3=p.Main
at.Visible=false
at.Parent=as
addCorner(at)
local _=Instance.new"Frame"
_.Name="Dot"
_.Size=UDim2.fromOffset(10,11)
_.Position=UDim2.fromOffset(10,12)
_.BackgroundColor3=ar and aa.Color or n.Light(p.Main,0.37)
_.Parent=as
addCorner(_,UDim.new(1,0))
local au=_:Clone()
au.Size=UDim2.fromOffset(8,9)
au.Position=UDim2.fromOffset(1,1)
au.BackgroundColor3=ar and aa.Color or n.Light(p.Main,0.02)
au.Parent=_
local av=Instance.new"TextLabel"
av.Name="Title"
av.Size=UDim2.new(1,-30,1,0)
av.Position=UDim2.fromOffset(30,0)
av.BackgroundTransparency=1
av.Text=aq
av.TextXAlignment=Enum.TextXAlignment.Left
av.TextColor3=n.Dark(p.Text,0.16)
av.TextSize=15
av.FontFace=p.Font
av.Parent=as
local aw=Instance.new"ImageButton"
aw.Name="Close"
aw.Size=UDim2.fromOffset(16,16)
aw.Position=UDim2.new(1,-26,0,8)
aw.BackgroundColor3=Color3.new(1,1,1)
aw.BackgroundTransparency=1
aw.AutoButtonColor=false
aw.Image=v"vape/assets/new/closemini.png"
aw.ImageColor3=n.Light(p.Text,0.2)
aw.ImageTransparency=0.5
aw.Parent=as
addCorner(aw,UDim.new(1,0))

aw.MouseEnter:Connect(function()
aw.ImageTransparency=0.3
o:Tween(aw,p.Tween,{
BackgroundTransparency=0.6,
})
end)
aw.MouseLeave:Connect(function()
aw.ImageTransparency=0.5
o:Tween(aw,p.Tween,{
BackgroundTransparency=1,
})
end)
aw.Activated:Connect(function()
am:ChangeValue(aq)
am:FilterItems(al)
end)
as.MouseEnter:Connect(function()
at.Visible=true
end)
as.MouseLeave:Connect(function()
at.Visible=false
end)
as.Activated:Connect(function()
local ax=table.find(am.ListEnabled,aq)
if ax then
table.remove(am.ListEnabled,ax)
_.BackgroundColor3=n.Light(p.Main,0.37)
au.BackgroundColor3=n.Light(p.Main,0.02)
else
table.insert(am.ListEnabled,aq)
_.BackgroundColor3=aa.Color
au.BackgroundColor3=aa.Color
end

local ay="None"
for az,aA in am.ListEnabled do
if az==1 then
ay=""
end
ay=ay..(az==1 and aA or", "..aA)
end

ak.Text=ay
aa.Function()
end)

table.insert(am.Objects,as)
end


am:FilterItems(al)
end


X:GetPropertyChangedSignal"Text":Connect(function()
ad:FilterItems(X.Text)
end)

X.MouseEnter:Connect(function()
o:Tween(V,p.Tween,{
BackgroundColor3=n.Light(p.Main,0.14),
})
end)
X.MouseLeave:Connect(function()
o:Tween(V,p.Tween,{
BackgroundColor3=n.Light(p.Main,0.02),
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
T.FocusLost:Connect(function(am)
if am and not table.find(ad.List,T.Text)and T.Text~=""then
ad:ChangeValue(T.Text)
T.Text=""
X.Text=""
end
end)
T.MouseEnter:Connect(function()
o:Tween(R,p.Tween,{
BackgroundColor3=n.Light(p.Main,0.14),
})
end)
T.MouseLeave:Connect(function()
o:Tween(R,p.Tween,{
BackgroundColor3=n.Light(p.Main,0.02),
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
o:Cancel(af)
af.BackgroundColor3=N.Visible
and Color3.fromHSV(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
or n.Light(p.Main,0.37)
end)
ae.MouseEnter:Connect(function()
if not ad.Window.Visible then
o:Tween(af,p.Tween,{
BackgroundColor3=n.Light(p.Main,0.37),
})
end
end)
ae.MouseLeave:Connect(function()
if not ad.Window.Visible then
o:Tween(af,p.Tween,{
BackgroundColor3=n.Light(p.Main,0.034),
})
end
end)
ae:GetPropertyChangedSignal"AbsolutePosition":Connect(function()
if d.ThreadFix then
setthreadidentity(8)
end
local am=(
ae.AbsolutePosition
-(ac.Legit and d.Legit.Window.AbsolutePosition or-j:GetGuiInset())
)/B.Scale
N.Position=UDim2.fromOffset(am.X+220,am.Y)
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
af.BackgroundColor3=n.Dark(ab.BackgroundColor3,aa.Darker and 0.02 or 0)
af.BorderSizePixel=0
af.AutoButtonColor=false
af.Visible=aa.Visible==nil or aa.Visible
af.Text="          "..aa.Name
af.TextXAlignment=Enum.TextXAlignment.Left
af.TextColor3=n.Dark(p.Text,0.16)
af.TextSize=14
af.FontFace=p.Font
af.Parent=ab
addTooltip(af,aa.Tooltip)
local ag=Instance.new"Frame"
ag.Name="Knob"
ag.Size=UDim2.fromOffset(22,12)
ag.Position=UDim2.new(1,-30,0,9)
ag.BackgroundColor3=n.Light(p.Main,0.14)
ag.Parent=af
addCorner(ag,UDim.new(1,0))
local ah=ag:Clone()
ah.Size=UDim2.fromOffset(8,8)
ah.Position=UDim2.fromOffset(2,2)
ah.BackgroundColor3=p.Main
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
o:Cancel(ag)
ag.BackgroundColor3=am
and Color3.fromHSV(d:Color((aj-(ai.Index*0.075))%1))
or Color3.fromHSV(aj,ak,al)
end
end

function ad.Toggle(ai)
ai.Enabled=not ai.Enabled
ai.Toggled:Fire()
local aj=d.GUIColor.Rainbow and d.RainbowMode.Value~="Retro"
o:Tween(ag,p.Tween,{
BackgroundColor3=ai.Enabled
and(aj and Color3.fromHSV(
d:Color((d.GUIColor.Hue-(ai.Index*0.075))%1)
)or Color3.fromHSV(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value))
or(ae and n.Light(p.Main,0.37)or n.Light(p.Main,0.14)),
})
o:Tween(ah,p.Tween,{
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
o:Tween(ag,p.Tween,{
BackgroundColor3=n.Light(p.Main,0.37),
})
end
end)
af.MouseLeave:Connect(function()
ae=false
if not ad.Enabled then
o:Tween(ag,p.Tween,{
BackgroundColor3=n.Light(p.Main,0.14),
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
ae.BackgroundColor3=n.Dark(ab.BackgroundColor3,aa.Darker and 0.02 or 0)
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
af.TextColor3=n.Dark(p.Text,0.16)
af.TextSize=11
af.FontFace=p.Font
af.Parent=ae
local ag=Instance.new"TextButton"
ag.Name="Value"
ag.Size=UDim2.fromOffset(60,15)
ag.Position=UDim2.new(1,-69,0,9)
ag.BackgroundTransparency=1
ag.Text=ad.ValueMax
ag.TextXAlignment=Enum.TextXAlignment.Right
ag.TextColor3=n.Dark(p.Text,0.16)
ag.TextSize=11
ag.FontFace=p.Font
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
ai.TextColor3=n.Dark(p.Text,0.16)
ai.TextSize=11
ai.FontFace=p.Font
ai.ClearTextOnFocus=false
ai.Parent=ae
local aj=ai:Clone()
aj.Position=ah.Position
aj.Parent=ae
local ak=Instance.new"Frame"
ak.Name="Slider"
ak.Size=UDim2.new(1,-20,0,2)
ak.Position=UDim2.fromOffset(10,37)
ak.BackgroundColor3=n.Light(p.Main,0.034)
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
an.Image=v"vape/assets/new/range.png"
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
ap.Image=v"vape/assets/new/rangearrow.png"
ap.ImageColor3=n.Light(p.Main,0.14)
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
o:Tween(al,TweenInfo.new(0.1),{
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
o:Tween(an,p.Tween,{
Size=UDim2.fromOffset(11,18),
})
end)
am.MouseLeave:Connect(function()
o:Tween(an,p.Tween,{
Size=UDim2.fromOffset(9,16),
})
end)
ao.MouseEnter:Connect(function()
o:Tween(ao.Knob,p.Tween,{
Size=UDim2.fromOffset(11,18),
})
end)
ao.MouseLeave:Connect(function()
o:Tween(ao.Knob,p.Tween,{
Size=UDim2.fromOffset(9,16),
})
end)
ae.InputBegan:Connect(function(ar)
if
(
ar.UserInputType==Enum.UserInputType.MouseButton1
or ar.UserInputType==Enum.UserInputType.Touch
)and(ar.Position.Y-ae.AbsolutePosition.Y)>(20*B.Scale)
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
av=h.InputEnded:Connect(function(aw)
if aw==ar and ar.UserInputState==Enum.UserInputState.End then
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
ac.BackgroundColor3=n.Light(p.Main,0.02)
ac.BorderSizePixel=0
ac.Parent=aa
if ab then
local ad=Instance.new"TextLabel"
ad.Name="DividerLabel"
ad.Size=UDim2.fromOffset(218,27)
ad.BackgroundTransparency=1
ad.Text="          "..ab:upper()
ad.TextXAlignment=Enum.TextXAlignment.Left
ad.TextColor3=n.Dark(p.Text,0.43)
ad.TextSize=9
ad.FontFace=p.Font
ad.Parent=aa
ac.Position=UDim2.fromOffset(0,26)
ac.Parent=ad
end
end,
}

for aa,ab in I do
local ac=ab
I[aa]=function(ad,...)
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

d.Components=setmetatable(I,{
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
ac.BackgroundColor3=n.Dark(p.Main,0.02)
ac.AutoButtonColor=false
ac.Text=""
ac.Parent=w
addBlur(ac)
addCorner(ac)
makeDraggable(ac)
local ad=Instance.new"ImageLabel"
ad.Name="VapeLogo"
ad.Size=UDim2.fromOffset(62,18)
ad.Position=UDim2.fromOffset(11,10)
ad.BackgroundTransparency=1
ad.Image=v"vape/assets/new/guivape.png"
ad.ImageColor3=select(3,p.Main:ToHSV())>0.5 and p.Text or Color3.new(1,1,1)
ad.Parent=ac
local ae=Instance.new"ImageLabel"
ae.Name="V4Logo"
ae.Size=UDim2.fromOffset(28,16)
ae.Position=UDim2.new(1,1,0,1)
ae.BackgroundTransparency=1
ae.Image=v"vape/assets/new/guiv4.png"
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
ai.Image=v"vape/assets/new/guisettings.png"
ai.ImageColor3=n.Light(p.Main,0.37)
ai.Parent=ah
local aj=Instance.new"ImageButton"
aj.Size=UDim2.fromOffset(16,16)
aj.Position=UDim2.new(1,-56,0,11)
aj.BackgroundTransparency=1
aj.Image=v"vape/assets/new/discord.png"
aj.Parent=ac
addTooltip(aj,"Join discord")
local ak=Instance.new"TextButton"
ak.Size=UDim2.fromScale(1,1)
ak.BackgroundColor3=n.Dark(p.Main,0.02)
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
al.TextColor3=p.Text
al.TextSize=13
al.FontFace=p.Font
al.Parent=ak
local am=addCloseButton(ak)
local an=Instance.new"ImageButton"
an.Name="Back"
an.Size=UDim2.fromOffset(16,16)
an.Position=UDim2.fromOffset(11,13)
an.BackgroundTransparency=1
an.Image=v"vape/assets/new/back.png"
an.ImageColor3=n.Light(p.Main,0.37)
an.Parent=ak
local ao=Instance.new"TextLabel"
ao.Name="Version"
ao.Size=UDim2.new(1,0,0,16)
ao.Position=UDim2.new(0,0,1,-16)
ao.BackgroundTransparency=1
ao.Text="Vape "
..d.Version
.." "
..(E"vape/profiles/commit.txt"and readfile"vape/profiles/commit.txt":sub(1,6)or"")
.." "
ao.TextColor3=n.Dark(p.Text,0.43)
ao.TextXAlignment=Enum.TextXAlignment.Right
ao.TextSize=10
ao.FontFace=p.Font
ao.Parent=ak
addCorner(ak)
local ap=Instance.new"Frame"
ap.Name="Children"
ap.Size=UDim2.new(1,0,1,-57)
ap.Position=UDim2.fromOffset(0,41)
ap.BackgroundColor3=p.Main
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
at.BackgroundColor3=p.Main
at.BorderSizePixel=0
at.AutoButtonColor=false
at.Text="          Rebind GUI"
at.TextXAlignment=Enum.TextXAlignment.Left
at.TextColor3=n.Dark(p.Text,0.16)
at.TextSize=14
at.FontFace=p.Font
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
av.Image=v"vape/assets/new/bind.png"
av.ImageColor3=n.Dark(p.Text,0.43)
av.Parent=au
local aw=Instance.new"TextLabel"
aw.Name="Text"
aw.Size=UDim2.fromScale(1,1)
aw.Position=UDim2.fromOffset(0,1)
aw.BackgroundTransparency=1
aw.Visible=false
aw.Text=""
aw.TextColor3=n.Dark(p.Text,0.43)
aw.TextSize=12
aw.FontFace=p.Font
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
au.Size=UDim2.fromOffset(math.max(F(aw.Text,aw.TextSize,aw.Font).X+10,20),21)
end

au.MouseEnter:Connect(function()
aw.Visible=false
av.Visible=not aw.Visible
av.Image=v"vape/assets/new/edit.png"
av.ImageColor3=n.Dark(p.Text,0.16)
end)
au.MouseLeave:Connect(function()
aw.Visible=true
av.Visible=not aw.Visible
av.Image=v"vape/assets/new/bind.png"
av.ImageColor3=n.Dark(p.Text,0.43)
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
au.BackgroundColor3=p.Main
au.BorderSizePixel=0
au.AutoButtonColor=false
au.Text=(
as.Icon
and"                                 "
or"             "
)..as.Name
au.TextXAlignment=Enum.TextXAlignment.Left
au.TextColor3=n.Dark(p.Text,0.16)
au.TextSize=14
au.FontFace=p.Font
au.Parent=af
local av
if as.Icon then
av=Instance.new"ImageLabel"
av.Name="Icon"
av.Size=as.Size
av.Position=UDim2.fromOffset(13,13)
av.BackgroundTransparency=1
av.Image=as.Icon
av.ImageColor3=n.Dark(p.Text,0.16)
av.Parent=au
end
if as.Name=="Profiles"then
local aw=Instance.new"TextLabel"
aw.Name="ProfileLabel"
aw.Size=UDim2.fromOffset(53,24)
aw.Position=UDim2.new(1,-36,0,8)
aw.AnchorPoint=Vector2.new(1,0)
aw.BackgroundColor3=n.Light(p.Main,0.04)
aw.Text="default"
aw.TextColor3=n.Dark(p.Text,0.29)
aw.TextSize=12
aw.FontFace=p.Font
aw.Parent=au
addCorner(aw)
d.ProfileLabel=aw
end
local aw=Instance.new"ImageLabel"
aw.Name="Arrow"
aw.Size=UDim2.fromOffset(4,8)
aw.Position=UDim2.new(1,-20,0,16)
aw.BackgroundTransparency=1
aw.Image=v"vape/assets/new/expandright.png"
aw.ImageColor3=n.Light(p.Main,0.37)
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
o:Tween(aw,p.Tween,{
Position=UDim2.new(1,ax.Enabled and-14 or-20,0,16),
})
au.TextColor3=ax.Enabled
and Color3.fromHSV(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
or p.Text
if av then
av.ImageColor3=au.TextColor3
end
au.BackgroundColor3=n.Light(p.Main,0.02)
as.Window.Visible=ax.Enabled
end

if as.Default and not at.Enabled then
at:Toggle()
end

au.MouseEnter:Connect(function()
if not at.Enabled then
au.TextColor3=p.Text
if buttonicon then
buttonicon.ImageColor3=p.Text
end
au.BackgroundColor3=n.Light(p.Main,0.02)
end
end)
au.MouseLeave:Connect(function()
if not at.Enabled then
au.TextColor3=n.Dark(p.Text,0.16)
if buttonicon then
buttonicon.ImageColor3=n.Dark(p.Text,0.16)
end
au.BackgroundColor3=p.Main
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
return I.Divider(af,as)
end

function ab.CreateOverlayBar(ar)
local as={Toggles={}}

local at=Instance.new"Frame"
at.Name="Overlays"
at.Size=UDim2.fromOffset(220,36)
at.BackgroundColor3=p.Main
at.BorderSizePixel=0
at.Parent=af
I.Divider(at)
local au=Instance.new"ImageButton"
au.Size=UDim2.fromOffset(24,24)
au.Position=UDim2.new(1,-29,0,7)
au.BackgroundTransparency=1
au.AutoButtonColor=false
au.Image=v"vape/assets/new/overlaysicon.png"
au.ImageColor3=n.Light(p.Main,0.37)
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
aw.BackgroundColor3=p.Main
aw.Parent=av
addCorner(aw)
local ax=Instance.new"ImageLabel"
ax.Name="Icon"
ax.Size=UDim2.fromOffset(14,12)
ax.Position=UDim2.fromOffset(10,13)
ax.BackgroundTransparency=1
ax.Image=v"vape/assets/new/overlaystab.png"
ax.ImageColor3=p.Text
ax.Parent=aw
local ay=Instance.new"TextLabel"
ay.Name="Title"
ay.Size=UDim2.new(1,-36,0,38)
ay.Position=UDim2.fromOffset(36,0)
ay.BackgroundTransparency=1
ay.Text="Overlays"
ay.TextXAlignment=Enum.TextXAlignment.Left
ay.TextColor3=p.Text
ay.TextSize=15
ay.FontFace=p.Font
ay.Parent=aw
local az=addCloseButton(aw,7)
local aA=Instance.new"Frame"
aA.Name="Divider"
aA.Size=UDim2.new(1,0,0,1)
aA.Position=UDim2.fromOffset(0,37)
aA.BackgroundColor3=n.Light(p.Main,0.02)
aA.BorderSizePixel=0
aA.Parent=aw
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
P.Text=string.rep(" ",33*B.Scale)..M.Name
P.TextXAlignment=Enum.TextXAlignment.Left
P.TextColor3=n.Dark(p.Text,0.16)
P.TextSize=14
P.FontFace=p.Font
P.Parent=J
local Q=Instance.new"ImageLabel"
Q.Name="Icon"
Q.Size=M.Size
Q.Position=M.Position
Q.BackgroundTransparency=1
Q.Image=M.Icon
Q.ImageColor3=p.Text
Q.Parent=P
local R=Instance.new"Frame"
R.Name="Knob"
R.Size=UDim2.fromOffset(22,12)
R.Position=UDim2.new(1,-30,0,14)
R.BackgroundColor3=n.Light(p.Main,0.14)
R.Parent=P
addCorner(R,UDim.new(1,0))
local S=R:Clone()
S.Size=UDim2.fromOffset(8,8)
S.Position=UDim2.fromOffset(2,2)
S.BackgroundColor3=p.Main
S.Parent=R
N.Object=P

function N.Toggle(T)
T.Enabled=not T.Enabled
T.Toggled:Fire()
o:Tween(R,p.Tween,{
BackgroundColor3=T.Enabled
and Color3.fromHSV(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
or(O and n.Light(p.Main,0.37)or n.Light(p.Main,0.14)),
})
o:Tween(S,p.Tween,{
Position=UDim2.fromOffset(T.Enabled and 12 or 2,2),
})
M.Function(T.Enabled)
end

B:GetPropertyChangedSignal"Scale":Connect(function()
P.Text=string.rep(" ",33*B.Scale)..M.Name
end)
P.MouseEnter:Connect(function()
O=true
if not N.Enabled then
o:Tween(R,p.Tween,{
BackgroundColor3=n.Light(p.Main,0.37),
})
end
end)
P.MouseLeave:Connect(function()
O=false
if not N.Enabled then
o:Tween(R,p.Tween,{
BackgroundColor3=n.Light(p.Main,0.14),
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
au.ImageColor3=p.Text
o:Tween(au,p.Tween,{
BackgroundTransparency=0.9,
})
end)
au.MouseLeave:Connect(function()
au.ImageColor3=n.Light(p.Main,0.37)
o:Tween(au,p.Tween,{
BackgroundTransparency=1,
})
end)
au.Activated:Connect(function()
av.Visible=true
o:Tween(av,p.Tween,{
BackgroundTransparency=0.5,
})
o:Tween(aw,p.Tween,{
Position=UDim2.new(0,0,1,-aw.Size.Y.Offset),
})
end)
az.Activated:Connect(function()
o:Tween(av,p.Tween,{
BackgroundTransparency=1,
})
o:Tween(aw,p.Tween,{
Position=UDim2.fromScale(0,1),
})
task.wait(0.2)
av.Visible=false
end)
av.Activated:Connect(function()
o:Tween(av,p.Tween,{
BackgroundTransparency=1,
})
o:Tween(aw,p.Tween,{
Position=UDim2.fromScale(0,1),
})
task.wait(0.2)
av.Visible=false
end)
K:GetPropertyChangedSignal"AbsoluteContentSize":Connect(function()
if d.ThreadFix then
setthreadidentity(8)
end
aw.Size=UDim2.fromOffset(220,math.min(37+K.AbsoluteContentSize.Y/B.Scale,605))
J.Size=UDim2.fromOffset(220,aw.Size.Y.Offset-5)
end)

d.Overlays=as

return as
end

function ab.CreateSettingsDivider(ar)
I.Divider(ap)
end

function ab.CreateSettingsPane(ar,as)
local at={}

local au=Instance.new"TextButton"
au.Name=as.Name
au.Size=UDim2.fromOffset(220,40)
au.BackgroundColor3=p.Main
au.BorderSizePixel=0
au.AutoButtonColor=false
au.Text="          "..as.Name
au.TextXAlignment=Enum.TextXAlignment.Left
au.TextColor3=n.Dark(p.Text,0.16)
au.TextSize=14
au.FontFace=p.Font
au.Parent=ap
local av=Instance.new"ImageLabel"
av.Name="Arrow"
av.Size=UDim2.fromOffset(4,8)
av.Position=UDim2.new(1,-20,0,16)
av.BackgroundTransparency=1
av.Image=v"vape/assets/new/expandright.png"
av.ImageColor3=n.Light(p.Main,0.37)
av.Parent=au
local aw=Instance.new"TextButton"
aw.Size=UDim2.fromScale(1,1)
aw.BackgroundColor3=p.Main
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
ax.TextColor3=p.Text
ax.TextSize=13
ax.FontFace=p.Font
ax.Parent=aw
local ay=addCloseButton(aw)
local az=Instance.new"ImageButton"
az.Name="Back"
az.Size=UDim2.fromOffset(16,16)
az.Position=UDim2.fromOffset(11,13)
az.BackgroundTransparency=1
az.Image=v"vape/assets/new/back.png"
az.ImageColor3=n.Light(p.Main,0.37)
az.Parent=aw
addCorner(aw)
local aA=Instance.new"Frame"
aA.Name="Children"
aA.Size=UDim2.new(1,0,1,-57)
aA.Position=UDim2.fromOffset(0,41)
aA.BackgroundColor3=p.Main
aA.BorderSizePixel=0
aA.Parent=aw
local J=Instance.new"Frame"
J.Name="Divider"
J.Size=UDim2.new(1,0,0,1)
J.BackgroundColor3=Color3.new(1,1,1)
J.BackgroundTransparency=0.928
J.BorderSizePixel=0
J.Parent=aA
local K=Instance.new"UIListLayout"
K.SortOrder=Enum.SortOrder.LayoutOrder
K.HorizontalAlignment=Enum.HorizontalAlignment.Center
K.Parent=aA

for L,M in I do
at["Create"..L]=function(N,O)
return M(O,aA,ab)
end
at["Add"..L]=at["Create"..L]
end

az.MouseEnter:Connect(function()
az.ImageColor3=p.Text
end)
az.MouseLeave:Connect(function()
az.ImageColor3=n.Light(p.Main,0.37)
end)
az.Activated:Connect(function()
aw.Visible=false
end)
au.MouseEnter:Connect(function()
au.TextColor3=p.Text
au.BackgroundColor3=n.Light(p.Main,0.02)
end)
au.MouseLeave:Connect(function()
au.TextColor3=n.Dark(p.Text,0.16)
au.BackgroundColor3=p.Main
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
ac.Size=UDim2.fromOffset(220,45+ag.AbsoluteContentSize.Y/B.Scale)
for L,M in ab.Buttons do
if M.Icon then
M.Object.Text=string.rep(" ",33*B.Scale)..M.Name
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
ay.BackgroundColor3=n.Dark(p.Main,0.02)
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
az.TextColor3=n.Dark(p.Text,0.16)
az.TextSize=11
az.FontFace=p.Font
az.Parent=ay
local aA=Instance.new"Frame"
aA.Name="Slider"
aA.Size=UDim2.fromOffset(200,2)
aA.Position=UDim2.fromOffset(10,37)
aA.BackgroundColor3=Color3.new(1,1,1)
aA.BorderSizePixel=0
aA.Parent=ay
local J=Instance.new"UIGradient"
J.Color=ax
J.Parent=aA
local K=aA:Clone()
K.Name="Fill"
K.Size=UDim2.fromScale(math.clamp(1,0.04,0.96),1)
K.Position=UDim2.new()
K.BackgroundTransparency=1
K.Parent=aA
local L=Instance.new"Frame"
L.Name="Knob"
L.Size=UDim2.fromOffset(24,4)
L.Position=UDim2.fromScale(1,0.5)
L.AnchorPoint=Vector2.new(0.5,0.5)
L.BackgroundColor3=n.Dark(p.Main,0.02)
L.BorderSizePixel=0
L.Parent=K
local M=Instance.new"Frame"
M.Name="Knob"
M.Size=UDim2.fromOffset(14,14)
M.Position=UDim2.fromScale(0.5,0.5)
M.AnchorPoint=Vector2.new(0.5,0.5)
M.BackgroundColor3=p.Text
M.Parent=L
addCorner(M,UDim.new(1,0))
if aw=="Custom color"then
local N=Instance.new"TextButton"
N.Size=UDim2.fromOffset(45,20)
N.Position=UDim2.new(1,-52,0,5)
N.BackgroundTransparency=1
N.Text="RESET"
N.TextColor3=n.Dark(p.Text,0.16)
N.TextSize=11
N.FontFace=p.Font
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
)and(N.Position.Y-ay.AbsolutePosition.Y)>(20*B.Scale)
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
math.clamp((O.Position.X-aA.AbsolutePosition.X)/aA.AbsoluteSize.X,0,1)
at:SetValue(
aw=="Custom color"and P or nil,
aw=="Saturation"and P or nil,
aw=="Vibrance"and P or nil,
aw=="Opacity"and P or nil
)
end
end)

local P
P=h.InputEnded:Connect(function(Q)
if Q==N and N.UserInputState==Enum.UserInputState.End then
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
o:Tween(M,p.Tween,{
Size=UDim2.fromOffset(16,16),
})
end)
ay.MouseLeave:Connect(function()
o:Tween(M,p.Tween,{
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
ax.TextColor3=n.Dark(p.Text,0.16)
ax.TextSize=11
ax.FontFace=p.Font
ax.Parent=aw
local ay=Instance.new"Frame"
ay.Name="Slider"
ay.Size=UDim2.fromOffset(200,2)
ay.Position=UDim2.fromOffset(10,37)
ay.BackgroundTransparency=1
ay.BorderSizePixel=0
ay.Parent=aw
local az=0
for aA,J in au do
local K=Instance.new"Frame"
K.Size=UDim2.fromOffset(27+(((aA+1)%2)==0 and 1 or 0),2)
K.Position=UDim2.fromOffset(az,0)
K.BackgroundColor3=J
K.BorderSizePixel=0
K.Parent=ay
az+=(K.Size.X.Offset+1)
end
local aA=Instance.new"ImageButton"
aA.Name="Preview"
aA.Size=UDim2.fromOffset(12,12)
aA.Position=UDim2.new(1,-22,0,10)
aA.BackgroundTransparency=1
aA.Image=v"vape/assets/new/colorpreview.png"
aA.ImageColor3=Color3.fromHSV(at.Hue,1,1)
aA.Parent=aw
local J=Instance.new"TextBox"
J.Name="Box"
J.Size=UDim2.fromOffset(60,15)
J.Position=UDim2.new(1,-69,0,9)
J.BackgroundTransparency=1
J.Visible=false
J.Text=""
J.TextXAlignment=Enum.TextXAlignment.Right
J.TextColor3=n.Dark(p.Text,0.16)
J.TextSize=11
J.FontFace=p.Font
J.ClearTextOnFocus=true
J.Parent=aw
local K=Instance.new"TextButton"
K.Name="Expand"
K.Size=UDim2.fromOffset(17,13)
K.Position=UDim2.new(0,F(ax.Text,ax.TextSize,ax.Font).X+11,0,7)
K.BackgroundTransparency=1
K.Text=""
K.Parent=aw
local L=Instance.new"ImageLabel"
L.Name="Expand"
L.Size=UDim2.fromOffset(9,5)
L.Position=UDim2.fromOffset(4,4)
L.BackgroundTransparency=1
L.Image=v"vape/assets/new/expandicon.png"
L.ImageColor3=n.Dark(p.Text,0.43)
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
N.Image=v"vape/assets/new/rainbow_1.png"
N.ImageColor3=n.Light(p.Main,0.37)
N.Parent=M
local O=N:Clone()
O.Image=v"vape/assets/new/rainbow_2.png"
O.Parent=M
local P=N:Clone()
P.Image=v"vape/assets/new/rainbow_3.png"
P.Parent=M
local Q=N:Clone()
Q.Image=v"vape/assets/new/rainbow_4.png"
Q.Parent=M
local R=Instance.new"ImageLabel"
R.Name="Knob"
R.Size=UDim2.fromOffset(26,12)
R.Position=UDim2.fromOffset(av[4]-3,-5)
R.BackgroundTransparency=1
R.Image=v"vape/assets/new/guislider.png"
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
local W=v"vape/assets/new/guislider.png"
local X=v"vape/assets/new/guisliderrain.png"
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

function at.SetValue(Z,_,aB,aC,aD)
if aD then
if Z.Rainbow then
Z:Toggle()
end
Z.CustomColor=false
_,aB,aC=au[aD]:ToHSV()
else
Z.CustomColor=true
end

Z.Hue=_ or Z.Hue
Z.Sat=aB or Z.Sat
Z.Value=aC or Z.Value
Z.Notch=aD
aA.ImageColor3=Color3.fromHSV(Z.Hue,Z.Sat,Z.Value)
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
o:Tween(R,p.Tween,{
Position=UDim2.fromOffset(av[4]-3,-5),
})
else
R.Image=W
R.ImageColor3=Color3.fromHSV(Z.Hue,Z.Sat,Z.Value)
o:Tween(R,p.Tween,{
Position=UDim2.fromOffset(av[aD or 4]-3,-5),
})
end

if Z.Rainbow then
if _ then
T.Slider.Fill.Size=UDim2.fromScale(math.clamp(Z.Hue,0.04,0.96),1)
end
if aB then
U.Slider.Fill.Size=UDim2.fromScale(math.clamp(Z.Sat,0.04,0.96),1)
end
if aC then
V.Slider.Fill.Size=UDim2.fromScale(math.clamp(Z.Value,0.04,0.96),1)
end
else
if _ then
o:Tween(T.Slider.Fill,p.Tween,{
Size=UDim2.fromScale(math.clamp(Z.Hue,0.04,0.96),1),
})
end
if aB then
o:Tween(U.Slider.Fill,p.Tween,{
Size=UDim2.fromScale(math.clamp(Z.Sat,0.04,0.96),1),
})
end
if aC then
o:Tween(V.Slider.Fill,p.Tween,{
Size=UDim2.fromScale(math.clamp(Z.Value,0.04,0.96),1),
})
end
end
as.Function(Z.Hue,Z.Sat,Z.Value)
end

function at.ToColor(aB)
return Color3.fromHSV(aB.Hue,aB.Sat,aB.Value)
end

function at.Toggle(aB)
aB.Rainbow=not aB.Rainbow
if Y then
task.cancel(Y)
end

if aB.Rainbow then
R.Image=X
table.insert(d.RainbowTable,aB)

N.ImageColor3=Color3.fromRGB(5,127,100)
Y=task.delay(0.1,function()
O.ImageColor3=Color3.fromRGB(228,125,43)
Y=task.delay(0.1,function()
P.ImageColor3=Color3.fromRGB(225,46,52)
Y=nil
end)
end)
else
aB:SetValue(nil,nil,nil,4)
R.Image=W
local aC=table.find(d.RainbowTable,aB)
if aC then
table.remove(d.RainbowTable,aC)
end

P.ImageColor3=n.Light(p.Main,0.37)
Y=task.delay(0.1,function()
O.ImageColor3=n.Light(p.Main,0.37)
Y=task.delay(0.1,function()
N.ImageColor3=n.Light(p.Main,0.37)
end)
end)
end
end

K.MouseEnter:Connect(function()
L.ImageColor3=n.Dark(p.Text,0.16)
end)
K.MouseLeave:Connect(function()
L.ImageColor3=n.Dark(p.Text,0.43)
end)
K.Activated:Connect(function()
T.Visible=not T.Visible
U.Visible=T.Visible
V.Visible=U.Visible
L.Rotation=U.Visible and 180 or 0
end)
aA.Activated:Connect(function()
aA.Visible=false
J.Visible=true
J:CaptureFocus()
local aB=Color3.fromHSV(at.Hue,at.Sat,at.Value)
J.Text=math.round(aB.R*255)
..", "
..math.round(aB.G*255)
..", "
..math.round(aB.B*255)
end)
aw.InputBegan:Connect(function(aB)
if
(
aB.UserInputType==Enum.UserInputType.MouseButton1
or aB.UserInputType==Enum.UserInputType.Touch
)and(aB.Position.Y-aw.AbsolutePosition.Y)>(20*B.Scale)
then
local aC=h.InputChanged:Connect(function(aC)
if
aC.UserInputType
==(
aB.UserInputType==Enum.UserInputType.MouseButton1
and Enum.UserInputType.MouseMovement
or Enum.UserInputType.Touch
)
then
at:SetValue(
nil,
nil,
nil,
math.clamp(
math.round((aC.Position.X-ay.AbsolutePosition.X)/B.Scale/27),
1,
7
)
)
end
end)

local aD
aD=h.InputEnded:Connect(function(Z)
if Z==aB and aB.UserInputState==Enum.UserInputState.End then
if aC then
aC:Disconnect()
end
if aD then
aD:Disconnect()
end
end
end)
at:SetValue(
nil,
nil,
nil,
math.clamp(math.round((aB.Position.X-ay.AbsolutePosition.X)/B.Scale/27),1,7)
)
end
end)
M.Activated:Connect(function()
at:Toggle()
end)
J.FocusLost:Connect(function(aB)
aA.Visible=true
J.Visible=false
if aB then
local aC=J.Text:split","
local aD,Z=pcall(function()
return tonumber(aC[1])
and Color3.fromRGB(tonumber(aC[1]),tonumber(aC[2]),tonumber(aC[3]))
or Color3.fromHex(J.Text)
end)

if aD then
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
an.ImageColor3=p.Text
end)
an.MouseLeave:Connect(function()
an.ImageColor3=n.Light(p.Main,0.37)
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
A.Text="Copied!"
setclipboard"https://discord.gg/voidware"
end)
end)
ah.MouseEnter:Connect(function()
ai.ImageColor3=p.Text
end)
ah.MouseLeave:Connect(function()
ai.ImageColor3=n.Light(p.Main,0.37)
end)
ah.Activated:Connect(function()
d.MainGuiSettingsOpenedEvent:Fire()
ak.Visible=true
end)
ag:GetPropertyChangedSignal"AbsoluteContentSize":Connect(function()
if aa.ThreadFix then
setthreadidentity(8)
end
ac.Size=UDim2.fromOffset(220,42+ag.AbsoluteContentSize.Y/B.Scale)
for ar,as in ab.Buttons do
if as.Icon then
as.Object.Text=string.rep(" ",36*B.Scale)..as.Name
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
ad.BackgroundColor3=p.Main
ad.AutoButtonColor=false
ad.Visible=false
ad.Text=""
ad.Parent=w
addBlur(ad)
addCorner(ad)

local ae=Instance.new"ImageLabel"
ae.Name="Icon"
ae.Size=ab.Size
ae.Position=UDim2.fromOffset(12,(ae.Size.X.Offset>20 and 14 or 13))
ae.BackgroundTransparency=1
ae.Image=ab.Icon
ae.ImageColor3=p.Text
ae.Parent=ad
local af=Instance.new"TextLabel"
af.Name="Title"
af.Size=UDim2.new(1,-(ab.Size.X.Offset>18 and 40 or 33),0,41)
af.Position=UDim2.fromOffset(math.abs(af.Size.X.Offset),0)
af.BackgroundTransparency=1
af.Text=ab.Name
af.TextXAlignment=Enum.TextXAlignment.Left
af.TextColor3=p.Text
af.TextSize=13
af.FontFace=p.Font
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
ai.Image=v"vape/assets/new/expandup.png"
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
category=ab.Name
})
d:Remove(an.Name)
local ao={
Enabled=false,
Options={},
Bind={},
Category=ab.Name,
Index=getTableSize(d.Modules),
Toggled=c(`{tostring(an.Name)}_{tostring(ac.Name)}_{tostring(an.SavingID)}_{tostring(an.ExtraText)}`),
}
for ap,aq in{"Name","SavingID","LegitSynced","ExtraText","NoSave","Aliases"}do
if an[aq]~=nil then
ao[aq]=an[aq]
end
end
an.Tooltip=an.Tooltip or an.Name
ao.Aliases=an.Aliases or d.AliasesConfig[ao.Name]or{}
ao.SearchKeys={ao.Name}
for ap,aq in ao.Aliases do
table.insert(ao.SearchKeys,aq)
end

local ap=an.DisplayName or an.Name
local aq=false
local ar=Instance.new"TextButton"
ar.Name=an.Name
ar.Size=UDim2.fromOffset(220,40)
ar.BackgroundColor3=p.Main
ar.BorderSizePixel=0
ar.AutoButtonColor=false
ar.Text="            "..ap
ar.TextXAlignment=Enum.TextXAlignment.Left
ar.TextColor3=n.Dark(p.Text,0.16)
ar.TextSize=14
ar.FontFace=p.Font
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
as.FontFace=p.Font

connectvisibilitychange(function(at)
o:Tween(as,TweenInfo.new(0.5,Enum.EasingStyle.Quad),{
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
av.Image=v"vape/assets/new/bind.png"
av.ImageColor3=n.Dark(p.Text,0.43)
av.Parent=au
local aw=Instance.new"TextLabel"
aw.Size=UDim2.fromScale(1,1)
aw.Position=UDim2.fromOffset(0,1)
aw.BackgroundTransparency=1
aw.Visible=false
aw.Text=""
aw.TextColor3=n.Dark(p.Text,0.43)
aw.TextSize=12
aw.FontFace=p.Font
aw.Parent=au
local ax=Instance.new"ImageLabel"
ax.Name="Cover"
ax.Size=UDim2.fromOffset(154,40)
ax.BackgroundTransparency=1
ax.Visible=false
ax.Image=v"vape/assets/new/bindbkg.png"
ax.ScaleType=Enum.ScaleType.Slice
ax.SliceCenter=Rect.new(0,0,141,40)
ax.Parent=ar
local ay=Instance.new"TextLabel"
ay.Name="Text"
ay.Size=UDim2.new(1,-10,1,-3)
ay.BackgroundTransparency=1
ay.Text="PRESS A KEY TO BIND"
ay.TextColor3=p.Text
ay.TextSize=11
ay.FontFace=p.Font
ay.Parent=ax
au.Parent=ar

local az=au:Clone()
az.Parent=ar
az.Name="Star"
az.Icon.Image=v"vape/assets/new/star.png"
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
o:Tween(aB,TweenInfo.new(0.5,Enum.EasingStyle.Quad),{
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

for aD,J in d.Modules do
aC[J.Category]=aC[J.Category]or{starred={},normal={}}

local K={
name=J.Name,

textSize=F(J.Name,J.Object.TextSize,J.Object.Font).X
}

if J.StarActive then
table.insert(aC[J.Category].starred,K)
else
table.insert(aC[J.Category].normal,K)
end
end

local function sortByTextSize(aD,J)
if aD.textSize==J.textSize then
return aD.name>J.name
end
return aD.textSize>J.textSize
end

for aD,J in aC do
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

for aC,aD in{az,au}do
aD:GetPropertyChangedSignal"Visible":Connect(function()
if not an.Premium then
return
end
if not aD.Visible then
return
end

task.defer(function()
aD.Visible=false
end)
end)
end

ao.StarActive=false
function ao.ToggleStar(aC,aD)
if an.Premium then
ao.StarActive=false
else
ao.StarActive=not ao.StarActive
end
az.BackgroundColor3=ao.StarActive and Color3.fromRGB(255,255,127)or Color3.fromRGB(255,255,255)
aB.Enabled=ao.StarActive
az.Visible=ao.StarActive or aq or at.Visible
if not aD then
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
local aD=Instance.new"ImageLabel"
aD.Name="Dots"
aD.Size=UDim2.fromOffset(3,16)
aD.Position=UDim2.fromOffset(4,12)
aD.BackgroundTransparency=1
aD.Image=v"vape/assets/new/dots.png"
aD.ImageColor3=n.Light(p.Main,0.37)
aD.Parent=aC
at.Name=an.Name.."Children"
at.Size=UDim2.new(1,0,0,0)
at.BackgroundColor3=n.Dark(p.Main,0.02)
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

local N=J.AbsoluteContentSize.Y/B.Scale

L=o:Tween(
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

M=o:Tween(
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
ax.Size=UDim2.fromOffset(F(ay.Text,ay.TextSize).X+20,40)
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
math.max(F(aw.Text,aw.TextSize,aw.Font).X+10,20),
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
ar.TextColor3=(aq or at.Visible)and p.Text
or n.Dark(p.Text,0.16)
ar.BackgroundColor3=(aq or at.Visible)and n.Light(p.Main,0.02)
or p.Main
aD.ImageColor3=N.Enabled and Color3.fromRGB(50,50,50)or n.Light(p.Main,0.37)
av.ImageColor3=n.Dark(p.Text,0.43)
aw.TextColor3=n.Dark(p.Text,0.43)
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

for N,O in I do
ao["Create"..N]=function(P,Q)
return O(Q,at,ao)
end
ao["Add"..N]=ao["Create"..N]
end

au.MouseEnter:Connect(function()
aw.Visible=false
av.Visible=not aw.Visible
av.Image=v"vape/assets/new/edit.png"
if not ao.Enabled then
av.ImageColor3=n.Dark(p.Text,0.16)
end
end)
au.MouseLeave:Connect(function()
aw.Visible=#ao.Bind>0
av.Visible=not aw.Visible
av.Image=v"vape/assets/new/bind.png"
if not ao.Enabled then
av.ImageColor3=n.Dark(p.Text,0.43)
end
end)
au.Activated:Connect(function()
ay.Text="PRESS A KEY TO BIND"
ax.Size=UDim2.fromOffset(F(ay.Text,ay.TextSize).X+20,40)
ax.Visible=true
d.Binding=ao
end)
az.Activated:Connect(function()
ao:ToggleStar()
end)
aC.MouseEnter:Connect(function()
if not ao.Enabled then
aD.ImageColor3=p.Text
end
end)
aC.MouseLeave:Connect(function()
if not ao.Enabled then
aD.ImageColor3=n.Light(p.Main,0.37)
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
ar.TextColor3=p.Text
ar.BackgroundColor3=n.Light(p.Main,0.02)
end
au.Visible=#ao.Bind>0 or aq or at.Visible
az.Visible=ao.StarActive or aq or at.Visible
end)
ar.MouseLeave:Connect(function()
aq=false
if not ao.Enabled and not at.Visible then
ar.TextColor3=n.Dark(p.Text,0.16)
ar.BackgroundColor3=p.Main
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

o:Tween(
S,
TweenInfo.new(R,Enum.EasingStyle.Linear),
{Size=UDim2.new(1,0,0,3)}
)

repeat
N=(h:GetMouseLocation()-Q).Magnitude<10
task.wait()
until(tick()-P)>R or not N or not w.Visible or d.Loaded==nil

if S and S.Parent then
S:Destroy()
end

if N and w.Visible then
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
O.Parent=w.Parent

local T=Instance.new"TextLabel"
T.Size=UDim2.fromScale(0.8,0.2)
T.Position=UDim2.fromScale(0.5,0.4)
T.AnchorPoint=Vector2.new(0.5,0.5)
T.BackgroundColor3=n.Dark(p.Main,0.1)
T.BackgroundTransparency=0
T.BorderSizePixel=0
T.Text="TAP ANYWHERE TO SET BUTTON POSITION"
T.TextColor3=p.Text
T.TextSize=18
T.TextWrapped=true
T.FontFace=p.Font
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
U.FontFace=p.Font
U.Parent=O


local V=o:Tween(
T,
TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut,-1,true),
{TextTransparency=0.3}
)

w.Visible=false
A.Visible=false
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

w.Visible=true
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

w.Visible=true
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
at.Size=UDim2.new(1,0,0,J.AbsoluteContentSize.Y/B.Scale)
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
o:Tween(ai,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
Rotation=am.Expanded and 0 or 180,
})
if not d.Loaded then
aj.Visible=am.Expanded
ad.Size=UDim2.fromOffset(
220,
am.Expanded and math.min(41+al.AbsoluteContentSize.Y/B.Scale,601)or 41
)
else
if am.Expanded then
aj.Visible=true
end
o:Tween(ad,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
Size=UDim2.fromOffset(
220,
am.Expanded and math.min(41+al.AbsoluteContentSize.Y/B.Scale,601)or 41
)
})





end
ak.Visible=aj.CanvasPosition.Y>10 and aj.Visible
end

if not ac.Expanded and ab.Visible then
ac:Expand()
end

ag.Activated:Connect(function()



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
aj.CanvasSize=UDim2.fromOffset(0,al.AbsoluteContentSize.Y/B.Scale)
if ac.Expanded then
ad.Size=UDim2.fromOffset(220,math.min(41+al.AbsoluteContentSize.Y/B.Scale,601))
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
ap.BackgroundColor3=an.BackgroundColor or n.Dark(p.Main,0.08)
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
as.ImageColor3=p.Text
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
at.TextColor3=p.Text
at.TextSize=14
at.FontFace=Font.new(p.Font.Family,Enum.FontWeight.SemiBold)
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
au.TextColor3=n.Dark(p.Text,0.4)
au.TextSize=12
au.FontFace=p.Font
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
aw.Image=v"vape/assets/new/expandup.png"
aw.ImageColor3=p.Text

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

local aB=az.Expanded and ay.AbsoluteContentSize.Y/B.Scale or 0

task.spawn(function()
flickerTextEffect(at,true,an.Name)
end)

local aC=az.UpExpand and 180 or 0
local aD=az.UpExpand and 0 or 180

o:Tween(aw,TweenInfo.new(0.25,Enum.EasingStyle.Quad),{
Rotation=az.Expanded and aC or aD,
ImageColor3=az.Expanded
and(an.AccentColor or an.StrokeColor or Color3.fromRGB(
100,
150,
255
))
or p.Text,
})

o:Tween(as,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
ImageColor3=az.Expanded
and(an.AccentColor or an.StrokeColor or Color3.fromRGB(
100,
150,
255
))
or p.Text,
})

o:Tween(as,TweenInfo.new(0.5,Enum.EasingStyle.Quad),{
Rotation=az.Expanded and 360 or 0,
})

o:Tween(ap,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
BackgroundColor3=az.Expanded and n.Dark(p.Main,0.12)
or(an.BackgroundColor or n.Dark(p.Main,0.08)),
})

ax.Visible=true
o:Tween(ax,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
Size=UDim2.new(1,0,0,aB),
})

if az.UpExpand then
o:Tween(ap,TweenInfo.new(0.3,Enum.EasingStyle.Quad),{
Size=UDim2.fromOffset(220,45+aB),
Position=UDim2.fromOffset(0,-(az.Expanded and aB or 0)),
})
else
o:Tween(ap,TweenInfo.new(0.3,Enum.EasingStyle.Quad),{
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
local aD=d.Modules[aC]
if aD then
az:AddModule(aD)
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
o:Tween(ap,TweenInfo.new(0.15),{
BackgroundColor3=n.Light(an.BackgroundColor or p.Main,0.05),
})
o:Tween(aw,TweenInfo.new(0.15),{
ImageColor3=an.AccentColor
or an.StrokeColor
or Color3.fromRGB(100,150,255),
})
end
end)

aq.MouseLeave:Connect(function()
if not ao.Expanded then
o:Tween(ap,TweenInfo.new(0.15),{
BackgroundColor3=an.BackgroundColor or n.Dark(p.Main,0.08),
})
o:Tween(aw,TweenInfo.new(0.15),{
ImageColor3=p.Text,
})
end
end)

ay:GetPropertyChangedSignal"AbsoluteContentSize":Connect(function()
if ao.Expanded then
local az=ay.AbsoluteContentSize.Y/B.Scale
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
if ac.LockedVisibility==nil then
return
end
if ad.Visible==ac.LockedVisibility then
return
end

task.defer(function()
ad.Visible=ac.LockedVisibility
end)
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
or G(
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
return G(
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
G(function()
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
or G(
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
or G(
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
return G(
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
G(function()
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
or G(
function()
if ab=="en"then
return{}
end
if tostring(shared.environment)=="translator_env"and isfolder"voidware_translations"and E(`voidware_translations/{ab}.json`)then
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
return G(
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
G(function()
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
ah.Visible=aj and(w.Visible or ai.Pinned)
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
ah.BackgroundColor3=p.Main
ah.AutoButtonColor=false
ah.Visible=false
ah.Text=""
ah.Parent=x

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
ak.ImageColor3=p.Text
ak.Parent=ah

local al=Instance.new"TextLabel"
al.Name="Title"
al.Size=UDim2.new(1,-32,0,41)
al.Position=UDim2.fromOffset(math.abs(al.Size.X.Offset),0)
al.BackgroundTransparency=1
al.Text=ag.Name
al.TextXAlignment=Enum.TextXAlignment.Left
al.TextColor3=p.Text
al.TextSize=13
al.FontFace=p.Font
al.Parent=ah

local am=Instance.new"ImageButton"
am.Name="Pin"
am.Size=UDim2.fromOffset(16,16)
am.Position=UDim2.new(1,-47,0,12)
am.BackgroundTransparency=1
am.AutoButtonColor=false
am.Image=v"vape/assets/new/pin.png"
am.ImageColor3=n.Dark(p.Text,0.43)
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
ao.Image=v"vape/assets/new/dots.png"
ao.ImageColor3=n.Light(p.Main,0.37)
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

aq.BackgroundColor3=n.Dark(p.Main,0.02)
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
ao.ImageColor3=as.Expanded and p.Text or n.Light(p.Main,0.37)

local au=ar.AbsoluteContentSize.Y/B.Scale
local av=math.min(41+au,601)

if as.Expanded then
if as.UpExpand then
o:Tween(ah,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
Size=UDim2.fromOffset(220,av),
Position=UDim2.fromOffset(ah.Position.X.Offset,ah.Position.Y.Offset-(av-41)),
})
else
o:Tween(ah,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
Size=UDim2.fromOffset(220,av),
})
end
else
if as.UpExpand then
local aw=ah.Size.Y.Offset
o:Tween(ah,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
Size=UDim2.fromOffset(as.WindowXOffset,41),
Position=UDim2.fromOffset(ah.Position.X.Offset,ah.Position.Y.Offset+(aw-41)),
})
else
o:Tween(ah,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
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
am.ImageColor3=as.Pinned and p.Text or n.Dark(p.Text,0.43)
end

if ag.Pinned then
ai.Pinned=true
end

function ai.Update(as)
ah.Visible=as.Button.Enabled and(w.Visible or as.Pinned)
if as.Expanded then
as:Expand()
end
if w.Visible then
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

for as,at in I do
ai["Create"..as]=function(au,av)
return at(av,aq,ai)
end
ai["Add"..as]=ai["Create"..as]
end

an.MouseEnter:Connect(function()
if not aq.Visible then
ao.ImageColor3=p.Text
end
end)
an.MouseLeave:Connect(function()
if not aq.Visible then
ao.ImageColor3=n.Light(p.Main,0.37)
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
aq.CanvasSize=UDim2.fromOffset(0,ar.AbsoluteContentSize.Y/B.Scale)
if ai.Expanded then
local as=ar.AbsoluteContentSize.Y/B.Scale
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
af:Clean(w:GetPropertyChangedSignal"Visible":Connect(function()
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
local an=a.createCustomSignal"refreshButtonsVisibility_Signal"
ag.PublicConfigs=ai

local ao="newest"

local ap=function()end
local aq=function()end

local ar=function()end
local as=function()end
local at=function()end
local au=function()end

local av=false
local aw=false
local ax=false
local ay=false

local az=false
local aA=false
local aB=false

local aC="STAGING"

local function checkWhitelistForRating()
if aC~="PRODUCTION"and not shared.VoidDev then
az=true
aB=false
end

if az then
an:Fire()
return aB
end

if not d._profile_loaded then
return false
end

local aD=d.Libraries.whitelist
if not aD then
return false
end

if not aD.refreshEvent then
return
end

if not aA then
aA=true
aD.refreshEvent:Connect(function()
aB=aD.localprio>0
an:Fire()
end)
end

if aD and aD.localprio then
aB=aD.localprio>0
else
aB=false
end
an:Fire()

az=true

return aB
end

am:Connect(checkWhitelistForRating)
af.Event:Connect(checkWhitelistForRating)


local aD=Instance.new"Frame"
aD.Name="ConfigGUI"
aD.Size=UDim2.fromOffset(1000,550)
aD.Position=UDim2.new(0.5,-500,0.5,-275)
aD.BackgroundColor3=p.Main
aD.BackgroundColor3=Color3.fromRGB(20,20,20)
aD.Visible=false
aD.Parent=x
y=aD
addBlur(aD)
addCorner(aD)
makeDraggable(aD)

ai.Window=aD
table.insert(d.Windows,aD)


local J=Instance.new"TextButton"
J.BackgroundTransparency=1
J.Text=""
J.Modal=true
J.Parent=aD


local K=Instance.new"TextButton"
K.Name="UploadButton"
K.Parent=aD
K.BackgroundColor3=Color3.fromRGB(5,134,105)
K.Size=UDim2.fromOffset(140,40)
K.Position=UDim2.new(1,-156,0,54)
K.Font=Enum.Font.GothamBold
K.Text="UPLOAD CONFIG"
K.TextColor3=Color3.new(1,1,1)
K.TextSize=12
K.AutoButtonColor=false
K.ZIndex=3
K.Visible=(getgenv().username~=nil and getgenv().password~=nil)
addCorner(K)

K.MouseEnter:Connect(function()
if ax then return end
g:Create(K,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(10,160,120)}):Play()
end)
K.MouseLeave:Connect(function()
if ax then return end
g:Create(K,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(5,134,105)}):Play()
end)


local L=Instance.new"Frame"
L.Name="UploadPopup"
L.Parent=aD
L.AnchorPoint=Vector2.new(0.5,0.5)
L.Position=UDim2.fromScale(0.5,0.55)
L.Size=UDim2.fromOffset(420,320)
L.BackgroundColor3=n.Dark(p.Main,0.1)
L.Visible=false
L.ZIndex=2
L.ChildAdded:Connect(function(M)
pcall(function()
M.ZIndex=2
end)
end)
addCorner(L)
addBlur(L)

local M=Instance.new"UIStroke"
M.Color=Color3.fromRGB(42,41,42)
M.Thickness=2
M.Parent=L

local N=addCloseButton(L)
N.ZIndex=11






N.Activated:Connect(function()
L.Visible=false
am:Fire()
al:Fire""
end)

local O=true


local P=Instance.new"TextLabel"
P.Parent=L
P.BackgroundTransparency=1
P.Position=UDim2.new(0,16,0,12)
P.Size=UDim2.new(1,-32,0,30)
P.Font=Enum.Font.GothamBold
P.Text="Upload Config"
P.TextColor3=Color3.fromRGB(220,220,220)
P.TextSize=16
P.TextXAlignment=Enum.TextXAlignment.Left

local Q=Instance.new"ScrollingFrame"
Q.Parent=L
Q.BackgroundTransparency=1
Q.Size=UDim2.fromScale(1,0.23)
Q.AutomaticCanvasSize=Enum.AutomaticSize.Y
Q.ScrollBarThickness=4
Q.Position=UDim2.new(0,10,0,60)
Q.CanvasSize=UDim2.new()

local R=Instance.new"UIScale"
R.Parent=Q
R.Scale=0.97

Q.ChildAdded:Connect(function(S)
pcall(function()
S.ZIndex=3
end)
end)

local S=Instance.new"UIListLayout"
S.Parent=Q
S.Padding=UDim.new(0,6)
S.SortOrder=Enum.SortOrder.LayoutOrder

local T

local function populateLocalProfiles()
for U,V in Q:GetChildren()do
if V:IsA"TextButton"then
V:Destroy()
end
end
for U,V in d.Profiles do
local W=Instance.new"TextButton"
W.Parent=Q
W.BackgroundColor3=Color3.fromRGB(40,40,40)
W.Size=UDim2.new(1,-10,0,38)
W.Text=V.Name
W.TextColor3=Color3.new(1,1,1)
W.Font=Enum.Font.Gotham
W.TextSize=16
W.ZIndex=2
W.TextTruncate=Enum.TextTruncate.AtEnd
addCorner(W)

W.Activated:Connect(function()
T=V.Name
for X,Y in Q:GetChildren()do
if Y:IsA"TextButton"then
Y.BackgroundColor3=Color3.fromRGB(40,40,40)
end
end
W.BackgroundColor3=Color3.fromHSV(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
end)
end
Q.CanvasSize=UDim2.fromOffset(0,S.AbsoluteContentSize.Y+10)
end

populateLocalProfiles()


local U=Instance.new"TextBox"
U.Parent=L
U.BackgroundColor3=n.Light(p.Main,0.3)
U.Position=UDim2.new(0,16,0,150)
U.Size=UDim2.new(1,-32,0,36)
U.PlaceholderText="Config name (required)"
U.Text=""
U.Font=Enum.Font.Gotham
U.TextColor3=Color3.new(1,1,1)
U.TextSize=15
addCorner(U)


local V=Instance.new"TextBox"
V.Parent=L
V.BackgroundColor3=n.Light(p.Main,0.3)
V.Position=UDim2.new(0,16,0,190)
V.Size=UDim2.new(1,-32,0,36)
V.PlaceholderText="Description (optional)"
V.Text=""
V.Font=Enum.Font.Gotham
V.TextColor3=Color3.new(1,1,1)
V.TextSize=15
addCorner(V)


local W=Instance.new"TextButton"
W.Parent=L
W.BackgroundColor3=Color3.fromRGB(5,134,105)
W.Position=UDim2.new(0,16,1,-60)
W.Size=UDim2.new(0.5,-24,0,40)
W.Text="PUBLISH"
W.TextColor3=Color3.new(1,1,1)
W.Font=Enum.Font.GothamBold
W.TextSize=13
addCorner(W)

local X=Instance.new"TextButton"
X.Parent=L
X.BackgroundColor3=Color3.fromRGB(60,60,60)
X.Position=UDim2.new(0.5,8,1,-60)
X.Size=UDim2.new(0.5,-24,0,40)
X.Text="CANCEL"
X.TextColor3=Color3.new(1,1,1)
X.Font=Enum.Font.GothamBold
X.TextSize=13
addCorner(X)

local Y=function()end
local function resetConfigs()
for Z,_ in ai do
pcall(function()
if _.instance~=nil then
pcall(function()
_:Destroy()
end)
end
end)
end
end

local Z=function()end

local _=Instance.new"TextButton"
_.Name="DeleteButton"
_.Parent=aD
_.BackgroundColor3=Color3.fromRGB(180,40,40)
_.Size=UDim2.fromOffset(140,40)
_.Position=UDim2.new(1,-312,0,54)
_.Font=Enum.Font.GothamBold
_.Text="DELETE CONFIG"
_.TextColor3=Color3.new(1,1,1)
_.TextSize=12
_.AutoButtonColor=false
_.Visible=(getgenv().username and getgenv().password)and true or false
_.ZIndex=2
addCorner(_)

_.MouseEnter:Connect(function()
if av then return end
g:Create(_,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(220,50,50)}):Play()
end)
_.MouseLeave:Connect(function()
if av then return end
g:Create(_,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(180,40,40)}):Play()
end)

local aE=Instance.new"TextButton"
aE.Name="UpdateButton"
aE.Parent=aD
aE.BackgroundColor3=Color3.fromRGB(100,80,200)
aE.Size=UDim2.fromOffset(140,40)
aE.Position=UDim2.new(1,-468,0,54)
aE.Font=Enum.Font.GothamBold
aE.Text="UPDATE CONFIG"
aE.TextColor3=Color3.new(1,1,1)
aE.TextSize=12
aE.AutoButtonColor=false
aE.Visible=(getgenv().username and getgenv().password)and true or false
aE.ZIndex=2
addCorner(aE)



aE.MouseEnter:Connect(function()
if aw then return end
g:Create(aE,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(130,100,230)}):Play()
end)
aE.MouseLeave:Connect(function()
if aw then return end
g:Create(aE,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(100,80,200)}):Play()
end)

local function revertToNormalMode(aF)
aw=false
al:Fire"None"
if not aF then
aq()
end

for aG,aH in ai do
if aH.instance and aH.deleteIcon and aH.canDelete and not aH.specialDelete then
aH.deleteIcon.Image=v("trash",true)
o:Tween(aH.deleteIcon,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{
BackgroundColor3=Color3.fromRGB(60,60,60)
})
local aI=aH.deleteIcon:FindFirstChild"UpdateStroke"
if aI then
aI:Destroy()
end
end
end
end

at=function()
aw=true

local aF=0

for aG,aH in ai do
if aH.instance and aH.deleteIcon and aH.canDelete and not aH.specialDelete then
aF=aF+1
aH.deleteIcon.Image=v("upload",true)
o:Tween(aH.deleteIcon,TweenInfo.new(0.3,Enum.EasingStyle.Quad),{
BackgroundColor3=Color3.fromRGB(70,60,140)
})


local aI=Instance.new"UIStroke"
aI.Name="UpdateStroke"
aI.Color=Color3.fromRGB(130,100,230)
aI.Thickness=0
aI.Transparency=1
o:Tween(aI,TweenInfo.new(0.3,Enum.EasingStyle.Quad),{
Thickness=1.5,
Transparency=0.3
})
aI.Parent=aH.deleteIcon
end
end
if aF==0 then
flickerTextEffect(aE,true,"UPDATE CONFIG")
o:Tween(aE,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(100,80,200),
})
revertToNormalMode(true)
ap("No Configs To Update :c",true)
task.delay(1.3,function()
aq()
end)
else
d:CreateNotification("Vape","Click the upload icon on any of your configs to update them",5,"info")
ap("Click the 'Upload' icon to update a config",true)
end
end

al:Connect(function(aF)
if aF=="Update"then return end
if aw then
flickerTextEffect(aE,true,"UPDATE CONFIG")
o:Tween(aE,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(100,80,200),
})
revertToNormalMode()
end
end)

aE.Activated:Connect(function()
if not getgenv().username or not getgenv().password then
d:CreateNotification("Vape","You must be logged in to update configs",6,"warning")
return
end

al:Fire"Update"

if aw then

flickerTextEffect(aE,true,"UPDATE CONFIG")
o:Tween(aE,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(100,80,200),
})
revertToNormalMode()
d:CreateNotification("Vape","Update mode cancelled",3,"info")
else

flickerTextEffect(aE,true,"STOP UPDATING")
o:Tween(aE,TweenInfo.new(0.15),{
BackgroundColor3=n.Dark(Color3.fromRGB(100,80,200),0.3)
})
at()
end
end)

local aF=Instance.new"TextButton"
aF.Name="RateButton"
aF.Parent=aD
aF.BackgroundColor3=Color3.fromRGB(200,160,20)
aF.Size=UDim2.fromOffset(140,40)
aF.Position=UDim2.new(1,-624,0,54)
aF.Font=Enum.Font.GothamBold
aF.Text="RATE CONFIG"
aF.TextColor3=Color3.new(1,1,1)
aF.TextSize=12
aF.AutoButtonColor=false
aF.Visible=false
aF.ZIndex=2
addCorner(aF)

aF.MouseEnter:Connect(function()
if ay then
return
end
g:Create(aF,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(230,190,50)}):Play()
end)
aF.MouseLeave:Connect(function()
if ay then
return
end
g:Create(aF,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(200,160,20)}):Play()
end)

local aG=Instance.new"Frame"
aG.Name="RatingPopup"
aG.Parent=aD
aG.AnchorPoint=Vector2.new(0.5,0.5)
aG.Position=UDim2.fromScale(0.5,0.55)
aG.Size=UDim2.fromOffset(450,400)
aG.BackgroundColor3=n.Dark(p.Main,0.1)
aG.Visible=false
aG.ZIndex=2
aG.ChildAdded:Connect(function(aH)
pcall(function()
aH.ZIndex=2
end)
end)
addCorner(aG)
addBlur(aG)

local aH=Instance.new"UIStroke"
aH.Color=Color3.fromRGB(42,41,42)
aH.Thickness=2
aH.Parent=aG

local aI=addCloseButton(aG)
aI.ZIndex=11

local aJ=a.createCustomSignal"ratingPopupClosed_Signal"

aI.Activated:Connect(function()
aG.Visible=false
aJ:Fire()
al:Fire""
end)

local aK=Instance.new"TextLabel"
aK.Parent=aG
aK.BackgroundTransparency=1
aK.Position=UDim2.new(0,16,0,12)
aK.Size=UDim2.new(1,-32,0,30)
aK.Font=Enum.Font.GothamBold
aK.Text="Rate Config"
aK.TextColor3=Color3.fromRGB(220,220,220)
aK.TextSize=16
aK.TextXAlignment=Enum.TextXAlignment.Left


local aL=Instance.new"TextLabel"
aL.Parent=aG
aL.BackgroundTransparency=1
aL.Position=UDim2.new(0,16,0,45)
aL.Size=UDim2.new(1,-32,0,20)
aL.Font=Enum.Font.Gotham
aL.Text=""
aL.TextColor3=Color3.fromRGB(150,150,150)
aL.TextSize=14
aL.TextXAlignment=Enum.TextXAlignment.Left

local aM=Instance.new"Frame"
aM.Parent=aG
aM.BackgroundTransparency=1
aM.Position=UDim2.new(0,16,0,80)
aM.Size=UDim2.new(1,-32,0,60)

local aN=Instance.new"UIListLayout"
aN.Parent=aM
aN.FillDirection=Enum.FillDirection.Horizontal
aN.SortOrder=Enum.SortOrder.LayoutOrder
aN.Padding=UDim.new(0,12)
aN.HorizontalAlignment=Enum.HorizontalAlignment.Center

local aO=0
local aP={}
local aQ

for aR=1,5 do
local aS=Instance.new"ImageButton"
aS.Parent=aM
aS.BackgroundTransparency=1
aS.Size=UDim2.fromOffset(50,50)
aS.Image=v("star",true)
aS.ImageColor3=Color3.fromRGB(100,100,100)
aS.LayoutOrder=aR
aS.ZIndex=3

local aT={
Button=aS,
Index=aR,
SetFilled=function(aT,aU)
o:Tween(aS,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
ImageColor3=aU and Color3.fromRGB(255,200,50)or Color3.fromRGB(100,100,100),
Size=aU and UDim2.fromOffset(55,55)or UDim2.fromOffset(50,50),
})
end,
}

aS.MouseEnter:Connect(function()
for aU=1,5 do
aP[aU]:SetFilled(aU<=aR)
end
end)

aS.MouseLeave:Connect(function()
for aU=1,5 do
aP[aU]:SetFilled(aU<=aO)
end
end)

aS.Activated:Connect(function()
aO=aR
for aU=1,5 do
aP[aU]:SetFilled(aU<=aO)
end
end)

table.insert(aP,aT)
end

local aR=Instance.new"TextLabel"
aR.Parent=aG
aR.BackgroundTransparency=1
aR.Position=UDim2.new(0,16,0,145)
aR.Size=UDim2.new(1,-32,0,20)
aR.Font=Enum.Font.GothamBold
aR.Text="Click a star to rate"
aR.TextColor3=Color3.fromRGB(180,180,180)
aR.TextSize=13

local aS={
"Terrible",
"Poor",
"Average",
"Good",
"Excellent",
}

for aT,aU in aP do
aU.Button.Activated:Connect(function()
aR.Text=aS[aT]or""
aR.TextColor3=Color3.fromHSV(math.clamp((aT-1)/4*0.33,0,0.33),0.7,0.9)
end)
end

local aT=Instance.new"TextLabel"
aT.Parent=aG
aT.BackgroundTransparency=1
aT.Position=UDim2.new(0,16,0,175)
aT.Size=UDim2.new(1,-32,0,20)
aT.Font=Enum.Font.GothamBold
aT.Text="Comment (Optional)"
aT.TextColor3=Color3.fromRGB(200,200,200)
aT.TextSize=13
aT.TextXAlignment=Enum.TextXAlignment.Left

local aU=Instance.new"TextBox"
aU.Parent=aG
aU.BackgroundColor3=n.Light(p.Main,0.3)
aU.Position=UDim2.new(0,16,0,200)
aU.Size=UDim2.new(1,-32,0,110)
aU.PlaceholderText="Share your thoughts about this config... (max 500 characters)"
aU.Text=""
aU.Font=Enum.Font.Gotham
aU.TextColor3=Color3.new(1,1,1)
aU.TextSize=17
aU.TextWrapped=true
aU.TextXAlignment=Enum.TextXAlignment.Left
aU.TextYAlignment=Enum.TextYAlignment.Top
aU.MultiLine=true
aU.ClearTextOnFocus=false
aU.ZIndex=3
addCorner(aU)

local aV=Instance.new"TextLabel"
aV.Parent=aU
aV.BackgroundTransparency=1
aV.Position=UDim2.new(1,-60,1,-22)
aV.Size=UDim2.fromOffset(50,20)
aV.Font=Enum.Font.Gotham
aV.Text="0/500"
aV.TextColor3=Color3.fromRGB(200,200,200)
aV.TextSize=15
aV.TextXAlignment=Enum.TextXAlignment.Right
aV.ZIndex=4

aU:GetPropertyChangedSignal"Text":Connect(function()
local aW=#aU.Text
if aW>500 then
aU.Text=aU.Text:sub(1,500)
aW=500
end
aV.Text=aW.."/500"
aV.TextColor3=aW>450 and Color3.fromRGB(255,150,150)or Color3.fromRGB(120,120,120)
end)

local aW=Instance.new"TextButton"
aW.Parent=aG
aW.BackgroundColor3=Color3.fromRGB(200,160,20)
aW.Position=UDim2.new(0,16,1,-60)
aW.Size=UDim2.new(0.5,-24,0,40)
aW.Text="SUBMIT RATING"
aW.TextColor3=Color3.new(1,1,1)
aW.Font=Enum.Font.GothamBold
aW.TextSize=13
aW.ZIndex=3
addCorner(aW)

aW.MouseEnter:Connect(function()
g
:Create(aW,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(230,190,50),
})
:Play()
end)

aW.MouseLeave:Connect(function()
g
:Create(aW,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(200,160,20),
})
:Play()
end)

local aX=Instance.new"TextButton"
aX.Parent=aG
aX.BackgroundColor3=Color3.fromRGB(60,60,60)
aX.Position=UDim2.new(0.5,8,1,-60)
aX.Size=UDim2.new(0.5,-24,0,40)
aX.Text="CANCEL"
aX.TextColor3=Color3.new(1,1,1)
aX.Font=Enum.Font.GothamBold
aX.TextSize=13
aX.ZIndex=3
addCorner(aX)

aX.MouseEnter:Connect(function()
g
:Create(aX,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(80,80,80),
})
:Play()
end)

aX.MouseLeave:Connect(function()
g
:Create(aX,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(60,60,60),
})
:Play()
end)

aX.Activated:Connect(function()
aG.Visible=false
aJ:Fire()
end)


aW.Activated:Connect(function()
if not checkWhitelistForRating()then
d:CreateNotification("Vape","You must be whitelisted (Rank 1+) to rate configs",6,"warning")
return
end

if aO==0 then
d:CreateNotification("Vape","Please select a star rating",5,"warning")
flickerTextEffect(aR,true,"Please select a rating!")
task.wait(0.5)
flickerTextEffect(aR,true,"Click a star to rate")
return
end

if not aQ then
d:CreateNotification("Vape","Invalid config reference",5,"warning")
return
end

d:CreateNotification("Vape","Submitting rating...",4,"info")

local aY=d.Libraries.whitelist~=nil and select(5,d.Libraries.whitelist:get(m.LocalPlayer))

local aZ={
hash=aY,
config_name=aQ.name,
rating=aO,
comment=aU.Text~=""and aU.Text or nil,
place=tostring(d.Place or game.PlaceId),
}

local a_,a0=pcall(function()
return request{
Url="https://configs.vapevoidware.xyz/configs/rate",
Method="POST",
Headers={["Content-Type"]="application/json"},
Body=l:JSONEncode(aZ),
}
end)

if a_ and a0 and a0.StatusCode==200 then
d:CreateNotification("Vape","Rating submitted successfully!",6,"info")
aG.Visible=false
aJ:Fire()

task.spawn(function()
task.wait(1)
Z()
end)
else
local a1=a0 and a0.Body or"Unknown error"
if a0 and a0.StatusCode==401 then
a1="Unable to verify whitelist :c"
elseif a0 and a0.StatusCode==409 then
a1="You've already rated this config"
else
local a2=decode(a1)
if a2~=nil and type(a2)=="table"and a2.detail~=nil then
a1=a2.detail
end
end
d:CreateNotification("Vape","Failed to submit rating: "..a1,8,"warning")
end
end)

local function revertFromRatingMode(aY)
ay=false
al:Fire"None"
if not aY then
aq()
end


for aZ,a_ in ai do
if a_.instance and tostring(a_.username)~=getgenv().username then

if a_.deleteIcon and a_.canDelete and not a_.specialDelete then
a_.deleteIcon.Image=v("trash",true)
o:Tween(a_.deleteIcon,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{
BackgroundColor3=Color3.fromRGB(60,60,60),
})
local a0=a_.deleteIcon:FindFirstChild"RatingStroke"
if a0 then
a0:Destroy()
end
end


if a_.tempRatingIcon then
a_.tempRatingIcon:Destroy()
a_.tempRatingIcon=nil


if a_.downloadButto and not a_.specialDelete then
o:Tween(a_.downloadButton,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
Size=UDim2.new(1,-24,0,38),
})
end
end
end
end
end

au=function()
ay=true

local aY=0

for aZ,a_ in ai do
if a_.instance and tostring(a_.username)~=getgenv().username then
aY=aY+1


if a_.deleteIcon and a_.canDelete and not a_.specialDelete then
a_.deleteIcon.Image=v("star",true)
o:Tween(a_.deleteIcon,TweenInfo.new(0.3,Enum.EasingStyle.Quad),{
BackgroundColor3=Color3.fromRGB(140,110,20),
})


local a0=Instance.new"UIStroke"
a0.Name="RatingStroke"
a0.Color=Color3.fromRGB(230,190,50)
a0.Thickness=0
a0.Transparency=1
o:Tween(a0,TweenInfo.new(0.3,Enum.EasingStyle.Quad),{
Thickness=1.5,
Transparency=0.3,
})
a0.Parent=a_.deleteIcon
else

local a0=Instance.new"ImageButton"
a0.Parent=a_.instance
a0.Size=UDim2.fromOffset(35,35)
a0.Position=UDim2.new(1,-47,1,-50)
a0.BackgroundColor3=Color3.fromRGB(140,110,20)
a0.AutoButtonColor=false
a0.Image=v("star",true)
a0.ImageColor3=Color3.fromRGB(255,220,100)
a0.ZIndex=a_.downloadButton.ZIndex
addCorner(a0)


local a1=Instance.new"UIStroke"
a1.Name="RatingStroke"
a1.Color=Color3.fromRGB(230,190,50)
a1.Thickness=1.5
a1.Transparency=0.3
a1.Parent=a0

a_.tempRatingIcon=a0


o:Tween(a_.downloadButton,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
Size=UDim2.new(1,-64,0,38),
})


a0.Activated:Connect(function()
if not checkWhitelistForRating()then
d:CreateNotification(
"Vape",
"You must be whitelisted (Rank 1+) to rate configs",
6,
"warning"
)
return
end

aQ=a_
aL.Text='"'..a_.name..'" by @'..a_.username
aG.Visible=true
end)
end
end
end

if aY==0 then
flickerTextEffect(aF,true,"RATE CONFIG")
o:Tween(aF,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(200,160,20),
})
revertFromRatingMode(true)
ap("No Configs To Rate :c",true)
task.delay(1.3,function()
aq()
end)
else
d:CreateNotification("Vape","Click the star icon on any config to rate it",5,"info")
ap("Click the 'Star' icon to rate a config",true)
end
end

al:Connect(function(aY)
if aY=="Rating"then
return
end
if ay then
flickerTextEffect(aF,true,"RATE CONFIG")
o:Tween(aF,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(200,160,20),
})
revertFromRatingMode()
end
end)

aF.Activated:Connect(function()
al:Fire"Rating"

if ay then

flickerTextEffect(aF,true,"RATE CONFIG")
o:Tween(aF,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(200,160,20),
})
revertFromRatingMode()
d:CreateNotification("Vape","Rating mode cancelled",3,"info")
else

flickerTextEffect(aF,true,"STOP RATING")
o:Tween(aF,TweenInfo.new(0.15),{
BackgroundColor3=n.Dark(Color3.fromRGB(200,160,20),0.3),
})
au()
end
end)

aJ:Connect(function()
aO=0
aU.Text=""
aQ=nil
aL.Text=""
for aY,aZ in aP do
aZ:SetFilled(false)
end
aR.Text="Click a star to rate"
aR.TextColor3=Color3.fromRGB(180,180,180)
end)


local function timestampToDate(aY)
local aZ=(os.time()-(tonumber(aY)or 0))/86400
if aZ<1 then
return"Today"
else
local a_=math.floor(aZ)
return a_.." day"..(a_>1 and"s"or"").." ago"
end
end

local aY={}
local aZ
local a_="all"

local a0=Instance.new"Frame"
a0.Name="PlaceFilterFrame"
a0.Parent=L
a0.BackgroundTransparency=1
a0.Position=UDim2.new(0,16,0,50)
a0.Size=UDim2.new(1,-32,0,30)
a0.Visible=false

local a1=Instance.new"UIListLayout"
a1.Parent=a0
a1.FillDirection=Enum.FillDirection.Horizontal
a1.SortOrder=Enum.SortOrder.LayoutOrder
a1.Padding=UDim.new(0,6)
a1.HorizontalAlignment=Enum.HorizontalAlignment.Left

local a2={}

local a3={
["6872265039"]="BW Lobby",
["6872274481"]="BW Game"
}

local function createPlaceFilterButton(a4,a5)
local a6=Instance.new"TextButton"
a6.Name=a3[a4]or a4
a6.Parent=a0
a6.ZIndex=3
a6.BackgroundColor3=Color3.fromHSV(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
a6.BackgroundTransparency=(a_==a5)and 0 or 0.8
a6.Size=UDim2.fromOffset(85,28)
a6.Font=Enum.Font.GothamBold
a6.Text=a6.Name:upper()
a6.TextColor3=Color3.new(1,1,1)
a6.TextSize=10
a6.TextTransparency=(a_==a5)and 0 or 0.6
a6.AutoButtonColor=false
addCorner(a6)

local a7={
Button=a6,
PlaceId=a5,
SetActive=function(a7,a8)
a6.BackgroundTransparency=a8 and 0 or 0.8
a6.TextTransparency=a8 and 0 or 0.6
end,
}

a6.Activated:Connect(function()
a_=a5
for a8,a9 in a2 do
a9:SetActive(false)
end
a7:SetActive(true)
ar()
end)

connectguicolorchange(function(a8,a9,ba)
a6.BackgroundColor3=Color3.fromHSV(a8,a9,ba)
end)

table.insert(a2,a7)
return a7
end

local function populateDeleteConfigs()
for a4,a5 in Q:GetChildren()do
if a5:IsA"TextButton"or a5:IsA"TextLabel"then
a5:Destroy()
end
end

local a4={}
for a5,a6 in aY do
local a7=tostring(a6.place or"")
if a_=="all"then
table.insert(a4,a6)
elseif a_=="no_place"then
if a7==""or a7=="nil"then
table.insert(a4,a6)
end
else
if a7==a_ then
table.insert(a4,a6)
end
end
end

if#a4==0 then
local a5=Instance.new"TextLabel"
a5.Parent=Q
a5.BackgroundTransparency=1
a5.Size=UDim2.new(1,-10,0,40)
a5.Text="No configs found for this filter"
a5.TextColor3=Color3.fromRGB(150,150,150)
a5.Font=Enum.Font.Gotham
a5.TextSize=13
return
end

for a5,a6 in a4 do
local a7=Instance.new"TextButton"
a7.Parent=Q
a7.BackgroundColor3=Color3.fromRGB(40,40,40)
a7.Size=UDim2.new(1,-10,0,40)

local a8=""
local a9=tostring(a6.place or"")
if a9~=""and a9~="nil"then
a8=" [Place: "..a9 .."]"
end

a7.Text=a6.name..a8 .." (Last Edited: "..timestampToDate(a6.edited)..")"
a7.TextColor3=Color3.new(1,1,1)
a7.Font=Enum.Font.Gotham
a7.TextSize=14
a7.TextTruncate=Enum.TextTruncate.AtEnd
addCorner(a7)

a7.Activated:Connect(function()
aZ=a6.name
for ba,bb in Q:GetChildren()do
if bb:IsA"TextButton"then
bb.BackgroundColor3=Color3.fromRGB(40,40,40)
end
end
a7.BackgroundColor3=Color3.fromRGB(180,40,40)
end)
end

Q.CanvasSize=UDim2.fromOffset(0,S.AbsoluteContentSize.Y+10)
end

ar=function()
ap("Click on the config you want to delete",true)
P.Text="Delete Config"
Q.Size=UDim2.fromScale(1,0.52)
Q.Position=UDim2.new(0,10,0,90)
U.Visible=false
V.Visible=false
W.Text="DELETE"
W.BackgroundColor3=Color3.fromRGB(180,40,40)
X.Text="CANCEL"
a0.Visible=true


for a4,a5 in a2 do
a5.Button:Destroy()
end
a2={}

if#aY==0 then
a0.Visible=false
for a4,a5 in Q:GetChildren()do
if a5:IsA"TextButton"or a5:IsA"TextLabel"then
a5:Destroy()
end
end
local a4=Instance.new"TextLabel"
a4.Parent=Q
a4.BackgroundTransparency=1
a4.Size=UDim2.new(1,-10,0,40)
a4.Text="No uploaded configs found"
a4.TextColor3=Color3.fromRGB(150,150,150)
a4.Font=Enum.Font.Gotham
a4.TextSize=13
return
end


local a4={}
local a5=false
for a6,a7 in aY do
local a8=tostring(a7.place or"")
if a8==""or a8=="nil"then
a5=true
else
if not table.find(a4,a8)then
table.insert(a4,a8)
end
end
end


createPlaceFilterButton("All","all")


if a5 then
createPlaceFilterButton("No Place","no_place")
end


table.sort(a4)
for a6,a7 in a4 do
local a8=a7

if#a7>10 then
a8=a7:sub(1,8)..".."
end
createPlaceFilterButton(a8,a7)
end


for a6,a7 in a2 do
a7:SetActive(a7.PlaceId==a_)
end

populateDeleteConfigs()
end

as=function()
ap("Click on the config you want to upload",true)
ax=true
P.Text="Upload Config"
U.Visible=true
V.Visible=true
W.Text="PUBLISH"
W.BackgroundColor3=Color3.fromRGB(5,134,105)
X.Text="CANCEL"
T=nil
a0.Visible=false
Q.Size=UDim2.fromScale(1,0.23)
Q.Position=UDim2.new(0,10,0,60)
populateLocalProfiles()
end

































































local a4={
oldest=function(a4,a5)
return(a4.edited or 0)<(a5.edited or 0)
end,
newest=function(a4,a5)
return(a4.edited or 0)>(a5.edited or 0)
end,
}

am:Connect(function()
if av then
flickerTextEffect(_,true,"DELETE CONFIG")
o:Tween(_,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(180,40,40),
})
aq()
end
av=false
end)

al:Connect(function(a5)
if a5=="Delete"then return end
if av then
flickerTextEffect(_,true,"DELETE CONFIG")
o:Tween(_,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(180,40,40),
})
end
av=false
L.Visible=false
end)

_.Activated:Connect(function()
if not getgenv().username or not getgenv().password then
d:CreateNotification("Vape","You must be logged in to delete configs",6,"warning")
return
end
al:Fire"Delete"

d:CreateNotification("Vape","Fetching your uploaded configs...",4,"info")
ap("Fetching uploaded configs...",true)

local a5,a6=pcall(function()
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

if av then
flickerTextEffect(_,true,"DELETE CONFIG")
o:Tween(_,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(180,40,40),
})
else
flickerTextEffect(_,true,"STOP DELETING")
o:Tween(_,TweenInfo.new(0.15),{
BackgroundColor3=n.Dark(Color3.fromRGB(180,40,40),0.3),
})
end

if a5 and a6 and a6.StatusCode==200 then
local a7=l:JSONDecode(a6.Body)
aY=a7.configs or{}

if#aY==0 then
d:CreateNotification("Vape","You have no uploaded configs",5,"info")
return
end

av=true
ar()
Q.Visible=true
L.Visible=true
else
local a7=a6 and a6.Body or"Request failed"
if a6 and a6.StatusCode==401 then
a7="Invalid username/password"
else
local a8=decode(a7)
if a8~=nil and type(a8)=="table"and a8.detail~=nil then
a7=a8.detail
end
end

ap("Couldn't fetch your configs :c",true)
task.delay(0.5,function()
aq()
end)
d:CreateNotification("Vape","Failed to fetch your configs: "..a7,8,"warning")
end
end)

W.Activated:Connect(function()
if av then
if not aZ then
d:CreateNotification("Vape","Please select a config to delete",5,"warning")
return
end

d:CreateNotification("Vape",`Deleting {aZ}...`,5,"info")

local a5,a6=pcall(function()
return request{
Url="https://configs.vapevoidware.xyz/configs",
Method="DELETE",
Headers={["Content-Type"]="application/json"},
Body=l:JSONEncode{
username=getgenv().username,
password=getgenv().password,
config=aZ,
place=tostring(d.Place or game.PlaceId)
}
}
end)

if a5 and a6 and a6.StatusCode==200 then
d:CreateNotification("Vape",`Successfully deleted {aZ}`,6,"info")
L.Visible=false
am:Fire()

task.spawn(function()
task.wait(1)
Z()
end)
else
local a7=a6 and a6.Body or"Unknown error"
if a6 and a6.StatusCode==401 then
a7="Invalid username/password!"
else
local a8=decode(a7)
if a8~=nil and type(a8)=="table"and a8.detail~=nil then
a7=a8.detail
end
end
d:CreateNotification("Vape","Delete failed: "..a7,8,"warning")
end
else
if not T then
d:CreateNotification("Vape","Please select a local profile first",5,"warning")
return
end
if U.Text==""then
d:CreateNotification("Vape","Config name is required",5,"warning")
flickerTextEffect(U,true,"Name Required!")
task.wait(0.3)
flickerTextEffect(U,true,"")
return
end

local a5="vape/profiles/"..T..d.Place..".txt"
if not E(a5)then
d:CreateNotification("Vape","Failed to read config file. Please choose different profile :c",6,"warning")
return
end
local a6,a7=pcall(readfile,a5)
if not(a6 and a7~=nil)then
d:CreateNotification("Vape","Failed to read config file. Please choose different profile :c",6,"warning")
return
end

d:CreateNotification("Vape","Publishing config...",5,"info")

local a8={
username=getgenv().username,
password=getgenv().password,
config_name=U.Text,
config=a7,
color={d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value},
description=V.Text,
}
if O then
a8.place=d.Place or game.PlaceId
a8.place=tostring(a8.place)
end

local a9,ba=pcall(function()
return request{
Url="https://configs.vapevoidware.xyz/configs",
Method="POST",
Headers={["Content-Type"]="application/json"},
Body=l:JSONEncode(a8)
}
end)

if a9 and ba and ba.StatusCode==200 then
local bb=ba.Body
local bc=string.find(bb,"isOverwritten")and true or false
d:CreateNotification(
"Vape",
`Successfully published "{U.Text}"`
..(bc and" (overwritten)"or"")
..(O and" [Place Based]"or""),
8,
"info"
)

L.Visible=false
am:Fire()

task.spawn(function()
task.wait(1)
Z()
end)
else
local bb=a9 and(ba and ba.Body or"Unknown error")or tostring(ba)
if ba.StatusCode==401 then
bb="Username or Password missing/invalid!"
else
local bc=decode(bb)
if bc~=nil and type(bc)=="table"and bc.detail~=nil then
bb=bc.detail
end
end
if string.lower(bb):find"rate limit"then
ap("Please wait before uploading a config!",true)
task.delay(2,function()
ap("Click on the config you want to upload",true)
end)
end
d:CreateNotification("Vape","Failed to publish: "..bb,10,"warning")
end
end
end)

X.Activated:Connect(function()
L.Visible=false
am:Fire()
av=false
if ax then
ax=false
else
as()
end
end)

am:Connect(function()
if ax then
flickerTextEffect(K,true,"UPLOAD CONFIG")
o:Tween(K,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(5,134,105),
})
ax=false
aq()
end
end)

al:Connect(function(a5)
if a5=="Upload"then return end
if ax then
flickerTextEffect(K,true,"UPLOAD CONFIG")
o:Tween(K,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(5,134,105),
})
ax=false
L.Visible=false
aq()
end
end)

K.Activated:Connect(function()
al:Fire"Upload"
av=false

if ax then

flickerTextEffect(K,true,"UPLOAD CONFIG")
o:Tween(K,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(5,134,105),
})
ax=false
L.Visible=false
aq()
else
flickerTextEffect(K,true,"STOP UPLOADING")
o:Tween(K,TweenInfo.new(0.15),{
BackgroundColor3=n.Dark(Color3.fromRGB(5,134,105),0.3),
})
ax=true
as()
populateLocalProfiles()
V.Text=""
L.Visible=true
end
end)

local function updateDeleteButtonVisibility()
_.Visible=(getgenv().username~=nil and getgenv().password~=nil)
K.Visible=_.Visible
aE.Visible=_.Visible
aF.Visible=aB
end
updateDeleteButtonVisibility()
an:Connect(updateDeleteButtonVisibility)


local a5=Instance.new"ImageLabel"
a5.Name="Icon"
a5.Size=UDim2.fromOffset(16,16)
a5.Position=UDim2.fromOffset(16,14)
a5.BackgroundTransparency=1
a5.Image=v"vape/assets/new/profilesicon.png"
a5.ImageColor3=p.Text
a5.Parent=aD

local a6=Instance.new"TextLabel"
a6.Parent=a5
a6.BackgroundTransparency=1
a6.Position=UDim2.new(0,24,0,0)
a6.Size=UDim2.new(1,100,0,16)
a6.Font=Enum.Font.GothamBold
a6.Text="Public Profiles"
a6.TextColor3=p.Text
a6.TextSize=14
a6.TextXAlignment=Enum.TextXAlignment.Left


local a7=Instance.new"Frame"
a7.Name="BadgeContainer"
a7.Parent=aD
a7.BackgroundTransparency=1
a7.Position=UDim2.new(0,160,0,12)
a7.Size=UDim2.fromOffset(400,20)

local a8=Instance.new"UIListLayout"
a8.Parent=a7
a8.FillDirection=Enum.FillDirection.Horizontal
a8.SortOrder=Enum.SortOrder.LayoutOrder
a8.Padding=UDim.new(0,6)
a8.VerticalAlignment=Enum.VerticalAlignment.Center


if getgenv().username then
local a9=Instance.new"Frame"
a9.Name="UserBadge"
a9.Parent=a7
a9.BackgroundColor3=Color3.fromRGB(45,45,45)
a9.Size=UDim2.fromOffset(0,20)
a9.AutomaticSize=Enum.AutomaticSize.X
addCorner(a9,UDim.new(0,10))

local ba=Instance.new"UIPadding"
ba.Parent=a9
ba.PaddingLeft=UDim.new(0,8)
ba.PaddingRight=UDim.new(0,8)

local bb=Instance.new"TextLabel"
bb.Parent=a9
bb.BackgroundTransparency=1
bb.Position=UDim2.fromOffset(4,-1)
bb.Size=UDim2.fromOffset(12,20)
bb.Font=Enum.Font.GothamBold
bb.Text="@"
bb.TextColor3=Color3.fromRGB(150,150,150)
bb.TextSize=12

local bc=Instance.new"TextLabel"
bc.Parent=a9
bc.BackgroundTransparency=1
bc.Position=UDim2.fromOffset(16,0)
bc.Size=UDim2.fromOffset(0,20)
bc.AutomaticSize=Enum.AutomaticSize.X
bc.Font=Enum.Font.Gotham
bc.Text=tostring(getgenv().username)
bc.TextColor3=Color3.fromRGB(200,200,200)
bc.TextSize=13
bc.TextXAlignment=Enum.TextXAlignment.Left

local bd=Instance.new"UIStroke"
bd.Color=Color3.fromRGB(70,70,70)
bd.Thickness=1
bd.Parent=a9
end


if getgenv().admin_config_api_key~=nil and shared.VoidDev then
local a9=Instance.new"Frame"
a9.Name="AdminBadge"
a9.Parent=a7
a9.BackgroundColor3=Color3.fromRGB(60,30,30)
a9.Size=UDim2.fromOffset(0,20)
a9.AutomaticSize=Enum.AutomaticSize.X
addCorner(a9,UDim.new(0,10))

local ba=Instance.new"UIPadding"
ba.Parent=a9
ba.PaddingLeft=UDim.new(0,8)
ba.PaddingRight=UDim.new(0,8)

local bb=Instance.new"TextLabel"
bb.Parent=a9
bb.BackgroundTransparency=1
bb.Position=UDim2.fromOffset(3,-1)
bb.Size=UDim2.fromOffset(12,20)
bb.Font=Enum.Font.GothamBold
bb.Text="★"
bb.TextColor3=Color3.fromRGB(255,100,100)
bb.TextSize=12

local bc=Instance.new"TextLabel"
bc.Parent=a9
bc.BackgroundTransparency=1
bc.Position=UDim2.fromOffset(16,0)
bc.Size=UDim2.fromOffset(0,20)
bc.AutomaticSize=Enum.AutomaticSize.X
bc.Font=Enum.Font.GothamBold
bc.Text="ADMIN"
bc.TextColor3=Color3.fromRGB(255,120,120)
bc.TextSize=13
bc.TextXAlignment=Enum.TextXAlignment.Left

local bd=Instance.new"UIStroke"
bd.Color=Color3.fromRGB(255,80,80)
bd.Thickness=1
bd.Transparency=0.3
bd.Parent=a9
end

local a9=Instance.new"TextLabel"
a9.Parent=a5
a9.BackgroundTransparency=1
a9.Position=UDim2.new(0,24,0,0)
a9.Size=UDim2.new(1,100,0,16)
a9.Font=Enum.Font.GothamBold
a9.Text="Public Profiles"
a9.TextColor3=p.Text
a9.TextSize=14
a9.TextXAlignment=Enum.TextXAlignment.Left


local ba=Instance.new"ImageButton"
ba.Name="CloseButton"
ba.Size=UDim2.fromOffset(24,24)
ba.Position=UDim2.new(1,-40,0,12)
ba.BackgroundColor3=Color3.fromRGB(60,60,60)
ba.AutoButtonColor=false
ba.Image=v"vape/assets/new/close.png"
ba.ImageColor3=Color3.fromRGB(200,200,200)
ba.Parent=aD
addCorner(ba)

ba.MouseEnter:Connect(function()
g
:Create(ba,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{
BackgroundColor3=Color3.fromRGB(220,53,53),
ImageColor3=Color3.fromRGB(255,255,255),
})
:Play()
end)

ba.MouseLeave:Connect(function()
g
:Create(ba,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{
BackgroundColor3=Color3.fromRGB(60,60,60),
ImageColor3=Color3.fromRGB(200,200,200),
})
:Play()
end)

ba.Activated:Connect(function()
aD.Visible=false
w.Visible=true
if d.TutorialAPI.isActive then
d.TutorialAPI:setText"Tutorial Cancelled"
task.delay(0.3,function()
d.TutorialAPI:revertTutorialMode()
end)
end
end)

local bb=Instance.new"Frame"
bb.Parent=aD
bb.BackgroundColor3=Color3.new(1,1,1)
bb.BackgroundTransparency=0.95
bb.BorderSizePixel=0
bb.Position=UDim2.new(0,0,0,44)
bb.Size=UDim2.new(1,0,0,1)

local bc=Instance.new"Frame"
bc.Name="Search"
bc.Parent=aD
bc.BackgroundColor3=n.Dark(p.Main,0.05)
bc.BorderSizePixel=0
bc.Position=UDim2.new(0,16,0,54)
bc.Size=UDim2.fromOffset(968,40)

local bd=Instance.new"UIStroke"
bd.Color=Color3.fromRGB(42,41,42)
bd.Thickness=1
bd.Parent=bc

addCorner(bc)

local be=Instance.new"ImageLabel"
be.Parent=bc
be.BackgroundTransparency=1
be.BorderSizePixel=0
be.Position=UDim2.new(0,14,0.5,-8)
be.Size=UDim2.fromOffset(16,16)
be.Image=v"vape/assets/new/search.png"
be.ImageColor3=Color3.fromRGB(150,150,150)

local bf=Instance.new"TextBox"
bf.Parent=bc
bf.BackgroundTransparency=1
bf.BorderSizePixel=0
bf.Position=UDim2.new(0,40,0,0)
bf.Size=UDim2.new(1,-50,1,0)
bf.Font=Enum.Font.Gotham
bf.PlaceholderColor3=Color3.fromRGB(180,180,180)
bf.PlaceholderText="Search profile name or username..."
bf.Text=""
bf.TextColor3=Color3.fromRGB(200,200,200)
bf.TextSize=15
bf.TextXAlignment=Enum.TextXAlignment.Left

local bg=Instance.new"Frame"
bg.Parent=aD
bg.BackgroundTransparency=1
bg.BorderSizePixel=0
bg.Position=UDim2.new(0,16,0,104)
bg.Size=UDim2.fromOffset(968,32)

local bh=Instance.new"UIListLayout"
bh.Parent=bg
bh.FillDirection=Enum.FillDirection.Horizontal
bh.SortOrder=Enum.SortOrder.LayoutOrder
bh.VerticalAlignment=Enum.VerticalAlignment.Center
bh.Padding=UDim.new(0,8)

local bi=Instance.new"ScrollingFrame"
bi.Name="Children"
bi.Parent=aD
bi.Position=UDim2.new(0,16,0,144)
bi.Size=UDim2.fromOffset(968,390)
bi.BackgroundTransparency=1
bi.BorderSizePixel=0
bi.ScrollBarThickness=3
bi.ScrollBarImageTransparency=0.5
bi.AutomaticCanvasSize=Enum.AutomaticSize.XY
bi.CanvasSize=UDim2.new()
bi.ClipsDescendants=false

local bj=Instance.new"TextLabel"
bj.Name="ConfigsInfo"
bj.Parent=aD
bj.Position=bi.Position
bj.Size=bi.Size
bj.Text="No configs found :c"
bj.BackgroundColor3=Color3.fromRGB(30,30,30)
bj.TextSize=40
bj.TextColor3=Color3.fromRGB(200,200,200)
bj.Visible=false

local bk={
SetStep=function(bk,bl,bm)
if bm~=nil then
bj.Visible=bm
end
if bl~=nil then
bj.Text=bl
end
end
}

Z=function()
ap("Refreshing Configs...",true)
local bl,bm=G(function()
return l:JSONDecode(d.http_function"https://configs.vapevoidware.xyz")
end,3)
if not bl then
errorNotification("Voidware | Configs","Couldn't load the configs data :c Try again later",5)
ap("Couldn't load configs :c",true)
return
end

resetConfigs()
for bn,bo in bi:GetChildren()do
pcall(function()
if bo:IsA"TextButton"then
bo:Destroy()
end
end)
end
ai={Sorts=ai.Sorts}

table.sort(bm,a4[ao])
local bn=0
for bo,bp in bm do
local bq=d.Place or game.PlaceId
if not bp.place or tostring(bp.place)==tostring(bq)then
bn=bn+1
bi.ClipsDescendants=(bn>10)
Y(bp.name,bp.username,bp)
end
end
if bn<1 then
bk:SetStep("No Configs found :C",true)
else
bk:SetStep(nil,false)
end
if aj~=nil then
local bo={"all"}
for bp,bq in table.clone(bm)do
if not bq.username then continue end
bq.username=tostring(bq.username)
if table.find(bo,bq.username)then continue end
table.insert(bo,bq.username)
end
aj:SetValues(bo,"all")
end
aq()
end
d.ConfigsAPIRefresh=function()
task.spawn(Z)
end

local bl=Instance.new"UIGridLayout"
bl.Parent=bi
bl.SortOrder=Enum.SortOrder.LayoutOrder
bl.CellSize=UDim2.fromOffset(180,180)
bl.CellPadding=UDim2.fromOffset(12,12)
bl.HorizontalAlignment=Enum.HorizontalAlignment.Center

bl:GetPropertyChangedSignal"AbsoluteContentSize":Connect(function()
if ag.ThreadFix then
setthreadidentity(8)
end
bi.CanvasSize=UDim2.fromOffset(0,bl.AbsoluteContentSize.Y+20)
end)

ak:Connect(function()
local bm=aj.Value
for bn,bo in ai do
if bo.instance~=nil and bo.username~=nil then
bo.instance.Visible=(bm=="all"or tostring(bo.username)==bm)
end
end
end)

Y=function(bm,bn,bo)
if ai[bm]then return end
ai[bm]=table.clone(bo)

local bp=false
local bq=false

if getgenv().username and bn and bn:lower()==tostring(getgenv().username):lower()then
bq=true
elseif getgenv().admin_config_api_key~=nil and shared.VoidDev then
bq=true
bp=true
end
local br=Instance.new"TextButton"
br.Parent=bi
br.BackgroundTransparency=1
br.LayoutOrder=#bi:GetChildren()+1
br.ClipsDescendants=false
br.AutoButtonColor=false
br.Text=""
br.Size=UDim2.fromOffset(220,220)

ai[bm].instance=br

local bs,bt
if bo.color~=nil and type(bo.color)=="table"then
bs,bt=hsv(unpack(bo.color))
else
bs=false
bt=nil
end

local bu=bs and bt~=nil and"config"or"gui"
local function getStrokeColor()
return bu=="gui"and Color3.fromHSV(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)or bt
end

local bv=Instance.new"UIStroke"
bv.Color=Color3.fromRGB(50,50,50)
if bu=="gui"then
connectguicolorchange(function(bw,bx,by)
bv.Color=Color3.fromHSV(bw,bx,by)
end)
else
bv.Color=bt
end
bv.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
bv.Thickness=1
bv.Parent=br

addCorner(br)


local bw=Instance.new"TextLabel"
bw.Parent=br
bw.BackgroundTransparency=1
bw.Position=UDim2.new(0,12,0,12)
bw.Size=UDim2.new(1,-24,0,40)
bw.Font=Enum.Font.GothamBold
bw.RichText=true
bw.Text=bm
bw.TextColor3=Color3.fromRGB(220,220,220)
bw.TextSize=15
bw.TextWrapped=true
bw.TextXAlignment=Enum.TextXAlignment.Left
bw.TextYAlignment=Enum.TextYAlignment.Top


local bx=Instance.new"TextLabel"
bx.Parent=br
bx.BackgroundTransparency=1
bx.Position=UDim2.new(0,12,0,52)
bx.Size=UDim2.new(1,-24,0,18)
bx.Font=Enum.Font.Gotham
bx.Text="By: @"..bn
bx.TextColor3=Color3.fromRGB(150,150,150)
bx.TextSize=15
bx.TextXAlignment=Enum.TextXAlignment.Left


local by=Instance.new"TextLabel"
by.Parent=br
by.BackgroundTransparency=1
by.Position=UDim2.new(0,12,0,70)
by.Size=UDim2.new(1,-24,0,65)
by.Font=Enum.Font.Gotham
by.Text=bo.description or"No description provided"
by.TextColor3=Color3.fromRGB(130,130,130)
by.TextSize=15
by.TextWrapped=true
by.TextXAlignment=Enum.TextXAlignment.Left
by.TextYAlignment=Enum.TextYAlignment.Top


local bz=Instance.new"TextLabel"
bz.Parent=br
bz.BackgroundTransparency=1
bz.Position=UDim2.new(0,12,0,100)
bz.Size=UDim2.new(1,-24,0,16)
bz.Font=Enum.Font.Gotham
bz.Text="Last Update: "..timestampToDate(bo.edited)
bz.TextColor3=Color3.fromRGB(100,100,100)
bz.TextSize=14

local bA=false


local bB=Instance.new"TextButton"
bB.Parent=br
bB.BackgroundColor3=Color3.fromRGB(5,134,105)
connectguicolorchange(function(bC,bD,bE)
bB.BackgroundColor3=bA and n.Dark(Color3.fromHSV(bC,bD,bE),0.3)or Color3.fromHSV(bC,bD,bE)
end)
bB.Size=bq and UDim2.new(1,-64,0,38)or UDim2.new(1,-24,0,38)
bB.Position=UDim2.new(0,12,1,-50)
bB.Font=Enum.Font.GothamBold
bB.Text="DOWNLOAD"
bB.TextColor3=Color3.fromRGB(255,255,255)
bB.TextSize=12
bB.AutoButtonColor=false
bB.BorderSizePixel=0

ai[bm].downloadButton=bB

addCorner(bB)

bB.MouseEnter:Connect(function()
local bC,bD,bE=d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value
local bF=bA and n.Dark(Color3.fromHSV(bC,bD,bE),0.3)or Color3.fromHSV(bC,bD,bE)
g
:Create(bB,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{
BackgroundColor3=n.Light(bF,0.3),
})
:Play()
end)

bB.MouseLeave:Connect(function()
local bC,bD,bE=d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value
local bF=bA and n.Dark(Color3.fromHSV(bC,bD,bE),0.3)or Color3.fromHSV(bC,bD,bE)
g
:Create(bB,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{
BackgroundColor3=bF
})
:Play()
end)

if bq then
local bC=bp

local bD=bC
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
PromptNote='<br/><font color="#ff6b6b">This action cannot be undone.</font>',
Accent=Color3.fromRGB(180,40,40),
}

local bE=Instance.new"ImageButton"
bE.Parent=br
bE.Size=UDim2.fromOffset(35,35)
bE.Position=UDim2.new(1,-47,1,-50)
bE.BackgroundColor3=Color3.fromRGB(60,60,60)
bE.AutoButtonColor=false
bE.Image=v((bp and"hammer"or"trash"),true)
bE.ImageColor3=Color3.fromRGB(220,220,220)
bE.ZIndex=bB.ZIndex
addCorner(bE)

ai[bm].deleteIcon=bE
ai[bm].canDelete=bq
ai[bm].specialDelete=bp

if bC then
bE.BackgroundColor3=Color3.fromRGB(90,30,30)

local bF=Instance.new"UIStroke"
bF.Color=Color3.fromRGB(255,80,80)
bF.Thickness=1.5
bF.Transparency=0.3
bF.Parent=bE
else
bE.MouseEnter:Connect(function()
g:Create(bE,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(180,40,40),
ImageColor3=Color3.fromRGB(255,255,255),
}):Play()
end)

bE.MouseLeave:Connect(function()
g:Create(bE,TweenInfo.new(0.15),{
BackgroundColor3=Color3.fromRGB(60,60,60),
ImageColor3=Color3.fromRGB(220,220,220),
}):Play()
end)
end

bE.Activated:Connect(function()
if ay then
if not checkWhitelistForRating()then
d:CreateNotification(
"Vape",
"You must be whitelisted (Rank 1+) to rate configs",
6,
"warning"
)
return
end

aQ=v
aL.Text='"'..v.name..'" by @'..v.username
aG.Visible=true
elseif aw then

local bF=d.Profile or"Unknown Profile"

d:CreatePrompt{
Title="Update Config",
Text=string.format(
'Overwrite <b><font color="rgb(150,150,255)">"%s"</font></b> with your current profile <b><font color="rgb(100,200,100)">"%s"</font></b>?\n<font color="rgb(180,180,180)">This will update the config with your current settings and GUI color.</font>',
bm,
bF
),
ConfirmText="UPDATE",
CancelText="CANCEL",
OnConfirm=function()

local bG="vape/profiles/"..bF..d.Place..".txt"
if not E(bG)then
d:CreateNotification(
"Vape",
"Failed to read current profile config file",
6,
"warning"
)
revertToNormalMode()
return
end
local bH,bI=pcall(readfile,bG)
if not(bH and bI~=nil)then
d:CreateNotification(
"Vape",
"Failed to read current profile config file",
6,
"warning"
)
revertToNormalMode()
return
end

d:CreateNotification("Vape",`Updating "{bm}"...`,5,"info")

local bJ={
username=getgenv().username,
password=getgenv().password,
config_name=bm,
config=bI,
color={d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value},
description=bo.description or"",
}

if O then
bJ.place=d.Place or game.PlaceId
bJ.place=tostring(bJ.place)
end

local bK,bL=pcall(function()
return request{
Url="https://configs.vapevoidware.xyz/configs",
Method="POST",
Headers={["Content-Type"]="application/json"},
Body=l:JSONEncode(bJ),
}
end)

if bK and bL and bL.StatusCode==200 then
d:CreateNotification(
"Vape",
`Successfully updated "{bm}" with profile "{bF}"!`,
8,
"info"
)

revertToNormalMode()

task.spawn(function()
task.wait(1)
Z()
end)
else
local bM=bK and(bL and bL.Body or"Unknown error")
or tostring(bL)
if bL and bL.StatusCode==401 then
bM="Username or Password missing/invalid!"
else
local bN=decode(bM)
if bN~=nil and type(bN)=="table"and bN.detail~=nil then
bM=bN.detail
end
end
d:CreateNotification("Vape","Failed to update: "..bM,10,"warning")
revertToNormalMode()
end
end,
OnCancel=function()
revertToNormalMode()
end,
}
else

d:CreatePrompt{
Title=bD.Title,
Text=([[Are you sure you want to delete "%s"?%s]]):format('<br/><font color="#ffffff">'..bm..'</font>',bD.PromptNote),
ConfirmText="DELETE",
CancelText="CANCEL",
OnConfirm=function()
d:CreateNotification(
"Vape",
(bD.ActionWord..' "%s"...'):format(bm),
5,
"info"
)

local bF={
username=getgenv().username,
password=getgenv().password,
config=bm,
place=tostring(d.Place or game.PlaceId),
}

if bC then
bF.adminkey=getgenv().admin_config_api_key
bF.username=tostring(bn)
bF.password=nil
end

local bG,bH=pcall(function()
return request{
Url="https://configs.vapevoidware.xyz/configs",
Method="DELETE",
Headers={["Content-Type"]="application/json"},
Body=l:JSONEncode(bF),
}
end)

if bG and bH and bH.StatusCode==200 then
d:CreateNotification(
"Vape",
(bD.DoneWord..' "%s"'):format(bm),
6,
"info"
)
Z()
else
local bI=bH and bH.Body or"Unknown error"
if bH and bH.StatusCode==401 then
bI="Invalid username/password!"
else
local bJ=decode(bI)
if bJ and type(bJ)=="table"and bJ.detail then
bI=bJ.detail
end
end

d:CreateNotification(
"Vape",
(bD.FailWord..": %s"):format(bI),
8,
"warning"
)
end
end,
}
end
end)
end

o:Tween(br,TweenInfo.new(0.3,Enum.EasingStyle.Quad),{
BackgroundColor3=n.Light(p.Main,0.08),
BackgroundTransparency=0,
})

br.MouseEnter:Connect(function()
o:Tween(br,TweenInfo.new(0.1,Enum.EasingStyle.Quad),{
BackgroundColor3=n.Light(p.Main,0.2),
})
o:Tween(bw,TweenInfo.new(0.1,Enum.EasingStyle.Quad),{
TextSize=17,
})
o:Tween(bx,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{
TextColor3=Color3.fromRGB(230,230,230),
})
o:Tween(bz,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{
TextColor3=Color3.fromRGB(200,200,200),
})
o:Tween(bv,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{

Color=getStrokeColor(),
Thickness=2,
})
end)

br.MouseLeave:Connect(function()
o:Tween(br,TweenInfo.new(0.1,Enum.EasingStyle.Quad),{
BackgroundColor3=n.Light(p.Main,0.08),
})
o:Tween(bw,TweenInfo.new(0.1,Enum.EasingStyle.Quad),{
TextSize=15,
})
o:Tween(bx,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{
TextColor3=Color3.fromRGB(150,150,150),
})
o:Tween(bz,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{
TextColor3=Color3.fromRGB(100,100,100),
})
o:Tween(bv,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{

Color=n.Dark(getStrokeColor(),0.3),
Thickness=1,
})
end)

pcall(function()
local bC=ai[bm]
if bC then
local bD=`{bC.name} ({bC.username})`
local bE=d.Profiles
if(bE~=nil and type(bE)=="table")then
for bF,bG in bE do
if type(bG)~="table"then continue end
if bG.Name==bD then
bB.Text="REINSTALL"
bA=true
local bH,bI,bJ=d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value
bB.BackgroundColor3=bA
and n.Dark(Color3.fromHSV(bH,bI,bJ),0.3)
or Color3.fromHSV(bH,bI,bJ)
break
end
end
end
end
end)

bB.Activated:Connect(function()
local bC=ai[bm]
if bC then
local bD=string.format("%s (%s)",bC.name,bC.username)
local bE,bF=bC.link:match"^(.-/)([^/]+)$"
if not bE or not bF then
errorNotification("Voidware | Configs",`Invalid URL for {tostring(bm)}. Please report this to a developer in discord.gg/voidware`,10)
warn("Invalid URL:",bC.link)
return
end local
bG, bH=pcall(function()
return bE..l:UrlEncode(bF)
end)
if not bH then
errorNotification("Voidware | Configs",`Couldn't resolve the url for {tostring(bm)}. Please report this to a developer in discord.gg/voidware`,10)
warn(`Invalid URL resolve: {tostring(bH)}`)
return
end
local bI=d.http_function(bH)
if bI:sub(1,1)=='"'and bI:sub(-1)=='"'then
local bJ,bK=pcall(function()
return l:JSONDecode(bI)
end)
if bJ then
bI=bK
end
end
local bJ=false
for bK,bL in d.Profiles do
if bL.Name==bD then
bJ=true
break
end
end
if not bJ then
table.insert(d.Profiles,{Name=bD,Bind={}})
end
local bK
if bC.color~=nil and type(bC.color)=="table"then
local bL,bM,bN=unpack(bC.color)
bL,bM,bN=num(bL),num(bM),num(bN)
if bL~=nil and bM~=nil and bN~=nil then
bK={
Hue=bL,
Sat=bM,
Value=bN,
CustomColor=true,
Rainbow=false
}
shared[`FORCE_PROFILE_GUI_COLOR_SET_{tostring(bD)}`]=bK
end
end
if bC.description~=nil then
shared[`FORCE_PROFILE_TEXT_GUI_CUSTOM_TEXT_{tostring(bD)}`]=tostring(bC.description)
end
d:Save(bD)
writefile("vape/profiles/"..bD..d.Place..".txt",bI)
d:Load(true,bD)
local bL=bJ and"Reinstalled"or"Downloaded"
d:CreateNotification("Vape",`{bL} "{bm}" by @{bC.username}`,5,"info")
bB.Text="REINSTALL"
bA=true
local bM,bN,bO=d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value
bB.BackgroundColor3=bA and n.Dark(Color3.fromHSV(bM,bN,bO),0.3)
or Color3.fromHSV(bM,bN,bO)
Z()
else
d:CreateNotification("Vape",`Failed to fetch config ({bm})`,10,"warning")
end
end)
task.wait(0.15)
end


local function addSorting(bm,bn,bo)
local bp=bo.Size
local bq=bo.On

local br=Instance.new"TextButton"
br.Name=bm
br.Parent=bg
br.BackgroundColor3=Color3.fromHSV(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
connectguicolorchange(br)
br.BackgroundTransparency=bq and 0 or 0.8
br.BorderSizePixel=0
br.Text=""
br.AutoButtonColor=false
br.Size=bp

local bs=Instance.new"TextLabel"
bs.Parent=br
bs.Name="label"
bs.BackgroundTransparency=1
bs.BorderSizePixel=0
bs.Size=UDim2.new(1,0,1,0)
bs.Font=Enum.Font.GothamBold
bs.TextTransparency=bq and 0 or 0.6
bs.Text=bm:upper()
bs.TextColor3=Color3.new(1,1,1)
bs.TextSize=11

addCorner(br,UDim.new(1,0))

local bt={
SetVisible=function(bt)
for bu,bv in ai.Sorts do
bv.Window.BackgroundTransparency=0.8
bv.Window.label.TextTransparency=0.6
end

br.BackgroundTransparency=bt and 0 or 0.8
bs.TextTransparency=bt and 0 or 0.6
end,
Window=br,
}

br.Activated:Connect(function()
bt:SetVisible(true)
ao=bm:lower()
Z()
end)

table.insert(ai.Sorts,bt)

return bt
end

addSorting("newest",nil,{
Size=UDim2.fromOffset(90,32),
On=true,
})

addSorting("oldest",nil,{
Size=UDim2.fromOffset(90,32),
On=false,
})

aj=I.Dropdown({
Name="Author",
List={"all"},
Function=function(bm)
ak:Fire(bm)
end,
Default="all",
Size=UDim2.new(0.2,0,0,40),
Visible=false,
},bg,{Options={}})
aj.Object.BackgroundTransparency=1

local bm=Instance.new"TextLabel"
bm.Parent=bg
bm.TextSize=15
bm.LayoutOrder=5
bm.TextColor3=Color3.fromRGB(200,200,200)
bm.TextTransparency=1
bm.Size=UDim2.new(0,600,1,0)
bm.BackgroundTransparency=1

ap=function(bn,bo)
task.spawn(function()
if bo~=nil then
flickerTextEffect(bm,bo,bn)
elseif bn~=nil then
bm.Text=bn
end
end)
end

if getgenv().username~=nil then
ap(`Welcome back {tostring(getgenv().username)}!`,true)
end

aq=function()
ap(`Awesome configs made by & for awesome people :D`,true)
end


bf:GetPropertyChangedSignal"Text":Connect(function()
for bn,bo in ai do
if bo and typeof(bo)=="table"and bo.instance then
bo.instance.Visible=false

if
bn:lower():gsub(" ",""):find(bf.Text:lower():gsub(" ",""),1,true)
or tostring(bo.username):lower():gsub(" ",""):find(bf.Text:lower():gsub(" ",""),1,true)
or bf.Text==""
then
bo.instance.Visible=true
end
end
end
end)

af.Event:Connect(Z)


local bn=false
aD:GetPropertyChangedSignal"Visible":Connect(function()
if not aD.Visible then
if bn then
w.Visible=true
bn=false
end
L.Visible=false
else
w.Visible=false
bn=true
end
local bo=d
if not bo.UpdateGUI then return end
bo:UpdateGUI(bo.GUIColor.Hue,bo.GUIColor.Sat,bo.GUIColor.Value)
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
aj.BackgroundColor3=p.Main
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
am.Color=n.Light(aq,0.2)
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
o:Tween(am,TweenInfo.new(0.15),{
Thickness=3
})
end)
aj.MouseLeave:Connect(function()
o:Tween(am,TweenInfo.new(0.15),{
Thickness=0
})
end)
end
return ao
end
}
end
aj.Text=""
aj.Parent=w
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
al.ImageColor3=p.Text
al.Parent=aj
local am=Instance.new"TextLabel"
am.Name="Title"
am.Size=UDim2.new(1,-(ah.Size.X.Offset>20 and 44 or 36),0,20)
am.Position=UDim2.fromOffset(math.abs(am.Size.X.Offset),12)
am.BackgroundTransparency=1
am.Text=ah.Name
am.TextXAlignment=Enum.TextXAlignment.Left
am.TextColor3=p.Text
am.TextSize=13
am.FontFace=p.Font
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
ao.Image=v"vape/assets/new/expandup.png"
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
aq.BackgroundColor3=n.Dark(p.Main,0.02)
aq.Visible=false
aq.Parent=ap
local ar=Instance.new"ImageButton"
ar.Name="Settings"
ar.Size=UDim2.fromOffset(16,16)
ar.Position=UDim2.new(1,-52,0,13)
ar.BackgroundTransparency=1
ar.AutoButtonColor=false
ar.Image=ah.Name~="Profiles"and v"vape/assets/new/customsettings.png"or v"vape/assets/new/worldicon.png"
ar.ImageColor3=n.Dark(p.Text,0.43)
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
av=I.Button({
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
aw=I.Button({
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
I.Button({
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
if E("vape/profiles/"..d.Profile..d.Place..".txt")and delfile then
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
ax.BackgroundColor3=n.Light(p.Main,0.02)
ax.Parent=ap
addCorner(ax)
local ay=ax:Clone()
ay.Size=UDim2.new(1,-2,1,-2)
ay.Position=UDim2.fromOffset(1,1)
ay.BackgroundColor3=n.Dark(p.Main,0.02)
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
az.FontFace=p.Font
az.ClearTextOnFocus=false
az.Parent=ax
local aA=Instance.new"ImageButton"
aA.Name="AddButton"
aA.Size=UDim2.fromOffset(16,16)
aA.Position=UDim2.new(1,-26,0,8)
aA.BackgroundTransparency=1
aA.Image=v"vape/assets/new/add.png"
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
if E("vape/profiles/"..aD..d.Place..".txt")and delfile then
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
local aG=Instance.new"TextButton"
aG.Name=aF.Name
aG.Size=UDim2.fromOffset(200,33)
aG.BackgroundColor3=n.Light(p.Main,0.02)
aG.AutoButtonColor=false
aG.Text=""
aG.Parent=ap
addCorner(aG)
local aH=Instance.new"UIStroke"
aH.Color=n.Light(p.Main,0.1)
aH.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
aH.Enabled=false
aH.Parent=aG
local aI=Instance.new"TextLabel"
aI.Name="Title"
aI.Size=UDim2.new(1,-10,1,0)
aI.Position=UDim2.fromOffset(10,0)
aI.BackgroundTransparency=1
aI.Text=aF.Name
aI.TextTruncate=Enum.TextTruncate.AtEnd
aI.TextXAlignment=Enum.TextXAlignment.Left
aI.TextColor3=n.Dark(p.Text,0.4)
aI.TextSize=15
aI.FontFace=p.Font
aI.Parent=aG
local aJ=Instance.new"TextButton"
aJ.Name="Dots"
aJ.Size=UDim2.fromOffset(25,33)
aJ.Position=UDim2.new(1,-25,0,0)
aJ.BackgroundTransparency=1
aJ.Text=""
aJ.Parent=aG
local aK=Instance.new"ImageLabel"
aK.Name="Dots"
aK.Size=UDim2.fromOffset(3,16)
aK.Position=UDim2.fromOffset(10,9)
aK.BackgroundTransparency=1
aK.Image=v"vape/assets/new/dots.png"
aK.ImageColor3=n.Light(p.Main,0.37)
aK.Parent=aJ
local aL=Instance.new"TextButton"
addTooltip(aL,"Click to bind")
aL.Name="Bind"
aL.Size=UDim2.fromOffset(20,21)
aL.Position=UDim2.new(1,-30,0,6)
aL.AnchorPoint=Vector2.new(1,0)
aL.BackgroundColor3=Color3.new(1,1,1)
aL.BackgroundTransparency=0.92
aL.BorderSizePixel=0
aL.AutoButtonColor=false
aL.Visible=false
aL.Text=""
addCorner(aL,UDim.new(0,4))
local aM=Instance.new"ImageLabel"
aM.Name="Icon"
aM.Size=UDim2.fromOffset(12,12)
aM.Position=UDim2.new(0.5,-6,0,5)
aM.BackgroundTransparency=1
aM.Image=v"vape/assets/new/bind.png"
aM.ImageColor3=n.Dark(p.Text,0.43)
aM.Parent=aL
local aN=Instance.new"TextLabel"
aN.Size=UDim2.fromScale(1,1)
aN.Position=UDim2.fromOffset(0,1)
aN.BackgroundTransparency=1
aN.Visible=false
aN.Text=""
aN.TextColor3=n.Dark(p.Text,0.43)
aN.TextSize=12
aN.FontFace=p.Font
aN.Parent=aL
aL.MouseEnter:Connect(function()
aN.Visible=false
aM.Visible=not aN.Visible
aM.Image=v"vape/assets/new/edit.png"
if aF.Name~=d.Profile then
aM.ImageColor3=n.Dark(p.Text,0.16)
end
end)
aL.MouseLeave:Connect(function()
aN.Visible=#aF.Bind>0
aM.Visible=not aN.Visible
aM.Image=v"vape/assets/new/bind.png"
if aF.Name~=d.Profile then
aM.ImageColor3=n.Dark(p.Text,0.43)
end
end)
local aO=Instance.new"ImageLabel"
aO.Name="Cover"
aO.Size=UDim2.fromOffset(154,33)
aO.BackgroundTransparency=1
aO.Visible=false
aO.Image=v"vape/assets/new/bindbkg.png"
aO.ScaleType=Enum.ScaleType.Slice
aO.SliceCenter=Rect.new(0,0,141,40)
aO.Parent=aG
local aP=Instance.new"TextLabel"
aP.Name="Text"
aP.Size=UDim2.new(1,-10,1,-3)
aP.BackgroundTransparency=1
aP.Text="PRESS A KEY TO BIND"
aP.TextColor3=p.Text
aP.TextSize=11
aP.FontFace=p.Font
aP.Parent=aO
aL.Parent=aG
aJ.MouseEnter:Connect(function()
if aF.Name~=d.Profile then
aK.ImageColor3=p.Text
end
end)
aJ.MouseLeave:Connect(function()
if aF.Name~=d.Profile then
aK.ImageColor3=n.Light(p.Main,0.37)
end
end)
aJ.Activated:Connect(function()
if aF.Name~=d.Profile then
ai:ChangeValue(aF.Name)
end
end)
aG.Activated:Connect(function()
d:Save(aF.Name,not E("vape/profiles/"..aF.Name..d.Place..".txt"))
d:Load(true,aF.Name)
end)
aG.MouseEnter:Connect(function()
aL.Visible=true
if aF.Name~=d.Profile then
aH.Enabled=true
aI.TextColor3=n.Dark(p.Text,0.16)
end
end)
aG.MouseLeave:Connect(function()
aL.Visible=#aF.Bind>0
if aF.Name~=d.Profile then
aH.Enabled=false
aI.TextColor3=n.Dark(p.Text,0.4)
end
end)

local function bindFunction(aQ,aR,aS)
aF.Bind=table.clone(aR)
if aS then
aP.Text=#aR<=0 and"BIND REMOVED"
or"BOUND TO "..table.concat(aR," + "):upper()
aO.Size=
UDim2.fromOffset(F(aP.Text,aP.TextSize).X+20,40)
task.delay(1,function()
aO.Visible=false
end)
end

if#aR<=0 then
aN.Visible=false
aM.Visible=true
aL.Size=UDim2.fromOffset(20,21)
else
aL.Visible=true
aN.Visible=true
aM.Visible=false
aN.Text=table.concat(aR," + "):upper()
aL.Size=UDim2.fromOffset(
math.max(F(aN.Text,aN.TextSize,aN.Font).X+10,20),
21
)
end
end

bindFunction({},aF.Bind)
aL.Activated:Connect(function()
aP.Text="PRESS A KEY TO BIND"
aO.Size=
UDim2.fromOffset(F(aP.Text,aP.TextSize).X+20,40)
aO.Visible=true
d.Binding={SetBind=bindFunction,Bind=aF.Bind}
end)
if aF.Name==d.Profile then
aC.Selected=aG
end
table.insert(aC.Objects,aG)
else
local aG=table.find(aC.ListEnabled,aF)
local aH=Instance.new"TextButton"
aH.Name=aF
aH.Size=UDim2.fromOffset(200,32)
aH.BackgroundColor3=n.Light(p.Main,0.02)
aH.AutoButtonColor=false
aH.Text=""
aH.Parent=ap
addCorner(aH)
local aI=Instance.new"Frame"
aI.Name="BKG"
aI.Size=UDim2.new(1,-2,1,-2)
aI.Position=UDim2.fromOffset(1,1)
aI.BackgroundColor3=p.Main
aI.Visible=false
aI.Parent=aH
addCorner(aI)
local aJ=Instance.new"Frame"
aJ.Name="Dot"
aJ.Size=UDim2.fromOffset(10,11)
aJ.Position=UDim2.fromOffset(10,12)
aJ.BackgroundColor3=aG and ah.Color or n.Light(p.Main,0.37)
aJ.Parent=aH
addCorner(aJ,UDim.new(1,0))
local aK=aJ:Clone()
aK.Size=UDim2.fromOffset(8,9)
aK.Position=UDim2.fromOffset(1,1)
aK.BackgroundColor3=aG and ah.Color or n.Light(p.Main,0.02)
aK.Parent=aJ
local aL=Instance.new"TextLabel"
aL.Name="Title"
aL.Size=UDim2.new(1,-30,1,0)
aL.Position=UDim2.fromOffset(30,0)
aL.BackgroundTransparency=1
aL.Text=aF
aL.TextXAlignment=Enum.TextXAlignment.Left
aL.TextColor3=n.Dark(p.Text,0.16)
aL.TextSize=15
aL.FontFace=p.Font
aL.Parent=aH
if d.ThreadFix then
setthreadidentity(8)
end
local aM=Instance.new"ImageButton"
aM.Name="Close"
aM.Size=UDim2.fromOffset(16,16)
aM.Position=UDim2.new(1,-23,0,8)
aM.BackgroundColor3=Color3.new(1,1,1)
aM.BackgroundTransparency=1
aM.AutoButtonColor=false
aM.Image=v"vape/assets/new/closemini.png"
aM.ImageColor3=n.Light(p.Text,0.2)
aM.ImageTransparency=0.5
aM.Parent=aH
addCorner(aM,UDim.new(1,0))
aM.MouseEnter:Connect(function()
aM.ImageTransparency=0.3
o:Tween(aM,p.Tween,{
BackgroundTransparency=0.6,
})
end)
aM.MouseLeave:Connect(function()
aM.ImageTransparency=0.5
o:Tween(aM,p.Tween,{
BackgroundTransparency=1,
})
end)
aM.Activated:Connect(function()
ai:ChangeValue(aF)
end)
aH.MouseEnter:Connect(function()
aI.Visible=true
end)
aH.MouseLeave:Connect(function()
aI.Visible=false
end)
aH.Activated:Connect(function()
local aN=table.find(aC.ListEnabled,aF)
if aN then
table.remove(aC.ListEnabled,aN)
aJ.BackgroundColor3=n.Light(p.Main,0.37)
aK.BackgroundColor3=n.Light(p.Main,0.02)
else
table.insert(aC.ListEnabled,aF)
aJ.BackgroundColor3=ah.Color
aK.BackgroundColor3=ah.Color
end
ah.Function()
end)
table.insert(aC.Objects,aH)
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
aC.Expanded and math.min(51+at.AbsoluteContentSize.Y/B.Scale,611)or 45
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

for aC,aD in I do
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
o:Tween(ax,p.Tween,{
BackgroundColor3=n.Light(p.Main,0.14),
})
end)
az.MouseLeave:Connect(function()
o:Tween(ax,p.Tween,{
BackgroundColor3=n.Light(p.Main,0.02),
})
end)
ap:GetPropertyChangedSignal"CanvasPosition":Connect(function()
as.Visible=ap.CanvasPosition.Y>10 and ap.Visible
end)
ar.MouseEnter:Connect(function()
ar.ImageColor3=p.Text
end)
ar.MouseLeave:Connect(function()
ar.ImageColor3=n.Light(p.Main,0.37)
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
ap.CanvasSize=UDim2.fromOffset(0,at.AbsoluteContentSize.Y/B.Scale)
if ai.Expanded then
aj.Size=UDim2.fromOffset(220,math.min(51+at.AbsoluteContentSize.Y/B.Scale,611))
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
o:Tween(ah,TweenInfo.new(0.5),{
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
ah.BackgroundColor3=n.Dark(p.Main,0.02)
ah.Parent=w
local ai=Instance.new"UIScale"
ai.Parent=ah
ai.Scale=1

ah.MouseEnter:Connect(function()
o:Tween(ai,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
Scale=1.15
})
end)
ah.MouseLeave:Connect(function()
o:Tween(ai,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
Scale=1
})
end)

local aj=Instance.new"ImageLabel"
aj.Name="Icon"
aj.Size=UDim2.fromOffset(14,14)
aj.Position=UDim2.new(1,-23,0,11)
aj.BackgroundTransparency=1
aj.Image=v"vape/assets/new/search.png"
aj.ImageColor3=n.Light(p.Main,0.37)
aj.Parent=ah
local ak=Instance.new"ImageButton"
ak.Name="Legit"
ak.Size=UDim2.fromOffset(29,16)
ak.Position=UDim2.fromOffset(8,11)
ak.BackgroundTransparency=1
ak.Image=v"vape/assets/new/legit.png"
ak.Parent=ah
local al=Instance.new"Frame"
al.Name="LegitDivider"
al.Size=UDim2.fromOffset(2,12)
al.Position=UDim2.fromOffset(43,13)
al.BackgroundColor3=n.Light(p.Main,0.14)
al.BorderSizePixel=0
al.Parent=ah
addBlur(ah)
addCorner(ah)
local am=Instance.new"TextBox"
am.Size=UDim2.new(1,-50,0,37)
am.Position=UDim2.fromOffset(50,0)
am.BackgroundTransparency=1
am.Text=""
am.PlaceholderText=""
am.TextXAlignment=Enum.TextXAlignment.Left
am.TextColor3=p.Text
am.TextSize=12
am.FontFace=p.Font
am.ClearTextOnFocus=false
am.Parent=ah
local an=Instance.new"ScrollingFrame"
an.Name="Children"
an.Size=UDim2.new(1,0,1,-37)
an.Position=UDim2.fromOffset(0,34)
an.BackgroundTransparency=1
an.BorderSizePixel=0
an.ScrollBarThickness=2
an.ScrollBarImageTransparency=0.75
an.CanvasSize=UDim2.new()
an.Parent=ah
local ao=Instance.new"Frame"
ao.Name="Divider"
ao.Size=UDim2.new(1,0,0,1)
ao.Position=UDim2.fromOffset(0,33)
ao.BackgroundColor3=Color3.new(1,1,1)
ao.BackgroundTransparency=0.928
ao.BorderSizePixel=0
ao.Visible=false
ao.Parent=ah
local ap=Instance.new"UIListLayout"
ap.SortOrder=Enum.SortOrder.LayoutOrder
ap.HorizontalAlignment=Enum.HorizontalAlignment.Center
ap.Parent=an

an:GetPropertyChangedSignal"CanvasPosition":Connect(function()
ao.Visible=an.CanvasPosition.Y>10 and an.Visible
end)
ak.Activated:Connect(function()
w.Visible=false
ag.Legit.Window.Visible=true
ag.Legit.Window.Position=UDim2.new(0.5,-350,0.5,-194)
end)






































local aq=false
local ar
am:GetPropertyChangedSignal"Text":Connect(function()
if ar~=nil then
pcall(function()
task.cancel(ar)
end)
ar=nil
end
for as,at in an:GetChildren()do
if at:IsA"TextButton"then
at:Destroy()
end
end
if am.Text=="Type to search..."then
return
end
if am.Text==""then
if not aq then
flickerTextEffect(am,true,"Type to search...")
end
return
end

ar=task.spawn(function()
for as,at in ag.Modules do
if not(at.Object~=nil and at.Object.Parent~=nil and at.Object:FindFirstChild"Bind")then continue end
local au=am.Text:lower()
au=removeSpaces(au)

local av
local aw

local ax=at.Name:lower()
local ay=removeSpaces(ax):find(au)

if ay then
aw=ay
end

if not aw and at.SearchKeys then
for az,aA in ipairs(at.SearchKeys)do
local aB=aA:lower():find(au)
if aB then
av=aA
break
end
end
end

if aw or av then
local az=at.Object:Clone()
az.RichText=true















local function highlight(aA)
return highlightIgnoringSpaces(aA,au)
end

if aw then
az.Text="            "..highlight(at.Name)
else
local aA=highlight(av)

local aB=math.floor(az.TextSize*0.8)

az.Text="            "
..`<font size="{aB}" color="#AAAAAA">{at.Name}</font> `
..aA
end

az.Bind:Destroy()
az.Activated:Connect(function()
at:Toggle()
end)

az.MouseButton2Click:Connect(function()
at.Object.Parent.Parent.Visible=true
local aA=at.Object.Parent
createHighlight(at.Object)
local aB=at.ModuleCategory
if aB~=nil then

aB:Toggle(true)
end
local aC=at.CategoryApi
if aC~=nil then

aC:ToggleCategoryButton(true)
end

o:Tween(aA,TweenInfo.new(0.5),{
CanvasPosition=Vector2.new(
0,
(at.Object.LayoutOrder*40)-(math.min(aA.CanvasSize.Y.Offset,600)/2)
),
})
end)

az.Parent=an
az.Name=as:lower()













end
end
end)
end)
am.Focused:Connect(function()
aq=true
if am.Text=="Type to search..."then
am.Text=""
end
end)
d.VisibilityChanged:Connect(function()
if not aq and w.Visible then
flickerTextEffect(am,true,"Type to search...")
end
end)
am.FocusLost:Connect(function()
aq=false
if am.Text==""then
flickerTextEffect(am,true,"Type to search...")
end
end)
ap:GetPropertyChangedSignal"AbsoluteContentSize":Connect(function()
if ag.ThreadFix then
setthreadidentity(8)
end
an.CanvasSize=UDim2.fromOffset(0,ap.AbsoluteContentSize.Y/B.Scale)
ah.Size=UDim2.fromOffset(220,math.min(37+ap.AbsoluteContentSize.Y/B.Scale,437))
end)
d.PreloadEvent:Connect(function()
flickerTextEffect(am,true,"Type to search...")
end)

ag.Legit.Icon=ak
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
aj.BackgroundColor3=p.Main
aj.Visible=false
aj.Parent=x
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
al.Image=v"vape/assets/new/legittab.png"
al.ImageColor3=p.Text
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
at.LegitSynced=true
local au=ai:CreateModule(at)

local av=Instance.new"TextButton"
av.Name=aq.Name
av.BackgroundColor3=n.Light(p.Main,0.02)
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
aw.TextColor3=n.Dark(p.Text,0.31)
aw.TextSize=13
aw.FontFace=p.Font
aw.Parent=av

local ax=Instance.new"Frame"
ax.Name="Knob"
ax.Size=UDim2.fromOffset(22,12)
ax.Position=UDim2.new(1,-57,0,14)
ax.BackgroundColor3=n.Light(p.Main,0.14)
ax.Parent=av
addCorner(ax,UDim.new(1,0))

local ay=ax:Clone()
ay.Size=UDim2.fromOffset(8,8)
ay.Position=UDim2.fromOffset(2,2)
ay.BackgroundColor3=p.Main
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
aA.Image=v"vape/assets/new/dots.png"
aA.ImageColor3=n.Light(p.Main,0.37)
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
aC.BackgroundColor3=p.Main
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
aD.TextColor3=n.Dark(p.Text,0.16)
aD.TextSize=13
aD.FontFace=p.Font
aD.Parent=aC

local aE=Instance.new"ImageButton"
aE.Name="Back"
aE.Size=UDim2.fromOffset(16,16)
aE.Position=UDim2.fromOffset(11,13)
aE.BackgroundTransparency=1
aE.Image=v"vape/assets/new/back.png"
aE.ImageColor3=n.Light(p.Main,0.37)
aE.Parent=aC
addCorner(aC)

local aF=Instance.new"ScrollingFrame"
aF.Name="Children"
aF.Size=UDim2.new(1,0,1,-45)
aF.Position=UDim2.fromOffset(0,41)
aF.BackgroundColor3=p.Main
aF.BorderSizePixel=0
aF.ScrollBarThickness=2
aF.ScrollBarImageTransparency=0.75
aF.CanvasSize=UDim2.new()
aF.Parent=aC

local aG=Instance.new"UIListLayout"
aG.SortOrder=Enum.SortOrder.LayoutOrder
aG.HorizontalAlignment=Enum.HorizontalAlignment.Center
aG.Parent=aF

if aq.Size then
local aH=Instance.new"Frame"
aH.Size=aq.Size
aH.BackgroundTransparency=1
aH.Visible=false
aH.Parent=x
makeDraggable(aH,aj)
local aI=Instance.new"UIStroke"
aI.Color=Color3.fromRGB(5,134,105)
aI.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
aI.Thickness=0
aI.Parent=aH
ar.Children=aH
end

aq.Function=aq.Function or function()end
addMaid(ar)

function ar.Toggle(aH)
if aH._syncing then
return
end

aH._syncing=true
ar.Enabled=not ar.Enabled

if ar.Children then
ar.Children.Visible=ar.Enabled
end


if au and au.Enabled~=ar.Enabled then
au._syncing=true
au:Toggle()
au._syncing=false
end

aw.TextColor3=ar.Enabled and n.Light(p.Text,0.2)or n.Dark(p.Text,0.31)
av.BackgroundColor3=ar.Enabled and n.Light(p.Main,0.05)
or n.Light(p.Main,0.02)

o:Tween(ax,p.Tween,{
BackgroundColor3=ar.Enabled
and Color3.fromHSV(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
or n.Light(p.Main,0.14),
})
o:Tween(ay,p.Tween,{
Position=UDim2.fromOffset(ar.Enabled and 12 or 2,2),
})

if not ar.Enabled then
for aI,aJ in ar.Connections do
aJ:Disconnect()
end
table.clear(ar.Connections)
end

aH._syncing=false
task.spawn(aq.Function,ar.Enabled)
end

local function createSyncedOption(
aH,
aI,
aJ,
aK,
aL,
aM
)

local aN=aH(aI,aJ,aL)
local aO=aH(table.clone(aI),aK,aM)


aN._syncing=false
aO._syncing=false


local aP={"ChangeValue","Color","SetValue","Toggle","ConnectCallback","SetValues"}


for aQ,aR in aP do
if aN[aR]and type(aN[aR])=="function"then
local aS=aN[aR]
aN[aR]=function(aT,...)

if aT._syncing then
return aS(aT,...)
end

aT._syncing=true
local aU={...}
local aV=aS(aT,unpack(aU))


if
aO[aR]
and type(aO[aR])=="function"
and not aO._syncing
then
pcall(function()
aO._syncing=true
aO[aR](aO,unpack(aU))
aO._syncing=false
end)
end

aT._syncing=false
return aV
end
end
end


for aQ,aR in aP do
if aO[aR]and type(aO[aR])=="function"then
local aS=aO[aR]
aO[aR]=function(aT,...)

if aT._syncing then
return aS(aT,...)
end

aT._syncing=true
local aU={...}
local aV=aS(aT,unpack(aU))


if
aN[aR]
and type(aN[aR])=="function"
and not aN._syncing
then
pcall(function()
aN._syncing=true
aN[aR](aN,unpack(aU))
aN._syncing=false
end)
end

aT._syncing=false
return aV
end
end
end


for aQ,aR in{"Load","Save"}do
if aN[aR]and type(aN[aR])=="function"then
local aS=aN[aR]
aN[aR]=function(aT,...)

return aS(aT,...)
end
end
end


aN.CategoryComponent=aO
aO.LegitComponent=aN

return aN
end


for aH,aI in I do
ar["Create"..aH]=function(aJ,aK)
return createSyncedOption(
aI,
aK,
aF,
au.Children,
ar,
au
)
end
ar["Add"..aH]=ar["Create"..aH]
end


for aH,aI in I do
ar["Create"..aH]=function(aJ,aK)
return createSyncedOption(
aI,
aK,
aF,
au.Children,
ar,
au
)
end
ar["Add"..aH]=ar["Create"..aH]
end


aE.MouseEnter:Connect(function()
aE.ImageColor3=p.Text
end)
aE.MouseLeave:Connect(function()
aE.ImageColor3=n.Light(p.Main,0.37)
end)
aE.Activated:Connect(function()
o:Tween(aB,p.Tween,{
BackgroundTransparency=1,
})
o:Tween(aC,p.Tween,{
Position=UDim2.fromScale(1,0),
})
task.wait(0.2)
aB.Visible=false
end)

az.Activated:Connect(function()
aB.Visible=true
o:Tween(aB,p.Tween,{
BackgroundTransparency=0.5,
})
o:Tween(aC,p.Tween,{
Position=UDim2.new(1,-220,0,0),
})
end)

az.MouseEnter:Connect(function()
aA.ImageColor3=p.Text
end)
az.MouseLeave:Connect(function()
aA.ImageColor3=n.Light(p.Main,0.37)
end)

av.MouseEnter:Connect(function()
if not ar.Enabled then
av.BackgroundColor3=n.Light(p.Main,0.05)
end
end)
av.MouseLeave:Connect(function()
if not ar.Enabled then
av.BackgroundColor3=n.Light(p.Main,0.02)
end
end)

av.Activated:Connect(function()
ar:Toggle()
end)

av.MouseButton2Click:Connect(function()
aB.Visible=true
o:Tween(aB,p.Tween,{
BackgroundTransparency=0.5,
})
o:Tween(aC,p.Tween,{
Position=UDim2.new(1,-220,0,0),
})
end)

aB.Activated:Connect(function()
o:Tween(aB,p.Tween,{
BackgroundTransparency=1,
})
o:Tween(aC,p.Tween,{
Position=UDim2.fromScale(1,0),
})
task.wait(0.2)
aB.Visible=false
end)

aG:GetPropertyChangedSignal"AbsoluteContentSize":Connect(function()
if d.ThreadFix then
setthreadidentity(8)
end
aF.CanvasSize=UDim2.fromOffset(0,aG.AbsoluteContentSize.Y/B.Scale)
end)

ar.Object=av
ar.LegitTabModule=ar
au.LegitTabModule=ar
au._syncing=false

ah.Modules[aq.Name]=ar


local aH={}
for aI,aJ in ah.Modules do
table.insert(aH,aJ.Name)
end
table.sort(aH)

for aI,aJ in aH do
ah.Modules[aJ].Object.LayoutOrder=aI
end

return ar
end

local function visibleCheck()
for ap,aq in ah.Modules do
if aq.Children then
local ar=w.Visible
for as,at in ag.Windows do
ar=ar or at.Visible
end
aq.Children.Visible=(not ar or aj.Visible)and aq.Enabled
end
end
end

am.Activated:Connect(function()
aj.Visible=false
w.Visible=true
end)

ag:Clean(w:GetPropertyChangedSignal"Visible":Connect(visibleCheck))
aj:GetPropertyChangedSignal"Visible":Connect(function()
ag:UpdateGUI(ag.GUIColor.Hue,ag.GUIColor.Sat,ag.GUIColor.Value)
visibleCheck()
end)

ao:GetPropertyChangedSignal"AbsoluteContentSize":Connect(function()
if ag.ThreadFix then
setthreadidentity(8)
end
an.CanvasSize=UDim2.fromOffset(0,ao.AbsoluteContentSize.Y/B.Scale)
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
local am=#r:GetChildren()+1
local an=Instance.new"ImageLabel"
an.Name="Notification"
an.Size=UDim2.fromOffset(math.max(F(removeTags(ai),14,p.Font).X+80,266),75)
an.Position=UDim2.new(1,0,1,-(29+(78*am)))
an.ZIndex=5
an.BackgroundTransparency=1
an.Image=v"vape/assets/new/notification.png"
an.ScaleType=Enum.ScaleType.Slice
an.SliceCenter=Rect.new(7,7,9,9)
an.Parent=r
addBlur(an,true)
local ao=Instance.new"ImageLabel"
ao.Name="Icon"
ao.Size=UDim2.fromOffset(60,60)
ao.Position=UDim2.fromOffset(-5,-8)
ao.ZIndex=5
ao.BackgroundTransparency=1
ao.Image=v("vape/assets/new/"..(al or"info")..".png")
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
aq.FontFace=p.FontSemiBold
aq.Parent=an
local ar=aq:Clone()
ar.Name="Text"
ar.Position=UDim2.fromOffset(47,44)
ar.Text=removeTags(ai)
ar.TextColor3=Color3.new()
ar.TextTransparency=0.5
ar.RichText=true
ar.FontFace=p.Font
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
if o.Tween then
o:Tween(an,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{
AnchorPoint=Vector2.new(1,0),
},o.tweenstwo)
o:Tween(at,TweenInfo.new(aj,Enum.EasingStyle.Linear),{
Size=UDim2.fromOffset(0,2),
})
end
task.delay(aj,function()
if o.Tween then
o:Tween(an,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{
AnchorPoint=Vector2.new(0,0),
},o.tweenstwo)
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
aw.Image=v"vape/assets/new/notification.png"
aw.ScaleType=Enum.ScaleType.Slice
aw.SliceCenter=Rect.new(7,7,9,9)
aw.Parent=t

local ax=Instance.new"UIScale"
ax.Scale=1
ax.Parent=aw

aw.MouseEnter:Connect(function()
o:Tween(ax,TweenInfo.new(0.15),{
Scale=1.05,
})
end)

aw.MouseLeave:Connect(function()
o:Tween(ax,TweenInfo.new(0.15),{
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
ay.FontFace=p.Font
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
az.FontFace=p.FontSemiBold
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
aA.FontFace=p.Font
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
aC.FontFace=p.FontSemiBold
aC.ZIndex=22
aC.Parent=aB
addCorner(aC)


local aD=aC:Clone()
aD.BackgroundColor3=ao
aD.Position=UDim2.new(0.5,6,0,0)
aD.Text=am
aD.Parent=aB

local function hover(aE,aF,aG,aH)
o:Tween(aE,TweenInfo.new(0.15),{
BackgroundColor3=aH and aF or aG,
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

if o.Tween then
o:Tween(aw,TweenInfo.new(0.25,Enum.EasingStyle.Exponential),{
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


if o.Tween then
aw.Size=UDim2.fromOffset(340,160)
o:Tween(aw,TweenInfo.new(0.35,Enum.EasingStyle.Exponential),{
Size=UDim2.fromOffset(360,180),
},o.tweenstwo)
end
end)
end

function d.Load(ah,ai,aj)
if not ah._profile_loaded then
ah.PreloadEvent:Fire()
end
ah._loading=ah._loading or 0
ah._loading+=1




ah._profile_loaded=true
if not ai then
ah.GUIColor:SetValue(nil,nil,nil,4)
end
local ak={}
local al=true

local am="vape/profiles/"..str(game.GameId).."_"..str(ah.Place)..".gui.txt"
if not E(am)then
am="vape/profiles/"..str(game.GameId)..".gui.txt"
end
if E(am)then
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
F(ah.ProfileLabel.Text,ah.ProfileLabel.TextSize,ah.ProfileLabel.Font).X+16,
24
)
end

local an=E("vape/profiles/"..ah.Profile..ah.Place..".txt")

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
if ar.LegitSynced then continue end
if ar.NoSave then continue end



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
y.Visible=false
w.Visible=true
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
ao.Parent=C
local ap=Instance.new"ImageLabel"
ap.Size=UDim2.fromOffset(26,26)
ap.Position=UDim2.fromOffset(3,3)
ap.BackgroundTransparency=1
ap.Image=v"vape/assets/new/vape.png"
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
as.Bind.Button.Visible=w.Visible
end
end
w.Visible=not w.Visible
A.Visible=false
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
w.Visible=false
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

C=Instance.new"ScreenGui"
C.Name=randomString()
C.DisplayOrder=9999999
C.ZIndexBehavior=Enum.ZIndexBehavior.Global
C.IgnoreGuiInset=true
pcall(function()
C.OnTopOfCoreBlur=true
end)



C.Parent=e(game:GetService"Players").LocalPlayer.PlayerGui
C.ResetOnSpawn=false

d.gui=C
x=Instance.new"Frame"
x.Name="ScaledGui"
x.Size=UDim2.fromScale(1,1)
x.BackgroundTransparency=1
x.Parent=C
w=Instance.new"Frame"
w.Name="ClickGui"
w.Size=UDim2.fromScale(1,1)
w.BackgroundTransparency=1
w.Visible=false
w.Parent=x
d:Clean(w:GetPropertyChangedSignal"Visible":Connect(function()
d.VisibilityChanged:Fire(w.Visible)
end))
local ah=Instance.new"TextLabel"
ah.Size=UDim2.fromScale(1,0.02)
ah.Position=UDim2.fromScale(0,0.97)
ah.BackgroundTransparency=1
ah.Text="discord.gg/voidware"
ah.TextScaled=true
ah.TextColor3=Color3.new(1,1,1)
ah.TextStrokeTransparency=0.5
ah.FontFace=p.Font
ah.Parent=w
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
o:Tween(ai.label,TweenInfo.new(1.5),{
TextSize=30,
Position=UDim2.fromScale(0.5,0.6)
})
ai:setText"Welcome to Voidware!"
ai.label.Parent=x
end,
tweenToSecondPosition=function(ai)
if not ai.isActive then return end
ai.GlobeIconWait=false
o:Tween(ai.label,TweenInfo.new(1.5),{
Position=UDim2.fromScale(0.5,0.78)
})
end,
revertTutorialMode=function(ai,aj)
ai:cleanTutorialLabel()
ai.GlobeIconWait=false
ai.isActive=false
ai.label.TextScaled=true
ai.label.AutomaticSize=Enum.AutomaticSize.None
o:Tween(ai.label,TweenInfo.new(0.5),{
Position=UDim2.fromScale(0.5,0.97)
}).Completed:Connect(function()
ai:setText(ai.defaultText)
ai.label.Parent=w
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
if d.TutorialAPI.isActive and d.TutorialAPI.GlobeIconWait and not y.Visible then
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
ai.Parent=w
local aj=Instance.new"ImageLabel"
aj.Size=UDim2.fromOffset(64,64)
aj.BackgroundTransparency=1
aj.Visible=false
aj.Image="rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png"
aj.Parent=C
r=Instance.new"Folder"
r.Name="Notifications"
r.Parent=x
t=Instance.new"Folder"
t.Name="Prompts"
t.Parent=x








A=Instance.new"TextLabel"
A.Name="Tooltip"
A.Position=UDim2.fromScale(-1,-1)
A.ZIndex=5
A.BackgroundColor3=n.Dark(p.Main,0.02)
A.Visible=false
A.Text=""
A.TextColor3=n.Dark(p.Text,0.16)
A.TextSize=15
A.FontFace=p.Font
A.Parent=x
z=addBlur(A)
addCorner(A)
local ak=Instance.new"Frame"
ak.Size=UDim2.new(1,-2,1,-2)
ak.Position=UDim2.fromOffset(1,1)
ak.ZIndex=6
ak.BackgroundTransparency=1
ak.Parent=A
local al=Instance.new"UIStroke"
al.Color=n.Light(p.Main,0.02)
al.Parent=ak
addCorner(ak,UDim.new(0,4))
B=Instance.new"UIScale"
B.Scale=math.max(C.AbsoluteSize.X/1920,0.6)
B.Parent=x
d.guiscale=B
x.Size=UDim2.fromScale(1/B.Scale,1/B.Scale)

d:Clean(C:GetPropertyChangedSignal"AbsoluteSize":Connect(function()
if d.Scale.Enabled then
B.Scale=math.max(C.AbsoluteSize.X/1920,0.6)
end
end))

d:Clean(B:GetPropertyChangedSignal"Scale":Connect(function()
x.Size=UDim2.fromScale(1/B.Scale,1/B.Scale)
for am,an in x:GetDescendants()do
if an:IsA"GuiObject"and an.Visible then
an.Visible=false
an.Visible=true
end
end
end))

d:Clean(w:GetPropertyChangedSignal"Visible":Connect(function()
d:UpdateGUI(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value,true)
if w.Visible and h.MouseEnabled then
repeat
local am=w.Visible
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
G(function()
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
end,5)
am:CreateButton{
Name="Reset current profile",
Function=function()
d.Save=function()end
if E("vape/profiles/"..d.Profile..d.Place..".txt")and delfile then
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
Icon=v"vape/assets/new/combaticon.png",
Size=UDim2.fromOffset(13,14),
Visible=true,
}
d:CreateCategory{
Name="Blatant",
Icon=v"vape/assets/new/blatanticon.png",
Size=UDim2.fromOffset(14,14),
Visible=true,
}
d:CreateCategory{
Name="Render",
Icon=v"vape/assets/new/rendericon.png",
Size=UDim2.fromOffset(15,14),
Visible=true,
}
d:CreateCategory{
Name="Utility",
Icon=v"vape/assets/new/utilityicon.png",
Size=UDim2.fromOffset(15,14),
Visible=true,
}
d:CreateCategory{
Name="World",
Icon=v"vape/assets/new/worldicon.png",
Size=UDim2.fromOffset(14,14),
Visible=true,
}
for an,ao in{
{
Name="Inventory",
Icon=v"vape/assets/new/inventoryicon.png",
Size=UDim2.fromOffset(15,14),
GuiColorSync=true,
},
{
Name="Minigames",
Icon=v"vape/assets/new/miniicon.png",
Size=UDim2.fromOffset(19,12),
GuiColorSync=true,
}
}do
d.Categories[ao.Name]=d.Categories.World:CreateModuleCategory(ao)
end
d:CreateCategory{
Name="Legit",
Icon=v"vape/assets/new/legittab.png",
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
Icon=v"vape/assets/new/friendstab.png",
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
if av and av.BackgroundColor3~=n.Light(p.Main,0.37)then
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
Icon=v"vape/assets/new/profilesicon.png",
Size=UDim2.fromOffset(17,10),
Position=UDim2.fromOffset(12,16),
Placeholder="Type name",
Profiles=true,
}

d:connectOnLoad(function(aq)
if aq.NewUser then
task.spawn(function()
task.wait(1.5)
if w.Visible then
w.Visible=false
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
o:Tween(ar.scale,TweenInfo.new(0.15),{
Scale=1.1
})
o:Tween(ar.stroke,TweenInfo.new(0.15),{
Thickness=3
})
ar.window.MouseLeave:Once(function()
o:Tween(ar.scale,TweenInfo.new(0.15),{
Scale=1
})
end)
w.Visible=true
task.delay(0.1,function()
d.TutorialAPI.GlobeIconWait=true
d.TutorialAPI:setText"Click on the globe icon to open the configs window"
flickerImageEffect(ar.globeicon,5,0.22)
end)
end
end,
OnCancel=function()
w.Visible=true
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
Icon=v"vape/assets/new/friendstab.png",
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
Icon=v"vape/assets/new/overlaysicon.png",
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
local av=o:Tween(au,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
Size=UDim2.fromOffset(220,ar.Expanded and 0 or 40),
TextTransparency=ar.Expanded and 1 or 0,
})
if ar.Expanded then
av.Completed:Once(function()
au.Visible=false
end)
end
elseif au:IsA"TextLabel"and not au.Name:lower():find"overlays"then
o:Tween(au,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
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
o:Tween(av,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
TextTransparency=ar.Expanded and 1 or 0
})
end
local aw=au.Object:FindFirstChild"Icon"
if aw then
o:Tween(aw,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
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
local ax=o:Tween(au.Object,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
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
A.Visible=false
z.Visible=au
end,
Default=true,
Tooltip="Toggles visibility of these",
}
at:CreateToggle{
Name="Show legit mode",
Function=function(au)
w.Search.Legit.Visible=au
w.Search.LegitDivider.Visible=au
w.Search.TextBox.Size=UDim2.new(1,au and-50 or-10,0,37)
w.Search.TextBox.Position=UDim2.fromOffset(au and 50 or 10,0)
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
B.Scale=math.max(C.AbsoluteSize.X/1920,0.6)
else
B.Scale=au.Value
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
B.Scale=av
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
A.TextSize=av
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
Icon=v"vape/assets/new/textguiicon.png",
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
local aG=aw:CreateToggle{
Name="Watermark",
Tooltip="Renders a vape watermark",
Default=true,
NoDefaultCallback=true,
Function=function()
d:UpdateTextGUI()
end,
}
local aH={
Value=0.5,
Object={Visible={}},
}
local aI={Enabled=false}
local aJ=aw:CreateToggle{
Name="Render background",
Default=true,
NoDefaultCallback=true,
Function=function(aJ)
aH.Object.Visible=aJ
aI.Object.Visible=aJ
d:UpdateTextGUI()
end,
}
aH=aw:CreateSlider{
Name="Transparency",
Min=0,
Max=1,
Default=0.6,
Decimal=10,
Function=function()
d:UpdateTextGUI()
end,
Darker=true,
Visible=aJ.Enabled
}
aI=aw:CreateToggle{
Name="Tint",
Function=function()
d:UpdateTextGUI()
end,
Default=true,
NoDefaultCallback=true,
Darker=true,
Visible=aJ.Enabled
}
local aK
local aL=aw:CreateToggle{
Name="Hide modules",
Tooltip="Allows you to blacklist certain modules from being shown.",
Function=function(aL)
aK.Object.Visible=aL
d:UpdateTextGUI()
end,
}
aK=aw:CreateTextList{
Name="Blacklist",
Tooltip="Name of module to hide.",
Icon=v"vape/assets/new/blockedicon.png",
Tab=v"vape/assets/new/blockedtab.png",
TabSize=UDim2.fromOffset(21,16),
Color=Color3.fromRGB(250,50,56),
Function=function()
d:UpdateTextGUI()
end,
Visible=false,
Darker=true,
}
local aM=aw:CreateToggle{
Name="Hide render",
Function=function()
d:UpdateTextGUI()
end,
}
local aN
local aO
local aP
local aQ
local aR=aw:CreateToggle{
Name="Add custom text",
Function=function(aR)
aN.Object.Visible=aR
aO.Object.Visible=aR
aP.Object.Visible=aR
aQ.Object.Visible=aP.Enabled and aR
d:UpdateTextGUI()
end,
}
aN=aw:CreateTextBox{
Name="Custom text",
Function=function()
d:UpdateTextGUI()
end,
Darker=true,
Visible=false,
}
d.settextguicustomtext=function(aS)
aR:SetValue(true)
aJ:SetValue(aS)
end
aO=aw:CreateFont{
Name="Custom Font",
Blacklist="Arial",
Function=function()
d:UpdateTextGUI()
end,
Darker=true,
Visible=false,
}
aP=aw:CreateToggle{
Name="Set custom text color",
Function=function(aS)
aQ.Object.Visible=aS
d:UpdateGUI(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
end,
Darker=true,
Visible=false,
}
aQ=aw:CreateColorSlider{
Name="Color of custom text",
Function=function()
d:UpdateGUI(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value)
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
aT.Image=v"vape/assets/new/textvape.png"
aT.Parent=aw.Children

local aU=aw.Children.AbsolutePosition.X>(C.AbsoluteSize.X/2)
d:Clean(aw.Children:GetPropertyChangedSignal"AbsolutePosition":Connect(function()
if d.ThreadFix then
setthreadidentity(8)
end
local aV=aw.Children.AbsolutePosition.X>(C.AbsoluteSize.X/2)
if aU~=aV then
aU=aV
d:UpdateTextGUI()
end
end))

local aV=Instance.new"ImageLabel"
aV.Name="Logo2"
aV.Size=UDim2.fromOffset(33,18)
aV.Position=UDim2.new(1,1,0,1)
aV.BackgroundColor3=Color3.new()
aV.BackgroundTransparency=1
aV.BorderSizePixel=0
aV.Image=v"vape/assets/new/textv4.png"
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
a_.Parent=aw.Children
aZ.Parent=aw.Children
local a0=Instance.new"Frame"
a0.Name="Holder"
a0.Size=UDim2.fromScale(1,1)
a0.Position=UDim2.fromOffset(5,37)
a0.BackgroundTransparency=1
a0.Parent=aw.Children
local a1=Instance.new"UIListLayout"
a1.HorizontalAlignment=Enum.HorizontalAlignment.Right
a1.VerticalAlignment=Enum.VerticalAlignment.Top
a1.SortOrder=Enum.SortOrder.LayoutOrder
a1.Parent=a0





local a2
local a3
local a4
a3=d:CreateOverlay{
Name="Target Info",
Icon=v"vape/assets/new/targetinfoicon.png",
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
a5.BackgroundColor3=n.Dark(p.Main,0.1)
a5.BackgroundTransparency=0.5
a5.Parent=a3.Children
local a7=addBlur(a5)
a7.Visible=false
addCorner(a5)
local a8=Instance.new"ImageLabel"
a8.Size=UDim2.fromOffset(26,27)
a8.Position=UDim2.fromOffset(19,17)
a8.BackgroundColor3=p.Main
a8.Image="rbxthumb://type=AvatarHeadShot&id=1&w=420&h=420"
a8.Parent=a5
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
bb.TextColor3=n.Light(p.Text,0.4)
bb.TextStrokeTransparency=1
bb.FontFace=p.Font
local bc=bb:Clone()
bc.Position=UDim2.fromOffset(55,21)
bc.TextColor3=Color3.new()
bc.TextTransparency=0.65
bc.Visible=false
bc.Parent=a5
bb:GetPropertyChangedSignal"Size":Connect(function()
bc.Size=bb.Size
end)
bb:GetPropertyChangedSignal"Text":Connect(function()
bc.Text=bb.Text
end)
bb:GetPropertyChangedSignal"FontFace":Connect(function()
bc.FontFace=bb.FontFace
end)
bb.Parent=a5
local bd=Instance.new"Frame"
bd.Name="HealthBKG"
bd.Size=UDim2.fromOffset(200,9)
bd.Position=UDim2.fromOffset(20,56)
bd.BackgroundColor3=p.Main
bd.BorderSizePixel=0
bd.Parent=a5
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
bh.Parent=a5

a3:CreateFont{
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
local bj=a3:CreateToggle{
Name="Use Displayname",
Default=true,
}
a3:CreateToggle{
Name="Render Background",
Function=function(bk)
a5.BackgroundTransparency=bk and bi.Value or 1
bc.Visible=not bk
a7.Visible=bk
bg.Visible=not bk
ba.Visible=not bk
bi.Object.Visible=bk
end,
Default=true,
}
bi=a3:CreateSlider{
Name="Transparency",
Min=0,
Max=1,
Default=0.5,
Decimal=10,
Function=function(bk)
a5.BackgroundTransparency=bk
end,
Darker=true,
}
local bk
local bl=a3:CreateToggle{
Name="Custom Color",
Function=function(bl)
bk.Object.Visible=bl
if bl then
a5.BackgroundColor3=
Color3.fromHSV(bk.Hue,bk.Sat,bk.Value)
a8.BackgroundColor3=
Color3.fromHSV(bk.Hue,bk.Sat,math.max(bk.Value-0.1,0.075))
bd.BackgroundColor3=a8.BackgroundColor3
else
a5.BackgroundColor3=n.Dark(p.Main,0.1)
a8.BackgroundColor3=p.Main
bd.BackgroundColor3=p.Main
end
end,
}
bk=a3:CreateColorSlider{
Name="Color",
Function=function(bm,bn,bo)
if bl.Enabled then
a5.BackgroundColor3=Color3.fromHSV(bm,bn,bo)
a8.BackgroundColor3=Color3.fromHSV(bm,bn,math.max(bo-0.1,0))
bd.BackgroundColor3=a8.BackgroundColor3
end
end,
Darker=true,
Visible=false,
}
d:setupguicolorsync(a3,{
Color1=bk,
Default=true
})
a3:CreateToggle{
Name="Border",
Function=function(bm)
bh.Enabled=bm
a4.Object.Visible=bm
end,
}
a4=a3:CreateColorSlider{
Name="Border Color",
Function=function(bm,bn,bo,bp)
bh.Color=Color3.fromHSV(bm,bn,bo)
bh.Transparency=1-bp
end,
Darker=true,
Visible=false,
}

local bm=0
local bn=0
a2={
Targets={},
Object=a5,
UpdateInfo=function(bo)
local bp=d.Libraries
if not bp then
return
end

for bq,br in bo.Targets do
if br<tick()then
bo.Targets[bq]=nil
end
end

local bq,br=(tick())
for bs,bt in bo.Targets do
if bt>bq then
br=bs
bq=bt
end
end

a5.Visible=br~=nil or w.Visible
if br then
bb.Text=br.Player and(bj.Enabled and br.Player.DisplayName or br.Player.Name)
or br.Character and br.Character.Name
or bb.Text
a8.Image="rbxthumb://type=AvatarHeadShot&id="
..(br.Player and br.Player.UserId or 1)
.."&w=420&h=420"

if not br.Character then
br.Health=br.Health or 0
br.MaxHealth=br.MaxHealth or 100
end

if br.Health~=bm or br.MaxHealth~=bn then
local bs=math.max(br.Health/br.MaxHealth,0)
o:Tween(be,TweenInfo.new(0.3),{
Size=UDim2.fromScale(math.min(bs,1),1),
BackgroundColor3=Color3.fromHSV(math.clamp(bs/2.5,0,1),0.89,0.75),
})
o:Tween(bf,TweenInfo.new(0.3),{
Size=UDim2.fromScale(math.clamp(bs-1,0,0.8),1),
})
if bm>br.Health and bo.LastTarget==br then
o:Cancel(a9)
a9.BackgroundTransparency=0.3
o:Tween(a9,TweenInfo.new(0.5),{
BackgroundTransparency=1,
})
end
bm=br.Health
bn=br.MaxHealth
end

if not br.Character then
table.clear(br)
end
bo.LastTarget=br
end
return br
end,
}
d.Libraries.targetinfo=a2

function d.UpdateTextGUI(bo,bp)
if not bp and not d.Loaded then
return
end
if aw.Button.Enabled then
local bq=aw.Children.AbsolutePosition.X>(C.AbsoluteSize.X/2)
aT.Visible=aG.Enabled
aT.Position=bq and UDim2.new(1/aB.Scale,-113,0,6)or UDim2.fromOffset(0,6)
aW.Visible=aC.Enabled
aZ.Text=aN.Value
aZ.FontFace=aO.Value
aZ.Visible=aZ.Text~=""and aR.Enabled
a_.Visible=aZ.Visible and aC.Enabled
a1.HorizontalAlignment=bq and Enum.HorizontalAlignment.Right or Enum.HorizontalAlignment.Left
a0.Size=UDim2.fromScale(1/aB.Scale,1)
a0.Position=UDim2.fromOffset(
bq and 3 or 0,
11
+(aT.Visible and aT.Size.Y.Offset or 0)
+(aZ.Visible and 28 or 0)
+(aJ.Enabled and 3 or 0)
)
if aZ.Visible then
local br=
F(removeTags(aZ.Text),aZ.TextSize,aZ.FontFace)
aZ.Size=UDim2.fromOffset(br.X,br.Y)
aZ.Position=UDim2.new(
bq and 1/aB.Scale or 0,
bq and-br.X or 0,
0,
(aT.Visible and 32 or 8)
)
end

local br={}
for bs,bt in aS do
if bt.Enabled then
table.insert(br,bt.Object.Name)
end
bt.Object:Destroy()
end
table.clear(aS)

local bs=TweenInfo.new(0.3,Enum.EasingStyle.Exponential)
for bt,bu in d.Modules do
if aL.Enabled and table.find(aK.ListEnabled,bt)then
continue
end
if aM.Enabled and bu.Category=="Render"then
continue
end
if bu.Enabled or table.find(br,bt)then
local bv=Instance.new"Frame"
bv.Name=bt
bv.Size=UDim2.fromOffset()
bv.BackgroundTransparency=1
bv.ClipsDescendants=true
bv.Parent=a0
local bw
local bx
if aJ.Enabled then
bw=Instance.new"Frame"
bw.Size=UDim2.new(1,3,1,0)
bw.BackgroundColor3=n.Dark(p.Main,0.15)
bw.BackgroundTransparency=aH.Value
bw.BorderSizePixel=0
bw.Parent=bv
local by=Instance.new"Frame"
by.Size=UDim2.new(1,0,0,1)
by.Position=UDim2.new(0,0,1,-1)
by.BackgroundColor3=Color3.new()
by.BackgroundTransparency=0.928
+(0.072*math.clamp((aH.Value-0.5)/0.5,0,1))
by.BorderSizePixel=0
by.Parent=bw
local bz=by:Clone()
bz.Name="Line"
bz.Position=UDim2.new()
bz.Parent=bw
bx=Instance.new"Frame"
bx.Size=UDim2.new(0,2,1,0)
bx.Position=bq and UDim2.new(1,-5,0,0)or UDim2.new()
bx.BorderSizePixel=0
bx.Parent=bw
end
local by=Instance.new"TextLabel"
by.Position=UDim2.fromOffset(bq and 3 or 6,2)
by.BackgroundTransparency=1
by.BorderSizePixel=0
by.Text=bt..(bu.ExtraText and" <font color='#A8A8A8'>"..bu.ExtraText().."</font>"or"")
by.TextSize=15
by.FontFace=ay.Value
by.RichText=true
local bz=F(removeTags(by.Text),by.TextSize,by.FontFace)
by.Size=UDim2.fromOffset(bz.X,bz.Y)
if aC.Enabled then
local bA=by:Clone()
bA.Position=
UDim2.fromOffset(by.Position.X.Offset+1,by.Position.Y.Offset+1)
bA.Text=removeTags(by.Text)
bA.TextColor3=Color3.new()
bA.Parent=bv
end
by.Parent=bv
local bA=UDim2.fromOffset(bz.X+10,bz.Y+(aJ.Enabled and 5 or 3))
if aF.Enabled then
if not table.find(br,bt)then
o:Tween(bv,bs,{
Size=bA,
})
else
bv.Size=bA
if not bu.Enabled then
o:Tween(bv,bs,{
Size=UDim2.fromOffset(),
})
end
end
else
bv.Size=bu.Enabled and bA or UDim2.fromOffset()
end
table.insert(aS,{
Object=bv,
Text=by,
Background=bw,
Color=bx,
Enabled=bu.Enabled,
})
end
end

if ax.Value=="Alphabetical"then
table.sort(aS,function(bt,bu)
return bt.Text.Text<bu.Text.Text
end)
else
table.sort(aS,function(bt,bu)
return bt.Text.Size.X.Offset>bu.Text.Size.X.Offset
end)
end

for bt,bu in aS do
if bu.Color then
bu.Color.Parent.Line.Visible=bt~=1
end
bu.Object.LayoutOrder=bt
end
end

d:UpdateGUI(d.GUIColor.Hue,d.GUIColor.Sat,d.GUIColor.Value,true)
end

function d.UpdateGUI(bo,bp,bq,br,bs)
if d.Loaded==nil then
return
end
d.GUIColorChanged:Fire(bp,bq,br,bs)
if not bs and d.GUIColor.Rainbow then
return
end
if aw.Button.Enabled then
aX.Color=ColorSequence.new{
ColorSequenceKeypoint.new(0,Color3.fromHSV(bp,bq,br)),
ColorSequenceKeypoint.new(
1,
aE.Enabled and Color3.fromHSV(d:Color((bp-0.075)%1))
or Color3.fromHSV(bp,bq,br)
),
}
aY.Color=aE.Enabled and aD.Enabled and aX.Color
or ColorSequence.new{
ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),
ColorSequenceKeypoint.new(1,Color3.new(1,1,1)),
}
aZ.TextColor3=aP.Enabled
and Color3.fromHSV(aQ.Hue,aQ.Sat,aQ.Value)
or aX.Color.Keypoints[2].Value

local bt=aA.Value=="Custom color"
and Color3.fromHSV(az.Hue,az.Sat,az.Value)
or nil
for bu,bv in aS do
bv.Text.TextColor3=bt
or(
d.GUIColor.Rainbow
and Color3.fromHSV(d:Color((bp-((aE and bu+2 or bu)*0.025))%1))
or aX.Color.Keypoints[2].Value
)
if bv.Color then
bv.Color.BackgroundColor3=bv.Text.TextColor3
end
if aI.Enabled and bv.Background then
bv.Background.BackgroundColor3=n.Dark(bv.Text.TextColor3,0.75)
end
end
end

if not w.Visible and not d.Legit.Window.Visible then
return
end
local bt=d.GUIColor.Rainbow and d.RainbowMode.Value~="Retro"

for bu,bv in d.Categories do
if bu=="Main"then
bv.Object.VapeLogo.V4Logo.ImageColor3=Color3.fromHSV(bp,bq,br)
for bw,bx in bv.Buttons do
if bx.Enabled then
bx.Object.TextColor3=bt
and Color3.fromHSV(d:Color((bp-(bx.Index*0.025))%1))
or Color3.fromHSV(bp,bq,br)
if bx.Icon then
bx.Icon.ImageColor3=bx.Object.TextColor3
end
end
end
end

if bv.Options then
for bw,bx in bv.Options do
if bx.Color then
bx:Color(bp,bq,br,bt)
end
end
end

if bv.Type=="CategoryList"then
bv.Object.Children.Add.AddButton.ImageColor3=bt and Color3.fromHSV(d:Color(bp%1))
or Color3.fromHSV(bp,bq,br)
if bv.Selected then
bv.Selected.BackgroundColor3=bt and Color3.fromHSV(d:Color(bp%1))
or Color3.fromHSV(bp,bq,br)
bv.Selected.Title.TextColor3=d.GUIColor.Rainbow and Color3.new(0.19,0.19,0.19)
or d:TextColor(bp,bq,br)
bv.Selected.Dots.Dots.ImageColor3=bv.Selected.Title.TextColor3
bv.Selected.Bind.Icon.ImageColor3=bv.Selected.Title.TextColor3
bv.Selected.Bind.TextLabel.TextColor3=bv.Selected.Title.TextColor3
end
end
end

for bu,bv in d.Modules do
if bv.Enabled then
bv.Object.BackgroundColor3=bt
and Color3.fromHSV(d:Color((bp-(bv.Index*0.025))%1))
or Color3.fromHSV(bp,bq,br)
bv.Object.TextColor3=d.GUIColor.Rainbow and Color3.new(0.19,0.19,0.19)
or d:TextColor(bp,bq,br)
bv.Object.UIGradient.Enabled=bt and d.RainbowMode.Value=="Gradient"
if bv.Object.UIGradient.Enabled then
bv.Object.BackgroundColor3=Color3.new(1,1,1)
bv.Object.UIGradient.Color=ColorSequence.new{
ColorSequenceKeypoint.new(0,Color3.fromHSV(d:Color((bp-(bv.Index*0.025))%1))),
ColorSequenceKeypoint.new(
1,
Color3.fromHSV(d:Color((bp-((bv.Index+1)*0.025))%1))
),
}
end
bv.Object.Bind.Icon.ImageColor3=bv.Object.TextColor3
bv.Object.Bind.TextLabel.TextColor3=bv.Object.TextColor3
bv.Object.Dots.Dots.ImageColor3=bv.Object.TextColor3
end

for bw,bx in bv.Options do
if bx.Color then
bx:Color(bp,bq,br,bt)
end
end
end

for bu,bv in d.Overlays.Toggles do
if bv.Enabled then
o:Cancel(bv.Object.Knob)
bv.Object.Knob.BackgroundColor3=bt and Color3.fromHSV(d:Color((bp-(bu*0.075))%1))
or Color3.fromHSV(bp,bq,br)
end
end

if d.Legit.Icon then
d.Legit.Icon.ImageColor3=Color3.fromHSV(bp,bq,br)
end

if d.Legit.Window.Visible then
for bu,bv in d.Legit.Modules do
if bv.Enabled then
o:Cancel(bv.Object.Knob)
bv.Object.Knob.BackgroundColor3=Color3.fromHSV(bp,bq,br)
end

for bw,bx in bv.Options do
if bx.Color then
bx:Color(bp,bq,br,bt)
end
end
end
end
end

d:Clean(r.ChildRemoved:Connect(function()
for bo,bp in r:GetChildren()do
if o.Tween then
o:Tween(bp,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{
Position=UDim2.new(1,0,1,-(29+(78*bo))),
})
end
end
end))

d:Clean(h.InputBegan:Connect(function(bo)
if not h:GetFocusedTextBox()and bo.KeyCode~=Enum.KeyCode.Unknown then
table.insert(d.HeldKeybinds,bo.KeyCode.Name)
if d.Binding then
return
end

if checkKeybinds(d.HeldKeybinds,d.Keybind,bo.KeyCode.Name)then
if d.ThreadFix then
setthreadidentity(8)
end
for bp,bq in d.Windows do
bq.Visible=false
end
w.Visible=not w.Visible
A.Visible=false
d:BlurCheck()
end

local bp=false
for bq,br in d.Modules do
if checkKeybinds(d.HeldKeybinds,br.Bind,bo.KeyCode.Name)then
bp=true
if d.ToggleNotifications.Enabled then
d:CreateNotification(
"Module Toggled",
bq
.."<font color='#FFFFFF'> has been </font>"
..(not br.Enabled and"<font color='#5AFF5A'>Enabled</font>"or"<font color='#FF5A5A'>Disabled</font>")
.."<font color='#FFFFFF'>!</font>",
0.75
)
end
br:Toggle(true)
end
end
if bp then
d:UpdateTextGUI()
end

for bq,br in d.Profiles do
if checkKeybinds(d.HeldKeybinds,br.Bind,bo.KeyCode.Name)and br.Name~=d.Profile then
d:Save(br.Name)
d:Load(true)
break
end
end
end
end))

d:Clean(h.InputEnded:Connect(function(bo)
if not h:GetFocusedTextBox()and bo.KeyCode~=Enum.KeyCode.Unknown then
if d.Binding then
if not d.MultiKeybind.Enabled then
d.HeldKeybinds={bo.KeyCode.Name}
end
d.Binding:SetBind(
checkKeybinds(d.HeldKeybinds,d.Binding.Bind,bo.KeyCode.Name)and{}
or d.HeldKeybinds,
true
)
d.Binding=nil
end
end

local bp=table.find(d.HeldKeybinds,bo.KeyCode.Name)
if bp then
table.remove(d.HeldKeybinds,bp)
end
end))

return d