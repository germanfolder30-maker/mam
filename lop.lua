--[[
    БЕЛОЕ МЕНЮ ДЛЯ MINE A MOUNTAIN (x2 Speed + Большой урон)
    Полная версия с отладкой.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ========== НАСТРОЙКИ ==========
local COLORS = {
    Background   = Color3.fromRGB(242, 242, 247),
    Panel        = Color3.fromRGB(235, 235, 240),
    Stroke       = Color3.fromRGB(255, 255, 255),
    TextMain     = Color3.fromRGB(30, 30, 35),
    TextDim      = Color3.fromRGB(130, 130, 140),
    ItemHover    = Color3.fromRGB(225, 225, 230),
    ItemActive   = Color3.fromRGB(210, 210, 215),
    ToggleOn     = Color3.fromRGB(100, 200, 100),
    ToggleOff    = Color3.fromRGB(200, 80, 80),
}

local FONT       = Enum.Font.GothamMedium
local FONT_BOLD  = Enum.Font.GothamBold

local WINDOW_SIZE_EXPANDED  = UDim2.fromOffset(300, 360)
local WINDOW_SIZE_COLLAPSED = UDim2.fromOffset(300, 60)

-- ========== УДАЛЯЕМ СТАРОЕ МЕНЮ ==========
if playerGui:FindFirstChild("CustomMenuGui") then
    playerGui.CustomMenuGui:Destroy()
end
print("✅ Старое меню удалено")

-- ========== БАЗОВЫЕ ФУНКЦИИ ==========
local function new(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then inst[k] = v end
    end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
end

local function addCorner(parent, radius)
    return new("UICorner", { CornerRadius = UDim.new(0, radius or 16), Parent = parent })
end

local function addStroke(parent, color, thickness, transparency)
    return new("UIStroke", {
        Color = color or COLORS.Stroke,
        Thickness = thickness or 1.5,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

-- ========== Создаём GUI ==========
local screenGui = new("ScreenGui", {
    Name = "CustomMenuGui",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    Parent = playerGui,
})
print("✅ ScreenGui создан")

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
addStroke(mainFrame, COLORS.Stroke, 1.8, 0)
print("✅ MainFrame создан")

-- ========== Верхняя панель ==========
local topBar = new("Frame", {
    Name = "TopBar",
    Size = UDim2.new(1, 0, 0, 52),
    BackgroundTransparency = 1,
    Parent = mainFrame,
})

-- линия под заголовком
new("Frame", {
    Size = UDim2.new(1, -24, 0, 1),
    Position = UDim2.new(0, 12, 1, -1),
    BackgroundColor3 = COLORS.TextDim,
    BackgroundTransparency = 0.5,
    BorderSizePixel = 0,
    Parent = topBar,
})

local iconDot = new("TextLabel", {
    Text = "●",
    Font = FONT_BOLD,
    TextSize = 12,
    TextColor3 = COLORS.TextMain,
    BackgroundTransparency = 1,
    Size = UDim2.fromOffset(20, 20),
    Position = UDim2.fromOffset(16, 16),
    Parent = topBar,
})

local titleLabel = new("TextLabel", {
    Name = "Title",
    Text = "Меню",
    Font = FONT_BOLD,
    TextSize = 18,
    TextColor3 = COLORS.TextMain,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1,
    Size = UDim2.fromOffset(160, 24),
    Position = UDim2.fromOffset(42, 14),
    Parent = topBar,
})

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
addStroke(collapseBtn, COLORS.Stroke, 1, 0.9)

local collapseIcon = new("TextLabel", {
    Text = "‹",
    Font = FONT_BOLD,
    TextSize = 20,
    TextColor3 = COLORS.TextMain,
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    Parent = collapseBtn,
})
print("✅ TopBar создан")

-- ========== Контент (область с кнопками) ==========
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
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = scroller,
})

new("UIPadding", {
    PaddingTop = UDim.new(0, 8),
    PaddingBottom = UDim.new(0, 8),
    PaddingLeft = UDim.new(0, 6),
    PaddingRight = UDim.new(0, 6),
    Parent = scroller,
})
print("✅ Scroller создан")

-- ========== СОСТОЯНИЯ ==========
local states = {
    speed = false,
    nofall = false,
    backpack = false,
    bigDamage = false,
}

local speedConnection = nil
local savedValues = {}

-- ========== x2 SPEED ==========
local function forceSpeed()
    local char = player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = 32
        end
    end
end

local function setSpeedForced(enabled)
    if enabled then
        if speedConnection then speedConnection:Disconnect() end
        speedConnection = RunService.RenderStepped:Connect(forceSpeed)
        forceSpeed()
    else
        if speedConnection then
            speedConnection:Disconnect()
            speedConnection = nil
        end
        local char = player.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                hum.WalkSpeed = 16
            end
        end
    end
end

player.CharacterAdded:Connect(function(char)
    if states.speed then
        task.wait(0.2)
        forceSpeed()
        if speedConnection then speedConnection:Disconnect() end
        speedConnection = RunService.RenderStepped:Connect(forceSpeed)
    end
end)

-- ========== БОЛЬШОЙ УРОН ==========
local function findStats(tool)
    local stats = {}
    for _, child in pairs(tool:GetChildren()) do
        if child:IsA("NumberValue") then
            local name = child.Name:lower()
            if name:find("damage") or name:find("power") or name:find("mining") or name:find("speed") or name:find("pickaxe") or name:find("strength") then
                table.insert(stats, {type = "NumberValue", object = child, name = child.Name, value = child.Value})
            end
        end
    end
    for _, attrName in pairs(tool:GetAttributes()) do
        local attrValue = tool:GetAttribute(attrName)
        if type(attrValue) == "number" then
            local lower = attrName:lower()
            if lower:find("damage") or lower:find("power") or lower:find("mining") or lower:find("speed") or lower:find("pickaxe") or lower:find("strength") then
                table.insert(stats, {type = "Attribute", name = attrName, value = attrValue})
            end
        end
    end
    return stats
end

local function setBigDamage(enabled)
    local char = player.Character
    if not char then 
        print("❌ Нет персонажа")
        return 
    end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then
        warn("❌ У тебя нет кирки в руках! Возьми кирку и попробуй снова.")
        return
    end
    local stats = findStats(tool)
    if #stats == 0 then
        warn("❌ У этого предмета нет характеристик добычи (вероятно, это кристалл).")
        return
    end
    if enabled then
        savedValues = {}
        for _, stat in ipairs(stats) do
            if stat.type == "NumberValue" then
                savedValues[stat.object] = {type = "NumberValue", object = stat.object, value = stat.value}
                stat.object.Value = 999999
                print("✅ Изменён NumberValue: " .. stat.name .. " = 999999")
            elseif stat.type == "Attribute" then
                savedValues[stat.name] = {type = "Attribute", name = stat.name, value = stat.value}
                tool:SetAttribute(stat.name, 999999)
                print("✅ Изменён атрибут: " .. stat.name .. " = 999999")
            end
        end
        print("✅ Большой урон активирован.")
    else
        for key, data in pairs(savedValues) do
            if data.type == "NumberValue" then
                if data.object and data.object.Parent then
                    data.object.Value = data.value
                    print("↩️ Восстановлен NumberValue: " .. data.object.Name .. " = " .. data.value)
                end
            elseif data.type == "Attribute" then
                if tool and tool.Parent then
                    tool:SetAttribute(data.name, data.value)
                    print("↩️ Восстановлен атрибут: " .. data.name .. " = " .. data.value)
                end
            end
        end
        savedValues = {}
        print("✅ Большой урон деактивирован.")
    end
end

player.CharacterAdded:Connect(function(char)
    if states.bigDamage then
        task.wait(0.5)
        setBigDamage(true)
    end
end)

-- ========== ФУНКЦИЯ СОЗДАНИЯ КНОПОК ==========
local function addToggleButton(icon, text, stateKey, callback)
    print("Создаю кнопку: " .. text)
    local btn = new("TextButton", {
        Name = text,
        Text = "",
        AutoButtonColor = false,
        BackgroundColor3 = COLORS.Background,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 46),
        LayoutOrder = #scroller:GetChildren() + 1,
        Parent = scroller,
    })
    addCorner(btn, 14)

    local iconLabel = new("TextLabel", {
        Text = icon,
        Font = FONT,
        TextSize = 18,
        TextColor3 = COLORS.TextMain,
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(24, 24),
        Position = UDim2.fromOffset(14, 11),
        Parent = btn,
    })

    local label = new("TextLabel", {
        Name = "Label",
        Text = text .. ": OFF",
        Font = FONT,
        TextSize = 14,
        TextColor3 = COLORS.TextMain,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.fromOffset(46, 0),
        Parent = btn,
    })

    btn.MouseEnter:Connect(function()
        if not states[stateKey] then
            TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = COLORS.ItemHover, BackgroundTransparency = 0 }):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if not states[stateKey] then
            TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundTransparency = 1 }):Play()
        end
    end)

    btn.MouseButton1Click:Connect(function()
        states[stateKey] = not states[stateKey]
        local on = states[stateKey]
        label.Text = text .. (on and ": ON" or ": OFF")
        btn.BackgroundColor3 = on and COLORS.ToggleOn or COLORS.Background
        btn.BackgroundTransparency = on and 0 or 1
        if callback then callback(on) end
    end)
    print("✅ Кнопка создана: " .. text)
    return btn
