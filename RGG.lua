-- ===================================================================
-- PROJECT RGG: ROBLOX GAME GUARDIAN PRO (Versión v6.0 - TOTAL ENGINE)
-- Características: Clon de iGameGod completo, Escaneo de todos los valores, Anti-Ban
-- ===================================================================

local RGG = {
    Resultados = {},
    Congelados = {}, 
    TiposValores = {"NumberValue", "IntValue", "DoubleConstrainedValue"},
    HiloFreeze = nil,
    IndiceSeleccionado = nil
}

-- [ OPTIMIZADOR DE RENDIMIENTO ANTI-CRASH ]
local function procesarConPausas(lista, accion)
    for i, elemento in ipairs(lista) do
        accion(elemento)
        if i % 2000 == 0 then task.wait() end -- Evita que Delta se cierre por exceso de datos
    end
end

-- ===================================================================
-- 1. MOTOR DE ESCÁNER TOTAL (BUSCA CUALQUIER VARIABLE NUMÉRICA)
-- ===================================================================
function RGG.Buscar(valor)
    RGG.Resultados = {}
    local objetivo = tonumber(valor)
    
    print("[RGG Engine] Iniciando escaneo completo del DataModel...")
    
    -- Escanear absolutamente todo el juego (Espacio de trabajo, Jugadores, Interfaz, etc.)
    local todosLosObjetos = game:GetDescendants()
    
    procesarConPausas(todosLosObjetos, function(obj)
        pcall(function()
            -- 1. Buscar en objetos contenedores de números (IntValue, NumberValue, etc.)
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
            
            -- 2. Buscar en Atributos numéricos personalizados ocultos
            local attrs = obj:GetAttributes()
            for n, v in pairs(attrs) do
                if type(v) == "number" then
                    if not objetivo or v == objetivo then
                        table.insert(RGG.Resultados, {
                            Instancia = obj, 
                            Tipo = "Attribute", 
                            Nombre = obj.Name .. " [" .. n .. "]", 
                            NombreAttr = n,
                            UltimoValor = v
                        })
                    end
                end
            end
        end)
    end)
    
    return #RGG.Resultados
end

-- ===================================================================
-- 2. FILTRADO LINEAL DE VARIACIONES
-- ===================================================================
function RGG.Refinar(valor)
    if #RGG.Resultados == 0 then return 0 end
    local num = tonumber(valor)
    local nuevos = {}
    
    procesarConPausas(RGG.Resultados, function(res)
        pcall(function()
            local valAct = nil
            if res.Tipo == "Value" then
                valAct = res.Instancia.Value
            else
                valAct = res.Instancia:GetAttribute(res.NombreAttr)
            end
            
            if valAct and valAct == num then
                res.UltimoValor = num
                table.insert(nuevos, res)
            end
        end)
    end)
    
    RGG.Resultados = nuevos
    return #RGG.Resultados
end

-- ===================================================================
-- 3. EDICIÓN Y CONGELACIÓN QUIRÚRGICA SELECCIONADA
-- ===================================================================
function RGG.ModificarEspecifico(indice, nuevoValor, bloquear)
    local res = RGG.Resultados[indice]
    if not res then return end
    local num = tonumber(nuevoValor)
    
    pcall(function() 
        if res.Tipo == "Value" then
            res.Instancia.Value = num 
        else
            res.Instancia:SetAttribute(res.NombreAttr, num)
        end
        res.UltimoValor = num
    end)
    
    if bloquear then
        RGG.Congelados[res] = num
    else
        RGG.Congelados[res] = nil
    end
    
    -- Hilo persistente seguro (Bucle de bloqueo continuo a 20Hz)
    if bloquear and not RGG.HiloFreeze then
        RGG.HiloFreeze = task.spawn(function()
            while true do
                local activos = 0
                for item, v in pairs(RGG.Congelados) do
                    activos = activos + 1
                    pcall(function() 
                        if item.Tipo == "Value" then
                            item.Instancia.Value = v 
                        else
                            item.Instancia:SetAttribute(item.NombreAttr, v)
                        end
                    end)
                end
                if activos == 0 then break end
                task.wait(0.05) 
            end
            RGG.HiloFreeze = nil
        end)
    end
end

