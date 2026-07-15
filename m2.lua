--[[
    Remote Spy + Instant Mine Tester (ИСПРАВЛЕНО)
    Кнопки работают, логи выводятся в окно.
    Запусти, нажми "Enable Spy", подойди к кристаллу, нажми "Mine Once".
    Скопируй строки с [SPY] и пришли мне.
]]

local player = game.Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")

-- Удаляем старый GUI
if game.CoreGui:FindFirstChild("SpyGUI") then
    game.CoreGui.SpyGUI:Destroy()
end

-- ====== ПРОСТОЙ GUI ======
local gui = Instance.new("ScreenGui")
gui.Name = "SpyGUI"
gui.Parent = game.CoreGui
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 380, 0, 260)
mainFrame.Position = UDim2.new(0, 20, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
title.Text = "REMOTE SPY + MINE TEST"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 14
title.BorderSizePixel = 0
title.Parent = mainFrame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

-- Кнопка Enable Spy
local spyBtn = Instance.new("TextButton")
spyBtn.Size = UDim2.new(0, 170, 0, 40)
spyBtn.Position = UDim2.new(0, 10, 0, 40)
spyBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
spyBtn.Text = "Enable Spy"
spyBtn.TextColor3 = Color3.new(1,1,1)
spyBtn.Font = Enum.Font.SourceSansBold
spyBtn.TextSize = 14
spyBtn.BorderSizePixel = 0
spyBtn.AutoButtonColor = false
spyBtn.Parent = mainFrame
Instance.new("UICorner", spyBtn).CornerRadius = UDim.new(0, 8)

-- Кнопка Mine Once
local mineBtn = Instance.new("TextButton")
mineBtn.Size = UDim2.new(0, 170, 0, 40)
mineBtn.Position = UDim2.new(0, 190, 0, 40)
mineBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
mineBtn.Text = "Mine Once"
mineBtn.TextColor3 = Color3.new(1,1,1)
mineBtn.Font = Enum.Font.SourceSansBold
mineBtn.TextSize = 14
mineBtn.BorderSizePixel = 0
mineBtn.AutoButtonColor = false
mineBtn.Parent = mainFrame
Instance.new("UICorner", mineBtn).CornerRadius = UDim.new(0, 8)

-- Лог-поле
local logBox = Instance.new("TextBox")
logBox.Size = UDim2.new(1, -20, 1, -100)
logBox.Position = UDim2.new(0, 10, 0, 90)
logBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
logBox.TextColor3 = Color3.new(1,1,1)
logBox.Font = Enum.Font.SourceSans
logBox.TextSize = 12
logBox.TextYAlignment = Enum.TextYAlignment.Top
logBox.TextXAlignment = Enum.TextXAlignment.Left
logBox.MultiLine = true
logBox.ClearTextOnFocus = false
logBox.BorderSizePixel = 0
logBox.Text = "Готов. Нажми 'Enable Spy', затем 'Mine Once' у кристалла."
logBox.Parent = mainFrame
Instance.new("UICorner", logBox).CornerRadius = UDim.new(0, 8)

-- ====== ЛОГИКА ======
local spyActive = false
local hooked = {}

local function addLog(msg)
    logBox.Text = logBox.Text .. "\n" .. os.date("%X") .. " " .. msg
end

-- Функция перехвата RemoteEvent
local function hookRemote(remote)
    if hooked[remote] then return end
    hooked[remote] = true
    local oldFireServer = remote.FireServer
    remote.FireServer = function(self, ...)
        if spyActive then
            local args = {...}
            local argStr = ""
            for i, v in ipairs(args) do
                argStr = argStr .. tostring(v) .. (i < #args and ", " or "")
            end
            addLog("[SPY] " .. remote.Name .. "(" .. argStr .. ")")
        end
        return oldFireServer(self, ...)
    end
end

-- Подключаем все существующие RemoteEvent
for _, remote in ipairs(replicatedStorage:GetDescendants()) do
    if remote:IsA("RemoteEvent") then
        hookRemote(remote)
    end
end
-- Подключаем новые, если появятся
replicatedStorage.DescendantAdded:Connect(function(desc)
    if desc:IsA("RemoteEvent") then
        hookRemote(desc)
    end
end)

-- Кнопка Spy
spyBtn.MouseButton1Click:Connect(function()
    spyActive = not spyActive
    spyBtn.Text = spyActive and "Spy ON" or "Enable Spy"
    spyBtn.BackgroundColor3 = spyActive and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
    addLog(spyActive and "Spy включён" or "Spy выключен")
end)

-- Кнопка Mine Once (мгновенная добыча)
mineBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    if not char then
        addLog("Нет персонажа")
        return
    end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then
        addLog("Нет HumanoidRootPart")
        return
    end

    addLog("Пытаемся собрать ближайший кристалл...")

    local found = false
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local part = obj.Parent
            if part:IsA("BasePart") then
                local dist = (part.Position - root.Position).Magnitude
                if dist <= obj.MaxActivationDistance then
                    found = true
                    addLog("Найден ProximityPrompt: " .. obj.Name .. " на " .. part.Name)
                    -- Пробуем выполнить мгновенный ввод
                    pcall(function()
                        obj:InputHoldBegin()
                        wait(0.02)
                        obj:InputHoldEnd()
                        addLog("InputHoldBegin/End выполнены")
                    end)
                    -- Также пробуем просто установить Duration в 0
                    pcall(function()
                        obj.Duration = 0
                        addLog("Duration установлен в 0")
                    end)
                    break -- обрабатываем только первый попавшийся
                end
            end
        end
    end
    if not found then
        addLog("Рядом нет активных ProximityPrompt. Подойди ближе.")
    end
end)

addLog("Скрипт загружен. Включи Spy, подойди к кристаллу, нажми Mine Once.")