end

-- ========== СОЗДАЁМ КНОПКИ ==========
print("Начинаю создание кнопок...")
addToggleButton("⚡", "x2 Speed", "speed", setSpeedForced)
addToggleButton("🛡️", "No Fall", "nofall", function(on) print("No Fall: " .. (on and "ON" or "OFF")) end)
addToggleButton("🎒", "x4 Backpack", "backpack", function(on) print("x4 Backpack: " .. (on and "ON" or "OFF")) end)
addToggleButton("💥", "Большой урон", "bigDamage", setBigDamage)
print("Все кнопки созданы.")

-- ========== ПЕРЕТАСКИВАНИЕ ==========
local dragging = false
local dragStart, startPos

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ========== СВОРАЧИВАНИЕ ==========
local collapsed = false
local function setCollapsed(state)
    collapsed = state
    local sizeGoal = collapsed and WINDOW_SIZE_COLLAPSED or WINDOW_SIZE_EXPANDED
    TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), { Size = sizeGoal }):Play()
    TweenService:Create(collapseIcon, TweenInfo.new(0.3), { Rotation = collapsed and 180 or 0 }):Play()

    iconDot.Visible = not collapsed
    titleLabel.Visible = not collapsed
    content.Visible = not collapsed
    if collapsed then
        task.delay(0.3, function()
            if collapsed then
                content.Visible = false
                iconDot.Visible = false
                titleLabel.Visible = false
            end
        end)
    else
        content.Visible = true
        iconDot.Visible = true
        titleLabel.Visible = true
    end
end

collapseBtn.MouseButton1Click:Connect(function() setCollapsed(not collapsed) end)
collapseBtn.MouseEnter:Connect(function()
    TweenService:Create(collapseBtn, TweenInfo.new(0.15), { BackgroundColor3 = COLORS.ItemHover }):Play()
end)
collapseBtn.MouseLeave:Connect(function()
    TweenService:Create(collapseBtn, TweenInfo.new(0.15), { BackgroundColor3 = COLORS.Panel }):Play()
end)

-- ========== ПЛАВНОЕ ПОЯВЛЕНИЕ ==========
mainFrame.BackgroundTransparency = 1
TweenService:Create(mainFrame, TweenInfo.new(0.35), { BackgroundTransparency = 0 }):Play()

print("✅ Меню полностью загружено. Если кнопки не видны, проверь консоль на ошибки.")
