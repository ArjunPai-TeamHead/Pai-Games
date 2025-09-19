-- Mars Survival UI Manager (Client)
-- Comprehensive UI system for inventory, trading, building, and progression

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local UIManager = {}

-- UI State
local uiState = {
    inventoryOpen = false,
    tradingOpen = false,
    buildingOpen = false,
    jobPanelOpen = false,
    progressionOpen = false
}

-- Data
local playerData = {}
local gameState = {}
local progressionData = {}

-- UI Elements
local mainScreenGui = nil
local inventoryFrame = nil
local tradingFrame = nil
local buildingFrame = nil
local jobFrame = nil
local progressionFrame = nil

-- Remote Events
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

-- Initialize UI Manager
function UIManager.Initialize()
    print("Mars Survival UI Manager initialized")
    
    -- Create main UI
    UIManager.CreateMainUI()
    
    -- Connect remote events
    remoteEvents.UpdatePlayerData.OnClientEvent:Connect(UIManager.OnPlayerDataUpdate)
    remoteEvents.UpdateGameState.OnClientEvent:Connect(UIManager.OnGameStateUpdate)
    
    if remoteEvents:FindFirstChild("UpdateProgression") then
        remoteEvents.UpdateProgression.OnClientEvent:Connect(UIManager.OnProgressionUpdate)
    end
    
    -- Setup input handling
    UIManager.SetupInputs()
end

-- Main UI Creation
function UIManager.CreateMainUI()
    mainScreenGui = Instance.new("ScreenGui")
    mainScreenGui.Name = "MarsUIManager"
    mainScreenGui.ResetOnSpawn = false
    mainScreenGui.Parent = playerGui
    
    -- Create inventory interface
    UIManager.CreateInventoryUI()
    
    -- Create trading interface
    UIManager.CreateTradingUI()
    
    -- Create building interface
    UIManager.CreateBuildingUI()
    
    -- Create job panel
    UIManager.CreateJobUI()
    
    -- Create progression panel
    UIManager.CreateProgressionUI()
    
    -- Create notifications system
    UIManager.CreateNotificationSystem()
end

-- Inventory UI
function UIManager.CreateInventoryUI()
    inventoryFrame = Instance.new("Frame")
    inventoryFrame.Name = "InventoryFrame"
    inventoryFrame.Size = UDim2.new(0, 400, 0, 500)
    inventoryFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    inventoryFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.15)
    inventoryFrame.BorderSizePixel = 2
    inventoryFrame.BorderColor3 = Color3.new(0.4, 0.6, 1)
    inventoryFrame.Visible = false
    inventoryFrame.Parent = mainScreenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.new(0.2, 0.2, 0.3)
    title.BorderSizePixel = 0
    title.Text = "INVENTORY"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = inventoryFrame
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextScaled = true
    closeButton.Parent = inventoryFrame
    
    closeButton.MouseButton1Click:Connect(function()
        UIManager.ToggleInventory()
    end)
    
    -- Resource display
    local resourceScrollFrame = Instance.new("ScrollingFrame")
    resourceScrollFrame.Size = UDim2.new(1, -20, 1, -60)
    resourceScrollFrame.Position = UDim2.new(0, 10, 0, 50)
    resourceScrollFrame.BackgroundColor3 = Color3.new(0.05, 0.05, 0.1)
    resourceScrollFrame.BorderSizePixel = 0
    resourceScrollFrame.ScrollBarThickness = 10
    resourceScrollFrame.Name = "ResourceList"
    resourceScrollFrame.Parent = inventoryFrame
    
    -- Create resource item template
    UIManager.CreateResourceItemTemplate(resourceScrollFrame)
end

