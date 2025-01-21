-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TextChatService = game:GetService("TextChatService")

-- Player setup
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local playerGui = player:WaitForChild("PlayerGui")

-- Flight Config
local FLIGHT_SPEED = 50
local TOGGLE_KEY = Enum.KeyCode.L
local ASCEND_KEY = Enum.KeyCode.Space
local DESCEND_KEY = Enum.KeyCode.LeftShift
local SPEED_INCREMENT = 10 -- เพิ่มค่าการเปลี่ยนแปลงความเร็ว
local MAX_SPEED = 1000 -- เพิ่มความเร็วสูงสุด

-- Feature Toggle Variables
local warpEnabled = true
local boomEnabled = true
local flightEnabled = true
local isLightOn = true
local isChatEnabled = true

-- Variables
local flying = false
local camera = workspace.CurrentCamera
local humanoid, rootPart
local canAdjustSpeed = true
local connections = {} -- Store all connections for cleanup

-- Create Main GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DogHubGui"
screenGui.Parent = playerGui

-- UI Helper Functions
local function makeUICorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function makeUIGradient(parent, color1, color2)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color1),
        ColorSequenceKeypoint.new(1, color2)
    })
    gradient.Parent = parent
    return gradient
end

local function createNotification(text, duration)
    local notification = Instance.new("TextLabel")
    notification.Size = UDim2.new(0, 200, 0, 50)
    notification.Position = UDim2.new(0.5, -100, 0.8, 0)
    notification.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    notification.TextColor3 = Color3.fromRGB(255, 255, 255)
    notification.Text = text
    notification.TextSize = 14
    notification.Font = Enum.Font.GothamBold
    notification.Parent = screenGui
    makeUICorner(notification, 8)
    
    game:GetService("Debris"):AddItem(notification, duration or 2)
end

-- Core Functions
local function getCharacter()
    character = player.Character or player.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
end

local function updateFlightStatus(isFlying)
    if not flightStatus then return end
    flightStatus.TextColor3 = isFlying and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    flightStatus.Text = "Flight: " .. (isFlying and "ON" or "OFF")
end

local function updateSpeedDisplay()
    if not speedText then return end
    speedText.Text = "Speed: " .. FLIGHT_SPEED
end

local function updateButtonStates()
    if warpButton then
        warpButton.Visible = warpEnabled
        warpButton.BackgroundColor3 = warpEnabled 
            and Color3.fromRGB(0, 255, 0) 
            or Color3.fromRGB(128, 128, 128)
    end
    
    if boomButton then
        boomButton.Visible = boomEnabled
        boomButton.BackgroundColor3 = boomEnabled 
            and Color3.fromRGB(255, 0, 0) 
            or Color3.fromRGB(128, 128, 128)
    end
    
    if flightButton then
        flightButton.Visible = flightEnabled
        flightButton.BackgroundColor3 = flightEnabled 
            and Color3.fromRGB(0, 150, 255) 
            or Color3.fromRGB(128, 128, 128)
    end
end

-- Create Toggle Button Function
local function createToggleButton(name, position, callback)
    local button = Instance.new("TextButton")
    button.Parent = toggleFrame
    button.Size = UDim2.new(1, 0, 0.2, 0)
    button.Position = position
    button.Text = "🔧 " .. name .. ": ON"
    button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    button.TextColor3 = Color3.fromRGB(0, 0, 0)
    button.TextSize = 16
    button.Font = Enum.Font.GothamBold
    makeUICorner(button, 8)
    
    local enabled = true
    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        button.Text = "🔧 " .. name .. (enabled and ": ON" or ": OFF")
        button.BackgroundColor3 = enabled 
            and Color3.fromRGB(0, 255, 0) 
            or Color3.fromRGB(255, 0, 0)
        callback(enabled)
        updateButtonStates()
        
        -- Show notification
        createNotification(name .. (enabled and " enabled!" or " disabled!"), 1.5)
    end)
    
    return button
end
-- Login Frame
local dogHubFrame = Instance.new("Frame")
dogHubFrame.Name = "LoginFrame"
dogHubFrame.Parent = screenGui
dogHubFrame.Size = UDim2.new(0, 420, 0, 250)
dogHubFrame.Position = UDim2.new(0.5, -210, 0.3, -100)
dogHubFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
dogHubFrame.BorderSizePixel = 0
makeUICorner(dogHubFrame, 12)
makeUIGradient(dogHubFrame, 
    Color3.fromRGB(40, 40, 40),
    Color3.fromRGB(25, 25, 25)
)

