-- ===================================================================
-- PROJECT RGG: ROBLOX GAME GUARDIAN (Versión Definitiva para Delta)
-- ===================================================================

local RGG = {
    Resultados = {},
    Congelados = {},
    TiposValores = {"NumberValue", "IntValue", "DoubleConstrainedValue"},
    HiloFreeze = nil
}

-- [ MOTOR DE MEMORIA INTERNO ]
local function procesarConPausas(lista, accion)
    for i, elemento in ipairs(lista) do
        accion(elemento)
        if i % 1500 == 0 then task.wait() end
    end
end

function RGG.Buscar(valor)
    RGG.Resultados = {}
    local objetivo = tonumber(valor)
    local todos = game:GetDescendants()
    procesarConPausas(todos, function(obj)
        if table.find(RGG.TiposValores, obj.ClassName) then
            if not objetivo or obj.Value == objetivo then
                table.insert(RGG.Resultados, {Instancia = obj, Tipo = "Value", UltimoValor = obj.Value})
            end
        end
        local attrs = obj:GetAttributes()
        for n, v in pairs(attrs) do
            if type(v) == "number" and (not objetivo or v == objetivo) then
                table.insert(RGG.Resultados, {Instancia = obj, Tipo = "Attribute", Nombre = n, UltimoValor = v})
            end
        end
    end)
    return #RGG.Resultados
end

function RGG.Refinar(modo, valor)
    if #RGG.Resultados == 0 then return 0 end
    local num = tonumber(valor)
    local nuevos = {}
    procesarConPausas(RGG.Resultados, function(res)
        local valAct = nil
        pcall(function()
            valAct = res.Tipo == "Value" and res.Instancia.Value or res.Instancia:GetAttribute(res.Nombre)
        end)
        if not valAct then return end
        local cumple = false
        if modo == "Exacto" and valAct == num then cumple = true
        elseif modo == "Mayor" and valAct > res.UltimoValor then cumple = true
        elseif modo == "Menor" and valAct < res.UltimoValor then cumple = true
        elseif modo == "Cambiado" and valAct ~= res.UltimoValor then cumple = true end
        if cumple then
            res.UltimoValor = valAct
            table.insert(nuevos, res)
        end
    end)
    RGG.Resultados = nuevos
    return #RGG.Resultados
end

function RGG.Modificar(valor, congelar)
    local num = tonumber(valor)
    for _, res in ipairs(RGG.Resultados) do
        pcall(function()
            if res.Tipo == "Value" then res.Instancia.Value = num
            else res.Instancia:SetAttribute(res.Nombre, num) end
            if congelar then table.insert(RGG.Congelados, {Res = res, Valor = num}) end
        end)
    end
    if congelar and not RGG.HiloFreeze then
        RGG.HiloFreeze = task.spawn(function()
            while #RGG.Congelados > 0 do
                for _, item in ipairs(RGG.Congelados) do
                    pcall(function()
                        if item.Res.Tipo == "Value" then item.Res.Instancia.Value = item.Valor
                        else item.Res.Instancia:SetAttribute(item.Res.Nombre, item.Valor) end
                    end)
                end
                task.wait(0.1)
            end
        end)
    end
end

function RGG.Limpiar()
    RGG.Resultados = {}
    RGG.Congelados = {}
    if RGG.HiloFreeze then task.cancel(RGG.HiloFreeze); RGG.HiloFreeze = nil end
end

-- ===================================================================
-- INTERFAZ GRÁFICA INTERACTIVA (GUI ESTILO GG)
-- ===================================================================
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "RGG_Console"

-- Botón Flotante para abrir/cerrar
local IconoGG = Instance.new("TextButton", ScreenGui)
IconoGG.Size = UDim2.new(0, 55, 0, 55)
IconoGG.Position = UDim2.new(0, 10, 0, 150)
IconoGG.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
IconoGG.Text = "RGG"
IconoGG.TextColor3 = Color3.fromRGB(0, 255, 150)
IconoGG.Font = Enum.Font.SourceSansBold
IconoGG.TextSize = 20
IconoGG.Active = true
IconoGG.Draggable = true -- Permite arrastrar el botón por la pantalla

