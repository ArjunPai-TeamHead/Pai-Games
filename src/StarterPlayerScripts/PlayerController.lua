-- Mars Survival Player Controller (Client)
-- Handles player movement, interactions, and UI on Mars surface

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local player = Players.LocalPlayer
local character = player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local PlayerController = {}

-- Player state
local playerData = {}
local gameState = {}
local selectedTool = nil
local isInShelter = false
local oxygenWarningActive = false

-- UI Elements (will be created)
local playerGui = player:WaitForChild("PlayerGui")
local mainUI = nil

-- Remote Events
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local mineResourceEvent = remoteEvents:WaitForChild("MineResource")
local tradeResourcesEvent = remoteEvents:WaitForChild("TradeResources")
local buildStructureEvent = remoteEvents:WaitForChild("BuildStructure")
local takeJobEvent = remoteEvents:WaitForChild("TakeJob")
local completeJobEvent = remoteEvents:WaitForChild("CompleteJob")
local updatePlayerDataEvent = remoteEvents:WaitForChild("UpdatePlayerData")
local updateGameStateEvent = remoteEvents:WaitForChild("UpdateGameState")

-- Initialize Player Controller
function PlayerController.Initialize()
    print("Mars Survival Player Controller initialized for", player.Name)
    
    -- Setup character
    PlayerController.SetupCharacter()
    
    -- Create UI
    PlayerController.CreateUI()
    
    -- Setup input handling
    PlayerController.SetupInputs()
    
    -- Connect remote events
    updatePlayerDataEvent.OnClientEvent:Connect(PlayerController.OnPlayerDataUpdate)
    updateGameStateEvent.OnClientEvent:Connect(PlayerController.OnGameStateUpdate)
    
    -- Start update loops
    PlayerController.StartUpdateLoops()
end

-- Character Setup
function PlayerController.SetupCharacter()
    -- Add Mars-specific effects to character
    local head = character:WaitForChild("Head")
    
    -- Add helmet effect (oxygen supply indicator)
    local helmet = Instance.new("Part")
    helmet.Name = "Helmet"
    helmet.Size = Vector3.new(2.2, 2.2, 2.2)
    helmet.Material = Enum.Material.ForceField
    helmet.BrickColor = BrickColor.new("Cyan")
    helmet.Transparency = 0.8
    helmet.CanCollide = false
    helmet.Shape = Enum.PartType.Ball
    
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = head
    weld.Part1 = helmet
    weld.Parent = helmet
    helmet.Parent = character
    
    -- Modify walkspeed for Mars gravity (lower gravity = faster movement)
    humanoid.WalkSpeed = 20 -- Slightly faster than normal due to lower Mars gravity
    humanoid.JumpPower = 60 -- Higher jumps on Mars
end