-- Shadow Effect
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.BackgroundTransparency = 1
shadow.Position = UDim2.new(0, -15, 0, -15)
shadow.Size = UDim2.new(1, 30, 1, 30)
shadow.ZIndex = 0
shadow.Image = "rbxassetid://5028857084"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.6
shadow.Parent = dogHubFrame

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = dogHubFrame
titleLabel.Size = UDim2.new(1, 0, 0.25, 0)
titleLabel.Text = "👑DOG HUB👑"
titleLabel.TextSize = 42
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
titleLabel.BackgroundTransparency = 1

-- Key Input
local keyTextBox = Instance.new("TextBox")
keyTextBox.Parent = dogHubFrame
keyTextBox.Size = UDim2.new(0.8, 0, 0.2, 0)
keyTextBox.Position = UDim2.new(0.1, 0, 0.4, 0)
keyTextBox.PlaceholderText = "Enter Key (DOG)"
keyTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
keyTextBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
keyTextBox.BorderSizePixel = 0
keyTextBox.TextSize = 18
keyTextBox.Font = Enum.Font.GothamSemibold
makeUICorner(keyTextBox, 8)

-- Submit Button
local submitButton = Instance.new("TextButton")
submitButton.Parent = dogHubFrame
submitButton.Size = UDim2.new(0.6, 0, 0.2, 0)
submitButton.Position = UDim2.new(0.2, 0, 0.7, 0)
submitButton.Text = "Login"
submitButton.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
submitButton.TextColor3 = Color3.fromRGB(0, 0, 0)
submitButton.TextSize = 20
submitButton.Font = Enum.Font.GothamBold
makeUICorner(submitButton, 8)

-- Controls Frame
local controlsFrame = Instance.new("Frame")
controlsFrame.Name = "ControlsFrame"
controlsFrame.Parent = screenGui
controlsFrame.Size = UDim2.new(0, 250, 0, 650)
controlsFrame.Position = UDim2.new(1, -270, 0.3, 0)
controlsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
controlsFrame.BorderSizePixel = 0
controlsFrame.Visible = false
makeUICorner(controlsFrame, 12)
makeUIGradient(controlsFrame,
    Color3.fromRGB(40, 40, 40),
    Color3.fromRGB(25, 25, 25)
)

-- Add shadow to controls frame
local controlsShadow = shadow:Clone()
controlsShadow.Parent = controlsFrame

-- Toggle Frame
local toggleFrame = Instance.new("Frame")
toggleFrame.Name = "ToggleFrame"
toggleFrame.Parent = controlsFrame
toggleFrame.Size = UDim2.new(0.8, 0, 0.3, 0)
toggleFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
toggleFrame.BackgroundTransparency = 1

-- Create Toggle Buttons
local warpToggle = createToggleButton("Warp Feature", UDim2.new(0, 0, 0, 0), function(enabled)
    warpEnabled = enabled
end)

local boomToggle = createToggleButton("Boom Feature", UDim2.new(0, 0, 0.25, 0), function(enabled)
    boomEnabled = enabled
end)

local flightToggle = createToggleButton("Flight Feature", UDim2.new(0, 0, 0.5, 0), function(enabled)
    flightEnabled = enabled
    if not enabled and flying then
        toggleFlight()
    end
end)

-- Main Controls UI
local controlsTitle = Instance.new("TextLabel")
controlsTitle.Parent = controlsFrame
controlsTitle.Size = UDim2.new(1, 0, 0.1, 0)
controlsTitle.Text = "Controls"
controlsTitle.TextColor3 = Color3.fromRGB(255, 255, 0)
controlsTitle.TextSize = 24
controlsTitle.Font = Enum.Font.GothamBold
controlsTitle.BackgroundTransparency = 1

-- Flight Status
local flightStatus = Instance.new("TextLabel")
flightStatus.Parent = controlsFrame
flightStatus.Size = UDim2.new(0.8, 0, 0.08, 0)
flightStatus.Position = UDim2.new(0.1, 0, 0.12, 0)
flightStatus.Text = "Flight: OFF"
flightStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
flightStatus.TextSize = 18
flightStatus.Font = Enum.Font.GothamSemibold
flightStatus.BackgroundTransparency = 1