-- Panel Principal
local Panel = Instance.new("Frame", ScreenGui)
Panel.Size = UDim2.new(0, 320, 0, 240)
Panel.Position = UDim2.new(0.5, -160, 0.4, -120)
Panel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Panel.Visible = false
Panel.Active = true
Panel.Draggable = true

local Titulo = Instance.new("TextLabel", Panel)
Titulo.Size = UDim2.new(1, 0, 0, 30)
Titulo.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Titulo.Text = " ROBLOX GAME GUARDIAN (RGG)"
Titulo.TextColor3 = Color3.fromRGB(255, 255, 255)
Titulo.TextXAlignment = Enum.TextXAlignment.Left
Titulo.Font = Enum.Font.SourceSansBold

-- Input de valor
local InputValor = Instance.new("TextBox", Panel)
InputValor.Size = UDim2.new(0, 200, 0, 35)
InputValor.Position = UDim2.new(0, 10, 0, 45)
InputValor.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
InputValor.PlaceholderText = "Ingresa el número..."
InputValor.Text = ""
InputValor.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Etiqueta de Estado / Resultados
local LabelEstado = Instance.new("TextLabel", Panel)
LabelEstado.Size = UDim2.new(0, 90, 0, 35)
LabelEstado.Position = UDim2.new(0, 220, 0, 45)
LabelEstado.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
LabelEstado.Text = "Res: 0"
LabelEstado.TextColor3 = Color3.fromRGB(0, 255, 255)

-- Botón Buscar
local BtnBuscar = Instance.new("TextButton", Panel)
BtnBuscar.Size = UDim2.new(0, 95, 0, 35)
BtnBuscar.Position = UDim2.new(0, 10, 0, 95)
BtnBuscar.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
BtnBuscar.Text = "Nueva Buscar"
BtnBuscar.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Botón Filtrar
local BtnFiltrar = Instance.new("TextButton", Panel)
BtnFiltrar.Size = UDim2.new(0, 95, 0, 35)
BtnFiltrar.Position = UDim2.new(0, 112, 0, 95)
BtnFiltrar.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
BtnFiltrar.Text = "Refinar (Exacto)"
BtnFiltrar.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Botón Limpiar
local BtnLimpiar = Instance.new("TextButton", Panel)
BtnLimpiar.Size = UDim2.new(0, 95, 0, 35)
BtnLimpiar.Position = UDim2.new(0, 215, 0, 95)
BtnLimpiar.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
BtnLimpiar.Text = "Limpiar Todo"
BtnLimpiar.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Sección Modificación
local InputMod = Instance.new("TextBox", Panel)
InputMod.Size = UDim2.new(0, 150, 0, 35)
InputMod.Position = UDim2.new(0, 10, 0, 145)
InputMod.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
InputMod.PlaceholderText = "Nuevo Valor Hack..."
InputMod.Text = ""
InputMod.TextColor3 = Color3.fromRGB(255, 255, 255)

local BtnHack = Instance.new("TextButton", Panel)
BtnHack.Size = UDim2.new(0, 140, 0, 35)
BtnHack.Position = UDim2.new(0, 170, 0, 145)
BtnHack.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
BtnHack.Text = "Modificar y Congelar"
BtnHack.TextColor3 = Color3.fromRGB(255, 255, 255)

-- ===================================================================
-- LOGICA DE INTERACCION DE LA INTERFAZ
-- ===================================================================
IconoGG.MouseButton1Click:Connect(function()
    Panel.Visible = not Panel.Visible
end)

BtnBuscar.MouseButton1Click:Connect(function()
    LabelEstado.Text = "Buscando..."
    task.wait(0.05)
    local cont = RGG.Buscar(InputValor.Text)
    LabelEstado.Text = "Res: " .. cont
end)

BtnFiltrar.MouseButton1Click:Connect(function()
    LabelEstado.Text = "Filtrando..."
    task.wait(0.05)
    local cont = RGG.Refinar("Exacto", InputValor.Text)
    LabelEstado.Text = "Res: " .. cont
end)

BtnLimpiar.MouseButton1Click:Connect(function()
    RGG.Limpiar()
    LabelEstado.Text = "Res: 0"
    InputValor.Text = ""
    InputMod.Text = ""
end)

BtnHack.MouseButton1Click:Connect(function()
    if InputMod.Text ~= "" then
        RGG.Modificar(InputMod.Text, true)
        LabelEstado.Text = "¡Bloqueado!"
    end
end)
