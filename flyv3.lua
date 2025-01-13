local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local flying = false -- Переменная для отслеживания состояния полёта
local speed = 50 -- Скорость полёта
local bindKey = Enum.KeyCode.G -- Клавиша для активации/деактивации полёта

local bodyVelocity
local bodyGyro

-- Функции для полёта
local function startFlying()
    flying = true

    -- Создаём BodyVelocity для управления скоростью
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e4, 1e4, 1e4)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = humanoidRootPart

    -- Создаём BodyGyro для стабилизации игрока в воздухе
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e4, 1e4, 1e4)
    bodyGyro.CFrame = humanoidRootPart.CFrame
    bodyGyro.Parent = humanoidRootPart
end

local function stopFlying()
    flying = false

    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end

    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
end

-- Управление полётом с помощью заданной клавиши
local userInput = game:GetService("UserInputService")
userInput.InputBegan:Connect(function(input, isProcessed)
    if isProcessed then return end

    if input.KeyCode == bindKey then
        if flying then
            stopFlying()
        else
            startFlying()
        end
    end
end)

-- Управление движением в полёте
game:GetService("RunService").RenderStepped:Connect(function()
    if flying and bodyVelocity then
        local moveDirection = Vector3.zero

        if userInput:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + workspace.CurrentCamera.CFrame.LookVector
        end
        if userInput:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - workspace.CurrentCamera.CFrame.LookVector
        end
        if userInput:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - workspace.CurrentCamera.CFrame.RightVector
        end
        if userInput:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + workspace.CurrentCamera.CFrame.RightVector
        end
        if userInput:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if userInput:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end

        bodyVelocity.Velocity = moveDirection * speed
        bodyGyro.CFrame = workspace.CurrentCamera.CFrame
    end
end)

-- Создание GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.Name = "FlyGUI"

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0.5, -150, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Parent = screenGui

frame.Active = true
frame.Draggable = true

local speedLabel = Instance.new("TextLabel")
speedLabel.Text = "Fly Speed"
speedLabel.Size = UDim2.new(0, 300, 0, 40)
speedLabel.Position = UDim2.new(0, 0, 0, 0)
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextSize = 20
speedLabel.BackgroundTransparency = 1
speedLabel.Parent = frame

local speedInput = Instance.new("TextBox")
speedInput.Text = tostring(speed)
speedInput.Size = UDim2.new(0, 100, 0, 40)
speedInput.Position = UDim2.new(0, 100, 0, 50)
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.TextSize = 20
speedInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedInput.Parent = frame
speedInput.ClearTextOnFocus = false

local bindKeyButton = Instance.new("TextButton")
bindKeyButton.Text = "Change Bind Key"
bindKeyButton.Size = UDim2.new(0, 300, 0, 40)
bindKeyButton.Position = UDim2.new(0, 0, 0, 100)
bindKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
bindKeyButton.TextSize = 20
bindKeyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
bindKeyButton.Parent = frame

local bindKeyLabel = Instance.new("TextLabel")
bindKeyLabel.Text = "Bind Key: " .. bindKey.Name
bindKeyLabel.Size = UDim2.new(0, 300, 0, 40)
bindKeyLabel.Position = UDim2.new(0, 0, 0, 140)
bindKeyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
bindKeyLabel.TextSize = 20
bindKeyLabel.BackgroundTransparency = 1
bindKeyLabel.Parent = frame

-- Обработка изменения скорости
speedInput.FocusLost:Connect(function()
    local newSpeed = tonumber(speedInput.Text)
    if newSpeed then
        speed = newSpeed
    else
        speedInput.Text = tostring(speed)
    end
end)

-- Смена клавиши бинда
bindKeyButton.MouseButton1Click:Connect(function()
    bindKeyButton.Text = "Press any key"
    local connection
    connection = userInput.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            bindKey = input.KeyCode
            bindKeyLabel.Text = "Bind Key: " .. bindKey.Name
            bindKeyButton.Text = "Change Bind Key"
            connection:Disconnect()
        end
    end)
end)
