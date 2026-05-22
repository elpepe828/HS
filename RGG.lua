-- ===================================================================
-- PROJECT RGG: ROBLOX GAME GUARDIAN PRO (Versión v7.0 - SPY INTEGRADO)
-- Características: Clon de iGameGod + Captura y Modificación de Red en Vivo
-- ===================================================================

local RGG = {
    Resultados = {},
    Congelados = {}, 
    RemotesCapturados = {}, -- Almacena eventos de red interceptados
    TiposValores = {"NumberValue", "IntValue", "DoubleConstrainedValue"},
    HiloFreeze = nil,
    IndiceSeleccionado = nil,
    ModoActual = "Memoria" -- Modos: "Memoria" o "Red"
}

-- [ OPTIMIZADOR DE RENDIMIENTO ANTI-CRASH ]
local function procesarConPausas(lista, accion)
    for i, elemento in ipairs(lista) do
        accion(elemento)
        if i % 2000 == 0 then task.wait() end
    end
end

-- ===================================================================
-- 1. MOTOR DE INTERCEPCIÓN EN VIVO (REMOTE SPY)
-- ===================================================================
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    -- Interceptar ejecuciones legítimas del juego hacia el servidor
    if method == "FireServer" and self:IsA("RemoteEvent") then
        local yaExiste = false
        for _, v in ipairs(RGG.RemotesCapturados) do
            if v.Instancia == self then yaExiste = true break end
        end
        
        -- Guardar el Remote y sus argumentos actuales para análisis
        if not yaExiste then
            table.insert(RGG.RemotesCapturados, {
                Instancia = self,
                Nombre = "[RED] " .. self.Name,
                Args = args
            })
        else
            -- Actualizar los últimos argumentos capturados
            for _, v in ipairs(RGG.RemotesCapturados) do
                if v.Instancia == self then v.Args = args break end
            end
        end
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- ===================================================================
-- 2. MOTOR DE MEMORIA LOCAL
-- ===================================================================
function RGG.Buscar(valor)
    RGG.Resultados = {}
    local objetivo = tonumber(valor)
    local todosLosObjetos = game:GetDescendants()
    
    procesarConPausas(todosLosObjetos, function(obj)
        pcall(function()
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
        -- MODIFICACIÓN REAL: Forzar disparo de red manipulado
        local data = RGG.RemotesCapturados[indice]
        if not data then return end
        
        local nuevosArgs = {}
        if data.Args and #data.Args > 0 then
            for i, arg in ipairs(data.Args) do
                -- Si el argumento original era numérico, inyectamos nuestro hack
                if type(arg) == "number" then
                    nuevosArgs[i] = num
                else
                    nuevosArgs[i] = arg
                end
            end
        else
            nuevosArgs = {num} -- Si no tenía argumentos, enviamos el número directo
        end
        
        pcall(function()
            data.Instancia:FireServer(unpack(nuevosArgs))
        end)
    end
end

function RGG.Limpiar()
    RGG.Resultados = {}
    RGG.Congelados = {}
    RGG.RemotesCapturados = {}
    RGG.IndiceSeleccionado = nil
    if RGG.HiloFreeze then task.cancel(RGG.HiloFreeze); RGG.HiloFreeze = nil end
end

-- ===================================================================
-- 3. INTERFAZ GRÁFICA DE USUARIO INTERACTIVA
-- ===================================================================
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "RGG_v7_SpyConsole"

local IconoGG = Instance.new("TextButton", ScreenGui)
IconoGG.Size = UDim2.new(0, 55, 0, 55)
IconoGG.Position = UDim2.new(0, 10, 0, 150)
IconoGG.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
IconoGG.Text = "RGG"
IconoGG.TextColor3 = Color3.fromRGB(255, 180, 0)
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
Titulo.Text = " 📡 RGG Network & Memory Engine v7.0"
Titulo.TextColor3 = Color3.fromRGB(255, 255, 255)
Titulo.Font = Enum.Font.SourceSansBold
Titulo.TextSize = 14

local InputValor = Instance.new("TextBox", Panel)
InputValor.Size = UDim2.new(0, 230, 0, 35)
InputValor.Position = UDim2.new(0, 10, 0, 45)
InputValor.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
InputValor.PlaceholderText = "Número de memoria a buscar..."
InputValor.TextColor3 = Color3.fromRGB(255, 255, 255)

local LabelEstado = Instance.new("TextLabel", Panel)
LabelEstado.Size = UDim2.new(0, 100, 0, 35)
LabelEstado.Position = UDim2.new(0, 250, 0, 45)
LabelEstado.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
LabelEstado.Text = "Líneas: 0"
LabelEstado.TextColor3 = Color3.fromRGB(0, 255, 150)

local BtnBuscar = Instance.new("TextButton", Panel)
BtnBuscar.Size = UDim2.new(0, 110, 0, 35)
BtnBuscar.Position = UDim2.new(0, 10, 0, 90)
BtnBuscar.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
BtnBuscar.Text = "🔍 Buscar Memoria"
BtnBuscar.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnBuscar.TextSize = 12

local BtnModoRed = Instance.new("TextButton", Panel)
BtnModoRed.Size = UDim2.new(0, 110, 0, 35)
BtnModoRed.Position = UDim2.new(0, 125, 0, 90)
BtnModoRed.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
BtnModoRed.Text = "📡 Mostrar Tráfico"
BtnModoRed.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnModoRed.TextSize = 12

local BtnModoMemoria = Instance.new("TextButton", Panel)
BtnModoMemoria.Size = UDim2.new(0, 110, 0, 35)
BtnModoMemoria.Position = UDim2.new(0, 240, 0, 90)
BtnModoMemoria.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
BtnModoMemoria.Text = "📦 Ver Escaneos"
BtnModoMemoria.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnModoMemoria.TextSize = 12

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
InputMod.PlaceholderText = "Cantidad/Inyección..."
InputMod.TextColor3 = Color3.fromRGB(255, 255, 255)

local BtnEjecutarHack = Instance.new("TextButton", Panel)
BtnEjecutarHack.Size = UDim2.new(0, 85, 0, 35)
BtnEjecutarHack.Position = UDim2.new(0, 185, 0, 315)
BtnEjecutarHack.BackgroundColor3 = Color3.fromRGB(0, 150, 70)
BtnEjecutarHack.Text = "⚡ Inyectar"
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
    
    local listaOrigen = RGG.ModoActual == "Memoria" and RGG.Resultados or RGG.RemotesCapturados
    ContenedorLista.CanvasSize = UDim2.new(0, 0, 0, #listaOrigen * 32)
    
    local maxItems = math.min(#listaOrigen, 50)
    for i = 1, maxItems do
        local data = listaOrigen[i]
        local Fila = Instance.new("Frame", ContenedorLista)
        Fila.Size = UDim2.new(1, 0, 0, 30)
        Fila.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        
        local BotonSeleccionar = Instance.new("TextButton", Fila)
        BotonSeleccionar.Size = UDim2.new(1, 0, 1, 0)
        BotonSeleccionar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        BotonSeleccionar.TextColor3 = RGG.ModoActual == "Red" and Color3.fromRGB(255, 150, 255) or Color3.fromRGB(230, 230, 230)
        BotonSeleccionar.TextXAlignment = Enum.TextXAlignment.Left
BotonSeleccionar.Font = Enum.Font.SourceSans
BotonSeleccionar.TextSize = 13
if RGG.ModoActual == "Memoria" then
BotonSeleccionar.Text = string.format(" [%02d] %s = (%s)", i, data.Nombre, tostring(data.Instancia.Value))
if RGG.Congelados[data] then BotonSeleccionar.BackgroundColor3 = Color3.fromRGB(0, 100, 150) end
else
BotonSeleccionar.Text = string.format(" [📡] %s (ArgCount: %d)", data.Nombre, #data.Args)
end
if RGG.IndiceSeleccionado == i then
BotonSeleccionar.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
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
RGG.ModoActual = "Memoria"
LabelEstado.Text = "Escan..."
task.wait(0.01)
local t = RGG.Buscar(InputValor.Text)
LabelEstado.Text = "Líneas: " .. t
RGG.IndiceSeleccionado = nil
refrescarListaVisual()
end)
BtnModoRed.MouseButton1Click:Connect(function()
RGG.ModoActual = "Red"
BtnModoRed.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
BtnModoMemoria.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
LabelEstado.Text = "Red: " .. #RGG.RemotesCapturados
RGG.IndiceSeleccionado = nil
refrescarListaVisual()
end)
BtnModoMemoria.MouseButton1Click:Connect(function()
RGG.ModoActual = "Memoria"
BtnModoMemoria.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
BtnModoRed.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
LabelEstado.Text = "Mem: " .. #RGG.Resultados
RGG.IndiceSeleccionado = nil
refrescarListaVisual()
end)
BtnEjecutarHack.MouseButton1Click:Connect(function()
if InputMod.Text == "" or not RGG.IndiceSeleccionado then return end
RGG.ModificarEspecifico(RGG.IndiceSeleccionado, InputMod.Text)
LabelEstado.Text = "Inyectado!"
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