function UIManager.CreateResourceItemTemplate(parent)
    local template = Instance.new("Frame")
    template.Name = "ResourceItemTemplate"
    template.Size = UDim2.new(1, -20, 0, 50)
    template.BackgroundColor3 = Color3.new(0.15, 0.15, 0.2)
    template.BorderSizePixel = 1
    template.BorderColor3 = Color3.new(0.3, 0.3, 0.4)
    template.Visible = false
    template.Parent = parent
    
    local icon = Instance.new("Frame")
    icon.Size = UDim2.new(0, 40, 0, 40)
    icon.Position = UDim2.new(0, 5, 0, 5)
    icon.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    icon.Name = "Icon"
    icon.Parent = template
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.6, 0, 1, 0)
    nameLabel.Position = UDim2.new(0, 50, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "Resource Name"
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextScaled = true
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Name = "NameLabel"
    nameLabel.Parent = template
    
    local quantityLabel = Instance.new("TextLabel")
    quantityLabel.Size = UDim2.new(0.3, 0, 1, 0)
    quantityLabel.Position = UDim2.new(0.7, 0, 0, 0)
    quantityLabel.BackgroundTransparency = 1
    quantityLabel.Text = "x999"
    quantityLabel.TextColor3 = Color3.new(0.8, 0.8, 1)
    quantityLabel.TextScaled = true
    quantityLabel.Name = "QuantityLabel"
    quantityLabel.Parent = template
end

-- Trading UI
function UIManager.CreateTradingUI()
    tradingFrame = Instance.new("Frame")
    tradingFrame.Name = "TradingFrame"
    tradingFrame.Size = UDim2.new(0, 600, 0, 400)
    tradingFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    tradingFrame.BackgroundColor3 = Color3.new(0.1, 0.15, 0.1)
    tradingFrame.BorderSizePixel = 2
    tradingFrame.BorderColor3 = Color3.new(0.4, 1, 0.4)
    tradingFrame.Visible = false
    tradingFrame.Parent = mainScreenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.new(0.2, 0.3, 0.2)
    title.Text = "TRADING POST"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = tradingFrame
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextScaled = true
    closeButton.Parent = tradingFrame
    
    closeButton.MouseButton1Click:Connect(function()
        UIManager.ToggleTrading()
    end)
    
    -- Buy/Sell sections
    local buyFrame = Instance.new("Frame")
    buyFrame.Size = UDim2.new(0.48, 0, 1, -60)
    buyFrame.Position = UDim2.new(0.02, 0, 0, 50)
    buyFrame.BackgroundColor3 = Color3.new(0.05, 0.1, 0.05)
    buyFrame.BorderSizePixel = 1
    buyFrame.BorderColor3 = Color3.new(0.3, 0.6, 0.3)
    buyFrame.Parent = tradingFrame
    
    local buyTitle = Instance.new("TextLabel")
    buyTitle.Size = UDim2.new(1, 0, 0, 30)
    buyTitle.BackgroundColor3 = Color3.new(0.1, 0.2, 0.1)
    buyTitle.Text = "BUY RESOURCES"
    buyTitle.TextColor3 = Color3.new(1, 1, 1)
    buyTitle.TextScaled = true
    buyTitle.Parent = buyFrame
    
    local sellFrame = Instance.new("Frame")
    sellFrame.Size = UDim2.new(0.48, 0, 1, -60)
    sellFrame.Position = UDim2.new(0.5, 0, 0, 50)
    sellFrame.BackgroundColor3 = Color3.new(0.1, 0.05, 0.05)
    sellFrame.BorderSizePixel = 1
    sellFrame.BorderColor3 = Color3.new(0.6, 0.3, 0.3)
    sellFrame.Parent = tradingFrame
    
    local sellTitle = Instance.new("TextLabel")
    sellTitle.Size = UDim2.new(1, 0, 0, 30)
    sellTitle.BackgroundColor3 = Color3.new(0.2, 0.1, 0.1)
    sellTitle.Text = "SELL RESOURCES"
    sellTitle.TextColor3 = Color3.new(1, 1, 1)
    sellTitle.TextScaled = true
    sellTitle.Parent = sellFrame
    
    -- Create trading lists
    UIManager.CreateTradingList(buyFrame, "BUY")
    UIManager.CreateTradingList(sellFrame, "SELL")
end

function UIManager.CreateTradingList(parent, tradeType)
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -10, 1, -40)
    scrollFrame.Position = UDim2.new(0, 5, 0, 35)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.Name = tradeType .. "List"
    scrollFrame.Parent = parent
    
    -- Create trade items for each resource
    local yPosition = 0
    for resourceName, baseValue in pairs(GameConfig.RESOURCE_VALUES) do
        local tradeItem = Instance.new("Frame")
        tradeItem.Size = UDim2.new(1, -10, 0, 60)
        tradeItem.Position = UDim2.new(0, 0, 0, yPosition)
        tradeItem.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
        tradeItem.BorderSizePixel = 1
        tradeItem.BorderColor3 = Color3.new(0.4, 0.4, 0.4)
        tradeItem.Parent = scrollFrame
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.5, 0, 0.5, 0)
        nameLabel.Position = UDim2.new(0, 5, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = resourceName
        nameLabel.TextColor3 = Color3.new(1, 1, 1)
        nameLabel.TextScaled = true
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = tradeItem
        
        local priceLabel = Instance.new("TextLabel")
        priceLabel.Size = UDim2.new(0.5, 0, 0.5, 0)
        priceLabel.Position = UDim2.new(0.5, 0, 0, 0)
        priceLabel.BackgroundTransparency = 1
        priceLabel.Text = baseValue .. " Credits"
        priceLabel.TextColor3 = Color3.new(1, 1, 0)
        priceLabel.TextScaled = true
        priceLabel.Name = "PriceLabel"
        priceLabel.Parent = tradeItem
        
        local tradeButton = Instance.new("TextButton")
        tradeButton.Size = UDim2.new(1, -10, 0.4, 0)
        tradeButton.Position = UDim2.new(0, 5, 0.6, 0)
        tradeButton.BackgroundColor3 = tradeType == "BUY" and Color3.new(0, 0.5, 0) or Color3.new(0.5, 0, 0)
        tradeButton.Text = tradeType .. " 1"
        tradeButton.TextColor3 = Color3.new(1, 1, 1)
        tradeButton.TextScaled = true
        tradeButton.Parent = tradeItem
        
        tradeButton.MouseButton1Click:Connect(function()
            UIManager.HandleTrade(resourceName, 1, tradeType)
        end)
        
        yPosition = yPosition + 65
    end
    
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPosition)
end

