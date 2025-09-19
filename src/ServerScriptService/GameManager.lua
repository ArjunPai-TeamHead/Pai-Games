-- Mars Survival Game Manager (Server)
-- Main server-side game controller

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local GameManager = {}

-- Services
local playerDataStore = DataStoreService:GetDataStore("PlayerData")
local gameDataStore = DataStoreService:GetDataStore("GameData")

-- Game State
local gameState = {
    timeOfDay = 0, -- 0 = dawn, 0.25 = day, 0.75 = dusk, 1 = night
    currentCycle = "DAY",
    dayCount = 1,
    hostileMobsActive = false,
    economyModifier = 1.0
}

-- Player Data Structure
local defaultPlayerData = {
    level = 1,
    experience = 0,
    currency = 100,
    skills = {
        MINING = {level = 1, experience = 0},
        ENGINEERING = {level = 1, experience = 0},
        SURVIVAL = {level = 1, experience = 0},
        COMBAT = {level = 1, experience = 0},
        SCIENCE = {level = 1, experience = 0}
    },
    inventory = {},
    survival = {
        oxygen = GameConfig.STARTING_OXYGEN,
        energy = GameConfig.STARTING_ENERGY,
        warmth = GameConfig.STARTING_WARMTH,
        hunger = GameConfig.STARTING_HUNGER
    },
    currentJob = nil,
    baseLocation = nil,
    structures = {},
    achievements = {},
    rocketProgress = {},
    planetProgress = {}
}

local playerData = {}

-- Initialize Game
function GameManager.Initialize()
    print("Mars Survival Game Manager initialized")
    
    -- Create remote events for client-server communication
    GameManager.CreateRemoteEvents()
    
    -- Start game loops
    GameManager.StartDayNightCycle()
    GameManager.StartSurvivalDecay()
    GameManager.StartEconomySystem()
    
    -- Connect player events
    Players.PlayerAdded:Connect(GameManager.OnPlayerJoined)
    Players.PlayerRemoving:Connect(GameManager.OnPlayerLeaving)
end

-- Create Remote Events
function GameManager.CreateRemoteEvents()
    local remoteEvents = Instance.new("Folder")
    remoteEvents.Name = "RemoteEvents"
    remoteEvents.Parent = ReplicatedStorage
    
    -- Player actions
    local mineResource = Instance.new("RemoteEvent")
    mineResource.Name = "MineResource"
    mineResource.Parent = remoteEvents
    
    local tradeResources = Instance.new("RemoteEvent")
    tradeResources.Name = "TradeResources"
    tradeResources.Parent = remoteEvents
    
    local buildStructure = Instance.new("RemoteEvent")
    buildStructure.Name = "BuildStructure"
    buildStructure.Parent = remoteEvents
    
    local takeJob = Instance.new("RemoteEvent")
    takeJob.Name = "TakeJob"
    takeJob.Parent = remoteEvents
    
    local completeJob = Instance.new("RemoteEvent")
    completeJob.Name = "CompleteJob"
    completeJob.Parent = remoteEvents
    
    -- Data updates
    local updatePlayerData = Instance.new("RemoteEvent")
    updatePlayerData.Name = "UpdatePlayerData"
    updatePlayerData.Parent = remoteEvents
    
    local updateGameState = Instance.new("RemoteEvent")
    updateGameState.Name = "UpdateGameState"
    updateGameState.Parent = remoteEvents
    
    -- Connect events
    mineResource.OnServerEvent:Connect(GameManager.OnMineResource)
    tradeResources.OnServerEvent:Connect(GameManager.OnTradeResources)
    buildStructure.OnServerEvent:Connect(GameManager.OnBuildStructure)
    takeJob.OnServerEvent:Connect(GameManager.OnTakeJob)
    completeJob.OnServerEvent:Connect(GameManager.OnCompleteJob)
end

