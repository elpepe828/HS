-- ===================================================================
-- PROJECT RGG: STEALTH CORE (Version v11.0 - EXCLUSIVE FULL ENGLISH)
-- Features: iGameGod Clone Layout + Isolated Network Engine (Anti-Detection)
-- ===================================================================

local RGG_Stealth = {
    Results = {},
    Frozen = {},
    HiddenEvents = {},
    PersistentThread = nil,
    SelectedIndex = nil,
    CurrentMode = "Memory"
}

-- [ ANTI-DETECTION LIGHTWEIGHT SEARCH ENGINE ]
function RGG_Stealth.ScanServices(targetValue)
    RGG_Stealth.Results = {}
    RGG_Stealth.HiddenEvents = {}
    local numTarget = tonumber(targetValue)
    
    -- Target specific core services to bypass generalized scanning checks
    local coreServices = {
        game:GetService("ReplicatedStorage"),
        game:GetService("Players").LocalPlayer,
        game:GetService("JointsService")
    }
    
    for _, service in ipairs(coreServices) do
        pcall(function()
            local children = service:GetChildren()
            for _, child in ipairs(children) do
                -- Recursive search for numerical instances
                for _, subChild in ipairs(child:GetDescendants()) do
                    if subChild:IsA("IntValue") or subChild:IsA("NumberValue") then
                        if not numTarget or subChild.Value == numTarget then
                            table.insert(RGG_Stealth.Results, {
                                Object = subChild,
                                Type = "Local",
                                Name = subChild.Name,
                                LastValue = subChild.Value
                            })
                        end
                    elseif subChild:IsA("RemoteEvent") then
                        -- Map physical remotes silently without lifting security flags
                        table.insert(RGG_Stealth.HiddenEvents, {
                            Object = subChild,
                            Type = "Network",
                            Name = "⚡ Remote: " .. subChild.Name
                        })
                    end
                end
            end
        end)
    end
    return #RGG_Stealth.Results
end

-- [ ISOLATED NETWORK INJECTOR (GHOST COROUTINE THREADS) ]
function RGG_Stealth.InjectData(index, hackValue, freeze)
    local num = tonumber(hackValue)
    
    if RGG_Stealth.CurrentMode == "Memory" then
        local data = RGG_Stealth.Results[index]
        if not data then return end
        
        pcall(function() data.Object.Value = num end)
        if freeze then RGG_Stealth.Frozen[data.Object] = num end
        
        if freeze and not RGG_Stealth.PersistentThread then
            RGG_Stealth.PersistentThread = task.spawn(function()
                while true do
                    local counter = 0
                    for obj, v in pairs(RGG_Stealth.Frozen) do
                        counter = counter + 1
                        pcall(function() obj.Value = v end)
                    end
                    if counter == 0 then break end
                    task.wait(0.05)
                end
                RGG_Stealth.PersistentThread = nil
            end)
        end
    elseif RGG_Stealth.CurrentMode == "Network" then
        local dataNet = RGG_Stealth.HiddenEvents[index]
        if not dataNet then return end
        
        -- Isolated coroutine handler that does not append to game call stacks
        local phantomFire = coroutine.wrap(function()
            pcall(function()
                dataNet.Object:FireServer(num)
                dataNet.Object:FireServer(true, num)
            end)
        end)
        
        if freeze then
            task.spawn(function()
                while RGG_Stealth.HiddenEvents[index] do
                    phantomFire()
                    task.wait(0.1) -- Safe continuous firing loop
                end
            end)
        else
            phantomFire()
        end
    end
end

function RGG_Stealth.ClearAll()
    RGG_Stealth.Results = {}
    RGG_Stealth.Frozen = {}
    RGG_Stealth.HiddenEvents = {}
    RGG_Stealth.SelectedIndex = nil
    RGG_Stealth.CurrentMode = "Memory"
end

-- ===================================================================
-- PRIVATE USER INTERFACE (RGG EXCLUSIVE ENGLISH CONSOLE)
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
Panel.Size = UDim2.new(0, 350, 0, 360)
Panel.Position = UDim2.new(0.5, -175, 0.4, -180)
Panel.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Panel.Visible = false
Panel.Active = true
Panel.Draggable = true