-- Building UI
function UIManager.CreateBuildingUI()
    buildingFrame = Instance.new("Frame")
    buildingFrame.Name = "BuildingFrame"
    buildingFrame.Size = UDim2.new(0, 500, 0, 600)
    buildingFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
    buildingFrame.BackgroundColor3 = Color3.new(0.15, 0.1, 0.05)
    buildingFrame.BorderSizePixel = 2
    buildingFrame.BorderColor3 = Color3.new(1, 0.6, 0.2)
    buildingFrame.Visible = false
    buildingFrame.Parent = mainScreenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.new(0.3, 0.2, 0.1)
    title.Text = "CONSTRUCTION MENU"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = buildingFrame
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextScaled = true
    closeButton.Parent = buildingFrame
    
    closeButton.MouseButton1Click:Connect(function()
        UIManager.ToggleBuilding()
    end)
    
    -- Building options
    UIManager.CreateBuildingOptions(buildingFrame)
end

function UIManager.CreateBuildingOptions(parent)
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -20, 1, -60)
    scrollFrame.Position = UDim2.new(0, 10, 0, 50)
    scrollFrame.BackgroundColor3 = Color3.new(0.1, 0.05, 0.02)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 10
    scrollFrame.Parent = parent
    
    local yPosition = 0
    for structureName, costs in pairs(GameConfig.BUILDING_COSTS) do
        local buildingItem = Instance.new("Frame")
        buildingItem.Size = UDim2.new(1, -20, 0, 120)
        buildingItem.Position = UDim2.new(0, 0, 0, yPosition)
        buildingItem.BackgroundColor3 = Color3.new(0.2, 0.15, 0.1)
        buildingItem.BorderSizePixel = 1
        buildingItem.BorderColor3 = Color3.new(0.5, 0.4, 0.3)
        buildingItem.Parent = scrollFrame
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0, 30)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = structureName:gsub("_", " ")
        nameLabel.TextColor3 = Color3.new(1, 1, 1)
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.Parent = buildingItem
        
        -- Cost display
        local costText = "REQUIRES: "
        for resource, amount in pairs(costs) do
            costText = costText .. amount .. " " .. resource .. "  "
        end
        
        local costLabel = Instance.new("TextLabel")
        costLabel.Size = UDim2.new(1, 0, 0, 40)
        costLabel.Position = UDim2.new(0, 0, 0, 30)
        costLabel.BackgroundTransparency = 1
        costLabel.Text = costText
        costLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
        costLabel.TextScaled = true
        costLabel.TextWrapped = true
        costLabel.Parent = buildingItem
        
        local buildButton = Instance.new("TextButton")
        buildButton.Size = UDim2.new(0.8, 0, 0, 40)
        buildButton.Position = UDim2.new(0.1, 0, 0, 75)
        buildButton.BackgroundColor3 = Color3.new(0, 0.6, 0)
        buildButton.Text = "BUILD"
        buildButton.TextColor3 = Color3.new(1, 1, 1)
        buildButton.TextScaled = true
        buildButton.Parent = buildingItem
        
        buildButton.MouseButton1Click:Connect(function()
            UIManager.HandleBuild(structureName)
        end)
        
        yPosition = yPosition + 125
    end
    
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPosition)
end

