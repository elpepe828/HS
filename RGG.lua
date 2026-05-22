-- ===================================================================
-- PROJECT RGG: ROBLOX GAME GUARDIAN PRO (Versión v8.0 - STEALTH ENGINE)
-- Características: Clon de iGameGod + Inyector de Red Pasivo (100% Sin Hooks / Anti-Ban)
-- ===================================================================

local RGG = {
    Resultados = {},
    Congelados = {}, 
    RemotesFisicos = {}, -- Almacena los Remotes encontrados físicamente en el mapa/juego
    TiposValores = {"NumberValue", "IntValue", "DoubleConstrainedValue"},
    HiloFreeze = nil,
    IndiceSeleccionado = nil,
    ModoActual = "Memoria"
}

-- [ OPTIMIZADOR INDEPENDIENTE ]
local function procesarConPausas(lista, accion)
    for i, elemento in ipairs(lista) do
        accion(elemento)
        if i % 2000 == 0 then task.wait() end
    end
end

-- ===================================================================
-- 1. MOTOR DE ESCÁNER SEGURO (PASIVO / SIN METATABLAS)
-- ===================================================================
function RGG.Buscar(valor)
    RGG.Resultados = {}
    RGG.RemotesFisicos = {}
    local objetivo = tonumber(valor)
    
    -- Escaneo ciego y pasivo de todo el árbol de objetos del juego
    local todosLosObjetos = game:GetDescendants()
    
    procesarConPausas(todosLosObjetos, function(obj)
        pcall(function()
            -- A. Clasificar variables locales en memoria
            if table.find(RGG.TiposValores, obj.ClassName) then
                if not objetivo or obj.Value == objetivo then
                    table.insert(RGG.Resultados, {
                        Instancia = obj, 
                        Tipo = "Value", 
                        Nombre = obj.Parent.Name .. " ➔ " .. obj.Name, 
                        UltimoValor = obj.Value
                    })
                end
            end
            
            -- B. Clasificar Remotes físicos (Para forzar cambios reales en el servidor)
            if obj:IsA("RemoteEvent") then
                local nombreLower = string.lower(obj.Name)
                -- Filtrar palabras clave comunes de la economía del juego
                if string.find(nombreLower, "cash") or string.find(nombreLower, "money") or string.find(nombreLower, "reward") or string.find(nombreLower, "add") or string.find(nombreLower, "drive") or string.find(nombreLower, "car") or string.find(nombreLower, "checkpoint") then
                    table.insert(RGG.RemotesFisicos, {
                        Instancia = obj,
                        Tipo = "Remote",
                        Nombre = "[RED] " .. obj.Name,
                        Ruta = obj:GetFullName()
                    })
                end
            end
        end)
    end)
    return #RGG.Resultados
end

function RGG.ModificarEspecifico(indice, nuevoValor)
    local num = tonumber(nuevoValor)
    
    if RGG.ModoActual == "Memoria" then
        local res = RGG.Resultados[indice]
        if not res then return end
        pcall(function() res.Instancia.Value = num end)
        RGG.Congelados[res] = num
        
        if not RGG.HiloFreeze then
            RGG.HiloFreeze = task.spawn(function()
                while true do
                    local activos = 0
                    for item, v in pairs(RGG.Congelados) do
                        activos = activos + 1
                        pcall(function() item.Instancia.Value = v end)
                    end
                    if activos == 0 then break end
                    task.wait(0.05) 
                end
                RGG.HiloFreeze = nil
            end)
        end
    elseif RGG.ModoActual == "Red" then
        -- INYECTOR REAL PASIVO: Disparar el evento de forma legítima como lo haría el juego
        local remoteData = RGG.RemotesFisicos[indice]
        if not remoteData then return end
        
        pcall(function()
            -- Enviamos variaciones de argumentos para probar cuál acepta el servidor
            remoteData.Instancia:FireServer(num)
            remoteData.Instancia:FireServer(true, num)
            remoteData.Instancia:FireServer("Reward", num)
        end)
    end
end

function RGG.Limpiar()
    RGG.Resultados = {}
    RGG.Congelados = {}
    RGG.RemotesFisicos = {}
    RGG.IndiceSeleccionado = nil
    if RGG.HiloFreeze then task.cancel(RGG.HiloFreeze); RGG.HiloFreeze = nil end
end

