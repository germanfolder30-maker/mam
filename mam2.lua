--[[
    === MODERN HORIZONTAL MENU (FOR EXECUTOR) ===
    Горизонтальное меню с боковой навигацией
    Оптимизировано для Xeno / Solara / Delta
--]]

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local uis = game:GetService("UserInputService")
local runService = game:GetService("RunService")

-- ===== КОНФИГУРАЦИЯ =====
local CONFIG = {
    MainWidth = 750,
    MainHeight = 600,
    SidebarWidth = 90,
    StartPosition = UDim2.new(0.1, 0, 0.15, 0),
    CornerRadius = 16,

    BgColor = Color3.fromRGB(245, 245, 248),
    SidebarColor = Color3.fromRGB(240, 240, 245),
    AccentColor = Color3.fromRGB(0, 0, 0),
    TextColor = Color3.fromRGB(40, 40, 50),
    TextSecondary = Color3.fromRGB(120, 120, 130),

    SidebarItems = {
        { icon = "⭐", name = "Home", id = "home" },
        { icon = "✉️", name = "Messages", id = "messages" },
        { icon = "➕", name = "Add", id = "add" },
        { icon = "📊", name = "Finance", id = "finance" },
        { icon = "📋", name = "Documents", id = "documents" },
        { icon = "👤", name = "Profile", id = "profile" },
        { icon = "🗑️", name = "Trash", id = "trash" },
    },

    MenuItems = {
        { icon = "🏠", name = "Home", badge = "" },
        { icon = "✉️", name = "Messages", badge = "2" },
        { icon = "🔗", name = "Integrations", badge = "+" },
        { icon = "💰", name = "Finance", badge = "" },
        { icon = "📁", name = "Threads", badge = "−", active = true },
        { icon = "📄", name = "Fignuts", badge = "" },
        { icon = "🔧", name = "Enlarz System", badge = "" },
        { icon = "👥", name = "Contacts", badge = "" },
        { icon = "🔍", name = "Explore", badge = "+" },
    }
}

-- Удаляем старое меню
if game.CoreGui:FindFirstChild("ModernMenu") then
    game.CoreGui.ModernMenu:Destroy()
end

-- ===== GUI =====
local gui = Instance.new("ScreenGui")
gui.Name = "ModernMenu"
gui.Parent = game.CoreGui
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ===== ГЛАВНЫЙ КОНТЕЙНЕР =====
local main = Instance.new("Frame")
main.Size = UDim2.new(0, CONFIG.MainWidth, 0, CONFIG.MainHeight)
main.Position = CONFIG.StartPosition
main.BackgroundColor3 = CONFIG.BgColor
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, CONFIG.CornerRadius)

-- Тень
local shadow = Instance.new("Frame")
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Position = UDim2.new(0, -10, 0, -10)
shadow.BackgroundColor3 = Color3.new(0, 0, 0)
shadow.BackgroundTransparency = 0.15
shadow.BorderSizePixel = 0
shadow.Parent = main
shadow.ZIndex = -1
Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, CONFIG.CornerRadius + 5)

-- ===== БОКОВАЯ ПАНЕЛЬ =====
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, CONFIG.SidebarWidth, 1, 0)
sidebar.BackgroundColor3 = CONFIG.SidebarColor
sidebar.BorderSizePixel = 0
sidebar.Parent = main

local sidebarPad = Instance.new("UIPadding", sidebar)
sidebarPad.PaddingTop = UDim.new(0, 15)
sidebarPad.PaddingBottom = UDim.new(0, 15)
sidebarPad.PaddingLeft = UDim.new(0, 10)
sidebarPad.PaddingRight = UDim.new(0, 10)

local sidebarList = Instance.new("UIListLayout", sidebar)
sidebarList.Padding = UDim.new(0, 12)
sidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Логотип
local logo = Instance.new("TextButton")
logo.Size = UDim2.new(0, 50, 0, 50)
logo.BackgroundColor3 = Color3.new(1, 1, 1)
logo.Text = "✨"
logo.TextSize = 24
logo.Font = Enum.Font.GothamBold
logo.BorderSizePixel = 0
logo.AutoButtonColor = false
logo.Parent = sidebar
Instance.new("UICorner", logo).CornerRadius = UDim.new(0, 12)

logo.MouseEnter:Connect(function() logo.BackgroundColor3 = Color3.fromRGB(240, 240, 248) end)
logo.MouseLeave:Connect(function() logo.BackgroundColor3 = Color3.new(1, 1, 1) end)

-- Разделитель
local divider = Instance.new("Frame")
divider.Size = UDim2.new(0, 1, 0, 20)
divider.BackgroundColor3 = Color3.fromRGB(200, 200, 210)
divider.BorderSizePixel = 0
divider.Parent = sidebar

-- Элементы боковой панели
for _, item in ipairs(CONFIG.SidebarItems) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 50)
    btn.BackgroundColor3 = Color3.fromRGB(230, 230, 240)
    btn.BorderSizePixel = 0
    btn.Text = item.icon
    btn.TextSize = 22
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Parent = sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = CONFIG.AccentColor
        btn.TextColor3 = Color3.new(1, 1, 1)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(230, 230, 240)
        btn.TextColor3 = CONFIG.TextColor
    end)
    btn.MouseButton1Click:Connect(function()
        print("Sidebar: " .. item.name)
    end)
end