-- Job UI
function UIManager.CreateJobUI()
    jobFrame = Instance.new("Frame")
    jobFrame.Name = "JobFrame"
    jobFrame.Size = UDim2.new(0, 400, 0, 500)
    jobFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    jobFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.2)
    jobFrame.BorderSizePixel = 2
    jobFrame.BorderColor3 = Color3.new(0.6, 0.4, 1)
    jobFrame.Visible = false
    jobFrame.Parent = mainScreenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.new(0.2, 0.2, 0.4)
    title.Text = "JOB BOARD"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = jobFrame
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextScaled = true
    closeButton.Parent = jobFrame
    
    closeButton.MouseButton1Click:Connect(function()
        UIManager.ToggleJobPanel()
    end)
    
    -- Current job display
    local currentJobFrame = Instance.new("Frame")
    currentJobFrame.Size = UDim2.new(1, -20, 0, 80)
    currentJobFrame.Position = UDim2.new(0, 10, 0, 50)
    currentJobFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.25)
    currentJobFrame.BorderSizePixel = 1
    currentJobFrame.BorderColor3 = Color3.new(0.4, 0.4, 0.6)
    currentJobFrame.Name = "CurrentJobFrame"
    currentJobFrame.Parent = jobFrame
    
    local currentJobLabel = Instance.new("TextLabel")
    currentJobLabel.Size = UDim2.new(1, 0, 1, 0)
    currentJobLabel.BackgroundTransparency = 1
    currentJobLabel.Text = "No Active Job"
    currentJobLabel.TextColor3 = Color3.new(1, 1, 1)
    currentJobLabel.TextScaled = true
    currentJobLabel.Name = "CurrentJobLabel"
    currentJobLabel.Parent = currentJobFrame
    
    -- Available jobs
    UIManager.CreateJobList(jobFrame)
end

function UIManager.CreateJobList(parent)
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -20, 1, -150)
    scrollFrame.Position = UDim2.new(0, 10, 0, 140)
    scrollFrame.BackgroundColor3 = Color3.new(0.05, 0.05, 0.15)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 10
    scrollFrame.Parent = parent
    
    local yPosition = 0
    for jobType, jobInfo in pairs(GameConfig.JOBS) do
        local jobItem = Instance.new("Frame")
        jobItem.Size = UDim2.new(1, -20, 0, 100)
        jobItem.Position = UDim2.new(0, 0, 0, yPosition)
        jobItem.BackgroundColor3 = Color3.new(0.15, 0.15, 0.25)
        jobItem.BorderSizePixel = 1
        jobItem.BorderColor3 = Color3.new(0.4, 0.4, 0.6)
        jobItem.Parent = scrollFrame
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0, 30)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = jobInfo.name
        nameLabel.TextColor3 = Color3.new(1, 1, 1)
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.Parent = jobItem
        
        local payLabel = Instance.new("TextLabel")
        payLabel.Size = UDim2.new(1, 0, 0, 25)
        payLabel.Position = UDim2.new(0, 0, 0, 30)
        payLabel.BackgroundTransparency = 1
        payLabel.Text = "Pay: " .. jobInfo.pay .. " Credits"
        payLabel.TextColor3 = Color3.new(1, 1, 0)
        payLabel.TextScaled = true
        payLabel.Parent = jobItem
        
        local takeJobButton = Instance.new("TextButton")
        takeJobButton.Size = UDim2.new(0.8, 0, 0, 35)
        takeJobButton.Position = UDim2.new(0.1, 0, 0, 60)
        takeJobButton.BackgroundColor3 = Color3.new(0, 0.5, 0.8)
        takeJobButton.Text = "TAKE JOB"
        takeJobButton.TextColor3 = Color3.new(1, 1, 1)
        takeJobButton.TextScaled = true
        takeJobButton.Parent = jobItem
        
        takeJobButton.MouseButton1Click:Connect(function()
            UIManager.HandleTakeJob(jobType)
        end)
        
        yPosition = yPosition + 105
    end
    
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPosition)
end

