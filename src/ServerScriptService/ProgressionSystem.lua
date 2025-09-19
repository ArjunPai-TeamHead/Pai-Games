-- Mars Survival Progression System (Server)
-- Handles player progression, rocket building, and planet creation

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local ProgressionSystem = {}

-- Progression state for all players
local playerProgressions = {}

-- Initialize progression system
function ProgressionSystem.Initialize()
    print("Mars Survival Progression System initialized")
    
    -- Create remote events for progression
    ProgressionSystem.CreateRemoteEvents()
    
    -- Connect player events
    Players.PlayerAdded:Connect(ProgressionSystem.OnPlayerJoined)
    Players.PlayerRemoving:Connect(ProgressionSystem.OnPlayerLeaving)
end

-- Create Remote Events
function ProgressionSystem.CreateRemoteEvents()
    local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
    
    -- Rocket building events
    local startRocketProject = Instance.new("RemoteEvent")
    startRocketProject.Name = "StartRocketProject"
    startRocketProject.Parent = remoteEvents
    
    local addRocketComponent = Instance.new("RemoteEvent")
    addRocketComponent.Name = "AddRocketComponent"
    addRocketComponent.Parent = remoteEvents
    
    local launchRocket = Instance.new("RemoteEvent")
    launchRocket.Name = "LaunchRocket"
    launchRocket.Parent = remoteEvents
    
    -- Planet creation events
    local startPlanetProject = Instance.new("RemoteEvent")
    startPlanetProject.Name = "StartPlanetProject"
    startPlanetProject.Parent = remoteEvents
    
    local addPlanetComponent = Instance.new("RemoteEvent")
    addPlanetComponent.Name = "AddPlanetComponent"
    addPlanetComponent.Parent = remoteEvents
    
    local completePlanet = Instance.new("RemoteEvent")
    completePlanet.Name = "CompletePlanet"
    completePlanet.Parent = remoteEvents
    
    -- Progression events
    local updateProgression = Instance.new("RemoteEvent")
    updateProgression.Name = "UpdateProgression"
    updateProgression.Parent = remoteEvents
    
    -- Connect events
    startRocketProject.OnServerEvent:Connect(ProgressionSystem.OnStartRocketProject)
    addRocketComponent.OnServerEvent:Connect(ProgressionSystem.OnAddRocketComponent)
    launchRocket.OnServerEvent:Connect(ProgressionSystem.OnLaunchRocket)
    startPlanetProject.OnServerEvent:Connect(ProgressionSystem.OnStartPlanetProject)
    addPlanetComponent.OnServerEvent:Connect(ProgressionSystem.OnAddPlanetComponent)
    completePlanet.OnServerEvent:Connect(ProgressionSystem.OnCompletePlanet)
end

-- Player Management
function ProgressionSystem.OnPlayerJoined(player)
    local userId = player.UserId
    
    playerProgressions[userId] = {
        rocketProjects = {},
        planetProjects = {},
        achievements = {},
        rank = "SETTLER", -- SETTLER -> ENGINEER -> SCIENTIST -> COMMANDER -> PIONEER
        totalExperience = 0,
        completedProjects = {}
    }
    
    print("Initialized progression for", player.Name)
end

function ProgressionSystem.OnPlayerLeaving(player)
    local userId = player.UserId
    playerProgressions[userId] = nil
end

-- Rocket Building System
function ProgressionSystem.OnStartRocketProject(player, rocketType)
    local userId = player.UserId
    local progression = playerProgressions[userId]
    if not progression then return end
    
    -- Check if player has required rank for rocket building
    if progression.rank == "SETTLER" then
        print(player.Name, "needs higher rank to build rockets")
        return
    end
    
    local rocketId = #progression.rocketProjects + 1
    local rocketProject = {
        id = rocketId,
        type = rocketType or "BASIC",
        startTime = tick(),
        components = {
            ENGINE = false,
            FUEL_TANK = false,
            NAVIGATION = false,
            LIFE_SUPPORT = false,
            HULL = false
        },
        status = "IN_PROGRESS",
        location = Vector3.new(0, 0, 0) -- Will be set by player
    }
    
    table.insert(progression.rocketProjects, rocketProject)
    
    print(player.Name, "started rocket project #" .. rocketId)
    
    ProgressionSystem.UpdatePlayerProgression(player)
    ProgressionSystem.CreateRocketPlatform(player, rocketProject)
