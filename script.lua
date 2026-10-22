local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- ==========================================
-- 1. НАСТРОЙКИ GUI
-- ==========================================
local espEnabled = true
local espHighlights = {}

-- ==========================================
-- 2. ЛОГИКА ESP (как в прошлом коде)
-- ==========================================
local function getPlayerRole(player)
    local backpack = player:FindFirstChild("Backpack")
    local character = player.Character
    
    if (backpack and backpack:FindFirstChild("Knife")) or 
       (character and character:FindFirstChild("Knife")) then
        return "Murderer"
    end
    if (backpack and backpack:FindFirstChild("Gun")) or 
       (character and character:FindFirstChild("Gun")) then
        return "Sheriff"
    end
    return "Innocent"
end

local function updateESP(player, color)
    if not player.Character then return end
    
    if espHighlights[player] and espHighlights[player].Parent then
        espHighlights[player].FillColor = color
        espHighlights[player].OutlineColor = color
        return
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "MM2_ESP"
    highlight.FillColor = color
    highlight.FillTransparency = 0.6
    highlight.OutlineColor = color
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = player.Character
    
    espHighlights[player] = highlight
end

RunService.RenderStepped:Connect(function()
    if not espEnabled then
        -- Если выключено, удаляем все подсветки
        for player, highlight in pairs(espHighlights) do
            if highlight and highlight.Parent then
                highlight:Destroy()
            end
        end
        espHighlights = {}
        return
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        
        local role = getPlayerRole(player)
        local color
        
        if role == "Murderer" then
            color = Color3.fromRGB(255, 0, 0)
        elseif role == "Sheriff" then
            color = Color3.fromRGB(0, 0, 255)
        else
            color = Color3.fromRGB(0, 255, 0)
        end
        
        updateESP(player, color)
    end
end)

-- ==========================================
-- 3. СОЗДАНИЕ GUI (Окно в стиле "Real")
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MM2_Client"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Главное окно
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 220, 0, 150)
mainFrame.Position = UDim2.new(0, 20, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35) -- Тёмный фон
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- Можно перетаскивать
mainFrame.Parent = screenGui

-- Скругление углов
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

-- Обводка
local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(90, 140, 255) -- Синяя обводка
uiStroke.Thickness = 1.5
uiStroke.Parent = mainFrame

-- Заголовок
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
title.BorderSizePixel = 0
title.Text = "  MM2 Client | ESP"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = title

-- Линия под заголовком (акцент)
local accentLine = Instance.new("Frame")
accentLine.Size = UDim2.new(1, 0, 0, 2)
accentLine.Position = UDim2.new(0, 0, 0, 30)
accentLine.BackgroundColor3 = Color3.fromRGB(90, 140, 255)
accentLine.BorderSizePixel = 0
accentLine.Parent = mainFrame

-- Контейнер для кнопки
local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.new(1, -20, 0, 40)
buttonContainer.Position = UDim2.new(0, 10, 0, 50)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = mainFrame

-- Кнопка ESP
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ESP_Toggle"
toggleBtn.Size = UDim2.new(1, 0, 1, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
toggleBtn.BorderSizePixel = 0
toggleBtn.Text = "ESP: ВКЛ"
toggleBtn.TextColor3 = Color3.fromRGB(0, 255, 0) -- Зелёный текст
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.Gotham
toggleBtn.Parent = buttonContainer

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = toggleBtn

local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Color3.fromRGB(80, 80, 100)
btnStroke.Thickness = 1
btnStroke.Parent = toggleBtn

-- Логика переключения
toggleBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        toggleBtn.Text = "ESP: ВКЛ"
        toggleBtn.TextColor3 = Color3.fromRGB(0, 255, 0) -- Зелёный
        btnStroke.Color = Color3.fromRGB(0, 255, 0)
    else
        toggleBtn.Text = "ESP: ВЫКЛ"
        toggleBtn.TextColor3 = Color3.fromRGB(255, 0, 0) -- Красный
        btnStroke.Color = Color3.fromRGB(255, 0, 0)
    end
end)

-- Подсказка внизу
local hint = Instance.new("TextLabel")
hint.Size = UDim2.new(1, -20, 0, 20)
hint.Position = UDim2.new(0, 10, 1, -25)
hint.BackgroundTransparency = 1
hint.Text = "Перетащи окно за заголовок"
hint.TextColor3 = Color3.fromRGB(150, 150, 150)
hint.TextSize = 11
hint.Font = Enum.Font.Gotham
hint.Parent = mainFrame
-- ==========================================
-- 5. SILENT AIM (базовый каркас)
-- ==========================================
local silentAimEnabled = false
local silentAimTarget = nil

-- Функция поиска ближайшего игрока
local function getClosestPlayerToMouse()
    local mousePos = game:GetService("UserInputService"):GetMouseLocation()
    local closest = nil
    local closestDist = 100 -- FOV радиус

    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
        if not onScreen then continue end

        local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
        if dist < closestDist then
            closestDist = dist
            closest = player
        end
    end
    return closest
end

-- Хук метатаблицы (подмена координат)
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    -- Если Silent Aim включен и это удар/рейкаст
    if silentAimEnabled and (method == "Raycast" or method == "FindPartOnRay") then
        local target = getClosestPlayerToMouse()
        if target and target.Character then
            local hrp = target.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                -- Подменяем направление на цель
                if method == "Raycast" then
                    -- Для Raycast (Workspace:Raycast)
                    local origin = args[1]
                    local direction = args[2]
                    local newDir = (hrp.Position - origin).Unit * direction.Magnitude
                    args[2] = newDir
                end
                -- Для FindPartOnRay (старый метод)
                -- ...
            end
        end
    end

    return oldNamecall(self, unpack(args))
end)

setreadonly(mt, true)

-- Кнопка Silent Aim в GUI
local silentBtn = Instance.new("TextButton")
silentBtn.Name = "SilentAimToggle"
silentBtn.Size = UDim2.new(1, 0, 0, 30)
silentBtn.Position = UDim2.new(0, 10, 0, 140) -- Под кнопкой шрифта
silentBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
silentBtn.BorderSizePixel = 0
silentBtn.Text = "Silent Aim: ВЫКЛ"
silentBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
silentBtn.TextSize = 14
silentBtn.Font = Enum.Font.Gotham
silentBtn.Parent = mainFrame

local silentCorner = Instance.new("UICorner")
silentCorner.CornerRadius = UDim.new(0, 6)
silentCorner.Parent = silentBtn

silentBtn.MouseButton1Click:Connect(function()
    silentAimEnabled = not silentAimEnabled
    if silentAimEnabled then
        silentBtn.Text = "Silent Aim: ВКЛ"
        silentBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        silentBtn.Text = "Silent Aim: ВЫКЛ"
        silentBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
end)
