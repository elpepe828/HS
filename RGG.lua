-- ===================================================================
-- PROJECT RGG: ROBLOX GAME GUARDIAN PRO (Versión v4.0 - SERVER BYPASS)
-- Características: Hooking de Red (Dinero Real), Bloqueo Selectivo estilo iGG
-- ===================================================================

local RGG = {
    Resultados = {},
    Congelados = {}, -- Diccionario para bloquear valores locales
    ModificadoresRed = {}, -- Diccionario para bloquear/cambiar argumentos del servidor
    TiposValores = {"NumberValue", "IntValue", "DoubleConstrainedValue"},
    HiloFreeze = nil,
    IndiceSeleccionado = nil
}

-- ===================================================================
-- 1. MOTOR DE INTERCEPCIÓN DE RED (DINERO REAL / SERVER BYPASS)
-- ===================================================================
-- Este hook intercepta la comunicación del juego con el servidor en tiempo real.
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    -- Si el juego está disparando un RemoteEvent hacia el servidor
    if method == "FireServer" and self:IsA("RemoteEvent") then
        local remoteName = string.lower(self.Name)
        
        -- Verificar si este Remote específico está registrado para ser alterado/bloqueado
        if RGG.ModificadoresRed[self] then
            local valorForzado = RGG.ModificadoresRed[self].Valor
            -- Reemplazamos todos los números que envíe el juego por nuestro valor hackeado
            for i = 1, #args do
                if type(args[i]) == "number" then
                    args[i] = valorForzado
                end
            end
            return oldNamecall(self, unpack(args))
        end
        
        -- Auto-Detección inteligente para dinero real en Highway Showdown y similares
        if string.find(remoteName, "cash") or string.find(remoteName, "money") or string.find(remoteName, "reward") or string.find(remoteName, "add") then
            for i = 1, #args do
                if type(args[i]) == "number" and RGG.ValorBypassGlobal then
                    args[i] = RGG.ValorBypassGlobal
                end
            end
        end
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- ===================================================================
-- 2. ESCÁNER DE MEMORIA LOCAL Y OBJETOS DE RED
-- ===================================================================
function RGG.Buscar(valor)
    RGG.Resultados = {}
    local objetivo = tonumber(valor)
    
    -- Escanear RemoteEvents (Para dinero real en el servidor)
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local nombreLower = string.lower(obj.Name)
            if not objetivo or string.find(nombreLower, "cash") or string.find(nombreLower, "money") then
                table.insert(RGG.Resultados, {Instancia = obj, Tipo = "Remote", Nombre = "[RED] " .. obj.Name, UltimoValor = "Transmisor"})
            end
        end
    end
    
    -- Escanear valores locales (Para velocidad, vida, datos visuales)
    for _, obj in ipairs(game:GetDescendants()) do
        if table.find(RGG.TiposValores, obj.ClassName) then
            if not objetivo or obj.Value == objetivo then
                table.insert(RGG.Resultados, {Instancia = obj, Tipo = "Value", Nombre = obj.Name, UltimoValor = obj.Value})
            end
        end
    end
    return #RGG.Resultados
end

function RGG.Refinar(valor)
    if #RGG.Resultados == 0 then return 0 end
    local num = tonumber(valor)
    local nuevos = {}
    
    for _, res in ipairs(RGG.Resultados) do
        if res.Tipo == "Value" then
            pcall(function()
                if res.Instancia.Value == num then
                    res.UltimoValor = num
                    table.insert(nuevos, res)
                end
            end)
        else
            -- Los remotes se mantienen en el refinamiento si buscas canales de red
            table.insert(nuevos, res)
        end
    end
    RGG.Resultados = nuevos
    return #RGG.Resultados
end

