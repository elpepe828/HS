-- ===================================================================
-- MINI WAR GLOBAL TIME SPOOFER v12.0 (UNIVERSAL TIME RANGE ENGINE)
-- Features: Remote Crop Auto-Harvest + Absolute Universal Timer Flattening
-- Target Range: From 10 seconds to multiple days (Infinite Seconds Support)
-- ===================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local MiniWarGlobal = {
    Interval = 0.3,
    AbsoluteZero = 0 -- The ultimate target value for all construction clocks
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
-- 2. ABSOLUTE UNIVERSAL TIMER FLATTENER (NO BOUNDARIES / INF TIME SUPPORT)
-- ===================================================================
local function runGlobalTimeFlattener()
    pcall(function()
        -- Palabras clave exclusivas de construcción para proteger el sistema operativo del juego
        local buildingKeywords = {"time", "timer", "duration", "build", "progress", "cooldown", "remaining", "seconds", "finish"}
        
        for _, model in ipairs(Workspace:GetDescendants()) do
            if model:IsA("Model") then
                -- A. Sobreescribir cualquier Atributo numérico de tiempo sin importar su tamaño
                local attributes = model:GetAttributes()
                for name, value in pairs(attributes) do
                    local nameLower = string.lower(name)
                    if type(value) == "number" and value > 0 then
                        -- El script verifica si el nombre coincide con el tiempo, ignorando el valor numérico
                        for _, keyword in ipairs(buildingKeywords) do
                            if string.find(nameLower, keyword) then
                                model:SetAttribute(name, MiniWarGlobal.AbsoluteZero)
                                break
                            end
                        end
                    end
                end
                
                -- B. Sobreescribir cualquier instancia IntValue/NumberValue hija dentro de las estructuras
                for _, child in ipairs(model:GetChildren()) do
                    if child:IsA("IntValue") or child:IsA("NumberValue") then
                        local childName = string.lower(child.Name)
                        if child.Value > 0 then
                            for _, keyword in ipairs(buildingKeywords) do
                                if string.find(childName, keyword) then
                                    child.Value = MiniWarGlobal.AbsoluteZero
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
        
        -- C. Sobreescribir registros en el Garbage Collector sin límites matemáticos de escala
        local garbage = getgc(true)
        for _, t in ipairs(garbage) do
            if type(t) == "table" then
                for k, v in pairs(t) do
                    if type(k) == "string" and type(v) == "number" and v > 0 then
                        local keyLower = string.lower(k)
                        for _, keyword in ipairs(buildingKeywords) do
                            if string.find(keyLower, keyword) then
                                t[k] = MiniWarGlobal.AbsoluteZero
                                break
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- ===================================================================
-- CORE MOTOR PROCESS
-- ===================================================================
task.spawn(function()
    print("[RGG Mini War Global v12.0] Infinite Time Scale Engine fully initialized.")
    while true do
        autoHarvestCrops()
        runGlobalTimeFlattener()
        task.wait(MiniWarGlobal.Interval)
    end
end)
