-- ===================================================================
-- PROJECT RGG: STEALTH CORE v12.0 (MODERN GAMES SUPPORT)
-- Features: GC Memory Mapping, Restore Default Button, Individual Unlock
-- ===================================================================

local RGG_Stealth = {
    Results = {},
    Frozen = {},
    OriginalValues = {}, -- Guarda el valor original antes de cambiarlo para poder restaurarlo
    HiddenEvents = {},
    PersistentThread = nil,
    SelectedIndex = nil,
    CurrentMode = "Memory"
}

-- [ MOTOR DE OPTIMIZACIÓN PASIVA ]
local function procesarConPausas(lista, accion)
    for i, elemento in ipairs(lista) do
        accion(elemento)
        if i % 2000 == 0 then task.wait() end
    end
end

-- ===================================================================
-- 1. MOTOR DE ESCANEO AVANZADO (SUPPORT FOR MODERN GAMES)
-- ===================================================================
function RGG_Stealth.ScanServices(targetValue)
    RGG_Stealth.Results = {}
    RGG_Stealth.HiddenEvents = {}
    local numTarget = tonumber(targetValue)
    
    -- Escaneo estándar de instancias físicas
    local coreServices = {
        game:GetService("ReplicatedStorage"),
        game:GetService("Players").LocalPlayer,
        game:GetService("JointsService")
    }
    
    for _, service in ipairs(coreServices) do
        pcall(function()
            for _, subChild in ipairs(service:GetDescendants()) do
                if subChild:IsA("IntValue") or subChild:IsA("NumberValue") then
                    if not numTarget or subChild.Value == numTarget then
                        table.insert(RGG_Stealth.Results, {
                            Object = subChild,
                            Type = "Local",
                            Name = subChild.Name,
                            LastValue = subChild.Value
                        })
                    end
                end
            end
        end)
    end
    
    -- SOPORTE MODERN GAMES: Escaneo de tablas de funciones del sistema (Garbage Collector)
    -- Esto busca los valores reales clonados dentro del motor interno de los scripts del juego
    pcall(function()
        local garbage = getgc(true)
        for _, t in ipairs(garbage) do
            if type(t) == "table" then
                for k, v in pairs(t) do
                    if type(v) == "number" and v == numTarget then
                        -- Evitar duplicados de tablas del sistema de Roblox
                        if type(k) == "string" and not rawget(t, "ClassName") then
                            table.insert(RGG_Stealth.Results, {
                                Object = t,
                                Key = k,
                                Type = "GC_Table",
                                Name = "[GC] " .. tostring(k),
                                LastValue = v
                            })
                        end
                    end
                end
            end
        end
    end)
    
    return #RGG_Stealth.Results
end

-- ===================================================================
-- 2. INYECTOR, BLOQUEADOR Y RESTAURADOR DE MEMORIA
-- ===================================================================
function RGG_Stealth.InjectData(index, hackValue, freeze)
    local num = tonumber(hackValue)
    local data = RGG_Stealth.Results[index]
    if not data then return end
    
    -- Respaldar el valor original la primera vez que se toca
    if not RGG_Stealth.OriginalValues[data.Object] then
        if data.Type == "Local" then
            RGG_Stealth.OriginalValues[data.Object] = data.Object.Value
        elseif data.Type == "GC_Table" then
            RGG_Stealth.OriginalValues[data.Object] = {Key = data.Key, Value = data.LastValue}
        end
    end
    
    -- Aplicar modificación según el tipo de origen
    pcall(function()
        if data.Type == "Local" then
            data.Object.Value = num
            if freeze then RGG_Stealth.Frozen[data.Object] = {Type = "Local", Value = num} end
        elseif data.Type == "GC_Table" then
            data.Object[data.Key] = num
            if freeze then RGG_Stealth.Frozen[data.Object] = {Type = "GC_Table", Key = data.Key, Value = num} end
        end
    end)
    
    -- Bucle persistente de congelación de memoria (Freeze)
    if freeze and not RGG_Stealth.PersistentThread then
        RGG_Stealth.PersistentThread = task.spawn(function()
            while true do
                local counter = 0
                for obj, info in pairs(RGG_Stealth.Frozen) do
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
            RGG_Stealth.PersistentThread = nil
        end)
    end
