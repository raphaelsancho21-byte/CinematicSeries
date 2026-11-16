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
    -- Angulos alternados para a perseguicao. Camara segue o rosto, nao o solo.
    if t<4 then
        return bh+Vector3.new(-12,4,12),bh,53
    elseif t<8 then
        return center+Vector3.new(-8,5,13),center,50
    elseif t<12 then
        return center+Vector3.new(2,3,10),center,43
    elseif t<19 then
        return bh+Vector3.new(10,3,12),bh,60
    elseif t<25 then
        return center+Vector3.new(-10,7,14),center,56
    elseif t<30 then
        return ph+Vector3.new(-7,3,9),bh:Lerp(ph,.55),48
    elseif t<34 then
        return bh+Vector3.new(4,2,8),bh,39
    elseif t<39 then
        return center+Vector3.new(-6,5,11),center,50
    end
    return center+Vector3.new(4,3,10),center,37
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
        if t>=(remote:GetAttribute("TakeDuration") or 45) then
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