-- ===== ОСНОВНАЯ ОБЛАСТЬ =====
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -CONFIG.SidebarWidth, 1, 0)
content.Position = UDim2.new(0, CONFIG.SidebarWidth, 0, 0)
content.BackgroundColor3 = CONFIG.BgColor
content.BorderSizePixel = 0
content.Parent = main

-- ===== ЗАГОЛОВОК =====
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = CONFIG.BgColor
header.BorderSizePixel = 0
header.Parent = content

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 1, 0)
title.BackgroundTransparency = 1
title.Text = "✨ Menu"
title.TextColor3 = CONFIG.TextColor
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header
Instance.new("UIPadding", title).PaddingLeft = UDim.new(0, 20)

-- Кнопка сворачивания
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 35, 0, 35)
minimizeBtn.Position = UDim2.new(1, -40, 0, 7)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(230, 230, 240)
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = CONFIG.TextColor
minimizeBtn.TextSize = 20
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.BorderSizePixel = 0
minimizeBtn.AutoButtonColor = false
minimizeBtn.Parent = header
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 8)

minimizeBtn.MouseEnter:Connect(function()
    minimizeBtn.BackgroundColor3 = CONFIG.AccentColor
    minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
end)
minimizeBtn.MouseLeave:Connect(function()
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(230, 230, 240)
    minimizeBtn.TextColor3 = CONFIG.TextColor
end)

-- Линия
local line = Instance.new("Frame")
line.Size = UDim2.new(1, 0, 0, 1)
line.Position = UDim2.new(0, 0, 1, -1)
line.BackgroundColor3 = Color3.fromRGB(220, 220, 230)
line.BorderSizePixel = 0
line.Parent = header

-- ===== СПИСОК КНОПОК =====
local itemsFrame = Instance.new("Frame")
itemsFrame.Size = UDim2.new(1, 0, 1, -50)
itemsFrame.Position = UDim2.new(0, 0, 0, 50)
itemsFrame.BackgroundTransparency = 1
itemsFrame.ClipsDescendants = true
itemsFrame.Parent = content

local itemsList = Instance.new("UIListLayout", itemsFrame)
itemsList.Padding = UDim.new(0, 8)

local itemsPad = Instance.new("UIPadding", itemsFrame)
itemsPad.PaddingTop = UDim.new(0, 12)
itemsPad.PaddingLeft = UDim.new(0, 15)
itemsPad.PaddingRight = UDim.new(0, 15)
itemsPad.PaddingBottom = UDim.new(0, 12)

for _, item in ipairs(CONFIG.MenuItems) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.BackgroundColor3 = item.active and CONFIG.AccentColor or Color3.new(1, 1, 1)
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = itemsFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    -- Контент кнопки
    local cf = Instance.new("Frame")
    cf.Size = UDim2.new(1, -20, 1, 0)
    cf.Position = UDim2.new(0, 10, 0, 0)
    cf.BackgroundTransparency = 1
    cf.Parent = btn

    local cfList = Instance.new("UIListLayout", cf)
    cfList.FillDirection = Enum.FillDirection.Horizontal
    cfList.Padding = UDim.new(0, 12)
    cfList.VerticalAlignment = Enum.VerticalAlignment.Center

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 30, 0, 30)
    icon.BackgroundTransparency = 1
    icon.Text = item.icon
    icon.TextSize = 18
    icon.Font = Enum.Font.GothamBold
    icon.Parent = cf

    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(0, 0, 1, 0)
    name.BackgroundTransparency = 1
    name.Text = item.name
    name.TextColor3 = item.active and Color3.new(1, 1, 1) or CONFIG.TextColor
    name.TextSize = 15
    name.Font = Enum.Font.Gotham
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.Parent = cf

    if item.badge ~= "" then
        local badge = Instance.new("TextLabel")
        badge.Size = UDim2.new(0, 25, 0, 25)
        badge.BackgroundColor3 = item.active and Color3.new(1, 1, 1) or Color3.new(0, 0, 0)
        badge.BorderSizePixel = 0
        badge.Text = item.badge
        badge.TextColor3 = item.active and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
        badge.TextSize = 12
        badge.Font = Enum.Font.GothamBold
        badge.Parent = btn
        badge.Position = UDim2.new(1, -35, 0.5, -12)
        Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 12)
    end

    btn.MouseEnter:Connect(function()
        if not item.active then
            btn.BackgroundColor3 = Color3.fromRGB(240, 240, 248)
        end
    end)
    btn.MouseLeave:Connect(function()
        if not item.active then
            btn.BackgroundColor3 = Color3.new(1, 1, 1)
        end
    end)
    btn.MouseButton1Click:Connect(function()
        print("Menu: " .. item.name)
    end)
end

-- ===== ПЕРЕТАСКИВАНИЕ =====
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

-- ===== СВОРАЧИВАНИЕ =====
local collapsed = false
local function toggleCollapse()
    collapsed = not collapsed
    if collapsed then
        minimizeBtn.Text = "+"
        content.Visible = false
        main.Size = UDim2.new(0, CONFIG.SidebarWidth + 50, 0, CONFIG.MainHeight)
    else
        minimizeBtn.Text = "−"
        content.Visible = true
        main.Size = UDim2.new(0, CONFIG.MainWidth, 0, CONFIG.MainHeight)
    end
end

minimizeBtn.MouseButton1Click:Connect(toggleCollapse)
logo.MouseButton1Click:Connect(toggleCollapse)

print("Modern Menu загружен в CoreGui. Готов к функциям!")
