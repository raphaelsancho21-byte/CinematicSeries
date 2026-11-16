-- CinematicSeries / GenerateNightCity.lua
-- COLE NA COMMAND BAR DO ROBLOX STUDIO (MODO EDICAO)
-- Recria somente Workspace.CinematicSeries_Set e posiciona os atores existentes.
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local CONFIG = {
    Origin = Vector3.new(0, 0, 0), -- desloque o SET inteiro
    StreetLength = 330,
    StreetWidth = 30,
    BlockDepth = 78,
    BuildingRows = 8,
    Seed = 2701,
    ApplyGlobalLighting = true,
    AddWetRoad = true,
    AddCars = true,
    AddNeon = true,
    LightBrightness = 5.5,
    LightRange = 42,
    PositionActors = true,
    ExtraStreetFill = true,
}
local rng = Random.new(CONFIG.Seed)
local previous = Workspace:FindFirstChild("CinematicSeries_Set")
if previous then previous:Destroy() end
local set = Instance.new("Model")
set.Name = "CinematicSeries_Set"
set.Parent = Workspace
local function folder(name)
    local f = Instance.new("Folder")
    f.Name = name; f.Parent = set; return f
end
local streets = folder("01_Streets")
local buildings = folder("02_Buildings")
local details = folder("03_Architectural_Details")
local lights = folder("04_StreetLights")
local props = folder("05_Props")
local markers = folder("06_Camera_And_Actor_Markers")
local origin = CONFIG.Origin
local function at(x,y,z) return origin + Vector3.new(x,y,z) end
local function part(parent,name,size,pos,color,material, transparency)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true; p.CanCollide = true; p.CastShadow = true
    p.Size = size; p.Position = pos
    p.Material = material or Enum.Material.Concrete
    p.Color = color or Color3.fromRGB(80,80,80)
    p.Transparency = transparency or 0
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end
local function light(parent,name,pos,color,brightness,range)
    local bulb = part(parent,name,Vector3.new(.6,.6,.6),pos,color,Enum.Material.Neon)
    bulb.CanCollide = false; bulb.CastShadow = false
    local point = Instance.new("PointLight")
    point.Color = color
    point.Brightness = brightness or CONFIG.LightBrightness
    point.Range = range or CONFIG.LightRange
    point.Shadows = true
    point.Parent = bulb
    return bulb
end
local asphalt = Color3.fromRGB(25,29,35)
local cement = Color3.fromRGB(69,72,78)
local curb = Color3.fromRGB(130,132,133)
local L = CONFIG.StreetLength
local W = CONFIG.StreetWidth
-- Superficie/calcadas/rua central em eixo X
part(streets,"Foundation",Vector3.new(L+90,2,CONFIG.BlockDepth*2+W+40),at(0,-2,0),Color3.fromRGB(38,43,44),Enum.Material.Concrete)
part(streets,"Wet_Asphalt_Main",Vector3.new(L,0.45,W),at(0,-.75,0),asphalt,Enum.Material.Asphalt)
for side=-1,1,2 do
    local z=side*(W/2+7)
    part(streets,side==-1 and "South_Sidewalk" or "North_Sidewalk",Vector3.new(L,0.65,14),at(0,-.35,z),cement)
    part(streets,"Curb_"..side,Vector3.new(L,.7,.7),at(0,-.38,side*(W/2+.35)),curb)
end
-- Marcas de trafego e poças
for x=-L/2+8,L/2-8,12 do
    local stripe=part(streets,"Center_Line",Vector3.new(6,.04,.25),at(x,-.49,0),Color3.fromRGB(196,171,87),Enum.Material.SmoothPlastic)
    stripe.CanCollide=false
end
for i=1,16 do
    local x=rng:NextNumber(-L/2+5,L/2-5)
    local z=rng:NextNumber(-W/2+2,W/2-2)
    local puddle=part(streets,"Rain_Puddle_"..i,Vector3.new(rng:NextNumber(2,7),.02,rng:NextNumber(1,3)),at(x,-.505,z),Color3.fromRGB(51,70,84),Enum.Material.Glass,.37)
    puddle.CanCollide=false