end

function ProgressionSystem.OnAddRocketComponent(player, rocketId, componentType)
    local userId = player.UserId
    local progression = playerProgressions[userId]
    if not progression then return end
    
    local rocketProject = progression.rocketProjects[rocketId]
    if not rocketProject or rocketProject.status ~= "IN_PROGRESS" then return end
    
    local requirements = GameConfig.ROCKET_COMPONENTS[componentType]
    if not requirements then return end
    
    -- This would check player's inventory for required materials
    -- For now, we'll simulate successful component addition
    rocketProject.components[componentType] = true
    
    print(player.Name, "added", componentType, "to rocket #" .. rocketId)
    
    -- Check if rocket is complete
    local allComponents = true
    for component, completed in pairs(rocketProject.components) do
        if not completed then
            allComponents = false
            break
        end
    end
    
    if allComponents then
        rocketProject.status = "READY_FOR_LAUNCH"
        print("Rocket #" .. rocketId, "is ready for launch!")
        
        -- Award achievement
        ProgressionSystem.AwardAchievement(player, "ROCKET_BUILDER")
    end
    
    ProgressionSystem.UpdatePlayerProgression(player)
    ProgressionSystem.UpdateRocketVisual(player, rocketProject)
end

function ProgressionSystem.OnLaunchRocket(player, rocketId, destination)
    local userId = player.UserId
    local progression = playerProgressions[userId]
    if not progression then return end
    
    local rocketProject = progression.rocketProjects[rocketId]
    if not rocketProject or rocketProject.status ~= "READY_FOR_LAUNCH" then return end
    
    rocketProject.status = "LAUNCHED"
    rocketProject.launchTime = tick()
    rocketProject.destination = destination or "MARS_ORBIT"
    
    print(player.Name, "launched rocket #" .. rocketId, "to", destination)
    
    -- Award major achievement and rank up
    ProgressionSystem.AwardAchievement(player, "ROCKET_LAUNCHER")
    ProgressionSystem.PromotePlayer(player)
    
    ProgressionSystem.UpdatePlayerProgression(player)
    ProgressionSystem.PlayRocketLaunchEffect(rocketProject)
    
    -- After successful launch, allow planet creation
    if progression.rank == "COMMANDER" or progression.rank == "PIONEER" then
        print(player.Name, "can now create planets!")
    end
end

-- Planet Creation System
function ProgressionSystem.OnStartPlanetProject(player, planetType)
    local userId = player.UserId
    local progression = playerProgressions[userId]
    if not progression then return end
    
    -- Check if player has launched at least one rocket
    local hasLaunchedRocket = false
    for _, rocket in pairs(progression.rocketProjects) do
        if rocket.status == "LAUNCHED" then
            hasLaunchedRocket = true
            break
        end
    end
    
    if not hasLaunchedRocket then
        print(player.Name, "must launch a rocket before creating planets")
        return
    end
    
    local planetId = #progression.planetProjects + 1
    local planetProject = {
        id = planetId,
        type = planetType or "BASIC",
        startTime = tick(),
        components = {
            TERRAFORM_MODULE = false,
            ATMOSPHERE_GENERATOR = false,
            GRAVITY_STABILIZER = false,
            ECOSYSTEM_SEED = false
        },
        status = "IN_PROGRESS",
        size = "SMALL", -- SMALL -> MEDIUM -> LARGE
        biome = "DESERT" -- DESERT -> FOREST -> OCEAN -> MIXED
    }
    
    table.insert(progression.planetProjects, planetProject)
    
    print(player.Name, "started planet project #" .. planetId)
    
    ProgressionSystem.UpdatePlayerProgression(player)
    ProgressionSystem.CreatePlanetaryWorkstation(player, planetProject)
end