-- UI Creation
function PlayerController.CreateUI()
    -- Main UI Screen
    mainUI = Instance.new("ScreenGui")
    mainUI.Name = "MarsUI"
    mainUI.Parent = playerGui
    
    -- Survival Stats Panel
    local survivalFrame = Instance.new("Frame")
    survivalFrame.Name = "SurvivalStats"
    survivalFrame.Size = UDim2.new(0, 300, 0, 150)
    survivalFrame.Position = UDim2.new(0, 10, 0, 10)
    survivalFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    survivalFrame.BackgroundTransparency = 0.3
    survivalFrame.BorderSizePixel = 0
    survivalFrame.Parent = mainUI
    
    -- Oxygen Bar
    local oxygenLabel = Instance.new("TextLabel")
    oxygenLabel.Size = UDim2.new(1, 0, 0, 25)
    oxygenLabel.Position = UDim2.new(0, 0, 0, 5)
    oxygenLabel.BackgroundTransparency = 1
    oxygenLabel.Text = "Oxygen: 100%"
    oxygenLabel.TextColor3 = Color3.new(0, 1, 1)
    oxygenLabel.TextScaled = true
    oxygenLabel.Name = "OxygenLabel"
    oxygenLabel.Parent = survivalFrame
    
    local oxygenBar = Instance.new("Frame")
    oxygenBar.Size = UDim2.new(0.9, 0, 0, 8)
    oxygenBar.Position = UDim2.new(0.05, 0, 0, 30)
    oxygenBar.BackgroundColor3 = Color3.new(0, 1, 1)
    oxygenBar.BorderSizePixel = 0
    oxygenBar.Name = "OxygenBar"
    oxygenBar.Parent = survivalFrame
    
    -- Energy Bar
    local energyLabel = Instance.new("TextLabel")
    energyLabel.Size = UDim2.new(1, 0, 0, 25)
    energyLabel.Position = UDim2.new(0, 0, 0, 40)
    energyLabel.BackgroundTransparency = 1
    energyLabel.Text = "Energy: 100%"
    energyLabel.TextColor3 = Color3.new(1, 1, 0)
    energyLabel.TextScaled = true
    energyLabel.Name = "EnergyLabel"
    energyLabel.Parent = survivalFrame
    
    local energyBar = Instance.new("Frame")
    energyBar.Size = UDim2.new(0.9, 0, 0, 8)
    energyBar.Position = UDim2.new(0.05, 0, 0, 65)
    energyBar.BackgroundColor3 = Color3.new(1, 1, 0)
    energyBar.BorderSizePixel = 0
    energyBar.Name = "EnergyBar"
    energyBar.Parent = survivalFrame
    
    -- Warmth Bar
    local warmthLabel = Instance.new("TextLabel")
    warmthLabel.Size = UDim2.new(1, 0, 0, 25)
    warmthLabel.Position = UDim2.new(0, 0, 0, 75)
    warmthLabel.BackgroundTransparency = 1
    warmthLabel.Text = "Warmth: 100%"
    warmthLabel.TextColor3 = Color3.new(1, 0.5, 0)
    warmthLabel.TextScaled = true
    warmthLabel.Name = "WarmthLabel"
    warmthLabel.Parent = survivalFrame
    
    local warmthBar = Instance.new("Frame")
    warmthBar.Size = UDim2.new(0.9, 0, 0, 8)
    warmthBar.Position = UDim2.new(0.05, 0, 0, 100)
    warmthBar.BackgroundColor3 = Color3.new(1, 0.5, 0)
    warmthBar.BorderSizePixel = 0
    warmthBar.Name = "WarmthBar"
    warmthBar.Parent = survivalFrame
    
    -- Hunger Bar
    local hungerLabel = Instance.new("TextLabel")
    hungerLabel.Size = UDim2.new(1, 0, 0, 25)
    hungerLabel.Position = UDim2.new(0, 0, 0, 110)
    hungerLabel.BackgroundTransparency = 1
    hungerLabel.Text = "Hunger: 100%"
    hungerLabel.TextColor3 = Color3.new(0, 1, 0)
    hungerLabel.TextScaled = true
    hungerLabel.Name = "HungerLabel"
    hungerLabel.Parent = survivalFrame
    
    local hungerBar = Instance.new("Frame")
    hungerBar.Size = UDim2.new(0.9, 0, 0, 8)
    hungerBar.Position = UDim2.new(0.05, 0, 0, 135)
    hungerBar.BackgroundColor3 = Color3.new(0, 1, 0)
    hungerBar.BorderSizePixel = 0
    hungerBar.Name = "HungerBar"
    hungerBar.Parent = survivalFrame
    
    -- Game Info Panel
    local infoFrame = Instance.new("Frame")
    infoFrame.Name = "GameInfo"
    infoFrame.Size = UDim2.new(0, 200, 0, 100)
    infoFrame.Position = UDim2.new(1, -210, 0, 10)
    infoFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    infoFrame.BackgroundTransparency = 0.3
    infoFrame.BorderSizePixel = 0
    infoFrame.Parent = mainUI
    
    local dayLabel = Instance.new("TextLabel")
    dayLabel.Size = UDim2.new(1, 0, 0, 25)
    dayLabel.Position = UDim2.new(0, 0, 0, 5)
    dayLabel.BackgroundTransparency = 1
    dayLabel.Text = "Day 1 - DAY"
    dayLabel.TextColor3 = Color3.new(1, 1, 1)
    dayLabel.TextScaled = true
    dayLabel.Name = "DayLabel"
    dayLabel.Parent = infoFrame
    
    local creditsLabel = Instance.new("TextLabel")
    creditsLabel.Size = UDim2.new(1, 0, 0, 25)
    creditsLabel.Position = UDim2.new(0, 0, 0, 30)
    creditsLabel.BackgroundTransparency = 1
    creditsLabel.Text = "Credits: 100"
    creditsLabel.TextColor3 = Color3.new(1, 1, 0)
    creditsLabel.TextScaled = true
    creditsLabel.Name = "CreditsLabel"
    creditsLabel.Parent = infoFrame
    
    local levelLabel = Instance.new("TextLabel")
    levelLabel.Size = UDim2.new(1, 0, 0, 25)
    levelLabel.Position = UDim2.new(0, 0, 0, 55)
    levelLabel.BackgroundTransparency = 1
    levelLabel.Text = "Level: 1"
    levelLabel.TextColor3 = Color3.new(0, 1, 0)
    levelLabel.TextScaled = true
    levelLabel.Name = "LevelLabel"
    levelLabel.Parent = infoFrame
    
    -- Interaction prompt
    local interactionLabel = Instance.new("TextLabel")
    interactionLabel.Size = UDim2.new(0, 300, 0, 50)
    interactionLabel.Position = UDim2.new(0.5, -150, 0.5, 100)
    interactionLabel.BackgroundTransparency = 1
    interactionLabel.Text = ""
    interactionLabel.TextColor3 = Color3.new(1, 1, 1)
    interactionLabel.TextScaled = true
    interactionLabel.Name = "InteractionLabel"
    interactionLabel.Visible = false
    interactionLabel.Parent = mainUI
    
    -- Tools Panel
    local toolsFrame = Instance.new("Frame")
    toolsFrame.Name = "Tools"
    toolsFrame.Size = UDim2.new(0, 300, 0, 60)
    toolsFrame.Position = UDim2.new(0, 10, 1, -70)
    toolsFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    toolsFrame.BackgroundTransparency = 0.3
    toolsFrame.BorderSizePixel = 0
    toolsFrame.Parent = mainUI
    
    -- Mining Tool Button
    local miningButton = Instance.new("TextButton")
    miningButton.Size = UDim2.new(0, 90, 0, 50)
    miningButton.Position = UDim2.new(0, 5, 0, 5)
    miningButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    miningButton.Text = "DRILL [1]"
    miningButton.TextColor3 = Color3.new(1, 1, 1)
    miningButton.TextScaled = true
    miningButton.Name = "MiningButton"
    miningButton.Parent = toolsFrame
    
    -- Building Tool Button
    local buildingButton = Instance.new("TextButton")
    buildingButton.Size = UDim2.new(0, 90, 0, 50)
    buildingButton.Position = UDim2.new(0, 100, 0, 5)
    buildingButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    buildingButton.Text = "BUILD [2]"
    buildingButton.TextColor3 = Color3.new(1, 1, 1)
    buildingButton.TextScaled = true
    buildingButton.Name = "BuildingButton"
    buildingButton.Parent = toolsFrame
    
    -- Trade Tool Button
    local tradeButton = Instance.new("TextButton")
    tradeButton.Size = UDim2.new(0, 90, 0, 50)
    tradeButton.Position = UDim2.new(0, 195, 0, 5)
    tradeButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    tradeButton.Text = "TRADE [3]"
    tradeButton.TextColor3 = Color3.new(1, 1, 1)
    tradeButton.TextScaled = true
    tradeButton.Name = "TradeButton"
    tradeButton.Parent = toolsFrame
    
    -- Connect tool buttons
    miningButton.MouseButton1Click:Connect(function()
        PlayerController.SelectTool("MINING")
    end)
    
    buildingButton.MouseButton1Click:Connect(function()
        PlayerController.SelectTool("BUILDING")
    end)
    
    tradeButton.MouseButton1Click:Connect(function()
        PlayerController.SelectTool("TRADING")
    end)