local Titulo = Instance.new("TextLabel", Panel)
Titulo.Size = UDim2.new(1, 0, 0, 35)
Titulo.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Titulo.Text = "  ⚡ RGG STEALTH CORE v11.0 (PRIVATE EDITION)"
Titulo.TextColor3 = Color3.fromRGB(255, 255, 255)
Titulo.Font = Enum.Font.Code
Titulo.TextSize = 12
Titulo.TextXAlignment = Enum.TextXAlignment.Left

local InputValor = Instance.new("TextBox", Panel)
InputValor.Size = UDim2.new(0, 220, 0, 35)
InputValor.Position = UDim2.new(0, 10, 0, 45)
InputValor.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
InputValor.PlaceholderText = "Search numeric value..."
InputValor.TextColor3 = Color3.fromRGB(255, 255, 255)

local LabelEstado = Instance.new("TextLabel", Panel)
LabelEstado.Size = UDim2.new(0, 100, 0, 35)
LabelEstado.Position = UDim2.new(0, 240, 0, 45)
LabelEstado.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
LabelEstado.Text = "Lines: 0"
LabelEstado.TextColor3 = Color3.fromRGB(0, 255, 150)

local BtnBuscar = Instance.new("TextButton", Panel)
BtnBuscar.Size = UDim2.new(0, 105, 0, 35)
BtnBuscar.Position = UDim2.new(0, 10, 0, 90)
BtnBuscar.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
BtnBuscar.Text = "🔍 Scan Memory"
BtnBuscar.TextSize = 11
BtnBuscar.TextColor3 = Color3.fromRGB(255, 255, 255)

local BtnModoRed = Instance.new("TextButton", Panel)
BtnModoRed.Size = UDim2.new(0, 105, 0, 35)
BtnModoRed.Position = UDim2.new(0, 122, 0, 90)
BtnModoRed.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
BtnModoRed.Text = "📡 Map Network"
BtnModoRed.TextSize = 11
BtnModoRed.TextColor3 = Color3.fromRGB(255, 255, 255)

local BtnModoMemoria = Instance.new("TextButton", Panel)
BtnModoMemoria.Size = UDim2.new(0, 105, 0, 35)
BtnModoMemoria.Position = UDim2.new(0, 235, 0, 90)
BtnModoMemoria.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
BtnModoMemoria.Text = "📦 View Memory"
BtnModoMemoria.TextSize = 11
BtnModoMemoria.TextColor3 = Color3.fromRGB(255, 255, 255)

local ContenedorLista = Instance.new("ScrollingFrame", Panel)
ContenedorLista.Size = UDim2.new(1, -20, 0, 150)
ContenedorLista.Position = UDim2.new(0, 10, 0, 135)
ContenedorLista.BackgroundColor3 = Color3.fromRGB(6, 6, 6)
ContenedorLista.CanvasSize = UDim2.new(0, 0, 0, 0)

local UIListLayout = Instance.new("UIListLayout", ContenedorLista)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local InputMod = Instance.new("TextBox", Panel)
InputMod.Size = UDim2.new(0, 165, 0, 35)
InputMod.Position = UDim2.new(0, 10, 0, 295)
InputMod.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
InputMod.PlaceholderText = "New Hack Value..."
InputMod.TextColor3 = Color3.fromRGB(255, 255, 255)

local BtnEjecutarHack = Instance.new("TextButton", Panel)
BtnEjecutarHack.Size = UDim2.new(0, 85, 0, 35)
BtnEjecutarHack.Position = UDim2.new(0, 185, 0, 295)
BtnEjecutarHack.BackgroundColor3 = Color3.fromRGB(0, 135, 60)
BtnEjecutarHack.Text = "⚡ Lock Value"
BtnEjecutarHack.TextColor3 = Color3.fromRGB(255, 255, 255)