function ProgressionSystem.OnAddPlanetComponent(player, planetId, componentType)
    local userId = player.UserId
    local progression = playerProgressions[userId]
    if not progression then return end
    
    local planetProject = progression.planetProjects[planetId]
    if not planetProject or planetProject.status ~= "IN_PROGRESS" then return end
    
    local requirements = GameConfig.PLANET_REQUIREMENTS[componentType]
    if not requirements then return end
    
    -- This would check player's inventory for required materials
    planetProject.components[componentType] = true
    
    print(player.Name, "added", componentType, "to planet #" .. planetId)
    
    -- Check if planet is complete
    local allComponents = true
    for component, completed in pairs(planetProject.components) do
        if not completed then
            allComponents = false
            break
        end
    end
    
    if allComponents then
        planetProject.status = "READY_FOR_CREATION"
        print("Planet #" .. planetId, "is ready for creation!")
    end
    
    ProgressionSystem.UpdatePlayerProgression(player)
    ProgressionSystem.UpdatePlanetVisual(player, planetProject)
end

function ProgressionSystem.OnCompletePlanet(player, planetId)
    local userId = player.UserId
    local progression = playerProgressions[userId]
    if not progression then return end
    
    local planetProject = progression.planetProjects[planetId]
    if not planetProject or planetProject.status ~= "READY_FOR_CREATION" then return end
    
    planetProject.status = "CREATED"
    planetProject.creationTime = tick()
    
    print(player.Name, "created planet #" .. planetId .. "!")
    
    -- Award ultimate achievement
    ProgressionSystem.AwardAchievement(player, "PLANET_CREATOR")
    ProgressionSystem.PromotePlayer(player) -- Promote to PIONEER
    
    ProgressionSystem.UpdatePlayerProgression(player)
    ProgressionSystem.CreateActualPlanet(player, planetProject)
    
    -- Player has achieved the ultimate goal!
    ProgressionSystem.TriggerVictorySequence(player)
end

-- Achievement System
function ProgressionSystem.AwardAchievement(player, achievementId)
    local userId = player.UserId
    local progression = playerProgressions[userId]
    if not progression then return end
    
    if not progression.achievements[achievementId] then
        progression.achievements[achievementId] = {
            earned = tick(),
            title = ProgressionSystem.GetAchievementTitle(achievementId)
        }
        
        print(player.Name, "earned achievement:", achievementId)
        
        -- Award experience based on achievement
        local expReward = ProgressionSystem.GetAchievementExperience(achievementId)
        progression.totalExperience = progression.totalExperience + expReward
        
        ProgressionSystem.UpdatePlayerProgression(player)
    end
end

function ProgressionSystem.GetAchievementTitle(achievementId)
    local titles = {
        ROCKET_BUILDER = "Rocket Engineer",
        ROCKET_LAUNCHER = "Space Pioneer",
        PLANET_CREATOR = "World Builder",
        MASTER_MINER = "Mars Excavator",
        SURVIVAL_EXPERT = "Red Planet Survivor",
        TRADER_MAGNATE = "Interplanetary Merchant"
    }
    return titles[achievementId] or "Unknown Achievement"
end

function ProgressionSystem.GetAchievementExperience(achievementId)
    local rewards = {
        ROCKET_BUILDER = 1000,
        ROCKET_LAUNCHER = 2500,
        PLANET_CREATOR = 5000,
        MASTER_MINER = 500,
        SURVIVAL_EXPERT = 750,
        TRADER_MAGNATE = 800
    }
    return rewards[achievementId] or 100
end

-- Rank System
function ProgressionSystem.PromotePlayer(player)
    local userId = player.UserId
    local progression = playerProgressions[userId]
    if not progression then return end
    
    local rankOrder = {"SETTLER", "ENGINEER", "SCIENTIST", "COMMANDER", "PIONEER"}
    local currentIndex = 1
    
    for i, rank in ipairs(rankOrder) do
        if progression.rank == rank then
            currentIndex = i
            break
        end
    end
    
    if currentIndex < #rankOrder then
        progression.rank = rankOrder[currentIndex + 1]
        print(player.Name, "promoted to", progression.rank)
        
        -- Award experience for promotion
        progression.totalExperience = progression.totalExperience + (currentIndex * 500)
        
        ProgressionSystem.UpdatePlayerProgression(player)
    end
end