end

-- Input Setup
function PlayerController.SetupInputs()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.One then
            PlayerController.SelectTool("MINING")
        elseif input.KeyCode == Enum.KeyCode.Two then
            PlayerController.SelectTool("BUILDING")
        elseif input.KeyCode == Enum.KeyCode.Three then
            PlayerController.SelectTool("TRADING")
        elseif input.KeyCode == Enum.KeyCode.E then
            PlayerController.Interact()
        elseif input.KeyCode == Enum.KeyCode.I then
            PlayerController.ToggleInventory()
        elseif input.KeyCode == Enum.KeyCode.J then
            PlayerController.ToggleJobPanel()
        end
    end)
    
    -- Mouse click for tool usage
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            PlayerController.UseTool()
        end
    end)
end

-- Tool System
function PlayerController.SelectTool(toolType)
    selectedTool = toolType
    print("Selected tool:", toolType)
    
    -- Update UI to show selected tool
    local toolsFrame = mainUI:FindFirstChild("Tools")
    if toolsFrame then
        for _, button in pairs(toolsFrame:GetChildren()) do
            if button:IsA("TextButton") then
                button.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
            end
        end
        
        if toolType == "MINING" then
            toolsFrame.MiningButton.BackgroundColor3 = Color3.new(0, 0.5, 1)
        elseif toolType == "BUILDING" then
            toolsFrame.BuildingButton.BackgroundColor3 = Color3.new(0, 1, 0)
        elseif toolType == "TRADING" then
            toolsFrame.TradeButton.BackgroundColor3 = Color3.new(1, 1, 0)
        end
    end
