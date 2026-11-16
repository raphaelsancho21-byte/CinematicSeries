-- CinematicSeries | ServerScriptService/CinematicNPCSpawner.server.lua
-- Garante que os atores do take aparecam na cidade toda vez que apertar Play.
-- Prioridade: Workspace (rig existente) > ServerStorage/CinematicNPCs (template)
-- > rig R6 padrao gerado pelo Roblox.
local Players=game:GetService("Players")
local ServerStorage=game:GetService("ServerStorage")
local Workspace=game:GetService("Workspace")

local CONFIG={
    SetName="CinematicSeries_Set",
    SpawnFolder="06_Camera_And_Actor_Markers",
    TemplateFolder="CinematicNPCs",
    AutoCreateMissing=true,
    FaceDirection=Vector3.new(1,0,0),
    FloorClearance=0.07,
}
Workspace:SetAttribute("CinematicNPCsReady",false)
local names={"Bandido","Policial"}
local function locate(name)
    local root=Workspace:FindFirstChild(name)
    if root and root:IsA("Model") then return root end
    local nested=Workspace:FindFirstChild(name,true)
    if nested and nested:IsA("Model") and not nested:IsDescendantOf(Players) then
        nested.Parent=Workspace
        return nested
    end
    local sources=ServerStorage:FindFirstChild(CONFIG.TemplateFolder)
    local prefab=sources and sources:FindFirstChild(name)
    if not prefab then prefab=ServerStorage:FindFirstChild(name) end
    if prefab and prefab:IsA("Model") then
        local clone=prefab:Clone()
        clone.Name=name
        clone.Parent=Workspace
        print("[NPC SPAWNER] Template clonado:",name)
        return clone
    end
    if not CONFIG.AutoCreateMissing then
        warn("[NPC SPAWNER] NPC ausente e AutoCreateMissing desligado:",name)
        return nil
    end
    local ok,rig=pcall(function()
        local description=Instance.new("HumanoidDescription")
        return Players:CreateHumanoidModelFromDescriptionAsync(
            description,Enum.HumanoidRigType.R6
        )
    end)
    if not ok or not rig then
        warn("[NPC SPAWNER] Falha ao gerar rig R6:",name,rig)
        return nil
    end
    rig.Name=name
    rig.Parent=Workspace
    local bodyColors=rig:FindFirstChildOfClass("BodyColors")
    if not bodyColors then
        bodyColors=Instance.new("BodyColors")
        bodyColors.Parent=rig
    end
    if name=="Policial" then
        bodyColors.TorsoColor3=Color3.fromRGB(29,53,91)
        bodyColors.LeftArmColor3=Color3.fromRGB(44,69,104)
        bodyColors.RightArmColor3=Color3.fromRGB(44,69,104)
        bodyColors.LeftLegColor3=Color3.fromRGB(19,28,44)
        bodyColors.RightLegColor3=Color3.fromRGB(19,28,44)
    else
        bodyColors.TorsoColor3=Color3.fromRGB(96,38,43)
        bodyColors.LeftArmColor3=Color3.fromRGB(111,66,61)
        bodyColors.RightArmColor3=Color3.fromRGB(111,66,61)
        bodyColors.LeftLegColor3=Color3.fromRGB(34,35,42)
        bodyColors.RightLegColor3=Color3.fromRGB(34,35,42)
    end
    print("[NPC SPAWNER] R6 criado automaticamente:",name)
    return rig
end

local set=Workspace:WaitForChild(CONFIG.SetName,15)
if not set then
    warn("[NPC SPAWNER] Cenario ausente! Execute GenerateNightCity.lua na Command Bar fora do Play.")
    return
end
local markers=set:WaitForChild(CONFIG.SpawnFolder,10)
if not markers then warn("[NPC SPAWNER] Pasta de spawns nao encontrada!");return end

local function positionRig(rig,spawn)
    local hrp=rig:FindFirstChild("HumanoidRootPart",true)
    local hum=rig:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then
        warn("[NPC SPAWNER] Rig nao possui Humanoid/RootPart:",rig.Name)
        return
    end
    if hum.RigType~=Enum.HumanoidRigType.R6 then
        warn("[NPC SPAWNER] Esperado R6:",rig.Name)
    end
    local target=spawn.Position
    -- Usa raycast contra o asfalto, ignorando personagens e marcadores.
    local filter={rig,markers}
    for _,other in ipairs(Workspace:GetChildren()) do
        if other:IsA("Model") and other:FindFirstChildOfClass("Humanoid") then
            table.insert(filter,other)
        end
    end
    local params=RaycastParams.new()
    params.FilterType=Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances=filter
    local result=Workspace:Raycast(target+Vector3.new(0,25,0),Vector3.new(0,-90,0),params)
    local groundY=result and result.Position.Y or spawn.Position.Y-spawn.Size.Y/2
    local direction=CONFIG.FaceDirection
    local dest=CFrame.lookAt(Vector3.new(target.X,0,target.Z),Vector3.new(target.X,0,target.Z)+direction)
    -- Primeiro orienta, depois apoia os pes no chao medindo bounding box.
    rig:PivotTo(CFrame.new(target.X,groundY+5,target.Z)*dest.Rotation)
    local box,size=rig:GetBoundingBox()
    local bottom=box.Position.Y-size.Y/2
    rig:PivotTo(rig:GetPivot()+Vector3.new(0,groundY-bottom+CONFIG.FloorClearance,0))
    hrp.Anchored=true -- o diretor move usando PivotTo
    hum.AutoRotate=false
    print("[NPC SPAWNER] Spawn:",rig.Name,rig:GetPivot().Position)
end
for _,name in ipairs(names) do
    local spawn=markers:FindFirstChild(name.."_Spawn")
    if not spawn then
        warn("[NPC SPAWNER] Marcador ausente:",name.."_Spawn")
    else
        local rig=locate(name)
        if rig then positionRig(rig,spawn) end
    end
end
Workspace:SetAttribute("CinematicNPCsReady",true)
print("[NPC SPAWNER] Concluido.")
