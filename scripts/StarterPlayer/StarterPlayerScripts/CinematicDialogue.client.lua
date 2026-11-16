-- CinematicSeries | StarterPlayerScripts/CinematicDialogue.client.lua
-- Take 01: legendas sincronizadas com opcao de balao nos NPCs.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local RS=game:GetService("ReplicatedStorage")
local guiParent=Players.LocalPlayer:WaitForChild("PlayerGui")
local remote=RS:WaitForChild("Take01Camera")
local CONFIG={Duration=45,TypeSpeed=.025,ShowBubbles=true}
local cues={
    {time=3.0,duration=2.2,name="POLICIAL",rig="Policial",text="EI! PARA AGORA!",color=Color3.fromRGB(90,170,255)},
    {time=7.9,duration=2.4,name="BANDIDO",rig="Bandido",text="VOCE NAO VAI ME PEGAR!",color=Color3.fromRGB(255,120,120)},
    {time=11.7,duration=2.5,name="POLICIAL",rig="Policial",text="PARADO! POLICIA!",color=Color3.fromRGB(90,170,255)},
    {time=19.5,duration=2.2,name="POLICIAL",rig="Policial",text="VOLTA AQUI!",color=Color3.fromRGB(90,170,255)},
    {time=25.1,duration=2,name="BANDIDO",rig="Bandido",text="SAI DA MINHA FRENTE!",color=Color3.fromRGB(255,120,120)},
    {time=30.2,duration=2,name="BANDIDO",rig="Bandido",text="AH! QUASE CAI!",color=Color3.fromRGB(255,120,120)},
    {time=34,duration=2.2,name="POLICIAL",rig="Policial",text="ACABOU A FUGA!",color=Color3.fromRGB(90,170,255)},
    {time=40,duration=3.2,name="BANDIDO",rig="Bandido",text="NAO CHEGA PERTO!",color=Color3.fromRGB(255,120,120)}
}

for _,name in ipairs({"CinematicDialogue","CinematicDialogueV2","CinematicDialogueV3"}) do
    local old=guiParent:FindFirstChild(name);if old then old:Destroy() end
end
local gui=Instance.new("ScreenGui")
gui.Name="CinematicDialogueV3";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true
gui.DisplayOrder=500;gui.Parent=guiParent
local frame=Instance.new("Frame")
frame.Name="Subtitles";frame.AnchorPoint=Vector2.new(.5,1)
frame.Position=UDim2.fromScale(.5,.92);frame.Size=UDim2.new(.8,0,0,92)
frame.BackgroundColor3=Color3.fromRGB(8,11,18)
frame.BackgroundTransparency=.15;frame.BorderSizePixel=0;frame.Visible=false;frame.Parent=gui
local limit=Instance.new("UISizeConstraint");limit.MaxSize=Vector2.new(850,110);limit.Parent=frame
local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,8);corner.Parent=frame
local stroke=Instance.new("UIStroke");stroke.Color=Color3.fromRGB(85,105,135);stroke.Transparency=.4;stroke.Parent=frame
local speaker=Instance.new("TextLabel")
speaker.BackgroundTransparency=1;speaker.Position=UDim2.fromOffset(18,8)
speaker.Size=UDim2.new(1,-36,0,25);speaker.Font=Enum.Font.GothamBold
speaker.TextSize=16;speaker.TextXAlignment=Enum.TextXAlignment.Left;speaker.Parent=frame
local message=Instance.new("TextLabel")
message.BackgroundTransparency=1;message.Position=UDim2.fromOffset(18,35)
message.Size=UDim2.new(1,-36,1,-42);message.Font=Enum.Font.GothamMedium
message.TextSize=20;message.TextColor3=Color3.new(1,1,1)
message.TextWrapped=true;message.TextXAlignment=Enum.TextXAlignment.Left
message.TextYAlignment=Enum.TextYAlignment.Center;message.Parent=frame
local bubbles={}
local function partFor(rigName)
    local rig=workspace:FindFirstChild(rigName)
    if not rig then return nil end
    if rig:IsA("BasePart") then return rig end
    if not rig:IsA("Model") then return nil end
    for _,name in ipairs({"Head","Torso","UpperTorso","HumanoidRootPart"}) do
        local p=rig:FindFirstChild(name,true)
        if p and p:IsA("BasePart") then return p end
    end
    return rig:FindFirstChildWhichIsA("BasePart",true)
end
local function getBubble(name)
    if not CONFIG.ShowBubbles then return nil end
    if bubbles[name] then return bubbles[name] end
    local p=partFor(name)
    if not p then return nil end
    local bb=Instance.new("BillboardGui")
    bb.Name="Bubble_"..name;bb.Adornee=p;bb.Size=UDim2.fromOffset(280,65)
    bb.StudsOffsetWorldSpace=Vector3.new(0,p.Name=="Head" and 1.8 or 3.3,0)
    bb.AlwaysOnTop=true;bb.Enabled=false;bb.Parent=gui
    local bg=Instance.new("Frame");bg.Size=UDim2.fromScale(1,1)
    bg.BackgroundColor3=Color3.fromRGB(12,16,24);bg.BackgroundTransparency=.1;bg.Parent=bb
    local cr=Instance.new("UICorner");cr.CornerRadius=UDim.new(0,6);cr.Parent=bg
    local label=Instance.new("TextLabel");label.Size=UDim2.new(1,-16,1,-10)
    label.Position=UDim2.fromOffset(8,5);label.BackgroundTransparency=1
    label.TextColor3=Color3.new(1,1,1);label.TextSize=15
    label.Font=Enum.Font.GothamBold;label.TextWrapped=true;label.Parent=bg
    bubbles[name]={gui=bb,label=label}
    return bubbles[name]
end
local function hide()
    frame.Visible=false
    for _,b in pairs(bubbles) do b.gui.Enabled=false end
end
local active,startTime,finished=nil,nil,false
local function sync(value)
    if type(value)~="number" or value==startTime then return end
    startTime=value;active=nil;finished=false;hide()
    print("[DIALOGUE] Take sincronizado:",value)
end
remote.OnClientEvent:Connect(sync)
remote:GetAttributeChangedSignal("TakeStartTime"):Connect(function()
    sync(remote:GetAttribute("TakeStartTime"))
end)
sync(remote:GetAttribute("TakeStartTime"))
RunService.RenderStepped:Connect(function()
    if not startTime or finished then return end
    local t=workspace:GetServerTimeNow()-startTime
    if t<0 then return end
    if t>=(remote:GetAttribute("TakeDuration") or CONFIG.Duration) then hide();finished=true;return end
    local cue
    for _,c in ipairs(cues) do
        if t>=c.time and t<c.time+c.duration then cue=c;break end
    end
    if cue~=active then
        active=cue;hide()
        if cue then
            frame.Visible=true;speaker.Text=cue.name
            speaker.TextColor3=cue.color;message.Text=cue.text
            message.MaxVisibleGraphemes=0
            print("[DIALOGUE] Fala:",cue.name,cue.text)
        end
    end
    if not cue then return end
    local count=math.floor((t-cue.time)/CONFIG.TypeSpeed)
    message.MaxVisibleGraphemes=math.clamp(count,0,utf8.len(cue.text) or #cue.text)
    local bubble=getBubble(cue.rig)
    if bubble then bubble.gui.Enabled=true;bubble.label.Text=cue.text end
end)
print("[DIALOGUE] Sistema carregado")
