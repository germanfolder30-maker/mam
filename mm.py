--[[
    Remote Spy + Instant Mine Helper (без GUI)
    Запусти, нажми E на кристалле, открой F9 и пришли мне лог.
]]

-- Объявляем все необходимые сервисы
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- ===================== REMOTE SPY =====================
local hooked = {}
local function hookRemote(remote)
    if hooked[remote] then return end
    hooked[remote] = true
    local oldFireServer = remote.FireServer
    remote.FireServer = function(self, ...)
        -- Собираем аргументы для вывода
        local args = {...}
        local argStr = ""
        for i, v in ipairs(args) do
            argStr = argStr .. tostring(v) .. (i < #args and ", " or "")
        end
        print("[SPY] " .. remote.Name .. "(" .. argStr .. ")")
        return oldFireServer(self, ...)
    end
end

-- Подключаемся ко всем существующим RemoteEvent
for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
    if remote:IsA("RemoteEvent") then
        hookRemote(remote)
    end
end
-- И к новым, если появятся
ReplicatedStorage.DescendantAdded:Connect(function(desc)
    if desc:IsA("RemoteEvent") then
        hookRemote(desc)
    end
end)

print("Remote Spy активирован. Все вызовы RemoteEvent будут показаны в консоли.")

-- ===================== МГНОВЕННЫЙ СБОР ПРИ НАЖАТИИ E =====================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.E then
        local char = player.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        print("[INSTANT] Нажата E, ищем ближайший ProximityPrompt...")

        -- Ищем все активные ProximityPrompt рядом с игроком
        local found = 0
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                -- Проверяем расстояние (хотя бы примерно)
                local part = obj.Parent
                if part:IsA("BasePart") then
                    local dist = (part.Position - root.Position).Magnitude
                    if dist <= obj.MaxActivationDistance then
                        found = found + 1
                        print("[INSTANT] Найден ProximityPrompt: " .. obj.Name .. " на объекте " .. part.Name)
                        -- Пробуем мгновенно начать и завершить ввод
                        pcall(function()
                            obj:InputHoldBegin()
                            task.wait(0.01)
                            obj:InputHoldEnd()
                            print("[INSTANT] InputHoldBegin/End выполнены для " .. obj.Name)
                        end)
                    end
                end
            end
        end
        if found == 0 then
            print("[INSTANT] Рядом нет активных ProximityPrompt. Возможно, кристалл далеко или не тот объект.")
        end
    end
end)

print("Скрипт готов. Подойди к кристаллу, нажми E, затем открой консоль (F9) и скопируй строки с [SPY].")
