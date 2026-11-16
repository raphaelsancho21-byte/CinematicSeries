-- CinematicSeries | ServerScriptService/CinematicDirectorV4.server.lua
-- TAKE 01: caminhada 0-4s, corrida 4-7s, giro 7-9s
-- Requer Workspace.Bandido, Workspace.Policial (R6)
-- Requer ServerStorage.RBX_ANIMSAVES com Walk1 e Run1 como KeyframeSequence.
local RunService=game:GetService("RunService")
local SS=game:GetService("ServerStorage")
local RS=game:GetService("ReplicatedStorage")
local KP=game:GetService("KeyframeSequenceProvider")
local CONFIG={
    Duration=15,Preparation=5,WalkDistance=12,
    PoliceStopDistance=4.5,WalkAnimation="Walk1",RunAnimation="Run1"
}
local bandido=workspace:WaitForChild("Bandido")
local policial=workspace:WaitForChild("Policial")
local folder=SS:WaitForChild("RBX_ANIMSAVES")
local remote=RS:FindFirstChild("Take01Camera")
if not remote then remote=Instance.new("RemoteEvent");remote.Name="Take01Camera";remote.Parent=RS end
local function ease(x) x=math.clamp(x,0,1);return x*x*(3-2*x) end
local function animator(rig)
    local hum=rig:WaitForChild("Humanoid")
    assert(hum.RigType==Enum.HumanoidRigType.R6,rig.Name.." precisa ser R6")
    rig:WaitForChild("HumanoidRootPart").Anchored=true
    hum.AutoRotate=false
    local old=rig:FindFirstChild("Animate")
    if old then old.Disabled=true end
    local a=hum:FindFirstChildOfClass("Animator") or Instance.new("Animator",hum)
    for _,track in ipairs(a:GetPlayingAnimationTracks()) do track:Stop(0) end
    return a
end
local function track(rig,prefix)
    local a=animator(rig)
    local sequence
    for _,item in ipairs(folder:GetDescendants()) do
        if item:IsA("KeyframeSequence") and item.Name:sub(1,#prefix)==prefix then
            sequence=item;break
        end
    end
    if not sequence then warn("[Director] Sequence ausente:",prefix);return nil end
    local ok,result=pcall(function()
        local anim=Instance.new("Animation")
        anim.AnimationId=KP:RegisterKeyframeSequence(sequence)
        local t=a:LoadAnimation(anim)
        t.Looped=true
        t.Priority=Enum.AnimationPriority.Action
        return t
    end)
    if not ok then warn("[Director] Falhou:",result);return nil end
    print("[DIRECTOR] Carregada:",rig.Name,sequence.Name)
    return result
end
local walk=track(bandido,CONFIG.WalkAnimation)
local run=track(policial,CONFIG.RunAnimation)
local banditCF=bandido:GetPivot()
local policeCF=policial:GetPivot()
local forward=Vector3.new(banditCF.LookVector.X,0,banditCF.LookVector.Z).Unit
local right=Vector3.new(banditCF.RightVector.X,0,banditCF.RightVector.Z).Unit
local start=banditCF.Position
local finish=start+forward*CONFIG.WalkDistance
local policeStart=start-forward*10+right*7
policeStart=Vector3.new(policeStart.X,policeCF.Position.Y,policeStart.Z)
local policeFinish=finish-forward*CONFIG.PoliceStopDistance
policeFinish=Vector3.new(policeFinish.X,policeCF.Position.Y,policeFinish.Z)
local function face(pos,target)
    local dest=Vector3.new(target.X,pos.Y,target.Z)
    if (dest-pos).Magnitude<.01 then return CFrame.new(pos) end
    return CFrame.lookAt(pos,dest)
end
local function update(t)
    local bp=start:Lerp(finish,ease(t/4))
    local pp=policeStart:Lerp(policeFinish,ease((t-4)/3))
    bandido:PivotTo(face(bp,bp+forward*10):Lerp(face(bp,policeFinish),ease((t-7)/2)))
    policial:PivotTo(face(pp,bp))
end
update(0)
local startTime=workspace:GetServerTimeNow()+CONFIG.Preparation
-- atributo evita perder evento caso LocalScript inicialize atrasado
remote:SetAttribute("TakeStartTime",startTime)
remote:FireAllClients(startTime)
print("[DIRECTOR V4] Take preparado!",startTime)
local didWalk,didStopWalk,didRun,didStopRun=false,false,false,false
local conn
conn=RunService.Heartbeat:Connect(function()
    local t=workspace:GetServerTimeNow()-startTime
    if t<0 then return end
    if not didWalk then didWalk=true;if walk then walk:Play(.15) end end
    if t>=4 and not didStopWalk then didStopWalk=true;if walk then walk:Stop(.2) end end
    if t>=4 and not didRun then didRun=true;if run then run:Play(.15) end end
    if t>=7 and not didStopRun then didStopRun=true;if run then run:Stop(.2) end end
    update(math.min(t,CONFIG.Duration))
    if t>=CONFIG.Duration then conn:Disconnect();print("[DIRECTOR V4] TAKE FINALIZADO!") end
end)
