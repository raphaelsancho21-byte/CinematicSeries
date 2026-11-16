-- CINEMATICSERIES: TAKE 01 V5 - 45 segundos
-- No scripts extras. Requer NPCSpawner + RBX_ANIMSAVES (Walk1 e Run1).
-- Todas as posicoes se baseiam no spawn do bandido; roteiro usa a rua da cidade.
local RS=game:GetService("ReplicatedStorage")
local SS=game:GetService("ServerStorage")
local RunService=game:GetService("RunService")
local KP=game:GetService("KeyframeSequenceProvider")
local CONFIG={Duration=45,Preparation=5,WalkAnimation="Walk1",RunAnimation="Run1",Dust=true}
local readyDeadline=os.clock()+22
repeat task.wait(.1) until workspace:GetAttribute("CinematicNPCsReady")==true or os.clock()>readyDeadline
local bandido=workspace:WaitForChild("Bandido",15)
local policial=workspace:WaitForChild("Policial",15)
assert(bandido and policial,"NPCs indisponiveis: confira o CinematicNPCSpawner")
local folder=SS:WaitForChild("RBX_ANIMSAVES")
local remote=RS:FindFirstChild("Take01Camera") or Instance.new("RemoteEvent")
remote.Name="Take01Camera";remote.Parent=RS

local function loadTracks(rig)
    local hum=rig:WaitForChild("Humanoid")
    assert(hum.RigType==Enum.HumanoidRigType.R6,rig.Name.." deve ser R6")
    rig:WaitForChild("HumanoidRootPart").Anchored=true
    hum.AutoRotate=false
    local animate=rig:FindFirstChild("Animate")
    if animate then animate.Disabled=true end
    local animator=hum:FindFirstChildOfClass("Animator") or Instance.new("Animator")
    animator.Parent=hum
    for _,track in ipairs(animator:GetPlayingAnimationTracks()) do track:Stop(0) end
    local result={}
    for _,prefix in ipairs({CONFIG.WalkAnimation,CONFIG.RunAnimation}) do
        local seq
        for _,obj in ipairs(folder:GetDescendants()) do
            if obj:IsA("KeyframeSequence") and obj.Name:match("^"..prefix) then seq=obj;break end
        end
        if seq then
            local ok,track=pcall(function()
                local a=Instance.new("Animation")
                a.AnimationId=KP:RegisterKeyframeSequence(seq)
                local tr=animator:LoadAnimation(a)
                tr.Looped=true;tr.Priority=Enum.AnimationPriority.Action
                return tr
            end)
            if ok then result[prefix]=track else warn("[TAKE V5]",rig.Name,track) end
        else warn("[TAKE V5] Falta animacao:",prefix) end
    end
    return result
end
local actor={
    Bandido={rig=bandido,tracks=loadTracks(bandido),current=""},
    Policial={rig=policial,tracks=loadTracks(policial),current=""}
}
-- Cinematografia: posicoes relativas ao inicio do bandido. Pistas livres.
local start=bandido:GetPivot().Position
local policeStart=policial:GetPivot().Position
local function pos(x,z,who)
    local y=who=="Policial" and policeStart.Y or start.Y
    return Vector3.new(start.X+x,y,start.Z+z)