-- Speed Display
local speedText = Instance.new("TextLabel")
speedText.Parent = controlsFrame
speedText.Size = UDim2.new(0.8, 0, 0.08, 0)
speedText.Position = UDim2.new(0.1, 0, 0.22, 0)
speedText.Text = "Speed: " .. FLIGHT_SPEED
speedText.TextColor3 = Color3.fromRGB(255, 255, 255)
speedText.TextSize = 18
speedText.Font = Enum.Font.GothamSemibold
speedText.BackgroundTransparency = 1

-- Speed Controls Label
local speedControlsLabel = Instance.new("TextLabel")
speedControlsLabel.Parent = controlsFrame
speedControlsLabel.Size = UDim2.new(0.8, 0, 0.08, 0)
speedControlsLabel.Position = UDim2.new(0.1, 0, 0.32, 0)
speedControlsLabel.Text = "Q/E - Adjust Speed"
speedControlsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedControlsLabel.TextSize = 16
speedControlsLabel.Font = Enum.Font.GothamSemibold
speedControlsLabel.BackgroundTransparency = 1

-- Distance Input
local distanceTextBox = Instance.new("TextBox")
distanceTextBox.Parent = controlsFrame
distanceTextBox.Size = UDim2.new(0.8, 0, 0.08, 0)
distanceTextBox.Position = UDim2.new(0.1, 0, 0.42, 0)
distanceTextBox.PlaceholderText = "Warp Distance"
distanceTextBox.Text = "5"
distanceTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
distanceTextBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
distanceTextBox.BorderSizePixel = 0
distanceTextBox.TextSize = 18
distanceTextBox.Font = Enum.Font.GothamSemibold
makeUICorner(distanceTextBox, 8)

-- Warp Button
local warpButton = Instance.new("TextButton")
warpButton.Parent = controlsFrame
warpButton.Size = UDim2.new(0.8, 0, 0.1, 0)
warpButton.Position = UDim2.new(0.1, 0, 0.52, 0)
warpButton.Text = "⚡ Warp (F)"
warpButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
warpButton.TextColor3 = Color3.fromRGB(0, 0, 0)
warpButton.TextSize = 20
warpButton.Font = Enum.Font.GothamBold
makeUICorner(warpButton, 8)

-- Boom Button
local boomButton = Instance.new("TextButton")
boomButton.Parent = controlsFrame
boomButton.Size = UDim2.new(0.8, 0, 0.1, 0)
boomButton.Position = UDim2.new(0.1, 0, 0.64, 0)
boomButton.Text = "💥 BOOM! (B)"
boomButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
boomButton.TextColor3 = Color3.fromRGB(255, 255, 255)
boomButton.TextSize = 20
boomButton.Font = Enum.Font.GothamBold
makeUICorner(boomButton, 8)

-- Light Button
local lightButton = Instance.new("TextButton")
lightButton.Parent = controlsFrame
lightButton.Size = UDim2.new(0.8, 0, 0.1, 0)
lightButton.Position = UDim2.new(0.1, 0, 0.76, 0)
lightButton.Text = "💡 Light ON"
lightButton.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
lightButton.TextColor3 = Color3.fromRGB(0, 0, 0)
lightButton.TextSize = 20
lightButton.Font = Enum.Font.GothamBold
makeUICorner(lightButton, 8)

-- Chat Button
local chatButton = Instance.new("TextButton")
chatButton.Parent = controlsFrame
chatButton.Size = UDim2.new(0.8, 0, 0.1, 0)
chatButton.Position = UDim2.new(0.1, 0, 0.88, 0)
chatButton.Text = "💭 Chat: ON"
chatButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
chatButton.TextColor3 = Color3.fromRGB(0, 0, 0)
chatButton.TextSize = 20
chatButton.Font = Enum.Font.GothamBold
makeUICorner(chatButton, 8)

-- Flight Button
local flightButton = Instance.new("TextButton")
flightButton.Parent = controlsFrame
flightButton.Size = UDim2.new(0.8, 0, 0.1, 0)
flightButton.Position = UDim2.new(0.1, 0, 1, 0)
flightButton.Text = "✈️ Toggle Flight (L)"
flightButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
flightButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flightButton.TextSize = 20
flightButton.Font = Enum.Font.GothamBold
makeUICorner(flightButton, 8)
-- Flight Functions
local function updateFlight()
    if not flying or not rootPart then return end
    
    local moveDirection = Vector3.new(0, 0, 0)
    local lookVector = camera.CFrame.LookVector
    local rightVector = camera.CFrame.RightVector
    
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        moveDirection = moveDirection + lookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        moveDirection = moveDirection - lookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        moveDirection = moveDirection - rightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        moveDirection = moveDirection + rightVector
    end
    if UserInputService:IsKeyDown(ASCEND_KEY) then
        moveDirection = moveDirection + Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(DESCEND_KEY) then
        moveDirection = moveDirection - Vector3.new(0, 1, 0)
    end
    
    if moveDirection.Magnitude > 0 then
        moveDirection = moveDirection.Unit * (FLIGHT_SPEED / 5) -- แก้จาก 10 เป็น 5
    end
    
    if rootPart then
        rootPart.CFrame = rootPart.CFrame + moveDirection
        rootPart.Velocity = Vector3.new(0, 0, 0)
    end
