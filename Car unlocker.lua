-- ===================================================================
-- PROJECT RGG: HIGHWAY SHOWDOWN - STAGE 4 TUNING BYPASS (STEALTH)
-- Features: Local Vehicle Performance Injector (Bypasses Gamepass Lock)
-- ===================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- [ CONFIGURATION: MULTIPLIERS FOR STAGE 4 TUNING PERFORMANCE ]
local PerformanceConfig = {
    MaxSpeedMultiplier = 1.35, -- Increases top speed by 35%
    TorqueMultiplier = 1.40,   -- Increases acceleration/torque by 40%
    HorsePowerBoost = 450      -- Adds flat raw power to the engine data
}

local function applyStage4Tuning()
    -- Localizar el carro actual del jugador en el Workspace
    local character = LocalPlayer.Character
    if not character then return print("[RGG] Character not found.") end
    
    local currentVehicle = nil
    
    -- Escaneo pasivo del coche en el que estás sentado
    for _, vehicle in ipairs(Workspace:GetDescendants()) do
        if vehicle:IsA("Model") and vehicle:FindFirstChild("DriveSeat") then
            if vehicle.DriveSeat.Occupant and vehicle.DriveSeat.Occupant.Parent == character then
                currentVehicle = vehicle
                break
            end
        end
    end
    
    if currentVehicle then
        pcall(function()
            print("[RGG] Tuning injected into: " .. currentVehicle.Name)
            
            -- Recorrer la configuración de físicas de las ruedas y motor del vehículo
            for _, prop in ipairs(currentVehicle:GetDescendants()) do
                -- Ajuste de velocidad máxima nativa
                if string.find(string.lower(prop.Name), "maxspeed") or string.find(string.lower(prop.Name), "topspeed") then
                    if prop:IsA("NumberValue") or prop:IsA("IntValue") then
                        prop.Value = prop.Value * PerformanceConfig.MaxSpeedMultiplier
                    end
                end
                
                -- Ajuste de aceleración y fuerza del motor (Torque)
                if string.find(string.lower(prop.Name), "torque") or string.find(string.lower(prop.Name), "horsepower") or string.find(string.lower(prop.Name), "engine") then
                    if prop:IsA("NumberValue") or prop:IsA("IntValue") then
                        prop.Value = prop.Value * PerformanceConfig.TorqueMultiplier + PerformanceConfig.HorsePowerBoost
                    end
                end
                
                -- Desbloqueo visual de opciones de Stage dentro del chasis local
                if string.find(string.lower(prop.Name), "stage") or string.find(string.lower(prop.Name), "tunelevel") then
                    if prop:IsA("IntValue") then
                        prop.Value = 4 -- Forces vehicle configuration data to read as Stage 4
                    end
                end
            end
            print("[RGG Stealth] Stage 4 modifications applied successfully!")
        end)
    else
        print("[RGG] You must be sitting inside a vehicle to apply the Stage 4 upgrade.")
    end
end

-- ===================================================================
-- AUTOMATIC TIMED INTERPOLATION LOOP (SINCRO CONSTANTE TIPO iGG)
-- ===================================================================
task.spawn(function()
    while true do
        -- Escanea y aplica las mejoras de Stage 4 automáticamente cada vez que manejas
        applyStage4Tuning()
        task.wait(2.5) -- Espera pasiva segura para no alertar al Anti-Cheat de telemetría
    end
end)