-- ===================================================================
-- 2. INTERFAZ GRÁFICA DE USUARIO EVASIVA
-- ===================================================================
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "RGG_v8_StealthConsole"

local IconoGG = Instance.new("TextButton", ScreenGui)
IconoGG.Size = UDim2.new(0, 55, 0, 55)
IconoGG.Position = UDim2.new(0, 10, 0, 150)
IconoGG.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
IconoGG.Text = "RGG"
IconoGG.TextColor3 = Color3.fromRGB(0, 255, 120)
IconoGG.Font = Enum.Font.SourceSansBold
IconoGG.TextSize = 22
IconoGG.Active = true
IconoGG.Draggable = true

local Panel = Instance.new("Frame", ScreenGui)
Panel.Size = UDim2.new(0, 360, 0, 380)
Panel.Position = UDim2.new(0.5, -180, 0.4, -190)
Panel.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
Panel.Visible = false
Panel.Active = true
Panel.Draggable = true

local Titulo = Instance.new("TextLabel", Panel)
Titulo.Size = UDim2.new(1, 0, 0, 35)
Titulo.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
Titulo.Text = " 安全 RGG Stealth Memory & Network Engine v8.0"
Titulo.TextColor3 = Color3.fromRGB(255, 255, 255)
Titulo.Font = Enum.Font.SourceSansBold
Titulo.TextSize = 13

local InputValor = Instance.new("TextBox", Panel)
InputValor.Size = UDim2.new(0, 230, 0, 35)
InputValor.Position = UDim2.new(0, 10, 0, 45)
InputValor.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
InputValor.PlaceholderText = "Número exacto a buscar..."
InputValor.TextColor3 = Color3.fromRGB(255, 255, 255)

local LabelEstado = Instance.new("TextLabel", Panel)
LabelEstado.Size = UDim2.new(0, 100, 0, 35)
LabelEstado.Position = UDim2.new(0, 250, 0, 45)
LabelEstado.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
LabelEstado.Text = "Líneas: 0"
LabelEstado.TextColor3 = Color3.fromRGB(0, 255, 150)

local BtnBuscar = Instance.new("TextButton", Panel)
BtnBuscar.Size = UDim2.new(0, 110, 0, 35)
BtnBuscar.Position = UDim2.new(0, 10, 0, 90)
BtnBuscar.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
BtnBuscar.Text = "🔍 Buscar Memoria"
BtnBuscar.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnBuscar.TextSize = 12

local BtnModoRed = Instance.new("TextButton", Panel)
BtnModoRed.Size = UDim2.new(0, 110, 0, 35)
BtnModoRed.Position = UDim2.new(0, 125, 0, 90)
BtnModoRed.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
BtnModoRed.Text = "📡 Remotes Seguros"
BtnModoRed.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnModoRed.TextSize = 12

local BtnModoMemoria = Instance.new("TextButton", Panel)
BtnModoMemoria.Size = UDim2.new(0, 110, 0, 35)
BtnModoMemoria.Position = UDim2.new(0, 240, 0, 90)
BtnModoMemoria.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
BtnModoMemoria.Text = "📦 Ver Escaneos"
BtnModoMemoria.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnModoMemoria.TextSize = 12

local ContenedorLista = Instance.new("ScrollingFrame", Panel)
ContenedorLista.Size = UDim2.new(1, -20, 0, 170)
ContenedorLista.Position = UDim2.new(0, 10, 0, 135)
ContenedorLista.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
ContenedorLista.CanvasSize = UDim2.new(0, 0, 0, 0)

local UIListLayout = Instance.new("UIListLayout", ContenedorLista)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local InputMod = Instance.new("TextBox", Panel)
InputMod.Size = UDim2.new(0, 165, 0, 35)
InputMod.Position = UDim2.new(0, 10, 0, 315)
InputMod.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
InputMod.PlaceholderText = "Monto a Inyectar..."
InputMod.TextColor3 = Color3.fromRGB(255, 255, 255)

local BtnEjecutarHack = Instance.new("TextButton", Panel)
BtnEjecutarHack.Size = UDim2.new(0, 85, 0, 35)
BtnEjecutarHack.Position = UDim2.new(0, 185, 0, 315)
BtnEjecutarHack.BackgroundColor3 = Color3.fromRGB(0, 135, 60)
BtnEjecutarHack.Text = "⚡ Forzar"
BtnEjecutarHack.TextColor3 = Color3.fromRGB(255, 255, 255)

