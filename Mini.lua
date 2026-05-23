-- ===================================================================
-- MINI WAR ADVANCED HARVESTER & HYPER-TIME ACCELERATOR
-- Features: Remote Crop Auto-Harvest + Time Warp Engine (Ultra Fast Progression)
-- Instructions: Copy and execute directly inside Delta.
-- ===================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local MiniWarEngine = {
    Interval = 0.1,        -- Execution pulse speed (10 times per second)
    TimeWarpSpeed = 50000  -- Multiplies time progression by 50,000x (Makes 16 minutes pass instantly)
}

-- 1. AUTO-HARVEST ENGINE (COSECHAS E ICONOS FLOTANTES)
local function autoHarvestCrops()
    pcall(function()
        -- Scan the workspace for plots, farms, or buildings that have a click collector
        for _, obj in ipairs(Workspace:GetDescendants()) do
            -- Simulate clicking the floating crop/harvest icons natively
            if obj:IsA("ClickDetector") then
                local parentName = string.lower(obj.Parent.Name)
                if string.find(parentName, "farm") or string.find(parentName, "crop") or string.find(parentName, "harvest") or string.find(parentName, "resource") or string.find(parentName, "collect") or string.find(parentName, "mine") then
                    fireclickdetector(obj, 0)
                end
            end
            
            -- Trigger ProximityPrompts for gathering systems
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

-- 2. TIME WARP PROGRESSION ENGINE (ACELERADOR ULTRA RÁPIDO - ANTI-CONGELAMIENTO)
local function runHyperTimeAccelerator()
    pcall(function()
        -- Step A: Target physical Attributes on active construction models
        for _, model in ipairs(Workspace:GetDescendants()) do
            if model:IsA("Model") then
                local attributes = model:GetAttributes()
                for name, value in pairs(attributes) do
                    local nameLower = string.lower(name)
                    -- Locate any numeric timer managing duration, cooldowns, or build progress
                    if type(value) == "number" and value > 0 then
                        if string.find(nameLower, "time") or string.find(nameLower, "duration") or string.find(nameLower, "build") or string.find(nameLower, "progress") then
                            -- Instead of zeroing out, subtract a massive block of time per pulse to simulate hyper speed
                            local acceleratedValue = value - (1 * MiniWarEngine.TimeWarpSpeed)
                            if acceleratedValue < 0 then acceleratedValue = 0 end
                            model:SetAttribute(name, acceleratedValue)
                        end
                    end
                end
                
                -- Step B: Target active internal value timers inside the building hierarchy
                for _, child in ipairs(model:GetChildren()) do
                    if child:IsA("IntValue") or child:IsA("NumberValue") then
                        local childName = string.lower(child.Name)
                        if string.find(childName, "time") or string.find(childName, "timer") or string.find(childName, "duration") or string.find(childName, "remaining") then
                            if child.Value > 0 then
                                -- Drain the seconds at hyper-sonic speed
                                local newVal = child.Value - (1 * MiniWarEngine.TimeWarpSpeed)
                                if newVal < 0 then newVal = 0 end
                                child.Value = newVal
                            end
                        end
                    end
                end
            end
        end
        
        -- Step C: Scan Garbage Collector local thread clocks to speed up script execution deltas
        local garbage = getgc(true)
        for _, t in ipairs(garbage) do
            if type(t) == "table" then
                for k, v in pairs(t) do
                    if type(k) == "string" and type(v) == "number" and v > 0 then
                        local kLower = string.lower(k)
                        if string.find(kLower, "timer") or string.find(kLower, "cooldown") or string.find(kLower, "buildtime") then
                            local dynamicWarp = v - (0.1 * MiniWarEngine.TimeWarpSpeed)
                            if dynamicWarp < 0 then dynamicWarp = 0 end
                            t[k] = dynamicWarp
                        end
                    end
                end
            end
        end
    end)
end

-- ===================================================================
-- EXECUTIVE BACKGROUND THREAD LOOP
-- ===================================================================
task.spawn(function()
    print("[RGG Mini War Master v3] Time Warp Engine successfully loaded.")
    while true do
        autoHarvestCrops()
        runHyperTimeAccelerator()
        task.wait(MiniWarEngine.Interval)
    end
end)