local BtnLimpiar = Instance.new("TextButton", Panel)
BtnLimpiar.Size = UDim2.new(0, 65, 0, 35)
BtnLimpiar.Position = UDim2.new(0, 275, 0, 295)
BtnLimpiar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
BtnLimpiar.Text = "🔄 Reset"
BtnLimpiar.TextColor3 = Color3.fromRGB(255, 255, 255)

local function refrescarListaVisual()
    for _, hijo in ipairs(ContenedorLista:GetChildren()) do
        if hijo:IsA("Frame") then hijo:Destroy() end
    end
    
    local listaOrigen = RGG_Stealth.CurrentMode == "Memory" and RGG_Stealth.Results or RGG_Stealth.HiddenEvents
    ContenedorLista.CanvasSize = UDim2.new(0, 0, 0, #listaOrigen * 32)
    
    local maxItems = math.min(#listaOrigen, 50)
    for i = 1, maxItems do
        local data = listaOrigen[i]
        local Fila = Instance.new("Frame", ContenedorLista)
        Fila.Size = UDim2.new(1, 0, 0, 30)
        Fila.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        
        local BotonSeleccionar = Instance.new("TextButton", Fila)
        BotonSeleccionar.Size = UDim2.new(1, 0, 1, 0)
        BotonSeleccionar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        BotonSeleccionar.TextColor3 = RGG_Stealth.CurrentMode == "Network" and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(220, 220, 220)
        BotonSeleccionar.TextXAlignment = Enum.TextXAlignment.Left
        BotonSeleccionar.Font = Enum.Font.Code
        BotonSeleccionar.TextSize = 12
        
        if RGG_Stealth.CurrentMode == "Memory" then
            BotonSeleccionar.Text = string.format(" [%02d] %s = (%s)", i, data.Name, tostring(data.Object.Value))
            if RGG_Stealth.Frozen[data.Object] then BotonSeleccionar.BackgroundColor3 = Color3.fromRGB(0, 80, 120) end
        else
            BotonSeleccionar.Text = string.format(" [%02d] %s", i, data.Name)
        end
        
        if RGG_Stealth.SelectedIndex == i then
            BotonSeleccionar.BackgroundColor3 = Color3.fromRGB(0, 135, 60)
        end
        
BotonSeleccionar.MouseButton1Click:Connect(function()
RGG_Stealth.SelectedIndex = i
InputMod.PlaceholderText = "Line ["..i.."] Selected"
refrescarListaVisual()
end)
end
end
IconoGG.MouseButton1Click:Connect(function() Panel.Visible = not Panel.Visible end)
BtnBuscar.MouseButton1Click:Connect(function()
RGG_Stealth.CurrentMode = "Memory"
LabelEstado.Text = "Scanning..."
task.wait(0.01)
local t = RGG_Stealth.ScanServices(InputValor.Text)
LabelEstado.Text = "Lines: " .. t
RGG_Stealth.SelectedIndex = nil
refrescarListaVisual()
end)
BtnModoRed.MouseButton1Click:Connect(function()
RGG_Stealth.CurrentMode = "Network"
BtnModoRed.BackgroundColor3 = Color3.fromRGB(0, 135, 60)
BtnModoMemoria.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
RGG_Stealth.ScanServices()
LabelEstado.Text = "Net: " .. #RGG_Stealth.HiddenEvents
RGG_Stealth.SelectedIndex = nil
refrescarListaVisual()
end)
BtnModoMemoria.MouseButton1Click:Connect(function()
RGG_Stealth.CurrentMode = "Memory"
BtnModoMemoria.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
BtnModoRed.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
LabelEstado.Text = "Mem: " .. #RGG_Stealth.Results
RGG_Stealth.SelectedIndex = nil
refrescarListaVisual()
end)
BtnEjecutarHack.MouseButton1Click:Connect(function()
if InputMod.Text == "" or not RGG_Stealth.SelectedIndex then return end
RGG_Stealth.InjectData(RGG_Stealth.SelectedIndex, InputMod.Text, true)
LabelEstado.Text = "Applied!"
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
