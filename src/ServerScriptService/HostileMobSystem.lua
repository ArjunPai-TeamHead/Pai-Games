-- Mars Hostile Mob System (Server)
-- Spawns and manages hostile creatures during night cycles

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local HostileMobSystem = {}

-- Active mobs tracking
local activeMobs = {}
local mobCounter = 0
local isNightTime = false

-- Mob spawn settings
local MAX_MOBS = 20
local SPAWN_RADIUS = 500
local DESPAWN_RADIUS = 800
local SPAWN_COOLDOWN = 5 -- seconds between spawns

-- Initialize the hostile mob system
function HostileMobSystem.Initialize()
    print("Mars Hostile Mob System initialized")
    
    -- Create remote events
    HostileMobSystem.CreateRemoteEvents()
    
    -- Start mob management loop
    HostileMobSystem.StartMobManagement()
end

-- Create Remote Events
function HostileMobSystem.CreateRemoteEvents()
    local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
    
    local attackPlayer = Instance.new("RemoteEvent")
    attackPlayer.Name = "AttackPlayer"
    attackPlayer.Parent = remoteEvents
    
    local mobDeath = Instance.new("RemoteEvent")
    mobDeath.Name = "MobDeath"
    mobDeath.Parent = remoteEvents
    
    local updateMobHealth = Instance.new("RemoteEvent")
    updateMobHealth.Name = "UpdateMobHealth"
    updateMobHealth.Parent = remoteEvents
    
    -- Connect events
    attackPlayer.OnServerEvent:Connect(HostileMobSystem.OnPlayerAttack)
end

-- Mob Management
function HostileMobSystem.StartMobManagement()
    local lastSpawn = 0
    
    RunService.Heartbeat:Connect(function()
        local currentTime = tick()
        
        -- Check if it's night time (this would be set by the main GameManager)
        -- For now, we'll assume night time for testing
        
        if isNightTime and currentTime - lastSpawn >= SPAWN_COOLDOWN then
            if #activeMobs < MAX_MOBS then
                HostileMobSystem.SpawnRandomMob()
                lastSpawn = currentTime
            end
        end
        
        -- Update existing mobs
        HostileMobSystem.UpdateMobs()
        
        -- Clean up distant or dead mobs
        HostileMobSystem.CleanupMobs()
    end)
end

function HostileMobSystem.SetNightTime(nightTime)
    isNightTime = nightTime
    
    if not nightTime then
        -- Despawn all mobs when day comes
        HostileMobSystem.DespawnAllMobs()
    else
        print("Night has fallen - hostile creatures are emerging...")
    end
end

