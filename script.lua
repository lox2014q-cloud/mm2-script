local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 1. НАСТРОЙКИ
-- ==========================================
local espEnabled = true
local silentAimEnabled = false
local antiFlingEnabled = false
local flingEnabled = false
local espHighlights = {}

-- ==========================================
-- 2. ЛОГИКА ESP
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

-- ==========================================
-- 3. АНТИ-ФЛИНГ (Защита)
-- ==========================================
RunService.Heartbeat:Connect(function()
    if not antiFlingEnabled then return end
    if not LocalPlayer.Character then return end
    
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Если скорость слишком высокая (признак флинга)
    if hrp.AssemblyLinearVelocity.Magnitude > 100 then
        -- Сбрасываем скорость и вращение
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end
end)

-- ==========================================
-- 4. ФЛИНГ (Атака)
-- ==========================================
local function getClosestPlayer()
    local closest = nil
    local closestDist = math.huge
    local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myPos then return nil end

    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        local dist = (hrp.Position - myPos.Position).Magnitude
        if dist < closestDist then
            closestDist = dist
            closest = player
        end
    end
    return closest
end

RunService.Heartbeat:Connect(function()
    if not flingEnabled then return end
    if not LocalPlayer.Character then return end
    
    local myHrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end
    
    local target = getClosestPlayer()
    if target and target.Character then
        local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
        if targetHrp then
            -- Телепортируемся к цели и крутимся (вызывает флинг)
            myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 1)
            myHrp.AssemblyAngularVelocity = Vector3.new(9999, 9999, 9999)
        end
    end
end)

-- ==========================================
-- 5. ЛОГИКА SILENT AIM
-- ==========================================
local function getClosestPlayerToMouse()
    local mousePos = game:GetService("UserInputService"):GetMouseLocation()
    local closest = nil
    local closestDist = 150

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

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if silentAimEnabled and (method == "Raycast" or method == "FindPartOnRay") then
        local target = getClosestPlayerToMouse()
        if target and target.Character then
            local hrp = target.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if method == "Raycast" then
                    local origin = args[1]
                    local direction = args[2]
                    local newDir = (hrp.Position - origin).Unit * direction.Magnitude
                    args[2] = newDir
                end
            end
        end
    end

    return oldNamecall(self, unpack(args))
end)

setreadonly(mt, true)

-- ==========================================
-- 6. СОЗДАНИЕ GUI
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MM2_Client"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 220, 0, 310) -- Увеличили высоту до 310
mainFrame.Position = UDim2.new(0, 20, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(90, 140, 255)
uiStroke.Thickness = 1.5
uiStroke.Parent = mainFrame

-- Заголовок
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
title.BorderSizePixel = 0
title.Text = "  MM2 Client"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = title

local accentLine = Instance.new("Frame")
accentLine.Size = UDim2.new(1, 0, 0, 2)
accentLine.Position = UDim2.new(0, 0, 0, 30)
accentLine.BackgroundColor3 = Color3.fromRGB(90, 140, 255)
accentLine.BorderSizePixel = 0
accentLine.Parent = mainFrame

-- Функция для создания кнопок (чтобы не дублировать код)
local function createButton(name, text, yPos, isActive)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextSize = 14
    btn.Font = Enum.Font.Gotham
    btn.Parent = mainFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Parent = btn
    
    return btn, stroke
end

-- Кнопка ESP
local espBtn, espStroke = createButton("ESP_Toggle", "ESP: ВКЛ", 45, espEnabled)
espBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
espStroke.Color = Color3.fromRGB(0, 255, 0)

espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        espBtn.Text = "ESP: ВКЛ"
        espBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
        espStroke.Color = Color3.fromRGB(0, 255, 0)
    else
        espBtn.Text = "ESP: ВЫКЛ"
        espBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
        espStroke.Color = Color3.fromRGB(255, 0, 0)
    end
end)

-- Кнопка Silent Aim
local aimBtn, aimStroke = createButton("SilentAimToggle", "Silent Aim: ВЫКЛ", 90, silentAimEnabled)
aimBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
aimStroke.Color = Color3.fromRGB(255, 0, 0)

aimBtn.MouseButton1Click:Connect(function()
    silentAimEnabled = not silentAimEnabled
    if silentAimEnabled then
        aimBtn.Text = "Silent Aim: ВКЛ"
        aimBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
        aimStroke.Color = Color3.fromRGB(0, 255, 0)
    else
        aimBtn.Text = "Silent Aim: ВЫКЛ"
        aimBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
        aimStroke.Color = Color3.fromRGB(255, 0, 0)
    end
end)

-- Кнопка Anti-Fling
local antiFlingBtn, antiFlingStroke = createButton("AntiFlingToggle", "Anti-Fling: ВЫКЛ", 135, antiFlingEnabled)
antiFlingBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
antiFlingStroke.Color = Color3.fromRGB(255, 0, 0)

antiFlingBtn.MouseButton1Click:Connect(function()
    antiFlingEnabled = not antiFlingEnabled
    if antiFlingEnabled then
        antiFlingBtn.Text = "Anti-Fling: ВКЛ"
        antiFlingBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
        antiFlingStroke.Color = Color3.fromRGB(0, 255, 0)
    else
        antiFlingBtn.Text = "Anti-Fling: ВЫКЛ"
        antiFlingBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
        antiFlingStroke.Color = Color3.fromRGB(255, 0, 0)
    end
end)

-- Кнопка Fling
local flingBtn, flingStroke = createButton("FlingToggle", "Fling: ВЫКЛ", 180, flingEnabled)
flingBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
flingStroke.Color = Color3.fromRGB(255, 0, 0)

flingBtn.MouseButton1Click:Connect(function()
    flingEnabled = not flingEnabled
    if flingEnabled then
        flingBtn.Text = "Fling: ВКЛ"
        flingBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
        flingStroke.Color = Color3.fromRGB(0, 255, 0)
    else
        flingBtn.Text = "Fling: ВЫКЛ"
        flingBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
        flingStroke.Color = Color3.fromRGB(255, 0, 0)
    end
end)

-- Подсказка
local hint = Instance.new("TextLabel")
hint.Size = UDim2.new(1, -20, 0, 20)
hint.Position = UDim2.new(0, 10, 1, -25)
hint.BackgroundTransparency = 1
hint.Text = "Перетащи окно за заголовок"
hint.TextColor3 = Color3.fromRGB(150, 150, 150)
hint.TextSize = 11
hint.Font = Enum.Font.Gotham
hint.Parent = mainFrame
