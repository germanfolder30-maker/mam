--[[
    Remote Spy + Instant Mine Tester (простой GUI)
    Запусти, нажми "Enable Spy", подойди к кристаллу, нажми "Mine Once".
    Все RemoteEvent, вызванные при сборе, отобразятся в окне.
    Скопируй их и пришли мне.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local coreGui = game:GetService("CoreGui")

-- Удаляем старый GUI, если есть
if coreGui:FindFirstChild("SpyGUI") then
    coreGui.SpyGUI:Destroy()
end

-- ===================== ПРОСТОЙ GUI =====================
local gui = Instance.new("ScreenGui")
gui.Name = "SpyGUI"
gui.Parent = coreGui
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 280)
mainFrame.Position = UDim2.new(0, 20, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
title.Text = "REMOTE SPY + MINE TEST"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 14
title.BorderSizePixel = 0
title.Parent = mainFrame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

-- Кнопка Enable Spy
local spyBtn = Instance.new("TextButton")
spyBtn.Size = UDim2.new(0, 160, 0, 35)
spyBtn.Position = UDim2.new(0, 10, 0, 40)
spyBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
spyBtn.Text = "Enable Spy"
spyBtn.TextColor3 = Color3.new(1,1,1)
spyBtn.Font = Enum.Font.SourceSansBold
spyBtn.TextSize = 14
spyBtn.BorderSizePixel = 0
spyBtn.AutoButtonColor = false
spyBtn.Parent = mainFrame
Instance.new("UICorner", spyBtn).CornerRadius = UDim.new(0, 6)

-- Кнопка Mine Once
local mineBtn = Instance.new("TextButton")
mineBtn.Size = UDim2.new(0, 160, 0, 35)
mineBtn.Position = UDim2.new(0, 180, 0, 40)
mineBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
mineBtn.Text = "Mine Once"
mineBtn.TextColor3 = Color3.new(1,1,1)
mineBtn.Font = Enum.Font.SourceSansBold
mineBtn.TextSize = 14
mineBtn.BorderSizePixel = 0
mineBtn.AutoButtonColor = false
mineBtn.Parent = mainFrame
Instance.new("UICorner", mineBtn).CornerRadius = UDim.new(0, 6)

-- Текстовое поле для логов
local logBox = Instance.new("TextBox")
logBox.Size = UDim2.new(1, -20, 1, -90)
logBox.Position = UDim2.new(0, 10, 0, 85)
logBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
logBox.TextColor3 = Color3.new(1,1,1)
logBox.Font = Enum.Font.SourceSans
logBox.TextSize = 12
logBox.TextYAlignment = Enum.TextYAlignment.Top
logBox.TextXAlignment = Enum.TextXAlignment.Left
logBox.MultiLine = true
logBox.ClearTextOnFocus = false
logBox.BorderSizePixel = 0
logBox.Text = "Нажми 'Enable Spy', затем подойди к кристаллу и нажми 'Mine Once'. Здесь появятся логи."
logBox.Parent = mainFrame
Instance.new("UICorner", logBox).CornerRadius = UDim.new(0, 6)

-- ===================== ЛОГИКА =====================
local spyActive = false
local hooked = {}

local function addLog(msg)
    logBox.Text = logBox.Text .. "\n" .. os.date("%X") .. " " .. msg
end

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
for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
    if remote:IsA("RemoteEvent") then
        hookRemote(remote)
    end
end
-- Следим за новыми
ReplicatedStorage.DescendantAdded:Connect(function(desc)
    if desc:IsA("RemoteEvent") then
        hookRemote(desc)
    end
end)

-- Кнопка Spy
local spyEnabled = false
spyBtn.MouseButton1Click:Connect(function()
    spyEnabled = not spyEnabled
    spyActive = spyEnabled
    spyBtn.Text = spyEnabled and "Spy ON" or "Enable Spy"
    spyBtn.BackgroundColor3 = spyEnabled and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
    addLog(spyEnabled and "Spy включён" or "Spy выключен")
end)

-- Кнопка Mine Once
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
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local part = obj.Parent
            if part:IsA("BasePart") then
                local dist = (part.Position - root.Position).Magnitude
                if dist <= obj.MaxActivationDistance then
                    found = true
                    addLog("Найден ProximityPrompt: " .. obj.Name .. " на " .. part.Name)
                    pcall(function()
                        obj:InputHoldBegin()
                        task.wait(0.01)
                        obj:InputHoldEnd()
                        addLog("Выполнен InputHoldBegin/End для " .. obj.Name)
                    end)
                    break -- берём только первый
                end
            end
        end
    end
    if not found then
        addLog("Рядом нет активных ProximityPrompt. Подойди ближе к кристаллу.")
    end
end)

addLog("Скрипт готов. Нажми 'Enable Spy', затем 'Mine Once' около кристалла.")