-- Mob Spawning
function HostileMobSystem.SpawnRandomMob()
    local players = Players:GetPlayers()
    if #players == 0 then return end
    
    -- Pick random player to spawn near
    local targetPlayer = players[math.random(1, #players)]
    if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local playerPosition = targetPlayer.Character.HumanoidRootPart.Position
    
    -- Find spawn position around player
    local angle = math.random() * 2 * math.pi
    local distance = math.random(100, SPAWN_RADIUS)
    local spawnPosition = playerPosition + Vector3.new(
        math.cos(angle) * distance,
        0,
        math.sin(angle) * distance
    )
    
    -- Raycast to find ground level
    local ray = workspace:Raycast(spawnPosition + Vector3.new(0, 100, 0), Vector3.new(0, -200, 0))
    if ray then
        spawnPosition = ray.Position + Vector3.new(0, 5, 0)
    end
    
    -- Choose random mob type
    local mobTypes = {"DUST_DEVIL", "MARS_SPIDER", "SAND_CRAWLER"}
    local mobType = mobTypes[math.random(1, #mobTypes)]
    
    HostileMobSystem.SpawnMob(mobType, spawnPosition)
end

function HostileMobSystem.SpawnMob(mobType, position)
    local mobConfig = GameConfig.MOBS[mobType]
    if not mobConfig then return end
    
    mobCounter = mobCounter + 1
    local mobId = "Mob_" .. mobType .. "_" .. mobCounter
    
    -- Create mob model
    local mob = HostileMobSystem.CreateMobModel(mobType, position, mobId)
    
    -- Create mob data
    local mobData = {
        id = mobId,
        type = mobType,
        model = mob,
        health = mobConfig.health,
        maxHealth = mobConfig.health,
        damage = mobConfig.damage,
        speed = mobConfig.speed,
        target = nil,
        lastAttack = 0,
        state = "ROAMING", -- ROAMING, CHASING, ATTACKING
        spawnTime = tick()
    }
    
    activeMobs[mobId] = mobData
    
    print("Spawned", mobType, "at", tostring(position))
end

function HostileMobSystem.CreateMobModel(mobType, position, mobId)
    local mob = Instance.new("Model")
    mob.Name = mobId
    mob.Parent = workspace
    
    local body, head
    
    if mobType == "DUST_DEVIL" then
        -- Swirling dust creature
        body = Instance.new("Part")
        body.Name = "Body"
        body.Size = Vector3.new(6, 12, 6)
        body.Position = position
        body.Material = Enum.Material.Sand
        body.BrickColor = BrickColor.new("Reddish brown")
        body.Shape = Enum.PartType.Cylinder
        body.Anchored = false
        body.CanCollide = true
        body.Parent = mob
        
        -- Add swirling effect
        local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
        bodyAngularVelocity.AngularVelocity = Vector3.new(0, 10, 0)
        bodyAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
        bodyAngularVelocity.Parent = body
        
        head = body -- Dust devils don't have separate heads
        
    elseif mobType == "MARS_SPIDER" then
        -- Multi-legged spider creature
        body = Instance.new("Part")
        body.Name = "Body"
        body.Size = Vector3.new(4, 2, 6)
        body.Position = position
        body.Material = Enum.Material.Rock
        body.BrickColor = BrickColor.new("Really black")
        body.Anchored = false
        body.CanCollide = true
        body.Parent = mob
        
        -- Spider legs (simplified)
        for i = 1, 6 do
            local leg = Instance.new("Part")
            leg.Size = Vector3.new(0.5, 4, 0.5)
            leg.Position = body.Position + Vector3.new(
                (i % 2 == 0 and 3 or -3),
                -1,
                (i - 3) * 1.5
            )
            leg.Material = Enum.Material.Rock
            leg.BrickColor = BrickColor.new("Really black")
            leg.Anchored = false
            leg.CanCollide = false
            leg.Parent = mob
            
            -- Connect leg to body
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = body
            weld.Part1 = leg
            weld.Parent = leg
        end
        
        head = body -- Simplified spider head
        
    elseif mobType == "SAND_CRAWLER" then
        -- Large armored creature
        body = Instance.new("Part")
        body.Name = "Body"
        body.Size = Vector3.new(8, 4, 12)
        body.Position = position
        body.Material = Enum.Material.Rock
        body.BrickColor = BrickColor.new("Brown")
        body.Anchored = false
        body.CanCollide = true
        body.Parent = mob
        
        -- Armored head
        head = Instance.new("Part")
        head.Name = "Head"
        head.Size = Vector3.new(6, 3, 4)
        head.Position = position + Vector3.new(0, 1, 7)
        head.Material = Enum.Material.Rock
        head.BrickColor = BrickColor.new("Dark stone grey")
        head.Anchored = false
        head.CanCollide = true
        head.Parent = mob
        
        -- Connect head to body
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = body
        weld.Part1 = head
        weld.Parent = head
    end
    
    -- Add humanoid for pathfinding and movement
    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = GameConfig.MOBS[mobType].health
    humanoid.Health = GameConfig.MOBS[mobType].health
    humanoid.WalkSpeed = GameConfig.MOBS[mobType].speed
    humanoid.Parent = mob
    
    -- Add humanoid root part
    local rootPart = Instance.new("Part")
    rootPart.Name = "HumanoidRootPart"
    rootPart.Size = Vector3.new(2, 2, 1)
    rootPart.Position = position
    rootPart.Anchored = false
    rootPart.CanCollide = false
    rootPart.Transparency = 1
    rootPart.Parent = mob
    
    -- Connect root part to body
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = rootPart
    weld.Part1 = body
    weld.Parent = rootPart
    
    -- Add health bar
    HostileMobSystem.CreateHealthBar(mob, head)
    
    -- Add glowing eyes effect
    local light = Instance.new("PointLight")
    light.Color = Color3.new(1, 0, 0)
    light.Brightness = 1
    light.Range = 10
    light.Parent = head
    
    return mob
end

function HostileMobSystem.CreateHealthBar(mob, head)
    local healthGui = Instance.new("BillboardGui")
    healthGui.Size = UDim2.new(0, 100, 0, 20)
    healthGui.Adornee = head
    healthGui.Parent = head
    
    local healthFrame = Instance.new("Frame")
    healthFrame.Size = UDim2.new(1, 0, 1, 0)
    healthFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    healthFrame.BorderSizePixel = 1
    healthFrame.Parent = healthGui
    
    local healthBar = Instance.new("Frame")
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.BackgroundColor3 = Color3.new(1, 0, 0)
    healthBar.BorderSizePixel = 0
    healthBar.Name = "HealthBar"
    healthBar.Parent = healthFrame
end

-- Mob AI and Updates
function HostileMobSystem.UpdateMobs()
    for mobId, mobData in pairs(activeMobs) do
        if mobData.model and mobData.model.Parent then
            HostileMobSystem.UpdateMobAI(mobData)
            HostileMobSystem.UpdateMobHealth(mobData)
        else
            -- Mob was destroyed, clean it up
            activeMobs[mobId] = nil
        end
    end
end

function HostileMobSystem.UpdateMobAI(mobData)
    local mob = mobData.model
    local humanoid = mob:FindFirstChild("Humanoid")
    local rootPart = mob:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return end
    
    -- Find nearest player
    local nearestPlayer = nil
    local nearestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
            if distance < nearestDistance then
                nearestDistance = distance
                nearestPlayer = player
            end
        end
    end
    
    -- AI State Machine
    if nearestPlayer and nearestDistance < 100 then
        -- Chase nearby players
        mobData.state = "CHASING"
        mobData.target = nearestPlayer
        
        -- Move towards player
        local targetPosition = nearestPlayer.Character.HumanoidRootPart.Position
        humanoid:MoveTo(targetPosition)
        
        -- Attack if close enough
        if nearestDistance < 10 and tick() - mobData.lastAttack > 2 then
            HostileMobSystem.AttackPlayer(mobData, nearestPlayer)
            mobData.lastAttack = tick()
        end
        
    else
        -- Roam randomly
        mobData.state = "ROAMING"
        mobData.target = nil
        
        -- Random movement every 5 seconds
        if tick() % 5 < 0.1 then
            local randomDirection = Vector3.new(
                math.random(-50, 50),
                0,
                math.random(-50, 50)
            )
            humanoid:MoveTo(rootPart.Position + randomDirection)
        end
    end
end

function HostileMobSystem.UpdateMobHealth(mobData)
    local mob = mobData.model
    local head = mob:FindFirstChild("Head") or mob:FindFirstChild("Body")
    if not head then return end
    
    local healthGui = head:FindFirstChild("BillboardGui")
    if healthGui then
        local healthBar = healthGui:FindFirstChild("Frame"):FindFirstChild("HealthBar")
        if healthBar then
            local healthPercent = mobData.health / mobData.maxHealth
            healthBar.Size = UDim2.new(healthPercent, 0, 1, 0)
            
            -- Change color based on health
            if healthPercent > 0.7 then
                healthBar.BackgroundColor3 = Color3.new(0, 1, 0) -- Green
            elseif healthPercent > 0.3 then
                healthBar.BackgroundColor3 = Color3.new(1, 1, 0) -- Yellow
            else
                healthBar.BackgroundColor3 = Color3.new(1, 0, 0) -- Red
            end
        end
    end
end

-- Combat System
function HostileMobSystem.AttackPlayer(mobData, player)
    if not player.Character or not player.Character:FindFirstChild("Humanoid") then return end
    
    print(mobData.id, "attacks", player.Name, "for", mobData.damage, "damage")
    
    -- This would normally damage the player's survival stats
    -- For now, we'll just create a visual effect
    HostileMobSystem.CreateAttackEffect(mobData.model, player.Character)
    
    -- Send attack event to client for UI effects
    local attackEvent = ReplicatedStorage:FindFirstChild("RemoteEvents"):FindFirstChild("AttackPlayer")
    if attackEvent then
        attackEvent:FireClient(player, mobData.id, mobData.damage)
    end
end

function HostileMobSystem.CreateAttackEffect(mob, character)
    local mobPosition = mob:FindFirstChild("HumanoidRootPart").Position
    local playerPosition = character:FindFirstChild("HumanoidRootPart").Position
    
    -- Create attack beam/effect
    local beam = Instance.new("Part")
    beam.Size = Vector3.new(0.5, 0.5, (mobPosition - playerPosition).Magnitude)
    beam.Position = mobPosition:Lerp(playerPosition, 0.5)
    beam.Material = Enum.Material.Neon
    beam.BrickColor = BrickColor.new("Really red")
    beam.Anchored = true
    beam.CanCollide = false
    beam.Parent = workspace
    
    -- Look at target
    beam.CFrame = CFrame.lookAt(mobPosition, playerPosition)
    
    -- Remove effect after short time
    game:GetService("Debris"):AddItem(beam, 0.3)
end

function HostileMobSystem.OnPlayerAttack(player, mobId, damage)
    local mobData = activeMobs[mobId]
    if not mobData then return end
    
    -- Take damage
    mobData.health = math.max(0, mobData.health - (damage or 25))
    
    print(player.Name, "dealt", damage or 25, "damage to", mobId)
    
    -- Check if mob died
    if mobData.health <= 0 then
        HostileMobSystem.KillMob(mobData, player)
    end
end

function HostileMobSystem.KillMob(mobData, killer)
    print(mobData.id, "was killed by", killer and killer.Name or "unknown")
    
    -- Create death effect
    if mobData.model and mobData.model:FindFirstChild("HumanoidRootPart") then
        local explosion = Instance.new("Explosion")
        explosion.Position = mobData.model.HumanoidRootPart.Position
        explosion.BlastRadius = 15
        explosion.BlastPressure = 0
        explosion.Parent = workspace
    end
    
    -- Remove mob
    if mobData.model then
        mobData.model:Destroy()
    end
    
    activeMobs[mobData.id] = nil
    
    -- Award experience to killer
    if killer then
        -- This would give combat experience to the player
        print(killer.Name, "gained combat experience")
    end
end

-- Cleanup
function HostileMobSystem.CleanupMobs()
    for mobId, mobData in pairs(activeMobs) do
        local mob = mobData.model
        if not mob or not mob.Parent then
            activeMobs[mobId] = nil
            
        elseif mob:FindFirstChild("HumanoidRootPart") then
            -- Check if mob is too far from all players
            local tooFar = true
            local mobPosition = mob.HumanoidRootPart.Position
            
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (player.Character.HumanoidRootPart.Position - mobPosition).Magnitude
                    if distance < DESPAWN_RADIUS then
                        tooFar = false
                        break
                    end
                end
            end
            
            if tooFar then
                print("Despawning distant mob:", mobId)
                mob:Destroy()
                activeMobs[mobId] = nil
            end
        end
    end
end

function HostileMobSystem.DespawnAllMobs()
    print("Despawning all hostile mobs (dawn)")
    
    for mobId, mobData in pairs(activeMobs) do
        if mobData.model then
            mobData.model:Destroy()
        end
    end
    
    activeMobs = {}
end

-- Utility Functions
function HostileMobSystem.GetActiveMobCount()
    local count = 0
    for _ in pairs(activeMobs) do
        count = count + 1
    end
    return count
end

function HostileMobSystem.GetMobInfo(mobId)
    return activeMobs[mobId]
end

-- For testing purposes
function HostileMobSystem.ForceSpawnMob(mobType, position)
    HostileMobSystem.SpawnMob(mobType, position)
end

-- Initialize the hostile mob system
HostileMobSystem.Initialize()

return HostileMobSystem