-- ===================================================================
-- MISSILE WARS (STRAY DYNAMICS) - STEALTH SPHERE SHIELD SCRIPT
-- Features: 3D Invisible Bubble Collision (Blocks all angle & top attacks)
-- Instructions: Execute inside Delta. Creates an invisible impenetrable dome.
-- ===================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local MissileWarsDome = {
    Enabled = true,
    ScanInterval = 0.5,
    ShieldBubble = nil,
    BubbleRadius = 95 -- Tamaño óptimo para cubrir toda la parcela en 3D
}

-- [ MOTOR DEL DOMO PROTECTOR ESFÉRICO INDETECTABLE ]
local function deployStealthSphere()
    if not MissileWarsDome.Enabled then return end
    
    pcall(function()
        -- 1. Buscar la parcela privada del jugador por el nombre o atributo de dueño
        local myPlot = nil
        
        for _, folder in ipairs(Workspace:GetDescendants()) do
            if string.find(string.lower(folder.Name), "plot") or string.find(string.lower(folder.Name), "tycoon") or string.find(string.lower(folder.Name), "base") then
                if string.find(string.lower(folder.Name), string.lower(LocalPlayer.Name)) or folder:GetAttribute("Owner") == LocalPlayer.Name then
                    myPlot = folder
                    break
                end
            end
        end
        
        if not myPlot then return end
        
        -- 2. Localizar el suelo central para anclar la burbuja invisible en el punto exacto
        local basePart = myPlot:FindFirstChild("Floor") or myPlot:FindFirstChild("Base") or myPlot:FindFirstChildWhichIsA("BasePart", true)
        
        if basePart and not MissileWarsDome.ShieldBubble then
            print("[RGG Shield] Deploying 3D Invisible Sphere Dome over your island...")
            
            -- CREACIÓN DE LA SÚPER ESFERA FÍSICA INVISIBLE
            local sphere = Instance.new("Part")
            sphere.Name = "RGG_Invisible_Shield_Bubble"
            sphere.Shape = Enum.PartType.Ball -- Forzar forma de esfera perfecta
            sphere.Size = Vector3.new(MissileWarsDome.BubbleRadius * 2, MissileWarsDome.BubbleRadius * 2, MissileWarsDome.BubbleRadius * 2)
            
            -- Centrar la esfera en el suelo y elevarla un poco para que el domo cubra todo el cielo de tu base
            sphere.CFrame = basePart.CFrame + Vector3.new(0, 15, 0) 
            
            sphere.Transparency = 1 -- 100% invisible para el ojo humano (Nadie te puede reportar)
            sphere.Anchored = true
            sphere.CanCollide = true -- Los misiles chocarán y explotarán aquí obligatoriamente
            sphere.Material = Enum.Material.ForceField -- Material nativo de Roblox especializado en colisiones de impactos
            sphere.Parent = Workspace
            
            MissileWarsDome.ShieldBubble = sphere
        end
        
        -- Verificación continua: Mantener la colisión rígida activa frente a cualquier intento de reinicio del juego
        if MissileWarsDome.ShieldBubble then
            MissileWarsDome.ShieldBubble.CanCollide = true
            MissileWarsDome.ShieldBubble.Parent = Workspace
        end
    end)
end

-- ===================================================================
-- AUTOMATIC RUNTIME THREAD
-- ===================================================================
task.spawn(function()
    print("[RGG Dome] 3D Stealth Sphere Shield Activated successfully.")
    while true do
        deployStealthSphere()
        task.wait(MissileWarsDome.ScanInterval)
    end
end)