-- Visual Effects and World Building
function ProgressionSystem.CreateRocketPlatform(player, rocketProject)
    local platform = Instance.new("Model")
    platform.Name = "RocketPlatform_" .. rocketProject.id
    platform.Parent = workspace
    
    -- Launch pad
    local pad = Instance.new("Part")
    pad.Size = Vector3.new(30, 2, 30)
    pad.Position = Vector3.new(math.random(-500, 500), 1, math.random(-500, 500))
    pad.Material = Enum.Material.Metal
    pad.BrickColor = BrickColor.new("Dark stone grey")
    pad.Anchored = true
    pad.Parent = platform
    
    -- Rocket assembly area
    local assembly = Instance.new("Part")
    assembly.Size = Vector3.new(8, 20, 8)
    assembly.Position = pad.Position + Vector3.new(0, 11, 0)
    assembly.Material = Enum.Material.Metal
    assembly.BrickColor = BrickColor.new("Light stone grey")
    assembly.Anchored = true
    assembly.Transparency = 0.5
    assembly.Parent = platform
    
    rocketProject.location = pad.Position
end

function ProgressionSystem.UpdateRocketVisual(player, rocketProject)
    local platformName = "RocketPlatform_" .. rocketProject.id
    local platform = workspace:FindFirstChild(platformName)
    if not platform then return end
    
    -- Count completed components
    local completedCount = 0
    for _, completed in pairs(rocketProject.components) do
        if completed then completedCount = completedCount + 1 end
    end
    
    -- Update rocket assembly visual
    local assembly = platform:FindFirstChild("Part") -- The transparent rocket frame
    if assembly then
        assembly.Transparency = 0.9 - (completedCount * 0.15) -- Gets more solid as components are added
        
        if rocketProject.status == "READY_FOR_LAUNCH" then
            assembly.Transparency = 0
            assembly.BrickColor = BrickColor.new("Bright red")
            
            -- Add launch effect preparation
            local light = Instance.new("PointLight")
            light.Color = Color3.new(1, 0.5, 0)
            light.Brightness = 2
            light.Range = 50
            light.Parent = assembly
        end
    end
end

function ProgressionSystem.PlayRocketLaunchEffect(rocketProject)
    local platformName = "RocketPlatform_" .. rocketProject.id
    local platform = workspace:FindFirstChild(platformName)
    if not platform then return end
    
    print("ROCKET LAUNCH SEQUENCE INITIATED!")
    
    -- Create massive explosion effect
    local rocket = platform:FindFirstChild("Part")
    if rocket then
        -- Launch sound effect
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxasset://sounds/electronicpingshort.wav" -- Placeholder
        sound.Volume = 1
        sound.Parent = rocket
        sound:Play()
        
        -- Visual effect
        local explosion = Instance.new("Explosion")
        explosion.Position = rocket.Position
        explosion.BlastRadius = 100
        explosion.BlastPressure = 0
        explosion.Parent = workspace
        
        -- Move rocket up and away
        local bodyPosition = Instance.new("BodyPosition")
        bodyPosition.MaxForce = Vector3.new(40000, 40000, 40000)
        bodyPosition.Position = rocket.Position + Vector3.new(0, 1000, 0)
        bodyPosition.Parent = rocket
        
        rocket.Anchored = false
        
        -- Remove after launch
        game:GetService("Debris"):AddItem(platform, 10)
    end
end

function ProgressionSystem.CreatePlanetaryWorkstation(player, planetProject)
    local workstation = Instance.new("Model")
    workstation.Name = "PlanetaryWorkstation_" .. planetProject.id
    workstation.Parent = workspace
    
    -- Main laboratory
    local lab = Instance.new("Part")
    lab.Size = Vector3.new(25, 15, 25)
    lab.Position = Vector3.new(math.random(-800, 800), 7.5, math.random(-800, 800))
    lab.Material = Enum.Material.Glass
    lab.BrickColor = BrickColor.new("Institutional white")
    lab.Anchored = true
    lab.Parent = workstation
    
    -- Planet hologram projector
    local projector = Instance.new("Part")
    projector.Size = Vector3.new(3, 8, 3)
    projector.Position = lab.Position + Vector3.new(0, 4, 0)
    projector.Material = Enum.Material.Neon
    projector.BrickColor = BrickColor.new("Bright blue")
    projector.Anchored = true
    projector.Parent = workstation
    
    planetProject.location = lab.Position