-- Player Management
function GameManager.OnPlayerJoined(player)
    print("Player joined:", player.Name)
    
    -- Load or create player data
    local success, data = pcall(function()
        return playerDataStore:GetAsync(player.UserId)
    end)
    
    if success and data then
        playerData[player.UserId] = data
        print("Loaded existing data for", player.Name)
    else
        playerData[player.UserId] = {}
        for key, value in pairs(defaultPlayerData) do
            playerData[player.UserId][key] = value
        end
        print("Created new data for", player.Name)
    end
    
    -- Send initial data to client
    local updateEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("UpdatePlayerData")
    updateEvent:FireClient(player, playerData[player.UserId])
    
    local gameStateEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("UpdateGameState")
    gameStateEvent:FireClient(player, gameState)
end

function GameManager.OnPlayerLeaving(player)
    print("Player leaving:", player.Name)
    
    if playerData[player.UserId] then
        -- Save player data
        local success, errorMessage = pcall(function()
            playerDataStore:SetAsync(player.UserId, playerData[player.UserId])
        end)
        
        if success then
            print("Saved data for", player.Name)
        else
            warn("Failed to save data for", player.Name, ":", errorMessage)
        end
        
        playerData[player.UserId] = nil
    end
end

-- Day/Night Cycle
function GameManager.StartDayNightCycle()
    local totalCycleDuration = GameConfig.DAY_DURATION + GameConfig.NIGHT_DURATION + 
                              GameConfig.DAWN_DURATION + GameConfig.DUSK_DURATION
    
    local startTime = tick()
    
    local function updateCycle()
        local elapsed = tick() - startTime
        local cycleProgress = (elapsed % totalCycleDuration) / totalCycleDuration
        
        gameState.timeOfDay = cycleProgress
        
        -- Determine current cycle phase
        local dawnEnd = GameConfig.DAWN_DURATION / totalCycleDuration
        local dayEnd = dawnEnd + (GameConfig.DAY_DURATION / totalCycleDuration)
        local duskEnd = dayEnd + (GameConfig.DUSK_DURATION / totalCycleDuration)
        
        if cycleProgress < dawnEnd then
            gameState.currentCycle = "DAWN"
        elseif cycleProgress < dayEnd then
            gameState.currentCycle = "DAY"
        elseif cycleProgress < duskEnd then
            gameState.currentCycle = "DUSK"
        else
            gameState.currentCycle = "NIGHT"
        end
        
        -- Handle hostile mobs
        local shouldHaveMobs = (gameState.currentCycle == "NIGHT")
        if shouldHaveMobs ~= gameState.hostileMobsActive then
            gameState.hostileMobsActive = shouldHaveMobs
            if shouldHaveMobs then
                GameManager.SpawnHostileMobs()
            else
                GameManager.DespawnHostileMobs()
            end
        end
        
        -- New day check
        local currentDay = math.floor(elapsed / totalCycleDuration) + 1
        if currentDay ~= gameState.dayCount then
            gameState.dayCount = currentDay
            GameManager.OnNewDay()
        end
    end
    
    RunService.Heartbeat:Connect(updateCycle)
end

-- Survival System
function GameManager.StartSurvivalDecay()
    local lastUpdate = tick()
    
    local function updateSurvival()
        local currentTime = tick()
        local deltaTime = currentTime - lastUpdate
        lastUpdate = currentTime
        
        for userId, data in pairs(playerData) do
            local player = Players:GetPlayerByUserId(userId)
            if player then
                -- Calculate decay rates based on time of day
                local oxygenRate = gameState.currentCycle == "NIGHT" and 
                                 GameConfig.OXYGEN_DECAY_RATE_NIGHT or GameConfig.OXYGEN_DECAY_RATE
                local warmthRate = gameState.currentCycle == "NIGHT" and 
                                  GameConfig.WARMTH_DECAY_RATE_NIGHT or GameConfig.WARMTH_DECAY_RATE_DAY
                
                -- Apply decay
                data.survival.oxygen = math.max(0, data.survival.oxygen - (oxygenRate * deltaTime / 60))
                data.survival.energy = math.max(0, data.survival.energy - (GameConfig.ENERGY_DECAY_RATE * deltaTime / 60))
                data.survival.warmth = math.max(0, data.survival.warmth - (warmthRate * deltaTime / 60))
                data.survival.hunger = math.max(0, data.survival.hunger - (GameConfig.HUNGER_DECAY_RATE * deltaTime / 60))
                
                -- Check for death conditions
                if data.survival.oxygen <= 0 or data.survival.energy <= 0 or 
                   data.survival.warmth <= 0 or data.survival.hunger <= 0 then
                    GameManager.HandlePlayerDeath(player)
                end
                
                -- Send updates to client
                local updateEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("UpdatePlayerData")
                updateEvent:FireClient(player, data)
            end
        end
    end
    
    RunService.Heartbeat:Connect(updateSurvival)
