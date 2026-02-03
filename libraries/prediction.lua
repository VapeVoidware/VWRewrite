



local a={}


local b={
velocitySmoothFactor=0.35,
pingCompensation=0.9,
distanceScaleMin=1.0,
distanceScaleMax=1.75,
distanceScaleRange=480,
distanceScaleOffset=80,
timeScaleMultiplier=0.45,
timeScaleMax=1.6,
epsilon=1e-9,
}


local c=not shared.CheatEngineMode and cloneref or function(c)
return c
end
local d=c(game:GetService"Players")
local e=d.LocalPlayer

local f={}
local g={}


local h=0
local i=false
if getthreadidentity and setthreadidentity then
i=true
h=getthreadidentity()
elseif shared.vape and shared.vape.ThreadFix then
i=true
h=0
end

local function setThreadSafe(j)
if i then
setthreadidentity(j)
end
end


local function isZero(j)
return j>-b.epsilon and j<b.epsilon
end

local function cuberoot(j)
return(j>=0)and math.pow(j,0.3333333333333333)or-math.pow(-j,0.3333333333333333)
end

local function solveQuadric(j,k,l)
local m=k/(2*j)
local n=l/j
local o=m*m-n

if isZero(o)then
return-m
elseif o<0 then
return nil,nil
else
local p=math.sqrt(o)
return p-m,-p-m
end
end

local function solveCubic(j,k,l,m)
local n=k/j
local o=l/j
local p=m/j

local q=n*n
local r=(0.3333333333333333)*(-q/3+o)
local s=0.5*((7.4074074074074066E-2)*n*q-(n*o)/3+p)

local t=s*s+r*r*r
local u,v,w,x

if isZero(t)then
if isZero(s)then
u,x=0,1
else
local y=cuberoot(-s)
u,v,x=2*y,-y,2
end
elseif t<0 then
local y=(0.3333333333333333)*math.acos(-s/math.sqrt(-r*r*r))
local z=2*math.sqrt(-r)
u=z*math.cos(y)
v=-z*math.cos(y+math.pi/3)
w=-z*math.cos(y-math.pi/3)
x=3
else
local y=math.sqrt(t)
local z=cuberoot(y-s)
local A=-cuberoot(y+s)
u,x=z+A,1
end

local y=n/3
if x and x>0 then
u=u and(u-y)or nil
end
if x and x>1 then
v=v and(v-y)or nil
end
if x and x>2 then
w=w and(w-y)or nil
end

return u,v,w
end

function a.solveQuartic(j,k,l,m,n)
local o=k/j
local p=l/j
local q=m/j
local r=n/j

local s=o*o
local t=-0.375*s+p
local u=0.125*s*o-0.5*o*p+q
local v=-1.171875E-2*s*s+0.0625*s*p-0.25*o*q+r

local w,x,y,z
local A={}

if isZero(v)then
A={1,0,t,u}
w,x,y=solveCubic(A[1],A[2],A[3],A[4])
else
A[1]=1
A[2]=-0.5*t
A[3]=-v
A[4]=0.5*v*t-0.125*u*u

local B=solveCubic(A[1],A[2],A[3],A[4])
if not B then
return nil
end

local C=B*B-v
local D=2*B-t
if C<0 or D<0 then
return nil
end

C=isZero(C)and 0 or math.sqrt(C)
D=isZero(D)and 0 or math.sqrt(D)

local function quad(E,F)
return solveQuadric(1,F,E)
end

w,x=quad(B-C,u<0 and-D or D)
y,z=quad(B+C,u<0 and D or-D)
end

local B=o*0.25
if w then
w=w-B
end
if x then
x=x-B
end
if y then
y=y-B
end
if z then
z=z-B
end

return{w,x,y,z}
end


local function distanceScale(j)
return math.clamp(
1+(j-b.distanceScaleOffset)/b.distanceScaleRange,
b.distanceScaleMin,
b.distanceScaleMax
)
end

local function timeScale(j)
return math.clamp(1+j*b.timeScaleMultiplier,1,b.timeScaleMax)
end


local function getSmoothedVelocity(j,k)
if not j or not k then
return Vector3.zero
end

local l=j.UserId
local m=k.AssemblyLinearVelocity
local n=tick()


if not f[l]then
f[l]=m
g[l]=n
return m
end


local o=n-(g[l]or n)
local p=math.clamp(o*60*b.velocitySmoothFactor,0,1)


local q=f[l]:Lerp(m,p)


f[l]=q
g[l]=n

return q
end







local function getPingSeconds()
local j,k=pcall(function()
return e:GetNetworkPing()
end)

if j and k and k>0 then
return k
end

return 0.01
end


function a.clearPlayerData(j)
if j then
local k=j.UserId
f[k]=nil
g[k]=nil
end
end


function a.clearAllData()
f={}
g={}
end


function a.predictStrafingMovement(j,k,l,m,n)
if not j or not j.Character or not k then
return k and k.Position or n
end

local o=k.Position
local p=getSmoothedVelocity(j,k)
local q=o-n
local r=q.Magnitude

if r<1 then
return o
end


local s=r/l
local t=distanceScale(r)
local u=timeScale(s)


s=s*math.clamp(1.15*t,1.15,1.9)


local v=Vector3.new(p.X,0,p.Z)
local w=v*s*(0.85*t)


local x
if p.Y<-12 then

x=p.Y*s*(0.38*u)
elseif p.Y>10 then

x=p.Y*s*(0.33*u)
else

x=(p.Y*s*0.26)-(m*s*s*0.12)
end