function RGG.Limpiar()
    RGG.Resultados = {}
    RGG.Congelados = {}
    RGG.IndiceSeleccionado = nil
    if RGG.HiloFreeze then task.cancel(RGG.HiloFreeze); RGG.HiloFreeze = nil end
end

-- ===================================================================
-- 4. INTERFAZ GRÁFICA DE USUARIO AVANZADA (GUI TIPO iGAMEGOD PRO)
-- ===================================================================
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "RGG_v6_TotalConsole"

local IconoGG = Instance.new("TextButton", ScreenGui)
IconoGG.Size = UDim2.new(0, 55, 0, 55)
IconoGG.Position = UDim2.new(0, 10, 0, 150)
IconoGG.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
IconoGG.Text = "RGG"
IconoGG.TextColor3 = Color3.fromRGB(0, 255, 150)
IconoGG.Font = Enum.Font.SourceSansBold
IconoGG.TextSize = 22
IconoGG.Active = true
IconoGG.Draggable = true

local Panel = Instance.new("Frame", ScreenGui)
Panel.Size = UDim2.new(0, 360, 0, 380)
Panel.Position = UDim2.new(0.5, -180, 0.4, -190)
Panel.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Panel.Visible = false
Panel.Active = true
Panel.Draggable = true

local Titulo = Instance.new("TextLabel", Panel)
Titulo.Size = UDim2.new(1, 0, 0, 35)
Titulo.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
Titulo.Text = "  🛠️ RGG iGameGod Total Engine v6.0"
Titulo.TextColor3 = Color3.fromRGB(255, 255, 255)
Titulo.Font = Enum.Font.SourceSansBold
Titulo.TextSize = 14
Titulo.TextXAlignment = Enum.TextXAlignment.Left

local InputValor = Instance.new("TextBox", Panel)
InputValor.Size = UDim2.new(0, 230, 0, 35)
InputValor.Position = UDim2.new(0, 10, 0, 45)
InputValor.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
InputValor.PlaceholderText = "Valor exacto a buscar..."
InputValor.TextColor3 = Color3.fromRGB(255, 255, 255)
InputValor.TextSize = 13

local LabelEstado = Instance.new("TextLabel", Panel)
LabelEstado.Size = UDim2.new(0, 100, 0, 35)
LabelEstado.Position = UDim2.new(0, 250, 0, 45)
LabelEstado.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
LabelEstado.Text = "Líneas: 0"
LabelEstado.TextColor3 = Color3.fromRGB(0, 255, 150)

local BtnBuscar = Instance.new("TextButton", Panel)
BtnBuscar.Size = UDim2.new(0, 165, 0, 35)
BtnBuscar.Position = UDim2.new(0, 10, 0, 90)
BtnBuscar.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
BtnBuscar.Text = "🔍 Nueva Buscar"
BtnBuscar.TextColor3 = Color3.fromRGB(255, 255, 255)

local BtnFiltrar = Instance.new("TextButton", Panel)
BtnFiltrar.Size = UDim2.new(0, 165, 0, 35)
BtnFiltrar.Position = UDim2.new(0, 185, 0, 90)
BtnFiltrar.BackgroundColor3 = Color3.fromRGB(180, 120, 0)
BtnFiltrar.Text = "⏳ Refinar Filtro"
BtnFiltrar.TextColor3 = Color3.fromRGB(255, 255, 255)

local ContenedorLista = Instance.new("ScrollingFrame", Panel)
ContenedorLista.Size = UDim2.new(1, -20, 0, 170)
ContenedorLista.Position = UDim2.new(0, 10, 0, 135)
ContenedorLista.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ContenedorLista.CanvasSize = UDim2.new(0, 0, 0, 0)

local UIListLayout = Instance.new("UIListLayout", ContenedorLista)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local InputMod = Instance.new("TextBox", Panel)
InputMod.Size = UDim2.new(0, 165, 0, 35)
InputMod.Position = UDim2.new(0, 10, 0, 315)
InputMod.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
InputMod.PlaceholderText = "Modificar por..."
InputMod.TextColor3 = Color3.fromRGB(255, 255, 255)