end

-- Resource and Mining System
function GameManager.OnMineResource(player, resourceType, miningPower)
    local userId = player.UserId
    local data = playerData[userId]
    if not data then return end
    
    local miningRange = GameConfig.MINING_RANGES[resourceType]
    if not miningRange then return end
    
    -- Calculate amount based on mining power and skill
    local skillLevel = data.skills.MINING.level
    local baseAmount = math.random(miningRange.min, miningRange.max)
    local skillBonus = math.floor(skillLevel / 10)
    local totalAmount = baseAmount + skillBonus + (miningPower or 0)
    
    -- Add to inventory
    if not data.inventory[resourceType] then
        data.inventory[resourceType] = 0
    end
    data.inventory[resourceType] = data.inventory[resourceType] + totalAmount
    
    -- Add experience
    local expGain = GameConfig.MINING_EXPERIENCE[resourceType] * totalAmount
    GameManager.AddSkillExperience(userId, "MINING", expGain)
    
    print(player.Name, "mined", totalAmount, resourceType)
    
    -- Update client
    local updateEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("UpdatePlayerData")
    updateEvent:FireClient(player, data)
end

-- Skill and Experience System
function GameManager.AddSkillExperience(userId, skillName, amount)
    local data = playerData[userId]
    if not data then return end
    
    local skill = data.skills[skillName]
    if not skill then return end
    
    skill.experience = skill.experience + amount
    
    -- Check for level up
    local requiredExp = GameConfig.LEVEL_EXPERIENCE_BASE * (GameConfig.LEVEL_EXPERIENCE_MULTIPLIER ^ (skill.level - 1))
    if skill.experience >= requiredExp then
        skill.level = skill.level + 1
        skill.experience = skill.experience - requiredExp
        
        local player = Players:GetPlayerByUserId(userId)
        if player then
            print(player.Name, "leveled up", skillName, "to level", skill.level)
        end
    end
end

-- Economy System
function GameManager.StartEconomySystem()
    -- Fluctuate prices every 5 minutes
    spawn(function()
        while true do
            wait(300) -- 5 minutes
            gameState.economyModifier = 0.8 + (math.random() * 0.4) -- 0.8 to 1.2
            print("Economy modifier updated to", gameState.economyModifier)
        end
    end)
end

function GameManager.OnTradeResources(player, resourceType, amount, action) -- action: "BUY" or "SELL"
    local userId = player.UserId
    local data = playerData[userId]
    if not data then return end
    
    local baseValue = GameConfig.RESOURCE_VALUES[resourceType]
    if not baseValue then return end
    
    local totalValue = math.floor(baseValue * amount * gameState.economyModifier)
    
    if action == "SELL" then
        if data.inventory[resourceType] and data.inventory[resourceType] >= amount then
            data.inventory[resourceType] = data.inventory[resourceType] - amount
            data.currency = data.currency + totalValue
            print(player.Name, "sold", amount, resourceType, "for", totalValue, "credits")
        end
    elseif action == "BUY" then
        if data.currency >= totalValue then
            data.currency = data.currency - totalValue
            if not data.inventory[resourceType] then
                data.inventory[resourceType] = 0
            end
            data.inventory[resourceType] = data.inventory[resourceType] + amount
            print(player.Name, "bought", amount, resourceType, "for", totalValue, "credits")
        end
    end
    
    local updateEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("UpdatePlayerData")
    updateEvent:FireClient(player, data)