return o+w+Vector3.new(0,x,0)
end


local function predictWithPing(j,k,l,m,n)
if not j or not k then
return n
end


local o=a.predictStrafingMovement(j,k,l,m,n)


local p=getPingSeconds()
local q=getSmoothedVelocity(j,k)
local r=(o-n).Magnitude


local s=math.clamp(1+r/350,1,1.6)


local t=q*p*b.pingCompensation*s


t=Vector3.new(t.X,math.clamp(t.Y,-8,8),t.Z)

return o+t
end


function a.SolveTrajectory(
j,
k,
l,
m,
n,
o,
p,
q,
r,
s,
t
)

setThreadSafe(8)


if s and t then
m=predictWithPing(s,t,k,l,j)
n=getSmoothedVelocity(s,t)
end


if not m then
setThreadSafe(h)
return j
end

local u=m-j
if u.Magnitude<1 then
setThreadSafe(h)
return m
end


n=n or Vector3.zero


local v,w,x=n.X,n.Y,n.Z
local y,z,A=u.X,u.Y,u.Z
local B=-0.5*l


local C=a.solveQuartic(
B*B,-2
*w*B,
w*w-2*z*B-k^2+v*v+x*x,
2*z*w+2*y*v+2*A*x,
z*z+y*y+A*A
)

local D

if C then

local E
for F,G in ipairs(C)do
if G and G>0 then
if not E or G<E then
E=G
end
end
end

if E then

local F=E*timeScale(E)


local G=(y+v*F)/F
local H=(z+w*F-B*F*F)/F
local I=(A+x*F)/F

D=j+Vector3.new(G,H,I)
end
end


if not D then
if isZero(l)then
local E=u.Magnitude/k
D=j+u+n*E
else

D=m
end
end


setThreadSafe(h)

return D
end


function a.PredictInstantHit(j,k,l)
if not j or not k then
return l
end

local m=k.Position
local n=getSmoothedVelocity(j,k)
local o=getPingSeconds()


return m+n*o*b.pingCompensation
end


function a.GetSimplePrediction(j,k,l,m)
if not j or not k then
return m
end

local n=k.Position
local o=getSmoothedVelocity(j,k)
local p=(n-m).Magnitude
local q=p/l

return n+o*q
end


function a.setConfig(j)
for k,l in pairs(j)do
if b[k]~=nil then
b[k]=l
end
end
end


function a.getConfig()
return table.clone(b)
end


function a.getPlayerVelocityData(j)
if not j then
return nil
end
local k=j.UserId
return{
lastVelocity=f[k],
lastTime=g[k],
age=g[k]and(tick()-g[k])or nil,
}
end





function a.PredictMeleeCombat(j,k,l,m)
m=m or{}


local n={

usePingCompensation=m.usePingCompensation~=false,
useVelocityPrediction=m.useVelocityPrediction~=false,


swingTime=m.swingTime or 0.3,
extraLead=m.extraLead or 0,


velocityMultiplier=m.velocityMultiplier or 1.0,
distanceScale=m.distanceScale or 1.0,


predictStrafe=m.predictStrafe~=false,
predictVertical=m.predictVertical~=false,


useAcceleration=m.useAcceleration or false,
clampVertical=m.clampVertical or true,
}


if not j or not k or not l then
return k and k.Position or l
end


setThreadSafe(8)

local o=k.Position
local p=getSmoothedVelocity(j,k)
local q=(o-l).Magnitude


if not n.useVelocityPrediction then
setThreadSafe(h)
return o
end


local r=n.swingTime+n.extraLead


if n.usePingCompensation then
local s=getPingSeconds()
r=r+s
end


if n.distanceScale~=1.0 then
local s=distanceScale(q)
r=r*s*n.distanceScale
end


local s=o

if n.predictStrafe then

local t=Vector3.new(p.X,0,p.Z)*n.velocityMultiplier
s=s+t*r
end

if n.predictVertical then

local t=p.Y*n.velocityMultiplier
local u=t*r


if n.clampVertical then
u=math.clamp(u,-8,8)
end

s=s+Vector3.new(0,u,0)
end


setThreadSafe(h)

return s,
{
distance=q,
velocity=p,
predictionTime=r,
originalPos=o,
}
end





function a.PredictMeleeRaycast(j,k,l,m,n)

local o,p=a.PredictMeleeCombat(j,k,l,n)


local q=(o-l).Unit



local r=math.max(p.distance-14.399,0)
local s=l+q*r

return{
targetPosition=o,
cameraPosition=s,
cursorDirection=q,
distance=p.distance,
predictionTime=p.predictionTime,
}
end





function a.GetPredictedClosestPoint(j,k,l,m)

local n=a.PredictMeleeCombat(j,k,l,m)


local o=Vector3.new(2,3,2)

local p=math.clamp(l.X,n.X-o.X/2,n.X+o.X/2)
local q=math.clamp(l.Y,n.Y-o.Y/2,n.Y+o.Y/2)
local r=math.clamp(l.Z,n.Z-o.Z/2,n.Z+o.Z/2)

return Vector3.new(p,q,r)
end





function a.PredictMultipleTargets(j,k,l)
local m={}

for n,o in ipairs(j)do
if o.Player and o.RootPart then
local p,q=a.PredictMeleeCombat(o.Player,o.RootPart,k,l)

table.insert(m,{
entity=o,
position=p,
distance=q.distance,
velocity=q.velocity,
predictionTime=q.predictionTime,
})
end
end


table.sort(m,function(n,o)
return n.distance<o.distance
end)

return m
end

return a