-- Modificación selectiva y congelación estilo iGG
function RGG.ModificarEspecifico(indice, nuevoValor, bloquear)
    local res = RGG.Resultados[indice]
    if not res then return end
    local num = tonumber(nuevoValor)
    
    if res.Tipo == "Remote" then
        -- HACK DE SERVIDOR: Forzar el bloqueo del canal de comunicación real
        if bloquear then
            RGG.ModificadoresRed[res.Instancia] = {Valor = num}
            -- Disparar una vez para actualizar instantáneamente
            pcall(function() res.Instancia:FireServer(num) end)
        else
            RGG.ModificadoresRed[res.Instancia] = nil
        end
    elseif res.Tipo == "Value" then
        -- HACK LOCAL: Modificar y freezar variable en pantalla
        pcall(function() res.Instancia.Value = num end)
        if bloquear then
            RGG.Congelados[res.Instancia] = num
        else
            RGG.Congelados[res.Instancia] = nil
        end
    end
    
    -- Hilo persistente de congelación local (Freeze)
    if bloquear and not RGG.HiloFreeze then
        RGG.HiloFreeze = task.spawn(function()
            while true do
                local activos = 0
                for instancia, v in pairs(RGG.Congelados) do
                    activos = activos + 1
                    pcall(function() instancia.Value = v end)
                end
                if activos == 0 and next(RGG.ModificadoresRed) == nil then break end
                task.wait(0.05) -- 20 veces por segundo
            end
            RGG.HiloFreeze = nil
        end)
    end
end

function RGG.Limpiar()
    RGG.Resultados = {}
    RGG.Congelados = {}
    RGG.ModificadoresRed = {}
    RGG.ValorBypassGlobal = nil
    RGG.IndiceSeleccionado = nil
    if RGG.HiloFreeze then task.cancel(RGG.HiloFreeze); RGG.HiloFreeze = nil end
end

-- ===================================================================
-- INTERFAZ GRÁFICA ESTILO iGAMEGOD
-- ===================================================================
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "RGG_v4_Console"

local IconoGG = Instance.new("TextButton", ScreenGui)
IconoGG.Size = UDim2.new(0, 55, 0, 55)
IconoGG.Position = UDim2.new(0, 10, 0, 150)
IconoGG.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
IconoGG.Text = "RGG"
IconoGG.TextColor3 = Color3.fromRGB(255, 60, 60) -- Color Pro Red
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
Titulo.Text = " ⚡ RGG iGameGod Edition v4.0 (REAL)"
Titulo.TextColor3 = Color3.fromRGB(255, 255, 255)
Titulo.Font = Enum.Font.SourceSansBold
Titulo.TextSize = 15

local InputValor = Instance.new("TextBox", Panel)
InputValor.Size = UDim2.new(0, 230, 0, 35)
InputValor.Position = UDim2.new(0, 10, 0, 45)
InputValor.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
InputValor.PlaceholderText = "Valor o nombre de Dinero..."
InputValor.TextColor3 = Color3.fromRGB(255, 255, 255)

local LabelEstado = Instance.new("TextLabel", Panel)
LabelEstado.Size = UDim2.new(0, 100, 0, 35)
LabelEstado.Position = UDim2.new(0, 250, 0, 45)
LabelEstado.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
LabelEstado.Text = "Líneas: 0"
LabelEstado.TextColor3 = Color3.fromRGB(0, 255, 150)

local BtnBuscar = Instance.new("TextButton", Panel)
BtnBuscar.Size = UDim2.new(0, 105, 0, 35)
BtnBuscar.Position = UDim2.new(0, 10, 0, 90)
BtnBuscar.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
BtnBuscar.Text = "🔍 Buscar"
BtnBuscar.TextColor3 = Color3.fromRGB(255, 255, 255)

local BtnFiltrar = Instance.new("TextButton", Panel)
BtnFiltrar.Size = UDim2.new(0, 105, 0, 35)
BtnFiltrar.Position = UDim2.new(0, 122, 0, 90)
BtnFiltrar.BackgroundColor3 = Color3.fromRGB(180, 120, 0)
BtnFiltrar.Text = "⏳ Filtrar"
BtnFiltrar.TextColor3 = Color3.fromRGB(255, 255, 255)

