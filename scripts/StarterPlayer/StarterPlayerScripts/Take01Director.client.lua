-- CinematicSeries | StarterPlayerScripts/Take01Director.client.lua
-- Camera V3: enquadramentos baseados nas posicoes dos atores, nao no chao.
local RunService=game:GetService("RunService")
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local remote=RS:WaitForChild("Take01Camera")
local bandido=workspace:WaitForChild("Bandido")
local policial=workspace:WaitForChild("Policial")
local function root(rig) return rig:WaitForChild("HumanoidRootPart") end
local function aimPart(rig)
    return rig:FindFirstChild("Head",true) or rig:FindFirstChild("Torso",true)
        or rig:FindFirstChild("HumanoidRootPart",true) or rig.PrimaryPart
end
local function target(rig)
    local p=aimPart(rig)
    return p and (p.Position+Vector3.new(0,p.Name=="Head" and 0 or 1.4,0)) or rig:GetPivot().Position+Vector3.new(0,2.5,0)
end
local function getShot(t)
    local br,pr=root(bandido),root(policial)
    local bh,ph=target(bandido),target(policial)
    local center=(bh+ph)/2
    if t<4 then
        return br.Position-br.CFrame.LookVector*12+br.CFrame.RightVector*7+Vector3.new(0,5,0),bh,55
    elseif t<7 then
        return pr.Position-pr.CFrame.LookVector*9+pr.CFrame.RightVector*6+Vector3.new(0,4,0),center,50
    elseif t<10 then
        return center+br.CFrame.RightVector*11+Vector3.new(0,4,0),center,45
    elseif t<13 then
        return ph+pr.CFrame.LookVector*5+pr.CFrame.RightVector*2+Vector3.new(0,.5,0),ph,36
    end
    return bh+br.CFrame.LookVector*4+br.CFrame.RightVector*1.5+Vector3.new(0,.3,0),bh,35
end
local player=Players.LocalPlayer
local activeConnection,activeStart
local function play(startTime)
    if type(startTime)~="number" or activeStart==startTime then return end
    activeStart=startTime
    if activeConnection then activeConnection:Disconnect() end
    local cam=workspace.CurrentCamera
    local oldType,oldFOV=cam.CameraType,cam.FieldOfView
    cam.CameraType=Enum.CameraType.Scriptable
    local current=cam.CFrame
    local currentFOV=cam.FieldOfView
    activeConnection=RunService.RenderStepped:Connect(function(dt)
        local t=workspace:GetServerTimeNow()-startTime
        if t<0 then return end
        if t>=15 then
            activeConnection:Disconnect();activeConnection=nil
            cam.CameraType=oldType;cam.FieldOfView=oldFOV
            local char=player.Character
            if char then cam.CameraSubject=char:FindFirstChildOfClass("Humanoid") end
            return
        end
        local pos,focus,fov=getShot(t)
        local alpha=1-math.exp(-dt*9)
        current=current:Lerp(CFrame.lookAt(pos,focus),alpha)
        currentFOV=currentFOV+(fov-currentFOV)*alpha
        cam.CFrame=current;cam.FieldOfView=currentFOV
    end)
end
remote.OnClientEvent:Connect(play)
remote:GetAttributeChangedSignal("TakeStartTime"):Connect(function()
    play(remote:GetAttribute("TakeStartTime"))
end)
play(remote:GetAttribute("TakeStartTime"))
print("[CINEMATIC V3] Camera carregada!")