end

function PlayerController.UseTool()
    if not selectedTool then return end
    
    local mouse = player:GetMouse()
    local target = mouse.Target
    
    if selectedTool == "MINING" then
        PlayerController.HandleMining(target)
    elseif selectedTool == "BUILDING" then
        PlayerController.HandleBuilding(mouse.Hit.Position)
    elseif selectedTool == "TRADING" then
        PlayerController.HandleTrading(target)
    end
end

function PlayerController.HandleMining(target)
    if not target then return end
    
    -- Check if target is a mineral deposit
    if target.Name:find("Mineral") or target.Name:find("Rock") or target.Name:find("Ice") then
        local resourceType = "IRON" -- Default, could be determined by target properties
        
        if target.Name:find("Copper") then
            resourceType = "COPPER"
        elseif target.Name:find("Titanium") then
            resourceType = "TITANIUM"
        elseif target.Name:find("Rare") then
            resourceType = "RARE_EARTH"
        elseif target.Name:find("Ice") then
            resourceType = "ICE"
        end
        
        -- Get mining power based on player level/tools
        local miningSkill = playerData.skills and playerData.skills.MINING or {level = 1}
        local miningPower = math.floor(miningSkill.level / 5)
        
        -- Send mining request to server
        mineResourceEvent:FireServer(resourceType, miningPower)
        
        -- Visual feedback
        PlayerController.ShowMiningEffect(target.Position)
        
        print("Mining", resourceType, "with power", miningPower)
    end
end

function PlayerController.HandleBuilding(position)
    -- Simple building system - could be expanded with menus
    print("Building at position:", position)
    buildStructureEvent:FireServer("SHELTER_BASIC", position)
end

function PlayerController.HandleTrading(target)
    if target and target.Name:find("TradingPost") then
        print("Opening trading interface")
        PlayerController.OpenTradingInterface()
    end
end

-- Effects
function PlayerController.ShowMiningEffect(position)
    -- Create particle effect at mining location
    local effect = Instance.new("Explosion")
    effect.Position = position
    effect.BlastRadius = 5
    effect.BlastPressure = 0
    effect.Parent = workspace
end

-- Interaction System
function PlayerController.Interact()
    local mouse = player:GetMouse()
    local target = mouse.Target
    
    if target then
        if target.Name:find("TradingPost") then
            PlayerController.OpenTradingInterface()
        elseif target.Name:find("JobBoard") then
            PlayerController.ToggleJobPanel()
        elseif target.Name:find("Shelter") then
            PlayerController.EnterShelter()
        end
    end
end

-- Data Update Handlers
function PlayerController.OnPlayerDataUpdate(data)
    playerData = data
    PlayerController.UpdateUI()
end

function PlayerController.OnGameStateUpdate(state)
    gameState = state
    PlayerController.UpdateGameUI()
end

-- UI Updates
function PlayerController.UpdateUI()
    if not playerData or not mainUI then return end
    
    local survivalFrame = mainUI:FindFirstChild("SurvivalStats")
    if survivalFrame and playerData.survival then
        -- Update survival bars
        local oxygen = playerData.survival.oxygen or 100
        local energy = playerData.survival.energy or 100
        local warmth = playerData.survival.warmth or 100
        local hunger = playerData.survival.hunger or 100
        
        survivalFrame.OxygenLabel.Text = "Oxygen: " .. math.floor(oxygen) .. "%"
        survivalFrame.OxygenBar.Size = UDim2.new(0.9 * (oxygen / 100), 0, 0, 8)
        
        survivalFrame.EnergyLabel.Text = "Energy: " .. math.floor(energy) .. "%"
        survivalFrame.EnergyBar.Size = UDim2.new(0.9 * (energy / 100), 0, 0, 8)
        
        survivalFrame.WarmthLabel.Text = "Warmth: " .. math.floor(warmth) .. "%"
        survivalFrame.WarmthBar.Size = UDim2.new(0.9 * (warmth / 100), 0, 0, 8)
        
        survivalFrame.HungerLabel.Text = "Hunger: " .. math.floor(hunger) .. "%"
        survivalFrame.HungerBar.Size = UDim2.new(0.9 * (hunger / 100), 0, 0, 8)
        
        -- Oxygen warning
        if oxygen <= 20 and not oxygenWarningActive then
            PlayerController.ShowOxygenWarning()
        elseif oxygen > 20 and oxygenWarningActive then
            PlayerController.HideOxygenWarning()
        end
    end
    
    local infoFrame = mainUI:FindFirstChild("GameInfo")
    if infoFrame then
        infoFrame.CreditsLabel.Text = "Credits: " .. (playerData.currency or 0)
        infoFrame.LevelLabel.Text = "Level: " .. (playerData.level or 1)
    end
