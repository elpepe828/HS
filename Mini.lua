-- ===================================================================
-- MINI WAR COLOSSAL WORKER FORCE MULTIPLIER (STEALTH EDITION)
-- Features: Remote Crop Auto-Harvest + 10,000x Single Worker Efficiency
-- Instructions: Execute directly in Delta.
-- ===================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local MiniWarUltimate = {
    Interval = 0.4,
    ColossalForce = 10000 -- One single worker will hit with the power of 10,000 workers
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

-- 2. FORCE MULTIPLIER ENGINE FOR ACTIVE UNITS
local function injectColossalWorkerForce()
    pcall(function()
        -- Scan the Garbage Collector to modify the action power variable of the active builder
        local garbage = getgc(true)
        for _, t in ipairs(garbage) do
            if type(t) == "table" then
                for k, v in pairs(t) do
                    if type(k) == "string" and type(v) == "number" then
                        local keyLower = string.lower(k)
                        
                        -- Target variables that dictate how much progress a single worker contributes per second
                        if string.find(keyLower, "efficiency") or string.find(keyLower, "buildpower") or string.find(keyLower, "workforce") or string.find(keyLower, "repairamount") or string.find(keyLower, "damage") then
                            -- Apply the colossal force block to the structural calculation
                            if v < MiniWarUltimate.ColossalForce then
                                t[k] = MiniWarUltimate.ColossalForce
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- ===================================================================
-- CORE EXECUTION SYSTEM THREAD
-- ===================================================================
task.spawn(function()
    print("[RGG Mini War Pro v7.0] Colossal Worker Multiplier Initialized.")
    while true do
        autoHarvestCrops()
        injectColossalWorkerForce()
        task.wait(MiniWarUltimate.Interval)
    end
end)
