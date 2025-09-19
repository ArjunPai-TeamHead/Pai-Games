-- Mars World Generator (Server)
-- Generates the Mars surface environment with mining deposits, trading posts, and structures

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local WorldGenerator = {}

-- World settings
local WORLD_SIZE = 2000 -- Size of the playable area
local DEPOSIT_COUNT = 200 -- Number of mineral deposits
local STRUCTURE_COUNT = 10 -- Number of pre-built structures

-- Initialize the Mars world
function WorldGenerator.GenerateWorld()
    print("Generating Mars surface world...")
    
    -- Setup lighting for Mars
    WorldGenerator.SetupMarsLighting()
    
    -- Generate terrain
    WorldGenerator.GenerateTerrain()
    
    -- Generate mineral deposits
    WorldGenerator.GenerateMineralDeposits()
    
    -- Generate structures
    WorldGenerator.GenerateStructures()
    
    -- Generate atmospheric effects
    WorldGenerator.GenerateAtmosphere()
    
    print("Mars world generation complete!")
end

-- Mars Lighting Setup
function WorldGenerator.SetupMarsLighting()
    Lighting.Ambient = Color3.new(0.4, 0.2, 0.1) -- Reddish ambient light
    Lighting.Brightness = 2
    Lighting.ShadowSoftness = 0.2
    Lighting.Technology = Enum.Technology.Future
    
    -- Mars sky
    local sky = Instance.new("Sky")
    sky.SkyboxBk = "rbxasset://sky/mars_bk.jpg"
    sky.SkyboxDn = "rbxasset://sky/mars_dn.jpg"
    sky.SkyboxFt = "rbxasset://sky/mars_ft.jpg"
    sky.SkyboxLf = "rbxasset://sky/mars_lf.jpg"
    sky.SkyboxRt = "rbxasset://sky/mars_rt.jpg"
    sky.SkyboxUp = "rbxasset://sky/mars_up.jpg"
    sky.Parent = Lighting
    
    -- Sun (represents the distant sun as seen from Mars)
    local sun = Instance.new("SunRaysEffect")
    sun.Intensity = 0.5
    sun.Spread = 0.2
    sun.Parent = Lighting
end

-- Terrain Generation
function WorldGenerator.GenerateTerrain()
    local terrain = workspace.Terrain
    
    -- Create base ground
    local groundRegion = Region3.new(
        Vector3.new(-WORLD_SIZE/2, -50, -WORLD_SIZE/2),
        Vector3.new(WORLD_SIZE/2, 0, WORLD_SIZE/2)
    )
    
    terrain:FillRegion(groundRegion, 4, Enum.Material.Mars)
    
    -- Add some hills and craters
    for i = 1, 20 do
        local x = math.random(-WORLD_SIZE/2, WORLD_SIZE/2)
        local z = math.random(-WORLD_SIZE/2, WORLD_SIZE/2)
        local radius = math.random(50, 150)
        local height = math.random(10, 40)
        
        -- Create hill
        local hillRegion = Region3.new(
            Vector3.new(x - radius, 0, z - radius),
            Vector3.new(x + radius, height, z + radius)
        )
        
        terrain:FillRegion(hillRegion, 4, Enum.Material.Rock)
    end
    
    -- Add craters
    for i = 1, 10 do
        local x = math.random(-WORLD_SIZE/2, WORLD_SIZE/2)
        local z = math.random(-WORLD_SIZE/2, WORLD_SIZE/2)
        local radius = math.random(30, 80)
        local depth = math.random(5, 20)
        
        local craterRegion = Region3.new(
            Vector3.new(x - radius, -depth, z - radius),
            Vector3.new(x + radius, 0, z + radius)
        )
        
        terrain:FillRegion(craterRegion, 4, Enum.Material.Air)
    end
end