end

local function toggleFlight()
    if not flightButton then
        warn("Flight button not found!")
        return
    end
    if not flightEnabled then 
        createNotification("Flight feature is disabled!", 1.5)
        return 
    end
    if not humanoid or humanoid.Health <= 0 then 
        flying = false
        updateFlightStatus(false)
        return 
    end
    
    flying = not flying
    
    if flying then
        getCharacter()
        if humanoid and rootPart then
            humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
            rootPart.Velocity = Vector3.new(0, 0, 0)
        end
        createNotification("Flight activated!", 1.5)
    else
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Landing)
            task.wait(0.1)
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
        createNotification("Flight deactivated!", 1.5)
    end
    
    updateFlightStatus(flying)
end

local function adjustSpeed(increment)
    if not canAdjustSpeed then return end
    canAdjustSpeed = false
    
    -- แก้ไขการคำนวณความเร็ว
    FLIGHT_SPEED = math.clamp(FLIGHT_SPEED + increment, 10, MAX_SPEED)
    updateSpeedDisplay()
    
    -- แสดงการเปลี่ยนแปลง
    createNotification("Speed: " .. FLIGHT_SPEED, 1)
    
    -- Visual feedback
    local flashTween = TweenService:Create(speedText, TweenInfo.new(0.2), {
        TextColor3 = Color3.fromRGB(255, 255, 0)
    })
    flashTween:Play()
    
    task.wait(0.1) -- ลดเวลารอ
    speedText.TextColor3 = Color3.fromRGB(255, 255, 255)
    canAdjustSpeed = true
end

-- Teleport Function
local function teleportForward()
    if not warpEnabled then 
        createNotification("Warp is disabled!", 1.5)
        return 
    end
    
    if not humanoid or humanoid.Health <= 0 then return end
    
    local distance = tonumber(distanceTextBox.Text)
    if not distance then
        distanceTextBox.Text = "5"
        distance = 5
    end
    distance = math.clamp(distance, 1, 100)
    
    local direction = rootPart.CFrame.LookVector
    rootPart.CFrame = rootPart.CFrame + direction * distance
    createNotification("Warped " .. distance .. " studs!", 1)
end

-- Boom Function
local function boom()
    if not boomEnabled then 
        createNotification("Boom is disabled!", 1.5)
        return 
    end
    
    if not humanoid or humanoid.Health <= 0 then return end
    
    local explosionSound = Instance.new("Sound")
    explosionSound.SoundId = "rbxassetid://138186576"
    explosionSound.Volume = 99
    explosionSound.Parent = rootPart
    explosionSound:Play()
    
    local explosion = Instance.new("Explosion")
    explosion.Position = rootPart.Position
    explosion.BlastRadius = 20
    explosion.BlastPressure = 999999
    explosion.DestroyJointRadiusPercent = 100
    explosion.ExplosionType = Enum.ExplosionType.NoCraters
    explosion.Parent = workspace
    
    humanoid.Health = 0
    
    local fire = Instance.new("Fire")
    fire.Heat = 25
    fire.Size = 20
    fire.Parent = rootPart
    
    task.wait(1)
    explosionSound:Destroy()
    fire:Destroy()
end

-- Light Toggle Function
local function toggleLight()
    isLightOn = not isLightOn
    
    if isLightOn then
        Lighting.ClockTime = 14
        Lighting.Brightness = 2
        Lighting.ExposureCompensation = 0.5
        Lighting.Ambient = Color3.fromRGB(150, 150, 150)
        Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 150)
        Lighting.FogEnd = 100000
        
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("ColorCorrectionEffect") then
                v:Destroy()
            end
        end
        
        lightButton.Text = "💡 Light ON"
        lightButton.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
        createNotification("Light enabled!", 1.5)
    else
        Lighting.ClockTime = 14
        Lighting.Brightness = 1
        Lighting.ExposureCompensation = 0
        Lighting.Ambient = Color3.fromRGB(100, 100, 100)
        Lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 100)
        Lighting.FogEnd = 10000
        
        lightButton.Text = "💡 Light OFF"
        lightButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        createNotification("Light disabled!", 1.5)
    end
