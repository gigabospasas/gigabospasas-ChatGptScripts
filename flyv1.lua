local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local flying = false -- Переменная для отслеживания состояния полёта
local speed = 50 -- Скорость полёта

local bodyVelocity
local bodyGyro

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

-- Управление полётом с помощью клавиши F
local userInput = game:GetService("UserInputService")
userInput.InputBegan:Connect(function(input, isProcessed)
    if isProcessed then return end

    if input.KeyCode == Enum.KeyCode.F then
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

        bodyVelocity.Velocity = moveDirection * speed
        bodyGyro.CFrame = workspace.CurrentCamera.CFrame
    end
end)
