--// Красивое меню для эксплоита (CoreGui) //
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local uis = game:GetService("UserInputService")
local runService = game:GetService("RunService")

-- Конфиг
local WIDTH = 280
local HEIGHT = 500
local CORNER = 12
local ACCENT = Color3.fromRGB(100, 180, 255)
local BG = Color3.fromRGB(20, 25, 35)
local TEXT = Color3.fromRGB(230, 230, 235)

-- Удаляем старое меню
if game.CoreGui:FindFirstChild("DraggableMenu") then
    game.CoreGui.DraggableMenu:Destroy()
end

-- ScreenGui в CoreGui
local gui = Instance.new("ScreenGui")
gui.Name = "DraggableMenu"
gui.Parent = game.CoreGui
gui.ResetOnSpawn = false

-- Главный контейнер
local main = Instance.new("Frame")
main.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
main.Position = UDim2.new(0.02, 0, 0.1, 0)
main.BackgroundColor3 = BG
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, CORNER)

-- Градиент
local grad = Instance.new("UIGradient", main)
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, BG),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25, 35, 50)),
    ColorSequenceKeypoint.new(1, BG)
})
grad.Rotation = 45

-- Тень
local shadow = Instance.new("Frame")
shadow.Size = UDim2.new(1, 10, 1, 10)
shadow.Position = UDim2.new(0, -5, 0, -5)
shadow.BackgroundColor3 = Color3.new(0,0,0)
shadow.BackgroundTransparency = 0.3
shadow.BorderSizePixel = 0
shadow.Parent = main
shadow.ZIndex = -1
Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, CORNER + 3)

-- Заголовок
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 60)
header.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
header.BorderSizePixel = 0
header.Parent = main
Instance.new("UIGradient", header).Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15,20,30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25,35,50))
})

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 1, 0)
title.BackgroundTransparency = 1
title.Text = "📱 МЕНЮ"
title.TextColor3 = TEXT
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header
Instance.new("UIPadding", title).PaddingLeft = UDim.new(0, 15)

-- Кнопка сворачивания
local collapseBtn = Instance.new("TextButton")
collapseBtn.Size = UDim2.new(0, 40, 0, 40)
collapseBtn.Position = UDim2.new(1, -50, 0, 10)
collapseBtn.BackgroundColor3 = ACCENT
collapseBtn.Text = "▲"
collapseBtn.TextColor3 = Color3.new(1,1,1)
collapseBtn.Font = Enum.Font.GothamBold
collapseBtn.TextSize = 20
collapseBtn.BorderSizePixel = 0
collapseBtn.Parent = header
Instance.new("UICorner", collapseBtn).CornerRadius = UDim.new(0, 8)

-- Контейнер для кнопок
local itemsFrame = Instance.new("Frame")
itemsFrame.Size = UDim2.new(1, 0, 1, -60)
itemsFrame.Position = UDim2.new(0, 0, 0, 60)
itemsFrame.BackgroundTransparency = 1
itemsFrame.ClipsDescendants = true
itemsFrame.Parent = main

local list = Instance.new("UIListLayout", itemsFrame)
list.Padding = UDim.new(0, 8)

local pad = Instance.new("UIPadding", itemsFrame)
pad.PaddingTop = UDim.new(0, 10)
pad.PaddingLeft = UDim.new(0, 10)
pad.PaddingRight = UDim.new(0, 10)
pad.PaddingBottom = UDim.new(0, 10)

-- Кнопки меню
local items = {
    "🎮 Игра",
    "⚙️ Настройки",
    "📊 Статистика",
    "🎨 Персонализация",
    "👥 Друзья",
    "❓ Помощь"
}

for _, name in ipairs(items) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(30, 40, 55)
    btn.Text = name
    btn.TextColor3 = TEXT
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.Parent = itemsFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    -- Ховер-эффект
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = ACCENT
        btn.Size = UDim2.new(1, 0, 0, 48)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(30, 40, 55)
        btn.Size = UDim2.new(1, 0, 0, 45)
    end)

    btn.MouseButton1Click:Connect(function()
        print("Нажата кнопка: " .. name)
    end)
end

-- Перетаскивание
local dragging = false
local dragStart = nil
local startPos = nil

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = Vector2.new(mouse.X, mouse.Y)
        startPos = main.Position
    end
end)

uis.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

mouse.Move:Connect(function()
    if dragging then
        local delta = Vector2.new(mouse.X, mouse.Y) - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Сворачивание
local collapsed = false
collapseBtn.MouseButton1Click:Connect(function()
    collapsed = not collapsed
    if collapsed then
        collapseBtn.Text = "▼"
        itemsFrame.Visible = false
        main.Size = UDim2.new(0, WIDTH, 0, 70)
    else
        collapseBtn.Text = "▲"
        itemsFrame.Visible = true
        main.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
    end
end)

-- Ховер кнопки сворачивания
collapseBtn.MouseEnter:Connect(function()
    collapseBtn.BackgroundColor3 = Color3.fromRGB(120, 200, 255)
end)
collapseBtn.MouseLeave:Connect(function()
    collapseBtn.BackgroundColor3 = ACCENT
end)

-- Анимация градиента
local angle = 0
runService.RenderStepped:Connect(function()
    angle = (angle + 0.5) % 360
    grad.Rotation = angle
end)

print("Меню загружено в CoreGui. Можно инжектить!")