end

-- Chat Toggle Function
local function toggleChat()
    isChatEnabled = not isChatEnabled
    
    local chatWindowConfig = TextChatService:FindFirstChild("ChatWindowConfiguration")
    if chatWindowConfig then
        chatWindowConfig.Enabled = isChatEnabled
    end
    
    chatButton.Text = "💭 Chat: " .. (isChatEnabled and "ON" or "OFF")
    chatButton.BackgroundColor3 = isChatEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    
    createNotification("Chat " .. (isChatEnabled and "enabled!" or "disabled!"), 1.5)
end

-- Draggable Frame Functions
local dragging
local dragStart
local startPos

local function onDragStart(frame, input)
    dragging = frame
    dragStart = input.Position
    startPos = frame.Position
end

local function onDragEnd(input)
    dragging = nil
    dragStart = nil
    startPos = nil
end

local function onDragUpdate(input)
    if dragging and dragStart and startPos then
        local delta = input.Position - dragStart
        dragging.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end

-- Event Connections
submitButton.MouseButton1Click:Connect(function()
    if keyTextBox.Text == "DOG" then
        dogHubFrame.Visible = false
        controlsFrame.Visible = true
        createNotification("Login successful!", 2)
    else
        keyTextBox.Text = ""
        keyTextBox.PlaceholderText = "Wrong Key!"
        createNotification("Invalid key!", 2)
        task.wait(2)
        keyTextBox.PlaceholderText = "Enter Key (DOG)"
    end
end)

-- Button Click Connections
chatButton.MouseButton1Click:Connect(toggleChat)
lightButton.MouseButton1Click:Connect(toggleLight)
flightButton.MouseButton1Click:Connect(toggleFlight)
warpButton.MouseButton1Click:Connect(teleportForward)
boomButton.MouseButton1Click:Connect(boom)

-- Draggable Frame Connections
dogHubFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        onDragStart(dogHubFrame, input)
    end
end)

controlsFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        onDragStart(controlsFrame, input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        onDragUpdate(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        onDragEnd(input)
    end
end)

-- Keyboard Controls
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Q and flightEnabled then
        adjustSpeed(-SPEED_INCREMENT)
    elseif input.KeyCode == Enum.KeyCode.E and flightEnabled then
        adjustSpeed(SPEED_INCREMENT)
    elseif input.KeyCode == TOGGLE_KEY and flightEnabled then
        toggleFlight()
    elseif input.KeyCode == Enum.KeyCode.F and warpEnabled then
        teleportForward()
    elseif input.KeyCode == Enum.KeyCode.B and boomEnabled then
        boom()
    elseif input.KeyCode == Enum.KeyCode.O then
        toggleLight()
    elseif input.KeyCode == Enum.KeyCode.T then
        toggleChat()
    elseif input.KeyCode == Enum.KeyCode.K then
        screenGui.Enabled = not screenGui.Enabled
        if screenGui.Enabled then
            createNotification("UI Shown", 1)
        else
            createNotification("UI Hidden", 1)
        end
    end
end)

-- Character Added Handler
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    getCharacter()
    
    humanoid = character:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        if controlsFrame then
            controlsFrame.Visible = true
        end
        
        task.wait(2)
        flying = false
        updateFlightStatus(false)
    end)
    
    if flying then
        task.wait(0.1)
        humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
    end
end)

-- Connect Flight Update Loop
RunService.Heartbeat:Connect(updateFlight)

-- Initialize
getCharacter()
updateFlightStatus(false)
updateSpeedDisplay()
toggleChat()

-- Create Cleanup Function
local function cleanup()
    flying = false
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Landing)
    end
    
    if not isLightOn then
        toggleLight()
    end
    
    if not isChatEnabled then
        toggleChat()
    end
    
    for _, connection in pairs(connections) do
        connection:Disconnect()
    end
    
    screenGui:Destroy()
end

-- Connect Cleanup
script.Disabled:Connect(cleanup)

-- Add Hide/Show UI Hotkey Notification
createNotification("Press K to toggle UI visibility", 3)