end
local bRoute={
    {t=0,x=0,z=0,move="Walk1"},
    {t=4,x=12,z=0,move=""},
    {t=11,x=12,z=0,move=""},
    {t=19,x=55,z=0,move="Run1"},
    {t=25,x=79,z=-4,move="Run1"},
    {t=30,x=94,z=-9,move="Run1"},
    {t=33,x=96,z=-9,move=""}, -- quase escorrega perto do carro
    {t=39,x=111,z=-5,move="Run1"},
    {t=45,x=111,z=-5,move=""}
}
local pRoute={
    {t=0,x=policeStart.X-start.X,z=policeStart.Z-start.Z,move=""},
    {t=4,x=policeStart.X-start.X,z=policeStart.Z-start.Z,move="Run1"},
    {t=8,x=7,z=5,move=""},
    {t=12,x=9,z=5,move=""},
    {t=20,x=48,z=4,move="Run1"},
    {t=28,x=85,z=-1,move="Run1"},
    {t=33,x=91,z=-4,move=""},
    {t=39,x=105,z=-5,move="Run1"},
    {t=45,x=105,z=-5,move=""}
}
-- Retorna posicao (interpolada), direcao e acao do ator.
local function sample(route,t,who)
    if t<=route[1].t then
        local k=route[1]
        return pos(k.x,k.z,who),Vector3.new(1,0,0),k.move
    end
    for i=1,#route-1 do
        local a,b=route[i],route[i+1]
        if t<=b.t then
            local alpha=math.clamp((t-a.t)/(b.t-a.t),0,1)
            local ap,bp=pos(a.x,a.z,who),pos(b.x,b.z,who)
            local v=bp-ap
            local moving=v.Magnitude>.04 and t<b.t-.08
            local facing=moving and v.Unit or Vector3.new(1,0,0)
            local action=moving and (b.move~="" and b.move or a.move) or ""
            return ap:Lerp(bp,alpha),facing,action
        end
    end
    local last=route[#route]
    return pos(last.x,last.z,who),Vector3.new(1,0,0),""
end
local function face(position,direction)
    local flat=Vector3.new(direction.X,0,direction.Z)
    if flat.Magnitude<.01 then flat=Vector3.new(1,0,0) end
    return CFrame.lookAt(position,position+flat.Unit)
end
local function animate(data,action)
    if data.current==action then return end
    for _,tr in pairs(data.tracks) do
        if tr.IsPlaying then tr:Stop(.17) end
    end
    data.current=action
    local tr=data.tracks[action]
    if tr then tr:Play(.17) end
end
local function update(t)
    local bp,bd,bAction=sample(bRoute,t,"Bandido")
    local pp,pd,pAction=sample(pRoute,t,"Policial")
    if t>=4 and t<12 then
        bd=pp-bp
        pd=bp-pp
    elseif t>=39 then
        bd=pp-bp
        pd=bp-pp
    end
    local bcf=face(bp,bd)
    local pcf=face(pp,pd)
    if t>=30 and t<33 then
        -- Reacao do bandido: inclinacao brusca e recuperacao.
        local roll=math.sin((t-30)/3*math.pi)*math.rad(17)
        bcf=bcf*CFrame.Angles(0,0,roll)
    end
    bandido:PivotTo(bcf)
    policial:PivotTo(pcf)
    animate(actor.Bandido,bAction)
    animate(actor.Policial,pAction)
end
-- Particulas leves integradas ao proprio diretor, sem scripts novos.
local debris=Instance.new("Folder")
debris.Name="CinematicTakeFX";debris.Parent=workspace
local dustPart=Instance.new("Part")
dustPart.Name="DustEmitter";dustPart.Size=Vector3.new(.25,.25,.25)
dustPart.Anchored=true;dustPart.Transparency=1;dustPart.CanCollide=false
dustPart.CanTouch=false;dustPart.Parent=debris
local emitter=Instance.new("ParticleEmitter")
emitter.Enabled=false;emitter.Rate=0;emitter.Lifetime=NumberRange.new(.25,.55)
emitter.Speed=NumberRange.new(2,4);emitter.SpreadAngle=Vector2.new(35,35)
emitter.Size=NumberSequence.new(.5,1.8)
emitter.Transparency=NumberSequence.new(0.3,1)
emitter.Color=ColorSequence.new(Color3.fromRGB(148,143,133))
emitter.Parent=dustPart
update(0)
local startTime=workspace:GetServerTimeNow()+CONFIG.Preparation
remote:SetAttribute("TakeDuration",CONFIG.Duration)
remote:SetAttribute("TakeStartTime",startTime)
remote:FireAllClients(startTime)
local fxDone=false
local conn
conn=RunService.Heartbeat:Connect(function()
    local t=workspace:GetServerTimeNow()-startTime
    if t<0 then return end
    if t>=CONFIG.Duration then
        update(CONFIG.Duration)
        for _,data in pairs(actor) do animate(data,"") end
        debris:Destroy();conn:Disconnect()
        print("[CINEMATIC V5] TAKE 45s FINALIZADO")
        return
    end
    update(t)
    if CONFIG.Dust and not fxDone and t>=30 then
        fxDone=true
        dustPart.Position=bandido:GetPivot().Position-Vector3.new(0,2,0)
        emitter:Emit(24)
    end
end)
print("[CINEMATIC V5] TAKE 45s preparado",startTime)