local BtnEjecutarHack = Instance.new("TextButton", Panel)
BtnEjecutarHack.Size = UDim2.new(0, 85, 0, 35)
BtnEjecutarHack.Position = UDim2.new(0, 185, 0, 315)
BtnEjecutarHack.BackgroundColor3 = Color3.fromRGB(0, 150, 70)
BtnEjecutarHack.Text = "🔒 Bloquear"
BtnEjecutarHack.TextColor3 = Color3.fromRGB(255, 255, 255)

local BtnLimpiar = Instance.new("TextButton", Panel)
BtnLimpiar.Size = UDim2.new(0, 75, 0, 35)
BtnLimpiar.Position = UDim2.new(0, 275, 0, 315)
BtnLimpiar.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
BtnLimpiar.Text = "🔄 Reset"
BtnLimpiar.TextColor3 = Color3.fromRGB(255, 255, 255)

local function refrescarListaVisual()
    for _, hijo in ipairs(ContenedorLista:GetChildren()) do
        if hijo:IsA("Frame") then hijo:Destroy() end
    end
    
    ContenedorLista.CanvasSize = UDim2.new(0, 0, 0, #RGG.Resultados * 32)
    local maxItems = math.min(#RGG.Resultados, 50)
    
    for i = 1, maxItems do
        local res = RGG.Resultados[i]
        
        local Fila = Instance.new("Frame", ContenedorLista)
        Fila.Size = UDim2.new(1, 0, 0, 30)
        Fila.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        
        local valAct = "Err"
        pcall(function()
            valAct = res.Tipo == "Value" and res.Instancia.Value or res.Instancia:GetAttribute(res.NombreAttr)
        end)
        
        local BotonSeleccionar = Instance.new("TextButton", Fila)
        BotonSeleccionar.Size = UDim2.new(0, 260, 1, 0)
        BotonSeleccionar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        BotonSeleccionar.Text = string.format(" [%02d] %s = (%s)", i, res.Nombre, tostring(valAct))
BotonSeleccionar.TextColor3 = Color3.fromRGB(230, 230, 230)
BotonSeleccionar.TextXAlignment = Enum.TextXAlignment.Left
BotonSeleccionar.Font = Enum.Font.SourceSans
BotonSeleccionar.TextSize = 13
local IndicadorFreeze = Instance.new("TextLabel", Fila)
IndicadorFreeze.Size = UDim2.new(0, 70, 1, 0)
IndicadorFreeze.Position = UDim2.new(0, 260, 0, 0)
IndicadorFreeze.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
IndicadorFreeze.Text = "Libre"
IndicadorFreeze.TextColor3 = Color3.fromRGB(120, 120, 120)
IndicadorFreeze.TextSize = 12
if RGG.Congelados[res] then
IndicadorFreeze.Text = "🔒 LOCK"
IndicadorFreeze.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
IndicadorFreeze.TextColor3 = Color3.fromRGB(255, 255, 255)
end
if RGG.IndiceSeleccionado == i then
BotonSeleccionar.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
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
if InputValor.Text == "" then LabelEstado.Text = "Pon un nº"; return end
LabelEstado.Text = "Escan..."
task.wait(0.01)
local t = RGG.Buscar(InputValor.Text)
LabelEstado.Text = "Líneas: " .. t
RGG.IndiceSeleccionado = nil
refrescarListaVisual()
end)
BtnFiltrar.MouseButton1Click:Connect(function()
if InputValor.Text == "" then LabelEstado.Text = "Pon un nº"; return end
LabelEstado.Text = "Filtr..."
task.wait(0.01)
local t = RGG.Refinar(InputValor.Text)
LabelEstado.Text = "Líneas: " .. t
RGG.IndiceSeleccionado = nil
refrescarListaVisual()
end)
BtnEjecutarHack.MouseButton1Click:Connect(function()
if InputMod.Text == "" or not RGG.IndiceSeleccionado then return end
RGG.ModificarEspecifico(RGG.IndiceSeleccionado, InputMod.Text, true)
LabelEstado.Text = "Fijado ["..RGG.IndiceSeleccionado.."]"
task.wait(0.1)
refrescarListaVisual()
end)
BtnLimpiar.MouseButton1Click:Connect(function()
RGG.Limpiar()
LabelEstado.Text = "Líneas: 0"
InputValor.Text = ""
InputMod.Text = ""
InputMod.PlaceholderText = "Modificar por..."
refrescarListaVisual()
end)
