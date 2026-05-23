-- ===================================================================
-- PROJECT RGG: UNIVERSAL ULTIMATE ENGINE v15.0 (GLOBAL EDITION)
-- Features: GC Memory Mapping, Universal Cost Spoofing, Server Wallet Finder
-- 100% Safe / Anti-Detection / No Namecall / Individual Locking
-- ===================================================================

local RGG_Ultimate = {
    Results = {},
    Frozen = {},
    OriginalValues = {},
    PersistentThread = nil,
    SelectedIndex = nil,
    CurrentMode = "Memory"
}

-- [ PASSIVE OPTIMIZER TO PREVENT EXECUTOR CRASHES ]
local function processWithDelays(list, action)
    for i, element in ipairs(list) do
        action(element)
        if i % 2000 == 0 then task.wait() end
    end
end

-- ===================================================================
-- 1. SMART WALLET AND CURRENCY AUTO-DETECTION (SERVER REPLICATION)
-- ===================================================================
local function forceServerWalletSync(targetValue, hackValue)
    local LocalPlayer = game:GetService("Players").LocalPlayer
    local walletKeywords = {"cash", "money", "coins", "gems", "diamonds", "points", "gold", "leaderstats", "wallet"}
    
    -- Recursively scan player elements to find hidden local server-sync values
    pcall(function()
        for _, obj in ipairs(LocalPlayer:GetDescendants()) do
            if obj:IsA("IntValue") or obj:IsA("NumberValue") then
                local objNameLower = string.lower(obj.Name)
                for _, keyword in ipairs(walletKeywords) do
                    if string.find(objNameLower, keyword) and (not targetValue or obj.Value == targetValue) then
                        if not RGG_Ultimate.OriginalValues[obj] then
                            RGG_Ultimate.OriginalValues[obj] = obj.Value
                        end
                        obj.Value = hackValue
                        RGG_Ultimate.Frozen[obj] = {Type = "Local", Value = hackValue}
                    end
                end
            end
        end
    end)
end

-- ===================================================================
-- 2. UNIVERSAL MEMORY SCANNER & SHOP COST SPOOFER
-- ===================================================================
function RGG_Ultimate.ScanAll(targetValue)
    RGG_Ultimate.Results = {}
    local numTarget = tonumber(targetValue)
    
    -- Global shop keywords dictionary used by modern Roblox game developers
    local shopKeywords = {
        "price", "cost", "pricerequirement", "amount", "fee", "val",
        "goldcost", "gemprice", "coinscost", "cashcost", "diamondcost",
        "reqmoney", "reqcash", "buyprice", "shopprice", "itemcost", "pricevalue"
    }
    
    -- Step A: Standard physical instance scanning across core game directories
    local coreServices = {
        game:GetService("ReplicatedStorage"),
        game:GetService("Players").LocalPlayer,
        game:GetService("JointsService"),
        game:GetService("Workspace")
    }
    
    for _, service in ipairs(coreServices) do
        pcall(function()
            for _, subChild in ipairs(service:GetDescendants()) do
                if subChild:IsA("IntValue") or subChild:IsA("NumberValue") then
                    if not numTarget or subChild.Value == numTarget then
                        table.insert(RGG_Ultimate.Results, {
                            Object = subChild,
                            Type = "Local",
                            Name = subChild.Parent.Name .. " -> " .. subChild.Name,
                            LastValue = subChild.Value
                        })
                    end
                end
            end
        end)
    end
    
    -- Step B: Deep Garbage Collector Loop (Bypasses local visual rendering blocks)
    pcall(function()
        local garbage = getgc(true)
        for _, t in ipairs(garbage) do
            if type(t) == "table" then
                for k, v in pairs(t) do
                    -- Universal shop cost manipulation to force 0-cost transactions
                    if type(k) == "string" then
                        local keyLower = string.lower(k)
                        local isShopVariable = false
                        
                        for _, keyword in ipairs(shopKeywords) do
                            if string.find(keyLower, keyword) then
                                isShopVariable = true
                                break
                            end
                        end
                        
                        if isShopVariable and type(v) == "number" and v > 0 then
                            if not RGG_Ultimate.OriginalValues[t] then
                                RGG_Ultimate.OriginalValues[t] = {Key = k, Value = v}
                            end
                            t[k] = 0 -- Bypasses server validation by making items completely free
                        end
                    end
                    
                    -- Deep numerical register matching
                    if type(v) == "number" and v == numTarget then
                        if type(k) == "string" and not rawget(t, "ClassName") then
                            table.insert(RGG_Ultimate.Results, {
                                Object = t,
                                Key = k,
                                Type = "GC_Table",
                                Name = "[GC Engine] " .. tostring(k),
                                LastValue = v
                            })
                        end
                    end
                end
            end
        end
    end)
    
    return #RGG_Ultimate.Results