end

-- FUNCIÓN DE NUEVO BOTÓN: Desbloquear una línea individual y devolverla a su estado normal
function RGG_Stealth.UnlockIndividual(index)
    local data = RGG_Stealth.Results[index]
    if not data then return end
    
    -- Eliminar del bucle de congelamiento
    RGG_Stealth.Frozen[data.Object] = nil
    
    -- Restaurar su valor guardado de fábrica
    local original = RGG_Stealth.OriginalValues[data.Object]
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

function RGG_Stealth.ClearAll()
    -- Restaurar todo antes de limpiar
    for obj, original in pairs(RGG_Stealth.OriginalValues) do
        pcall(function()
            if type(original) == "table" then
                obj[original.Key] = original.Value
            else
                obj.Value = original
            end
        end)
    end
    
    RGG_Stealth.Results = {}
    RGG_Stealth.Frozen = {}
    RGG_Stealth.OriginalValues = {}
    RGG_Stealth.SelectedIndex = nil
    if RGG_Stealth.PersistentThread then task.cancel(RGG_Stealth.PersistentThread); RGG_Stealth.PersistentThread = nil end
end

-- ===================================================================
-- 3. INTERFAZ GRÁFICA PRIVADA EN INGLÉS ACTUALIZADA (GUI TIPO iGG)
-- ===================================================================
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "RGG_Private_Core_EN"

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
Titulo.Text = "  ⚡ RGG STEALTH CORE v12.0 (MODERN SUPPORT)"
Titulo.TextColor3 = Color3.fromRGB(255, 255, 255)
Titulo.Font = Enum.Font.Code
Titulo.TextSize = 11
Titulo.TextXAlignment = Enum.TextXAlignment.Left

local InputValor = Instance.new("TextBox", Panel)
InputValor.Size = UDim2.new(0, 230, 0, 35)
InputValor.Position = UDim2.new(0, 10, 0, 45)
InputValor.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
InputValor.PlaceholderText = "Search memory value..."
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
BtnBuscar.Text = "🔍 Scan Memory (Standard + GC Modern Support)"
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
InputMod.PlaceholderText = "New Hack Value..."
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
ContenedorLista.CanvasSize = UDim2.new(0, 0, 0, #RGG_Stealth.Results * 32)
local maxItems = math.min(#RGG_Stealth.Results, 50)
for i = 1, maxItems do
local data = RGG_Stealth.Results[i]
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
if RGG_Stealth.Frozen[data.Object] then
BotonSeleccionar.BackgroundColor3 = Color3.fromRGB(0, 80, 120)
end
if RGG_Stealth.SelectedIndex == i then
BotonSeleccionar.BackgroundColor3 = Color3.fromRGB(0, 135, 60)
end
BotonSeleccionar.MouseButton1Click:Connect(function()
RGG_Stealth.SelectedIndex = i
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
local t = RGG_Stealth.ScanServices(InputValor.Text)
LabelEstado.Text = "Lines: " .. t
RGG_Stealth.SelectedIndex = nil
refrescarListaVisual()
end)
BtnLock.MouseButton1Click:Connect(function()
if InputMod.Text == "" or not RGG_Stealth.SelectedIndex then return end
RGG_Stealth.InjectData(RGG_Stealth.SelectedIndex, InputMod.Text, true)
LabelEstado.Text = "Locked ["..RGG_Stealth.SelectedIndex.."]"
task.wait(0.1)
refrescarListaVisual()
end)
BtnUnlock.MouseButton1Click:Connect(function()
if not RGG_Stealth.SelectedIndex then return end
RGG_Stealth.UnlockIndividual(RGG_Stealth.SelectedIndex)
LabelEstado.Text = "Restored ["..RGG_Stealth.SelectedIndex.."]"
task.wait(0.1)
refrescarListaVisual()
end)
BtnLimpiar.MouseButton1Click:Connect(function()
RGG_Stealth.ClearAll()
LabelEstado.Text = "Lines: 0"
InputValor.Text = ""
InputMod.Text = ""
refrescarListaVisual()
end)