end

function PlayerController.UpdateGameUI()
    if not gameState or not mainUI then return end
    
    local infoFrame = mainUI:FindFirstChild("GameInfo")
    if infoFrame then
        local cycleText = gameState.currentCycle or "DAY"
        local dayCount = gameState.dayCount or 1
        infoFrame.DayLabel.Text = "Day " .. dayCount .. " - " .. cycleText
        
        -- Change background color based on time of day
        if cycleText == "NIGHT" then
            infoFrame.BackgroundColor3 = Color3.new(0.1, 0, 0.2)
        elseif cycleText == "DAWN" or cycleText == "DUSK" then
            infoFrame.BackgroundColor3 = Color3.new(0.2, 0.1, 0)
        else
            infoFrame.BackgroundColor3 = Color3.new(0, 0, 0)
        end
    end
end

-- Warning Systems
function PlayerController.ShowOxygenWarning()
    oxygenWarningActive = true
    
    -- Create flashing oxygen warning
    local warning = Instance.new("Frame")
    warning.Size = UDim2.new(1, 0, 1, 0)
    warning.Position = UDim2.new(0, 0, 0, 0)
    warning.BackgroundColor3 = Color3.new(1, 0, 0)
    warning.BackgroundTransparency = 0.8
    warning.BorderSizePixel = 0
    warning.Name = "OxygenWarning"
    warning.Parent = mainUI
    
    local warningText = Instance.new("TextLabel")
    warningText.Size = UDim2.new(0, 400, 0, 100)
    warningText.Position = UDim2.new(0.5, -200, 0.5, -50)
    warningText.BackgroundTransparency = 1
    warningText.Text = "LOW OXYGEN WARNING!"
    warningText.TextColor3 = Color3.new(1, 1, 1)
    warningText.TextScaled = true
    warningText.Font = Enum.Font.SourceSansBold
    warningText.Parent = warning
    
    -- Flash effect
    local flashTween = TweenService:Create(warning, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true), {BackgroundTransparency = 0.95})
    flashTween:Play()
end

function PlayerController.HideOxygenWarning()
    oxygenWarningActive = false
    
    local warning = mainUI:FindFirstChild("OxygenWarning")
    if warning then
        warning:Destroy()
    end
end

-- Interface Functions (placeholders for full implementation)
function PlayerController.ToggleInventory()
    print("Inventory toggled")
    -- Implementation would show/hide inventory panel
end

function PlayerController.ToggleJobPanel()
    print("Job panel toggled")
    -- Implementation would show/hide job selection panel
end

function PlayerController.OpenTradingInterface()
    print("Trading interface opened")
    -- Implementation would show trading UI
end

function PlayerController.EnterShelter()
    isInShelter = true
    print("Entered shelter - survival decay reduced")
    -- Could modify survival decay rates when in shelter
end

-- Update Loops
function PlayerController.StartUpdateLoops()
    -- Update interaction prompts
    RunService.Heartbeat:Connect(function()
        PlayerController.UpdateInteractionPrompts()
    end)
end

function PlayerController.UpdateInteractionPrompts()
    local mouse = player:GetMouse()
    local target = mouse.Target
    local interactionLabel = mainUI:FindFirstChild("InteractionLabel")
    
    if not interactionLabel then return end
    
    if target then
        local distance = (character.HumanoidRootPart.Position - target.Position).Magnitude
        
        if distance <= 10 then -- Interaction range
            if target.Name:find("TradingPost") then
                interactionLabel.Text = "Press E to Trade"
                interactionLabel.Visible = true
            elseif target.Name:find("JobBoard") then
                interactionLabel.Text = "Press E for Jobs"
                interactionLabel.Visible = true
            elseif target.Name:find("Shelter") then
                interactionLabel.Text = "Press E to Enter Shelter"
                interactionLabel.Visible = true
            elseif target.Name:find("Mineral") or target.Name:find("Rock") or target.Name:find("Ice") then
                interactionLabel.Text = "Click to Mine (Select Drill First)"
                interactionLabel.Visible = true
            else
                interactionLabel.Visible = false
            end
        else
            interactionLabel.Visible = false
        end
    else
        interactionLabel.Visible = false
    end
end

-- Initialize when character spawns
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    wait(1) -- Wait for character to fully load
    PlayerController.SetupCharacter()
end)

-- Initialize
PlayerController.Initialize()

return PlayerController