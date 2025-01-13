local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local flying = false
local speed = 50
local height = 50
local bindKey = Enum.KeyCode.F -- Стандартная клавиша для активации полета

local antiTPEnabled = true  -- Переменная для управления анти-ТП

-- Создание GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.Name = "FlyGUI"

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 300)  -- Увеличиваем высоту для дополнительного текста
frame.Position = UDim2.new(0.5, -150, 0.5, -150)  -- Размещаем центр фрейма
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Parent = screenGui

-- Добавляем возможность двигать фрейм
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

-- Текстовое поле для ввода скорости
local speedInput = Instance.new("TextBox")
speedInput.Text = tostring(speed)
speedInput.Size = UDim2.new(0, 100, 0, 40)
speedInput.Position = UDim2.new(0, 100, 0, 50)
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.TextSize = 20
speedInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedInput.Parent = frame
speedInput.ClearTextOnFocus = false  -- Не очищать текст при фокусе

-- Кнопка для смены клавиши бинда
local keyBindButton = Instance.new("TextButton")
keyBindButton.Text = "Change Bind Key"
keyBindButton.Size = UDim2.new(0, 300, 0, 40)
keyBindButton.Position = UDim2.new(0, 0, 0, 100)
keyBindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
keyBindButton.TextSize = 20
keyBindButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
keyBindButton.Parent = frame

local keyBindLabel = Instance.new("TextLabel")
keyBindLabel.Text = "Bind Key: " .. bindKey.Name
keyBindLabel.Size = UDim2.new(0, 300, 0, 40)
keyBindLabel.Position = UDim2.new(0, 0, 0, 140)
keyBindLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
keyBindLabel.TextSize = 20
keyBindLabel.BackgroundTransparency = 1
keyBindLabel.Parent = frame

-- Текст для уведомления об анти-ТП
local antiTPText = Instance.new("TextLabel")
antiTPText.Text = "Anti-TP: Enabled (Sometimes works incorrectly)"
antiTPText.Size = UDim2.new(0, 300, 0, 40)
antiTPText.Position = UDim2.new(0, 0, 0, 180)
antiTPText.TextColor3 = Color3.fromRGB(255, 255, 255)
antiTPText.TextSize = 18
antiTPText.BackgroundTransparency = 1
antiTPText.TextWrapped = true  -- Включаем перенос текста
antiTPText.TextYAlignment = Enum.TextYAlignment.Top  -- Выравнивание по верхнему краю
antiTPText.Parent = frame

-- Кнопка для включения/выключения анти-ТП
local antiTPButton = Instance.new("TextButton")
antiTPButton.Text = "Toggle Anti-TP"
antiTPButton.Size = UDim2.new(0, 300, 0, 40)
antiTPButton.Position = UDim2.new(0, 0, 0, 220)
antiTPButton.TextColor3 = Color3.fromRGB(255, 255, 255)
antiTPButton.TextSize = 20
antiTPButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
antiTPButton.Parent = frame

-- Функции полета
local bodyVelocity, bodyGyro

local lastPosition = humanoidRootPart.Position  -- Переменная для хранения последней позиции игрока

local function startFlying()
    flying = true
    humanoid.PlatformStand = true  -- Отключаем анимации и движения персонажа

    -- Создание BodyVelocity для управления скоростью
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e4, 1e4, 1e4)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = humanoidRootPart

    -- Создание BodyGyro для стабилизации в воздухе
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e4, 1e4, 1e4)
    bodyGyro.CFrame = humanoidRootPart.CFrame
    bodyGyro.Parent = humanoidRootPart
end

local function stopFlying()
    flying = false
    humanoid.PlatformStand = false -- Включаем стандартное поведение

    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end

    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
end

-- Управление полётом
local function onKeyPress(input, isProcessed)
    if isProcessed then return end
    if input.KeyCode == bindKey then
        if flying then
            stopFlying()
        else
            startFlying()
        end
    end
end

-- Функция для анти-ТП
local function antiTP()
    if not antiTPEnabled then return end  -- Если анти-ТП выключен, не проверяем

    local positionDifference = (humanoidRootPart.Position - lastPosition).magnitude
    if positionDifference > 50 then  -- Если разница в позициях слишком велика (например, быстрее чем 50 студийных единиц за кадр)
        humanoidRootPart.CFrame = CFrame.new(lastPosition)  -- Возвращаем игрока на последнюю позицию
    else
        lastPosition = humanoidRootPart.Position  -- Обновляем позицию, если перемещение нормальное
    end
end

-- Управление движением в полёте
game:GetService("RunService").RenderStepped:Connect(function()
    if flying then
        local moveDirection = Vector3.zero
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + workspace.CurrentCamera.CFrame.LookVector
        end
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - workspace.CurrentCamera.CFrame.LookVector
        end
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - workspace.CurrentCamera.CFrame.RightVector
        end
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + workspace.CurrentCamera.CFrame.RightVector
        end
        humanoidRootPart.Velocity = moveDirection * speed
    end
end)

-- Переменная для блокировки повторной привязки клавиши
local isBinding = false
local inputConnection -- Переменная для подключения события

-- Подключение события для смены клавиши бинда
keyBindButton.MouseButton1Click:Connect(function()
    if isBinding then return end  -- Если уже идет процесс привязки, не начинаем новый
    isBinding = true  -- Устанавливаем флаг, что привязка началась

    -- Делаем так, чтобы игрок мог выбрать новую клавишу
    local function onKeyPressed(input, gameProcessed)
        if gameProcessed then return end  -- Проверяем, что это не системное событие
        bindKey = input.KeyCode  -- Обновляем bindKey на новую клавишу
        keyBindLabel.Text = "Bind Key: " .. bindKey.Name  -- Обновляем текст с новой клавишей
        
        -- После того как клавиша была выбрана, больше не слушаем события
        isBinding = false
        if inputConnection then
            inputConnection:Disconnect()  -- Отключаем слушатель
        end
    end
    
    -- Начинаем слушать ввод с клавиатуры
    inputConnection = game:GetService("UserInputService").InputBegan:Connect(onKeyPressed)
end)

-- Функция для изменения скорости через текстовое поле
speedInput.FocusLost:Connect(function()
    local newSpeed = tonumber(speedInput.Text)
    if newSpeed then
        speed = newSpeed  -- Убираем ограничение на максимальное значение скорости
        speedInput.Text = tostring(speed)  -- Обновляем текст в поле
    else
        speedInput.Text = tostring(speed)  -- Если введено некорректное значение, восстанавливаем старую скорость
    end
end)

-- Подключение к событию нажатия клавиши
game:GetService("UserInputService").InputBegan:Connect(onKeyPress)

-- Проверка на анти-ТП при каждом кадре
game:GetService("RunService").RenderStepped:Connect(antiTP)

-- Кнопка для включения/выключения анти-ТП
antiTPButton.MouseButton1Click:Connect(function()
    antiTPEnabled = not antiTPEnabled  -- Переключаем значение
    if antiTPEnabled then
        antiTPText.Text = "Anti-TP: Enabled (Sometimes works incorrectly)"
    else
        antiTPText.Text = "Anti-TP: Disabled"
    end
end)