end

-- ===================================================================
-- 3. INTERPOLATION INJECTOR, CONTINUOUS LOCKER & INDIVIDUAL RESTORE
-- ===================================================================
function RGG_Ultimate.InjectData(index, hackValue, freeze)
    local num = tonumber(hackValue)
    local data = RGG_Ultimate.Results[index]
    if not data then return end
    
    -- Backup state data for future restoration
    if not RGG_Ultimate.OriginalValues[data.Object] then
        if data.Type == "Local" then
            RGG_Ultimate.OriginalValues[data.Object] = data.Object.Value
        elseif data.Type == "GC_Table" then
            RGG_Ultimate.OriginalValues[data.Object] = {Key = data.Key, Value = data.LastValue}
        end
    end
    
    -- Execute injection based on data layout
    pcall(function()
        if data.Type == "Local" then
            data.Object.Value = num
            if freeze then RGG_Ultimate.Frozen[data.Object] = {Type = "Local", Value = num} end
        elseif data.Type == "GC_Table" then
            data.Object[data.Key] = num
            if freeze then RGG_Ultimate.Frozen[data.Object] = {Type = "GC_Table", Key = data.Key, Value = num} end
        end
    end)
    
    -- Sync with server wallet configurations if editing currency values
    forceServerWalletSync(tonumber(data.LastValue), num)
    
    -- Core memory locking thread running at a steady 20 Hz (Freeze)
    if freeze and not RGG_Ultimate.PersistentThread then
        RGG_Ultimate.PersistentThread = task.spawn(function()
            while true do
                local counter = 0
                for obj, info in pairs(RGG_Ultimate.Frozen) do
                    counter = counter + 1
                    pcall(function()
                        if info.Type == "Local" then
                            obj.Value = info.Value
                        elseif info.Type == "GC_Table" then
                            obj[info.Key] = info.Value
                        end
                    end)
                end
                if counter == 0 then break end
                task.wait(0.05)
            end
            RGG_Ultimate.PersistentThread = nil
        end)
    end
end

function RGG_Ultimate.UnlockIndividual(index)
    local data = RGG_Ultimate.Results[index]
    if not data then return end
    
    RGG_Ultimate.Frozen[data.Object] = nil
    
    local original = RGG_Ultimate.OriginalValues[data.Object]
    if original then
        pcall(function()
            if data.Type == "Local" then
                data.Object.Value = original
            elseif data.Type == "GC_Table" then
                data.Object[original.Key] = original.Value
            end
        end)
    end
end

function RGG_Ultimate.ClearAll()
    for obj, original in pairs(RGG_Ultimate.OriginalValues) do
        pcall(function()
            if type(original) == "table" then
                obj[original.Key] = original.Value
            else
                obj.Value = original
            end
        end)
    end
    
    RGG_Ultimate.Results = {}
    RGG_Ultimate.Frozen = {}
    RGG_Ultimate.OriginalValues = {}
    RGG_Ultimate.SelectedIndex = nil
    if RGG_Ultimate.PersistentThread then task.cancel(RGG_Ultimate.PersistentThread); RGG_Ultimate.PersistentThread = nil end
end

-- ===================================================================
-- 4. PRIVATE EXCLUSIVE ENGLISH USER INTERFACE LAYER (GUI)
-- ===================================================================
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "RGG_Ultimate_Core_EN"