-- Progression UI
function UIManager.CreateProgressionUI()
    progressionFrame = Instance.new("Frame")
    progressionFrame.Name = "ProgressionFrame"
    progressionFrame.Size = UDim2.new(0, 700, 0, 500)
    progressionFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
    progressionFrame.BackgroundColor3 = Color3.new(0.05, 0.1, 0.15)
    progressionFrame.BorderSizePixel = 2
    progressionFrame.BorderColor3 = Color3.new(0.4, 0.8, 1)
    progressionFrame.Visible = false
    progressionFrame.Parent = mainScreenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.new(0.1, 0.2, 0.3)
    title.Text = "PROGRESSION & ACHIEVEMENTS"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = progressionFrame
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextScaled = true
    closeButton.Parent = progressionFrame
    
    closeButton.MouseButton1Click:Connect(function()
        UIManager.ToggleProgression()
    end)
    
    -- Rank and experience display
    local statsFrame = Instance.new("Frame")
    statsFrame.Size = UDim2.new(1, -20, 0, 100)
    statsFrame.Position = UDim2.new(0, 10, 0, 50)
    statsFrame.BackgroundColor3 = Color3.new(0.1, 0.15, 0.2)
    statsFrame.BorderSizePixel = 1
    statsFrame.BorderColor3 = Color3.new(0.3, 0.5, 0.7)
    statsFrame.Name = "StatsFrame"
    statsFrame.Parent = progressionFrame
    
    local rankLabel = Instance.new("TextLabel")
    rankLabel.Size = UDim2.new(0.5, 0, 0.5, 0)
    rankLabel.BackgroundTransparency = 1
    rankLabel.Text = "Rank: SETTLER"
    rankLabel.TextColor3 = Color3.new(1, 1, 1)
    rankLabel.TextScaled = true
    rankLabel.Name = "RankLabel"
    rankLabel.Parent = statsFrame
    
    local expLabel = Instance.new("TextLabel")
    expLabel.Size = UDim2.new(0.5, 0, 0.5, 0)
    expLabel.Position = UDim2.new(0.5, 0, 0, 0)
    expLabel.BackgroundTransparency = 1
    expLabel.Text = "Experience: 0"
    expLabel.TextColor3 = Color3.new(0.8, 1, 0.8)
    expLabel.TextScaled = true
    expLabel.Name = "ExpLabel"
    expLabel.Parent = statsFrame
    
    -- Projects display
    local projectsLabel = Instance.new("TextLabel")
    projectsLabel.Size = UDim2.new(1, 0, 0.5, 0)
    projectsLabel.Position = UDim2.new(0, 0, 0.5, 0)
    projectsLabel.BackgroundTransparency = 1
    projectsLabel.Text = "Rockets: 0 | Planets: 0"
    projectsLabel.TextColor3 = Color3.new(0.8, 0.8, 1)
    projectsLabel.TextScaled = true
    projectsLabel.Name = "ProjectsLabel"
    projectsLabel.Parent = statsFrame
end

-- Notification System
function UIManager.CreateNotificationSystem()
    local notificationFrame = Instance.new("Frame")
    notificationFrame.Name = "NotificationFrame"
    notificationFrame.Size = UDim2.new(0, 300, 1, 0)
    notificationFrame.Position = UDim2.new(1, -310, 0, 10)
    notificationFrame.BackgroundTransparency = 1
    notificationFrame.Parent = mainScreenGui
end

-- Input Handling
function UIManager.SetupInputs()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.I then
            UIManager.ToggleInventory()
        elseif input.KeyCode == Enum.KeyCode.T then
            UIManager.ToggleTrading()
        elseif input.KeyCode == Enum.KeyCode.B then
            UIManager.ToggleBuilding()
        elseif input.KeyCode == Enum.KeyCode.J then
            UIManager.ToggleJobPanel()
        elseif input.KeyCode == Enum.KeyCode.P then
            UIManager.ToggleProgression()
        elseif input.KeyCode == Enum.KeyCode.Escape then
            UIManager.CloseAllUIs()
        end
    end)