end
-- Edificios com fachadas, janelas acesas e apagadas, portas, marquises e escadas
local palette={
    Color3.fromRGB(72,77,89),Color3.fromRGB(92,84,82),
    Color3.fromRGB(59,69,75),Color3.fromRGB(98,96,90),
    Color3.fromRGB(65,68,73)
}
local frontage=L/CONFIG.BuildingRows
for side=-1,1,2 do
    for i=1,CONFIG.BuildingRows do
        local cx=-L/2+(i-.5)*frontage
        local depth=rng:NextNumber(21,36)
        local height=rng:NextInteger(25,55)
        local z=side*(W/2+15+depth/2)
        local col=palette[rng:NextInteger(1,#palette)]
        local b=Instance.new("Model")
        b.Name=(side==-1 and "South_" or "North_").."Block_"..i
        b.Parent=buildings
        local width=frontage-3
        part(b,"Building_Shell",Vector3.new(width,height,depth),at(cx,height/2-1,z),col,Enum.Material.Brick)
        local front= z-side*(depth/2+.07)
        -- janelas nas fachadas voltadas a rua
        local floors=math.max(2,math.floor((height-5)/7))
        for floor=1,floors do
            for window=1,3 do
                local wx=cx+(window-2)*width/4
                local wy=4+floor*6.2
                if wy<height-2 then
                    local lit=rng:NextNumber()>.40
                    local glass=part(details,"Window_"..side.."_"..i.."_"..floor.."_"..window,
                        Vector3.new(width/7,3.5,.12),at(wx,wy,front),
                        lit and Color3.fromRGB(211,170,101) or Color3.fromRGB(21,33,48),
                        lit and Enum.Material.Neon or Enum.Material.Glass,lit and .12 or .08)
                    glass.CanCollide=false
                    part(details,"Window_Lintel",Vector3.new(width/7+.5,.2,.35),at(wx,wy+2,front),Color3.fromRGB(33,35,40),Enum.Material.Metal)
                end
            end
        end
        part(details,"Shopfront",Vector3.new(width-2,6,.35),at(cx,2.35,front),Color3.fromRGB(27,36,47),Enum.Material.Glass,.16)
        part(details,"Entrance",Vector3.new(3.8,6,.45),at(cx-width*.27,2.35,front-.2*side),Color3.fromRGB(33,38,42),Enum.Material.Metal)
        part(details,"Awning",Vector3.new(width-1,.35,3.6),at(cx,7,front-side*1.4),Color3.fromRGB(33,36,40),Enum.Material.Metal)
        part(details,"Roof_Trim",Vector3.new(width+.8,.55,depth+.8),at(cx,height-.6,z),Color3.fromRGB(33,36,40),Enum.Material.Concrete)
        if CONFIG.AddNeon and i%2==0 then
            local sign=part(details,"Neon_Sign",Vector3.new(width*.42,1.1,.3),at(cx,8.5,front-side*.45),i%4==0 and Color3.fromRGB(37,175,205) or Color3.fromRGB(224,66,106),Enum.Material.Neon)
            sign.CanCollide=false
            local surface=Instance.new("SurfaceGui");surface.Face=side==-1 and Enum.NormalId.Back or Enum.NormalId.Front
            surface.Parent=sign
            local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1
            text.Text=i%4==0 and "24H  MART" or "HOTEL  /  BAR";text.TextScaled=true
            text.Font=Enum.Font.GothamBold;text.TextColor3=Color3.new(1,1,1);text.Parent=surface
            light(lights,"Sign_Glow",at(cx,8,front-side*1.8),sign.Color,1.2,12)
        end
        -- telhados: caixas de ventilacao
        for n=1,2 do
            part(details,"Roof_AC_"..i.."_"..n,Vector3.new(3,2.2,3),at(cx+(n==1 and -6 or 6),height+1,z),Color3.fromRGB(72,78,81),Enum.Material.Metal)
        end
    end
end
-- Beco lateral para fuga: abertura visual com piso, muro, caçambas e portão
local alleyX=28
part(streets,"Escape_Alley_Floor",Vector3.new(13,.36,55),at(alleyX,-.69,-W/2-37),Color3.fromRGB(32,35,40),Enum.Material.Asphalt)
for side=-1,1,2 do
    part(details,"Alley_Wall_"..side,Vector3.new(.75,15,48),at(alleyX+side*7,6.5,-W/2-37),Color3.fromRGB(77,76,79),Enum.Material.Brick)
end
light(lights,"Alley_Security_Light",at(alleyX,11,-W/2-30),Color3.fromRGB(174,211,247),2,20)
-- Postes e lanternas com SpotLight direcionado para baixo
for x=-L/2+18,L/2-18,32 do
    for side=-1,1,2 do
        local z=side*(W/2+5)
        local pole=part(lights,"Lamp_Post",Vector3.new(.45,15,.45),at(x,7,z),Color3.fromRGB(57,63,69),Enum.Material.Metal)
        local arm=part(lights,"Lamp_Arm",Vector3.new(3,.28,.28),at(x,14.5,z-side*1.25),Color3.fromRGB(57,63,69),Enum.Material.Metal)
        local cap=part(lights,"Lamp_Head",Vector3.new(2.4,.4,1),at(x,14.35,z-side*2.2),Color3.fromRGB(38,44,48),Enum.Material.Metal)
        local glow=part(lights,"Warm_Lamp",Vector3.new(2,.12,.65),at(x,14.1,z-side*2.2),Color3.fromRGB(255,205,125),Enum.Material.Neon)
        glow.CanCollide=false
        local spot=Instance.new("SpotLight");spot.Face=Enum.NormalId.Bottom
        spot.Angle=110;spot.Range=CONFIG.LightRange;spot.Brightness=CONFIG.LightBrightness
        spot.Color=Color3.fromRGB(255,201,145);spot.Shadows=true;spot.Parent=glow
    end
end
-- Hidrantes, lixo, bancos e cartazes
for i=1,13 do
    local x=-L/2+i*23
    local side=i%2==0 and 1 or -1
    local z=side*(W/2+8)
    part(props,"Trash_Bin_"..i,Vector3.new(2.1,3,1.8),at(x,1.1,z),Color3.fromRGB(44,59,61),Enum.Material.Metal)
    if i%3==0 then
        part(props,"Fire_Hydrant_"..i,Vector3.new(1.1,2,1.1),at(x+4,.5,z),Color3.fromRGB(150,46,48),Enum.Material.Metal)
    end
    if i%4==0 then
        part(props,"Bus_Stop_Bench_"..i,Vector3.new(6,.5,1.4),at(x-4,1,z),Color3.fromRGB(84,76,68),Enum.Material.Wood)
    end
end
-- Veiculos cenograficos (sem IA e sem chassis)
local function staticCar(name,x,z,color)
    local car=Instance.new("Model");car.Name=name;car.Parent=props
    part(car,"Body",Vector3.new(11,2.2,5.5),at(x,1.5,z),color,Enum.Material.Metal)
    part(car,"Cabin",Vector3.new(5.5,2.1,4.7),at(x-.8,3.2,z),Color3.fromRGB(31,45,58),Enum.Material.Glass,.1)
    for dx=-3.3,3.3,6.6 do
        for dz=-1,1,2 do
            local wheel=part(car,"Wheel",Vector3.new(1.7,2,1),at(x+dx,.7,z+dz*2.6),Color3.fromRGB(18,19,22),Enum.Material.SmoothPlastic)
            wheel.CanCollide=true
        end
    end
    for dz=-1,1,2 do
        local tail=part(car,"Rear_Light",Vector3.new(.1,.45,.75),at(x-5.58,1.65,z+dz*1.7),Color3.fromRGB(232,48,42),Enum.Material.Neon)
        tail.CanCollide=false
    end
end
if CONFIG.AddCars then
    staticCar("Parked_Sedan_01",-99,-W/2+2,Color3.fromRGB(37,55,77))
    staticCar("Parked_Sedan_02",112,W/2-2,Color3.fromRGB(100,103,106))
    staticCar("Police_Car_Prop",145,-W/2+2,Color3.fromRGB(35,45,64))
end
-- Marcadores editaveis para setar cenas, sem alterar rigs
local function marker(name,x,y,z,color)
    local p=part(markers,name,Vector3.new(2,.18,2),at(x,y,z),color,Enum.Material.Neon,.45)
    p.CanCollide=false
    p:SetAttribute("CinematicMarker",true)
    return p
end
marker("Bandido_Start",-55,.03,-3,Color3.fromRGB(255,92,92))
marker("Policial_Start",-68,.03,8,Color3.fromRGB(85,165,255))
marker("Chase_Corner",alleyX,.03,-7,Color3.fromRGB(245,215,95))
marker("Escape_Alley",alleyX,.03,-37,Color3.fromRGB(245,215,95))
marker("Camera_Wide",-45,6,15,Color3.fromRGB(90,230,200))
marker("Camera_Alley",alleyX+11,5,-29,Color3.fromRGB(90,230,200))
-- Luz global editavel: preserva scripts e personagens
if CONFIG.ApplyGlobalLighting then
    Lighting.ClockTime=0.55
    Lighting.Brightness=2.6
    Lighting.ExposureCompensation=.22
    Lighting.Ambient=Color3.fromRGB(65,75,97)
    Lighting.OutdoorAmbient=Color3.fromRGB(75,88,112)
    Lighting.EnvironmentDiffuseScale=.35
    Lighting.EnvironmentSpecularScale=.8
    Lighting.GlobalShadows=true
    local atmosphere=Lighting:FindFirstChild("CinematicSeries_Atmosphere")
    if not atmosphere then atmosphere=Instance.new("Atmosphere");atmosphere.Name="CinematicSeries_Atmosphere";atmosphere.Parent=Lighting end
    atmosphere.Density=.2;atmosphere.Offset=.1
    atmosphere.Color=Color3.fromRGB(137,157,190)
    atmosphere.Decay=Color3.fromRGB(36,46,70)
    atmosphere.Glare=.08;atmosphere.Haze=.85
    local cc=Lighting:FindFirstChild("CinematicSeries_ColorGrade")
    if not cc then cc=Instance.new("ColorCorrectionEffect");cc.Name="CinematicSeries_ColorGrade";cc.Parent=Lighting end
    cc.Contrast=.08;cc.Saturation=-.08;cc.TintColor=Color3.fromRGB(218,229,255)
    local bloom=Lighting:FindFirstChild("CinematicSeries_Bloom")
    if not bloom then bloom=Instance.new("BloomEffect");bloom.Name="CinematicSeries_Bloom";bloom.Parent=Lighting end
    bloom.Intensity=.28;bloom.Size=20;bloom.Threshold=1.5
end

-- Preenchimento cinematografico frio: o luar/reflectores iluminam o rosto dos atores.
if CONFIG.ExtraStreetFill then
    for x=-L/2+12,L/2-12,35 do
        local fixture=light(lights,"Cool_Street_Fill_"..math.floor(x),at(x,10,0),Color3.fromRGB(168,203,255),1.65,33)
        fixture.Transparency=1
        fixture.CanCollide=false
        local point=fixture:FindFirstChildOfClass("PointLight")
        if point then point.Shadows=false end
    end
    for _,x in ipairs({-55,-28,28,70}) do
        local fixture=light(lights,"Actor_Key_Light_"..x,at(x,10,-10),Color3.fromRGB(210,226,255),2.1,24)
        fixture.Transparency=1
        fixture.CanCollide=false
        fixture:FindFirstChildOfClass("PointLight").Shadows=false
    end
end
-- Bandido/Policial ficam fora da pasta do set e por isso nunca sao apagados.
local function moveActor(name,markerName)
    local rig=Workspace:FindFirstChild(name)
    local mark=markers:FindFirstChild(markerName)
    if not rig or not rig:IsA("Model") or not mark then
        warn("[CinematicSeries] Nao posicionei",name,"(rig R6 nao encontrado no Workspace)")
        return
    end
    -- Orienta na direcao +X para o primeiro percurso do take.
    local base=CFrame.lookAt(mark.Position,mark.Position+Vector3.new(1,0,0))
    rig:PivotTo(base)
    local boxCF,boxSize=rig:GetBoundingBox()
    local bottom=boxCF.Position.Y-boxSize.Y/2
    local roadTop=at(0,-.75,0).Y+.45/2
    local shiftY=roadTop-bottom+.08
    rig:PivotTo(base+Vector3.new(0,shiftY,0))
    print("[CinematicSeries] Posicionado:",name)
end
if CONFIG.PositionActors then
    moveActor("Bandido","Bandido_Start")
    moveActor("Policial","Policial_Start")
end

print("[CinematicSeries] Mapa noturno gerado em Workspace.CinematicSeries_Set")
print("[CinematicSeries] Edite as pastas e marcadores. Para regenerar, altere CONFIG e execute novamente.")