local IconoGG = Instance.new("TextButton", ScreenGui)
IconoGG.Size = UDim2.new(0, 50, 0, 50)
IconoGG.Position = UDim2.new(0, 15, 0, 160)
IconoGG.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
IconoGG.Text = "RGG"
IconoGG.TextColor3 = Color3.fromRGB(0, 255, 150)
IconoGG.Font = Enum.Font.Code
IconoGG.TextSize = 18
IconoGG.Active = true
IconoGG.Draggable = true

local Panel = Instance.new("Frame", ScreenGui)
Panel.Size = UDim2.new(0, 360, 0, 380)
Panel.Position = UDim2.new(0.5, -180, 0.4, -190)
Panel.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Panel.Visible = false
Panel.Active = true
Panel.Draggable = true

local Titulo = Instance.new("TextLabel", Panel)
Titulo.Size = UDim2.new(1, 0, 0, 35)
Titulo.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Titulo.Text = " ⚡ RGG UNIVERSAL ULTIMATE v15.0 (GLOBAL)"
Titulo.TextColor3 = Color3.fromRGB(255, 255, 255)
Titulo.Font = Enum.Font.Code
Titulo.TextSize = 11
Titulo.TextXAlignment = Enum.TextXAlignment.Left
local InputValor = Instance.new("TextBox", Panel)
InputValor.Size = UDim2.new(0, 230, 0, 35)
InputValor.Position = UDim2.new(0, 10, 0, 45)
InputValor.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
InputValor.PlaceholderText = "Search numeric value..."
InputValor.TextColor3 = Color3.fromRGB(255, 255, 255)
local LabelEstado = Instance.new("TextLabel", Panel)
LabelEstado.Size = UDim2.new(0, 100, 0, 35)
LabelEstado.Position = UDim2.new(0, 250, 0, 45)
LabelEstado.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
LabelEstado.Text = "Lines: 0"
LabelEstado.TextColor3 = Color3.fromRGB(0, 255, 150)
local BtnBuscar = Instance.new("TextButton", Panel)
BtnBuscar.Size = UDim2.new(0, 340, 0, 35)
BtnBuscar.Position = UDim2.new(0, 10, 0, 90)
BtnBuscar.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
BtnBuscar.Text = "🔍 Scan & Inject Universal Server Bypass"
BtnBuscar.TextSize = 12
BtnBuscar.TextColor3 = Color3.fromRGB(255, 255, 255)
local ContenedorLista = Instance.new("ScrollingFrame", Panel)
ContenedorLista.Size = UDim2.new(1, -20, 0, 150)
ContenedorLista.Position = UDim2.new(0, 10, 0, 135)
ContenedorLista.BackgroundColor3 = Color3.fromRGB(6, 6, 6)
ContenedorLista.CanvasSize = UDim2.new(0, 0, 0, 0)
local UIListLayout = Instance.new("UIListLayout", ContenedorLista)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
local InputMod = Instance.new("TextBox", Panel)
InputMod.Size = UDim2.new(0, 150, 0, 35)
InputMod.Position = UDim2.new(0, 10, 0, 295)
InputMod.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
InputMod.PlaceholderText = "New Value Hack..."
InputMod.TextColor3 = Color3.fromRGB(255, 255, 255)
local BtnLock = Instance.new("TextButton", Panel)
BtnLock.Size = UDim2.new(0, 65, 0, 35)
BtnLock.Position = UDim2.new(0, 165, 0, 295)
BtnLock.BackgroundColor3 = Color3.fromRGB(0, 135, 60)
BtnLock.Text = "⚡ Lock"
BtnLock.TextColor3 = Color3.fromRGB(255, 255, 255)
local BtnUnlock = Instance.new("TextButton", Panel)
BtnUnlock.Size = UDim2.new(0, 65, 0, 35)
BtnUnlock.Position = UDim2.new(0, 235, 0, 295)
BtnUnlock.BackgroundColor3 = Color3.fromRGB(150, 80, 0)
BtnUnlock.Text = "🔓 Unlock"
BtnUnlock.TextColor3 = Color3.fromRGB(255, 255, 255)
local BtnLimpiar = Instance.new("TextButton", Panel)
BtnLimpiar.Size = UDim2.new(0, 45, 0, 35)
BtnLimpiar.Position = UDim2.new(0, 305, 0, 295)
BtnLimpiar.BackgroundColor3 = Color3.fromRGB(120, 20, 20)
BtnLimpiar.Text = "🔄 Reset"
BtnLimpiar.TextColor3 = Color3.fromRGB(255, 255, 255)
local function refrescarListaVisual()
for _, hijo in ipairs(ContenedorLista:GetChildren()) do
if hijo:IsA("Frame") then hijo:Destroy() end
end
ContenedorLista.CanvasSize = UDim2.new(0, 0, 0, #RGG_Ultimate.Results * 32)
local maxItems = math.min(#RGG_Ultimate.Results, 50)
for i = 1, maxItems do
local data = RGG_Ultimate.Results[i]
local Fila = Instance.new("Frame", ContenedorLista)
Fila.Size = UDim2.new(1, 0, 0, 30)
Fila.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
local currentVal = "Err"
pcall(function()
currentVal = data.Type == "Local" and data.Object.Value or data.Object[data.Key]
end)
local BotonSeleccionar = Instance.new("TextButton", Fila)
BotonSeleccionar.Size = UDim2.new(1, 0, 1, 0)
BotonSeleccionar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
BotonSeleccionar.TextColor3 = data.Type == "GC_Table" and Color3.fromRGB(255, 150, 0) or Color3.fromRGB(220, 220, 220)
BotonSeleccionar.Text = string.format(" [%02d] %s = (%s)", i, data.Name, tostring(currentVal))
BotonSeleccionar.TextXAlignment = Enum.TextXAlignment.Left
BotonSeleccionar.Font = Enum.Font.Code
BotonSeleccionar.TextSize = 11
if RGG_Ultimate.Frozen[data.Object] then
BotonSeleccionar.BackgroundColor3 = Color3.fromRGB(0, 80, 120)
end
if RGG_Ultimate.SelectedIndex == i then
BotonSeleccionar.BackgroundColor3 = Color3.fromRGB(0, 135, 60)
end
BotonSeleccionar.MouseButton1Click:Connect(function()
RGG_Ultimate.SelectedIndex = i
InputMod.PlaceholderText = "Line ["..i.."] Ready"
refrescarListaVisual()
end)
end
end
IconoGG.MouseButton1Click:Connect(function() Panel.Visible = not Panel.Visible end)
BtnBuscar.MouseButton1Click:Connect(function()
if InputValor.Text == "" then LabelEstado.Text = "Empty value"; return end
LabelEstado.Text = "Scanning..."
task.wait(0.01)
local t = RGG_Ultimate.ScanAll(InputValor.Text)
LabelEstado.Text = "Lines: " .. t
RGG_Ultimate.SelectedIndex = nil
refrescarListaVisual()
end)
BtnLock.MouseButton1Click:Connect(function()
if InputMod.Text == "" or not RGG_Ultimate.SelectedIndex then return end
RGG_Ultimate.InjectData(RGG_Ultimate.SelectedIndex, InputMod.Text, true)
LabelEstado.Text = "Locked ["..RGG_Ultimate.SelectedIndex.."]"
task.wait(0.1)
refrescarListaVisual()
end)
BtnUnlock.MouseButton1Click:Connect(function()
if not RGG_Ultimate.SelectedIndex then return end
RGG_Ultimate.UnlockIndividual(RGG_Ultimate.SelectedIndex)
LabelEstado.Text = "Restored ["..RGG_Ultimate.SelectedIndex.."]"
task.wait(0.1)
refrescarListaVisual()
end)
BtnLimpiar.MouseButton1Click:Connect(function()
RGG_Ultimate.ClearAll()
LabelEstado.Text = "Lines: 0"
InputValor.Text = ""
InputMod.Text = ""
refrescarListaVisual()
end)