end

-- Hostile Mobs (Night System)
function GameManager.SpawnHostileMobs()
    print("Spawning hostile mobs for night cycle")
    -- Implementation would create actual mob NPCs in the workspace
end

function GameManager.DespawnHostileMobs()
    print("Despawning hostile mobs for day cycle")
    -- Implementation would remove mob NPCs from the workspace
end

function GameManager.OnNewDay()
    print("New day started! Day", gameState.dayCount)
    
    -- Broadcast to all clients
    for _, player in pairs(Players:GetPlayers()) do
        local gameStateEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("UpdateGameState")
        gameStateEvent:FireClient(player, gameState)
    end
end

-- Building System
function GameManager.OnBuildStructure(player, structureType, position)
    local userId = player.UserId
    local data = playerData[userId]
    if not data then return end
    
    local cost = GameConfig.BUILDING_COSTS[structureType]
    if not cost then return end
    
    -- Check if player has required resources
    for resource, amount in pairs(cost) do
        if not data.inventory[resource] or data.inventory[resource] < amount then
            print(player.Name, "does not have enough", resource, "to build", structureType)
            return
        end
    end
    
    -- Deduct resources
    for resource, amount in pairs(cost) do
        data.inventory[resource] = data.inventory[resource] - amount
    end
    
    -- Add structure to player's base
    table.insert(data.structures, {
        type = structureType,
        position = position,
        built = tick()
    })
    
    print(player.Name, "built", structureType, "at", tostring(position))
    
    local updateEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("UpdatePlayerData")
    updateEvent:FireClient(player, data)
end

-- Job System
function GameManager.OnTakeJob(player, jobType)
    local userId = player.UserId
    local data = playerData[userId]
    if not data then return end
    
    local jobInfo = GameConfig.JOBS[jobType]
    if not jobInfo then return end
    
    data.currentJob = {
        type = jobType,
        startTime = tick(),
        progress = 0
    }
    
    print(player.Name, "took job:", jobInfo.name)
    
    local updateEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("UpdatePlayerData")
    updateEvent:FireClient(player, data)
end

function GameManager.OnCompleteJob(player)
    local userId = player.UserId
    local data = playerData[userId]
    if not data or not data.currentJob then return end
    
    local jobInfo = GameConfig.JOBS[data.currentJob.type]
    if not jobInfo then return end
    
    -- Pay player
    data.currency = data.currency + jobInfo.pay
    
    -- Add skill experience bonus
    for _, skill in pairs(jobInfo.xp_bonus) do
        GameManager.AddSkillExperience(userId, skill, 50)
    end
    
    print(player.Name, "completed job:", jobInfo.name, "and earned", jobInfo.pay, "credits")
    
    data.currentJob = nil
    
    local updateEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("UpdatePlayerData")
    updateEvent:FireClient(player, data)
end

function GameManager.HandlePlayerDeath(player)
    local userId = player.UserId
    local data = playerData[userId]
    if not data then return end
    
    print(player.Name, "died! Respawning...")
    
    -- Reset survival stats
    data.survival.oxygen = GameConfig.STARTING_OXYGEN
    data.survival.energy = GameConfig.STARTING_ENERGY
    data.survival.warmth = GameConfig.STARTING_WARMTH
    data.survival.hunger = GameConfig.STARTING_HUNGER
    
    -- Lose some currency as penalty
    data.currency = math.max(0, math.floor(data.currency * 0.9))
    
    local updateEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("UpdatePlayerData")
    updateEvent:FireClient(player, data)
end

-- Initialize the game manager
GameManager.Initialize()

return GameManager