local BtnLimpiar = Instance.new("TextButton", Panel)
BtnLimpiar.Size = UDim2.new(0, 75, 0, 35)
BtnLimpiar.Position = UDim2.new(0, 275, 0, 315)
BtnLimpiar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
BtnLimpiar.Text = "🔄 Reset"
BtnLimpiar.TextColor3 = Color3.fromRGB(255, 255, 255)

local function refrescarListaVisual()
    for _, hijo in ipairs(ContenedorLista:GetChildren()) do
        if hijo:IsA("Frame") then hijo:Destroy() end
    end
    
    local listaOrigen = RGG.ModoActual == "Memoria" and RGG.Resultados or RGG.RemotesFisicos
    ContenedorLista.CanvasSize = UDim2.new(0, 0, 0, #listaOrigen * 32)
    
    local maxItems = math.min(#listaOrigen, 50)
    for i = 1, maxItems do
        local data = listaOrigen[i]
        local Fila = Instance.new("Frame", ContenedorLista)
        Fila.Size = UDim2.new(1, 0, 0, 30)
        Fila.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        
        local BotonSeleccionar = Instance.new("TextButton", Fila)
        BotonSeleccionar.Size = UDim2.new(1, 0, 1, 0)
        BotonSeleccionar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        BotonSeleccionar.TextColor3 = RGG.ModoActual == "Red" and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(230, 230, 230)
        BotonSeleccionar.TextXAlignment = Enum.TextXAlignment.Left
        BotonSeleccionar.Font = Enum.Font.SourceSans
        BotonSeleccionar.TextSize = 13
        
        if RGG.ModoActual == "Memoria" then
            BotonSeleccionar.Text = string.format(" [%02d] %s = (%s)", i, data.Nombre, tostring(data.Instancia.Value))
            if RGG.Congelados[data] then BotonSeleccionar.BackgroundColor3 = Color3.fromRGB(0, 100, 150) end
        else
            BotonSeleccionar.Text = string.format(" [📡] %s", data.Nombre)
        end
        
        if RGG.IndiceSeleccionado == i then
BotonSeleccionar.BackgroundColor3 = RGG.ModoActual == "Red" and Color3.fromRGB(0, 100, 180) or Color3.fromRGB(0, 135, 60)
end
BotonSeleccionar.MouseButton1Click:Connect(function()
RGG.IndiceSeleccionado = i
InputMod.PlaceholderText = "Línea ["..i.."] elegida"
refrescarListaVisual()
end)
end
end
IconoGG.MouseButton1Click:Connect(function() Panel.Visible = not Panel.Visible end)
BtnBuscar.MouseButton1Click:Connect(function()
RGG.ModivActual = "Memoria"
LabelEstado.Text = "Escan..."
task.wait(0.01)
local t = RGG.Buscar(InputValor.Text)
LabelEstado.Text = "Líneas: " .. t
RGG.IndiceSeleccionado = nil
refrescarListaVisual()
end)
BtnModoRed.MouseButton1Click:Connect(function()
RGG.ModoActual = "Red"
BtnModoRed.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
BtnModoMemoria.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
if #RGG.RemotesFisicos == 0 then RGG.Buscar() end -- Auto-mapeo rápido
LabelEstado.Text = "Eventos: " .. #RGG.RemotesFisicos
RGG.IndiceSeleccionado = nil
refrescarListaVisual()
end)
BtnModoMemoria.MouseButton1Click:Connect(function()
RGG.ModoActual = "Memoria"
BtnModoMemoria.BackgroundColor3 = Color3.fromRGB(0, 135, 60)
BtnModoRed.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
LabelEstado.Text = "Mem: " .. #RGG.Resultados
RGG.IndiceSeleccionado = nil
refrescarListaVisual()
end)
BtnEjecutarHack.MouseButton1Click:Connect(function()
if InputMod.Text == "" or not RGG.IndiceSeleccionado then return end
RGG.ModificarEspecifico(RGG.IndiceSeleccionado, InputMod.Text)
LabelEstado.Text = "¡Enviado!"
task.wait(0.1)
refrescarListaVisual()
end)
BtnLimpiar.MouseButton1Click:Connect(function()
RGG.Limpiar()
LabelEstado.Text = "Líneas: 0"
InputValor.Text = ""
InputMod.Text = ""
refrescarListaVisual()
end)