local BtnBypassMasivo = Instance.new("TextButton", Panel)
BtnBypassMasivo.Size = UDim2.new(0, 115, 0, 35)
BtnBypassMasivo.Position = UDim2.new(0, 235, 0, 90)
BtnBypassMasivo.BackgroundColor3 = Color3.fromRGB(0, 120, 180)
BtnBypassMasivo.Text = "🌍 Auto Server Hack"
BtnBypassMasivo.TextColor3 = Color3.fromRGB(255, 255, 255)

-- CONTENEDOR DE LÍNEAS INDIVIDUALES (IGUAL A iGG)
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
InputMod.PlaceholderText = "Monto a Inyectar..."
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
local maxItems = math.min(#RGG.Resultados, 40)
for i = 1, maxItems do
local res = RGG.Resultados[i]
local Fila = Instance.new("Frame", ContenedorLista)
Fila.Size = UDim2.new(1, 0, 0, 30)
Fila.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
local BotonSeleccionar = Instance.new("TextButton", Fila)
BotonSeleccionar.Size = UDim2.new(0, 260, 1, 0)
BotonSeleccionar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
BotonSeleccionar.Text = string.format(" [%02d] %s ➔ (%s)", i, res.Nombre, tostring(res.UltimoValor))
BotonSeleccionar.TextColor3 = res.Tipo == "Remote" and Color3.fromRGB(255, 180, 50) or Color3.fromRGB(230, 230, 230)
BotonSeleccionar.TextXAlignment = Enum.TextXAlignment.Left
BotonSeleccionar.Font = Enum.Font.SourceSans
BotonSeleccionar.TextSize = 14
local IndicadorFreeze = Instance.new("TextLabel", Fila)
IndicadorFreeze.Size = UDim2.new(0, 70, 1, 0)
IndicadorFreeze.Position = UDim2.new(0, 260, 0, 0)
IndicadorFreeze.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
IndicadorFreeze.Text = "Desfijado"
IndicadorFreeze.TextColor3 = Color3.fromRGB(120, 120, 120)
IndicadorFreeze.TextSize = 12
if RGG.Congelados[res.Instancia] or RGG.ModificadoresRed[res.Instancia] then
IndicadorFreeze.Text = "🔒 REAL HACK"
IndicadorFreeze.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
IndicadorFreeze.TextColor3 = Color3.fromRGB(255, 255, 255)
end
if RGG.IndiceSeleccionado == i then
BotonSeleccionar.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
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
LabelEstado.Text = "Escan..."
task.wait(0.01)
local t = RGG.Buscar(InputValor.Text)
LabelEstado.Text = "Líneas: " .. t
RGG.IndiceSeleccionado = nil
refrescarListaVisual()
end)
BtnFiltrar.MouseButton1Click:Connect(function()
LabelEstado.Text = "Filtr..."
task.wait(0.01)
local t = RGG.Refinar(InputValor.Text)
LabelEstado.Text = "Líneas: " .. t
RGG.IndiceSeleccionado = nil
refrescarListaVisual()
end)
BtnEjecutarHack.MouseButton1Click:Connect(function()
if InputMod.Text == "" or not RGG.IndiceSeleccionado then return end
-- MODIFICACIÓN Y BLOQUEO SELECTIVO INDIVIDUAL
RGG.ModificarEspecifico(RGG.IndiceSeleccionado, InputMod.Text, true)
LabelEstado.Text = "Bloqueado ["..RGG.IndiceSeleccionado.."]"
task.wait(0.1)
refrescarListaVisual()
end)
BtnBypassMasivo.MouseButton1Click:Connect(function()
if InputMod.Text == "" then return end
RGG.ValorBypassGlobal = tonumber(InputMod.Text)
LabelEstado.Text = "Servidor Forzado"
end)
BtnLimpiar.MouseButton1Click:Connect(function()
RGG.Limpiar()
LabelEstado.Text = "Líneas: 0"
InputValor.Text = ""
InputMod.Text = ""
InputMod.PlaceholderText = "Monto a Inyectar..."
refrescarListaVisual()
end)