end

-- UI Toggle Functions
function UIManager.ToggleInventory()
    uiState.inventoryOpen = not uiState.inventoryOpen
    inventoryFrame.Visible = uiState.inventoryOpen
    
    if uiState.inventoryOpen then
        UIManager.UpdateInventoryDisplay()
    end
end

function UIManager.ToggleTrading()
    uiState.tradingOpen = not uiState.tradingOpen
    tradingFrame.Visible = uiState.tradingOpen
    
    if uiState.tradingOpen then
        UIManager.UpdateTradingDisplay()
    end
end

function UIManager.ToggleBuilding()
    uiState.buildingOpen = not uiState.buildingOpen
    buildingFrame.Visible = uiState.buildingOpen
end

function UIManager.ToggleJobPanel()
    uiState.jobPanelOpen = not uiState.jobPanelOpen
    jobFrame.Visible = uiState.jobPanelOpen
    
    if uiState.jobPanelOpen then
        UIManager.UpdateJobDisplay()
    end
end

function UIManager.ToggleProgression()
    uiState.progressionOpen = not uiState.progressionOpen
    progressionFrame.Visible = uiState.progressionOpen
    
    if uiState.progressionOpen then
        UIManager.UpdateProgressionDisplay()
    end
end

function UIManager.CloseAllUIs()
    for key, _ in pairs(uiState) do
        uiState[key] = false
    end
    
    inventoryFrame.Visible = false
    tradingFrame.Visible = false
    buildingFrame.Visible = false
    jobFrame.Visible = false
    progressionFrame.Visible = false
end

-- Data Update Handlers
function UIManager.OnPlayerDataUpdate(data)
    playerData = data
    UIManager.UpdateAllDisplays()
end

function UIManager.OnGameStateUpdate(state)
    gameState = state
end

function UIManager.OnProgressionUpdate(data)
    progressionData = data
    UIManager.UpdateProgressionDisplay()
end

-- Display Updates
function UIManager.UpdateAllDisplays()
    if uiState.inventoryOpen then
        UIManager.UpdateInventoryDisplay()
    end
    if uiState.tradingOpen then
        UIManager.UpdateTradingDisplay()
    end
    if uiState.jobPanelOpen then
        UIManager.UpdateJobDisplay()
    end
end

function UIManager.UpdateInventoryDisplay()
    local resourceList = inventoryFrame:FindFirstChild("ResourceList")
    if not resourceList or not playerData.inventory then return end
    
    -- Clear existing items
    for _, child in pairs(resourceList:GetChildren()) do
        if child.Name ~= "ResourceItemTemplate" then
            child:Destroy()
        end
    end
    
    local template = resourceList:FindFirstChild("ResourceItemTemplate")
    if not template then return end
    
    local yPosition = 0
    for resourceName, quantity in pairs(playerData.inventory) do
        if quantity > 0 then
            local item = template:Clone()
            item.Name = resourceName .. "Item"
            item.Visible = true
            item.Position = UDim2.new(0, 0, 0, yPosition)
            item.NameLabel.Text = resourceName
            item.QuantityLabel.Text = "x" .. quantity
            
            -- Color icon based on resource type
            local color = UIManager.GetResourceColor(resourceName)
            item.Icon.BackgroundColor3 = color
            
            item.Parent = resourceList
            yPosition = yPosition + 55
        end
    end
    
    resourceList.CanvasSize = UDim2.new(0, 0, 0, yPosition)
end

