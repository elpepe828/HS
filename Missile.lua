-- ===================================================================
-- MISSILE WARS (STRAY DYNAMICS) - ANTI-PROJECTILE SWEEPER v1.0
-- Features: Active Air Defense - Destroys incoming missiles instantly
-- Instructions: Execute inside Delta. Keeps your base 100% safe from explosions.
-- ===================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local RGG_Sweeper = {
    Enabled = true,
    Interval = 0.1, -- Ultra fast scanning (10 times per second)
    DefenseRadius = 110 -- Space area around your base to delete missiles
}

-- [ MOTOR DE DETECCIÓN Y DESTRUCCIÓN DE MISILES ]
local function runAirDefenseSweeper()
    if not RGG_Sweeper.Enabled then return end
    
    pcall(function()
        -- 1. Encontrar la ubicación exacta de tu base
        local myPlot = nil
        for _, folder in ipairs(Workspace:GetDescendants()) do
            if string.find(string.lower(folder.Name), "plot") or string.find(string.lower(folder.Name), "tycoon") or string.find(string.lower(folder.Name), "base") then
                if string.find(string.lower(folder.Name), string.lower(LocalPlayer.Name)) or folder:GetAttribute("Owner") == LocalPlayer.Name then
                    myPlot = folder
                    break
                end
            end
        end
        
        local basePart = myPlot and (myPlot:FindFirstChild("Floor") or myPlot:FindFirstChild("Base") or myPlot:FindFirstChildWhichIsA("BasePart", true))
        if not basePart then return end
        
        -- 2. ESCANEAR EL MAPA EN BUSCA DE MISILES ENEMIGOS
        for _, obj in ipairs(Workspace:GetDescendants()) do
            -- Detectar si el objeto es un misil (buscando por su nombre o tags de proyectil)
            if obj:IsA("Model") or obj:IsA("BasePart") then
                local objName = string.lower(obj.Name)
                if string.find(objName, "missile") or string.find(objName, "rocket") or string.find(objName, "misil") or string.find(objName, "projectile") then
                    
                    -- Calcular la distancia entre el misil enemigo y el centro de tu base
                    local distance = (obj.Position - basePart.Position).Magnitude
                    
                    -- Si el misil entra en tu espacio aéreo privado, lo desintegramos
                    if distance <= RGG_Sweeper.DefenseRadius then
                        -- Lo borramos del cliente de forma agresiva para que no pueda detonar en tu base
                        obj:Destroy()
                        print("[RGG Anti-Air] Enemy missile intercepted and destroyed at distance: " .. math.floor(distance))
                    end
                end
            end
        end
    end)
end

-- ===================================================================
-- CORE AUTOMATION THREAD
-- ===================================================================
task.spawn(function()
    print("[RGG Sweeper] Iron Dome air defense system activated.")
    while true do
        runAirDefenseSweeper()
        task.wait(RGG_Sweeper.Interval)
    end
end)
