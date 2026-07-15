--[[
    CUSTOM MENU GUI – версия для Executor (CoreGui)
    Стиль: тёмный фон, скруглённые углы, тонкая белая обводка,
    перетаскивание за верхнюю панель, кнопка сворачивания с
    плавной анимацией (Tween), аккуратный шрифт (Gotham).
    Запускай через Xeno / Solara / Delta – без бана.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
-- ВАЖНО: используем CoreGui вместо PlayerGui
local coreGui = game:GetService("CoreGui")

-- ===================== ПАЛИТРА / НАСТРОЙКИ =====================
local COLORS = {
    Background   = Color3.fromRGB(30, 30, 34),
    Panel        = Color3.fromRGB(38, 38, 43),
    Stroke       = Color3.fromRGB(255, 255, 255),
    TextMain     = Color3.fromRGB(235, 235, 240),
    TextDim      = Color3.fromRGB(160, 160, 168),
    Accent       = Color3.fromRGB(255, 255, 255),
    ItemHover    = Color3.fromRGB(50, 50, 56),
    ItemActive   = Color3.fromRGB(20, 20, 22),
}

local FONT       = Enum.Font.GothamMedium
local FONT_BOLD  = Enum.Font.GothamBold

local WINDOW_SIZE_EXPANDED  = UDim2.fromOffset(300, 420)
local WINDOW_SIZE_COLLAPSED = UDim2.fromOffset(70, 420)

-- ===================== ОЧИСТКА СТАРОГО GUI =====================
local old = coreGui:FindFirstChild("CustomMenuGui")
if old then old:Destroy() end

-- ===================== БАЗОВЫЕ КОНСТРУКТОРЫ =====================
local function new(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            inst[k] = v
        end
    end
    if props and props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

local function addCorner(parent, radius)
    return new("UICorner", { CornerRadius = UDim.new(0, radius or 16), Parent = parent })
end

local function addStroke(parent, color, thickness, transparency)
    return new("UIStroke", {
        Color = color or COLORS.Stroke,
        Thickness = thickness or 1,
        Transparency = transparency == nil and 0.85 or transparency,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

-- ===================== SCREEN GUI (в CoreGui) =====================
local screenGui = new("ScreenGui", {
    Name = "CustomMenuGui",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    Parent = coreGui,
})

-- ===================== ГЛАВНОЕ ОКНО =====================
local mainFrame = new("Frame", {
    Name = "MainWindow",
    Size = WINDOW_SIZE_EXPANDED,
    Position = UDim2.fromScale(0.5, 0.5),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = COLORS.Background,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Parent = screenGui,
})
addCorner(mainFrame, 20)
addStroke(mainFrame, COLORS.Stroke, 1.2, 0.8)

-- Тень (простой полупрозрачный прямоугольник, без ассетов)
local shadow = new("Frame", {
    Name = "Shadow",
    BackgroundColor3 = Color3.new(0, 0, 0),
    BackgroundTransparency = 0.7,
    Size = UDim2.new(1, 30, 1, 30),
    Position = UDim2.new(0.5, 0, 0.5, 8),
    AnchorPoint = Vector2.new(0.5, 0.5),
    ZIndex = -1,
    Parent = mainFrame,
})
addCorner(shadow, 22)

-- ===================== ВЕРХНЯЯ ПАНЕЛЬ (drag + свернуть) =====================
local topBar = new("Frame", {
    Name = "TopBar",
    Size = UDim2.new(1, 0, 0, 52),
    BackgroundTransparency = 1,
    Parent = mainFrame,
})

new("Frame", {
    Size = UDim2.new(1, -24, 0, 1),
    Position = UDim2.new(0, 12, 1, -1),
    BackgroundColor3 = COLORS.Stroke,
    BackgroundTransparency = 0.9,
    BorderSizePixel = 0,
    Parent = topBar,
})

local iconStar = new("TextLabel", {
    Text = "✦",
    Font = FONT_BOLD,
    TextSize = 18,
    TextColor3 = COLORS.TextMain,
    BackgroundTransparency = 1,
    Size = UDim2.fromOffset(24, 24),
    Position = UDim2.fromOffset(16, 14),
    Parent = topBar,
})

local titleLabel = new("TextLabel", {
    Name = "Title",
    Text = "Menu",
    Font = FONT_BOLD,
    TextSize = 18,
    TextColor3 = COLORS.TextMain,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1,
    Size = UDim2.fromOffset(160, 24),
    Position = UDim2.fromOffset(46, 14),
    Parent = topBar,
})

-- Кнопка сворачивания
local collapseBtn = new("TextButton", {
    Name = "CollapseButton",
    Text = "",
    AutoButtonColor = false,
    BackgroundColor3 = COLORS.Panel,
    Size = UDim2.fromOffset(28, 28),
    Position = UDim2.new(1, -44, 0, 12),
    Parent = topBar,
})
addCorner(collapseBtn, 14)
addStroke(collapseBtn, COLORS.Stroke, 1, 0.85)

local collapseIcon = new("TextLabel", {
    Text = "‹",
    Font = FONT_BOLD,
    TextSize = 20,
    TextColor3 = COLORS.TextMain,
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    Parent = collapseBtn,
})

-- ===================== СОДЕРЖИМОЕ (список меню) =====================
local content = new("Frame", {
    Name = "Content",
    Size = UDim2.new(1, 0, 1, -60),
    Position = UDim2.fromOffset(0, 60),
    BackgroundTransparency = 1,
    Parent = mainFrame,
})

local scroller = new("ScrollingFrame", {
    Name = "List",
    Size = UDim2.new(1, -16, 1, -8),
    Position = UDim2.fromOffset(8, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = COLORS.TextDim,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Parent = content,
})

local listLayout = new("UIListLayout", {
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = scroller,
})

new("UIPadding", {
    PaddingTop = UDim.new(0, 4),
    PaddingBottom = UDim.new(0, 8),
    Parent = scroller,
})

-- ===================== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ =====================
local order = 0
local function nextOrder()
    order += 1
    return order
end

local function addSectionHeader(text)
    local header = new("TextLabel", {
        Text = text,
        Font = FONT,
        TextSize = 13,
        TextColor3 = COLORS.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -8, 0, 26),
        LayoutOrder = nextOrder(),
        Parent = scroller,
    })
    new("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingTop = UDim.new(0, 10), Parent = header })
    return header
end

local function addMenuItem(icon, text, opts)
    opts = opts or {}

    local item = new("TextButton", {
        Name = text,
        Text = "",
        AutoButtonColor = false,
        BackgroundColor3 = opts.Active and COLORS.ItemActive or COLORS.ItemHover,
        BackgroundTransparency = opts.Active and 0 or 1,
        Size = UDim2.new(1, -8, 0, 40),
        LayoutOrder = nextOrder(),
        Parent = scroller,
    })
    addCorner(item, 12)

    local iconLabel = new("TextLabel", {
        Text = icon,
        Font = FONT,
        TextSize = 16,
        TextColor3 = opts.Active and Color3.fromRGB(255,255,255) or COLORS.TextMain,
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(24, 24),
        Position = UDim2.fromOffset(10, 8),
        Parent = item,
    })

    local textLabel = new("TextLabel", {
        Name = "Label",
        Text = text,
        Font = opts.Active and FONT_BOLD or FONT,
        TextSize = 14,
        TextColor3 = opts.Active and Color3.fromRGB(255,255,255) or COLORS.TextMain,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.fromOffset(42, 0),
        Parent = item,
    })

    if opts.Badge then
        local badge = new("Frame", {
            BackgroundColor3 = Color3.fromRGB(20,20,20),
            Size = UDim2.fromOffset(22, 22),
            Position = UDim2.new(1, -34, 0.5, -11),
            Parent = item,
        })
        addCorner(badge, 11)
        new("TextLabel", {
            Text = tostring(opts.Badge),
            Font = FONT_BOLD,
            TextSize = 12,
            TextColor3 = Color3.fromRGB(255,255,255),
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1,1),
            Parent = badge,
        })
    end

    item.MouseEnter:Connect(function()
        if not opts.Active then
            TweenService:Create(item, TweenInfo.new(0.15), { BackgroundTransparency = 0 }):Play()
        end
    end)
    item.MouseLeave:Connect(function()
        if not opts.Active then
            TweenService:Create(item, TweenInfo.new(0.15), { BackgroundTransparency = 1 }):Play()
        end
    end)

    item.MouseButton1Click:Connect(function()
        if opts.OnClick then opts.OnClick() end
    end)

    return item
end

-- ===================== ЗАПОЛНЕНИЕ МЕНЮ =====================
addMenuItem("🏠", "Home")
addMenuItem("💬", "Messages", { Badge = 2 })
addMenuItem("➕", "Integrations")
addMenuItem("💳", "Finance")
addMenuItem("🧵", "Threads", { Active = true })

addSectionHeader("Drafts (3)")
addMenuItem("</>", "General")
addMenuItem("</>", "Drafts")
addMenuItem("</>", "Feedback")

addSectionHeader("Folders (6)")
addMenuItem("📁", "Stroke LLC")
addMenuItem("📁", "Duotone")
addMenuItem("📁", "Solid")
addMenuItem("📁", "Animations")

addMenuItem("👤", "Contacts")
addMenuItem("🔎", "Explore")

-- ===================== ПЕРЕТАСКИВАНИЕ ОКНА =====================
local dragging = false
local dragStart, startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        updateDrag(input)
    end
end)

-- ===================== СВОРАЧИВАНИЕ С АНИМАЦИЕЙ =====================
local collapsed = false

local function setCollapsed(state)
    collapsed = state

    local sizeGoal = collapsed and WINDOW_SIZE_COLLAPSED or WINDOW_SIZE_EXPANDED
    TweenService:Create(mainFrame, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = sizeGoal
    }):Play()

    TweenService:Create(collapseIcon, TweenInfo.new(0.28), {
        Rotation = collapsed and 180 or 0
    }):Play()

    local fadeGoal = collapsed and 1 or 0
    TweenService:Create(titleLabel, TweenInfo.new(0.15), { TextTransparency = fadeGoal }):Play()

    for _, itm in ipairs(scroller:GetChildren()) do
        if itm:IsA("TextButton") then
            local lbl = itm:FindFirstChild("Label")
            if lbl then
                TweenService:Create(lbl, TweenInfo.new(0.15), { TextTransparency = fadeGoal }):Play()
            end
        elseif itm:IsA("TextLabel") then
            TweenService:Create(itm, TweenInfo.new(0.15), { TextTransparency = fadeGoal }):Play()
        end
    end

    content.Visible = not collapsed and true or content.Visible
    if collapsed then
        task.delay(0.28, function()
            if collapsed then content.Visible = false end
        end)
    else
        content.Visible = true
    end
end

collapseBtn.MouseButton1Click:Connect(function()
    setCollapsed(not collapsed)
end)

collapseBtn.MouseEnter:Connect(function()
    TweenService:Create(collapseBtn, TweenInfo.new(0.15), { BackgroundColor3 = COLORS.ItemHover }):Play()
end)
collapseBtn.MouseLeave:Connect(function()
    TweenService:Create(collapseBtn, TweenInfo.new(0.15), { BackgroundColor3 = COLORS.Panel }):Play()
end)

-- ===================== ПОЯВЛЕНИЕ ОКНА (плавный fade-in) =====================
mainFrame.BackgroundTransparency = 1
TweenService:Create(mainFrame, TweenInfo.new(0.35), { BackgroundTransparency = 0 }):Play()

print("✓ CustomMenuGui готов. Перетаскивай за заголовок, сворачивай кнопкой ‹")
