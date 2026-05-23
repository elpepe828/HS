-- ===================================================================
-- MINI WAR STATE-SPOOFER & HARVEST ENGINE v10.0 (EXCLUSIVE)
-- Features: Remote Crop Auto-Harvest + Logical State Overrider (Instant Built)
-- Instructions: Execute directly in Delta. No re-log needed if successful!
-- ===================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local MiniWarState = {
    Interval = 0.3
}

-- 1. UNIVERSAL CROP AND HARVEST COLLECTOR
local function autoHarvestCrops()
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ClickDetector") then
                local parentName = string.lower(obj.Parent.Name)
                if string.find(parentName, "farm") or string.find(parentName, "crop") or string.find(parentName, "harvest") or string.find(parentName, "resource") or string.find(parentName, "collect") or string.find(parentName, "mine") then
                    fireclickdetector(obj, 0)
                end
            end
            
            if obj:IsA("ProximityPrompt") then
                local promptName = string.lower(obj.ObjectText or obj.ActionText)
                if string.find(promptName, "harvest") or string.find(promptName, "collect") or string.find(promptName, "gather") or string.find(promptName, "claim") then
                    obj:InputHoldBegin()
                    task.wait()
                    obj:InputHoldEnd()
                end
            end
        end
    end)
end

-- ===================================================================
-- 2. LOGICAL STATE OVERRIDER (MANDA SEÑAL DE "YA CONSTRUIDO")
-- ===================================================================
local function runStateOverrider()
    pcall(function()
        -- Escanear la memoria oculta de las tablas de los scripts de la base (Garbage Collector)
        local garbage = getgc(true)
        for _, t in ipairs(garbage) do
            if type(t) == "table" then
                -- Verificar si es una tabla que maneja el estado de una estructura o una obra
                if t["Building"] or t["UpgradeData"] or t["ConstructionData"] or t["StructureState"] then
                    
                    -- Cambiar el estado booleano de la obra: decirle que ya NO está construyendo
                    if t["IsBuilding"] ~= nil then t["IsBuilding"] = false end
                    if t["Constructing"] ~= nil then t["Constructing"] = false end
                    if t["UnderConstruction"] ~= nil then t["UnderConstruction"] = false end
                    
                    -- Cambiar el estado lógico de la obra: decirle que SÍ está terminada por completo
                    if t["IsCompleted"] ~= nil then t["IsCompleted"] = true end
                    if t["Finished"] ~= nil then t["Finished"] = true end
                    if t["Built"] ~= nil then t["Built"] = true end
                    if t["State"] ~= nil and type(t["State"]) == "string" then
                        if string.lower(t["State"]) == "building" then
                            t["State"] = "Built" -- Forzar el estado de "Construyendo" a "Construido"
                        end
                    end
                end
            end
        end

        -- Aplicar la misma re-escritura lógica a los atributos físicos de los modelos en el mapa
        for _, model in ipairs(Workspace:GetDescendants()) do
            if model:IsA("Model") then
                -- Si el edificio tiene un atributo de estado, lo cambiamos a Completado de inmediato
                if model:GetAttribute("State") and string.lower(tostring(model:GetAttribute("State"))) == "building" then
                    model:SetAttribute("State", "Built")
                end
                if model:GetAttribute("IsBuilding") ~= nil then model:SetAttribute("IsBuilding", false) end
                if model:GetAttribute("IsCompleted") ~= nil then model:SetAttribute("IsCompleted", true) end
            end
        end
    end)
end

-- ===================================================================
-- EXECUTIVE BACKGROUND DESYNC LOOP
-- ===================================================================
task.spawn(function()
    print("[RGG Mini War v10.0] Logical State Overrider successfully injected.")
    while true do
        autoHarvestCrops()
        runStateOverrider()
        task.wait(MiniWarState.Interval)
    end
end)