-- Mineral Deposit Generation
function WorldGenerator.GenerateMineralDeposits()
    local deposits = Instance.new("Folder")
    deposits.Name = "MineralDeposits"
    deposits.Parent = workspace
    
    -- Iron deposits (most common)
    WorldGenerator.CreateDepositCluster("IRON", 80, Color3.new(0.4, 0.3, 0.2), deposits)
    
    -- Copper deposits
    WorldGenerator.CreateDepositCluster("COPPER", 50, Color3.new(0.7, 0.4, 0.2), deposits)
    
    -- Titanium deposits (less common)
    WorldGenerator.CreateDepositCluster("TITANIUM", 30, Color3.new(0.6, 0.6, 0.7), deposits)
    
    -- Rare earth deposits (rare)
    WorldGenerator.CreateDepositCluster("RARE_EARTH", 15, Color3.new(0.8, 0.2, 0.8), deposits)
    
    -- Ice deposits (important for survival)
    WorldGenerator.CreateDepositCluster("ICE", 25, Color3.new(0.7, 0.9, 1), deposits)
end

function WorldGenerator.CreateDepositCluster(resourceType, count, color, parent)
    for i = 1, count do
        local x = math.random(-WORLD_SIZE/2 + 100, WORLD_SIZE/2 - 100)
        local z = math.random(-WORLD_SIZE/2 + 100, WORLD_SIZE/2 - 100)
        
        -- Raycast to find ground level
        local ray = workspace:Raycast(Vector3.new(x, 100, z), Vector3.new(0, -200, 0))
        local y = ray and ray.Position.Y or 0
        
        local deposit = Instance.new("Part")
        deposit.Name = "Mineral_" .. resourceType .. "_" .. i
        deposit.Size = Vector3.new(
            math.random(5, 12),
            math.random(3, 8),
            math.random(5, 12)
        )
        deposit.Position = Vector3.new(x, y + deposit.Size.Y/2, z)
        deposit.Material = Enum.Material.Rock
        deposit.Color = color
        deposit.Anchored = true
        deposit.CanCollide = true
        deposit.Shape = Enum.PartType.Block
        
        -- Add some randomness to shape
        local mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.Brick
        mesh.Scale = Vector3.new(
            0.8 + math.random() * 0.4,
            0.8 + math.random() * 0.4,
            0.8 + math.random() * 0.4
        )
        mesh.Parent = deposit
        
        -- Add mining indicator
        local indicator = Instance.new("BillboardGui")
        indicator.Size = UDim2.new(0, 100, 0, 50)
        indicator.Adornee = deposit
        indicator.Parent = deposit
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = resourceType
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextScaled = true
        label.Font = Enum.Font.SourceSansBold
        label.Parent = indicator
        
        -- Add glow effect for rare materials
        if resourceType == "RARE_EARTH" or resourceType == "TITANIUM" then
            local light = Instance.new("PointLight")
            light.Color = color
            light.Brightness = 0.5
            light.Range = 15
            light.Parent = deposit
        end
        
        deposit.Parent = parent
    end
end

-- Structure Generation
function WorldGenerator.GenerateStructures()
    local structures = Instance.new("Folder")
    structures.Name = "Structures"
    structures.Parent = workspace
    
    -- Central trading post
    WorldGenerator.CreateTradingPost(Vector3.new(0, 0, 0), structures)
    
    -- Job board near trading post
    WorldGenerator.CreateJobBoard(Vector3.new(50, 0, 0), structures)
    
    -- Basic shelters around the map
    for i = 1, 5 do
        local angle = (i - 1) * (2 * math.pi / 5)
        local distance = 300
        local x = math.cos(angle) * distance
        local z = math.sin(angle) * distance
        
        WorldGenerator.CreateBasicShelter(Vector3.new(x, 0, z), structures)
    end
    
    -- Research stations
    for i = 1, 3 do
        local x = math.random(-500, 500)
        local z = math.random(-500, 500)
        
        WorldGenerator.CreateResearchStation(Vector3.new(x, 0, z), structures)
    end
end

