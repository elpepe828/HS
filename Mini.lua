-- ===================================================================
-- MINI WAR POPULATION SPOOFER & HARVEST ENGINE v6.0
-- Features: Fake Builder Count Injection (Multiplier Bypass) + Auto Harvest
-- Instructions: Execute directly in Delta.
-- ===================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local MiniWarConfig = {
    Interval = 0.4,
    FakeWorkersAmount = 9999 -- Simulates 9,999 workers hitting the building at the same time
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

-- 2. BUILDER COUNT SPOOFER ENGINE (FALSIFICADOR DE TRABAJADORES ACTIVOS)
local function injectFakeWorkerCount()
    pcall(function()
        -- Step A: Scan for physical values that update the builder display
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("IntValue") or obj:IsA("NumberValue") then
                local nameLower = string.lower(obj.Name)
                
                -- Target builder count variables assigned to active structural tasks
                if string.find(nameLower, "workercount") or string.find(nameLower, "buildercount") or string.find(nameLower, "activebuilders") or string.find(nameLower, "assignedworkers") or string.find(nameLower, "currentbuilders") then
                    obj.Value = MiniWarConfig.FakeWorkersAmount
                end
            end
        end
        
        -- Step B: Deep loop inside local memory tables to spoof local script logic calculations
        local garbage = getgc(true)
        for _, t in ipairs(garbage) do
            if type(t) == "table" then
                for k, v in pairs(t) do
                    if type(k) == "string" and type(v) == "number" then
                        local keyLower = string.lower(k)
                        
                        -- Look for worker variables inside the local game systems
                        if string.find(keyLower, "builders") or string.find(keyLower, "workers") or string.find(keyLower, "numworkers") or string.find(keyLower, "totalbuilders") or string.find(keyLower, "activeworkers") then
                            -- Only override if it handles current building stats to avoid messing up unit spawners
                            if t["Building"] or t["Construction"] or t["Progress"] or string.find(keyLower, "count") or string.find(keyLower, "amount") then
                                t[k] = MiniWarConfig.FakeWorkersAmount
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- ===================================================================
-- EXECUTIVE SYSTEM LOOP
-- ===================================================================
task.spawn(function()
    print("[RGG Mini War Pro v6.0] Universal Population Spoofer Active.")
    while true do
        autoHarvestCrops()
        injectFakeWorkerCount()
        task.wait(MiniWarConfig.Interval)
    end
end)
