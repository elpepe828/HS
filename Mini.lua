-- ===================================================================
-- MINI WAR ADVANCED HARVESTER & CONSTRUCTION MANAGEMENT
-- Features: Remote Crop Auto-Harvest + Construction Completion Stimulator
-- Instructions: Copy and execute directly inside Delta.
-- ===================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local MiniWarHacks = {
    HarvestInterval = 0.5 -- Scans crops and buildings 2 times per second
}

-- 1. AUTO-HARVEST ENGINE (COSECHAS E ICONOS FLOTANTES)
local function autoHarvestCrops()
    pcall(function()
        -- Scan the workspace for plots, farms, or buildings that have a click collector
        for _, obj in ipairs(Workspace:GetDescendants()) do
            -- Method A: Simulate clicking the floating crop/harvest icons natively
            if obj:IsA("ClickDetector") then
                local parentName = string.lower(obj.Parent.Name)
                -- Check for keywords related to crops, farms, food, or resources in Mini War
                if string.find(parentName, "farm") or string.find(parentName, "crop") or string.find(parentName, "harvest") or string.find(parentName, "resource") or string.find(parentName, "collect") or string.find(parentName, "mine") then
                    -- Fire the click detector from any distance instantly
                    fireclickdetector(obj, 0)
                end
            end
            
            -- Method B: Trigger ProximityPrompts for gathering systems
            if obj:IsA("ProximityPrompt") then
                local promptName = string.lower(obj.ObjectText or obj.ActionText)
                if string.find(promptName, "harvest") or string.find(promptName, "collect") or string.find(promptName, "gather") or string.find(promptName, "claim") then
                    -- Simulate holding the interaction key instantly
                    obj:InputHoldBegin()
                    task.wait()
                    obj:InputHoldEnd()
                end
            end
        end
    end)
end

-- 2. CONSTRUCTION TIME REDUCTION STIMULATOR (15+ MINUTE TIMERS)
local function autoStimulateConstruction()
    pcall(function()
        -- Locate active construction nodes inside the workspace structures
        for _, model in ipairs(Workspace:GetDescendants()) do
            if model:IsA("Model") then
                -- Check for building attributes that hold server-synced remaining seconds
                local attributes = model:GetAttributes()
                for name, value in pairs(attributes) do
                    local nameLower = string.lower(name)
                    if string.find(nameLower, "time") or string.find(nameLower, "duration") or string.find(nameLower, "build") or string.find(nameLower, "progress") then
                        if type(value) == "number" and value > 0 then
                            -- Force the local state to zero to drop the wait barrier
                            model:SetAttribute(name, 0)
                        end
                    end
                end
                
                -- Force child values that handle internal client timers
                for _, child in ipairs(model:GetChildren()) do
                    if child:IsA("IntValue") or child:IsA("NumberValue") then
                        local childName = string.lower(child.Name)
                        if string.find(childName, "time") or string.find(childName, "timer") or string.find(childName, "duration") then
                            child.Value = 0
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
    print("[RGG Mini War Master v2] English Dedicated Script Loaded Successfully.")
    while true do
        autoHarvestCrops()
        autoStimulateConstruction()
        task.wait(MiniWarHacks.HarvestInterval)
    end
end)