function WorldGenerator.CreateTradingPost(position, parent)
    local tradingPost = Instance.new("Model")
    tradingPost.Name = "TradingPost_Central"
    
    -- Main building
    local building = Instance.new("Part")
    building.Name = "TradingPost"
    building.Size = Vector3.new(20, 15, 20)
    building.Position = position + Vector3.new(0, 7.5, 0)
    building.Material = Enum.Material.Metal
    building.BrickColor = BrickColor.new("Really black")
    building.Anchored = true
    building.CanCollide = true
    building.Parent = tradingPost
    
    -- Trading sign
    local sign = Instance.new("Part")
    sign.Size = Vector3.new(15, 8, 1)
    sign.Position = position + Vector3.new(0, 20, -10.5)
    sign.Material = Enum.Material.Neon
    sign.BrickColor = BrickColor.new("Bright green")
    sign.Anchored = true
    sign.CanCollide = false
    sign.Parent = tradingPost
    
    local signGui = Instance.new("SurfaceGui")
    signGui.Face = Enum.NormalId.Front
    signGui.Parent = sign
    
    local signText = Instance.new("TextLabel")
    signText.Size = UDim2.new(1, 0, 1, 0)
    signText.BackgroundTransparency = 1
    signText.Text = "TRADING POST"
    signText.TextColor3 = Color3.new(0, 0, 0)
    signText.TextScaled = true
    signText.Font = Enum.Font.SourceSansBold
    signText.Parent = signGui
    
    -- Landing pad
    local pad = Instance.new("Part")
    pad.Size = Vector3.new(30, 1, 30)
    pad.Position = position + Vector3.new(0, 0.5, 0)
    pad.Material = Enum.Material.Metal
    pad.BrickColor = BrickColor.new("Dark stone grey")
    pad.Anchored = true
    pad.CanCollide = true
    pad.Parent = tradingPost
    
    tradingPost.Parent = parent
end

function WorldGenerator.CreateJobBoard(position, parent)
    local jobBoard = Instance.new("Model")
    jobBoard.Name = "JobBoard"
    
    local post = Instance.new("Part")
    post.Name = "JobBoard"
    post.Size = Vector3.new(1, 8, 6)
    post.Position = position + Vector3.new(0, 4, 0)
    post.Material = Enum.Material.Wood
    post.BrickColor = BrickColor.new("Brown")
    post.Anchored = true
    post.CanCollide = true
    post.Parent = jobBoard
    
    local board = Instance.new("Part")
    board.Size = Vector3.new(0.5, 6, 4)
    board.Position = position + Vector3.new(0.75, 4, 0)
    board.Material = Enum.Material.Wood
    board.BrickColor = BrickColor.new("Tan")
    board.Anchored = true
    board.CanCollide = false
    board.Parent = jobBoard
    
    local boardGui = Instance.new("SurfaceGui")
    boardGui.Face = Enum.NormalId.Front
    boardGui.Parent = board
    
    local boardText = Instance.new("TextLabel")
    boardText.Size = UDim2.new(1, 0, 1, 0)
    boardText.BackgroundTransparency = 1
    boardText.Text = "JOB BOARD\n\nClick for Available Jobs"
    boardText.TextColor3 = Color3.new(0, 0, 0)
    boardText.TextScaled = true
    boardText.Font = Enum.Font.SourceSans
    boardText.Parent = boardGui
    
    jobBoard.Parent = parent
end

function WorldGenerator.CreateBasicShelter(position, parent)
    local shelter = Instance.new("Model")
    shelter.Name = "BasicShelter"
    
    -- Dome-shaped shelter
    local dome = Instance.new("Part")
    dome.Name = "Shelter"
    dome.Size = Vector3.new(12, 8, 12)
    dome.Position = position + Vector3.new(0, 4, 0)
    dome.Material = Enum.Material.Metal
    dome.BrickColor = BrickColor.new("Medium stone grey")
    dome.Anchored = true
    dome.CanCollide = true
    dome.Shape = Enum.PartType.Ball
    dome.Parent = shelter
    
    -- Entry airlock
    local airlock = Instance.new("Part")
    airlock.Size = Vector3.new(3, 6, 3)
    airlock.Position = position + Vector3.new(7, 3, 0)
    airlock.Material = Enum.Material.Metal
    airlock.BrickColor = BrickColor.new("Really black")
    airlock.Anchored = true
    airlock.CanCollide = true
    airlock.Parent = shelter
    
    -- Life support indicator
    local light = Instance.new("PointLight")
    light.Color = Color3.new(0, 1, 0)
    light.Brightness = 1
    light.Range = 20
    light.Parent = dome
    
    shelter.Parent = parent