function UIManager.UpdateTradingDisplay()
    -- Update prices based on economy modifier
    if not gameState.economyModifier then return end
    
    for _, tradeFrame in pairs({tradingFrame:FindFirstChild("Frame"), tradingFrame:FindFirstChild("Frame2")}) do
        if tradeFrame then
            for _, list in pairs({tradeFrame:FindFirstChild("BUYList"), tradeFrame:FindFirstChild("SELLList")}) do
                if list then
                    for _, item in pairs(list:GetChildren()) do
                        if item:IsA("Frame") then
                            local priceLabel = item:FindFirstChild("PriceLabel")
                            if priceLabel then
                                local resourceName = item:FindFirstChild("TextLabel").Text
                                local baseValue = GameConfig.RESOURCE_VALUES[resourceName]
                                if baseValue then
                                    local currentPrice = math.floor(baseValue * gameState.economyModifier)
                                    priceLabel.Text = currentPrice .. " Credits"
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function UIManager.UpdateJobDisplay()
    local currentJobFrame = jobFrame:FindFirstChild("CurrentJobFrame")
    if currentJobFrame and playerData.currentJob then
        local currentJobLabel = currentJobFrame:FindFirstChild("CurrentJobLabel")
        if currentJobLabel then
            if playerData.currentJob then
                local jobInfo = GameConfig.JOBS[playerData.currentJob.type]
                currentJobLabel.Text = "Current Job: " .. (jobInfo and jobInfo.name or "Unknown")
            else
                currentJobLabel.Text = "No Active Job"
            end
        end
    end
end

function UIManager.UpdateProgressionDisplay()
    if not progressionData then return end
    
    local statsFrame = progressionFrame:FindFirstChild("StatsFrame")
    if not statsFrame then return end
    
    local rankLabel = statsFrame:FindFirstChild("RankLabel")
    if rankLabel then
        rankLabel.Text = "Rank: " .. (progressionData.rank or "SETTLER")
    end
    
    local expLabel = statsFrame:FindFirstChild("ExpLabel")
    if expLabel then
        expLabel.Text = "Experience: " .. (progressionData.totalExperience or 0)
    end
    
    local projectsLabel = statsFrame:FindFirstChild("ProjectsLabel")
    if projectsLabel then
        local rocketCount = progressionData.rocketProjects and #progressionData.rocketProjects or 0
        local planetCount = progressionData.planetProjects and #progressionData.planetProjects or 0
        projectsLabel.Text = "Rockets: " .. rocketCount .. " | Planets: " .. planetCount
    end
end

-- Action Handlers
function UIManager.HandleTrade(resourceName, amount, tradeType)
    print("Trading", amount, resourceName, "(" .. tradeType .. ")")
    remoteEvents.TradeResources:FireServer(resourceName, amount, tradeType)
end

function UIManager.HandleBuild(structureType)
    print("Building", structureType)
    -- For now, build at a random location near the player
    local randomPos = Vector3.new(math.random(-50, 50), 0, math.random(-50, 50))
    remoteEvents.BuildStructure:FireServer(structureType, randomPos)
    UIManager.ToggleBuilding()
end

function UIManager.HandleTakeJob(jobType)
    print("Taking job:", jobType)
    remoteEvents.TakeJob:FireServer(jobType)
    UIManager.UpdateJobDisplay()
end

-- Utility Functions
function UIManager.GetResourceColor(resourceName)
    local colors = {
        IRON = Color3.new(0.6, 0.6, 0.7),
        COPPER = Color3.new(0.8, 0.5, 0.3),
        TITANIUM = Color3.new(0.7, 0.7, 0.8),
        RARE_EARTH = Color3.new(1, 0.4, 1),
        ICE = Color3.new(0.7, 0.9, 1),
        FOOD = Color3.new(0.3, 0.8, 0.3),
        OXYGEN_TANK = Color3.new(0.4, 0.8, 1)
    }
    return colors[resourceName] or Color3.new(0.5, 0.5, 0.5)
end

function UIManager.ShowNotification(message, color)
    local notificationFrame = mainScreenGui:FindFirstChild("NotificationFrame")
    if not notificationFrame then return end
    
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(1, 0, 0, 60)
    notification.Position = UDim2.new(0, 0, 0, 0)
    notification.BackgroundColor3 = color or Color3.new(0.2, 0.2, 0.2)
    notification.BorderSizePixel = 1
    notification.BorderColor3 = Color3.new(0.6, 0.6, 0.6)
    notification.Parent = notificationFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 1, -10)
    label.Position = UDim2.new(0, 5, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = message
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.TextWrapped = true
    label.Parent = notification
    
    -- Move existing notifications down
    for _, child in pairs(notificationFrame:GetChildren()) do
        if child ~= notification and child:IsA("Frame") then
            child.Position = child.Position + UDim2.new(0, 0, 0, 65)
        end
    end
    
    -- Auto-remove after 5 seconds
    game:GetService("Debris"):AddItem(notification, 5)
end

-- Initialize the UI Manager
UIManager.Initialize()

return UIManager