end

function ProgressionSystem.UpdatePlanetVisual(player, planetProject)
    -- Update the hologram as components are added
    local workstationName = "PlanetaryWorkstation_" .. planetProject.id
    local workstation = workspace:FindFirstChild(workstationName)
    if not workstation then return end
    
    local projector = workstation:FindFirstChild("Part") -- The neon projector
    if projector and planetProject.status == "READY_FOR_CREATION" then
        projector.BrickColor = BrickColor.new("Bright green")
    end
end

function ProgressionSystem.CreateActualPlanet(player, planetProject)
    print("Creating planet in the solar system!")
    
    -- Create a new planet object in space
    local planet = Instance.new("Part")
    planet.Name = "Planet_" .. player.Name .. "_" .. planetProject.id
    planet.Size = Vector3.new(200, 200, 200) -- Large planet
    planet.Position = Vector3.new(math.random(-5000, 5000), 1000, math.random(-5000, 5000))
    planet.Material = Enum.Material.Rock
    planet.Shape = Enum.PartType.Ball
    planet.Anchored = true
    
    -- Color based on biome
    if planetProject.biome == "FOREST" then
        planet.BrickColor = BrickColor.new("Bright green")
    elseif planetProject.biome == "OCEAN" then
        planet.BrickColor = BrickColor.new("Bright blue")
    elseif planetProject.biome == "DESERT" then
        planet.BrickColor = BrickColor.new("Tan")
    else
        planet.BrickColor = BrickColor.new("Brown") -- Mixed biome
    end
    
    -- Add atmosphere effect
    local atmosphere = Instance.new("Part")
    atmosphere.Size = planet.Size * 1.2
    atmosphere.Position = planet.Position
    atmosphere.Material = Enum.Material.ForceField
    atmosphere.BrickColor = BrickColor.new("Cyan")
    atmosphere.Transparency = 0.8
    atmosphere.Shape = Enum.PartType.Ball
    atmosphere.Anchored = true
    atmosphere.CanCollide = false
    atmosphere.Parent = planet
    
    planet.Parent = workspace
    
    -- Add planet to a special folder
    local planetsFolder = workspace:FindFirstChild("PlayerPlanets")
    if not planetsFolder then
        planetsFolder = Instance.new("Folder")
        planetsFolder.Name = "PlayerPlanets"
        planetsFolder.Parent = workspace
    end
    
    planet.Parent = planetsFolder
end

function ProgressionSystem.TriggerVictorySequence(player)
    print(player.Name, "HAS ACHIEVED ULTIMATE VICTORY!")
    print("From a simple Mars settler to a planet creator!")
    
    -- Could trigger special effects, victory UI, or other endgame content
    -- This represents the completion of the Mars Survival experience
end

-- Data Management
function ProgressionSystem.UpdatePlayerProgression(player)
    local userId = player.UserId
    local progression = playerProgressions[userId]
    if not progression then return end
    
    -- Send progression data to client
    local updateEvent = ReplicatedStorage:FindFirstChild("RemoteEvents"):FindFirstChild("UpdateProgression")
    if updateEvent then
        updateEvent:FireClient(player, progression)
    end
end

-- Utility Functions
function ProgressionSystem.GetPlayerProgression(userId)
    return playerProgressions[userId]
end

function ProgressionSystem.GetAllPlayerStats()
    local stats = {}
    for userId, progression in pairs(playerProgressions) do
        local player = Players:GetPlayerByUserId(userId)
        if player then
            stats[player.Name] = {
                rank = progression.rank,
                totalExperience = progression.totalExperience,
                rockets = #progression.rocketProjects,
                planets = #progression.planetProjects,
                achievements = 0
            }
            
            for _ in pairs(progression.achievements) do
                stats[player.Name].achievements = stats[player.Name].achievements + 1
            end
        end
    end
    return stats
end

-- Initialize the progression system
ProgressionSystem.Initialize()

return ProgressionSystem