end

function WorldGenerator.CreateResearchStation(position, parent)
    local station = Instance.new("Model")
    station.Name = "ResearchStation"
    
    local lab = Instance.new("Part")
    lab.Size = Vector3.new(15, 10, 25)
    lab.Position = position + Vector3.new(0, 5, 0)
    lab.Material = Enum.Material.Glass
    lab.BrickColor = BrickColor.new("Institutional white")
    lab.Anchored = true
    lab.CanCollide = true
    lab.Parent = station
    
    -- Solar panels
    for i = 1, 4 do
        local panel = Instance.new("Part")
        panel.Size = Vector3.new(8, 0.5, 12)
        panel.Position = position + Vector3.new((i-2.5)*10, 12, 0)
        panel.Material = Enum.Material.Glass
        panel.BrickColor = BrickColor.new("Really black")
        panel.Anchored = true
        panel.CanCollide = false
        panel.Parent = station
    end
    
    -- Research equipment indicator
    local light = Instance.new("PointLight")
    light.Color = Color3.new(0, 0, 1)
    light.Brightness = 0.8
    light.Range = 15
    light.Parent = lab
    
    station.Parent = parent
end

-- Atmospheric Effects
function WorldGenerator.GenerateAtmosphere()
    -- Mars dust storm effect (occasional)
    local dustFolder = Instance.new("Folder")
    dustFolder.Name = "AtmosphericEffects"
    dustFolder.Parent = workspace
    
    -- Create dust particles
    spawn(function()
        while true do
            wait(math.random(300, 600)) -- Dust storm every 5-10 minutes
            WorldGenerator.CreateDustStorm()
            wait(60) -- Storm lasts 1 minute
            WorldGenerator.ClearDustStorm()
        end
    end)
end

function WorldGenerator.CreateDustStorm()
    print("Mars dust storm beginning...")
    
    -- Reduce visibility
    local originalAmbient = Lighting.Ambient
    local stormTween = TweenService:Create(Lighting, TweenInfo.new(10), {
        Ambient = Color3.new(0.2, 0.1, 0.05)
    })
    stormTween:Play()
    
    -- Add dust particles throughout the world
    for i = 1, 50 do
        local dust = Instance.new("Part")
        dust.Name = "DustParticle"
        dust.Size = Vector3.new(2, 2, 2)
        dust.Position = Vector3.new(
            math.random(-WORLD_SIZE/2, WORLD_SIZE/2),
            math.random(5, 50),
            math.random(-WORLD_SIZE/2, WORLD_SIZE/2)
        )
        dust.Material = Enum.Material.Sand
        dust.BrickColor = BrickColor.new("Reddish brown")
        dust.Anchored = false
        dust.CanCollide = false
        dust.Transparency = 0.7
        dust.Parent = workspace
        
        -- Make dust move with wind
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(4000, 0, 4000)
        bodyVelocity.Velocity = Vector3.new(
            math.random(-20, 20),
            0,
            math.random(-20, 20)
        )
        bodyVelocity.Parent = dust
        
        -- Remove dust after storm
        game:GetService("Debris"):AddItem(dust, 70)
    end
end

function WorldGenerator.ClearDustStorm()
    print("Mars dust storm ending...")
    
    -- Restore visibility
    local clearTween = TweenService:Create(Lighting, TweenInfo.new(5), {
        Ambient = Color3.new(0.4, 0.2, 0.1)
    })
    clearTween:Play()
    
    -- Remove remaining dust particles
    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name == "DustParticle" then
            obj:Destroy()
        end
    end
end

-- Initialize world generation
WorldGenerator.GenerateWorld()

return WorldGenerator